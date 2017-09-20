public class SAFFormAssemblyController {
    
    @AuraEnabled
    public static List<User> getUserId(){
        string currentUser;
        currentUser = Userinfo.getUserId();
        List<User> userlist = [Select u.Id,u.ContactId from User u where u.Id = :UserInfo.getUserId()];
        return userlist;
    }   
}