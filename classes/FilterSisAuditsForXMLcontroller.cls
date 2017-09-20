public class FilterSisAuditsForXMLcontroller 
{
    Public String year{get;set;}
    Public List<String> programmeTypes{get;set;}
    Public List<String> specialinclusions{get;set;}
    Public List<Programme__c> programmes{get;set;}
    public map<String,Boolean> mpChckBxProgrammeType{get;set;}  
    public map<String,Boolean> mpChckBxspecialinclusions{get;set;}
    public map<Id,Boolean> mpChckBxProgramme{get;set;}  
    public List<SelectOption> options{get;set;}  
    
    public FilterSisAuditsForXMLcontroller()
    {
        programmeTypes = new List<String>();
        specialinclusions = new List<String>();
        programmes = new List<Programme__c>();   
        mpChckBxProgrammeType = new map<String,Boolean>();
        mpChckBxspecialinclusions = new map<String,Boolean>();
        mpChckBxProgramme = new map<Id,Boolean>();

        options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Programme__c.Academic_Year__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            if(f.getValue() != '14/15' && f.getValue() != '15/16' )
                options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        options.add(new SelectOption('15/16', '15/16'));

        Schema.DescribeFieldResult SIfieldResult = SIS_Audit__c.Special_Inclusion__c.getDescribe();
        List<Schema.PicklistEntry> SIple = SIfieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : SIple)
        {
            specialinclusions.add(f.getValue());
        }       
        
        programmeTypes.add('MSc Programme');
        programmeTypes.add('Professional Diploma');
        programmeTypes.add('PGR');

        for(String pt : programmeTypes)
        {
            mpChckBxProgrammeType.put(pt,false);
        }
        
        for(String si : specialinclusions)
        {
            mpChckBxspecialinclusions.put(si,false);
        }   

    }
    
    public PageReference onSelect()
    {
        List<String> selectedPTS = new List<String>();

        for(String pt : mpChckBxProgrammeType.keyset() )
            if(mpChckBxProgrammeType.get(pt))
               selectedPTS.add(pt);
        
        programmes = [SELECT Id,Name FROM Programme__c WHERE HESA_Audit__c = true AND Type__c IN: selectedPTS AND Academic_Year__c =: year ]; 

        Set<Programme__c> tempSet = new Set<Programme__c>();
        for(Programme__c prog : programmes)
        {
            mpChckBxProgramme.put(prog.Id,false);
            tempSet.add(prog);
        }   
        programmes.clear();
        for(Programme__c prog : tempSet)
            programmes.add(prog);
        
        return null;                   
        
    }
    
        
    public pagereference saveMethod()
    {
        List<FilteredProgramTypes__c> csProgramTypes_old = FilteredProgramTypes__c.getAll().values();
        List<FilteredProgrammeIds__c> csPrograms_old = FilteredProgrammeIds__c.getAll().values(); 
        List<FilteredSpecialinclusions__c> csSpecialinclusions_old = FilteredSpecialinclusions__c.getAll().values();   
        List<FilteredYear__c> csyear_old = FilteredYear__c.getAll().values();   
        delete csProgramTypes_old;
        delete csPrograms_old;
        delete csSpecialinclusions_old;
        delete csyear_old;
            
        List<FilteredProgrammeIds__c> csPrograms = new List<FilteredProgrammeIds__c>();  
        List<FilteredProgramTypes__c> csProgramTypes = new List<FilteredProgramTypes__c>();  
        List<FilteredSpecialinclusions__c> csSpInclusions = new List<FilteredSpecialinclusions__c>();  

        FilteredYear__c fy = new FilteredYear__c();
        fy.name = year;
        System.debug('FY'+fy);
        insert fy;
        
        for(String pt : mpChckBxProgrammeType.keyset() )
        {
            if(mpChckBxProgrammeType.get(pt))
            {
                FilteredProgramTypes__c csProgramType = new FilteredProgramTypes__c();
                csProgramType.Name = pt;
                csProgramTypes.add(csProgramType);
                System.debug('csProgramTypes'+csProgramTypes);
            }
        }
        for(Id prog : mpChckBxProgramme.keyset() )
        {
            if(mpChckBxProgramme.get(prog))
            {
                FilteredProgrammeIds__c csProgram = new FilteredProgrammeIds__c();
                csProgram.Name = prog;
                csPrograms.add(csProgram);
                System.debug('csPrograms'+csPrograms);
            }
        } 
        
        for(String si : mpChckBxspecialinclusions.keyset() )
        {
            if(mpChckBxspecialinclusions.get(si))
            {
                FilteredSpecialinclusions__c csSpInclusion = new FilteredSpecialinclusions__c();
                csSpInclusion.Name = si;
                csSpInclusions.add(csSpInclusion);
                System.debug('csSpInclusions'+csSpInclusions);
            }
        }       
        insert csProgramTypes;
        insert csPrograms;     
        insert csSpInclusions;
    
        PageReference page = new PageReference('/apex/XMLgeneratorHelper');              
        page.setRedirect(false);        
        return page;

    }
}