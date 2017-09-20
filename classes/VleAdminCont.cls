/**
 * Controller for VleAdmin visualforce page
 */
public with sharing class VleAdminCont {

    // Constants for context state
    public static final String STATUS_OK = 'OK';
    public static final String STATUS_ERROR = 'Error!'; 
    public static final String STATE_NOT_CHECKED = 'N/A';
    public static final String STATE_SKIPPED = 'Skipped';
    
    // Messages
    public static final String REMOTE_SITE_NOT_ALLOWED_TEMPLATE = STATUS_ERROR + ' Please check Security Controls -> Remote Site Settings for {0}';
    public static final String API_USER_NAME_TEMPLATE = STATUS_OK + ', API user name [{0}]';
    
    // API constants
    public static final String API_VERSION_PATH = '/d2l/api/versions/';
    public static final String API_WHOAMI_PATH = '/d2l/api/lp/1.0/users/whoami';
    public static final String WHOAMI_USERNAME_FIELD = 'UniqueName';
    
    // Number of last log records
    public static final Integer LAST_LOG_SIZE = 10;
    
    /**
     * Constructor
     */
    public VleAdminCont() {
        appContextState = STATE_NOT_CHECKED;
        userContextState = STATE_NOT_CHECKED;
        emailSettingsEditMode = false;
    }
    
    /**
     * Check for exist custom settings with credentials
     */
    public Boolean csFound {
        get {
            return VleServices.credentials != null;
        }
    }
    
    /**
     * Status of checking Application Context
     */
    public String appContextState { get; set; }
    
    /**
     * Status of checking User Context
     */
    public String userContextState { get; set; }
    
    /**
     * Id of VLE_Action__c for running
     */
    public Id actionIdForRun { get; set; }
    
    
    /**
     * Flag of sending welcome email to student
     */
    public Boolean sendWelcomeEmailToStudent {
        get{
            if ( sendWelcomeEmailToStudent == null ) {
                sendWelcomeEmailToStudent = VleServices.credentials.Email_To_Student__c;
            }
            return sendWelcomeEmailToStudent;
        }
        set;
    }
    
    /**
     * Flag of sending welcome email to staff
     */
    public Boolean sendWelcomeEmailToStaff {
        get{
            if ( sendWelcomeEmailToStaff == null ) {
                sendWelcomeEmailToStaff = VleServices.credentials.Email_To_Staff__c;
            }
            return sendWelcomeEmailToStaff;
        }
        set;
    }
    
    /**
     * Edit mode of Email Settings
     */
    public Boolean emailSettingsEditMode { get; set; }
    
    /**
     * Return list of last modified VLE_Action__c
     * @return List of VLE_Action__c
     */
    public List<Vle_Action__c> getLastSyncActions() {
        return VleDaoServices.getLastSyncActions(LAST_LOG_SIZE);
    }
    
    /**
     * Get URL for update user context (session)
     */
    public String getVleAuthTokenUrl() {
        if ( csFound ) {
            URL cb = new URL(URL.getSalesforceBaseUrl().toExternalForm() + Page.VleCallback.getURL());
            return VleServices.appContextInstance().createWebUrlForAuthentication(cb).toExternalForm();
        } else {
            return null;
        }
    }
    
    /**
     * Check Application Context
     * @return True if check was successful
     */
    @testVisible
    private Boolean checkAppContext() {
        try {
            HttpResponse res = VleServices.performHttpCall(
                API_VERSION_PATH, VleServices.GET_METHOD, VleServices.appContextInstance().createAnonymousUserContext()
            );
            if ( res.getStatusCode() == VleServices.OK_STATUS_CODE ) {
                appContextState = STATUS_OK;
                return true;
            } else {
                appContextState = STATUS_ERROR;
            }
        } catch (Exception e) {
            appContextState = String.format(REMOTE_SITE_NOT_ALLOWED_TEMPLATE, new String[] {VleServices.credentials.API_Host__c});
        }
        return false;
    }
    
    /**
     * Check User Context
     * @return True if check was successful
     */
    @testVisible
    private Boolean checkUserContext() {
        try {
            HttpResponse res = VleServices.performHttpCall(
                API_WHOAMI_PATH, VleServices.GET_METHOD,
                VleServices.appContextInstance().createUserContext(VleServices.credentials.User_ID__c, VleServices.credentials.User_Key__c)
            );
            if ( res.getStatusCode() == VleServices.OK_STATUS_CODE ) {
                // show user name
                Map<String,Object> whoAmI = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());                
                userContextState = String.format(API_USER_NAME_TEMPLATE, new String[] {(String) whoAmI.get(WHOAMI_USERNAME_FIELD)});
                return true;
            } else {
                userContextState = STATUS_ERROR;
            }
        } catch (Exception e) {
            userContextState = STATUS_ERROR + ' Callout exception'; 
        }
        return false;
    }
    
    /**
     * Action to perform checking of connection with VLE API
     * App Context first, User Context after
     */
    public void checkContexts() {
        if ( csFound ) {
            if ( checkAppContext() ) {
                checkUserContext();
            } else {
                userContextState = STATE_SKIPPED;
            }
        } 
    }
    
    public Pagereference gotoRoleAssignments(){
        return Page.ManageVleOrgWideUnitRoles;
    }
    
    /**
     * Action for perform VLE Action manually
     */
    public void runActionManually() {
        VleSyncServices.syncActionBatch(actionIdForRun);
    }
    
    /**
     * Another point to run some delayed jobs
     */
    public void runAsyncServices() {
        VleSyncServices.runAsyncServices();
    }
    
    /**
     * Action to enter in edit mode for Email Settings
     */
    public void editEmailSettings() {
        emailSettingsEditMode = true;
    }
    
    /**
     * Action for saving Email Settings
     */
    public void saveEmailSettings() {
        VLE__c vle = new VLE__c(
            Id = VleServices.credentials.Id,
            Email_To_Student__c = sendWelcomeEmailToStudent,
            Email_To_Staff__c = sendWelcomeEmailToStaff
        );
        update vle;
        emailSettingsEditMode = false;
    }
    
    /**
     * Cancel action of edit Email Settings 
     */
    public void cancelEmailSettings() {
        emailSettingsEditMode = false;
        sendWelcomeEmailToStudent = null;
        sendWelcomeEmailToStaff = null;
    }
    // ***Suyati Modified Start 16-02-2016
    public PageReference redirectToReport(){
        Report report = [SELECT Id, Name FROM Report where Name = 'VLE Action Report' limit 1];
        //Id reportId = report.Id;
        //if(report !=null){
            string reportUrl = ApexPages.currentPage().getHeaders().get('Host');
            System.debug('reportUrl = '+reportUrl );
            reportUrl += '/';
            reportUrl +=report.Id;
            PageReference ref = new PageReference('https://'+reportUrl );
            return ref;
        //}
       
        
    }
    // ***Suyati Modified End
    
}