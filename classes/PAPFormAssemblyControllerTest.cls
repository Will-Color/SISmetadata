@isTest
public class PAPFormAssemblyControllerTest {
    
    static final String PROGRAMME_NAME = 'PhD - Full Time Speculative - 17/18 Registration';  
    static final String PROGRAMME_VERSION = 'Programme_Version__c';
    static final String PROGRAMME_TYPE = ApplyServices.PT_PGR;   
    
    static testmethod void getPapData(){
        
        VLE__c vle = new VLE__c(
            Name = VleServices.CS_NAME, API_Host__c = 'vle-host.com', App_ID__c = 'app_id', App_Key__c = 'app_key',
            External_Examiner_Role_ID__c = '468', Instructor_Role_ID__c = String.valueOf(357), User_ID__c = 'user_id', User_Key__c = 'user_key'
        ); 
        insert vle;
        Id mvrtId = CommonUtils.findRecordTypeIdByDev(PROGRAMME_VERSION, ApplyServices.RT_MASTER_PV_DEVNAME);
        Programme_Version__c mv = VleTestingUtils.createMasterProgrammeVersion(PROGRAMME_NAME, mvrtId, PROGRAMME_TYPE, false);
        mv.Code__c = StudentProgrammeTriggerMethods.CODE_DTN;
        insert mv;
        
        Id rtId = CommonUtils.findRecordTypeIdByDev(PROGRAMME_VERSION, ApplyServices.RT_VERSION_PV_DEVNAME);
        Programme_Version__c pv = VleTestingUtils.createProgrammeVersion(PROGRAMME_NAME, rtId, PROGRAMME_TYPE, mv.Id, false);
        pv.Code__c = StudentProgrammeTriggerMethods.CODE_DTN;
        insert pv;
        
        Programme__c prog = VleTestingUtils.createProgramme(PROGRAMME_NAME, pv.Id, false);
        insert prog;
        
        Contact staff = VleTestingUtils.CreateStudent(true);
        
        Student_Programme__c sp = VleTestingUtils.CreateStudentProgramme(prog.Id, staff.Id, true);
        sp.recordtypeId=Schema.SObjectType.Student_Programme__c.getRecordTypeInfosByName().get('PGR Application').getRecordTypeId();
        sp.Test_Class_Record__c = true;
        update sp;
        Research_Period__c resPeriod = new Research_Period__c();
        resPeriod.Name = 'tstPeriod';
        resPeriod.Student_Programme__c = sp.Id;
        resPeriod.Period_Number__c = 1;
        resPeriod.Active__c = true;
        //resPeriod.Re_register__c = true;
        resPeriod.PAP_Completed__c = true;
        insert resPeriod;
        
        Progress_Assessment__c pap = new Progress_Assessment__c();
        pap.Name = 'test_progress_assesment';
        pap.Date_of_Review__c = System.today();
        pap.Assessed_Period__c = resPeriod.id;
        insert pap;
        
        PAPFormAssemblyController.getUserData(pap.id);
        
        
    }
}