/**
 * Wrapper class for Programme__c object
 */
public class ProgrammeWrapper {
    public String combinedDates {
        get {
            String dateString = '';
            String dateDay = '';
            String dateEndDay = '';
            String dateMonth = '';
            String dateEndMonth = '';
            String dateYear = '';
            String dateEndYear = '';
            Date startDate = programme.Start_Date__c;
            Date endDate = programme.End_Date__c;
            if(startDate != null) {
                dateDay = String.valueOf(startDate.day());
                dateMonth = String.valueOf(Datetime.newInstance(startDate.year(), startDate.month(), startDate.day()).format('MMMM'));
                dateYear = String.valueOf(startDate.year());
            }
            if(endDate != null) {
                dateEndDay = String.valueOf(endDate.day());
                dateEndMonth = String.valueOf(Datetime.newInstance(endDate.year(), endDate.month(), endDate.day()).format('MMMM'));
                dateEndYear = String.valueOf(endDate.year());
            }
            if(startDate != null && endDate != null) {
                if (startDate.year() == endDate.year()) {
                    if(startDate.month() == endDate.month()) {
                        if (startDate.day() != endDate.day()) 
                            dateDay = String.valueOf(startDate.day() + ' - ' + endDate.day());
                        dateString = dateDay + ' ' + dateMonth + ' ' + dateYear;
                    }
                    else {
                        dateString = dateDay + ' ' + dateMonth + ' - ' + dateEndDay + ' ' + dateEndMonth + ' ' + dateYear;
                    }
                }
                else {
                    dateString = dateDay + ' ' + dateMonth + ' ' + dateYear + ' - ' + dateEndDay + ' ' + dateEndMonth + ' ' + dateEndYear;
                }
            }
            else {
                if(startDate != null) {
                    dateString = 'From ' + dateDay + ' ' + dateMonth + ' ' + dateYear;
                }
                else if(endDate != null) {
                    dateString = 'Till ' + dateEndDay + ' ' + dateEndMonth + ' ' + dateEndYear;
                }
                else return '';
            }
            return dateString;
        }
    }
    //2014-08-13 : CSL : Client now wants to show both Home Fee and Overseas Fee, so two new methods will be added 
    //so the current 'fee' method is left untouched
    
    public Decimal displayFee {
        get {
            return programme.Home_EU_Fee__c;
        }
    }
    
    public Decimal displayOverseasFee {
        get {
            return programme.Overseas_Fee__c;
        }
    }
    
    public boolean displayTBC {
        get {
            return programme.Fee_TBC__c;
        }
    }
    
    public Decimal fee {
        get {
            if (usr.Contact != null && usr.Contact.EU_Citizen__c == true) {
                return programme.Home_EU_Fee__c;
            }
            return programme.Overseas_Fee__c;
        }
    }
    public Programme__c programme { get; private set;}
    
    @TestVisible
    private static User usr {
        get {
            if(usr == null) {
                usr = [SELECT Id, Contact.EU_Citizen__c FROM User WHERE Id = :UserInfo.getUserId()];
            }
            return usr;
        }
        set;
    }
    public ProgrammeWrapper(Programme__c programme) {
        this.programme = programme;
    }
}