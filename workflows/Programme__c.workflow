<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><fieldUpdates>
        <fullName>Set_Audit_Trigger</fullName>
        <description>Sets Audit Trigger to True, to invoke HESA Course XML audit Flow and so update the related SIS Audit record
3/7/16: removed from rule for initial Audit work</description>
        <field>Audit_Trigger__c</field>
        <literalValue>1</literalValue>
        <name>Set Audit Trigger</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Set_Instance_Code</fullName>
        <field>Programme_Code__c</field>
        <formula>Programme_Version__r.Code__c</formula>
        <name>Set Programme Code on Instance</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Set_Programme_Code</fullName>
        <field>Programme_Code__c</field>
        <formula>Programme_Version__r.Code__c</formula>
        <name>Set Programme Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Prog_Instance_Name</fullName>
        <field>Name</field>
        <formula>Programme_Version__r.Master_Link__r.Name &amp; ": " &amp;  Instance_Suffix__c</formula>
        <name>Update Prog Instance Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><rules>
        <fullName>Amend Prog Instance Name</fullName>
        <actions>
            <name>Update_Prog_Instance_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Adds Instance Suffix to the Programme name, either if record is new or is modified; takes original name from Version Master
5/6/16: Amended to also set Audit Trigger to true, to invoke HESA Course XML Flow</description>
        <formula>AND ( OR ( ISNEW() ,  ISCHANGED( LastModifiedDate )),      NOT ( ISBLANK ( Instance_Suffix__c )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Programme Code</fullName>
        <actions>
            <name>Set_Programme_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Programme_Code__c to Programme_Version__r.Code__c on creation of Instance record only.</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>Programme Instance Code</fullName>
        <actions>
            <name>Set_Instance_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Programme_Code__c to Programme_Version__r.Code__c on creation of Instance record only.</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules></Workflow>