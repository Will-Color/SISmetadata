/**
 * @author simon edwards
 * @date 22/05/2014
 * @description Service class CloneProgrammeController
 */
/***** Modifications
** @author MKM 
** done for Support task Remove additional X fields
<summary>Modifieds SOQL ANd removed usage of additional X fields From Student Programme and programme module querries</summary>
*/

public with sharing class CloneProgrammeController {
    public final String PROG_ID_PARAM = 'progId';
    public final String MSC_TYPE = 'Masters Module';
    public List<Programme__c> originalProgList {get; set;}
    public Programme__c originalProg {get; set;}
    public Programme__c cloneProg {get; set;}
    public List<Programme_Module__c> originalProgModuleList {get; set;}
    public List<ModuleWrapper> moduleWrapperList {get; set;}
    public integer numberOfSessions {get; set;}
    public Map<Id, Programme_Module__c> originalProgModuleMap {get; set;}
    public boolean isShortCourse {get; set;}
    public String filterName {get; set;}
    public String filterType {get; set;}
    public boolean noResults {get; set;}
    public Map<Module__c,Module__c> duplicateModuleMap {get;set;}
    public Map<String,Module__c> moduleReferenceMap {get;set;}

    public CloneProgrammeController(ApexPages.standardController std){
        isShortCourse = false;
        String progId = ApexPages.currentPage().getParameters().get(PROG_ID_PARAM);
        moduleReferenceMap = new Map<String,Module__c>();        
        duplicateModuleMap = new Map<Module__c,Module__c>();
        cloneProg = new Programme__c();
        originalProgList = new List<Programme__c>();
        originalProgList = [Select p.Type__c, p.Start_Date__c, p.Remaining_Places__c, p.Programme_Version__c, p.Programme_Type__c, p.Programme_Instance_Name__c, p.Programme_Group__c, p.Places_Taken__c, 
                            p.Overseas_Fee__c, p.Name, p.Mode__c, p.Instance_Suffix__c, p.Instance_Reference__c, p.Instance_Date__c, p.Home_EU_Fee__c, p.End_Date__c, p.Director_of_Studies__c, 
                            p.Description__c, p.Code__c, p.Capacity__c, p.Assigned_Modules__c, p.Active__c, p.Academic_Credits__c, 
                             (Select Name, Member_Type__c, Programme__c, Module__c, Places_Taken__c, Programme_Type__c,Programme_Credits__c From Programme_Modules__r) 
                            From Programme__c p where p.Id = :progId];   
        
        if (originalProgList.size() > 0){
            originalProg = originalProgList[0];
            originalProgModuleList = originalProgList[0].Programme_Modules__r;
        }
        
        if (MSC_TYPE.equalsIgnoreCase(originalProg.Type__c)){
            isShortCourse = true;
        }
        
        originalProgModuleMap = new Map<Id, Programme_Module__c>();
        for (Programme_Module__c pm : originalProgModuleList){
            originalProgModuleMap.put(pm.Module__c, pm);
        }       
        
        cloneProg = originalProg.clone(false, true, false, false);
        cloneProg.Active__c = true;
        
        if (!isShortCourse){        
            Set<Id> moduleIds = new Set<Id>();
            for (Programme_Module__c pm : originalProgModuleList){
                moduleIds.add(pm.Module__c);
            }
            
            List<Module__c> originalModuleList = new List<Module__c>();
            List<Module__c> clonedModuleList = new List<Module__c>();
            Map<Id, Module__c> originalModuleMap = new Map<Id, Module__c>();
            originalModuleList = [Select m.Retire_Date__c, m.Name, m.Module_Version__c, m.Module_Type__c, m.Module_Status__c, m.Module_Reference__c, m.Instance_Suffix__c, 
                                   m.Id, m.Description__c, m.Criticality_Threshold__c, m.Criticality_Rollup__c, m.Credits__c, m.Assessment_Variable_Sum__c, m.Assessment_Variable_6__c, 
                                    m.Assessment_Variable_5__c, m.Assessment_Variable_4__c, m.Assessment_Variable_3__c, m.Assessment_Variable_2__c, m.Assessment_Variable_1__c, m.Approved_Date__c, 
                                    m.Active_Date__c, m.Accreditation__c,
                                    (Select Name, RecordTypeId, Session_Type__c, Room_Name__c, Module__c From Sessions__r), 
                                    (Select Name, Module__c, Assessment_Type__c, Description__c, Weighting_Variable__c, Weighting_percent__c,
                                    Module_Reference__c, Pass_Critical__c, Criticality_Score__c From Assessments__r)  
                                    From Module__c m where m.Id in :moduleIds];
                                    
            moduleWrapperList = new List<ModuleWrapper>();
            for (Module__c m : originalModuleList){
                moduleWrapperList.add(new ModuleWrapper(m));
                moduleReferenceMap.put(m.Module_Reference__c,m);
            }
        }   
    }

    //This method will return a list of Modules with the matching searched for criteria
    public PageReference filterModules(){
        String dbQuery = 'Select m.Retire_Date__c, m.Name, m.Module_Version__c, m.Module_Type__c, m.Module_Status__c, m.Module_Reference__c, m.Instance_Suffix__c,'; 
        dbQuery += 'm.Id, m.Description__c, m.Criticality_Threshold__c, m.Criticality_Rollup__c, m.Credits__c, m.Assessment_Variable_Sum__c, m.Assessment_Variable_6__c,'; 
        dbQuery += 'm.Assessment_Variable_5__c, m.Assessment_Variable_4__c, m.Assessment_Variable_3__c, m.Assessment_Variable_2__c, m.Assessment_Variable_1__c, m.Approved_Date__c,'; 
        dbQuery += 'm.Active_Date__c, m.Accreditation__c,';
        dbQuery += '(Select Name, RecordTypeId, Session_Type__c, Room_Name__c, Module__c From Sessions__r),'; 
        dbQuery +=  '(Select Name, Module__c, Assessment_Type__c, Description__c, Weighting_Variable__c, Weighting_percent__c,'; 
        dbQuery += 'Module_Reference__c, Pass_Critical__c, Criticality_Score__c From Assessments__r) From Module__c m where m.Name LIKE \'' + filterName + '%\' ORDER BY m.Name DESC';
        
        system.debug('*** -- dbQuery = ' + dbQuery + ' -- ***');
        
        List<Module__c> originalModuleList = new List<Module__c>();
        originalModuleList = Database.Query(dbQuery);
        if (originalModuleList.size() == 0){
            noResults = true;
        }else {
            noResults = false;
        }
        
        List<Module__c> clonedModuleList = new List<Module__c>();
        Map<Id, Module__c> originalModuleMap = new Map<Id, Module__c>();
        
        if (!noResults){
            moduleWrapperList = new List<ModuleWrapper>();
            for (Module__c m : originalModuleList){
                moduleWrapperList.add(new ModuleWrapper(m));
            }
        }
        
        return null;
    }

    //This is the method that will clone the programme and all modules
    public PageReference cloneProgramme(){
        Map<Id, Module__c> cloneModulesMap = new Map<Id, Module__c>();
        List<Programme_Module__c> cloneProgModules = new List<Programme_Module__c>();
        List<Assessment__c> cloneAssessments = new List<Assessment__c>();
        List<Session__c> cloneSessions = new List<Session__c>();
        PageReference pageRef;
        
        //First we need to insert the new Programme
        insert cloneProg;

        for(Module__c m : [Select Retire_Date__c, Name, Module_Version__c, Module_Type__c, Module_Status__c, Module_Reference__c, Instance_Suffix__c,Id,Description__c,Criticality_Threshold__c,Criticality_Rollup__c,Credits__c,Assessment_Variable_Sum__c,Assessment_Variable_6__c, 
                                  Assessment_Variable_5__c,Assessment_Variable_4__c,Assessment_Variable_3__c,Assessment_Variable_2__c,Assessment_Variable_1__c,Approved_Date__c,Active_Date__c,Accreditation__c
                           From Module__c WHERE Instance_Suffix__c =: cloneProg.Instance_Suffix__c AND Module_Reference__c IN: moduleReferenceMap.keyset() AND Id NOT IN: moduleReferenceMap.Values()]){
            duplicateModuleMap.put(moduleReferenceMap.get(m.Module_Reference__c),m);                    
        }               
            
        system.debug('Ref map : ' + moduleReferenceMap);
        system.debug('Duplicate map : ' + duplicateModuleMap);       
                           
        //2014-07-15 : CSL : We need to only create Modules if this isn't the special type (At the moment set to Short Course, but TBD)
        if (!isShortCourse){
            //Then we need to loop through all the selected Modules and clone them
            for (ModuleWrapper mw : moduleWrapperList){
                if (mw.isSelected){
                    if(duplicateModuleMap.containsKey(mw.theModule)){
                        cloneModulesMap.put(mw.theModule.Id,duplicateModuleMap.get(mw.theModule));
                    }
                    else{
                        system.debug('Cloning module.....');
                        Module__c cloneMod = mw.theModule.clone(false, true, false, false);
                        cloneMod.Instance_Suffix__c = cloneProg.Instance_Suffix__c;
                        cloneModulesMap.put(mw.theModule.Id, cloneMod);                     
                    }
                }
            }
            
            upsert cloneModulesMap.values();
                    
            //Now we need to make sure we have the Programme_Modules__c cloned
            for (ModuleWrapper mw : moduleWrapperList){
                if (mw.isSelected){
                    Programme_Module__c originalPM = originalProgModuleMap.get(mw.theModule.Id);
                    if (originalPM != null){
                        Module__c cloneModule = cloneModulesMap.get(mw.theModule.Id);
                        Programme_Module__c clonePM = originalPM.clone(false, true, false, false);
                        clonePM.Module__c = cloneModule.Id;
                        clonePM.Programme__c = cloneProg.Id;
                        cloneProgModules.add(clonePM);
                    }   
                }
            }
            
            insert cloneProgModules;
            
            for (ModuleWrapper mw : moduleWrapperList){
                if (mw.isSelected){
                    for (Assessment__c a : mw.theModule.Assessments__r){
                        Assessment__c cloneAssessment = a.clone(false, true, false, false);
                        cloneAssessment.Module__c = cloneModulesMap.get(mw.theModule.Id).Id;
                        cloneAssessments.add(cloneAssessment);
                    }
                    for (Session__c s : mw.theModule.Sessions__r){
                        Session__c cloneSession = s.clone(false, true, false, false);
                        cloneSession.Module__c = cloneModulesMap.get(mw.theModule.Id).Id;
                        cloneSessions.add(cloneSession);
                    }
                }
            }
            
            insert cloneAssessments;
            insert cloneSessions;
        }else {
            //2014-07-15 : CSL : This is new code for the specialist 'forked clone' functionality
            for (ModuleWrapper mw : moduleWrapperList){
                if (mw.isSelected){
                    Programme_Module__c clonePM = new Programme_Module__c();
                    clonePM.Module__c = mw.theModule.Id;
                    clonePM.Programme__c = cloneProg.Id;
                    cloneProgModules.add(clonePM);
                }
            }
            
            insert cloneProgModules;
            
            for (ModuleWrapper mw : moduleWrapperList){
                if (mw.isSelected){
                    for (Assessment__c a : mw.theModule.Assessments__r){
                        Assessment__c cloneAssessment = a.clone(false, true, false, false);
                        cloneAssessment.Module__c = mw.theModule.Id;
                        cloneAssessments.add(cloneAssessment);
                    }
                    for (Session__c s : mw.theModule.Sessions__r){
                        Session__c cloneSession = s.clone(false, true, false, false);
                        cloneSession.Module__c = mw.theModule.Id;
                        cloneSessions.add(cloneSession);
                    }
                }
            }
            
            insert cloneAssessments;
            insert cloneSessions;
        }
        
        pageRef = new PageReference('/' + cloneProg.Id);
        pageRef.setRedirect(true);
                
        return pageRef;
    }

    public class ModuleWrapper {
        public Module__c theModule {get; set;}
        public integer numberOfSessions {get; set;}
        public integer numberOfAssessments {get; set;}
        public boolean isSelected {get; set;}
        
        public ModuleWrapper(Module__c inMod) {
            theModule = inMod;
            numberOfSessions = inMod.Sessions__r.size();
            numberOfAssessments = inMod.Assessments__r.size();
            isSelected = false;
        }
        
    }

}