@istest
private class JustToTestCLSTest{
    static testMethod void myUnitTest(){
        Account instOfAcc = new Account();
        instOfAcc.Name = 'TEST';
        instOfAcc.BillingCountryCode = 'US';
        instOfAcc.BillingStateCode = 'NY';
        insert instOfAcc;
        //instOfAcc.Other_AccountId__c = instOfAcc.Id;  //Commented By Mohsin on 21st June 2019 - FP Activity
        //update instOfAcc;  //Commented By Mohsin on 21st June 2019 - FP Activity
        Apexpages.currentPage().getParameters().put('Id',instOfAcc.Id);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(instOfAcc);
        JustToTestCLS instOfJTTC = new JustToTestCLS(controller);
        
    }
}