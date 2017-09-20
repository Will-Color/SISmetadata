trigger ModuleRoleTrigger on Module_Role__c (before delete, after insert, after update) {
	ModuleRoleServices.onTrigger(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, Trigger.isBefore, 
		Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
}