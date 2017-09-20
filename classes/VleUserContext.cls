/**
 * Implementation of UserContext for VLE(desire2learn)
 */
public with sharing class VleUserContext implements VleServices.IUserContext {

	private final String instanceUrl;
	private final String appId;
    private final String appKey;
    private final String userId;
    private final String userKey;
    
	private Long serverSkewMillis = 0;
	
	// Names of query string parameters
	private static final String APP_ID_PARAMETER = 'x_a';
    private static final String USER_ID_PARAMETER = 'x_b';
    private static final String SIGNATURE_BY_APP_KEY_PARAMETER = 'x_c';
    private static final String SIGNATURE_BY_USER_KEY_PARAMETER = 'x_d';
    private static final String TIMESTAMP_PARAMETER = 'x_t';
    
    public static final String INVALID_TOKEN_ANSWER = 'Invalid Token';
    public static final String TIMESTAMP_BODY_START = 'Timestamp out of range';
    
    public VleUserContext(String url, String appId, String appKey, String userId, String userKey) {
        this.instanceUrl = url;
        this.appId = appId;
        this.appKey = appKey;
        this.userId = userId;
        this.userKey = userKey;
    }
    
    private String buildAuthenticatedUriQueryString(String signature, long timestamp) {
        String queryString = '?' + APP_ID_PARAMETER + '=' + appId;
        if ( userId != null ) {
            queryString += '&' + USER_ID_PARAMETER + '=' + userId;
        }
        queryString += '&' + SIGNATURE_BY_APP_KEY_PARAMETER;
        queryString += '=' + VleServices.buildBase64HashString(appKey, signature);
        if ( userId != null ) {
            queryString += '&' + SIGNATURE_BY_USER_KEY_PARAMETER;
            queryString += '=' + VleServices.buildBase64HashString(userKey, signature);
        }
        queryString += '&' + TIMESTAMP_PARAMETER + '=' + timestamp;
        return queryString;
    }
    
    private Long getAdjustedTimestampInSeconds() {
        return (System.currentTimeMillis() + getServerSkewMillis()) / 1000;
    }
    
    private static String formatSignature(String path, String httpMethod, Long timestampSeconds) {
        return httpMethod.toUpperCase() + '&' + path.toLowerCase() + '&' + timestampSeconds;
    }
	
	@TestVisible
	private String getQueryString(String path, String query, String httpMethod) {
        Long adjustedTimestampSeconds = getAdjustedTimestampInSeconds();
        String signature = formatSignature(path, httpMethod, adjustedTimestampSeconds);
        String queryString = buildAuthenticatedUriQueryString(signature, adjustedTimestampSeconds);
        if ( !String.isEmpty(query) ) {
            queryString += '&' + query;
        }
        return queryString;
    }
    
    /**
     * Return the timestamp from server answer if the time between the request and when the server received it is too large
     * @param timestampMessage Body of server response
     * @return Timestamp in seconds or 0 
     */
    private Long tryParseTimestamp(String timestampMessage) {
        Long result = 0;
        Pattern p = Pattern.compile(TIMESTAMP_BODY_START + '\\r*\\n*\\s*(([0-9]+))');
        
        Matcher m = p.matcher(timestampMessage);
        boolean match = m.matches();
        
        if( match && m.groupCount() >= 2 ) {
                result = Long.valueOf(m.group(1));
                return result;
        }
        return result;
    }
	
	public Long getServerSkewMillis() {
		return serverSkewMillis;
	}
	public void setServerSkewMillis(Long millis) {
		serverSkewMillis = millis;
	}
	
	public URL createAuthenticatedUri(String path, String httpMethod) {
		Integer split = path.indexOf('?');
        String query = '';
        if (split >= 0) {
            query = path.substring(split + 1);
            path = path.substring(0, split);
        }
        String queryString = getQueryString(path, query, httpMethod);
        return new URL(instanceUrl + path + queryString);
	}
	
	public Boolean calculateServerSkewFromResponse(String responseBody) {
		Long serverTimestampSeconds = tryParseTimestamp(responseBody);
        if ( serverTimestampSeconds > 0 ) {
            setServerSkewMillis(serverTimestampSeconds * 1000 - System.currentTimeMillis());
            return true;
        }
        return false;
	}
	
	public Integer interpretResult(Integer resultCode, String responseBody) {
		if ( resultCode == VleServices.OK_STATUS_CODE ) {
            return VleServices.RESULT_OKAY;
        } else if ( resultCode == VleServices.FORBIDDEN_STATUS_CODE ) {
            if ( calculateServerSkewFromResponse(responseBody) ) {
                return VleServices.RESULT_INVALID_TIMESTAMP;
            } else if ( responseBody.equals(INVALID_TOKEN_ANSWER) ) {
                return VleServices.RESULT_INVALID_SIG;
            } else {
                return VleServices.RESULT_NO_PERMISSION;
            }
        }
        return VleServices.RESULT_UNKNOWN;
	}
	
}