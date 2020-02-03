@Istest(SeeAllData=True)
private class BCP_Test_Class {
public static Account instofAcc = new Account();
static testMethod void testBCP_Project_Class() {
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        instofAcc.Name = 'Test';
        //instofAcc.CurrencyIsoCode  = 'USD';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        insert instofAcc;
        Account Acc = new account (name = 'testname' );
        insert Acc;
        
        Current_Status__c c = new Current_Status__c (Account_Progress__c = 'Closed Lost',Parent_Account__c= Acc.Id );
        insert c;
      //001P000000amT9H
      //00100000007vYFq  
       list<Account> A1 = [Select id, parentid from account where parentid = null limit 1];
 
       ApexPages.currentPage().getParameters().put('id', instofAcc.id);
       ApexPages.currentPage().getParameters().put('PID', Acc.Id);
        
       BCP_Project_Class  controller  =new BCP_Project_Class();
       String nextPage = controller.edit().getUrl();
       String nextPage1 = controller.save().getUrl();
       String nextPage3 = controller.edit().getUrl();
       String nextPage2 = controller.cancel().getUrl();
       List<SelectOption> instOfCont = controller.getItems();
       controller.getCountries();
       controller.setCountries('Test');
       //String nextPage4 = controller.countries;
       
     


    }
}