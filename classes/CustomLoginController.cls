/*CustomLoginController Created by Simon Edwards 
/// <summary>  An apex page controller that exposes the site login functionality  </summary>
 */
 
/***** Modifications done for  on A6 Persistent Application Links ,Display the data base on parameter received on applyWizard Page o=in student community on 14-06-2015 *****/
///Author MKM
/// <summary> Edited Returning Url by adding new Url parametr for passing programme id </summary>
/// <param name="pgmId">Used store selected programme id and send via Url</param>

global with sharing class CustomLoginController {
    global String username{get;set;}
    global String password{get;set;}
    global String url{get;set;}
    global String pgmId {get;set;}
    global CustomLoginController () {
       pgmId = ApexPages.currentPage().getParameters().get('programmeid');           
    }
    global PageReference forwardToCustomAuthPage() {
     
        return new PageReference( '/CustomLogin');
    }
    global PageReference login() {  
    string filter = ApexPages.currentPage().getParameters().get('programmeid');   
    system.debug('*** -- filter= ' + filter + ' -- ***');
    //modifieng Url by adding programme id as url parameter
    url = '/'+'ChooseProgramme?programmeid=' + filter ;
    if(filter != null){
                     return Site.login(username, password,url);
    } 
    else{    
         return Site.login(username, password,null);
    }
    return Site.login(username, password,null);
        //return Site.login(username, password, '/CustomLandingPage');
    }

}