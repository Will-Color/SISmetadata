/*
*
* 2014-07-18 : CSL : PreRegistrationTabController is used on the PreRegistrationTab page on the Customer Community
*
*/
public class PreRegistrationTabController {
	public final String STAGE_ACCEPTED = 'Accepted';
	public List<Student_Programme__c> progList {get; set;}
	public User currentUser {get; set;}
	public boolean showList {get; set;}
	

	public PreRegistrationTabController(){
		showList = false;
		currentUser = [select u.Id, u.ContactId from User u where u.Id = :UserInfo.getUserId() LIMIT 1];
		if (currentUser != null){
			if (currentUser.ContactId != null){
				progList = [select s.Id, s.Stage__c, s.Name, s.Programme__r.Name from Student_Programme__c s where s.Student__c = :currentUser.ContactId and s.Stage__c = :STAGE_ACCEPTED];
				if (progList != null && progList.size() > 0){
					showList = true;
				}	
			}	
		}
		
	}

}