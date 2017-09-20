/**
 * Different implementations of commands
 */
public with sharing class VleCommands {
    
    // Version of "lp" product
    public static final String LP_API_VERSION = '1.4';

    // API path
    public static final String CREATE_USER_API_PATH = '/d2l/api/lp/' + LP_API_VERSION + '/users/';
    public static final String CREATE_COURSE_API_PATH = '/d2l/api/lp/' + LP_API_VERSION + '/courses/';
    public static final String UPDATE_COURSE_API_PATH = '/d2l/api/lp/{0}/courses/{1}';
    public static final String ENROLL_USER_TO_COURSE_API_PATH = '/d2l/api/lp/' + LP_API_VERSION + '/enrollments/';
    public static final String UPDATE_ACTIVATION_API_PATH_TEMPLATE = '/d2l/api/lp/{0}/users/{1}/activation';
    public static final String DELETE_ENROLLMENTS_API_PATH_TEMPLATE = '/d2l/api/lp/{0}/enrollments/orgUnits/{1}/users/{2}';
    
    /**
     * Structure of JSON params for enrollemnt command 
     */
    public class EnrollmentParams {
        public Long roleId { get; set; }
        public Id userSourceId { get; set; } // Contact.Id
        public Long orgUnitId {get; set;} 
    }
    
    /**
     * Command for creating user with default role
     */
    public class CreateUser implements VleSyncServices.ICommand {
    
        @TestVisible
        private VleStructures.CreateUserData cuData;
        
        public Boolean sendEmail = true;
        public Contact person { get; set; }
        public Long roleId { get; set; }
        
        public void init(VLE_Sync_Command__c cmd) {
            cuData = new VleStructures.CreateUserData();
            cuData.OrgDefinedId = person.Id;
            cuData.FirstName = person.FirstName;
            cuData.LastName = person.LastName;
            cuData.MiddleName = ( String.isBlank(person.Middle_Name_Other_Names__c) ) ? '' : person.Middle_Name_Other_Names__c;
            //Modified by Suyati 24-03-2016
            System.debug('Person = '+person);
            System.debug('Record Type = '+person.RecordType.Name);
            if(person.RecordType.Name =='Student Applicant'){
                System.debug('Inside if');
                cuData.ExternalEmail = person.LSTM_Email__c;
                cuData.UserName = person.LSTM_Email__c;
            }
            else{
                cuData.ExternalEmail = person.Email;
                cuData.UserName = person.Email;
            }
            
            cuData.RoleId = roleId;
            cuData.IsActive = true;
            cuData.SendCreationEmail = sendEmail;
        }
        
        public HttpResponse makeCallout(VleServices.IUserContext userContext) {
            return VleServices.performHttpCall(
                CREATE_USER_API_PATH, VleServices.POST_METHOD, userContext, JSON.serialize(cuData)
            );
        }
        
        public VleSyncServices.ParseResult parseResultOk(HttpResponse resp) {
            VleSyncServices.ParseResult res = new VleSyncServices.ParseResult();
            VleStructures.UserData userData = (VleStructures.UserData) JSON.deserialize(resp.getBody(), VleStructures.UserData.Class);
            // set UserId and add Contact to updatedObjects
            person.VLE_ID__c = String.valueOf(userData.UserId);
            res.result = true;
            res.updatedRecords.add(person);
            return res;
        }
        
    }
    
    /**
     * Command for enrollment user to ordUnitId with certain role 
     */
    public class CreateEnrollment implements VleSyncServices.ICommand {
        
        @TestVisible
        private VleStructures.CreateEnrollmentData enrollData;
        
        public Contact cont { get; set; }
        public Long orgUnitId { get; set; }
        public Long roleId { get; set; }
        
        public void init(VLE_Sync_Command__c cmd) {
            enrollData = new VleStructures.CreateEnrollmentData();
            enrollData.OrgUnitId = orgUnitId;
            enrollData.UserId = Long.valueOf(cont.VLE_ID__c);
            // get ID of role from params if params not empty
            if ( !String.isBlank(cmd.Params__c) ) {
                EnrollmentParams enrParams = (EnrollmentParams) JSON.deserialize(cmd.Params__c, EnrollmentParams.class); 
                enrollData.RoleId = enrParams.roleId;
            } else {
                enrollData.RoleId = roleId;
            }
        }
        
        public HttpResponse makeCallout(VleServices.IUserContext userContext) {
            return VleServices.performHttpCall(
                ENROLL_USER_TO_COURSE_API_PATH, VleServices.POST_METHOD, userContext, JSON.serialize(enrollData)
            );
        }
        
        public VleSyncServices.ParseResult parseResultOk(HttpResponse resp) {
            VleSyncServices.ParseResult res = new VleSyncServices.ParseResult();
            VleStructures.EnrollmentData enrollData = (VleStructures.EnrollmentData) JSON.deserialize(resp.getBody(), VleStructures.EnrollmentData.Class);
            res.result = true;
            return res;
        }
    }
    
    /**
     * Command for removing enrollment for user and orgUnit
     */
    public class DeleteEnrollment implements VleSyncServices.ICommand {
        
        public Contact cont { get; set; }
        public String orgUnitId { get; set; }
        
        public void init(VLE_Sync_Command__c cmd) {}
        
        public HttpResponse makeCallout(VleServices.IUserContext userContext) {
            String apiPath = String.format(DELETE_ENROLLMENTS_API_PATH_TEMPLATE, new String[]{ LP_API_VERSION, orgUnitId, cont.VLE_ID__c});
            return VleServices.performHttpCall(
                apiPath, VleServices.DELETE_METHOD, userContext, null
            );
        }
        
        public VleSyncServices.ParseResult parseResultOk(HttpResponse resp) {
            VleSyncServices.ParseResult res = new VleSyncServices.ParseResult();
            res.result = true; // 200 status code means OK
            return res;
        }
        
    }
    
    /**
     * Command for checking VLE_ID__c field
     * Do not use any callouts
     */
    public class WaitForVleId implements VleSyncServices.ICommand {
        
        @TestVisible
        private Boolean isValid = false;
        
        public Id recordId { get; set; }
        public String objName { get; set; }
        
        
        public void init(VLE_Sync_Command__c cmd) {
            isValid = VleDaoServices.hasNotEmptyVleId(objName, recordId);
            System.debug('>>>> is valid >>>> ' + isValid);
        }
        
        public HttpResponse makeCallout(VleServices.IUserContext userContext) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode((isValid) ? VleServices.OK_STATUS_CODE : VleServices.NOT_FOUND_STATUS_CODE);
            return resp;
        }
        
        public VleSyncServices.ParseResult parseResultOk(HttpResponse resp) {
            VleSyncServices.ParseResult res = new VleSyncServices.ParseResult();
            res.result = true; // valid if we here
            return res;
        }
    }
    
    /**
     * Command for changing user activation status
     */
    public class UpdateUserActivation implements VleSyncServices.ICommand {
        
        @TestVisible
        private VleStructures.UserActivationData actData;
        
        public Contact person { get; set; }
        
        public void init(VLE_Sync_Command__c cmd) {
            // get activation status from command parameters
            actData = (VleStructures.UserActivationData) JSON.deserialize(cmd.Params__c, VleStructures.UserActivationData.class);
        }
        
        public HttpResponse makeCallout(VleServices.IUserContext userContext) {
            String apiPath = String.format(UPDATE_ACTIVATION_API_PATH_TEMPLATE, new String[]{ LP_API_VERSION, person.VLE_ID__c });
            return VleServices.performHttpCall(
                apiPath, VleServices.PUT_METHOD, userContext, JSON.serialize(actData)
            );
        }
        
        public VleSyncServices.ParseResult parseResultOk(HttpResponse resp) {
            VleSyncServices.ParseResult res = new VleSyncServices.ParseResult();
            res.result = true; // 200 status code means good
            return res;
        }
    }
    
    /**
     * Command for creating vle course
     */
    public class CreateVleCourse implements VleSyncServices.ICommand {
        
        private VleStructures.CreateCourseOffering courseData;

        public Module__c module {get;set;}

        public void init(VLE_Sync_Command__c cmd) {
            String moduleReference = String.isBlank( module.Module_Reference__c ) ? VleServices.credentials.Default_Module_Reference__c : module.Module_Reference__c;
            String moduleSuffix = String.isBlank( module.Instance_Suffix__c ) ? VleServices.credentials.Default_Module_Suffix__c : module.Instance_Suffix__c;

            if ( String.isBlank( moduleReference ) ){
                moduleReference = '';
            }
            if ( String.isBlank( moduleSuffix ) ){
                moduleSuffix = '';
            }

            courseData = new VleStructures.CreateCourseOffering();
            courseData.Name = ( String.isBlank( moduleReference ) ? '' : moduleReference + ' ' ) + module.Name;
            courseData.Name += ( String.isBlank( module.Instance_Suffix__c ) ? ' ' + moduleSuffix : '' );

            courseData.Code = ( String.isBlank( moduleReference ) ? '' : moduleReference + ' ' ) + ( String.isBlank( moduleSuffix ) ? '' : moduleSuffix );
            courseData.StartDate = module.Active_Date__c == null ? null : VleServices.dateToUTCFormatString(module.Active_Date__c);
            courseData.EndDate = module.Retire_Date__c == null ? null : VleServices.dateToUTCFormatString(module.Retire_Date__c);            
            courseData.CourseTemplateId = module.Course_Template_VLE_ID__c != null 
                ? Long.valueOf( module.Course_Template_VLE_ID__c ) 
                : Long.valueOf( VleServices.credentials.Default_Course_Template_VLE_ID__c );
        }
        
        public HttpResponse makeCallout(VleServices.IUserContext userContext) {           
            return VleServices.performHttpCall(
                CREATE_COURSE_API_PATH, VleServices.POST_METHOD, userContext, JSON.serialize(courseData)
            );
        }
        
        public VleSyncServices.ParseResult parseResultOk(HttpResponse resp) {
            VleSyncServices.ParseResult res = new VleSyncServices.ParseResult();
            VleStructures.CreateCourseOffering moduleData = (VleStructures.CreateCourseOffering) JSON.deserialize(resp.getBody(), VleStructures.CreateCourseOffering.Class);
            // set vle id and set module to updated mudules
            module.VLE_ID__c = String.valueOf(moduleData.Identifier);
            module.Module_Code__c = String.valueOf(moduleData.code);
            res.result = true;
            res.updatedRecords.add(module);            
            res.result = true; // 200 status code means good
            return res;
        }
    }


    /**
     * Command for updating vle course
     */
    public class UpdateVleCourse implements VleSyncServices.ICommand {
        
        private VleStructures.CreateCourseInfo courseData;

        public Module__c module {get;set;}
    
        //vle api requires all fields to be present for update
        public void init(VLE_Sync_Command__c cmd) {
            courseData = new VleStructures.CreateCourseInfo();
            courseData.Name = module.Name;
            courseData.Code = module.Module_Code__c;
            courseData.StartDate = module.Active_Date__c == null ? null : VleServices.dateToUTCFormatString(module.Active_Date__c);
            courseData.EndDate = module.Retire_Date__c == null ? null : VleServices.dateToUTCFormatString(module.Retire_Date__c);            
            courseData.IsActive = module.Active__c;
        }
        
        public HttpResponse makeCallout(VleServices.IUserContext userContext) {  
            String apiPath = String.format(UPDATE_COURSE_API_PATH, new List<String> { LP_API_VERSION, module.VLE_ID__c } );
            return VleServices.performHttpCall(
                apiPath, VleServices.PUT_METHOD, userContext, JSON.serialize(courseData)
            );
        }
        
        public VleSyncServices.ParseResult parseResultOk(HttpResponse resp) {
            VleSyncServices.ParseResult res = new VleSyncServices.ParseResult();    
            res.result = true; // 200 status code means good
            return res;
        }
    }

}