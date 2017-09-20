/**
 * Service class for working with Contact (Student) records
 */
public with sharing class ContactServices {
    /**
     * Single point to the all Contact triggers
     */
    public static void onTrigger(List<Contact> newList, List<Contact> oldList, Map<Id,Contact> newMap, Map<Id,Contact> oldMap,
			Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
    	if (isAfter) {
    		if (isUpdate) {
    			findVLEVisibleModuleRoles(newList, oldMap);
    			findVLENotVisibleContacts(newList, oldMap);
    		}
    	}
	}

    public static List<Module_Role__c> findVLEVisibleModuleRoles(List<Contact> newList, Map<Id,Contact> oldMap) {
        List<Contact> cList = new List<Contact>();
        Id staffRecTypeId = CommonUtils.findRecordTypeIdByDev('Contact', 'Staff');
        for (Contact c : newList) {
            if (staffRecTypeId == c.RecordTypeId && c.VLE_Visibility__c == true && oldMap.get(c.Id).VLE_Visibility__c == false) {
                cList.add(c);
            }
        }
       
        if ( cList.size() > 0 ) {
            // create staff actions
            List<Contact> staffList = VleDaoServices.findStaffWithModuleRoles(cList);
            for (Contact staff: staffList) {
                VleCreateStaffAction createStaffAction = new VleCreateStaffAction();
                createStaffAction.staff = staff;
                VleSyncServices.addToQueue(createStaffAction, VleSyncServices.CREATE_VLE_STAFF_ACTION, staff.Id);
            }
            VleSyncServices.persistQueue(); // sync
            return [SELECT Id FROM Module_Role__c WHERE Staff__c IN :cList];
        }
        return new List<Module_Role__c>();
    }

    public static List<Contact> findVLENotVisibleContacts(List<Contact> newList, Map<Id,Contact> oldMap) {
        List<Contact> cList = new List<Contact>();
        for (Contact c : newList) {
            if (c.VLE_Visibility__c == false && oldMap.get(c.Id).VLE_Visibility__c == true) {
                cList.add(c);
            }
        }
        if (cList.size() > 0) {
            // create actions to make user inactive
            for (Contact c: cList) {
                VleMakeUserInactiveAction inactiveAction = new VleMakeUserInactiveAction();
                inactiveAction.person = c;
                VleSyncServices.addToQueue(inactiveAction, VleSyncServices.MAKE_VLE_USER_INACTIVE_ACTION, c.Id);
            }
            VleSyncServices.persistQueue(); // sync
        }
        return cList;
    }
    
}