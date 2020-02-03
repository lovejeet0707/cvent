@isTest(SeeAllData=true)
private class testMyTaskTrigger {
 
    public static testMethod void testTTrigger(){
      
        
        Account acc  = new Account();
        acc.name = 'Test';
        insert acc;

       
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.AccountId = acc.Id;
        insert con;

       
       
       // Task t = new Task();
        //t.OwnerId = UserInfo.getUserId();
      //  t.Subject='Donni';
      //  t.Status='Not Started';
      //  t.Priority='Normal';
      //  t.Minutes_on_tasks__c = 2000;
      //  t.status = 'Completed';
      //  insert t;
 
        Task tas = new Task();
        tas.OwnerId = UserInfo.getUserId();
        tas.Subject='Donni';
        tas.Status='Not Started';
        tas.Priority='Normal';
        tas.Minutes_on_tasks__c = 2000;
        tas.status = 'Completed';
        tas.whoid = con.id;

        Sales_Resources__c sr = new Sales_Resources__c ();
        sr.Name = 'Test Sales Resources';
        insert sr;
        
        Task p = [select id from task where Ownerid = '00500000006scDCAAY' limit 1];
         try{
        delete p;
        }
        Catch(Exception e)
        {

          system.debug('Error:'+e);
        }
  
       
        Test.startTest();
       // insert tas; 
        try{
        delete tas;
        }
        Catch(Exception e)
        {

          system.debug('Error:'+e);
        }

        Test.stopTest();
       
     }

}