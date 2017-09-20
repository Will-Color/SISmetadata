@IsTest(seeAllData=true)
public class CustomLandingControllerTest{
    static testMethod void TestController() {
        CustomLandingController obj = new CustomLandingController(); 
        obj.forwardToCustomAuthPage();
        
        User u = [SELECT Id, UserType, Name FROM User WHERE UserType='Guest' LIMIT 1];
        
        System.runAs(u) 
        {
            CustomLandingController obj2 = new CustomLandingController(); 
            obj2.forwardToCustomAuthPage();
        }
                
    }
}