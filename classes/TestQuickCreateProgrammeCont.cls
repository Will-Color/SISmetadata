/**
 * @author Mykola Senyk
 * @date 16/07/2014
 * @description Unit test for QuickCreateProgrammeCont class
 */
@isTest
private class TestQuickCreateProgrammeCont {
	
	static Programme__c findProgramme(Id progId) {
		return [
			SELECT Active__c, Capacity__c, End_Date__c, Home_EU_Fee__c, Instance_Suffix__c, Name, Overseas_Fee__c, Start_Date__c,
				Programme_Version__r.Name, Programme_Version__r.Programme_Group__c, Programme_Version__r.Programme_Type__c, Programme_Version__r.RecordType.DeveloperName, Programme_Version__r.Version_Suffix__c, 
				Programme_Version__r.Master_Link__r.Code__c, Programme_Version__r.Master_Link__r.Mode__c, Programme_Version__r.Master_Link__r.RecordType.DeveloperName
			FROM Programme__c
			WHERE Id = :progId
		];
	}
        
    static testMethod void testController() {
        QuickCreateProgrammeCont cont = new QuickCreateProgrammeCont();
        String testName = 'Test';
        Date startDate = Date.newInstance(2014, 6, 16);
        Date endDate = Date.newInstance(2014, 6, 27);
        String suffix = 'testSfx';
        Boolean isActive = true;
        String prType = ApplyServices.PT_SHORT_COURSE;
        String mode = ApplyServices.PV_MODE_FT;
        String code = 'TCD';
        
        // check full create cycle
        // mandatory fields
        cont.prog.Name = testName;
        cont.prog.Start_Date__c = startDate;
        cont.prog.End_Date__c = endDate;
        cont.prog.Instance_Suffix__c = suffix;
        cont.progVersion.Programme_Type__c = prType;
        // optional fields
        cont.prog.Active__c = isActive;
        cont.progVersion.Mode__c = mode;
        cont.progVersion.Code__c = code;
        PageReference pr = cont.create();
        System.assert(pr != null);
        System.assert(cont.programme.Id != null);
        System.assert(cont.module.Name.startsWith(testName));
        Programme__c p = findProgramme(cont.programme.Id);
        System.assert(p.Name.startsWith(testName));
        System.assertEquals(suffix, p.Instance_Suffix__c);
        System.assertEquals(startDate, p.Start_Date__c);
        System.assertEquals(endDate, p.End_Date__c);
        System.assertEquals(isActive, p.Active__c);
        System.assertEquals(prType, p.Programme_Version__r.Programme_Type__c);
        System.assertEquals(suffix, p.Programme_Version__r.Version_Suffix__c);        
        System.assertEquals(ApplyServices.RT_VERSION_PV_DEVNAME, p.Programme_Version__r.RecordType.DeveloperName);
        System.assertEquals(mode, p.Programme_Version__r.Master_Link__r.Mode__c);
        System.assertEquals(code, p.Programme_Version__r.Master_Link__r.Code__c);
        System.assertEquals(ApplyServices.RT_MASTER_PV_DEVNAME, p.Programme_Version__r.Master_Link__r.RecordType.DeveloperName);
        
        // check programme <-> module junction
        Programme_Module__c pm = [SELECT Module__c, Programme__c FROM Programme_Module__c WHERE Programme__c =: cont.programme.Id];
        System.assert(pm != null);
        
        // use Module Reference
        cont.progModule.Module__c = pm.Module__c;
        mode = ApplyServices.PV_MODE_FT;
        cont.progVersion.Mode__c = mode;
        pr = cont.create();
        System.assertEquals(pm.Module__c, cont.module.Id);
        p = findProgramme(cont.programme.Id);
        System.assertEquals(mode, p.Programme_Version__r.Master_Link__r.Mode__c);
    }
    
}