trigger AttachmentTrigger on Attachment (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    if (trigger.isAfter){
        if (trigger.isInsert){
            AttachmentTriggerMethods.updateAttachmentCheckbox(false, trigger.new);
        }else if (trigger.isDelete){
            AttachmentTriggerMethods.updateAttachmentCheckbox(true, trigger.old);
        }
    }

}