<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><fieldUpdates>
        <fullName>Set_Audit_Trigger</fullName>
        <description>3/7/16: removed from rule for initial Audit work</description>
        <field>Audit_Trigger__c</field>
        <literalValue>1</literalValue>
        <name>Set Audit Trigger</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Module_Instance_Name</fullName>
        <field>Name</field>
        <formula>Module_Version__r.Master_Link__r.Name &amp; ": " &amp; Instance_Suffix__c</formula>
        <name>Update Module Instance Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><rules>
        <fullName>Amend Mod Instance Name</fullName>
        <actions>
            <name>Update_Module_Instance_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Adds Instance Suffix to the Module name, either if record is new or is modified; takes original name from Version Master</description>
        <formula>OR ( ISNEW() , ISCHANGED( LastModifiedDate ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules></Workflow>