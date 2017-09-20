/*
*@auther :Simon Edwards
* 2014-08-04 : CSL : This class will hold methods called from Student Programme buttons & pages
*<summary>
@Auther: Manu KM
*Date:17-Sep-2015
*Support task:- Renamed all the studentAttandance object to studentAbsences
*Line number, 23,
*</summary>
*/

global class StudentProgrammeUtilities {

    //2014-08-04 : CSL : This method will be called from a button on the Student Programme
    //and will create the necessary Student Assessment records and Student Attendance records
    //against the provided Student Programme
    webservice static void createAssessmentsAndAttendance(String spID){
        Student_Programme__c sp;
        Map<Id, Assessment__c> assessmentMap = new Map<Id, Assessment__c>();
        Map<Id, Session__c> sessionMap = new Map<Id, Session__c>();
        List<Student_Assessment__c> studentAssessments = new List<Student_Assessment__c>();        
        List<Student_Absence__c> studentAbsences = new List<Student_Absence__c>();
        Map<Id, Student_Module__c> savedStudentModules = new Map<Id, Student_Module__c>();        
        System.Debug('spID'+spID);
        //We need to get hold of the Student Programme and relevant records
        sp = [Select s.Id, s.Student__c, s.Student__r.LastName, (Select Id, Programme_Module__c,Assessments_Created__c,Attendances_Created__c, Programme_Module__r.Module__r.Id, Programme_Module__r.Module__r.Name From Student_Modules__r) From Student_Programme__c s where s.Id =:spID LIMIT 1];
        //sp = [Select s.Id, s.Student__c, s.Student__r.LastName, (Select Id, Programme_Module__c,Programme_Module__r.Module__r.Id, Programme_Module__r.Module__r.Name From Student_Modules__r) From Student_Programme__c s where s.Id =:spID LIMIT 1];
        System.debug('sp'+sp);
        if (sp == null){
            return;
        }
        
        
        Set<Id> moduleIdSet = new Set<Id>();
        
        for (Student_Module__c sm : sp.Student_Modules__r){
            moduleIdSet.add(sm.Programme_Module__r.Module__r.Id);
        }
        System.Debug('moduleIdSet'+moduleIdSet);
        //Process Assessments
        for (Assessment__c a : [Select a.Module__c, a.Id From Assessment__c a where a.Module__c in :moduleIdSet]){
            assessmentMap.put(a.Module__c, a);
        }
        System.Debug('assessmentMap'+assessmentMap);
        //Process Sessions
        for (Session__c s : [Select s.Module__c, s.Id From Session__c s where s.Module__c in :moduleIdSet]){
            sessionMap.put(s.Module__c, s);
        }
        System.Debug('sessionMap'+sessionMap);
        for (Student_Module__c sm : sp.Student_Modules__r){
            //Create the Student Assessments
          //  System.debug('sm.Assessments_Created__c = ' + sm.Assessments_Created__c);
            if (!sm.Assessments_Created__c){
                Student_Assessment__c sa = new Student_Assessment__c();
                Assessment__c getAssessment = assessmentMap.get(sm.Programme_Module__r.Module__r.Id);
                if (getAssessment != null){
                    sa.Name = sp.Student__r.LastName + sm.Programme_Module__r.Module__r.Name;
                    sa.Assessment__c = getAssessment.Id;
                    sa.Student_Module__c = sm.Id;
                    sa.Student__c = sp.Student__c;
                    studentAssessments.add(sa);
                    //Once we have created an Assessment, we can update the Student Module
                    sm.Assessments_Created__c = true;
                    if (!savedStudentModules.containsKey(sm.Id)){
                        savedStudentModules.put(sm.Id, sm);
                    }
                }
            }
            
            if (!sm.Attendances_Created__c){
                //Create the Student Attendances
                Session__c getSession = sessionMap.get(sm.Programme_Module__r.Module__r.Id);
                if (getSession != null){
                   
                    Student_Absence__c satt = new Student_Absence__c();
                    satt.Session__c = getSession.Id;
                    satt.Student_Module__c = sm.Id;
                    satt.Student__c = sp.Student__c; 
                   
                    studentAbsences.add(satt);
                    //Once we have created an Attendance record, we can update the Student Module
                    sm.Attendances_Created__c = true;
                    if (!savedStudentModules.containsKey(sm.Id)){
                        savedStudentModules.put(sm.Id, sm);
                    }
                }
            }
            
        }
        //System.Debug('studentAbsences '+studentAbsences);
        System.Debug('studentAssessments'+studentAssessments);
        //Insert the records
        if (studentAssessments.size() > 0){
            insert studentAssessments;
        }
      
        if (studentAbsences.size() > 0){         
            insert studentAbsences;
        } 
        
        //Update the Student Module records to say we've created the Assessment and Session records per Student Module
        if (savedStudentModules.size() > 0){
            update savedStudentModules.values();
        }
        
    }

}