/**
 * Unit test to VleSetStudentInactiveBySpAction class
 */
@isTest
private class TestVleSetStudentInactiveBySpAction {
    
    static final String PROGRAMME_VERSION = 'Programme_Version__c';
    static final String PROGRAMME_NAME = 'Diploma in Tropical Nursing';
    static final String PROGRAMME_TYPE = ApplyServices.PT_PROFESSIONAL_DIPLOMA;
    static final String TEST_MODULE_VLE_ID = '135';
    static final String TEST_STUDENT_VLE_ID = '246';
    static final Long TEST_ROLE_ID = 246;
    
    static Programme__c prog;
    static Contact student;
    static Programme_Version__c mv;
    static Programme_Version__c pv;
    static Module__c m;
    static Student_Programme__c sp;
    static VleSetStudentInactiveBySpAction actionImpl;
    
    static void setupCredentials() {
        VLE__c vle = new VLE__c(
            Name = VleServices.CS_NAME, API_Host__c = 'vle-host.com', App_ID__c = 'app_id', App_Key__c = 'app_key',
            Student_Role_ID__c = String.valueOf(TEST_ROLE_ID), User_ID__c = 'user_id', User_Key__c = 'user_key'
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
        student = VleTestingUtils.CreateStudent(false);
        student.VLE_ID__c = TEST_STUDENT_VLE_ID;
        insert student;
        sp = VleTestingUtils.CreateStudentProgramme(prog.Id, student.Id, true);
        actionImpl = new VleSetStudentInactiveBySpAction();
        actionImpl.sp = VleDaoServices.findStudentProgrammeInfo(sp.Id);
    }

    static testMethod void testCreate() {
        setupCredentials();
        setupTestData();
        
        VleSyncServices.ActionStructure aStruct = actionImpl.create();
        System.assertEquals(VleSyncservices.SET_STUDENT_INACTIVE_BY_SP_ACTION, aStruct.masterAction.Action__c);
        System.assertEquals(1, aStruct.getDetailCommands().size());
        System.assertEquals(VleSyncServices.UPDATE_ACTIVATION_COMMAND, aStruct.getDetailCommands()[0].Command__c);
        
        student.VLE_ID__c = null;
        update student;
        actionImpl.sp = VleDaoServices.findStudentProgrammeInfo(sp.Id);
        aStruct = actionImpl.create();
        System.assert(aStruct == null);
    }
    
    static testMethod void testFindCommand() {
        setupCredentials();
        setupTestData();
        VleSyncServices.ActionStructure aStruct = actionImpl.create();
        
        VleSyncServices.ICommand updateCmd = actionImpl.findCommand(aStruct.getDetailCommands()[0]);
        System.assert(updateCmd instanceof VleCommands.UpdateUserActivation);
    }
    
    static testMethod void testFindActionData() {
        setupCredentials();
        setupTestData();
        VleSyncServices.ActionStructure aStruct = actionImpl.create();
        
        Boolean res = actionImpl.findActionData(aStruct.masterAction);
        System.assert(res);
        
        delete sp;
        res = actionImpl.findActionData(aStruct.masterAction);
        System.assert(res == false);
    }
    
}