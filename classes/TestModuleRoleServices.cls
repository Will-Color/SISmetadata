@isTest
private class TestModuleRoleServices {

    private static final String STR_CONTACT = 'Contact';
    private static final String STR_STAFF = 'Staff';

    static testMethod void testFindInsertedRolesWithVisibleContactsPositive() {
        Contact c = VleTestingUtils.createStudent(false);
        c.RecordTypeId = CommonUtils.findRecordTypeIdByDev(STR_CONTACT, STR_STAFF);
        c.Email = 'test@test.com';
        c.VLE_Visibility__c = false;
        insert c;
        
        Module__c m = VleTestingUtils.createModule('Test Module', '123', true);
        Module_Role__c mr = new Module_Role__c(
            Module__c = m.Id, Staff__c = c.Id, Module_Role__c = 'Test role'
        );
        
        try {
            insert mr;
        } catch (DMLException dmle) {
            System.debug(dmle.getMessage());
        }       
        
        Contact c1 = VleTestingUtils.createStudent(false);
        c1.RecordTypeId = CommonUtils.findRecordTypeIdByDev(STR_CONTACT, STR_STAFF);
        c1.VLE_Visibility__c = false;
        insert c1;
        Module_Role__c mr1 = new Module_Role__c(
            Staff__c = c1.Id, Module_Role__c = 'Test role'
        );
        insert mr1;
        
        Test.startTest();
            List<Module_Role__c> mrListToTest = new List<Module_Role__c>{mr,mr1};
            List<Module_Role__c> mrList = ModuleRoleServices.findInsertedRolesWithVisibleContacts(mrListToTest);
        Test.stopTest();
        System.assertEquals(0,mrList.size());
    }

    static testMethod void testFindInsertedRolesWithVisibleContactsNegative() {
        Contact c = VleTestingUtils.createStudent(false);
        c.RecordTypeId = CommonUtils.findRecordTypeIdByDev(STR_CONTACT, STR_STAFF);
        c.VLE_Visibility__c = false;
        insert c;
        Module_Role__c mr = new Module_Role__c(
            Staff__c = c.Id, Module_Role__c = 'Test role'
        );
        insert mr;
        Test.startTest();
            List<Module_Role__c> mrListToTest = new List<Module_Role__c>{mr};
            List<Module_Role__c> mrList = ModuleRoleServices.findInsertedRolesWithVisibleContacts(mrListToTest);
        Test.stopTest();
        System.assertEquals(0,mrList.size());
    }

    static testMethod void testFindDeletedRolesWithVisibleContactsPositive() {
        Contact c = VleTestingUtils.createStudent(false);
        c.RecordTypeId = CommonUtils.findRecordTypeIdByDev(STR_CONTACT, STR_STAFF);
        c.VLE_Visibility__c = true;
        insert c;
        Module_Role__c mr = new Module_Role__c(
            Staff__c = c.Id, Module_Role__c = 'Test role'
        );
        insert mr;
        Test.startTest();
            List<Module_Role__c> mrListToTest = new List<Module_Role__c>{mr};
            List<Module_Role__c> mrList = ModuleRoleServices.findDeletedRolesWithVisibleContacts(mrListToTest);
            System.assertEquals(1,mrList.size());
        Test.stopTest();
        delete mr;
        List<Module_Role__c> mrListDeleted = ModuleRoleServices.findDeletedRolesWithVisibleContacts(mrListToTest);
        System.assertEquals(0,mrListDeleted.size());
    }

    static testMethod void testFindDeletedRolesWithVisibleContactsNegative() {
        Contact c = VleTestingUtils.createStudent(false);
        c.RecordTypeId = CommonUtils.findRecordTypeIdByDev(STR_CONTACT, STR_STAFF);
        c.VLE_Visibility__c = false;
        insert c;
        Module_Role__c mr = new Module_Role__c(
            Staff__c = c.Id, Module_Role__c = 'Test role'
        );
        insert mr;
        Test.startTest();
            List<Module_Role__c> mrListToTest = new List<Module_Role__c>{mr};
            List<Module_Role__c> mrList = ModuleRoleServices.findDeletedRolesWithVisibleContacts(mrListToTest);
        Test.stopTest();
        System.assertEquals(0,mrList.size());
    }

    static testMethod void testFindUpdatedRolesWithVisibleContactsPositive() {
        Contact c = VleTestingUtils.createStudent(false);
        c.RecordTypeId = CommonUtils.findRecordTypeIdByDev(STR_CONTACT, STR_STAFF);
        c.VLE_Visibility__c = true;
        insert c;
        Module_Role__c mr = new Module_Role__c(
            Staff__c = c.Id,
            Module_Role__c = ModuleRoleServices.EXT_EXAMINER_ROLE_NAME
        );
        insert mr;
        mr.Module_Role__c = ModuleRoleServices.TEACHING_ROLE_NAME;
        update mr;
        Test.startTest();
            List<Module_Role__c> mrListNew = new List<Module_Role__c>{mr};
            Module_Role__c mrOld = mr.clone(true, true, true, true);
            mrOld.Module_Role__c = ModuleRoleServices.EXT_EXAMINER_ROLE_NAME;
            List<Module_Role__c> mrOldList = new List<Module_Role__c>{mrOld};
            Map<Id, Module_Role__c> mrOldMap = new Map <Id, Module_Role__c>(mrOldList);
            List<Module_Role__c> mrList = ModuleRoleServices.findUpdatedRolesWithVisibleContacts(mrListNew, mrOldMap);
            System.assertEquals(1,mrList.size());
        Test.stopTest();
    }

    static testMethod void testFindUpdatedRolesWithVisibleContactsNegative() {
        Contact c = VleTestingUtils.createStudent(false);
        c.RecordTypeId = CommonUtils.findRecordTypeIdByDev(STR_CONTACT, STR_STAFF);
        c.VLE_Visibility__c = true;
        insert c;
        Module_Role__c mr = new Module_Role__c(
            Staff__c = c.Id,
            Module_Role__c = ModuleRoleServices.EXT_EXAMINER_ROLE_NAME
        );
        insert mr;
        Test.startTest();
            List<Module_Role__c> mrListNew = new List<Module_Role__c>{mr};
            Module_Role__c mrOld = mr.clone(true, true, true, true);
            mrOld.Module_Role__c = ModuleRoleServices.EXT_EXAMINER_ROLE_NAME;
            List<Module_Role__c> mrOldList = new List<Module_Role__c>{mrOld};
            Map<Id, Module_Role__c> mrOldMap = new Map <Id, Module_Role__c>(mrOldList);
            List<Module_Role__c> mrList = ModuleRoleServices.findUpdatedRolesWithVisibleContacts(mrListNew, mrOldMap);
            System.assertEquals(0,mrList.size());
        Test.stopTest();
    }
    
}