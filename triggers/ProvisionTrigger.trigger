trigger ProvisionTrigger on Provision__c (after insert,after update, before delete,after undelete) {
    
    ProvisionTriggerMethods obj = new ProvisionTriggerMethods();
    if(Trigger.isInsert){
        obj.insertPassword(trigger.new);
        obj.setADAccountValue(trigger.new,trigger.old);
    }
    if(Trigger.isUpdate){
        obj.setADAccountValue(trigger.new,trigger.old);
        obj.UpdateActive(trigger.new);
    }
    if (Trigger.isDelete){        
        obj.setADAccountValue(null,trigger.old);
        obj.removePassword(trigger.old);
    }
    if(Trigger.isUndelete){
        obj.populateLastPass(trigger.new);
    }
    
    
}