/**
* Author : Sandeep Kumar
* Date : 12 April, 2017
* Description : It tests below mentioned class
* 1) CreateEBProject_ContExt
*/
@isTest(seeAllData=true)
public class CreateEBProject_ContExt_Test {
    private static Opportunity opp;
    private static Account acc; 
    private static ARA__c AraObj;
    private static Contact con;
    private static Professional_Services_Project__c PSPRec;
    private static List<PricebookEntry> pbeList;
    private static User depUser = [Select Id, ProfileId from User where Name = 'CRM Deployment User'];
    private static Id userProfieId = UserProfileUtil.getProfileIDByName('Customer Care Rep - Product Consultant EB Team'); 
    
    public static void setupData(){        
        // Create Contact Record.
        con = TestUtil.createContact(acc.id);
        insert con;
        
        // Create Product Record.
        List<Product2> products =  TestUtil.createProducts(new List<String>{'EOY Cvent Event Builder Promotion- Advanced','EOY Cvent Event Builder Promotion- Advanced with Mobile'});
        insert products;
        
        pbeList = new List<PricebookEntry>();        
        PricebookEntry pbe1 =  TestUtil.createPricebookEntry(products[0],200);
        pbeList.add(pbe1);
        PricebookEntry pbe2 =  TestUtil.createPricebookEntry(products[1],400);
        pbeList.add(pbe2);        
        insert pbeList;   
        
        Opportunity o1 = TestUtil.createOpportunity('testOpp','Event','Bid Phase');
        o1.Contact_Associated__c = con.Id;
        o1.AccountId = acc.Id;
        o1.Event_Planner_Name__c = 'test User';
        o1.Event_Planner_Email__c = 'testuser@cvent.com';
        o1.CloseDate = Date.today().addDays(80);
        insert o1;
        
        opp = [select id, amount from opportunity where id = :o1.id];
        
        OpportunityLineItem oli1 = TestUtil.createOpportunityLineItems(o1,pbe1);
        OpportunityLineItem oli2 = TestUtil.createOpportunityLineItems(o1,pbe2);
        
        insert new List <OpportunityLineItem> {oli1,oli2};            
        }
    
    // Testing when we already have PSP ID for current year.
    static testMethod void CreateEBProjectWithPSPID(){
        system.runAs(depUser){
            // Create Account Record.
            acc = TestUtil.createAccount('EB Account 1', 'Biz_Ac');
            insert acc;
           	Test.startTest();
            setupData();              
            Apexpages.StandardController sc = new ApexPages.StandardController(opp);
            CreateEBProject_ContExt controller = new CreateEBProject_ContExt(sc);
            controller.CreateProjects();
            for(Integer i = 0; i < controller.WrapOppLineItemList.Size(); i++){
                controller.WrapOppLineItemList[i].selected =true;
            }
            controller.CreateProjects();
            controller.back();
            Test.stopTest();
        }
    }  
    
    // Testing when we don't have products associated with opportunity.
    static testMethod void showAllProducts(){
        system.runAs(depUser){
            // Create Account Record.
            acc = TestUtil.createAccount('EB Account 1', 'Biz_Ac');
            insert acc;
            Test.startTest(); 
            setupData();           
            Apexpages.StandardController sc = new ApexPages.StandardController(opp);
            CreateEBProject_ContExt controller = new CreateEBProject_ContExt(sc);
            controller.showAllProducts();
            Test.stopTest();
        }
    }  
    
    // Testing when we don't have PSP ID for current year.
    static testMethod void CreateEBProjectWithOutPSPID(){
        system.runAs(depUser){ 
            // Create Account Record.
            acc = TestUtil.createAccount('EB Account 2', 'Biz_Ac');
            acc.Active_ARA__c = true;   
            insert acc;
            // Create Active ARAs with the Account. 
            AraObj = new ARA__c();
            AraObj.Account__c = acc.Id;
            AraObj.Status__c = 'Open';
            insert AraObj;  
            setupData();
            Test.startTest();
            // Tests with Open ARA Account
            Apexpages.StandardController sc = new ApexPages.StandardController(opp);
            CreateEBProject_ContExt controller = new CreateEBProject_ContExt(sc);
            controller.WrapOppLineItemList[0].selected =true;
            controller.CreateProjects();
            controller.back();
            
            // Tests with Closed ARA Account
            acc.Active_ARA__c = false;  
            update acc;
            // Tests with Open ARA Account
            Apexpages.StandardController sc1 = new ApexPages.StandardController(opp);
            controller = new CreateEBProject_ContExt(sc1);
            controller.WrapOppLineItemList[0].selected =true;
            controller.WrapOppLineItemList[1].selected =true;
            controller.CreateProjects();            
            Test.stopTest();
        }
    } 
}