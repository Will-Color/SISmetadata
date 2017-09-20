/**
 * Common DAO service for SOQL and DML operations
 * Note: Use 'without sharing' to perform all operation in system mode 
 */
public without sharing class VleDaoServices {

    /**
     * Get list of last modified action records
     * @param num List size
     * @return List of actions
     */
    public static List<Vle_Action__c> getLastSyncActions(Integer num) {
        return [
            SELECT Action__c, LastModifiedDate, Name, Next_Try__c, Note__c, Status__c
            FROM VLE_Action__c
            ORDER BY LastModifiedDate DESC
            LIMIT :num
        ];
    }
    
    /**
     * Retrieve Student programme records with related data like Contact and Programme__c
     * @param studentProgramId ID of Student_Programme__c record
     * @return Student_Programme__c or null
     */
    public static Student_Programme__c findStudentProgrammeInfo(Id studentProgramId) {
        System.debug('Person query');
        List<Student_Programme__c> spList = [
            SELECT Student__c, Student__r.Email,Student__r.RecordType.Name,Student__r.LSTM_Email__c, Student__r.FirstName, Student__r.LastName,
                Student__r.Name, Student__r.Middle_Name_Other_Names__c, Student__r.VLE_ID__c,
                Programme__r.Type__c, Programme__r.Homepage_VLE_ID__c
            FROM Student_Programme__c
            WHERE Id = :studentProgramId
        ];
        System.debug('spList ='+spList);
        return ( spList.isEmpty() ) ? null : spList[0];
    }
    
    /**
     * Retrieve contacts with related module roles
     * @param cList List of contacts
     * @return List of contacts
     */
    public static List<Contact> findStaffWithModuleRoles(List<Contact> cList) {
        System.debug('Suyati VleDaoServices findStaffWithModuleRoles');
        return [
            SELECT Email,LSTM_Email__c,RecordType.Name, FirstName, LastName, Name, Middle_Name_Other_Names__c, VLE_ID__c, VLE_Visibility__c,
                ( SELECT Module__c, Module_Role__c, Module__r.VLE_ID__c, Module__r.VLE_Visibility__c, Staff__c FROM Module_Roles__r )
            FROM Contact
            WHERE Id IN :cList
        ];
    }
    
    /**
     * Retrieve Contact with related module roles
     * @param studentId ID of student
     * @return Contact with related data
     */
    public static Contact findStaffModuleRoles(Id studentId) {
        List<Contact> cList = findStaffWithModuleRoles(new List<Contact>{ new Contact(Id = studentId) });
        return ( cList.isEmpty() ) ? null : cList[0];
    }
    
    /**
     * Retrieve modules by IDs
     * @param moduleIds Set of ID
     * @return List of modules
     */
    public static List<Module__c> findProgrammeModules(Set<Id> moduleIds) {
        return [SELECT VLE_ID__c FROM Module__c WHERE Id IN :moduleIds];
    }
    
    /**
     * Retrieve list of contacts with VLE fields
     * @param cList List of contacts
     * @return List of contacts with VLE fields
     */
    public static List<Contact> findContacts(List<Contact> cList) {
        System.debug('Suyati VleDaoServices findContacts');
        return [SELECT VLE_ID__c, VLE_Visibility__c FROM Contact WHERE Id IN :cList];
    }
    
    /**
     * Retrieve contact by ID with VLE fields
     * @param contactID ID of contact
     * @return Contact or null
     */
    public static Contact findContact(Id contactId) {
        List<Contact> cList = findContacts(new List<Contact>{ new Contact(Id = contactId) });
        return ( cList.isEmpty() ) ? null : cList[0];
    }
    
    /**
     * Retrieve related to list of Module_Role__c data
     * @param mrList List of Module_Role__c records
     * @return List of Module_Role__c with related data
     */
    public static List<Module_Role__c> findModuleRolesData(List<Module_Role__c> mrList) {
        return [
            SELECT Module__c, Module_Role__c, Module__r.VLE_ID__c, Module__r.VLE_Visibility__c,
                Staff__c, Staff__r.VLE_ID__c, Staff__r.VLE_Visibility__c
            FROM Module_Role__c
            WHERE Id IN :mrList
        ];
    }
    
    /**
     * Retrieve related to Module_Role__c data
     * @param mrId ID of Module_Role__c record
     * @return Module_Role__c or null
     */
    public static Module_Role__c findModuleRoleData(Id mrId) {
        List<Module_Role__c> mrList = findModuleRolesData(new List<Module_Role__c>{ new Module_Role__c(Id = mrId) });
        return ( mrList.isEmpty() ) ? null : mrList[0];
    }
    
    /**
     * Detect empty or not empty VLE_ID__c field value
     * @param objName Name of sObject e.g. Contact or Student_Programme__c
     * @param recordId ID of record
     * @return True if VLE_ID__c has a value (not null) 
     */
    public static Boolean hasNotEmptyVleId(String objName, Id recordId) {
        String s = 'SELECT Id FROM ' + objName + ' WHERE Id = :recordId AND VLE_ID__c != NULL';
        System.debug('query >>>> ' + s);
        List<sObject> sObjList = Database.query(s);
        return !sObjList.isEmpty();
    }
    
    /**
     * Do update DML in system mode
     * @param sObjList List of sObject for update
     */
    public static void makeUpdate(List<sObject> sObjList) {
        update sObjList;
    }

    /**
     * Retrieve Module__c data by specified Ids
     * @param moduleIds Set of Module__c record Ids
     * @return List of Module__c records
     */
    public static List<Module__c> findModuleData(Set<Id> moduleIds) {
        return [
            SELECT Id, Vle_Id__c
            FROM Module__c
            WHERE Id IN :moduleIds
        ];
    }   
    
}