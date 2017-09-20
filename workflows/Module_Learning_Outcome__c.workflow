<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><fieldUpdates>
        <fullName>Set_No_Value</fullName>
        <description>Sets Record Number value</description>
        <field>Record_No__c</field>
        <formula>Text (  Module_Version__r.Count_of_Outcomes__c + 1)</formula>
        <name>Set No Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><rules>
        <fullName>Set No Value</fullName>
        <actions>
            <name>Set_No_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Record Number value for Module Learning Outcome</description>
        <formula>ISBLANK ( Record_No__c )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules></Workflow>