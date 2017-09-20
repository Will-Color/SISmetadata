/* TestQandERelatedlistControllerExt  Created by Manu KM on 08-sep-2015*/
/// <summary>
// This is Unit test for TeQandERelatedlistControllerExt  
/// </summary>
@isTest
public class TestQandERelatedlistControllerExt{
    //testmethod 
    public static testMethod void testPagination(){
        //creatin test contact
        contact testContact = new contact();
        testContact.lastName = 'TestLastName';
        insert testContact;
        //creating test student programme
        //Suyati Modified Start
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
        prog.Test_Class_Record__c = True;
        INSERT prog;
        //Suyati Modified End

        Student_Programme__c testSp = new Student_Programme__c();
        testSp.name = 'testSpName';
        testSp.Student__c  = testContact.Id;
        testSp.Fee_Status__c = 'Overseas';
        testSp.Programme__c = prog.Id;
        testSp.Test_Class_Record__c = True;
        /*
        //Student_Programme__c sp = new Student_Programme__c();
         //sp .Name='test';
         //sp.Student__c =student.Id;
         sp.LSTM_No__c= '00012345';
         sp.Fee_Status__c = 'Overseas';
         sp.Programme__c = prog.Id;
         insert sp;
        */
        insert testSp;
        ApexPages.StandardController sc = new ApexPages.StandardController(testSp);
        //setting URl page parameter for student programme as newly created student programme
        ApexPages.currentPage().getParameters().put('Id',testSp.Id);
        List< Qualifications_Experience__c > tesLstQandE = new List<Qualifications_Experience__c>();
        //insantiateing the class it also invokes the cunstructer methods
        QandERelatedlistControllerExt objParent = new QandERelatedlistControllerExt(sc);
        QandERelatedlistControllerExt objParent1 = new QandERelatedlistControllerExt();
        //create new Qualification and experience record
        Qualifications_Experience__c testQnandE = new Qualifications_Experience__c();
        testQnandE.Contact__c = testContact.Id; 
        testQnandE.Test_Class_Record__c = True; 
        insert testQnandE ;
        //verifies the soql query works
        tesLstQandE = objParent.getQandE();
        //Refreshes the page after action 
        PageReference testPage= objParent.refresh();
        
        objParent.deleteRecordId = testQnandE.Id;
        objParent.deleteRecord = testQnandE.Id;
        
        //Testing the pagination functions
        system.assertEquals(1,objParent.pageNumber,false);
        objParent.first();
        objParent.last();
        system.assertEquals(false,objParent.hasNext,false); 
        objParent.previous();
                
        objParent.next();
        system.assertEquals(false,objParent.hasPrevious,true);
        //testing the delete action                     
        objParent.deleteRecord();
        tesLstQandE = [select id from Qualifications_Experience__c];
        system.assertEquals(0,tesLstQandE.size());
    }  
}