public class PicklistDescriber {
    static final Pattern OPTION_PATTERN = Pattern.compile('<option.+?>(.+?)</option>'); 
    
    /**
        Desribe a picklist field for an sobject id. RecordType is automatically picked
        based on the record's RecordTypeId field value.
        example usage :
        List<String> options = PicklistDescriber.describe(accountId, 'Industry');
    */
    public static List<String> describe(Id sobjectId, String pickListFieldAPIName) {
        return parseOptions(
                            new Map<String, String> {
                                                     'id' => sobjectId,
                                                     'pickListFieldName'=> pickListFieldAPIName
                                                    }
                            );
    }
    
    /*
        Internal method to parse the OPTIONS
    */
    static List<String> parseOptions(Map<String, String> params) {
        Pagereference pr = Page.PicklistDesc;
        // to handle development mode, if ON
        pr.getParameters().put('core.apexpages.devmode.url', '1');
        
        for (String key : params.keySet()) {
            pr.getParameters().put(key, params.get(key));   
        }
        
        if(!Test.isRunningTest())
        {
            String xmlContent = pr.getContent().toString();
            
            Matcher mchr = OPTION_PATTERN.matcher(xmlContent);
            List<String> options = new List<String>();
            while(mchr.find()) {
                options.add(mchr.group(1));
            } 
            // remove the --None-- element
            if (!options.isEmpty()) options.remove(0);
            return options;
        }
        else
        {
            List<String> options = new List<String>();
            options.add('Stage1');
            options.add('Stage2');
            options.add('Stage3'); 
            options.add('Stage4');    
            options.add('Stage5');    
            options.add('Stage6'); 
            options.add('Stage7');
            options.add('Stage8');    
            options.add('Stage9');    
            options.add('Stage10');    
                
            return options;                               
        }    
    }
}