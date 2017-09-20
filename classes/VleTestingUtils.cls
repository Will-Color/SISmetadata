/** 
 * Helper class for testing VLE integration
 */
public with sharing class VleTestingUtils {
    
    // Test constants
    public static final String STUDENT_LAST_NAME = 'Doe';
    public static final String PROGRAMME_VERSION_CODE = 'ABC';
    public static final String PROGRAMME_INSTANCE_SUFFIX = '1234';
    public static final Integer PROGRAMME_HOME_EU_FEE = 1000;
    public static final Integer PROGRAMME_OVERSEAS_FEE = 1250;
    public static final String STUDENT_EMAIL = 'student@mail.com';
    
    /**
     * Create Contact as Student
     * @param doInsert If true DML will be performed
     * @return Just created Contact
     */
    public static Contact createStudent(Boolean doInsert) {
        Contact st = new Contact(LastName = STUDENT_LAST_NAME, Email = STUDENT_EMAIL);
        if ( doInsert ) insert st;
        return st;
    }
    
    /**
     * Create Contact as Staff person
     * @param doInsert If true DML will be performed
     * @return Just created Contact
     */
    public static Contact createStaff(Boolean doInsert) {
        Contact st = new Contact(LastName = STUDENT_LAST_NAME, RecordTypeId = CommonUtils.findRecordTypeIdByDev('Contact', 'Staff'));
        if ( doInsert ) insert st;
        return st;
    }
    
    /**
     * This method creates a new master Programme_Version__c object
     * @param String pvName Created programme version name
     * @param Id rtId Created programme version record type id
     * @param String pvType Created programme version type
     * @param Boolean doInsert Flag indicates that results will be inserted in database immediately
     * @return Programme_Version__c programmeVersion
     */
    public static Programme_Version__c createMasterProgrammeVersion(String pvName, Id rtId, String pvType, Boolean doInsert) {
        Programme_Version__c programmeVersion = (Programme_Version__c)Programme_Version__c.sObjectType.newSobject(null, true);
        programmeVersion.Name = pvName;
        programmeVersion.Programme_Type__c = pvType;
        programmeVersion.RecordTypeId = rtId;
        programmeVersion.Code__c = PROGRAMME_VERSION_CODE;
        if(doInsert) insert programmeVersion;
        return programmeVersion;
    }
    
    /**
     * This method creates a new child Programme_Version__c object
     * @param String pvName Created programme version name
     * @param Id rtId Created programme version record type id
     * @param String pvType Created programme version type
     * @param Id masterLinkId Created programme version master link
     * @param Boolean doInsert Flag indicates that results will be inserted in database immediately
     * @return Programme_Version__c programmeVersion
     */
    public static Programme_Version__c createProgrammeVersion(String pvName, Id rtId, String pvType, Id masterLinkId, Boolean doInsert) {
        Programme_Version__c programmeVersion = (Programme_Version__c)Programme_Version__c.sObjectType.newSobject(null, true);
        programmeVersion.Name = pvName;
        programmeVersion.Programme_Type__c = pvType;
        programmeVersion.RecordTypeId = rtId;
        programmeVersion.Code__c = PROGRAMME_VERSION_CODE;
        programmeVersion.Master_Link__c = masterLinkId;
        if(doInsert) insert programmeVersion;
        return programmeVersion;
    }
    
    /**
     * This method creates a new Programme__c object
     * @param String pName Created programme name
     * @param Id versionId Created programme vresion Id
     * @param Boolean doInsert Flag indicates that programme will be inserted in database immediately
     * @return Programme__c programme
     */
    public static Programme__c createProgramme(String pName, Id versionId, Boolean doInsert) {
        Programme__c programme = (Programme__c)Programme__c.sObjectType.newSobject(null, true);
        programme.Name = pName;
        programme.Programme_Version__c = versionId;
        programme.Active__c = true;
        programme.Start_Date__c = Date.today().toStartOfMonth().addYears(1);
        programme.End_Date__c = Date.today().toStartOfMonth().addYears(3);
        programme.Home_EU_Fee__c = PROGRAMME_HOME_EU_FEE;
        programme.Overseas_Fee__c = PROGRAMME_OVERSEAS_FEE;
        programme.Instance_Suffix__c = PROGRAMME_INSTANCE_SUFFIX;
        programme.Test_Class_Record__c = True ;
        if(doInsert) insert programme;
        return programme;
    }
    
    /**
     * Create Module__c record
     * @param doInsert If true DML will be performed
     * @return Module__c
     */
    public static Module__c createModule(String name, String vleId, Boolean doInsert) {
        Boolean isVleVisible = !String.isBlank(vleId);
        Module__c m = new Module__c(Active__c = true, Name = name, VLE_ID__c = vleId, VLE_Visibility__c = isVleVisible, Test_Class_Record__c = true);
        if ( doInsert ) insert m;
        return m;
    }
    
    /**
     * Create Student Programme
     * @param rogrammeId ID of programme
     * @param studentId ID of Contact
     * @param doInsert If true DML will be performed
     * @return Just created Student programme
     */
    public static Student_Programme__c createStudentProgramme(Id programmeId, Id studentId, Boolean doInsert) {
        Student_Programme__c sp = new Student_Programme__c(
            Programme__c = programmeId, Student__c = studentId, Name = ApplyServices.DUMMY_REQUIRED_STRING,
            Stage__c = ApplyServices.COURSE_INIT_STAGE_NAME,Test_Class_Record__c = True
        );
        if ( doInsert ) {
            insert sp;
        }
        return sp;
    }
    
    /**
     * Create junction object Module_Role__c
     * @param c Staff person
     * @param m Module
     * @param roleName Value for Module_Role__c field
     * @return Record
     */
    public static Module_Role__c createModuleRole(Contact c, Module__c m, String roleName, Boolean doInsert) {
        Module_Role__c mr = new Module_Role__c(
            Staff__c = c.Id, Module__c = m.Id, Module_Role__c = roleName
        );
        if ( doInsert ) insert mr;
        return mr;
    }

}