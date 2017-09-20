@isTest
private class TestContactServices {
    
    @testSetup
    public static void setup() {
        VLE__c vle = new VLE__c();
        vle.Name = 'main';
        vle.Default_Staff_Role_VLE_ID__c = '102';
        vle.API_Host__c = '2lstmedtest.desire2learn.com';
        vle.App_ID__c = '2BqFg3qrSd26I';
        vle.App_Key__c = '2MWXZLyA2xo4I';
        insert vle;
    }
    
    
    static testMethod void testOnTriggerPositive() {
        Contact c = VleTestingUtils.createStudent(false);
        c.RecordTypeId = CommonUtils.findRecordTypeIdByDev('Contact', 'Staff');
        c.VLE_Visibility__c = false;
        
        insert c;
        Module_Role__c mr = new Module_Role__c(
            Staff__c = c.Id, Module_Role__c = 'Test role'
        );
        insert mr;
        c.VLE_Visibility__c = true;
        update c;
        List<Contact> cNewList = new List<Contact>{c};
        Contact cOld = c.clone(true, true, true, true);
        cOld.VLE_Visibility__c = false;
        List<Contact> cOldList = new List<Contact>{cOld};
        Map<Id, Contact> cOldMap = new Map <Id, Contact>(cOldList);

        Test.startTest();
            List<Module_Role__c> mrList = ContactServices.findVLEVisibleModuleRoles(cNewList,cOldMap);
        Test.stopTest();

        System.assertEquals(1, mrList.size());
    }

    static testMethod void testFindVLEVisibleModuleRolesZero() {
        Contact c = VleTestingUtils.createStudent(false);
        c.RecordTypeId = CommonUtils.findRecordTypeIdByDev('Contact', 'Staff');
        c.VLE_Visibility__c = false;
        insert c;
        Module_Role__c mr = new Module_Role__c(
            Staff__c = c.Id, Module_Role__c = 'Test role'
        );
        insert mr;
        List<Contact> cNewList = new List<Contact>{c};
        Contact cOld = c.clone(true, true, true, true);
        cOld.VLE_Visibility__c = false;
        List<Contact> cOldList = new List<Contact>{cOld};
        Map<Id, Contact> cOldMap = new Map <Id, Contact>(cOldList);

        Test.startTest();
            List<Module_Role__c> mrList = ContactServices.findVLEVisibleModuleRoles(cNewList,cOldMap);
        Test.stopTest();

        System.assertEquals(0, mrList.size());
    }

    static testMethod void testFindVLENotVisibleModuleRoles() {
        Contact c = VleTestingUtils.createStudent(false);
        c.RecordTypeId = CommonUtils.findRecordTypeIdByDev('Contact', 'Staff');
        c.VLE_Visibility__c = false;
        insert c;
        Module_Role__c mr = new Module_Role__c(
            Staff__c = c.Id, Module_Role__c = 'Test role'
        );
        insert mr;
        List<Contact> cNewList = new List<Contact>{c};
        Contact cOld = c.clone(true, true, true, true);
        cOld.VLE_Visibility__c = true;
        List<Contact> cOldList = new List<Contact>{cOld};
        Map<Id, Contact> cOldMap = new Map <Id, Contact>(cOldList);

        Test.startTest();
            List<Contact> cList = ContactServices.findVLENotVisibleContacts(cNewList,cOldMap);
        Test.stopTest();

        System.assertEquals(1, cList.size());
    }

    static testMethod void testFindVLENotVisibleModuleRolesZero() {
        Contact c = VleTestingUtils.createStudent(false);
        c.RecordTypeId = CommonUtils.findRecordTypeIdByDev('Contact', 'Staff');
        c.VLE_Visibility__c = false;
        insert c;
        Module_Role__c mr = new Module_Role__c(
            Staff__c = c.Id, Module_Role__c = 'Test role'
        );
        insert mr;
        List<Contact> cNewList = new List<Contact>{c};
        Contact cOld = c.clone(true, true, true, true);
        cOld.VLE_Visibility__c = false;
        List<Contact> cOldList = new List<Contact>{cOld};
        Map<Id, Contact> cOldMap = new Map <Id, Contact>(cOldList);

        Test.startTest();
            List<Contact> cList = ContactServices.findVLENotVisibleContacts(cNewList,cOldMap);
        Test.stopTest();

        System.assertEquals(0, cList.size());
    }


}