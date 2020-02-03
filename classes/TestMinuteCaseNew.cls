@isTest
private class TestMinuteCaseNew
{
  public static testMethod void testTTrigger()
  {
    test.startTest();

    Sales_Resources__c sr1 = new Sales_Resources__c (Name = 'Test Sales Resources1');
    Sales_Resources__c sr2 = new Sales_Resources__c (Name = 'Test Sales Resources2');
    Mobile_Card__c mb = new Mobile_Card__c (Name = 'test mobile card');
    insert sr1;
    insert sr2;
    insert mb;
	List<Task> taskList = new List<Task>();
    Task t1 = new Task(OwnerId = UserInfo.getUserId(), Subject='Donni', Priority='Normal',Minutes_on_tasks__c = 2000, Status = 'Completed', WhatId = sr1.Id);
    Task t3 = new Task(OwnerId = UserInfo.getUserId(), Subject='Donni', Priority='Normal',Minutes_on_tasks__c = 500, Status = 'Not Started', WhatId = sr1.Id);
    Task t2 = new Task(OwnerId = UserInfo.getUserId(), Subject='Donni', Priority='Normal',Minutes_on_Case__c  = 500, Status = 'Completed', WhatId = mb.Id);
    Task t4 = new Task(OwnerId = UserInfo.getUserId(), Subject='Donni', Priority='Normal',Minutes_on_Case__c  = 100, Status = 'Not Started', WhatId = mb.Id);
	Task t5 = new Task(OwnerId = UserInfo.getUserId(), Subject='Donni', Priority='Normal',Minutes_on_tasks__c = 2000, Status = 'Completed', WhatId = mb.Id);
    Task t6 = new Task(OwnerId = UserInfo.getUserId(), Subject='Donni', Priority='Normal',Minutes_on_tasks__c = 500, Status = 'Not Started', WhatId = mb.Id);

    taskList.add(t1);
	taskList.add(t2);
	taskList.add(t3);
	taskList.add(t4);
	taskList.add(t5);
	taskList.add(t6);
	insert taskList;
	
	taskList.clear();
    t3.Status = 'Completed';
	t6.Status = 'Completed';
	t4.Status = 'Completed';
	
	taskList.add(t3);
	taskList.add(t6);
	taskList.add(t4);
	update taskList;
	delete taskList;
    
    Test.stopTest();
  }
}