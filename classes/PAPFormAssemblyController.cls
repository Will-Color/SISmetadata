public class PAPFormAssemblyController {
	
    @AuraEnabled
    public static List<Progress_Assessment__c> getUserData(Id recId){
        List<Progress_Assessment__c> userList = new List<Progress_Assessment__c>();
        userList = [Select Id, Name, User_is_PAP_Member__c, User_is_Supervisor__c from Progress_Assessment__c where Id =: recId];
        return userList;        
    }
}