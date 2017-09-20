/*
Created by Suyati Technologies
The class is used to genearate an XML stracture based on the SIS Audit object.

*/
public class XMLGenerationController {
    
    public List<String> FilteredprogramTypes = new List<String>();
    public List<String> Filteredprograms = new List<String>();  
    public List<String> FilteredSpecialinclusions = new List<String>();  
    public String FilteredYear;
    public String audit_period;
    
    public XMLGenerationController(){
        
        for(FilteredYear__c fy : FilteredYear__c.getAll().values())
        {
            FilteredYear = fy.name;
            System.debug('FilteredYear'+FilteredYear);
            audit_period = 'H' + fy.name.remove('/');
            System.debug('audit_period'+audit_period);
        }       
        for(FilteredProgramTypes__c pt : FilteredProgramTypes__c.getAll().values())
            FilteredprogramTypes.add(pt.Name);  
        System.debug('FilteredprogramTypes'+FilteredprogramTypes);
        
        for(FilteredProgrammeIds__c prog : FilteredProgrammeIds__c.getAll().values())
            Filteredprograms.add(prog.Name);  
        System.debug('Filteredprograms'+Filteredprograms);
        
        for(FilteredSpecialinclusions__c specialinclusions : FilteredSpecialinclusions__c.getAll().values())
            FilteredSpecialinclusions.add(specialinclusions.Name);  
        System.debug('FilteredSpecialinclusions'+FilteredSpecialinclusions);
        
    }
    
    //Return XML header
    public String getHeaderXmlOutput(){
        String headerXml = '<?xml version="1.0" encoding="utf-8" standalone="yes"?>';
        headerXml += '\n<StudentRecord';
        headerXml += ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"';
        headerXml += ' xsi:noNamespaceSchemaLocation=';
        headerXml += '"\\\\filestore\\Projects\\C16051_Student\\Testing\\Schema_XSD\\C16051.xsd">';
        headerXml += '<Institution><UKPRN>10003958</UKPRN><INSTAPP>0</INSTAPP><RECID>16051</RECID>';
        return headerXml.trim();
    }
    
    //Return XML footer
    public String getFooterXmlOutput(){
        return ('</Institution>'+ '\n' + '</StudentRecord>').trim();
    }
    
    //Return list of Courses
    public list<string> getCourses(){
        list<string> courseList = new list<string>();
        
        if(FilteredprogramTypes.isEmpty() && !FilteredSpecialinclusions.isEmpty())
        {
            System.debug('1'+FilteredprogramTypes.isEmpty() +!FilteredSpecialinclusions.isEmpty());
            for(SIS_Audit__c sisAuditRecordList :[SELECT Id, Audit_Output__c  FROM SIS_Audit__c 
                                                  WHERE 
                                                  Output_section__c= 'Course'  AND Exclude__c = False AND Audit_Period__c =: audit_period AND Special_Inclusion__c IN:FilteredSpecialinclusions
                                                 ]){            
                                                     courseList.add(sisAuditRecordList.Audit_Output__c.replaceAll('&','&amp;'));   
                                                     system.debug('sisAuditRecordList'+sisAuditRecordList);
                                                 }      
            
        }   
        else if(!FilteredprogramTypes.isEmpty() && !FilteredSpecialinclusions.isEmpty())
        {
            System.debug('2'+!FilteredprogramTypes.isEmpty() + !FilteredSpecialinclusions.isEmpty());
            
            for(SIS_Audit__c sisAuditRecordList :[SELECT Id, Audit_Output__c  FROM SIS_Audit__c 
                                                  WHERE 
                                                  Output_section__c= 'Course'  AND Exclude__c = False AND Audit_Period__c =: audit_period
                                                 ]){            
                                                     courseList.add(sisAuditRecordList.Audit_Output__c.replaceAll('&','&amp;'));             
                                                 }   }   
        else
        {
            System.debug('3'+!FilteredprogramTypes.isEmpty() + !FilteredSpecialinclusions.isEmpty());
            for(SIS_Audit__c sisAuditRecordList :[SELECT Id, Audit_Output__c  FROM SIS_Audit__c 
                                                  WHERE 
                                                  Output_section__c= 'Course'  AND Exclude__c = False AND Audit_Period__c =: audit_period AND Special_Inclusion__c = null
                                                 ]){            
                                                     
                                                     courseList.add(sisAuditRecordList.Audit_Output__c.replaceAll('&','&amp;'));                         
                                                 }   
        }   
        system.debug('courseList'+courseList);
        return courseList;
    }
    
    //Return list of Modules
    public list<String> getModules(){
        //To store the modules in SIS records
        list<String> moduleList = new list<String>();
        if(FilteredprogramTypes.isEmpty() && !FilteredSpecialinclusions.isEmpty())
        {
            for(SIS_Audit__c sisAuditRecordList :[SELECT Id, Audit_Output__c  FROM SIS_Audit__c 
                                                  WHERE 
                                                  Output_section__c= 'Module'  AND Exclude__c = False AND Audit_Period__c =: audit_period AND  Special_Inclusion__c IN:FilteredSpecialinclusions
                                                 ]){            
                                                     moduleList.add(sisAuditRecordList.Audit_Output__c.replaceAll('&','&amp;'));   
                                                 }
        }
        else if(!FilteredprogramTypes.isEmpty() && !FilteredSpecialinclusions.isEmpty())
        {
            for(SIS_Audit__c sisAuditRecordList :[SELECT Id, Audit_Output__c  FROM SIS_Audit__c 
                                                  WHERE 
                                                  Output_section__c= 'Module'  AND Exclude__c = False AND Audit_Period__c =: audit_period
                                                 ]){            
                                                     moduleList.add(sisAuditRecordList.Audit_Output__c.replaceAll('&','&amp;'));   
                                                 }           
        }
        else
        {
            for(SIS_Audit__c sisAuditRecordList :[SELECT Id, Audit_Output__c  FROM SIS_Audit__c 
                                                  WHERE 
                                                  Output_section__c= 'Module'  AND Exclude__c = False AND Audit_Period__c =: audit_period AND Special_Inclusion__c = null
                                                 ]){            
                                                     moduleList.add(sisAuditRecordList.Audit_Output__c.replaceAll('&','&amp;'));   
                                                 }                       
        }   
        system.debug('moduleList'+moduleList);
        return moduleList;
    }
    
        /*
    Return student details which consist of
    - Each student XML details
    - All the XML of student instances 
    - XML of student on module
    - XML of qualification on module 
    */
    
    public list<List<String>> getStudentDetails(){
        Map <Id,List<SIS_Audit__c>> studentMap = new Map <Id,List<SIS_Audit__c>>();
        Map <Id,List<SIS_Audit__c>> SPMap = new Map <Id,List<SIS_Audit__c>>();
        list<string> AuditEvent = new list<string>{'Registration','Student Module','Qualification','REF Data'};
            string Studentid, SPid;
        list<String> xmlPerStudent = new list<String>();
        list<list<String>> xmlStudent = new list<list<String>>();
        List<SIS_Audit__c> SISList = new List<SIS_Audit__c>([SELECT Id, Student__c,Output_section__c, Audit_Output__c,Audit_Output2__c,Student_Programme__c 
                                                             FROM SIS_Audit__c 
                                                             WHERE 
                                                             (Audit_Event__c IN : AuditEvent 
                                                              AND Exclude__c = False 
                                                              AND Student_Programme__r.Programme_Type__c IN:FilteredprogramTypes 
                                                              AND Student_Programme__r.Programme__c IN: Filteredprograms 
                                                              AND Student_Programme__r.Academic_Year__c =: FilteredYear 
                                                              AND Audit_Period__c =: audit_period
                                                             ) 
                                                             OR 
                                                             (Audit_Event__c IN : AuditEvent 
                                                              AND Exclude__c = False 
                                                              AND Special_Inclusion__c IN: FilteredSpecialinclusions
                                                              AND Audit_Period__c =: audit_period
                                                             ) 
                                                             ORDER BY Order__c
                                                            ]);
        system.debug('SISList'+SISList);
        for(SIS_Audit__c AudObj : SISList)
        {
            
            Studentid = AudObj.Student__c;
            if(studentMap.containsKey(Studentid)) {
                List<SIS_Audit__c> sAList = studentMap.get(Studentid);
                sAList.add(AudObj); 
                studentMap.put(Studentid,sAList);
            } else {
                studentMap.put(Studentid, new List<SIS_Audit__c> { AudObj });
            }   
            
        }
        list<String> studList = new list<String>();
        
        list<String> instanceList = new list<String>();
        list<String> temporarySOM = new list<String>();
        list<String> temporaryInstaceList = new list<String>();
        map<id, string> stdM = new map<id, string>();
        for(List<SIS_Audit__c> AudList1 : studentMap.values())
        {
            for(SIS_Audit__c AudObj1 : AudList1)
            {
                if(AudObj1.Output_section__c == 'Qualification on Entry')
                    stdM.put(AudObj1.Student__c, AudObj1.Audit_Output__c);
            }
        }
        for(List<SIS_Audit__c> AudList1 : studentMap.values())
        {
            for(SIS_Audit__c AudObj1 : AudList1)
            {
                SPid = AudObj1.Student_Programme__c;
                if(SPMap.containsKey(SPid)) {
                    List<SIS_Audit__c> sAList = SPMap.get(SPid);
                    sAList.add(AudObj1); 
                    SPMap.put(SPid,sAList);
                } else {
                    SPMap.put(SPid, new List<SIS_Audit__c> { AudObj1 });
                }
                //stdM.put(SPid, AudObj1.Audit_Output__c);  
            }
            for(List<SIS_Audit__c> AudList : SPMap.values())
            {
                for(SIS_Audit__c sisAuditObj: AudList)
                {
                    
                    if(sisAuditObj.Output_section__c == 'Student')
                        studList.add(sisAuditObj.Audit_Output__c.replaceAll('&','&amp;'));
                }
                for(SIS_Audit__c sisAuditObj: AudList)
                {
                    if(sisAuditObj.Output_section__c == 'instance'){
                        temporaryInstaceList.add(sisAuditObj.Audit_Output__c.replaceAll('&','&amp;'));
                        if(stdM.get(sisAuditObj.Student__c) != null && stdM.get(sisAuditObj.Student__c) != '')
                        {
                            temporaryInstaceList.add('<QualificationsOnEntry>');
                            temporaryInstaceList.add(stdM.get(sisAuditObj.Student__c));
                            temporaryInstaceList.add('</QualificationsOnEntry>');                   
                        }   
                        temporaryInstaceList.add('</EntryProfile>');
                    }
                    if(sisAuditObj.Audit_Output2__c != null && sisAuditObj.Audit_Output2__c != '' ){
                        temporaryInstaceList.add(sisAuditObj.Audit_Output2__c);
                    }
                    
                    
                    if(sisAuditObj.Output_section__c == 'Unit of Assessment'){
                        temporaryInstaceList.add('<REFData>');
                        temporaryInstaceList.add(sisAuditObj.Audit_Output__c.replaceAll('&','&amp;'));
                        temporaryInstaceList.add('</REFData>');
                    }
                    
                    if(sisAuditObj.Output_section__c == 'Student on Module'){
                        temporarySOM.add('<StudentOnModule>');
                        temporarySOM.add(sisAuditObj.Audit_Output__c.replaceAll('&','&amp;'));
                        temporarySOM.add('</StudentOnModule>');
                    }
                }
                
                
                if (!temporaryInstaceList.isEmpty() && !temporarySOM.isEmpty())
                {
                    instanceList.add('<Instance>');
                    instanceList.addall(temporaryInstaceList);
                    instanceList.addall(temporarySOM);  
                    instanceList.add('</Instance>');
                }
                else if (!temporaryInstaceList.isEmpty())
                {
                    instanceList.add('<Instance>');
                    instanceList.addall(temporaryInstaceList); 
                    instanceList.add('</Instance>'); 
                }
                else if (!temporarySOM.isEmpty())
                {
                    instanceList.add('<Instance>');
                    instanceList.addall(temporarySOM);  
                    instanceList.add('</Instance>');
                }
                temporarySOM.clear();
                temporaryInstaceList.clear();
                
            }
            xmlPerStudent.addAll(studList);
            xmlPerStudent.addAll(instanceList);
            xmlStudent.add(xmlPerStudent); 
            studList.clear();
            instanceList.clear();
            temporarySOM.clear();
            xmlPerStudent = new list<String>();
            SPMap = new Map <Id,List<SIS_Audit__c>>();
        }
        return xmlStudent;
    }//getStudentDetails() End          
}