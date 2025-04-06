/**
 * ===================================================================
 * 
 * author      
 * email       
 * version     
 * date        
 * description 
 * ===================================================================
**/
@isTest
public class DemoDataCreationTest {

    @TestSetup
    static void setup(){
        
    }

    @isTest
    public static void createAllDeleteAllTest(){
        DemoDataCreation.createAll();
        List<Account> accts = [
            select Id, Name 
            from Account
        ];
        System.assert(accts.size() > 0);

        //Delete all
        DemoDataCreation.deleteAll('DELETE-ALL-RECORDS-FROM-ORG');

        accts = [
            select Id, Name 
            from Account
        ];

        System.assert(accts.size() == 0);
    }



    @isTest
    public static void createAccountsTest(){
        DemoDataCreation.createAccounts();
        List<Account> accts = [
            select Id, Name 
            from Account
        ];
        System.assert(accts.size() > 0);

    }


    @isTest
    public static void createContactsTest(){
        DemoDataCreation.createAccounts();
        DemoDataCreation.createContacts();
        List<Contact> cnts = [
            select Id, Name 
            from Contact
        ];
        System.assert(cnts.size() > 0);
    }

    @isTest
    public static void createRecordsDeleteRecordsTest(){
        DemoDataCreation.createRecords('Account', true);
        List<Account> accts = [
            select Id, Name 
            from Account
        ];
        System.assert(accts.size() > 0);

        DemoDataCreation.deleteAllRecords('Account');
        accts = [
            select Id, Name 
            from Account
        ];
        System.assert(accts.size() == 0);
    }

}