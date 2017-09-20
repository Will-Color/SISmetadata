<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><fieldUpdates>
        <fullName>Set_No_Value</fullName>
        <field>Record_No__c</field>
        <formula>IF (  Type__c = "A", 
  "A"&amp; Text (Programme_Version__r.Count_of_OutcomesA__c + 1),    
  IF (  Type__c = "B", 
    "B"&amp; Text ( Programme_Version__r.Count_of_Outcomes_B__c + 1 ), 
      IF (  Type__c = "C", 
        "C"&amp; Text (Programme_Version__r.Count_of_Outcomes_C__c + 1),
        "Error"
)))</formula>
        <name>Set No Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Set_Type_Abbrev</fullName>
        <description>Sets first character of Outcome Type to hidden field Type, to allow RSF on Programme Versions and so allow No workflow on Outcomes</description>
        <field>Type__c</field>
        <formula>LEFT( TEXT( Outcome_Type__c ) , 1)</formula>
        <name>Set Type Abbrev</name>
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
        <description>Looks for change in hidden field Type and applies field update</description>
        <formula>ISBLANK (  Record_No__c )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>Set Type Abbrev</fullName>
        <actions>
            <name>Set_Type_Abbrev</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets first character of picklist to separate field for reporting</description>
        <formula>OR ( ISNEW() , ISCHANGED(Outcome_Type__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules></Workflow>