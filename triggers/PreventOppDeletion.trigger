/*Created By Rishi Ojha
    ===============================================================================
    This trigger will prevent Opportunity deletion based on the mentioned conditions
    Test class for the Trigger is : TestPreventOppTrigger
    ===============================================================================*/
    
    trigger PreventOppDeletion on Opportunity (before delete) {
    
        /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
        if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
                return;
        } 

        String UserId = UserInfo.getuserId();
        user userRec =  [Select id from user where id = '005000000079DxB' limit 1];   
        
              for(opportunity  opp : trigger.old)
              {
              if (UserId != userRec.Id && (opp.StageName == 'Closed Won'||opp.StageName == 'Closed Lost') && opp.New_Type__c.startswith('Renewal')) {Opp.addError('You are not authorised to delete this Opportunity.');
              }
              
             }
    
    }