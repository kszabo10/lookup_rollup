trigger col_ProjectTrigger on col_Project__c (
    before insert,
    after insert,
    before update,
    after update,
    before delete,
    after delete) {
    	new col_ProjectTriggerHandler().run();   
}