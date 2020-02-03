trigger supportCaseDel on Case(before delete) {
    
    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    } 

    String UserId = UserInfo.getuserId();
    String profileId = UserInfo.getprofileId();
    //user userRec =  [Select id from user where IsActive = True and userName like '%eglazyrin%' limit 1]; 
    Profile userPro =  [Select id from Profile where Name = 'System Administrator'];  
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>(); 
    String[] toAddresses = new String[]{'vaibhav.jain@cvent.com'};
    for(Case c : trigger.old){
        if(/*UserId != userRec.Id &&*/ c.RecordTypeId == '012o0000000GiLz' && profileId != userPro.id) {
            c.addError('You are not authorised to delete this Case.');
        }
    }
    if(mails.size()>0)
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>(mails));
}