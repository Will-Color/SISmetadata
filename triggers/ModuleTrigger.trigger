trigger ModuleTrigger on Module__c (after update) {
	ModuleServices.onTrigger(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, Trigger.isBefore, 
		Trigger.isAfter,Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
}