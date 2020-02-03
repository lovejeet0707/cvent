//========================Created By Rishi Ojha dated 30/07/13====================================

//=========This trigger is created to capture the first activity date on Contacts records===========
//=========Test class for this trigger is >>TestActivitytriggerEvent


trigger FirstActivityevent  on Event (after insert,after update) {

    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    }
 if(createGDPRPersonaBatch.bypassGDPR == false ){   // createGDPRPersonaBatch.bypassGDPR added by Udita to bypass the trigger for GDPR Processed records (5/23/2018))
  Set<Id> RecordIds=new Set<Id>();
    for (Event evntObj: Trigger.new){
        
        RecordIds.add(evntObj.WhoId);
    
    }
    List<Contact> conList=new List<Contact>();
    for(Contact con:[Select id,(SELECT ActivityDate FROM ActivityHistories Where ActivityDate<=Today Order By ActivityDate ASC Limit 1) from Contact where id in:RecordIds])
    {
         if(con.ActivityHistories.size()>0)
         {
         con.First_ACTIVITY_Date__c=con.ActivityHistories[0].ActivityDate;
         conList.add(con);
        // con.Apex_context__c=True;//UD:Commented for FP:4thApril
         } 
         else 
         { 
         con.First_ACTIVITY_Date__c=null; 
         conList.add(con);
        // con.Apex_context__c=True;//UD:Commented for FP:4thApril
         }
         
    }
    
    if(conList.size()>0)
    {
    update conList;
    }
   }
 }