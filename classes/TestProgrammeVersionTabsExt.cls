/**
 * 2014-03-02 : Test class for ProgrammeVersionTabsExt
 */
@isTest
private class TestProgrammeVersionTabsExt {
    final static String PROG_MASTER_NAME = 'Master_Version';
    final static String PROG_VERSION_NAME = 'Versions';
    
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
        
        ApexPages.StandardController std = new ApexPages.StandardController(newProgVersion);
        
        test.startTest();
        
        PageReference pageRef = Page.ProgrammeVersionTabs;
        
        ProgrammeVersionTabsExt pvte = new ProgrammeVersionTabsExt(std);
        
        test.stopTest();
        
    }
    
}