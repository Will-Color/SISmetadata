/* tgrUpdateWebtoCase Created by maneesh on 22-jun-15 */
/// <summary> This Trigger Used to update Programe_version__c relationship based on the name inserted by user when case creating </summary>
/// <param name="NewPgrmVersion "> Used to store the matching Programme versions inserted programme name and updating programme__c  </param>
/*Modifications*/
///Author Manu K M on  15-Oct-15 for Amendment to A7 Per Programme Enquiries
///<summary>Removed use of realtion to programme and included new relationship to programme_version
///trigger modified to create relationship with programme version based on the selected master programme version name
///</summary>
trigger tgrUpdateWebtoCase on Case (After insert) {
     //Collecting all the cases from trigger.new
     List<Case> lstCases = [Select Programme_Version__c,Programme_Version_Name__c, Origin  from Case where id IN: trigger.new ];
     for(case c : lstCases)
     {              
        if(c.origin=='Web' && c.Programme_Version_Name__c !=null )
        {  
            try{
                //Finding the Programme versions matching inserted programme version name and updating programme_version__c          
               Programme_Version__c NewPgrmVersion = new Programme_Version__c();
               NewPgrmVersion =  [Select Id,Name from Programme_Version__c where name =: c.Programme_Version_Name__c and Master_Link__c = null and RecordType.name = 'Master version' Limit 1 ];
               if(NewPgrmVersion != null){           
                   c.Programme_Version__c = NewPgrmVersion .id;                       
               }
             }  
             catch( QueryException e){
                 system.debug(e);
             }      
        }
    }        
    update lstCases ;     
}