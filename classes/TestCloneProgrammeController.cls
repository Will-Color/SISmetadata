/**
 * 2014-05-22 : Test class for CloneProgrammeController
 */
@isTest
private class TestCloneProgrammeController {

    static testMethod void testController() {
        //Set up test data
        Programme__c newProg = new Programme__c();
        newProg.Name = 'Test Programme';
        newProg.Test_Class_Record__c = true;
        insert newProg;
        
        Map<String, Module__c> modMap = new Map<String, Module__c>();
        for (integer i = 0 ; i < 4 ; i++){
            Module__c m = new Module__c();
            m.Name = 'Test Module ' + i; 
            m.Test_Class_Record__c = true;         
            modMap.put(m.Name, m);
        }
        
        insert modMap.values();
        
        List<Programme_Module__c> newModList = new List<Programme_Module__c>();
        for (integer i = 0 ; i < 4 ; i++){
            Programme_Module__c pm = new Programme_Module__c();
            pm.Test_Class_Record__c = true;
            pm.Programme__c = newProg.Id;
            pm.Module__c = modMap.get('Test Module ' + i).Id;
            newModList.add(pm);
        }
        
        insert newModList;
        
        PageReference pageRef = Page.CloneProgramme;
        pageRef.getParameters().put('progId',newProg.Id);
        test.setCurrentPage(pageRef);
        
        ApexPages.StandardController std = new ApexPages.StandardController(newProg);
        
        test.startTest();
        
        CloneProgrammeController cpc = new CloneProgrammeController(std);
        cpc.moduleWrapperList[0].isSelected = true;
        
        PageReference returnRef = cpc.cloneProgramme();
               
        test.stopTest();
    }
    
    static testMethod void testControllerWithFilter() {
        //Set up test data
        Programme__c newProg = new Programme__c();
        newProg.Name = 'Test Programme';
        newProg.Test_Class_Record__c = true;
        
        insert newProg;
        
        Map<String, Module__c> modMap = new Map<String, Module__c>();
        for (integer i = 0 ; i < 4 ; i++){
            Module__c m = new Module__c();
            m.Name = 'Test Module ' + i; 
            m.Test_Class_Record__c = true;         
            modMap.put(m.Name, m);
        }
        
        insert modMap.values();
        
        List<Programme_Module__c> newModList = new List<Programme_Module__c>();
        for (integer i = 0 ; i < 4 ; i++){
            Programme_Module__c pm = new Programme_Module__c();
            pm.Programme__c = newProg.Id;
            pm.Test_Class_Record__c = true;
            pm.Module__c = modMap.get('Test Module ' + i).Id;
            newModList.add(pm);
        }
        
        insert newModList;
        
        PageReference pageRef = Page.CloneProgramme;
        pageRef.getParameters().put('progId',newProg.Id);
        test.setCurrentPage(pageRef);
        
        ApexPages.StandardController std = new ApexPages.StandardController(newProg);
        
        test.startTest();
        
        CloneProgrammeController cpc = new CloneProgrammeController(std);
        
        cpc.filterName = 'Test';
        
        PageReference returnRef = cpc.filterModules();
               
        test.stopTest();
    }
}