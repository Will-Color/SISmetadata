/**
 * @author Valentyn Bilenkyy
 * @date 13/06/2014
 * @description Controller for ChooseProgramme page
 */
 /***** Modifications
/// done for  on A6 Persistent Application Links ,Display the data base on parameter received on applyWizard Page o=in student community on 14-06-2015 *****/
///Author: MKM
/// <summary> Edited the query by adding filter using programme id passed through url </summary>
/// <param name="programmeId">Used store selected programme id and send via Url</param>
public class ChooseProgrammeCont {
    
    public static final String EMPTY_STRING = '';
    public static final String LABEL_NONE = '-None-';
    public static final Integer SEARCH_RESULTS_PER_PAGE = 10;
    
    public static final String PROG_TYPE_DIPLOMA = 'Professional Diploma';
    public static final String PROG_TYPE_MSC = 'MSc Programme';
    public static final String PROG_TYPE_MASTERS = 'Masters Module';
    public static final String PROG_TYPE_SHORT_COURSE = 'Short Course';
    public static final String PROG_TYPE_PGT = 'PGT';
    public static final String PROG_TYPE_PGR = 'PGR';
    
    public static final String EXT_TYPE_SHORT_COURSE = 'Short Course';
    public static final String EXT_TYPE_MSC = 'MSc Programme';
    public static final String EXT_TYPE_PROFESSIONAL = 'Professional Programme';
    public static final String EXT_TYPE_RESEARCH = 'Research Programme';
    public static final String EXT_TYPE_CLOSED = 'Closed Course';
    
    /**
     * Constructor after initialization seaches for available programmes
     */
    public ChooseProgrammeCont() {
        search();
    }
    
    public String searchTerm {get;set;}
    public String searchProgrammeType {get;set;}
    public Boolean hasResults {get;set;}
    public Integer resultsSize {get;set;}
    public Integer resultsPageSize {get;set;}
    public Id programmeId {get;set;}

    /**
     * List controller for enabling pagination
     * @return ApexPages.StandardSetController programmesSetController
     */
    public ApexPages.StandardSetController programmesSetController {
        get{
            if(programmesSetController == null) {
                resultsPageSize = SEARCH_RESULTS_PER_PAGE;
                if(searchTerm == null) 
                    searchTerm = '';
                if(searchProgrammeType == null) 
                    searchProgrammeType = '';
                String searchString = '\'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
                String queryString = 'SELECT Id, Code__c, Name, Start_Date__c, End_Date__c, Home_EU_Fee__c, Overseas_Fee__c, Programme_Type_External__c, Fee_TBC__c FROM Programme__c WHERE Name LIKE ' + searchString;
                if(String.isNotEmpty(searchProgrammeType)){
                    if (EXT_TYPE_SHORT_COURSE.equalsIgnoreCase(searchProgrammeType)){
                        queryString += ' AND Type__c IN (\'' + String.escapeSingleQuotes(PROG_TYPE_MASTERS) + '\',\'' + String.escapeSingleQuotes(PROG_TYPE_SHORT_COURSE) + '\')';
                        //queryString += ' AND Type__c LIKE \'' + String.escapeSingleQuotes(PROG_TYPE_MASTERS) + '\' OR Type__c LIKE \'' + String.escapeSingleQuotes(PROG_TYPE_SHORT_COURSE) + '\'';
                    }else if (EXT_TYPE_RESEARCH.equalsIgnoreCase(searchProgrammeType)){
                        queryString += ' AND Type__c IN (\'' + String.escapeSingleQuotes(PROG_TYPE_PGR) + '\',\'' + String.escapeSingleQuotes(PROG_TYPE_PGT) + '\')';
                        //queryString += ' AND Type__c LIKE \'' + String.escapeSingleQuotes(PROG_TYPE_PGR) + '\' OR Type__c LIKE \'' + String.escapeSingleQuotes(PROG_TYPE_PGT) + '\'';
                        
                    }else if (EXT_TYPE_PROFESSIONAL.equalsIgnoreCase(searchProgrammeType)){
                        queryString += ' AND (Type__c LIKE \'' + String.escapeSingleQuotes(PROG_TYPE_DIPLOMA) + '\' OR Type__c LIKE \'' + String.escapeSingleQuotes(EXT_TYPE_CLOSED) + '\')';
                    
                    }else {
                        queryString += ' AND Type__c LIKE \'' + String.escapeSingleQuotes(searchProgrammeType) + '\'';
                    }
                } 
                string filter =  ApexPages.currentPage().getParameters().get('programmeid');                
                system.debug('*** -- filter= ' + filter + ' -- ***');
                if(filter != null&& filter != '' ){
                    //set<id> idsOfPgmVersion = new set<id>(); 
                   // for(Programme_Version__c  pgmversioVr : [SELECT Id FROM Programme_Version__c where Master_Link__c =: filter  ]){
                        //idsOfPgmVersion.add(pgmversioVr.id);
                  //    }
                  //   system.debug('*** -- idsOfPgmVersion= ' + idsOfPgmVersion+ ' -- ***');
                    //queryString += ' AND Programme_Version__c IN :idsOfPgmVersion AND Active__c = true AND Start_Date__c > today ORDER BY Name ASC';
                    queryString += ' AND Id =: filter AND Active__c = true AND (Start_Date__c > today OR End_Date__c = null ) ORDER BY Name ASC';
                    
                } 
                else{    
                      queryString += ' AND Active__c = true AND (Start_Date__c > today OR End_Date__c = null) ORDER BY Name ASC';
                }
                system.debug('*** -- QueryString = ' + queryString + ' -- ***');
                programmesSetController = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                programmesSetController.setPageSize(resultsPageSize);
                resultsSize = programmesSetController.getResultSize();
            }
            return programmesSetController;
        }
        set;
    }

    /**
     * Indicates whether there are more records after the current page set
     * @return Boolean
     */
    public Boolean hasNext {
        get {
            return programmesSetController.getHasNext();
        }
        set;
    }

    /**
     * Indicates whether there are more records before the current page set
     * @return Boolean
     */
    public Boolean hasPrevious {
        get {
            return programmesSetController.getHasPrevious();
        }
        set;
    }
  
    /**
     * Returns the page number of the current page set. Note that the first page returns 1
     * @return Integer
     */
    public Integer pageNumber {
        get {
            return programmesSetController.getPageNumber();
        }
        set;
    }

    /**
     * Redirects to given page reference
     * @return PageReference page
     */
    private PageReference redirect(PageReference page) {
        page.setRedirect(true);
        return page;
    }

    /**
     * Returns the first page of records
     */
    public void first() {
        programmesSetController.first();
    }
  
    /**
     * Returns the last page of records
     */
    public void last() {
        programmesSetController.last();
    }
  
    /**
     * Returns the previous page of records
     */
    public void previous() {
        programmesSetController.previous();
    }
  
    /**
     * Returns the next page of records
     */
    public void next() {
        programmesSetController.next();
    }

    /**
     * Returns available programmes list
     * @return List<ProgrammeWrapper> programmesList
     */
    public List<ProgrammeWrapper> getFoundProgrammes() {
        List<ProgrammeWrapper> programmesList = new List<ProgrammeWrapper>();
        if(programmesSetController != null) {
            for(Programme__c p : (List<Programme__c>)programmesSetController.getRecords())
                programmesList.add(new ProgrammeWrapper(p));
        }
        return programmesList;
    }

    /**
     * Populating values for dropdown filter
     * @return List<SelectOption> options
     */
    public List<SelectOption> getProgrammeTypes() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Programme_Version__c.Programme_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption(EMPTY_STRING, LABEL_NONE));
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        return options;
    }
    
    /**
     * Populating values for dropdown filter for external facing list
     * @return List<SelectOption> options
     */
    public List<SelectOption> getProgrammeTypesExternal() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Programme_Version__c.Programme_Type_External__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption(EMPTY_STRING, LABEL_NONE));
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        return options;
    }

    /**
     * Page reference for search button
     */
    public PageReference search() {
        programmesSetController = null;
        hasResults = false;
        if(getFoundProgrammes() != null) {
            programmesSetController.setPageNumber(1);
            if(resultsSize>0) hasResults = true;
        }
        return null;
    }

    /**
    * Page reference for reset search button
    */
    public PageReference resetSearch(){
        programmesSetController = null;
        searchTerm = null;
        searchProgrammeType = null;
        return null;
    }

    /**
     * Page reference for apply button/link
     */
    public PageReference processApply() {
        if(programmeId != null) {
            Student_Programme__c sp = ApplyServices.createCourseByProgrammeId(programmeId);
            system.debug('sp = ' + sp);
            if(sp == NULL){
                return NULL;
            }
            
            Contact student = [SELECT Id,LSTM_No__c FROM Contact WHERE Id =: sp.Student__c];
            Programme__c programme = [SELECT Id,External_Form__c,Programme_Version__r.Master_Link__r.Application_Form_Type__c FROM Programme__c WHERE Id =: sp.Programme__c];
            
            if(programme.Programme_Version__r.Master_Link__r.Application_Form_Type__c.equals('FormAssembly') && String.isNotBlank(programme.External_Form__c))
            {
                PageReference pg = Page.ExternalForm;
                pg.getParameters().put('SPID', sp.Id);
                pg.getParameters().put('StudentID', student.Id);
                return pg;  
            }
            else
            {
                PageReference applyWizardReference = Page.ApplyWizard;
                applyWizardReference.getParameters().put('Id', sp.Id);
                return redirect(applyWizardReference);              
            }   
        }
        return null;
    }
}