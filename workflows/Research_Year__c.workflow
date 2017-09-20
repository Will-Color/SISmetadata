<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><fieldUpdates>
        <fullName>Set_Name</fullName>
        <description>Sets Name to Student Programme Name + Period Number</description>
        <field>Name</field>
        <formula>Student_Programme__r.Name&amp;" - Year "&amp;TEXT(Period_Number__c)&amp;" of "&amp;TEXT(Student_Programme__r.PGR_Programme_Length_Years__c)</formula>
        <name>Set Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><rules>
        <fullName>Set Research Year Name</fullName>
        <actions>
            <name>Set_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules></Workflow>