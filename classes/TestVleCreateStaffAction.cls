/**
 * Unit test for VleCreateStaffAction class
 */
@isTest
private with sharing class TestVleCreateStaffAction {
    @testSetup
    public static void setup() {
        VLE__c vle = new VLE__c();
        vle.Name = 'main';
        vle.Default_Staff_Role_VLE_ID__c = '102';
        vle.API_Host__c = 'lstmedtest.desire2learn.com';
        vle.App_ID__c = 'BqFg3qrSd26IkO-4dTpjJA';
        vle.App_Key__c = 'MWXZLyA2xo4IyRBTq9GyBQ';
        insert vle;
    }
    
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
    
    static void setupCredentials() {
        VLE__c vle = new VLE__c(
            Name = VleServices.CS_NAME, API_Host__c = 'vle-host.com', App_ID__c = 'app_id', App_Key__c = 'app_key', Email_To_Staff__c = false,
            External_Examiner_Role_ID__c = '468', Instructor_Role_ID__c = String.valueOf(357), User_ID__c = 'user_id', User_Key__c = 'user_key',
            Default_Staff_Role_VLE_ID__c = '102'
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
    }
    
    static testMethod void testFindActionData() {
        setupTestData();
        VLE_Action__c vleAction = VleSyncServices.createAction(VleSyncServices.CREATE_ENROLL_COMMAND, staff.Id, VleSyncServices.ACTION_NEW_STATUS);
        insert vleAction;
        
        VleCreateStaffAction actionImpl = new VleCreateStaffAction();
        System.assert(actionImpl.staff == null);
        System.assert(actionImpl.findActionData(vleAction));
        System.assertEquals(staff.Id, actionImpl.staff.Id);
    }
    
    static testMethod void testFindCommand() {
        setupTestData();
        setupCredentials();
        VLE_Action__c vleAction = VleSyncServices.createAction(VleSyncServices.CREATE_ENROLL_COMMAND, staff.Id, VleSyncServices.ACTION_NEW_STATUS);
        insert vleAction;
        List<VLE_Sync_Command__c> cmdList = new List<VLE_Sync_Command__c>(); 
        VLE_Sync_Command__c vleCreateUserCmd = VleSyncServices.createCommand(
            VleSyncServices.CREATE_USER_COMMAND, staff.Id, 1, VleSyncServices.OBJ_TYPE_CONTACT, null
        );
        vleCreateUserCmd.VLE_Action__c = vleAction.Id;
        cmdList.add(vleCreateUserCmd);
        VleCommands.EnrollmentParams enrParams = new VleCommands.EnrollmentParams();
        enrParams.roleId = TEST_ROLE_ID;
        VLE_Sync_Command__c vleCreateEnrollCmd = VleSyncServices.createCommand(
            VleSyncServices.CREATE_ENROLL_COMMAND, mr.Id, 2, VleSyncServices.OBJ_TYPE_MODULE_ROLE, JSON.serialize(enrParams)
        );
        vleCreateEnrollCmd.VLE_Action__c = vleAction.Id;
        cmdList.add(vleCreateEnrollCmd);
        insert cmdList;
        
        VleCreateStaffAction actionImpl = new VleCreateStaffAction();
        System.assert(actionImpl.findActionData(vleAction));
        
        // check 'create user' command
        VleSyncServices.ICommand cmdImpl = actionImpl.findCommand(vleCreateUserCmd);
        System.assert(cmdImpl instanceof VleCommands.CreateUser);
        
        // check 'create enrollment' command
        cmdImpl = actionImpl.findCommand(vleCreateEnrollCmd);
        System.assert(cmdImpl instanceof VleCommands.CreateEnrollment);
    }
    
    static testMethod void testCreate() {
        setupTestData();
        setupCredentials();
        VleCreateStaffAction actionImpl = new VleCreateStaffAction();
        actionImpl.staff = VleDaoServices.findStaffModuleRoles(staff.Id);
        VleSyncServices.ActionStructure aStruct = actionImpl.create();
        System.assert(aStruct != null);
        System.assertEquals(VleSyncServices.CREATE_VLE_STAFF_ACTION, aStruct.masterAction.Action__c);
        System.assertEquals(2, aStruct.getDetailCommands().size());
        System.assertEquals(VleSyncServices.CREATE_USER_COMMAND, aStruct.getDetailCommands()[0].Command__c);
        System.assertEquals(VleSyncServices.CREATE_ENROLL_COMMAND, aStruct.getDetailCommands()[1].Command__c);
        
        // check sending email
        VleSyncServices.ICommand cmdImpl = actionImpl.findCommand(aStruct.getDetailCommands()[0]);
        if ( cmdImpl instanceof VleCommands.CreateUser ) {
            VleCommands.CreateUser cuCommand = (VleCommands.CreateUser) cmdImpl;
            System.assert(cuCommand.sendEmail == false);
        } else {
            System.assert(false);
        }
        
        // with Staff.VLE_ID__c and without module roles
        staff.VLE_ID__c = '123';
        update staff;
        delete mr;
        actionImpl.staff = VleDaoServices.findStaffModuleRoles(staff.Id);
        aStruct = actionImpl.create();
        System.assert(aStruct == null);
    }

}