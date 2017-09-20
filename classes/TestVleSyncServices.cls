/**
 * Unit test for VleSyncServices and VleBaseAction classes
 */
@isTest
private class TestVleSyncServices {

    static List<Contact> contactList;
    
    class GetErrorTimestampCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('Error');
            res.setStatusCode(VleServices.FORBIDDEN_STATUS_CODE);
            res.setBody(VleUserContext.TIMESTAMP_BODY_START + ' 123456');
            return res;
        }
    }
    
    static void setupTestData(Integer numberInstances) {
        // contacts
        contactList = new List<Contact>(); 
        for (Integer i=0; i<numberInstances; i++) {
            Contact c = new Contact(LastName = 'test' + i);
            contactList.add(c);
        }
        insert contactList;
        
        // add CS
        VLE__c vle = new VLE__c(
            Name = VleServices.CS_NAME, BatchIsRunning__c = false,
            API_Host__c = 'vle-host.com', App_ID__c = 'app_id', App_Key__c = 'app_key',
            User_ID__c = 'user_id', User_Key__c = 'user_key'
        ); 
        insert vle;
    }
    
    static VLE_Action__c prepareDummyActionWithNote(String noteMsg) {
        setupTestData(1);
        Contact c = contactList[0];
        VleBaseAction.DummyAction actionImpl = new VleBaseAction.DummyAction();
        actionImpl.c = c;        
        VleSyncServices.addToQueue(actionImpl, VleSyncServices.DUMMY_ACTION, c.Id);
        List<VleSyncServices.ActionStructure> aStructList = VleSyncServices.persistQueue();
        System.assertEquals(1, aStructList.size());
        VLE_Action__c action = VleSyncServices.findActionWithCommands(aStructList[0].masterAction.Id);
        action.Note__c = noteMsg;
        update action;
        return action;
    } 
    
    static testMethod void testAddToQueue() {
        setupTestData(3);
        System.assert(VleSyncServices.itemsToSync.isEmpty());
        
        // add first action
        VleBaseAction.DummyAction actionImpl = new VleBaseAction.DummyAction();
        actionImpl.c = contactList[0];
        VleSyncServices.addToQueue(actionImpl, VleSyncServices.DUMMY_ACTION, actionImpl.c.Id);
        System.assertEquals(1, VleSyncServices.itemsToSync.size());
        System.assertEquals(VleSyncServices.ACTION_NEW_STATUS, VleSyncServices.itemsToSync[0].masterAction.Status__c);
        System.assertEquals(1, VleSyncServices.itemsToSync[0].getDetailCommands().size());
        
        // add second action
        actionImpl = new VleBaseAction.DummyAction();
        actionImpl.c = contactList[1];
        VleSyncServices.addToQueue(actionImpl, VleSyncServices.DUMMY_ACTION, actionImpl.c.Id);
        System.assertEquals(2, VleSyncServices.itemsToSync.size());
        
        // void to add the same action
        VleSyncServices.addToQueue(actionImpl, VleSyncServices.DUMMY_ACTION, actionImpl.c.Id);
        System.assertEquals(2, VleSyncServices.itemsToSync.size());
    }
    
    static testMethod void testPersistQueue() {
        // add actions
        Integer overFutureLimit = 3;
        Integer totalCount = Limits.getLimitFutureCalls() + overFutureLimit; 
        setupTestData(totalCount);
        for (Integer i=0; i<totalCount; i++) {
            VleBaseAction.DummyAction actionImpl = new VleBaseAction.DummyAction();
            actionImpl.c = contactList[i];
            VleSyncServices.addToQueue(actionImpl, VleSyncServices.DUMMY_ACTION, actionImpl.c.Id);
        }
        System.assertEquals(totalCount, VleSyncServices.itemsToSync.size());
        for (VleSyncServices.ActionStructure aStruct: VleSyncServices.itemsToSync) {
            System.assertEquals(VleSyncServices.ACTION_NEW_STATUS, aStruct.masterAction.Status__c);
            System.assert(aStruct.masterAction.Id == null);
        }
        
        // run queue
        Test.startTest();
        System.assertEquals(totalCount, VleSyncServices.itemsToSync.size());
        List<VleSyncServices.ActionStructure> aStructList = VleSyncServices.persistQueue();
        System.assert(VleSyncServices.itemsToSync.isEmpty());
        Set<Id> actionIds = new Set<Id>();
        for (VleSyncServices.ActionStructure aStruct: aStructList) {
            actionIds.add(aStruct.masterAction.Id);
        }
        System.assertEquals(totalCount, actionIds.size());
        List<VLE_Action__c> dbActions = [SELECT Id, Status__c FROM VLE_Action__c WHERE Id IN :actionIds];
        System.assertEquals(totalCount, dbActions.size());
        Integer newCount = 0;
        Integer batchCount = 0;
        for (VLE_Action__c action: dbActions) {
            if ( action.Status__c == VleSyncServices.ACTION_NEW_STATUS ) newCount++;
            else if ( action.Status__c == VleSyncServices.ACTION_BATCH_STATUS ) batchCount++;
            else System.assert(false);
        }
        System.assertEquals(overFutureLimit, batchCount);
        System.assertEquals(totalCount - overFutureLimit, newCount);
        
        // check status after future
        Test.stopTest();
        dbActions = [SELECT Id, Status__c FROM VLE_Action__c WHERE Id IN :actionIds];
        Integer doneCount = 0;
        for (VLE_Action__c action: dbActions) {
            if ( action.Status__c == VleSyncServices.ACTION_DONE_STATUS ) doneCount++;
            if ( action.Status__c == VleSyncServices.ACTION_NEW_STATUS ) System.assert(false);
        }
        System.assertEquals(totalCount - overFutureLimit, doneCount);
    }
    
    static testMethod void testRunSyncBatch() {
        // create test actions for batch
        Integer n = 5; 
        setupTestData(n);
        for (Integer i=0; i<n; i++) {
            VleBaseAction.DummyAction actionImpl = new VleBaseAction.DummyAction();
            actionImpl.c = contactList[i];
            VleSyncServices.addToQueue(actionImpl, VleSyncServices.DUMMY_ACTION, actionImpl.c.Id);
        }
        System.assertEquals(n, VleSyncServices.itemsToSync.size());
        List<VLE_Action__c> actionList = new List<VLE_Action__c>();
        for (VleSyncServices.ActionStructure aStruct: VleSyncServices.itemsToSync) {
            actionList.add(aStruct.masterAction);
        }
        actionList[0].Status__c = VleSyncServices.ACTION_BATCH_STATUS; // single record only due to test limitation of batch with callouts
        insert actionList;
        System.assertEquals(n, actionList.size());
        
        // run batch
        Test.startTest();
        System.assert(VleSyncServices.isBatchRunning == false);
        Boolean res = VleSyncServices.runSyncBatch();
        System.assert(res);
        System.assert(VleSyncServices.isBatchRunning);
        res = VleSyncServices.runSyncBatch(); // second run always will be failed
        System.assert(res == false);
        System.assert(VleSyncServices.isBatchRunning);
        Test.stopTest();
        
        // check results after batch
        List<VLE_Action__c> resList = [SELECT Status__c FROM VLE_Action__c WHERE Id IN :actionList];
        System.assertEquals(n, resList.size());
        for (VLE_Action__c action: resList) {
            if ( action.Id == actionList[0].Id ) {
                System.assertEquals(action.Status__c, VleSyncServices.ACTION_DONE_STATUS);
            } else {
                System.assertEquals(action.Status__c, VleSyncServices.ACTION_NEW_STATUS);
            }
        }
    }
    
    static testMethod void testPrepareActionsForSync() {
        // create test actions for batch
        Integer n = 5; 
        setupTestData(n);
        for (Integer i=0; i<n; i++) {
            VleBaseAction.DummyAction actionImpl = new VleBaseAction.DummyAction();
            actionImpl.c = contactList[i];
            VleSyncServices.addToQueue(actionImpl, VleSyncServices.DUMMY_ACTION, actionImpl.c.Id);
        }
        System.assertEquals(n, VleSyncServices.itemsToSync.size());
        List<VLE_Action__c> actionList = new List<VLE_Action__c>();
        for (VleSyncServices.ActionStructure aStruct: VleSyncServices.itemsToSync) {
            actionList.add(aStruct.masterAction);
        }
        VLE_Action__c delayedAction = actionList[0]; 
        delayedAction.Status__c = VleSyncServices.ACTION_DELAYED_STATUS; // first delayed
        insert actionList;
        System.assertEquals(n, actionList.size());
        
        // check with Next_Try__c equals to NULL
        Boolean res = VleSyncServices.prepareActionsForSync();
        System.assert(res == false);
        
        // check with to early Next_Try__c value
        delayedAction.Next_Try__C = Datetime.now().addHours(1);
        update delayedAction;
        res = VleSyncServices.prepareActionsForSync();
        System.assert(res == false);
        
        // check with valid Next_Try__c value
        delayedAction.Next_Try__C = Datetime.now().addHours(-1);
        update delayedAction;
        res = VleSyncServices.prepareActionsForSync();
        System.assert(res);
        for (VLE_Action__c action: [SELECT Status__c FROM VLE_Action__c WHERE Id IN :actionList]) {
            if ( action.Id == delayedAction.Id) {
                System.assertEquals(action.Status__c, VleSyncServices.ACTION_BATCH_STATUS);
            } else {
                System.assertEquals(action.Status__c, VleSyncServices.ACTION_NEW_STATUS);
            }
        }
    }
    
    static testMethod void testRunAsyncServices() {
        System.assert(VleSyncServices.firstTryToRunBatch);
        // *** Suyati Modified Start 17-02-2016
        Expiry_Days_For_Old_Vle_Actions__c expiryDays = new Expiry_Days_For_Old_Vle_Actions__c();
        expiryDays.NAme = 'Expiry Days for Old Vle Action';
        expiryDays.Expiry_Days__c = 5;
        INSERT expiryDays;
        // *** Suyati Modified End
        VleSyncServices.runAsyncServices();
        System.assert(VleSyncServices.firstTryToRunBatch == false);
    }
    
    
    static testMethod void testBaseActionCanceled() {
        Test.startTest();
        VLE_Action__c action = prepareDummyActionWithNote(VleBaseAction.DUMMY_NOTE_FIND_FALSE);
        Test.stopTest();
        action = VleSyncServices.findActionWithCommands(action.Id);
        System.assert(action != null);
        System.assertEquals(VleSyncServices.ACTION_CANCELED_STATUS, action.Status__c);
    }
    
    static testMethod void testBaseActionInitException() {
        Test.startTest();
        VLE_Action__c action = prepareDummyActionWithNote(VleBaseAction.DUMMY_NOTE_INIT_EXCEPTION);
        System.assert(action.Next_Try__c == null);
        Test.stopTest();
        action = VleSyncServices.findActionWithCommands(action.Id);
        System.assert(action != null);
        System.assertEquals(VleSyncServices.ACTION_DELAYED_STATUS, action.Status__c);
        System.assert(action.Next_Try__c != null);
    }
    
    static testMethod void testBaseActionCommandException() {
        Test.startTest();
        VLE_Action__c action = prepareDummyActionWithNote(null);
        VLE_Sync_Command__c cmd = action.VLE_Sync_Commands__r[0]; 
        cmd.Last_Error_Message__c = VleBaseAction.DUMMY_ERR_MSG_EXCEPTION;
        update cmd;
        Test.stopTest();
        action = VleSyncServices.findActionWithCommands(action.Id);
        System.assert(action != null);
        System.assertEquals(VleSyncServices.ACTION_DELAYED_STATUS, action.Status__c);
        System.assert(action.Next_Try__c != null);
        System.assert(action.VLE_Sync_Commands__r[0].Last_Error_Message__c != null);
        System.assertNotEquals(VleBaseAction.DUMMY_ERR_MSG_EXCEPTION, action.VLE_Sync_Commands__r[0].Last_Error_Message__c);
    }
    
    static testMethod void testBaseActionDmlCommandException() {
        Test.startTest();
        VLE_Action__c action = prepareDummyActionWithNote(null);
        VLE_Sync_Command__c cmd = action.VLE_Sync_Commands__r[0]; 
        cmd.Last_Error_Message__c = VleBaseAction.DUMMY_ERR_DML_EXCEPTION;
        update cmd;
        Test.stopTest();
        action = VleSyncServices.findActionWithCommands(action.Id);
        System.assert(action != null);
        System.assertEquals(VleSyncServices.ACTION_DELAYED_STATUS, action.Status__c);
        //System.assert(action.Note__c.startsWith(VleBaseAction.ROLLBACK_DML_ERR_MSG));
    }
    
    static testMethod void testBaseActionCommandErrorLongMsg() {
        Test.startTest();
        VLE_Action__c action = prepareDummyActionWithNote(null);
        VLE_Sync_Command__c cmd = action.VLE_Sync_Commands__r[0]; 
        cmd.Last_Error_Message__c = VleBaseAction.DUMMY_ERR_LONG_MSG;
        update cmd;
        Test.stopTest();
        action = VleSyncServices.findActionWithCommands(action.Id);
        System.assert(action != null);
        System.assertEquals(VleSyncServices.ACTION_DELAYED_STATUS, action.Status__c);
    }
    
    static testMethod void testBaseActionCommandParseFailed() {
        Test.startTest();
        VLE_Action__c action = prepareDummyActionWithNote(null);
        VLE_Sync_Command__c cmd = action.VLE_Sync_Commands__r[0]; 
        cmd.Last_Error_Message__c = VleBaseAction.DUMMY_ERR_PARSE_FAILED;
        update cmd;
        Test.stopTest();
        action = VleSyncServices.findActionWithCommands(action.Id);
        System.assert(action != null);
        System.assertEquals(VleSyncServices.ACTION_DELAYED_STATUS, action.Status__c);
    }
    
    static testMethod void testBaseActionCommandInvalidTimestamp() {
        Test.setMock(HttpCalloutMock.class, new GetErrorTimestampCalloutMock());
        Test.startTest();
        VLE_Action__c action = prepareDummyActionWithNote(null);
        VLE_Sync_Command__c cmd = action.VLE_Sync_Commands__r[0]; 
        cmd.Last_Error_Message__c = VleBaseAction.DUMMY_ERR_INVALID_TIMESTAMP;
        update cmd;
        Test.stopTest();
        action = VleSyncServices.findActionWithCommands(action.Id);
        System.assert(action != null);
        System.assertEquals(VleSyncServices.ACTION_DELAYED_STATUS, action.Status__c);
        System.assertEquals(VleBaseAction.THERE_IS_NO_CALLOUTS_ERR_MSG, action.VLE_Sync_Commands__r[0].Last_Error_Message__c);
    }
    
    static testMethod void testBaseActionNotFoundCommand() {
        Test.startTest();
        VLE_Action__c action = prepareDummyActionWithNote(VleBaseAction.DUMMY_NOTE_COMMAND_NOT_FOUND);
        Test.stopTest();
        action = VleSyncServices.findActionWithCommands(action.Id);
        System.assert(action != null);
        System.assertEquals(VleSyncServices.ACTION_DELAYED_STATUS, action.Status__c);
        System.assertEquals(VleBaseAction.COMMAND_NOT_SUPPORTED_ERR_MSG, action.VLE_Sync_Commands__r[0].Last_Error_Message__c);
    }
    
}