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
public class col_RollupCalculationTest {
   
	private static col_LookupWrapper wr;
	private static List<Opportunity> opps = null;
	private static Integer oppNum = 3;

    @TestSetup
    static void setup(){
        col_DemoDataCreation.createAccounts();
    }

    static col_LookupWrapper createWrapper(String iOperation){
        col_LookupWrapper wr = new col_LookupWrapper(
        );
    
		// Rollup Opportunity.Amount into Account.col_TotalBudget__c
		wr.setParentObjectAPI('Account');
		wr.setChildObjectAPI('Opportunity');
		wr.setParentRollupFieldAPI('AccountId');
		wr.setChildFieldAPI('Amount');
		wr.setLookupFieldAPI('col_TotalBudget__c');
		wr.setLookupFieldReferenceAPI('Account');
		wr.setOperation(iOperation);
		return wr;

    }

    @IsTest
    static void calculateSUMTest(){
		Double assertVal = 0.0;
		Account acct = [select Id, Name, col_TotalBudget__c from Account limit 1];
		col_LookupWrapper wr = createWrapper('SUM');
		opps = new List<Opportunity>();
		for(Integer i = 0; i < oppNum; i++){
			Opportunity opp = new Opportunity(
				Name = 'TestOpportunity_' + i, 
				AccountId = acct.Id,
				Amount = 100 * (i + 1),
				StageName = 'New',
				CloseDate = Date.today().addMonths(3)
			);
			opps.add(opp);
		}
		assertVal = col_RollupCalculation.calculateSUM(opps, wr);
		System.assertEquals(600.0, assertVal, 'SUM assert failed');
	}

    @IsTest
    static void calculateMINTest(){
		Double assertVal = 0.0;
		Account acct = [select Id, Name, col_TotalBudget__c from Account limit 1];
		col_LookupWrapper wr = createWrapper('MIN');
		opps = new List<Opportunity>();
		for(Integer i = 0; i < oppNum; i++){
			Opportunity opp = new Opportunity(
				Name = 'TestOpportunity_' + i, 
				AccountId = acct.Id,
				Amount = 100 * (oppNum - i),
				StageName = 'New',
				CloseDate = Date.today().addMonths(3)
			);
			opps.add(opp);
		}
		assertVal = col_RollupCalculation.calculateMIN(opps, wr);
		System.assertEquals(100.0, assertVal, 'MIN assert failed');
		opps = new List<Opportunity>();
		assertVal = col_RollupCalculation.calculateMIN(opps, wr);
		System.assertEquals(0.0, assertVal, 'MIN assert with empty input failed');
	}

    @IsTest
    static void calculateMAXTest(){
		Double assertVal = 0.0;
		Account acct = [select Id, Name, col_TotalBudget__c from Account limit 1];
		col_LookupWrapper wr = createWrapper('MAX');
		opps = new List<Opportunity>();
		for(Integer i = 0; i < oppNum; i++){
			Opportunity opp = new Opportunity(
				Name = 'TestOpportunity_' + i, 
				AccountId = acct.Id,
				Amount = 100 * (i + 1),
				StageName = 'New',
				CloseDate = Date.today().addMonths(3)
			);
			opps.add(opp);
		}
		assertVal = col_RollupCalculation.calculateMAX(opps, wr);
		System.assertEquals(300.0, assertVal, 'MAX assert failed');
		opps = new List<Opportunity>();
		assertVal = col_RollupCalculation.calculateMAX(opps, wr);
		System.assertEquals(0.0, assertVal, 'MAX assert with empty input failed');
	}

	@IsTest
    static void calculateAVGTest(){
		Double assertVal = 0.0;
		Account acct = [select Id, Name, col_TotalBudget__c from Account limit 1];
		col_LookupWrapper wr = createWrapper('AVG');
		opps = new List<Opportunity>();
		for(Integer i = 0; i < oppNum; i++){
			Opportunity opp = new Opportunity(
				Name = 'TestOpportunity_' + i, 
				AccountId = acct.Id,
				Amount = 100 * (i + 1),
				StageName = 'New',
				CloseDate = Date.today().addMonths(3)
			);
			opps.add(opp);
		}
		assertVal = col_RollupCalculation.calculateAVG(opps, wr);
		System.assertEquals(200.0, assertVal, 'AVG assert failed');
		opps = new List<Opportunity>();
		assertVal = col_RollupCalculation.calculateAVG(opps, wr);
		System.assertEquals(0.0, assertVal, 'AVG assert with empty input failed');

	}

	@IsTest
    static void calculateCOUNTTest(){
		Double assertVal = 0.0;
		Account acct = [select Id, Name, col_TotalBudget__c from Account limit 1];
		col_LookupWrapper wr = createWrapper('COUNT');
		opps = new List<Opportunity>();
		for(Integer i = 0; i < oppNum; i++){
			Opportunity opp = new Opportunity(
				Name = 'TestOpportunity_' + i, 
				AccountId = acct.Id,
				Amount = 100 * (i + 1),
				StageName = 'New',
				CloseDate = Date.today().addMonths(3)
			);
			opps.add(opp);
		}
		assertVal = col_RollupCalculation.calculateCOUNT(opps);
		System.assertEquals(3.0, assertVal, 'COUNT assert failed');
	}

}