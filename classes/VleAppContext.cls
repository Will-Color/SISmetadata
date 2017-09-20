/**
 * Implementation of AppContext for VLE(desire2learn)
 */
public with sharing class VleAppContext implements VleServices.IAppContext {
	
	// URL names of parameters
	@TestVisible
	private static final String APP_ID_PARAMETER = 'x_a';
    private static final String APP_KEY_PARAMETER = 'x_b';
    private static final String CALLBACK_URL_PARAMETER = 'x_target';
    
    // fields
	private final String appId;
    private final String appKey;
    private final String url;
    
    // path for authentication
    public static final String AUTHENTICATION_SERVICE_URI_PATH = '/d2l/auth/api/token';
    
    public VleAppContext(String appId, String appKey, String url) {
    	this.appId = appId;
    	this.appKey = appKey;
    	this.url = url;
    }
    
    private String buildAuthenticationUriQueryString(URL callbackUri) {
        String callbackUriString = callbackUri.toExternalForm();
        String uriHash = VleServices.buildBase64HashString(appKey, callbackUriString);
        String result = APP_ID_PARAMETER + '=' + appId;
        result += '&' + APP_KEY_PARAMETER + '=' + uriHash;
        result += '&' + CALLBACK_URL_PARAMETER + '=' + EncodingUtil.urlEncode(callbackUriString, 'UTF-8');
        return result;
    }
    
    public URL createWebUrlForAuthentication(URL resultUri) {
    	return new URL(url + AUTHENTICATION_SERVICE_URI_PATH + '?' + buildAuthenticationUriQueryString(resultUri));
    }
        
	public VleServices.IUserContext createUserContext(String userId, String userKey) {
		return new VleUserContext(url, appId, appKey, userId, userKey);
	}
	
	public VleServices.IUserContext createAnonymousUserContext() {
		return new VleUserContext(url, appId, appKey, null, null);
	}
	
}