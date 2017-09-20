public class CloneProgrammeVersionController {
	public final String PROG_ID_PARAM = 'progId';
	public final String MSC_TYPE = 'Masters Module';
	public List<Programme_Version__c> originalProgList {get; set;}
	public Programme_Version__c originalProg {get; set;}
	public Programme_Version__c cloneProg {get; set;}
	public List<Programme_Module_Version__c> originalProgModuleList {get; set;}
	public List<ModuleWrapper> moduleWrapperList {get; set;}
	public integer numberOfSessions {get; set;}
	public Map<Id, Programme_Module_Version__c> originalProgModuleMap {get; set;}
	public boolean isShortCourse {get; set;}
	public String filterName {get; set;}
	public String filterType {get; set;}
	public boolean noResults {get; set;}
	//Related list objects against Programme Version
	public List<Programme_Aim__c> programmeAims {get; set;}
	public List<Skills_Attributes__c> skillsAttributes {get; set;}
	public List<Learning_Outcome__c> learningOutcomes {get; set;}
	

	public CloneProgrammeVersionController(ApexPages.standardController std){
		isShortCourse = false;
		String progId = ApexPages.currentPage().getParameters().get(PROG_ID_PARAM);
		cloneProg = new Programme_Version__c();
		originalProgList = new List<Programme_Version__c>();

		String dbQuery = 'SELECT Id, ';
		for(Schema.FieldSetMember f : SObjectType.Programme_Version__c.FieldSets.AllFields.getFields()) {
            dbQuery += f.getFieldPath() + ', ';
        }

	    dbQuery += '(Select Name, Member_Type__c, Module_Reference__c, Module_Version__c, Mod_Ver_Name__c, Programme_Version__c, Programme_Version_Suffix__c, Prog_Ver_Name__c From Instance_Members__r), ';
	    //Programme Aims
	    dbQuery += '(Select Record_No__c, Specific_Aim__c from Programme_Aims__r), ';
	    //Skills & Attributes
	    dbQuery += '(Select Mode_of_Assessing__c, Modules_Included__c, Record_No__c, Skill_Attribute__c from Skills_Attributes__r), ';
	    //Learning Outcomes
	    dbQuery += '(Select Learning_Outcome__c, Mode_of_Assessing__c, Modules_Included__c, Record_No__c, Outcome_Type__c, Type__c from Specification_Outcomes__r)';

        dbQuery += 'FROM Programme_Version__c where Id = \'' + progId + '\'';

        system.debug('*** -- dbQuery -- ***');
        system.debug(dbQuery);
		
		originalProgList = Database.query(dbQuery);

		if (originalProgList.size() > 0){
			originalProg = originalProgList[0];
			originalProgModuleList = originalProgList[0].Instance_Members__r;
		}
		
		if (MSC_TYPE.equalsIgnoreCase(originalProg.Programme_Type__c)){
			isShortCourse = true;
		}
		
		system.debug('*** -- isShortCourse = ' + isShortCourse + ' -- ***');

		originalProgModuleMap = new Map<Id, Programme_Module_Version__c>();
		for (Programme_Module_Version__c pm : originalProgModuleList){
			originalProgModuleMap.put(pm.Module_Version__c, pm);
		}		
		
		cloneProg = originalProg.clone(false, true, false, false);
		cloneProg.Active__c = true;
		
		if (!isShortCourse){		
			Set<Id> moduleIds = new Set<Id>();
			for (Programme_Module_Version__c pm : originalProgModuleList){
				moduleIds.add(pm.Module_Version__c);
			}
			
			List<Module_Version__c> originalModuleList = new List<Module_Version__c>();
			List<Module_Version__c> clonedModuleList = new List<Module_Version__c>();
			Map<Id, Module_Version__c> originalModuleMap = new Map<Id, Module_Version__c>();

			String dbModuleQuery = 'SELECT ';

			for(Schema.FieldSetMember f : SObjectType.Module_Version__c.FieldSets.AllFields.getFields()) {
	            dbModuleQuery += f.getFieldPath() + ', ';
	        }

		    //dbModuleQuery += '(Select Name, RecordTypeId, Session_Type__c, Room_Name__c, Module__c From Sessions__r), ';
		    //dbModuleQuery += '(Select Name, Module__c, Assessment_Type__c, Description__c, Weighting_Variable__c, Weighting_percent__c, Short_Name__c, Module_Reference__c, Pass_Critical__c, Criticality_Score__c From Assessments__r)';

	        dbModuleQuery += 'Id From Module_Version__c m where m.Id in :moduleIds';

					
			originalModuleList = Database.query(dbModuleQuery);

			moduleWrapperList = new List<ModuleWrapper>();
			for (Module_Version__c m : originalModuleList){
				moduleWrapperList.add(new ModuleWrapper(m));
			}
		} 	
	}

	//This method will return a list of Modules with the matching searched for criteria
	public PageReference filterModules(){
		String dbQuery = 'SELECT ';

		for(Schema.FieldSetMember f : SObjectType.Module_Version__c.FieldSets.AllFields.getFields()) {
            dbQuery += f.getFieldPath() + ', ';
        }

	    //dbQuery += '(Select Name, RecordTypeId, Session_Type__c, Room_Name__c, Module__c From Sessions__r), ';
	    //dbQuery += '(Select Name, Module__c, Assessment_Type__c, Description__c, Weighting_Variable__c, Weighting_percent__c, Short_Name__c, Module_Reference__c, Pass_Critical__c, Criticality_Score__c From Assessments__r)';

        dbQuery += 'Id From Module_Version__c m where m.Name LIKE \'' + filterName + '%\' ORDER BY m.Name DESC';

		system.debug('*** -- dbQuery = ' + dbQuery + ' -- ***');
		
		List<Module_Version__c> originalModuleList = new List<Module_Version__c>();
		originalModuleList = Database.Query(dbQuery);
		if (originalModuleList.size() == 0){
			noResults = true;
		}else {
			noResults = false;
		}
		
		List<Module_Version__c> clonedModuleList = new List<Module_Version__c>();
		Map<Id, Module_Version__c> originalModuleMap = new Map<Id, Module_Version__c>();
		
		if (!noResults){
			moduleWrapperList = new List<ModuleWrapper>();
			for (Module_Version__c m : originalModuleList){
				moduleWrapperList.add(new ModuleWrapper(m));
			}
		}
		
		return null;
	}

	//This is the method that will clone the programme and all modules
	public PageReference cloneProgramme(){
		Map<Id, Module_Version__c> cloneModulesMap = new Map<Id, Module_Version__c>();
		List<Programme_Module_Version__c> cloneProgModules = new List<Programme_Module_Version__c>();
		List<Assessment__c> cloneAssessments = new List<Assessment__c>();
		List<Session__c> cloneSessions = new List<Session__c>();
		PageReference pageRef;
		
		//First we need to insert the new Programme
		insert cloneProg;
		
		//2014-07-15 : CSL : We need to only create Modules if this isn't the special type (At the moment set to Short Course, but TBD)
		if (!isShortCourse){
			//Then we need to loop through all the selected Modules and clone them
			for (ModuleWrapper mw : moduleWrapperList){
				if (mw.isSelected){
					Module_Version__c cloneMod = mw.theModule.clone(false, true, false, false);
					cloneMod.Version_Suffix__c = cloneProg.Version_Suffix__c;
					cloneModulesMap.put(mw.theModule.Id, cloneMod);
				}
			}
			
			insert cloneModulesMap.values();
					
			//Now we need to make sure we have the Programme_Modules__c cloned
			for (ModuleWrapper mw : moduleWrapperList){
				if (mw.isSelected){
					Programme_Module_Version__c originalPM = originalProgModuleMap.get(mw.theModule.Id);
					if (originalPM != null){
						Module_Version__c cloneModule = cloneModulesMap.get(mw.theModule.Id);
						Programme_Module_Version__c clonePM = originalPM.clone(false, true, false, false);
						clonePM.Module_Version__c = cloneModule.Id;
						clonePM.Programme_Version__c = cloneProg.Id;
						cloneProgModules.add(clonePM);
					}	
				}
			}
			
			insert cloneProgModules;
			
		}else {
			//2014-07-15 : CSL : This is new code for the specialist 'forked clone' functionality
			for (ModuleWrapper mw : moduleWrapperList){
				if (mw.isSelected){
					Programme_Module_Version__c clonePM = new Programme_Module_Version__c();
					clonePM.Module_Version__c = mw.theModule.Id;
					clonePM.Programme_Version__c = cloneProg.Id;
					cloneProgModules.add(clonePM);
				}
			}
			
			insert cloneProgModules;
			
		}

		//Clone any related list objects
		programmeAims = new List<Programme_Aim__c>();
		skillsAttributes = new List<Skills_Attributes__c>();
		learningOutcomes = new List<Learning_Outcome__c>();
		for (Programme_Aim__c pa : originalProgList[0].Programme_Aims__r){
			Programme_Aim__c newPA = pa.Clone(false, true, false, false);
			newPA.Programme_Version__c = cloneProg.Id;
			programmeAims.add(newPA);
		}

		for (Skills_Attributes__c sa : originalProgList[0].Skills_Attributes__r){
			Skills_Attributes__c newSA = sa.Clone(false, true, false, false);
			newSA.Programme_Version__c = cloneProg.Id;
			skillsAttributes.add(newSA);
		}

		for (Learning_Outcome__c lc : originalProgList[0].Specification_Outcomes__r){
			Learning_Outcome__c newLC = lc.Clone(false, true, false, false);
			newLC.Programme_Version__c = cloneProg.Id;
			learningOutcomes.add(newLC);
		}

		if (programmeAims.size() > 0) insert programmeAims;

		if (skillsAttributes.size() > 0) insert skillsAttributes;

		if (learningOutcomes.size() > 0) insert learningOutcomes;
		
		pageRef = new PageReference('/' + cloneProg.Id);
		pageRef.setRedirect(true);
				
		return pageRef;
	}

	public class ModuleWrapper {
		public Module_Version__c theModule {get; set;}
		public integer numberOfSessions {get; set;}
		public integer numberOfAssessments {get; set;}
		public boolean isSelected {get; set;}
		
		public ModuleWrapper(Module_Version__c inMod) {
			theModule = inMod;
			//numberOfSessions = inMod.Sessions__r.size();
			//numberOfAssessments = inMod.Assessments__r.size();
			isSelected = false;
		}
		
	}

}