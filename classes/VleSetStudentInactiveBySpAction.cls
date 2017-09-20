/**
 * Action for set user to inactive when Stage__c of related Student_Programme__c becomes 'Completed'
 */
public with sharing class VleSetStudentInactiveBySpAction extends VleBaseAction {

    /**
     * Student programme that becomes completed
     */
    public Student_Programme__c sp { get; set; }
    
    @TestVisible
    protected override Boolean findActionData(VLE_Action__c action) {
        sp = VleDaoServices.findStudentProgrammeInfo(action.Name);
        return sp != null;
    }
    
    @TestVisible
    protected override VleSyncServices.ICommand findCommand(VLE_Sync_Command__c cmd) {
        VleSyncServices.ICommand cmdImpl;

        if ( cmd.Command__c == VleSyncServices.UPDATE_ACTIVATION_COMMAND ) {
            VleCommands.UpdateUserActivation inactiveCmd = new VleCommands.UpdateUserActivation();
            inactiveCmd.person = sp.Student__r;
            cmdImpl = inactiveCmd;
        }

        return cmdImpl;
    }
    
    public VleSyncServices.ActionStructure create() {
        if ( String.isBlank(sp.Student__r.VLE_ID__c) ) {
            return null; // with empty VLE_ID - doesn't make sense
        } else {
            VleSyncServices.ActionStructure aStruct = new VleSyncServices.ActionStructure();
            aStruct.masterAction = VleSyncServices.createAction(
                VleSyncServices.SET_STUDENT_INACTIVE_BY_SP_ACTION, sp.Id, VleSyncServices.ACTION_NEW_STATUS
            );
            
            // add command to set user inactive
            VleStructures.UserActivationData actData = new VleStructures.UserActivationData();
            system.debug('actData '+actData );
            actData.IsActive = false;
            Vle_Sync_Command__c cmd = VleSyncServices.createCommand(
                VleSyncServices.UPDATE_ACTIVATION_COMMAND, sp.Student__r.Id, 1,
                VleSyncServices.OBJ_TYPE_CONTACT, JSON.serialize(actData)
            );
            aStruct.getDetailCommands().add(cmd);
            
            return aStruct;         
        }
    }
    
}