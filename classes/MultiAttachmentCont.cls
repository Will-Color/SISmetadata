/**
 * @author Valentyn Bilenkyy
 * @date 19/06/2014
 * @description Controller class for MultiAttachment.component
 */
public class MultiAttachmentCont {
    public String attachmentParentId {get;set;}
    public String name {get;set;}
    public String attachmentDescription {get;set;}
    public Id attachmentIdToRemove {get;set;}
    public String errorMessage {get; private set;}
    public Boolean readOnlyModeVal {get; set;}
    
    public Attachment attachment {
        get {
            if(attachment == null)
                attachment = new Attachment();
            return attachment;
        }
        set;
    }
    
    public List<Attachment> recordAttachments {
        get {
            List<Attachment> recordAttachments = new List<Attachment>();
            if(String.isBlank(attachmentDescription))
                recordAttachments = CommonUtils.findAttachments(attachmentParentId);
            else 
                recordAttachments = CommonUtils.findAttachments(attachmentParentId, attachmentDescription);
            return recordAttachments;
        }
        private set;
    }
    
    public Boolean hasAttachments {
        get {
            return (recordAttachments.size()>0);
        }
        set;
    }

    public PageReference removeAttachment() {
        errorMessage = null;
        if(attachmentIdToRemove!=null) {
            try {
                Attachment a = [SELECT Id FROM Attachment WHERE Id=:attachmentIdToRemove];
                delete a;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        }
        attachmentIdToRemove = null;
        return null;
    }
    
    public PageReference upload() {
        errorMessage = null;
        attachment.OwnerId = UserInfo.getUserId();
        attachment.ParentId = attachmentParentId;
        attachment.IsPrivate = false;
        attachment.Description = attachmentDescription;
        System.debug('attachment.Description = '+attachment.Description);
        try {
            
            insert attachment;
            //Suyati Modified Start 26-04-2016
            /*if(attachment.Description == 'passport'){
                 Student_Programme__c sp = [SELECT Id,New_Upload__c FROM Student_Programme__c WHERE Id =: attachmentParentId ];
                 sp.New_Upload__c = true;
                 System.debug('before update');
                 UPDATE sp;
            
            }
            */
            Id attachmentIdentifier = Id.valueOf(attachmentParentId);
            System.debug(''+attachmentIdentifier.getSobjectType());
            if(string.valueOf(attachmentIdentifier.getSobjectType()) == 'Qualifications_Experience__c'){
                Qualifications_Experience__c qE = [SELECT Id,New_Upload__c FROM Qualifications_Experience__c WHERE Id =:attachmentIdentifier];
                qE.New_Upload__c = true;
                UPDATE qE;
                //Suyati Modified End 
            }
            
        }
        catch (Exception e) {
            errorMessage = e.getMessage();
        }
        finally {
            attachment = new Attachment();
        }
        return null;
    }
}