/**
 * Base abstract action to hold common utilitty methods
 * As a rule any other actions should use this class as a parent 
 */
public with sharing abstract class VleBaseAction implements VleSyncServices.IAction {
    
    private Boolean allOk = false;
    
    private static final Integer LAST_ERROR_MSG_LENGTH = 255;
    private static final Integer ACTION_NOTE_LENGTH = 64;
    
    // Error messages
    public static final String COMMAND_NOT_SUPPORTED_ERR_MSG = 'Command not supported';
    public static final String RESPONSE_PARSE_FAILED_ERR_MSG = 'Parse failed';
    public static final String THERE_IS_NO_CALLOUTS_ERR_MSG = 'Command did not run due to lack of callouts';
    public static final String ROLLBACK_DML_ERR_MSG = 'DML were rollback: ';
    
    // Dummy Note__c values for testing purpose
    public static final String DUMMY_NOTE_FIND_FALSE = 'Find has failed';
    public static final String DUMMY_NOTE_INIT_EXCEPTION = 'Init has failed';
    public static final String DUMMY_NOTE_COMMAND_NOT_FOUND = 'Command not found';
    
    // Dummy Last_Error_Message__c values for testing purpose
    public static final String DUMMY_ERR_MSG_EXCEPTION = 'Command has thrown exception';
    public static final String DUMMY_ERR_DML_EXCEPTION = 'DML exception';
    public static final String DUMMY_ERR_LONG_MSG = 'Error message is too long';
    public static final String DUMMY_ERR_PARSE_FAILED = 'Parse has failed';
    public static final String DUMMY_ERR_INVALID_TIMESTAMP = 'Timestamp is invalid';



    /**
     * Set Last_Error_Message__c field value for Vle_Sync_Command__c with respect to field length
     * @param cmd Current command
     * @param msg Error message text
     */
    protected void setLastErrorMessage(Vle_Sync_Command__c cmd, String msg) {
        System.debug('Message = '+msg);
        if ( !String.isBlank(msg) && msg.length() > LAST_ERROR_MSG_LENGTH ) {
            msg = msg.substring(0, LAST_ERROR_MSG_LENGTH);
        }
        cmd.Last_Error_Message__c = msg;
    }
    
    protected void markCommandAsError(Vle_Sync_Command__c cmd, String msg) {
        allOk = false;
        cmd.Status__c = VleSyncServices.COMMAND_ERROR_STATUS;
        setLastErrorMessage(cmd, msg);
        cmd.Error_Count__c += 1;
    }
    
    /**
     * Set Note__c field of action
     * @param action Action instance
     * @param msg Text to note
     */
    protected void setNote(Vle_Action__c action, String msg) {
        if ( !String.isBlank(msg) && msg.length() > ACTION_NOTE_LENGTH ) {
            msg = msg.substring(0, ACTION_NOTE_LENGTH);
        }
        System.debug('Message = '+msg);
        action.Note__c = msg;
    }
    
    /**
     * Collect data related to action
     * @param action Current action
     * @return True if there is data, False - action should be closed
     */
    protected abstract Boolean findActionData(VLE_Action__c action);
    
    /**
     * Find ready to use ICommand implementation
     * @param cmd Command record
     * @return Instance of ICommand with all needed params
     */
    protected abstract VleSyncServices.ICommand findCommand(Vle_Sync_Command__c cmd);
    
    /**
     * Try to synchronize action 'create student'
     * @param action Action with details (commands)
     */

    public void perform(VLE_Action__c action) {
        String errorStr ;
        System.debug('performing action: ' + action);
        if ( VleServices.credentials == null ) return;
        VleServices.IUserContext userContext = VleServices.userContextInstance();
        
        try {

            if ( findActionData(action) ) {
                allOk = true;
                List<VLE_Sync_Command__c> updatedCommands = new List<VLE_Sync_Command__c>();
                List<sObject> updatedObjects = new List<sObject>();
                for (VLE_Sync_Command__c cmd: action.VLE_Sync_Commands__r) {
                    if ( cmd.Status__c == VleSyncServices.COMMAND_DONE_STATUS ) continue;
                    updatedCommands.add(cmd);
                    // try to perform action
                    VleSyncServices.ICommand cmdImpl = findCommand(cmd);
                    if ( cmdImpl == null ) {
                        markCommandAsError(cmd, COMMAND_NOT_SUPPORTED_ERR_MSG);
                        break;
                    }
                    cmdImpl.init(cmd);
                    Boolean timestampWasAdjusted = false;
                    do {
                        try {
                            // check callout limits
                            if ( Limits.getLimitCallouts() - Limits.getCallouts() <= 0 ) {
                                markCommandAsError(cmd, THERE_IS_NO_CALLOUTS_ERR_MSG);
                                break;
                            } 
                            HttpResponse resp = cmdImpl.makeCallout(userContext);
                            // check response
                            Integer callResult = userContext.interpretResult(resp.getStatusCode(), resp.getBody());
                            System.Debug('resp.getBody():'+ resp.getBody());
                            System.debug('Test updated object 1 ='+updatedObjects);
                            if ( callResult == VleServices.RESULT_OKAY ) {
                                // try to recognize API result
                                setLastErrorMessage(cmd, resp.getBody()); // FIXME temporary
                                System.Debug('resp.getBody():'+ resp.getBody());
                                VleSyncServices.ParseResult res = cmdImpl.parseResultOk(resp);
                                System.Debug('res :'+ res);
                                if ( res.result ) {
                                    updatedObjects.addAll(res.updatedRecords);
                                    cmd.Status__c = VleSyncServices.COMMAND_DONE_STATUS;    
                                } else {
                                    markCommandAsError(cmd, RESPONSE_PARSE_FAILED_ERR_MSG + ' ' + resp.getBody());
                                }
                            } else if ( callResult == VleServices.RESULT_INVALID_TIMESTAMP ) {
                                // timestamp was adjusted, try again
                                cmd.Error_Count__c += 1;
                                timestampWasAdjusted = true;
                                continue;
                            } else {
                                System.debug('Test UpdatedCommands = '+updatedCommands);
                                System.Debug('errortest:'+ resp.getBody());
                                errorStr = resp.getBody();
                                
                                markCommandAsError(cmd, 'Error code ' + callResult +': ' + resp.getBody());
                            }
                        } catch (Exception e) {
                            markCommandAsError(cmd, e.getMessage());
                        }
                        timestampWasAdjusted = false;
                        System.debug('Test UpdatedCommands = '+updatedCommands);
                    } while( timestampWasAdjusted );
                    
                    // check for stop on current command
                    if ( !allOk ) {
                        System.debug('Test after'+updatedObjects);
                        break;
                    }
                }
                
                // persist after all callouts
                try {
                    // update in system mode
                    System.debug('Test UpdatedCommands = '+updatedCommands);
                    System.debug('Test updatedObjects = '+updatedObjects);
                    VleDaoServices.makeUpdate(updatedObjects);
                    VleDaoServices.makeUpdate(updatedCommands);
                } catch (Exception e) {
                    // rollback all changes
                    System.debug('Test RollBack');
                    setNote(action, ROLLBACK_DML_ERR_MSG + e.getMessage());
                    allOk = false;
                }
                if ( allOk ) {
                    
                    System.debug('errorStr = '+errorStr);
                    action.Status__c = VleSyncServices.ACTION_DONE_STATUS;
                } else {
                    //Modified by Suyati 05-02-2016
                     System.debug('errorStr inside else = '+errorStr);
                    errorStr = errorStr.substringBetween('"Message":"', '"}]}');
                    System.debug('Error String = '+errorStr);
                    if(errorStr == 'The username supplied is invalid or already in use. Please choose a different username.' ){
                        //Update the status to Done
                        System.debug('True Condition');
                        action.Status__c = VleSyncServices.ACTION_DONE_STATUS;
                        System.debug('action.Status__c = '+action.Status__c);
                        String emailSub = 'VLE Sync: Duplicate username';
                        System.debug('currentPage=  '+ ApexPages.currentPage());
                        System.debug('headers =  '+ ApexPages.currentPage().getHeaders());
                        System.debug('Host =  '+ ApexPages.currentPage().getHeaders().get('Host'));
                        String body = 'Hi,<br>';
                               body += 'You are trying to create a user with duplicate username in VLE system for the following record  <br>';
                               body += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() +'/'+ action.Name + '">Click here</a><br>';
                               body += 'This process is cancelled due to the invalid username.<br>';
                               body += 'Thank you. ';
                        System.debug('Before sendEmailToAdmin');
                        sendEmailToAdmin(emailSub,body);

                    }
                    else if(errorStr == 'Resource Not Found'){
                        //Send email to Admin
                        action.Status__c = VleSyncServices.ACTION_DONE_STATUS;
                        String emailSub = 'VLE Sync:Resource Not Found ';
                        String body = 'Hi,<br>';
                               body += 'The resource you are trying to access in the VLE system is not found. <br>';
                               body += '<a href="https://' + ApexPages.currentPage().getHeaders().get('Host')+'/'+ action.Name + '">Click here</a><br>';
                               body += 'Thank you. ';
                        sendEmailToAdmin(emailSub,body);

                    }
                    else{
                        action.Status__c = VleSyncServices.ACTION_DELAYED_STATUS;
                    }
                    action.Next_Try__c = Datetime.Now().addMinutes(VleSyncServices.MINUTES_FOR_REPEAT_DELAYED);
                }
            } else {
                action.Status__c = VleSyncServices.ACTION_CANCELED_STATUS;
            }
            
        } catch(Exception e) {
            System.debug('Exception ='+e);
            System.debug('Exception GetMessage = '+e.getMessage());
            setNote(action, e.getMessage());
            action.Status__c = VleSyncServices.ACTION_DELAYED_STATUS;
            action.Next_Try__c = Datetime.Now().addMinutes(VleSyncServices.MINUTES_FOR_REPEAT_DELAYED);
        }
        System.debug('Test Action ='+action);
        update action;
    }

    public void sendEmailToAdmin(String subject,String emailBody){
      System.debug('Inside sendEmailToAdmin');
      List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
      Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
      List<String> sendTo = new List<String>();
      
      Vle_Admin_To_Send_Email__c adEmail = Vle_Admin_To_Send_Email__c.getInstance('Admin ID');
      String userId = adEmail.User_Id__c;
      System.debug('userId  = '+userId );
      User u = [SELECT Id,Name,Email FROM USER where id=: userId];
      System.debug('User Email ='+u.Email);
      sendTo.add(u.Email);
      
      //sendTo.add('dmsunny@suyati.com');
      mail.setToAddresses(sendTo);
      mail.setSubject(subject);
      mail.setHtmlBody(emailBody);
      mails.add(mail);
      Messaging.sendEmail(mails);
    }
    
    /**
     * Implementation of dummy command for test purpose only
     */
    public class DummyCommand implements VleSyncServices.ICommand {
        
        private Boolean throwException = false;
        private Boolean dmlException = false;
        private Boolean errMsgTooLong = false;
        private Boolean parseFailed = false;
        private Boolean timestampError = false;
        
        public Contact c { get; set; }
        
        public void init(VLE_Sync_Command__c cmd) {
            throwException = (cmd.Last_Error_Message__c == DUMMY_ERR_MSG_EXCEPTION);
            dmlException = ( cmd.Last_Error_Message__c == DUMMY_ERR_DML_EXCEPTION );
            errMsgTooLong = ( cmd.Last_Error_Message__c == DUMMY_ERR_LONG_MSG );
            parseFailed = ( cmd.Last_Error_Message__c == DUMMY_ERR_PARSE_FAILED );
            timestampError = ( cmd.Last_Error_Message__c == DUMMY_ERR_INVALID_TIMESTAMP );
        }
        
        public HttpResponse makeCallout(VleServices.IUserContext userContext) {
            if ( throwException ) {
                Integer res = 15 / 0; // exception
            }
            HttpResponse resp = new HttpResponse();
            if ( errMsgTooLong ) {
                resp.setStatusCode(VleServices.NOT_FOUND_STATUS_CODE);
                String longStr = 'this body is too long 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890';
                resp.setBody(longStr + longStr + longStr);
            } else if ( timestampError ) {
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                resp = h.send(req);
            } else {
                resp.setStatusCode(VleServices.OK_STATUS_CODE);
            }
            return resp;
        }
        
        public VleSyncServices.ParseResult parseResultOk(HttpResponse resp) {
            VleSyncServices.ParseResult pr = new VleSyncServices.ParseResult();
            if ( dmlException ) {
                pr.updatedRecords.add(new Contact(FirstName = 'test')); // without mandatory LastName 
            }
            pr.result = !parseFailed;
            return pr;
        }
    }
    
    /**
     * Implementation of dummy action related to Contact (for testing purpose only)
     */
    public class DummyAction extends VleBaseAction {
        
        private Boolean findException = false;
        private Boolean findFalse = false;
        public Boolean cmdNotFound = false;
        
        public Contact c { get; set; }
        
        protected override Boolean findActionData(VLE_Action__c action) {
            
            if ( action.Note__c == DUMMY_NOTE_FIND_FALSE ) return false;
            if ( action.Note__c == DUMMY_NOTE_INIT_EXCEPTION ) {
                Integer res = 15 / 0; // exception
            }
            cmdNotFound = ( action.Note__c == DUMMY_NOTE_COMMAND_NOT_FOUND ); 
            return true;
        }
        
        protected override VleSyncServices.ICommand findCommand(Vle_Sync_Command__c cmd) {
            if ( cmdNotFound ) return null;
            DummyCommand cmdImpl = new DummyCommand();
            cmdImpl.c = this.c;
            return cmdImpl;
        }
        
        public VleSyncServices.ActionStructure create() {
            VleSyncServices.ActionStructure res = new VleSyncServices.ActionStructure();
            res.masterAction = VleSyncServices.createAction(VleSyncServices.DUMMY_ACTION, c.Id, VleSyncServices.ACTION_NEW_STATUS);
            res.getDetailCommands().add(VleSyncServices.createCommand(VleSyncServices.DUMMY_COMMAND, c.Id, 1, VleSyncServices.OBJ_TYPE_CONTACT, null));
            return res;
        }
        
    }
    
}