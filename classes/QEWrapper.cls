/**
 * @author Mykola Senyk
 * @date 17/06/2014
 * @description Wrapper class for Qualifications_Experience__c
 */
public class QEWrapper {
    
    /**
     * Constructor
     * @param record Object for wrapping
     */
    public QEWrapper(Qualifications_Experience__c record) {
    	item = record;
    }
    
    /**
     * Inner object
     */
    public Qualifications_Experience__c item { get; set; }
    
    /**
     * Index in parent list
     */
    public Integer index { get; set; }
    
    
}