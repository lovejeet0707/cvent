@Istest(SeeAllData=True)
private class CCAcctStatusTest {
    public static Account instofAcc = new Account();
    static testMethod void testCCAcctStatusTest() {
        Account Acc = new account (name = 'testname' );
        insert Acc;
        
        Current_Status__c c = new Current_Status__c (Account_Progress__c = 'Closed Won',Parent_Account__c= Acc.Id,CC_Acct_Status__c='Closed Won');
        insert c;
       
        ApexPages.currentPage().getParameters().put('id', Acc.id);
        ApexPages.currentPage().getParameters().put('PID', Acc.Id);
        
        CCAcctStatus  controller  =new CCAcctStatus ();
        String parentAccount = controller.getParentaccount();
        String nextPage = controller.edit().getUrl();
        String nextPage1 = controller.save().getUrl();
        String nextPage3 = controller.edit().getUrl();
        String nextPage2 = controller.cancel().getUrl();
    }
}