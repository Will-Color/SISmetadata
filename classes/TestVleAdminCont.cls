/**
 * Unit test for VleAdminCont page controller
 */
@isTest
private class TestVleAdminCont {
    
    static String testUserName = 'John.Dou';
    
    static void setupCredentials() {
        VLE__c vle = new VLE__c(
            Name = VleServices.CS_NAME, API_Host__c = 'vle-host.com', App_ID__c = 'app_id', App_Key__c = 'app_key',
            User_ID__c = 'user_id', User_Key__c = 'user_key', Email_To_Student__c = false, Email_To_Staff__c = false
        ); 
        insert vle;
    }
    
    public class GetOkCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(VleServices.OK_STATUS_CODE);
            res.setBody('{"success":true,"' + VleAdminCont.WHOAMI_USERNAME_FIELD + '":"' + testUserName + '"}');
            return res;
        }
    }
    
    public class GetErrorCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('Error');
            res.setStatusCode(VleServices.FORBIDDEN_STATUS_CODE);
            res.setBody('{"success":false}');
            return res;
        }
    }
    
    public class CustomCalloutException extends Exception {}
    
    public class GetExceptionCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req){
            throw new CustomCalloutException('Exception');
        }
    }

    static testMethod void testController() {
        // without credentials
        VleAdminCont cont = new VleAdminCont();
        System.assert(cont.csFound == false);
        System.assert(cont.getVleAuthTokenUrl() == null);
        // with credentials
        setupCredentials();
        cont = new VleAdminCont();
        System.assert(cont.csFound);
        System.assert(cont.getVleAuthTokenUrl() != null);
        // empty last log list
        System.assert(cont.getLastSyncActions().isEmpty());
        // void actions call
        cont.runActionManually();
        cont.runAsyncServices();
    }
    
    static testMethod void testCheckContextsOk() {
        setupCredentials();
        VleAdminCont cont = new VleAdminCont();
        Test.setMock(HttpCalloutMock.class, new GetOkCalloutMock());
        Test.startTest();
        cont.checkContexts();
        Test.stopTest();
        System.assert(cont.appContextState.startsWith(VleAdminCont.STATUS_OK));
        System.assert(cont.userContextState.startsWith(VleAdminCont.STATUS_OK));
        System.assert(cont.userContextState.indexOf(testUserName) >= 0);
    }
    
    static testMethod void testCheckContextsUserSkipped() {
        setupCredentials();
        VleAdminCont cont = new VleAdminCont();
        Test.setMock(HttpCalloutMock.class, new GetErrorCalloutMock());
        Test.startTest();
        cont.checkContexts();
        Test.stopTest();
        System.assert(cont.appContextState.startsWith(VleAdminCont.STATUS_ERROR));
        System.assertEquals(cont.userContextState, VleAdminCont.STATE_SKIPPED);
    }
    
    static testMethod void testAppContextException() {
        setupCredentials();
        VleAdminCont cont = new VleAdminCont();
        Test.setMock(HttpCalloutMock.class, new GetExceptionCalloutMock());
        Test.startTest();
        cont.checkAppContext();
        Test.stopTest();
        System.assert(cont.appContextState.startsWith(VleAdminCont.STATUS_ERROR));
    }
    
    static testMethod void testUserContextError() {
        setupCredentials();
        VleAdminCont cont = new VleAdminCont();
        Test.setMock(HttpCalloutMock.class, new GetErrorCalloutMock());
        Test.startTest();
        cont.checkUserContext();
        Test.stopTest();
        System.assert(cont.userContextState.startsWith(VleAdminCont.STATUS_ERROR));
    }
    
    static testMethod void testUserContextException() {
        setupCredentials();
        VleAdminCont cont = new VleAdminCont();
        Test.setMock(HttpCalloutMock.class, new GetExceptionCalloutMock());
        Test.startTest();
        cont.checkUserContext();
        Test.stopTest();
        System.assert(cont.userContextState.startsWith(VleAdminCont.STATUS_ERROR));
    }
    
    static testMethod void testEmailSettings() {
        setupCredentials();
        VleAdminCont cont = new VleAdminCont();
        System.assert(cont.sendWelcomeEmailToStudent == false);
        System.assert(cont.sendWelcomeEmailToStaff == false);
        System.assert(cont.emailSettingsEditMode == false);
        
        // set edit mode and cancel
        cont.editEmailSettings();
        System.assert(cont.emailSettingsEditMode);
        cont.sendWelcomeEmailToStudent = true;
        cont.sendWelcomeEmailToStaff = true;
        cont.cancelEmailSettings();
        System.assert(cont.sendWelcomeEmailToStudent == false);
        System.assert(cont.sendWelcomeEmailToStaff == false);
        System.assert(cont.emailSettingsEditMode == false);
        
        // edit and save
        cont.editEmailSettings();
        cont.sendWelcomeEmailToStaff = true;
        cont.saveEmailSettings();
        System.assert(cont.sendWelcomeEmailToStudent == false);
        System.assert(cont.sendWelcomeEmailToStaff);
        System.assert(cont.emailSettingsEditMode == false);
    }
    // ***Suyati Modified Start 17-02-2016
    @isTest(SeeAllData='true')
    public static void testRedirectingReportUrl(){
        VleAdminCont cont = new VleAdminCont();
        cont.redirectToReport();
    }
    // *** Suyati End
    
}