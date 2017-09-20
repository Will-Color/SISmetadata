@isTest(SeeAllData=true)

public class PAPMemberTriggerMethodsTest {
    
    static final String PROGRAMME_NAME = 'PhD - Full Time Speculative - 17/18 Registration';  
    static final String PROGRAMME_VERSION = 'Programme_Version__c';
    static final String PROGRAMME_TYPE = ApplyServices.PT_PGR;    
    
    
    static testmethod void papInsertion(){
        
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
        
        Contact staff = VleTestingUtils.CreateStudent(true);
        
        Student_Programme__c sp = VleTestingUtils.CreateStudentProgramme(prog.Id, staff.Id, true);   
        
        List<PAP_Member__c> listPapMemberToInsert = new List<PAP_Member__c>();
        for(integer i=0;i<10;i++){
            PAP_Member__c papMember = new PAP_Member__c();
            PapMember.Panel_Member__c = staff.Id;
            listPapMemberToInsert.add(papMember);
        }
        PAP_Member__c papMember1 = new PAP_Member__c();
        PapMember1.Panel_Member__c = staff.Id;

        listPapMemberToInsert.add(papMember1);
        Test.startTest();
        insert listPapMemberToInsert;
        update listPapMemberToInsert;
        delete listPapMemberToInsert;
        Test.stopTest();
        
    }
}