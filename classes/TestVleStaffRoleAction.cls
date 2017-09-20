/**
 * Unit test to VleStaffRoleAction class
 */
@isTest
private class TestVleStaffRoleAction {
    
    static final String PROGRAMME_VERSION = 'Programme_Version__c';
    static final String PROGRAMME_NAME = 'Diploma in Tropical Nursing';
    static final String PROGRAMME_TYPE = ApplyServices.PT_PROFESSIONAL_DIPLOMA;
    static final String TEST_MODULE_VLE_ID = '135';
    static final Long TEST_ROLE_ID = 246;
    static final Long TEST_INSTRUCTOR_ROLE_ID = 357;
    
    static Programme__c prog;
    static Contact staff;
    static Programme_Version__c mv;
    static Programme_Version__c pv;
    static Module__c m;
    static Module_Role__c mr;
    static VleStaffRoleAction actionImpl;
    
    static void setupCredentials() {
        VLE__c vle = new VLE__c(
            Name = VleServices.CS_NAME, API_Host__c = 'vle-host.com', App_ID__c = 'app_id', App_Key__c = 'app_key',
            External_Examiner_Role_ID__c = '468', Instructor_Role_ID__c = String.valueOf(357), User_ID__c = 'user_id', User_Key__c = 'user_key',
            Default_Staff_Role_VLE_ID__c = '102', Default_Student_Role_VLE_ID__c = '103'
        ); 
        insert vle;
    }
    
    static void setupTestData() {
        Id mvrtId = CommonUtils.findRecordTypeIdByDev(PROGRAMME_VERSION, ApplyServices.RT_MASTER_PV_DEVNAME);
        mv = VleTestingUtils.createMasterProgrammeVersion(PROGRAMME_NAME, mvrtId, PROGRAMME_TYPE, true);
        Id rtId = CommonUtils.findRecordTypeIdByDev(PROGRAMME_VERSION, ApplyServices.RT_VERSION_PV_DEVNAME);
        pv = VleTestingUtils.createProgrammeVersion(PROGRAMME_NAME, rtId, PROGRAMME_TYPE, mv.Id, true);
        prog = VleTestingUtils.createProgramme(PROGRAMME_NAME, pv.Id, true);
        m = VleTestingUtils.createModule('Test Module', TEST_MODULE_VLE_ID, true);
        Programme_Module__c pm = new Programme_Module__c(Programme__c = prog.Id, Module__c = m.Id);
        pm.Test_Class_Record__c = true;
        insert pm;
        staff = VleTestingUtils.CreateStaff(true);
        mr = VleTestingUtils.createModuleRole(staff, m, ModuleRoleServices.MODULE_CONVENOR_ROLE_NAME, true);
        actionImpl = new VleStaffRoleAction();
        actionImpl.moduleRole = mr; 
    }

    static testMethod void testCreate() {
        setupCredentials();
        setupTestData();
        
        // insert
        actionImpl.actionType = VleStaffRoleAction.INSERT_ACTION_TYPE;
        VleSyncServices.ActionStructure aStruct = actionImpl.create();
        System.assertEquals(VleSyncServices.VLE_STAFF_ROLE_ACTION, aStruct.masterAction.Action__c);
        System.assertEquals(2, aStruct.getDetailCommands().size());
        System.assertEquals(VleSyncServices.WAIT_VLE_ID_COMMAND, aStruct.getDetailCommands()[0].Command__c);
        System.assertEquals(VleSyncServices.CREATE_ENROLL_COMMAND, aStruct.getDetailCommands()[1].Command__c);
        
        // update
        actionImpl.actionType = VleStaffRoleAction.UPDATE_ACTION_TYPE;
        aStruct = actionImpl.create();
        System.assertEquals(VleSyncServices.VLE_STAFF_ROLE_ACTION, aStruct.masterAction.Action__c);
        System.assertEquals(3, aStruct.getDetailCommands().size());
        System.assertEquals(VleSyncServices.WAIT_VLE_ID_COMMAND, aStruct.getDetailCommands()[0].Command__c);
        System.assertEquals(VleSyncServices.DELETE_ENROLL_COMMAND, aStruct.getDetailCommands()[1].Command__c);
        System.assertEquals(VleSyncServices.CREATE_ENROLL_COMMAND, aStruct.getDetailCommands()[2].Command__c);
        
        // delete
        actionImpl.actionType = VleStaffRoleAction.DELETE_ACTION_TYPE;
        aStruct = actionImpl.create();
        System.assertEquals(VleSyncServices.VLE_STAFF_ROLE_ACTION, aStruct.masterAction.Action__c);
        System.assertEquals(2, aStruct.getDetailCommands().size());
        System.assertEquals(VleSyncServices.WAIT_VLE_ID_COMMAND, aStruct.getDetailCommands()[0].Command__c);
        System.assertEquals(VleSyncServices.DELETE_ENROLL_COMMAND, aStruct.getDetailCommands()[1].Command__c);
        
        Boolean findActionData = actionImpl.findActionData(new VLE_Action__c());
        
        VLE_Sync_Command__c sCm = new VLE_Sync_Command__c();
        sCm.Command__c = VleSyncServices.WAIT_VLE_ID_COMMAND;
        VleSyncServices.ICommand actionImplVar = actionImpl.findCommand(sCm);
        
        sCm.Command__c = VleSyncServices.CREATE_ENROLL_COMMAND;
        actionImplVar = actionImpl.findCommand(sCm);
        
        sCm.Command__c = VleSyncServices.DELETE_ENROLL_COMMAND;
        //actionImplVar = actionImpl.findCommand(sCm);
    }
    
    static testMethod void testFindCommand() {
        setupCredentials();
        setupTestData();
        actionImpl.actionType = VleStaffRoleAction.UPDATE_ACTION_TYPE;
        VleSyncServices.ActionStructure aStruct = actionImpl.create();
        
        VleSyncServices.ICommand waitCmd = actionImpl.findCommand(aStruct.getDetailCommands()[0]);
        System.assert(waitCmd instanceof VleCommands.WaitForVleId);
        VleSyncServices.ICommand delEnrollCmd = actionImpl.findCommand(aStruct.getDetailCommands()[1]);
        System.assert(delEnrollCmd instanceof VleCommands.DeleteEnrollment);
        VleSyncServices.ICommand createEnrollCmd = actionImpl.findCommand(aStruct.getDetailCommands()[2]);
        System.assert(createEnrollCmd instanceof VleCommands.CreateEnrollment);
    }
    
    static testMethod void testFindActionData() {
        setupCredentials();
        setupTestData();
        VleSyncServices.ActionStructure aStruct = actionImpl.create();
        
        Boolean res = actionImpl.findActionData(aStruct.masterAction);
        System.assert(res);
        
        delete mr;
        res = actionImpl.findActionData(aStruct.masterAction);
        System.assert(res == false);
    }
    
}