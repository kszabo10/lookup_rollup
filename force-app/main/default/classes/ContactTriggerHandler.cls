/***
 * ===================================================================
 * @author      
 * @email       
 * @version
 * @date        
 * @description 
 *              
 * ===================================================================
 **/
public class ContactTriggerHandler extends TriggerHandler {
    public override void onAfterInsert() {
        LookupManagement.manageRollups(Trigger.newMap, null, 'onAfterInsert');
    }

    public override void onAfterUpdate() {
        LookupManagement.manageRollups(Trigger.newMap, Trigger.oldMap, 'onAfterUpdate');
    }

    public override void onAfterDelete() {
        LookupManagement.manageRollups(null, Trigger.oldMap, 'onAfterDelete');
    }
}