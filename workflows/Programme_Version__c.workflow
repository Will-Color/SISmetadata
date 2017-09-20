<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><fieldUpdates>
        <fullName>Update_Programme_Version_Name</fullName>
        <field>Name</field>
        <formula>Master_Link__r.Name &amp; IF(ISPICKVAL(Master_Link__r.Programme_Type__c,"PGR")," - "&amp;Version_Suffix__c," / V:" &amp; Text(Academic_Year__c))</formula>
        <name>Update Prog Version Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><rules>
        <fullName>Amend Prog Version Name</fullName>
        <actions>
            <name>Update_Programme_Version_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Amend Programme Version name for non-Master records to append suffix</description>
        <formula>RecordType.DeveloperName = "Versions"</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Create Version Name</fullName>
        <actions>
            <name>Update_Programme_Version_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND (ISCHANGED ( LastModifiedDate ),  RecordType.DeveloperName = "Versions")</formula>
        <triggerType>onAllChanges</triggerType>
    </rules></Workflow>