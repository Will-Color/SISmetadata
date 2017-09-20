/*
* 2014-08-04 : CSL : This is the Student_Programme__c trigger that runs on ALL events
*
*/
trigger StudentProgrammeTrigger on Student_Programme__c (after update) {
	StudentProgrammeTriggerMethods.onTrigger(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, Trigger.isBefore, 
		Trigger.isAfter,Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
}