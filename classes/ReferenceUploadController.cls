/*
*
* 2014-07-16 : CSL : New class that looks after the ReferenceUpload VF Page
* enabling Referees to upload References (documents) against a Student Programme Application
*
*/
public class ReferenceUploadController {
    
    public final String STUDENT_PROG_PARAM_ID = 'spid';
    public final String REFERENCE_PARAM_ID = 'rid';
    public final String REFERENCE_STATUS_REPLIED = 'Replied';

    public Student_Programme__c sp {get; set;}
    public References__c reference {get; set;}
    public boolean showError {get; set;}
    public blob inputFile {get; set;}
    public String inFileName {set; get;}

    public ReferenceUploadController(){
        showError = false;
        Id spId = ApexPages.currentPage().getParameters().get(STUDENT_PROG_PARAM_ID);
        Id rId = ApexPages.currentPage().getParameters().get(REFERENCE_PARAM_ID);
        
        if (spId == null || rId == null){
            showError = true;
        }else {
            sp = [select s.Id, s.Name from Student_Programme__c s where s.Id = :spId LIMIT 1];
            reference = [select r.Id, r.Reference_Status__c, r.Referee__r.LastName from References__c r where r.Id = :rId LIMIT 1]; 
        }
            
        if (sp == null || reference == null){
            showError = true;
        }
        
        
    }
    
    public PageReference uploadAttachment(){
        PageReference pageRef;
        
        Attachment a = new Attachment();
        a.ParentId = reference.Id;
        //a.Name = sp.Name + '_REFERENCE ' + reference.Referee__r.LastName;
        a.Name = inFileName;
        //Need to populate the Body field
        a.Body = inputFile;
        
        insert a;
        
        reference.Reference_Status__c = REFERENCE_STATUS_REPLIED;
        
        update reference;
        
        pageRef = Page.ReferenceUploadThankyou;
        pageRef.setRedirect(true);
        
        return pageRef;
    }

}