trigger ProgrammeTrigger on Programme__c (after insert, after update) {

    if (Trigger.isAfter){
        
        
    
        if (Trigger.isInsert || Trigger.isUpdate){
        if ( Trigger.isUpdate)
        {
             //Stores programmes with updated fee values
            Set<Id> updatedProgrammeIds = new Set<Id>();
            //Stores Student Programmes of updated programmes
            List<Student_Programme__c> lstStudentProgramme = new LIST<Student_Programme__c>();
            
            for (Programme__c newProgramme : Trigger.new) {
                Programme__c oldProgramme = Trigger.oldMap.get(newProgramme.Id);
                //Old Home EU Fee of the record
                Decimal oldHomeEUFee = oldProgramme.Home_EU_Fee__c;
                //New Home EU Fee of the record
                Decimal newHomeEUFee = newProgramme.Home_EU_Fee__c;
                //Old Overseas Fee of the record
                Decimal oldOverseasFee = oldProgramme.Overseas_Fee__c;
                //New Overseas Fee of the record
                Decimal newOverseasFee = newProgramme.Overseas_Fee__c;
                
                //Add record id to the set if its fee values are found updated
                if(oldHomeEUFee != newHomeEUFee || oldOverseasFee != newOverseasFee){
                    updatedProgrammeIds.add(newProgramme.Id);
                }
            }
            
            //Stores student programmes whose parent programmes have updated fee values
            lstStudentProgramme = [SELECT id, Fee_Recalc__c, Programme__c  FROM Student_Programme__c WHERE Programme__c IN: updatedProgrammeIds];
            
            //Set fee recalculate checkbox to the student programmes
            for(Student_Programme__c sp : lstStudentProgramme){
                sp.Fee_Recalc__c = TRUE;
            }
            //Update the list of student programmes
            UPDATE lstStudentProgramme;
        }
            ProgrammeServices.createProgramContentAsXmlAttachment( Trigger.newMap.keySet() );
        }       
    }
}