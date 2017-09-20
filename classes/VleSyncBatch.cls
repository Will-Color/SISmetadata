/**
 * Batch job for synchronizing action to VLE
 */
global class VleSyncBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

	private String query = 'SELECT Id, Status__c FROM VLE_Action__c WHERE Status__c = \'' + VleSyncServices.ACTION_BATCH_STATUS + '\'';
	
	public Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext BC, List<VLE_Action__c> scope){
		VleSyncServices.syncActionBatch(scope[0].Id);
	}

	global void finish(Database.BatchableContext BC) {
		VleSyncServices.isBatchRunning = false;
	}
	
}