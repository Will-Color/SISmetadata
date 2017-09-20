/**
 * @author Mykola Senyk
 * @date 20/06/2014
 * @description Unit test for ApplyWizardContExt class
 */
@isTest
private class TestApplyWizardContExt {
    
    static void createControllerRelatedStuff() {
        // create Page_Copy__c
        List<Page_Copy__c> pcList = new List<Page_Copy__c>(); 
        Page_Copy__c pageCopy = new Page_Copy__c(Copy_Location__c = 'Application Welcome', Page_Status__c = 'Active', Body_Copy__c = 'test body');
        pcList.add(pageCopy);
        pageCopy = new Page_Copy__c(Copy_Location__c = 'Application Review', Page_Status__c = 'Active', Body_Copy__c = 'test body');
        pcList.add(pageCopy);
        pageCopy = new Page_Copy__c(Copy_Location__c = 'Research Proposal', Page_Status__c = 'Active', Body_Copy__c = 'test body');
        pcList.add(pageCopy);
        insert pcList;

        
    }
    static testMethod  void testBooleanVariables() {
        ApplyTestingUtils.setupTestData();
        createControllerRelatedStuff();
        Test.setCurrentPageReference(new PageReference('Page.ApplyWizard'));
        Test.startTest();
        System.currentPageReference().getParameters().put('id', ApplyTestingUtils.sp.Id);
        ApplyWizardContExt cont = new ApplyWizardContExt();
        boolean needLSS = cont.needLeadSourceSpecify;
        boolean needVFD = cont.needVisaFurtherDetails;
        Test.stopTest();

    }
    static testMethod void testController() {
        ApplyTestingUtils.setupTestData();
        createControllerRelatedStuff();
        Test.setCurrentPageReference(new PageReference('Page.ApplyWizard'));
        System.currentPageReference().getParameters().put('id', ApplyTestingUtils.sp.Id);
        Test.startTest();
        ApplyWizardContExt cont = new ApplyWizardContExt();
        //ApplyWizardContExt cont = new ApplyWizardContExt(new ApexPages.Standardcontroller(ApplyTestingUtils.sp));
        //System.assert(cont != null);
        // step movement
        System.assertEquals(0, cont.step.stepIndex);
        cont.init();
        cont.gotoNextStep();
        System.assertEquals(1, cont.step.stepIndex);
        cont.gotoPreviousStep();
        System.assertEquals(0, cont.step.stepIndex);
        cont.stepName = ApplyServices.STEP_PERSONAL_STATEMENT;
        cont.gotoStep();
        System.assertEquals(ApplyServices.STEP_PERSONAL_STATEMENT, cont.step.getName());
        cont.stepName = ApplyServices.STEP_WELCOME;
        cont.gotoStep();
        System.assertEquals(ApplyServices.STEP_WELCOME, cont.step.getName());
        // welcome step
        System.assert(!cont.needLeadSourceSpecify);
        cont.sp.How_did_you_hear_about_this_Course__c = 'test (please specify)';
        System.assert(cont.needLeadSourceSpecify);
        cont.saveAndProceed();
        // check dummy student surname
        //System.assertEquals(ApplyTestingUtils.STUDENT_LAST_NAME, cont.student.LastName);
        Contact student = ApplyTestingUtils.student;
        student.LastName = ApplyServices.DUMMY_REQUIRED_STRING;
        update student;       
        Test.setCurrentPageReference(new PageReference('Page.ApplyWizard'));
        System.currentPageReference().getParameters().put('id', ApplyTestingUtils.sp.Id);
        ApplyWizardContExt cont2 = new ApplyWizardContExt();
        //cont = new ApplyWizardContExt(new ApexPages.Standardcontroller(ApplyTestingUtils.sp));
        //System.assert(String.isBlank(cont2.student.LastName));
        //test Save and proceed
       // cont.deleteQual();
       // cont.doSubmit();
        Test.stopTest();
        
    }
    
    static testMethod void testPTypesMScProgrammes() {
        ApplyTestingUtils.setupTestData();
        createControllerRelatedStuff();
        
        Test.setCurrentPageReference(new PageReference('Page.ApplyWizard'));
        System.currentPageReference().getParameters().put('id', ApplyTestingUtils.ST_PROG_MSC_PROGRAMME.Id);
        Test.startTest();
        ApplyWizardContExt cont = new ApplyWizardContExt();
        //System.assertEquals(ApplyServices.steps.size()-1, cont.innerSteps.size());
        //System.assert(!cont.isPGR);
        Test.stopTest();
    }

    static testMethod void testPTypesProfessionalDiploma() {
        ApplyTestingUtils.setupTestData();
        createControllerRelatedStuff();
        Test.setCurrentPageReference(new PageReference('Page.ApplyWizard'));
        Test.startTest();
        System.currentPageReference().getParameters().put('id', ApplyTestingUtils.ST_PROG_PROFESSIONAL_DIPLOMA.Id);
        ApplyWizardContExt cont1 = new ApplyWizardContExt();
        //System.assertEquals(ApplyServices.steps.size()-1, cont1.innerSteps.size());
        //System.assert(!cont1.isPGR);
        Test.stopTest();

    }
    static testMethod void testPTypesMastersModule() {
        ApplyTestingUtils.setupTestData();
        createControllerRelatedStuff();
        Test.setCurrentPageReference(new PageReference('Page.ApplyWizard'));
        System.currentPageReference().getParameters().put('id', ApplyTestingUtils.ST_PROG_MASTERS_MODULE.Id);
        Test.startTest();
        ApplyWizardContExt cont2 = new ApplyWizardContExt();
        //System.assertEquals(ApplyServices.steps.size()-1, cont.innerSteps.size());
        //System.assert(!cont2.isPGR);
        Test.stopTest();
    }
    
    static testMethod void testPTShortCourse() {

        ApplyTestingUtils.setupTestData();
        createControllerRelatedStuff();      
        
        Test.setCurrentPageReference(new PageReference('Page.ApplyWizard'));
        System.currentPageReference().getParameters().put('id', ApplyTestingUtils.ST_PROG_SHORT_COURSE.Id);
        Test.startTest();
        ApplyWizardContExt cont3 = new ApplyWizardContExt();
        //System.assertEquals(ApplyServices.steps.size()-1, cont3.innerSteps.size());
        //System.assert(!cont3.isPGR);
        Test.stopTest();

    }
    static testMethod void testPTPGT() {
        ApplyTestingUtils.setupTestData();
        createControllerRelatedStuff();
        Test.setCurrentPageReference(new PageReference('Page.ApplyWizard'));
        System.currentPageReference().getParameters().put('id', ApplyTestingUtils.ST_PROG_PGT.Id);
        Test.startTest();
        ApplyWizardContExt cont4 = new ApplyWizardContExt();
        //cont = new ApplyWizardContExt(new ApexPages.Standardcontroller(ApplyTestingUtils.ST_PROG_PGT));
        //System.assertEquals(ApplyServices.steps.size()-1, cont4.innerSteps.size());
        //System.assert(!cont4.isPGR);
        Test.stopTest();

    }

    static testMethod void testPTPGR() {
        ApplyTestingUtils.setupTestData();
        createControllerRelatedStuff();
        Test.setCurrentPageReference(new PageReference('Page.ApplyWizard'));
        System.currentPageReference().getParameters().put('id', ApplyTestingUtils.ST_PROG_PGR.Id);
        System.debug('ApplyTestingUtils.setupTestData()'+ApplyTestingUtils.ST_PROG_PGR.Id);
        Test.startTest();
        ApplyWizardContExt cont5 = new ApplyWizardContExt();
        //cont = new ApplyWizardContExt(new ApexPages.Standardcontroller(ApplyTestingUtils.ST_PROG_PGR));
        //System.assertEquals(ApplyServices.steps.size(), cont5.innerSteps.size());
        //System.assert(cont5.isPGR);
        Test.stopTest();

    }
    
    
    static testMethod void testReferences() {


        ApplyTestingUtils.setupTestData();
        createControllerRelatedStuff();
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.ApplyWizard'));
        System.currentPageReference().getParameters().put('id', ApplyTestingUtils.sp.Id);
        ApplyWizardContExt cont = new ApplyWizardContExt();
        //ApplyWizardContExt cont = new ApplyWizardContExt(new ApexPages.Standardcontroller(ApplyTestingUtils.sp));
        cont.init();
        
        System.assertEquals(2, cont.references.size());
        System.assertEquals(ApplyTestingUtils.REFEREE_LAST_NAME, cont.references[0].referee.LastName);
        System.assert(String.isBlank(cont.references[1].referee.LastName));
        cont.validate();
        ////System.assert(!cont.errorByStep.get(Applyservices.STEP_REFERENCES));
        cont.references[1].referee.FirstName = 'test';
        cont.validate();
        System.assert(cont.errorByStep.get(Applyservices.STEP_REFERENCES));
        
        // check with empty referee surname
        cont.references[1].referee.LastName = '';
        cont.saveDraftApplication();
        
        Test.setCurrentPageReference(new PageReference('Page.ApplyWizard'));
        System.currentPageReference().getParameters().put('id', ApplyTestingUtils.sp.Id);
        Test.stopTest();
        
    }

    
    static testMethod void testQEs() {
        
        ApplyTestingUtils.setupTestData();
        createControllerRelatedStuff();
        
        Student_Programme__c sp = ApplyTestingUtils.sp;
        System.debug('sp programType = ' + sp.Programme__r.Programme_Version__r.Master_Link__r.Application_Form_Type__c);
        List<Qualifications_Experience__c> qeList = [SELECT Id FROM Qualifications_Experience__c WHERE Contact__c = :sp.Student__c];
        delete qeList; // clear pre-defined QEs on the contact
        
        Test.setCurrentPageReference(new PageReference('Page.ApplyWizard'));
        System.currentPageReference().getParameters().put('id', ApplyTestingUtils.sp.Id);
        Test.startTest();
        ApplyWizardContExt cont = new ApplyWizardContExt();
        //ApplyWizardContExt cont = new ApplyWizardContExt(new ApexPages.Standardcontroller(sp));
        //System.assert(cont.qeMap == null);
        cont.init();
        //System.assertEquals(3, cont.qeMap.size());
        for (List<QEWrapper> wr: cont.qeMap.values()) {
            System.assertEquals(1, wr.size());
            System.assertEquals(0, wr[0].index);
            System.assert(wr[0].item.Id != null);
        }
        
        // add new instances
        cont.addAcademicQE();
        System.assertEquals(2, cont.qeMap.get(ApplyServices.RT_ACADEMIC_QE_DEVNAME).size());
        cont.addLanguageQE();
        System.assertEquals(1, cont.qeMap.get(ApplyServices.RT_LANGUAGE_QE_DEVNAME).size());
        cont.addProfessionalQE();
        System.assertEquals(2, cont.qeMap.get(ApplyServices.RT_PROFESSIONAL_QE_DEVNAME).size());
        cont.addExperienceQE();
        System.assertEquals(2, cont.qeMap.get(ApplyServices.RT_EXPERIENCE_QE_DEVNAME).size());
        List<Qualifications_Experience__c> qeList1 = [SELECT Id FROM Qualifications_Experience__c WHERE Contact__c = :sp.Student__c];
        cont.deleteQualId=qeList1[0].Id;
        cont.deleteQual();
        Test.stopTest(); 
    }
    
    static testMethod void testValidate() {
        
        ApplyTestingUtils.setupTestData();
        createControllerRelatedStuff();
        Test.setCurrentPageReference(new PageReference('Page.ApplyWizard'));
        System.currentPageReference().getParameters().put('id', ApplyTestingUtils.sp.Id);
        Test.startTest();
        ApplyWizardContExt cont = new ApplyWizardContExt();
        //ApplyWizardContExt cont = new ApplyWizardContExt(new ApexPages.Standardcontroller(ApplyTestingUtils.sp));
        cont.init();
        //System.assert(!cont.requiredMode);
        cont.references[0].referee.LastName = '';
        cont.references[0].referee.FirstName = 'John';
        //System.assert(cont.isEEAStudent); // HESA nationality - not set
        cont.validate();
        //System.assert(cont.isValidationErrors);
        //System.assert(cont.requiredMode);
        
        // fix personal details Names
        //System.assert(cont.errorByStep.get(ApplyServices.STEP_PERSONAL_NAME));
        String tv = 'test';
        cont.student.LastName = tv;
        cont.student.FirstName = tv;
        cont.student.Salutation = 'Mr.';
        cont.student.Male_Female__c = 'Male';
        cont.student.Country_of_Birth__c = 'Albania';
        cont.student.HESA_Nationality__c = ApplyTestingUtils.hesaCodes[2].Id; // nonEEA
        //System.assert(!cont.isEEAStudent);
        cont.student.Birthdate = Date.newInstance(1970, 5, 15);
        cont.validate();
        //System.assert(cont.isValidationErrors);
        //System.assert(!cont.errorByStep.get(ApplyServices.STEP_PERSONAL_NAME));
        
        // fix personal details Addresses
        //System.assert(cont.errorByStep.get(ApplyServices.STEP_PERSONAL_ADDRESS));
        cont.student.MailingStreet = tv;
        cont.student.MailingCity = tv;
        cont.student.MailingState = tv;
        cont.student.MailingPostalCode = tv;
        cont.student.MailingCountry = tv;
        cont.student.Gaps_in_Residence__c = ApplyServices.PICKLIST_NO;
        cont.validate();
        //System.assert(cont.isValidationErrors);
        //System.assert(cont.errorByStep.get(ApplyServices.STEP_PERSONAL_ADDRESS)); // reason: gaps in residence = N
        cont.student.Previous_Country__c = 'France, Spain';
        cont.validate();
        //System.assert(cont.isValidationErrors);
        //System.assert(!cont.errorByStep.get(ApplyServices.STEP_PERSONAL_ADDRESS));
        
        // fix English language
        //System.assert(cont.errorByStep.get(ApplyServices.STEP_LANGUAGE_QUALIFICATIONS));
        cont.student.HESA_Nationality__c = ApplyTestingUtils.hesaCodes[0].Id; // UK
        cont.validate();
        //System.assert(cont.errorByStep.get(ApplyServices.STEP_LANGUAGE_QUALIFICATIONS));
        cont.sp.Confirm_British_Irish_Nationality__c = ApplyServices.PICKLIST_YES;
        cont.validate();
        //System.assert(!cont.errorByStep.get(ApplyServices.STEP_LANGUAGE_QUALIFICATIONS));
        cont.student.HESA_Nationality__c = ApplyTestingUtils.hesaCodes[2].Id; // not UK
        cont.validate();
        //System.assert(cont.errorByStep.get(ApplyServices.STEP_LANGUAGE_QUALIFICATIONS));
        cont.sp.National_of_Majority_English_Speaking__c = ApplyServices.PICKLIST_NO;
        cont.sp.Completed_Degree_Level_Qualification__c = ApplyServices.PICKLIST_NO;
        cont.sp.Cert_for_Approved_Country_Specific_Qual__c = ApplyServices.PICKLIST_NO;
        cont.sp.Cert_for_English_Language_Test__c = ApplyServices.PICKLIST_NO;
        cont.sp.Intend_to_Take_English_Language_Test__c = ApplyServices.PICKLIST_YES;
        cont.validate();
        //System.assert(!cont.errorByStep.get(ApplyServices.STEP_LANGUAGE_QUALIFICATIONS));
        
        // fix references
        //System.assert(cont.errorByStep.get(ApplyServices.STEP_REFERENCES));
        cont.references[0].referee.LastName = tv;
        cont.validate();
        System.assert(cont.isValidationErrors);
        System.assert(!cont.errorByStep.get(ApplyServices.STEP_REFERENCES));
        
        // fix visa history
        //System.assert(cont.errorByStep.get(ApplyServices.STEP_VISA_HISTORY));
        //System.assert(!cont.needVisaFurtherDetails);
        cont.sp.UK_Visa_Required__c = ApplyWizardContExt.UK_VISA_REQUIRED_OTHER;
        //System.assert(cont.needVisaFurtherDetails);
        cont.validate();
        //System.assert(cont.errorByStep.get(ApplyServices.STEP_VISA_HISTORY)); // still error with blank UK type of visa
        //System.assert(cont.isValidationErrors);
        cont.student.HESA_Nationality__c = ApplyTestingUtils.hesaCodes[0].Id; // EEA
        cont.validate();
        //System.assert(cont.isEEAStudent);
        //System.assert(!cont.errorByStep.get(ApplyServices.STEP_VISA_HISTORY)); // error gone for EEA student 
        cont.student.HESA_Nationality__c = ApplyTestingUtils.hesaCodes[2].Id; // nonEEA again
        cont.qeMap.get(ApplyServices.RT_ACADEMIC_QE_DEVNAME)[0].item.Type_Of_Visa__c = tv;
        cont.validate();
        //System.assert(!cont.isEEAStudent);
        //System.assert(cont.isValidationErrors);
        //System.assert(!cont.errorByStep.get(ApplyServices.STEP_VISA_HISTORY));
        
        // fix declaration and save
        //System.assert(cont.errorByStep.get(ApplyServices.STEP_DECLARATION));
        cont.sp.Do_you_have_any_Criminal_Convictions__c = ApplyServices.PICKLIST_NO;
        cont.validate();
        //System.assert(!cont.errorByStep.get(ApplyServices.STEP_DECLARATION));
        //System.assert(!cont.isValidationErrors);
        //Suyati Modified
        cont.validateShortCourses();
        Test.stopTest();
    }
    
    static testMethod void testSaveDraftApplication() {
        
        ApplyTestingUtils.setupTestData();
        createControllerRelatedStuff();
        Test.setCurrentPageReference(new PageReference('Page.ApplyWizard'));
        System.currentPageReference().getParameters().put('id', ApplyTestingUtils.sp.Id);
        System.debug('*************************ApplyTestingUtils.sp.Test_Class_Record__c = '+ApplyTestingUtils.sp.Test_Class_Record__c);
        Test.startTest();
        ApplyWizardContExt cont = new ApplyWizardContExt();
        //ApplyWizardContExt cont = new ApplyWizardContExt(new ApexPages.Standardcontroller(ApplyTestingUtils.sp));
        cont.init();
        
        // set dummy values for required fields
        cont.student.LastName = '';
        cont.student.FirstName = 'John';
        cont.student.HESA_Domicile__c = ApplyTestingUtils.hesaCodes[3].Id;
        cont.saveDraftApplication();
        System.assertEquals(ApplyServices.DUMMY_REQUIRED_STRING, cont.student.LastName);
        Test.stopTest();
    }

}