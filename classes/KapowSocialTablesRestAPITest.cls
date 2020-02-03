@IsTest
private class KapowSocialTablesRestAPITest{
    @isTest static void doGetTest() {
        Test.startTest();
        
        Id accountRecordId = createAccountRecord();
        Id recordId = createTestRecord(accountRecordId);
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://cvent--pgo.cs25.my.salesforce.com/services/apexrest/AccountId/'
            + recordId;
        request.params.put('id', recordId);
    
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        KapowSocialTablesRestAPI.doGet();
        Test.stopTest();
    }
     // Helper method
    static Id createTestRecord(Id accountId) {
        // Create test record
        Acquisition__c acquisitionTest = new Acquisition__c(
            Account__c = accountId,
            Migrated_Record_ID__c =accountId,
            Migrated_Record__c = 'Merged',
            Account_Type_for_Aquired_Org__c = 'Client',
            Account_Owner_for_Acquired_Org__c = 'Test');
        insert acquisitionTest;
        return acquisitionTest.Id;
    } 
// Helper method
    static Id createAccountRecord() {
        // Create test record
        Account accountTest = new Account(
            Name='Test record');
        insert accountTest;
        return accountTest.Id;
    }   
}