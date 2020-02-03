/* ***************************************************************************************************************
 * Trigger Name:OppDeleteCS 
 * Author: Rishi Ojha
 * Date: 21-May-2014
 * Requirement # We need to prevent Opportunity deletion by client services team
 * Description: # Based on the below criterias mentioned in the code, restricting users to delete an Opportunity 
                
***************************************************************************************************************** */
    trigger OppDeleteCS on Opportunity (before delete) {
        /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
        if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
                return;
        } 

        String ProfileId = UserInfo.getProfileId();
        String Userid = UserInfo.getUserId();
        system.debug('@@@@@UserId'+UserInfo.getUserId());
        List<Profile> userRec =  [Select id from Profile where id = '00e00000006xpYL' or Name = 'System Administrator'];   
        for(opportunity  opp : trigger.old){
            if (Opp.LeadSource == 'Client Services' && (ProfileId != userRec[0].Id && ProfileId != userRec[1].Id && UserInfo.getUserId() != '005000000079DxBAAU')){
                Opp.addError('You cannot delete opportunities created by Client Services');
            }
        }
    }