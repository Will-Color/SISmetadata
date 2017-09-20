<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><fieldUpdates>
        <fullName>Moderated_Mark</fullName>
        <field>Agreed_Mark__c</field>
        <formula>Marker_1__c</formula>
        <name>Moderated Mark</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Remove_Resit_Button</fullName>
        <description>Changes Record type and so page layout</description>
        <field>RecordTypeId</field>
        <lookupValue>Resit_Disallowed</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Remove Resit Button</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Student_Assessment_Name</fullName>
        <field>Name</field>
        <formula>If (AND ( Sit_Level__c =1,  Inactive__c = False),
    Student__r.LastName &amp; " - " &amp; Left ( Assessment__r.Name ,30) &amp; " (" &amp; Student_Module__r.Programme_Module__r.Programme__r.Code__c &amp;")",
    Student__r.LastName &amp; " - " &amp; Left ( Assessment__r.Name ,30) &amp; " (" &amp; Student_Module__r.Programme_Module__r.Programme__r.Code__c &amp;") - " &amp;  Sitting__c 
)</formula>
        <name>Update Student Assessment Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Weighted_Score</fullName>
        <field>Weighted_Score__c</field>
        <formula>IF ( OR (TEXT(Mitigating_Circumstances__c)="Accepted", Inactive__c = True),  
    Null, 
    IF ( NOT(ISBLANK( Manual_Mark__c)), 
        Manual_Mark__c *  Weighting__c ,
        IF ( AND (Resit_Level__c  &gt; 0,  Agreed_Mark__c &gt; 50),
           50 * Weighting__c, 
            Agreed_Mark__c *  Weighting__c 
        )
    )
)</formula>
        <name>Update Weighted Score</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><rules>
        <fullName>Moderated Mark</fullName>
        <actions>
            <name>Moderated_Mark</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Student_Assessment__c.Agreement_Reached__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>If Agreement Reached (say in import) is True that populates Agreed Mark with Marker 1 score</description>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Refresh Student Assessment</fullName>
        <actions>
            <name>Update_Student_Assessment_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Write weighted score from raw score, based on various business rules; and record name from Student Surname, Assessment Name, Module Code and Sitting</description>
        <formula>OR( ISNEW() , ISCHANGED(  LastModifiedDate ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Remove Resit Button</fullName>
        <actions>
            <name>Remove_Resit_Button</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>from Student Assessment page layout; changes Record type and so page layout</description>
        <formula>OR ( Inactive__c = TRUE, ( AND (  Resit_Level__c &gt;0, NOT(ISPICKVAL(Mitigating_Circumstances__c,"Accepted")))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Weighted Score</fullName>
        <actions>
            <name>Update_Weighted_Score</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Write weighted score from raw score, based on various business rules</description>
        <formula>OR( ISNEW() , ISCHANGED(  Agreed_Mark__c  ), ISCHANGED(  Manual_Score__c ), ISCHANGED ( Weighted_Score__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules></Workflow>