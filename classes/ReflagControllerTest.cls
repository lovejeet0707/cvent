// ===============================
// Name             : ReflagController
// AUTHOR           : Hemant Rana   
// CREATED DATE     : 3 Nov 2016
// PURPOSE          : Test class for "ReflagController"............
// TEST CLASS       : ReflagControllerTest
// SPECIAL NOTES    :
// ===============================
@isTest
private class ReflagControllerTest{
    public static Account instofAcc = new Account();
    public static Contact instofCon =  new Contact();
    public static List<Account > instOfAccList= new List<Account >();
    public static Multi_Property_Bundles__c instOfMulPropBund =  new Multi_Property_Bundles__c();
    Private static User u;
    
    Private static void createUser(string roleName,integer id ){
        Profile p = [SELECT Id FROM Profile WHERE Name='Finance - Management']; 
        String s = '%' + roleName + '%'; 
        USerrole testroleId=[select id from userRole where name like :s limit 1];
        u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, userRoleId=testroleId.id,
                     TimeZoneSidKey='America/Los_Angeles', UserName=id+'deploymentuser@cvent.com',CountryCode='IN');
    }
    
    static testMethod void unitTest(){
        createUser('Direct Sales (Event)',21);
        System.runAs (u) {
            
            RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
            instofAcc = new Account();
            instofAcc.Name = 'Test';
            //instofAcc.CurrencyIsoCode  = 'USD';
            instofAcc.Supplier_Type__c = 'Venue';
            instofAcc.Venue_Type__c = 'CVB';
            instofAcc.RecordTypeId = rtType.id;
            instOfAcc.BillingCountryCode = 'US';
            instOfAcc.BillingStateCode = 'NY';
            instOfAccList.add(instofAcc);
            
            instofAcc = new Account();
            instofAcc.Name = 'Test';
            //instofAcc.CurrencyIsoCode  = 'USD';
            instofAcc.Supplier_Type__c = 'Venue';
            instofAcc.Venue_Type__c = 'CVB';
            instofAcc.RecordTypeId = rtType.id;
            instOfAcc.BillingCountryCode = 'US';
            instOfAcc.BillingStateCode = 'NY';
            instOfAccList.add(instofAcc);
            
            insert instOfAccList;
            
            instOfCon.LastName = 'Test';
            instOfCon.AccountId = instOfAccList[0].Id;
            insert instOfCon;
            
            instOfMulPropBund.Name = 'Test';
            //instOfMulPropBund.MSA_Code__c = '9999e';
            insert instOfMulPropBund;
            
            RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
            Opportunity instOfOppSec = new Opportunity();
            //instOfOpp.Opportunity_Start_Date__c = system.today();
            instOfOppSec.License_Type__c = 'Diamond Plus';
            instOfOppSec.Contract_Type_Test__c = 'Renewal';
            instOfOppSec.Counted_sales_Cancellation_Value__c =110;
            instOfOppSec.Liquidation_Fee__c  = 10;
            instOfOppSec.OptOutDate__c = system.today();
            instOfOppSec.Opp_End_Date__c  = system.today();
            instOfOppSec.AccountId = instOfAccList[0].id;
            instOfOppSec.Name = 'Test';
            instOfOppSec.Product__c = 'CrowdCompass';
            instOfOppSec.Contract_Number_New__c = '255122';
            instOfOppSec.New_Type__c =  'Upsell-NBB';
            instOfOppSec.StageName = 'Closed Won';
            instOfOppSec.CloseDate = system.today();
            instOfOppSec.RecordTypeId = instOfRecType.Id;
            instOfOppSec.Year_1_at_Risk__c = 11;
            instOfOppSec.New_Type__c = 'Test';
            instOfOppSec.Deal_Booked_In__c = 'UK Books';
            //instOfOppSec.Price_per_lead__c = 1;
            instOfOppSec.Years__c= '1';
            instOfOppSec.LeadSource = 'ACD-PS';
            instOfOppSec.Contact_Associated__c = instOfCon.Id;
            instOfOppSec.Contact_Role__c = 'Primary User';
            instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
            instOfOppSec.ContractReceived__c = system.today();
            //instOfOppSec.Deal_Year__c = '1';
            instOfOppSec.MYD_Deal__c = 'First Year';
            instOfOppSec.Deal_Year__c = '1';
            instOfOppSec.New_Amount__c = 1000;
            instOfOppSec.Parent_Upsell__c = 'Primary';
            instOfOppSec.Send_This_To_Tract__c = true;
            //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
            instOfOppSec.Forex_rate__c = 1;
            // instOfOppSec.Price_per_lead__c = 1;
            instOfOppSec.Clubbed_Opportunity__c = true;
            //instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
            instOfOppSec.License_Type__c = '1/2 Diamond';
            instOfOppSec.ContractEndDate__c = system.today();
            insert instOfOppSec;
            
            Rebrand_Reflag__c reflagObj = new Rebrand_Reflag__c();
            reflagObj.Reflagged_on_Date__c = system.today();
            reflagObj.Old_Supp_Ac__c = instOfAccList[0].id;
            reflagObj.New_Supplier_Account__c = instOfAccList[1].id;
            insert reflagObj ;
            
            PageReference pageRef = Page.Reflag;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController controller=new ApexPages.StandardController(reflagObj);
            
            ReflagController controllerO = new ReflagController(controller);
            ApexPages.currentPage().getParameters().put('Id',reflagObj.Id);
            controllerO.selectedoppMap.put(instOfOppSec.id,instOfOppSec);
            controllerO.ReflagOpportunity();
            ReflagController.WrapperOpportunityWrapper empW = new ReflagController.WrapperOpportunityWrapper(instOfOppSec,true); 
            controllerO.getOpportunities();
        }
    }
}