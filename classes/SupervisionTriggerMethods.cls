public class SupervisionTriggerMethods
{
    public static void addToTextArea(List<Supervision__c> supervisionList, List<id> studentproIds)
    {
        Map<Id,Set<Id>> SPsupervisorMap = new Map<Id,Set<Id>>();
        Map<Id,Id> contactUserMap = new Map<Id,Id>();   
        Set<Id> contactIDs= new Set<Id>();
        
        
        
        
        
        if ( !supervisionList.isEmpty() ) 
        {
            for(Supervision__c supervisions : supervisionList) 
            {
                if(SPsupervisorMap.containsKey(supervisions.Student_Programme__c))
                {
                    SPsupervisorMap.get(supervisions.Student_Programme__c).add(supervisions.Supervisor__c);
                    contactIDs.add(supervisions.Supervisor__c);
                }
                else
                { 
                    SPsupervisorMap.put(supervisions.Student_Programme__c, new Set<Id> {supervisions.Supervisor__c});                    
                    contactIDs.add(supervisions.Supervisor__c);
                }
            }
        }
        for(User u : [SELECT Id,ContactId FROM User WHERE ContactId IN: contactIDs])
        {
            contactUserMap.put(u.ContactId,u.Id);
        }           
        Set<String> spListToUpdate = new Set <String>();
       // spListToUpdate;
        List<Student_Programme__c> spListToUpdateLst = new List <Student_Programme__c>();
        for(Student_Programme__c sp : [SELECT Id,Assigned_Supervisors__c FROM Student_Programme__c WHERE ID IN: studentproIds])
        {
            
          // sp.Assigned_Supervisors__c='';
            String str2='';
            
            for(Id supervisorId : SPsupervisorMap.get(sp.Id))
            {   
                spListToUpdate.add(String.valueOf(contactUserMap.get(supervisorId)));
            }
            for(String str : spListToUpdate)
            {
                str2=str2+str+',';            	
                system.debug('str2'+str2);
            } 
            sp.Assigned_Supervisors__c=str2;
            spListToUpdateLst.add(sp);
        }
        update spListToUpdateLst;
    }
    
    public static void removeFromTextArea(List<Supervision__c> supervisionList)
    {
        Map<Id,List<Id>> SPsupervisorMap = new Map<Id,List<Id>>();
        Map<Id,Id> contactUserMap = new Map<Id,Id>();   
        Set<Id> contactIDs= new Set<Id>();
        
        if ( !supervisionList.isEmpty() ) 
        {
            for(Supervision__c supervisions : supervisionList) 
            {
                if(SPsupervisorMap.containsKey(supervisions.Student_Programme__c))
                {
                    SPsupervisorMap.get(supervisions.Student_Programme__c).add(supervisions.Supervisor__c);
                    contactIDs.add(supervisions.Supervisor__c);
                }
                else
                {
                    SPsupervisorMap.put(supervisions.Student_Programme__c , new List<Id> {supervisions.Supervisor__c});
                    contactIDs.add(supervisions.Supervisor__c);
                }
            }
        }
        
        for(User u : [SELECT Id,ContactId FROM User WHERE ContactId IN: contactIDs])
        {
            contactUserMap.put(u.ContactId,u.Id);
        }           
        
        List<Student_Programme__c> spListToUpdate = new List <Student_Programme__c>();
        for(Student_Programme__c sp : [SELECT Id,Assigned_Supervisors__c FROM Student_Programme__c WHERE ID IN: SPsupervisorMap.keyset()])
        {
            
            for(Id supervisorId : SPsupervisorMap.get(sp.Id))
            {
                if(contactUserMap.get(supervisorId)!=null)
                {
                    If(sp.Assigned_Supervisors__c.contains(',' + String.valueOf(contactUserMap.get(supervisorId))))
                    {
                        sp.Assigned_Supervisors__c = sp.Assigned_Supervisors__c.remove(',' + String.valueOf(contactUserMap.get(supervisorId)));             
                        spListToUpdate.add(sp); 
                    }
                    else if(sp.Assigned_Supervisors__c.contains(String.valueOf(contactUserMap.get(supervisorId)+ ',')))
                    {
                        sp.Assigned_Supervisors__c = sp.Assigned_Supervisors__c.remove(String.valueOf(contactUserMap.get(supervisorId)+ ','));              
                        spListToUpdate.add(sp); 
                    }
                    else
                    {
                        sp.Assigned_Supervisors__c = sp.Assigned_Supervisors__c.remove(String.valueOf(contactUserMap.get(supervisorId)));               
                        spListToUpdate.add(sp);
                    }
                }
            }
        }
        update spListToUpdate;        
    } 
    public static void blankTextArea(List<Student_Programme__c> str)
    {
        for (Student_Programme__c str1: str)
            str1.Assigned_Supervisors__c=null;
            update str;

        
    }
    
}