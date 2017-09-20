/**
 * @author Mykola Senyk
 * @date 13/06/2014
 * @description Controller extension for Module Registration Page
 */
 /***** Modifications
 ** @author MKM
 ** done for workstream Module Registration amendments  
 */
/// <summary>Added new logic to calulate total availbale, used and required modules credits on Controller </summary>
///<param name="totalAvlCredit"> Used calculate and store total available credits</param>
///<param name="totalUsedCredits">Used calculated and store total used credits</param>
///<param name="sumOfRequiredModuled">Used to store sum of required module credits</param>
global with sharing class ModuleRegistrationContExt {

    // List of modlules to show in the page from which the user selects optional modules
    public List < Programme_Module__c > lstModules {
        get;
        set;
    }

    // List of existing modlules to show in the page from which the user selects optional modules
    public List < Programme_Module__c > lstExtModules {
        get;
        set;
    }

    // List of modlules to store user selections
    public List < Module__c > lstSelectedModuleModule {
        get;
        set;
    }

    //The application by student
    global static Student_Programme__c application {
        get;
        set;
    }
    //The application by student
    public Student_Programme__c application1 {
        get;
        set;
    }   
    // List of modlules to store user selections
    public Integer count {
        get;
        set;
    }

    // List of student modules selected by the user to insert
    public static List < Student_Module__c > lstNewStudentModule {
        get;
        set;
    }


    // List of student modules selected by the user to insert
    public static List < Student_Module__c > lstexistingStudentModule {
        get;
        set;
    }

    // boolean value which will set if the sp stage is Registerd
    public boolean lsstageRegister {
        get;
        set;
    }

    public double totalAvlCredit {
        get;
        set;
    }
    public double totalUsedCredits{
        get;
        set;
    }    
   public double sumOfRequiredModuled {get; set; }
    
    public ModuleRegistrationContExt(ApexPages.StandardController stdcontroller) {

        //populating the student programme record in page load
        List < string > fieldlist = new List < String > ();
        fieldlist.add('Programme__c');
        fieldlist.add('Student__c');
        fieldlist.add('Student__r.Name');
        fieldlist.add('Programme__r.Name');
        fieldlist.add('Stage__c');
        fieldlist.add('Name');
        fieldlist.add('Required_Credits__c'); 
        if (!Test.isRunningTest()) {
            stdcontroller.addFields(fieldlist);
        }

        application = new Student_Programme__c();
        application = (Student_Programme__c) stdController.getRecord();     
        application1 = (Student_Programme__c) stdController.getRecord(); 
          
        if (application.Stage__c == 'Registered') {
            //This parameter uses to hide and show the panel for adding modules
            lsstageRegister = true;
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'This Student Programme is not yet Registered so you cannot add optional modules.'));

        }        
        //Querying all the modules assigned to the student in this application
        lstexistingStudentModule = new List < Student_Module__c > ([Select Id, Name, Programme_Module__c, Programme_Module__r.Id from Student_Module__c where Student__c = : application.Student__c and Student_Programme__c = : application.Id]);
        Set < Id > existingprogrammemoduleids = new Set < Id > ();


        for (Student_Module__c mod: lstexistingStudentModule) {
            existingprogrammemoduleids.add(mod.Programme_Module__r.Id);
        }



        //Querying and the modules to dispalay in the page load

        lstModules = new List < Programme_Module__c > ();
        lstExtModules = new List < Programme_Module__c > ();
        //Querying all the optional programme modules available
         totalAvlCredit = 0.0;
        totalUsedCredits = 0.0;
        sumOfRequiredModuled = 0.0;
        List < Programme_Module__c > lstallmodules = new List < Programme_Module__c > ([Select Id, Name,Module_Credits__c,Module__r.Module_Reference__c, Module__r.Name from Programme_Module__c where Programme__c = : application.Programme__c and Member_Type__c = 'Optional']);
        for(Student_Module__c temppm :[Select Credits__c from Student_Module__c where Student_Programme__c =:application.id and (Member_Type__c = 'required' OR Member_Type__c ='Specials') and Student__c = : application.Student__c ]){
          
           sumOfRequiredModuled = sumOfRequiredModuled + temppm.Credits__c ;
        }
        // Seperating already assigned modules and other in to seperate lists.
        for (Programme_Module__c programmeModule: lstallmodules) {
            if (existingprogrammemoduleids.contains(programmeModule.Id)) {
                System.debug('programmeModule.Module_Credits__c'+programmeModule.Module_Credits__c);
                if( programmeModule.Module_Credits__c != null){                
                  totalUsedCredits =totalUsedCredits + programmeModule.Module_Credits__c;
                }              
                lstExtModules.add(programmeModule);
            } else {                       
                lstModules.add(programmeModule);
            }              
        }            
        lstNewStudentModule = new List < Student_Module__c > ();
        count = 1;
    }


    @RemoteAction
    global static String saveOptionalModules(String selectedModlueIds, String studentProgrammeId, String unselectedModlueIds) {

        application = new Student_Programme__c();
        application = [SELECT Id, Name, Programme__c, Student__c from Student_Programme__c where Id = : studentProgrammeId];        
        // The Set od unselected Ids
        Set < String > unselectedids = new Set < String > ();
        if (unselectedModlueIds.split(',').size() > 0) {
            //finding the removed modules, forming a list and deleting the list
            unselectedids.addAll(unselectedModlueIds.split(','));
            List < Student_Module__c > lstNewStudentModuletobedeleted = new List < Student_Module__c > ([Select Id from Student_Module__c where Programme_Module__c IN: unselectedids and Student__c=:application.Student__c and Student_Programme__c = : application.Id]);
            if (lstNewStudentModuletobedeleted.size() > 0) {
                delete lstNewStudentModuletobedeleted;
            }
        }
        if (selectedModlueIds.split(',').size() > 0) {
            Set < String > ids = new Set < String > ();

            //contains the set of program module ids in existing student modules
            Set < String > existingids = new Set < String > ();
            ids.addAll(selectedModlueIds.split(','));
           
            Student_Module__c objStudentModule;
            lstexistingStudentModule = new List < Student_Module__c > ();
            lstNewStudentModule = new List < Student_Module__c > ();
            // lstexistingStudentModule=  new List<Student_Module__c>([Select id, Programme_Module__c from Student_Module__c where Programme_Module__c IN:ids ]);
            for (Student_Module__c sm: [Select id, Programme_Module__c from Student_Module__c where Programme_Module__c IN: ids and Student__c=:application.Student__c ]) {
                existingids.add(sm.Programme_Module__c);
            }
            

            for (Programme_Module__c mod: [Select ID, Name from Programme_Module__c Where Id IN: ids and Id NOT IN: existingids]) {
                System.Debug('Success: ');
                objStudentModule = new Student_Module__c();
                objStudentModule.Programme_Module__c = mod.Id;
                objStudentModule.Student__c = application.Student__c;
                objStudentModule.Student_Programme__c = application.Id;
                lstNewStudentModule.add(objStudentModule);
                System.Debug('objStudentModule  ' + objStudentModule);
            }
            
            if (lstNewStudentModule.size() > 0 && !Test.isRunningTest()) {
                insert lstNewStudentModule;
            }
        }
        // Create the assesment and Attendence records
        StudentProgrammeUtilities.createAssessmentsAndAttendance(application.Id);
        // Save the Optional modules In to the programme which is selected
        return 'Success';

    }

}