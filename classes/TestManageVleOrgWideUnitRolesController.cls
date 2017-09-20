@IsTest
public class TestManageVleOrgWideUnitRolesController {
    
    static testMethod void studentRoleAssignment(){

        VLE_Program_Type_2_Role_VLE_ID_Mapping__c vlePT2Role = new VLE_Program_Type_2_Role_VLE_ID_Mapping__c();
        vlePT2Role.Name = 'testvlePT2';
        vlePT2Role.Programme_Type__c ='testProgrammeType';
        vlePT2Role.Role_VLE_ID__c = '100';
        INSERT vlePT2Role;
        ManageVleOrgWideUnitRolesController mVController = new ManageVleOrgWideUnitRolesController();
        mVController.objName = 'VLE_Program_Type_2_Role_VLE_ID_Mapping__c';
        mVController.addRecord();
        mVController.indexToDelete = 0;
        mVController.deleteRowStudent();
        //PageReference pRef = new PageReference();
        PageReference  pRef = mVController.saveMappings();
    }

    /*static testMethod void staffRoleAssignment(){
        VLE_Staff_Module_Roles_And_Vle_Role_Ids__c vleStaff = new VLE_Staff_Module_Roles_And_Vle_Role_Ids__c();
        vleStaff.Name = 'testvleStaff';
        vleStaff.Module_Role__c = 'mRole';
        vleStaff.Role_VLE_ID__c = '121';
        INSERT vleStaff;

        ManageVleOrgWideUnitRolesController mVController = new ManageVleOrgWideUnitRolesController();
        mVController.objName = 'VLE_Staff_Module_Roles_And_Vle_Role_Ids__c';
        mVController.addRecord();
        mVController.indexToDelete = 0;
        mVController.deleteRowStaff();
        //PageReference pRef = new PageReference();
        PageReference  pRef = mVController.saveMappings();   
    }*/

    
}