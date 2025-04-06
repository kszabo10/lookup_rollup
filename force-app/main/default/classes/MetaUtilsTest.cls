/***
 * ===================================================================
 * @author      
 * @email       
 * @version     
 * @date        
 * @description 
 * ===================================================================
**/
@isTest
public class MetaUtilsTest {
   
    @TestSetup
    static void setup(){
        DemoDataCreation.createRollupOperations();
        DemoDataCreation.createAccounts();
    }
    
    @IsTest
    static void getLookupInverseNameTest(){
        
        String retVal = MetaUtils.getLookupInverseName('Account', 'Opportunity');
        System.assertEquals('Opportunities', retVal, 'Passed');
    }

    @IsTest
    static void isObjectExistingTest(){
        Boolean isExisting = MetaUtils.isObjectExisting('Account');
        System.assertEquals(true, isExisting, 'Passed');
    }

    @IsTest
    static void isFieldExistingTest(){
        Boolean isExisting = MetaUtils.isFieldExisting('Account', 'Name');
        System.assertEquals(true, isExisting, 'Passed');
    }
    
    @IsTest
    static void getObjectFieldsTest(){
        Set<String> fieldNames= MetaUtils.getObjectFields('Account');
        System.assert(fieldNames.size() > 4, 'Passed');
    }

    @IsTest
    static void getSObjectNameTest(){
        Account acct = [select Id, Name from Account limit 1];
        String objectName = MetaUtils.getSObjectName(acct.Id);
        System.assertEquals('Account', objectName, 'Passed');
    }

    @IsTest
    static void getRecordTypesTest(){
        String sObjectName = 'Account';
        List<RecordType> acctRecordTypes = MetaUtils.getRecordTypes(sObjectName);
        Assert.isTrue(acctRecordTypes.size() > 0);
    }


}