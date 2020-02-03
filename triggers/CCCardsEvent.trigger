trigger CCCardsEvent on Event (after insert, after update) {
    
    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    }
    

    //Preparting CCCards to Update
    public list<Mobile_Card__c> CardsToUpdate = new List<Mobile_Card__c>();
    public set<Id> MobileCardIDs = new Set<Id>();
    

 if(Trigger.isInsert){

 for(Event t : Trigger.new)
 {
      
         if(t.EndDateTime > system.now() && t.subject.contains('CrowdCompass Kick-Off Call'))
         {
          
           MobileCardIDs.add(t.WhatId);          
           for(Mobile_Card__c c : [Select c.Id, c.stage__c From Mobile_Card__c c where Id in :MobileCardIDs])
             {
                     c.stage__c = 'Pending Kick-Off';
                     CardsToUpdate.add(c);                
             } 
             update CardsToUpdate;
         }
  }
  }
  
 if(Trigger.isUpdate){

 for(Event t : Trigger.new)
 {
      
          if(t.EndDateTime < system.now() && t.subject.contains('CrowdCompass Kick-Off Call'))
         {
          
           MobileCardIDs.add(t.WhatId);          
           for(Mobile_Card__c c : [Select c.Id, c.stage__c From Mobile_Card__c c where Id in :MobileCardIDs])
             {
                   c.stage__c = 'Graphics & Data';
                   c.a_Kickoff_Date__c = system.today();
                   CardsToUpdate.add(c);                
             } 
             update CardsToUpdate;
         }
  }
  }
  
  
  }