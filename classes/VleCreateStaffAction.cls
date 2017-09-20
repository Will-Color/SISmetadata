/**
 * Action for creating new staff VLE user.
 * Run when Contact.VLE_Visibility__c becomes true
 */
public with sharing class VleCreateStaffAction extends VleBaseAction {
    
    /**
     * Staff person for creating in VLE 
     */
    public Contact staff { get; set; }   
    

    @TestVisible
    protected override Boolean findActionData(VLE_Action__c action) {
        staff = VleDaoServices.findStaffModuleRoles(action.Name);
        return staff != null;
    }
    
    @TestVisible
    protected override VleSyncServices.ICommand findCommand(VLE_Sync_Command__c cmd) {
        VleSyncServices.ICommand cmdImpl;
        if ( cmd.Command__c == VleSyncServices.CREATE_USER_COMMAND ) {
            VleCommands.CreateUser createUserCmd = new VleCommands.CreateUser();
            createUserCmd.person = staff;
            createUserCmd.roleId = Long.valueOf(VleServices.credentials.Default_Staff_Role_VLE_ID__c);
            createUserCmd.sendEmail = VleServices.credentials.Email_To_Staff__c;
            cmdImpl = createUserCmd;
        } else if ( cmd.Command__c == VleSyncServices.CREATE_ENROLL_COMMAND ) {

            if ( cmd.Name == 'DEFAULT_MODULE' ){

                if ( cmd.Params__c != null ){
                    VleCommands.EnrollmentParams enrParams = (VleCommands.EnrollmentParams) JSON.deserialize(cmd.Params__c, VleCommands.EnrollmentParams.class);                    
                    VleCommands.CreateEnrollment enrollCmd = new VleCommands.CreateEnrollment();
                    enrollCmd.cont = staff;
                    enrollCmd.orgUnitId = enrParams.orgUnitId;
                    enrollCmd.roleId = enrParams.roleId;
                    cmdImpl = enrollCmd;
                }

            } else {
                Map<Id,Module_Role__c> moduleRoleMap = new Map<Id,Module_Role__c>(staff.Module_Roles__r); 
                Module_Role__c moduleRole = moduleRoleMap.get(cmd.Name);
                if ( moduleRole != null ) {
                    VleCommands.CreateEnrollment enrollCmd = new VleCommands.CreateEnrollment();
                    enrollCmd.cont = staff;
                    enrollCmd.orgUnitId = Long.valueOf(moduleRole.Module__r.VLE_ID__c);
                    cmdImpl = enrollCmd;
                }
            }
        }
        return cmdImpl;
    }
    

    public VleSyncServices.ActionStructure create() {
        VleSyncServices.ActionStructure aStruct = new VleSyncServices.ActionStructure();
        aStruct.masterAction = VleSyncServices.createAction(
            VleSyncServices.CREATE_VLE_STAFF_ACTION, staff.Id, VleSyncServices.ACTION_NEW_STATUS
        );
        
        if ( String.isEmpty(staff.VLE_ID__c) ) {
            // create user command
            Vle_Sync_Command__c cmd = VleSyncServices.createCommand(
                VleSyncServices.CREATE_USER_COMMAND, staff.Id, 1, VleSyncServices.OBJ_TYPE_CONTACT, null
            );
            aStruct.getDetailCommands().add(cmd);
        }
        
        // enroll all module roles
        if ( staff.Module_Roles__r != null ) {
            for (Module_Role__c mr: staff.Module_Roles__r) {
                
                List<Long> roleIds = VleServices.staffRoles.get(mr.Module_Role__c) != null 
                    ? VleServices.staffRoles.get(mr.Module_Role__c) 
                    : new List<Long> { Long.valueOf( VleServices.credentials.Default_Staff_Role_VLE_ID__c ) };

                if ( roleIds != null ) {
                    for (Long roleId: roleIds) {
                        VleCommands.EnrollmentParams enrParams = new VleCommands.EnrollmentParams();
                        enrParams.roleId = roleId;
                        Vle_Sync_Command__c cmd = VleSyncServices.createCommand(
                            VleSyncServices.CREATE_ENROLL_COMMAND, mr.Id, aStruct.getDetailCommands().size()+1,
                            VleSyncServices.OBJ_TYPE_MODULE_ROLE, JSON.serialize(enrParams)
                        );
                        aStruct.getDetailCommands().add(cmd);
                    }
                }
            }
        }

        //ENROLE TO ORG-WIDE MODULES
        if ( ! VleServices.staffOrgUnitId2RoleVleId.isEmpty() ) {
            for ( String orgUnitId : VleServices.staffOrgUnitId2RoleVleId.keySet() ) {
               
                List<Long> vleRoleIds = VleServices.staffOrgUnitId2RoleVleId.get( orgUnitId ) != null 
                    ? VleServices.staffOrgUnitId2RoleVleId.get( orgUnitId ) 
                    : new List<Long> { Long.valueOf( VleServices.credentials.Default_Staff_Role_VLE_ID__c ) };

                for ( Long roleId : vleRoleIds ){

                    VleCommands.EnrollmentParams enrParams = new VleCommands.EnrollmentParams();
                    enrParams.roleId = roleId;
                    enrParams.orgUnitId = Long.valueOf( orgUnitId );

                    Vle_Sync_Command__c cmd = VleSyncServices.createCommand(
                        VleSyncServices.CREATE_ENROLL_COMMAND, 'DEFAULT_MODULE', aStruct.getDetailCommands().size()+1,
                        VleSyncServices.OBJ_TYPE_MODULE_ROLE, JSON.serialize(enrParams)
                    );
                    aStruct.getDetailCommands().add(cmd);
                }
            }
        }    

        if ( aStruct.getDetailCommands().isEmpty() ) {
            return null;
        } else {
            return aStruct;         
        }
    }
    
}