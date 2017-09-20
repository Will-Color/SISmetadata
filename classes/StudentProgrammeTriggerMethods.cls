/*
*
* 2014-07-31 : CSL : This class holds methods called from the StudentProgrammeTrigger
*
*/
public class StudentProgrammeTriggerMethods {
    
    public static final String TYPE_REQUIRED = 'Required';
    public static final String TYPE_OPTIONAL = 'Optional';
    
    // Student_Programme__c.Stage__c constants
    public static final String STAGE_ACCEPTED = 'Accepted';
    public static final String STAGE_PRE_REGISTERED = 'Pre-Registered';
    public static final String STAGE_COMPLETED = 'Completed';
    
    public static final String CODE_DTN = 'DTN';

    private static List<Student_Programme__c> findDTNStudentProgrammesData(List<Student_Programme__c> spList) {
        return [
            SELECT Id, Programme__c, Student__c, Student__r.VLE_ID__c, Student__r.FirstName, Student__r.LastName
            FROM Student_Programme__c
            WHERE Id IN :spList
            //AND Programme__r.Code__c = :CODE_DTN
        ];
    }

    private static List<Student_Programme__c> findStudentProgrammesDataWithPv(List<Student_Programme__c> spList) {
        List<Id> spIds = new List<Id>();
        for(Student_Programme__c sp : spList)
            spIds.add(sp.Id);
        
        return [
            SELECT Id, Programme__c, Student__c, Student__r.VLE_ID__c, Student__r.FirstName, Student__r.LastName, Programme__r.Type__c, Programme__r.Homepage_VLE_ID__c
            FROM Student_Programme__c
            WHERE Id IN :spIds
            AND Programme__r.Programme_Version__c != NULL
            //AND Programme__r.Code__c = :CODE_DTN
        ];
    }


    //return Programme id to list of modules (student module relation is used)
    private static Map<Id,List<Module__c>> findStudentModulesByProgramModuleMemberType(List<Student_Programme__c> spList, List<String> memberTypes) {
        Set<Id> progIds = new Set<Id>();
        List<Id> spIds = new List<Id>();
        for (Student_Programme__c sp: spList) {
            progIds.add(sp.Programme__c);
            spIds.add(sp.Id);
        }
        system.debug('##1'+progIds);
        system.debug('##2'+memberTypes);
        List<Student_Module__c> smList = [
            SELECT Id, Programme_Module__c, Programme_Module__r.Programme__c, Programme_Module__r.Module__r.VLE_ID__c,Student_Programme__c
            FROM Student_Module__c
            WHERE Programme_Module__r.Programme__c IN : progIds
            AND Programme_Module__r.Member_Type__c in :memberTypes
            AND Programme_Module__r.Module__c != null
            AND Programme_Module__r.Module__r.VLE_Visibility__c = true
            AND Student_Programme__c IN : spIds
        ];
        system.debug('##3'+spList );
        system.debug('##3'+smList );
     /*   Map<Id,List<Module__c>> progToModuleMap = new Map<Id,List<Module__c>>();
        for (Student_Module__c sm: smList) {
            List<Module__c> innerList = progToModuleMap.get(sm.Programme_Module__r.Programme__c); 
            if ( innerList == null ) {
                innerList = new List<Module__c>();
                progToModuleMap.put(sm.Programme_Module__r.Programme__c, innerList);
            }
            innerList.add(sm.Programme_Module__r.Module__r);
        }
        */

        Map<Id,List<Module__c>> progToModuleMap = new Map<Id,List<Module__c>>();
        for (Student_Module__c sm: smList) {
            List<Module__c> innerList = progToModuleMap.get(sm.Student_Programme__c); 
            if ( innerList == null ) {
                innerList = new List<Module__c>();
                progToModuleMap.put(sm.Student_Programme__c, innerList);
            }
            innerList.add(sm.Programme_Module__r.Module__r);
        }
        
        return progToModuleMap;
    }




    private static List<Student_Programme__c> findStudentProgrammesWithNewStage(List<Student_Programme__c> newList, Map<Id,Student_Programme__c> oldMap, String newStage) {
        List<Student_Programme__c> spList = new List<Student_Programme__c>();
        for (Student_Programme__c sp : newList) {
            if (sp.Stage__c == newStage && oldMap.get(sp.Id).Stage__c != newStage) {
                spList.add(sp);
            }
        }
        return spList;
    }

    /**
     * Single point to the all Student_Programme__c triggers
     */
    public static void onTrigger(List<Student_Programme__c> newList, List<Student_Programme__c> oldList, Map<Id,Student_Programme__c> newMap, Map<Id,Student_Programme__c> oldMap,
    Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
        if (isAfter && isUpdate) {

            //This call creates the Mandatory Student Modules, if a Student Programme is updated as 'Accepted'
            //findAcceptedStudentProgrammesAndCreateMandatoryModules(newList);

            /* This call creates new user (save VLE ID in the Contact record) and sets user's role depending on Programme Type 
                value of related Programme Version. 
                assigns user to Course offering equals with specific role */     
            //findPreRegisteredStudentProgrammesByProgrammeType(newList, oldMap);
            
            findCompletedStudentProgrammes(newList, oldMap);
            
        }
    }

/*
    public static void findAcceptedStudentProgrammesAndCreateMandatoryModules(List<Student_Programme__c> newList) {
        List<Student_Programme__c> spList = new List<Student_Programme__c>();
        for (Student_Programme__c sp : newList) {
            if (sp.Stage__c == STAGE_ACCEPTED) {
                spList.add(sp);
            }
        }

        List<Student_Programme__c> spListToProcess = findStudentProgrammesDataWithPv(spList);

        if (! spList.isEmpty() ){
            Map<Id,List<Module__c>> progModules = findStudentModulesByProgramModuleMemberType(spList, new List<String>{TYPE_OPTIONAL});
            for (Student_Programme__c sp: spListToProcess) {
                // add action to create VLE student
                
                //ENROLE TO ORG-WIDE MODULES
                Set<Long> defaultOrgUnits = new Set<Long>( VleServices.studentOrgUnitIds );
                if ( VleServices.credentials.Enable_Programme_Homepage__c && sp.Programme__r.Homepage_VLE_ID__c != null ){
                    defaultOrgUnits.add( Long.valueOf( sp.Programme__r.Homepage_VLE_ID__c ) );  //Enroll to homepage
                }      
                System.debug( '>>> defaultOrgUnits >>> ' + defaultOrgUnits );

                VleCreateStudentWithRoleBySpAction vleAction = new VleCreateStudentWithRoleBySpAction();
                vleAction.sp = sp;
                vleAction.modules = progModules.get(sp.Programme__c);
                vleAction.defaultOrgUnits = defaultOrgUnits;
                VleSyncServices.addToQueue(vleAction, VleSyncServices.CREATE_VLE_STUDENT_WITH_ROLE_BY_SP_ACTION, sp.Student__r.Id);  
                
            }
            VleSyncServices.persistQueue(); // sync
        }
    }
*/

    @InvocableMethod
    public static List<Student_Programme__c> findPreRegisteredStudentProgrammesByProgrammeType(List<Student_Programme__c> newList) 
    {
        //List<Student_Programme__c> spList = findStudentProgrammesWithNewStage(newList, oldMap, STAGE_PRE_REGISTERED);
        List<Student_Programme__c> spListToProcess = findStudentProgrammesDataWithPv(newList);
        system.debug('##SP1'+newList );
        system.debug('##SP2'+spListToProcess);
        if (! spListToProcess.isEmpty() )
        {
            createMandatoryModules(spListToProcess);
        }

        Map<Id,List<Module__c>> progModules = findStudentModulesByProgramModuleMemberType(newList, new List<String>{TYPE_REQUIRED,TYPE_OPTIONAL});
        for (Student_Programme__c sp: spListToProcess) 
        {
            // add action to create VLE student
            
            //ENROLE TO ORG-WIDE MODULES
            Set<Long> defaultOrgUnits = new Set<Long>( VleServices.studentOrgUnitIds );
            if ( VleServices.credentials.Enable_Programme_Homepage__c != null && VleServices.credentials.Enable_Programme_Homepage__c && sp.Programme__r.Homepage_VLE_ID__c != null )
            {
                defaultOrgUnits.add( Long.valueOf( sp.Programme__r.Homepage_VLE_ID__c ) );  //Enroll to homepage
            }      
            
            System.debug( '>>> defaultOrgUnits >>> ' + defaultOrgUnits );

            VleCreateStudentWithRoleBySpAction vleAction = new VleCreateStudentWithRoleBySpAction();
            vleAction.sp = sp;
        //  vleAction.modules = progModules.get(sp.Programme__c);
            vleAction.modules = progModules.get(sp.Id);
            vleAction.defaultOrgUnits = defaultOrgUnits;
            VleSyncServices.addToQueue(vleAction, VleSyncServices.CREATE_VLE_STUDENT_WITH_ROLE_BY_SP_ACTION, sp.Student__r.Id);  
        }
        VleSyncServices.persistQueue(); // sync
        
        return spListToProcess;                
    }


    public static List<Student_Programme__c> findCompletedStudentProgrammes(List<Student_Programme__c> newList, Map<Id,Student_Programme__c> oldMap) 
    {
        List<Student_Programme__c> spList = findStudentProgrammesWithNewStage(newList, oldMap, STAGE_COMPLETED);
        List<Student_Programme__c> spListToProcess = findDTNStudentProgrammesData(spList);

        // add VLE actions
        for (Student_Programme__c sp: spListToProcess) 
        {
            VleSetStudentInactiveBySpAction vleAction = new VleSetStudentInactiveBySpAction();
            vleAction.sp = sp;
            VleSyncServices.addToQueue(vleAction, VleSyncServices.SET_STUDENT_INACTIVE_BY_SP_ACTION, sp.Student__r.Id);
        }
        VleSyncServices.persistQueue(); // sync
        
        return spListToProcess;
    }
    
    //2014-07-31 : CSL : This method will create all the necessary Student Modules for those Student Programmes that have beem 'Accepted' by the Student
    public static void createMandatoryModules(List<Student_Programme__c> inRecords)
    {
        system.debug('*** -- Into StudentProgrammeTriggerMethods.createMandatoryModules with ' + inRecords.size() + ' -- ***');
        Set<Id> progIds = new Set<Id>();
        Set<Id> studentProgIds = new Set<Id>();
        Map<String, Student_Module__c> currentModules = new Map<String, Student_Module__c>();
        List<Student_Module__c> newStudentModules = new List<Student_Module__c>();
        
        for (Student_Programme__c sp : inRecords)
        {
            progIds.add(sp.Programme__c);
            studentProgIds.add(sp.Id);
        }
        
        System.debug('>>> progIds >>>' + progIds);
        System.debug('>>> studentProgIds>>>' + studentProgIds);
        //We need to make sure we don't create Student Modules that already exist
        for (Student_Module__c sm : [Select s.Student_Programme__c, s.Programme_Module__c, s.Id From Student_Module__c s where s.Student_Programme__c in :studentProgIds])
        {
            String smKey = sm.Student_Programme__c + '~' + sm.Programme_Module__c;
            system.debug('*** -- smKey = ' + smKey + ' -- ***');
            currentModules.put(smKey, sm);
        }
        
        Map<Id, Programme__c> progMap = new Map<Id, Programme__c>([Select (Select Id, Name From Programme_Modules__r where Member_Type__c = :TYPE_REQUIRED) From Programme__c p where p.Id in :progIds]);
              
        System.debug('>>> progMap  >>>' + progMap );
        for (Student_Programme__c sp : inRecords)
        {
            Programme__c prog = progMap.get(sp.Programme__c);
            
            if (prog != null)
            {
                for (Programme_Module__c pm : prog.Programme_Modules__r)
                {
                    String smKey = sp.Id + '~' + pm.Id;
                    Student_Module__c sm = currentModules.get(smKey);                   
                    if (sm == null)
                    {
                        system.debug('*** -- Creating new Module -- ***');
                        Student_Module__c newSM = new Student_Module__c();
                        newSM.Name = pm.Name + ' Student Module';
                        newSM.Student__c = sp.Student__c;
                        newSM.Student_Programme__c = sp.Id;
                        newSM.Programme_Module__c = pm.Id;
                        newStudentModules.add(newSM);
                    }
                }
            }
        }
        
        if (newStudentModules.size() > 0)
        {
            system.debug('*** -- About to insert ' + newStudentModules.size() + ' new Student Modules -- ***');
            insert newStudentModules;
        }
    }
    
}