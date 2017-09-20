/**
 * Implementation of Action: 'update Module'
 * Description:
 * When module is set to be InActive, deactivate respective Course on VLE
 */
public with sharing class VleUpdateModuleAction extends VleBaseAction {

    /**
     * Module_Role__c object related to the action
     */
    public Module__c module { get; set; }
    

    @TestVisible
    protected override Boolean findActionData(VLE_Action__c action) {
        List<Module__c> modules = [SELECT Id, Name, Active_Date__c, Module_Code__c, Retire_Date__c, Active__c, VLE_ID__c, VLE_Visibility__c FROM Module__c WHERE Id = : action.Name];
        module = (modules.isEmpty()) ? null : modules.get(0);
        return module != null;
    }
    
    @TestVisible
    protected override VleSyncServices.ICommand findCommand(VLE_Sync_Command__c cmd) {
        VleSyncServices.ICommand cmdImpl;

        if (cmd.Command__c == VleSyncServices.UPDATE_MUDULE_COMMAND){
            VleCommands.UpdateVleCourse updCourseCmd = new VleCommands.UpdateVleCourse();
            updCourseCmd.module = module;
            cmdImpl = updCourseCmd;
        }
        return cmdImpl;
    }
    

    public VleSyncServices.ActionStructure create() {
        VleSyncServices.ActionStructure aStruct = new VleSyncServices.ActionStructure();
        aStruct.masterAction = VleSyncServices.createAction(
            VleSyncServices.UPDATE_VLE_COURSE_ACTION, module.Id, VleSyncServices.ACTION_NEW_STATUS
        );

        Vle_Sync_Command__c cmd = VleSyncServices.createCommand(
            VleSyncServices.UPDATE_MUDULE_COMMAND, module.Id, 1,
            VleSyncServices.OBJ_TYPE_MODULE, null
        );
        aStruct.getDetailCommands().add(cmd);        

        return aStruct;         
    }
    
}