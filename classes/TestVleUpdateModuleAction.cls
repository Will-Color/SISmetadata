@isTest
private class TestVleUpdateModuleAction {
    
    static testMethod void testController() {
        VLE__c vle = new VLE__c(
            Name = VleServices.CS_NAME, API_Host__c = 'vle-host.com', App_ID__c = 'app_id', App_Key__c = 'app_key',
            User_ID__c = 'user_id', User_Key__c = 'user_key', Email_To_Student__c = false, Default_Staff_Role_VLE_ID__c = '102',
            Default_Student_Role_VLE_ID__c = '103'
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
        
        VleUpdateModuleAction ma = new VleUpdateModuleAction();
        ma.module = m;
        
        VleSyncServices.ActionStructure st = ma.create();
        
        Boolean findActionData = ma.findActionData(new VLE_Action__c());
        VleSyncServices.ICommand findCommand = ma.findCommand(new VLE_Sync_Command__c());
        
    }
}