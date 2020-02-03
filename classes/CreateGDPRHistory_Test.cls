@istest(SeeAllData=true)
public class CreateGDPRHistory_Test{

public static testMethod void testContactGDPRMEthod(){
    
    Account acc  = new Account();
    acc.Name = 'Test Account';
    insert acc;
    
    Account accTest  = new Account();
    accTest.FirstName = 'Test';
    accTest.LastName = 'Test Account';
    accTest.Type = 'Product Competitor';
    accTest.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person A/c').getRecordTypeId();
    insert accTest;
    
    accTest.LastName = 'Test Last Name';
    accTest.Type = 'Property Distribution';
    update accTest;
    
    accTest.Is_GDPR__pc= true;
    update accTest;
    
    
    
    Contact con = new Contact();
    con.LastName = 'Test Contact';
    con.Email = 'test@test.com';
    con.AccountId = acc.Id;
    insert con;
     
    con.Email = 'test1@test.com';
    update con;
    
    System.debug('ContactHistory****'+[SELECT OldValue FROM ContactHistory where ContactId =: con.Id]);
    
    con.Is_GDPR__c = true;
    update con;

    System.debug('****'+[SELECT OldValue FROM ContactHistory where ContactId =: con.Id]);
    
    Lead TestLead = new Lead(LastName='TestLead 1', Company='Test Company', Status='Qualified',Email='testlead@test.com');
    insert TestLead;
    
    TestLead.Company = 'Cvent'; 
    TestLead.Email = 'testlead1@test.com'; 
    TestLead.Phone = '3983983983';
    update TestLead;

    LeadHistory leadHistoryRecord = new LeadHistory(LeadId= TestLead.id, Field = 'Phone'); 
    insert leadHistoryRecord; 

    TestLead.is_GDPR__C = true;
    update TestLead;
        
    System.debug('****'+[SELECT CreatedById,CreatedBy.name,CreatedDate,Field,Id,IsDeleted,LeadId,NewValue,OldValue FROM LeadHistory where LeadId =: TestLead.Id]);
    
    Test.startTest();
    Database.executeBatch(new CreateGDPRHistory(),10);  
    Test.stopTest();
    CreateGDPRHistory.fakeMethod();
}
}