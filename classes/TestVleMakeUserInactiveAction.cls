/**
 * Unit test to the VleMakeUserInactiveAction class
 */
@isTest
private class TestVleMakeUserInactiveAction {
	
	static final String TEST_VLE_ID = '135';
	static final Long TEST_ROLE_ID = 246;
	
	static Contact student;
	static VleMakeUserInactiveAction actionImpl;
	
	static void setupCredentials() {
		VLE__c vle = new VLE__c(
			Name = VleServices.CS_NAME, API_Host__c = 'vle-host.com', App_ID__c = 'app_id', App_Key__c = 'app_key',
			Student_Role_ID__c = String.valueOf(TEST_ROLE_ID), User_ID__c = 'user_id', User_Key__c = 'user_key'
		); 
		insert vle;
	}
	
	static void setupTestData() {
		student = VleTestingUtils.CreateStudent(false);
		student.VLE_ID__c = TEST_VLE_ID;
		insert student;
		actionImpl = new VleMakeUserInactiveAction();
		actionImpl.person = student;
    }
    
    static testMethod void testCreate() {
    	setupCredentials();
    	setupTestData();
    	
    	VleSyncServices.ActionStructure aStruct = actionImpl.create();
    	System.assertEquals(VleSyncServices.MAKE_VLE_USER_INACTIVE_ACTION, aStruct.masterAction.Action__c);
    	System.assertEquals(2, aStruct.getDetailCommands().size());
    	System.assertEquals(VleSyncServices.WAIT_VLE_ID_COMMAND, aStruct.getDetailCommands()[0].Command__c);
    	System.assertEquals(VleSyncServices.UPDATE_ACTIVATION_COMMAND, aStruct.getDetailCommands()[1].Command__c);
    }
    
    static testMethod void testFindCommand() {
    	setupCredentials();
    	setupTestData();
    	VleSyncServices.ActionStructure aStruct = actionImpl.create();
    	
    	// find wait for VLE_ID command
    	VleSyncServices.ICommand waitCmd = actionImpl.findCommand(aStruct.getDetailCommands()[0]);
    	System.assert(waitCmd instanceof VleCommands.WaitForVleId);
    	
    	// find update activation command
    	VleSyncServices.ICommand updateCmd = actionImpl.findCommand(aStruct.getDetailCommands()[1]);
    	System.assert(updateCmd instanceof VleCommands.UpdateUserActivation);
    }
    
    static testMethod void testFindActionData() {
    	setupCredentials();
    	setupTestData();
    	VleSyncServices.ActionStructure aStruct = actionImpl.create();
    	
    	Boolean res = actionImpl.findActionData(aStruct.masterAction);
    	System.assert(res);
    	
    	delete student;
    	res = actionImpl.findActionData(aStruct.masterAction);
    	System.assert(res == false);
    }
    
}