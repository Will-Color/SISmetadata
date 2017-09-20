<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><fieldUpdates>
        <fullName>Set_Expiration_Date</fullName>
        <field>Expiry_Date__c</field>
        <formula>IF( Programme_Type__c = "MSc Programme",DATE(YEAR( Student_Programme__r.Programme__r.End_Date__c ),MONTH(DATE(2001,12,31)),DAY(Date(2001,12,31))),IF(Programme_Code__c = "DTM&amp;H",Student_Programme__r.Programme__r.End_Date__c +30,IF(Programme_Type__c = "Short Course",Student_Programme__r.Programme__r.End_Date__c +15,NULL )))</formula>
        <name>Set Expiration Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><rules>
        <fullName>Set Expiry Date</fullName>
        <actions>
            <name>Set_Expiration_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Expiry Date of Provision based on Programme Type/Code</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules></Workflow>