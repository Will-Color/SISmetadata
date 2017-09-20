public with sharing class ModuleServices {
    
    /**
     * Single point to the all Module__c triggers
     */
    public static void onTrigger(List<Module__c> newList, List<Module__c> oldList, Map<Id,Module__c> newMap, Map<Id,Module__c> oldMap,
            Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
        if (isAfter) {
            if (isUpdate) {
                //findActiveModules(newList, oldMap);
                //findModulesSetAsInactive(newList, oldMap);
            }
        }        
    }

     @InvocableMethod
     public static List<Module__c> findActiveModules(List<Module__c> mList) {        
        if (! mList.isEmpty()){
            for (Module__c m : mList){
                VleCreateModuleAction newModuleAction = new VleCreateModuleAction();
                newModuleAction.module = m;
                VleSyncServices.addToQueue(newModuleAction, VleSyncServices.CREATE_VLE_COURSE_ACTION, m.Id);
            }
            VleSyncServices.persistQueue(); //sync
        }
        return mList;
    }    

    //process InActive modules
    public static List<Module__c> findModulesSetAsInactive(List<Module__c> newList, Map<Id, Module__c> oldMap) {
    List<Module__c> mList = new List<Module__c>();       
        for (Module__c m : newList){
            if (m.VLE_ID__c != null && m.Module_Code__c != null
            && ! m.Active__c && oldMap.get(m.Id).Active__c){
                mList.add(m);
            }
        }
        if (! mList.isEmpty()){
            for (Module__c m : mList){
                VleUpdateModuleAction updModuleAction = new VleUpdateModuleAction();
                updModuleAction.module = m;
                VleSyncServices.addToQueue(updModuleAction, VleSyncServices.UPDATE_VLE_COURSE_ACTION, m.Id);
            }
            VleSyncServices.persistQueue(); //sync
        }
        return mList;
    } 


}