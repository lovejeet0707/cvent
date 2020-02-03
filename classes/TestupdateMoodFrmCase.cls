@isTest(Seealldata=true)
private class TestupdateMoodFrmCase {
    public static Account instofAcc = new Account();
   static testMethod void updateMoodFrmCaseTest(){
   
        Case_Settings__c settings       = new Case_Settings__c();
        settings.Name                   = 'CaseStatusTest1313';
        settings.X24_hrs_SLA__c         = 'ReOpened,Escalated';
        settings.Case_Status__c         = 'Open - Investigating, Open - Waiting on 3rd Party, Open - Waiting on Customer Information, Updated,ReOpened,Re-Close,Closed by System,Updated Development/IT,Scheduled for Later,Repeating Task,Work in Progress,Escalated,Closed';
        settings.Quick_Responses__c     = 'StarCite,New_Passkey,New_Group_Meetings,New_Meeting';
        settings.Standard_Response__c   = 'New_Business_Transient,New_RegOnline,New_GenieConnect,New_Conference';
        settings.Status_where_SLA_deadline_apply__c = 'Open - Investigating, Updated, ReOpened';
        insert settings;
       
                /*Test.StartTest();
                RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
                instofAcc.Name = 'Test';
                instofAcc.Supplier_Type__c = 'Venue';
                instofAcc.Venue_Type__c = 'CVB';
                instofAcc.RecordTypeId = rtType.id;
                insert instofAcc;
               test.StopTest();*/
               Test.StartTest();
               ID accid = [Select id from Account where name =: 'SalesforceGenericAccount' limit 1].id;
       
       List<Contact> con = new List<Contact>{ new contact(
                           FirstName = 'test con 1',
                           LastName = 'xyz',
                           AccountId = accid ,
                           LeadSource = 'Web')};
       insert con;
       
       List<Case> c = new List<Case>{ new Case(
                           ContactId=con[0].Id,
                           Status='Closed',
                           subject='Test',
                           Mood__c='1 - Irate',
                           Primary_Reason_for_Mood_Driver__c = 'Sales',
                           Reason__c = 'Oversold',
                           RecordTypeId=Schema.SObjectType.case.getRecordTypeInfosByName().get('Event').getRecordTypeId()),new Case(
                           ContactId=con[0].Id,
                           Status='Open',
                           RecordTypeId=Schema.SObjectType.case.getRecordTypeInfosByName().get('Event').getRecordTypeId())};
       insert c;  
       
       c[1].Mood__c = '1 - Irate';
       c[1].Status='Closed';
       c[1].Primary_Reason_for_Mood_Driver__c = 'Sales';
       c[1].Reason__c = 'Oversold';
       //update c;
       
       /*List<task> t = new List<task>{ new task(
        WhoID = con[0].id,
        Subject='Newtask',
        Status='Completed',
        OwnerId='005000000077sNe',
        Task_Event_Type__c = 'Client Emails',
        Priority='High')
        ,new task(
        WhoID = con[0].id,
        Subject='Newtask',
        Status='Completed',
        OwnerId='005000000077sNe',
        Task_Event_Type__c = 'Client Emails',
        Priority='High',
        Mood__c='2 - Frustrated',
        Primary_Reason_for_Mood_Driver__c = 'Sales',
        Reason__c = 'Oversold')
        ,new task(
        WhoID = con[0].id,
        Subject='Newtask',
        Status='Completed',
        OwnerId='005000000077sNe',
        Task_Event_Type__c = 'Client Emails',
        Priority='High',
        Mood__c='4 - Happy')};
        
        insert t;  
        
        t[0].status = 'Completed';
        t[0].Mood__c='1 - Irate';
        t[0].Primary_Reason_for_Mood_Driver__c = 'Sales';
        t[0].Reason__c = 'Oversold';
        
        update t[0];*/
         test.StopTest();
   }
}