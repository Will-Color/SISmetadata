trigger PAPMemberTrigger on PAP_Member__c (after insert, after update, after delete) {
    
    /*PAP Member Trigger for updating user id of PAP member contacts into Research periods*/

    List<Id> researchPeriods = new List<Id>();
    Set<Id> papMemberIds = new Set<Id>();    
    if(trigger.isInsert){
        for(PAP_Member__c papMembers : trigger.new){
            if(papMembers.Research_Period__c != null || papMembers.Panel_Member__c != null){
                researchPeriods.add(papMembers.Research_Period__c);
                papMemberIds.add(papMembers.Panel_Member__c);
            }
        }
    }
      if(Trigger.isUpdate){
        for(PAP_Member__c papMembersNew: trigger.new)
        {
            if(papMembersNew.Research_Period__c != null || papMembersNew.Panel_Member__c != null){
                researchPeriods.add(papMembersNew.Research_Period__c);   
                papMemberIds.add(papMembersNew.Panel_Member__c);
            }
        }  
        for(PAP_Member__c papMembersOld: trigger.old)
        {
            researchPeriods.add(papMembersOld.Research_Period__c);
            papMemberIds.add(papMembersOld.Panel_Member__c);
        }
    }    
    if(Trigger.isDelete){
        for(PAP_Member__c papMembersNew: trigger.old)
        {
            papMemberIds.add(papMembersNew.Panel_Member__c);
            researchPeriods.add(papMembersNew.Research_Period__c);            
        }  
    } 
    Set<Id> rpPanelMembers = new Set<Id>();
    for(PAP_Member__c pap : [Select Id, Panel_Member__c from PAP_Member__c where Research_Period__c IN: researchPeriods]){
        rpPanelMembers.add(pap.Panel_Member__c);
    }
    Map<Id,Id> cotactUserMap = new Map<Id,Id>();
    for(User u : [Select Id, ContactId from User where ContactId IN:rpPanelMembers]){
        cotactUserMap.put(u.ContactId, u.Id);
    }
    List<Research_Period__c> rpListToUpdate = new List<Research_Period__c>();
    set<Id> listOfPapMemberIds = new set<Id>();
    String str;
    for(Research_Period__c r : [Select Id, PAP_Members__c, (select Name, id, Panel_Member__c from PAP_Members__r) from Research_Period__c where Id IN: researchPeriods]){
        str = '';
        for(PAP_Member__c papMem : r.PAP_Members__r){
            listOfPapMemberIds.add(papMem.Panel_Member__c);
        }
        for(Id panelMemId : listOfPapMemberIds){
            str += String.valueOf(cotactUserMap.get(panelMemId)) + ',';
        }
        r.PAP_Members__c = str;
        rpListToUpdate.add(r);
        listOfPapMemberIds.clear();
        
    }
    
    update rpListToUpdate;

}