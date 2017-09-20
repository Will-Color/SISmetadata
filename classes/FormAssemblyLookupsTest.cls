@IsTest
public class FormAssemblyLookupsTest{

    public static testMethod void  testFormAssemblyLookups(){
        id recType = Schema.SObjectType.Programme_Version__c.getRecordTypeInfosByName().get('Versions - Pre Approved').getRecordTypeId();
        id recType1 = Schema.SObjectType.Programme_Version__c.getRecordTypeInfosByName().get('Master Version').getRecordTypeId();
        
        HESA_Code__c domicile = new HESA_Code__c();
        domicile.Name = 'Ireland';
        domicile.Active__c = true;
        domicile.RecordTypeId = Schema.SObjectType.HESA_Code__c.getRecordTypeInfosByName().get('Domicile').getRecordTypeId();
        insert domicile;
        
        HESA_Code__c nationality = new HESA_Code__c();
        nationality.Name = 'England';
        nationality.Active__c = true;
        nationality.RecordTypeId = Schema.SObjectType.HESA_Code__c.getRecordTypeInfosByName().get('Nationality').getRecordTypeId();
        insert nationality;
        
        HESA_Code__c fee = new HESA_Code__c();
        fee.Name = 'British Academy';
        fee.Active__c = true;
        fee.RecordTypeId = Schema.SObjectType.HESA_Code__c.getRecordTypeInfosByName().get('MSTUFEE').getRecordTypeId();
        insert fee;        
                
        Contact student = ApplytestingUtils.createStudent(true); 
        student.Domicile__c = Contact.Domicile__c.getDescribe().getPicklistValues()[0].getValue();

        student.Nationality__c = Contact.Nationality__c.getDescribe().getPicklistValues()[0].getValue();
        update student;
        
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
        sp.MSTUFEE_FA__c = 'British Academy';
        sp.Test_Class_Record__c = true;         

        insert sp;
        
        Test.startTest();     
        
        sp.Stage__c = 'Submitted';
        update sp;
        
        Test.stopTest();        
        
        Contact updatedStudent = [SELECT Id, HESA_Domicile__c,HESA_Nationality__c FROM Contact WHERE Id =: student.Id];
        Student_Programme__c updatedSP = [SELECT Id,Major_source_of_tuition_fees__c FROM Student_Programme__c WHERE Id =: sp.Id];
        //system.assertEquals(updatedStudent.HESA_Domicile__c, domicile.Id);
        //system.assertEquals(updatedStudent.HESA_Nationality__c, nationality.Id);
        //system.assertEquals(updatedSP.Major_source_of_tuition_fees__c, fee.Id);        
        
    }
}