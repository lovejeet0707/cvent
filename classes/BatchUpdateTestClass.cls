@isTest
public class BatchUpdateTestClass{
    
    static testMethod void batchUpdateContactsTest()
    {
        BatchUpdateContactFields__c customSetting = new BatchUpdateContactFields__c();
        customSetting.Name = 'HasOptedOutOfEmail';
        insert customSetting;
        
        Account instofAcc1 = TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc1.Supplier_Type__c = 'Venue';
        instofAcc1.Venue_Type__c = 'CVB';
        instofAcc1.Phone = '056465465465';
        insert instofAcc1;
        
        Contact instContactFif1 = TestUtil.createContact(String.valueOf(instofAcc1.Id));
        instContactFif1.HasOptedOutOfEmail = false;
        instContactFif1.Email = 'TestbatchUpdateContactsTest@email.com';
        instContactFif1.BatchFlag__c = true;
        insert instContactFif1;
        
        
        Contact instContactFif2 = TestUtil.createContact(String.valueOf(instofAcc1.Id));
        instContactFif2.HasOptedOutOfEmail = false;
        instContactFif2.Email = 'TestbatchUpdateContactsTest@email.com';
        insert instContactFif2;
        
        Test.startTest();
        String CRON_EXP1 = '0 0 0 1 1 ? 2025';  
        String jobId1 = System.schedule('schedulerBatchUpdateContacts', CRON_EXP1, new SchedulerBatchUpdateContacts() );
        
        CronTrigger ct1 = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId1];
        
        List<List<sObject>> lstWrapper = new List<List<sObject>>();
        Id batchJobId = Database.executeBatch(new BatchUpdateContacts(false,0,lstWrapper,0,new Map<Id,String>()), 200);
        Test.stopTest();
    }
    
    static testMethod void batchUpdateLeadsTest()
    {
        BatchUpdateContactFields__c customSetting = new BatchUpdateContactFields__c();
        customSetting.Name = 'HasOptedOutOfEmail';
        insert customSetting;
        
        Lead le = new Lead();
        le.LastName = 'Test Lead 25';
        le.CountryCode = 'IN';
        le.Phone = '056465465465';
        le.MobilePhone = '056465465465';
        le.Email = 'TestbatchUpdateLeadsTest@email.com';
        le.Other_Phone__c = '056465465465';
        le.BatchFlag__c = true;
        
        insert le;
        
        Lead le1 = new Lead();
        le1.LastName = 'Test Lead 254';
        le1.CountryCode = 'IN';
        le1.Phone = '056465465465';
        le1.MobilePhone = '056465465465';
        le1.Email = 'TestbatchUpdateLeadsTest@email.com';
        le1.Other_Phone__c = '056465465465';
        
        insert le1;
        
        Test.startTest();
        String CRON_EXP1 = '0 0 0 1 1 ? 2025';  
        String jobId1 = System.schedule('schedulerBatchUpdateLeads', CRON_EXP1, new SchedulerBatchUpdateLeads() );
        
        CronTrigger ct1 = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId1];
        
        List<List<sObject>> lstWrapper = new List<List<sObject>>();
        Id batchJobId = Database.executeBatch(new BatchUpdateLeads(false,0,lstWrapper,0,new Map<Id,String>()), 200);
        Test.stopTest();
    }
}