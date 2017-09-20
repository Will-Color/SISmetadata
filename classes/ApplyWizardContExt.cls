/**
 * @author simon m
 * @date 28/08/2014
 * @description Controller extension for ApplyWizard page
 */
 /***** Modifications 
 *#1
 ** @author MKM
 **done for workstream A & B (Phase 2) 
 **<Description> Understanding the data configuration settings in "ApplyServices" & "StepWizard" and implementing new solution to accommodate current requirement.
 ** on 19-06-2015 
 **<summary> 53 to 83</summary>
 *#2
 ** @author MKM
 ** done for workstream B2 (Data Model fix) Relating Reference to Student Program and Qalification to Student (Contact)[Note: We have to further analyse the impact on the existing data due to the change inrelation and communicate to client before actual implementation} 
 on  15-06-2015 
 <summary> Edited Soql and removed the usage of Student_Programme on line 840 </summary>
  *#3
 ** @author MKM
 ** done for Save And proceed b1 Saving Data  of previous pages
 on  05-09-2015 
  <summary> Included new condition that the registration password only get updated on first time </summary>
  <parms name="regPwModified"> Boolean value stored to specify whether the registration pw already updtaed or not</param>
*/
public without sharing class ApplyWizardContExt {



    /**
     * Student_Programme__c item
     */
    @TestVisible
    public Student_Programme__c sp{get; set;}
    
    private static final String END_LEAD_SOURCE_SPECIFY = ' (please specify)';
    
    public static final String REQUIRED_FIELD_MSG = 'You must enter a value';
    
    public static final String UK_VISA_REQUIRED_OTHER = 'OTHER (please provide further details and UPLOAD a copy of your immigration documentation if applicable)';
    
    public static final String STAGE_SUBMITTED = 'Submitted';
    public static final String STAGE_DRAFT = 'Draft';
    
    public static final String NATIONALITY_RT = 'Nationality';
    public static final String DOMICILE_RT = 'Domicile';
    
    // Descriptions for language certificates
    public static final String CERT_COUNTRY = 'country specific qualification';
    public static final String CERT_ENGLISH = 'English language test';
    
    //Variable to store temp password length
    public static final integer TEMP_PASSWORD_LENGTH = 8;
    
    //UK Country Variables
    public static final String CNTY_ENGLAND = 'England';
    public static final String CNTY_NORTHERN_IRELAND = 'Northern Ireland';
    public static final String CNTY_SCOTLAND = 'Scotland';
    public static final String CNTY_WALES = 'Wales';
    public boolean regPwModified = false;
    public boolean editEnable{ get; set; }
    public String programmeCategory {get; set;}
     
    //**Parameter to check if short courses are saved
    public Boolean shortCourseSaved {get; set;}
    
    /**
     * Constructor
     */
    
    public ApplyWizardContExt() {
        String studentProgramId;
        studentProgramId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('studentProgramId = ' + studentProgramId);
        //sp = (Student_Programme__c) stdController.getRecord();
         sp = ApplyServices.findStudentProgramme(studentProgramId);
         
        /*
         * Suyati Modified start
        */ 
        //sp.Amount__c = null;
        shortCourseSaved = FALSE;                      
        if(applicationType == 'Short-' || applicationType == 'Short+' || applicationType == 'Online' ){
            
            //**Set programmeCategory as Short Course
            programmeCategory = 'Short Course';
            
            innerSteps = new List<String>();
            //**retrieve steps for short courses
            for(String s : ApplyServices.stepsForShortCourses) {
                if ( !isPGR && (s == ApplyServices.STEP_RESEARCH_PROPOSAL) )
                    continue;
                innerSteps.add(s);
            }
            step = new StepWizard(0, innerSteps, ApplyServices.stepTitlesForShortCourses);
        }
        else{
            //retrieve steps for standard courses
            innerSteps = new List<String>();
            for(String s : ApplyServices.steps) {
                if ( !isPGR && (s == ApplyServices.STEP_RESEARCH_PROPOSAL) )
                    continue;
                innerSteps.add(s);
            }
            step = new StepWizard(0, innerSteps, ApplyServices.stepTitles);
        }        
        if(applicationType == 'Short+'){
            step.stepIndex = 1;      
        }
        //**code for retriving steps ends
          
        
        requiredMode = false;
        student = ApplyServices.findPersonalDetails(sp.Student__c);
        if ( student.LastName.equals(ApplyServices.DUMMY_REQUIRED_STRING) ) {
            student.LastName = '';
        }
        System.Debug('student'+student);
        if(! Test.isRunningTest()){
            welcomePageCopy = [select p.Body_Copy__c from Page_Copy__c p where p.Copy_Location__c = 'Application Welcome' and Page_Status__c = 'Active' LIMIT 1];
            System.Debug('welcomePageCopy'+welcomePageCopy);
            reviewPageCopy = [select p.Body_Copy__c from Page_Copy__c p where p.Copy_Location__c = 'Application Review' and Page_Status__c = 'Active' LIMIT 1];
            System.Debug('reviewPageCopy'+reviewPageCopy);
            researchProposalCopy = [select p.Body_Copy__c from Page_Copy__c p where p.Copy_Location__c = 'Research Proposal' and Page_Status__c = 'Active' LIMIT 1];
            System.Debug('researchProposalCopy'+researchProposalCopy);
        }
        Map<String, RecordType> hesaRTMap = new Map<String, RecordType>();
        for (RecordType r : [select r.Id, r.DeveloperName from RecordType r where r.SObjectType = 'HESA_Code__c' and IsActive = true]){
            hesaRTMap.put(r.DeveloperName, r);
        }
        System.Debug('hesaRTMap'+hesaRTMap);
        hesaNationalityCountries = new List<SelectOption>();
        hesaNationalityCountries.add(new SelectOption('','-None-'));
        HESA_Code__c hcUK = [select h.Id, h.Name, h.Active__c from HESA_Code__c h where h.Name = 'United Kingdom' and h.RecordTypeId = :hesaRTMap.get(NATIONALITY_RT).Id LIMIT 1];
        hesaNationalityCountries.add(new SelectOption(hcUK.Id, hcUK.Name));
        for (Hesa_Code__c h : [select h.Id, h.Name, h.Active__c from HESA_Code__c h where h.RecordTypeId = :hesaRTMap.get(NATIONALITY_RT).Id ORDER BY h.Name ASC]){
            if (!'UNITED KINGDOM'.equalsIgnoreCase(h.Name)){
                hesaNationalityCountries.add(new SelectOption(h.Id, h.Name));
            }
        }
        //2015-04-02 : SM : 'United Kingdom, not otherwise specified' is now being put into the list normally
        //2015-04-02 : SM : and instead 'England', 'Northern Ireland', 'Scotland' and 'Wales' will be put into the top of the list
        hesaDomicileCountries = new List<SelectOption>();
        hesaDomicileCountriesByName = new List<SelectOption>();
        
        hesaDomicileCountries.add(new SelectOption('','-None-'));
        hesaDomicileCountriesByName.add(new SelectOption('','-None-'));
        
        //HESA_Code__c hcUKDom = [select h.Id, h.Name, h.Active__c from HESA_Code__c h where h.Name = 'United Kingdom, not otherwise specified' and h.RecordTypeId = :hesaRTMap.get(DOMICILE_RT).Id LIMIT 1];
        Map<String, String> ukStrings = new Map<String, String>();
        ukStrings.put(CNTY_ENGLAND,CNTY_ENGLAND);
        ukStrings.put(CNTY_NORTHERN_IRELAND,CNTY_NORTHERN_IRELAND);
        ukStrings.put(CNTY_SCOTLAND,CNTY_SCOTLAND);
        ukStrings.put(CNTY_WALES,CNTY_WALES);
        List<HESA_Code__c> ukList = [select h.Id, h.Name, h.Active__c from HESA_Code__c h where h.Name in :ukStrings.values() and h.RecordTypeId = :hesaRTMap.get(DOMICILE_RT).Id ORDER BY h.Name];
        for (HESA_Code__c hc : ukList){
            hesaDomicileCountries.add(new SelectOption(hc.Id, hc.Name));
            hesaDomicileCountriesByName.add(new SelectOption(hc.Name, hc.Name));
        }
        
        
        for (Hesa_Code__c h : [select h.Id, h.Name, h.Active__c from HESA_Code__c h where h.RecordTypeId = :hesaRTMap.get(DOMICILE_RT).Id ORDER BY h.Name ASC]){
            if (!ukStrings.containsKey(h.Name)){
                hesaDomicileCountries.add(new SelectOption(h.Id, h.Name));
                hesaDomicileCountriesByName.add(new SelectOption(h.Name, h.Name));
            }
        }
             
        editEnable = applyWizardPageRedirectingStages(sp);
    }
    
    
    public Page_Copy__c welcomePageCopy {get; set;}
    public Page_Copy__c reviewPageCopy {get; set;}
    public Page_Copy__c researchProposalCopy {get; set;}
    
    public Id deleteQualId {
        get {
            return deleteQualId;
        }
        set {
            system.debug('*** -- SETTER FIRED -- ***');
            deleteQualId = value;
            system.debug('*** -- after Setter ' + deleteQualId + ' -- ***');
        }
    }
    
   
    
    /**
     * Current inner step (used for skipping wizard pages)
     */
    public List<String> innerSteps { get; set; }
        
    /**
     * Current step of wizard
     */
    public StepWizard step { get; set; }
    
    /**
     * Name of step to jump
     */
    public String stepName { get; set; }
    
    /**
     * Indicates step of validation (if true)
     */
    public Boolean validationStep { get; set; }
    
    /**
     * Is any error or missing fields after validation
     */
    public Boolean isValidationErrors { get {
            for (Boolean wasError: errorByStep.values()) {
                if ( wasError ) return true;
            }
            return false;
        }
    }
    
    /**
     * Show map where key = name of step, value = error flag (true means error)
     */
    public Map<String,Boolean> errorByStep { get {
        if ( errorByStep == null ) {
            errorByStep = new Map<String,Boolean>();
            for (String name: innerSteps) {
                errorByStep.put(name, false);
            }
        }
        return errorByStep;
    } set; }
    
    /**
     * Indicates validation mode where required fields are mandatory (true)
     */
    public Boolean requiredMode { get; set; }
    
    /**
    * 2014-08-12 : CSL : New boolean value to store when the form is ready to Submit
    */
    public Boolean readyToSubmit {
        get {
            if (readyToSubmit == null){
                readyToSubmit = false;
            }
            return readyToSubmit;
        }
        set;
    }
    
    
    /**
     * Indicates if LeadSource should be specified
     */
    public Boolean needLeadSourceSpecify { get {
            return ( sp.How_did_you_hear_about_this_Course__c != null && sp.How_did_you_hear_about_this_Course__c.endsWith(END_LEAD_SOURCE_SPECIFY) );
        }
    }
    
    /**
     * Indicates if need textarea for VISA details
     */
    public Boolean needVisaFurtherDetails {
        get {
            return ( sp.UK_Visa_Required__c == UK_VISA_REQUIRED_OTHER );
        }
    }
    
    /**
     * Related to the Student_Programme__c Contact object (personal details)
     */
    public Contact student { get; set; }
    
    /**
     * References to other contacts
     */
    public List<ReferenceWrapper> references { get; set; }
    
    /**
     * Map of qualifications and experiences by RecodType
     */
    public Map<String,List<QEWrapper>> qeMap { get; set; }
    
      /**
     * Find applyWizard Page Redirecting Stages
     */
     public Boolean applyWizardPageRedirectingStages(Student_Programme__c thisSp ){
    
        Boolean Enableit;
        set<String> stStages = new set<String>{'Submitted','Incomplete','Checked','Reviewed','Accepted','Reject','Withdrawn'};              
        if(stStages.contains(thisSp.Stage__c)){
            Enableit= False;
        }
        else{
            Enableit= True;
        }
        return Enableit;
    }
    
    /**
     * Get list of previous qualifications in the UK 
     */
    public List<Qualifications_Experience__c> historyVisaUK { get {
            List<Qualifications_Experience__c> qList = new List<Qualifications_Experience__c>();
            Set<String> qeNames = new Set<String> {ApplyServices.RT_ACADEMIC_QE_DEVNAME, ApplyServices.RT_PROFESSIONAL_QE_DEVNAME};
            for (String qeName: qeNames) {
                for (QEWrapper wr: qeMap.get(qeName)) {
                    Qualifications_Experience__c qe = wr.item;
                    if ( ApplyServices.COUNTRY_UK.equals(qe.Country__c) ) {
                        qList.add(qe);
                    }
                }
            }
            return qList;
        }
    }

    /**
    * List of HESA Countries used to on Contact information for Nationality values (populated during init())
    */
    public List<SelectOption> hesaNationalityCountries {get; set;}
    
    /**
    * List of HESA Countries used to on Contact information for Domicile values (populated during init())
    */
    public List<SelectOption> hesaDomicileCountries {get; set;}
    
    /**
    * List of HESA Countries used to on Contact information for Domicile values (populated during init())
    */
    public List<SelectOption> hesaDomicileCountriesByName {get; set;}

    /**
     * Get Student Programme Type
     */
    public String programmeType {
        get {
            if (programmeType==null)
                programmeType = ApplyServices.getProgrammeType(sp.Id);
            return programmeType;
        }
        private set;
    }
    
    /**
     * Get Student Programme Type
     */
    public String applicationType {
        get {
            if (applicationType==null)
                applicationType = ApplyServices.getApplicationType(sp.Id);
            System.debug('applicationType = ' + applicationType);
            if(applicationType == null || applicationType == ''){
                applicationType = 'Standard';
            }
            return applicationType;
        }
        private set;
    }
    
    public String programVersionType {
        get {
            if (programVersionType ==null)
                
                programVersionType = [SELECT Programme__r.Programme_Version__r.Master_Link__r.Programme_Type__c FROM Student_Programme__c WHERE Id=:sp.id LIMIT 1][0].Programme__r.Programme_Version__r.Master_Link__r.Programme_Type__c ;
           
            return programVersionType ;
        }
        private set;
    }
    
    /**
     * Checks is programme type PGR
     */
    public Boolean isPGR {
        get {
            return ApplyServices.PT_PGR == programmeType;
        }
    }
    
    /**
     * Checks is programme type 'MSc Programme'
     */
    public Boolean isMSc {
        get {
            return ApplyServices.PT_MSC_PROGRAMME == programmeType;
        }
    }
    
    /**
     * If student's nationality not spesified we are thinking that student is EEA,
     * otherwise use value from HESA_Code__c.EEA_Nationality__c
     */
    public Boolean isEEAStudent {
        get {
            if ( String.isBlank(student.HESA_Nationality__c) ) {
                return true;
            } else {
                return ApplyServices.findHesaCodeById(student.HESA_Nationality__c).EEA_Nationality__c;
                 
            }
        }
    }
    
    /**
     * Get nationality of student from HESA_Nationality__c lookup
     */
    public String studentNationality {
        get {
            if ( String.isBlank(student.HESA_Nationality__c) ) {
                return null;
            } else {
                return ApplyServices.findHesaCodeById(student.HESA_Nationality__c).Name;
                 
            }
        }
    }

    /**
    * Is the student a Non-EEA Student (for Visa History)
    */
    /*
    public Boolean visaIsNonEEA {
        get {
            if (visaIsNonEEA == null){
                visaIsNonEEA = false;
            }
            return visaIsNonEEA;
        }
        set;
    }
    */
    
    /**
    * Is the Programme a Masters / Research Programme (for Visa History)
    */
    /*
    public Boolean visaIsMastersResearch {
        get {
            if (visaIsMastersResearch == null){
                visaIsMastersResearch = false;
            }
            return visaIsMastersResearch;
        }
        set;
    }
    */
    
    
    /**
     * Append qe object to the map with by RecordType.DeveloperName
     * @param rt DeveloperName of RecordType
     * @param qeItem Qualifications_Experience__c object
     * @param m Map of the list of wrappers
     */
    private void addQE(String rt, Qualifications_Experience__c qeItem, Map<String,List<QEWrapper>> m) {
        List<QEWrapper> wList = m.get(rt);
        if ( wList == null ) {
            wList = new List<QEWrapper>();
            m.put(rt, wList);
        }
        QEWrapper w = new QEWrapper(qeItem);
        w.index = wList.size();
        wList.add(w);
    }
    
    /**
     * Add new qualification to the qeMap
     * @param DeveloperName of RecordType
     * @return Just created object
     */
    private Qualifications_Experience__c addQE(String rt) {
        Qualifications_Experience__c qeItem = ApplyServices.buildQualification(student.Id, sp.Id, rt);
        addQE(rt, qeItem, qeMap);
        return qeItem;
    }
    
    /**
     * Check if values on the English language step is valid
     * @return True mean step is valid
     */
    private Boolean isEngLangStepValid() {
        String stNat = studentNationality;
        if ( stNat == null ) {
            return false;
        }
        if ( stNat == ApplyServices.COUNTRY_UK || stNat == ApplyServices.COUNTRY_IRELAND ) {
            // British or Irish
            return ( sp.Confirm_British_Irish_Nationality__c == ApplyServices.PICKLIST_YES );
        } else {
            // other nationality
            if ( CommonUtils.hasEmptyFields(sp, 'National_of_Majority_English_Speaking__c,Completed_Degree_Level_Qualification__c,Cert_for_Approved_Country_Specific_Qual__c,Cert_for_English_Language_Test__c,Intend_to_Take_English_Language_Test__c') ) {
                return false;
            }
            //2014-09-08 : CSL : We no longer user the Language Qualification type to store the Language attachments - we use the Student ID.  So this code has to be changed.
            //Id langQeId = qeMap.get(ApplyServices.RT_LANGUAGE_QE_DEVNAME)[0].item.Id;
            Id langQeId = sp.Id;
            return (
                sp.National_of_Majority_English_Speaking__c == ApplyServices.PICKLIST_YES ||
                sp.Completed_Degree_Level_Qualification__c == ApplyServices.PICKLIST_YES ||
                ( sp.Cert_for_Approved_Country_Specific_Qual__c == ApplyServices.PICKLIST_YES && !CommonUtils.findAttachments(langQeId, CERT_COUNTRY).isEmpty() ) ||
                ( sp.Cert_for_English_Language_Test__c == ApplyServices.PICKLIST_YES && !CommonUtils.findAttachments(langQeId, CERT_ENGLISH).isEmpty() ) ||
                sp.Intend_to_Take_English_Language_Test__c == ApplyServices.PICKLIST_YES
            );
        }
    }
    
    /**
     * Init action to create References and QEs related to application form
     * Should be used as action param of Visualforce page
     */
    public pagereference init() {
    
        String studentProgramId = ApexPages.currentPage().getParameters().get('Id');        
        sp = ApplyServices.findStudentProgramme(studentProgramId);      
        Contact student = [SELECT Id,LSTM_No__c FROM Contact WHERE Id =: sp.Student__c];        
        Programme__c programme = [SELECT Id,External_Form__c,Programme_Version__r.Master_Link__r.Application_Form_Type__c FROM Programme__c WHERE Id =: sp.Programme__c];       
        if(programme.Programme_Version__r.Master_Link__r.Application_Form_Type__c.equals('FormAssembly') && String.isNotBlank(programme.External_Form__c))      
        {       
            PageReference result_page = new PageReference('https://' + URL.getSalesforceBaseUrl().getHost() + '/students/ExternalForm');        
            result_page.getParameters().put('SPID', sp.Id);     
            result_page.getParameters().put('StudentID', student.Id);     
            return result_page;                 
        }   
            
        // init references and if need append to two
        //List<References__c> refList = ApplyServices.findRelatedReferences(sp.Student__c);
        //changes for datamodelfix
        List<References__c> refList = ApplyServices.findRelatedReferencesForStudentPgm(sp.Id);
        //changes for datamodelfix ends
        while ( refList.size() < 2 ) {
            refList.add(new References__c(Applicant__c = sp.Student__c, Student_Programme__c = sp.Id));
        }
        upsert refList;
        references = new List<ReferenceWrapper>();
        for (Integer i=0; i<refList.size(); i++) {
            ReferenceWrapper ref = new ReferenceWrapper(refList[i]);
            ref.index = i;
            references.add(ref);
        }
        for (ReferenceWrapper wr: references) {
            if ( !String.isBlank(wr.referee.LastName) && wr.referee.LastName.equals(ApplyServices.DUMMY_REQUIRED_STRING) ) {
                wr.referee.LastName = '';
            }
        }
        
        // init QEs
        //2014-09-08 : CSL : Removing the 'Language Qualification' record type, as this record is no longer needed (ApplyServices.RT_LANGUAGE_QE_DEVNAME)
        Set<String> allRtNames = new Set<String> {
            ApplyServices.RT_ACADEMIC_QE_DEVNAME, ApplyServices.RT_PROFESSIONAL_QE_DEVNAME, ApplyServices.RT_EXPERIENCE_QE_DEVNAME 
        };
        Map<String,List<QEWrapper>> m = new Map<String,List<QEWrapper>>();
        List<Qualifications_Experience__c> qeList = ApplyServices.findRelatedQualifications(sp.Student__c);
        for (Qualifications_Experience__c qeItem: qeList) {
            allRtNames.remove(qeItem.RecordType.DeveloperName);
            addQE(qeItem.RecordType.DeveloperName, qeItem, m);
        }
        List<Qualifications_Experience__c> forInsert = new List<Qualifications_Experience__c>(); 
        for (String rtDevName: allRtNames) {
            Qualifications_Experience__c qeItem = ApplyServices.buildQualification(sp.Student__c, sp.Id, rtDevName);
            forInsert.add(qeItem);
            addQE(rtDevName, qeItem, m);
        }
        insert forInsert;
        qeMap = m;
        system.debug('references123'+references );
        
        return null;            
    }
    
    /**
     * Action to move to the next step of wizard
     */
    public void gotoNextStep() {
        if ( step.hasNextStep && isStepFieldsValid(step.getName()) ) {
            //** Implementation to exclude steps for short-
            if(applicationType == 'Short-' || applicationType == 'Online'){
                if(sp.academic_credit__c == FALSE){
                    if(step.stepIndex == 1){
                        step.stepIndex = 3;
                        return;
                    }                    
                }
                if(step.stepIndex == 3){
                    step.stepIndex = 5;
                    return;
                }                
            }
            step.stepIndex++;
           //** Implementation to exclude steps for short- Ends
        }        
    }
    
    
    //** Function to save fields in the current step and proceed to next step(Save and proceed)
    public void saveAndProceed(){
        gotoNextStep();
        addDummyValuesToBlankFields();        
        saveApplication();
    }
    
      public void next(){
        gotoNextStep();
        addDummyValuesToBlankFields();        
        //saveApplication();
    }
    
    //Populate Student and Referee Last Names with Dummy values
    void addDummyValuesToBlankFields(){
        if ( String.isBlank(student.LastName) ) {
            student.LastName = ApplyServices.DUMMY_REQUIRED_STRING;
        }
        for (ReferenceWrapper wr: references) {
            if ( !wr.empty && String.isBlank(wr.referee.LastName) ) {
                wr.referee.LastName = ApplyServices.DUMMY_REQUIRED_STRING;
            }
        }        
    }
   
    /*
     * Action to move to the previous step of wizard
    */
    public void gotoPreviousStep() {
        if ( step.hasPreviousStep && isStepFieldsValid(step.getName()) ) {
            //2014-08-14 : CSL : We need to make sure the MailingCountry field is populated
            //from the Student HESA_Code__c lookup
            //if (student.HESA_Domicile__c != null){
            //  student.MailingCountry = student.HESA_Domicile__r.Name;
            //}
            //** Implementation to exclude steps for short- while going to the previous step
            if(applicationType == 'Short-' || applicationType == 'Online'){
                if(sp.academic_credit__c == FALSE){
                    if(step.stepIndex == 3){
                        step.stepIndex = 1;
                        return;
                    }
                }
               
                if(step.stepIndex == 5){
                    step.stepIndex = 3;
                    return;
                }  
            }
            //** Implementation to exclude steps for short- while going to the previous step Ends
          
            step.stepIndex--;
        }
    }
    
    /**
     * Action to move to the this.stepName step of wizard
     */
    public void gotoStep() {
        if ( step.gotoStepByName(stepName) ) {
            //2014-08-14 : CSL : We need to make sure the MailingCountry field is populated
            //from the Student HESA_Code__c lookup
            //if (student.HESA_Domicile__c != null){
            //  student.MailingCountry = student.HESA_Domicile__r.Name;
            //}
            validationStep = false;
        }
    }
        
    /**
     * Action for add new Academic qualification
     */
    public void addAcademicQE() {
        insert addQE(ApplyServices.RT_ACADEMIC_QE_DEVNAME);
    }
    
    /**
     * Action for add new Language qualification
     */
    public void addLanguageQE() {
        insert addQE(ApplyServices.RT_LANGUAGE_QE_DEVNAME);
    }
    
    /**
     * Action for add new Professional qualification
     */
    public void addProfessionalQE() {
        insert addQE(ApplyServices.RT_PROFESSIONAL_QE_DEVNAME);
    }
    
    /**
     * Action for add new Experience qualification
     */
    public void addExperienceQE() {
        insert addQE(ApplyServices.RT_EXPERIENCE_QE_DEVNAME);
    }
    
    /**
    * 2014-08-13 : CSL : Action to delete the newly added Qualification
    */
    
    public PageReference deleteQual(){
        Qualifications_Experience__c qe = [select q.Id, q.RecordType.DeveloperName from Qualifications_Experience__c q where q.Id = :deleteQualId LIMIT 1];
        integer delInt = 0;
        system.debug('*** -- into deleteQual with ' + deleteQualId + ' -- ***');
        if (deleteQualId != null){
            String whichMap;
            integer j = 0;
            
            List<QEWrapper> qwList = qeMap.get(qe.RecordType.DeveloperName);
            integer i = 0;
            if (qwList != null){
                for (QEWrapper qw : qwList){
                    if (qw.item.Id == deleteQualId){
                        delInt = i;
                    }
                    i++;
                }
            }
            
            qwList.remove(delInt);
            
            
            system.debug('*** -- Got ' + qe.Id + ' -- ***');
            if (qe != null){
                try {
                    delete qe;
                }catch (DMLException dmlEx){
                    system.debug('*** -- Error deleting : ' + dmlEx + ' -- ***');
                }
            }
        }
        return null;
    }
    
    /**
     * Action for validating form and save application form if validation was successful
     */
    public void validate() {
        if(programmeCategory == 'Short Course'){
            validateShortCourses();
        }
        else{
            validateCourses();
        }        
    }
    
    public void validateCourses(){
        requiredMode = true;
        validationStep = true;
        
        //2014-08-13 : CSL : We need to populate 'MailingCountry' with the name of the HESA_Code__c country the user selected
        //if (student.HESA_Domicile__c != null){
        //  student.MailingCountry = student.HESA_Domicile__r.Name;
        //}
        
        // personal details - names
        errorByStep.put(ApplyServices.STEP_PERSONAL_NAME, CommonUtils.hasEmptyFields(student, 'Salutation,FirstName,LastName,Male_Female__c,Birthdate,Country_of_Birth__c'));
        // personal details - addresses
        Boolean pdAddress = CommonUtils.hasEmptyFields(student, 'MailingStreet,MailingPostalCode');
        if ( !pdAddress ) {
            pdAddress = !isStepFieldsValid(ApplyServices.STEP_PERSONAL_ADDRESS);
        } 
        errorByStep.put(ApplyServices.STEP_PERSONAL_ADDRESS, pdAddress);
        //2014-08-08 : CSL : New validation code
        //We need to check that they have provided 'Previous Countries' if the have not lived in the UK continually for three years
        if ('NO'.equalsIgnoreCase(student.Gaps_in_Residence__c)){
            Boolean previousCountriesEmpty = CommonUtils.hasEmptyFields(student, 'Previous_Country__c');
            if (previousCountriesEmpty){
                errorByStep.put(ApplyServices.STEP_PERSONAL_ADDRESS, true);
            }
        }
        
        // English language
        errorByStep.put(ApplyServices.STEP_LANGUAGE_QUALIFICATIONS, !isEngLangStepValid());
        // references
        Boolean referencesErr = false;
        for (ReferenceWrapper refW: references) {
            if ( ! refW.empty && CommonUtils.hasEmptyFields(refW.referee, 'LastName') ) {
                referencesErr = true;
                break;
            }
        }
        errorByStep.put(ApplyServices.STEP_REFERENCES, referencesErr);
        // visa history
        //2014-08-15 : CSL : TO DO : This code will need to change, as the Visa History table is only shown for particular Students
        //Attending particular programmes now
        Boolean visaErr = CommonUtils.hasEmptyFields(sp, 'UK_Visa_Required__c');
        if ( !visaErr && !isEEAStudent && (isPGR || isMSc) ) {
            for (Qualifications_Experience__c qeItem: historyVisaUK) {
                if ( String.isBlank(qeItem.Type_Of_Visa__c) ) {
                    visaErr = true;
                    break;
                }
            }
        } 
        errorByStep.put(ApplyServices.STEP_VISA_HISTORY, visaErr);
        // declaration
        errorByStep.put(ApplyServices.STEP_DECLARATION, CommonUtils.hasEmptyFields(sp, 'Do_you_have_any_Criminal_Convictions__c'));
        
        if ( !isValidationErrors ) {
            //As this has passed validation, and we are not saving the draft version, we can set the status to Submitted
            //2014-08-12 : CSL : Moving this code to a new method, as client wants a separate Submit button on the last screen
            //sp.Stage__c = STAGE_SUBMITTED;
            //saveApplication();
            readyToSubmit = true;   
        }
    }
    
    //** function to validation for short courses
    public void validateShortCourses() {
        Boolean personalDetailsShortError = FALSE;
        personalDetailsShortError = CommonUtils.hasEmptyFields(student, 'Salutation,FirstName,LastName,Male_Female__c,Birthdate,Country_of_Birth__c');        
        system.debug('personalDetailsShortError 1 = ' + personalDetailsShortError);
        if(personalDetailsShortError == FALSE){
            personalDetailsShortError = CommonUtils.hasEmptyFields(student, 'MailingStreet,MailingPostalCode');
            system.debug('personalDetailsShortError 2 = ' + personalDetailsShortError);
            if (personalDetailsShortError == FALSE) {
                personalDetailsShortError = !isStepFieldsValid(ApplyServices.STEP_PERSONAL_DETAILS_SHORT);
                system.debug('personalDetailsShortError 3 = ' + personalDetailsShortError);
            }
        }         
        errorByStep.put(ApplyServices.STEP_PERSONAL_DETAILS_SHORT, personalDetailsShortError);        
                
        // English language
        errorByStep.put(ApplyServices.STEP_LANGUAGE_QUALIFICATIONS_SHORT, !isEngLangStepValid());
        
        // references
        if(sp.academic_credit__c == true){
            Boolean referencesErr = false;
            for (ReferenceWrapper refW: references) {
                if ( ! refW.empty && CommonUtils.hasEmptyFields(refW.referee, 'LastName') ) {
                    referencesErr = true;
                    break;
                }
            }        
            errorByStep.put(ApplyServices.STEP_PERSONAL_STATEMENT_SHORT, referencesErr);
        }
        system.debug('errorByStep = ' + errorByStep);
        
        /*
        // visa and declaration
        Boolean visaErr = CommonUtils.hasEmptyFields(sp, 'UK_Visa_Required__c');
        if ( !visaErr && !isEEAStudent && (isPGR || isMSc) ) {
            for (Qualifications_Experience__c qeItem: historyVisaUK) {
                if ( String.isBlank(qeItem.Type_Of_Visa__c) ) {
                    visaErr = true;
                    break;
                }
            }
        } 
        if(visaErr == FALSE){
            visaErr = CommonUtils.hasEmptyFields(sp, 'Do_you_have_any_Criminal_Convictions__c');
        }
        errorByStep.put(ApplyServices.STEP_REGULATORY_SHORT, visaErr);
        
        if ( !isValidationErrors ) {
            readyToSubmit = true;   
        }
        
        */
    }
    
    //2014-08-12 : CSL : New method to submit application at final screen
    public void doSubmit(){
        sp.Stage__c = STAGE_SUBMITTED;
        //** Setting shortCourseSaved to true for displaying submit message  
        if(applicationType != 'Standard'){
            shortCourseSaved = TRUE;
        }
        saveApplication();
    }
    
    /**
     * Action for saving application form
     */
    public void saveApplication() {
        RecordType refereeRecordType = [select r.Id from RecordType r where r.SObjectType = 'Contact' and r.DeveloperName = 'Other' LIMIT 1];
        // save
        //2014-07-18 : CSL : We set the field Created_In_Portal to TRUE so we know this came from the portal
        //And not the UI
        if ( student.HESA_Domicile__c != null ) {
            student.MailingCountry = ApplyServices.findHesaCodeById(student.HESA_Domicile__c).Name;
        }
        //2015-03-20 : SM : We need to generate a random string of characters for a 'temp' password  
        // This condition only allow to updtae registration pw on first time            
        if ( student.Registration_Password__c == null && regPwModified  ==  false){
                String tp = getPassword(TEMP_PASSWORD_LENGTH);
                student.Registration_Password__c = tp;
                regPwModified = true;
            }        
        //student.LSTM_Temp_Password__c = tp;
        update student;
        sp.Name = ApplyServices.buildNameOfApplication(sp.Programme__c, student.LastName);
        sp.Created_In_Portal__c = true;
        //sp.Amount__c = null;
        //Suyati Modified 18-05-2016 Start
        if(sp.Id != null)
        {
            /*
            Student_Programme__c updatedSp = [SELECT Id,Amount__c,Fee_Status__c,Fee_Status_Override__c FROM Student_Programme__c where Id =: sp.Id];
            sp.Fee_Status__c = updatedSp.Fee_Status__c;
            sp.Amount__c = updatedSp.Amount__c;
            sp.Fee_Status_Override__c = updatedSp.Fee_Status_Override__c;
            */
            List<Schema.FieldSetMember> spfields = SObjectType.Student_Programme__c.FieldSets.Apex_Exempt_Fields.getFields();
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : spfields) {
                query += f.getFieldPath() + ', ';
            }

            query += 'Id FROM Student_Programme__c WHERE Id=\'' + sp.Id + '\' LIMIT 1';
            System.debug('query = ' + query);
            Student_Programme__c updatedSp = Database.query(query);
            System.debug('updatedSp = ' + updatedSp);

            for(Schema.FieldSetMember f : spfields) {
                //sp.put(f.getFieldPath()) = updatedSp.get(f.getFieldPath());
                sp.put(f.getFieldPath(),updatedSp.get(f.getFieldPath()));
            }
            System.debug('##sp = ' + sp);
        }
        //Suyati Modified 18-05-2016 End
        update sp;
        
        
        
        
        //** Implementation to save References for standard or short+ courses
        if(applicationType == 'Standard' || applicationType == 'Short+'){
            List<Contact> refereeList = new List<Contact>();
            List<References__c> refList = new List<References__c>();
            //Get the Individual Account from the Apply Services class
            Account individualAccount = ApplyServices.getIndividualAccount();
            
            for (ReferenceWrapper wr: references) {
                if ( ! wr.empty ) {
                    if (wr.referee.RecordTypeId != refereeRecordType.Id){
                        wr.referee.RecordTypeId = refereeRecordType.Id;
                        //2014-12-16 : SM : Updating this method to set the 'AccountId' to be the Id of the 'Individual' account
                        if (individualAccount != null){
                            wr.referee.AccountId = individualAccount.Id;
                        }
                    }
                    refereeList.add(wr.referee);
                    refList.add(wr.item);
                }
            }
            upsert refereeList;
            for (Integer i=0; i<refList.size(); i++) {
                refList[i].Student_Programme__c =sp.id;
                refList[i].Referee__c = refereeList[i].Id;
                //As we are saving the Student Programme as 'Submitted', we also need to set the Reference object to status 'Submitted'
                if (STAGE_SUBMITTED.equalsIgnoreCase(sp.Stage__c)){
                    refList[i].Reference_Status__c = STAGE_SUBMITTED;                     
                }   
            }
            upsert refList;
        }
        
        
        //** imlimentation for saving Qualification and Experience for Standard courses
        if(applicationType == 'Standard'){
            List<Qualifications_Experience__c> qeList = new List<Qualifications_Experience__c>();
            for (List<QEWrapper> wrList: qeMap.values()) {
                for (QEWrapper wr: wrList) {
                    qeList.add(wr.item);
                }
            }
            update qeList;
        }
    }
    
    
    
    /**
     * Action: save and close application form in draft mode
     * @return Home page reference
     */
    public PageReference saveDraftApplication() {
        sp.Save_as_Draft__c = true;
        update sp;
        // add dummy values for required field and save
        addDummyValuesToBlankFields();
        
        // save application
        saveApplication();
        return gotoHomePage();
    }       
      public PageReference close() {
        
        // add dummy values for required field and save
        addDummyValuesToBlankFields();        
        // save application
        // saveApplication();
        return gotoHomePage();
    }        
     
    
    /**
     * Action goes to home page
     * @return PageReference of home page
     */
    public PageReference gotoHomePage() {
        return new PageReference('/');
    }
    
    /**
     * Action goes to home page
     * @return PageReference of home page
     */
    public PageReference gotoNewUserPage() {
        return new PageReference('/LSTMUserPage?Id=' + sp.Id);
    }
    
    /**
     * Use this method to perform additional validation of step data
     */
    public Boolean isStepFieldsValid(String nameOfStep) {
        if ( requiredMode ) { 
            // validate some complex step logic
            //2014-07-17 : CSL : Changing this step - We are now checking a new field for 'Previous Countries'
            if ( nameOfStep == ApplyServices.STEP_PERSONAL_ADDRESS ) {
                //if ( student.Gaps_in_Residence__c == ApplyServices.PICKLIST_NO && CommonUtils.hasEmptyFields(student, 'Country_Most_Recent_Previous__c') ) {
                if ( student.Gaps_in_Residence__c == ApplyServices.PICKLIST_NO && CommonUtils.hasEmptyFields(student, 'Previous_Country__c') ) {
                    student.Previous_Country__c.addError(REQUIRED_FIELD_MSG);
                    return false;
                }
            }
        }
        return true;
    }
    
    //2015-03-20 : SM : New method to generate a random password string
     public String getPassword(Integer len)
     {
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        System.debug('*** -- Key from getPassword = ' + key + ' -- ***');
        return key.substring(0,len);
     }
    
}