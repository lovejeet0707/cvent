/*************************************************
* Author : Sandeep Kumar
* Date : 17 Nov 2017
* Description : It tests below mentioned classes
* 1) PopulateFieldsOnCustomerAsset_TrigAct
**************************************************/
@isTest(seeAllData=false)
public class PopulateFieldsOnCustmrAsset_TrigAct_Test {
    private static Opportunity opp;
    private static Contract newCon;
    private static Account acc; 
    private static Contact con;
    private static User testUser;
    private static Professional_Services_Project__c PSP;    
    private static User depUser = [Select Id, ProfileId from User where Name = 'CRM Deployment User'];    
    
    public static void createTestData(){
        // Create Account record
        acc = TestUtil.createAccount('EB Account 1', 'Biz_Ac');
        insert acc;     
        
        // Create Contact record
        con = TestUtil.createContact(acc.id);
        con.Email = 'testContact@test.com';
        insert con;           
        
        // Create Opportunity record
        opp = TestUtil.createOpportunity('testOpp','Event','Bid Phase');
        opp.Contact_Associated__c = con.Id;
        opp.AccountId = acc.Id;
        opp.Bill_To_Contact__c = con.Id;
        opp.Event_Planner_Name__c = 'test User';
        opp.Event_Planner_Email__c = 'testuser@cvent.com';
        opp.CloseDate = Date.today().addDays(80);
        insert opp;
        
        // Create Contract record
        newCon = new Contract();
        newCon.AccountId = acc.Id;
        newCon.SBQQ__Opportunity__c = opp.Id;
        insert newCon;        
    }
    
    public static testMethod void testAssetCreation(){
        System.runAs(depUser){
            Test.startTest();
            // Call test data method
            createTestData();
            // Create Customer Asset record manually
            Customer_Asset__c newAsset = new Customer_Asset__c();
            newAsset.Account__c = acc.Id;
            newAsset.Contract__c = newCon.Id;
            insert newAsset;
            
            // Get the inserted Customer Asset
            Customer_Asset__c getInsertedRecord = [Select Id,Opportunity_Owner_Email__c,Customer_Email__c From Customer_Asset__c Where Id = :newAsset.Id];
            
            // Validate new values for Customer email and Opportunity email on before insert.
            System.assertEquals('salesforce@cvent.com', getInsertedRecord.Opportunity_Owner_Email__c);
            System.assertEquals('testcontact@test.com', getInsertedRecord.Customer_Email__c);
            Test.stopTest();            
        }
    }    
}