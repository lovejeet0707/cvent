@istest
public class SuccessMailTempControllerTest{
    
    public static testmethod void testDUNS(){
        
        Test.startTest();
                   
           Account instofAcc =TestUtil.createAccount('Test Account','Biz_Ac');
           instofAcc.Supplier_Type__c = 'Venue';
           instofAcc.Venue_Type__c = 'CVB';
           instofAcc.CSN_Status__c ='Using';
           instofAcc.Supplier_Status__c='Approved';
           instofAcc.BillingCountryCode='US';
           instOfAcc.BillingStateCode='TX';
           instofAcc.Global_Ultimate_DUNS__c = '123';
           
           insert instofAcc;
           
           SuccessMailTempController.dunsNumber = '123';
           SuccessMailTempController.getDUNSAccounts();
     }
        
       
}