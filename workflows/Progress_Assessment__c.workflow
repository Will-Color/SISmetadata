<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><fieldUpdates>
        <fullName>Set_PAP_Completed_to_TRUE</fullName>
        <field>PAP_Completed__c</field>
        <literalValue>1</literalValue>
        <name>Set PAP Completed to TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Assessed_Period__c</targetObject>
    </fieldUpdates><fieldUpdates>
        <fullName>Set_PAP_Outcome</fullName>
        <field>PAP_Outcome__c</field>
        <formula>IF(TEXT(Panel_Recommendation__c)="Student has made satisfactory progress and should be permitted to re-register.",1,
IF(TEXT(Panel_Recommendation__c)="Minor concerns have been raised and these will be brought to attention of DPR and may require further action.",2,
IF(TEXT(Panel_Recommendation__c)="Student has not made sufficient satisfactory academic progress but is permitted a further period under review. Academic progress will be assessed further by the PAP.",3,
IF(TEXT(Panel_Recommendation__c)="Student's initial PhD registration is downgraded to MPhil and they are permitted to re-register under the revised qualification aim.",4,
IF(TEXT(Panel_Recommendation__c)="Student has not made satisfactory academic progress, and their studies should be terminated.",5,
IF(TEXT(Panel_Recommendation__c)="Student has been found guilty of serious academic malpractice in accordance with the Procedure of Academic Integrity of Postgraduate Research Programmes.",6,0))))))</formula>
        <name>Set PAP Outcome</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Assessed_Period__c</targetObject>
    </fieldUpdates><rules>
        <fullName>Set PAP Outcome on Assessed Research Period</fullName>
        <actions>
            <name>Set_PAP_Completed_to_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_PAP_Outcome</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3 OR 4 OR 5 OR 6 OR 7)</booleanFilter>
        <criteriaItems>
            <field>Progress_Assessment__c.Release_to_Student__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Progress_Assessment__c.Panel_Recommendation__c</field>
            <operation>startsWith</operation>
            <value>Student has made satisfactory progress and should be permitted to re-register.,Minor concerns have been raised and these will be brought to attention of DPR and may require further action.,Student has not made sufficient satisfactory academic progress b</value>
        </criteriaItems>
        <criteriaItems>
            <field>Progress_Assessment__c.Panel_Recommendation__c</field>
            <operation>startsWith</operation>
            <value>Minor concerns have been raised and these will be brought to attention of DPR and may require further action.</value>
        </criteriaItems>
        <criteriaItems>
            <field>Progress_Assessment__c.Panel_Recommendation__c</field>
            <operation>startsWith</operation>
            <value>Student has not made sufficient satisfactory academic progress but is permitted a further period under review. Academic progress will be assessed further by the PAP.</value>
        </criteriaItems>
        <criteriaItems>
            <field>Progress_Assessment__c.Panel_Recommendation__c</field>
            <operation>startsWith</operation>
            <value>Student's initial PhD registration is downgraded to MPhil and they are permitted to re-register under the revised qualification aim.</value>
        </criteriaItems>
        <criteriaItems>
            <field>Progress_Assessment__c.Panel_Recommendation__c</field>
            <operation>startsWith</operation>
            <value>Student has not made satisfactory academic progress,and their studies should be terminated.</value>
        </criteriaItems>
        <criteriaItems>
            <field>Progress_Assessment__c.Panel_Recommendation__c</field>
            <operation>startsWith</operation>
            <value>Student has been found guilty of serious academic malpractice in accordance with the Procedure of Academic Integrity of Postgraduate Research Programmes.</value>
        </criteriaItems>
        <description>Writes up to Assessed Research Period and sets 'PAP Outcome' according to Panel Recommendation. Sets  'PAP Completed' to true when Progress Assessment is released to student with acceptable Panel Recommendations.</description>
        <triggerType>onAllChanges</triggerType>
    </rules></Workflow>