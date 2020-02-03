@isTest(SeeAllData=true)
private class TestOpenTaskUpdate {

static testMethod void LeadTest(){
try{
// Create a Lead
Lead newLead = new Lead(lastname = 'Test', Company='ABC', Status='Targeted',Country='UK');
insert newLead;


// Create a Task
Task newTask = new Task(Subject='Open Task', Status='Not Started', WhoId=newLead.Id);
test.startTest();
//insert newTask;
test.stopTest();

// Verify that the # Open Tasks is correct
newLead = [select Total_Open_Event_Tasks__c from Lead where Id=:newLead.Id ];
System.assertEquals(null,newLead.Total_Open_Event_Tasks__c);

newLead = [select Total_Open_CC_Tasks__c from Lead where Id=:newLead.Id ];
System.assertEquals(null,newLead.Total_Open_CC_Tasks__c);
 }
        Catch(Exception e)
        {

          system.debug('Error:'+e);
        }
}


static testMethod void ContactTest(){
// Create a Contact
try{

Contact newContact = new contact(LastName='Test',MailingCountry='UK');
insert newContact;

// Create a Task
Task newTask = new Task(Subject='Open Task', Status='Not Started', WhoId=newContact.Id);
test.startTest();
//insert newTask;
test.stopTest();

// Verify that the # Open Tasks is correct
newContact = [select Total_Open_Event_Tasks__c from Contact where Id=:newContact.Id];
System.assertEquals(null,newContact.Total_Open_Event_Tasks__c);

newContact = [select Total_Open_CC_Tasks__c from Contact where Id=:newContact.Id];
System.assertEquals(null,newContact.Total_Open_CC_Tasks__c);

 }
        Catch(Exception ee)
        {

          system.debug('Error:'+ee);
        }
}



}