@isTest
public class TestModuleRegistrationContExt {
    public static testMethod void testModuleRegistration(){
        ApplyTestingUtils.setupTestData(); 
        Test.startTest();
        //Programme__c prog = ApplyTestingUtils.prog;
        id recType = Schema.SObjectType.Programme_Version__c.getRecordTypeInfosByName().get('Versions - Pre Approved').getRecordTypeId();
        id recType1 = Schema.SObjectType.Programme_Version__c.getRecordTypeInfosByName().get('Master Version').getRecordTypeId();
        
        Contact student = ApplytestingUtils.createStudent(true);        
        Programme_Version__c pV1= new Programme_Version__c();
        pV1.Name = 'Test';
        pV1.Entry_Award_1__c = 'MSc';
        pV1.Active__c = true;
        pV1.RecordTypeid = recType1;
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
        INSERT prog;

        Student_Programme__c sp = new Student_Programme__c();
         sp .Name='test';
         sp.Student__c =student.Id;
         sp.LSTM_No__c= '00012345';
         sp.Fee_Status__c = 'Overseas';
         sp.Programme__c = prog.Id;
         sp.Test_Class_Record__c = true;         
         insert sp;
        /*
        List<Student_Programme__c> lstSp = [SELECT Id from Student_Programme__c WHERE Id =: sp.Id];
        System.assertEquals(1, lstSp.size());
        */
        Programme_Module__c programmeModule = new Programme_Module__c();
        programmeModule.Programme__c = prog.Id;
        programmeModule.Member_Type__c ='Optional';
        programmeModule.Test_Class_Record__c = true;
        INSERT programmeModule;
        
        /*
        List<Programme_Module__c> lstPm = [SELECT Id FROM Programme_Module__c WHERE Id =: programmeModule.Id];
        System.assertEquals(1, lstPm.size());
        */
        
        Student_Module__c studentModule = new Student_Module__c();
        studentModule.Name='TestStudentModule';
        studentModule.Student_Programme__c = sp.Id;
        studentModule.Student__c = sp.Student__c;
        studentModule.Programme_Module__c = programmeModule.Id;
        studentModule.Test_Class_Record__c = true;
        INSERT studentModule;
        
        /*
        List<Student_Module__c> lstSM = [SELECT Id FROM Student_Module__c WHERE Id =: studentModule.Id];
        System.assertEquals(1, lstSM.size());
        */
        
       
            ModuleRegistrationContExt.application = sp;
            ApexPages.StandardController sc = new ApexPages.StandardController(sp);
            ModuleRegistrationContExt test1 = new ModuleRegistrationContExt(sc);
            ModuleRegistrationContExt.saveOptionalModules(programmeModule.Id,sp.Id,programmeModule.Id);
  
       Test.stopTest();
    }
}