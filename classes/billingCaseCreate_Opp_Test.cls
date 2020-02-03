@isTest(seeAllData=false)
public class billingCaseCreate_Opp_Test{
    Private static User u;
    Private static void createUser(string roleName,integer id ){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Finance - Management']; 
        String s = '%' + roleName + '%'; 
        USerrole testroleId=[select id from userRole where name like :s limit 1];
        u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, userRoleId=testroleId.id,
                     TimeZoneSidKey='America/Los_Angeles', UserName=id+'deploymentuser@cvent.com');
        
    }
    
    Static testmethod void oppAutomationYear1_Methodtest(){
        test.startTest();
        user u = TestUtil.CreateDeploymentUser();
        insert u;
        system.runAs(u)
        {
            
            Account acc= testutil.createAccount('name', 'Biz_Ac');
            acc.CVII_ID__c='11;12;23';
            acc.Affiliate_Name__c ='Curio Collection';
            acc.BillingCountryCode = 'US';
            acc.BillingState = 'TX';
            insert acc;
            //acc.Billing_Case__c=billingObj.Id;
            Id pricebookId = Test.getStandardPricebookId();
            Product2 prod = new Product2(Name = 'Product X', ProductCode = 'Pro-X',isActive = true);
            insert prod;
            
            //Create pricebook entry
            PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,
                                                        IsActive = true);
            
            system.debug('accountIDformutil'+acc.Id);
            Contact con= testutil.createContact('firstName', 'lastName', 'email@test.com', acc.Id);
            insert con;
            system.debug('contactformutil'+con.Id);
            opportunity opp = testutil.createOpportunity('theName', 'Event', 'Closed');
            opp.AccountId= acc.Id;
            opp.Contract_Number_New__c='123';
            opp.Contract_Implemented__c=false;
            opp.Deal_Year__c='1';
            opp.AccountId=acc.id;
            opp.ContractReceived__c=system.today();
            opp.ContractStartDate__c=system.today();
            opp.Chain_Deal__c='Bulk Purchase By Management Company';
            opp.Case_Received_Date__c=System.today();
            opp.Implementation_Response__c='1';
            opp.Contract_Number_New__c ='1';
            opp.Contact_Associated__c= con.Id;
            opp.Deal_Closed_by__c=u.Id;
            //opp.Manager__c='testManager@test.com';
            
            opp.Contact_Role__c='Primary User & Signer';
            opp.Pricebook2Id = pbEntry.Pricebook2Id;
            opp.NBB_Renewal__c ='Renewal';
            opp.Early_Contract__c='Not Early';
            opp.ContractStartDate__c= system.today()-1;
            
            date dt1 = date.newInstance(2018, 1, 1);
            date dt2 = date.newInstance(2018, 5, 1);
            opp.RenewalDate__c=dt2;
            opp.ContractReceived__c = dt1;
            //opp.Deal_Closed_by__c= u.Id;
            //opp.CVII_ID__c='1;2;3';
            insert opp;
            //system.debug('cviiId test'+opp.CVII_ID__c);
            
            
            
            HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
            hybrid.Name='2Test';
            hybrid.HybridValue__c='Attendee Hub';
            insert hybrid;
            
            RRATracker__c RR = new RRATracker__c();
            RR.RoundRobinId__c=0;
            RR.UserId__c=u.id;
            rr.Name='0';
            RR.User_Name__c ='test user';
            insert RR;
            
            
            opportunity oppquery = [select Id,accountId,CVII_ID__c,Contract_Number_New__c from opportunity where accountId=:acc.Id limit 1][0];
            system.assertEquals('11;12;23', oppquery.CVII_ID__c);
            oppquery.Date_Assigned__c=system.today();
            oppquery.Bill_To_Contact__c=con.Id;
            update oppquery;
            
            Contract_Reviewing__c conRev = new Contract_Reviewing__c();
            conRev.Accounting_Hybrid_Review_Ok__c='Yes';
            conRev.Contract_Reviewer__c=u.Id;
            conRev.Opportunity__c =oppquery.Id;
            //conRev.Opportunity_Contract__c =123;
            insert conRev;
            
            
            
            //system.debug('cviiId test update'+oppquery.CVII_ID__c);
            //system.debug('oppformutil---'+opp.Id+'oppqueryID>>>>'+oppquery.Id);
            
            // custom setting
            FeatureSet__c fCustomSetting= new FeatureSet__c();
            fCustomSetting.Name='1test';
            //fCustomSetting.FeatureSet__c='Attendee Hub';
            fCustomSetting.FeatureSet__c='Product X';
            insert fCustomSetting;
            

            insert pbEntry;
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id,
                                                              PricebookEntryId = pbEntry.Id,
                                                              quantity=4, 
                                                              totalprice=200);
            insert oli;
            list<opportunity> opplist = new list<opportunity>();
            opplist.add(oppquery);
            
            
            Contract_Reviewing__c ContractNum =[select Id,Accounting_Hybrid_Review_Ok__c,
                                                Opportunity__c,Contract_Reviewer__c,Opportunity_Contract__c
                                                from Contract_Reviewing__c where Opportunity__c=:oppquery.Id];
            billingCaseCreate_Opp_handler.oppAutomationYear1_Method(opplist);
            system.assertEquals(oppquery.ContractReceived__c, oppquery.CloseDate);
        }
    }
    Static testmethod void oppAutomationYear1_MethodtestNOOLI(){
        test.startTest();
        user u = TestUtil.CreateDeploymentUser();
        insert u;
        system.runAs(u)
        {
            
            Account acc= testutil.createAccount('name', 'Biz_Ac');
            acc.BillingCountryCode = 'US';
            acc.BillingState = 'TX';
            acc.CVII_ID__c='11;12;23';
            //acc.Affiliate_Name__c ='';
            insert acc;
            //acc.Billing_Case__c=billingObj.Id;
            Id pricebookId = Test.getStandardPricebookId();
            Product2 prod = new Product2(Name = 'Product X', ProductCode = 'Pro-X',isActive = true);
            insert prod;
            
            //Create pricebook entry
            PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,
                                                        IsActive = true);
            
            system.debug('accountIDformutil'+acc.Id);
            Contact con= testutil.createContact('firstName', 'lastName', 'email@test.com', acc.Id);
            insert con;
            system.debug('contactformutil'+con.Id);
            opportunity opp = testutil.createOpportunity('theName', 'Event', 'Closed');
            opp.AccountId= acc.Id;
            opp.Contract_Number_New__c='123';
            opp.Contract_Implemented__c=false;
            opp.Deal_Year__c='1';
            opp.AccountId=acc.id;
            opp.ContractReceived__c=system.today();
            opp.ContractStartDate__c=system.today();
            opp.Chain_Deal__c='Bulk Purchase By Management Company';
            opp.Case_Received_Date__c=System.today();
            opp.Implementation_Response__c='1';
            opp.Contract_Number_New__c ='1';
            opp.Contact_Associated__c= con.Id;
            opp.Deal_Closed_by__c=u.Id;
            opp.Chain_Name__c='Accor';
            opp.Brand_Name__c='Accor';
            //opp.Manager__c='testManager@test.com';
            
            opp.Contact_Role__c='Primary User & Signer';
            //opp.Pricebook2Id = pbEntry.Pricebook2Id;
            opp.NBB_Renewal__c ='Renewal';
            opp.Early_Contract__c='Not Early';
            opp.ContractStartDate__c= system.today()-1;
            
            date dt1 = date.newInstance(2018, 1, 1);
            date dt2 = date.newInstance(2018, 5, 1);
            opp.RenewalDate__c=dt2;
            opp.ContractReceived__c = dt1;
            //opp.Deal_Closed_by__c= u.Id;
            //opp.CVII_ID__c='1;2;3';
            insert opp;
            //system.debug('cviiId test'+opp.CVII_ID__c);
            
            
            
            HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
            hybrid.Name='2Test';
            hybrid.HybridValue__c='Attendee Hub';
            insert hybrid;
            
            RRATracker__c RR = new RRATracker__c();
            RR.RoundRobinId__c=0;
            RR.UserId__c=u.id;
            rr.Name='0';
            RR.User_Name__c ='test user';
            insert RR;
            
            
            opportunity oppquery = [select Id,accountId,CVII_ID__c,Contract_Number_New__c from opportunity where accountId=:acc.Id limit 1][0];
            system.assertEquals('11;12;23', oppquery.CVII_ID__c);
            oppquery.Date_Assigned__c=system.today();
            oppquery.Bill_To_Contact__c=con.Id;
            oppquery.MYD_Deal__c='MYD';
            update oppquery;
            
            Contract_Reviewing__c conRev = new Contract_Reviewing__c();
            conRev.Accounting_Hybrid_Review_Ok__c='Yes';
            conRev.Contract_Reviewer__c=u.Id;
            conRev.Opportunity__c =oppquery.Id;
            //conRev.Opportunity_Contract__c =123;
            insert conRev;
            
            
            
            //system.debug('cviiId test update'+oppquery.CVII_ID__c);
            //system.debug('oppformutil---'+opp.Id+'oppqueryID>>>>'+oppquery.Id);
            
            // custom setting
            FeatureSet__c fCustomSetting= new FeatureSet__c();
            fCustomSetting.Name='1test';
            //fCustomSetting.FeatureSet__c='Attendee Hub';
            fCustomSetting.FeatureSet__c='Product X';
            insert fCustomSetting;
            

            insert pbEntry;
            list<opportunity> opplist = new list<opportunity>();
            opplist.add(oppquery);
            
            
            Contract_Reviewing__c ContractNum =[select Id,Accounting_Hybrid_Review_Ok__c,
                                                Opportunity__c,Contract_Reviewer__c,Opportunity_Contract__c
                                                from Contract_Reviewing__c where Opportunity__c=:oppquery.Id];
            billingCaseCreate_Opp_handler.oppAutomationYear1_Method(opplist);
            //system.assertEquals(oppquery.ContractReceived__c, oppquery.CloseDate);
        }
    }
    static testmethod void billingCasemethod4()
    { 
        test.startTest();
        user u = TestUtil.CreateDeploymentUser();
        
        insert u;
        
        system.runAs(u)
        {
            Account acc= testutil.createAccount('name', 'Biz_Ac');
            acc.BillingCountryCode = 'US';
            acc.BillingState = 'TX';
            acc.Affiliate_Name__c ='Autograph Collection';
            insert acc;
            system.debug('accountIDformutil'+acc.Id);
            Contact con= testutil.createContact('firstName', 'lastName', 'email@test.com', acc.Id);
            insert con;
            system.debug('contactformutil'+con.Id);
            opportunity opp = testutil.createOpportunity('theName', 'Event', 'Closed');
            opp.AccountId= acc.Id;
            opp.Deal_Closed_by__c= u.Id;
            date dt1 = date.newInstance(2018, 1, 1);
            date dt2 = date.newInstance(2018, 5, 1);
            opp.RenewalDate__c=dt2;
            opp.ContractReceived__c = dt1;
            opp.MYD_Deal__c='MYD';
            insert opp;
            system.debug('oppformutil'+opp.Id);
            
            // custom setting
            FeatureSet__c fCustomSetting= new FeatureSet__c();
            fCustomSetting.Name='1test';
            //fCustomSetting.FeatureSet__c='Attendee Hub';
            fCustomSetting.FeatureSet__c='Product X';
            insert fCustomSetting;
            
            Id pricebookId = Test.getStandardPricebookId();
            Product2 prod = new Product2(Name = 'Product X', ProductCode = 'Pro-X',isActive = true);
            insert prod;
            
            //Create pricebook entry
            PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,
                                                        IsActive = true);
            insert pbEntry;
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id,
                                                              PricebookEntryId = pbEntry.Id,
                                                              quantity=4, 
                                                              totalprice=200);
            insert oli;
            list<opportunity> opplist = new list<opportunity>();
            opplist.add(opp);
            billingCaseCreate_opp_handler.oppAutomationYear1_Method(opplist);
            //billingCaseCreate_opp_handler.billingCaseCreate_Method(opplist);
        }
        test.stopTest();  
    }
    static testmethod void billingCasemethod5()
    { 
        test.startTest();
        user u = TestUtil.CreateDeploymentUser();
        insert u;
        system.runAs(u)
        {
            BillingCase__c billingObj = new BillingCase__c();
            billingObj.CVII_Number__c='123';
            billingObj.Name='testbilling';
            insert billingObj;
            
            
            Account acc= testutil.createAccount('name', 'Biz_Ac');
            acc.BillingCountryCode = 'US';
            acc.BillingState = 'TX';
            acc.CVII_ID__c='11;12;23';
            acc.Billing_Case__c=billingObj.Id;
            
            insert acc;
            system.debug('accountIDformutil'+acc.Id);
            Contact con= testutil.createContact('firstName', 'lastName', 'email@test.com', acc.Id);
            insert con;
            system.debug('contactformutil'+con.Id);
            opportunity opp = testutil.createOpportunity('theName', 'Event', 'Closed');
            opp.AccountId= acc.Id;
            //opp.Deal_Closed_by__c= u.Id;
            //opp.CVII_ID__c='1;2;3';
            
            insert opp;
            system.debug('cviiId test'+opp.CVII_ID__c);
            opportunity oppquery = [select Id,accountId,CVII_ID__c from opportunity where accountId=:acc.Id limit 1][0];
            system.assertEquals('11;12;23', oppquery.CVII_ID__c);
            oppquery.Date_Assigned__c=system.today();
            oppquery.Bill_To_Contact__c=con.Id;
            update oppquery;
            system.debug('cviiId test update'+oppquery.CVII_ID__c);
            system.debug('oppformutil---'+opp.Id+'oppqueryID>>>>'+oppquery.Id);
            
            // custom setting
            FeatureSet__c fCustomSetting= new FeatureSet__c();
            fCustomSetting.Name='1test';
            //fCustomSetting.FeatureSet__c='Attendee Hub';
            fCustomSetting.FeatureSet__c='Product X';
            insert fCustomSetting;
            
            Id pricebookId = Test.getStandardPricebookId();
            Product2 prod = new Product2(Name = 'Product X', ProductCode = 'Pro-X',isActive = true);
            insert prod;
            
            //Create pricebook entry
            PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,
                                                        IsActive = true);
            insert pbEntry;
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id,
                                                              PricebookEntryId = pbEntry.Id,
                                                              quantity=4, 
                                                              totalprice=200);
            insert oli;
            list<opportunity> opplist = new list<opportunity>();
            opplist.add(oppquery);
            //billingCaseCreate_opp_handler.oppAutomationYear1_Method(opplist);
            billingCaseCreate_opp_handler.billingCaseCreate_Method(opplist);
            
            
        }
        test.stopTest();  
    }
    static testmethod void billingCasemethod5BillingAddress()
    { 
        test.startTest();
        user u = TestUtil.CreateDeploymentUser();
        insert u;
        system.runAs(u)
        {
            BillingCase__c billingObj = new BillingCase__c();
            billingObj.CVII_Number__c='123';
            billingObj.Name='testbilling';
            insert billingObj;
            
            
            Account acc= testutil.createAccount('name', 'Biz_Ac');
            acc.BillingCountryCode = 'US';
            acc.BillingState = 'TX';
            acc.CVII_ID__c='11;12;23';
            acc.Billing_Case__c=billingObj.Id;
            
            insert acc;
            address__c address = testutil.createAccountAddress(acc.Id,'Billing');
            insert address;
            system.debug('accountIDformutil'+acc.Id);
            Contact con= testutil.createContact('firstName', 'lastName', 'email@test.com', acc.Id);
            insert con;
            system.debug('contactformutil'+con.Id);
            opportunity opp = testutil.createOpportunity('theName', 'Event', 'Closed');
            opp.AccountId= acc.Id;
            //opp.Deal_Closed_by__c= u.Id;
            //opp.CVII_ID__c='1;2;3';
            
            insert opp;
            system.debug('cviiId test'+opp.CVII_ID__c);
            opportunity oppquery = [select Id,accountId,CVII_ID__c from opportunity where accountId=:acc.Id limit 1][0];
            system.assertEquals('11;12;23', oppquery.CVII_ID__c);
            oppquery.Date_Assigned__c=system.today();
            //oppquery.Bill_To_Contact__c=con.Id;
            oppquery.Bill_To_Address__c=address.Id;
            update oppquery;
            system.debug('cviiId test update'+oppquery.CVII_ID__c);
            system.debug('oppformutil---'+opp.Id+'oppqueryID>>>>'+oppquery.Id);
            
            // custom setting
            FeatureSet__c fCustomSetting= new FeatureSet__c();
            fCustomSetting.Name='1test';
            //fCustomSetting.FeatureSet__c='Attendee Hub';
            fCustomSetting.FeatureSet__c='Product X';
            insert fCustomSetting;
            
            Id pricebookId = Test.getStandardPricebookId();
            Product2 prod = new Product2(Name = 'Product X', ProductCode = 'Pro-X',isActive = true);
            insert prod;
            
            //Create pricebook entry
            PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,
                                                        IsActive = true);
            insert pbEntry;
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id,
                                                              PricebookEntryId = pbEntry.Id,
                                                              quantity=4, 
                                                              totalprice=200);
            insert oli;
            list<opportunity> opplist = new list<opportunity>();
            opplist.add(oppquery);
            //billingCaseCreate_opp_handler.oppAutomationYear1_Method(opplist);
            billingCaseCreate_opp_handler.billingCaseCreate_Method(opplist);
            
            
        }
        test.stopTest();  
    }
    static testmethod void billingCasemethodElsePart()
    { 
        test.startTest();
        user u = TestUtil.CreateDeploymentUser();
        insert u;
        system.runAs(u)
        {
            BillingCase__c billingObj = new BillingCase__c();
            billingObj.CVII_Number__c='11;12;23';
            billingObj.Name='testbilling';
            insert billingObj;
            Account acc= testutil.createAccount('name', 'Biz_Ac');
            acc.BillingCountryCode = 'US';
            acc.BillingState = 'TX';
            acc.CVII_ID__c='11;12;23';
            //acc.Billing_Case__c=billingObj.Id; // commented  it for the billing case else part
            
            insert acc;
            system.debug('accountIDformutil'+acc.Id);
            Contact con= testutil.createContact('firstName', 'lastName', 'email@test.com', acc.Id);
            insert con;
            system.debug('contactformutil'+con.Id);
            opportunity opp = testutil.createOpportunity('theName', 'Event', 'Closed');
            opp.AccountId= acc.Id;
            //opp.Deal_Closed_by__c= u.Id;
            //opp.CVII_ID__c='1;2;3';
            
            insert opp;
            system.debug('cviiId test'+opp.CVII_ID__c);
            opportunity oppquery = [select Id,accountId,CVII_ID__c from opportunity where accountId=:acc.Id limit 1][0];
            system.assertEquals('11;12;23', oppquery.CVII_ID__c);
            oppquery.Date_Assigned__c=system.today();
            oppquery.Bill_To_Contact__c=con.Id;
            update oppquery;
            system.debug('cviiId test update'+oppquery.CVII_ID__c);
            system.debug('oppformutil---'+opp.Id+'oppqueryID>>>>'+oppquery.Id);
            
            // custom setting
            FeatureSet__c fCustomSetting= new FeatureSet__c();
            fCustomSetting.Name='1test';
            //fCustomSetting.FeatureSet__c='Attendee Hub';
            fCustomSetting.FeatureSet__c='Product X';
            insert fCustomSetting;
            
            Id pricebookId = Test.getStandardPricebookId();
            Product2 prod = new Product2(Name = 'Product X', ProductCode = 'Pro-X',isActive = true);
            insert prod;
            
            //Create pricebook entry
            PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,
                                                        IsActive = true);
            insert pbEntry;
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id,
                                                              PricebookEntryId = pbEntry.Id,
                                                              quantity=4, 
                                                              totalprice=200);
            insert oli;
            list<opportunity> opplist = new list<opportunity>();
            opplist.add(oppquery);
            //billingCaseCreate_opp_handler.oppAutomationYear1_Method(opplist);
            billingCaseCreate_opp_handler.billingCaseCreate_Method(opplist);
            
            
        }
        test.stopTest();  
    }
    static testmethod void billingCasemethodElsePartBillAddress()
    { 
        test.startTest();
        user u = TestUtil.CreateDeploymentUser();
        insert u;
        system.runAs(u)
        {
            BillingCase__c billingObj = new BillingCase__c();
            billingObj.CVII_Number__c='11;12;23';
            billingObj.Name='testbilling';
            insert billingObj;
            Account acc= testutil.createAccount('name', 'Biz_Ac');
            acc.BillingCountryCode = 'US';
            acc.BillingState = 'TX';
            acc.CVII_ID__c='11;12;23';
            //acc.Billing_Case__c=billingObj.Id; // commented  it for the billing case else part
            address__c address = testutil.createAccountAddress(acc.Id,'Billing');
            address.City__c=' TestCity';
            insert address;
            insert acc;
            system.debug('accountIDformutil'+acc.Id);
            Contact con= testutil.createContact('firstName', 'lastName', 'email@test.com', acc.Id);
            insert con;
            system.debug('contactformutil'+con.Id);
            opportunity opp = testutil.createOpportunity('theName', 'Event', 'Closed');
            opp.AccountId= acc.Id;
            //opp.Deal_Closed_by__c= u.Id;
            //opp.CVII_ID__c='1;2;3';
            
            insert opp;
            system.debug('cviiId test'+opp.CVII_ID__c);
            opportunity oppquery = [select Id,accountId,CVII_ID__c from opportunity where accountId=:acc.Id limit 1][0];
            system.assertEquals('11;12;23', oppquery.CVII_ID__c);
            oppquery.Date_Assigned__c=system.today();
            //oppquery.Bill_To_Contact__c=con.Id;
            oppquery.Bill_To_Address__c=address.Id;
            update oppquery;
            system.debug('cviiId test update'+oppquery.CVII_ID__c);
            system.debug('oppformutil---'+opp.Id+'oppqueryID>>>>'+oppquery.Id);
            
            // custom setting
            FeatureSet__c fCustomSetting= new FeatureSet__c();
            fCustomSetting.Name='1test';
            //fCustomSetting.FeatureSet__c='Attendee Hub';
            fCustomSetting.FeatureSet__c='Product X';
            insert fCustomSetting;
            
            Id pricebookId = Test.getStandardPricebookId();
            Product2 prod = new Product2(Name = 'Product X', ProductCode = 'Pro-X',isActive = true);
            insert prod;
            
            //Create pricebook entry
            PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,
                                                        IsActive = true);
            insert pbEntry;
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id,
                                                              PricebookEntryId = pbEntry.Id,
                                                              quantity=4, 
                                                              totalprice=200);
            insert oli;
            list<opportunity> opplist = new list<opportunity>();
            opplist.add(oppquery);
            //billingCaseCreate_opp_handler.oppAutomationYear1_Method(opplist);
            billingCaseCreate_opp_handler.billingCaseCreate_Method(opplist);
        }
        test.stopTest();  
    }
    static testmethod void billingCasemethodbillToAddressElse298()
    { 
        test.startTest();
        user u = TestUtil.CreateDeploymentUser();
        insert u;
        system.runAs(u)
        {
            
            Account acc= testutil.createAccount('name', 'Biz_Ac');
            acc.BillingCountryCode = 'US';
            acc.BillingState = 'TX';
            acc.CVII_ID__c='11;12;23';
            //acc.Billing_Case__c=billingObj.Id;
            
            insert acc;
            address__c address = testutil.createAccountAddress(acc.Id,'Billing');
            insert address;
            system.debug('accountIDformutil'+acc.Id);
            Contact con= testutil.createContact('firstName', 'lastName', 'email@test.com', acc.Id);
            insert con;
            system.debug('contactformutil'+con.Id);
            opportunity opp = testutil.createOpportunity('theName', 'Event', 'Closed');
            opp.AccountId= acc.Id;
            //opp.Deal_Closed_by__c= u.Id;
            //opp.CVII_ID__c='1;2;3';
            
            insert opp;
            system.debug('cviiId test'+opp.CVII_ID__c);
            opportunity oppquery = [select Id,accountId,CVII_ID__c from opportunity where accountId=:acc.Id limit 1][0];
            system.assertEquals('11;12;23', oppquery.CVII_ID__c);
            oppquery.Date_Assigned__c=system.today();
            //oppquery.Bill_To_Contact__c=con.Id;
            oppQuery.Bill_To_Address__c= address.Id;
            update oppquery;
            system.debug('cviiId test update'+oppquery.CVII_ID__c);
            system.debug('oppformutil---'+opp.Id+'oppqueryID>>>>'+oppquery.Id);
            
            // custom setting
            FeatureSet__c fCustomSetting= new FeatureSet__c();
            fCustomSetting.Name='1test';
            //fCustomSetting.FeatureSet__c='Attendee Hub';
            fCustomSetting.FeatureSet__c='Product X';
            insert fCustomSetting;
            
            Id pricebookId = Test.getStandardPricebookId();
            Product2 prod = new Product2(Name = 'Product X', ProductCode = 'Pro-X',isActive = true);
            insert prod;
            
            //Create pricebook entry
            PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,
                                                        IsActive = true);
            insert pbEntry;
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id,
                                                              PricebookEntryId = pbEntry.Id,
                                                              quantity=4, 
                                                              totalprice=200);
            insert oli;
            list<opportunity> opplist = new list<opportunity>();
            opplist.add(oppquery);
            //billingCaseCreate_opp_handler.oppAutomationYear1_Method(opplist);
            billingCaseCreate_opp_handler.billingCaseCreate_Method(opplist);
            
            
        }
        test.stopTest();  
    }
    
    static testmethod void billingCasemethodbillTocontactElse298()
    { 
        test.startTest();
        user u = TestUtil.CreateDeploymentUser();
        insert u;
        system.runAs(u)
        {
            
            Account acc= testutil.createAccount('name', 'Biz_Ac');
            acc.BillingCountryCode = 'US';
            acc.BillingState = 'TX';
            acc.CVII_ID__c='11;12;23';
            //acc.Billing_Case__c=billingObj.Id;
            
            insert acc;
            address__c address = testutil.createAccountAddress(acc.Id,'Billing');
            insert address;
            system.debug('accountIDformutil'+acc.Id);
            Contact con= testutil.createContact('firstName', 'lastName', 'email@test.com', acc.Id);
            insert con;
            system.debug('contactformutil'+con.Id);
            opportunity opp = testutil.createOpportunity('theName', 'Event', 'Closed');
            opp.AccountId= acc.Id;
            //opp.Deal_Closed_by__c= u.Id;
            //opp.CVII_ID__c='1;2;3';
            
            insert opp;
            system.debug('cviiId test'+opp.CVII_ID__c);
            opportunity oppquery = [select Id,accountId,CVII_ID__c from opportunity where accountId=:acc.Id limit 1][0];
            system.assertEquals('11;12;23', oppquery.CVII_ID__c);
            oppquery.Date_Assigned__c=system.today();
            oppquery.Bill_To_Contact__c=con.Id;
            //oppQuery.Bill_To_Address__c= address.Id;
            update oppquery;
            system.debug('cviiId test update'+oppquery.CVII_ID__c);
            system.debug('oppformutil---'+opp.Id+'oppqueryID>>>>'+oppquery.Id);
            
            // custom setting
            FeatureSet__c fCustomSetting= new FeatureSet__c();
            fCustomSetting.Name='1test';
            //fCustomSetting.FeatureSet__c='Attendee Hub';
            fCustomSetting.FeatureSet__c='Product X';
            insert fCustomSetting;
            
            Id pricebookId = Test.getStandardPricebookId();
            Product2 prod = new Product2(Name = 'Product X', ProductCode = 'Pro-X',isActive = true);
            insert prod;
            
            //Create pricebook entry
            PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,
                                                        IsActive = true);
            insert pbEntry;
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id,
                                                              PricebookEntryId = pbEntry.Id,
                                                              quantity=4, 
                                                              totalprice=200);
            insert oli;
            list<opportunity> opplist = new list<opportunity>();
            opplist.add(oppquery);
            //billingCaseCreate_opp_handler.oppAutomationYear1_Method(opplist);
            billingCaseCreate_opp_handler.billingCaseCreate_Method(opplist);
            
            
        }
        test.stopTest();  
    }
    Static testmethod void createContractReviewTestMethod(){
        test.startTest();
        user u = TestUtil.CreateDeploymentUser();
        insert u;
        system.runAs(u)
        {
            
            Account acc= testutil.createAccount('name', 'Biz_Ac');
            acc.BillingCountryCode = 'US';
            acc.BillingState = 'TX';
            acc.CVII_ID__c='11;12;23';
            //acc.Billing_Case__c=billingObj.Id;
            
            insert acc;
            system.debug('accountIDformutil'+acc.Id);
            Contact con= testutil.createContact('firstName', 'lastName', 'email@test.com', acc.Id);
            insert con;
            system.debug('contactformutil'+con.Id);
            opportunity opp = testutil.createOpportunity('theName', 'Event', 'Closed');
            opp.AccountId= acc.Id;
            opp.Contract_Number_New__c='123';
            //opp.Deal_Closed_by__c= u.Id;
            //opp.CVII_ID__c='1;2;3';
            insert opp;
            //system.debug('cviiId test'+opp.CVII_ID__c);
            
            
            
            HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
            hybrid.Name='2Test';
            hybrid.HybridValue__c='Attendee Hub';
            insert hybrid;
            
            RRATracker__c RR = new RRATracker__c();
            RR.RoundRobinId__c=0;
            RR.UserId__c=u.id;
            rr.Name='0';
            RR.User_Name__c ='test user';
            insert RR;
            
            
            opportunity oppquery = [select Id,accountId,CVII_ID__c,Contract_Number_New__c from opportunity where accountId=:acc.Id limit 1][0];
            system.assertEquals('11;12;23', oppquery.CVII_ID__c);
            oppquery.Date_Assigned__c=system.today();
            oppquery.Bill_To_Contact__c=con.Id;
            update oppquery;
            
            Contract_Reviewing__c conRev = new Contract_Reviewing__c();
            conRev.Accounting_Hybrid_Review_Ok__c='Yes';
            conRev.Contract_Reviewer__c=u.Id;
            conRev.Opportunity__c =oppquery.Id;
            //conRev.Opportunity_Contract__c =123;
            insert conRev;
            
            
            
            //system.debug('cviiId test update'+oppquery.CVII_ID__c);
            //system.debug('oppformutil---'+opp.Id+'oppqueryID>>>>'+oppquery.Id);
            
            // custom setting
            FeatureSet__c fCustomSetting= new FeatureSet__c();
            fCustomSetting.Name='1test';
            //fCustomSetting.FeatureSet__c='Attendee Hub';
            fCustomSetting.FeatureSet__c='Product X';
            insert fCustomSetting;
            
            Id pricebookId = Test.getStandardPricebookId();
            Product2 prod = new Product2(Name = 'Product X', ProductCode = 'Pro-X',isActive = true);
            insert prod;
            
            //Create pricebook entry
            PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,
                                                        IsActive = true);
            insert pbEntry;
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id,
                                                              PricebookEntryId = pbEntry.Id,
                                                              quantity=4, 
                                                              totalprice=200);
            insert oli;
            list<opportunity> opplist = new list<opportunity>();
            opplist.add(oppquery);
            
            
            Contract_Reviewing__c ContractNum =[select Id,Accounting_Hybrid_Review_Ok__c,
                                                Opportunity__c,Contract_Reviewer__c,Opportunity_Contract__c
                                                from Contract_Reviewing__c where Opportunity__c=:oppquery.Id];
            
            map<id,Boolean> mapcontractReview = new map<id,Boolean>();
            mapcontractReview.put(oppquery.Id,true);
            billingCaseCreate_Opp_handler.createContractReview(opplist,mapcontractReview);
            
        }
    }
    Static testmethod void createContractReviewTestMethodElsePart(){
        test.startTest();
        user u = TestUtil.CreateDeploymentUser();
        insert u;
        system.runAs(u)
        {
            
            Account acc= testutil.createAccount('name', 'Biz_Ac');
            acc.BillingCountryCode = 'US';
            acc.BillingState = 'TX';
            acc.CVII_ID__c='11;12;23';
            //acc.Billing_Case__c=billingObj.Id;
            
            insert acc;
            system.debug('accountIDformutil'+acc.Id);
            Contact con= testutil.createContact('firstName', 'lastName', 'email@test.com', acc.Id);
            insert con;
            system.debug('contactformutil'+con.Id);
            opportunity opp = testutil.createOpportunity('theName', 'Event', 'Closed');
            opp.AccountId= acc.Id;
            opp.Contract_Number_New__c='123';
            //opp.Deal_Closed_by__c= u.Id;
            //opp.CVII_ID__c='1;2;3';
            insert opp;
            //system.debug('cviiId test'+opp.CVII_ID__c);
            
            
            
            HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
            hybrid.Name='2Test';
            hybrid.HybridValue__c='Attendee Hub';
            insert hybrid;
            
            RRATracker__c RR = new RRATracker__c();
            RR.RoundRobinId__c=0;
            RR.UserId__c=u.id;
            rr.Name='0';
            RR.User_Name__c ='test user';
            insert RR;
            
            
            opportunity oppquery = [select Id,accountId,CVII_ID__c,Contract_Number_New__c from opportunity where accountId=:acc.Id limit 1][0];
            system.assertEquals('11;12;23', oppquery.CVII_ID__c);
            oppquery.Date_Assigned__c=system.today();
            oppquery.Bill_To_Contact__c=con.Id;
            update oppquery;
            
            Contract_Reviewing__c conRev = new Contract_Reviewing__c();
            conRev.Accounting_Hybrid_Review_Ok__c='Yes';
            //conRev.Contract_Reviewer__c=u.Id;
            conRev.Opportunity__c =oppquery.Id;
            //conRev.Opportunity_Contract__c =123;
            insert conRev;
            
            
            
            //system.debug('cviiId test update'+oppquery.CVII_ID__c);
            //system.debug('oppformutil---'+opp.Id+'oppqueryID>>>>'+oppquery.Id);
            
            // custom setting
            FeatureSet__c fCustomSetting= new FeatureSet__c();
            fCustomSetting.Name='1test';
            //fCustomSetting.FeatureSet__c='Attendee Hub';
            fCustomSetting.FeatureSet__c='Product X';
            insert fCustomSetting;
            
            Id pricebookId = Test.getStandardPricebookId();
            Product2 prod = new Product2(Name = 'Product X', ProductCode = 'Pro-X',isActive = true);
            insert prod;
            
            //Create pricebook entry
            PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,
                                                        IsActive = true);
            insert pbEntry;
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id,
                                                              PricebookEntryId = pbEntry.Id,
                                                              quantity=4, 
                                                              totalprice=200);
            insert oli;
            oppquery.Contract_Implemented__c=true;
            oppquery.Event_Name__C='Cvnet';
            update oppquery;
            list<opportunity> opplist = new list<opportunity>();
            opplist.add(oppquery);
            
            
            Contract_Reviewing__c ContractNum =[select Id,Accounting_Hybrid_Review_Ok__c,
                                                Opportunity__c,Contract_Reviewer__c,Opportunity_Contract__c
                                                from Contract_Reviewing__c where Opportunity__c=:oppquery.Id];
            ContractNum.Accounting_Hybrid_Review_Ok__c='No';
            ContractNum.Acc_Reviewer_Comments_Hybrid__c ='test comment';
            update ContractNum;
            map<id,Boolean> mapcontractReview = new map<id,Boolean>();
            mapcontractReview.put(oppquery.Id,true);                                            
            
            /* for else if part */
            billingCaseCreate_Opp_handler.createContractReview(opplist,mapcontractReview);
        }
    }
    Static testmethod void createContractReviewTestMethodISHybridloop(){
        test.startTest();
        user u = TestUtil.CreateDeploymentUser();
        insert u;
        system.runAs(u)
        {
            
            Account acc= testutil.createAccount('name', 'Biz_Ac');
            acc.BillingCountryCode = 'US';
            acc.BillingState = 'TX';
            acc.CVII_ID__c='11;12;23';
            //acc.Billing_Case__c=billingObj.Id;
            
            insert acc;
            system.debug('accountIDformutil'+acc.Id);
            Contact con= testutil.createContact('firstName', 'lastName', 'email@test.com', acc.Id);
            insert con;
            system.debug('contactformutil'+con.Id);
            opportunity opp = testutil.createOpportunity('theName', 'Event', 'Closed');
            opp.AccountId= acc.Id;
            //opp.Contract_Number_New__c=123;
            //opp.Deal_Closed_by__c= u.Id;
            //opp.CVII_ID__c='1;2;3';
            insert opp;
            //system.debug('cviiId test'+opp.CVII_ID__c);
            
            
            
            HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
            hybrid.Name='2Test';
            hybrid.HybridValue__c='Attendee Hub';
            insert hybrid;
            
            RRATracker__c RR = new RRATracker__c();
            RR.RoundRobinId__c=0;
            RR.UserId__c=u.id;
            RR.name='test';
            RR.User_Name__c = u.name;
            insert RR;
            
            
            opportunity oppquery = [select Id,accountId,CVII_ID__c,Contract_Number_New__c from opportunity where accountId=:acc.Id limit 1][0];
            system.assertEquals('11;12;23', oppquery.CVII_ID__c);
            oppquery.Date_Assigned__c=system.today();
            oppquery.Bill_To_Contact__c=con.Id;
            update oppquery;
            //system.debug('cviiId test update'+oppquery.CVII_ID__c);
            //system.debug('oppformutil---'+opp.Id+'oppqueryID>>>>'+oppquery.Id);
            
            // custom setting
            FeatureSet__c fCustomSetting= new FeatureSet__c();
            fCustomSetting.Name='1test';
            //fCustomSetting.FeatureSet__c='Attendee Hub';
            fCustomSetting.FeatureSet__c='Product X';
            insert fCustomSetting;
            
            Id pricebookId = Test.getStandardPricebookId();
            Product2 prod = new Product2(Name = 'Product X', ProductCode = 'Pro-X',isActive = true);
            insert prod;
            
            //Create pricebook entry
            PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,
                                                        IsActive = true);
            insert pbEntry;
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id,
                                                              PricebookEntryId = pbEntry.Id,
                                                              quantity=4, 
                                                              totalprice=200);
            insert oli;
            list<opportunity> opplist = new list<opportunity>();
            opplist.add(oppquery);
            map<id,Boolean> mapcontractReview = new map<id,Boolean>();
            mapcontractReview.put(oppquery.Id,true);
            billingCaseCreate_Opp_handler.createContractReview(opplist,mapcontractReview);
        }
    }
    Static testmethod void createContractReviewTestMethodISHybridloopFalse(){
        test.startTest();
        user u = TestUtil.CreateDeploymentUser();
        insert u;
        system.runAs(u)
        {
            
            Account acc= testutil.createAccount('name', 'Biz_Ac');
            acc.BillingCountryCode = 'US';
            acc.BillingState = 'TX';
            acc.CVII_ID__c='11;12;23';
            //acc.Billing_Case__c=billingObj.Id;
            
            insert acc;
            system.debug('accountIDformutil'+acc.Id);
            Contact con= testutil.createContact('firstName', 'lastName', 'email@test.com', acc.Id);
            insert con;
            system.debug('contactformutil'+con.Id);
            opportunity opp = testutil.createOpportunity('theName', 'Event', 'Closed');
            opp.AccountId= acc.Id;
            //opp.Contract_Number_New__c=123;
            //opp.Deal_Closed_by__c= u.Id;
            //opp.CVII_ID__c='1;2;3';
            insert opp;
            //system.debug('cviiId test'+opp.CVII_ID__c);
            
            
            
            HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
            hybrid.Name='2Test';
            hybrid.HybridValue__c='Attendee Hub';
            insert hybrid;
            
            RRATracker__c RR = new RRATracker__c();
            RR.RoundRobinId__c=0;
            RR.UserId__c=u.id;
            RR.name='test';
            RR.User_Name__c = u.name;
            insert RR;
            
            
            opportunity oppquery = [select Id,accountId,CVII_ID__c,Contract_Number_New__c from opportunity where accountId=:acc.Id limit 1][0];
            system.assertEquals('11;12;23', oppquery.CVII_ID__c);
            oppquery.Date_Assigned__c=system.today();
            oppquery.Bill_To_Contact__c=con.Id;
            update oppquery;
            //system.debug('cviiId test update'+oppquery.CVII_ID__c);
            //system.debug('oppformutil---'+opp.Id+'oppqueryID>>>>'+oppquery.Id);
            
            // custom setting
            FeatureSet__c fCustomSetting= new FeatureSet__c();
            fCustomSetting.Name='1test';
            //fCustomSetting.FeatureSet__c='Attendee Hub';
            fCustomSetting.FeatureSet__c='Product X';
            insert fCustomSetting;
            
            Id pricebookId = Test.getStandardPricebookId();
            Product2 prod = new Product2(Name = 'Product X', ProductCode = 'Pro-X',isActive = true);
            insert prod;
            
            //Create pricebook entry
            PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,
                                                        IsActive = true);
            insert pbEntry;
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id,
                                                              PricebookEntryId = pbEntry.Id,
                                                              quantity=4, 
                                                              totalprice=200);
            insert oli;
            list<opportunity> opplist = new list<opportunity>();
            opplist.add(oppquery);
            map<id,Boolean> mapcontractReview = new map<id,Boolean>();
            mapcontractReview.put(oppquery.Id,False);
            billingCaseCreate_Opp_handler.createContractReview(opplist,mapcontractReview);
        }
    }
}