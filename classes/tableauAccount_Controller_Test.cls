@isTest
public class tableauAccount_Controller_Test{
    
    static testmethod void validateStandardController(){
        // set up some test data to work with
        Account testAccount = TestUtil.createAccount('Test Company Name123','Biz_Ac');  
        testAccount.Cvent_Account_ID__c='oo1abch';
        insert testAccount;
        // start the test execution context
        Test.startTest();
        // set the test's page to your VF page (or pass in a PageReference)
        String AccId = testAccount.id;
        PageReference pageRef = Page.tableauAccount;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('AccountID',AccId);
        // call the constructor
        tableauAccount_Controller controller = new tableauAccount_Controller();
        
        controller.DataFromTableau();
        //controller.AccountId=String.ValueOf(testAccount.Id);
        // stop the test
        Test.stopTest();
    }
    
    static testmethod void myUnitTest(){
        
        Test.startTest();
        // set the test's page to your VF page (or pass in a PageReference)
        String AccId = null;
        PageReference pageRef = Page.tableauAccount;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('AccountID',AccId);
        // call the constructor
        tableauAccount_Controller controller = new tableauAccount_Controller();
        
        controller.DataFromTableau();
        //controller.AccountId=String.ValueOf(testAccount.Id);
        // stop the test
        Test.stopTest();
        
    }
    
}