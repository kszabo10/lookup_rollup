trigger col_ContactTrigger on Contact (
    before insert,
    after insert,
    before update,
    after update,
    before delete,
    after delete) {
    	new col_ContactTriggerHandler().run();   
}