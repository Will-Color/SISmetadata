/**
 * Service class for VLE integration
 */
public with sharing class VleServices {
    
    // Name of Custom Settings
    public static final String CS_NAME = 'main';
    
    // HTTP methods
    public static final String DELETE_METHOD =  'DELETE';
    public static final String GET_METHOD =     'GET';
    public static final String POST_METHOD =    'POST';
    public static final String PUT_METHOD =     'PUT';
    
    // Default callout timeout
    public static final Integer HTTP_TIMEOUT = 30000;
    
    // HTTP status codes
    public static final Integer OK_STATUS_CODE = 200;
    public static final Integer FORBIDDEN_STATUS_CODE = 403;
    public static final Integer NOT_FOUND_STATUS_CODE = 404;
    
    // API result constants
    public static final Integer RESULT_UNKNOWN = 0;
    public static final Integer RESULT_OKAY = 1;
    public static final Integer RESULT_INVALID_SIG = 2;
    public static final Integer RESULT_INVALID_TIMESTAMP = 3;
    public static final Integer RESULT_NO_PERMISSION = 4;

    // API auth interfaces
    public interface IAppContext {
        URL createWebUrlForAuthentication(URL resultUri);
        IUserContext createUserContext(String userId, String userKey);
        IUserContext createAnonymousUserContext();
    }
    
    public interface IUserContext {
        Long getServerSkewMillis();
        void setServerSkewMillis(Long millis);
        URL createAuthenticatedUri(String path, String httpMethod);
        Boolean calculateServerSkewFromResponse(String responseBody);
        Integer interpretResult(Integer resultCode, String responseBody);
    }
    
    /**
     * Custom Settings with VLE auth credentials
     */
    public static VLE__c credentials {
        get {
            if ( credentials == null ) {
                credentials = VLE__c.getInstance(CS_NAME);
            }
            return credentials; 
        }
        private set;
    }
    
    /**
     * Custom Settings with Student Role Assignments
     * Returns Programme Type 2 Role VLE ID
     */
    public static Map<String, Long> programType2StudentRoleVleId {
        get {
            if ( programType2StudentRoleVleId == null ){
                programType2StudentRoleVleId = new Map<String, Long>();
                
                for ( VLE_Program_Type_2_Role_VLE_ID_Mapping__c sett : VLE_Program_Type_2_Role_VLE_ID_Mapping__c.getall().values() ){
                    programType2StudentRoleVleId.put( sett.Programme_Type__c, Long.valueOf( sett.Role_VLE_ID__c ) );
                }  
            }
            return programType2StudentRoleVleId;
        }
        private set;
    }

    /**
     * Custom Settings with Staff Role Assignments
     * Returns Programme Type 2 Role VLE ID
     */
    public static Map<String, List<Long>> staffOrgUnitId2RoleVleId {
        get {
            if ( staffOrgUnitId2RoleVleId == null ){
                staffOrgUnitId2RoleVleId = new Map<String, List<Long>>();
                
                for ( VLE_Org_Wide_Units_And_Role_Assignments__c sett : VLE_Org_Wide_Units_And_Role_Assignments__c.getall().values() ){
                    if ( sett.Available_for_Staff__c && sett.Org_Unit_VLE_ID__c != null && sett.Staff_Role_VLE_ID__c != null ){
                        staffOrgUnitId2RoleVleId.put( sett.Org_Unit_VLE_ID__c, new List<Long> { Long.valueOf( sett.Staff_Role_VLE_ID__c ) } );
                    }
                }
            }
            return staffOrgUnitId2RoleVleId;
        }
        private set;
    }

    public static Set<Long> studentOrgUnitIds {
        get{
            if ( studentOrgUnitIds == null ){
                studentOrgUnitIds = new Set<Long>();
                
                for ( VLE_Org_Wide_Units_And_Role_Assignments__c sett : VLE_Org_Wide_Units_And_Role_Assignments__c.getall().values() ){
                    if ( sett.Available_for_Student__c && sett.Org_Unit_VLE_ID__c != null ) {
                        studentOrgUnitIds.add( Long.valueOf( sett.Org_Unit_VLE_ID__c ) );
                    }
                }               
            }
            return studentOrgUnitIds;
        }   
        private set;
    }

    //saff module role 2 list VLE role Ids
    public static Map<String, List<Long>> staffRoles {
        get {
            if ( staffRoles == null ) {
                staffRoles = new Map<String, List<Long>>();
                
                for ( VLE_Staff_Module_Roles_And_Vle_Role_Ids__c sett : VLE_Staff_Module_Roles_And_Vle_Role_Ids__c.getall().values() ) {
                    staffRoles.put( sett.Module_Role__c, new List<Long> { Long.valueOf( sett.Role_VLE_ID__c ) } );
                }
            }
            return staffRoles;
        }
        private set;
    }


    /**
     * Return AppContext instance
     */
    public static IAppContext appContextInstance() {
        return new VleAppContext(credentials.App_ID__c, credentials.App_Key__c, 'https://' + credentials.API_Host__c);
    }
    
    /**
     * Return UserContext instance
     */
    public static IUserContext userContextInstance() {
        return appContextInstance().createUserContext(credentials.User_Id__c, credentials.User_Key__c);
    }
    
    /**
     * Build encrypted digest of value with private key
     * @param secretKey Private key
     * @param saltValue Value for encryption
     * @return Encrypted digest
     */
    public static String buildBase64HashString(String secretKey, String saltValue) {
        String algorithmName = 'HmacSHA256';
        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(saltValue), Blob.valueOf(secretKey));
        String base64Str = EncodingUtil.base64Encode(hmacData);
        // make hash to be URL safe
        String urlSafe = base64Str.replace('+', '-').replace('/', '_').replace('=', '');
        return urlSafe;
    }
    
    /**
     * Make HTTP(s) callout with User Context to VLE API
     * @param path Relative path for API
     * @param httpMethod Method of request e.g. GET or POST
     * @param userContext Instance of User Context
     * @param body String body of request
     * @return HttpResponse or exception (as a rule callout)
     */
    public static HttpResponse performHttpCall(String path, String httpMethod, IUserContext userContext, String body) {
        Http h = new Http();
        
        System.debug(LoggingLevel.ERROR, '@@@ HTTP(' + httpMethod + '), path=' + path);
        HttpRequest req = new HttpRequest();
        req.setTimeout(HTTP_TIMEOUT);
        req.setMethod(httpMethod);
        URL endpoint = userContext.createAuthenticatedUri(path, httpMethod);
        req.setEndpoint(endpoint.toExternalForm());
        System.debug(LoggingLevel.ERROR, '@@@ endpoint=' + endpoint.toExternalForm());
        if ( !String.isBlank(body) ) {
            System.debug(LoggingLevel.ERROR, '@@@ request body: ' + body);
            req.setBody(body);
        }
        
        HttpResponse res = h.send(req);
        System.debug(LoggingLevel.ERROR, '@@@ response body: ' + res.getBody());
        return res;
    }
    
    /**
     * Make HTTP callout without body.
     * See @method performHttpCall()
     */
    public static HttpResponse performHttpCall(String path, String httpMethod, IUserContext userContext) {
        return performHttpCall(path, httpMethod, userContext, null);
    }

    /**
     * Converts Date to String format UTC
     * @param instance of Date
     * @return String in UTC format.
     */
    public static String dateToUTCFormatString(Date d){
        String gmtFormatStr = 'yyyy-MM-dd\'T\'hh:mm:ss.000\'Z\'';
        DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
        return dt.formatGmt(gmtFormatStr);
    }   
    
    /**
     * Converts module name to unique code
     * @param String name of Module
     * @return String unique code 
     */ 
    public static String moduleNameToCode (String name){
        return name.left(5) + System.now().format('dd-MM-yy_hh-mm-ss');
    }   

}