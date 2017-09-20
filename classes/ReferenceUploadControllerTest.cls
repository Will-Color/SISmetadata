@isTest
private class ReferenceUploadControllerTest{

    static final String PROGRAMME_VERSION = 'Programme_Version__c';
    static final String PROGRAMME_NAME = 'Diploma in Tropical Nursing';
    static final String PROGRAMME_TYPE = ApplyServices.PT_PROFESSIONAL_DIPLOMA;

    static Programme__c prog { get; set; }
    static Student_Programme__c sp { get; set; }
    static Contact student { get; set; }
    static Programme_Version__c mv { get; set; }
    static Programme_Version__c pv { get; set; }

    static testMethod void testCreateReference() {
        setupTestData();
        prog = VleTestingUtils.createProgramme(PROGRAMME_NAME, pv.Id, false);
        insert prog;
        student = VleTestingUtils.CreateStudent(true);
        sp = VleTestingUtils.CreateStudentProgramme(prog.Id, student.Id, true);
        
        References__c reference = new References__c();
        reference.Applicant__c = student.Id;
        reference.Referee__c = student.Id;
        insert reference;
        
        ReferenceUploadController obj = new ReferenceUploadController();
        obj.sp = sp;
        obj.inFileName = 'Input File';
        obj.reference = reference;
        obj.inputFile = Blob.valueOf('Unit Test Attachment Body');        
        obj.uploadAttachment();
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