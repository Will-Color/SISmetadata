/**
 * @author Mykola Senyk
 * @date 20/06/2014
 * @description Unit test for ReferenceWrapper class
 */
@isTest
private class TestReferenceWrapper {
	
	static testMethod void testWrapper() {
		// empty reference
		References__c ref = new References__c();
		ReferenceWrapper wr = new ReferenceWrapper(ref);
		System.assert(wr.item.Id == null);
		System.assert(wr.referee.Id == null);
		System.assert(wr.empty);
		wr.referee.FirstName = 'John';
		System.assert(!wr.empty);
		
		// inserted reference
		ApplyTestingUtils.setupTestData();
		List<References__c> refList = ApplyServices.findRelatedReferences(ApplyTestingUtils.student.Id);
		System.assertEquals(1, refList.size());
		ref = refList[0];
		wr = new ReferenceWrapper(ref);
		System.assertEquals(ref.Id, wr.item.Id);
		System.assert(wr.referee.Id != null);
		System.assertEquals(ref.Referee__c, wr.referee.Id);
		System.assert(!wr.empty);
	}

}