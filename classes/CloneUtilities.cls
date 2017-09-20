/*
 * @author simon edwards
 * @date 22/05/2014
*  2014-05-13 : CSL : This class will be used from the Salesforce UI (hence the 'global' setting)
*  and will hold methods used for cloning records
*
*/
/***** Modifications
** @author MKM 
** done for Support task Remove additional X fields
<summary>Modifieds SOQL ANd removed usage of additional X fields From Student Programme and programme module querries</summary>
*/

global with sharing class CloneUtilities {
    public Programme__c originalProg {get; set;}
    public Programme__c cloneProg {get; set;}
    public String progId {get; set;}
    //Method to clone a Programme, but give the user a choice of which 
    //Existing module to link to via a VF page
    
    global CloneUtilities(ApexPages.StandardController std){
        //This constructor has been left intentionally blank
        progId = ApexPages.currentPage().getParameters().get('Id');
        List<Programme_Module__c> originalProgModuleList;
        List<Programme__c> originalProgList = new List<Programme__c>();
        
        originalProgList = [Select p.Start_Date__c, p.Remaining_Places__c, p.Programme_Version__c, p.Programme_Type__c, p.Programme_Instance_Name__c, p.Places_Taken__c, p.OwnerId, 
                            p.Overseas_Fee__c, p.Instance_Suffix__c, p.Programme_Group__c, p.Name, p.Instance_Reference__c, p.Instance_Date__c, p.Home_EU_Fee__c, p.End_Date__c, p.Description__c, p.Capacity__c, p.Assigned_Modules__c, 
                            p.Active__c, p.Code__c, p.Mode__c, p.Academic_Credits__c, p.Type__c,
                            (Select Name, Member_Type__c, Programme__c, Module__c, Places_Taken__c, Programme_Type__c, Programme_Credits__c From Programme_Modules__r) 
                            From Programme__c p where p.Id = :progId];   
                                      
                            
        if (originalProgList.size() > 0){
            originalProg = originalProgList[0];
            originalProgModuleList = originalProgList[0].Programme_Modules__r;
        }
        
        cloneProg = new Programme__c();
        
        
    }
    
    public PageReference cloneProgrammeVF(String progId){
        List<Programme__c> originalProgList = new List<Programme__c>();
        Programme__c originalProg;
        List<Programme_Module__c> originalProgModuleList;
         originalProgList = [Select p.Start_Date__c, p.Remaining_Places__c, p.Programme_Version__c, p.Programme_Type__c, p.Programme_Instance_Name__c, p.Places_Taken__c, p.OwnerId, 
                            p.Overseas_Fee__c, p.Name, p.Instance_Reference__c, p.Instance_Date__c, p.Home_EU_Fee__c, p.End_Date__c, p.Description__c, p.Capacity__c, p.Assigned_Modules__c, 
                            p.Active__c, (Select Name, Member_Type__c, Programme__c, Module__c, Places_Taken__c, Programme_Type__c, Programme_Credits__c From Programme_Modules__r) 
                            From Programme__c p where p.Id = :progId];   
                            
       
        
        if (originalProgList.size() > 0){
            originalProg = originalProgList[0];
            originalProgModuleList = originalProgList[0].Programme_Modules__r;
        }
        
        Programme__c clonedProg = originalProg.clone(false, true, false, false);
        clonedProg.Instance_Reference__c = clonedProg.Instance_Reference__c + '_CLONE';
        clonedProg.Name = clonedProg.Name + '_CLONE';
        
        try {
            insert clonedProg;
        }catch (DMLException dmlEx){
            system.debug('*** -- Error inserting cloned programme -- ***');
            system.debug('*** -- ' + dmlEx + ' -- ***');
            return null;
        }
        
        //Now we need to return the user to a VF page so 
        //that they can choose which Module (singular) they wish to 
        //clone and attach
        
        return Page.ProgrammeClone;
        //return null;
        
    }


    //Method to clone a Programme and all associated child records
    webservice static String cloneProgramme(String progId){
        List<Programme__c> originalProgList = new List<Programme__c>();
        Programme__c originalProg;
        List<Programme_Module__c> originalProgModuleList;
        originalProgList = [Select p.Start_Date__c, p.Remaining_Places__c, p.Programme_Version__c, p.Programme_Type__c, p.Programme_Instance_Name__c, p.Places_Taken__c, p.OwnerId, 
                            p.Overseas_Fee__c, p.Name, p.Instance_Reference__c, p.Instance_Date__c, p.Home_EU_Fee__c, p.End_Date__c, p.Description__c, p.Capacity__c, p.Assigned_Modules__c, 
                            p.Active__c, (Select Name, Member_Type__c, Programme__c, Module__c, Places_Taken__c, Programme_Type__c, Programme_Credits__c From Programme_Modules__r) 
                            From Programme__c p where p.Id = :progId]; 
      
        
        if (originalProgList.size() > 0){
            originalProg = originalProgList[0];
            originalProgModuleList = originalProgList[0].Programme_Modules__r;
        } 
        
        //We clone the original programme, using preserve id = false, deep clone = true, preserve read only fields = false, preserve autonumber = false
        //TODO : Question - do we need to clear out 'Places Taken' etc.
        Programme__c clonedProg = originalProg.clone(false, true, false, false);
        clonedProg.Instance_Reference__c = clonedProg.Instance_Reference__c + '_CLONE';
        clonedProg.Name = clonedProg.Name + '_CLONE';
        
        try {
            insert clonedProg;
        }catch (DMLException dmlEx){
            system.debug('*** -- Error inserting cloned programme -- ***');
            system.debug('*** -- ' + dmlEx + ' -- ***');
            return null;
        }
        
        //Now we need to clone all the Module records, using the same arguments as the Programme clone
        Set<Id> moduleIds = new Set<Id>();
        for (Programme_Module__c pm : originalProgModuleList){
            moduleIds.add(pm.Module__c);
        }
        
        List<Module__c> originalModuleList = new List<Module__c>();
        List<Module__c> clonedModuleList = new List<Module__c>();
        Map<Id, Module__c> originalModuleMap = new Map<Id, Module__c>();
        originalModuleList = [Select m.Retire_Date__c, m.Name, m.Module_Version__c, m.Module_Type__c, m.Module_Status__c, m.Module_Reference__c,
                                m.Description__c, m.Credits__c, m.Assessment_Variable_Sum__c, m.Assessment_Variable_3__c, m.Assessment_Variable_2__c, m.Assessment_Variable_1__c, m.Approved_Date__c, 
                                m.Active_Date__c, m.Accreditation__c 
                                From Module__c m where m.Id in :moduleIds];
                                
        if (originalModuleList.size() > 0){
            for (Module__c m : originalModuleList){
                Module__c clonedModule = m.clone(false, true, false, false);
                clonedModuleList.add(clonedModule);
                originalModuleMap.put(m.Id, clonedModule);
            }
            
            try {
                insert clonedModuleList;
            }catch (DMLException dmlEx){
                system.debug('*** -- Error inserting cloned programme -- ***');
                system.debug('*** -- ' + dmlEx + ' -- ***');
                return null;
            }
        }
        
        //Finally we need to clone all the Programme Module records, using the same arguments as the Programme clone        
        List<Programme_Module__c> clonedProgModuleList = new List<Programme_Module__c>();
        for (Programme_Module__c pm : originalProgModuleList){
            Programme_Module__c clonedPM = pm.clone(false, true, false, false);
            clonedPM.Programme__c = clonedProg.Id;
            clonedPM.Module__c = originalModuleMap.get(pm.Module__c).Id;
            clonedProgModuleList.add(clonedPM);
        }
        
        if (clonedProgModuleList.size() > 0){
            try {
                insert clonedProgModuleList;
            }catch (DMLException dmlEx){
                system.debug('*** -- Error inserting cloned programme modules -- ***');
                system.debug('*** -- ' + dmlEx + ' -- ***');
                return null;
            }
        }
        
        return clonedProg.Id;
    }

}