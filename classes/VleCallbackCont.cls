/**
 * Controller for VleCallback page
 */
public with sharing class VleCallbackCont {
	
	private static final String MSG_OK = 'Session for User context has been successfully updated!';
	private static final String MSG_ERROR = 'Signature doesn\'t match';
	
	public String tokenId { get; set; }
	public String tokenKey { get; set; }
	public String tokenSig { get; set; }
	
	public VleCallbackCont() {
		tokenId = ApexPages.currentPage().getParameters().get('x_a');
		tokenKey = ApexPages.currentPage().getParameters().get('x_b');
		tokenSig = ApexPages.currentPage().getParameters().get('x_c');
	}
	
	public void checkToken() {
		// check token's signature
		String value = tokenId + '&' + tokenKey;
		String verifiedSig = VleServices.buildBase64HashString(VleServices.credentials.App_Key__c, value);
		
		if ( verifiedSig.equals(tokenSig) ) {
			// update custom setting
			VLE__c cs = new VLE__c(Id = VleServices.credentials.Id, User_ID__c = tokenId, User_Key__c = tokenKey);
			update cs;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, MSG_OK));
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_ERROR));
		}
	}

}