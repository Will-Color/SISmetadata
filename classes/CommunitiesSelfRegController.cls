/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
/***** Modifications 
///done for  on A6 Persistent Application Links ,Display the data base on parameter received on applyWizard Page o=in student community on 14-06-2015 *****/
///Author MKM
/// <summary> Edited Returning Url by adding new Url parametr for passing programme id </summary>
/// <param name="pgmId">Used store selected programme id and send via Url</param>
public with sharing class CommunitiesSelfRegController {

    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String pgmId {get;set;}
    public String url{get;set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }
    //2014-08-13 : CSL : New code to retrieve Page Copy text, for the header text on the Self Registration page
    public Page_Copy__c selfRegPageCopy {get; set;}
    
    public CommunitiesSelfRegController() {
        pgmId = ApexPages.currentPage().getParameters().get('programmeid');   
        selfRegPageCopy = [select p.Body_Copy__c from Page_Copy__c p where p.Copy_Location__c = 'Self Registration' and Page_Status__c = 'Active' LIMIT 1];
    }
    
    private boolean isValidPassword() {
        return password == confirmPassword;
    }
    
    public PageReference cancel(){
        return new PageReference('/LSTMLogin?programmeid='+pgmId);
    }

    public PageReference registerUser() {    
           // it's okay if password is null - we'll send the user a random password in that case
        if (!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        } 
       

        String profileId = '00e20000001V3BS'; // To be filled in by customer.
        String roleEnum = null; // To be filled in by customer.        
        String accountId = '00120000017HW56'; // To be filled in by customer.
                                     
        String userName = email;
        User u = new User();
        u.Username = userName;
        u.Email = email;
        u.FirstName = firstName;
        u.LastName = lastName;
        //2014-08-07 : CSL : New code to create CommunityNickname automatically
        //2014-12-16 : CSL : We are now setting the CommunityNickName to the Email address
        //communityNickname = lastName.substring(0,4) + (firstName == null ? '' : firstName.substring(0,1));
        //u.CommunityNickname = communityNickname;
        u.CommunityNickname = email;
        u.ProfileId = profileId;
        System.Debug('accountId'+ accountId);
         System.Debug('u'+ u);

        String userId = Site.createPortalUser(u, accountId, password);
        System.Debug('userId: '+userId);
      
        if (userId != null) { 
            if (password != null && password.length() > 1) {
               url = '/'+'ChooseProgramme?programmeid=' + pgmId ;
               return Site.login(userName, password, url);               
            }
            else {
                PageReference page = System.Page.CommunitiesSelfRegConfirm;
                page.getParameters().put('programmeid', pgmId);               
                page.setRedirect(true);
                return page;                
            }
        }
        return null;
    }
}