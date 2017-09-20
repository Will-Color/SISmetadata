<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><fieldUpdates>
        <fullName>Update_Module_Version_Name</fullName>
        <field>Name</field>
        <formula>Master_Link__r.Name &amp; " / V:" &amp;  Version_Suffix__c</formula>
        <name>Update Mod Version Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><rules>
        <fullName>Amend Mod Version Name</fullName>
        <actions>
            <name>Update_Module_Version_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Amend Module Version name for non-Master records to append suffix</description>
        <formula>RecordType.DeveloperName = "Versions"</formula>
        <triggerType>onAllChanges</triggerType>
    </rules></Workflow>