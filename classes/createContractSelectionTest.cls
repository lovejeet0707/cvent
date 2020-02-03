/**
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 16th July 2014
Test Class for createContractSelection
 */
@isTest
private class createContractSelectionTest{
    public static List<Contract_Status_Values__c> lstContStatVal = new List<Contract_Status_Values__c>();
    static{
        Contract_Status_Values__c instOfContStatVal = new Contract_Status_Values__c();
        instOfContStatVal.Name = '1';
        instOfContStatVal.Custom_Field_Api__c = 'Ready_for_Signature_Days_Count__c';
        instOfContStatVal.Picklist_Values_del__c = 'Ready for Signature';
        lstContStatVal.add(instOfContStatVal);
        
        Contract_Status_Values__c instOfContStatValSec = new Contract_Status_Values__c();
        instOfContStatValSec.Name = '2';
        instOfContStatValSec.Custom_Field_Api__c = 'Received_Days_Count__c';
        instOfContStatValSec.Picklist_Values_del__c = 'Received';
        lstContStatVal.add(instOfContStatValSec);
        
        Contract_Status_Values__c instOfContStatValThir = new Contract_Status_Values__c();
        instOfContStatValThir.Name = '2';
        instOfContStatValThir.Custom_Field_Api__c = 'WFD_Days_Count__c';
        instOfContStatValThir.Picklist_Values_del__c = 'Waiting for Documents';
        lstContStatVal.add(instOfContStatValThir);
        
        Contract_Status_Values__c instOfContStatValFor = new Contract_Status_Values__c();
        instOfContStatValFor.Name = '2';
        instOfContStatValFor.Custom_Field_Api__c = 'Assigned_Days_Count__c';
        instOfContStatValFor.Picklist_Values_del__c = 'Assigned';
        lstContStatVal.add(instOfContStatValFor);
        insert lstContStatVal;
        
        
    }
    static testMethod void myUnitTest() {
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        Account instofAcc = new Account();
        Contact instofCon =  new Contact();
        instofAcc.Name = 'Venue';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        insert instofAcc;
        
        instOfCon.LastName = 'Test';
        instOfCon.AccountId = instofAcc.Id;
        insert instOfCon;
        
        Opportunity instOfOpp = new Opportunity();
        instOfOpp.AccountId = instofAcc.id;
        instOfOpp.Name = 'Test';
        instOfOpp.Product__c = 'Event';
        instOfOpp.New_Type__c =  'Upsell-NBB';
        instOfOpp.StageName = 'Verbal';
        instOfOpp.CloseDate = system.today();
        instOfOpp.New_Amount__c = 11;
        instOfOpp.Years__c= '1';
        instOfOpp.LeadSource = 'ACD-PS';
        instOfOpp.Contact_Associated__c = instOfCon.Id;
        instOfOpp.Contact_Role__c = 'Primary User';
        instOfOpp.Contract_Implemented__c = true;
        instOfOpp.ContractReceived__c = system.today();
        instOfOpp.Deal_Year__c = '1';
        insert instOfOpp;
        apexpages.currentpage().getparameters().put('Id',instOfOpp.Id);
        RecordType lstRecType = [SELECT Id FROM RecordType WHERE DeveloperName ='Customer_Contracts' LIMIT 1];
        Contract instOfContract = new Contract();
        instOfContract.Document_Type__c = 'Cvent Modified Terms';
        instOfContract.Security_Review_Required__c = 'Yes';
        instOfContract.RecordTypeId = lstRecType.Id;
        instOfContract.SLA_Type__c = 'NonStandard SLA';
        instOfContract.Finance_Review_Required__c = 'Yes';
        instOfContract.Product_Enhancement__c = 'Yes';
        // original line from below --> instOfContract.Primary_Opportunity__c = instOfOpp.Id;
        instOfContract.Primary_Opportunity__c  = instOfOpp.Id;
        instOfContract.Status = 'Waiting for Documents';
        instOfContract.Accountid = instofAcc.id;
        insert instOfContract;
        
        contractCreationController instOfCCC = new contractCreationController();
        
        instOfCCC.contractRec.Document_Type__c = 'Cvent Modified Terms';
        instOfCCC.contractRec.Security_Review_Required__c = 'Yes';
        instOfCCC.contractRec.RecordTypeId = lstRecType.Id;
        instOfCCC.contractRec.SLA_Type__c = 'NonStandard SLA';
        instOfCCC.contractRec.Finance_Review_Required__c = 'Yes';
        instOfCCC.contractRec.Product_Enhancement__c = 'Yes';
        instOfCCC.SubmitSec();
        Contract instCOntr  = new Contract();
        instCOntr =  [SELECT ID,Security_Review_Required__c,Document_Type__c,status,Legal_Review_Required__c FROM Contract LIMIT 1];
        ApexPages.StandardController ApptController = new ApexPages.StandardController(instCOntr);
        ContractAnnouncementCls objc = new ContractAnnouncementCls(ApptController);
    }
    static testMethod void myUnitTestSec() {
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        Account instofAcc = new Account();
        Contact instofCon =  new Contact();
        instofAcc.Name = 'Venue';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        insert instofAcc;
        
        instOfCon.LastName = 'Test';
        instOfCon.AccountId = instofAcc.Id;
        insert instOfCon;
        
        Opportunity instOfOpp = new Opportunity();
        instOfOpp.AccountId = instofAcc.id;
        instOfOpp.Name = 'Test';
        instOfOpp.Product__c = 'Event';
        instOfOpp.New_Type__c =  'Upsell-NBB';
        instOfOpp.StageName = 'Verbal';
        instOfOpp.CloseDate = system.today();
        instOfOpp.New_Amount__c = 11;
        instOfOpp.Years__c= '1';
        instOfOpp.LeadSource = 'ACD-PS';
        instOfOpp.Contact_Associated__c = instOfCon.Id;
        instOfOpp.Contact_Role__c = 'Primary User';
        instOfOpp.Contract_Implemented__c = true;
        instOfOpp.ContractReceived__c = system.today();
        instOfOpp.Deal_Year__c = '1';
        insert instOfOpp;
        apexpages.currentpage().getparameters().put('Id',instOfOpp.Id);
        contractCreationController instOfCCC = new contractCreationController();
        RecordType lstRecType = [SELECT Id FROM RecordType WHERE DeveloperName ='Customer_Contracts' LIMIT 1];
        Contract instOfContract = new Contract();
        instOfContract.Document_Type__c = 'Cvent Standard Terms';
        instOfContract.Security_Review_Required__c = 'Yes';
        instOfContract.RecordTypeId = lstRecType.Id;
        instOfContract.SLA_Type__c = 'NonStandard SLA';
        instOfContract.Finance_Review_Required__c = 'Yes';
        instOfContract.Product_Enhancement__c = 'Yes';
        //original line from below --> instOfContract.Primary_Opportunity__c = instOfOpp.Id;
        instOfContract.Primary_Opportunity__c  = instOfOpp.Id;
        instOfContract.Status = 'Waiting for Documents';
        instOfContract.Accountid = instofAcc.id;
        insert instOfContract;
        
        instOfCCC.contractRec.Document_Type__c = 'Cvent Standard Terms';
        instOfCCC.contractRec.Security_Review_Required__c = 'Yes';
        instOfCCC.contractRec.RecordTypeId = lstRecType.Id;
        instOfCCC.contractRec.SLA_Type__c = 'NonStandard SLA';
        instOfCCC.contractRec.Finance_Review_Required__c = 'Yes';
        instOfCCC.contractRec.Product_Enhancement__c = 'Yes';
        instOfCCC.SubmitSec();
        instOfCCC.Test();
        Contract instCOntr = [SELECT ID,Security_Review_Required__c,Document_Type__c,status,Legal_Review_Required__c FROM Contract ];
        ApexPages.StandardController ApptController = new ApexPages.StandardController(instCOntr);
        ContractAnnouncementCls objc = new ContractAnnouncementCls(ApptController);
        
        apexpages.currentpage().getparameters().put('Id',instOfOpp.Id);
        contractCreationController instOfCCCSec = new contractCreationController();
        instOfCCCSec.contractRec.Document_Type__c = 'Cvent Standard Terms';
        instOfCCCSec.contractRec.Security_Review_Required__c = 'Yes';
        instOfCCCSec.contractRec.RecordTypeId = lstRecType.Id;
        instOfCCCSec.contractRec.SLA_Type__c = 'NonStandard SLA';
        instOfCCCSec.contractRec.Finance_Review_Required__c = 'Yes';
        instOfCCCSec.contractRec.Product_Enhancement__c = 'Yes';
        try{
            instOfCCCSec.SubmitSec();
        }catch(Exception e){
            
        }
        
    }
    static testMethod void myUnitTestThir() {
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        Account instofAcc = new Account();
        Contact instofCon =  new Contact();
        instofAcc.Name = 'Venue';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        insert instofAcc;
        
        instOfCon.LastName = 'Test';
        instOfCon.AccountId = instofAcc.Id;
        insert instOfCon;
        
        Opportunity instOfOpp = new Opportunity();
        instOfOpp.AccountId = instofAcc.id;
        instOfOpp.Name = 'Test';
        instOfOpp.Product__c = 'Event';
        instOfOpp.New_Type__c =  'Upsell-NBB';
        instOfOpp.StageName = 'Verbal';
        instOfOpp.CloseDate = system.today();
        instOfOpp.New_Amount__c = 11;
        instOfOpp.Years__c= '1';
        instOfOpp.LeadSource = 'ACD-PS';
        instOfOpp.Contact_Associated__c = instOfCon.Id;
        instOfOpp.Contact_Role__c = 'Primary User';
        instOfOpp.Contract_Implemented__c = true;
        instOfOpp.ContractReceived__c = system.today();
        instOfOpp.Deal_Year__c = '1';
        insert instOfOpp;
        apexpages.currentpage().getparameters().put('Id',instOfOpp.Id);
        contractCreationController instOfCCC = new contractCreationController();
        RecordType lstRecType = [SELECT Id FROM RecordType WHERE DeveloperName ='Customer_Contracts' LIMIT 1];
        Contract instOfContract = new Contract();
        instOfContract.Document_Type__c = 'Cvent Standard Terms';
        instOfContract.Security_Review_Required__c = 'No';
        instOfContract.RecordTypeId = lstRecType.Id;
        instOfContract.SLA_Type__c = 'NonStandard SLA';
        instOfContract.Finance_Review_Required__c = 'No';
        instOfContract.Product_Enhancement__c = 'No';
        //original line from below --> instOfContract.Primary_Opportunity__c= instOfOpp.Id;
        instOfContract.Primary_Opportunity__c = instOfOpp.Id;
        instOfContract.Status = 'Ready for Signature';
        instOfContract.Accountid = instofAcc.id;
        insert instOfContract;
        
        instOfCCC.contractRec.Document_Type__c = 'Cvent Modified Terms';
        instOfCCC.contractRec.Security_Review_Required__c = 'No';
        instOfCCC.contractRec.RecordTypeId = lstRecType.Id;
        instOfCCC.contractRec.SLA_Type__c = 'Standard SLA (Current Version)';
        instOfCCC.contractRec.Finance_Review_Required__c = 'No';
        instOfCCC.contractRec.Product_Enhancement__c = 'No';
        instOfCCC.SubmitSec();
        instOfCCC.Test();
        Contract instCOntr = [SELECT ID,Security_Review_Required__c,Document_Type__c,status,Legal_Review_Required__c FROM Contract ];
        system.debug(instCOntr.Security_Review_Required__c+instCOntr.Legal_Review_Required__c+instCOntr.status);
        instCOntr.Security_Review_Required__c = 'No';
        instCOntr.Legal_Review_Required__c = 'No';
        update instCOntr;
        ApexPages.StandardController ApptController = new ApexPages.StandardController(instCOntr);
        ContractAnnouncementCls objc = new ContractAnnouncementCls(ApptController);
        
        
    }
    static testMethod void myUnitTestFor() {
        updateContractCountScheduler instOfSechd = new updateContractCountScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, instOfSechd );
        
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        Account instofAcc = new Account();
        Contact instofCon =  new Contact();
        instofAcc.Name = 'Venue';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        insert instofAcc;
        
        instOfCon.LastName = 'Test';
        instOfCon.AccountId = instofAcc.Id;
        insert instOfCon;
        
        Opportunity instOfOpp = new Opportunity();
        instOfOpp.AccountId = instofAcc.id;
        instOfOpp.Name = 'Test';
        instOfOpp.Product__c = 'Event';
        instOfOpp.New_Type__c =  'Upsell-NBB';
        instOfOpp.StageName = 'Verbal';
        instOfOpp.CloseDate = system.today();
        instOfOpp.New_Amount__c = 11;
        instOfOpp.Years__c= '1';
        instOfOpp.LeadSource = 'ACD-PS';
        instOfOpp.Contact_Associated__c = instOfCon.Id;
        instOfOpp.Contact_Role__c = 'Primary User';
        instOfOpp.Contract_Implemented__c = true;
        instOfOpp.ContractReceived__c = system.today();
        instOfOpp.Deal_Year__c = '1';
        instOfOpp.MaintenanceFee__c = 10000000;
        instOfOpp.CurrencyIsoCode = 'USD';
        instOfOpp.Exchange_Rate__c= 1;
        insert instOfOpp;
        apexpages.currentpage().getparameters().put('Id',instOfOpp.Id);
        contractCreationController instOfCCC = new contractCreationController();
        RecordType lstRecType = [SELECT Id FROM RecordType WHERE DeveloperName ='Customer_Contracts' LIMIT 1];
        Contract instOfContract = new Contract();
        instOfContract.Document_Type__c = 'Cvent Standard Terms';
        instOfContract.Security_Review_Required__c = 'No';
        instOfContract.RecordTypeId = lstRecType.Id;
        instOfContract.SLA_Type__c = 'NonStandard SLA';
        instOfContract.Finance_Review_Required__c = 'No';
        instOfContract.Product_Enhancement__c = 'No';
        //Original line from below --> instOfContract.Primary_Opportunity__c = instOfOpp.Id;
        instOfContract.Primary_Opportunity__c  = instOfOpp.Id;
        instOfContract.Status = 'Ready for Signature';
        instOfContract.Accountid = instofAcc.id;
        insert instOfContract;
        
        instOfCCC.contractRec.Document_Type__c = 'Cvent Modified Terms';
        instOfCCC.contractRec.Security_Review_Required__c = 'No';
        instOfCCC.contractRec.RecordTypeId = lstRecType.Id;
        instOfCCC.contractRec.SLA_Type__c = 'Standard SLA (Current Version)';
        instOfCCC.contractRec.Finance_Review_Required__c = 'No';
        instOfCCC.contractRec.Product_Enhancement__c = 'No';
        instOfCCC.contractRec.Is_there_an_information_security_review__c = 'Yes';
        instOfCCC.SubmitSec();
        instOfCCC.Test();
        Contract instCOntr = [SELECT ID,Security_Review_Required__c,Document_Type__c,status,Legal_Review_Required__c FROM Contract];
        system.debug(instCOntr.Security_Review_Required__c+instCOntr.Legal_Review_Required__c+instCOntr.status);
        instCOntr.Security_Review_Required__c = 'No';
        instCOntr.Legal_Review_Required__c = 'No';
        system.debug('instCOntr.status++'+instCOntr.status);
        instCOntr.status = 'Assigned';
        update instCOntr;
        ApexPages.StandardController ApptController = new ApexPages.StandardController(instCOntr);
        ContractAnnouncementCls objc = new ContractAnnouncementCls(ApptController);
        Test.startTest();
        updateContractCount c = new updateContractCount();
        Database.executeBatch(c);
        Test.stopTest();
    }
}