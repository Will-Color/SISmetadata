/**
 * @author Mykola Senyk
 * @date 16/06/2014
 * @description Helper library of common utils
 */
public class CommonUtils {

    /**
     * Custom exception class
     */
    public class ApplicationException extends Exception {}
    
    /**
     * Supported sObject by API name
     * Please, add needed name of sObject in the set below
     */
    private static Set<String> supportedSObjTypes = new Set<String> { 'Contact', 'HESA_Code__c', 'Module_Version__c', 'Opportunity', 'Programme_Version__c', 'Qualifications_Experience__c' };
    
    private static Map<String,Map<String,Id>> rtDevMap {
        get {
            if ( rtDevMap == null ) {
                buildRtMaps();
            }
            return rtDevMap;
        }
    }
    
    /**
     * Cached profile map
     */
    public static Map<String,Profile> profileMap {
        get {
            if ( profileMap == null ) {
                buildProfileMaps();
            }
            return profileMap;
        }
    }
    
    /**
     * Build lazy-load RecordType map for DeveloperName
     */
    private static void buildRtMaps() {
        rtDevMap = new Map<String,Map<String,Id>>();
        for(RecordType rt: [SELECT Id, Name, DeveloperName, SObjectType FROM RecordType WHERE SObjectType IN :supportedSObjTypes AND isActive = TRUE]) {
            // by DeveloperName
            Map<String,Id> rtNameToId = rtDevMap.get(rt.SObjectType);
            if ( rtNameToId == null ) {
                rtNameToId = new Map<String,Id>();
                rtDevMap.put(rt.SObjectType, rtNameToId);
            }
            rtNameToId.put(rt.DeveloperName, rt.Id);
        }
    }
    
    /**
     * Build lazy-load map with key = Profile.Name and value = Profile
     */
    private static void buildProfileMaps() {
        profileMap = new Map<String,Profile>();
        for (Profile p: [SELECT Id, Name, UserType FROM Profile]) {
            profileMap.put(p.Name, p);
        }
    }
    
    /**
     * Get from cache ID of RecordType for sObject by DeveloperName
     * @param sObjName Name of sObject like 'Product2'
     * @param rtDevName DeveloperName of RecordType
     * @return ID of RecordType
     */
    public static Id findRecordTypeIdByDev(String sObjName, String rtDevName) {
        if ( !supportedSObjTypes.contains(sObjName) ) 
            throw new ApplicationException('RecordTypeId for "' + sObjName + '" is not supported');
        return rtDevMap.get(sObjName).get(rtDevName);
    }
    
    /**
     * Check if some of coma-separated field in the object is empty (blank)
     * @param sObj sObject with fields
     * @param fieldNames Coma-separated field names
     * @return True if any empty fielda is present
     */
    public static Boolean hasEmptyFields(sObject sObj, String fieldNames) {
        for (String fieldName: fieldNames.split(',')) {
            Object val = sObj.get(fieldName);
            if ( val instanceof String ) {
                if ( String.isBlank((String) val) ) {
                    return true;
                }
            }
            else {
                if (val != null)
                    return false;
            }
        }
        return false;
    }
    
    /**
     * Return true if all coma-separated fields in sObject are empty
     * @param sObj sObject with fields
     * @param fieldNames Coma-separated field names
     * @return True if all fields are empty
     */
    public static Boolean allFieldsAreEmpty(sObject sObj, String fieldNames) {
        for (String fieldName: fieldNames.split(',')) {
            Object val = sObj.get(fieldName);
            if ( val instanceof String ) {
                if ( ! String.isBlank((String) val) ) {
                    return false;
                }
            }
            else {
                if (val != null)
                    return false;
            }
        }
        return true;
    }
    
    /**
     * Check if there is any attachment for ID
     * @param parentId ID of parent sObject
     * @return True if attachment was found
     */
    public static Boolean hasAttachment(Id parentId) {
        List<Attachment> attList = [SELECT Id FROM Attachment WHERE ParentId = :parentId LIMIT 1];
        return !attList.isEmpty();
    }
    
    /**
     * Get all attachments for parentId
     * @param parentId ID of parent object
     * @return List of attachments
     */
    public static List<Attachment> findAttachments(Id parentId) {
        return [SELECT Name FROM Attachment WHERE ParentId = :parentId];
    }
    
    /**
     * Get list of attachments for parentId and certain description
     * @param parentId ID of parent object
     * @param description Description of attachment
     * @return List of attachments
     */
    public static List<Attachment> findAttachments(Id parentId, String description) {
        return [SELECT Name FROM Attachment WHERE ParentId = :parentId AND Description = :description];
    }

    /**
     * get map were key = sObject field name  value is Sobject value.
     * Supports field name which contains parent/child relations up to one leevl
     * @param Sobject instance
     * @param List of field names of Sobject so
     * @return Map field name to value
     */
    public static Map<String, Object> deserializeUntyped (SObject so, List<String> fieldNames){
        Map<String, Object> result = new Map<String, Object>();
        for (String fieldName : fieldNames){
            
            if (fieldName.contains('.')){
                Sobject parentSo = so.getSObject(fieldName.split('\\.').get(0));    
                Object value = parentSo == null ? '' : parentSo.get( fieldName.split('\\.').get(1) );
                result.put(fieldName, value);
            } else {
                result.put(fieldName, so.get(fieldName));
            }
        }
        return result;
    }   


    /**
     * gets Api field Names from FieldSetMemnber instances
     * @param fields FieldSetMember instances
     * @return List of Api field Names
     */    
    public static List<String> getFieldNames(List<Schema.FieldSetMember> fields){
        List<String> fieldNames = new List<String>();
        for (Schema.FieldSetMember field : fields){
            fieldNames.add( field.FieldPath );
        }
        return fieldNames;      
    }
    
}