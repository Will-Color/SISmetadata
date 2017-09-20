<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><fieldUpdates>
        <fullName>Set_Supervision_Name</fullName>
        <field>Name</field>
        <formula>Student_Programme__r.Name&amp;" - "&amp;IF(ISBLANK(Supervisor__c),Supervisor_Name_temp_del__c,Supervisor__r.LastName)&amp;" - "&amp;IF(ISBLANK(Research_Period__c),"Application","Year "&amp;TEXT(Research_Period__r.Period_Number__c))</formula>
        <name>Set Supervision Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><rules>
        <fullName>Set Supervision Name</fullName>
        <actions>
            <name>Set_Supervision_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets name of Supervision record according to record type</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules></Workflow>