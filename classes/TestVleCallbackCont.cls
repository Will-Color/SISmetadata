/**
 * Unit test for VleCallbackCont page controller
 */
@isTest
private class TestVleCallbackCont {
	
	static String testUserId = 'user_id';
	static String testUserKey = 'user_key';

	static void setupCredentials() {
		VLE__c vle = new VLE__c(
			Name = VleServices.CS_NAME, API_Host__c = 'vle-host.com', App_ID__c = 'app_id', App_Key__c = 'app_key',
			User_ID__c = '_id', User_Key__c = '_key'
		); 
		insert vle;
	}
	
    static testMethod void testController() {
    	setupCredentials();
    	// without params
        VleCallbackCont cont = new VleCallbackCont();
        cont.checkToken();
        VLE__c vle = VleServices.credentials;
        System.assertNotEquals(vle.User_ID__c, testUserId);
        System.assertNotEquals(vle.User_Key__c, testUserKey);
        
        // with bad signature
		Test.setCurrentPageReference(new PageReference('Page.VleCallback'));
		System.currentPageReference().getParameters().put('x_a', testUserId);
		System.currentPageReference().getParameters().put('x_b', testUserKey);
		System.currentPageReference().getParameters().put('x_c', 'fake_signature');
		cont = new VleCallbackCont();
        cont.checkToken();
        VleServices.credentials = null;
        vle = VleServices.credentials;
        System.assertNotEquals(vle.User_ID__c, testUserId);
        System.assertNotEquals(vle.User_Key__c, testUserKey);
        
        // valid
		String sig = VleServices.buildBase64HashString(vle.App_Key__c, testUserId + '&' + testUserKey);
        System.currentPageReference().getParameters().put('x_c', sig);
		cont = new VleCallbackCont();
        cont.checkToken();
        VleServices.credentials = null;
        vle = VleServices.credentials;
        System.assertEquals(vle.User_ID__c, testUserId);
        System.assertEquals(vle.User_Key__c, testUserKey);
    }
    
}