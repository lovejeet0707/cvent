/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class BatchConvertUpdateLeadContactTest {

    static testMethod void myUnitTest() {
        Test.startTest();
        Lead TestLead1 = new Lead(LastName='TestLead 1', Company='Test Company', Status='Qualified',Country='US');
        insert TestLead1;
        Account TestAccount1 = new Account(Name = 'TestAccount');
        TestAccount1.BillingCountryCode='US';
        TestAccount1.BillingStateCode='TX';
        insert TestAccount1;
        Contact Testcontact1 = new Contact(LastName='TestContact 1',AccountId = TestAccount1.Id);
        insert Testcontact1;
        Campaign TestCampaign1 = new Campaign(Name='Test Campaign');
        insert TestCampaign1;
        List<CampaignMember> cmpList = new List<CampaignMember>();
        CampaignMember cmp1 = new CampaignMember(CampaignId = TestCampaign1.Id, LeadId=TestLead1.Id, Status='Registered');
        CampaignMember cmp2 = new CampaignMember(CampaignId = TestCampaign1.Id, ContactId=Testcontact1.Id, Status='Registered');
        cmpList.add(cmp1);
        cmpList.add(cmp2);
        insert cmpList;
        
        //Inserting task
        List<Task> taskList = new List<Task>();
        Task t1 = new Task(Subject = 'Marketo Submission: CT_Quick_Registration',RecordtypeId = Label.TaskRecordTypeID,whoId = TestLead1.Id,Campaign_ID__c=TestCampaign1.Id);
        Task t2 = new Task(Subject = 'Marketo Submission: CT_Quick_Registration',RecordtypeId = Label.TaskRecordTypeID,whoId = Testcontact1.Id,Campaign_ID__c=TestCampaign1.Id);
        taskList.add(t1);
        taskList.add(t2);
        insert taskList;
        
        BatchConvertUpdateLeadContact c = new BatchConvertUpdateLeadContact();
        Database.executeBatch(c);
        Test.stopTest();
    }
}