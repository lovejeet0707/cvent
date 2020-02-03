/*
 * Name: EBSContactAddressTrigger
 * Description: This trigger is created during BOSS implementation and used exclusively for Salesforce to EBS Integration related functionality. 
 * 				It performs the following functions:
 * 				- Trigger a Sync with EBS for new Contact Addresses
 * 				- Watch for any updates to EBS Integration related fields and trigger a Sync with EBS
 * 
 *  History:
 *  Date			Version 	Change/Description							Author
 * -------------------------------------------------------------------------------------------
 *  April 15, 2017	1.0			Created										Praveen Kaushik
 * -------------------------------------------------------------------------------------------
*/
trigger EBSContactAddressTrigger on Address_Contact__c (after insert, after update) 
{
     /* Skip execution if this user is not setup for EBS Data Sync */
    boolean syncEnabled = BypassTriggerUtility.isEBSSyncEnabledForThisUserOrProfileId(UserInfo.getUserId());
    if(syncEnabled) {
        if(Trigger.isInsert)
        {
            List<Address_Contact__c> newList=Trigger.new;
            if(Trigger.isBefore)
            {
                
            }
            else if(Trigger.isAfter)
            {
                IntegrationAddressContact.handleNewAddressContacts(newList);
            }
        }
        else if(Trigger.isUpdate)
        {
            List<Address_Contact__c> newList=Trigger.new;
            Map<Id,Address_Contact__c> oldMap=Trigger.oldMap;
            if(Trigger.isBefore)
            {
            }
            else if(Trigger.isAfter)
            {
                IntegrationAddressContact.handleUpdatedAddressContactss(newList,oldMap);
            }
        }
    }
}