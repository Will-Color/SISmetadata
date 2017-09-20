/**
 * Action that makes user inactive
 */
public with sharing class VleMakeUserInactiveAction extends VleBaseAction {
	
	/**
	 * Student of Staff person
	 */
	public Contact person { get; set; }
	
	@TestVisible
	protected override Boolean findActionData(VLE_Action__c action) {
		person = VleDaoServices.findContact(action.Name);
        return person != null;
    }
    
    @TestVisible
    protected override VleSyncServices.ICommand findCommand(VLE_Sync_Command__c cmd) {
        VleSyncServices.ICommand cmdImpl;

        if ( cmd.Command__c == VleSyncServices.WAIT_VLE_ID_COMMAND ) {
        	VleCommands.WaitForVleId waitCmd = new VleCommands.WaitForVleId();
	        waitCmd.objName = VleSyncServices.OBJ_TYPE_CONTACT;
	        waitCmd.recordId = person.Id;
	        cmdImpl = waitCmd;
        } else if ( cmd.Command__c == VleSyncServices.UPDATE_ACTIVATION_COMMAND ) {
        	VleCommands.UpdateUserActivation inactiveCmd = new VleCommands.UpdateUserActivation();
        	inactiveCmd.person = person;
        	cmdImpl = inactiveCmd;
        }

        return cmdImpl;
    }
    
    public VleSyncServices.ActionStructure create() {
        VleSyncServices.ActionStructure aStruct = new VleSyncServices.ActionStructure();
        aStruct.masterAction = VleSyncServices.createAction(
            VleSyncServices.MAKE_VLE_USER_INACTIVE_ACTION, person.Id, VleSyncServices.ACTION_NEW_STATUS
        );
        
        // check VLE_ID__c field on Contact
        Vle_Sync_Command__c cmd = VleSyncServices.createCommand(
            VleSyncServices.WAIT_VLE_ID_COMMAND, person.Id, 1,
            VleSyncServices.OBJ_TYPE_CONTACT, null
        );
        aStruct.getDetailCommands().add(cmd);
        
        // add command to set user inactive
        VleStructures.UserActivationData actData = new VleStructures.UserActivationData();
        actData.IsActive = false;
        cmd = VleSyncServices.createCommand(
            VleSyncServices.UPDATE_ACTIVATION_COMMAND, person.Id, 2,
            VleSyncServices.OBJ_TYPE_CONTACT, JSON.serialize(actData)
        );
        aStruct.getDetailCommands().add(cmd);
        
        
        return aStruct;         
    }
    
}