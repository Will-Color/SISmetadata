<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><fieldUpdates>
        <fullName>Set_Audit_Trigger</fullName>
        <field>Audit_Trigger__c</field>
        <literalValue>1</literalValue>
        <name>Set Audit Trigger</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Stud_Mod</fullName>
        <description>Uses first 10 chars of Student surname, with Trop code and Instance Suffix from Programme</description>
        <field>Name</field>
        <formula>LEFT (Student__r.LastName, 10) 
&amp; " - " &amp;  LEFT (Programme_Module__r.Module__r.Module_Reference__c, 20)
&amp; " " &amp;  Programme_Module__r.Programme__r.Instance_Suffix__c</formula>
        <name>Update Stud Mod Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><rules>
        <fullName>Amend Stud Mod Name</fullName>
        <actions>
            <name>Update_Stud_Mod</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>With first 10 chars of Student surname, with Trop code and Instance Suffix from Programme</description>
        <formula>OR ( ISNEW() ,  ISCHANGED ( LastModifiedDate ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Audit Log on Student Programme</fullName>
        <actions>
            <name>Set_Audit_Trigger</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Audit Log on Student Programme but not on Student Module will set Audit Trigger to True and so invoke the Flow for HESA Student on Module XML Output</description>
        <formula>AND(
   NOT (ISBLANK(Student_Programme__r.Audit_Log__c)),
   ISBLANK( Audit_Log__c )
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules></Workflow>