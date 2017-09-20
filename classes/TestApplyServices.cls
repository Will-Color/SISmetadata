/**
 * @author Mykola Senyk
 * @date 20/06/2014
 * @description Unit test for ApplyServices class
 */
@isTest
private class TestApplyServices {
    
    static void testGetIndividualAccount() {
        ApplyTestingUtils.setupTestData();
        Account testAccount = ApplyServices.getIndividualAccount();
        System.assertEquals(testAccount.Name, ApplyTestingUtils.INDIVIDUAL_ACCOUNT_NAME);
    }
    
    static testMethod void testBuildQualification() {
        ApplyTestingUtils.setupTestData();
        Qualifications_Experience__c qe = ApplyServices.buildQualification(ApplyTestingUtils.student.Id, ApplyTestingUtils.sp.Id, ApplyServices.RT_ACADEMIC_QE_DEVNAME);
        System.assert(qe.Id == null);       
        System.assertEquals(CommonUtils.findRecordTypeIdByDev('Qualifications_Experience__c', ApplyServices.RT_ACADEMIC_QE_DEVNAME), qe.RecordTypeId);
        System.assertEquals(ApplyTestingUtils.student.Id, qe.Contact__c);
        // add different experience
        qe = ApplyServices.buildQualification(ApplyTestingUtils.student.Id, ApplyTestingUtils.sp.Id, ApplyServices.RT_EXPERIENCE_QE_DEVNAME);
        System.assert(qe.Id == null);       
        System.assertEquals(CommonUtils.findRecordTypeIdByDev('Qualifications_Experience__c', ApplyServices.RT_EXPERIENCE_QE_DEVNAME), qe.RecordTypeId);
        System.assertEquals(ApplyTestingUtils.student.Id, qe.Contact__c);
    }
    
    static testMethod void testFindPersonalDetails() {
        ApplyTestingUtils.setupTestData();
        
        // find contact
        Contact cont = ApplyServices.findPersonalDetails(ApplyTestingUtils.student.Id);
        System.assert(cont != null);
        System.assertEquals(ApplyTestingUtils.student.Id, cont.Id);
        
        // unable to find contact after delete
        delete cont;
        try {
            ApplyServices.findPersonalDetails(ApplyTestingUtils.student.Id);
            System.assert(false);
        } catch (QueryException e) {
            System.assert(true);
        }
    }
    
    static testMethod void testFindRelatedQualifications() {
        ApplyTestingUtils.setupTestData();
        Id contactId = ApplyTestingUtils.student.Id;
        // all
        List<Qualifications_Experience__c> qeList = ApplyServices.findRelatedQualifications(contactId);
        System.assertEquals(ApplyTestingUtils.qualifications.size(), qeList.size());
        for (Qualifications_Experience__c qe: qeList) {
            System.assertEquals(contactId, qe.Contact__c);
           // System.assertEquals(ApplyTestingUtils.sp.Id, qe.Student_Programme__c);
        }
        
        // for given RT only
        Id langRtId = CommonUtils.findRecordTypeIdByDev('Qualifications_Experience__c', ApplyServices.RT_LANGUAGE_QE_DEVNAME);
        Set<Id> rtIds = new Set<Id>{ langRtId };
        qeList = ApplyServices.findRelatedQualifications(contactId, rtIds);
        System.assertEquals(1, qeList.size());
        Qualifications_Experience__c qe = qeList[0];
        System.assertEquals(contactId, qe.Contact__c);
        //System.assertEquals(ApplyTestingUtils.sp.Id, qe.Student_Programme__c);
        System.assertEquals(langRtId, qe.RecordTypeId);
    }
    
    static testMethod void testFindRelatedReferences() {
        ApplyTestingUtils.setupTestData();
        Id contactId = ApplyTestingUtils.student.Id;
        List<References__c> refList = ApplyServices.findRelatedReferences(contactId);
        System.assertEquals(1, refList.size());
        System.assertEquals(contactId, refList[0].Applicant__c);
       // System.assertEquals(ApplyTestingUtils.sp.Id, refList[0].Student_Programme__c);
    }
    
    static testMethod void testCreateCourseByProgrammeId() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Id progId;
        User commUser;
        System.runAs(thisUser) {
            ApplyTestingUtils.setupTestData();
            progId = ApplyTestingUtils.prog.Id;
            commUser = ApplyTestingUtils.createCommunityUser('Doe', 'dd@test.com', ApplyTestingUtils.CUSTOMER_COMMUNITY_PROFILE_NAME);  
        }
        Test.startTest();
        System.runAs(thisUser) {
            Student_Programme__c course = Applyservices.createCourseByProgrammeId(progId);
            System.assertEquals(progId, course.Programme__c);
            System.assertEquals(ApplyServices.COURSE_INIT_STAGE_NAME, course.Stage__c);
           // System.assertEquals(commUser.ContactId, course.Student__c);
        }
        Test.stopTest();
    }
    
    @isTest(seeAllData = true)
    static void testCreateCourseForSFByProgrammeId() {
        ApplyTestingUtils.setupTestData();
        Id progId = ApplyTestingUtils.prog.Id;
        Student_Programme__c course = Applyservices.createCourseByProgrammeId(progId);
        System.assertEquals(progId, course.Programme__c);
        System.assertEquals(ApplyServices.COURSE_INIT_STAGE_NAME, course.Stage__c);
    }
    
    static testMethod void testBuildNameOfApplication() {
        ApplyTestingUtils.setupTestData();
        Id progId = ApplyTestingUtils.prog.Id;
        String applicationName = ApplyServices.buildNameOfApplication(progId, ApplyTestingUtils.STUDENT_LAST_NAME);
        System.assertEquals(ApplyTestingUtils.STUDENT_LAST_NAME + ' - ' + ApplyTestingUtils.PROGRAMME_VERSION_CODE, applicationName);
    }

    static testMethod void testGetProgrammeType() {
        ApplyTestingUtils.setupTestData();
        String pType = ApplyServices.getProgrammeType(ApplyTestingUtils.sp.Id);
        System.assertEquals(ApplyTestingUtils.PROGRAMME_TYPE, pType);
    }
    
}