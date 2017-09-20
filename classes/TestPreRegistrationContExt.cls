/**
 * @author Valentyn Bilenkyi
 * @date 08/07/2014
 * @description Unit test for PreRegistrationContExt class
 */
@isTest
private class TestPreRegistrationContExt {

    private static final String STUDENT_MAILING_STREET = 'Street Name';
    private static final String QE_GRADE = 'String';
    private static final String QE_UNIVERSITY_1 = 'University 1';
    private static final String QE_UNIVERSITY_2 = 'University 2';
    private static final String SPONSORED_STRING = 'Sponsored';
    
    static void insertTestAttachment(Id parentId) {
        Attachment attachment = new Attachment();
        attachment.ParentId = parentId;
        attachment.Name = 'Test Name';
        attachment.IsPrivate = true;
        attachment.Description = PreRegistrationContExt.PASSPORT_PHOTO_ATTACHMENT_DESCRIPTION;
        Blob b = Blob.valueOf('Test Data');
        attachment.Body = b;
        insert attachment;
    }

    @isTest static void testAddQE() {
        ApplyTestingUtils.setupTestData();
        Test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.PreRegistration'));
            System.currentPageReference().getParameters().put('id', ApplyTestingUtils.sp.Id);
            PreRegistrationContExt ctrl = new PreRegistrationContExt();
            //PreRegistrationContExt ctrl = new PreRegistrationContExt(new ApexPages.Standardcontroller(ApplyTestingUtils.sp));
            
            //Suyati Modified 28-04-2016
            String str;
            str = ctrl.getProfilePicture();
            Boolean readOnlyUpload ;
            readOnlyUpload = ctrl.readonlyUpload;
            // Suyati Modified End
            
            System.assertEquals(0, ctrl.newQeList.size());
            ctrl.addAcademicQE();
            System.assertEquals(1, ctrl.newQeList.size());
            ctrl.addProfessionalQE();
            System.assertEquals(2, ctrl.newQeList.size());
            ctrl.validate();
             //Suyati Modified 01-04-2016
            Contact con = new Contact(LastName = 'test');
            INSERT con;
            
            Attachment attach = new Attachment();
            attach.Name = 'test';
            attach.body = Blob.valueof('iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB9YGARc5KB0XV+IAAAAddEVYdENvbW1lbnQAQ3JlYXRlZCB3aXRoIFRoZSBHSU1Q72QlbgAAAF1JREFUGNO9zL0NglAAxPEfdLTs4BZM4DIO4C7OwQg2JoQ9LE1exdlYvBBeZ7jqch9//q1uH4TLzw4d6+ErXMMcXuHWxId3KOETnnXXV6MJpcq2MLaI97CER3N0vr4MkhoXe0rZigAAAABJRU5ErkJggg==');
            attach.ParentId  = con.Id;
            INSERT attach;
            
            string profilepic = ctrl.getProfilePicture();
            //Suyati Modified End
            System.assertEquals(0, ctrl.newQeList.size());
        Test.stopTest();
    }

    @isTest static void testController() {
        ApplyTestingUtils.setupTestData();
        Test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.PreRegistration'));
            System.currentPageReference().getParameters().put('id', ApplyTestingUtils.sp.Id);
            PreRegistrationContExt ctrl = new PreRegistrationContExt();
            //PreRegistrationContExt ctrl = new PreRegistrationContExt(new ApexPages.Standardcontroller(ApplyTestingUtils.sp));
            System.assertNotEquals(null, ctrl);
            System.assertNotEquals(null, ctrl.qeLabels);
            System.assertNotEquals(null, ctrl.textFromTermsAndConditions);
            System.assertNotEquals(null, ctrl.textFromDataProtection);
            //qualifications
            Qualifications_Experience__c qe = new Qualifications_Experience__c(
                //Student_Programme__c = ctrl.sp.Id, 
                Contact__c = ctrl.student.Id, 
                RecordTypeId = CommonUtils.findRecordTypeIdByDev('Qualifications_Experience__c', ApplyServices.RT_ACADEMIC_QE_DEVNAME)
            );
            qe.Test_Class_Record__c = True;
            insert qe;
            List<Qualifications_Experience__c> qel  = ctrl.qeList;
            Id artId = CommonUtils.findRecordTypeIdByDev('Qualifications_Experience__c', ApplyServices.RT_ACADEMIC_QE_DEVNAME);
            Id prtId = CommonUtils.findRecordTypeIdByDev('Qualifications_Experience__c', ApplyServices.RT_PROFESSIONAL_QE_DEVNAME);
            List<Qualifications_Experience__c> eqList = new List<Qualifications_Experience__c>();
            for(Qualifications_Experience__c q : ApplyTestingUtils.qualifications) {
                if(q.RecordTypeId == artId || q.RecordTypeId == prtId) eqList.add(q);
            }
            System.assertEquals(eqList.size()+1, qel.size());
            ctrl.init();
            System.assertEquals(eqList.size(), ctrl.qeList.size());
            // step movement
            System.assertEquals(0, ctrl.step.stepIndex);
            ctrl.gotoNextStep();
            System.assertEquals(1, ctrl.step.stepIndex);
            ctrl.gotoPreviousStep();
            System.assertEquals(0, ctrl.step.stepIndex);
            ctrl.stepName = PreRegistrationServices.STEP_PERSONAL_ADDRESS;
            ctrl.gotoStep();
            System.assertEquals(PreRegistrationServices.STEP_PERSONAL_ADDRESS, ctrl.step.getName());
            System.assertEquals(PreRegistrationServices.stepTitles.get(PreRegistrationServices.STEP_PERSONAL_ADDRESS), ctrl.step.getTitle());
            ctrl.stepName = PreRegistrationServices.STEP_ACADEMIC_QUALIFICATIONS;
            ctrl.gotoStep();
            System.assertEquals(PreRegistrationServices.STEP_ACADEMIC_QUALIFICATIONS, ctrl.step.getName());
            ctrl.addAcademicQE();
            ctrl.addProfessionalQE();
            System.assertEquals(2, ctrl.newQeList.size());
            ctrl.gotoNextStep();
            System.assertEquals(0, ctrl.newQeList.size());
            //passport attachment
            System.assertEquals(null, ctrl.passportAttachmentId);
            insertTestAttachment(ctrl.student.Id);
            //System.assertNotEquals(null, ctrl.passportAttachmentId);
        Test.stopTest();
    }

    @isTest static void testGetCountriesOptions() {
        ApplyTestingUtils.setupTestData();
        Test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.PreRegistration'));
            System.currentPageReference().getParameters().put('id', ApplyTestingUtils.sp.Id);
            PreRegistrationContExt ctrl = new PreRegistrationContExt();
            //PreRegistrationContExt ctrl = new PreRegistrationContExt(new ApexPages.Standardcontroller(ApplyTestingUtils.sp));
            List<SelectOption> countriesOptions = ctrl.getCountriesOptions();
            System.assertNotEquals(null, countriesOptions);
        Test.stopTest();
    }

    @isTest static void testGetStudentProgrammes() {
        ApplyTestingUtils.setupTestData();
        Test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.PreRegistration'));
            System.currentPageReference().getParameters().put('id', ApplyTestingUtils.sp.Id);
            PreRegistrationContExt ctrl = new PreRegistrationContExt();
            //PreRegistrationContExt ctrl = new PreRegistrationContExt(new ApexPages.Standardcontroller(ApplyTestingUtils.sp));
            List<ProgrammeWrapper> studentProgrammes = ctrl.getStudentProgrammes();
            System.assertEquals(1, studentProgrammes.size());
        Test.stopTest();
    }

    @isTest static void testSaveDraftApplication() {
        ApplyTestingUtils.setupTestData();
        Test.startTest();
            PreRegistrationContExt ctrl;
            Test.setCurrentPageReference(new PageReference('Page.PreRegistration'));
            System.currentPageReference().getParameters().put('id', ApplyTestingUtils.sp.Id);
            ctrl = new PreRegistrationContExt();
            //ctrl = new PreRegistrationContExt(new ApexPages.Standardcontroller(ApplyTestingUtils.sp));
            
            System.assertEquals(null, ctrl.student.MailingStreet);
            ctrl.student.MailingStreet = STUDENT_MAILING_STREET;
            
            System.assertEquals(null, ctrl.qeList[0].Class_Grade__c);
            ctrl.qeList[0].Class_Grade__c = QE_GRADE;
            Integer qeListSize = ctrl.qeList.size();

            ctrl.addAcademicQE();
            System.assertEquals(null, ctrl.newQeList[0].Name_of_College_University__c);
            ctrl.newQeList[0].Name_of_College_University__c = QE_UNIVERSITY_1;
            ctrl.addProfessionalQE();
            System.assertEquals(null, ctrl.newQeList[1].Name_of_College_University__c);
            ctrl.newQeList[1].Name_of_College_University__c = QE_UNIVERSITY_2;
            Integer newQeListSize = qeListSize + 2;

            System.assertEquals(null, ctrl.sp.Fees_and_Funding__c);
            ctrl.sp.Fees_and_Funding__c = SPONSORED_STRING;

            ctrl.saveDraftApplication();

            Test.setCurrentPageReference(new PageReference('Page.PreRegistration'));
            System.currentPageReference().getParameters().put('id', ApplyTestingUtils.sp.Id);
            ctrl = new PreRegistrationContExt();
            //ctrl = new PreRegistrationContExt(new ApexPages.Standardcontroller(ApplyTestingUtils.sp));
            Integer maxQeListIndex = qeListSize -1;
            System.assertEquals(STUDENT_MAILING_STREET, ctrl.student.MailingStreet);
            System.assertEquals(QE_GRADE, ctrl.qeList[0].Class_Grade__c);
            System.assertEquals(newQeListSize, ctrl.qeList.size());
            System.assertEquals(QE_UNIVERSITY_1, ctrl.qeList[maxQeListIndex + 1].Name_of_College_University__c);
            System.assertEquals(QE_UNIVERSITY_2, ctrl.qeList[maxQeListIndex + 2].Name_of_College_University__c);
            System.assertEquals(SPONSORED_STRING, ctrl.sp.Fees_and_Funding__c);

        Test.stopTest();
    }

    @isTest static void testValidate() {
        ApplyTestingUtils.setupTestData();
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.PreRegistration'));
            System.currentPageReference().getParameters().put('id', ApplyTestingUtils.sp.Id);
            PreRegistrationContExt ctrl = new PreRegistrationContExt();
        //PreRegistrationContExt ctrl = new PreRegistrationContExt(new ApexPages.Standardcontroller(ApplyTestingUtils.sp));
        ctrl.validate();
        System.assert(ctrl.isValidationErrors);
        System.assertEquals(false, ctrl.readonlyMode);

        // fix personal address
        System.assert(ctrl.errorByStep.get(PreRegistrationServices.STEP_PERSONAL_ADDRESS));
        ctrl.student.MailingCity = 'London';
        ctrl.student.MailingCountry = 'UK';
        ctrl.student.MailingPostalCode = '36000';
        ctrl.student.MailingState = 'Wales';
        ctrl.student.MailingStreet = 'Baker Str., 221B';
        ctrl.validate();
        System.assert(ctrl.isValidationErrors);
        System.assert(!ctrl.errorByStep.get(PreRegistrationServices.STEP_PERSONAL_ADDRESS));
        
        // fix term time address
        //2015-03-27 : SM : TTA fields no longer validated nor is ECD Address
        System.assert(ctrl.errorByStep.get(PreRegistrationServices.STEP_TERM_TIME_ADDRESS));
        //ctrl.sp.TTA_City__c = 'London';
        //ctrl.sp.TTA_Country__c = 'UK';
        //ctrl.sp.TTA_Postcode__c = '36000';
        //ctrl.sp.TTA_County__c = 'Wales';
        //ctrl.sp.TTA_Street__c = 'Baker Str., 221B';
        //ctrl.sp.ECD_Address__c = 'UK, London, Wales, 36000, Baker St, 221B';
        ctrl.sp.ECD_Phone__c = '01511111111';
        ctrl.sp.ECD_Name__c = 'Edward Collins';
        ctrl.sp.ECD_Relationship__c = 'friend';
        ctrl.validate();
        System.assert(ctrl.isValidationErrors);
        System.assert(!ctrl.errorByStep.get(PreRegistrationServices.STEP_TERM_TIME_ADDRESS));
        
        // fix passport photo
        //System.assert(ctrl.errorByStep.get(PreRegistrationServices.STEP_UPLOAD_PHOTO));
        insertTestAttachment(ctrl.student.Id);
        ctrl.validate();
        System.assert(ctrl.isValidationErrors);
        //System.assert(!ctrl.errorByStep.get(PreRegistrationServices.STEP_UPLOAD_PHOTO));
        
        // terms accepted & stage
        System.assert(ctrl.errorByStep.get(PreRegistrationServices.STEP_TERMS_AND_CONDITIONS));
        //System.assertEquals(ApplyServices.COURSE_EXPECTED_STAGE_NAME, ctrl.sp.Stage__c);
        ctrl.isTermsChecked = true;
        ctrl.isDataProtectionChecked = true;
        ctrl.validate();
        //System.assertEquals(true, ctrl.readonlyMode);
        //System.assert(!ctrl.isValidationErrors);
        //System.assert(!ctrl.errorByStep.get(PreRegistrationServices.STEP_TERMS_AND_CONDITIONS));
        //System.assertEquals(ApplyServices.COURSE_PRE_REGISTERED_STAGE_NAME, ctrl.sp.Stage__c);
        
        Test.stopTest();
    }

}