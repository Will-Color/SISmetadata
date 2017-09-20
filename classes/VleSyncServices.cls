/**
 * Service to deal with synchronization to VLE
 * Note: Use 'without sharing' to perform all operation in system mode
 */
public without sharing class VleSyncServices {
    
    // List of ActionStructure waiting for insert
    @TestVisible
    private static final List<ActionStructure> itemsToSync = new List<ActionStructure>();
    
    // Maximum number of delayed records that could be added to batch at one time  
    private static final Integer PREPARED_ACTIONS_SIZE_LIMIT = 500;
    
    /**
     * Indicator to try run batch job only once at execution context
     */
    @TestVisible
    private static Boolean firstTryToRunBatch = true;
    
    // Set of unique actions (action name + id)
    private static final Set<String> uniqActions = new Set<String>();

    // Action names
    public static final String DUMMY_ACTION =                               'dummy'; // note: for test only
    public static final String CREATE_VLE_STUDENT_BY_SP_ACTION =            'create student by SP';
    public static final String CREATE_VLE_STAFF_ACTION =                    'create staff';
    public static final String VLE_STAFF_ROLE_ACTION =                      'staff role';
    public static final String MAKE_VLE_USER_INACTIVE_ACTION =              'make user inactive';
    public static final String SET_STUDENT_INACTIVE_BY_SP_ACTION =          'set student inactive by SP';
    public static final String CREATE_VLE_COURSE_ACTION =                   'create course offering';
    public static final String UPDATE_VLE_COURSE_ACTION =                   'update course offering';
    public static final String CREATE_VLE_STUDENT_WITH_ROLE_BY_SP_ACTION =  'create student with role by SP';
    /*
    //TODO temp
    public static Set<Id> defaultModulesIds = new Set<Id>{
        VleServices.credentials.Programme_Page_Module_Id__c, 
        VleServices.credentials.Student_Community_Site_Module_ID__c, 
        VleServices.credentials.Study_Skills_Module_ID__c
    };  */  
    
    // Map with equivalent of action name and action implementation class name 
    public static final Map<String,String> actionMap = new Map<String,String> {
        DUMMY_ACTION => 'VleBaseAction.DummyAction',
        CREATE_VLE_STUDENT_BY_SP_ACTION => 'VleCreateStudentBySpAction',
        CREATE_VLE_STAFF_ACTION => 'VleCreateStaffAction',
        VLE_STAFF_ROLE_ACTION => 'VleStaffRoleAction',
        MAKE_VLE_USER_INACTIVE_ACTION => 'VleMakeUserInactiveAction',
        SET_STUDENT_INACTIVE_BY_SP_ACTION => 'VleSetStudentInactiveBySpAction',
        CREATE_VLE_COURSE_ACTION => 'VleCreateModuleAction',
        UPDATE_VLE_COURSE_ACTION => 'VleUpdateModuleAction',
        CREATE_VLE_STUDENT_WITH_ROLE_BY_SP_ACTION => 'VleCreateStudentWithRoleBySpAction'
    };
    
    // Command names
    public static final String DUMMY_COMMAND =              'dummy'; // note: for test only
    public static final String CREATE_USER_COMMAND =        'create user';
    public static final String CREATE_ENROLL_COMMAND =      'create enrollment';
    public static final String WAIT_VLE_ID_COMMAND =        'wait for VLE ID';
    public static final String UPDATE_ACTIVATION_COMMAND =  'update user activation';
    public static final String DELETE_ENROLL_COMMAND =      'delete enrollment';
    public static final String CREATE_MUDULE_COMMAND =      'create module/course';    
    public static final String UPDATE_MUDULE_COMMAND =      'update module/course';    
    
    // Action statuses
    public static final String ACTION_NEW_STATUS =      'New';
    public static final String ACTION_BATCH_STATUS =    'Batch';
    public static final String ACTION_DELAYED_STATUS =  'Delayed';
    public static final String ACTION_DONE_STATUS =     'Done';
    public static final String ACTION_CANCELED_STATUS = 'Canceled';
    
    // Command statuses
    public static final String COMMAND_NEW_STATUS =     'New';
    public static final String COMMAND_ERROR_STATUS =   'Error';
    public static final String COMMAND_DONE_STATUS =    'Done';
    
    // Valid Obj_Type__c constants
    public static final String OBJ_TYPE_CONTACT =           'Contact';
    public static final String OBJ_TYPE_STUDENT_PROGRAMME = 'Student_Programme__c';
    public static final String OBJ_TYPE_MODULE_ROLE =       'Module_Role__c';
    public static final String OBJ_TYPE_MODULE =            'Module__c';
    
    // Time constants
    //** Suyati Modified Start 16-02-2016
    public static final String EXPIRY_DAYS_FOR_OLD_ACTIONS = 'Expiry Days for Old Vle Action';
    //public static final Integer EXPIRY_DAYS_FOR_OLD_ACTIONS = 3;
    //** Suyati Modified End
    public static final Integer MINUTES_FOR_REPEAT_DELAYED = 30; // add this time to now() for 'delayed' actions
    
    /**
     * Structure class for holding all info about VLE action and commands   
     */
    public class ActionStructure {
        private List<VLE_Sync_Command__c> detailCommands = new List<VLE_Sync_Command__c>(); 
        public VLE_Action__c masterAction { get; set; }
        public List<VLE_Sync_Command__c> getDetailCommands() {
            return detailCommands;
        }
    }
    
    /**
     * Interface for class that implements VLE action
     */
    public interface IAction {
        /**
         * Create action and command object to persist in DB
         * @return Structure with action and commands ready to insert into DB or null
         */
        ActionStructure create();
        
        /**
         * Try to synchronize action
         * @param action Action with details (commands)
         */
        void perform(VLE_Action__c action);
    }
    
    public class ParseResult {
        public Boolean result { get; set; }
        public List<sObject> updatedRecords = new List<sObject>();
    }
    
    /**
     * Interface for class that implements VLE command
     */
    public interface ICommand {
        /**
         * Prepare command data
         * @param cmd Record of command
         */
        void init(VLE_Sync_Command__c cmd);
        
        /**
         * Perform HTTP(s) callout
         * @param userContext UserContext of API call
         * @return HttpResponse object or exception
         */
        HttpResponse makeCallout(VleServices.IUserContext userContext);
        /**
         * Try to get useful information from VleServices.RESULT_OKAY response
         * @param HttpResponse Response of API
         * @return Structure with result and list of updated records
         */
        ParseResult parseResultOk(HttpResponse resp);
    }
    
    /**
     * Indicates state of batch (true - running, false - not)
     */
    public static Boolean isBatchRunning {
        get {
            if ( isBatchRunning == null ) {
                // get from Custom Settings, true by default
                VLE__c vle = VLE__c.getInstance(VleServices.CS_NAME);
                isBatchRunning = ( vle == null ) ? true : vle.BatchIsRunning__c;
            }
            return isBatchRunning;
        }
        set {
            isBatchRunning = value;
            VLE__c vle = VLE__c.getInstance(VleServices.CS_NAME);
            if ( vle != null ) {
                update new VLE__c(Id = vle.Id, BatchIsRunning__c = value);
            }
        }
    }
    
    /**
     * Create certain action related to the object
     * @param name Action's name
     * @param recordId Id of record
     * @param status of 
     * @return Action instance
     */
    public static VLE_Action__c createAction(String name, Id recordId, String status) {
        return new VLE_Action__c(Name = recordId, Action__c = name, Status__c = status);
    }
    
    /**
     * Create command object
     * @param name Name of command
     * @param recordId Id of record related to command
     * @param orderNumber Order indicator
     * @param objType Name of related object
     * @params params JSON string with parameters
     * @return Command instance
     */
    public static VLE_Sync_Command__c createCommand(String name, String recordId, Integer orderNumber, String objType, String params) {
        return new VLE_Sync_Command__c(
            Name = recordId, Command__c = name, Obj_Type__c = objType,
            Order__c = orderNumber, Params__c = params, Status__c = COMMAND_NEW_STATUS
        );
    }
    
    /**
     * Return VLE_Action__c with related commands
     * @param actionId Id of action
     * @return Action with related commands or null 
     */
    public static VLE_Action__c findActionWithCommands(Id actionId) {
        List<VLE_Action__c> actions = [
            SELECT Action__c, Name, Next_Try__c, Note__c, Status__c,
                ( SELECT Command__c, Error_Count__c, Last_Error_Message__c, Name,
                    Obj_Type__c, Order__c, Params__c, Status__c, VLE_Action__c
                  FROM VLE_Sync_Commands__r
                   ORDER BY Order__c
                )
            FROM VLE_Action__c
            WHERE Id = :actionId
        ];
        System.debug('actions ='+actions);
        return ( actions.isEmpty() ) ? null : actions[0]; 
    }
    
    /**
     * Create a action with commands and add to queue.
     * Only unique action+id will be added
     * @param action Instance of action 
     */
    public static void addToQueue(IAction action, String actionName, Id relatedId) {
        String mapKey = actionName + relatedId;
        if ( !uniqActions.contains(mapKey) ) {
            uniqActions.add(mapKey);
            ActionStructure aStruct = action.create();
            if ( aStruct != null ) {
                itemsToSync.add(aStruct);
            }
        }
    }
    
    /**
     * Add items from queue to the database and clear queue.
     * First with new (future) status, other with 'delayed'
     * @return Queue that has been cleared 
     */
    public static List<ActionStructure> persistQueue() {
        // mark as batch over future limits
        Integer numberOfFutureCalls = Limits.getLimitFutureCalls() - Limits.getFutureCalls();
        if ( numberOfFutureCalls < itemsToSync.size() ) {
            for (Integer i = numberOfFutureCalls; i < itemsToSync.size(); i++) {
                itemsToSync[i].masterAction.Status__c = ACTION_BATCH_STATUS;
            }
        }
        System.debug('>>> here 2 >>>');
        // insert actions
        List<VLE_Action__c> actionList = new List<VLE_Action__c>();
        for (ActionStructure aStruct: itemsToSync) {
            actionList.add(aStruct.masterAction);
        }
        insert actionList;
        
        // insert commands
        List<VLE_Sync_Command__c> commandList = new List<VLE_Sync_Command__c>(); 
        for (Integer i = 0; i < actionList.size(); i++) {
            ActionStructure aStruct = itemsToSync[i];
            for (VLE_Sync_Command__c syncCommand: aStruct.getDetailCommands()) {
                syncCommand.VLE_Action__c = aStruct.masterAction.Id;
                commandList.add(syncCommand);
            }
        }
        insert commandList;
        
        System.debug('>>> actionList >>>' + actionList);
        // perform future calls
        for (VLE_Action__c actionItem: actionList) {
            if ( actionItem.Status__c == ACTION_NEW_STATUS ) {
                System.debug(LoggingLevel.ERROR, '@@@ Running future action: ' + actionItem.Action__c);
                syncActionFuture(actionItem.Id);
            }
        }
        System.debug('>>> here 3 >>>');
        // clear queue and return previous state
        List<ActionStructure> prevList = new List<ActionStructure>(itemsToSync);
        itemsToSync.clear();
        return prevList;
    }
    
    /**
     * Do action by ID as future call
     * @param vleActionId Id of action
     */
    @Future(callout=true)
    public static void syncActionFuture(Id vleActionId) {
        syncActionBatch(vleActionId);
    }
    
    /**
     * Do action by ID
     * @param vleActionId Id of action
     */
    public static void syncActionBatch(Id vleActionId) {
        VLE_Action__c action = findActionWithCommands(vleActionId);
        if ( action != null ) {
            String actionClassName = actionMap.get(action.Action__c);
            if ( actionClassName != null ) {
                // create instance of class that implements action
                Type instanceType = Type.forName(actionClassName);
                IAction actionImpl = (IAction) instanceType.newInstance();
                actionImpl.perform(action);
            }
        }
    }
    
    /**
     * Try to find actions for Batch
     * @return True if some delayed actions were found
     */
    public static Boolean prepareActionsForSync() {
        List<VLE_Action__c> delayedActions = [
            SELECT Id
            FROM VLE_Action__c
            WHERE Next_Try__c < :Datetime.now()
            AND Status__c = :ACTION_DELAYED_STATUS
            ORDER BY LastModifiedDate
            LIMIT :PREPARED_ACTIONS_SIZE_LIMIT
        ];
        
        if ( !delayedActions.isEmpty() ) {
            // ready for batch
            for (VLE_Action__c action: delayedActions) {
                action.Status__c = ACTION_BATCH_STATUS;
            }
            update delayedActions;
            return true;
        }
        
        return false;
    }
    
    /**
     * Looking for actions with status 'Batch'
     * @param True if even one action was found
     */
    public static Boolean isAnyActionsReadyForSync() {
        List<VLE_Action__c> actionList = [SELECT Id FROM VLE_Action__c WHERE Status__c = :ACTION_BATCH_STATUS LIMIT 1];
        return !actionList.isEmpty();
    }
    
    /**
     * Run Batch for synchronization if:
     * there is actions to sync and running of batch is allowed 
     * @return True of batch was added to queue
     */
    public static Boolean runSyncBatch() {
        if ( !isBatchRunning ) {
            // check for available actions
            if ( isAnyActionsReadyForSync() ) {
                isBatchRunning = true;
                Database.executeBatch(new VleSyncBatch(), 1);
                return true;
            }
        }
        return false;
    }
    
    /**
     * Delete from DB old synchronized actions.
     * @param expiryDateTime Records earlier than LastModifiedDate should be deleted
     */
    public static void removeOldSyncActions(Datetime expiryDateTime) {
        Set<String> removeStatuses = new Set<String> {ACTION_DONE_STATUS, ACTION_CANCELED_STATUS };
        List<VLE_Action__c> oldActions = [SELECT Id FROM VLE_Action__c WHERE LastModifiedDate < :expiryDateTime AND Status__c IN :removeStatuses];
        delete oldActions;
    }
    
    /**
     * This method is called only one at execution context.
     * It try to initiate all services like run batch job, find actions for batch and clean up old actions
     */
    public static void runAsyncServices() {
        if ( firstTryToRunBatch ) {
            firstTryToRunBatch = false;
            // clean up some old records
            //** Suyati Modified  Start 16-02-2016
            Expiry_Days_For_Old_Vle_Actions__c expiryDaysForOldVleAction = Expiry_Days_For_Old_Vle_Actions__c.getInstance(EXPIRY_DAYS_FOR_OLD_ACTIONS);
            if(expiryDaysForOldVleAction != null){
                integer expiryDays = (integer)expiryDaysForOldVleAction.Expiry_Days__c;
                System.debug('expiryDays ='+expiryDays);
                Datetime expDt = Date.today().addDays(-expiryDays);
                System.debug('expDt = '+expDt);          
                removeOldSyncActions(expDt);
            }
            //***Suyati Modified End
            //** Suyati Modified Start 15-02-2016
            // find delayed actions
            //prepareActionsForSync();
            // call batch job
            //runSyncBatch();
            //** Suyati Modified End
        }
    }

}