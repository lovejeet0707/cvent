/* ===============================
AUTHOR     : Mohsin Siddiqui    
CREATED DATE     : 15 APR 2019  
PURPOSE     :  Test Class For "ShowImplementationSurveyDetailsCtrl"
SPECIAL NOTES:  

============================= 
*/

@isTest
public class ShowImplementationSurveyDetailsCtrlTest 
{
    public static testmethod void ImplementationSurveyForEC()
    {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        //Userrole[] testroleId=[select id from userRole where name ='Direct Sales (Event)' limit 1];
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Sherlin', LastName='Lauren', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='deploymentuser@cvent.com.testing',UserRoleId = r.Id);
        insert user1;
        
        
        Opportunity instOpp;
        
        System.runAs(user1)
        {  
            TaxValidationUsersOnIMPSurvey__c custSetting = new TaxValidationUsersOnIMPSurvey__c();
            custSetting.name = user1.Id;
            insert custSetting;
            Account instofAcc=TestUtil.createAccount('Test Account','Biz_Ac');
            instofAcc.Supplier_Type__c = 'Venue';
            instofAcc.Venue_Type__c = 'CVB';
            instofAcc.CSN_Status__c ='Using';
            instofAcc.Supplier_Status__c='Approved';
            insert instofAcc;
            
            Contact instofCon = TestUtil.createContact(String.valueOf(instofAcc.Id));
            instOfCon.Email = 'Test987654321@test.com';
            instOfCon.Phone = '8877665544';
            insert instofCon;
            
            Opportunity_Products__c oppProductCS = new Opportunity_Products__c();
            oppProductCS.Name = 'Event';
            oppProductCS.Type__c = 'EC';
            insert oppProductCS;
            
            Opportunity_Record_Types__c oppRecordTypeCS = new Opportunity_Record_Types__c();
            oppRecordTypeCS.Name = 'Event';
            oppRecordTypeCS.Type__c = 'EC';
            insert oppRecordTypeCS;
            
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
            instOpp = TestUtil.createOpportunityNew('Test Opportunity','Qualified',instOfCon.Id,instofAcc.Id);
            instOpp.RecordTypeId = oppRecordTypeId;
            instOpp.Deal_Year__c ='1';
            instOpp.NBB_Renewal__c = 'NBB';
            instOpp.Parent_Upsell__c = 'Primary';
            instOpp.CloseDate = system.today().addmonths(12);
            //instOpp.Contract_Implemented__c = true;
            instOpp.ContractReceived__c = system.today();
            instOpp.Product__c ='TicketMob';
            instOpp.Net_Amount_Opp__c = 2500;
            instOpp.MYD_Deal__c='First Year';
            instOpp.pricebook2id=Test.getStandardPricebookID();
            insert instOpp;
            
            SBQQ__Quote__c sbqq = new SBQQ__Quote__c();
            sbqq.SBQQ__StartDate__c=system.today();
            sbqq.SBQQ__Opportunity2__c = instopp.id;
            sbqq.Contract_Term_Years__c = '1';
            insert sbqq;
            
            instopp.SBQQ__PrimaryQuote__c=sbqq.id;
            update instopp;
            
            Product2 product1 = new Product2();
            product1.Name = 'Product 1';
            product1.Contract_Output_Grouping__c = 'Event Cloud';
            product1.Family = 'CrowdCompass';
            product1.ProductCode = 'CV-SW-EC-SCT-SCTPLNLISC';
            product1.isActive = true;
            insert product1;
            
            //Insert Quote Line
            SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
            ql1.SBQQ__Quantity__c = 1;
            ql1.SBQQ__Product__c = product1.Id;
            ql1.SBQQ__ListPrice__c = 10;
            ql1.SBQQ__NetPrice__c = 10;
            ql1.Rack_Rate__c = 10;
            ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            ql1.SBQQ__Number__c = 1;
            ql1.SBQQ__Quote__c = sbqq.Id;
            ql1.Notes__c = 'abc';
            insert ql1;
        }
        System.debug('RecordType of Opp:'+instOpp.RecordTypeId);
        
        Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(instOpp);
        Test.setCurrentPageReference(new PageReference('Page.ShowImplementationSurveyDetails'));
        System.currentPageReference().getParameters().put('id', instOpp.Id);
        ShowImplementationSurveyDetailsCtrl instanceOfController = new ShowImplementationSurveyDetailsCtrl(sc);
        instanceOfController.implementationSurvey.Upgrade_account_from_Renewal_Desk_to_AM__c = 'Yes';
        PageReference saveResult = instanceOfController.OnSave();
        instanceOfController.implementationSurvey.Give_Specific_Details__c = 'Yes!!!';
        PageReference saveResult1 = instanceOfController.OnSave();
        PageReference saveResult2 = instanceOfController.OnCancel();
        Test.StopTest();
    }
    
    public static testmethod void ImplementationSurveyForECContainIS()
    {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Sherlin', LastName='Lauren', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='deploymentuser@cvent.com.testing',UserRoleId = r.Id);
        insert user1;
        
        
        
        Opportunity instOpp;
        System.runAs(user1)
        {     
            
            Account instofAcc=TestUtil.createAccount('Test Account','Biz_Ac');
            instofAcc.Supplier_Type__c = 'Venue';
            instofAcc.Venue_Type__c = 'CVB';
            instofAcc.CSN_Status__c ='Using';
            instofAcc.Supplier_Status__c='Approved';
            insert instofAcc;
            
            Contact instofCon=TestUtil.createContact(instofAcc.id);
            instOfCon.Email = 'Test987654321@test.com';
            instOfCon.Phone = '8877665544';
            insert instofCon;
            
            Opportunity_Products__c oppProductCS = new Opportunity_Products__c();
            oppProductCS.Name = 'Event';
            oppProductCS.Type__c = 'EC';
            insert oppProductCS;
            
            Opportunity_Record_Types__c oppRecordTypeCS = new Opportunity_Record_Types__c();
            oppRecordTypeCS.Name = 'Event';
            oppRecordTypeCS.Type__c = 'EC';
            insert oppRecordTypeCS;
            
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
            instOpp = TestUtil.createOpportunityNew('Test Opportunity','Qualified',instOfCon.Id,instofAcc.Id);
            instOpp.RecordTypeId = oppRecordTypeId;
            instOpp.Deal_Year__c ='1';
            instOpp.NBB_Renewal__c = 'NBB';
            instOpp.Parent_Upsell__c = 'Primary';
            instOpp.CloseDate = system.today().addmonths(12);
            //instOpp.Contract_Implemented__c = true;
            instOpp.ContractReceived__c = system.today();
            instOpp.Product__c ='TicketMob';
            instOpp.Net_Amount_Opp__c = 2500;
            instOpp.MYD_Deal__c='First Year';
            instOpp.pricebook2id=Test.getStandardPricebookID();
            insert instOpp;
            
            SBQQ__Quote__c sbqq = new SBQQ__Quote__c();
            sbqq.SBQQ__StartDate__c=system.today();
            sbqq.SBQQ__Opportunity2__c = instopp.id;
            sbqq.Contract_Term_Years__c = '1';
            insert sbqq;
            
            instopp.SBQQ__PrimaryQuote__c=sbqq.id;
            update instopp;
            
            Product2 product1 = new Product2();
            product1.Name = 'Product 1';
            product1.Contract_Output_Grouping__c = 'Event Cloud';
            product1.Family = 'CrowdCompass';
            product1.ProductCode = 'CV-SW-EC-SCT-SCTPLNLISC';
            product1.isActive = true;
            insert product1;
            
            //Insert Quote Line
            SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
            ql1.SBQQ__Quantity__c = 1;
            ql1.SBQQ__Product__c = product1.Id;
            ql1.SBQQ__ListPrice__c = 10;
            ql1.SBQQ__NetPrice__c = 10;
            ql1.Rack_Rate__c = 10;
            ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            ql1.SBQQ__Number__c = 1;
            ql1.SBQQ__Quote__c = sbqq.Id;
            ql1.Notes__c = 'abc';
            insert ql1;
            
            Implementation_Survey__c instImp=new Implementation_Survey__c();
            instImp.Account__c=instofAcc.id;
            instImp.Opportunity__c=instopp.Id;
            instImp.Tax_Exempt__c='Yes, but certificate on file is expired';
            instImp.Upload_Tax_Exempt_Cert__c = 'No';
            instImp.Quote__c=sbqq.Id;
            insert instImp;
            
            System.debug('RecordType of Opp:'+instOpp.RecordTypeId);
            
            Test.StartTest(); 
            ApexPages.StandardController sc = new ApexPages.StandardController(instOpp);
            Test.setCurrentPageReference(new PageReference('Page.ShowImplementationSurveyDetails'));
            System.currentPageReference().getParameters().put('id', instOpp.Id);
            ShowImplementationSurveyDetailsCtrl instanceOfController = new ShowImplementationSurveyDetailsCtrl(sc);
            Attachment attachment1 = new Attachment();
            Blob b = Blob.valueOf('Test Data');
            attachment1.Body = b;
            attachment1.Name = 'Test Attachment';
            
            Attachment attachment2 = new Attachment();
            Blob b2 = Blob.valueOf('Test Data 2 ');
            attachment2.Body = b2;
            attachment2.Name = 'Test Attachment 2';
            
            ShowImplementationSurveyDetailsCtrl.oAttachment = attachment1;
            ShowImplementationSurveyDetailsCtrl.oAttachment2 = attachment2;
            instanceOfController.implementationSurvey.Upgrade_account_from_Renewal_Desk_to_AM__c = 'Yes';
            instanceOfController.implementationSurvey.K_has_mult_Bill_to_or_Ship_to_addresses__c = 'Yes';
            PageReference saveResult = instanceOfController.OnSave();
            Test.StopTest();
        }
    }
    
    public static testmethod void ImplementationSurveyForHC()
    {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Sherlin', LastName='Lauren', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='deploymentuser@cvent.com.testing',UserRoleId = r.Id);
        insert user1;
        
        
        
        Opportunity instOpp;
        System.runAs(user1)
        {      
        
        Account instofAcc=TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.CSN_Status__c ='Using';
        instofAcc.Supplier_Status__c='Approved';
        insert instofAcc;
        
        Contact instofCon=TestUtil.createContact(instofAcc.id);
        instOfCon.Email = 'Test987654321@test.com';
        instOfCon.Phone = '8877665544';
        insert instofCon;
        
        Opportunity_Products__c oppProductCS = new Opportunity_Products__c();
        oppProductCS.Name = 'CSN';
        oppProductCS.Type__c = 'HC';
        insert oppProductCS;
        
        Opportunity_Record_Types__c oppRecordTypeCS = new Opportunity_Record_Types__c();
        oppRecordTypeCS.Name = 'CSN_Supplier';
        oppRecordTypeCS.Type__c = 'HC';
        insert oppRecordTypeCS;
        
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSN_Supplier').getRecordTypeId();
            instOpp =TestUtil.createOpportunityNew('Test Opportunity','Qualified',instOfCon.Id,instofAcc.Id);
            instOpp.RecordTypeId = oppRecordTypeId;
            instOpp.Deal_Year__c ='1';
            instOpp.NBB_Renewal__c = 'NBB';
            instOpp.Parent_Upsell__c = 'Primary';
            instOpp.CloseDate = system.today().addmonths(12);
            //instOpp.Contract_Implemented__c = true;
            instOpp.ContractReceived__c = system.today();
            instOpp.Product__c ='TicketMob';
            instOpp.MYD_Deal__c='First Year';
            instOpp.pricebook2id=Test.getStandardPricebookID();
            insert instOpp;
            
            
            SBQQ__Quote__c sbqq = new SBQQ__Quote__c();
            sbqq.SBQQ__StartDate__c=system.today();
            sbqq.SBQQ__Opportunity2__c = instopp.id;
            sbqq.Contract_Term_Years__c = '1';
            insert sbqq;
            
            instopp.SBQQ__PrimaryQuote__c=sbqq.id;
            update instopp;
            
            Product2 product1 = new Product2();
            product1.Name = 'Product 1';
            product1.Contract_Output_Grouping__c = 'Event Cloud';
            product1.Family = 'Bundles';
            product1.ProductCode = 'CV-AD-HC-CSN-DGBRP';
            product1.isActive = true;
            insert product1;
            
            Product2 product3 = new Product2();
            product3.Name = 'Product 2';
            product3.Contract_Output_Grouping__c = 'Event Cloud';
            product3.Family = 'EMA';
            product3.ProductCode = 'CV-PE-HC-CEV-ELMALPKG';
            product3.isActive = true;
            insert product3;
            
            Product2 product4 = new Product2();
            product4.Name = 'Product 3';
            product4.Contract_Output_Grouping__c = 'Event Cloud';
            product4.Family = 'CventConnect';
            product4.ProductCode = 'CV-PE-HC-CEV-DEDCCEES';
            product4.isActive = true;
            insert product4;
            
            //Insert Quote Line
            SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
            ql1.SBQQ__Quantity__c = 1;
            ql1.SBQQ__Product__c = product1.Id;
            ql1.SBQQ__ListPrice__c = 10;
            ql1.SBQQ__NetPrice__c = 10;
            ql1.Rack_Rate__c = 10;
            ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            ql1.SBQQ__Number__c = 1;
            ql1.SBQQ__Quote__c = sbqq.Id;
            ql1.Notes__c = 'abc';
            insert ql1;
            
            //Insert Quote Line
            SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c();
            ql2.SBQQ__Quantity__c = 1;
            ql2.SBQQ__Product__c = product3.Id;
            ql2.SBQQ__ListPrice__c = 10;
            ql2.SBQQ__NetPrice__c = 10;
            ql2.Rack_Rate__c = 10;
            ql2.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            ql2.SBQQ__Number__c = 1;
            ql2.SBQQ__Quote__c = sbqq.Id;
            ql2.Notes__c = 'abc';
            insert ql2;
            
            //Insert Quote Line
            SBQQ__QuoteLine__c ql3 = new SBQQ__QuoteLine__c();
            ql3.SBQQ__Quantity__c = 1;
            ql3.SBQQ__Product__c = product4.Id;
            ql3.SBQQ__ListPrice__c = 10;
            ql3.SBQQ__NetPrice__c = 10;
            ql3.Rack_Rate__c = 10;
            ql3.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            ql3.SBQQ__Number__c = 1;
            ql3.SBQQ__Quote__c = sbqq.Id;
            ql3.Notes__c = 'abc';
            insert ql3;
        
        System.debug('RecordType of Opp:'+instOpp.RecordTypeId);
        
        Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(instOpp);
        Test.setCurrentPageReference(new PageReference('Page.ShowImplementationSurveyDetails'));
        System.currentPageReference().getParameters().put('id', instOpp.Id);
        ShowImplementationSurveyDetailsCtrl instanceOfController = new ShowImplementationSurveyDetailsCtrl(sc);
        Attachment attachment1 = new Attachment();
        Blob b = Blob.valueOf('Test Data');
        attachment1.Body = b;
        attachment1.Name = 'Test Attachment';
            
        Attachment attachment2 = new Attachment();
        Blob b2 = Blob.valueOf('Test Data 2 ');
        attachment2.Body = b2;
        attachment2.Name = 'Test Attachment 2';
        
        //attachment1.ParentId = instOpp.Id;
        //insert attachment1;
        ShowImplementationSurveyDetailsCtrl.oAttachment = attachment1;
        ShowImplementationSurveyDetailsCtrl.oAttachment2 = attachment2;
        instanceOfController.implementationSurvey.Tax_Exempt__c = 'Yes, but certificate on file is expired';
        instanceOfController.implementationSurvey.K_has_mult_Bill_to_or_Ship_to_addresses__c = 'Yes';
        PageReference saveResult = instanceOfController.OnSave();
        instanceOfController.EdittheSection();
        Test.StopTest();
        }
    }
    
    public static testmethod void ImplementationSurveyForRenewal()
    {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRoleCSN', Name = 'My Role CSN');
        insert r;
        
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Sherlin', LastName='Lauren', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='deploymentuser@cvent.com.testing',UserRoleId = r.Id);
        insert user1;
        
        
        
        Opportunity instOpp;
        System.runAs(user1)
        {     
            
            Account instofAcc=TestUtil.createAccount('Test Account','Biz_Ac');
            instofAcc.Supplier_Type__c = 'Venue';
            instofAcc.Venue_Type__c = 'CVB';
            instofAcc.CSN_Status__c ='Using';
            instofAcc.Supplier_Status__c='Approved';
            insert instofAcc;
            
            Contact instofCon=TestUtil.createContact(instofAcc.id);
            instOfCon.Email = 'Test987654321@test.com';
            instOfCon.Phone = '8877665544';
            insert instofCon;
            
            Opportunity_Products__c oppProductCS = new Opportunity_Products__c();
            oppProductCS.Name = 'Renewal';
            oppProductCS.Type__c = 'Both';
            insert oppProductCS;
            
            Opportunity_Record_Types__c oppRecordTypeCS = new Opportunity_Record_Types__c();
            oppRecordTypeCS.Name = 'Renewal';
            oppRecordTypeCS.Type__c = 'Both';
            insert oppRecordTypeCS;
            
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
            instOpp = TestUtil.createOpportunityNew('Test Opportunity','Qualified',instOfCon.Id,instofAcc.Id);
            instOpp.RecordTypeId = oppRecordTypeId;
            instOpp.Deal_Year__c ='1';
            instOpp.NBB_Renewal__c = 'NBB';
            instOpp.Parent_Upsell__c = 'Primary';
            instOpp.CloseDate = system.today().addmonths(12);
            //instOpp.Contract_Implemented__c = true;
            instOpp.ContractReceived__c = system.today();
            instOpp.Product__c ='TicketMob';
            instOpp.Net_Amount_Opp__c = 2500;
            instOpp.MYD_Deal__c='First Year';
            instOpp.RenewalDate__c = System.today() +365;
            instOpp.pricebook2id=Test.getStandardPricebookID();
            insert instOpp;
            
            SBQQ__Quote__c sbqq = new SBQQ__Quote__c();
            sbqq.SBQQ__StartDate__c=system.today();
            sbqq.SBQQ__Opportunity2__c = instopp.id;
            sbqq.Contract_Term_Years__c = '1';
            insert sbqq;
            
            instopp.SBQQ__PrimaryQuote__c=sbqq.id;
            update instopp;
            
            Product2 product1 = new Product2();
            product1.Name = 'Product 1';
            product1.Contract_Output_Grouping__c = 'Event Cloud';
            product1.Family = 'CrowdCompass';
            product1.ProductCode = 'CV-SW-EC-SCT-SCTPLNLISC';
            product1.isActive = true;
            insert product1;
            
            //Insert Quote Line
            SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
            ql1.SBQQ__Quantity__c = 1;
            ql1.SBQQ__Product__c = product1.Id;
            ql1.SBQQ__ListPrice__c = 10;
            ql1.SBQQ__NetPrice__c = 10;
            ql1.Rack_Rate__c = 10;
            ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            ql1.SBQQ__Number__c = 1;
            ql1.SBQQ__Quote__c = sbqq.Id;
            ql1.Notes__c = 'abc';
            insert ql1;
            
            Implementation_Survey__c instImp=new Implementation_Survey__c();
            instImp.Account__c=instofAcc.id;
            instImp.Opportunity__c=instopp.Id;
            instImp.Tax_Exempt__c='Yes, but certificate on file is expired';
            instImp.Upload_Tax_Exempt_Cert__c = 'No';
            instImp.Quote__c=sbqq.Id;
            insert instImp;
            
            System.debug('RecordType of Opp:'+instOpp.RecordTypeId);
            
            Test.StartTest(); 
            ApexPages.StandardController sc = new ApexPages.StandardController(instOpp);
            Test.setCurrentPageReference(new PageReference('Page.ShowImplementationSurveyDetails'));
            System.currentPageReference().getParameters().put('id', instOpp.Id);
            ShowImplementationSurveyDetailsCtrl instanceOfController = new ShowImplementationSurveyDetailsCtrl(sc);
            Attachment attachment1 = new Attachment();
            Blob b = Blob.valueOf('Test Data');
            attachment1.Body = b;
            attachment1.Name = 'Test Attachment';
            
            Attachment attachment2 = new Attachment();
            Blob b2 = Blob.valueOf('Test Data 2 ');
            attachment2.Body = b2;
            attachment2.Name = 'Test Attachment 2';
            
            ShowImplementationSurveyDetailsCtrl.oAttachment = attachment1;
            ShowImplementationSurveyDetailsCtrl.oAttachment2 = attachment2;
            instanceOfController.implementationSurvey.Upgrade_account_from_Renewal_Desk_to_AM__c = 'No';
            instanceOfController.implementationSurvey.K_has_mult_Bill_to_or_Ship_to_addresses__c = 'Yes';
            PageReference saveResult = instanceOfController.OnSave();
            Test.StopTest();
        }
    }
    /*
public static testmethod void ImplementationSurveyForBoth()
{
Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 

User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
EmailEncodingKey='UTF-8', FirstName='Sherlin', LastName='Lauren', LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', ProfileId = p.Id, 
TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
insert user1;

Account instofAcc=TestUtil.createAccount('Test Account','Biz_Ac');
instofAcc.Supplier_Type__c = 'Venue';
instofAcc.Venue_Type__c = 'CVB';
instofAcc.CSN_Status__c ='Using';
instofAcc.Supplier_Status__c='Approved';
instofAcc.BillingCountryCode='US';
instOfAcc.BillingState='TX';
insert instofAcc;

Contact instofCon=TestUtil.createContact(instofAcc.id);
instOfCon.Email = 'Test987654321@test.com';
instOfCon.Phone = '8877665544';
insert instofCon;

Opportunity_Products__c oppProductCS = new Opportunity_Products__c();
oppProductCS.Name = 'Event';
oppProductCS.Type__c = 'EC';
insert oppProductCS;

Opportunity_Record_Types__c oppRecordTypeCS = new Opportunity_Record_Types__c();
oppRecordTypeCS.Name = 'Renewal';
oppRecordTypeCS.Type__c = 'Both';
insert oppRecordTypeCS;

Opportunity instOpp;
System.runAs(user1)
{      
Id oppRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
instOpp =TestUtil.createOpportunity('Test Opp','Renewal','Qualified');
instOpp.StageName ='Qualified';
//instOpp.RecordTypeId = oppRecordTypeId;
instOpp.Deal_Year__c ='1';
instOpp.NBB_Renewal__c = 'Renewal';
instOpp.RenewalDate__c = System.today()+5;
instOpp.Parent_Upsell__c = 'Primary';
instOpp.Product__c = 'Event';
instOpp.Opp_Owner_Role__c = 'Administrator'; 
instOpp.CloseDate = system.today().addmonths(12);
instOpp.Contract_Implemented__c = true;
instOpp.ContractReceived__c = system.today();
instOpp.Product__c ='TicketMob';
instOpp.MYD_Deal__c='First Year';
instOpp.pricebook2id=Test.getStandardPricebookID();
instOpp.Contact_Associated__c=instofCon.id; 
insert instOpp;


SBQQ__Quote__c sbqq = new SBQQ__Quote__c();
sbqq.SBQQ__StartDate__c=system.today();
sbqq.SBQQ__Opportunity2__c = instopp.id;
sbqq.Contract_Term_Years__c = '1';
insert sbqq;

instopp.SBQQ__PrimaryQuote__c=sbqq.id;
update instopp;

Product2 product1 = new Product2();
product1.Name = 'Product 1';
product1.Contract_Output_Grouping__c = 'Event Cloud';
product1.Family = 'Bundles';
product1.ProductCode = 'CV-AD-HC-CSN-DGBRP';
product1.isActive = true;
insert product1;

Product2 product3 = new Product2();
product3.Name = 'Product 2';
product3.Contract_Output_Grouping__c = 'Event Cloud';
product3.Family = 'EMA';
product3.ProductCode = 'CV-PE-HC-CEV-ELMALPKG';
product3.isActive = true;
insert product3;

Product2 product4 = new Product2();
product4.Name = 'Product 3';
product4.Contract_Output_Grouping__c = 'Event Cloud';
product4.Family = 'CventConnect';
product4.ProductCode = 'CV-PE-HC-CEV-DEDCCEES';
product4.isActive = true;
insert product4;

//Insert Quote Line
SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
ql1.SBQQ__Quantity__c = 1;
ql1.SBQQ__Product__c = product1.Id;
ql1.SBQQ__ListPrice__c = 10;
ql1.SBQQ__NetPrice__c = 10;
ql1.Rack_Rate__c = 10;
ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
ql1.SBQQ__Number__c = 1;
ql1.SBQQ__Quote__c = sbqq.Id;
ql1.Notes__c = 'abc';
insert ql1;

//Insert Quote Line
SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c();
ql2.SBQQ__Quantity__c = 1;
ql2.SBQQ__Product__c = product3.Id;
ql2.SBQQ__ListPrice__c = 10;
ql2.SBQQ__NetPrice__c = 10;
ql2.Rack_Rate__c = 10;
ql2.SBQQ__SubscriptionPricing__c = 'Fixed Price';
ql2.SBQQ__Number__c = 1;
ql2.SBQQ__Quote__c = sbqq.Id;
ql2.Notes__c = 'abc';
insert ql2;

//Insert Quote Line
SBQQ__QuoteLine__c ql3 = new SBQQ__QuoteLine__c();
ql3.SBQQ__Quantity__c = 1;
ql3.SBQQ__Product__c = product4.Id;
ql3.SBQQ__ListPrice__c = 10;
ql3.SBQQ__NetPrice__c = 10;
ql3.Rack_Rate__c = 10;
ql3.SBQQ__SubscriptionPricing__c = 'Fixed Price';
ql3.SBQQ__Number__c = 1;
ql3.SBQQ__Quote__c = sbqq.Id;
ql3.Notes__c = 'abc';
insert ql3;
}
System.debug('RecordType of Opp:'+instOpp.RecordTypeId);

Test.StartTest(); 
ApexPages.StandardController sc = new ApexPages.StandardController(instOpp);
Test.setCurrentPageReference(new PageReference('Page.ShowImplementationSurveyDetails'));
System.currentPageReference().getParameters().put('id', instOpp.Id);
ShowImplementationSurveyDetailsCtrl instanceOfController = new ShowImplementationSurveyDetailsCtrl(sc);
Attachment attachment1 = new Attachment();
Blob b = Blob.valueOf('Test Data');
attachment1.Body = b;
attachment1.Name = 'Test Attachment';
ShowImplementationSurveyDetailsCtrl.oAttachment = attachment1;
instanceOfController.implementationSurvey.Tax_Exempt__c = 'Yes, but certificate on file is expired';
PageReference saveResult = instanceOfController.OnSave();
Test.StopTest();
}
*/
}