public with sharing class ProgrammeVersionServices {

    public static final String PT_MSC_PROGRAMME =           'MSc Programme';
    public static final String PT_PROFESSIONAL_DIPLOMA =    'Professional Diploma';
    public static final String PT_MASTERS_MODULE =          'Masters Module';
    public static final String PT_SHORT_COURSE =            'Short Course';
    public static final String PT_PGT =                     'PGT';
    public static final String PT_PGR =                     'PGR';

	public static final String PROGRAMME_AIMS_RLP_NAME = 'Programme_Aims';

	public static void createProgrameVersionContentAsXmlAttachment ( Set<Id> progVersionIds){

		Map<Id, SObjectXMLBuilder.SObjectXMLContext> progVersionId2Context = new Map<Id, SObjectXMLBuilder.SObjectXMLContext>();
		List<Attachment> attachsToCreate = new List<Attachment>();
		SObjectXMLBuilder xmlBuilder = new SObjectXMLBuilder(true);

		List<Programme_Version__c> programVersioms = findProgrammeVersionsWithLatestXmlContextAttachment( progVersionIds );
		
		//form SObjectXMLContext objects
		for (Programme_Version__c pv : programVersioms){
			SObjectXMLBuilder.SObjectXMLContext pvContext = 
				new SObjectXMLBuilder.SObjectXMLContext( Programme_Version__c.getSObjectType(), CommonUtils.deserializeUntyped(pv, getProgrammeVersionFieldNames()) );

			List<SObjectXMLBuilder.SObjectXMLContext> aimContexts = new List<SObjectXMLBuilder.SObjectXMLContext>();
			if (! pv.Programme_Aims__r.isEmpty() ){
				for (Programme_Aim__c aim : pv.Programme_Aims__r){
					aimContexts.add( new SObjectXMLBuilder.SObjectXMLContext( Programme_Aim__c.getSObjectType(), CommonUtils.deserializeUntyped(aim, getProgrammeAimFieldNames()) ) );
				}
				pvContext.addChildRelation(PROGRAMME_AIMS_RLP_NAME, aimContexts);
			}
			progVersionId2Context.put(pv.Id, pvContext);
		}

		//compare/generate attachments
		Map<Id, Blob> pvId2AttachBody = getPvId2AttachmentBody( programVersioms );

		for (Programme_Version__c pv : programVersioms){
			String newlyGeneratedXmlStr = xmlBuilder.getFullXml( progVersionId2Context.get(pv.Id) ).getXmlString();

			//if pv has no attachment (e.g. new record) or there were changes to pv agains data in attachment
			if ((pvId2AttachBody.containsKey(pv.Id) && pvId2AttachBody.get(pv.Id).toString() != newlyGeneratedXmlStr)
			|| ! pvId2AttachBody.containsKey(pv.Id)){				

				Attachment att = new Attachment(
					Name = AttachmentServices.XML_CONTEXT_ATTACHMENT_PREFIX + Programme_Version__c.getSObjectType() + '_' + System.now(),
					ParentId = pv.Id,
					Body = Blob.valueOf(newlyGeneratedXmlStr)
				);
				attachsToCreate.add(att);		
			}
		}

		if (! attachsToCreate.isEmpty() ){
			insert attachsToCreate;
		}
	}


    public static List<String> getProgrammeVersionFieldNames() {
     	return CommonUtils.getFieldNames( SObjectType.Programme_Version__c.FieldSets.Xml.getFields() );
    }

    //Specific Aims
    public static List<String> getProgrammeAimFieldNames() {
     	return CommonUtils.getFieldNames( SObjectType.Programme_Aim__c.FieldSets.Aims.getFields() );
    }  

/*
    public static void processDefaultModulesCreationForActivePv(List<Programme_Version__c> newList, Map<Id,Programme_Version__c> oldMap){
    	List<Programme_Version__c> pvListFiltered = findActiveProgrammeVersions(newList, oldMap);

    	if (pvListFiltered.isEmpty()){
    		return;
    	}

    	Map<Id, Set<Id>> programmeId2ModuleIds = new Map<Id, Set<Id>>();

    	for (Programme__c programme : findProgrammesWithModulesByProgVersionIdsAndModuleIds(pvListFiltered, VleSyncServices.defaultModulesIds) ){
    		programmeId2ModuleIds.put(programme.Id, new Set<Id>());
    		if (! programme.Programme_Modules__r.isEmpty()){
    			for (Programme_Module__c progModule : programme.Programme_Modules__r){
    				programmeId2ModuleIds.get(programme.Id).add(progModule.Module__c);
    			}
    		}
    	}

    	List<Programme_Module__c> progModulesToCreate = new List<Programme_Module__c>();

    	for (Id programId : programmeId2ModuleIds.keySet()){
    		Set<Id> moduleIdsToCreate = new Set<Id>(VleSyncServices.defaultModulesIds);
    		moduleIdsToCreate.removeAll( programmeId2ModuleIds.get(programId) );

    		for (Id moduleId : moduleIdsToCreate){
    			Programme_Module__c pm = new Programme_Module__c(
    				Member_Type__c = 'Required',
    				Programme__c = programId,
    				Module__c = moduleId
    			);
    			progModulesToCreate.add(pm);
    		}
    	}

    	if (! progModulesToCreate.isEmpty()){
    		insert progModulesToCreate;
    	}
    }
*/

    public static List<Programme_Version__c> findActiveProgrammeVersions(List<Programme_Version__c> newList, Map<Id,Programme_Version__c> oldMap){
    	List<Programme_Version__c> pvList = new List<Programme_Version__c>();
    	for (Programme_Version__c progVersion : newList){
    		if (progVersion.Active__c && ! oldMap.get(progVersion.Id).Active__c) {
    			pvList.add(progVersion);
    		}
    	}
    	return pvList;
    }


    private static List<Programme__c> findProgrammesWithModulesByProgVersionIdsAndModuleIds(List<Programme_Version__c> progVersions, Set<Id> moduleIds){
    	return  [SELECT Id, Programme_Version__c,
    				(SELECT Module__c
    			 	FROM Programme_Modules__r
    			 	WHERE Module__c IN : moduleIds)
    		 	FROM Programme__c
    		 	WHERE Programme_Version__c IN : progVersions];
    }


    @TestVisible
	private static List<Programme_Version__c> findProgrammeVersionsWithLatestXmlContextAttachment(Set<Id> progVersionIds){
		String queryStr = ''
			+ ' SELECT ' + String.join(getProgrammeVersionFieldNames(), ',')
			+ 		', (SELECT ' + String.join(getProgrammeAimFieldNames(), ',')
			+ 		'  FROM Programme_Aims__r)'
			+ 		', (SELECT Id, ParentId' 
			+ 		'  FROM Attachments'
			+ 		'  WHERE Name LIKE \'' + AttachmentServices.XML_CONTEXT_ATTACHMENT_PREFIX + '%\''			
			+ 		'  ORDER BY CreatedDate DESC'
			+ 		'  LIMIT 1)'			
			+ ' FROM Programme_Version__c'
			+ ' WHERE Id IN : progVersionIds';
		
		return Database.query( queryStr );
	}

	@TestVisible
	private static Map<Id, Blob> getPvId2AttachmentBody( List<Programme_Version__c> programmeVersions ){
		Set<Id> attIds = new Set<Id>();
		Map<Id, Blob> progId2AttachBody = new Map<Id, Blob>();

		for (Programme_Version__c pv : programmeVersions){
			if (! pv.Attachments.isEmpty() ){
				attIds.add( pv.Attachments.get(0).Id );
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