/*
 * Name: EBSOpportunityTrigger
 * Description: This trigger is created during BOSS implementation and used exclusively for Salesforce to EBS Integration related functionality. 
 *              The primary purpose is to check and tag any EBS Synced (with EBS Site Id) Addresses (Billing and Shipping) from the associated Account. 
 *              All orders are generated manually by Finance team by clicking the "Send to EBS" button on Opportunity layout.
 * 
 *  History:
 *  Date            Version     Change/Description                          Author
 * -------------------------------------------------------------------------------------------
 *  April 15, 2017  1.0         Created                                     Praveen Kaushik
 * -------------------------------------------------------------------------------------------
*/
trigger EBSOpportunityTrigger on Opportunity (before insert)
{
    /* Skip execution if this user is not setup for EBS Data Sync 
    boolean syncEnabled = BypassTriggerUtility.isEBSSyncEnabledForThisUserOrProfileId(UserInfo.getUserId());
    if(syncEnabled) {*/
        List<Opportunity> newList = Trigger.new;
        OpportunityDefaultBillingShipping.UpdateOppBillingShipping(newList);
    //}
}