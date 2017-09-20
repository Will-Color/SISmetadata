public with sharing class ModuleRoleServices {

    // ModuleRole constants
    public static final String MODULE_CONVENOR_ROLE_NAME =	'Module Convenor';
    public static final String MODULE_MODERATOR_ROLE_NAME =	'Module Moderator';
    public static final String TEACHING_ROLE_NAME =			'Teaching';
    public static final String EXT_EXAMINER_ROLE_NAME =		'External Examiner';
    
    /**
     * Get list of Module_Role__c with VLE_Visibility__c equals to true
     * @param newList List of Module_Role__c
     * return List of valid records
     */
    private static List<Module_Role__c> findRolesWithVisibleContacts(List<Module_Role__c> newList) {
        return [SELECT Id FROM Module_Role__c WHERE Staff__r.VLE_Visibility__c = true AND Id IN :newList];
    }
    
    /**
     * Add sync action for certain type of Mode_Role__c modification (insert, update or delete)
     * @param mrList List of module roles
     * @param actionType Mode of action
     */
    private static void syncToVLE(List<Module_Role__c> mrList, String actionType) {
    	if ( !mrList.isEmpty() ) {
	    	// add actions
    		for (Module_Role__c mr: VleDaoServices.findModuleRolesData(mrList)) {
    			if ( !String.isBlank(mr.Module__r.VLE_ID__c) ) {
	    			VleStaffRoleAction staffRoleAction = new VleStaffRoleAction();
	    			staffRoleAction.actionType = actionType;
	    			staffRoleAction.moduleRole = mr;
	    			VleSyncServices.addToQueue(staffRoleAction, VleSyncServices.VLE_STAFF_ROLE_ACTION, mr.Id);
    			}
    		}
    		VleSyncServices.persistQueue(); // sync
    	}
    }

    /**
     * Single point to the all Module_Role__c triggers
     */
    public static void onTrigger(List<Module_Role__c> newList, List<Module_Role__c> oldList, Map<Id,Module_Role__c> newMap, Map<Id,Module_Role__c> oldMap,
    		Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
        if (isBefore) {
            if (isDelete) {
                findDeletedRolesWithVisibleContacts(oldList);
            }
        }
        if (isAfter) {
            if (isInsert) {
                findInsertedRolesWithVisibleContacts(newList);
            }
            if (isUpdate) {
                findUpdatedRolesWithVisibleContacts(newList, oldMap);
            }
        }
    }

    public static List<Module_Role__c> findDeletedRolesWithVisibleContacts(List<Module_Role__c> oldList) {
        List<Module_Role__c> mrList = findRolesWithVisibleContacts(oldList);
        syncToVLE(mrList, VleStaffRoleAction.DELETE_ACTION_TYPE);
        return mrList;
    }

    public static List<Module_Role__c> findInsertedRolesWithVisibleContacts(List<Module_Role__c> newList) {
    	List<Module_Role__c> mrList = findRolesWithVisibleContacts(newList);
    	syncToVLE(mrList, VleStaffRoleAction.INSERT_ACTION_TYPE);
        return mrList;
    }

    public static List<Module_Role__c> findUpdatedRolesWithVisibleContacts(List<Module_Role__c> newList, Map<Id,Module_Role__c> oldMap) {
        List<Module_Role__c> mrs = new List<Module_Role__c>();
        for (Module_Role__c mr : newList) {
            if (mr.Module_Role__c != oldMap.get(mr.Id).Module_Role__c) {
                mrs.add(mr);
            }
        }
        
        List<Module_Role__c> mrList = findRolesWithVisibleContacts(mrs);
        syncToVLE(mrList, VleStaffRoleAction.UPDATE_ACTION_TYPE);
        return mrList;
    }
    
}