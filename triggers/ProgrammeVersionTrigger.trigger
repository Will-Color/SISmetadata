trigger ProgrammeVersionTrigger on Programme_Version__c (after insert, after update) {
    
    if (Trigger.isAfter){
        if (Trigger.isInsert || Trigger.isUpdate){
            ProgrammeVersionServices.createProgrameVersionContentAsXmlAttachment(Trigger.newMap.keySet());
            //ProgrammeVersionServices.processDefaultModulesCreationForActivePv(Trigger.new, Trigger.oldMap);
        }       
    }
}