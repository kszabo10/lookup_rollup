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
@isTest
public class ContactTriggerHandlerTest {

    static String internalRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
    static String externalRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External').getRecordTypeId();

    @TestSetup
    static void setup(){
        DemoDataCreation.createRollupOperations();
        DemoDataCreation.createAccounts();
    }

    @isTest
    static void onAfterInsertTest(){
        Test.startTest();
        Account acct = [
            select Id
            from Account
            order by Name
            limit 1
        ];
        Contact cnt = new Contact(
            FirstName = 'Abigail',
            LastName = 'Test',
            Email = 'abigail.test@officialfirm.com.invalid',
            AccountId = acct.Id,
            RecordTypeId = externalRTId
        );
        insert cnt;
        Test.stopTest();
        acct = [
            select Id, Name, NumberOfContacts__c
            from Account
            order by Name
            limit 1
        ];
        Assert.isTrue(acct.NumberOfContacts__c > 0, 'The accounts contact number did not change after adding a new contact');
    }

    @isTest
    static void onAfterUpdateTest(){

        Test.startTest();
        Account acct = [
            select Id
            from Account
            order by Name
            limit 1
        ];
        Contact cnt = new Contact(
            FirstName = 'Abigail',
            LastName = 'Test',
            Email = 'abigail.test@officialfirm.com.invalid',
            AccountId = acct.Id,
            RecordTypeId = externalRTId        
        );
        insert cnt;
        cnt.FirstName = 'AbigailNew';
        update cnt;
        Test.stopTest();

        acct = [
            select Id, Name, NumberOfContacts__c
            from Account
            order by Name
            limit 1
        ];
        Assert.isTrue(acct.NumberOfContacts__c == 1, 'Contact number got wrongly modified at Parent level after update');
    }

    @isTest
    static void onAfterDeleteTest(){
        Account acct = [
            select Id
            from Account
            order by Name
            limit 1
        ];
        Contact cnt = new Contact(
            FirstName = 'Abigail',
            LastName = 'Test',
            Email = 'abigail.test@officialfirm.com.invalid',
            AccountId = acct.Id,
            RecordTypeId = externalRTId

        );
        insert cnt;
        delete cnt;
        acct = [
            select Id, Name, NumberOfContacts__c
            from Account
            order by Name
            limit 1
        ];
        Assert.isTrue(acct.NumberOfContacts__c == 0, 'Contact number got wrongly modified at Parent level after delete');
    }


}