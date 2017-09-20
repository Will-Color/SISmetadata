public class ExternalFormController{

    public HTTPResponse res {get; set;}
    public String resBody {get; set;}
    public String endpoint {get; set;}
    public Boolean hasAccess {get; set;}
    public String instanceName {get; set;}    

    public ExternalFormController() {
        PageReference pageRef = ApexPages.currentPage();

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');

        if(pageRef.getParameters().get('tfa_next') == null){
            String spId = pageRef.getParameters().get('SPID');
            String studentId = pageRef.getParameters().get('StudentID');
            String formURL = [SELECT Programme__r.External_Form__c FROM Student_Programme__c WHERE Id=:spId].Programme__r.External_Form__c;
            instanceName = [SELECT Programme__r.Name FROM Student_Programme__c WHERE Id=:spId].Programme__r.Name;

            String studentId_sf;

            try{
                studentId_sf = [SELECT Student__c FROM Student_Programme__c WHERE Id =: spId].Student__c;
            }
            catch(Exception e){
                studentId_sf = null;
                hasAccess = false;
            }
            
            //formURL = formURL.replace('www.tfaforms', System.Label.FormAssemblyURL);
            endpoint = formURL + '?SPID=' + spId + '&StudentID=' + studentId;
            
            User usr = new User();
            usr = [SELECT Name, ContactId FROM User WHERE Id = : UserInfo.getUserId()];

            if(usr.ContactId == studentId  && studentId != null && studentId_sf == studentId) //&& lstm_no != null && lstm_no_sf == lstm_no)
                hasAccess = true;
            else
                hasAccess = false;                
        }
        else{
            endpoint = 'https://' + System.Label.FormAssemblyURL + '.com/rest' + pageRef.getParameters().get('tfa_next');
        }
        req.setEndpoint(endpoint);

        Http http = new Http();
        try {
            res = http.send(req);
            resBody = res.getBody();
        } 
        catch(System.CalloutException e) {
            System.debug(e);
        }
    }
}