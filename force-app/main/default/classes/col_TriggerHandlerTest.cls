/**
 * ===================================================================
 * 
 * @author      
 * @email       
 * @version     
 * @date        
 * @description 
 * ===================================================================
**/

@isTest
private class TriggerHandlerTest {

	private static final String TRIGGER_CONTEXT_ERROR = 'Trigger handler called outside of Trigger execution';
	private static final String PERMISSIONSET_BYPASSAPEX = 'isBypassApexTrigger';

	private static String lastMethodCalled;
	private static TriggerHandlerTest.TestHandler handler;

	static {
		handler = new TriggerHandlerTest.TestHandler();
		// Override its internal trigger detection
		handler.isTriggerExecuting = true;
	}

	/***************************************
	 * Unit tests
	 ***************************************/

	// Contexts tests

	@isTest
	static void testOnBeforeInsert() {
		beforeInsertMode();

		Test.StartTest();
			handler.run();
		Test.StopTest();

		Assert.areEqual('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
	}

	@isTest
	static void testOnBeforeUpdate() {
		beforeUpdateMode();

		Test.StartTest();
			handler.run();
		Test.StopTest();

		Assert.areEqual('beforeUpdate', lastMethodCalled, 'last method should be beforeUpdate');
	}

	@isTest
	static void testOnBeforeDelete() {
		beforeDeleteMode();

		Test.StartTest();
			handler.run();
		Test.StopTest();

		Assert.areEqual('beforeDelete', lastMethodCalled, 'last method should be beforeDelete');
	}

	@isTest
	static void testOnAfterInsert() {
		afterInsertMode();

		Test.StartTest();
			handler.run();
		Test.StopTest();

		Assert.areEqual('afterInsert', lastMethodCalled, 'last method should be afterInsert');
	}

	@isTest
	static void testOnAfterUpdate() {
		afterUpdateMode();

		Test.StartTest();
			handler.run();
		Test.StopTest();

		Assert.areEqual('afterUpdate', lastMethodCalled, 'last method should be afterUpdate');
	}

	@isTest
	static void testOnAfterDelete() {
		afterDeleteMode();

		Test.StartTest();
			handler.run();
		Test.StopTest();

		Assert.areEqual('afterDelete', lastMethodCalled, 'last method should be afterDelete');
	}

	@isTest
	static void testOnAfterUndelete() {
		afterUndeleteMode();

		Test.StartTest();
			handler.run();
		Test.StopTest();

		Assert.areEqual('afterUndelete', lastMethodCalled, 'last method should be afterUndelete');
	}

	@isTest 
	static void testNonTriggerContext() {
		try {
			Test.StartTest();
				handler.run();
			Test.StopTest();
			Assert.fail('The handler ran but should have thrown an error');
		} catch(TriggerHandler.TriggerHandlerException te) {
			Assert.areEqual(TRIGGER_CONTEXT_ERROR, te.getMessage(), 'the exception message should match');
		} catch(Exception e) {
			Assert.fail('the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
		}
	}

	@isTest
	static void testBypassApexTrigger() {
		User testUser = createTestUserWithBypassTrigger();
		System.runAs(testUser){

			List<PermissionSetAssignment> psaTestUser = [
				SELECT Id FROM PermissionSetAssignment
				WHERE AssigneeId = :testUser.Id
				AND PermissionSet.Name = :PERMISSIONSET_BYPASSAPEX
			];
			Assert.isFalse(psaTestUser.isEmpty(), 'Cannot find the ' + PERMISSIONSET_BYPASSAPEX + ' PermissionSet on the testUser.');

			beforeInsertMode();
			Test.StartTest();
				handler.run();
			Test.StopTest();
		}
		Assert.isNull(lastMethodCalled, 'lastMethodCalled should be null.');
	}

	// Private method tests

	@isTest 
	static void testGetHandlerName() {
		Assert.areEqual('TestHandler', handler.getHandlerName(), 'handler name should match class name');
	}

	// Test virtual methods	
	@isTest
	static void testVirtualMethods() {
		TriggerHandler h = new TriggerHandler();
		h.onBeforeInsert();
		h.onBeforeUpdate();
		h.onBeforeDelete();
		h.onAfterInsert();
		h.onAfterUpdate();
		h.onAfterDelete();
		h.onAfterUndelete();
	}

	/***************************************
	 * Testing utilities
	 ***************************************/

	// Modes for testing
	private static void beforeInsertMode() {
		handler.setTriggerContext('before insert', true);
	}

	private static void beforeUpdateMode() {
		handler.setTriggerContext('before update', true);
	}

	private static void beforeDeleteMode() {
		handler.setTriggerContext('before delete', true);
	}

	private static void afterInsertMode() {
		handler.setTriggerContext('after insert', true);
	}

	private static void afterUpdateMode() {
		handler.setTriggerContext('after update', true);
	}

	private static void afterDeleteMode() {
		handler.setTriggerContext('after delete', true);
	}

	private static void afterUndeleteMode() {
		handler.setTriggerContext('after undelete', true);
	}

	private static User createTestUserWithBypassTrigger() {
		Id profId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1][0].Id;

		String orgId = UserInfo.getOrganizationId();
		String uniqueName = String.valueOf(DateTime.now())
			.replace(' ', '')
			.replace(':', '')
			.replace('-', '');

        // Create a similar user to the current one, thus preventing any User creation validation error
		User testUser = new User(
			Alias = 'standt',
            Email = UserInfo.getUserEmail(),
			EmailEncodingKey = 'UTF-8',
			LastName = 'Testing',
			LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
			ProfileId = profId,
            TimeZoneSidKey = 'America/Los_Angeles',
			UserName = UserInfo.getUserEmail() + '.testuser'
		);
		insert testUser;

		// Add isBypassApexTrigger PermissionSet to testUser
		insert new PermissionSetAssignment(
			AssigneeId = testUser.Id,
			PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = :PERMISSIONSET_BYPASSAPEX LIMIT 1][0].Id
		);

		return testUser;
	}

	// Test implementation of the TriggerHandler
	private class TestHandler extends TriggerHandler {

		public override void onBeforeInsert() {
			TriggerHandlerTest.lastMethodCalled = 'beforeInsert';
		}

		public override void  onBeforeUpdate() {
			TriggerHandlerTest.lastMethodCalled = 'beforeUpdate';
		}

		public override void onBeforeDelete() {
			TriggerHandlerTest.lastMethodCalled = 'beforeDelete';
		}

		public override void onAfterInsert() {
			TriggerHandlerTest.lastMethodCalled = 'afterInsert';
		}

		public override void onAfterUpdate() {
			TriggerHandlerTest.lastMethodCalled = 'afterUpdate';
		}

		public override void onAfterDelete() {
			TriggerHandlerTest.lastMethodCalled = 'afterDelete';
		}

		public override void onAfterUndelete() {
			TriggerHandlerTest.lastMethodCalled = 'afterUndelete';
		}
	}
}