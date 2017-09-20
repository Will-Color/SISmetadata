@isTest(SeeAllData=true)
public class SupervisionTriggerMethodsTest 
{
    
    static final String PROGRAMME_VERSION = 'Programme_Version__c';
    static final String PROGRAMME_NAME = 'Diploma in Tropical Nursing';
    static final String PROGRAMME_TYPE = ApplyServices.PT_PROFESSIONAL_DIPLOMA;
    
    static Programme__c prog { get; set; }
    static Student_Programme__c sp { get; set; }
    static Contact student { get; set; }
    static Contact student1 { get; set; }
    static Programme_Version__c mv { get; set; }
    static Programme_Version__c pv { get; set; }
    
    static testMethod void testCreateMandatoryModules() 
    {
        setupTestData();      
        prog = VleTestingUtils.createProgramme(PROGRAMME_NAME, pv.Id, false);
        insert prog;
        student = VleTestingUtils.createStaff(true);
        student.Registered_Supervisor__c = true;
        update student;
        sp = VleTestingUtils.CreateStudentProgramme(prog.Id, student.Id, true);  
        student1 = VleTestingUtils.createStaff(true);
        student1.Registered_Supervisor__c = true;
        update student1;
        sp.Assigned_Supervisors__c  = student1.id;
        
        
        update sp;
        
        List<Supervision__c> spList = new List<Supervision__c>();
        for( integer i=0; i<50; i++)
        {
            Supervision__c spv = new Supervision__c();
            spv.Supervisor__c= student.id;
            spv.Student_Programme__c = sp.id;
            spv.Name = 'Supervisor';
            spList.add(spv);
        }
        Supervision__c spv1 = new Supervision__c();
        spv1.Supervisor__c= null;
        spv1.Student_Programme__c = sp.id;
        spv1.Name = 'Supervisor';
        spList.add(spv1);
        
        Test.startTest();
        insert spList;
        update spList;
        delete spList;
        Test.stopTest();
    } 
    
    static void setupTestData() 
    {
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