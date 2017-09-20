/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
@IsTest public with sharing class CommunitiesLandingControllerTest {
    @IsTest(SeeAllData=true) public static void testCommunitiesLandingController() {
        // Instantiate a new controller with all parameters in the page

        PageReference pageRef = Page.CommunitiesLanding;
        Test.setCurrentPage(pageRef);    
        
        CommunitiesLandingController controller = new CommunitiesLandingController();
        controller.forwardToStartPage();
      }
}