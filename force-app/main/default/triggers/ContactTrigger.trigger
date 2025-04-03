trigger ContactTrigger on Contact (
    before insert,
    after insert,
    before update,
    after update,
    before delete,
    after delete) {
    	new ContactTriggerHandler().run();   
}