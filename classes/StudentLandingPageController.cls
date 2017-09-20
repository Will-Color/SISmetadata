/*
* Simon Molloy 
* 2014-07-18 : CSL : This controller is for the Student Landing Page in the Customer Community
*
*/
/***** Modifications 
/// Support Task, remove health__c from all the code on 14-06-2015 *****/
///Author Maneesh
/// <summary> Removed Usage of fields Health__c from SOQL </summary>
/***** Modifications 2
/// Phase 2C, Applicant refrence on 06-10-2015
///Author Manu KM 
/// <summary>Modified Diffrenet panels:-submitted application and offerd to show the applicant reference status and application status with description </summary>
*/
public class StudentLandingPageController {
      
    public final String STAGE_DRAFT = 'Draft';
    public final String STAGE_SUBMITTED = 'Submitted';
    public final String STAGE_INCOMPLETE = 'Incomplete';
    public final String STAGE_CHECKED = 'Checked';
    public final String STAGE_REVIEWED = 'Reviewed';
    public final String STAGE_OFFERED = 'Offered';
    public final String STAGE_CONDITIONAL = 'Conditional';
    public final String STAGE_UNCONDITIONAL = 'Unconditional';
    public final String STAGE_ACCEPTED = 'Accepted';
    public final String STAGE_EXPECTED = 'Expected';
    public final String STAGE_REJECT = 'Reject';
    public final String STAGE_PRE_REGISTERED = 'Pre-Registered';
    public final String STAGE_REGISTERED = 'Registered';
    public final String STAGE_COMPLETED = 'Completed';
    public final String STAGE_WITHDRAWN = 'Withdrawn';
    
    //Student programme stage description Notes
    public final String STAGE_SUBMITTED_DESC = '(we have received your application, which is being processed)';
    public final String STAGE_CHECKED_DESC = '(your application has been checked and has been forwarded for review by the Director of Studies)';
    public final String STAGE_INCOMPLETE_DESC ='(we are awaiting additional information from you and/or your referees before we can process your application)';
    public final String STAGE_REVIEWED_DESC = '(your application has been reviewed by the DoS and you will be notified of the decision by email)';
    public final String STAGE_CONDITIONAL_DESC =  '(your offer is subject to the conditions set out in your offer letter)';
    public final String STAGE_UNCONDITIONAL_DESC =  '(Please Accept or Reject this offer)';
    
    public final String GROUP_STAGE_DRAFT = 'Draft';
    public final String GROUP_STAGE_SUBMITTED = 'Submitted';
    public final String GROUP_STAGE_OFFERS = 'Offers';
    public final String GROUP_STAGE_REJECTED = 'Rejected';
    public final String GROUP_STAGE_REGISTRATION = 'Registration';
    public final String GROUP_STAGE_COMPLETED = 'Completed';
    //Suyati Modified 21-04-2016
    public final String GROUP_STAGE_WITHDRAWN = 'Withdrawn';
    
    public final String PAGE_STATUS_ACTIVE = 'Active';
    public final String PAGE_COPY_RECORD_TYPE = 'Main_body_copy';
    public final String OFFER_CONDITION_PAGE_COPY_RECORD_TYPE = 'Multi_part_copy';
    public final String SP_ID_PARAM = 'Id';
    public final String CASE_OWNER_NAME = 'Admission Team';
    //refrence status Description
    public final String REF_STAGE_SUBMITTED_DESC = '(the reference you uploaded is being processed with your application)';
    public final String REF_STAGE_REPLIED_DEC = '(a reference has been received and has been forwarded for review by the Director of Studies)';
    public final String REF_STAGE_CHECKED_DEC = '(the reference has been checked and verified)';
         
    Map<String, String> stageToGroupStageMap = new Map<String, String>();

    public List<SelectOption> offerOptions {
        get {
            if (offerOptions == null){
                Schema.DescribeFieldResult F = Student_Programme__c.Conditions_Acceptance__c.getDescribe();
                
                offerOptions = new List<SelectOption>();
                offerOptions.add(new SelectOption('NULL','--Please Select--'));
                for (Schema.PicklistEntry pe : F.getPicklistValues()){
                    offerOptions.add(new SelectOption(pe.getValue().toUpperCase(),pe.getValue()));
                }
            }
            return offerOptions;
        }
        set;
    }
   

    public Id communityProfileId {
        get {
            Profile p;
            if (communityProfileId == null){
                p = [select p.Id from Profile p where p.Name = 'LSTM Community User' LIMIT 1];
            }
            return p.Id;
        }
        set;
    }
  
    
    public String offerAccepted {get; set;}
    public Student_Programme__c currentSP {get; set;}
    public List<Student_Programme__c> draftApplications {get; set;}
    public List<Student_Programme__c> submittedApplications {get; set;}
    public List<Student_Programme__c> offeredApplications {get; set;}
    public List<Student_Programme__c> rejectedApplications {get; set;}
    //Suyati Modified 21-04-2016
    public List<Student_Programme__c> withdrawnApplications{get;set;}
    //2015-03-27 : SM : New list of 'Expected' applications for the Welcome Page
    public List<Student_Programme__c> expectedApplications {get; set;}
    public List<Student_Programme__c> registrationApplications {get; set;}
    public List<Student_Programme__c> completedApplications {get; set;}
    
    public User currentUser {get;set;}
    public Contact currentStudentRecord {get; set;}
    public boolean showDraft {get; set;}
    public boolean showSubmitted {get; set;}
    public boolean showOffered {get; set;}
    public boolean showRejected {get; set;}
    //Suyati modified 21-04-2016
    public boolean showWithdrawn {get;set;}
    public boolean showRegistration {get; set;}
    //2015-03-27 : SM : New boolean value for Expected for the Welcome Page
    public boolean showExpected {get; set;}
    public boolean showCompleted {get; set;}
    public List<Page_Copy__c> pageCopyList {get; set;}
    public List<Page_Copy__c> offerConditionsList {get; set;}
    public Page_Copy__c pageCopy {get; set;}
    public Page_Copy__c offerConditions {get; set;}
    public boolean foundPageCopy {get; set;}
    public String acceptOfferError {get; set;}
    public String caseRejectReason {get; set;}
    public List<References__c> submittedAppRefrences {get; set;}
  //  public List<References__c> offeredAppliref{get; set;}
    //Suyati Modification refrences 
    //map used store the refrence status and description
    public map<id,string> mapStatus {get;set;}
     //map used store the Submitted application refrence status and description
    public Map<id,List<wrapperrefrences>> lstRefrerences {get;set;}
     //map used store the offrede refrence status and description
    public Map<id,List<wrapperrefrences>> lstRefrerences1 {get;set;}   
     //map used store the offred refrence status and description 
    public Map<id,List<wrapperrefrences>> mapOfferRefrerences {get;set;}  
    //map used store the offred refrence status and description  
    public List<wrapperrefrences> offeredRef {get; set;}
      //map used store the offred refrence status and description 
    public List<wrapperrefrences> offeredRef1 {get; set;}
    //map used store the submitted refrence status and description 
    public List<wrapperrefrences> submittedRef {get; set;}
  
    public StudentLandingPageController(){
        Id spId = ApexPages.currentPage().getParameters().get(SP_ID_PARAM);
        if (spId != null){
                       
             currentSP = [Select s.UK_Visa_Required__c, s.Type_of_Visa__c, s.Student__c, s.Student__r.FirstName,
                            s.Student__r.LastName, s.Student_Acceptance__c,
                            s.Stage__c, s.Sponsor_Official_Position__c, s.Sponsor_Email_Address__c, s.Sponsor_Address_for_Invoice__c, 
                            s.RecordTypeId, s.Received_a_scholarship_sponsorship_offer__c, s.Reasons_for_choosing_to_study_at_LSTM__c, s.Reasons_for_choosing_programme__c, 
                            s.Proposed_Start_Date__c, s.Proposed_Area_of_Research__c,s.Programme__c, s.Programme_Type__c, 
                            s.Personal_Statement__c, s.Payment_method_if_Self_financing__c, s.Passport_Number__c, 
                            s.Other_Relevant_Skills_and_Experience__c, s.Offer_Conditions__c, s.Non_EEA_student_Visa_Details__c, s.Name_of_Sponsor_Financial_Guarantor__c, 
                            s.Name_Address_of_Funding_Body__c, s.Name, s.Mode_of_Study__c, s.IsDeleted, s.If_Sponsored_indicate_the_following__c, 
                            s.If_Sponsored_applied_for_sponsorship__c, s.Id, s.How_does_programme_connect_to_career_pla__c, s.How_did_you_hear_about_this_Course__c, 
                            s.How_did_you_hear_about_Course_Specify__c, s.Future_Plans__c, s.Fees_and_Funding__c, s.Expiry_Date__c, 
                            s.Ethnic_Origin__c,s.Do_you_have_any_Criminal_Convictions__c, s.Do_you_have_a_Disability__c, s.Disability__c, 
                            s.Description__c, s.Created_In_Portal__c, s.Country_of_Issue__c, s.Conditions_Acceptance__c, 
                            s.Application_discussed_with_LSTM_staff__c, s.Application_discussed_with_LSTM_details__c, s.Amount__c
                            From Student_Programme__c s where s.Id = :spId LIMIT 1];
                            
                            
        }
        system.debug('currentSP '+currentSP );
        stageToGroupStageMap.put(STAGE_DRAFT, GROUP_STAGE_DRAFT);
        stageToGroupStageMap.put(STAGE_SUBMITTED, GROUP_STAGE_SUBMITTED);
        stageToGroupStageMap.put(STAGE_INCOMPLETE, GROUP_STAGE_SUBMITTED);
        stageToGroupStageMap.put(STAGE_CHECKED, GROUP_STAGE_SUBMITTED);
        stageToGroupStageMap.put(STAGE_REVIEWED, GROUP_STAGE_SUBMITTED);
        stageToGroupStageMap.put(STAGE_CONDITIONAL, GROUP_STAGE_OFFERS);
        stageToGroupStageMap.put(STAGE_UNCONDITIONAL, GROUP_STAGE_OFFERS);
        stageToGroupStageMap.put(STAGE_ACCEPTED, GROUP_STAGE_OFFERS);
        //2015-03-13 : SM : Moving the EXPECTED stage into the REGISTERED Group as per request
        
        //stageToGroupStageMap.put(STAGE_EXPECTED, GROUP_STAGE_OFFERS);
        stageToGroupStageMap.put(STAGE_EXPECTED, GROUP_STAGE_REGISTRATION);
        stageToGroupStageMap.put(STAGE_REJECT, GROUP_STAGE_REJECTED);
        stageToGroupStageMap.put(STAGE_PRE_REGISTERED, GROUP_STAGE_REGISTRATION);
        stageToGroupStageMap.put(STAGE_REGISTERED, GROUP_STAGE_REGISTRATION);
        stageToGroupStageMap.put(STAGE_COMPLETED, GROUP_STAGE_COMPLETED);
         stageToGroupStageMap.put(STAGE_WITHDRAWN, GROUP_STAGE_WITHDRAWN);
        
        
        RecordType pageCopyRecordType = [select r.Id from RecordType r where r.SObjectType = 'Page_Copy__c' and r.DeveloperName = :PAGE_COPY_RECORD_TYPE LIMIT 1];
        RecordType offerConditionsRecordType = [select r.Id from RecordType r where r.SObjectType = 'Page_Copy__c' and r.DeveloperName = :OFFER_CONDITION_PAGE_COPY_RECORD_TYPE LIMIT 1];
        draftApplications = new List<Student_Programme__c>();
        submittedApplications = new List<Student_Programme__c>();
        offeredApplications = new List<Student_Programme__c>();
        rejectedApplications = new List<Student_Programme__c>();
        //Suyati Modified 21-04-2016
        withdrawnApplications = new List<Student_Programme__c>(); 
        registrationApplications = new List<Student_Programme__c>();
        expectedApplications = new List<Student_Programme__c>();
        completedApplications = new List<Student_Programme__c>();
        submittedAppRefrences = new List<References__c>();
       
        //Suyati Modification for References
        mapOfferRefrerences = new Map<id,List<wrapperrefrences>> ();
        offeredRef = new List<wrapperrefrences>();
        offeredRef1 = new List<wrapperrefrences>();               
        lstRefrerences = new  Map<id,List<wrapperrefrences>>();
        lstRefrerences1 = new  Map<id,List<wrapperrefrences>>();
        mapStatus = new map<id,String>();               
        //Suyati Modification for References ends
        
        showDraft = false;
        showSubmitted = false;
        showOffered = false;
        showRejected = false;       
        showRegistration = false;
        showExpected = false;
        showCompleted = false;
        foundPageCopy = false;
        //Suyati Modified 21-04-2016
        showWithdrawn = false;
        
        if (test.isRunningTest()){
            currentUser = [select u.Id, u.ContactId, u.ProfileId from User u where u.ProfileId = :communityProfileId and u.IsActive = true LIMIT 1];
        }else {
            currentUser = [select u.Id, u.ContactId, u.ProfileId from User u where u.Id = :UserInfo.getUserId() LIMIT 1];
        }        
        if (currentUser != null){
            currentStudentRecord = [select c.Id, c.Name from Contact c where c.Id = :currentUser.ContactId LIMIT 1];
        }        
        if (currentStudentRecord != null){
            for (Student_Programme__c sp : [select s.Id, s.Name, s.Programme__c, s.Programme__r.Name, s.Programme_Type__c, s.Stage__c from Student_Programme__c s where s.Student__c = :currentStudentRecord.Id]){
                system.debug('sp'+sp);
                String whichStage = stageToGroupStageMap.get(sp.Stage__c);
                system.debug('GROUP_STAGE_DRAFT.equalsIgnoreCase(whichStage)'+GROUP_STAGE_DRAFT.equalsIgnoreCase(whichStage));
                 system.debug('GROUP_STAGE_SUBMITTED.equalsIgnoreCase(whichStage)'+GROUP_STAGE_SUBMITTED.equalsIgnoreCase(whichStage));
                if (GROUP_STAGE_DRAFT.equalsIgnoreCase(whichStage)){
                    draftApplications.add(sp);
                }else if (GROUP_STAGE_SUBMITTED.equalsIgnoreCase(whichStage)){
                    submittedApplications.add(sp);                   
                    //suyati modification  for collecting all the submitted application's refrences and status and description                                                                                                                                   
                    offeredRef1 = findStageDescription(sp.id);
                    lstRefrerences1.put(sp.id,offeredRef1); 
                    offeredRef1 = new List<wrapperrefrences>();                                                                                                         
                    //ends suyati modification      
                }else if (GROUP_STAGE_OFFERS.equalsIgnoreCase(whichStage)){
                    offeredApplications.add(sp);
                    //suyati modification  for collecting all the offered application's refrences and status and description 
                    offeredRef = findStageDescription(sp.id);                                                     
                    mapOfferRefrerences.put(sp.id,offeredRef);
                    offeredRef= new List<wrapperrefrences>(); 
                    //Suyati modification ends
                }else if (GROUP_STAGE_REJECTED.equalsIgnoreCase(whichStage)){
                    rejectedApplications.add(sp);
                }else if (GROUP_STAGE_REGISTRATION.equalsIgnoreCase(whichStage)){                
                    registrationApplications.add(sp);                                     
                }else if (GROUP_STAGE_COMPLETED.equalsIgnoreCase(whichStage)){
                    completedApplications.add(sp);
                }else if(GROUP_STAGE_WITHDRAWN.equalsIgnoreCase(whichStage)){
                    withdrawnApplications.add(sp);
                    System.debug('Inside Size 1 = '+withdrawnApplications.size());
                }

                System.debug('Outside Size 1 = '+withdrawnApplications.size());
                if (STAGE_EXPECTED.equalsIgnoreCase(sp.Stage__c)){
                    expectedApplications.add(sp);
                }
            }
            //Suyati modification for assigning all the application status and description
            
            for( Student_Programme__c spStatus:submittedApplications){
              
                
               String StatusTest = '';
               StatusTest  = findSpStageAndNote( spStatus);                
                mapStatus.put(spStatus.id,StatusTest ); 
            }
            
            for(Student_Programme__c spOfferApp :offeredApplications){
                String StatusTest = '';
                StatusTest = findSpStageAndNote(spOfferApp );               
                mapStatus.put(spOfferApp.id,StatusTest);
            }
            //Suyati modification for status
            System.debug('lstRefrerences'+lstRefrerences);
            if (draftApplications.size() > 0) showDraft = true;
            if (submittedApplications.size() > 0) showSubmitted = true;
            if (offeredApplications.size() > 0) showOffered = true;
            if (rejectedApplications.size() > 0) showRejected = true;
            //Suyati Modified 21-04-2016
            if (withdrawnApplications.size()>0) showWithdrawn = true;
            if (registrationApplications.size() > 0) showRegistration = true;
            if (expectedApplications.size() > 0) showExpected = true;
            if (completedApplications.size() > 0) showCompleted = true;
            
        }
        
        //This code brings back Page Copy information for the Welcome Page
        pageCopyList = [select p.Name, p.Active_Date__c, p.Body_Copy__c, p.Link_1_Name__c, p.Link_1_URL__c, p.Link_2_Name__c, p.Link_2_URL__c,p.Link_3_Name__c, p.Link_3_URL__c, p.Page_Status__c from Page_Copy__c p 
                        where p.Page_Status__c = :PAGE_STATUS_ACTIVE 
                        and p.RecordTypeId = :pageCopyRecordType.Id
                        and p.Copy_Location__c = 'Applicant Homepage' order by p.Active_Date__c DESC ];
                        
        if (pageCopyList != null && pageCopyList.size() > 0){
            pageCopy = pageCopyList[0];
            foundPageCopy = true;
        }   
        
        offerConditionsList = [select p.Name, p.Active_Date__c, p.Body_Copy__c, p.Link_1_Name__c, p.Link_1_URL__c, p.Link_2_Name__c, p.Link_2_URL__c,p.Link_3_Name__c, p.Link_3_URL__c, p.Page_Status__c from Page_Copy__c p 
                        where p.Page_Status__c = :PAGE_STATUS_ACTIVE 
                        and p.RecordTypeId = :offerConditionsRecordType.Id 
                        and p.Copy_Location__c = 'Conditional Offer page' order by p.Active_Date__c DESC ];
                        
        if (offerConditionsList != null && offerConditionsList.size() > 0){
            offerConditions = offerConditionsList[0];
        }                   
    }
    //This method returns the Student Prgramme stage and description note
    public String findSpStageAndNote(Student_Programme__c spStatus){
        String StatusTest = '';
        if(spStatus.Stage__c == 'Submitted'){
            StatusTest = STAGE_SUBMITTED_DESC ;
        }
        else if(spStatus.Stage__c == 'Checked'){
         StatusTest = STAGE_CHECKED_DESC ;
        }
        else if(spStatus.Stage__c == 'Incomplete'){
         StatusTest = STAGE_INCOMPLETE_DESC ;
        }
        else if(spStatus.Stage__c == 'Reviewed'){
         StatusTest = STAGE_REVIEWED_DESC ;
        }
        else if(spStatus.Stage__c == 'Conditional'){
         StatusTest = STAGE_CONDITIONAL_DESC ;
        }
        else if(spStatus.Stage__c == 'Unconditional'){
         StatusTest = STAGE_UNCONDITIONAL_DESC ;
        }
        /* condition for WAITING LIST stage yet to be defined
        else if(spStatus.Stage__c == 'WAITING LIST'){
         StatusTest = 'Yet to defiend';
        }*/
        return StatusTest ;
    }
    //returns the stage as map
   public List<wrapperrefrences> findStageDescription(Id spid){
           List<wrapperrefrences> returnResult = new List<wrapperrefrences>();
           for(References__c status1 : [SELECT Id, Name,Referee_Name__c,Reference_Status__c,LastModifiedDate FROM References__c where Student_Programme__c =:spid ] ){
                       wrapperrefrences tempWrapperHolder1 = new wrapperrefrences(); 
                       if(status1.Reference_Status__c == 'Draft' ){                       
                           tempWrapperHolder1.status = '';
                           tempWrapperHolder1.refrence = 'Draft';                          
                       } 
                       else if(status1.Reference_Status__c == 'Submitted' ){                     
                            tempWrapperHolder1.refrence = 'SUBMITTED ';
                            tempWrapperHolder1.status = REF_STAGE_SUBMITTED_DESC ;                           
                       } 
                       else if(status1.Reference_Status__c == 'Requested' ){                            
                            DateTime dT = status1.LastModifiedDate ;                          
                            tempWrapperHolder1.refrence = 'REQUESTED';
                            tempWrapperHolder1.status = '(we requested a reference on '+  dT.day()+'/' + dT.month() + '/'+ dT.year() + ' and we are awaiting a response)';                     
                       }
                       else if(status1.Reference_Status__c == 'Replied' ){
                            tempWrapperHolder1.refrence = 'Replied';                        
                            tempWrapperHolder1.status = REF_STAGE_REPLIED_DEC ;
                       } 
                       else if(status1.Reference_Status__c == 'Checked' ){
                            tempWrapperHolder1.refrence = 'CHECKED ';                       
                            tempWrapperHolder1.status = REF_STAGE_CHECKED_DEC ;
                       }
                       if(status1.Referee_Name__c != null){                        
                           tempWrapperHolder1.name = status1.Referee_Name__c ; 
                           returnResult.add(tempWrapperHolder1);                                                  
                       }                 
                    }  
       return returnResult  ; 
    }
    //This method is called from the Cancel button on the AcceptOffer VF Page
    public PageReference cancelFromAcceptOffer(){
        return Page.StudentLandingPage;
        
    }
    
    //This method is called from the Accept button on the AcceptOffer VF Page
    public PageReference acceptFromAcceptOffer(){
        system.debug('*** -- Into acceptFromAcceptOffer -- ***');
        PageReference pageRef;
        //Validate that they have selected 'Yes' and then update the Student Programme
        if ('NULL'.equalsIgnoreCase(currentSP.Conditions_Acceptance__c) || 'NO'.equalsIgnoreCase(currentSP.Conditions_Acceptance__c)){
            acceptOfferError = 'You must accept the Conditions before accepting the offer';
            return null;            
        }else {
            currentSP.Student_Acceptance__c = 'Yes';
            currentSP.Stage__c = STAGE_ACCEPTED;
            update currentSP;
            //pageRef = Page.StudentLandingPage;
            pageRef = Page.WelcomePage;
            return pageRef;
        }       
        
        
        return pageRef;
    }
    
    //This method is called from the Reject button on the AcceptOffer VF Page
    public PageReference rejectFromAcceptOffer(){
        //We need to forward to the new 'Case' screen for logging the rejection reason
        PageReference pageRef = Page.RejectionReason;
        
        currentSP.Student_Acceptance__c = 'No';
        currentSP.Stage__c = STAGE_REJECT;
        update currentSP;
        
        pageRef.getParameters().put(SP_ID_PARAM,currentSP.Id);
        pageRef.setRedirect(true);
        
        return pageRef;
    }
    
    //This method is called when a user has provided a Rejection Reason from the RejectionReason VF Page
    public PageReference createCaseFromRejection(){
        List<Group> admissionTeamList = [select g.Id, g.Name from Group g where g.Name = :CASE_OWNER_NAME LIMIT 1];
        Case rejectionCase = new Case();
        rejectionCase.ContactId = currentSP.Student__c;
        rejectionCase.First_Name__c = currentSP.Student__r.FirstName;
        rejectionCase.Last_Name__c = currentSP.Student__r.LastName;
        rejectionCase.Enquiry_Type__c = 'Student Information';
        rejectionCase.Student_Enquiry_Type__c = 'General Information';
        rejectionCase.Origin = 'Web';
        rejectionCase.Subject = 'Offer Rejected';
        rejectionCase.Student_Programme__c = currentSP.Id;
        if (caseRejectReason == null || caseRejectReason.length() == 0){
            caseRejectReason = 'No reason supplied';
        }
        rejectionCase.Description = caseRejectReason;
        
        if (!admissionTeamList.isEmpty()){
            rejectionCase.OwnerId = admissionTeamList[0].Id;
        }
        
        insert rejectionCase;
        
        
        return Page.WelcomePage;
    }
         
    //public List<> findreferences 
  public class wrapperrefrences {
      public string status{get; set;}
      public string refrence {get; set;}
      public string name{get; set;}
  }

}