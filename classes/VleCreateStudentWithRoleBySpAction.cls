/**
 * Implementation of Action: 'create student by SP'
 * Description:
 * When Stage of Student_Progamme__c becomes 'Pre-Registered' we will create VLE student 
 */
public with sharing class VleCreateStudentWithRoleBySpAction extends VleBaseAction {
    
    /**
     * Student programme with all related data like Contact and Programme__c
     */
    public Student_Programme__c sp { get; set; }
    
    /**
     * List of modules related to Student_Programme__c
     */
    public List<Module__c> modules { get; set; }
    
    /**
     * List of VLE Organisation Wide Orgs
     */
    public Set<Long> defaultOrgUnits { get; set; }


    @TestVisible
    protected override Boolean findActionData(VLE_Action__c action) {
        sp = VleDaoServices.findStudentProgrammeInfo(action.Name);

        System.debug('>>> SP >>>' + sp);

        if ( sp != null ) {
            Set<Id> moduleIds = new Set<Id>();
            Set<String> orgWideUnitIds = new Set<String>();
            for (VLE_Sync_Command__c cmd: action.VLE_Sync_Commands__r) {
                if ( cmd.Command__c == VleSyncServices.CREATE_ENROLL_COMMAND && cmd.Obj_Type__c == VleSyncServices.OBJ_TYPE_MODULE ) {
                    moduleIds.add(cmd.Name);
                } else if ( cmd.Obj_Type__c == 'ORG_WIDE_UNIT' && cmd.Name != null ){
                    orgWideUnitIds.add(cmd.Name);
                }
            }

            System.debug('>>> SP moduleIds >>>' + moduleIds);

            modules = VleDaoServices.findProgrammeModules(moduleIds);

            System.debug('>>> SP modules >>>' + modules.size() );
    

            System.debug('>>> orgWideUnitIds >>>' + orgWideUnitIds );

            if ( orgWideUnitIds != null ){
                return !modules.isEmpty() || ! orgWideUnitIds.isEmpty();
            }

            System.debug('>>> HERE?  >>>' + !modules.isEmpty());

            return !modules.isEmpty();
        }

        return false;
    }
    
    @TestVisible
    protected override VleSyncServices.ICommand findCommand(Vle_Sync_Command__c cmd) {
        VleSyncServices.ICommand cmdImpl;
        if ( cmd.Command__c == VleSyncServices.CREATE_USER_COMMAND ) {
            VleCommands.CreateUser createUserCmd = new VleCommands.CreateUser();
            createUserCmd.person = sp.Student__r;
            
            createUserCmd.roleId = VleServices.programType2StudentRoleVleId.get(sp.Programme__r.Type__c) != null 
                ? VleServices.programType2StudentRoleVleId.get(sp.Programme__r.Type__c) 
                : Long.valueOf(VleServices.credentials.Default_Student_Role_VLE_ID__c);

            createUserCmd.sendEmail = VleServices.credentials.Email_To_Student__c;
            cmdImpl = createUserCmd;
        
        } else if ( cmd.Command__c == VleSyncServices.CREATE_ENROLL_COMMAND ) {

            VleCommands.EnrollmentParams enrParams = (VleCommands.EnrollmentParams) JSON.deserialize(cmd.Params__c, VleCommands.EnrollmentParams.class);       

            if ( cmd.Obj_Type__c == 'ORG_WIDE_UNIT' ){

                System.debug('>>>  ORG_WIDE_UNIT'  );

                VleCommands.CreateEnrollment takeCmd = new VleCommands.CreateEnrollment();
                takeCmd.cont = sp.Student__r;
                takeCmd.orgUnitId = enrParams.orgUnitId;
                takeCmd.roleId = enrParams.roleId;
                cmdImpl = takeCmd;

            } else {

                System.debug('>>>  usual module 2 >>>>'  );

                Map<Id,Module__c> moduleMap = new Map<Id,Module__c>(modules); 
                Module__c module = moduleMap.get(cmd.Name);
                if ( module != null ) {
                    VleCommands.CreateEnrollment takeCmd = new VleCommands.CreateEnrollment();
                    takeCmd.cont = sp.Student__r;
                    takeCmd.orgUnitId = Long.valueOf(module.VLE_ID__c);
                    takeCmd.roleId = enrParams.roleId;
                    cmdImpl = takeCmd;
                }                
            }
        }
        return cmdImpl;
    }

    /**
     * Prepare action with commands to 'create student' action
     * Note: sp and modules should be populated before
     * @return Structure with action and commands ready to insert into DB
     */
    public VleSyncServices.ActionStructure create() {
        VleSyncServices.ActionStructure aStruct = new VleSyncServices.ActionStructure();
        aStruct.masterAction = VleSyncServices.createAction(
            VleSyncServices.CREATE_VLE_STUDENT_WITH_ROLE_BY_SP_ACTION, sp.Id, VleSyncServices.ACTION_NEW_STATUS
        );
        
        if ( String.isEmpty(sp.Student__r.VLE_ID__c) && modules != null) {
            // create user command
            Vle_Sync_Command__c cmd = VleSyncServices.createCommand(
                VleSyncServices.CREATE_USER_COMMAND, sp.Student__c, 1, VleSyncServices.OBJ_TYPE_CONTACT, null
            );
            aStruct.getDetailCommands().add(cmd);
        }

        if ( modules != null ){
            // attach user to the course offering for each module
            for (Module__c module: modules) {

                Long vleRoleId = VleServices.programType2StudentRoleVleId.get(sp.Programme__r.Type__c) != null 
                    ? VleServices.programType2StudentRoleVleId.get(sp.Programme__r.Type__c) 
                    : Long.valueOf(VleServices.credentials.Default_Student_Role_VLE_ID__c);

                System.debug( LoggingLevel.ERROR, '>>>> OPTIONAL MODULES vle Role Id >>> ' +  vleRoleId );

                if ( vleRoleId != null ){
                    VleCommands.EnrollmentParams enrParams = new VleCommands.EnrollmentParams();
                    enrParams.roleId = vleRoleId ;
                    
                    Vle_Sync_Command__c cmd = VleSyncServices.createCommand(
                        VleSyncServices.CREATE_ENROLL_COMMAND, module.Id, aStruct.getDetailCommands().size()+1, 
                        VleSyncServices.OBJ_TYPE_MODULE, JSON.serialize( enrParams ) 
                    );
                    aStruct.getDetailCommands().add(cmd);
                }
            }  
        }

        //ENROLE TO ORG-WIDE MODULES
        if ( defaultOrgUnits != null ) {
            for ( Long orgUnitId : defaultOrgUnits ) {
               
                Long vleRoleId = VleServices.programType2StudentRoleVleId.get(sp.Programme__r.Type__c) != null 
                    ? VleServices.programType2StudentRoleVleId.get(sp.Programme__r.Type__c) 
                    : Long.valueOf(VleServices.credentials.Default_Student_Role_VLE_ID__c);
               
                VleCommands.EnrollmentParams enrParams = new VleCommands.EnrollmentParams();
                enrParams.roleId = vleRoleId;
                enrParams.orgUnitId = orgUnitId;

                Vle_Sync_Command__c cmd = VleSyncServices.createCommand(
                    VleSyncServices.CREATE_ENROLL_COMMAND, String.valueOf(orgUnitId), aStruct.getDetailCommands().size()+1,
                    'ORG_WIDE_UNIT', JSON.serialize( enrParams )
                );
                aStruct.getDetailCommands().add( cmd );
            
            }
        }  

        return aStruct; 
    }


}