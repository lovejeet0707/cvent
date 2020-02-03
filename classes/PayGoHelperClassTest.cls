@isTest
public class PayGoHelperClassTest{
    static testmethod void updatePayGoIdAddressTest(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Address__c addr = new Address__c();
        addr.Address__c = 'Test Address';
        addr.Type__c = 'Billing';
        addr.Account__c = acc.Id;
        insert addr;
        
        Address__c shipAddr = new Address__c();
        shipAddr.Address__c = 'Test Address';
        shipAddr.Type__c = 'Shipping';
        shipAddr.Account__c = acc.Id;
        insert shipAddr;
        
        Opportunity opp2 = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Open');
        opp2.CurrencyIsoCode  = 'USD';
        opp2.Bill_To_Address__c = addr.id;
        opp2.Ship_To_Address__c = shipAddr.id;
        opp2.License_Type__c = 'Pay Go';
        opp2.AccountId = acc.Id;
        insert opp2;
        
        Login_Account__c LA = new Login_Account__c();
        LA.Opportunity__c = opp2.Id;
        LA.Cvent_Account_ID__c = '111111111111';
        LA.GUI_ID__c = '22222222222';
        LA.Instance__c = 'NA';
        LA.Attention_To__c = '44444444444';
        LA.Customer__c = acc.Id;
        insert LA;
        
        Login_Account__c LA2 = new Login_Account__c();
        LA2.Opportunity__c = opp2.Id;
        LA2.Cvent_Account_ID__c = '111111111111';
        LA2.GUI_ID__c = '22222222222';
        LA2.Instance__c = 'NA';
        LA2.Attention_To__c = '44444444444';
        LA2.Customer__c = acc.Id;
        LA2.Status__c = 'Event Launch';
        insert LA2;
        LA2.Status__c = 'Event Create';
        update LA2;
        LA2.Status__c = 'Account Open';
        update LA2;
        LA2.Status__c = 'Account Request';
        update LA2;
        
        opp2.StageName = 'Closed Won';
        update opp2;
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        oppMap.put(opp2.Id,opp2);
        PayGoHelperClass.updatePayGoIdAddress(oppMap,oppMap);
        
        PayGo_Summary__c paygoRec = new PayGo_Summary__c();
        paygoRec.Account__c = acc.Id;
        insert paygoRec;
        try      
        {
            delete LA;
            delete paygoRec;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('You') ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        } 
    } 
}