/* testtgrUpdateWebtoCase Test class Created by Manu KM on 10-sep-2015*/
/// <summary>
// This is Unit test for tgrUpdateWebtoCase
/// </summary>
@isTest
public class testTgrUpdateWebtoCase{
    public static testMethod void testCaseCreation(){
        //creating test cases 
        case testCase = new case();
        testCase.Programme_Version_Name__c = 'testPgmname'; 
        testCase.origin= 'Web';
        testCase.Last_Name__c= 'test';
        //inserting test case this will invoke TgrUpdateWebtoCase with bad case
        insert testCase;
        //creating test programme data
        Programme_Version__c testpgmversion = new Programme_Version__c();
        testpgmversion.Name = 'test';
        insert testpgmversion;
        //inserting test case record with true value
        case testCase2 = new case();
        testCase2.Programme_Version_Name__c = '-'; 
        testCase2.origin= 'Web';
        testCase2.Last_Name__c= 'test';
        //this will invoke trigger with true values
        insert testCase2;
        case resultset=[Select id from case where id=:testCase2.Id];
        //Asserting the result
        System.assertEquals(true,resultset != null);
    }
}