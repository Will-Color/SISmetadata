/**
 * Unit test for VleCreateStudentBySpAction class
 */
@isTest
private class TestVleCreateStudentBySpAction {
    
    static final String PROGRAMME_VERSION = 'Programme_Version__c';
    static final String PROGRAMME_NAME = 'Diploma in Tropical Nursing';
    static final String PROGRAMME_TYPE = ApplyServices.PT_PROFESSIONAL_DIPLOMA;
    static final String TEST_MODULE_VLE_ID = '135';
    static final Long TEST_ROLE_ID = 246;
    
    static Programme__c prog;
    static Contact student;
    static Programme_Version__c mv;
    static Programme_Version__c pv;
    static Module__c m;
    static Student_Programme__c sp;
    static VleCreateStudentBySpAction actionImpl;
    
    static void setupCredentials() {
        VLE__c vle = new VLE__c(
            Name = VleServices.CS_NAME, API_Host__c = 'vle-host.com', App_ID__c = 'app_id', App_Key__c = 'app_key',
            Student_Role_ID__c = String.valueOf(TEST_ROLE_ID), User_ID__c = 'user_id', User_Key__c = 'user_key', Email_To_Student__c = false,
            Default_Student_Role_VLE_ID__c = '103'
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
        student = VleTestingUtils.CreateStudent(true);
        sp = VleTestingUtils.CreateStudentProgramme(prog.Id, student.Id, true);
    }
    
    static VleSyncServices.ActionStructure createActionStructure() {
        actionImpl = new VleCreateStudentBySpAction();
        actionImpl.sp = sp;
        actionImpl.modules = new List<Module__c>{ m };
        return actionImpl.create();
    }

    static testMethod void testCreate() {
        setupCredentials();
        setupTestData();
        VleSyncServices.ActionStructure aStruct = createActionStructure();
        
        System.assertEquals(VleSyncServices.CREATE_VLE_STUDENT_BY_SP_ACTION, aStruct.masterAction.Action__c);
        System.assertEquals(2, aStruct.getDetailCommands().size());
        
        actionImpl.modules = null;
        aStruct = actionImpl.create();
        System.assert(aStruct == null);
    }
    
    static testMethod void testFindCommand() {
        setupCredentials();
        setupTestData();
        VleSyncServices.ActionStructure aStruct = createActionStructure();
        
        // create user command
        VLE_Sync_Command__c createUserCmd = aStruct.getDetailCommands()[0];
        System.assertEquals(VleSyncServices.CREATE_USER_COMMAND, createUserCmd.Command__c);
        VleSyncServices.ICommand cmdImpl = actionImpl.findCommand(createUserCmd);
        if ( cmdImpl instanceof VleCommands.CreateUser ) {
            VleCommands.CreateUser cuCommand = (VleCommands.CreateUser) cmdImpl;
            System.assert(cuCommand.sendEmail == false);
        } else {
            System.assert(false);
        }
        
        // enroll command
        VLE_Sync_Command__c createEnrollCmd = aStruct.getDetailCommands()[1];
        System.assertEquals(VleSyncServices.CREATE_ENROLL_COMMAND, createEnrollCmd.Command__c);
        cmdImpl = actionImpl.findCommand(createEnrollCmd);
        System.assert(cmdImpl instanceof VleCommands.CreateEnrollment);
    }
    
    static testMethod void testFindActionData() {
        setupCredentials();
        setupTestData();
        VleSyncServices.ActionStructure aStruct = createActionStructure();
        insert aStruct.masterAction;
        for (VLE_Sync_Command__c cmd: aStruct.getDetailCommands()) {
            cmd.VLE_Action__c = aStruct.masterAction.Id;
        }
        insert aStruct.getDetailCommands();
        
        Boolean res = actionImpl.findActionData(VleSyncServices.findActionWithCommands(aStruct.masterAction.Id));
        System.assert(res);
        System.assertEquals(sp.Id, actionImpl.sp.Id);
        
        delete sp;
        res = actionImpl.findActionData(VleSyncServices.findActionWithCommands(aStruct.masterAction.Id));
        System.assert(res == false);
    }
    
}