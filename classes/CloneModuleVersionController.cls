public class CloneModuleVersionController {
    public final String MODULE_ID_PARAM = 'moduleId';

    public List<Module_Version__c> originalModuleList {get; set;}
    public Module_Version__c originalModule {get; set;}
    public Module_Version__c cloneModule {get; set;}
    public List<Assessment_Specification__c> assessmentSpecs {get; set;}
    public List<Module_Aim__c> moduleAims {get; set;}
    public List<Module_Learning_Outcome__c> moduleLearningOutcomes {get; set;}
    public List<Module_Skill_Attribute__c> moduleSkillsAttributes {get; set;}
    public List<MV_Modification__c> moduleMVmodifications {get; set;}
    
    public CloneModuleVersionController(ApexPages.StandardController std) {
        String moduleId = ApexPages.currentPage().getParameters().get(MODULE_ID_PARAM);
        cloneModule = new Module_Version__c();
        originalModuleList = new List<Module_Version__c>();

        String dbQuery = 'SELECT ';
        for(Schema.FieldSetMember f : SObjectType.Module_Version__c.FieldSets.Clone_Fields.getFields()) {
            dbQuery += f.getFieldPath() + ', ';
        }

        //dbQuery += '(Select Name, Member_Type__c, Module_Reference__c, Module_Version__c, Mod_Ver_Name__c, Programme_Version__c, Programme_Version_Suffix__c, Prog_Ver_Name__c From Instance_Members__r) ';
        //Include the Related List records for the Module Version
        //Assessment Specification
        dbQuery += '(SELECT of_Final_Module_Mark__c, Anonymous_Marking__c, Duration__c, Exam_Type__c, Final_Assessment__c, Module_Version__c, Record_No__c, Notes__c, Re_sit_Re_submission__c, Timing__c, Type__c,Semester__c  from Assessment_Specifications__r), ';
        //Module Aims
        dbQuery += '(SELECT Module_Version__c, Record_No__c, Specific_Aim__c from Module_Aims__r), ';
        //Module Learning Outcomes
        dbQuery += '(SELECT Learning_Outcome__c, Method_of_Teaching__c, Mode_of_Assessment__c, Module_Version__c, Record_No__c from Module_Learning_Outcomes__r), ';
        //Module Skills & Attributes
        dbQuery += '(SELECT How_Developed__c, Method_of_Teaching__c, Module_Version__c, Record_No__c, Skill_or_Attribute__c from Module_Skill_Attributes__r), ';
        //Module Skills & Attributes
        dbQuery += '(SELECT Cohort_Affected__c, Date_Approved_by_QMC__c, Modification_Description__c, Modification_Type__c, Module_Version__c from MV_Modifications__r) ';


        dbQuery += ' FROM Module_Version__c where Id = \'' + moduleId + '\'';

        system.debug('*** -- dbQuery -- ***');
        system.debug(dbQuery);
        
        originalModuleList = Database.query(dbQuery);   

        if (originalModuleList.size() > 0){
            originalModule = originalModuleList[0];
        }

        cloneModule = originalModule.clone(false, true, false, false);
        cloneModule.Active__c = true;

    }

    //This is the method that will clone the programme and all modules
    public PageReference cloneModule(){
        PageReference pageRef;
        
        //Insert the new Module
        insert cloneModule;
        
        //2015-02-10 : SM : Also clone any corresponding Related List records
        assessmentSpecs = new List<Assessment_Specification__c>();
        moduleAims = new List<Module_Aim__c>();
        moduleLearningOutcomes = new List<Module_Learning_Outcome__c>();
        moduleSkillsAttributes = new List<Module_Skill_Attribute__c>();
        moduleMVmodifications = new List<MV_Modification__c>();

        for (Assessment_Specification__c aspec : originalModule.Assessment_Specifications__r){
            Assessment_Specification__c newAS = aspec.Clone(false, true, false, false);
            newAS.Module_Version__c = cloneModule.Id;
            assessmentSpecs.add(newAS);
        }

        for (Module_Aim__c ma : originalModule.Module_Aims__r){
            Module_Aim__c newMA = ma.Clone(false, true, false, false);
            newMA.Module_Version__c = cloneModule.Id;
            moduleAims.add(newMA);
        }

        for (Module_Learning_Outcome__c mlc : originalModule.Module_Learning_Outcomes__r){
            Module_Learning_Outcome__c newMLC = mlc.Clone(false, true, false, false);
            newMLC.Module_Version__c = cloneModule.Id;
            moduleLearningOutcomes.add(newMLC);
        }

        for (Module_Skill_Attribute__c msa : originalModule.Module_Skill_Attributes__r){
            Module_Skill_Attribute__c newMSA = msa.Clone(false, true, false, false);
            newMSA.Module_Version__c = cloneModule.Id;
            moduleSkillsAttributes.add(newMSA);
        }
        
        for (MV_Modification__c mvm : originalModule.MV_Modifications__r){
            MV_Modification__c newMVM = mvm.Clone(false, true, false, false);
            newMVM.Module_Version__c = cloneModule.Id;
            moduleMVmodifications.add(newMVM);
        }

        insert assessmentSpecs;
        insert moduleAims;
        insert moduleLearningOutcomes;
        insert moduleSkillsAttributes;
        insert moduleMVmodifications;
        
        pageRef = new PageReference('/' + cloneModule.Id);
        pageRef.setRedirect(true);
                
        return pageRef;
    }
}