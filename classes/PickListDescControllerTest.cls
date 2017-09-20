@isTest(seeAllData=true)
public class PickListDescControllerTest{
    static final String PROGRAMME_VERSION = 'Programme_Version__c';
    static final String PROGRAMME_NAME = 'Diploma in Tropical Nursing';
    static final String PROGRAMME_TYPE = ApplyServices.PT_PROFESSIONAL_DIPLOMA;
    
    static Programme__c prog { get; set; }
    static Student_Programme__c sp { get; set; }
    static Contact student { get; set; }
    static Programme_Version__c mv { get; set; }
    static Programme_Version__c pv { get; set; }
    
    public static testMethod void testController1() {
        RecordType rt = [select id,Name from RecordType where SobjectType='Student_Programme__c' Limit 1];
        setupTestData();
        prog = VleTestingUtils.createProgramme(PROGRAMME_NAME, pv.Id, false);
        insert prog;
        student = VleTestingUtils.createStudent(true);
        sp = VleTestingUtils.createStudentProgramme(prog.Id, student.Id, false);
        
        test.startTest();  
        Test.setCurrentPageReference(new PageReference('Page.PicklistDesc'));
        System.currentPageReference().getParameters().put('id', sp.id);
        System.currentPageReference().getParameters().put('recordTypeName', rt.name);
        System.currentPageReference().getParameters().put('sobjectType', 'Student_Programme__c');
        System.currentPageReference().getParameters().put('picklistFieldName ', 'Stage__c');
                
        PickListDescController obj = new PickListDescController();                     
        test.stopTest();
    }    
    
    public static testMethod void testController2() {
        RecordType rt = [select id,Name from RecordType where SobjectType='Student_Programme__c' Limit 1];
        setupTestData();
        prog = VleTestingUtils.createProgramme(PROGRAMME_NAME, pv.Id, false);
        insert prog;
        student = VleTestingUtils.createStudent(true);
        sp = VleTestingUtils.createStudentProgramme(prog.Id, student.Id, false);
        
        test.startTest();  
        Test.setCurrentPageReference(new PageReference('Page.PicklistDesc'));
        System.currentPageReference().getParameters().put('id', sp.id);
        System.currentPageReference().getParameters().put('recordTypeId', rt.id);
        System.currentPageReference().getParameters().put('recordTypeName', rt.name);
        System.currentPageReference().getParameters().put('sobjectType', 'Student_Programme__c');
        System.currentPageReference().getParameters().put('picklistFieldName ', 'Stage__c');                
        PickListDescController obj = new PickListDescController();                     
        test.stopTest();
    }        
    
    public static testMethod void testController3() {
        RecordType rt = [select id,Name from RecordType where SobjectType='Student_Programme__c' Limit 1];
        setupTestData();
        prog = VleTestingUtils.createProgramme(PROGRAMME_NAME, pv.Id, false);
        insert prog;
        student = VleTestingUtils.createStudent(true);
        sp = VleTestingUtils.createStudentProgramme(prog.Id, student.Id, false);
        
        test.startTest();  
        Test.setCurrentPageReference(new PageReference('Page.PicklistDesc'));
        System.currentPageReference().getParameters().put('id', sp.id);
        PickListDescController obj = new PickListDescController();                     
        test.stopTest();
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