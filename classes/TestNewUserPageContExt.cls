/**
 * 2014-05-22 : Test class for NewUserPageContExt
 */
 @IsTest
public class TestNewUserPageContExt {
    
    @testSetup
    public static void setup() {
        VLE__c vle = new VLE__c();
        vle.Name = 'main';
        vle.Default_Staff_Role_VLE_ID__c = '102';
        vle.API_Host__c = '2lstmedtest.desire2learn.com';
        vle.App_ID__c = '2BqFg3qrSd26I';
        vle.App_Key__c = '2MWXZLyA2xo4I';
        insert vle;
    }
        
    static testMethod void testController() {
        ApplyTestingUtils.setupTestData();
        Student_Programme__c sp = ApplyTestingUtils.sp;
        Page_Copy__c pc = new Page_Copy__c();
        pc.Copy_Location__c = 'New User Information';
        pc.Page_Status__c = 'Active';
        pc.Body_Copy__c = 'Test Copy';
        insert pc;

        sp.Stage__c = ApplyServices.COURSE_SUBMITTED_STAGE_NAME;
        sp.Test_Class_Record__c = true;
        update sp;

        PageReference testPage = Page.LSTMUserPage;
        
         Test.setCurrentPageReference(new PageReference('Page.LSTMUserPage'));
        System.currentPageReference().getParameters().put('id', sp.Id);  
        //ApexPages.StandardController std = new ApexPages.StandardController(sp);

        test.startTest();
            NewUserPageContExt ctrl = new NewUserPageContExt();

            PageReference homePage = ctrl.gotoHomePage();
            PageReference checkHomePage = Page.StudentLandingPage;


            system.assertEquals(checkHomePage.getUrl(), homePage.getUrl());

            ctrl.confirmDetails();
            
        test.stopTest();




    }
}