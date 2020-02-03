@IsTest
private class RestLeadConvertTest {
    @isTest static void testGetLeadById() {
        Test.startTest();
        Id recordId = createTestRecord();
        Id accountRecordId = createAccountRecord();
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://cvent--pgo.cs25.my.salesforce.com/services/apexrest/Lead/'
            + recordId;
        request.params.put('LeadId', recordId);
        request.params.put('AccountId', accountRecordId);
        request.params.put('PayGo_GUID', 'GGGGGGGGGG');
    
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        String thisLead = RestLeadConvert.doGet();
        // Verify results
        System.assert(thisLead != null);
        //System.assertEquals('Test record', thisLead.Subject);
        RestLeadConvert.UpdateIntegrationLogs(recordId,'Test Error Message');
        Test.stopTest();
    }
     // Helper method
    static Id createTestRecord() {
        // Create test record
        Lead leadTest = new Lead(
            FirstName='Test record',
            LastName='Test Last record',
            Company='Test Company',
            Status='Open',
            Product_Desired__c='CrowdCompass');
        insert leadTest;
        return leadTest.Id;
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