<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><fieldUpdates>
        <fullName>HESA_QualsAwarded</fullName>
        <description>To record &lt;QualificationsAwarded&gt; in correct HESA format</description>
        <field>Audit_Output2__c</field>
        <formula>"&lt;QualificationsAwarded&gt;" &amp;
   CASE ( TEXT ( Student_Programme__r.Agreed_Classification__c), "Distinction", "&lt;CLASS&gt;" &amp; "12" &amp;"&lt;/CLASS&gt;", "Merit", "&lt;CLASS&gt;" &amp; "13" &amp;"&lt;/CLASS&gt;", "Pass", "&lt;CLASS&gt;" &amp; "14" &amp;"&lt;/CLASS&gt;", NULL) 
&amp; "&lt;QUAL&gt;" &amp;  
   IF (  Student_Programme__r.Programme_Type__c = "MSc Programme", "M00",
   IF (  Student_Programme__r.Programme_Type__c = "Professional Diploma", "M41",   
   IF (  Student_Programme__r.Programme_Type__c = "PGR", "D00","M90"))) &amp; 
"&lt;/QUAL&gt;" &amp;
"&lt;/QualificationsAwarded&gt;"</formula>
        <name>HESA QualsAwarded</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Stamp_Missing_Fields</fullName>
        <field>Compiled_Missing_Fields__c</field>
        <formula>Student_Programme_Missing_Fiedls__c + Student_Missing_Fields__c</formula>
        <name>Stamp Missing Fields</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><rules>
        <fullName>HESA QualsAwarded</fullName>
        <actions>
            <name>HESA_QualsAwarded</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>To record &lt;QualificationsAwarded&gt; in correct HESA format</description>
        <formula>AND ( Output_Section__c = "Instance",  TEXT (Student_Programme__r.Stage__c) = "Completed", 
     NOT ( OR  ( 
           TEXT (Student_Programme__r.Agreed_Classification__c) = "Fail", 
           TEXT (Student_Programme__r.Agreed_Classification__c) = "Did not complete",
           ISBLANK ( TEXT ( Student_Programme__r.Agreed_Classification__c))
          ))
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Stamp Missing Fields</fullName>
        <actions>
            <name>Stamp_Missing_Fields</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(NOT(ISNULL(Student_Missing_Fields__c)),NOT(ISNULL(Student_Programme_Missing_Fiedls__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules></Workflow>