@IsTest(seeAllData=true)
public class CustomLoginControllerTest{
    static testMethod void TestController() {
        Programme__c newProg = new Programme__c();

        newProg.Name = 'Test Programme';
        newProg.Test_Class_Record__c = true;
        
        insert newProg;
    
        Test.setCurrentPageReference(new PageReference('Page.LSTMLogin')); 
        System.currentPageReference().getParameters().put('programmeid', newProg.Id);
    
        CustomLoginController obj = new CustomLoginController(); 
        obj.login();
        obj.forwardToCustomAuthPage();
        
                
    }
}