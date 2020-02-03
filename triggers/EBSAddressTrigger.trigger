/*
 * Name: EBSAddressTrigger
 * Description: This trigger is created during BOSS implementation and used exclusively for Salesforce to EBS Integration related functionality. 
 *              It performs the following functions:
 *              - Trigger a Sync with EBS If the parent Account EBS Id is available (new addresses)
 *              - Watch for any updates to EBS Integration related fields and trigger a Sync with EBS
 * 
 *  History:
 *  Date            Version     Change/Description                          Author
 * -------------------------------------------------------------------------------------------
 *  April 15, 2017  1.0         Created                                     Praveen Kaushik
 * -------------------------------------------------------------------------------------------
*/
trigger EBSAddressTrigger on Address__c (before insert,after insert,before update,after update,before delete)
{

    //Validate country codes
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        AddressValidator.validateCountryCode(trigger.new, trigger.oldMap);
    }

    /* Skip execution if this user is not setup for EBS Data Sync */
    boolean syncEnabled = BypassTriggerUtility.isEBSSyncEnabledForThisUserOrProfileId(UserInfo.getUserId());
    if(syncEnabled) {
    
        List<Address__c> newList=Trigger.new;
        Set<ID> adrIds = new Set<ID> ();
        
        if(Trigger.isInsert)
        {
            if(Trigger.isBefore)
            {
                Map<Id,Address__c> oldMap=new Map<Id,Address__c>();
                
                IntegrationAddress.handleAddressUpdates(newList,oldMap);
            }
            else if(Trigger.isAfter)
            {
                IntegrationAddress.handleNewAddresses(newList);
                
                //Validate Address and Update the Address Validation field with status - Added on 04/10/2018
                for(Address__c adr : newList){
                    if(adr.Type__c == 'Shipping')
                        adrIds.add(adr.Id);
                }
            }
            
        }
        else if(Trigger.isUpdate)
        {
            Map<Id,Address__c> oldMap=Trigger.oldMap;
            if(Trigger.isBefore)
            {
                IntegrationAddress.handleAddressUpdates(newList,oldMap);
            }
            else if(Trigger.isAfter)
            {
                
                IntegrationAddress.handleUpdatedAddresses(newList,oldMap);
                
                //Validate Address and Update the Address Validation field with status - Added on 04/10/2018
                for(Address__c adr : newList){
                
                    Address__c oldadr = oldMap.get(adr.Id);
                    
                    //Trigger validation and sync to EBS only when 
                    if(adr.Type__c == 'Shipping' && ( adr.Address_Validation__c !=oldadr.Address_Validation__c || adr.Is_EBS_Synced__c!=oldadr.Is_EBS_Synced__c ||
                    adr.Postal_Code__c!=oldadr.Postal_Code__c || adr.City__c!=oldadr.City__c || adr.Country__c!=oldadr.Country__c || adr.State__c!=oldadr.State__c)){
                        adrIds.add(adr.Id);
                    }
                }
            }
            
        }
        if(!System.isFuture() && !System.isBatch()){
            //Validate Address in Bulk at a time 100 allowed
            AddressValidator.validateShippingAddressBulk(adrIds);
        }
    }
    
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            IntegrationAddress.validationRestrictingPrimarySync(Trigger.new,null);
        }
       	if(Trigger.isUpdate)
        {
          	IntegrationAddress.validationRestrictingPrimarySync(Trigger.new,Trigger.oldMap);
        }
    }
}