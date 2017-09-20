/* QandERelatedlistControllerExt  Created by Manu KM on 08-sep-2015*/
/// <summary>
// This Class consist of methods for showing Q and E fields as a related list on Student programme and pagination mehtods
/// </summary>
/// <param name="deleteRecordId "> Strores the Id of Q&E record to be deletds</param>
/// <param name="deleteRecord "> Returns the Id of deleting Q&E filed</param>
/// <param name="studentPgmId ">Stores the parent Student programme ID </param>
/// <param name="noOfRecords"> Stores totoal number of Q&E records present for pagination</param>
/// <param name="size "> Number of records showing</param>

public with sharing class QandERelatedlistControllerExt {
 public Id deleteRecordId {
        get;
        set;
    }
    public id deleteRecord {
        get;
        set;
    }
    public string studentPgmId {
        get;
        set;
    }
    Public Integer noOfRecords {
        get;
        set;
    }
    Public Integer size {
        get;
        set;
    }   
   //Queries all then Q&E fields Based on the criteria
    public ApexPages.StandardSetController setCon {
        get {
            if (setCon == null) {
                size = 5;
                studentPgmId = ApexPages.currentPage().getParameters().get('id');
                // string studentPgmId = 'a0B11000005Pcq7';
                Student_Programme__c sp = [Select Student__c from Student_Programme__c where id = : studentPgmId];
                string spStdntId = sp.Student__c;
                string queryString = 'Select Id,name,Narrative__c,LastModifiedDate,RecordType.Name,Status__c,Order__c  from Qualifications_Experience__c where Contact__c =: spStdntId ORDER BY Order__c ASC NULLS LAST ';
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }
        set;
    }
   
    //method will find whter there is any next page to be showned for Q&E
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
     //will find whter there is any previous page to be showned for Q&E
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
    
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
     //Standared Controller
    public QandERelatedlistControllerExt(ApexPages.StandardController controller) {

    }
    public QandERelatedlistControllerExt(){
    }
    //Fteches all the Q&E records related to the parent Student programme
    public List < Qualifications_Experience__c > getQandE() {
        List < Qualifications_Experience__c > QEList = new List < Qualifications_Experience__c > ();
        for (Qualifications_Experience__c a: (List < Qualifications_Experience__c > ) setCon.getRecords())
            QEList.add(a);
        return QEList;

    }
     //Refreshes the pageblock manually or after every action
    public pageReference refresh() {
        setCon = null;
        getQandE();
        setCon.setPageNumber(1);
        return null;
    }
    //take to the first page of the pagination
    public void first() {
        setCon.first();
    }
    //take to the lastpage of the pagination
    public void last() {
        setCon.last();
    }
    //take to the previous page of the pagination
    public void previous() {
        setCon.previous();
    }
    //take to the next page of the pagination
    public void next() {
        setCon.next();
    }
    //Method will delete the selected Q&E record
    public void deleteRecord() {
        Qualifications_Experience__c deletingRecord = [select id from Qualifications_Experience__c where id = : deleteRecordId];
        delete deletingRecord;
        refresh();
        return;
    }
}