/**
 * @author Valentyn Bilenkyi
 * @date 01/07/2014
 * @description Service class for pre registration form
 * 2015-03-13 : SM : Removing references to FEES & FUNDING section
 */
public class PreRegistrationServices
{
    public static final String EMPTY_STRING = '';
    public static final String LABEL_NONE = '-None-';

    // Constants step names
    public static final String STEP_WELCOME =                   'welcome';
    public static final String STEP_PERSONAL_NAME =             'personal name';
    public static final String STEP_PERSONAL_ADDRESS =          'personal address';
    public static final String STEP_TERM_TIME_ADDRESS =         'term time address';
    public static final String STEP_ACADEMIC_QUALIFICATIONS =   'academic qualifications';
    //public static final String STEP_FEES_AND_FUNDING =          'fees and funding';
    public static final String STEP_UPLOAD_PHOTO =              'upload photo';
    public static final String STEP_TERMS_AND_CONDITIONS =      'terms and conditions';

    // Steps of wizard in correct order
    public static final List<String> steps = new List<String> {
        STEP_WELCOME, STEP_PERSONAL_NAME, STEP_PERSONAL_ADDRESS, STEP_TERM_TIME_ADDRESS, 
        STEP_ACADEMIC_QUALIFICATIONS, STEP_UPLOAD_PHOTO, STEP_TERMS_AND_CONDITIONS
    };

    // Titles for steps
    public static final Map<String,String> stepTitles = new Map<String,String> {
        STEP_WELCOME => 'Welcome to Online Registration',
        STEP_PERSONAL_NAME => 'Personal Details',
        STEP_PERSONAL_ADDRESS => 'Personal Details',
        STEP_TERM_TIME_ADDRESS => 'Term Time Address & Emergency Contact Details',
        STEP_ACADEMIC_QUALIFICATIONS => 'Academic and Professional Qualifications',
        //STEP_FEES_AND_FUNDING => 'Fees and Funding',
        STEP_UPLOAD_PHOTO => 'Upload Photo',
        STEP_TERMS_AND_CONDITIONS => 'Terms and Conditions'
    };

    // List of countries
    public static List<SelectOption> countriesList {
        get {
            if(countriesList == null) {
                List<SelectOption> options = new List<SelectOption>();
                Schema.DescribeFieldResult fieldResult = Contact.Country_of_Birth__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                options.add(new SelectOption(EMPTY_STRING, LABEL_NONE));
                for(Schema.PicklistEntry f : ple) {
                    options.add(new SelectOption(f.getValue(), f.getLabel()));
                }
                countriesList = options;
            }
            return countriesList;
        }
    }
}