/**
 * Unit test for VleServices class
 */
@isTest
private class TestVleServices {
	
	static final String testAppId = 'appId';
	static final String testAppKey = 'appKey';
	static final String testApiUrl = 'https://api.com';
	static final String testUserId = 'userId';
	static final String testUserKey = 'userKey';
	static final String testPath = '/api/path/';
	
	public class GetOkCalloutMock implements HttpCalloutMock {
		public HttpResponse respond(HTTPRequest req){
			HttpResponse res = new HttpResponse();
			res.setStatus('OK');
			res.setStatusCode(VleServices.OK_STATUS_CODE);
			res.setBody('{"success":true}');
			return res;
		}
	}
	
	static VleUserContext buildUserContext() {
		return new VleUserContext(testApiurl, testAppId, testAppKey, testUserId, testUserKey);
	}
	
    @isTest(seeAllData=true)
    static void testCredentials() {
    	VLE__c creds = VleServices.credentials;
        System.assert(creds != null);
        System.assert(creds.App_ID__c != null);
        System.assert(creds.App_Key__c != null);
    }
    
    @isTest(seeAllData=true)
    static void testContextsInstance() {
        VleServices.IAppContext appContext = VleServices.appContextInstance();
        System.assert(appContext != null);
        VleServices.IUserContext userContext = VleServices.userContextInstance();
        System.assert(userContext != null);
    }

    static testMethod void testBuildBase64HashString() {
    	String value = 'just a value';
    	String secretKey = '12345';
    	String digest = VleServices.buildBase64HashString(secretKey, value);
    	System.assert(digest != null);
    	System.assertEquals(-1, digest.indexOf('='));
    	System.assertEquals(-1, digest.indexOf('/'));
    	System.assertEquals(-1, digest.indexOf('+'));
    }

	static testMethod void testPerformHttpCall() {
		VleServices.IUserContext userContext = buildUserContext();
		Test.setMock(HttpCalloutMock.class, new GetOkCalloutMock());
    	Test.startTest();
    	HttpResponse resp = VleServices.performHttpCall(testPath, VleServices.GET_METHOD, userContext);
    	Test.stopTest();
    	System.assertEquals(VleServices.OK_STATUS_CODE, resp.getStatusCode());
	}
	
	static testMethod void testPerformHttpCallWithBody() {
		VleServices.IUserContext userContext = buildUserContext();
		Test.setMock(HttpCalloutMock.class, new GetOkCalloutMock());
    	Test.startTest();
    	HttpResponse resp = VleServices.performHttpCall(testPath, VleServices.GET_METHOD, userContext, 'Test body');
    	Test.stopTest();
    	System.assertEquals(VleServices.OK_STATUS_CODE, resp.getStatusCode());
	}
	
}