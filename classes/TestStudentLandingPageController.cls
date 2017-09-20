@isTest(seeAlldata=true) 
private class TestStudentLandingPageController {

    static final String PROGRAMME_VERSION = 'Programme_Version__c';
    static final String PROGRAMME_NAME = 'Diploma in Tropical Nursing';
    static final String PROGRAMME_TYPE = ApplyServices.PT_PROFESSIONAL_DIPLOMA;

    static Programme__c prog { get; set; }
    static Student_Programme__c sp { get; set; }
    static Contact student { get; set; }
    static Programme_Version__c mv { get; set; }
    static Programme_Version__c pv { get; set; }

    
    static testMethod void testPageController1() {

        setupTestData();        
        prog = VleTestingUtils.createProgramme(PROGRAMME_NAME, pv.Id, false);
        insert prog;
        student = VleTestingUtils.CreateStudent(true);
        sp = VleTestingUtils.CreateStudentProgramme(prog.Id, student.Id, true);
            
        List<References__c> referenceList = new List<References__c>();    
        References__c reference1 = new References__c();
        reference1.Applicant__c = student.Id;
        reference1.Student_Programme__c = sp.Id;
        reference1.Reference_Status__c = 'Submitted';
        referenceList.add(reference1);
        
        References__c reference2 = new References__c();
        reference2.Applicant__c = student.Id;
        reference2.Student_Programme__c = sp.Id;
        reference2.Reference_Status__c = 'Requested';
        referenceList.add(reference2);
        
        References__c reference3 = new References__c();
        reference3.Applicant__c = student.Id;
        reference3.Student_Programme__c = sp.Id;
        reference3.Reference_Status__c = 'Replied';
        referenceList.add(reference3);
        
        References__c reference4 = new References__c();
        reference4.Applicant__c = student.Id;
        reference4.Student_Programme__c = sp.Id;
        reference4.Reference_Status__c = 'Checked';
        reference4.Referee__c = student.Id;
        referenceList.add(reference4);      
        
        insert referenceList;                  
               
        PageReference vfPage = Page.StudentLandingPage;
        vfPage.getParameters().put('Id',sp.Id);
        test.setCurrentPage(vfPage);
        
        StudentLandingPageController slpc = new StudentLandingPageController();
        //Test the select option list
        List<SelectOption> offerChoices = slpc.offerOptions;
        system.assertNotEquals(offerChoices.size(), 0);
        
        slpc.findStageDescription(sp.Id);
        slpc.rejectFromAcceptOffer();
        slpc.acceptFromAcceptOffer();
        
        //Test the Cancel button
        PageReference cancelPage = slpc.cancelFromAcceptOffer();
        
        //Test the Accept button
        
        //Test the Reject button
        
        //Test the CreateCase button
        PageReference welcomePage = slpc.createCaseFromRejection();
        
        sp.stage__c = 'Checked';
        update sp;
        slpc.findSpStageAndNote(sp);

        sp.stage__c = 'Incomplete';
        update sp;
        slpc.findSpStageAndNote(sp);

        sp.stage__c = 'Reviewed';
        update sp;
        slpc.findSpStageAndNote(sp);

        sp.stage__c = 'Conditional';
        update sp;
        slpc.findSpStageAndNote(sp);    

        sp.stage__c = 'Unconditional';
        update sp;
        slpc.findSpStageAndNote(sp);    
                            
        
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

    }
    

}