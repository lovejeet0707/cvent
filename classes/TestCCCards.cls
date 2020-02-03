@isTest
public class TestCCCards{

   public static testMethod void CCcardsTrigger() {
        //create a new Card
         
       List<Mobile_Card__c> card = new List<Mobile_Card__c>  {new Mobile_Card__c(Name='test',
       Stage__c = 'Kick-Off',
       a_Preview_Date__c = system.today(),
       a_approval_Date__c = system.today(),
       a_released_Date__c = system.today())};
       
        insert card;
        
        List<Mobile_Card__c> card1 = new List<Mobile_Card__c>  {new Mobile_Card__c(Name='test1',
       Stage__c = 'Pending App Store Approval',
       a_Preview_Date__c = system.today(),
       a_approval_Date__c = system.today(),
       a_released_Date__c = system.today())};
       
        insert card1;
        
          
       List<Mobile_Card__c> card2 = new List<Mobile_Card__c>  {new Mobile_Card__c(Name='test2',
       Stage__c = 'Approved & Released',
       a_Preview_Date__c = system.today(),
       a_approval_Date__c = system.today(),
       a_released_Date__c = system.today())};
       
        insert card2;

        //create a new Task
        List<Task> t1 = new List<Task>{
        new task(OwnerId = UserInfo.getUserId(), 
        Status='Not Started',
        Subject='test subject',
        Priority='Normal',
        WhatId=card[0].Id)};
        
            
         insert t1;
         
          List<Task> t3 = new List<Task>{
        new task(OwnerId = UserInfo.getUserId(), 
        Status='Completed',
        Subject='test subject',
        Priority='Normal',
        WhatId=card[0].Id)};
        
            
         insert t3;
         
         List<Task> t4 = new List<Task>{
        new task(OwnerId = UserInfo.getUserId(), 
        Status='Not Started',
        Subject='test subject',
        Priority='Normal',
        WhatId=card[0].Id)};        
            
         insert t4;
         
                             test.startTest();
                             t1[0].status = 'Completed';
                             t1[0].subject = 'App Preview Sent to Customer';
                             
                             update t1;
                             
                             t3[0].subject = 'Submit iPhone App to Apple';
                              update t3;
         
                             t4[0].status = 'Completed';
                             t4[0].subject = 'Live App Links Sent to Customer';
                             
                             update t4;
                             
                             t3[0].subject = 'Final Preview Approved';
                              update t3;
         
         List<task> t2 = New List<task>{ [select id from task where id in :t1]};
     for(task tOK:t2)
     tOK.status = 'Completed';
   
                
                             update t2;
                             
                          

        Mobile_Card__c[] m1 = [select id, Stage__c,a_Preview_Date__c,a_approval_Date__c,a_released_Date__c from Mobile_Card__c where id in :card];
        //System.assertEquals('Preview & Iterate',m1[0].Stage__c );        
        //System.assertEquals(Date.today(), m1[0].a_Preview_Date__c);
       // System.assertEquals(system.today(), m1[0].a_approval_Date__c);
         //System.assertEquals(system.today(), m1[0].a_released_Date__c);
        
        Mobile_Card__c[] m2 = [select id, Stage__c,a_Preview_Date__c  from Mobile_Card__c where id in :card1];
        //System.assertEquals('Pending App Store Approval',m2[0].Stage__c );        
        //System.assertEquals(Date.today(), m2[0].a_Preview_Date__c);
        
         Mobile_Card__c[] m3 = [select id, Stage__c,a_Preview_Date__c  from Mobile_Card__c where id in :card2];
        //System.assertEquals('Approved & Released',m3[0].Stage__c );        
        //System.assertEquals(Date.today(), m3[0].a_Preview_Date__c);
        
        Test.stopTest();

        //the trigger has fired and we check that the card fields have been modified
        //List<Mobile_Card__c> cardList = [SELECT Id, stage__c, a_Preview_Date__c FROM Mobile_Card__c WHERE Id=:card.Id];
        //System.assertEquals('Preview & Iterate', cardList[0].stage__c);
        //System.assertEquals(Date.today(), cardList[0].a_Preview_Date__c);

    }
}