/**
 * 2014-05-22 : Test class for CloneProgrammeController
 */
@isTest
private class TestCloneModuleVersionController {
    final static String MODULE_MASTER_NAME = 'Master_Version';
    final static String MODULE_VERSION_NAME = 'Versions';

    static testMethod void testController() {
        //Set up test data
        
        Map<String, RecordType> moduleRTMap = new Map<String, RecordType>();
        
        for (RecordType r : [select r.Id, r.DeveloperName from RecordType r where r.SObjectType = 'Module_Version__c' and r.IsActive = true]){
            moduleRTMap.put(r.DeveloperName, r);
        }
        
        Map<String, Module_Version__c> modMap = new Map<String, Module_Version__c>();
        for (integer i = 0 ; i < 4 ; i++){
            Module_Version__c m = new Module_Version__c();
            m.Name = 'Test Module Version Master ' + i;
            //m.Instance_Date__c = date.today();
            m.RecordTypeId = moduleRTMap.get(MODULE_MASTER_NAME).Id;
            modMap.put(m.Name, m);
        }
        
        insert modMap.values();
        
        Map<String, Module_Version__c> modMapVersions = new Map<String, Module_Version__c>();
        for (integer i = 0 ; i < 4 ; i++){
            Module_Version__c m = new Module_Version__c();
            m.Name = 'Test Module Version ' + i;
            //m.Instance_Date__c = date.today();
            m.RecordTypeId = moduleRTMap.get(MODULE_VERSION_NAME).Id;
            m.Master_Link__c = modMap.get('Test Module Version Master ' + i).Id;
            modMapVersions.put(m.Name, m);
        }

        insert modMapVersions.values();

        //Related List records
        List<Assessment_Specification__c> assessmentSpecs = new List<Assessment_Specification__c>();
        List<Module_Aim__c> moduleAims = new List<Module_Aim__c>();
        List<Module_Learning_Outcome__c> moduleLearningOutcomes = new List<Module_Learning_Outcome__c>();
        List<Module_Skill_Attribute__c> moduleSkillsAttributes = new List<Module_Skill_Attribute__c>();
        List<MV_Modification__c> moduleMVmodifications= new List<MV_Modification__c>();

        for (Module_Version__c mv : modMapVersions.values()){
            Assessment_Specification__c aSpec = new Assessment_Specification__c();
            aSpec.Module_Version__c = mv.Id;
            assessmentSpecs.add(aSpec);

            Module_Aim__c ma = new Module_Aim__c();
            ma.Module_Version__c = mv.Id;
            moduleAims.add(ma);

            Module_Learning_Outcome__c mlc = new Module_Learning_Outcome__c();
            mlc.Module_Version__c = mv.Id;
            moduleLearningOutcomes.add(mlc);

            Module_Skill_Attribute__c msa = new Module_Skill_Attribute__c();
            msa.Module_Version__c = mv.Id;
            moduleSkillsAttributes.add(msa);
            
            MV_Modification__c mvm = new MV_Modification__c();
            mvm.Module_Version__c = mv.Id;
            moduleMVmodifications.add(mvm);
        }

        insert assessmentSpecs;
        insert moduleAims;
        insert moduleLearningOutcomes;
        insert moduleSkillsAttributes;
        insert moduleMVmodifications;
        
        PageReference pageRef = Page.CloneModuleVersion;
        pageRef.getParameters().put('moduleId',modMapVersions.get('Test Module Version 0').Id);
        test.setCurrentPage(pageRef);
        
        ApexPages.StandardController std = new ApexPages.StandardController(modMapVersions.get('Test Module Version 0'));
        
        test.startTest();
        
        CloneModuleVersionController cpc = new CloneModuleVersionController(std);
        
        PageReference returnRef = cpc.cloneModule();
               
        test.stopTest();
    }
    
}