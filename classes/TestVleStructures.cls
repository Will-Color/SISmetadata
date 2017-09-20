@isTest
private class TestVleStructures {
    
    static testMethod void testConstructors() {
        VleStructures.CreateUserData cud = new VleStructures.CreateUserData();
        cud.OrgDefinedId = '';
        cud.FirstName = '';
        cud.MiddleName = '';
        cud.LastName = '';
        cud.ExternalEmail = '';
        cud.UserName = '';
        cud.RoleId = 1;
        cud.IsActive = true;
        cud.SendCreationEmail = true;
        
        VleStructures.UserActivationData uad = new VleStructures.UserActivationData();
        uad.IsActive = true;
        
        VleStructures.UserData ud = new VleStructures.UserData();
        ud.OrgId = 1;
        ud.UserId = 1;
        ud.FirstName = '';
        ud.MiddleName = '';
        ud.LastName = '';
        ud.UserName = '';
        ud.ExternalEmail = '';
        ud.OrgDefinedId = '';
        ud.UniqueIdentifier = '';
        ud.Activation = null;
        
        VleStructures.CreateEnrollmentData ced = new VleStructures.CreateEnrollmentData();
        ced.OrgUnitId = 1;
        ced.UserId = 1;
        ced.RoleId = 1;
        
        VleStructures.EnrollmentData ed = new VleStructures.EnrollmentData();
        ed.OrgUnitId = 1;
        ed.UserId = 1;
        ed.RoleId = 1;
        ed.IsCascading = true;
        
        VleStructures.CreateCourseOffering cco = new VleStructures.CreateCourseOffering();
        cco.Identifier = 1;
        cco.Name = '';
        cco.Code = '';
        cco.Path = '';
        cco.CourseTemplateId = 1;
        cco.SemesterId = 1;
        cco.StartDate = '';
        cco.EndDate = '';
        cco.LocaleId = 1;
        cco.ForceLocale = true;
        cco.ShowAddressBook = true; 
        
        VleStructures.CreateCourseInfo cci = new VleStructures.CreateCourseInfo();
        cci.Name = '';
        cci.Code = '';
        cci.StartDate = '';
        cci.EndDate = '';
        cci.IsActive = true;
    
    }   

}