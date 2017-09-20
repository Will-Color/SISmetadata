/**
 * Unit test for VleAppContext class
 */
@isTest
private class TestVleAppContext {
	
	static final String testAppId = 'appId';
	static final String testAppKey = 'appKey';
	static final String testApiHost = 'api.com';
	static final String testApiUrl = 'https://' + testApiHost + '/index.html';
	static final String testCbUrl = 'https://callback.com/index.html';

    static testMethod void testCreateWebUrlForAuthentication() {
        VleServices.IAppContext appContext = new VleAppContext(testAppId, testAppKey, testApiUrl);
        URL authUrl = appContext.createWebUrlForAuthentication(new URL(testCbUrl));
        System.assert(authUrl != null);
        System.assertEquals(testApiHost, authUrl.getHost());
        String queryStr = authUrl.getQuery();
        System.assert(queryStr != null);
        Map<String,String> params = new Map<String,String>();
        for (String qp: queryStr.split('&')) {
        	String[] chunks = qp.split('=');
        	params.put(chunks[0], chunks[1]);
        }
        System.assertEquals(3, params.size());
        System.assertEquals(testAppId, params.get(VleAppContext.APP_ID_PARAMETER));
    }
    
    static testMethod void testCreateUserContext() {
    	VleServices.IAppContext appContext = new VleAppContext(testAppId, testAppKey, testApiUrl);
    	VleServices.IUserContext userContext = appContext.createUserContext('userId', 'userKey');
    	System.assert(userContext != null);
    	System.assertEquals(0, userContext.getServerSkewMillis());
    }
    
    static testMethod void testCreateAnonymousUserContext() {
    	VleServices.IAppContext appContext = new VleAppContext(testAppId, testAppKey, testApiUrl);
    	VleServices.IUserContext userContext = appContext.createAnonymousUserContext();
    	System.assert(userContext != null);
    	System.assertEquals(0, userContext.getServerSkewMillis());
    }
    
}