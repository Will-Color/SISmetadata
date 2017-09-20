public class FormAssemblyLookups{

    @InvocableMethod
    public static void buildLookups(List<Student_Programme__c> spList) {
        Set<Id> studentIds = new Set<Id>();
        Set<String> domicileNames = new Set<String>();
        Set<Id> spIds = new Set<Id>();
        Set<String> nationalityNames = new Set<String>();
        Set<String> feeNames = new Set<String>();        
        Map<String,Id> domicileMap = new Map<String,Id>();
        Map<String,Id> nationalityMap = new Map<String,Id>();
        Map<String,Id> feeMap = new Map<String,Id>();                        
        
        for(Student_Programme__c sp: spList){
            studentIds.add(sp.Student__c);
            feeNames.add(sp.MSTUFEE_FA__c);
            spIds.add(sp.Id);                            
        }
        
        for(Contact student: [SELECT Id,Domicile__c, HESA_Domicile__c, Nationality__c, HESA_Nationality__c FROM Contact WHERE Id IN: studentIds]){
            domicileNames.add(student.Domicile__c);
            nationalityNames.add(student.Nationality__c);
        }   
        
        for(HESA_Code__c hesaCode : [SELECT Id,Name,RecordTypeId FROM HESA_Code__c WHERE Active__c = true AND (Name IN: domicileNames OR Name IN: nationalityNames OR Name IN: feeNames) ]){
            Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.HESA_Code__c.getRecordTypeInfosById();
            if(rtMap.get(hesaCode.RecordTypeId).getName().containsIgnoreCase('Domicile') && domicileNames.contains(hesaCode.Name))  
                domicileMap.put(hesaCode.Name,hesaCode.Id);
            if(rtMap.get(hesaCode.RecordTypeId).getName().containsIgnoreCase('Nationality') && nationalityNames.contains(hesaCode.Name))
                nationalityMap.put(hesaCode.Name,hesaCode.Id); 
            if(rtMap.get(hesaCode.RecordTypeId).getName().containsIgnoreCase('MSTUFEE') && feeNames.contains(hesaCode.Name))
                feeMap.put(hesaCode.Name,hesaCode.Id);                 
        }
        system.debug(nationalityMap);

        List<Contact> studentsToUpdate = new List<Contact>();
        for(Contact student: [SELECT Id,Domicile__c, HESA_Domicile__c, Nationality__c, HESA_Nationality__c FROM Contact WHERE Id IN: studentIds]){
            if(domicileMap.containsKey(student.Domicile__c))
                student.HESA_Domicile__c = domicileMap.get(student.Domicile__c);
            if(nationalityMap.containsKey(student.Nationality__c))
                student.HESA_Nationality__c = nationalityMap.get(student.Nationality__c); 
            
            studentsToUpdate.add(student); 
        }

        update studentsToUpdate;
        
        List<Student_Programme__c> spsToUpdate = new List<Student_Programme__c>();
        for(Student_Programme__c sp: [SELECT MSTUFEE_FA__c, Major_source_of_tuition_fees__c FROM Student_Programme__c WHERE Id IN: spIds]){
            if(feeMap.containsKey(sp.MSTUFEE_FA__c)){
                sp.Major_source_of_tuition_fees__c = feeMap.get(sp.MSTUFEE_FA__c);
                spsToUpdate.add(sp);
            }
        }        
        update spsToUpdate;
    }
}