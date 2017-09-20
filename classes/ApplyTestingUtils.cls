/**
 * @author Valentyn Bilenkyy
 * @date 17/06/2014
 * @description Utility class
 */
/***** Modifications
 ** @author MKM
 ** done for workstream B2 (Data Model fix) Relating Reference to Student Program and Qalification to Student (Contact)[Note: We have to further analyse the impact on the existing data due to the change inrelation and communicate to client before actual implementation} on  15-06-2015 **** 
 */
/// <summary>Edited Soql and removed the usage of Student_Programme on line 200 </summary>
public with sharing class ApplyTestingUtils {
    
    // Constants of profile names
    public static final String CUSTOMER_COMMUNITY_PROFILE_NAME = 'LSTM Community User';
    public static final String SYSADMIN_PROFILE_NAME = 'System Administrator';
    
    // Test constants
    public static final String PROGRAMME_NAME = 'Tropical Medicine';
    public static final String STUDENT_LAST_NAME = 'Doe';
    public static final String REFEREE_LAST_NAME = 'Jackson';
    public static final String PROGRAMME_VERSION = 'Programme_Version__c';
    public static final String PROGRAMME_VERSION_CODE = 'ABC';
    public static final String PROGRAMME_TYPE = ApplyServices.PT_MSC_PROGRAMME;
    public static final String PROGRAMME_INSTANCE_SUFFIX = '1234';
    public static final Integer PROGRAMME_HOME_EU_FEE = 1000;
    public static final Integer PROGRAMME_OVERSEAS_FEE = 1250;
    public static final String INDIVIDUAL_ACCOUNT_NAME = 'Individuals';

    // Test Programmes by types
    public static Programme__c PROG_MSC_PROGRAMME;
    public static Programme__c PROG_PROFESSIONAL_DIPLOMA;
    public static Programme__c PROG_MASTERS_MODULE;
    public static Programme__c PROG_SHORT_COURSE;
    public static Programme__c PROG_PGT;
    public static Programme__c PROG_PGR;

    // Test Student Programmes by types
    public static Student_Programme__c ST_PROG_MSC_PROGRAMME;
    public static Student_Programme__c ST_PROG_PROFESSIONAL_DIPLOMA;
    public static Student_Programme__c ST_PROG_MASTERS_MODULE;
    public static Student_Programme__c ST_PROG_SHORT_COURSE;
    public static Student_Programme__c ST_PROG_PGT;
    public static Student_Programme__c ST_PROG_PGR;
    
    // Properties of createTestData() method
    public static Programme__c prog { get; set; }
    public static Student_Programme__c sp { get; set; }
    public static Contact student { get; set; }
    public static List<Qualifications_Experience__c> qualifications { get; set; }
    public static List<References__c> references { get; set; }
    public static List<HESA_Code__c> hesaCodes { get; set; }
    
    /**
     * Create user instance for certain profile without DML
     * @param lastName Surname of user
     * @param email User's email
     * @param profileName Name of profile
     * @return User not inserted
     */
    public static User buildUser(String lastName, String email, String profileName) {
        Profile pf = CommonUtils.profileMap.get(profileName);
        User u = new User(
            Alias = 'alias', CommunityNickname = email.split('@')[0], CompanyName = 'Test Company', Email = email,
            EmailEncodingKey = 'ISO-8859-1', IsActive = true, LanguageLocaleKey = 'en_US', LastName = lastName,
            LocaleSidKey = 'en_US', ProfileId = pf.Id, TimeZoneSidKey = 'America/New_York', Username = email
        );
        return u;
    }
    
    /**
     * Create User for Customer Community
     * @param lastName Surname of user
     * @param email User's email
     * @param profileName Name of profile for customer community
     * @return User 
     */
    public static User createCommunityUser(String lastName, String email, String profileName) {
        // create sysadmin with UserRole
        UserRole r = new UserRole(Name = 'a' + lastName, OpportunityAccessForAccountOwner = 'Edit');
        insert r;
        User sysadmin = buildUser('a' + lastName, 'a' + email, SYSADMIN_PROFILE_NAME);
        sysadmin.UserRoleId = r.Id;
        insert sysadmin;
                
        
        User commUser;
        System.runAs(sysadmin) {
            // create community user with Contact and Account
            Account a = new Account(Name = 'Community Account');
            insert a;
            Contact c = new Contact(LastName = lastName, AccountId = a.Id);
            insert c;
            commUser = buildUser(lastName, email, CUSTOMER_COMMUNITY_PROFILE_NAME);
            commUser.ContactId = c.Id;
            insert commUser;
        }
        return commUser;
    }

    /**
     * This method creates a new master Programme_Version__c object
     * @param String pvName Created programme version name
     * @param Id rtId Created programme version record type id
     * @param String pvType Created programme version type
     * @param Boolean doInsert Flag indicates that results will be inserted in database immediately
     * @return Programme_Version__c programmeVersion
     */
    public static Programme_Version__c createProgrammeVersion(String pvName, Id rtId, String pvType, Boolean doInsert) {
        Programme_Version__c programmeVersion = (Programme_Version__c)Programme_Version__c.sObjectType.newSobject(null, true);
        programmeVersion.Name = pvName;
        programmeVersion.Programme_Type__c = pvType;
        programmeVersion.RecordTypeId = rtId;
        programmeVersion.Code__c = PROGRAMME_VERSION_CODE;
        //Suyati Modified Start
        programmeVersion.Application_Form_Type__c = 'Standard';
        //Suyati Modified Start
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
        programme.Test_Class_Record__c = true;
        if(doInsert) insert programme;
        return programme;
    }

    /**
     * This method creates a list of new Programme__c objects
     * @param String pName Created programme name
     * @param Id versionId Created programme vresion Id
     * @param Integer count Number of created objects
     * @param Boolean doInsert Flag indicates that results will be inserted in database immediately
     * @return List<Programme__c> results
     */
    public static List<Programme__c> createProgramme(String pName, Id versionId, Integer count, Boolean doInsert) {
        List<Programme__c> results = new List<Programme__c>();
        for(Integer i = 0; i < count; i++) {
            Programme__c p = createProgramme(pName + ' ' + String.valueOf(i), versionId, false);
            p.Test_Class_Record__c = true;
            results.add(p);
        }
        if(doInsert) insert results;
        return results;
    }
    
    /**
     * Create Contact as Student
     * @param doInsert If true DML will be performed
     * @return Just created Contact
     */
    public static Contact createStudent(Boolean doInsert) {
        Contact st = new Contact(LastName = STUDENT_LAST_NAME);
        if ( doInsert ) insert st;
        return st;
    }
    
    /**
     * Create Student Programme
     * @param rogrammeId ID of programme
     * @param studentId ID of Contact
     * @param doInsert If true DML will be performed
     * @return Just created Student programme
     */
    public static Student_Programme__c createOpportunity(Id programmeId, Id studentId, Boolean doInsert) {
        Student_Programme__c course = new Student_Programme__c(
            Programme__c = programmeId, Student__c = studentId, Name = ApplyServices.DUMMY_REQUIRED_STRING,
            Stage__c = ApplyServices.COURSE_INIT_STAGE_NAME,Test_Class_Record__c = True
        );
        if ( doInsert ) insert course;
        return course;
    }
    
    /**
     * Create Qualifications_Experience__c
     * @param contactId ID of student
     * @param oppId ID of Student Programme
     * @param rtDevName DeveloperName of RecordType
     * @param doInsert If true DML will be performed
     * @return Just created Qualifications_Experience__c instance
     */
    public static Qualifications_Experience__c createQualification(Id contactId, Id oppId, String rtDevName, Boolean doInsert) {
        Qualifications_Experience__c qe = new Qualifications_Experience__c(
            Contact__c = contactId, RecordTypeId = CommonUtils.findRecordTypeIdByDev('Qualifications_Experience__c', rtDevName)
        );
        qe.Test_Class_Record__c = true;
        if ( doInsert ) insert qe;
        return qe;
    }
    
    /**
     * Create References__c
     * @param contactId ID of master Contact
     * @param oppId Id of Student Programme
     * @param refereeLastName LastName of referee
     * @return Just created and insterted References__c
     */
    public static References__c createReference(Id contactId, Id oppId, String refereeLastName) {
        Contact referee = new Contact(LastName = refereeLastName);
        insert referee;
        References__c ref = new References__c(Applicant__c = contactId, Student_Programme__c = oppId, Referee__c = referee.Id);
        insert ref;
        return ref;
    }
    
    /**
     * Create test amount of HESA_Code__c records
     * @return List of HESA Nationalities and Domicile
     */
    public static List<HESA_Code__c> createHESAs() {
        // add HESA Nationality and Domicile
        List<HESA_Code__c> hesaList = new List<HESA_Code__c>();
        HESA_Code__c hesa = new HESA_Code__c(
            Name = 'United Kingdom', RecordTypeId = CommonUtils.findRecordTypeIdByDev('HESA_Code__c', ApplyWizardContExt.NATIONALITY_RT),
            EEA_Nationality__c = true
        );
        hesaList.add(hesa); // [0]
        hesa = new HESA_Code__c(
            Name = 'France', RecordTypeId = CommonUtils.findRecordTypeIdByDev('HESA_Code__c', ApplyWizardContExt.NATIONALITY_RT),
            EEA_Nationality__c = true
        );
        hesaList.add(hesa); // [1]
        hesa = new HESA_Code__c(
            Name = 'Angola', RecordTypeId = CommonUtils.findRecordTypeIdByDev('HESA_Code__c', ApplyWizardContExt.NATIONALITY_RT),
            EEA_Nationality__c = false
        );
        hesaList.add(hesa); // [2] nationality nonEEA
        hesa = new HESA_Code__c(Name = 'United Kingdom, not otherwise specified', RecordTypeId = CommonUtils.findRecordTypeIdByDev('HESA_Code__c', ApplyWizardContExt.DOMICILE_RT));
        hesaList.add(hesa); // [3]
        hesa = new HESA_Code__c(Name = 'Domicile', RecordTypeId = CommonUtils.findRecordTypeIdByDev('HESA_Code__c', ApplyWizardContExt.DOMICILE_RT));
        hesaList.add(hesa); // [4]
        insert hesaList;
        return hesaList;
    }
    
    /**
     * Prepare common data for testing
     */
    public static void setupTestData() {
        // add single master version => version => programme => student programme
        Id mvrtId = CommonUtils.findRecordTypeIdByDev(PROGRAMME_VERSION, ApplyServices.RT_MASTER_PV_DEVNAME);
        Programme_Version__c mv = createProgrammeVersion(PROGRAMME_NAME, mvrtId, PROGRAMME_TYPE, true);
        Id rtId = CommonUtils.findRecordTypeIdByDev(PROGRAMME_VERSION, ApplyServices.RT_VERSION_PV_DEVNAME);
        Programme_Version__c pv = createProgrammeVersion(PROGRAMME_NAME, rtId, PROGRAMME_TYPE, mv.Id, true);
        prog = createProgramme(PROGRAMME_NAME, pv.Id, true);
        student = createStudent(true);
        sp = createOpportunity(prog.Id, student.Id, true);
        // add qualifications
        qualifications = new List<Qualifications_Experience__c>();
        Qualifications_Experience__c qe = createQualification(student.Id, sp.Id, ApplyServices.RT_ACADEMIC_QE_DEVNAME, false);
        qe.Country__c = ApplyServices.COUNTRY_UK; // for check Visa History
        qe.Qualification__c = 'Qualification Name';
        qualifications.add(qe);
        qe = createQualification(student.Id, sp.Id, ApplyServices.RT_ACADEMIC_QE_DEVNAME, false);
        qe.Qualification__c = 'Qualification Name';
        qualifications.add(qe);
        qe = createQualification(student.Id, sp.Id, ApplyServices.RT_LANGUAGE_QE_DEVNAME, false);
        qe.Qualification__c = 'Qualification Name';
        qualifications.add(qe);
        qe = createQualification(student.Id, sp.Id, ApplyServices.RT_PROFESSIONAL_QE_DEVNAME, false);
        qe.Qualification__c = 'Qualification Name';
        qualifications.add(qe);
        qe = createQualification(student.Id, sp.Id, ApplyServices.RT_EXPERIENCE_QE_DEVNAME, false);
        qe.Qualification__c = 'Qualification Name';
        qualifications.add(qe);
        insert qualifications;
        // add multiple master version => version => programme => student programme
        List<String> ptList = new List<String> { ApplyServices.PT_MSC_PROGRAMME, ApplyServices.PT_PROFESSIONAL_DIPLOMA, ApplyServices.PT_MASTERS_MODULE, ApplyServices.PT_SHORT_COURSE, ApplyServices.PT_PGT, ApplyServices.PT_PGR };
        List<Programme_Version__c> mvList = new List<Programme_Version__c>();
        for (String pt: ptList) {
            mvList.add(createProgrammeVersion(pt + ' Name', mvrtId, pt, false));
        }
        insert mvList;
        List<Programme_Version__c> pvList = new List<Programme_Version__c>();
        for (Integer i=0; i<ptList.size(); i++) {
            String pt = ptList[i];
            pvList.add(createProgrammeVersion(pt + ' Name', rtId, pt, mvList[i].Id, false));
            
        }
        insert pvList;
        List<Programme__c> pList = new List<Programme__c>();
        PROG_MSC_PROGRAMME = createProgramme(ApplyServices.PT_MSC_PROGRAMME + ' Name', pvList[0].Id, false);
        pList.add(PROG_MSC_PROGRAMME);
        PROG_PROFESSIONAL_DIPLOMA = createProgramme(ApplyServices.PT_PROFESSIONAL_DIPLOMA + ' Name', pvList[1].Id, false);
        pList.add(PROG_PROFESSIONAL_DIPLOMA);
        PROG_MASTERS_MODULE = createProgramme(ApplyServices.PT_MASTERS_MODULE + ' Name', pvList[2].Id, false);
        pList.add(PROG_MASTERS_MODULE);
        PROG_SHORT_COURSE = createProgramme(ApplyServices.PT_SHORT_COURSE + ' Name', pvList[3].Id, false);
        pList.add(PROG_SHORT_COURSE);
        PROG_PGT = createProgramme(ApplyServices.PT_PGT + ' Name', pvList[4].Id, false);
        pList.add(PROG_PGT);
        PROG_PGR = createProgramme(ApplyServices.PT_PGR + ' Name', pvList[5].Id, false);
        pList.add(PROG_PGR);
        System.debug(LoggingLevel.ERROR, '@@@ ' + pList);
        insert pList;
        List<Student_Programme__c> spList = new List<Student_Programme__c>();
        ST_PROG_MSC_PROGRAMME = createOpportunity(PROG_MSC_PROGRAMME.Id, student.Id, false);
        spList.add(ST_PROG_MSC_PROGRAMME);
        ST_PROG_PROFESSIONAL_DIPLOMA = createOpportunity(PROG_PROFESSIONAL_DIPLOMA.Id, student.Id, false);
        spList.add(ST_PROG_PROFESSIONAL_DIPLOMA);
        ST_PROG_MASTERS_MODULE = createOpportunity(PROG_MASTERS_MODULE.Id, student.Id, false);
        spList.add(ST_PROG_MASTERS_MODULE);
        ST_PROG_SHORT_COURSE = createOpportunity(PROG_SHORT_COURSE.Id, student.Id, false);
        spList.add(ST_PROG_SHORT_COURSE);
        ST_PROG_PGT = createOpportunity(PROG_PGT.Id, student.Id, false);
        spList.add(ST_PROG_PGT);
        ST_PROG_PGR = createOpportunity(PROG_PGR.Id, student.Id, false);
        spList.add(ST_PROG_PGR);
        insert spList;
        // add references
        references = new List<References__c>();
        References__c ref = createReference(student.Id, sp.Id, REFEREE_LAST_NAME);
        references.add(ref);
        // add nationalities and domicile
        hesaCodes = createHESAs();
        //Create the 'Individual' account record
        Account individualAccount = new Account(Name=INDIVIDUAL_ACCOUNT_NAME);
        insert individualAccount;
        
    }
}