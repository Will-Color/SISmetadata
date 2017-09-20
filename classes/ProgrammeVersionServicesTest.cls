/**
 * 2016-12-28 : CSL : Test class for ProgrammeVersionServices
 */

@isTest
private class ProgrammeVersionServicesTest{

    static final String PROGRAMME_VERSION = 'Programme_Version__c';
    static final String PROGRAMME_NAME = 'Diploma in Tropical Nursing';
    static final String PROGRAMME_TYPE = ApplyServices.PT_PROFESSIONAL_DIPLOMA;

    static Programme__c prog { get; set; }
    //static Student_Programme__c sp { get; set; }
    static Contact student { get; set; }
    static Programme_Version__c mv { get; set; }
    static Programme_Version__c pv { get; set; }
    
    static testMethod void testCreateMandatoryModules() {

        Id mvrtId = CommonUtils.findRecordTypeIdByDev(PROGRAMME_VERSION, ApplyServices.RT_MASTER_PV_DEVNAME);
        mv = VleTestingUtils.createMasterProgrammeVersion(PROGRAMME_NAME, mvrtId, PROGRAMME_TYPE, false);
        mv.Code__c = StudentProgrammeTriggerMethods.CODE_DTN;
        insert mv;

        Id rtId = CommonUtils.findRecordTypeIdByDev(PROGRAMME_VERSION, ApplyServices.RT_VERSION_PV_DEVNAME);
        pv = VleTestingUtils.createProgrammeVersion(PROGRAMME_NAME, rtId, PROGRAMME_TYPE, mv.Id, false);
        pv.Code__c = StudentProgrammeTriggerMethods.CODE_DTN;
        insert pv;
        update pv;

        prog = VleTestingUtils.createProgramme(PROGRAMME_NAME, pv.Id, false);
        insert prog;
        Set<id> pvIds = new Set<Id>();
        pvIds.add(mv.Id);
        pvIds.add(pv.Id);        
        
        ProgrammeVersionServices obj = new ProgrammeVersionServices();
        ProgrammeVersionServices.createProgrameVersionContentAsXmlAttachment(pvIds);
    }
}