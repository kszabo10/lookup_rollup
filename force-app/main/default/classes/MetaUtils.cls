/***
 * =========================================================================
 * @author      
 * @email       
 * @version     
 * @date        
 * @description 	Utility-type methods related to metadata management
 * =========================================================================
***/
public class MetaUtils {
	

    /**
    * @description			    get the lookup relationship field's reverse name, 
    *                           ... from the Parent to use it for child
	* @param parentObjectAPI	[String] the Parent Object's API name
	* @param childObjectAPI	    [String] the Child Object's API name
    * @return				    [String] the API name of the relationship from Parent
    **/
    public static String getLookupInverseName(String parentObjectAPI, String childObjectAPI){
        String retVal = null;
		// find the lookup relationship field's API name from the Parent's side
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType parentSObjectType = gd.get(parentObjectAPI);

        Schema.DescribeSObjectResult describeResult = parentSObjectType.getDescribe();
        List<Schema.ChildRelationship> childRelationships = describeResult.getChildRelationships();
        for(Schema.ChildRelationship cr : childRelationships){
            if(cr.getRelationshipName() == null){
                continue;
            }
            if( cr.getChildSObject().getDescribe().getName() == childObjectAPI){
                retVal = cr.getRelationshipName();
            }
        }
		return retVal;
    }

    /*
    * returns true if the Object exists
    */
    public static Boolean isObjectExisting(String objectName){
        Boolean isExisting = false;
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        if(objectType != null){
            isExisting = true;
        }
        return isExisting;
    }

    /**
	* @description			return true if a field exists on an Object
	* @param sObjectName	[String] the sObject#s API name
	* @param fieldName		[String] the field's API name on the sObject
    * @return				[Boolean] true if the field exists
    **/
    public static Boolean isFieldExisting(String sObjectName, String fieldName){
        Boolean isExisting = false;
        SObjectType objectType = Schema.getGlobalDescribe().get(sObjectName);
        Set<String> objectFields = objectType.getDescribe().fields.getMap().keySet();
        if(objectFields.contains(fieldName.toLowerCase()) == true){
            isExisting = true;
        }
        return isExisting;
    }

    public static Set<String> getObjectFields(String sObjectName){
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName);
        Schema.DescribeSObjectResult describeSobjResult = sObjectType.getDescribe();
        Set<String> sObjectFields = sObjectType.getDescribe().fields.getMap().keySet();
        return sObjectFields;
    }
    
    /**
	* @description			return the sOBject'a API name from the input record Id
	* @param recordId		[Id] an existing record's record Id
    * @return				[String] the sObject API name of the record
    **/
    public static String getSObjectName(Id recordId){
        return String.valueOf(recordId.getSObjectType());
    }


    /**
	* @description			return the RecordType belonging to an sObject
	* @param sObjectName	[String] input sObject API name
    * @return				[List<RecordType] the related active RecordTypes
    **/
    @AuraEnabled(cacheable=true)
    public static List<RecordType> getRecordTypes(String sObjectName){
        List<RecordType> recTypes = new List<RecordType>([
            select Id, Name, DeveloperName
            from RecordType
            where SObjectType = :sObjectName
            and IsActive = true
        ]);
        return recTypes;
    }

    
    public static Map<String, Map<String, String>> collectPicklistFields(String objectName) {
        Map<String, Map<String, String>> picklistFieldMap = new Map<String, Map<String, String>>();
        
        // Get the describe result for the object
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
        if (sObjectType == null) {
            throw new IllegalArgumentException('Object ' + objectName + ' not found');
        }
        
        Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
        
        // Get the fields of the object
        Map<String, Schema.SObjectField> fields = describeResult.fields.getMap();
        
        // Loop through the fields and collect picklist fields
        for (String fieldName : fields.keySet()) {
            Schema.SObjectField field = fields.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            
            // Check if the field is a picklist
            if (fieldDescribe.getType() == Schema.DisplayType.Picklist) {
                Map<String, String> picklistValuesMap = new Map<String, String>();
                
                // Get picklist values
                List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
                for (Schema.PicklistEntry picklistValue : picklistValues) {
                    picklistValuesMap.put(picklistValue.getValue(), picklistValue.getLabel());
                }
                picklistValuesMap.put(null,'');//to avaoid nullpointer exception if the field is empty....
                // Add to the main map
                picklistFieldMap.put(fieldDescribe.getName(), picklistValuesMap);
            }
        }
        
        return picklistFieldMap;
    }
}