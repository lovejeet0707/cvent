//////////// Test class for trigger EventTimeSpentME /////////////////////////
                //////// Created by Rohit saxena //////////

@isTest
private class TestMinuteOnEvent
{
  public static testMethod void testEventTimeSpent()
  {
    test.startTest();

    
      
    Mobile_Card__c mc = new Mobile_Card__c (Name ='test');
    insert mc;
    Mobile_Card__c mc1 = new Mobile_Card__c (Name ='test1');
    insert mc1;
    Mobile_Card__c mc2 = new Mobile_Card__c (Name ='test2');
    insert mc2;    
       

    Event e1 = new Event(OwnerId = UserInfo.getUserId(), Subject='Qualifying Call', Source__c='Chat',
                        Minutes_on_tasks__c = 2000,DurationInMinutes=55,ActivityDateTime=System.today(), WhatId = mc.Id);
                        
    Event e2 = new Event(OwnerId = UserInfo.getUserId(), Subject='Qualifying Call', Source__c='Chat',
                        Minutes_on_tasks__c = 500,DurationInMinutes=60,ActivityDateTime=System.today(), WhatId = mc.Id);

    Event e3 = new Event(OwnerId = UserInfo.getUserId(), Subject='Qualifying Call', Source__c='Chat',
                        Minutes_on_tasks__c = 30,DurationInMinutes=60,ActivityDateTime=System.today(), WhatId = mc1.Id);
                        
    Event e4 = new Event(OwnerId = UserInfo.getUserId(), Subject='Qualifying Call',
                        Minutes_on_tasks__c =0 ,DurationInMinutes=60,ActivityDateTime=System.today(), WhatId = mc2.Id);                    

   
    

    insert e1;
    insert e2;
    insert e3;
    insert e4;
    
    update mc;
    delete e4;
    e2.Source__c='Chat';
    Update e2;
    delete e2;
    Test.stopTest();
  }
}