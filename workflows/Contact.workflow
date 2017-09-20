<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><fieldUpdates>
        <fullName>Populates_LSTM_Email</fullName>
        <field>LSTM_Email__c</field>
        <formula>TEXT( VALUE(LSTM_No__c)) &amp;"@lstmed.ac.uk"</formula>
        <name>Populates LSTM Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates>
        <fullName>Populates_Personal_Email</fullName>
        <field>Personal_Email__c</field>
        <formula>Email</formula>
        <name>Populates Personal Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><rules>
        <fullName>LSTM Email on Contact</fullName>
        <actions>
            <name>Populates_LSTM_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populates_Personal_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>From LSTM No, LSTM Email is blank; only for Student records</description>
        <formula>AND( ISBLANK ( LSTM_Email__c ),  RecordType.Name = "Student Applicant")</formula>
        <triggerType>onAllChanges</triggerType>
    </rules></Workflow>