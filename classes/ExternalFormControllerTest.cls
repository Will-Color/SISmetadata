@IsTest
public class ExternalFormControllerTest{

    public static testMethod void  testExternalFormController(){
        id recType = Schema.SObjectType.Programme_Version__c.getRecordTypeInfosByName().get('Versions - Pre Approved').getRecordTypeId();
        id recType1 = Schema.SObjectType.Programme_Version__c.getRecordTypeInfosByName().get('Master Version').getRecordTypeId();
        
        Contact student = ApplytestingUtils.createStudent(true); 
        
        Programme_Version__c pV1= new Programme_Version__c();
        pV1.Name = 'Test';
        pV1.Entry_Award_1__c = 'MSc';
        pV1.Active__c = true;
        pV1.RecordTypeid = recType1;
        pv1.Application_Form_Type__c = 'Form Assembly';
        INSERT pV1;
        
        Programme_Version__c pV= new Programme_Version__c();
        pV.Name = 'Test';
        pV.Entry_Award_1__c = 'PGDip';
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
        prog.External_Form__c = 'abc';
        INSERT prog;

        Student_Programme__c sp = new Student_Programme__c();
        sp .Name='test';
        sp.Student__c =student.Id;
        sp.LSTM_No__c= '00012345';
        sp.Fee_Status__c = 'Overseas';
        sp.Programme__c = prog.Id;
        sp.Test_Class_Record__c = true;         

        insert sp;
        
        Test.startTest();     
        Test.setMock(HttpCalloutMock.Class, new MockHttpResponseGenerator (200, 'OK', ''));   
        Test.setCurrentPageReference(new PageReference('Page.ExternalForm')); 
        System.currentPageReference().getParameters().put('SPID', sp.Id);
        System.currentPageReference().getParameters().put('LSTM_NO', student.LSTM_NO__c);        

        ExternalFormController obj = new ExternalFormController();
        Test.stopTest();        
        
    }
}