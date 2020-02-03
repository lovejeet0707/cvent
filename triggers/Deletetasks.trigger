trigger Deletetasks on Task (before delete)
{
    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    } 

    String ProfileId = UserInfo.getuserId();
     

     for  (task q: trigger.old)

       if (ProfileId == '00500000006scDCAAY' || ProfileId == '00500000007CsfE' )
       {
       
        if (q.Ownerid <> '00500000007CsfE' && q.Ownerid <> '00500000006scDCAAY')
     
        
          {
         
           q.adderror('You are not authorised to delete this task');
          
          } 
          
          
          }
          
        
}