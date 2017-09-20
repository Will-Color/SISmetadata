/**
 * @author Valentyn Bilenkyy
 * @date 17/06/2014
 * @description Test class for ChooseProgrammeCont.cls
 */
 /* Support task :commented the lines for removing additioanl x fields 95 and 102*/
@isTest
private class TestChooseProgrammeCont {

    private static final Integer NUMBER_OF_PROGRAMS_TO_CREATE = 3 * ChooseProgrammeCont.SEARCH_RESULTS_PER_PAGE;
    private static final String PROGRAMME_TYPE = 'Test';
    private static final String PROGRAMME_NAME = 'Test Programme';

    @isTest static void testConstructorIsNotNull() {
        Test.startTest();
            ChooseProgrammeCont ctrl = new ChooseProgrammeCont();
        Test.stopTest();
        System.assertNotEquals(null, ctrl);
    }

    @isTest static void testSearch() {
        createTestData();
        Test.startTest();
            ChooseProgrammeCont ctrl = new ChooseProgrammeCont();
            ctrl.searchTerm = PROGRAMME_NAME;
            ctrl.searchProgrammeType = PROGRAMME_TYPE;
            ctrl.search();
            System.assert(ctrl.getFoundProgrammes().size()>0);            
        Test.stopTest();
    }

    @isTest static void testPaginationMethodsAndProperties() {
        createTestData();
        Test.startTest();
            ChooseProgrammeCont ctrl = new ChooseProgrammeCont();
            System.assertEquals(1, ctrl.pageNumber);
            System.assertEquals(false, ctrl.hasPrevious);
            System.assertEquals(true, ctrl.hasNext);
            ctrl.next();
            System.assertEquals(2, ctrl.pageNumber);
            ctrl.first();
            System.assertEquals(1, ctrl.pageNumber);
            ctrl.last();
            System.assertEquals(3, ctrl.pageNumber);
            ctrl.previous();
            System.assertEquals(2, ctrl.pageNumber);                       
        Test.stopTest();
    }

    @isTest static void testGetProgrammeTypes() {
        Test.startTest();
            ChooseProgrammeCont ctrl = new ChooseProgrammeCont();
            List<SelectOption> programmeTypes = ctrl.getProgrammeTypes();                       
            ctrl.resetSearch();
            ctrl.getProgrammeTypesExternal();
            ApexPages.currentPage().getParameters().put('programmeid', 'a0311000003b1hF');
            ChooseProgrammeCont ctrl2 = new ChooseProgrammeCont();
        Test.stopTest();
        System.assert(programmeTypes.size()>0);
    }
    
    @isTest static void testProcessApply(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User commUser;
        System.runAs(thisUser) {
           
            commUser = ApplyTestingUtils.createCommunityUser('Patterson', 'd1@test.com', ApplyTestingUtils.CUSTOMER_COMMUNITY_PROFILE_NAME);
        }
        Test.startTest();
        System.runAs(commUser) {
             createTestData();
            ChooseProgrammeCont ctrl = new ChooseProgrammeCont();
            PageReference result1 = ctrl.processApply();
            System.assertEquals(null, result1);
            Id progId = ctrl.getFoundProgrammes()[0].programme.Id;
            ctrl.programmeId = progId;
            PageReference result2 = ctrl.processApply();
            System.assert(result2.getUrl().toLowerCase().startsWith('/apex/applywizard'));
        }
        Test.stopTest();
    }

    @isTest static void testProgrammeWrapper() {
        Test.startTest();
            Programme__c p = new Programme__c();
            p.Home_EU_Fee__c = 1000;
            p.Overseas_Fee__c = 1500;
            ProgrammeWrapper pw;
            pw = new ProgrammeWrapper(p);
            System.assertEquals('', pw.combinedDates);

            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            User commUser;
            System.runAs(thisUser) {
                commUser = ApplyTestingUtils.createCommunityUser('Fox Maulder', 'maulder@fbi.com', ApplyTestingUtils.CUSTOMER_COMMUNITY_PROFILE_NAME);
            }
             Contact c = [SELECT Id FROM Contact WHERE Id = : commUser.ContactId];
            c.EU_Citizen__c = false;
            update c;
            System.runAs(commUser) {
                System.assertEquals(1500, pw.fee);
            }
            c.EU_Citizen__c = true;
            update c; 
            ProgrammeWrapper.usr = null;
            System.runAs(commUser) {
                System.assertEquals(1000, pw.fee);
            }

            p.Start_Date__c = Date.newInstance(2014, 5, 15);
            pw = new ProgrammeWrapper(p);
            System.assertEquals('From 15 May 2014', pw.combinedDates);
            p.Start_Date__c = null;
            p.End_Date__c = Date.newInstance(2014, 5, 15);
            pw = new ProgrammeWrapper(p);
            System.assertEquals('Till 15 May 2014', pw.combinedDates);
            p.Start_Date__c = Date.newInstance(2014, 5, 15);
            pw = new ProgrammeWrapper(p);
            System.assertEquals('15 May 2014', pw.combinedDates);
            p.Start_Date__c = Date.newInstance(2014, 5, 14);
            pw = new ProgrammeWrapper(p);
            System.assertEquals('14 - 15 May 2014', pw.combinedDates);
            p.Start_Date__c = Date.newInstance(2014, 4, 15);
            pw = new ProgrammeWrapper(p);
            System.assertEquals('15 April - 15 May 2014', pw.combinedDates);
            p.Start_Date__c = Date.newInstance(2013, 5, 15);
            pw = new ProgrammeWrapper(p);
            System.assertEquals('15 May 2013 - 15 May 2014', pw.combinedDates);
        Test.stopTest();
    }
    
    private static void createTestData() {
        //Programme Version
        Id mvrtId = CommonUtils.findRecordTypeIdByDev(ApplyTestingUtils.PROGRAMME_VERSION, ApplyServices.RT_MASTER_PV_DEVNAME);
        Programme_Version__c mv = ApplyTestingUtils.createProgrammeVersion(PROGRAMME_NAME, mvrtId, PROGRAMME_TYPE, true);
        Id rtId = CommonUtils.findRecordTypeIdByDev(ApplyTestingUtils.PROGRAMME_VERSION, ApplyServices.RT_VERSION_PV_DEVNAME);
        Programme_Version__c pv = ApplyTestingUtils.createProgrammeVersion(PROGRAMME_NAME, rtId, PROGRAMME_TYPE, mv.Id, true);
        //Programme
        List<Programme__c> programmesList = ApplyTestingUtils.createProgramme(PROGRAMME_NAME, pv.Id, NUMBER_OF_PROGRAMS_TO_CREATE, true);
        System.debug('### Initial programmesList: ' + programmesList);
    }
}