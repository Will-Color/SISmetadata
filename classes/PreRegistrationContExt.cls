/**
 * @author Valentyn Bilenkyi
 * @date 01/07/2014
 * @description Controller extension for PreRegistration page
 */
public without sharing class PreRegistrationContExt {

 


    // Description for attachment of passport photo
    public static final String PASSPORT_PHOTO_ATTACHMENT_DESCRIPTION = 'Passport photo 45:35';
    public static final String PASSPORT_PHOTO_ATTACHMENT_ERROR_MESSAGE = 'Please upload your passport photo!';
    public static final String EXTERNAL_STAGE_REGISTRATION = 'Registration';

    /**
     * Constructor
     */
    public PreRegistrationContExt() {
        //sp = (Student_Programme__c) stdController.getRecord();
        Id spId = ApexPages.currentPage().getParameters().get('Id');
        sp = ApplyServices.findStudentProgramme(spId);
        wizardSteps = PreRegistrationServices.steps;
        if (EXTERNAL_STAGE_REGISTRATION.equalsIgnoreCase(sp.External_Stage__c)|| sp.Stage__c == 'Submitted' || sp.Stage__c == 'Incomplete' || sp.Stage__c == 'Checked' || sp.Stage__c == 'Reviewed' || sp.Stage__c == 'Completed' || sp.Stage__c == 'Withdrawn' || sp.Stage__c == 'Reject'||sp.Stage__c == 'Accepted'){
            step = new StepWizard(1, wizardSteps, PreRegistrationServices.stepTitles);
        }else {
            step = new StepWizard(0, wizardSteps, PreRegistrationServices.stepTitles);
        }
        
        requiredMode = false;
        isDataProtectionChecked = (sp.Data_Protection_Reg__c == null ? false : sp.Data_Protection_Reg__c);
        isTermsChecked = (sp.Terms_Conditions_Reg__c == null ? false : sp.Terms_Conditions_Reg__c);
        student = ApplyServices.findPersonalDetails(sp.Student__c);
    }

    /**
     * Indicates to old upload style (without cropping) will be used
     */
    public Boolean oldUploadImageStyle { get; set; }

    /**
     * Show map where key = name of step, value = error flag (true means error)
     */
    public Map<String,Boolean> errorByStep { 
        get {
            if (errorByStep == null) {
                errorByStep = new Map<String,Boolean>();
                for (String name: wizardSteps) {
                    errorByStep.put(name, false);
                }
            }
            return errorByStep;
        } 
        set; 
    }

    /**
     * Current wizard step (can be used for skipping wizard pages)
     */
    public List<String> wizardSteps { get; set; }

    /**
     * Data Protection checkbox
     */
    public Boolean isDataProtectionChecked { get; set; }

    /**
     * Terms And Conditions checkbox
     */
    public Boolean isTermsChecked { get; set; }

    /**
     * Is any error or missing fields after validation
     */
    public Boolean isValidationErrors { 
        get {
            for (Boolean wasError: errorByStep.values()) {
                if (wasError) 
                    return true;
            }
            return false;
        }
    }

    /**
     * List of new qualifications
     */
    public List<Qualifications_Experience__c> newQeList { 
        get {
            if (newQeList == null) {
                newQeList = new List<Qualifications_Experience__c>();
            }
            return newQeList;
        }
        set;
    }
    
    /**
     * Get ID of attachment with passport photo or null
     */
    public Id passportAttachmentId { get {
        //2015-03-20 : SM : We now link the Passport photo to Student Programme not the Student
        List<Attachment> aList = CommonUtils.findAttachments(sp.Id, PASSPORT_PHOTO_ATTACHMENT_DESCRIPTION);
        //List<Attachment> aList = CommonUtils.findAttachments(student.Id, PASSPORT_PHOTO_ATTACHMENT_DESCRIPTION);
        if ( aList.isEmpty() ) {
            return null;
        } else {
            System.debug('Photo ID = ' + aList[0].Id);
            return aList[0].Id;
        }
    } }

    /**
     * Qualifications Labels
     */
    public Map<Id, String> qeLabels {
        get {
            if(qeLabels == null) {
                qeLabels = new Map<Id, String>();
                qeLabels.put(CommonUtils.findRecordTypeIdByDev('Qualifications_Experience__c', ApplyServices.RT_ACADEMIC_QE_DEVNAME), 'Academic Qualification');
                qeLabels.put(CommonUtils.findRecordTypeIdByDev('Qualifications_Experience__c', ApplyServices.RT_PROFESSIONAL_QE_DEVNAME), 'Professional Qualification');
            }
            return qeLabels;
        }
        set;
    }

    /**
     * Qualifications List
     */
    public List<Qualifications_Experience__c> qeList {
        get {
            if(qeList == null) {
                Set<Id> rtIds = new Set<Id> {
                    CommonUtils.findRecordTypeIdByDev('Qualifications_Experience__c', ApplyServices.RT_ACADEMIC_QE_DEVNAME),
                    CommonUtils.findRecordTypeIdByDev('Qualifications_Experience__c', ApplyServices.RT_PROFESSIONAL_QE_DEVNAME)
                };
                qeList = ApplyServices.findRelatedQualifications(sp.Student__c, rtIds);
            }
            return qeList;
        }
        set;
    }

    /**
     * Indicates read only mode for student programme
     */
    public Boolean readonlyMode { 
        get {
            if(((sp.Programme_Type__c=='Closed Course' || sp.Programme_Type__c=='Online Course') && sp.Stage__c == 'Expected') ||sp.Stage__c == ApplyServices.COURSE_PRE_REGISTERED_STAGE_NAME || sp.Stage__c == 'Withdrawn' || sp.Stage__c == 'Completed' || sp.Stage__c == 'Submitted' || sp.Stage__c == 'Reject' || sp.Stage__c == 'Incomplete' || sp.Stage__c == 'Checked' || sp.Stage__c =='Reviewed'|| sp.Stage__c == 'Registered' || sp.Stage__c == 'Accepted') {
                return true;
            } else {
                return false;
            }
        }
    }
    // A variable to show and hide Review Button
    public Boolean showReviewButton{ 
        get {
            if( sp.Stage__c == 'Submitted' || 
                sp.Stage__c == 'Incomplete'||
                sp.Stage__c == 'Checked' || 
                sp.Stage__c == 'Reviewed' || 
                sp.Stage__c == 'Accepted'|| 
                sp.Stage__c == 'Reject'||
                sp.Stage__c == ApplyServices.COURSE_PRE_REGISTERED_STAGE_NAME || 
                sp.Stage__c == 'Registered'||
                sp.Stage__c == 'Completed'||
                sp.Stage__c == 'Withdrawn') {
                return false;
            } 
            else{
                return true;
            }
        }
    }
    //Suyati Modified 26-04-2016
    public Boolean readonlyUpload { 
        get {
            if(sp.Stage__c == 'Submitted' || sp.Stage__c == 'Incomplete'||sp.Stage__c == 'Checked' || sp.Stage__c == 'Reviewed' || sp.Stage__c == 'Accepted'|| sp.Stage__c == 'Draft' || sp.Stage__c == 'Expected') {
                return true;
            } else if(sp.Stage__c == 'Reject'|| sp.Stage__c == ApplyServices.COURSE_PRE_REGISTERED_STAGE_NAME || sp.Stage__c == 'Registered' ||sp.Stage__c == 'Completed' ||sp.Stage__c == 'Withdrawn' ){
                return false;
            }
            else{
                return false;
            }
        }
    }
    //Suyati Modified End

    //

    /**
     * Indicates validation mode where required fields are mandatory (true)
     */
    public Boolean requiredMode { get; set; }

    /**
     * Student_Programme__c item
     */
    public final Student_Programme__c sp { get; private set; }

    /**
     * Current step
     */
    public StepWizard step { get; set; }

    /**
     * Name of step to jump
     */
    public String stepName { get; set; }

    /**
     * Related to the Student_Programme__c Contact object (personal details)
     */
    public Contact student { get; set; }

    /**
     * Reads html static resource TermsAndConditions
     * 2015-03-13 : SM : Updating this to look at the Page Copy object
     */
    public String textFromTermsAndConditions {
        get {
            //StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'TermsAndConditions'];
            //return sr.Body.toString();
            List<Page_Copy__c> pgList = [SELECT p.Id, p.Body_Copy__c from Page_Copy__c p where
                                            p.Copy_Location__c = 'Pre-Registration Terms Conditions' 
                                            and p.Page_Status__c = 'Active' LIMIT 1];
            if (pgList == null || pgList.isEmpty()){
                return 'Terms & Conditions Statement';
            }else {
                return pgList[0].Body_Copy__c;
            }
        }
    }

    /**
     * Reads html static resource DataProtection
     * 2015-03-13 : SM : Updating this to look at the Page Copy object
     */
    public String textFromDataProtection {
        get {
            //StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'DataProtection'];
            //return sr.Body.toString();
            List<Page_Copy__c> pgList = [SELECT p.Id, p.Body_Copy__c from Page_Copy__c p where
                                            p.Copy_Location__c = 'Pre-Registration Data Protection' 
                                            and p.Page_Status__c = 'Active' LIMIT 1];
            if (pgList == null || pgList.isEmpty()){
                return 'Data Protection Statement';
            }else {
                return pgList[0].Body_Copy__c;
            }
        }
    }

    /**
     * Indicates step of validation (if true)
     */
    public Boolean validationStep { get; set; }

    /**
     * remove empty qualifications records from student programme
     */
    private void cleanQEList() {
        List<Qualifications_Experience__c> qeListToDelete = new List<Qualifications_Experience__c>();
        for(Integer j = qeList.size()-1; j>=0; j--) {
            if(
                CommonUtils.allFieldsAreEmpty(qeList.get(j), 'Name_of_College_University__c,Country__c,Start_Date__c,End_Date__c,Qualification__c,Subject__c,Class_Grade__c,Date_of_Award__c')
                && !CommonUtils.hasAttachment(qeList.get(j).Id)
            ) {
                qeListToDelete.add(qeList.get(j));
                qeList.remove(j);
            }
        }
        delete qeListToDelete;
    }
    
    /**
     * Add new qualification to the newQeList
     * @param DeveloperName of RecordType
     * @return Just created object
     */
    private Qualifications_Experience__c addQE(String rt) {
        Qualifications_Experience__c qeItem = ApplyServices.buildQualification(student.Id, sp.Id, rt);
        newQeList.add(qeItem);
        return qeItem;
    }
    
    /**
     * Action for add new Academic qualification
     */
    public void addAcademicQE() {
        insert addQE(ApplyServices.RT_ACADEMIC_QE_DEVNAME);
    }

    /**
     * Action for add new Professional qualification
     */
    public void addProfessionalQE() {
        insert addQE(ApplyServices.RT_PROFESSIONAL_QE_DEVNAME);
    }

    /**
     * remove empty new qualifications from lists
     */
    public void cleanNewQEList() {
        List<Qualifications_Experience__c> qeListToDelete = new List<Qualifications_Experience__c>();
        for(Integer j = newQeList.size()-1; j>=0; j--) {
            if(
                CommonUtils.allFieldsAreEmpty(newQeList.get(j), 'Name_of_College_University__c,Country__c,Start_Date__c,End_Date__c,Qualification__c,Subject__c,Class_Grade__c,Date_of_Award__c')
                && !CommonUtils.hasAttachment(newQeList.get(j).Id)
            ) {
                qeListToDelete.add(newQeList.get(j));
                newQeList.remove(j);
            }
        }
        delete qeListToDelete;
    }

    /**
     * Populating values for countries dropdown list
     * @return List<SelectOption> options
     */
    public List<SelectOption> getCountriesOptions() {
        return PreRegistrationServices.countriesList;
    }

    /**
     * Returns selected by student programmes list
     * @return List<ProgrammeWrapper> programmesList
     */
    public List<ProgrammeWrapper> getStudentProgrammes() {
        List<ProgrammeWrapper> programmesList = new List<ProgrammeWrapper>();
        for(Programme__c p : [SELECT Id, Code__c, Name, Start_Date__c, End_Date__c, Home_EU_Fee__c, Overseas_Fee__c FROM Programme__c WHERE Id=:sp.Programme__c])
            programmesList.add(new ProgrammeWrapper(p));
        return programmesList;
    }

    /**
     * Action goes to home page
     * @return PageReference of home page
     */
    public PageReference gotoHomePage() {
        return new PageReference('/');
    }

     /**
     * Action goes to New User Information page
     * @return PageReference of new user information page
     */
    public PageReference gotoNewUserPage() {
        return new PageReference('/LSTMUserPage?Id=' + sp.Id);
    }

    /**
     * Action to move to the next step of wizard
     */
    public void gotoNextStep() {
        if ( step.hasNextStep && isStepFieldsValid(step.getName())) {
            step.stepIndex++;
        }
    }
    
    /**
     * Action to move to the previous step of wizard
     */

    public void gotoPreviousStep() {
        if ( step.hasPreviousStep && isStepFieldsValid(step.getName())) {
            step.stepIndex--;
        }
    }

    /**
     * Action to move to the this.stepName step of wizard
     */
    public void gotoStep() {
        if ( step.gotoStepByName(stepName) ) {
            validationStep = false;
        }
    }

    
    /**
     * Init action to cleanup empty qualification expiriences
     * Should be used as action param of Visualforce page
     */
    public void init() {
        cleanQEList();
    }

    /**
     * Use this method to perform additional validation of step data
     */
    public Boolean isStepFieldsValid(String nameOfStep) {
        if (nameOfStep == PreRegistrationServices.STEP_ACADEMIC_QUALIFICATIONS) {
            cleanNewQEList();
        }
        if (requiredMode) { 
            if (nameOfStep == PreRegistrationServices.STEP_UPLOAD_PHOTO) {
                if (passportAttachmentId==null) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, PASSPORT_PHOTO_ATTACHMENT_ERROR_MESSAGE));
                    return false;
                }
            }
        }
        return true;
    }

    /**
     * Persist application form
     */
    private void saveApplication() {
        // save
        student.Photo_Attachment_ID__c = passportAttachmentId;
        update student;
        //sp
        //sp.Stage__c = ( isValidationErrors ) ? ApplyServices.COURSE_EXPECTED_STAGE_NAME : ApplyServices.COURSE_PRE_REGISTERED_STAGE_NAME;
        //2015-03-19 : SM : Write back the terms & conditions and data protection boolean values to the SP record
        sp.Terms_Conditions_Reg__c = isTermsChecked;
        sp.Data_Protection_Reg__c = isDataProtectionChecked;
        update sp;
        // save QEs
        cleanNewQEList();
        update qeList;
        update newQeList;
        for(Qualifications_Experience__c q : newQeList) {
            qeList.add(q);
        }
        newQeList.clear();
    }

    /**
     * Action: save and close student resistration form in draft mode
     * @return Home page reference
     */
    public PageReference saveDraftApplication() {
        validate(); // need for detect Stage__c status
        return gotoHomePage();
    }

    /**
     * Action for validating form and save application form if validation was successful
     */
    public void validate() {
        requiredMode = true;
        validationStep = true;
        // personal address
        Boolean pdAddress = CommonUtils.hasEmptyFields(student, 'MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry');
        errorByStep.put(PreRegistrationServices.STEP_PERSONAL_ADDRESS, pdAddress);
        // term time address
        //2015-03-19 : SM : We now use Student Programme to store the fields below, so changing this validation step
        //Boolean ttAddress = CommonUtils.hasEmptyFields(student, 'TTA_MailingStreet__c,TTA_MailingCity__c,TTA_MailingCounty__c,TTA_MailingPostcode__c,TTA_MailingCountry__c,ECD_Address__c,ECD_Name__c,ECD_Relationship__c');
        //2015-03-27 : SM : We now no longer need to validate TTA fields, nor ECD Address, but we need to add in ECD_Phone__c
        Boolean ttAddress = CommonUtils.hasEmptyFields(sp, 'ECD_Phone__c,ECD_Name__c,ECD_Relationship__c');
        errorByStep.put(PreRegistrationServices.STEP_TERM_TIME_ADDRESS, ttAddress);
        // passport photo
        //2015-04-02 : SM : Removing the validation for the Photo Upload, but functionality being kept
        //errorByStep.put(PreRegistrationServices.STEP_UPLOAD_PHOTO, !isStepFieldsValid(PreRegistrationServices.STEP_UPLOAD_PHOTO));
        // terms accepted
        Boolean termsAccepted = (isTermsChecked&&isDataProtectionChecked);
        errorByStep.put(PreRegistrationServices.STEP_TERMS_AND_CONDITIONS, !termsAccepted);
        
        saveApplication();
    }
    //Suyati Modified 31-03-2016
    public String getProfilePicture(){
        list<Attachment> attach = [SELECT Id, ContentType, ParentId, Body FROM Attachment where id =: passportAttachmentId limit 1];
       
        if(attach.size()!=0){
            String blobValue = EncodingUtil.base64Encode(attach[0].Body);
            return blobValue;
        }
        else{
            return '';
        }
    }
    
    
    //Suyati Modified End
}