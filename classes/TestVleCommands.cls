/**
 * Unit test for VleCommands class
 */
@isTest
private with sharing class TestVleCommands {
    
    static final Long TEST_VLE_ID = 1234567;
    static final Long TEST_ROLE_ID = 543;
    static final String TEST_ORG_UNIT_ID = 'orgUnit';
    static final VleServices.IUserContext userContext = new VleUserContext('https://lstm-desire2learn.com', 'appId', 'appKey', 'userId', 'userKey');
    
    class CreateUserOkCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(VleServices.OK_STATUS_CODE);
            VleStructures.UserData userData = new VleStructures.UserData();
            userData.UserId = TEST_VLE_ID;
            res.setBody(JSON.serialize(userData));
            return res;
        }
    }
    
    class CreateEnrollmentOkCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(VleServices.OK_STATUS_CODE);
            VleStructures.EnrollmentData enrollData = new VleStructures.EnrollmentData();
            enrollData.OrgUnitId = 123;
            res.setBody(JSON.serialize(enrollData));
            return res;
        }
    }

    static testMethod void testCreateUser() {
        // setup data
        Contact c = VleTestingUtils.createStudent(true);
        VLE_Sync_Command__c cmd = VleSyncServices.createCommand(VleSyncServices.CREATE_USER_COMMAND, c.Id, 1, VleSyncServices.OBJ_TYPE_CONTACT, null);
        
        
        VleCommands.CreateUser createUserCmd = new VleCommands.CreateUser();
        createUserCmd.person = c;
        createUserCmd.init(cmd);
        System.assertEquals(createUserCmd.cuData.OrgDefinedId, c.Id);
        System.assert(createUserCmd.cuData.SendCreationEmail);
        
        // send email false
        createUserCmd.sendEmail = false;
        createUserCmd.init(cmd);
        System.assert(createUserCmd.cuData.SendCreationEmail == false);
        
        Test.setMock(HttpCalloutMock.class, new CreateUserOkCalloutMock());
        Test.startTest();
        HttpResponse resp = createUserCmd.makeCallout(userContext);
        Test.stopTest();
        System.assertEquals(VleServices.OK_STATUS_CODE, resp.getStatusCode());
        VleSyncServices.ParseResult pr = createUserCmd.parseResultOk(resp);
        System.assert(pr.result);
        System.assertEquals(1, pr.updatedRecords.size());
        sObject sObj = pr.updatedRecords[0];
        if ( sObj instanceof Contact ) {
            Contact updContact = (Contact) sObj;
            System.assertEquals(c.Id, updContact.Id);
            System.assertEquals(String.valueOf(TEST_VLE_ID), updContact.VLE_ID__c);
        } else {
            System.assert(false);
        }
    }
    
    static testMethod void testCreateEnrollmentWithParams() {
        Contact c = VleTestingUtils.createStudent(false);
        c.VLE_ID__c = String.valueOf(TEST_VLE_ID);
        insert c;
        VleCommands.EnrollmentParams enrParams = new VleCommands.EnrollmentParams();
        enrParams.roleId = TEST_ROLE_ID;
        enrParams.orgUnitId = 1;
        VLE_Sync_Command__c cmd = VleSyncServices.createCommand(
            VleSyncServices.CREATE_ENROLL_COMMAND, c.Id, 1, VleSyncServices.OBJ_TYPE_CONTACT, JSON.serialize(enrParams)
        );
        
        VleCommands.CreateEnrollment createEnrollmentCmd = new VleCommands.CreateEnrollment();
        createEnrollmentCmd.cont = c;
        createEnrollmentCmd.init(cmd);
        System.assertEquals(TEST_ROLE_ID, createEnrollmentCmd.enrollData.RoleId);
        
        Test.setMock(HttpCalloutMock.class, new CreateEnrollmentOkCalloutMock());
        Test.startTest();
        HttpResponse resp = createEnrollmentCmd.makeCallout(userContext);
        Test.stopTest();
        System.assertEquals(VleServices.OK_STATUS_CODE, resp.getStatusCode());
        VleSyncServices.ParseResult pr = createEnrollmentCmd.parseResultOk(resp);
        System.assert(pr.result);
    }
    
    static testMethod void testCreateEnrollmentWithoutParams() {
        Contact c = VleTestingUtils.createStudent(false);
        c.VLE_ID__c = String.valueOf(TEST_VLE_ID);
        insert c;
        VLE_Sync_Command__c cmd = VleSyncServices.createCommand(
            VleSyncServices.CREATE_ENROLL_COMMAND, c.Id, 1, VleSyncServices.OBJ_TYPE_CONTACT, null
        );
        
        VleCommands.CreateEnrollment createEnrollmentCmd = new VleCommands.CreateEnrollment();
        createEnrollmentCmd.cont = c;
        createEnrollmentCmd.roleId = TEST_ROLE_ID;
        createEnrollmentCmd.init(cmd);
        System.assertEquals(TEST_ROLE_ID, createEnrollmentCmd.enrollData.RoleId);
        
        Test.setMock(HttpCalloutMock.class, new CreateEnrollmentOkCalloutMock());
        Test.startTest();
        HttpResponse resp = createEnrollmentCmd.makeCallout(userContext);
        Test.stopTest();
        System.assertEquals(VleServices.OK_STATUS_CODE, resp.getStatusCode());
        VleSyncServices.ParseResult pr = createEnrollmentCmd.parseResultOk(resp);
        System.assert(pr.result);
    }
    
    static testMethod void testDeleteEnrollment() {
        Contact c = VleTestingUtils.createStudent(false);
        c.VLE_ID__c = String.valueOf(TEST_VLE_ID);
        insert c;
        VLE_Sync_Command__c cmd = VleSyncServices.createCommand(
            VleSyncServices.DELETE_ENROLL_COMMAND, c.Id, 1, VleSyncServices.OBJ_TYPE_CONTACT, null
        );
        
        VleCommands.DeleteEnrollment delEnrollCmd = new VleCommands.DeleteEnrollment();
        delEnrollCmd.cont = c;
        delEnrollCmd.orgUnitId = TEST_ORG_UNIT_ID;
        delEnrollCmd.init(cmd);
        
        Test.setMock(HttpCalloutMock.class, new CreateEnrollmentOkCalloutMock()); // it doesn't matter what type of mock callout
        Test.startTest();
        HttpResponse resp = delEnrollCmd.makeCallout(userContext);
        Test.stopTest();
        System.assertEquals(VleServices.OK_STATUS_CODE, resp.getStatusCode());
        VleSyncServices.ParseResult pr = delEnrollCmd.parseResultOk(resp);
        System.assert(pr.result);
    }
    
    static testMethod void testWaitForVleId() {
        Contact c = VleTestingUtils.createStudent(true);
        VLE_Sync_Command__c cmd = VleSyncServices.createCommand(
            VleSyncServices.WAIT_VLE_ID_COMMAND, c.Id, 1, VleSyncServices.OBJ_TYPE_CONTACT, null
        );
        
        VleCommands.WaitForVleId waitCmd = new VleCommands.WaitForVleId();
        waitCmd.recordId = c.Id;
        waitCmd.objName = VleSyncServices.OBJ_TYPE_CONTACT;
        System.assert(waitCmd.isValid == false);
        waitCmd.init(cmd);
        System.assert(waitCmd.isValid == false);
        
        HttpResponse resp = waitCmd.makeCallout(userContext);
        System.assertEquals(VleServices.NOT_FOUND_STATUS_CODE, resp.getStatusCode());
        VleSyncServices.ParseResult pr = waitCmd.parseResultOk(resp);
        System.assert(pr.result); // true always
    }
    
    static testMethod void testUpdateUserActivation() {
        Contact c = VleTestingUtils.createStudent(false);
        c.VLE_ID__c = String.valueOf(TEST_VLE_ID);
        insert c;
        VleStructures.UserActivationData uaData = new VleStructures.UserActivationData();
        uaData.IsActive = false;
        VLE_Sync_Command__c cmd = VleSyncServices.createCommand(
            VleSyncServices.UPDATE_ACTIVATION_COMMAND, c.Id, 1, VleSyncServices.OBJ_TYPE_CONTACT, JSON.serialize(uaData)
        );
        
        VleCommands.UpdateUserActivation updUserActCmd = new VleCommands.UpdateUserActivation();
        System.assert(updUserActCmd.actData == null);
        updUserActCmd.person = c;
        updUserActCmd.init(cmd);
        System.assert(updUserActCmd.actData.IsActive == false);
        
        Test.setMock(HttpCalloutMock.class, new CreateEnrollmentOkCalloutMock()); // it doesn't matter what type of mock callout
        Test.startTest();
        HttpResponse resp = updUserActCmd.makeCallout(userContext);
        Test.stopTest();
        System.assertEquals(VleServices.OK_STATUS_CODE, resp.getStatusCode());
        VleSyncServices.ParseResult pr = updUserActCmd.parseResultOk(resp);
        System.assert(pr.result);
    }
    
    static testMethod void testUpdateUserActivation2() {
        VLE__c vle = new VLE__c(
            Name = VleServices.CS_NAME, API_Host__c = 'vle-host.com', App_ID__c = 'app_id', App_Key__c = 'app_key',
            User_ID__c = 'user_id', User_Key__c = 'user_key', Email_To_Student__c = false, Default_Staff_Role_VLE_ID__c = '102',
            Default_Student_Role_VLE_ID__c = '103', Default_Course_Template_VLE_ID__c = '6638'
        ); 
        insert vle;
        
        Id mvrtId = CommonUtils.findRecordTypeIdByDev('Programme_Version__c', ApplyServices.RT_MASTER_PV_DEVNAME);
        Programme_Version__c mv = VleTestingUtils.createMasterProgrammeVersion('Diploma in Tropical Nursing', mvrtId, ApplyServices.PT_PROFESSIONAL_DIPLOMA, true);
        Id rtId = CommonUtils.findRecordTypeIdByDev('Programme_Version__c', ApplyServices.RT_VERSION_PV_DEVNAME);
        Programme_Version__c pv = VleTestingUtils.createProgrammeVersion('Diploma in Tropical Nursing', rtId, ApplyServices.PT_PROFESSIONAL_DIPLOMA, mv.Id, true);
        Programme__c prog = VleTestingUtils.createProgramme('Diploma in Tropical Nursing', pv.Id, true);
        Module__c m = VleTestingUtils.createModule('Test Module', '135', true);
        Programme_Module__c pm = new Programme_Module__c(Programme__c = prog.Id, Module__c = m.Id);
        pm.Test_Class_Record__c = true;
        insert pm;
        Contact student = VleTestingUtils.CreateStudent(true);
        Student_Programme__c sp = VleTestingUtils.CreateStudentProgramme(prog.Id, student.Id, true);
        
        VleCommands.CreateVleCourse course = new VleCommands.CreateVleCourse();
        course.module = m;
        course.init(new VLE_Sync_Command__c());
        
        VleCommands.UpdateVleCourse courseUp = new VleCommands.UpdateVleCourse();
        courseUp.module = m;
        courseUp.init(new VLE_Sync_Command__c());
    }

}