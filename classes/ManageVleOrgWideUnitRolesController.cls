public class ManageVleOrgWideUnitRolesController {

    public ManageVleOrgWideUnitRolesController(){
        isValid = false;
        
        try{
            initAndValidate();
        } catch (Exception e){
            ApexPages.addMessage( new ApexPages.message( ApexPages.severity.INFO, e.getMessage() ) );
            return;
        }
        isValid = true;
    }
    
    public Boolean isValid {get;set;}
    
    public List<SelectOption> studentRoles { get; set; }
    public List<SelectOption> staffRoles { get; set; }

    public List<SelectOption> moduleRoles { get; set; }
    public List<SelectOption> programTypes { get; set; }

    public List<VLE_Program_Type_2_Role_VLE_ID_Mapping__c> studentProgramType2VleRoleId {get; set;}
    public List<VLE_Staff_Module_Roles_And_Vle_Role_Ids__c> staffModuleRole2VleRoleId {get; set;}   
    public List<VLE_Org_Wide_Units_And_Role_Assignments__c> staffOrgUnitsParameters {get; set;}
    
    public Vle__c vleParameters {get;set;}

    public PageReference saveMappings(){

        try {
        
            Set<String> duplicates = new Set<String>();
            for ( VLE_Program_Type_2_Role_VLE_ID_Mapping__c prop : studentProgramType2VleRoleId ){
                prop.Name = prop.Programme_Type__c;
                if (! duplicates.add( prop.Programme_Type__c ) ) {
                    ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, 'Duplicate Programme Type' ) );
                    return null;
                }
            }
            upsert studentProgramType2VleRoleId;
            
            duplicates  = new Set<String>();
            for ( VLE_Staff_Module_Roles_And_Vle_Role_Ids__c prop : staffModuleRole2VleRoleId ){
                prop.Name = prop.Module_Role__c;
                if (! duplicates.add( prop.Module_Role__c) ) {
                    ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, 'Duplicate Module Role' ) );
                    return null;
                }                
            }            
            upsert staffModuleRole2VleRoleId;

            upsert staffOrgUnitsParameters;
            
            update vleParameters;

        } catch ( Exception e ){
            ApexPages.addMessage( new ApexPages.message( ApexPages.severity.INFO, 'Something went wrong while saving ... ' + e.getMessage() ) );
            return null;
        }
        
        ApexPages.addMessage( new ApexPages.message( ApexPages.severity.CONFIRM, 'Saved succesfully' ) );
        return null;
    }

    public PageReference cancel(){
        return Page.VleAdmin;
    }

    public String objName {get;set;}
    public void addRecord( ){
        if ( objName == 'VLE_Program_Type_2_Role_VLE_ID_Mapping__c' ){
            studentProgramType2VleRoleId.add( new VLE_Program_Type_2_Role_VLE_ID_Mapping__c() );
        
        } else  if ( objName == 'VLE_Staff_Module_Roles_And_Vle_Role_Ids__c' ){
            staffModuleRole2VleRoleId.add( new VLE_Staff_Module_Roles_And_Vle_Role_Ids__c() );
        
        } else if ( objName == 'VLE_Org_Wide_Units_And_Role_Assignments__c' ){
            staffOrgUnitsParameters.add( new VLE_Org_Wide_Units_And_Role_Assignments__c() );
        }
    }

    public Integer indexToDelete {get;set;}
    
    public void deleteRowStaff(){
        VLE_Staff_Module_Roles_And_Vle_Role_Ids__c param = staffModuleRole2VleRoleId.get( indexToDelete  );
        if ( param.Id != null ){
            delete param;
        }
        staffModuleRole2VleRoleId.remove( indexToDelete   );
    }

    public void deleteRowStudent(){
        VLE_Program_Type_2_Role_VLE_ID_Mapping__c param = studentProgramType2VleRoleId.get( indexToDelete  );
        if ( param.Id != null ){
            delete param;
        }
        studentProgramType2VleRoleId.remove( indexToDelete   );
    }

    private void initAndValidate(){

        //INIT STUDENT ROLES
        studentRoles = new List<SelectOption>();
        for ( VLE_Roles__c role : VLE_Roles__c.getAll().values() ) {
            if ( role.Available_for_Student__c && role.Vle_Role_Id__c != null ){
                studentRoles.add( new SelectOption( role.Vle_Role_Id__c, role.Name + ' (' + role.Vle_Role_Id__c + ')' ) );
            }
        }
        if ( studentRoles.isEmpty() ){
            ApexPages.addMessage( new ApexPages.message( ApexPages.severity.INFO, ' Student Roles are not setup. Please go to Setup => Custom Settings => "VLE Roles"' ) );
        }

        //INIT STAFF ROLES SETTINTS
        staffRoles = new List<SelectOption>();
        for ( VLE_Roles__c role : VLE_Roles__c.getAll().values() ) {
            if ( role.Available_for_Staff__c && role.Vle_Role_Id__c != null ){
                staffRoles.add( new SelectOption( role.Vle_Role_Id__c, role.Name + ' (' + role.Vle_Role_Id__c + ')'  ) );
            }
        }
        if ( staffRoles.isEmpty() ){
            ApexPages.addMessage( new ApexPages.message( ApexPages.severity.INFO, ' Staff Roles are not setup. Please go to Setup => Custom Settings => "VLE Roles"' ) );
        }

        //INIT MODULE ROLES PICKLIST VALUES
        moduleRoles = new List<SelectOption>();
        for ( String picklistValue : getPicklistValues( Module_Role__c.Module_Role__c ) ){
            moduleRoles.add( new SelectOption( picklistValue, picklistValue ) );
        }

        //INIT PROGRAM TYPES PICKLIST VALUES
        programTypes = new List<SelectOption>();
        for ( String picklistValue : getPicklistValues( Programme_Version__c.Programme_Type__c ) ){
            programTypes.add( new SelectOption( picklistValue, picklistValue ) );
        }   
    
        //INIT SETTINGS FOR MAPPINGS
        studentProgramType2VleRoleId = VLE_Program_Type_2_Role_VLE_ID_Mapping__c.getAll().values();
        staffModuleRole2VleRoleId = VLE_Staff_Module_Roles_And_Vle_Role_Ids__c.getAll().values();
        
        staffOrgUnitsParameters = new List<VLE_Org_Wide_Units_And_Role_Assignments__c>();
        for ( VLE_Org_Wide_Units_And_Role_Assignments__c orgUnitParam : VLE_Org_Wide_Units_And_Role_Assignments__c.getAll().values() ){
            if ( orgUnitParam.Available_for_Staff__c ){
                staffOrgUnitsParameters.add( orgUnitParam );
            }
        }
        
        //INIT VLE PARAMETERS SETTINGS  
        vleParameters = Vle__c.getInstance(VleServices.CS_NAME);
        if ( vleParameters == null ){
            ApexPages.addMessage( new ApexPages.message( ApexPages.severity.INFO, 'Vle Parameters are not setup. Please go to Setup => Custom Settings => "VLE parameters". Create record with name "main"' ) );
            return;
        }        
        
    }

    private static List<String> getPicklistValues(Schema.sObjectField picklistFieldToken) {
        List<String> values = new List<String>();
        List<Schema.PicklistEntry> plEntries = picklistFieldToken.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry item: plEntries) {
            values.add(item.getValue());
        }
        return values;
    }

}