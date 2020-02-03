@Istest(SeeAllData=false)

private class TestAccountRelateOpp{

   
    @TestSetup
    static void setupData(){
    
        Account acct=TestUtil.createAccount('Test account' ,'Biz_Ac');
        insert acct;
        // custom setting for opportunity insert
        UserAssignment__c instUA = new UserAssignment__c();
        instUA.Name = 'OnArrival';
        instUA.User_id__c = userinfo.getUserID();
        instUA.UserName__c = 'Brett Wischow';
        insert instUA;
        
    }
    static testMethod void testAccrelateopp() {
        
        
        
        Test.startTest();
            Account acct=[select id from account limit 1];
            Opportunity opp1=TestUtil.createOpportunity('Opp1','Event','Qualified');
            opp1.AccountId=acct.id;
        
            insert opp1;
            
            ApexPages.currentPage().getParameters().put('id', acct.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(acct);
            AccountRelateOpp instAcc = new AccountRelateOpp(sc);
            
          
        Test.stopTest();
        
       
    }
    
    static testMethod void testAccwithNoOpp() {
        Account acct=[select id from account limit 1];
        
        
        Test.startTest();
             ApexPages.currentPage().getParameters().put('id', acct.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(acct);
            AccountRelateOpp instAcc = new AccountRelateOpp(sc);
            
           
        Test.stopTest();
        
       
    }// end */
    
    
}