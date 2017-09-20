/**
 * @author Mykola Senyk
 * @date 13/06/2014
 * @description Service class for application form for apply new student to the programme
 */
/***** Modifications
** @author MKM
** done for workstream B2 Relating Reference to Student Program and Qalification to Student (Contact)[Note: We have to further analyse the impact on the existing data due to the change inrelation and communicate to client before actual implementation} on  15-06-2015 *****/
/// <summary>Edited Soql and removed the usage of Student_Programme on line 290,300 and 280 </summary>
/***** Modifications #2
**done for save and proceed validation 
<summary> added new field(registration_password__c ) to the soql query on line 276 on function finddetails so that we can check is there is any values exist in it 
*/
public class ApplyServices {
    
    // Cached value of HESA_Code__c
    private static HESA_Code__c cachedHesaCode;

    // Default temporary value for all required Text field
    public static final String DUMMY_REQUIRED_STRING = '_DUMMY_';
    
    // Name for account that parent for all students records created by salesforce user
    public static final String ACCOUNT_NAME_FOR_SF_CONTACTS = 'Individuals';
    
    //Name of Individual Account 
    public static final String INDIVIDUAL_ACCOUNT_NAME = 'Individuals';
    
    // Programme_Version__c Mode constants
    public static final String PV_MODE_FT = 'FT';
    public static final String PV_MODE_PT = 'PT';
    
    // Constants for common picklist yes/no
    public static final String PICKLIST_YES = 'Yes';
    public static final String PICKLIST_NO = 'No';
    
    // Stage names for Student_Programme__c
    public static final String COURSE_INIT_STAGE_NAME =             'Draft';
    public static final String COURSE_SUBMITTED_STAGE_NAME =        'Submitted';
    public static final String COURSE_EXPECTED_STAGE_NAME =         'Expected';
    public static final String COURSE_PRE_REGISTERED_STAGE_NAME =   'Pre-Registered';
    
    // Name of countries (from picklist) 
    public static final String COUNTRY_UK =         'United Kingdom';
    public static final String COUNTRY_IRELAND =    'Ireland';
    
    // RecordType developer name for Programme_Version__c
    public static final String RT_MASTER_PV_DEVNAME = 'Master_Version';
    public static final String RT_VERSION_PV_DEVNAME = 'Versions';
    
    // RecordType developer name for Module_Version__c
    public static final String RT_MASTER_MV_DEVNAME = 'Master_Version';
    public static final String RT_VERSION_MV_DEVNAME = 'Versions';
    
    // RecordType developer name for Qualifications_Experience__c object
    public static final String RT_ACADEMIC_QE_DEVNAME =     'Academic_University_Qualifications';
    public static final String RT_LANGUAGE_QE_DEVNAME =     'Language_Qualifications';
    public static final String RT_PROFESSIONAL_QE_DEVNAME = 'Professional_Qualifications';
    public static final String RT_EXPERIENCE_QE_DEVNAME =   'Experience';
    
    // Constants step names
    public static final String STEP_WELCOME =                       'welcome';
    public static final String STEP_PERSONAL_NAME =                 'personal name';
    public static final String STEP_PERSONAL_ADDRESS =              'personal address';
    public static final String STEP_ACADEMIC_QUALIFICATIONS =       'academic qualifications';
    public static final String STEP_LANGUAGE_QUALIFICATIONS =       'language qualifications';
    public static final String STEP_PROFESSIONAL_QUALIFICATIONS =   'professional qualifications';
    public static final String STEP_EXPERIENCE =                    'experience';
    public static final String STEP_PERSONAL_STATEMENT =            'personal statement';
    public static final String STEP_RESEARCH_PROPOSAL =             'research proposal';
    public static final String STEP_REFERENCES =                    'references';
    public static final String STEP_FEES_AND_FUNDING =              'fees and funding';
    public static final String STEP_VISA_HISTORY =                  'visa history';
    public static final String STEP_EQUAL_OPPORTUNITIES =           'equal opportunities';
    public static final String STEP_DECLARATION =                   'declaration';
    
    //Suyati Modified Start
    //Step names for short courses
    public static final String STEP_WELCOME_SHORT = 'welcome short';
    public static final String STEP_PERSONAL_DETAILS_SHORT = 'personal details short';
    public static final String STEP_LANGUAGE_QUALIFICATIONS_SHORT = 'language qualifications short';
    public static final String STEP_QUALIFICATION_EMPLOYMENT_SHORT = 'qualification employment short';
    public static final String STEP_PERSONAL_STATEMENT_SHORT = 'personal statement short';
    public static final String STEP_FEES_AND_FUNDING_SHORT = 'fees and funding short';
    public static final String STEP_REGULATORY_SHORT = 'regulatory short';
    //Suyati Modified End
    
    // Steps of wizard in correct order
    public static final List<String> steps = new List<String> {
            STEP_WELCOME, 
            STEP_PERSONAL_NAME, 
            STEP_PERSONAL_ADDRESS, 
            STEP_ACADEMIC_QUALIFICATIONS, 
            STEP_LANGUAGE_QUALIFICATIONS, 
            STEP_PROFESSIONAL_QUALIFICATIONS, 
            STEP_EXPERIENCE,
            STEP_PERSONAL_STATEMENT, 
            STEP_RESEARCH_PROPOSAL, 
            STEP_REFERENCES, 
            STEP_FEES_AND_FUNDING, 
            STEP_VISA_HISTORY, 
            STEP_EQUAL_OPPORTUNITIES, 
            STEP_DECLARATION
    };

    //Suyati Modified Start

    // Steps of short courses wizard in correct order
    public static final List<String> stepsForShortCourses = new List<String> {
            STEP_WELCOME_SHORT,
            STEP_PERSONAL_DETAILS_SHORT,
            STEP_LANGUAGE_QUALIFICATIONS_SHORT,
            STEP_QUALIFICATION_EMPLOYMENT_SHORT,
            STEP_PERSONAL_STATEMENT_SHORT,
            STEP_FEES_AND_FUNDING_SHORT,
            STEP_REGULATORY_SHORT
    };

    // Titles for short courses steps
    public static final Map<String,String> stepTitlesForShortCourses = new Map<String,String> {
        STEP_WELCOME_SHORT => 'Welcome',
        STEP_PERSONAL_DETAILS_SHORT => 'Personal Details',
        STEP_LANGUAGE_QUALIFICATIONS_SHORT => 'English Language',
        STEP_QUALIFICATION_EMPLOYMENT_SHORT => 'More About You',
        STEP_PERSONAL_STATEMENT_SHORT => 'References',
        STEP_FEES_AND_FUNDING_SHORT => 'Funding and Visa',
        STEP_REGULATORY_SHORT => 'Regulatory'
    };

    //Suyati Modified End
    
    // Titles for steps
    public static final Map<String,String> stepTitles = new Map<String,String> {
        STEP_WELCOME => 'Welcome',
        STEP_PERSONAL_NAME => 'Personal Details',
        STEP_PERSONAL_ADDRESS => 'Personal Details',
        STEP_ACADEMIC_QUALIFICATIONS => 'Academic Qualifications',
        STEP_LANGUAGE_QUALIFICATIONS => 'English Language',
        STEP_PROFESSIONAL_QUALIFICATIONS => 'Professional Qualifications and Experience',
        STEP_EXPERIENCE => 'Professional Qualifications and Experience',
        STEP_PERSONAL_STATEMENT => 'Personal Statement',
        STEP_RESEARCH_PROPOSAL => 'Research Proposal',
        STEP_REFERENCES => 'References',
        STEP_FEES_AND_FUNDING => 'Fees and Funding',
        STEP_VISA_HISTORY => 'Visa and Immigration',
        STEP_EQUAL_OPPORTUNITIES => 'Equal Opportunities',
        STEP_DECLARATION => 'Declaration'
    };

    // Constants for Programme_Version__c types
    public static final String PT_MSC_PROGRAMME =           'MSc Programme';
    public static final String PT_PROFESSIONAL_DIPLOMA =    'Professional Diploma';
    public static final String PT_MASTERS_MODULE =          'Masters Module';
    public static final String PT_SHORT_COURSE =            'Short Course';
    public static final String PT_PGT =                     'PGT';
    public static final String PT_PGR =                     'PGR';

    /**
    * 2014-12-16 : SM : This method returns the 'Individual' account for assigning to Reference / Customer Community Contacts
    * @param none
    * @return Type of Account
    */
    public static Account getIndividualAccount(){
        return [select a.Id, a.Name from Account a where a.Name = :INDIVIDUAL_ACCOUNT_NAME LIMIT 1];
    }

    /**
    * Gets Programme Type by a given Student Programme Id
    * @param progId ID of programme
    * @return Type of programme
    */
    public static String getProgrammeType(Id progId) {
        return [SELECT Programme__r.Type__c FROM Student_Programme__c WHERE Id=:progId LIMIT 1][0].Programme__r.Type__c;
    }
    
    /**
     * Get Application type
     */
    public static String getApplicationType(Id progId) {
        return [SELECT Programme__r.Programme_Version__r.Master_Link__r.Application_Form_Type__c FROM Student_Programme__c WHERE Id=:progId LIMIT 1][0].Programme__r.Programme_Version__r.Master_Link__r.Application_Form_Type__c;
    }
    
    /**
     * Build name for Student_Programme__c from surname of student and TROPCode
     * @param progId ID of programme
     * @param studentLastName Surname of student
     * @return Name for application
     */
    public static String buildNameOfApplication(Id progId, String studentLastName) {
        String name = studentLastName + ' - ';
        List<Programme__c> progList = [SELECT Code__c FROM Programme__c WHERE Id = :progId LIMIT 1];
        if ( !progList.isEmpty() ) {
            name += progList[0].Code__c;
        }
        return name;
    }
    
    /**
     * Create Student_Programme__c with related objects for apply to Programme/course
     * @param programmeId ID of Programme__c
     * @return Just created Student_Programme__c
     */
    public static Student_Programme__c createCourseByProgrammeId(Id programmeId) {
        // get Contact from user login
        User u = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Contact c; 
        if ( u.ContactId != null ) {
            c = findPersonalDetails(u.ContactId);
        } else {
            // work with salesforce user
            Account a = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME_FOR_SF_CONTACTS LIMIT 1];
            c = new Contact(LastName = DUMMY_REQUIRED_STRING, AccountId = a.Id);
            insert c;
        }
        
        Student_Programme__c course = new Student_Programme__c(
            Programme__c = programmeId, Student__c = c.Id, Name = buildNameOfApplication(programmeId, c.LastName),
            Stage__c = COURSE_INIT_STAGE_NAME
        );
        List <Student_Programme__c> lstExistingStudentProgramme = new List <Student_Programme__c>();
        lstExistingStudentProgramme = [SELECT Id, Programme__c, Student__c, Name, Stage__c FROM Student_Programme__c WHERE Student__c =: c.Id AND Programme__c =: programmeId];
        /*
         * Suyati Modified Start
         */
        system.debug('lstExistingStudentProgramme size = ' + lstExistingStudentProgramme.size());
        if(lstExistingStudentProgramme.size() > 0){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.WARNING,'You have already applied for this course. Click <a style="font-size: 12px; margin-right: 0px; margin-left: 0px;" href="/students/applywizard?Id=' + lstExistingStudentProgramme[0].Id + '" target="_blank">here</a> to view the existing application or click <a style="font-size: 12px; margin-right: 0px; margin-left: 0px;" href="/students/apex/StudentLandingPage" target="_blank">here</a> to view the list of Applications');
            apexpages.addmessage(msg);
            return NULL;
        }
        else{            
            insert course;
            return course;
        }
        /* 
        //Previous Code
        insert course;
        return course;
        Suyati Modified End
        */
    }
    
    /**
    * Retrieve ALL fields from Student Programme record
    * @param spId ID of Student Programme
    * @return Student_Programme__c
    */
    
    public static Student_Programme__c findStudentProgramme(Id inSPId){
        List<Student_Programme__c> results = new List<Student_Programme__c>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Student_Programme__c.fields.getMap();
        Id spId = inSPId;
    
        String dbQuery;
    
        dbQuery = 'SELECT ';
    
        for (Schema.SObjectField f : fieldMap.values()){
          dbQuery += f + ',';
        }
        
        //Remove the last ',' from the Query
        //dbQuery = dbQuery.substring(0, dbQuery.length()-1);
    
        dbQuery += 'Programme__r.Name FROM Student_Programme__c WHERE ID = \'' + spId + '\'';
    
        results = Database.query(dbQuery);
        
        return results[0];
    }
    
    /**
     * Retrieve needed fields from the Contact object by ID
     * @param contactId ID of Contact
     * @return Contact 
     */
    public static Contact findPersonalDetails(Id contactId) {
    
            // commented to remove save and proceed validation changes
         return [
            SELECT Birthdate, Country_of_Birth__c, 
                DoNotContact__c, Email,  FirstName, Gaps_in_Residence__c,Registration_Password__c,
                LastName, LeadSource, MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet, 
                Male_Female__c, Middle_Name_Other_Names__c, MobilePhone, OtherCity, OtherCountry, OtherPhone, OtherPostalCode, OtherState, OtherStreet, Phone,
                Previous_Country__c, Previous_Surname__c,Salutation, 
                Type_of_Visa__c, Visa_End_Date__c, Visa_Start_Date__c, Known_As__c, HESA_Domicile__c, HESA_Nationality__c, HESA_Nationality__r.Name,
                HESA_Domicile__r.Name 
            FROM Contact
            WHERE Id = :contactId
        ]; 
          /* return [
            SELECT Birthdate,Country_of_Birth__c, 
                DoNotContact__c, Email, FirstName, Gaps_in_Residence__c,
                LastName, LeadSource, MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet, 
                Male_Female__c, Middle_Name_Other_Names__c, MobilePhone, OtherCity, OtherCountry, OtherPhone, OtherPostalCode, OtherState, OtherStreet, Phone,
                Previous_Country__c, Previous_Surname__c, Salutation, 
                Type_of_Visa__c, Visa_End_Date__c, Visa_Start_Date__c, Known_As__c, HESA_Domicile__c, HESA_Nationality__c, HESA_Nationality__r.Name,
                HESA_Domicile__r.Name 
            FROM Contact
            WHERE Id = :contactId
        ]; */
        
    }
    
    /**
     * Create Qualifications_Experience__c object related to Contact with certain RecordType
     * @param conactId ID of Master contact record
     * @param oppId ID of Student_Programme__c
     * @param rtDevName DeveloperName of RecordType
     * @return Qualifications_Experience__c instance
     */
    public static Qualifications_Experience__c buildQualification(Id contactId, Id oppId, String rtDevName) {
    //new return statement removed usage of Student_programme__c for Datamodel fix
     return new Qualifications_Experience__c(Contact__c = contactId, RecordTypeId = CommonUtils.findRecordTypeIdByDev('Qualifications_Experience__c', rtDevName));
   //  return new Qualifications_Experience__c(Contact__c = contactId, Student_Programme__c = oppId, RecordTypeId = CommonUtils.findRecordTypeIdByDev('Qualifications_Experience__c', rtDevName));
    }
    
    /**
     * Find list of all Qualifications related to the Contact              
     * @param contactID ID of Contact
     * @return List of related qualifications
     */
    public static List<Qualifications_Experience__c> findRelatedQualifications(Id contactId) {
          //new return statement removed usage of Student_programme__c for Datamodel fix
        return [
            SELECT Brief_Description_of_Responsibilities__c, Class_Grade__c, Contact__c, Country__c, Date_of_Award__c,
                End_Date__c, Employer__c,Name_of_College_University__c,
                Position_Held__c, Qualification__c, RecordTypeId, RecordType.DeveloperName,Start_Date__c, Subject__c, Type_Of_Visa__c
            FROM Qualifications_Experience__c
            WHERE Contact__c = :contactId
        ];
    }

    /**
     * Find list of all Qualifications related to the Contact by given RecordType
     * @param contactID ID of Contact
     * @param recordTypeIds IDs of qualifications recordTypes
     * @return List of related qualifications
     */
    public static List<Qualifications_Experience__c> findRelatedQualifications(Id contactId, Set<Id> recordTypeIds) {
        
        return [
            SELECT Brief_Description_of_Responsibilities__c, Class_Grade__c, Contact__c, Country__c, Date_of_Award__c,
                End_Date__c, Employer__c,Name_of_College_University__c,
                Position_Held__c, Qualification__c, RecordTypeId, RecordType.DeveloperName, Start_Date__c, Subject__c, Type_Of_Visa__c
            FROM Qualifications_Experience__c
            WHERE Contact__c = :contactId AND RecordTypeId IN :recordTypeIds
        ];
        
    }
    
    /**
     * Find children References__c to the master Contact.
     * It couldn't return more than 2 references
     * @param contactId ID of master Contact
     * @return List of references
     */
    public static List<References__c> findRelatedReferences(Id contactId) {
        return [
            SELECT Applicant__c, Student_Programme__c, Can_Request_Reference_from_Referee__c, College_University_or_Employer__c,
                Referee__r.Email, Referee__r.FirstName, Referee__r.LastName, Referee__r.MailingCity, Referee__r.MailingCountry, Referee__r.MailingPostalCode,
                Referee__r.MailingState, Referee__r.MailingStreet, Referee__r.Phone, Referee__r.RecordTypeId, Referee__r.Salutation, Referee__r.Title
            FROM References__c
            WHERE Applicant__c = :contactId
            LIMIT 2
        ];
    }
      // New finding method which uses stdent programme changed for data model fix
      public static List<References__c> findRelatedReferencesForStudentPgm(Id spId) {
        return [
            SELECT Applicant__c, Student_Programme__c, Can_Request_Reference_from_Referee__c, College_University_or_Employer__c,
                Referee__r.Email, Referee__r.FirstName, Referee__r.LastName, Referee__r.MailingCity, Referee__r.MailingCountry, Referee__r.MailingPostalCode,
                Referee__r.MailingState, Referee__r.MailingStreet, Referee__r.Phone, Referee__r.RecordTypeId, Referee__r.Salutation, Referee__r.Title
            FROM References__c
            WHERE Student_Programme__c = :spId
            LIMIT 2
        ];
    } 
    /**
     * Find HESA_Code__c by ID or use the cached value
     * @param hesaCodeId ID of the record
     * @return HESA_Code__c instance
     */
    public static HESA_Code__c findHesaCodeById(Id hesaCodeId) {
        if ( cachedHesaCode == null || cachedHesaCode.Id != hesaCodeId ) {
            cachedHesaCode = [SELECT EEA_Nationality__c, Name FROM HESA_Code__c WHERE Id = :hesaCodeId];
        }
        return cachedHesaCode;
    }
    
}