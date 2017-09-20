@IsTest
public class TestFilterSisAuditsForXMLcontroller{

static testMethod void TestStudentXML() {

  id masterRecType = Schema.SObjectType.Programme_Version__c.getRecordTypeInfosByName().get('Master Version').getRecordTypeId();
  id recType = Schema.SObjectType.Programme_Version__c.getRecordTypeInfosByName().get('Versions').getRecordTypeId();

  Contact con = new Contact(LastName = 'test');
  INSERT con;

  Programme_Version__c masterLink = new Programme_Version__c(Name = 'testPV',HESA_Audit__c = true, Programme_Type__c = 'Professional Diploma');
  masterLink.RecordTypeId = masterRecType;
  Insert masterLink;

  Programme_Version__c pv = new Programme_Version__c(Name = 'testPV',HESA_Audit__c = true, Programme_Type__c = 'Professional Diploma',Master_Link__c = masterLink.Id);
  pv.RecordTypeId = recType;
  Insert pv;

  Programme__c p = new Programme__c(Name = 'testProgramme',Academic_Year__c = '14/15');
  p.programme_version__c = pv.Id;
  Insert p;
    
  Programme__c prog = [SELECT Id,Name,Type__c,HESA_Audit__c FROM Programme__c WHERE Id =: p.Id];
  system.debug(prog.Type__c + ',' + prog.Hesa_Audit__c);

  Test.startTest();
  FilterSisAuditsForXMLcontroller filterXml = new FilterSisAuditsForXMLcontroller();
  filterXml.mpChckBxProgrammeType.put('Professional Diploma',True);  
  filterXml.year = '14/15';
  filterXml.onSelect();
  filterXml.mpChckBxProgramme.put(prog.id,True);
  filterXml.saveMethod();

  Test.stopTest();
 }
}