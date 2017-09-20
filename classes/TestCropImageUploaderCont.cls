/**
 * @author Mykola Senyk
 * @date 08/07/2014
 * @description Unit test for CropImageUploaderCont class
 */
@isTest
private class TestCropImageUploaderCont {
    
    static testMethod void testUploadImage() {
        Contact student = ApplytestingUtils.createStudent(true);
        System.assert(!CommonUtils.hasAttachment(student.Id));
        String testData = 'Just test data as attachment body Кириллица'; // not valid Base64 string
        String testDescription = 'Descr';
  
        
        
        CropImageUploaderCont cont = new CropImageUploaderCont();
        
        
         id recType = Schema.SObjectType.Programme_Version__c.getRecordTypeInfosByName().get('Versions - Pre Approved').getRecordTypeId();
         //[SELECT Id, Name FROM RecordType where Name = 'Versions - Pre Approved' limit 1].id;
        id recType1 = Schema.SObjectType.Programme_Version__c.getRecordTypeInfosByName().get('Master Version').getRecordTypeId();
        //[SELECT Id, Name FROM RecordType where Name = 'Master Version' limit 1].id;

        Programme_Version__c pV1= new Programme_Version__c();
        pV1.Name = 'Test';
        pV1.Entry_Award_1__c = 'MSc';
        pV1.Active__c = true;
        pV1.RecordTypeid = recType1;
        INSERT pV1;
        
        Programme_Version__c pV= new Programme_Version__c();
        pV.Name = 'Test';
        pV.Entry_Award_1__c = 'MSc';
        pV.Active__c = true;
        pV.RecordTypeid = recType;
        pV.Master_Link__c = pV1.id;
        INSERT pV;

        Programme__c prog = new Programme__c();
        prog.Name ='testProgramme';
        prog.Overseas_Fee__c = 1000;
        prog.Home_EU_Fee__c = 500;       
        prog.Programme_Version__c = pV.id;
        prog.Test_Class_Record__c = true;
        INSERT prog;

        Student_Programme__c sp = new Student_Programme__c();
         sp .Name='test';
         sp.Student__c =student.Id;
         sp.LSTM_No__c= '00012345';
         sp.Fee_Status__c = 'Overseas';
         sp.Programme__c = prog.Id;
         sp.Test_Class_Record__c = true;
         insert sp;
         System.Debug('sp:'+sp);
         cont.attParentId = sp.Id;
        cont.attDescription = testDescription;
        
        // empty attachment
        cont.uploadImage();
        System.assert(!CommonUtils.hasAttachment(sp.Id));
        
        // wrong Base64 data
        cont.imageBody = testData;
        try {
            cont.uploadImage();
            System.assert(false);
        } catch(Exception e) {
            System.assert(true);
        }
        System.assert(!CommonUtils.hasAttachment(sp.Id));
        
        // valid Base64 data
        cont.imageBody = EncodingUtil.base64Encode(Blob.valueOf(testData));
        cont.uploadImage();
        System.assert(CommonUtils.hasAttachment(sp.Id));
        List<Attachment> aList = CommonUtils.findAttachments(sp.Id, testDescription);
        System.assertEquals(1, aList.size());
        Attachment prevAttachment = aList[0];
        System.assert(String.isBlank(cont.imageBody));
        
        // delete previous attachment
        cont.imageBody = EncodingUtil.base64Encode(Blob.valueOf(testData));
        cont.uploadImage();
        System.assert(CommonUtils.hasAttachment(sp.Id));
        aList = CommonUtils.findAttachments(sp.Id, testDescription);
        System.assertEquals(1, aList.size());
        System.assertNotEquals(prevAttachment.Id, aList[0].Id);
    }

}