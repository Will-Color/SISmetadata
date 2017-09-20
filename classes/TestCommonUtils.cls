@isTest
private class TestCommonUtils {
	private static final String EMPTY_STRING = '';
	private static final String SOBJECT_ACCOUNT = 'Account';
	private static final String SOBJECT_CONTACT = 'Contact';
	private static final String SOBJECT_FAKE = 'Fake';
	private static final String SOBJECT_CONTACT_DEV_NAME_STAFF = 'Staff';
	private static final String SOBJECT_CONTACT_DEV_NAME_FAKE = '_Fake01234_0123456789_56789Fake_';
	private static final String FIELD_NAME = 'Name';
	private static final String FIELD_PHONE = 'Phone';
	private static final String FIELD_NUMBER_OF_EMPLOYEES = 'NumberOfEmployees';

	@isTest static void testFindRecordTypeIdByDev() {
		Test.startTest();
			Id recordTypeIdExists = CommonUtils.findRecordTypeIdByDev(SOBJECT_CONTACT, SOBJECT_CONTACT_DEV_NAME_STAFF);
			Id recordTypeIdNotExists = CommonUtils.findRecordTypeIdByDev(SOBJECT_CONTACT, SOBJECT_CONTACT_DEV_NAME_FAKE);
			try{
				Id recordTypeIdException = CommonUtils.findRecordTypeIdByDev(SOBJECT_FAKE, SOBJECT_CONTACT_DEV_NAME_FAKE);
				System.assert(false);
			}
			catch (CommonUtils.ApplicationException e) {
				System.assert(true);
			}
		Test.stopTest();
		System.assertNotEquals(null, recordTypeIdExists);
		System.assertEquals(null, recordTypeIdNotExists);
	}

	@isTest static void testHasEmptyFields() {
		Account a = new Account();
		a.put(FIELD_NAME, '');
		a.put(FIELD_PHONE, '');
		Account b = new Account();
		b.put(FIELD_NAME, 'Ambulance');
		b.put(FIELD_PHONE, '911');
		Account c = new Account();
		c.put(FIELD_NAME, 'Ambulance');
		c.put(FIELD_PHONE, '');
		Account d = new Account();
		d.put(FIELD_NAME, '');
		d.put(FIELD_PHONE, '911');
		Account e = new Account();
		e.put(FIELD_NAME, 'Ambulance');
		e.put(FIELD_PHONE, '911');
		e.put(FIELD_NUMBER_OF_EMPLOYEES, 1);
		String fieldNames = FIELD_NAME + ',' + FIELD_PHONE;
		String extendedeFieldNames = fieldNames + ',' + FIELD_NUMBER_OF_EMPLOYEES;
		Test.startTest();
			Boolean trueFlag1 = CommonUtils.hasEmptyFields(a, fieldNames);
			Boolean falseFlag1 = CommonUtils.hasEmptyFields(b, fieldNames);
			Boolean trueFlag2 = CommonUtils.hasEmptyFields(c, fieldNames);
			Boolean trueFlag3 = CommonUtils.hasEmptyFields(d, fieldNames);
			Boolean falseFlag2 = CommonUtils.hasEmptyFields(e, extendedeFieldNames);
		Test.stopTest();
		System.assertEquals(true, trueFlag1);
		System.assertEquals(false, falseFlag1);
		System.assertEquals(true, trueFlag2);
		System.assertEquals(true, trueFlag3);
		System.assertEquals(false, falseFlag2);
	}

	@isTest static void testAllFieldsAreEmpty() {
		Account a = new Account();
		a.put(FIELD_NAME, '');
		a.put(FIELD_PHONE, '');
		Account b = new Account();
		b.put(FIELD_NAME, '');
		b.put(FIELD_PHONE, '911');
		Account c = new Account();
		c.put(FIELD_NAME, 'Ambulance');
		c.put(FIELD_PHONE, '');
		Account d = new Account();
		d.put(FIELD_NAME, 'Ambulance');
		d.put(FIELD_PHONE, '911');
		Account e = new Account();
		e.put(FIELD_NAME, '');
		e.put(FIELD_PHONE, '');
		e.put(FIELD_NUMBER_OF_EMPLOYEES, 1);
		String fieldNames = FIELD_NAME + ',' + FIELD_PHONE;
		String extendedeFieldNames = fieldNames + ',' + FIELD_NUMBER_OF_EMPLOYEES;
		Test.startTest();
			Boolean trueFlag = CommonUtils.allFieldsAreEmpty(a, fieldNames);
			Boolean falseFlag1 = CommonUtils.allFieldsAreEmpty(b, fieldNames);
			Boolean falseFlag2 = CommonUtils.allFieldsAreEmpty(c, fieldNames);
			Boolean falseFlag3 = CommonUtils.allFieldsAreEmpty(d, fieldNames);
			Boolean falseFlag4 = CommonUtils.allFieldsAreEmpty(e, extendedeFieldNames);
		Test.stopTest();
		System.assertEquals(true, trueFlag);
		System.assertEquals(false, falseFlag1);
		System.assertEquals(false, falseFlag2);
		System.assertEquals(false, falseFlag3);
		System.assertEquals(false, falseFlag4);
	}
	
	static testMethod void testProfileMap() {
		System.assert(CommonUtils.profileMap != null);
		System.assert(!CommonUtils.profileMap.isEmpty());
		System.assert(CommonUtils.profileMap.get(ApplyTestingUtils.SYSADMIN_PROFILE_NAME) != null);
		System.assert(CommonUtils.profileMap.get('_unknown_profile_') == null);
	}
	
}