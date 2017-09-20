public with sharing class PicklistBannerSPController{

    @AuraEnabled
    public static List<String> getCompletedStages(Id studenProgrammeId) {
        List<String> stageList = new List<String>();
        
        String currentStage = [SELECT Stage__c FROM Student_Programme__c WHERE Id =: studenProgrammeId].Stage__c;
    
        List<String> stages = PicklistDescriber.describe(studenProgrammeId, 'Stage__c');
    
        for(String stage : stages)
        {
            if(stage == currentStage)
                break;
            stageList.add(stage);               
        }
        system.debug('completed stages : ' + stageList);
        return stageList;
    }

    @AuraEnabled
    public static String getCurrentStage(Id studenProgrammeId) {
        
        String currentStage = [SELECT Stage__c FROM Student_Programme__c WHERE Id =: studenProgrammeId].Stage__c;
        system.debug('current Stage : ' + currentStage);                
        return currentStage;
    }
    
    @AuraEnabled
    public static List<String> getFutureStages(Id studenProgrammeId) {
        List<String> stageList = new List<String>();
        
        String currentStage = [SELECT Stage__c FROM Student_Programme__c WHERE Id =: studenProgrammeId].Stage__c;
        boolean flag = false;    
        List<String> stages = PicklistDescriber.describe(studenProgrammeId, 'Stage__c');
        
        for(String stage : stages)
        {
            if(stage == currentStage)
            {
                flag = true;
                continue;
            }    
            if(flag == true)
                stageList.add(stage);               
        }
        system.debug('Future stages : ' + stageList);        
        return stageList;
    }


    @AuraEnabled
    public static Student_Programme__c updateStage(Id studenProgrammeId,String stageName) {        
        Student_Programme__c sp = [SELECT Id,Stage__c FROM Student_Programme__c WHERE Id =: studenProgrammeId];
        sp.Stage__c = stageName;
        update sp;
        return sp;
    }    
    
}