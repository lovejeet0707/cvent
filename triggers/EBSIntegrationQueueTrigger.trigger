/*
 * Name: EBSIntegrationQueueTrigger
 * Description: This trigger is created during BOSS implementation and used exclusively for Salesforce to EBS Integration related functionality. 
 * 				Integration Queue object maintains the transactional information for every sync that happens with EBS on Account, Contact, Address and Opportunity (order). 
 * 				During Order processing, all dependencies for the opportunity are resolved by first syncing related account, address and contacts to EBS.  
 * 				The dependency resolution is handled by controlled sequenced execution of all such Integration Queue records via an EBS Order Sync Framework Object.
 * 				An Integration Queue record could be Independent (no association to a master Order Sync record) or Associated (EBS_Order_Sync_Process_Id__c lookup field). 
 * 				For all successfully processed "Associated" Integration queue records; this trigger cascades an update back to the associated Sync Framework master record.
 * 
 *  History:
 *  Date			Version 	Change/Description							Author
 * -------------------------------------------------------------------------------------------
 *  April 15, 2017	1.0			Created										Praveen Kaushik
 * -------------------------------------------------------------------------------------------
*/
trigger EBSIntegrationQueueTrigger on Integration_Queue__c (after update) {
	Map<Id, EBS_Order_Sync_Framework__c> orderSyncProcessMap = new Map<Id, EBS_Order_Sync_Framework__c>();
    
    for(Integration_Queue__c obj: Trigger.new){
        if(obj.EBS_Order_Sync_Process_Id__c != null && obj.Status__c != ((Integration_Queue__c)Trigger.oldMap.get(obj.Id)).Status__c && (obj.Status__c == 'Processed')){
			System.debug('EBSIntegrationQueueTrigger invoked for '+obj.Id);       
			orderSyncProcessMap.put(obj.EBS_Order_Sync_Process_Id__c, new EBS_Order_Sync_Framework__c(Id = obj.EBS_Order_Sync_Process_Id__c));						            
        }    
    }
    if(!orderSyncProcessMap.isEmpty()){
        update orderSyncProcessMap.values();
    }

}