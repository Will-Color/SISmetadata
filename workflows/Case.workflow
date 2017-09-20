<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><alerts>
        <fullName>Web_Enquiry_to_MyLSTM</fullName>
        <description>Web Enquiry to MyLSTM</description>
        <protected>false</protected>
        <recipients>
            <recipient>mylstm@lstmed.ac.uk</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>mylstm@lstmed.ac.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>MyLSTM_Account/Web_Enquiry</template>
    </alerts><fieldUpdates>
        <fullName>Add_Code_to_Subject</fullName>
        <description>Prefix  the Code of Programme Version to Subject line</description>
        <field>Subject</field>
        <formula>Programme_Version__r.Code__c &amp; " - " &amp;  Web_Subject__c</formula>
        <name>Add Code to Subject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Populate_Web_Subject</fullName>
        <field>Web_Subject__c</field>
        <formula>Subject</formula>
        <name>Populate Web Subject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates>
        <fullName>Priority_to_High</fullName>
        <field>Priority</field>
        <literalValue>High</literalValue>
        <name>Priority to High</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><rules>
        <fullName>Add Code to Subject</fullName>
        <actions>
            <name>Add_Code_to_Subject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Add the code from chosen Programme Version to the Enquiry subject</description>
        <formula>NOT ( ISBLANK ( Web_Subject__c ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Populate Web Subject</fullName>
        <actions>
            <name>Populate_Web_Subject</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Priority_to_High</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>to allow Enquiry Subject to start with Programme Version Code</description>
        <formula>AND ( ISPICKVAL (Origin, "Web"),  ISBLANK ( Web_Subject__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Web Enquiry to MyLSTM</fullName>
        <actions>
            <name>Web_Enquiry_to_MyLSTM</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web</value>
        </criteriaItems>
        <description>Sends web to case enquiry details to MyLSTM mailbox.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules></Workflow>