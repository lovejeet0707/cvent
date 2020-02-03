/**
 * Test class for VistaAssetExpiredBatchable and Schedulable jobs.
 */

@IsTest
private class VistaAssetExpiredBatchableTest {
    static testMethod void testSchedulable() {
        VistaAssetExpiredSchedule scheduable = new VistaAssetExpiredSchedule();
        System.schedule('VistaAssetExpiredScheduleTest', '0 0 0 3 9 ? 2022', scheduable);
    }

    static testMethod void testBatchable() {
        Account anAccount = new Account();
        anAccount.Name = 'Test Account';
        insert anAccount;

        Customer_Asset__c asset = new Customer_Asset__c();
        asset.Quantity__c = 100;
        asset.Decommission_Effective_Date__c = Date.today();
        asset.Account__c = anAccount.Id;
        asset.Asset_Status__c = 'Active';

        insert asset;

        VistaAssetExpiredBatchable b = new VistaAssetExpiredBatchable();
        database.executeBatch(b);

    }
}