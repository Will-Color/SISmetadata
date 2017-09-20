/**
 * @author Mykola Senyk
 * @date 17/06/2014
 * @description Wrapper class for References__c
 */
public class ReferenceWrapper {
	
	// comma separeated field names of Contact & References__c
	public static final STRING CONTACT_FIELDS = 'Salutation,LastName,FirstName,Title,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,Phone';
	public static final String REFERENCE_FIELDS = 'College_University_or_Employer__c';
	
	public ReferenceWrapper(References__c record) {
		item = record;
		referee = ( item.Referee__r != null ) ? item.Referee__r : new Contact(); 
	}
	
	public References__c item { get; set; }
	
	public Contact referee { get; set; }
	
	/**
     * Index in parent list
     */
    public Integer index { get; set; }
    
    /**
     * Return true if all fields of wrapper are empty
     */
    public Boolean empty { get {
    	Boolean res = CommonUtils.allFieldsAreEmpty(referee, CONTACT_FIELDS) && CommonUtils.allFieldsAreEmpty(item, REFERENCE_FIELDS) && !item.Can_Request_Reference_from_Referee__c;
    	if ( res ) {
    		res = !CommonUtils.hasAttachment(item.Id);
    	}
    	return res;
    } }

}