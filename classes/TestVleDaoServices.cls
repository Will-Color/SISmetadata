/**
 * Unit test for VleDaoServices class
 */
@isTest
private class TestVleDaoServices {
    
    static final String testAppId = 'appId';
    static final String testAppKey = 'appKey';
    static final String testApiUrl = 'https://api.com';
    static final String testUserId = 'userId';
    static final String testUserKey = 'userKey';
    static final String testPath = '/api/path/';
    static final String PROGRAMME_VERSION = 'Programme_Version__c';
    static final String PROGRAMME_NAME = 'Diploma in Tropical Nursing';
    static final String TEST_MODULE_VLE_ID = '135';
    static final String PROGRAMME_TYPE = ApplyServices.PT_PROFESSIONAL_DIPLOMA;
    
    static Programme__c prog;
    static Student_Programme__c sp;
    static Contact student;
    static Contact staff;
    static Programme_Version__c mv;
    static Programme_Version__c pv;
    static Module__c m;
    static Module_Role__c mr;
    
    static void setupStudentTestData() {
        Id mvrtId = CommonUtils.findRecordTypeIdByDev(PROGRAMME_VERSION, ApplyServices.RT_MASTER_PV_DEVNAME);
        mv = VleTestingUtils.createMasterProgrammeVersion(PROGRAMME_NAME, mvrtId, PROGRAMME_TYPE, true);
        Id rtId = CommonUtils.findRecordTypeIdByDev(PROGRAMME_VERSION, ApplyServices.RT_VERSION_PV_DEVNAME);
        pv = VleTestingUtils.createProgrammeVersion(PROGRAMME_NAME, rtId, PROGRAMME_TYPE, mv.Id, true);
        prog = VleTestingUtils.createProgramme(PROGRAMME_NAME, pv.Id, true);
        m = VleTestingUtils.createModule('Test Module', '123', true);
        Programme_Module__c pm = new Programme_Module__c(Programme__c = prog.Id, Module__c = m.Id);
        pm.Test_Class_Record__c = true;
        insert pm;
        student = VleTestingUtils.CreateStudent(true);
        sp = VleTestingUtils.CreateStudentProgramme(prog.Id, student.Id, true);
    }
    
    static void setupStaffTestData() {
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

    static testMethod void testGetLastSyncActions() {
        student = VleTestingUtils.createStudent(true);
        List<VLE_Action__c> aList = new List<VLE_Action__c>();
        Integer n = 3;
        for (Integer i=0; i<n; i++) {
            VLE_Action__c action = VleSyncServices.createAction('test action', student.Id, VleSyncServices.COMMAND_NEW_STATUS);
            aList.add(action);
        }
        insert aList;
        
        List<VLE_Action__c> resList = VleDaoServices.getLastSyncActions(1);
        System.assertEquals(1, resList.size());
        resList = VleDaoServices.getLastSyncActions(n);
        System.assertEquals(n, resList.size());
        resList = VleDaoServices.getLastSyncActions(n+1);
        System.assertEquals(n, resList.size());
    }
    
    static testMethod void testFindStudentProgrammeInfo() {
        setupStudentTestData();
        Student_Programme__c opp = VleDaoServices.findStudentProgrammeInfo(sp.Id);
        System.assert(opp != null);
        System.assertEquals(student.Id, opp.Student__c);
        
        delete sp;
        opp = VleDaoServices.findStudentProgrammeInfo(sp.Id);
        System.assert(opp == null);
    }
    
    static testMethod void testFindStaffWithModuleRoles() {
        setupStaffTestData();
        List<Contact> cList = VleDaoServices.findStaffWithModuleRoles(new List<Contact>{ staff });
        System.assertEquals(1, cList.size());
        System.assertEquals(1, cList[0].Module_Roles__r.size());
        System.assertEquals(TEST_MODULE_VLE_ID, cList[0].Module_Roles__r[0].Module__r.VLE_ID__c);
        
        Contact c = VleDaoServices.findStaffModuleRoles(staff.Id);
        System.assertEquals(1, c.Module_Roles__r.size());
        System.assertEquals(TEST_MODULE_VLE_ID, c.Module_Roles__r[0].Module__r.VLE_ID__c);
        
        delete staff;
        c = VleDaoServices.findStaffModuleRoles(staff.Id);
        System.assert(c == null);
    }
    
    static testMethod void testFindProgrammeModules() {
        setupStaffTestData();
        Set<Id> mIds = new Set<Id>{ m.Id };
        List<Module__c> mList = VleDaoServices.findProgrammeModules(mIds);
        System.assertEquals(1, mList.size());
        System.assertEquals(m.Id, mList[0].Id);
        
        delete m;
        mList = VleDaoServices.findProgrammeModules(mIds);
        System.assert(mList.isEmpty());
    }
    
    static testMethod void testFindContacts() {
        Contact c = VletestingUtils.createStudent(true);
        // find list of contacts
        List<Contact> cList = VleDaoServices.findContacts(new List<Contact>{ c });
        System.assertEquals(1, cList.size());
        System.assertEquals(c.Id, cList[0].Id);
        
        // find single contact
        Contact cont = VleDaoServices.findContact(c.Id);
        System.assertEquals(c.Id, cont.Id);
        
        // find null as result
        delete c;
        cont = VleDaoServices.findContact(c.Id);
        System.assert(cont == null);
    }
    
    static testMethod void testFindModuleRoleData() {
        setupStaffTestData();
        
        List<Module_Role__c> mrList = VleDaoServices.findModuleRolesData(new List<Module_Role__c>{ mr });
        System.assertEquals(1, mrList.size());
        System.assertEquals(mr.Id, mrList[0].Id);
        
        Module_Role__c mrInst = VleDaoServices.findModuleRoleData(mr.Id);
        System.assertEquals(mr.Id, mrInst.Id);
        
        delete mr;
        mrInst = VleDaoServices.findModuleRoleData(mr.Id);
        System.assert(mrInst == null);
    }
    
    static testMethod void testHasNotEmptyVleId() {
        Contact c = VletestingUtils.createStudent(true);
        System.assert(VleDaoServices.hasNotEmptyVleId('Contact', c.Id) == false);
        c.VLE_ID__c = '123';
        VleDaoServices.makeUpdate(new List<Contact>{ c });
        System.assert(VleDaoServices.hasNotEmptyVleId('Contact', c.Id));
    }
    
    static testMethod void testFindModuleData() {
        List<Module__c> ms = VleDaoServices.findModuleData(new Set<Id>());
    }
    
}