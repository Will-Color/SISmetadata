/**
 * @author Valentyn Bilenkyy
 * @date 20/06/2014
 * @description Test class for MultiAttachmentCont.cls
 */
@isTest
private class TestMultiAttachmentCont {
	private static Account TEST_ACCOUNT;
	private static Id ATTACHMENT_ID;
	private static final String ATTACHMENT_DESCRIPTION = 'Test description';
	
	@isTest static void testUpload() {
		createTestData();
		Test.startTest();
			System.assertNotEquals(true, CommonUtils.hasAttachment(TEST_ACCOUNT.Id));
			MultiAttachmentCont cls = new MultiAttachmentCont();
			cls.attachmentParentId = TEST_ACCOUNT.Id;
			cls.attachmentDescription = ATTACHMENT_DESCRIPTION;
			cls.attachment.name = 'test.jpg';
			cls.attachment.body = Blob.valueOf('Test Data');
			cls.upload();
			System.assert(CommonUtils.hasAttachment(TEST_ACCOUNT.Id));
     		System.assertEquals(true, cls.hasAttachments);
     		System.assertEquals(1, cls.recordAttachments.size());
     		cls.attachmentParentId = null;
			cls.attachment.name = 'test.jpg';
			cls.attachment.body = Blob.valueOf('Test Data');
			try {
				cls.upload();
				System.assert(true);
			}
			catch (DmlException e) {
				System.assert(false);
			}
		Test.stopTest();
	}

	@isTest static void testRemove() {
		createTestData();
		System.assertNotEquals(true, CommonUtils.hasAttachment(TEST_ACCOUNT.Id));
		Blob b = Blob.valueOf('Test Data');
		Attachment attachment = new Attachment();
		attachment.ParentId = TEST_ACCOUNT.Id;
		attachment.Name = 'Test Name';
		attachment.Body = b;
		insert(attachment);
		System.assert(CommonUtils.hasAttachment(TEST_ACCOUNT.Id));
		ATTACHMENT_ID = attachment.Id;
		Test.startTest();
			MultiAttachmentCont cls = new MultiAttachmentCont();
			cls.attachmentParentId = TEST_ACCOUNT.Id;
     		System.assertEquals(1, cls.recordAttachments.size());
			cls.attachmentIdToRemove = ATTACHMENT_ID;
     		cls.removeAttachment();
     		System.assertNotEquals(true, CommonUtils.hasAttachment(TEST_ACCOUNT.Id));
     		System.assertEquals(0, cls.recordAttachments.size());
     		cls.attachmentIdToRemove = ATTACHMENT_ID;
     		try {
     			cls.removeAttachment();
     			System.assert(true);
     		}
     		catch (Exception e) {
     			System.assert(false);
     		}
		Test.stopTest();
	}

	static void createTestData() {
		Account acc=new Account(Name = 'Test Account');
        insert acc;
        TEST_ACCOUNT = acc;
	}
}