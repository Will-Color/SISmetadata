/**
 * Complex action to modify enrollments accordingly to changes in Module_Role__c object
 */
public with sharing class VleStaffRoleAction extends VleBaseAction {
    
    // Action types
    public static final String INSERT_ACTION_TYPE = 'insert';
    public static final String UPDATE_ACTION_TYPE = 'update';
    public static final String DELETE_ACTION_TYPE = 'delete'; 

    /**
     * Module_Role__c object related to the action
     */
    public Module_Role__c moduleRole { get; set; }
    
    /**
     * Type of action
     */
    public String actionType { get; set; }
    
    /**
     * Add command of creating new enrollments to current ActionStructure
     * @param aStruct Structure of action
     */
    private void addCreateEnrollCommand(VleSyncServices.ActionStructure aStruct) {
        List<Long> roleIds = VleServices.staffRoles.get(moduleRole.Module_Role__c) != null 
            ? VleServices.staffRoles.get(moduleRole.Module_Role__c) 
            : new List<Long> { Long.valueOf( VleServices.credentials.Default_Staff_Role_VLE_ID__c ) };
            
        if ( roleIds != null ) {
            for (Long roleId: roleIds) {
                VleCommands.EnrollmentParams enrParams = new VleCommands.EnrollmentParams();
                enrParams.roleId = roleId;
                Vle_Sync_Command__c cmd = VleSyncServices.createCommand(
                    VleSyncServices.CREATE_ENROLL_COMMAND, moduleRole.Id, aStruct.getDetailCommands().size()+1,
                    VleSyncServices.OBJ_TYPE_MODULE_ROLE, JSON.serialize(enrParams)
                );
                aStruct.getDetailCommands().add(cmd);
            }
        }
    }
    
    /**
     * Add command of deleting enrollments to current ActionStructure
     * @param aStruct Structure of action
     */
    private void addDeleteEnrollCommand(VleSyncServices.ActionStructure aStruct) {
        VleCommands.EnrollmentParams enrParams = new VleCommands.EnrollmentParams();
        enrParams.userSourceId = moduleRole.Staff__c;
        Vle_Sync_Command__c cmd = VleSyncServices.createCommand(
            VleSyncServices.DELETE_ENROLL_COMMAND, moduleRole.Module__c, aStruct.getDetailCommands().size()+1,
            VleSyncServices.OBJ_TYPE_MODULE, JSON.serialize(enrParams)
        );
        aStruct.getDetailCommands().add(cmd);
    }
    
    @TestVisible
    protected override Boolean findActionData(VLE_Action__c action) {
        moduleRole = VleDaoServices.findModuleRoleData(action.Name);
        return moduleRole != null;
    }
    
    @TestVisible
    protected override VleSyncServices.ICommand findCommand(VLE_Sync_Command__c cmd) {
        VleSyncServices.ICommand cmdImpl;

        if ( cmd.Command__c == VleSyncServices.WAIT_VLE_ID_COMMAND ) {
            VleCommands.WaitForVleId waitCmd = new VleCommands.WaitForVleId();
            waitCmd.objName = VleSyncServices.OBJ_TYPE_CONTACT;
            waitCmd.recordId = cmd.Name; // ID of contact
            cmdImpl = waitCmd;
        } else if ( cmd.Command__c == VleSyncServices.CREATE_ENROLL_COMMAND && moduleRole != null ) {
            VleCommands.CreateEnrollment enrollCmd = new VleCommands.CreateEnrollment();
            enrollCmd.cont = moduleRole.Staff__r;
            enrollCmd.orgUnitId = ( String.isBlank(moduleRole.Module__r.VLE_ID__c) ) ? null : Long.valueOf(moduleRole.Module__r.VLE_ID__c);
            cmdImpl = enrollCmd;
        } else if ( cmd.Command__c == VleSyncServices.DELETE_ENROLL_COMMAND ) {
            VleCommands.DeleteEnrollment enrollCmd = new VleCommands.DeleteEnrollment();
            Module__c module = VleDaoServices.findProgrammeModules(new Set<Id>{ cmd.Name })[0];
            enrollCmd.orgUnitId = module.VLE_ID__c;
            VleCommands.EnrollmentParams enrParams = (VleCommands.EnrollmentParams) JSON.deserialize(cmd.Params__c, VleCommands.EnrollmentParams.class);
            enrollCmd.cont = VleDaoServices.findContact(enrParams.userSourceId);
            cmdImpl = enrollCmd;
        }

        return cmdImpl;
    }
    
    public VleSyncServices.ActionStructure create() {
        VleSyncServices.ActionStructure aStruct = new VleSyncServices.ActionStructure();
        aStruct.masterAction = VleSyncServices.createAction(
            VleSyncServices.VLE_STAFF_ROLE_ACTION, moduleRole.Id, VleSyncServices.ACTION_NEW_STATUS
        );
        
        // check VLE_ID__c field on Contact
        Vle_Sync_Command__c cmd = VleSyncServices.createCommand(
            VleSyncServices.WAIT_VLE_ID_COMMAND, moduleRole.Staff__c, 1,
            VleSyncServices.OBJ_TYPE_CONTACT, null
        );
        aStruct.getDetailCommands().add(cmd);
        
        // enrollments by type of action
        if ( actionType == INSERT_ACTION_TYPE ) {
            addCreateEnrollCommand(aStruct);
        } else if ( actionType == UPDATE_ACTION_TYPE ) {
            addDeleteEnrollCommand(aStruct);
            addCreateEnrollCommand(aStruct);
        } else if ( actionType == DELETE_ACTION_TYPE ) {
            addDeleteEnrollCommand(aStruct);
        }
        
        return aStruct;         
    }
    
}