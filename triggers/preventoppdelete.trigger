/*Created By Rishi Ojha
    ===============================================================================
    This trigger will prevent Opportunity deletion based on the mentioned conditions
    Test class for the Trigger is : TestoppTrigger
    ===============================================================================*/
trigger preventoppdelete on opportunity (before delete){
    
    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    } 

    String UserId = UserInfo.getuserId();
    user userRec = [Select id from user where id = '005000000079DxB' limit 1];     
       
     for(opportunity o : trigger.old){

       if (UserId != userRec.Id && o.StageName == 'Closed Won'&& o.CFC_Check__c != null && o.Contract_Implemented__c == True){ o.adderror('You are not authorised to delete this Opportunity');
       } 
     }          
}