/**
 * 2014-05-22 : Test class for CloneProgrammeController
 */
@isTest
private class TestCloneProgrammeVersionController {
    final static String PROG_MASTER_NAME = 'Master_Version';
    final static String PROG_VERSION_NAME = 'Versions';
    final static String MODULE_MASTER_NAME = 'Master_Version';
    final static String MODULE_VERSION_NAME = 'Versions';

    static testMethod void testController() {
        //Set up test data
        Map<String, RecordType> progRTMap = new Map<String, RecordType>();
        Map<String, RecordType> moduleRTMap = new Map<String, RecordType>();
        for (RecordType r : [select r.Id, r.DeveloperName from RecordType r where r.SObjectType = 'Programme_Version__c' and r.IsActive = true]){
            progRTMap.put(r.DeveloperName, r);
        }
        for (RecordType r : [select r.Id, r.DeveloperName from RecordType r where r.SObjectType = 'Module_Version__c' and r.IsActive = true]){
            moduleRTMap.put(r.DeveloperName, r);
        }
        
        Programme_Version__c newProgMaster = new Programme_Version__c();
        newProgMaster.Name = 'Test PVM';
        newProgMaster.RecordTypeId = progRTMap.get(PROG_MASTER_NAME).Id;
        insert newProgMaster;
        
        Map<String, Module_Version__c> modMap = new Map<String, Module_Version__c>();
        for (integer i = 0 ; i < 4 ; i++){
        	Module_Version__c m = new Module_Version__c();
        	m.Name = 'Test MVM ' + i;
        	//m.Instance_Date__c = date.today();
            m.RecordTypeId = moduleRTMap.get(MODULE_MASTER_NAME).Id;
        	modMap.put(m.Name, m);
        }
        
        insert modMap.values();
        
        Programme_Version__c newProgVersion = new Programme_Version__c();
        newProgVersion.Name = 'Test PV ';
        newProgVersion.RecordTypeId = progRTMap.get(PROG_VERSION_NAME).Id;
        newProgVersion.Master_Link__c = newProgMaster.Id;
        insert newProgVersion;

        //Insert relates list records
        List<Programme_Aim__c> programmeAims = new List<Programme_Aim__c>();
        List<Skills_Attributes__c> skillsAttributes = new List<Skills_Attributes__c>();
        List<Learning_Outcome__c> learningOutcomes = new List<Learning_Outcome__c>();

        Programme_Aim__c pa = new Programme_Aim__c();
        pa.Programme_Version__c = newProgVersion.Id;
        insert pa;

        Skills_Attributes__c sa = new Skills_Attributes__c();
        sa.Programme_Version__c = newProgVersion.Id;
        insert sa;

        Learning_Outcome__c lc = new Learning_Outcome__c();
        lc.Programme_Version__c = newProgVersion.Id;
        lc.Outcome_Type__c = 'A (Knowledge & Understanding)';
        insert lc;

        Map<String, Module_Version__c> modMapVersions = new Map<String, Module_Version__c>();
        for (integer i = 0 ; i < 4 ; i++){
            Module_Version__c m = new Module_Version__c();
            m.Name = 'Test MV ' + i;
            //m.Instance_Date__c = date.today();
            m.RecordTypeId = moduleRTMap.get(MODULE_VERSION_NAME).Id;
            m.Master_Link__c = modMap.get('Test MVM ' + i).Id;
            modMapVersions.put(m.Name, m);
        }

        insert modMapVersions.values();

        List<Programme_Module_Version__c> newModVersionList = new List<Programme_Module_Version__c>();
        for (integer i = 0 ; i < 4 ; i++){
            Programme_Module_Version__c pmv = new Programme_Module_Version__c();
            pmv.Programme_Version__c = newProgVersion.Id;
            pmv.Module_Version__c = modMapVersions.get('Test MV ' + i).Id;
            newModVersionList.add(pmv);
        }
        
        insert newModVersionList;

        
        PageReference pageRef = Page.CloneProgrammeVersion;
        pageRef.getParameters().put('progId',newProgVersion.Id);
        test.setCurrentPage(pageRef);
        
        ApexPages.StandardController std = new ApexPages.StandardController(newProgVersion); 
        
        test.startTest();
        
        CloneProgrammeVersionController cpc = new CloneProgrammeVersionController(std);

        cpc.moduleWrapperList[0].isSelected = true;
        
        PageReference returnRef = cpc.cloneProgramme();
               
        test.stopTest();
    }
    
    static testMethod void testControllerWithFilter() {
         //Set up test data
        Map<String, RecordType> progRTMap = new Map<String, RecordType>();
        Map<String, RecordType> moduleRTMap = new Map<String, RecordType>();
        for (RecordType r : [select r.Id, r.DeveloperName from RecordType r where r.SObjectType = 'Programme_Version__c' and r.IsActive = true]){
            progRTMap.put(r.DeveloperName, r);
        }
        for (RecordType r : [select r.Id, r.DeveloperName from RecordType r where r.SObjectType = 'Module_Version__c' and r.IsActive = true]){
            moduleRTMap.put(r.DeveloperName, r);
        }
        
        Programme_Version__c newProgMaster = new Programme_Version__c();
        newProgMaster.Name = 'Test PVM';
        newProgMaster.RecordTypeId = progRTMap.get(PROG_MASTER_NAME).Id;
        insert newProgMaster;
        
        Map<String, Module_Version__c> modMap = new Map<String, Module_Version__c>();
        for (integer i = 0 ; i < 4 ; i++){
            Module_Version__c m = new Module_Version__c();
            m.Name = 'Test MVM ' + i;
            //m.Instance_Date__c = date.today();
            m.RecordTypeId = moduleRTMap.get(MODULE_MASTER_NAME).Id;
            modMap.put(m.Name, m);
        }
        
        insert modMap.values();
        
        Programme_Version__c newProgVersion = new Programme_Version__c();
        newProgVersion.Name = 'Test Programme Version ';
        newProgVersion.RecordTypeId = progRTMap.get(PROG_VERSION_NAME).Id;
        newProgVersion.Master_Link__c = newProgMaster.Id;
        insert newProgVersion;

        Map<String, Module_Version__c> modMapVersions = new Map<String, Module_Version__c>();
        for (integer i = 0 ; i < 4 ; i++){
            Module_Version__c m = new Module_Version__c();
            m.Name = 'Test MV ' + i;
            //m.Instance_Date__c = date.today();
            m.RecordTypeId = moduleRTMap.get(MODULE_VERSION_NAME).Id;
            m.Master_Link__c = modMap.get('Test MVM ' + i).Id;
            modMapVersions.put(m.Name, m);
        }

        insert modMapVersions.values();

        List<Programme_Module_Version__c> newModVersionList = new List<Programme_Module_Version__c>();
        for (integer i = 0 ; i < 4 ; i++){
            Programme_Module_Version__c pmv = new Programme_Module_Version__c();
            pmv.Programme_Version__c = newProgVersion.Id;
            pmv.Module_Version__c = modMapVersions.get('Test MV ' + i).Id;
            newModVersionList.add(pmv);
        }
        
        insert newModVersionList;
        
        PageReference pageRef = Page.CloneProgrammeVersion;
        pageRef.getParameters().put('progId',newProgVersion.Id);
        test.setCurrentPage(pageRef);
        
        ApexPages.StandardController std = new ApexPages.StandardController(newProgVersion);
        
        test.startTest();
        
        CloneProgrammeVersionController cpc = new CloneProgrammeVersionController(std);
        
        cpc.filterName = 'Test';
        
        PageReference returnRef = cpc.filterModules();
               
        test.stopTest();
        
    }
    
    
}