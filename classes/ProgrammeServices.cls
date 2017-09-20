public with sharing class ProgrammeServices {

	public static final String APPLICATION_LINK_XML_NAME = 'APPLICATION_LINK__C';

	public static void createProgramContentAsXmlAttachment( Set<Id> progIds){
	
		Map<Id, SObjectXMLBuilder.SObjectXMLContext> progId2Context = new Map<Id, SObjectXMLBuilder.SObjectXMLContext>();
		List<Attachment> attachsToCreate = new List<Attachment>();
		SObjectXMLBuilder xmlBuilder = new SObjectXMLBuilder(true);

		List<Programme__c> programmes = findProgrammeWithLatestXmlContextAttachment( progIds );
		
		//form SObjectXMLContext objects
		for (Programme__c programme : programmes){

			Map<String, Object> fieldName2Value = CommonUtils.deserializeUntyped(programme, getProgrammeFieldNames());
			fieldName2Value.put(APPLICATION_LINK_XML_NAME, URL.getSalesforceBaseUrl().toExternalForm() + '/' + programme.Id);

			SObjectXMLBuilder.SObjectXMLContext pvContext = 
				new SObjectXMLBuilder.SObjectXMLContext( Programme__c.getSObjectType(), fieldName2Value );
			progId2Context.put(programme.Id, pvContext);
		}

		//compare/generate attachments
		Map<Id, Blob> progId2AttachBody = getProgrammeId2AttachmentBody(programmes);
	
		for (Programme__c programme : programmes){
			String newlyGeneratedXmlStr = xmlBuilder.getFullXml( progId2Context.get(programme.Id) ).getXmlString();

			//if programme has no attachment (e.g. new record) or there were changes to programme agains data in attachment
			if ((progId2AttachBody.containsKey(programme.Id) && progId2AttachBody.get(programme.Id).toString() != newlyGeneratedXmlStr)
			|| ! progId2AttachBody.containsKey(programme.Id)){				

				Attachment att = new Attachment(
					Name = AttachmentServices.XML_CONTEXT_ATTACHMENT_PREFIX + Programme__c.getSObjectType() + '_' + System.now(),
					ParentId = programme.Id,
					Body = Blob.valueOf(newlyGeneratedXmlStr)
				);
				attachsToCreate.add(att);		
			}
		}

		if (! attachsToCreate.isEmpty() ){
			insert attachsToCreate;
		}

	}

    public static List<String> getProgrammeFieldNames() {
     	return CommonUtils.getFieldNames( SObjectType.Programme__c.FieldSets.Xml.getFields() );
    }


	private static List<Programme__c> findProgrammeWithLatestXmlContextAttachment(Set<Id> progIds){
		String queryStr = ''
			+ ' SELECT ' + String.join(getProgrammeFieldNames(), ',')
			+ 		', (SELECT Id, ParentId' 
			+ 		'  FROM Attachments'
			+ 		'  WHERE Name LIKE \'' + AttachmentServices.XML_CONTEXT_ATTACHMENT_PREFIX + '%\''			
			+ 		'  ORDER BY CreatedDate DESC'
			+ 		'  LIMIT 1)'			
			+ ' FROM Programme__c'
			+ ' WHERE Id IN : progIds';
		
		return Database.query( queryStr );
	}

	private static Map<Id, Blob> getProgrammeId2AttachmentBody( List<Programme__c> programmes ){
		Set<Id> attIds = new Set<Id>();
		Map<Id, Blob> progId2AttachBody = new Map<Id, Blob>();

		for (Programme__c programme : programmes){
			if (! programme.Attachments.isEmpty() ){
				attIds.add( programme.Attachments.get(0).Id );
			}
		}

		if (! attIds.isEmpty()) {
			for (Attachment att : AttachmentServices.getAttachmentsWithBodyByIds(attIds)){
				progId2AttachBody.put(att.parentId, att.Body);
			}
		}
		return 	progId2AttachBody;
	}    

}