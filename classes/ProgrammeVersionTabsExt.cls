/*
*
* 2015-03-02 : SM : Controller extension for the ProgrammeVersionTabs VF Page
*
*/
public class ProgrammeVersionTabsExt {
    public List<Programme_Aim__c> aimList {get; set;}
    public List<Learning_Outcome__c> outcomeList {get; set;}
    public List<Skills_Attributes__c> skillsList {get; set;}

    public ProgrammeVersionTabsExt(ApexPages.StandardController std){
        Id progId = std.getId();
        
        String aimQuery = 'SELECT ';
        for(Schema.FieldSetMember f : SObjectType.Programme_Aim__c.FieldSets.Aims.getFields()) {
            aimQuery += f.getFieldPath() + ', ';
        }
        
        aimQuery += 'Id from Programme_Aim__c where Programme_Version__c = :progId ORDER BY Record_No__c ASC';
                
        aimList = Database.query(aimQuery);
        
        String outcomeQuery = 'SELECT ';
        
        for(Schema.FieldSetMember f : SObjectType.Learning_Outcome__c.FieldSets.Outcomes.getFields()) {
            outcomeQuery += f.getFieldPath() + ', ';
        }
        
        outcomeQuery += 'Id from Learning_Outcome__c where Programme_Version__c = :progId ORDER BY Record_No__c ASC';
                
        outcomeList = Database.query(outcomeQuery);
        
        String skillsQuery = 'SELECT ';
        
        for(Schema.FieldSetMember f : SObjectType.Skills_Attributes__c.FieldSets.Skills.getFields()) {
            skillsQuery += f.getFieldPath() + ', ';
        }
        
        skillsQuery += 'Id from Skills_Attributes__c where Programme_Version__c = :progId ORDER BY Record_No__c ASC';
                
        skillsList = Database.query(skillsQuery);
        
        
        
    }

}