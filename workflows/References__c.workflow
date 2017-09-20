<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><alerts>
        <fullName>Referee_Request</fullName>
        <description>Referee Request</description>
        <protected>false</protected>
        <recipients>
            <field>Referee__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>mylstm@lstmed.ac.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Application_Email_Templates/Referee_Request</template>
    </alerts><fieldUpdates>
        <fullName>Update_Referee_Status</fullName>
        <field>Reference_Status__c</field>
        <literalValue>Requested</literalValue>
        <name>Update Referee Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><rules>
        <fullName>Referee Request</fullName>
        <actions>
            <name>Referee_Request</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Referee_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>References__c.Reference_Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>References__c.Can_Request_Reference_from_Referee__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>References__c.Has_Attachment__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>References__c.Programme_Type__c</field>
            <operation>notEqual</operation>
            <value>Short Course</value>
        </criteriaItems>
        <criteriaItems>
            <field>References__c.Referee_Override__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Sends email to referees requesting reference; not sent for Short Courses or if manual reference uploaded</description>
        <triggerType>onAllChanges</triggerType>
    </rules><tasks>
        <fullName>Email_Reference_Request_Sent</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Email: Reference Request Sent</subject>
    </tasks></Workflow>