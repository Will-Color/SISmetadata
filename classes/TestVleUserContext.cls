/**
 * Unit test for VleUserContext class
 */
@isTest
private class TestVleUserContext {
	
	static final String testAppId = 'appId';
	static final String testAppKey = 'appKey';
	static final String testApiUrl = 'https://api.com';
	static final String testUserId = 'userId';
	static final String testUserKey = 'userKey';
	static final String testPath = '/api/1.0/path/user.php?version=1';
	
	static VleUserContext buildUserContext() {
		return new VleUserContext(testApiurl, testAppId, testAppKey, testUserId, testUserKey);
	}

    static testMethod void testServerSkewMillis() {
    	VleServices.IUserContext userContext = buildUserContext();
    	System.assertEquals(0, usercontext.getServerSkewMillis());
    	Long skew = 123;
    	usercontext.setServerSkewMillis(skew);
    	System.assertEquals(skew, usercontext.getServerSkewMillis());
    }
    
    static testMethod void testCreateAuthenticatedUri() {
        VleServices.IUserContext userContext = buildUserContext();
        URL authUrl = userContext.createAuthenticatedUri(testPath, VleServices.GET_METHOD);
        System.assert(authUrl != null);
        System.assert(authUrl.toExternalForm().startsWith(testApiUrl));
        System.assert(testPath.startsWith(authUrl.getPath()));
        System.assertEquals(-1, authUrl.getPath().indexOf('?'));
        List<String> joinedParams = authUrl.getQuery().split('&');
        System.assertEquals(6, joinedParams.size()); // note: additional param from testPath
    }
    
    static testMethod void testGetQueryString() {
    	VleUserContext userContext = buildUserContext();
    	String testQuery = 'fakeParam1=1';
    	String queryString = userContext.getQueryString(testPath, testQuery, VleServices.GET_METHOD);
    	System.assert(queryString.indexOf(testQuery) >=0 );
    }
    
    static testMethod void testCalculateServerSkewFromResponse() {
        VleUserContext userContext = buildUserContext();
        // invalid response
        System.assert(userContext.calculateServerSkewFromResponse('Bad timestamp response') == false);
        System.assertEquals(0, usercontext.getServerSkewMillis());
        // valid response, server in future
        Long serverSeconds = System.currentTimeMillis()/1000 + 30;
        System.assert(userContext.calculateServerSkewFromResponse(VleUserContext.TIMESTAMP_BODY_START + '   ' + serverSeconds));
        System.assert(usercontext.getServerSkewMillis() > 0);
        // valid response, server in past
        serverSeconds = System.currentTimeMillis()/1000 - 30;
        System.assert(userContext.calculateServerSkewFromResponse(VleUserContext.TIMESTAMP_BODY_START + '   ' + serverSeconds));
        System.assert(usercontext.getServerSkewMillis() < 0);
    }
    
    static testMethod void testInterpretResult() {
        VleUserContext userContext = buildUserContext();
        Integer res = userContext.interpretResult(VleServices.OK_STATUS_CODE, 'any of body');
        System.assertEquals(VleServices.RESULT_OKAY, res);
        res = userContext.interpretResult(VleServices.FORBIDDEN_STATUS_CODE, VleUserContext.TIMESTAMP_BODY_START + ' 12345');
        System.assertEquals(VleServices.RESULT_INVALID_TIMESTAMP, res);
        res = userContext.interpretResult(VleServices.FORBIDDEN_STATUS_CODE, VleUserContext.INVALID_TOKEN_ANSWER);
        System.assertEquals(VleServices.RESULT_INVALID_SIG, res);
        res = userContext.interpretResult(VleServices.FORBIDDEN_STATUS_CODE, 'another body');
        System.assertEquals(VleServices.RESULT_NO_PERMISSION, res);
        res = userContext.interpretResult(VleServices.NOT_FOUND_STATUS_CODE, 'still another body');
        System.assertEquals(VleServices.RESULT_UNKNOWN, res);
    }
    
}