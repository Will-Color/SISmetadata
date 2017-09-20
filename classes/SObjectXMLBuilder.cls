public class SObjectXMLBuilder {
	
	public static final String DOM_ELEM_SOBJECT = 'SOBJECT';
	public static final String DOM_ELEM_TYPE = 'TYPE';
	public static final String DOM_ELEM_FIELDS = 'FIELDS';
	public static final String DOM_ELEM_CHILD_RELATIONS = 'CHILD_RELATIONS';	

	private Boolean includeEmptyContent;

	public SObjectXMLBuilder(Boolean includeEmptyContent){
		this.includeEmptyContent = includeEmptyContent;
	}

	public Xmlstreamwriter getFullXml (SObjectXMLContext context){
		Xmlstreamwriter xmlW = new Xmlstreamwriter();
		xmlW.writeStartDocument('utf-8','1.0');
		setXml( xmlW, context );
		xmlW.writeEndDocument();
		return xmlW;
	}


	private void setXml (Xmlstreamwriter xmlW, SObjectXMLContext context){
		xmlW.writeStartElement(null, DOM_ELEM_SOBJECT, null);
		
			xmlW.writeStartElement(null, DOM_ELEM_TYPE, null);
				xmlW.writeCharacters( context.sObjectApiName );
			xmlW.writeEndElement(); //end TYPE

			xmlW.writeStartElement(null, DOM_ELEM_FIELDS, null);
				for ( String fieldApiName : context.fieldApiName2Value.keySet()) {
					String valueStr = String.valueOf ( context.fieldApiName2Value.get( fieldApiName ) );	

					if ( ! includeEmptyContent && String.isBlank(valueStr) ) {
						continue;
					}				

					xmlW.writeStartElement(null, fieldApiName.replace('.', '_').toUpperCase() , null);
						if (includeEmptyContent && String.isBlank(valueStr)){
							xmlW.writeCharacters( '' );
						} else {
							xmlW.writeCharacters( valueStr );
						}
					xmlW.writeEndElement(); 
					
				}
			xmlW.writeEndElement(); //end FIELDS

			if (! context.rlpName2childrenRelations.isEmpty() ){
				xmlW.writeStartElement(null, DOM_ELEM_CHILD_RELATIONS, null);
					for ( String childRlpName : context.rlpName2childrenRelations.keySet() ){
						
						xmlW.writeStartElement(null, childRlpName.toUpperCase(), null);
							for ( SObjectXMLContext childContext : context.rlpName2childrenRelations.get(childRlpName) ){
								setXml( xmlW, childContext );					
							}													
						xmlW.writeEndElement(); 
					}
				xmlW.writeEndElement(); //end CHILD_RELATIONS
			}
		xmlW.writeEndElement(); // end SOBJECT	
	}


	public class SObjectXMLContext {
		
		public String sObjectApiName;
		public Map<String, Object> fieldApiName2Value;
		public Map<String, List<SObjectXMLContext>> rlpName2childrenRelations;

		public SObjectXMLContext(SObjectType sObjType, Map<String, Object> fieldApiName2Value){
			this.fieldApiName2Value = fieldApiName2Value;
			this.rlpName2childrenRelations = new Map<String, List<SObjectXMLContext>>();
			this.sObjectApiName = String.valueOf(sObjType);	
		}

		public void addChildRelation(String chilrRlpName, List<SObjectXMLContext> context){
			rlpName2childrenRelations.put(chilrRlpName, context);
		}

	}


}