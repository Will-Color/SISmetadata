/**
 * 2014-08-05 : CSL : Test class for StudentProgrammeTriggerMethods
 */
@isTest
private class TestStudentProgrammeTriggerMethods {

    static final String PROGRAMME_VERSION = 'Programme_Version__c';
    static final String PROGRAMME_NAME = 'Diploma in Tropical Nursing';
    static final String PROGRAMME_TYPE = ApplyServices.PT_PROFESSIONAL_DIPLOMA;

    static Programme__c prog { get; set; }
    static Student_Programme__c sp { get; set; }
    static Contact student { get; set; }
    static Programme_Version__c mv { get; set; }
    static Programme_Version__c pv { get; set; }
    
    static testMethod void testCreateMandatoryModules() {
        setupTestData();
        prog = VleTestingUtils.createProgramme(PROGRAMME_NAME, pv.Id, false);
        insert prog;
        student = VleTestingUtils.CreateStudent(true);
        sp = VleTestingUtils.CreateStudentProgramme(prog.Id, student.Id, true);
        
        sp.Stage__c = 'Accepted';
        update sp;
    }


/* Added by Suyati after optional module ammends on 09/16/2016  */
    
     static testMethod void testPreRegistered() {
        setupTestData();
        prog = VleTestingUtils.createProgramme(PROGRAMME_NAME, pv.Id, false);
        insert prog;
        student = VleTestingUtils.CreateStudent(true);
        sp = VleTestingUtils.CreateStudentProgramme(prog.Id, student.Id, true);

        Module__c module = new Module__c();
        module.Name = 'Test module';
        module.VLE_Visibility__c = true;
        module.Test_Class_Record__c = true;
        insert module; 
        
        Programme_Module__c programmeModule = new Programme_Module__c();
        programmeModule.Programme__c = prog.Id;
        programmeModule.Member_Type__c ='Required';
        //programmeModule.Module__c = module.Id;
        programmeModule.Test_Class_Record__c = true;
        INSERT programmeModule;
        
        Student_Module__c studentModule = new Student_Module__c();
        studentModule.Name='TestStudentModule';
        studentModule.Student_Programme__c = sp.Id;
        studentModule.Student__c = sp.Student__c;
        studentModule.Programme_Module__c = programmeModule.Id;
        studentModule.Test_Class_Record__c = true;
        INSERT studentModule;

        sp.Stage__c = 'Pre-Registered';
        update sp;      
    }       
    
/* //Commented by Pavlo due to LS-2
    static testMethod void testFindPreRegisteredStudentProgrammes() {
        setupTestData();
        prog = VleTestingUtils.createProgramme(PROGRAMME_NAME, pv.Id, false);
        insert prog;
        Module__c m = new Module__c(VLE_ID__c = '123', VLE_Visibility__c = true);
        insert m;
        Programme_Module__c pm = new Programme_Module__c(Programme__c = prog.Id, Module__c = m.Id);
        insert pm; 
        
        student = VleTestingUtils.createStudent(true);
        sp = VleTestingUtils.createStudentProgramme(prog.Id, student.Id, false);
        sp.Stage__c = StudentProgrammeTriggerMethods.STAGE_PRE_REGISTERED;
        insert sp;
        Test.startTest();
            List<Student_Programme__c> spNewList = [SELECT Id, Stage__c, Programme__r.Code__c FROM Student_Programme__c WHERE Id = :sp.Id];
            Student_Programme__c spOld = sp.clone(true, true, true, true);
            spOld.Stage__c = 'Draft';
            List<Student_Programme__c> spOldList = new List<Student_Programme__c>{spOld};
            Map<Id, Student_Programme__c> spOldMap = new Map <Id, Student_Programme__c>(spOldList);
            List<Student_Programme__c> spList = StudentProgrammeTriggerMethods.findPreRegisteredStudentProgrammes(spNewList, spOldMap);
        Test.stopTest();
        System.assertEquals(1, spList.size());
    }
    */

    static testMethod void testFindCompletedStudentProgrammes() {
        setupTestData();
        prog = VleTestingUtils.createProgramme(PROGRAMME_NAME, pv.Id, false);
        insert prog;
        student = VleTestingUtils.createStudent(true);
        sp = VleTestingUtils.createStudentProgramme(prog.Id, student.Id, false);
        sp.Total_Module_Score__c = 49;
        sp.Stage__c = StudentProgrammeTriggerMethods.STAGE_COMPLETED;
        sp.Test_Class_Record__c = true;
        insert sp;
        Test.startTest();
            List<Student_Programme__c> spNewList = [SELECT Id, Stage__c, Programme__r.Code__c FROM Student_Programme__c WHERE Id = :sp.Id];
            Student_Programme__c spOld = sp.clone(true, true, true, true);
            spOld.Stage__c = 'Draft';
            List<Student_Programme__c> spOldList = new List<Student_Programme__c>{spOld};
            Map<Id, Student_Programme__c> spOldMap = new Map <Id, Student_Programme__c>(spOldList);
            List<Student_Programme__c> spList = StudentProgrammeTriggerMethods.findCompletedStudentProgrammes(spNewList, spOldMap);
            //Suyati Modified 19-04-2016
            StudentProgrammeTriggerMethods.createMandatoryModules(spList);
            //Suyati Modified End
        Test.stopTest();
        System.assertEquals(1, spList.size());
    }

    static void setupTestData() {
        // add single master version => version => programme => student programme
        Id mvrtId = CommonUtils.findRecordTypeIdByDev(PROGRAMME_VERSION, ApplyServices.RT_MASTER_PV_DEVNAME);
        mv = VleTestingUtils.createMasterProgrammeVersion(PROGRAMME_NAME, mvrtId, PROGRAMME_TYPE, false);
        mv.Code__c = StudentProgrammeTriggerMethods.CODE_DTN;
        insert mv;

        Id rtId = CommonUtils.findRecordTypeIdByDev(PROGRAMME_VERSION, ApplyServices.RT_VERSION_PV_DEVNAME);
        pv = VleTestingUtils.createProgrammeVersion(PROGRAMME_NAME, rtId, PROGRAMME_TYPE, mv.Id, false);
        pv.Code__c = StudentProgrammeTriggerMethods.CODE_DTN;
        insert pv;

        VLE__c vle = new VLE__c(
            Name = VleServices.CS_NAME, API_Host__c = 'vle-host.com', App_ID__c = 'app_id', App_Key__c = 'app_key',
            External_Examiner_Role_ID__c = '468', Instructor_Role_ID__c = String.valueOf(357), User_ID__c = 'user_id', User_Key__c = 'user_key'
        ); 
        insert vle;
    }
    
}