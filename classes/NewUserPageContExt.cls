public class NewUserPageContExt {


    public final String PAGE_COPY_LOCATION = 'New User Information';
    public final String ACTIVE_STATUS = 'Active';
    public final String EMAIL_DOMAIN = '@lstmed.ac.uk';
    public final integer PASSWORD_LENGTH = 8;

    public Contact student {get; set;}
    public Student_Programme__c sp {get; set;}
    public Page_Copy__c pageCopy {get; set;}
    public boolean saveContact {get; set;}
    public boolean saveProgramme {get; set;}
    public String displayPassword {get; set;}
    public String lstmEmail {get; set;}
    
    public NewUserPageContExt(){
        saveContact = false; 
        saveProgramme = false;
        
        Id spId = ApexPages.currentPage().getParameters().get('Id');
        if (spId != null){
        //Suyati modified code for 6.1
            sp = [select s.Id, s.Stage__c, s.Student__c, s.Student__r.LSTM_No__c,
                    s.Student__r.Registration_Password__c from Student_Programme__c s where s.Id = :spId LIMIT 1];
            //old code  
            /* sp = [select s.Id, s.Stage__c, s.Student__c, s.Student__r.LSTM_No__c
                     from Student_Programme__c s where s.Id = :spId LIMIT 1]; */                 
           student = [select c.Id, c.LSTM_No__c,c.Registration_Password__c from Contact c where c.Id = :sp.Student__c LIMIT 1];
          //old code    
          //student = [select c.Id, c.LSTM_No__c from Contact c where c.Id = :sp.Student__c LIMIT 1]; 
          //Suyati modified code ends for 6.1
           if (student.Registration_Password__c == null){       
                displayPassword = getPassword(PASSWORD_LENGTH);
                //Encrypted commented by .suyati
               // student.LSTM_Temp_Password__c = displayPassword;
                //Unencrypted .changed name tp to  Registration_Password__c
               student.Registration_Password__c = displayPassword;
                saveContact = true;
            }else {
                //commented for 6.1 by suyati chhnaged name tp to Registration_Password__c 
                //displayPassword = sp.Student__r.LSTM_Temp_Password__c;
                displayPassword = student.Registration_Password__c ;
            }
            
            if (student.LSTM_No__c != null){
                integer intLSTMNo = integer.valueOf(student.LSTM_No__c);
                String strLSTMNo = intLSTMNO.format().replace(',','');
                lstmEmail = strLSTMNO + EMAIL_DOMAIN;
            }else {
                lstmEmail = 'NO LSTM NUMBER FOUND';
            }
            
        }
        
        pageCopy = [select p.Id, p.Body_Copy__c from Page_Copy__c p 
                    where p.Copy_Location__c = :PAGE_COPY_LOCATION and p.Page_Status__c = :ACTIVE_STATUS
                    ORDER BY Active_Date__c DESC LIMIT 1];
    
    }
    
    public PageReference gotoHomePage() {
        //return new PageReference('/');
        return Page.StudentLandingPage;
    }
    
    public PageReference confirmDetails(){
        if (saveContact){
            update student;
        }
        if (!ApplyServices.COURSE_PRE_REGISTERED_STAGE_NAME.equalsIgnoreCase(sp.Stage__c)){
            sp.Stage__c = ApplyServices.COURSE_PRE_REGISTERED_STAGE_NAME;    
            saveProgramme = true;
        }
            
        if (saveProgramme){
            update sp;
        }
        
        return gotoHomePage();
    }
    
    public String getPassword(Integer len)
     {
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        System.debug('*** -- Key from getPassword = ' + key + ' -- ***');
        return key.substring(0,len);
     }

}