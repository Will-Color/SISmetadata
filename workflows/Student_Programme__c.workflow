<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><alerts>
        <fullName>Confirmation_of_Submission_Email</fullName>
        <description>Confirmation of Submission Email</description>
        <protected>false</protected>
        <recipients>
            <field>Student__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>mylstm@lstmed.ac.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Application_Email_Templates/Submission_Confirmation</template>
    </alerts><alerts>
        <fullName>Confirmation_of_Submission_Online</fullName>
        <description>Confirmation of Submission Email - Online</description>
        <protected>false</protected>
        <recipients>
            <field>Student__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>mylstm@lstmed.ac.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Application_Email_Templates/Submission_Confirmation_Online</template>
    </alerts><alerts>
        <fullName>Delete_AD_Account</fullName>
        <description>Delete AD Account</description>
        <protected>false</protected>
        <recipients>
            <recipient>itservices@lstmed.ac.uk</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kevin.thomas@lstmed.ac.uk</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tel@lstmed.ac.uk</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>mylstm@lstmed.ac.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Registration_Email_Templates/Delete_AD_Account</template>
    </alerts><alerts>
        <fullName>INTERNAL_Pre_Reg_Completed</fullName>
        <description>INTERNAL Pre-Reg Completed</description>
        <protected>false</protected>
        <recipients>
            <recipient>VLE_Admin_Group</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>mylstm@lstmed.ac.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Registration_Email_Templates/Internal_Pre_Registration_Confirmation</template>
    </alerts><alerts>
        <fullName>Internal_Disability_Email</fullName>
        <description>Internal Disability Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>sarah.jones@lstmed.ac.uk</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>mylstm@lstmed.ac.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Application_Email_Templates/Internal_Disability_Notification</template>
    </alerts><alerts>
        <fullName>Internal_Submission_Alert</fullName>
        <description>Internal Submission Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>VLE_Admin_Group</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>mylstm@lstmed.ac.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Application_Email_Templates/Internal_Submission_Confirmation</template>
    </alerts><alerts>
        <fullName>Invitation_to_Pre_Register</fullName>
        <description>Invitation to Pre-Register</description>
        <protected>false</protected>
        <recipients>
            <field>Personal_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>mylstm@lstmed.ac.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Registration_Email_Templates/Pre_Registration_Invitation_PCU</template>
    </alerts><alerts>
        <fullName>Invitation_to_Pre_Register_MSc</fullName>
        <description>Invitation to Pre-Register MSc</description>
        <protected>false</protected>
        <recipients>
            <field>Personal_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>mylstm@lstmed.ac.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Registration_Email_Templates/Pre_Registration_Invitation_MSc</template>
    </alerts><alerts>
        <fullName>LSTM_Reminder_Please_Upload_a_Photograph</fullName>
        <description>LSTM Reminder: Please Upload a Photograph</description>
        <protected>false</protected>
        <recipients>
            <field>LSTM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Personal_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>mylstm@lstmed.ac.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Registration_Email_Templates/Pre_Registration_Photograph</template>
    </alerts><alerts>
        <fullName>Pre_Registration_Confirmation</fullName>
        <description>Pre-Registration Confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>Personal_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>mylstm@lstmed.ac.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Registration_Email_Templates/Pre_Registration_Confirmation</template>
    </alerts><alerts>
        <fullName>Pre_Registration_LSTM_Password</fullName>
        <description>Pre-Registration LSTM Password</description>
        <protected>false</protected>
        <recipients>
            <field>Personal_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>mylstm@lstmed.ac.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Registration_Email_Templates/Pre_Registration_LSTM_Password</template>
    </alerts><alerts>
        <fullName>Send_MRC_DTP_Reminder_1_Email</fullName>
        <description>Send MRC DTP Reminder 1 Email</description>
        <protected>false</protected>
        <recipients>
            <field>Personal_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>mylstm@lstmed.ac.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>MRC_DTP/MRC_DTP_Reminder_1</template>
    </alerts><alerts>
        <fullName>Send_Online_Payment_email</fullName>
        <description>Send Online Payment email</description>
        <protected>false</protected>
        <recipients>
            <field>Personal_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PCU_Emails/Online_Payment_PCU</template>
    </alerts><alerts>
        <fullName>Send_Online_Payment_with_Academic_Credit_email</fullName>
        <description>Send Online Payment with Academic Credit email</description>
        <protected>false</protected>
        <recipients>
            <field>Personal_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PCU_Emails/Online_Payment_PCU_with_AC</template>
    </alerts><fieldUpdates>
        <fullName>Application_RT_Checked</fullName>
        <description>changes student programme record type to Checkec</description>
        <field>RecordTypeId</field>
        <lookupValue>Checked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Stud Prog RT=Checked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Force_Student_Programme_Name</fullName>
        <description>For dataloaded records (eg test or paper applications)</description>
        <field>Name</field>
        <formula>Student__r.LastName &amp; " - " &amp; Programme__r.Code__c</formula>
        <name>Force Student Programme Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>OHA_Status_Exempt</fullName>
        <description>Updates the OHA Status when the OHA Exemption checkbox = TRUE</description>
        <field>OHA_Status__c</field>
        <literalValue>Exempt</literalValue>
        <name>OHA Status to EXEMPT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates>
        <fullName>OHA_Status_None</fullName>
        <description>Updates the OHA Statue to None when the OHA Exemption checkbox = FALSE</description>
        <field>OHA_Status__c</field>
        <name>OHA Status to NONE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates>
        <fullName>Populate_LSTM_No</fullName>
        <field>LSTM_No__c</field>
        <formula>Student__r.LSTM_No__c</formula>
        <name>Populate LSTM No</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Populates_LSTM_Email</fullName>
        <field>LSTM_Email__c</field>
        <formula>Student__r.LSTM_Email__c</formula>
        <name>Populates LSTM Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Populates_Personal_Email</fullName>
        <field>Personal_Email__c</field>
        <formula>Student__r.Personal_Email__c</formula>
        <name>Populates Personal Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>RA_Status_EXEMPT</fullName>
        <description>Updates the Risk Assessment Status to Exempt when RA Exemption checkbox = TRUE</description>
        <field>RA_Status__c</field>
        <literalValue>Exempt</literalValue>
        <name>RA Status to EXEMPT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates>
        <fullName>RA_Status_NONE</fullName>
        <description>Updates RA Status to None when RA Exemption checkbox = FALSE</description>
        <field>RA_Status__c</field>
        <name>RA Status to NONE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates>
        <fullName>RT_Masters_Registered</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Masters_Registered</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>RT=Masters Registered</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Reset_FA_Submission</fullName>
        <description>Reset to False to allow seemless re-trigger of FA Submission if required</description>
        <field>FA_Submission__c</field>
        <literalValue>0</literalValue>
        <name>Reset FA Submission</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Reset_Fee_Recalc</fullName>
        <field>Fee_Recalc__c</field>
        <literalValue>0</literalValue>
        <name>Reset Fee Recalc</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Set_AD_Expiry_Date</fullName>
        <field>Expiry_Date__c</field>
        <formula>IF( Programme_Type__c  = "MSc Programme",DATE(YEAR( Programme__r.End_Date__c ),MONTH(DATE(2001,12,31)),DAY(Date(2001,12,31))),IF(Programme_Code__c = "DTM&amp;H",Programme__r.End_Date__c +30,IF(Programme_Type__c = "Short Course",Programme__r.End_Date__c +15,NULL )))</formula>
        <name>Set AD Expiry Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Set_Stage_to_Reviewed</fullName>
        <field>Stage__c</field>
        <literalValue>Reviewed</literalValue>
        <name>Set Stage to Reviewed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Stage_to_Submitted_on_FA_Submission</fullName>
        <description>Changes Stage to Submitted</description>
        <field>Stage__c</field>
        <literalValue>Submitted</literalValue>
        <name>Stage to Submitted on FA Submission</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Stud_Prog_RT_Applied</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Applied</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Stud Prog RT=Applied</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Stud_Prog_RT_Completed</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Completed</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Stud Prog RT=Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Stud_Prog_RT_Pre_Registration</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Pre_Registration</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Stud Prog RT=Pre-Registration</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Stud_Prog_RT_Registered</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Registered</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Stud Prog RT=Non-Masters Registered</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Student_Registration</fullName>
        <field>Stage__c</field>
        <literalValue>Registered</literalValue>
        <name>Student Registration</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates>
        <fullName>Submission_Date</fullName>
        <field>Submission_Date__c</field>
        <formula>TODAY()</formula>
        <name>Submission Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>UpdateFee</fullName>
        <field>Amount__c</field>
        <formula>IF(ISPICKVAL(Fee_Status__c, 'Home/EU'), Programme__r.Home_EU_Fee__c, Programme__r.Overseas_Fee__c)</formula>
        <name>UpdateFee</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Fee</fullName>
        <field>Amount__c</field>
        <formula>IF (  Text(Fee_Status__c) = "Home/EU",  Programme__r.Home_EU_Fee__c , 
   IF (  Text (Fee_Status__c) = "Overseas",  Programme__r.Overseas_Fee__c ,
      IF ( Text (Fee_Status__c) = "", 
         IF (  EEAStudent__c  = TRUE, Programme__r.Home_EU_Fee__c, Programme__r.Overseas_Fee__c),
      -1)
   )
)</formula>
        <name>Update Fee</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Fee_Status_to_Home_EU</fullName>
        <field>Fee_Status__c</field>
        <literalValue>Home/EU</literalValue>
        <name>Update Fee Status to Home/EU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Fee_Status_to_Overseas</fullName>
        <field>Fee_Status__c</field>
        <literalValue>Overseas</literalValue>
        <name>Update Fee Status to Overseas</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Personal_email</fullName>
        <description>Takes email from Contact</description>
        <field>Personal_Email__c</field>
        <formula>Student__r.Email</formula>
        <name>Update Personal email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Stage_to_Checked</fullName>
        <description>Updates field to Checked when application is sent for approval
SE: added re-evaluate WF rules check to trigger RT workflows</description>
        <field>Stage__c</field>
        <literalValue>Checked</literalValue>
        <name>Update Stage to Checked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Stage_to_Reviewed</fullName>
        <description>Changes stage from Checked to Reviewed upon completion of the review process.
SE: added re-evaluate WF rules check to trigger RT workflows</description>
        <field>Stage__c</field>
        <literalValue>Reviewed</literalValue>
        <name>Update Stage to Reviewed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Student_Programme_Name</fullName>
        <field>Name</field>
        <formula>Student__r.LastName &amp; " - " &amp;  Programme__r.Code__c</formula>
        <name>Update Student Programme Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><rules>
        <fullName>Confirmation of Submission</fullName>
        <actions>
            <name>Confirmation_of_Submission_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Internal_Submission_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Submission_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Personal_email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Student_Programme__c.Stage__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <description>When applicant submits a valid application; to applicant and separate internal email. Also, date stamps submission</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Confirmation of Submission - Online</fullName>
        <actions>
            <name>Confirmation_of_Submission_Online</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Internal_Submission_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Submission_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Personal_email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Student_Programme__c.Stage__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Student_Programme__c.Programme_Type__c</field>
            <operation>equals</operation>
            <value>Closed Course,Online Course</value>
        </criteriaItems>
        <description>When applicant submits a valid application; to applicant and separate internal email. Also, date stamps submission</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Delete AD Account</fullName>
        <actions>
            <name>Delete_AD_Account</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Request_to_delete_AD_Account_sent</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Student_Programme__c.AD_Account__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Student_Programme__c.Stage__c</field>
            <operation>equals</operation>
            <value>Deferred,Withdrawn</value>
        </criteriaItems>
        <description>Email request to delete AD Account for any student where AD Account = YES and Student Programme Stage = DEFERRED or WITHDRAWN</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Entry Option</fullName>
        <active>false</active>
        <description>Checks whether Programme is MSc Programme. Action then sets Entry Award to MSc.</description>
        <formula>ISPICKVAL(Programme__r.Programme_Version__r.Programme_Type__c,"MSc Programme")</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>FA Submission</fullName>
        <actions>
            <name>Reset_FA_Submission</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Stage_to_Submitted_on_FA_Submission</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Student_Programme__c.FA_Submission__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>To change Stage to Submitted</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Fee Status Update - Home</fullName>
        <actions>
            <name>Update_Fee_Status_to_Home_EU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND (  ISPICKVAL(Fee_Status__c, "") = TRUE,  EEAStudent__c = TRUE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Fee Status Update - Overseas</fullName>
        <actions>
            <name>Update_Fee_Status_to_Overseas</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Modified to allow for initial state if when no Natonality is known, so does not default to Overseas (by mistake)</description>
        <formula>AND ( ISPICKVAL(Fee_Status__c, "") = TRUE, EEAStudent__c = FALSE, NOT ( ISBLANK ( Student__r.HESA_Nationality__c ) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Fee Update</fullName>
        <actions>
            <name>Reset_Fee_Recalc</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Fee</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Updates Student Programme from fee data on Programme
nb: Fee field has API name of Amount__c</description>
        <formula>OR ( ISNEW(),  ISNULL ( Amount__c ), ISCHANGED ( Fee_Status__c ), Fee_Recalc__c = TRUE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Force Student Programme Name</fullName>
        <actions>
            <name>Force_Student_Programme_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>For dataloaded records (eg for testing or paper applications)</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Internal Disability Notification</fullName>
        <actions>
            <name>Internal_Disability_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Internal disability notification when the Student Programme Stage = UNCONDITIONAL</description>
        <formula>AND( ISPICKVAL(Stage__c , "Unconditional") ,AND( NOT(ISPICKVAL(Disability__c , "No known disability")),LEN(TEXT(Disability__c))!=0))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>LSTM Email on Student Programme</fullName>
        <actions>
            <name>Populate_LSTM_No</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populates_LSTM_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populates_Personal_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates LSTM email &amp; No, Personal email on Student Programme if blank</description>
        <formula>ISBLANK (LSTM_Email__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>OHA Exemption %3D FALSE</fullName>
        <actions>
            <name>OHA_Status_None</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Student_Programme__c.OHA_Exemption__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Updates the OHA Status to None when OHA Exemption checkbox = FALSE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>OHA Exemption %3D TRUE</fullName>
        <actions>
            <name>OHA_Status_Exempt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Student_Programme__c.OHA_Exemption__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Updates the OHA Status to Exempt when OHA Exemption checkbox = TRUE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>PCU Online Payment with Academic Credit</fullName>
        <actions>
            <name>Send_Online_Payment_with_Academic_Credit_email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Online_Payment_AC_Sent</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Send out Online Payment email when Programme Type = Short Course, Professional Programme or Masters Modules, Academic Credit is equal to YES and Payment Status= Requested.</description>
        <formula>AND(TEXT ( Payment_Status__c ) = "Fee Requested",   OR(Programme_Type__c = "Short Course", Programme_Type__c = "Professional Diploma", Programme_Type__c = "Masters Module"),  academic_credit__c  = TRUE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>PCU Online Payment without Academic Credit</fullName>
        <actions>
            <name>Send_Online_Payment_email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Online_Payment_Sent</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Send out Online Payment email when Programme Type = Short Course, Professional Programme or Masters Modules, Academic Credit is not equal to YES and Payment Status= Requested.</description>
        <formula>AND(TEXT ( Payment_Status__c ) = "Fee Requested",   OR(Programme_Type__c = "Short Course", Programme_Type__c = "Professional Diploma", Programme_Type__c = "Masters Module"),  academic_credit__c  &lt;&gt; TRUE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Paper Apps Import</fullName>
        <actions>
            <name>Update_Student_Programme_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Only to be made Active when paper applications are being imported - SO LEAVE INACTIVE OTHERWISE (in case of code coverage impact)</description>
        <formula>LEFT( Name , 3) = "a0B"</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Pre-Reg Invitation</fullName>
        <actions>
            <name>Invitation_to_Pre_Register</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Pre_Registration_Invite_Sent</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Send out email to applicant to invite them to Pre-Register. Initially limited to DTN May 15 only applicants</description>
        <formula>AND (  TEXT (Stage__c) = "Expected",  Programme__r.Name = "Diploma in Tropical Nursing - May 15")</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Pre-Registration Confirmation</fullName>
        <actions>
            <name>INTERNAL_Pre_Reg_Completed</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Pre_Registration_Confirmation</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Pre_Registration_LSTM_Password</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Check_Pre_Registration_Details</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>Pre_Registration_Confirmation</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Email to applicant when confirmed user login details; restricted to DTN May 15 programme for pilot</description>
        <formula>AND ( TEXT (Stage__c) = "Pre-Registered", Programme__r.Name = "Diploma in Tropical Nursing - May 15")</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Pre-Registration Invitation %28MSc%29</fullName>
        <actions>
            <name>Invitation_to_Pre_Register_MSc</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_MSc_Pre_Registration_Invite_Sent</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Send out Invitation to Pre-Register email to MSc students when their Student Programme Stage = Expected.</description>
        <formula>AND(TEXT (Stage__c) = "Expected",  ISPICKVAL( AD_Account__c, "Yes"), Programme_Type__c = "MSc Programme" )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Pre-Registration Invitation %28PCU%29</fullName>
        <actions>
            <name>Invitation_to_Pre_Register</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Pre_Registration_Invite_Sent</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Send out email to PCU students (September 2015) to invite them to Pre-Register when their Student Programme Stage = Expected.</description>
        <formula>AND(TEXT (Stage__c) = "Expected",ISPICKVAL( AD_Account__c, "Yes"),   OR(Programme_Type__c = "Professional Diploma",Programme_Type__c = "Short Course",Programme_Type__c = "Masters Module"))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Pre-Registration Reminder</fullName>
        <actions>
            <name>LSTM_Reminder_Please_Upload_a_Photograph</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Student_Programme__c.Stage__c</field>
            <operation>equals</operation>
            <value>Pre-Registered</value>
        </criteriaItems>
        <criteriaItems>
            <field>Student_Programme__c.Photo_Check__c</field>
            <operation>equals</operation>
            <value>N</value>
        </criteriaItems>
        <description>Email to remind students to complete online Pre-Registration.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules><rules>
        <fullName>RA Status %3D FALSE</fullName>
        <actions>
            <name>RA_Status_NONE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Student_Programme__c.RA_Exemption__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Updates the RA Status to Exempt when RA Exemption checkbox = TRUE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>RA Status %3D TRUE</fullName>
        <actions>
            <name>RA_Status_EXEMPT</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Student_Programme__c.RA_Exemption__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Updates the RA Status to Exempt when RA Exemption checkbox = TRUE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Set Stage to Reviewed - PGR %2F SAF Submitted</fullName>
        <actions>
            <name>Set_Stage_to_Reviewed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Student_Programme__c.SAF_Submitted__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Student_Programme__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PGR Application</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Stud Prog RT%3DApplied</fullName>
        <actions>
            <name>Stud_Prog_RT_Applied</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>OR ( Text ( Stage__c ) = "Submitted", Text ( Stage__c ) = "Submitted")</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Stud Prog RT%3DChecked</fullName>
        <actions>
            <name>Application_RT_Checked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>OR ( TEXT( Stage__c )= "Checked", TEXT ( Stage__c) = "Reviewed", TEXT ( Stage__c) = "Conditional", TEXT ( Stage__c) = "Unconditional", TEXT ( Stage__c) = "Reject", TEXT ( Stage__c) = "Accepted")</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Stud Prog RT%3DCompleted</fullName>
        <actions>
            <name>Stud_Prog_RT_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>Text( Stage__c) = "Completed"</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Stud Prog RT%3DMasters Registered</fullName>
        <actions>
            <name>RT_Masters_Registered</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISPICKVAL(Programme__r.Programme_Version__r.Programme_Type__c,"MSc Programme"), TEXT ( Stage__c ) = "Registered")</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Stud Prog RT%3DNon-Masters Registered</fullName>
        <actions>
            <name>Stud_Prog_RT_Registered</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(NOT(ISPICKVAL(Programme__r.Programme_Version__r.Programme_Type__c,"MSc Programme")), TEXT ( Stage__c ) = "Registered")</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Stud Prog RT%3DPre-Registration</fullName>
        <actions>
            <name>Stud_Prog_RT_Pre_Registration</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>For Stage = Expected or Pre-registered</description>
        <formula>OR (TEXT ( Stage__c ) = "Expected", TEXT ( Stage__c ) = "Pre-Registered")</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Stud Prog RT%3DRegistered</fullName>
        <actions>
            <name>Stud_Prog_RT_Registered</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>TEXT ( Stage__c ) = "Registered"</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Student Registration</fullName>
        <actions>
            <name>Student_Registration</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Student_Programme__c.Identification_Check__c</field>
            <operation>equals</operation>
            <value>Verified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Student_Programme__c.Immigration_Check__c</field>
            <operation>equals</operation>
            <value>Verified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Student_Programme__c.Tuition_Fee_Check__c</field>
            <operation>notEqual</operation>
            <value>Unpaid</value>
        </criteriaItems>
        <criteriaItems>
            <field>Student_Programme__c.Verification_User__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Updates Student Programme Stage to Registered if ID &amp; Immigration is Verified &amp; Tuition Fee is not Unpaid.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><tasks>
        <fullName>Application_Reviewed</fullName>
        <assignedToType>owner</assignedToType>
        <description>The following application has been reviewed.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Application Reviewed</subject>
    </tasks><tasks>
        <fullName>Check_Pre_Registration_Details</fullName>
        <assignedToType>owner</assignedToType>
        <description>Set task to Registry staff to check pre-registration details provided by student</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Check Pre-Registration Details</subject>
    </tasks><tasks>
        <fullName>Email_MSc_Pre_Registration_Invite_Sent</fullName>
        <assignedToType>owner</assignedToType>
        <description>To provide on confirmation on Student Programme that this email was sent by workflow</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Email: MSc Pre-Registration Invite Sent</subject>
    </tasks><tasks>
        <fullName>Email_Online_Payment_AC_Sent</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Email: Online Payment with Academic Credit Sent</subject>
    </tasks><tasks>
        <fullName>Email_Online_Payment_Sent</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Email: Online Payment Sent</subject>
    </tasks><tasks>
        <fullName>Email_Pre_Registration_Invite_Sent</fullName>
        <assignedTo>sue.assinder@lstmed.ac.uk</assignedTo>
        <assignedToType>user</assignedToType>
        <description>To provide on confirmation on Student Programme that this email was sent by workflow</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Email: Pre-Registration Invite Sent</subject>
    </tasks><tasks>
        <fullName>Pre_Registration_Confirmation</fullName>
        <assignedToType>owner</assignedToType>
        <description>To provide confirmation on Student Programme that this email was sent by workflow</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Email: Pre-Registration Confirmation Sent</subject>
    </tasks><tasks>
        <fullName>Reject_Email_Sent</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Email: Reject Sent</subject>
    </tasks><tasks>
        <fullName>Request_to_delete_AD_Account_sent</fullName>
        <assignedTo>magenta.uatlstm@colorconsultancy.co.uk</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Request to delete AD Account sent</subject>
    </tasks></Workflow>