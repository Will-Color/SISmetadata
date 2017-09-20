@isTest
private class PicklistBannerSPControllerTest
{
    static Programme_Version__c pv{ get; set;}
    static Programme_Version__c mv { get; set; }
    
    static testMethod void PCtest() 
    {
        setupTestData();
        Programme__c prog = VleTestingUtils.createProgramme('Test Programme', pv.Id, false);
        insert prog;
        Contact student = VleTestingUtils.CreateStudent(true);
        Student_Programme__c sp = VleTestingUtils.CreateStudentProgramme(prog.Id, student.Id, true);
        sp.Stage__c = 'Stage2';
        update sp;
        
        PicklistBannerSPController.getCompletedStages(sp.Id);
        PicklistBannerSPController.getCurrentStage(sp.Id);
        PicklistBannerSPController.getFutureStages(sp.Id);
        PicklistBannerSPController.updateStage(sp.Id,'Stage4');
    }
    
    static void setupTestData() 
    {
        Id mvrtId = CommonUtils.findRecordTypeIdByDev('Programme_Version__c', ApplyServices.RT_MASTER_PV_DEVNAME);
        mv = VleTestingUtils.createMasterProgrammeVersion('Test Programme', mvrtId, ApplyServices.PT_PROFESSIONAL_DIPLOMA, false);
        mv.Code__c = StudentProgrammeTriggerMethods.CODE_DTN;
        insert mv;
    
        Id rtId = CommonUtils.findRecordTypeIdByDev('Programme_Version__c', ApplyServices.RT_VERSION_PV_DEVNAME);
        pv = VleTestingUtils.createProgrammeVersion('Test Programme', rtId, ApplyServices.PT_PROFESSIONAL_DIPLOMA, mv.Id, false);
        pv.Code__c = StudentProgrammeTriggerMethods.CODE_DTN;
        insert pv;        
    }            
}