/**
 * @author Mykola Senyk
 * @date 16/07/2014
 * @description Controller for QuickCreateProgramme page
 */
public with sharing class QuickCreateProgrammeCont {
    
    // inner fields
    private Programme_Version__c masterProgramme;
    private Programme_Version__c versionProgramme;
    @TestVisible
    private Programme__c programme;
    private Module_Version__c masterModule;
    private Module_Version__c versionModule;
    @TestVisible
    private Module__c module;
    private Programme_Module_Version__c pmv;
    Programme_Module__c pm;
    
    public QuickCreateProgrammeCont() {
        init();
    }
    
    public Programme__c prog { get; set; }
    public Programme_Version__c progVersion { get; set; }
    public Programme_Module__c progModule { get; set; }
    
    
    /**
     * To do initialization
     */
    private void init() {
        prog = new Programme__c();
        progVersion = new Programme_Version__c(Mode__c = ApplyServices.PV_MODE_FT);
        progModule = new Programme_Module__c();
    }
    
    /**
     * Create programme with versions
     */
    private void buildProgrammes() {
        masterProgramme = new Programme_Version__c(
            RecordTypeId = CommonUtils.findRecordTypeIdByDev('Programme_Version__c', ApplyServices.RT_MASTER_PV_DEVNAME),
            Name = prog.Name, Active__c = prog.Active__c, Programme_Type__c = progVersion.Programme_Type__c,
            Mode__c = progVersion.Mode__c, Code__c = progVersion.Code__c, Programme_Group__c = progVersion.Programme_Group__c
        );
        insert masterProgramme;
        
        versionProgramme = new Programme_Version__c(
            RecordTypeId = CommonUtils.findRecordTypeIdByDev('Programme_Version__c', ApplyServices.RT_VERSION_PV_DEVNAME),
            Master_Link__c = masterProgramme.Id,
            Name = prog.Name, Version_Suffix__c = prog.Instance_Suffix__c, Start_Date__c = prog.Start_Date__c, End_Date__c = prog.End_Date__c,
            Active__c = prog.Active__c, Programme_Type__c = progVersion.Programme_Type__c,
            Mode__c = progVersion.Mode__c, Code__c = progVersion.Code__c, Programme_Group__c = progVersion.Programme_Group__c
        );
        insert versionProgramme;
        
        programme = new Programme__c(
            Programme_Version__c = versionProgramme.Id,
            Name = prog.Name, Instance_Suffix__c = prog.Instance_Suffix__c, Start_Date__c = prog.Start_Date__c, End_Date__c = prog.End_Date__c,
            Active__c = prog.Active__c, Home_EU_Fee__c = prog.Home_EU_Fee__c, Overseas_Fee__c = prog.Overseas_Fee__c, Capacity__c = prog.Capacity__c
        );
        insert programme;
    }
    
    /**
     * Create module and versions
     */
    private void buildModules() {
        if ( progModule.Module__c != null ) {
            // use existing Module Reference
            module = [
                SELECT Id, Module_Version__r.Id, Module_Version__r.Master_Link__r.Id
                FROM Module__c
                WHERE Id = :progModule.Module__c
            ];
            versionModule = module.Module_Version__r;
            masterModule = versionModule.Master_Link__r;
        } else {
            // create new module and version
            masterModule = new Module_Version__c(
                RecordTypeId = CommonUtils.findRecordTypeIdByDev('Module_Version__c', ApplyServices.RT_MASTER_MV_DEVNAME),
                Name = prog.Name, Active__c = prog.Active__c
            );
            insert masterModule;
            
            versionModule = new Module_Version__c(
                RecordTypeId = CommonUtils.findRecordTypeIdByDev('Module_Version__c', ApplyServices.RT_VERSION_MV_DEVNAME),
                Master_Link__c = masterModule.Id,
                Name = prog.Name, Version_Suffix__c = prog.Instance_Suffix__c, Start_Date__c = prog.Start_Date__c, End_Date__c = prog.End_Date__c,
                Active__c = prog.Active__c
            );
            insert versionModule;
            
            module = new Module__c(
                Module_Version__c = versionModule.Id,
                Name = prog.Name, Instance_Suffix__c = prog.Instance_Suffix__c, // FIXME Start_Date__c = prog.Start_Date__c, End_Date__c = prog.End_Date__c,
                Active__c = prog.Active__c
            );
            insert module;
        }
    }
    
    /**
     * Create junction records between programme and module and related versions
     */
    private void buildJunctionRecords() {
        // join module version with programme version (RT Versions)
        pmv = new Programme_Module_Version__c(
            Programme_Version__c = versionProgramme.Id, Module_Version__c = versionModule.Id
        );
        insert pmv;
        
        // join module with programme
        pm = new Programme_Module__c(
            Programme__c = programme.Id, Module__c = module.Id
        );
        insert pm;
    }
    
    /**
     * Action for quick create set of records
     */
    public PageReference create() {
        // return link to just created programme
        buildProgrammes();
        buildModules();
        buildJunctionRecords();
        
        PageReference pr = new ApexPages.StandardController(programme).view();
        pr.setRedirect(true);
        return pr;
    }

}