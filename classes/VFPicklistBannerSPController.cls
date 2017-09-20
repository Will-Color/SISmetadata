global with sharing class VFPicklistBannerSPController{

    public List<String> options{get; set;}
    public string opts {get; set;}

    public VFPicklistBannerSPController(ApexPages.StandardController controller) {
        Id spID = (Id)controller.getRecord().id;
        options = new List<String>();       
        List<String> options = PicklistDescriber.describe(spID, 'Stage__c');
        opts = JSON.serialize(options);       
    }
    
    @RemoteAction
    global static String doSubmitForm(String spId, String stage) {
        if(spId != null) {
            Student_Programme__c sp = [Select Id,Name,Stage__c FROM Student_Programme__c WHERE Id=:spId];
            if(sp != null) {
                sp.Stage__c = stage;
                update sp;
                return 'Success';
            } 
            else {
                return 'Student Programme could not be found';
            }
        } 
        else {
            return 'Student Programme Id was null';
        }
    }
}