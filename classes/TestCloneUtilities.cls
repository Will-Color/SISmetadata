/**
 * 2014-05-13 : CSL : Test class for CloneUtilities
 * This class contains unit tests for the CloneUtilities class
 *
 */
@isTest
private class TestCloneUtilities {

    static testMethod void testCloneProgramme() {
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
            pm.Module__c = modMap.get('Test Module ' + i).Id;
            pm.Test_Class_Record__c = true;
            newModList.add(pm);
        }
        
        insert newModList;
        
        test.startTest();
        
        String cloneProgId = CloneUtilities.cloneProgramme(newProg.Id);
                
        system.assertNotEquals(null, cloneProgId);
        
        Programme__c cloneProg = [select p.Name from Programme__c p where p.Id = :cloneProgId];
        
        //system.assertEquals(newProg.Name + '_CLONE', cloneProg.Name);
        
        test.stopTest();
        
    }
    
    static testMethod void testCloneProgramme2() {
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
            pm.Module__c = modMap.get('Test Module ' + i).Id;
            pm.Test_Class_Record__c = true;
            newModList.add(pm);
        }
        
        insert newModList;
        
        test.startTest();
        
        Test.setCurrentPageReference(new PageReference('Page.ProgrammeClone')); 
        System.currentPageReference().getParameters().put('id', newProg.Id);        
        ApexPages.StandardController ctlr = new ApexPages.StandardController(newProg);
        CloneUtilities obj = new CloneUtilities(ctlr);
        obj.cloneProgrammeVF(newProg.Id);
        
        test.stopTest();
        
    }    
}