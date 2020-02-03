/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 23rd Feb 2014
Description : To Test ACMRestIntegrationcls and  ACMRestIntegrationSchedulerCls
*/
@isTest
private class ACMRestIntegrationclsTest {
    static{
        CurrencyPassAuth__c instOfCAP = new CurrencyPassAuth__c();
        instOfCAP.Security_Token__c = '093844';
        instOfCAP.Password__c = 'Asesdd';
        instOfCAP.Name = '1';
        instOfCAP.Username_del__c = 'Test';
        insert instOfCAP;
    }
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    static testMethod void myUnitTest() {
        ACMRestIntegrationcls.Call(); 
        Test.startTest();
        ACMRestIntegrationSchedulerCls sh1 = new ACMRestIntegrationSchedulerCls();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1);
        Test.stopTest();
    }
}