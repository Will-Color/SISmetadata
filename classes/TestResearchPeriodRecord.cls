/*
* Test Class for ResearchPeriodRecord Visualforce Page to invoke from Student_Programme__c
* Created : 13/06/2017
* Suyati
* Desc : Class will create Student Programme and inserts Research Period and Supervisions
* Suyati Modified : 22/06/2017 - To cover the additional Visualforce amends
*/
@isTest
public class TestResearchPeriodRecord {
    
    /*Global data setting for PGR Programme Type */
    
    static final String PROGRAMME_NAME = 'PhD - Full Time Speculative - 17/18 Registration';  
    static final String PROGRAMME_VERSION = 'Programme_Version__c';
    static final String PROGRAMME_TYPE = ApplyServices.PT_PGR;   
    
    static testmethod void testVFData(){
        VLE__c vle = new VLE__c(
            Name = VleServices.CS_NAME, API_Host__c = 'vle-host.com', App_ID__c = 'app_id', App_Key__c = 'app_key',
            External_Examiner_Role_ID__c = '468', Instructor_Role_ID__c = String.valueOf(357), User_ID__c = 'user_id', User_Key__c = 'user_key'
        ); 
        insert vle;
        /* Insert Module Version */
        Id mvrtId = CommonUtils.findRecordTypeIdByDev(PROGRAMME_VERSION, ApplyServices.RT_MASTER_PV_DEVNAME);
        Programme_Version__c mv = VleTestingUtils.createMasterProgrammeVersion(PROGRAMME_NAME, mvrtId, PROGRAMME_TYPE, false);
        mv.Code__c = StudentProgrammeTriggerMethods.CODE_DTN;
        insert mv;
        
        /*Insert Programme Version */
        Id rtId = CommonUtils.findRecordTypeIdByDev(PROGRAMME_VERSION, ApplyServices.RT_VERSION_PV_DEVNAME);
        Programme_Version__c pv = VleTestingUtils.createProgrammeVersion(PROGRAMME_NAME, rtId, PROGRAMME_TYPE, mv.Id, false);
        pv.Code__c = StudentProgrammeTriggerMethods.CODE_DTN;
        insert pv;
        
        /* Create new Programme */
        Programme__c prog = VleTestingUtils.createProgramme(PROGRAMME_NAME, pv.Id, false);
        insert prog;
        
        /* Create a Student Contact for Creating Student Programme */
        Contact student = VleTestingUtils.CreateStudent(true);
        
        /* Get RecordType Id from Student Programme */
        Id spRecordTypeId = Schema.SObjectType.Student_Programme__c.getRecordTypeInfosByName().get('PGR Application').getRecordTypeId();
        system.debug('spRecordTypeId'+spRecordTypeId);
        
        /* Create new Student Programme */
        Student_Programme__c newSp = new Student_Programme__c();
        newSp.Name = 'TestProgramme';
        newSp.Programme__c = prog.Id;
        newSp.Student__c = student.Id;
        newSp.Test_Class_Record__c = true;
        newSp.RecordTypeId = spRecordTypeId;
        newSp.Stage__c = ApplyServices.COURSE_PRE_REGISTERED_STAGE_NAME;
        newSp.Mode_of_Study__c = 'Full Time';
        insert newSp;
        
        /* Get the Student Programme and assign Research Period and Supervisions*/
        Student_Programme__c lstPr = [select id, name,Mode_of_Study__c,Stage__c from Student_Programme__c where Id=: newSp.Id limit 1];
        lstPr.RecordTypeId = spRecordTypeId;
        update lstPr;
        system.debug('lstptrrrrrrrrrrrrrrrr'+lstPr.id);
        /* Create new Staff */
        Contact staff = VleTestingUtils.createStaff(true);
        staff.Registered_Supervisor__c = true;
        update staff;
        
        /* Create new Research period */
        Research_Period__c resPeriod = new Research_Period__c();
        resPeriod.Name = 'tstPeriod';
        resPeriod.Student_Programme__c = lstPr.Id;
        //resPeriod.Period_Number__c = 1;
        insert resPeriod;
        
        /* Create new Supervision */
       /* Supervision__c spv1 = new Supervision__c();
        spv1.Supervisor__c= staff.Id;
        spv1.Student_Programme__c = lstPr.id;
        spv1.Primary_Supervisor__c = true;
        spv1.Research_Period__c = resPeriod.id;
        spv1.Name = 'Supervisor';
        spv1.Supervisor_Weighting__c = 60;
        insert spv1;
        
        Supervision__c spv2 = new Supervision__c();
        spv2.Supervisor__c= staff.Id;
        spv2.Student_Programme__c = lstPr.id;
        spv2.Primary_Supervisor__c = false;
        spv2.Research_Period__c = resPeriod.id;
        spv2.Name = 'Supervisor';
        spv2.Supervisor_Weighting__c = 40;
        insert spv2;
        */
        /* Create Page reference and assign ID of Student Programme via constructor method */
        PageReference pageRef = Page.ResearchPeriodRecord;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',lstPr.Id);
        
        Student_Programme__c cinstance = new Student_Programme__c();
        ApexPages.StandardController sc = new ApexPages.standardController(cinstance);
        Test.startTest();
        ResearchPeriodRecord controller = new ResearchPeriodRecord(sc);
        controller.UpdateData();
        controller.Cancel();
        controller.SaveData();
        Test.stopTest();
    }
    
}