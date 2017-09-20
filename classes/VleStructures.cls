/**
 * Class for hold couple of desire2learn structures useful in JSON transformations
 */
public with sharing class VleStructures {
	
	/**
	 * Structure for create new user.
	 * All fields are mandatory
	 * See more: http://docs.valence.desire2learn.com/res/user.html#User.CreateUserData
	 */
	public class CreateUserData {
		public String OrgDefinedId;
    	public String  FirstName;
    	public String MiddleName;
    	public String  LastName;
    	public String ExternalEmail;
    	public String UserName;
    	public Long RoleId;
    	public Boolean IsActive;
    	public Boolean SendCreationEmail;
	}
	
	/**
	 * Activation user's data
	 * See more: http://docs.valence.desire2learn.com/res/user.html#User.UserActivationData
	 */
	public class UserActivationData {
		public Boolean IsActive;
	}
	
	/**
	 * Structure of retrieve user's data
	 * See more: http://docs.valence.desire2learn.com/res/user.html#User.UserData
	 */
	public class UserData {
		public Long OrgId;
		public Long UserId;
    	public String  FirstName;
    	public String MiddleName;
    	public String  LastName;
    	public String UserName;
    	public String ExternalEmail;
    	public String OrgDefinedId;
    	public String UniqueIdentifier;
    	public UserActivationData Activation;
	}
	
	/**
	 * Structure to create new enrollment
	 * See more: http://docs.valence.desire2learn.com/res/enroll.html#Enrollment.CreateEnrollmentData
	 */
	public class CreateEnrollmentData {
		public Long OrgUnitId;
		public Long UserId;
		public Long RoleId;
	}
	
	/**
	 * Structure to retrieve single enrollment
	 * See more: http://docs.valence.desire2learn.com/res/enroll.html#Enrollment.EnrollmentData
	 */
	public class EnrollmentData {
		public Long OrgUnitId;
		public Long UserId;
		public Long RoleId;
		public Boolean IsCascading;
	}

	/**
	 * Structure to create course offering
	 * See more: http://docs.valence.desire2learn.com/res/course.html#Course.CreateCourseOffering
	 */
	public class CreateCourseOffering {
		public Long Identifier;
	    public String Name;
	    public String Code;
	    public String Path;
	    public Long CourseTemplateId;
	    public Long SemesterId;
	    public String StartDate;
	    public String EndDate;
	    public Long LocaleId;
	    public Boolean ForceLocale;
	    public Boolean ShowAddressBook;		
	}

	public class CreateCourseInfo {
		public String Name;
		public String Code;
	    public String StartDate;
	    public String EndDate;
	    public Boolean IsActive;		
	}



}