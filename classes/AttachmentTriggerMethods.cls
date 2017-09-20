/*
*
* 2014-08-13 : CSL : This class holds methods called from the Attachment trigger
*
*/

public class AttachmentTriggerMethods {

    //This method updates the Has_Attachment__c check box on the insert / delete of an attachment against References
    public static void updateAttachmentCheckbox(boolean isDelete, List<Attachment> inRecords){
        if (!isDelete){
            //It is not a DELETE call
            Map<Id, References__c> referencesToSave = new Map<Id, References__c>();
            List<Attachment> attachmentsToProcess = new List<Attachment>();
            Schema.DescribeSObjectResult dr = References__c.sObjectType.getDescribe();
            String keyPrefix = dr.getKeyPrefix();
            Set<Id> parentIds = new Set<Id>();
            for (Attachment a : inRecords){
                String pId = a.ParentId;
                if (pId.substring(0,3) == keyPrefix){
                    parentIds.add(a.ParentId);
                    attachmentsToProcess.add(a);
                }
            }
            
            Map<Id, References__c> referenceMap = new Map<Id, References__c>([select r.Has_Attachment__c from References__c r where r.Id in :parentIds]);
            
            for (Attachment a : attachmentsToProcess){
                References__c r = referenceMap.get(a.ParentId);
                if (r != null){
                    if (!r.Has_Attachment__c){
                        r.Has_Attachment__c = true;
                        if (!referencesToSave.containsKey(r.Id)){
                            referencesToSave.put(r.Id, r);
                        }
                    }
                }
            }
            
            if (referencesToSave.size() > 0){
                update referencesToSave.values();
            }
        }else {
            //It is a DELETE call
            Map<Id, References__c> referencesToSave = new Map<Id, References__c>();
            Map<Id, Attachment> attachmentsToProcess = new Map<Id, Attachment>();
            Schema.DescribeSObjectResult dr = References__c.sObjectType.getDescribe();
            String keyPrefix = dr.getKeyPrefix();
            Set<Id> parentIds = new Set<Id>();
            Map<String, integer> referenceCounter = new Map<String, integer>();
            for (Attachment a : inRecords){
                String pId = a.ParentId;
                if (pId.substring(0,3) == keyPrefix){
                    parentIds.add(a.ParentId);
                    attachmentsToProcess.put(a.Id, a);
                }
            }
            
            Map<Id, References__c> referenceMap = new Map<Id, References__c>([select r.Has_Attachment__c from References__c r where r.Id in :parentIds]);
            
            for (References__c r : referenceMap.values()){
                referenceCounter.put(r.Id, 0);
            }
            
            for (Attachment a : [select a.Id, a.ParentId from Attachment a where a.ParentId in :referenceMap.keySet()]){
                if (!attachmentsToProcess.containsKey(a.Id)){
                    integer rCount = referenceCounter.get(a.ParentId);
                    referenceCounter.put(a.ParentId, rCount++);
                }
            }
            
            for (Attachment a : attachmentsToProcess.values()){
                References__c r = referenceMap.get(a.ParentId);
                if (r != null){
                    integer rCount = referenceCounter.get(r.Id);
                    if (rCount > 0){
                        rCount = rCount-1;
                        referenceCounter.put(r.Id, rCount);
                        if (rCount <= 0){
                            r.Has_Attachment__c = false;
                            if (!referencesToSave.containsKey(r.Id)){
                                referencesToSave.put(r.Id, r);
                            }   
                        }
                    }else {
                        r.Has_Attachment__c = false;
                        if (!referencesToSave.containsKey(r.Id)){
                            referencesToSave.put(r.Id, r);
                        }
                    }
                }
            }
            
            if (referencesToSave.size() > 0){
                update referencesToSave.values();
            }
        }
    }

}