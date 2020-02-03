@isTest
public class TestCCCardsEvent {

    static testMethod void CCCardsEvent() {
        //create a new Card
        
           List<Event> e4  = new  List<Event>();
        
        datetime dtstart = Datetime.newInstance(2012, 5, 12, 00, 00, 00); //Année/Jour/Mois hh/mm/ss
        datetime dtend = Datetime.newInstance(2012, 5, 12, 01, 00, 00);
        datetime dtstart1 = system.now();
        datetime dtend1 = system.now().adddays(1);
        
       List<Mobile_Card__c> card1 = new List<Mobile_Card__c> {new Mobile_Card__c(Name='test2',
       Stage__c = 'Pending Kick-Off'
       )};
       
        insert card1;
        
       List<Mobile_Card__c> card = new List<Mobile_Card__c>  {new Mobile_Card__c(Name='test',
       Stage__c = 'Graphics & Data',
       a_Kickoff_Date__c = system.today())};
       
        insert card;       
        
            List<Event> E1 = new List<Event>{new Event(WhatId=card[0].Id,
         Subject='test subject',
         StartDateTime=dtstart,
         EndDateTime=dtend)};
         
        insert E1;
    
      Event ee = new Event();
      ee.Subject='test subject';
         ee.StartDateTime=dtstart1;
        ee.EndDateTime = dtend1;
        ee.WhatId=card1[0].Id;
         e4.add(ee);
      
       Event e8 = new Event();
      e8.Subject='CrowdCompass Kick-Off Call';
         e8.StartDateTime=dtstart1;
        e8.EndDateTime = dtend1;
        e8.WhatId=card1[0].Id;
        e4.add(e8);
        
        Test.startTest();
         
       
        //new List<Event> {new Event(WhatId=card1[0].Id,
        // Subject='CrowdCompass Kick-Off Call',
       //  StartDateTime=dtstart,
         //EndDateTime = dtend)};
         
      insert e4;

    
        
        
        
        
        //we simulate the trigger conditions
     //    E2[0].subject = 'CrowdCompass Kick-Off Call';
       //     E2[0].StartDateTime = dtstart1;
          //    E2[0].EndDateTime = dtend1; 
       //   update E2;
          
        //    insert E2;
        
        
         E1[0].subject = 'CrowdCompass Kick-Off Call';
                  
          update E1;
                   
                          
           // System.assertEquals('2009-08-12 05:00:00', ' ' + E1[0].EndDateTime);
           Mobile_Card__c[] m2 = [select id, Stage__c from Mobile_Card__c where id in :card1];
         System.assertEquals('Pending Kick-Off',m2[0].Stage__c );
                    
            
       Mobile_Card__c[] m1 = [select id, Stage__c,a_Kickoff_Date__c from Mobile_Card__c where id in :card];
       System.assertEquals('Graphics & Data',m1[0].Stage__c ); 
       System.assertEquals(Date.today(), m1[0].a_Kickoff_Date__c);
        
        
        Test.stopTest();

        //the trigger has fired and we check that the card fields have been modified
        //List<Mobile_Card__c> cardList = [SELECT Id, stage__c, a_Kickoff_Date__c FROM Mobile_Card__c WHERE Id=:card.Id];
        //System.assertEquals('Graphics & Data', cardList[0].stage__c);
       

    }
}