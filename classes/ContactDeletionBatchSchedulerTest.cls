/**=====================================================================
 * Cvent
 * Name: ContactDeletionBatchSchedulerTest
 * Description: Test Class for "ContactDeletionBatch" , "ScheduledContactDeletionBatch" ,"ContactIdDeletionBatch" , "ScheduledContactIdDeletionBatch","AccountDeletionBatch"
                 "ScheduledAccountDeletionBatch","AccountRecordDeletionBatch","ScheduledAccountRecordDeletionBatch"
 * Created Date: [10/05/2016]
 * Created By: Hemant Rana
 * 
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 =====================================================================*/ 
@isTest
public class ContactDeletionBatchSchedulerTest
{
  
    static String CRON_EXP = '0 0 0 15 3 ? 2022';
    
    static testMethod void validateScheduledContactDeletionBatch() {
        
        Account instAccount=TestUtil.createAccount('TestAccount','Biz_Ac');  // call by test util [kumud]
        instAccount.CVII_ID__c='1'; 
        instAccount.Affiliate_Name__c='Autograph Collection';
        instAccount.Supplier_Status__c = 'Not Visible';
        instAccount.BillingCountryCode='US';
        instAccount.BillingState='TX';
        insert instAccount;
        
        Test.setCreatedDate(instAccount.Id, DateTime.newInstance(2000,10,10));
       
        Contact con=TestUtil.createContact(instAccount.id);// call by test util [kumud]
        insert con;
        Test.setCreatedDate(con.Id, DateTime.newInstance(2000,10,10)); 
        
        
        Contact_Id__c conIdObj = new Contact_Id__c();
        conIdObj.ContactId__c = con.Id;
        insert conIdObj;
        
        // Add by kumud on 9 march 2018
        DeletedAccountId__c instDelAcc=new DeletedAccountId__c(Account_Id__c=instAccount.id);
        insert instDelAcc;
        
        Test.setCreatedDate(conIdObj.Id, DateTime.newInstance(2000,10,10)); 
        
       Test.StartTest();
       // Schedule the ScheduledDeleteLeadBatch
       System.schedule('ScheduledDeleteContactBatch',CRON_EXP,new ScheduledContactDeletionBatch());
       System.schedule('ScheduledContactIdDeletionBatch',CRON_EXP,new ScheduledContactIdDeletionBatch());
       System.schedule('ScheduledAccountDeletionBatch',CRON_EXP,new ScheduledAccountDeletionBatch());
       System.schedule('ScheduledAccountRecordDeletionBatch',CRON_EXP,new ScheduledAccountRecordDeletionBatch());
        Test.stopTest(); 
    }
}