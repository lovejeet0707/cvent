/**=====================================================================
* Cvent
* Name: TestDataFactory 
* Description: It will create a common Test Record for all the Test Classes.
* Created Date: [22/07/2016]
* Created By: Hemant Rana
* 
* Date Modified                Modified By                  Description of the update
* [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
=====================================================================*/ 

@isTest
public class TestDataFactory {
    @testSetup public static void createTestRecord() {
        Integer numAccts=2; Integer numConPerAccts=4;Integer numTaskPerConts=3;

        //Inserting User...............
        Profile p = [SELECT Id FROM Profile WHERE Name='Finance - Management']; 

        USerrole[] testroleId=[select id from userRole where name ='AM (Event)' OR name ='Pre Sales - Special Projects' limit 2];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Sops', LanguageLocaleKey='en_US', FirstName='TestUser',
        LocaleSidKey='en_US', ProfileId = p.Id, userRoleId=testroleId[0].id,
        TimeZoneSidKey='America/Los_Angeles', UserName='Test'+'deploymentuser@cvent.com');
        
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Sops', LanguageLocaleKey='en_US', FirstName='TestUser',
        LocaleSidKey='en_US', ProfileId = p.Id, userRoleId=testroleId[1].id,
        TimeZoneSidKey='America/Los_Angeles', UserName='TestIST'+'deploymentuser@cvent.com');
        
        system.runAs(u){
            //Insert Account
            List<Account> accts = new List<Account>();
            for(Integer i=0;i<numAccts;i++) {
                Account a = new Account(Name='TestAccount' + i);
                accts.add(a);
            }
            insert accts;
            //Insert Contact        
            List<Contact> contList = new List<Contact>();
            for (Integer j=0;j<numAccts;j++) {
                Account acct = accts[j];
                // For each account just inserted, add opportunities
                for (Integer k=0;k<numConPerAccts;k++) {
                    contList.add(new Contact(LastName=acct.Name + ' Contact ' + k,
                    AccountId=acct.Id,Event_Contact_Status__c='Marketing Qualified'));
                }
            }
            insert contList;
            //Insert Task
            List<Task> taskList = new List<Task>();
            for (Integer j=0;j<numConPerAccts;j++) {
                Contact cont = contList[j];
                // For each account just inserted, add opportunities
                for (Integer k=0;k<numTaskPerConts;k++) {
                    taskList.add(new Task(Subject=cont.LastName + ' Marketing Qualified ' + k,OwnerId=u.Id,
                    WhoId=cont.Id));
                    taskList.add(new Task(Subject=cont.LastName + ' Marketing Qualified OD-CC ' + k,OwnerId=u.Id,
                    WhoId=cont.Id));
                    taskList.add(new Task(Subject=cont.LastName + ' Marketing Qualified OD-CC ' + k,OwnerId=u.Id,
                    WhoId=cont.Id,Product__c='Cvent Connect',Status='Completed'));
                    taskList.add(new Task(Subject=cont.LastName + ' Marketing Qualified OD-CC ' + k,OwnerId=u.Id,
                    WhoId=cont.Id,Product__c='Cvent Connect;Diamonds',Status='Completed'));
                }
            }
            insert taskList;
        }
        //Inserting new Task with different OWNER Id
        system.runAs(u1){
            //Insert Account
            List<Account> accts = new List<Account>();
            for(Integer i=0;i<numAccts;i++) {
                Account a = new Account(Name='TestAccount' + i);
                accts.add(a);
            }
            insert accts;
            //Insert Contact        
            List<Contact> contList = new List<Contact>();
            for (Integer j=0;j<numAccts;j++) {
                Account acct = accts[j];
                // For each account just inserted, add opportunities
                for (Integer k=0;k<numConPerAccts;k++) {
                    contList.add(new Contact(LastName=acct.Name + ' Contact ' + k,
                    AccountId=acct.Id,Event_Contact_Status__c='Marketing Qualified'));
                }
            }
            insert contList;
            //Insert Task
            List<Task> taskList = new List<Task>();
            for (Integer j=0;j<numConPerAccts;j++) {
                Contact cont = contList[j];
                // For each account just inserted, add opportunities
                for (Integer k=0;k<numTaskPerConts;k++) {
                    taskList.add(new Task(Subject=cont.LastName + ' Marketing Qualified ' + k,OwnerId=u1.Id,
                    WhoId=cont.Id));
                    taskList.add(new Task(Subject=cont.LastName + ' Marketing Qualified OD-CC ' + k,OwnerId=u1.Id,
                    WhoId=cont.Id,Status='Completed'));
                    taskList.add(new Task(Subject=cont.LastName + ' Marketing Qualified OD-CC ' + k,OwnerId=u1.Id,
                    WhoId=cont.Id,Product__c='Cvent Connect',Status='Completed'));
                    taskList.add(new Task(Subject=cont.LastName + ' Marketing Qualified OD-CC ' + k,OwnerId=u1.Id,
                    WhoId=cont.Id,Product__c='Cvent Connect;Diamonds',Status='Completed'));
                }
            }
            insert taskList;
        }
    }
}