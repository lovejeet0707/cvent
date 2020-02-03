// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 28/04/2016
// PURPOSE     :  Test Class for Seed Owner fields on Account
// CLASS COVERED:   SeedOwnerAccController
// ===============================
@istest
public class SeedOwnerAccControllerTest{

    static testmethod void createSeedOwner(){
    
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Seed_Expiration_Date__c = Date.Today()+1;
        acc.Seed_Owner_Name__c = 'CRM User';
        insert acc;
        
        ApexPages.StandardController ctr = new ApexPages.StandardController (acc);
        SeedOwnerAccController sController= new SeedOwnerAccController(ctr);
        
        sController.Save();
        sController.cancel();
    
    }
    
}