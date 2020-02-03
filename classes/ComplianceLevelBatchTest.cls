@isTest
public class ComplianceLevelBatchTest{
     public static Account instofAcc = new Account();
     public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    public static Contact instofCon =  new Contact();
public static testMethod void unitTest(){
 RecordType rtTypeAcc = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
 RecordType rtTypeOpp = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Opportunity' And DeveloperName='Renewal' And IsActive=true];
        instofAcc.Name = 'Test';
        //instofAcc.CurrencyIsoCode  = 'USD';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtTypeAcc.id;
        insert instofAcc;
        
        
        instOfCon.LastName = 'Test';
        instOfCon.AccountId = instofAcc.Id;
        insert instOfCon;

Opportunity instOfOpp = new Opportunity();
instOfOpp.recordTypeId = rtTypeOpp.Id;
        instOfOpp.AccountId = instofAcc.id;
        instOfOpp.Name = 'Test';
        instOfOpp.Product__c = 'Event';
        instOfOpp.New_Type__c =  'Upsell-NBB';
        instOfOpp.StageName = 'Verbal';
        instOfOpp.CloseDate = system.today();
        instOfOpp.New_Amount__c = 11;
        instOfOpp.Years__c= '1';
        instOfOpp.LeadSource = 'ACD-PS';
        instOfOpp.Contact_Associated__c = instOfCon.Id;
        instOfOpp.Contact_Role__c = 'Primary User';
        //instOfOpp.MSA_Code__c = lstMPB[0].MSA_Code__c;
        instOfOpp.Contract_Implemented__c = true;
        instOfOpp.ContractReceived__c = system.today();
        instOfOpp.Deal_Year__c = '1';
        insert instOfOpp;

    
    //system.abortJob(batchId);        
        ComplianceLevelBatch sh1 = new ComplianceLevelBatch();
         system.schedule('ScheduledBatchDeactivateUsers',CRON_EXP , sh1); 

Id batchId = Database.executeBatch(new ComplianceLevelBatch());    
}

}