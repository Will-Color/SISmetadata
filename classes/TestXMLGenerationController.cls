@IsTest
public class TestXMLGenerationController {

 //XMLGenerationController xml = new XMLGenerationController();
 //string header= xml.getHeaderXmlOutput();
static testMethod void TestCourseXML() {
  SIS_Audit__c sisAudit = new SIS_Audit__c();
  sisAudit.AUDIT_BODY__C = 'test';
  sisAudit.AUDIT_PERIOD__C = 'H1516';
  sisAudit.AUDIT_OUTPUT__C = '<COURSEID>MC776</COURSEID><OWNCOURSEID>MC776</OWNCOURSEID><AWARDBOD>10003958</AWARDBOD><CLSDCRS>0</CLSDCRS><COLLORG>0000</COLLORG><COURSEAIM>*** LSTM tbc ***</COURSEAIM><CTITLE>Child Nutrition - 14/15</CTITLE><MSFUND>*** LSTM tbc ***</MSFUND><REDUCEDC>00</REDUCEDC><TTCID>0</TTCID><CourseSubject><SBJCA>A000</SBJCA><SBJPCNT>100</SBJPCNT></CourseSubject>';
  sisAudit.OUTPUT_SECTION__C = 'Course';
  sisAudit.AUDIT_EVENT__C = 'Active Programme';
  sisAudit.Special_Inclusion__c = 'Credit Bearing Short Course';
  INSERT sisAudit;
  
  SIS_Audit__c sisAudit2 = new SIS_Audit__c();
  sisAudit2.AUDIT_BODY__C = 'test';
  sisAudit2.AUDIT_PERIOD__C = 'H1516';
  sisAudit2.AUDIT_OUTPUT__C = '<COURSEID>MC776</COURSEID><OWNCOURSEID>MC776</OWNCOURSEID><AWARDBOD>10003958</AWARDBOD><CLSDCRS>0</CLSDCRS><COLLORG>0000</COLLORG><COURSEAIM>*** LSTM tbc ***</COURSEAIM><CTITLE>Child Nutrition - 14/15</CTITLE><MSFUND>*** LSTM tbc ***</MSFUND><REDUCEDC>00</REDUCEDC><TTCID>0</TTCID><CourseSubject><SBJCA>A000</SBJCA><SBJPCNT>100</SBJPCNT></CourseSubject>';
  sisAudit2.OUTPUT_SECTION__C = 'Course';
  sisAudit2.AUDIT_EVENT__C = 'Active Programme';
  INSERT sisAudit2;  
  
  FilteredYear__c fy = new FilteredYear__c(Name='15/16');
  insert fy;
  
  FilteredProgramTypes__c fpt = new FilteredProgramTypes__c(Name='Professional Diploma');
  insert fpt;   
  
  XMLGenerationController xml1 = new XMLGenerationController();
  list < string > courseList1 = xml1.getCourses();
  
  FilteredSpecialinclusions__c fsi = new FilteredSpecialinclusions__c(Name='Credit Bearing Short Course');
  insert  fsi;
  
  XMLGenerationController xml2 = new XMLGenerationController();
  list < string > courseList2 = xml2.getCourses();

  delete fpt;
  
  Test.startTest();
  XMLGenerationController xml3 = new XMLGenerationController();
  list < string > courseList3 = xml3.getCourses();
  Test.stopTest();

}

static testMethod void TestStaticHeaderAndFooter() {
  string header;
  string footer;
  Test.startTest();
  XMLGenerationController xml = new XMLGenerationController();
  header = xml.getHeaderXmlOutput();
  footer = xml.getFooterXmlOutput();
  Test.stopTest();

}

static testMethod void TestModuleXML() {
  SIS_Audit__c sisAudit = new SIS_Audit__c();
  sisAudit.AUDIT_BODY__C = 'test';
  sisAudit.AUDIT_PERIOD__C = 'H1516';
  sisAudit.AUDIT_OUTPUT__C = '<MODID></MODID><CRDTPTS></CRDTPTS><CRDTSCM>1</CRDTSCM><FTE>100</FTE><LEVLPTS>6</LEVLPTS><MTITLE>Parasite Epidemiology & Control - 2014/15</MTITLE><PCOLAB>00</PCOLAB><ModuleSubject><COSTCN>*** LSTM tbc ***</COSTCN><MODSBJ>*** LSTM tbc ***</MODSBJ><MODSBJP>100</MODSBJP></ModuleSubject>';
  sisAudit.OUTPUT_SECTION__C = 'Module';
  sisAudit.Audit_Event__c = 'Active Module';
  sisAudit.Special_Inclusion__c = 'Credit Bearing Short Course';
  INSERT sisAudit;

  SIS_Audit__c sisAudit2 = new SIS_Audit__c();
  sisAudit2.AUDIT_BODY__C = 'test';
  sisAudit2.AUDIT_PERIOD__C = 'H1516';
  sisAudit2.AUDIT_OUTPUT__C = '<COURSEID>MC776</COURSEID><OWNCOURSEID>MC776</OWNCOURSEID><AWARDBOD>10003958</AWARDBOD><CLSDCRS>0</CLSDCRS><COLLORG>0000</COLLORG><COURSEAIM>*** LSTM tbc ***</COURSEAIM><CTITLE>Child Nutrition - 14/15</CTITLE><MSFUND>*** LSTM tbc ***</MSFUND><REDUCEDC>00</REDUCEDC><TTCID>0</TTCID><CourseSubject><SBJCA>A000</SBJCA><SBJPCNT>100</SBJPCNT></CourseSubject>';
  sisAudit2.OUTPUT_SECTION__C = 'Course';
  sisAudit2.AUDIT_EVENT__C = 'Active Programme';
  INSERT sisAudit2;  
  
  FilteredYear__c fy = new FilteredYear__c(Name='15/16');
  insert fy;  
  
  FilteredProgramTypes__c fpt = new FilteredProgramTypes__c(Name='Professional Diploma');
  insert fpt;   

  XMLGenerationController xml = new XMLGenerationController();
  list < string > moduleList = xml.getModules();
  
  FilteredSpecialinclusions__c fsi = new FilteredSpecialinclusions__c(Name='Credit Bearing Short Course');
  insert  fsi;  

  XMLGenerationController xml2 = new XMLGenerationController();
  list < string > moduleList2 = xml2.getModules();  
  
  delete fpt;
  
  Test.startTest();
  XMLGenerationController xml3 = new XMLGenerationController();
  list < string > moduleList3 = xml3.getModules();
  Test.stopTest();

}

static testMethod void TestStudentXML() {

  id recType = Schema.SObjectType.Programme_Version__c.getRecordTypeInfosByName().get('Versions').getRecordTypeId();

  Contact con = new Contact(LastName = 'test');
  INSERT con;
  Programme_Version__c pv = new Programme_Version__c(Name = 'testPV',Programme_Type__c = 'Professional Diploma');
  pv.Entry_Award_1__c = 'MSc';
  pv.RecordTypeId = recType;
  INSERT pv;

  Programme__c p = new Programme__c(Name = 'testProgramme',Academic_year__c = '15/16');
  p.programme_version__c = pv.Id;
  INSERT p;

  FilteredProgrammeIds__c fp = new FilteredProgrammeIds__c(Name = p.Id);
  insert fp;
  FilteredProgramTypes__c fpt = new FilteredProgramTypes__c(Name='Professional Diploma');
  insert fpt;   
  FilteredYear__c fy = new FilteredYear__c(Name='15/16');
  insert fy;  
  
  Student_Programme__c sp = new Student_Programme__c();
  sp.Name = 'testStudentProgramme';
  sp.Student__c = con.Id;
  sp.programme__C = p.Id;
  INSERT sp;

  SIS_Audit__c sisAudit = new SIS_Audit__c();
  sisAudit.AUDIT_BODY__C = 'test';
  sisAudit.AUDIT_PERIOD__C = 'H1516';
  sisAudit.AUDIT_OUTPUT__C = '<HUSID>*** LSTM tbc ***</HUSID><OWNSTU>00011727</OWNSTU><BIRTHDTE>2015-06-20</BIRTHDTE><DISABLE></DISABLE><ETHNIC></ETHNIC><FNAMES>Manu</FNAMES><NATION>AS</NATION><SEXID>1</SEXID><SURNAME>km</SURNAME><TTACCOM>*** LSTM tbc ***</TTACCOM><TTPCODE>6578393</TTPCODE><ULN>*** LSTM tbc ***</ULN>';
  sisAudit.OUTPUT_SECTION__C = 'Student';
  sisAudit.AUDIT_EVENT__C = 'Registration';
  sisAudit.Student__c = con.Id;
  sisAudit.Student_Programme__c = sp.Id;
  INSERT sisAudit;

  SIS_Audit__c sisAuditInstance = new SIS_Audit__c();
  sisAuditInstance.AUDIT_BODY__C = 'test';
  sisAuditInstance.AUDIT_PERIOD__C = 'H1516';
  sisAuditInstance.AUDIT_OUTPUT__C = '<NUMHUS>01</NUMHUS><OWNINST>00012488</OWNINST><COURSEID>Work in Progress</COURSEID><BRIDGE>0</BRIDGE><CAMPID>A</CAMPID><COMDATE>2016-01-11</COMDATE><ELQ>*** LSTM tbc ***</ELQ><ENDDATE>2016-04-08</ENDDATE><EXCHANGE>N</EXCHANGE><FEEELIG>Work in Progress</FEEELIG><FEEREGIME>*** LSTM tbc ***</FEEREGIME><FESTUMK>*** LSTM tbc ***</FESTUMK><FUNDCODE>*** LSTM tbc ***</FUNDCODE><FUNDCOMP>*** LSTM tbc ***</FUNDCOMP><FUNDLEV>20</FUNDLEV><LOCSDY>Z</LOCSDY><MODE>01</MODE><MSTUFEE>*** LSTM tbc ***</MSTUFEE><RCSTDNT>99</RCSTDNT><REDUCEDI>*** LSTM tbc ***</REDUCEDI><SPECFEE>0</SPECFEE><SPLENGTH>Work in Progress</SPLENGTH><SSN>*** LSTM tbc ***</SSN><STULOAD>Work in Progress</STULOAD><TYPEYR>Work in Progress</TYPEYR><UNITLGTH>Work in Progress</UNITLGTH><YEARPRG>Work in Progress</YEARPRG><YEARSTU>Work in Progress</YEARSTU>';
  sisAuditInstance.OUTPUT_SECTION__C = 'Instance';
  sisAuditInstance.AUDIT_EVENT__C = 'Registration';
  sisAuditInstance.Student__c = con.Id;
  sisAuditInstance.Student_Programme__c = sp.Id;
  INSERT sisAuditInstance;

  SIS_Audit__c sisAuditQOEntry = new SIS_Audit__c();
  sisAuditQOEntry.AUDIT_BODY__C = 'test';
  sisAuditQOEntry.AUDIT_PERIOD__C = 'H1516';
  sisAuditQOEntry.AUDIT_OUTPUT__C = '<QUALGRADE>Pass</QUALGRADE><QUALSBJ>C14</QUALSBJ><QUALSIT>W</QUALSIT><QUALTYPE>A</QUALTYPE><QUALYEAR>2010</QUALYEAR>';
  sisAuditQOEntry.OUTPUT_SECTION__C = 'Qualification on Entry';
  sisAuditQOEntry.AUDIT_EVENT__C = 'Registration';
  sisAuditQOEntry.Student__c = con.Id;
  INSERT sisAuditQOEntry;

  SIS_Audit__c sisAuditSOM = new SIS_Audit__c();
  sisAuditSOM.AUDIT_BODY__C = 'test';
  sisAuditSOM.AUDIT_PERIOD__C = 'H1516';
  sisAuditSOM.AUDIT_OUTPUT__C = '<MODID>DTM&H</MODID><MODOUT>6</MODOUT><MODSTAT>2</MODSTAT>';
  sisAuditSOM.OUTPUT_SECTION__C = 'Student On Module';
  sisAuditSOM.AUDIT_EVENT__C = 'Student Module';
  sisAuditSOM.Student__c = con.Id;
  sisAuditSOM.Student_Programme__c = sp.Id;
  INSERT sisAuditSOM;
  Test.startTest();
  XMLGenerationController xml = new XMLGenerationController();
  list < list < string >> studList = xml.getStudentDetails();
  Test.stopTest();
 }

static testMethod void TestStudentXMLWithInstanceOnly() {
  id recType = Schema.SObjectType.Programme_Version__c.getRecordTypeInfosByName().get('Versions').getRecordTypeId();

  Contact con = new Contact(LastName = 'test');
  INSERT con;
  Programme_Version__c pv = new Programme_Version__c(Name = 'testPV',Programme_Type__c = 'Professional Diploma');
  pv.Entry_Award_1__c = 'MSc';
  pv.RecordTypeId = recType;
  INSERT pv;

  Programme__c p = new Programme__c(Name = 'testProgramme',Academic_year__c = '15/16');
  p.programme_version__c = pv.Id;
  INSERT p;

  FilteredProgrammeIds__c fp = new FilteredProgrammeIds__c(Name = p.Id);
  insert fp;
  FilteredProgramTypes__c fpt = new FilteredProgramTypes__c(Name='Professional Diploma');
  insert fpt;   
  FilteredYear__c fy = new FilteredYear__c(Name='15/16');
  insert fy;  

  Student_Programme__c sp = new Student_Programme__c();
  sp.Name = 'testStudentProgramme';
  sp.Student__c = con.Id;
  sp.programme__C = p.Id;
  INSERT sp;

  SIS_Audit__c sisAudit = new SIS_Audit__c();
  sisAudit.AUDIT_BODY__C = 'test';
  sisAudit.AUDIT_PERIOD__C = 'H1516';
  sisAudit.AUDIT_OUTPUT__C = '<HUSID>*** LSTM tbc ***</HUSID><OWNSTU>00011727</OWNSTU><BIRTHDTE>2015-06-20</BIRTHDTE><DISABLE></DISABLE><ETHNIC></ETHNIC><FNAMES>Manu</FNAMES><NATION>AS</NATION><SEXID>1</SEXID><SURNAME>km</SURNAME><TTACCOM>*** LSTM tbc ***</TTACCOM><TTPCODE>6578393</TTPCODE><ULN>*** LSTM tbc ***</ULN>';
  sisAudit.OUTPUT_SECTION__C = 'Student';
  sisAudit.AUDIT_EVENT__C = 'Registration';
  sisAudit.Student__c = con.Id;
  sisAudit.Student_Programme__c = sp.Id;
  INSERT sisAudit;

  SIS_Audit__c sisAuditQOEntry = new SIS_Audit__c();
  sisAuditQOEntry.AUDIT_BODY__C = 'test';
  sisAuditQOEntry.AUDIT_PERIOD__C = 'H1516';
  sisAuditQOEntry.AUDIT_OUTPUT__C = '<QUALGRADE>Pass</QUALGRADE><QUALSBJ>C14</QUALSBJ><QUALSIT>W</QUALSIT><QUALTYPE>A</QUALTYPE><QUALYEAR>2010</QUALYEAR>';
  sisAuditQOEntry.OUTPUT_SECTION__C = 'Qualification on Entry';
  sisAuditQOEntry.AUDIT_EVENT__C = 'Registration';
  sisAuditQOEntry.Student__c = con.Id;
  INSERT sisAuditQOEntry;

  SIS_Audit__c sisAuditInstance = new SIS_Audit__c();
  sisAuditInstance.AUDIT_BODY__C = 'test';
  sisAuditInstance.AUDIT_PERIOD__C = 'H1516';
  sisAuditInstance.AUDIT_OUTPUT__C = '<NUMHUS>01</NUMHUS><OWNINST>00012488</OWNINST><COURSEID>Work in Progress</COURSEID><BRIDGE>0</BRIDGE><CAMPID>A</CAMPID><COMDATE>2016-01-11</COMDATE><ELQ>*** LSTM tbc ***</ELQ><ENDDATE>2016-04-08</ENDDATE><EXCHANGE>N</EXCHANGE><FEEELIG>Work in Progress</FEEELIG><FEEREGIME>*** LSTM tbc ***</FEEREGIME><FESTUMK>*** LSTM tbc ***</FESTUMK><FUNDCODE>*** LSTM tbc ***</FUNDCODE><FUNDCOMP>*** LSTM tbc ***</FUNDCOMP><FUNDLEV>20</FUNDLEV><LOCSDY>Z</LOCSDY><MODE>01</MODE><MSTUFEE>*** LSTM tbc ***</MSTUFEE><RCSTDNT>99</RCSTDNT><REDUCEDI>*** LSTM tbc ***</REDUCEDI><SPECFEE>0</SPECFEE><SPLENGTH>Work in Progress</SPLENGTH><SSN>*** LSTM tbc ***</SSN><STULOAD>Work in Progress</STULOAD><TYPEYR>Work in Progress</TYPEYR><UNITLGTH>Work in Progress</UNITLGTH><YEARPRG>Work in Progress</YEARPRG><YEARSTU>Work in Progress</YEARSTU>';
  sisAuditInstance.OUTPUT_SECTION__C = 'Instance';
  sisAuditInstance.AUDIT_EVENT__C = 'Registration';
  sisAuditInstance.Student__c = con.Id;
  sisAuditInstance.Student_Programme__c = sp.Id;
  INSERT sisAuditInstance;
  Test.startTest();
  XMLGenerationController xml = new XMLGenerationController();
  list < list < string >> studList = xml.getStudentDetails();
  Test.stopTest();
}

static testMethod void TestStudentXMLWithSOMOnly() {
  id recType = Schema.SObjectType.Programme_Version__c.getRecordTypeInfosByName().get('Versions').getRecordTypeId();

  Contact con = new Contact(LastName = 'test');
  INSERT con;
  Programme_Version__c pv = new Programme_Version__c(Name = 'testPV',Programme_Type__c = 'Professional Diploma');
  pv.Entry_Award_1__c = 'MSc';
  pv.RecordTypeId = recType;
  INSERT pv;

  Programme__c p = new Programme__c(Name = 'testProgramme',Academic_year__c = '15/16');
  p.programme_version__c = pv.Id;
  INSERT p;
  
  FilteredProgrammeIds__c fp = new FilteredProgrammeIds__c(Name = p.Id);
  insert fp;
  FilteredProgramTypes__c fpt = new FilteredProgramTypes__c(Name='Professional Diploma');
  insert fpt;   
  FilteredYear__c fy = new FilteredYear__c(Name='15/16');
  insert fy;  
  
  Student_Programme__c sp = new Student_Programme__c();
  sp.Name = 'testStudentProgramme';
  sp.Student__c = con.Id;
  sp.programme__C = p.Id;
  INSERT sp;

  SIS_Audit__c sisAudit = new SIS_Audit__c();
  sisAudit.AUDIT_BODY__C = 'test';
  sisAudit.AUDIT_PERIOD__C = 'H1516';
  sisAudit.AUDIT_OUTPUT__C = '<HUSID>*** LSTM tbc ***</HUSID><OWNSTU>00011727</OWNSTU><BIRTHDTE>2015-06-20</BIRTHDTE><DISABLE></DISABLE><ETHNIC></ETHNIC><FNAMES>Manu</FNAMES><NATION>AS</NATION><SEXID>1</SEXID><SURNAME>km</SURNAME><TTACCOM>*** LSTM tbc ***</TTACCOM><TTPCODE>6578393</TTPCODE><ULN>*** LSTM tbc ***</ULN>';
  sisAudit.OUTPUT_SECTION__C = 'Student';
  sisAudit.AUDIT_EVENT__C = 'Registration';
  sisAudit.Student__c = con.Id;
  sisAudit.Student_Programme__c = sp.Id;
  INSERT sisAudit;

  SIS_Audit__c sisAuditQOEntry = new SIS_Audit__c();
  sisAuditQOEntry.AUDIT_BODY__C = 'test';
  sisAuditQOEntry.AUDIT_PERIOD__C = 'H1516';
  sisAuditQOEntry.AUDIT_OUTPUT__C = '<QUALGRADE>Pass</QUALGRADE><QUALSBJ>C14</QUALSBJ><QUALSIT>W</QUALSIT><QUALTYPE>A</QUALTYPE><QUALYEAR>2010</QUALYEAR>';
  sisAuditQOEntry.OUTPUT_SECTION__C = 'Qualification on Entry';
  sisAuditQOEntry.AUDIT_EVENT__C = 'Registration';
  sisAuditQOEntry.Student__c = con.Id;
  INSERT sisAuditQOEntry;

  SIS_Audit__c sisAuditSOM = new SIS_Audit__c();
  sisAuditSOM.AUDIT_BODY__C = 'test';
  sisAuditSOM.AUDIT_PERIOD__C = 'H1516';
  sisAuditSOM.AUDIT_OUTPUT__C = '<MODID>DTM&H</MODID><MODOUT>6</MODOUT><MODSTAT>2</MODSTAT>';
  sisAuditSOM.OUTPUT_SECTION__C = 'Student On Module';
  sisAuditSOM.AUDIT_EVENT__C = 'Student Module';
  sisAuditSOM.Student__c = con.Id;
  sisAuditSOM.Student_Programme__c = sp.Id;
  INSERT sisAuditSOM;

  Test.startTest();
  XMLGenerationController xml = new XMLGenerationController();
  list < list < string >> studList = xml.getStudentDetails();
  Test.stopTest();
}

}