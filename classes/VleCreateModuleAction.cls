/**
 * Implementation of Action: 'create Module'
 * Description:
 * When module is set to be Active, create respective Course on VLE
 */
public with sharing class VleCreateModuleAction extends VleBaseAction {

    /**
     * Module_Role__c object related to the action
     */
    public Module__c module { get; set; }
    

    @TestVisible
    protected override Boolean findActionData(VLE_Action__c action) {
        List<Module__c> modules = 
            [SELECT Id, Name, Active_Date__c, Retire_Date__c, Active__c, VLE_ID__c, VLE_Visibility__c, Course_Template_VLE_ID__c, Module_Reference__c,
             		Instance_Suffix__c
             FROM Module__c 
             WHERE Id = : action.Name];
        module = (modules.isEmpty()) ? null : modules.get(0);
        return module != null;
    }
    
    @TestVisible
    protected override VleSyncServices.ICommand findCommand(VLE_Sync_Command__c cmd) {
        VleSyncServices.ICommand cmdImpl;

        if (cmd.Command__c == VleSyncServices.CREATE_MUDULE_COMMAND){
            VleCommands.CreateVleCourse newCourseCmd = new VleCommands.CreateVleCourse();
            newCourseCmd.module = module;
            cmdImpl = newCourseCmd;
        }
        return cmdImpl;
    }
    

    public VleSyncServices.ActionStructure create() {
        VleSyncServices.ActionStructure aStruct = new VleSyncServices.ActionStructure();
        aStruct.masterAction = VleSyncServices.createAction(
            VleSyncServices.CREATE_VLE_COURSE_ACTION, module.Id, VleSyncServices.ACTION_NEW_STATUS
        );
      /*  
        // check VLE_ID__c field on Contact
        Vle_Sync_Command__c cmd = VleSyncServices.createCommand(
            VleSyncServices.WAIT_VLE_ID_COMMAND, module.Id, 1,
            VleSyncServices.OBJ_TYPE_MODULE, null
        );
        aStruct.getDetailCommands().add(cmd);*/

        Vle_Sync_Command__c cmd = VleSyncServices.createCommand(
            VleSyncServices.CREATE_MUDULE_COMMAND, module.Id, 2,
            VleSyncServices.OBJ_TYPE_MODULE, null
        );
        aStruct.getDetailCommands().add(cmd);        

        return aStruct;         
    }
    
}