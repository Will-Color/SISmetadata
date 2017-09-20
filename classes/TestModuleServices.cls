@isTest
private class TestModuleServices
{
    static testMethod void testModuleServices() 
    {
        Map<Id,Module__c> oldMap = new Map<Id,Module__c>();
        List<Module__c> moduleList = new List<Module__c>();   
        Module__c module = new Module__c();
        module.Name = 'Test Module'; 
        module.Test_Class_Record__c = true;
        module.VLE_ID__c = '1234'; 
        module.Module_Code__c = 'Test Code';
        moduleList.add(module);
        insert moduleList;
        oldMap.put(module.Id,module);
        ModuleServices.findActiveModules(moduleList);      
        ModuleServices.findModulesSetAsInactive(moduleList,oldMap);  
    }
}