public without sharing class AttachmentServices {
    
    public static final String XML_CONTEXT_ATTACHMENT_PREFIX = 'Xml_Context_';


    //---------------- Helper Dao Methods -------------------//

    public static List<Attachment> getAttachmentsWithBodyByIds(Set<Id> attachIds){
        return [SELECT Id, Body, ParentId 
                FROM Attachment 
                WHERE Id IN : attachIds];
    }
}