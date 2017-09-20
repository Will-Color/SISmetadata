public class ProvisionTriggerMethods
{
    public static boolean run = true;
    public void insertPassword(List<Provision__c> provisionList)
    {  
        String passwordStr;
        Set<Id> studentIds = new Set<Id>();
        List<Provision__c > ProvisionList1=new List<Provision__c >();
        for(Provision__c provision : provisionList)
        {
            Provision__c provisionOb = new Provision__c (Id=provision.Id);
            if(String.isBlank(provisionOb.Password__c))
            {
                passwordStr = getPassword();
                provisionOb.Password__c = passwordStr;
                
            } 
            if(provision.Expiry_Date__c > system.today()) 
            {
            provisionOb.Active__c = true;
            }
            system.debug('provisionOb'+provisionOb);
            
            ProvisionList1.add(provisionOb);
            
            studentIds.add( provision.Student_Staff__c);          
        }
        update ProvisionList1;
        
        system.debug('studentIds'+ProvisionList1);
        List<Contact> studentList = [SELECT Registration_Password__c, Name, Id, ContactId__c FROM Contact WHERE Id IN: studentIds]; 
        for(Contact std : studentList)
        { 
            std.Registration_Password__c = passwordStr;
        }
        update studentList;
    }
    
    public void removePassword(List<Provision__c> currentProvision){
        
        Set<String> stdStaff = new Set<String>();
        Map<id,List<DateTime>> stdMap = new Map<id,List<DateTime>>();
        Map<id,Contact> studentStaff= new Map<id,Contact>();
        Set<contact> ContactUpdate=new Set<contact>();
        
        Map<Id,List<Provision__c>> newStdMap = new Map<Id,List<Provision__c>>();
        for(Provision__c prs : currentProvision){
            stdStaff.add(prs.Student_Staff__c);
            if(newStdMap.containsKey(prs.Student_Staff__c))
            {   
                newStdMap.get(prs.Student_Staff__c).add(prs);  
            }
            else 
            {   
                newStdMap.put(prs.Student_Staff__c,new list<Provision__c>{prs}); 
            }
        }
        
        List<Contact> studentList = [SELECT Registration_Password__c, Name, Id, ContactId__c FROM Contact WHERE Id in: stdStaff];
        for(Contact Contacts :studentList)
        {
            studentStaff.put(Contacts.Id,Contacts);
        }
        List<Provision__c> groupedResults = [SELECT  Student_Staff__c, CreatedDate FROM Provision__c WHERE Student_Staff__c IN: stdStaff ORDER BY createdDate DESC];
        
        for(Provision__c pttt : groupedResults){
            
            if(stdMap.containsKey(pttt.Student_Staff__c))
            {   
                stdMap.get(pttt.Student_Staff__c).add(pttt.CreatedDate);  
            }
            else 
            {   
                stdMap.put(pttt.Student_Staff__c,new list<DateTime>{pttt.CreatedDate}); 
            }
            
            
        }
        for(id stdPrgid:newStdMap.keyset())
        {
            if(newStdMap.get(stdPrgid)!=null)
            {
                List<Provision__c>  provisionList= newStdMap.get(stdPrgid);
                Set<DateTime> provLastDate = new Set<DateTime>();
                List<DateTime> provDateList = new List<DateTime>();
                for(Provision__c provisDateFilter: provisionList)
                {
                    provLastDate.add(provisDateFilter.CreatedDate);
                }
                provDateList.addAll(provLastDate);
                
                provDateList.sort();
                
                if(provDateList[provDateList.size()-1] >= stdMap.get(stdPrgid)[0]){
                    studentStaff.get(stdPrgid).Registration_Password__c='';
                    ContactUpdate.add(studentStaff.get(stdPrgid));
                }
            }
            
        }
        List<contact> test= new List<contact>();
        test.addAll(ContactUpdate);
        update test;
        
    }
    
    public void populateLastPass(List<Provision__c> undeletedProvision){
        
        system.debug('Populate');
        Set<String> stdStaff = new Set<String>();
        Set<String> provisnID = new Set<String>();
        Map<id,List<DateTime>> stdMap = new Map<id,List<DateTime>>();
        Map<id,Contact> studentStaff= new Map<id,Contact>();
        List<contact> ContactForUpdate = new List<contact>();
        for(Provision__c prs : undeletedProvision){
            provisnID.add(prs.id);
        }
        
        Map<Id,List<Provision__c>> newStdMap = new Map<Id,List<Provision__c>>();
        List<Provision__c> undeletedProvisionList =[Select id,Student_Staff__c,CreatedDate,Password__c from Provision__c where id in:provisnID ORDER BY createdDate DESC ];
        for(Provision__c prs : undeletedProvisionList){
            stdStaff.add(prs.Student_Staff__c);
            if(newStdMap.containsKey(prs.Student_Staff__c))
            {   
                newStdMap.get(prs.Student_Staff__c).add(prs);  
            }
            else 
            {   
                newStdMap.put(prs.Student_Staff__c,new list<Provision__c>{prs}); 
            }
        }
        List<Contact> studentList = [SELECT Registration_Password__c, Name, Id, ContactId__c FROM Contact WHERE Id in: stdStaff];
        for(Contact Contacts :studentList)
        {
            studentStaff.put(Contacts.Id,Contacts);
        }
        List<Provision__c> groupedResults = [SELECT  Student_Staff__c, CreatedDate FROM Provision__c WHERE Student_Staff__c IN: stdStaff ORDER BY createdDate DESC];
        for(Provision__c pttt : groupedResults){
            
            if(stdMap.containsKey(pttt.Student_Staff__c))
            {   
                stdMap.get(pttt.Student_Staff__c).add(pttt.CreatedDate);  
            }
            else 
            {   
                stdMap.put(pttt.Student_Staff__c,new list<DateTime>{pttt.CreatedDate}); 
            }
        }
        system.debug('newStdMap'+newStdMap);
        for(id stdPrgid : newStdMap.keyset())
        {
            if(newStdMap.get(stdPrgid)!=null)
            {
                List<Provision__c>  provisionList= newStdMap.get(stdPrgid);
                if(provisionList[0].CreatedDate>=stdMap.get(stdPrgid)[0])
                {
                    studentStaff.get(stdPrgid).Registration_Password__c=provisionList[0].Password__c;
                    ContactForUpdate.add(studentStaff.get(stdPrgid));
                }
                
            }
        }
        
        List<contact> test= new List<contact>();
        
        test.addAll(ContactForUpdate);
        
        if(ContactForUpdate.size()==test.size()) 
            update test;
        
    }
    
    public String getPassword()
    {
        List<PasswordPrefixes__c> prefixesList = PasswordPrefixes__c.getall().values();
        PasswordPrefixes__c prefix = PasswordPrefixes__c.getInstance(getWordIndex(prefixesList.size()));  
        system.debug('prefixesList.size()'+getWordIndex(prefixesList.size()));
        system.debug('The passsword Prefixx'+prefix);
        String password = prefix.Word__c + getrandomNumber();
        return password;    
    }
    
    public String getrandomNumber()
    {
        integer randomNum = (integer)(Math.random()*9000)+1000;
        return String.valueOf(randomNum);
    }
    
    public String getWordIndex(Integer max)
    {
        integer random = (integer )(Math.random() * max + 1);
        String randomString;
        
        if(random < 10){
            randomString = '0000' + String.valueOf(random); 
        }
        
        else if(random < 100){
            randomString = '000' + String.valueOf(random);
        }
        
        else{
            randomString = '00' + String.valueOf(random);
        }
        
        return randomString;
    }  
    
    public void setADAccountValue(List<Provision__c> prov,List<Provision__c> Oldprov){
        

        Set<Id> studentProgList = new Set<Id>();
        Set<Id> childProvs = new Set<Id>();
        List<Student_Programme__c> ListStudentPgm =new List<Student_Programme__c>();
        List<Provision__c > ListProvision =new List<Provision__c >();
        Boolean flag= false;
        Set<Id> TriggerSet= new Set<Id>();
        
        if(prov!=null)
        {
            system.debug('Enters New list');
            for(Provision__c provis : prov)
            {
                studentProgList.add(provis.Student_Programme__c);            
            }
        }
        
        if(Oldprov!=null)
            {
                
                for(Provision__c provisOld : Oldprov)
                {                    
                    studentProgList.add(provisOld.Student_Programme__c);
                    TriggerSet.add(provisOld.id);                    
                }
                
            }
      for(Provision__c provList: [Select Id, AD_Account_Created_Updated__c,Expiry_Date__c, Active__c, Student_Programme__c from Provision__c where Student_Programme__c IN: studentProgList]){
            childProvs.add(provList.Id);
       }
       
        
        for(Student_Programme__c studentProgs : [Select Id, AD_Account__c, (Select Id, Active__c,Expiry_Date__c, AD_Account_Created_Updated__c from Student_Programme__r) from Student_Programme__c where Id IN: studentProgList])
        {
        
        system.debug('studentProgs'+studentProgs); 
         
         for(Provision__c ProvisionObj :studentProgs.Student_Programme__r)
         {
             
             system.debug('ProvisionObjId'+ProvisionObj.Id); 
             if((ProvisionObj.Expiry_Date__c>system.today() && ProvisionObj.AD_Account_Created_Updated__c=='Yes' && prov!=null) || (ProvisionObj.Expiry_Date__c>system.today() && ProvisionObj.AD_Account_Created_Updated__c=='Yes' && prov==null && !TriggerSet.contains(ProvisionObj.id)) )             
             {
                 //ProvisionObj.Active__c=true;
                 flag=true;
             }
             ListProvision.add(ProvisionObj);
             
         } 
         system.debug('flag '+flag); 
        if(flag==true)
        {
          system.debug('Enters true condition '+flag);  
          studentProgs.AD_Account__c='Yes'; 
          system.debug('studentProgs'+studentProgs); 
        }
        else
        {
            studentProgs.AD_Account__c='No';
        } 
        ListStudentPgm.add(studentProgs);
        
        
        }
        update ListStudentPgm ; 
   
    }
    
    public void UpdateActive(List<Provision__c> prov)
    {
        List<Provision__c > ProvisonList = new List<Provision__c >();
        if(run)
        {
            for(Provision__c provision : prov)
            {
                Provision__c provisionOb = new Provision__c(id=provision.id);
                if(provision.Expiry_Date__c > system.today())
                {
                    provisionOb.Active__c=true;
                }
                else
                {
                    provisionOb.Active__c=false;
                }
            ProvisonList.add(provisionOb);            
            }
            run = false;
            update ProvisonList;
            
        }
        
    
    }    
    
    
}