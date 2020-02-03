/*
 * Name: EBSOrderSyncFrameworkTrigger
 * Description: This trigger is created during BOSS implementation and used exclusively for Salesforce to EBS Integration related functionality. 
 * 				EBS Order Sync Framework Object is used for a controlled sequenced execution during Order Processing. For any Opportunity to sync 
 * 				with EBS and generate an Order; It needs to have a valid Account, Bill To & Ship To Addresses and Contacts. Valid here denotes 
 * 				a synced record with EBS that has got an EBS Id attached to it. If any of these is missing, then these records are processed first before sending 
 * 				the Opportunity data to EBS. This is tracked and controlled on EBS Order Sync Framework Object with the help of multiple child 
 * 				Integration Queue records (one each for each dependency). Here is the sync sequence that happens:
 * 				Step 1. Account --- 
 * 							  | (Integration Queue record processed succesfully for Account)
 * 							    --> Step 2. Bill To Address
 * 									   Ship To Address
 * 								  	   Bill To Contact
 * 								  	   Ship To Contact --
 * 												 		 | (Integration Queue record processed succesfully for all in Step 2)
 * 														  --> Step 3. Opportunity
 * 
 * 				The Order creation process is initiated when a Finance rep clicks the "Send to EBS" button on Opportunity layout.
 * 				Irrespective of how many times the button is clicked, there is one and only one EBS Order Sync Framework record per Opportunity.
 * 
 *  History:
 *  Date			Version 	Change/Description							Author
 * -------------------------------------------------------------------------------------------
 *  April 15, 2017	1.0			Created										Praveen Kaushik
 * -------------------------------------------------------------------------------------------
*/
trigger EBSOrderSyncFrameworkTrigger on EBS_Order_Sync_Framework__c (after insert, after update) {
    for(EBS_Order_Sync_Framework__c syncObj: Trigger.new){
        System.debug('EBSOrderSyncFrameworkTrigger invoked for '+syncObj);       
        
        if(!syncObj.EBS_Order_Generated__c){
            
            boolean dependenciesExist = false;
            //Check for EBS Account Id and trigger Account Sync if unavailable
            if(syncObj.Related_Account_EBS_Id__c == null){
                IntegrationAccount.resyncAccountForOrderSync(syncObj.Related_Account_SF_Id__c, String.valueOf(syncObj.Id));
                dependenciesExist = true;
            }
            else {
                //Check for EBS Bill To Site Id and trigger Address Sync if unavailable
                if(syncObj.Related_Bill_To_Address_EBS_Id__c == null){
                    Address__c addr = new Address__c(Id = syncObj.Related_Bill_To_Address_SF_Id__c);
                    addr.Operating_Unit_Name__c = syncObj.Operating_Unit_Name__c;
                    update addr;
                    
                    IntegrationAddress.resyncAddressForOrderSync(syncObj.Related_Bill_To_Address_SF_Id__c, String.valueOf(syncObj.Id));
                    dependenciesExist = true;
                }
                
                //Check for EBS Bill To Contact Id and trigger Contact Sync if unavailable
                if(syncObj.Related_Bill_To_Contact_EBS_Id__c == null){
                    IntegrationContact.resyncContactForOrderSync(syncObj.Related_Bill_To_Contact_SF_Id__c, String.valueOf(syncObj.Id));
                    dependenciesExist = true;
                }
                
                //Check for EBS Ship To Site Id and trigger Address Sync if unavailable
                if(syncObj.Related_Ship_To_Address_EBS_Id__c == null){
                    Address__c addr = new Address__c(Id = syncObj.Related_Ship_To_Address_SF_Id__c);
                    addr.Operating_Unit_Name__c = syncObj.Operating_Unit_Name__c;
                    update addr;
                    
                    IntegrationAddress.resyncAddressForOrderSync(syncObj.Related_Ship_To_Address_SF_Id__c, String.valueOf(syncObj.Id));
                    dependenciesExist = true;
                }
                
                //Check for EBS Ship To Contact Id and trigger Contact Sync if unavailable
                if(syncObj.Related_Ship_To_Contact_EBS_Id__c == null){
                    IntegrationContact.resyncContactForOrderSync(syncObj.Related_Ship_To_Contact_SF_Id__c, String.valueOf(syncObj.Id));
                    dependenciesExist = true;
                }
            }
            //All pre-requisite related data is synced with EBS
            if(!dependenciesExist){
                System.debug('EBSOrderSyncFrameworkTrigger: All Dependencies Resolved ** READY FOR ORDER SYNC');
                IntegrationOpportunity.resyncOpportunityForOrderSync(syncObj.Opportunity__c, String.valueOf(syncObj.Id));
            }
        } 
    }
}