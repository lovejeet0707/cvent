@istest
public class testGDPR{

public static testMethod void testGDPRMEthod(){
    
    Account acc1  = new Account();
    acc1.name = 'Test';
    acc1.BillingCountry='US';
    acc1.BillingState='TX';
    insert acc1;
        
    Account acc  = new Account();
    acc.name = 'Test123';
    acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
    insert acc;
    
    Account accTest  = new Account();
    accTest.name = 'Test321';
    accTest.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
    insert accTest;
    
    Task t1 = new task();
    t1.WhatId= accTest.id;
    t1.subject ='test GDPR';
    t1.description ='testing GDPR';
    T1.Campaign_ID__c='01p000000008yz5AAA';
    t1.RecordTypeId = '0120000000099ns';
    insert t1;
    
    Event e1 = new event();
    e1.WhatId = accTest.id;
    e1.subject ='test GDPR';
    e1.description ='testing GDPR';
    e1.Campaign_ID__c='01p000000008yz5AAA';
    e1.DurationInMinutes =1;
    e1.ActivityDateTime = system.now();
    insert e1;
    
    case c1 = new case();
    c1.accountId =accTest.id;
    c1.subject= 'testing';
    c1.description='testtt';
    insert c1;
    
    AccountHistory accHist = new AccountHistory();
    accHist.AccountId= accTest.Id;
    accHist.Field = 'FirstName';
    insert accHist;
     
    accTest.Is_GDPR__c= true;
    update accTest;
    
    Lead TestLead1 = new Lead(LastName='TestLead 1', Company='Test Company', Status='Qualified');
    insert TestLead1;
    
    TestLead1.Company = 'Cvent'; 
    update TestLead1;
    
    Lead TestLead = new Lead(LastName='TestLead 1', Company='Test Company', Status='Qualified');
    insert TestLead;
    TestLead.is_GDPR__C = true;
    update TestLead;
   
    Contact con = new Contact();
    con.LastName = 'Test Contact';
    con.AccountId = acc1.Id;
    insert con;
    Test.startTest();     
    con.CC_Contact_Status__c = 'Suspect';
    update con;
    
    Contact conTest = new Contact();
    conTest.LastName = 'Test Contact';
    conTest.AccountId = acc1.Id;
    conTest.email='test@test123.com';
    conTest.Alternate_Email__c ='testing@test.com';
    insert conTest;
    
    conTest.CC_Contact_Status__c = 'Suspect';
    update conTest;
    
    
    Task t = new task();
    t.WhoId = conTest.id;
    t.subject ='test GDPR';
    t.description ='testing GDPR';
    T.Campaign_ID__c='01p000000008yz5AAA';
    t.RecordTypeId = '0120000000099ns';
    insert t;
    
    Event e = new event();
    e.WhoId = conTest.id;
    e.subject ='test GDPR';
    e.description ='testing GDPR';
    e.Campaign_ID__c='01p000000008yz5AAA';
    e.DurationInMinutes =1;
    e.ActivityDateTime = system.now();
    insert e;
    
    case c = new case();
    c.contactId =conTest.id;
    c.subject= 'testing';
    c.description='testtt';
    insert c;
    
    ContactHistory conHist = new ContactHistory();
    conHist.ContactId= conTest.Id;
    conHist.Field = 'CC_Contact_Status__c';
    insert conHist;
    
    conTest.is_gdpr__c = true;
    update conTest;

    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs (thisUser) {

     user u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
     LastName = 'last',
     Email = 'puser000@amamama.com',
     Username = 'puser000@amamama.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US'//,
   //  UserRoleId = '00E00000006omly',
    // isPortalEnabled=true,
    // contactId = conTest.id
     );
     insert u;
     
     u.Is_GDPR__c = true;
     update u;
    } 

    String CRON_EXP = '0 0 0 1 1 ? 2025';  
    String jobId = System.schedule('schedulercreateGDPRPersonaBatch', CRON_EXP, new schedulercreateGDPRPersonaBatch() );

    CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

    System.assertEquals(CRON_EXP, ct.CronExpression); 
    System.assertEquals(0, ct.TimesTriggered);
    System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct.NextFireTime));
            
    
    
    
// code for createGDPRPersonaBatch batch...........    
    GDPR_Central_Repository__c gdpr  = new GDPR_Central_Repository__c();
    gdpr.id__c = con.id; 
    gdpr.sObject_type__c ='Contact';
    gdpr.Is_GDPR__c = true;
    gdpr.LastName__c='testLastname';
    insert gdpr;
    
    GDPR_Central_Repository__c gdprLead  = new GDPR_Central_Repository__c();
    gdprLead.id__c = TestLead1.id; 
    gdprLead.sObject_type__c ='Lead';
    gdprLead.Is_GDPR__c = true;
    gdprLead.LastName__c='testLastname';
    insert gdprLead;
    
    GDPR_Central_Repository__c gdprAcc  = new GDPR_Central_Repository__c();
    gdprAcc.id__c = acc.id; 
    gdprAcc.sObject_type__c ='Person Account';
    gdprAcc.Is_GDPR__c = true;
    gdprAcc.LastName__c='testLastname';
    insert gdprAcc;
    
    String CRON_EXP2 = '0 0 0 1 1 ? 2025';  
    String jobId2 = System.schedule('schedulerCreateGDPRHistory', CRON_EXP2, new schedulerCreateGDPRHistory() );

    CronTrigger ct2 = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId2];

    System.assertEquals(CRON_EXP2, ct2.CronExpression); 
    System.assertEquals(0, ct2.TimesTriggered);
    System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct2.NextFireTime));
                        
    LIST<GDPR_Central_Repository__c> gdprObj = NEW LIST<GDPR_Central_Repository__c> ();       
    gdprObj =[select id,Is_GDPR__c ,Follow_Up_Created__c from GDPR_Central_Repository__c where id__c = : conTest.id];
    IF(gdprObj.SIZE() > 0){
    gdprObj[0].Is_GDPR__c = false;
    gdprObj[0].Follow_Up_Created__c= true;    
    update gdprObj;
    

    // code for deleteGDPRPersonaBatch batch...........
    GDPR_Persona_Data__c gdpPersona = new GDPR_Persona_Data__c();
    gdpPersona.sObject_type__c ='Task';
    gdpPersona.id__C = t.id;
    gdpPersona.GDPR_Central_Repository__c = gdprObj[0].id;
    gdpPersona.Task_Subject__c = 'GDPR- test GDPR';
    gdpPersona.Comments__c = 'GDPR- testing GDPR';
    insert gdpPersona;
    
    GDPR_Persona_Data__c gdpPersona1 = new GDPR_Persona_Data__c();
    gdpPersona1.sObject_type__c ='Event';
    gdpPersona1.id__C = e.id;
    gdpPersona1.GDPR_Central_Repository__c = gdprObj[0].id;
    gdpPersona1.Task_Subject__c = 'GDPR- test GDPR';
    gdpPersona1.Comments__c = 'GDPR- testing GDPR';
    insert gdpPersona1;
    
    GDPR_Persona_Data__c gdpPersona2 = new GDPR_Persona_Data__c();
    gdpPersona2.sObject_type__c ='Case';
    gdpPersona2.id__C = c.id;
    gdpPersona2.GDPR_Central_Repository__c = gdprObj[0].id;
    gdpPersona2.Task_Subject__c = 'GDPR- test GDPR';
    gdpPersona2.Comments__c = 'GDPR- testing GDPR';
    insert gdpPersona2;
    
  //  gdprObj.Follow_Up_Created__c= true;    
 //   update gdprObj;
    
    gdprObj[0].Is_GDPR__c = false;
    update gdprObj;
    }
      
            
    String CRON_EXP1 = '0 0 0 1 1 ? 2025';  
    String jobId1 = System.schedule('schedulerdeleteGDPRPersonaBatch', CRON_EXP1, new schedulerdeleteGDPRPersonaBatch() );

    CronTrigger ct1 = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId1];

    System.assertEquals(CRON_EXP1, ct1.CronExpression); 
    System.assertEquals(0, ct1.TimesTriggered);
    System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct1.NextFireTime));
    
    
    gdprLead.Is_GDPR__c = false;
    update gdprLead;
    
    
    gdprAcc.Is_GDPR__c = false;
    update gdprAcc;
    
                       
   Test.stopTest();    
   }
    
}