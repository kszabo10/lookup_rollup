/***
 * ===================================================================
 * @author      
 * @email       
 * @version     
 * @date        
 * @description Queueable class to trigger the rollup calculation asynchronously
 * ===================================================================
**/
public class LookupManagementQueueable implements Queueable{
    
    Map<Id, SObject> newRecordMap;
    Map<Id, SObject> oldRecordMap;
    String triggerType;

    /**
     * Constructor to initialize the Queueable with new and old record maps and trigger type.
     * @param newRecords Map of new records, Trigger.newMap
     * @param oldRecords Map of old records, Trigger.oldMap
     * @param triggerType Trigger operation type
     */
    public LookupManagementQueueable(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords, String triggerType) {
        this.newRecordMap = newRecords;
        this.oldRecordMap = oldRecords;
        this.triggerType = triggerType;
    }

    /**
     * Executes the Queueable job by calling LookupManagement.calculateAllRollups.
     */
    public void execute(QueueableContext context) {
        LookupManagement.calculateAllRollups(newRecordMap, oldRecordMap, triggerType);
    }
}