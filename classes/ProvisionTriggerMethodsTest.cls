@isTest(seeAlldata=true)
public class ProvisionTriggerMethodsTest{
        
    static final String PROGRAMME_NAME = 'Diploma in Tropical Nursing';  
    static final String PROGRAMME_VERSION = 'Programme_Version__c';
    static final String PROGRAMME_TYPE = ApplyServices.PT_PROFESSIONAL_DIPLOMA;    
  
    public static testMethod void insertProvision(){
        
        Id mvrtId = CommonUtils.findRecordTypeIdByDev(PROGRAMME_VERSION, ApplyServices.RT_MASTER_PV_DEVNAME);
        Programme_Version__c mv = VleTestingUtils.createMasterProgrammeVersion(PROGRAMME_NAME, mvrtId, PROGRAMME_TYPE, false);
        mv.Code__c = StudentProgrammeTriggerMethods.CODE_DTN;
        insert mv;

        Id rtId = CommonUtils.findRecordTypeIdByDev(PROGRAMME_VERSION, ApplyServices.RT_VERSION_PV_DEVNAME);
        Programme_Version__c pv = VleTestingUtils.createProgrammeVersion(PROGRAMME_NAME, rtId, PROGRAMME_TYPE, mv.Id, false);
        pv.Code__c = StudentProgrammeTriggerMethods.CODE_DTN;
        insert pv;
        
        Programme__c prog = VleTestingUtils.createProgramme(PROGRAMME_NAME, pv.Id, false);
        insert prog;
        Contact student = VleTestingUtils.CreateStudent(true);
        Student_Programme__c sp = VleTestingUtils.CreateStudentProgramme(prog.Id, student.Id, true);        
        
        Test.startTest();
        List<Provision__c> provisionList = new List<Provision__c>();
        for(integer i=0;i<10;i++)
        {
            Provision__c provision = new Provision__c();
            provision.Name = 'Test Provision' + string.ValueOf(i);
            provision.Student_Staff__c = student.Id;
            provision.Student_Programme__c = sp.Id;
            provision.AD_Account_Created_Updated__c='Yes';
            provision.Expiry_date__c=system.today()+1;
            provisionList.add(provision);
        }
        Provision__c Provision1 = new Provision__c();
        provision1.Name = 'Test Provision';
        provision1.Student_Staff__c = student.Id;
        provision1.Student_Programme__c = sp.Id;
        provision1.AD_Account_Created_Updated__c='No';
        provision1.Expiry_date__c=system.today()-1;
        provisionList.add(provision1);
        
            
        insert provisionList;
        Provision__c insertedProvision = [SELECT Password__c FROM Provision__c WHERE Id IN: provisionList LIMIT 1];
        system.debug('insertedProvision '+insertedProvision.Password__c );
        system.AssertEquals(insertedProvision.Password__c.length(),8);
        delete provisionList;
        undelete provisionList;
        Test.stopTest();
    }
}