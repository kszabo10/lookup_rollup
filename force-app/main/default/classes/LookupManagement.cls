/***
 * ===================================================================
 * @version     
 * @date        
 * @description 
 * 				
 * ===================================================================
**/
public class LookupManagement {
	
	public static Boolean isLookupManagementExecuting = false;

	public static final Map<String, List<RollupOperation__c>> rollupOperationMap {
		get{
			if(rollupOperationMap == null){
				rollupOperationMap = new Map<String, List<RollupOperation__c>>();
				for(RollupOperation__c rollupRecord : [SELECT Id, Name, ChildFieldAPI__c, ChildObjectAPI__c, IsActive__c, 
																	LookupFieldAPI__c, Operation__c, ParentObjectAPI__c, 
																	ParentRollupFieldAPI__c, QueryCondition__c
															FROM RollupOperation__c
															WHERE IsActive__c = true]){
					if(!rollupOperationMap.containsKey(rollupRecord.ChildObjectAPI__c)){
						rollupOperationMap.put(rollupRecord.ChildObjectAPI__c, new List<RollupOperation__c>());
					}
					rollupOperationMap.get(rollupRecord.ChildObjectAPI__c).add(rollupRecord);
				}
				return rollupOperationMap;
			}else{
				return rollupOperationMap;
			}
		}
		set;
	}

	/*
	* Create all defined Rollup based on input child SObject records 
	* and based on the input Wrapper information and the sObjectName
	* The method is to be invoked from the TriggerHandler, in the AFTER event handler methods
	* Inputs
	* - newRecords: equals with Trigger.newMap, it may be null
	* - oldRecords: equals with Trigger.oldMap, it may be also be null
	* - triggerType: for debugging purpose only, it could also be retrieved from the context
	*/
	public static void calculateAllRollups(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords, String triggerType){
		// calculateAllRollups should not trigger itself to prevent recursion
		if(isLookupManagementExecuting){
			return;
		}
		System.debug('calucalteAllRollups STARTS');
		isLookupManagementExecuting = true;

		Set<Id> originalParentIds = new Set<Id>();					// Refers to the Parent record IDs. May change for each lookup definition in each wrapper
		List<SObject> toUpdateSObjects = new List<SObject>();		// Parent SObjects which will be updated due to rollups		
		Map<Id, SObject> toUpdateSObjectsMap = new Map<Id, SOBject>();

		// Find out the child sObject's sObjectName
		List<Id> recordIdList = newRecords == null ? new List<Id>(oldRecords.keySet()) : new List<Id>(newRecords.keySet());

		// select either the newRecords or the oldRecords, the latter in case of Delete operation
		Map<Id, SObject> toBeUsedRecords = getToBeUsedRecords(newRecords, oldRecords);	// selects either the newRecords or the oldRecords
		String sObjectName = MetaUtils.getSObjectName(recordIdList.get(0));

		// Get the wrappers based on the RollupOperation__c Object's relevant records
		List<LookupWrapper> wrapperRecords = createRollupWrappers(sObjectName);

    	// for each defined wrapper (Rollup Operation), loop over them
		for(LookupWrapper wrapperRecord : wrapperRecords){

			// Collect parent records' Id's from the original triggered records
			originalParentIds = getParentRecordIds(toBeUsedRecords, oldRecords, wrapperRecord);
			if(originalParentIds.size() == 0){
				continue;
			}
			String queryString = createQueryString(wrapperRecord);
			System.debug('queryString = ' + queryString);
            List<SObject> returnedSObjectList = Database.query(queryString);

			// Collect the parent records' Id's after querying for the sibling records
			Set<Id> retrievedParentIds = getRetrievedParentIds(returnedSObjectList, wrapperRecord);

			// Build up the Map of parent Id -> List of related children
			Map<Id, List<SObject>> parentToChildrenMap = new Map<Id, List<SObject>>();

			if(retrievedParentIds.size() < originalParentIds.size()){
				// There is a Parent who has no more related child -> all children have been deleted
				// Parents without children have to be added to the parentToChildrenMap too, without children records
				for(Id originalId : originalParentIds){
					if(retrievedParentIds.contains(originalId) == false){
						parentToChildrenMap.put(originalId, new List<SObject>());
					}
				}
			}

			// Extend the parentToChildren map with records based on the re-queried children siblings
			for(SObject sobj : returnedSObjectList){				
				Id parentRecordId = (Id) sobj.get(wrapperRecord.lookupFieldAPI);
				if(parentRecordId == null){
					// There is no binding between the child and the parent - not considered
					continue;
				}
				if(parentToChildrenMap.containsKey(parentRecordId)){
					parentToChildrenMap.get(parentRecordId).add(sobj);
				}else{
					List<SObject> relatedSObjects = new List<SObject>();
					relatedSObjects.add(sobj);
					parentToChildrenMap.put(parentRecordId, relatedSObjects);
				}
			}
			for(Id parentRecordId : parentToChildrenMap.keySet()){
				Double rollUpValue = RollupCalculation.calculateRollup(parentToChildrenMap.get(parentRecordId), wrapperRecord);
				Type objectType = Type.forName(wrapperRecord.parentObjectAPI); 		//Create a type class instance
				if(toUpdateSObjectsMap.containsKey(parentRecordId)){
					// the same record shall be updated more times in the same DML -> those records need to be consolidated
					toUpdateSObjectsMap.get(parentRecordId).put(wrapperRecord.parentRollupFieldAPI, rollUpValue);
				}else{
					SObject toUpdateSObject = (SObject) objectType.newInstance(); 		//Convert a type class instance to a SObject instance using typecasting
					toUpdateSObject.put('Id', parentRecordId);
					toUpdateSObject.put(wrapperRecord.parentRollupFieldAPI, rollUpValue);
					toUpdateSObjects.add(toUpdateSObject);
					toUpdateSObjectsMap.put(parentRecordId, toUpdateSObject);
				}
			}
			
		}
		if(toUpdateSObjects.size() > 0){
			update toUpdateSObjects;
		}

		isLookupManagementExecuting = false;
	}

    /**
    * @description			    Call the calculaRollups method in an async way
    * @param newRecords			[Map<Id, SObject] the possible newRecords from the TriggerHandler
	* @param oldRecords	    	[Map<Id, SObject] the possible oldRecords from the TriggerHandler
	* @param triggerType		[String] the trigger type
    * @return				    N/A
    **/
	 public static void calculateAllRollupsAsync(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords, String triggerType){
		LookupManagementQueueable instance = new LookupManagementQueueable(
			newRecords,
			oldRecords,
			triggerType
		);
		System.enqueueJob(instance);
	}

	public static void manageRollups(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords, String triggerType){
		// Check if Bypass is set for the user. If so return
		Boolean isBypassLookupRollup = FeatureManagement.checkPermission('isBypassLookupRollup');
		if(isBypassLookupRollup){
			return;
		}

		Map<Id, SObject> filteredRecords = gatherRecordsForRollupCalulation(newRecords, oldRecords, triggerType);
		//System.debug(JSON.serializePretty(filteredRecords));
		if(filteredRecords == null || filteredRecords.size() == 0){
			return;
		} 
		switch on Configurations__mdt.getInstance('RollupExecutionType').Value__c {
			when 'sync' {
				calculateAllRollups(filteredRecords, oldRecords, triggerType);
			}
			when 'async'{
				calculateAllRollupsAsync(filteredRecords, oldRecords, triggerType);
			}
			when else {
				System.debug('Wrong value in the RollupExecutionType metadata.');
				//throw new Exception('Wrong value in the RollupExecutionType metadata.');
			}
		}
	}

	private static Map<Id, SObject> gatherRecordsForRollUpCalulation(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords, String triggerType){
		Id recordId = newRecords == null ? oldRecords.values().get(0).Id : newRecords.values().get(0).Id;
		String sObjectName = MetaUtils.getSObjectName(recordId);		

		//System.debug(JSON.serializePretty(rollupOperationMap));
		if(!rollupOperationMap.containsKey(sObjectName)){
			return null;
		}

		//Delete and insert should always trigger the rollup calculations
		if(!triggerType.containsIgnoreCase('Update')){
			return newRecords == null ? oldRecords : newRecords;
		}

		Map<Id, SObject> returnMap = new Map<Id, SObject>();
		for(SObject newSObj : newRecords.values()){
			SObject oldRecord = oldRecords?.get(newSObj.Id);
			for(RollupOperation__c rollupOp : rollupOperationMap.get(sObjectName)){
				if(oldRecord != null){
					// the condition below commented out: consider all records, even if the field dd not change
					//if(newSObj.get(rollupOp.ChildFieldAPI__c) != oldRecord.get(rollupOp.ChildFieldAPI__c)){
						returnMap.put(newSObj.Id, newSObj);
					//}
					// The lookup field on the child record has changed (the record has been reparented)
					if(newSObj.get(rollupOp.LookupFieldAPI__c) != oldRecord.get(rollupOp.LookupFieldAPI__c)){
						returnMap.put(newSObj.Id, newSObj);
					}
				}
			}
		}
		return returnMap;
	}


	private static Set<Id> getRetrievedParentIds(List<SOBject> returnedSObjectList, LookupWrapper wrapper){
		Set<Id> retVal = new Set<Id>();
		for(SObject sObjectRecord : returnedSObjectList){
			retVal.add((Id) (sObjectRecord.get(wrapper.lookupFieldAPI)));
		}
		return retVal;
	}

	/*
	* Retrieve all parent Id's which are referred to as either their lookup values have changed
	* or their old and new trigger Parent Id's have changed (the record has been reparented)
	*/
	private static Set<Id> getParentRecordIds(Map<Id,SObject> toBeUsedRecords, Map<Id,SObject> oldRecords, LookupWrapper wrapper){
		Set<Id> retVal = new Set<Id>();
		for(Id recordId : toBeUsedRecords.keySet()){
			SObject sObjRecord = toBeUsedRecords.get(recordId);
			if(sObjRecord.get(wrapper.lookupFieldAPI) != null){
				retVal.add((Id) (sObjRecord.get(wrapper.lookupFieldAPI)));
			}
			/* Check if the lookup field's value has changed (the child has been reparented). 
			* If so -> add the old value to the return values
			*/
			if(oldRecords != null){
				// Compare the child to-be-rolled-up field's value with the old record's same value
				Id oldVal = (Id) oldrecords.get(recordId).get(wrapper.LookupFieldAPI);
				Id newVal = (Id) toBeUsedRecords.get(recordId).get(wrapper.LookupFieldAPI);
				// update, there is a potential for record reparenting
				if(oldVal != null && oldVal != newVal){
					// There has been a reparenting. Add the old lookup Id to the list
					retVal.add(oldVal);
				}
			}
		}
		return retVal;
	}

	/*
	* defines which input record map shall be used for rollup calculation. 
	* either Trigger.newMap or Trigger.oldMap
	*/	
	private static Map<Id, SOBject> getToBeUsedRecords(Map<Id,SObject> newRecords, Map<Id,SObject> oldRecords){
		Map<Id, SOBject> retVal = new Map<Id, SOBject>();
		if(newRecords == null){
			retVal.putAll(oldRecords);
		}else{
			retVal.putAll(newRecords);
		}
		return retVal;	
	}


	/*
	* creates a query String which fetches all sibling records
	* which look up to a set of defined parent records
	*/
	public static String createQueryString(LookupWrapper lwr){
		String target = '__c';
		String replacement = '__r';

		String queryString = 'SELECT Id, ';
		queryString += lwr.childFieldAPI + ', ';
		queryString += lwr.lookupFieldAPI + ', ';
		queryString += lwr.lookupFieldReferenceAPI + '.' + lwr.ParentRollupFieldAPI;
		queryString += ' FROM ' + lwr.childObjectAPI;
		queryString += ' WHERE ' + lwr.lookupFieldAPI + ' IN :originalParentIds';
		if(lwr.queryCondition != null){
			queryString += ' AND ' + lwr.queryCondition;
		}
		return queryString;
	}


    /*
    * Returns the List of Wrapper class records with rollup information
	* related to the actual input child object from the RollupOperation__c records
    */
    public static List<LookupWrapper> createRollupWrappers(String objectName){
        List<LookupWrapper> retWrapper = new List<LookupWrapper>();
        
		// Retrieve custom metadata records
        List<RollupOperation__c> rollupOperations = rollupOperationMap.containsKey(objectName) ? rollupOperationMap.get(objectName) : null;
	
		if(rollupOperations == null){
			return retWrapper;
		}

        for(RollupOperation__c actRollupOpMeta : rollupOperations){
			String childObjectAPI = actRollupOpMeta.ChildObjectAPI__c;
            
            // Filter out the ones which are not relevant for this Child Object
			if(childObjectAPI != objectName || actRollupOpMeta.IsActive__c == false){
                continue;
            }

            String parentObjectAPI = actRollupOpMeta.ParentObjectAPI__c;
            String childFieldAPI = actRollupOpMeta.ChildFieldAPI__c;
            String parentRollupFieldAPI = actRollupOpMeta.ParentRollupFieldAPI__c;
			String lookupFieldAPI = actRollupOpMeta.lookupFieldAPI__c;
			String lookupFieldReferenceAPI = actRollupOpMeta.lookupFieldAPI__c.contains('__c') ? actRollupOpMeta.lookupFieldAPI__c.replace('__c', '__r') : actRollupOpMeta.lookupFieldAPI__c;

			if(lookupFieldReferenceAPI.endsWith('Id')){
				// It was a standard lookup field like AccountId on Contact. For relationships, the Id tag needs to be taken out.
				Integer length = lookupFieldReferenceAPI.length();
				lookupFieldReferenceAPI = lookupFieldReferenceAPI.subString(0,length -2);
			}

            // Check if the lookup field is defined on the child object
			if(isFieldExisting(childObjectAPI, childFieldAPI) == false){
				continue;
			}

			LookupWrapper newWrapper = new LookupWrapper();
			newWrapper.setParentObjectAPI(parentObjectAPI);
			newWrapper.setChildObjectAPI(childObjectAPI);
			newWrapper.setParentRollupFieldAPI(parentRollupFieldAPI);
			newWrapper.setChildFieldAPI(childFieldAPI);
			newWrapper.setLookupFieldAPI(lookupFieldAPI);
			newWrapper.setLookupFieldReferenceAPI(lookupFieldReferenceAPI);
			newWrapper.setOperation(actRollupOpMeta.Operation__c);
			newWrapper.setQueryCondition(actRollupOpMeta.QueryCondition__c);

			retWrapper.add(newWrapper);
        }    
        return retWrapper;
    }

	private static Boolean isFieldExisting(String childObjectAPI, String childFieldAPI){
		Boolean retVal = true;
		if(MetaUtils.isObjectExisting(childObjectAPI) == false ||
			MetaUtils.isFieldExisting(childObjectAPI, childFieldAPI) == false){
			retVal = false;
		}
		return retVal;
	}

}