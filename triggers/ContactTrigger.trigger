trigger ContactTrigger on Contact (after update) {
	ContactServices.onTrigger(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, Trigger.isBefore, 
		Trigger.isAfter,Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
}