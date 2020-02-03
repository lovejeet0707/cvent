@istest
public class AutoLoginTest{

    
    static testmethod void create1(){
        
        //Insert Custom Setting.....
        LanyonCredentials__c lanCred = new LanyonCredentials__c();
        lanCred.Name = 'test@cvent.com';
        lanCred.EndPointURL__c = 'https://login.salesforce.com';
        lanCred.LoginPassSecure__c = 'PassowrdSecurityToken';
        insert lanCred;
        
        Account lanyonAcc = new Account(Name = 'Lanyon-Account',Lanyon_AccountId__c='');
        insert lanyonAcc ;
        
            
        Account acctA1 = new Account(Name = 'AAA-Account',Lanyon_AccountId__c=lanyonAcc .Id);
        insert acctA1;
        
        
        Pagereference pg = Page.SystemLogin;
        pg.getParameters().put('Id',acctA1.Id);
        
        test.setCurrentPage(pg);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(acctA1);
        AutoLogin a = new AutoLogin(stdController);
       
    }
        
        
    

}