public class PGRApplicationFAController {
    
    @AuraEnabled
    public static List<Student_Programme__c> getUserDataStd(Id recId){
        List<Student_Programme__c> stdList = [SELECT Id, Student__c FROM Student_Programme__c where Id=:recId LIMIT 1];
        return stdList;
    }

}