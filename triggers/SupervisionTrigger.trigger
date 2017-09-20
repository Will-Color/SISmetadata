trigger SupervisionTrigger on Supervision__c (after insert, after update, after delete) {
    
    List<Supervision__c> addList = new List<Supervision__c>();
    List<Supervision__c> removeList = new List<Supervision__c>();
    List<Supervision__c> supervisionsList = new List<Supervision__c>();
    
    List<Id> studentproIds= new List<Id>();
    set<Id> SupervisorIds= new set<Id>();
    List<Id> studentPrgmOldIds = new List<Id>();
    Map<Id,Id> contactUserMap = new Map<Id,Id>();   
    if(Trigger.isInsert)
    {
        for(Supervision__c supervisions: trigger.new)
        {
            if(supervisions.Supervisor__c !=null || supervisions.Student_Programme__c != null){
                studentproIds.add(supervisions.Student_Programme__c);  
                SupervisorIds.add(supervisions.Supervisor__c);
            }   
        } 
    }
    if(Trigger.isUpdate){
        for(Supervision__c supervisionsNew: trigger.new)
        {
            if(supervisionsNew.Supervisor__c !=null || supervisionsNew.Student_Programme__c != null){
                studentproIds.add(supervisionsNew.Student_Programme__c);   
                SupervisorIds.add(supervisionsNew.Supervisor__c);
            }
        }  
        for(Supervision__c supervisionsOld: trigger.old)
        {
            studentproIds.add(supervisionsOld.Student_Programme__c);
            SupervisorIds.add(supervisionsOld.Supervisor__c);
        }
    }    
    if(Trigger.isDelete){
        for(Supervision__c supervisionsNew: trigger.old)
        {
            SupervisorIds.add(supervisionsNew.Supervisor__c);
            studentproIds.add(supervisionsNew.Student_Programme__c);            
        }  
    }  
    set<id>ProgrammeSupervisor =new set<id>();
    for(Supervision__c sup : [SELECT Id, Supervisor__c FROM Supervision__c WHERE  Student_Programme__c IN: studentproIds ])  
    {
        ProgrammeSupervisor.add(sup.Supervisor__c);
    }
    
    for(User u : [SELECT Id,ContactId FROM User WHERE ContactId IN: ProgrammeSupervisor])
        contactUserMap.put(u.ContactId,u.Id);
    List<Student_Programme__c> ListUpdate = new List<Student_Programme__c >();
    set<id> ListofSupervisonids = new  set<id>();
    string str;
    for(Student_Programme__c s: [select id,Assigned_Supervisors__c,(select Name,id,Supervisor__c from Supervisors__r) from Student_Programme__c Where id IN: studentproIds])
    {   
        str='';
        //System.debug('s.Supervisors__r'+ s.Supervisors__r);
        for(Supervision__c Supervisor : s.Supervisors__r)
            ListofSupervisonids.add(Supervisor.Supervisor__c);
        for(id sid : ListofSupervisonids)
            str +=String.valueOf(contactUserMap.get(sid))+',';
        s.Assigned_Supervisors__c = str;
        ListUpdate.add(s) ;  
        ListofSupervisonids.clear();
    }
    //System.debug('ListUpdate'+ListUpdate);
    update ListUpdate;
    
    
    
    
}