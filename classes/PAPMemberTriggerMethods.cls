public class PAPMemberTriggerMethods
{
    public static void addToTextArea(List<PAP_Member__c> PAPMemberList)
    {
        Map<Id,Set<Id>> RPpanelmemberMap = new Map<Id,Set<Id>>();
        Map<Id,Id> contactUserMap = new Map<Id,Id>();   
        Set<Id> contactIDs= new Set<Id>();
        
        if ( !papmemberList.isEmpty() ) 
        {
            for(PAP_Member__c papmembers : papmemberList) 
            {
                if(RPpanelmemberMap.containsKey(papmembers.Research_Period__c))
                {
                    RPpanelmemberMap.get(papmembers.Research_Period__c).add(papmembers.Panel_Member__c);
                    contactIDs.add(papmembers.Panel_Member__c);
                }
                else
                {
                    RPpanelmemberMap.put(papmembers.Research_Period__c , new Set<Id> {papmembers.Panel_Member__c});
                    contactIDs.add(papmembers.Panel_Member__c);
                }
            }
        }
        
        System.debug('contactIDs'+contactIDs);
        for(User u : [SELECT Id,ContactId FROM User WHERE ContactId IN: contactIDs])
        { System.debug('u'+u);
            contactUserMap.put(u.ContactId,u.Id);
        }           
        
        System.debug('contactUserMap'+contactUserMap);
        Set<Research_Period__c> rpListToUpdate = new Set <Research_Period__c>();
        for(Research_Period__c rp : [SELECT Id,PAP_Members__c FROM Research_Period__c WHERE ID IN: RPpanelmemberMap.keyset()])
        {
            for(Id panelmemberId : RPpanelmemberMap.get(rp.Id))
            {   if(rp.PAP_Members__c == null){
                rp.PAP_Members__c = String.valueOf(contactUserMap.get(panelmemberId));
                rpListToUpdate.add(rp);
            }else{
                rp.PAP_Members__c = rp.PAP_Members__c + ',' + String.valueOf(contactUserMap.get(panelmemberId));
                rpListToUpdate.add(rp); 
            }
            }
        }
        List<Research_Period__c> newRpList = new    List<Research_Period__c>();
        newRpList.addAll(rpListToUpdate);
        update newRpList;
    }
    
    public static void removeFromTextArea(List<PAP_Member__c> PAPMemberList)
    {
     System.debug('papmemberList'+PAPMemberList);
        Map<Id,List<Id>> RPpanelmemberMap = new Map<Id,List<Id>>();
        Map<Id,Id> contactUserMap = new Map<Id,Id>();   
        Set<Id> contactIDs= new Set<Id>();
        
        if ( !PAPMemberList.isEmpty() ) 
        {
            for(PAP_Member__c papmembers : papmemberList) 
            {
                if(RPpanelmemberMap.containsKey(papmembers.Research_Period__c))
                {
                    RPpanelmemberMap.get(papmembers.Research_Period__c).add(papmembers.Panel_Member__c);
                    contactIDs.add(papmembers.Panel_Member__c);
                }
                else
                {
                    RPpanelmemberMap.put(papmembers.Research_Period__c , new List<Id> {papmembers.Panel_Member__c});
                    contactIDs.add(papmembers.Panel_Member__c);
                }
            }
        }
   
        for(User u : [SELECT Id,ContactId FROM User WHERE ContactId IN: contactIDs])
        {
            contactUserMap.put(u.ContactId,u.Id);
        }           
        
        List<Research_Period__c> rpListToUpdate = new List <Research_Period__c>();
        for(Research_Period__c rp : [SELECT Id,PAP_Members__c FROM Research_Period__c WHERE ID IN: RPpanelmemberMap.keyset()])
        {
            for(Id panelmemberId : RPpanelmemberMap.get(rp.Id))
            {
                if(contactUserMap.get(panelmemberId)!=null){
                    
                    If(rp.PAP_Members__c.contains(',' + String.valueOf(contactUserMap.get(panelmemberId))))
                    {
                        rp.PAP_Members__c = rp.PAP_Members__c.remove(',' + String.valueOf(contactUserMap.get(panelmemberId)));             
                        rpListToUpdate.add(rp); 
                    }
                    else if(rp.PAP_Members__c.contains(String.valueOf(contactUserMap.get(panelmemberId)+ ',')))
                    {
                        rp.PAP_Members__c = rp.PAP_Members__c.remove(String.valueOf(contactUserMap.get(panelmemberId)+ ','));              
                        rpListToUpdate.add(rp); 
                    }
                    else
                    {
                        rp.PAP_Members__c = rp.PAP_Members__c.remove(String.valueOf(contactUserMap.get(panelmemberId)));               
                        rpListToUpdate.add(rp);
                    }
                }
            }
        }
        update rpListToUpdate;        
    }   
}