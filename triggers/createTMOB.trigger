//Created BY Rishi Ojha 
    //Creating TM onboarding records when opportunities are closed won 
    //Updating the Name field of TM onboarding with Opp name ..
    //TM Onboarding name should be Acc name 
    //Starts with NBB
    
    trigger createTMOB on Opportunity (after insert, after update) {
        
        List<TM_Buildout__c> TMToInsert = new List<TM_Buildout__c>  (); 
        List<Opportunity> lstOpp = [Select Id, AccountId, MYD_Deal__c, NBB_Renewal__c,Parent_Upsell__c, Account.Name, StageName, TM_ID__c, Account_Name_TM__c, Product__c,New_Type__c,(Select id from TM_Buildout__r) from Opportunity where id in: trigger.newmap.keyset()];
        for (Opportunity o : lstOpp)
        {
           
      if ( ((Trigger.isInsert) || (Trigger.isUpdate) ) && (o.StageName == 'Closed Won' && o.Product__c == 'TicketMob' && o.NBB_Renewal__c.startswith('NBB') && o.Parent_Upsell__c == 'Primary' && o.MYD_Deal__c == 'First Year') && o.TM_Buildout__r.size() == 0)
        {
         if(HelperClassforCreateTMOB.firstRun){
            TM_Buildout__c tm = new TM_Buildout__c ();         
            
            tm.Opportunity__c = o.Id ; 
            tm.Name=o.Account_Name_TM__c;
            tm.OwnerId=o.TM_Id__c;
            tm.Account__c=o.AccountId;
            TMToInsert.add(tm);
            HelperClassforCreateTMOB.firstRun=false;
            }
         }
            
        }
        
        
        try {
            insert TMToInsert; 
        } catch (system.Dmlexception e) {
            system.debug (e);
        }
    }