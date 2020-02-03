@isTest
public class ClosedLostDetailsTriggerHelperTest 
{
    public testmethod static void testMethod1()
    {
        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc.BillingCountryCode='US';
        instOfAcc.BillingStateCode='TX';
        insert instOfAcc;
        
        Contact instofCon = TestUtil.createContact(instofAcc.id);
        instOfCon.Email = 'Test987654321@test.com';
        instOfCon.Phone = '8877665544';
        insert instofCon;
        
        Opportunity instOpp=TestUtil.createOpportunity('Test Opp','Event','Qualified');
        instOpp.AccountId = instOfAcc.Id;
        instOpp.StageName ='Verbal';
        instOpp.Deal_Year__c ='1';
        instOpp.NBB_Renewal__c = 'NBB';
        instOpp.Parent_Upsell__c = 'Primary';
        instOpp.CloseDate = system.today().addmonths(12);
        instOpp.pricebook2id=Test.getStandardPricebookID();
        instOpp.Contact_Associated__c=instofCon.id; 
        insert instOpp;
        
        Id recordTypeId = RecordTypeUtil.getRecordTypeIDByDevName('Account_Shut_Down_Details__c','Event_Renewal');
        Account_Shut_Down_Details__c closedLostRec = new Account_Shut_Down_Details__c();
        closedLostRec.RecordTypeId = recordTypeId;
        closedLostRec.Opportunity_Lost_On__c = 'Product';
        closedLostRec.Lost_Reason__c = 'Usability';
        closedLostRec.Did_we_Lose_to_a_Competitor__c = 'Yes';
        closedLostRec.Please_Specify_the_Competitors_Name__c = 'E - Active.com';
        closedLostRec.Did_we_Lose_to_an_Internal_System__c = 'Yes';
        closedLostRec.Additional_Comments_Description__c = 'testing testing testing';
        closedLostRec.Opportunity_Stage__c = 'At Risk';
        closedLostRec.Opportunity__c = instOpp.Id;
        insert closedLostRec;
        
        closedLostRec.Opportunity_Stage__c = 'Closed Lost';
        update closedLostRec;
    }
}