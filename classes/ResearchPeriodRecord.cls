/*
 * Created on : 13/06/2017
 * Suyati
 * Desc : Class will handle the Student Programme Visualforce page for 'Register PGR Student'
 * Suyati Modified : 22/06/2017
*/
public Without Sharing class ResearchPeriodRecord
{ 
    public string studentId;
    public Date dat {get;set;}
    public Date enddat {get;set;}
    public Integer num{get;set;}
    public Integer Snum{get;set;}
    public Boolean second{get;set;}
    public Boolean check{get;set;}
    public Student_Programme__c Student{get;set;}
    public List<Supervision__c> Supervision{get;set;}
    public List<wrapper> superList{get;set;}
    Research_Period__c Research;
    public List<Supervision__c > ListSupervisor;
    public boolean WeightingError{get;set;}
    Public Id periodId;
    PageReference pr;
    Map<Id, Supervision__c> SupervisionMap = new Map<Id, Supervision__c>();
    
    public ResearchPeriodRecord(ApexPages.StandardController controller)
    {
        decimal period=0;
        Id highestWeight;
        Integer sameWeight=0;
        WeightingError=false;
        Supervision = new List<Supervision__c>();
        superList=new List<wrapper>();
        second= false;
        check= true;
        Decimal weight=0;
        Decimal weightOld=0;
        ListSupervisor =new List<Supervision__c >();
        
        // Calculate period start date
        datetime myDate = date.today(); 
        String formatted1 = myDate.formatGMT('EEEEEEE');
        datetime nextmonth=mydate.addmonths(1);
        date firstDate = date.valueof(nextmonth).toStartOfMonth();
        
        dat = firstDate; //system.today(); 
        datetime endDate = firstDate.addYears(1)-1;
        enddat =  date.valueof(endDate);
        num =1;
        studentId= ApexPages.currentPage().getParameters().get('id');
        system.debug('student++++++++++++++++++++++++++++++++++'+studentId); 
        Student= [select id,Name,Mode_of_Study__c,Programme_Start_Date__c,Programme_End_Date__c,Programme_Length__c,Status__c,(Select id, Previous_Period__c,Period_Number__c from Research_Periods__r ) from  Student_Programme__c  where id =:studentId]; 
        for(Research_Period__c research : Student.Research_Periods__r)
        {
            if(research.Period_Number__c > period)
            {
                period=research.Period_Number__c;
                periodId =research.Id;
                system.debug('periodId'+periodId);                
            }
        }
        ListSupervisor = [select id,Name,Supervisor_Weighting__c,Primary_Supervisor__c,Supervisor__r.name from  Supervision__c where Student_Programme__c =:studentId and Research_Period__c=:periodId ];   
        
        for(Supervision__c superv: ListSupervisor)
        { 
            system.debug('superv'+superv.Supervisor_Weighting__c);
            if(superv.Supervisor_Weighting__c > weight)
            {  
                weight=superv.Supervisor_Weighting__c;                
                highestWeight=superv.Id;
            }
            if(superv.Supervisor_Weighting__c==weightOld)
            {
                sameWeight=sameWeight+1;
            }
            superList.add(new wrapper(superv.id,true,superv.Supervisor__r.name,superv.Supervisor_Weighting__c,superv.Primary_Supervisor__c));
            weightOld=superv.Supervisor_Weighting__c;
        }
        for(wrapper listElement: superList)
        {
            
            if(listElement.RecordId==highestWeight && sameWeight!=ListSupervisor.size()-1)
            {
                listElement.Primary=true;
            }
            else
            {
                listElement.Primary=false;
            }
        }
        
    }
    public PageReference UpdateData()
    {
        
        second= true;
        system.debug('number'+num);
        //count = count+1;
        String Periodname = Student.Name + 'Period';
        system.debug('studentId'+studentId);        
        system.debug('periodId'+periodId);
        Id devRecordTypeId = Schema.SObjectType.Research_Period__c.getRecordTypeInfosByName().get(Student.Mode_of_Study__c).getRecordTypeId();
        system.debug('devRecordTypeId '+devRecordTypeId );
        Research = new Research_Period__c(Name= Periodname ,Active__c=true, Student_Programme__c=studentId,Previous_Period__c=periodId, Period_Number__c=num, Period_Start_Date__c= dat ,Period_End_Date__c=enddat,Required_Supervisory_Meetings__c=Snum  );
        Research.RecordTypeId = devRecordTypeId;      
        insert Research;
        update Student;
        return null;
        
    }
    
    public PageReference SaveData()
    {
        set<Supervision__c> lstSupervisor=new set<Supervision__c>();
        List<Supervision__c > setSupervisor = new List<Supervision__c >();
        List<Supervision__c > listToUpdate = new List<Supervision__c >();
        List<Supervision__c > Li= new List<Supervision__c >();
        List<Supervision__c > DuplicateSupervisor= new List<Supervision__c >();
        set<Supervision__c> St=new set<Supervision__c>();
        decimal count=0;
        boolean save=true;
        decimal primaryWt;
        decimal weightValue=0;
        integer prim =0;
        system.debug('ListSupervisor%%%%%%%% '+ListSupervisor );
        for(wrapper a: superList )
        {
           if(a.Weight > weightValue && a.checked==true) 
           {
               weightValue =a.Weight;
           }
           if(a.Primary == true && a.checked==true)
           {
               primaryWt=a.Weight;               
           }
           if(a.Primary == true && a.checked!=true)
           {
               save=false;
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Primary Supervisor must be one of the selected Supervisors'));
           }
        }
        for(wrapper a: superList)
        {
            if(a.checked==true)
            {
                count=count+a.weight;              
                for(Supervision__c superv: ListSupervisor )
                {
                    if(a.RecordId==superv.id)
                    {  
                        if(a.Weight!=null && a.Weight==weightValue && primaryWt!=a.Weight && a.Primary!=true)
                        {                            
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'The Primary Supervisor must have the highest supervision weighting'));
                            save=false;
                        }
                        else if(a.Weight!=null)
                        {
                            superv.Primary_Supervisor__c=a.Primary;
                        }
                        
                        superv.Supervisor_Weighting__c=a.Weight;
                        //superv.Research_Period__c=Research.id;
                    }                    
                    lstSupervisor.add(superv);  
                }
            }
        }
        for(Supervision__c newSupervision : lstSupervisor) {
            SupervisionMap.put(newSupervision.Id,newSupervision);
        }
        system.debug('lstSupervisorSize'+lstSupervisor.size());
        if(count!=100)
        {
            save=false;
            WeightingError=true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Total weighting for all selected Supervisors must be 100%'));
        }
        else if(save==true)
        {  
            system.debug('SupervisionMap'+ SupervisionMap);
            Student.Stage__c='Registered';
            system.debug('+++++++++++++++++***'+Student.Stage__c);
            update Student;
            update SupervisionMap.values();
            System.debug('SupervisionMap'+SupervisionMap);
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            pr = new PageReference(baseUrl +'/'+ Research.id);
            pr.setRedirect(true);          
  
            
            for(wrapper a: superList)
            {      
                if(a.checked==true)
                {
                    for(Supervision__c supervision: ListSupervisor )
                    {
                        if(a.RecordId==supervision.id )
                        {
                            Supervision__c s = new Supervision__c ();
                            s.Name=supervision.Name;
                            s.Supervisor__c=supervision.Supervisor__c;
                            s.Supervisor_Weighting__c=supervision.Supervisor_Weighting__c;
                            s.Primary_Supervisor__c=supervision.Primary_Supervisor__c;                
                            s.Research_Period__c=Research.id;    
                            s.Student_Programme__c=Student.Id;
                            DuplicateSupervisor.add(s);
                        }
                    }
                }
            }
            insert DuplicateSupervisor;
            system.debug('listToUpdate'+listToUpdate);
            system.debug('DuplicateSupervisor'+DuplicateSupervisor);
        }
        return pr;
    }
    
    public PageReference Cancel()
    {
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        pr = new PageReference(baseUrl +'/'+ Student.id);
        //pr = new PageReference(Label.RedirectToResearch + Student.id);
        pr.setRedirect(true);
        return pr;
    }
    
    /* Wrapper for holding VF page data */
    public class wrapper
    {
        public Id RecordId{get;set;}
        public Boolean checked{get;set;}
        public string  Name{get;set;}
        public Boolean Primary{get;set;}  
        public decimal Weight{get;set;}    
        
        public wrapper(Id r,Boolean c,string n,decimal W,Boolean p)
        {
            RecordId=r;
            checked = c;
            Name = n;
            Weight=w;
            Primary = p;
        }    
    }
}