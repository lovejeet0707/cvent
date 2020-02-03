@istest
public class TaskAutomationTest {
   
    @testsetup
    static void setupdata()
    {
        
        
        Id recodrdtypeacc=schema.SObjectType.account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
        Id recodrdtypeopp=schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        //Account creation
        account acc = new account();
        acc.Name='TestAccount1';
        acc.RecordTypeId=recodrdtypeacc;
        acc.BillingCountry='MX';
        insert acc;
        
        
        accountTeamMember atm =testutil.createAccountTeamMember(acc.id, 'AM - Event');
        insert atm;
        
        opportunity opp = new opportunity();
        opp.Name='taskAutomation1';
        opp.AccountId=acc.Id;
        opp.CloseDate=system.today();
		opp.RenewalDate__c = System.today() + 365;
        opp.StageName='Verbal';
        opp.Product__c='Event';
        //opp.Contract_Implemented__c=true;
        opp.CurrencyIsoCode='USD';
        opp.RecordTypeId=recodrdtypeopp;
        insert opp; 
        //SBQQ data
        
                Id pricebookId = Test.getStandardPricebookId();
        /*sku  no sku Product*/
        product2 pdhccore = new product2();
        pdhccore.Name=' bundle no sku';
        pdhccore.Family='HC Core Products - Bundles & Promo Hub';
        pdhccore.Product_Line__c='Bundles';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-HC-CSN-WHTLAPRO';
        insert pdhccore;
         PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        
         SBQQ__Quote__c  SbQuote = new SBQQ__Quote__c();
        
        insert SbQuote;
        SBQQ__QuoteLine__c SBqline= new SBQQ__QuoteLine__c();
        Sbqline.SBQQ__Quote__c=sbquote.Id;
        sbqline.SBQQ__NetPrice__c =1732;
        sbqline.SBQQ__Quantity__c=1;
        sbqline.SBQQ__Product__c=pdhccore.Id;
        //sbqline.SBQQ__ProductCode__c='CV-SW-HC-CSN-WHTLAPRO';
        insert sbqline;
        opportunity opp1 = new opportunity();
		opp.RenewalDate__c = System.today() + 365;
        opp1.Name='SBQuoteopp';
        opp1.AccountId=acc.Id;
        opp1.CloseDate=system.today();
        opp1.RenewalDate__c = System.today() + 365;
        opp1.StageName='Verbal';
        opp1.Product__c='Event';
        //opp.Contract_Implemented__c=true;
        opp1.CurrencyIsoCode='USD';
        opp1.RecordTypeId=recodrdtypeopp;
        insert opp1; 
        SbQuote.SBQQ__Opportunity2__c=opp1.Id;
        update SbQuote;
        opp1.SBQQ__PrimaryQuote__c=SbQuote.Id;
        update opp1;
    }
	
	static testmethod void ValidateEC_AM_CC_Product()
    {      
        Id recodrdtypeacc=schema.SObjectType.account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
        Id recodrdtypeopp=schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        //Account creation
        account acc = new account();
        acc.Name='TestAccount';
        acc.RecordTypeId=recodrdtypeacc;
        acc.BillingCountry='MX';
        insert acc;
        
        accountTeamMember atm =testutil.createAccountTeamMember(acc.id, 'AM - Event');
        insert atm;
        
        opportunity opp = new opportunity();
        opp.Name='taskAutomation';
        opp.AccountId=acc.Id;
        opp.CloseDate=system.today();
        opp.RenewalDate__c = System.today() + 365;
        opp.StageName='Verbal';
        opp.Product__c='CrowdCompass';
        opp.RenewalDate__c = System.today() + 365;
        //opp.Contract_Implemented__c=true;
        opp.CurrencyIsoCode='USD';
        opp.RecordTypeId=recodrdtypeopp;
        insert opp;
        /*event Product*/
        product2 pd = new product2();
        pd.Name='setsku1';
        pd.IsActive=true;
        pd.Family='CrowdCompass';
        pd.ProductCode='CV-SW-EC-CC-CCMBAP50-CCMBAP50';
        insert pd;
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pd.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        OpportunityLineItem oli = testutil.createOpportunityLineItems(opp, standardPrice);
        insert oli;
        
        opp.StageName='Closed Won – Do Not Send to EBS';
        update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
    }
    
    static testmethod void ValidateEC_AM_OSS_Product()
    {      
        Id recodrdtypeacc=schema.SObjectType.account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
        Id recodrdtypeopp=schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        //Account creation
        account acc = new account();
        acc.Name='TestAccount';
        acc.RecordTypeId=recodrdtypeacc;
        acc.BillingCountry='MX';
        insert acc;
        
        accountTeamMember atm =testutil.createAccountTeamMember(acc.id, 'AM - Event');
        insert atm;
        
        opportunity opp = new opportunity();
        opp.Name='taskAutomation';
        opp.AccountId=acc.Id;
        opp.CloseDate=system.today();
        opp.RenewalDate__c = System.today() + 365;
        opp.StageName='Verbal';
        opp.Product__c='Onsite Solutions';
        opp.RenewalDate__c = System.today() + 365;
        //opp.Contract_Implemented__c=true;
        opp.CurrencyIsoCode='USD';
        opp.RecordTypeId=recodrdtypeopp;
        insert opp;
        /*event Product*/
        product2 pd = new product2();
        pd.Name='setsku1';
        pd.IsActive=true;
        pd.Family='Onsite Solutions';
        pd.ProductCode='CV-SW-EC-OSS-DEDOAPSOW';
        insert pd;
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pd.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        OpportunityLineItem oli = testutil.createOpportunityLineItems(opp, standardPrice);
        insert oli;
        
        opp.StageName='Closed Won – Do Not Send to EBS';
        update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
    }
    
    static testmethod void ValidateEC_AM_SS_Product()
    {      
        Id recodrdtypeacc=schema.SObjectType.account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
        Id recodrdtypeopp=schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        //Account creation
        account acc = new account();
        acc.Name='TestAccount';
        acc.RecordTypeId=recodrdtypeacc;
        acc.BillingCountry='MX';
        insert acc;
        
        accountTeamMember atm =testutil.createAccountTeamMember(acc.id, 'AM - Event');
        insert atm;
        
        opportunity opp = new opportunity();
        opp.Name='taskAutomation';
        opp.AccountId=acc.Id;
        opp.CloseDate=system.today();
        opp.RenewalDate__c = System.today() + 365;
        opp.StageName='Verbal';
        opp.Product__c='Social Tables';
        opp.RenewalDate__c = System.today() + 365;
        //opp.Contract_Implemented__c=true;
        opp.CurrencyIsoCode='USD';
        opp.RecordTypeId=recodrdtypeopp;
        insert opp;
        /*event Product*/
        product2 pd = new product2();
        pd.Name='setsku1';
        pd.IsActive=true;
        pd.Family='Social Tables';
        pd.ProductCode='CV-SW-EC-SCT-SCTPLNLISC';
        insert pd;
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pd.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        OpportunityLineItem oli = testutil.createOpportunityLineItems(opp, standardPrice);
        insert oli;
        
        opp.StageName='Closed Won – Do Not Send to EBS';
        update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
    }
    
    static testmethod void ValidateEC_AM_QM_Product()
    {      
        Id recodrdtypeacc=schema.SObjectType.account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
        Id recodrdtypeopp=schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        //Account creation
        account acc = new account();
        acc.Name='TestAccount';
        acc.RecordTypeId=recodrdtypeacc;
        acc.BillingCountry='MX';
        insert acc;
        
        accountTeamMember atm =testutil.createAccountTeamMember(acc.id, 'AM - Event');
        insert atm;
        
        opportunity opp = new opportunity();
        opp.Name='taskAutomation';
        opp.AccountId=acc.Id;
        opp.CloseDate=system.today();
        opp.RenewalDate__c = System.today() + 365;
        opp.StageName='Verbal';
        opp.Product__c='QuickMobile';
        opp.RenewalDate__c = System.today() + 365;
        //opp.Contract_Implemented__c=true;
        opp.CurrencyIsoCode='USD';
        opp.RecordTypeId=recodrdtypeopp;
        insert opp;
        /*event Product*/
        product2 pd = new product2();
        pd.Name='setsku1';
        pd.IsActive=true;
        pd.Family='QuickMobile';
        pd.ProductCode='CV-SW-EC-QML-CENSE114';
        insert pd;
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pd.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        OpportunityLineItem oli = testutil.createOpportunityLineItems(opp, standardPrice);
        insert oli;
        
        opp.StageName='Closed Won – Do Not Send to EBS';
        update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
    }
	
    static testmethod void ValidateEC_AM()
    {      
        Id recodrdtypeacc=schema.SObjectType.account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
        Id recodrdtypeopp=schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        //Account creation
        account acc = new account();
        acc.Name='TestAccount';
        acc.RecordTypeId=recodrdtypeacc;
        acc.BillingCountry='MX';
        insert acc;
        
        
        accountTeamMember atm =testutil.createAccountTeamMember(acc.id, 'AM - Event');
        insert atm;
        
        opportunity opp = new opportunity();
        opp.Name='taskAutomation';
        opp.AccountId=acc.Id;
        opp.CloseDate=system.today();
		opp.RenewalDate__c = System.today() + 365;
        opp.StageName='Verbal';
        opp.Product__c='Event';
		opp.RenewalDate__c = System.today() + 365;
        //opp.Contract_Implemented__c=true;
        opp.CurrencyIsoCode='USD';
        opp.RecordTypeId=recodrdtypeopp;
        insert opp;
        /*event Product*/
        product2 pd = new product2();
        pd.Name='setsku1';
        pd.IsActive=true;
        pd.Family='Event';
        pd.ProductCode='CV-SW-EC-EVT-ENTLICCORE';
        insert pd;
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pd.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        OpportunityLineItem oli = testutil.createOpportunityLineItems(opp, standardPrice);
        insert oli;
        
        product2 pdhccore = new product2();
        pdhccore.Name='accTeamMem1';
        pdhccore.Family='Event';
        pdhccore.IsActive=true;
        pdhccore.ProductCode='CV-SW-EC-EVT-CSNPLALICENT';
        insert pdhccore;
        
        PricebookEntry hccore = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert hccore;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, hccore);
        insert oli2;
        product2 pdhccoreSurvey = new product2();
        pdhccoreSurvey.Name='accTeamMem';
        pdhccoreSurvey.Family='CrowdCompass';
        pdhccoreSurvey.IsActive=true;
        pdhccoreSurvey.ProductCode='CV-SW-EC-CC-CCMBAP3001-CCMBAP3001';
        insert pdhccoreSurvey;
        
        
        PricebookEntry hccoreSurvey = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccoreSurvey.Id,
            UnitPrice = 10000, IsActive = true);
        insert hccoreSurvey;
        OpportunityLineItem oli3 = testutil.createOpportunityLineItems(opp, hccoreSurvey);
        insert oli3;
        opp.StageName='Closed Won – Do Not Send to EBS';
        update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
      
     
    }
    
    static testmethod void ValidateEC_AM2()
    {      
        Id recodrdtypeacc=schema.SObjectType.account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
        Id recodrdtypeopp=schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        //Account creation
        account acc = new account();
        acc.Name='TestAccount';
        acc.RecordTypeId=recodrdtypeacc;
        acc.BillingCountry='MX';
        insert acc;
        
        
        accountTeamMember atm =testutil.createAccountTeamMember(acc.id, 'AM - Event');
        insert atm;
        
        opportunity opp2 = new opportunity();
        opp2.Name='taskAutomation';
        opp2.AccountId=acc.Id;
        opp2.OptOutDate__c=system.today()+7;
		opp2.RenewalDate__c = System.today() + 365;
        opp2.CloseDate=system.today();
        opp2.StageName='Verbal';
        opp2.Product__c='Event';
        opp2.Contract_Implemented__c=false;
        opp2.CurrencyIsoCode='USD';
        opp2.RecordTypeId=recodrdtypeopp;
        insert opp2;
        
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name='accTeamMem';
        pdhccore.Family='CrowdCompass';
        pdhccore.IsActive=true;
        pdhccore.ProductCode='CV-SW-EC-CC-CCMBAP10001-CCMBAP10001';
        insert pdhccore;
        
        PricebookEntry hccore = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert hccore;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp2, hccore);
        insert oli2;
        opp2.StageName='Closed Won – Do Not Send to EBS';
        update opp2;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp2.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();

        
    }
    static testmethod void ValidateEC_AM3()
    {      
        Id recodrdtypeacc=schema.SObjectType.account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
        Id recodrdtypeopp=schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        //Account creation
        account acc = new account();
        acc.Name='TestAccount';
        acc.RecordTypeId=recodrdtypeacc;
        acc.BillingCountry='MX';
        insert acc;
        
        
        accountTeamMember atm =testutil.createAccountTeamMember(acc.id, 'AM - Event');
        insert atm;
        
        opportunity opp2 = new opportunity();
        opp2.Name='taskAutomation';
        opp2.AccountId=acc.Id;
        opp2.OptOutDate__c=system.today()+7;
        opp2.CloseDate=system.today();
		opp2.RenewalDate__c = System.today() + 365;
        opp2.StageName='Verbal';
        opp2.Product__c='Event';
        opp2.Contract_Implemented__c=false;
        opp2.CurrencyIsoCode='USD';
        opp2.RecordTypeId=recodrdtypeopp;
        insert opp2;
        
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccoreSurvey = new product2();
        pdhccoreSurvey.Name='accTeamMem';
        pdhccoreSurvey.Family='Survey';
        pdhccoreSurvey.IsActive=true;
        pdhccoreSurvey.ProductCode='CV-SW-EC-SUR-QSTNRLIC';
        insert pdhccoreSurvey;
        
        
        PricebookEntry hccoreSurvey = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccoreSurvey.Id,
            UnitPrice = 10000, IsActive = true);
        insert hccoreSurvey;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp2, hccoreSurvey);
        insert oli2;
        opp2.StageName='Closed Won – Do Not Send to EBS';
        update opp2;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp2.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
    }
    static testmethod void Validatecccs1()
    {      
        Id recodrdtypeacc=schema.SObjectType.account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
        Id recodrdtypeopp=schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        //Account creation
        account acc = new account();
        acc.Name='TestAccount';
        acc.RecordTypeId=recodrdtypeacc;
        acc.BillingCountry='MX';
        insert acc;
        
        
        accountTeamMember atm =testutil.createAccountTeamMember(acc.id, 'CrowdCompass PC');
        insert atm;
        
        opportunity opp2 = new opportunity();
        opp2.Name='taskAutomation';
        opp2.AccountId=acc.Id;
        opp2.OptOutDate__c=system.today()+7;
        opp2.CloseDate=system.today();
		opp2.RenewalDate__c = System.today() + 365;
        opp2.StageName='Verbal';
        opp2.Product__c='Event';
        opp2.Contract_Implemented__c=false;
        opp2.CurrencyIsoCode='USD';
        opp2.RecordTypeId=recodrdtypeopp;
        insert opp2;
        
        Id pricebookId = Test.getStandardPricebookId();
        /*cccs sku  CV-SW-EC-CC-CCMBAP501-CCMBAP501 Product*/
        product2 pdhccore = new product2();
        pdhccore.Name='accTeamMem2';
        pdhccore.Family='CrowdCompass';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-EC-CC-CCMBAP501-CCMBAP501';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp2, CrowdCompass2);
        insert oli2;
        
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp2.Id);
        opp2.StageName='Closed Won – Do Not Send to EBS';
        update opp2;
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
    }
    static testmethod void Validatecccs2()
    {      
        Id recodrdtypeacc=schema.SObjectType.account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
        Id recodrdtypeopp=schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        //Account creation
        account acc = new account();
        acc.Name='TestAccount';
        acc.RecordTypeId=recodrdtypeacc;
        acc.BillingCountry='MX';
        insert acc;
        
        
        accountTeamMember atm =testutil.createAccountTeamMember(acc.id, 'CrowdCompass PC');
        insert atm;
        
        opportunity opp2 = new opportunity();
        opp2.Name='taskAutomation';
        opp2.AccountId=acc.Id;
        opp2.OptOutDate__c=system.today()+7;
		opp2.RenewalDate__c = System.today() + 365;
        opp2.CloseDate=system.today();
        opp2.StageName='Verbal';
        opp2.Product__c='Event';
        opp2.Contract_Implemented__c=false;
        opp2.CurrencyIsoCode='USD';
        opp2.RecordTypeId=recodrdtypeopp;
        insert opp2;
        
        Id pricebookId = Test.getStandardPricebookId();
        /*cccs sku  setSku1 Product*/
        product2 pdhccore = new product2();
        pdhccore.Name='accTeamMem2';
        pdhccore.Family='CrowdCompass';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-EC-CC-CCMBAP3001-CCMBAP3001';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp2, CrowdCompass2);
        insert oli2;
        opp2.StageName='Closed Won – Do Not Send to EBS';
        update opp2;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp2.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
    }
    static testmethod void Validatecccs3()
    {      
        Id recodrdtypeacc=schema.SObjectType.account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
        Id recodrdtypeopp=schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        //Account creation
        account acc = new account();
        acc.Name='TestAccount';
        acc.RecordTypeId=recodrdtypeacc;
        acc.BillingCountry='MX';
        insert acc;
        
        
        accountTeamMember atm =testutil.createAccountTeamMember(acc.id, 'CrowdCompass PC');
        insert atm;
        
        opportunity opp2 = new opportunity();
        opp2.Name='taskAutomation';
        opp2.AccountId=acc.Id;
        opp2.OptOutDate__c=system.today()+7;
        opp2.CloseDate=system.today();
		opp2.RenewalDate__c = System.today() + 365;
        opp2.StageName='Verbal';
        opp2.Product__c='Event';
        opp2.Contract_Implemented__c=false;
        opp2.CurrencyIsoCode='USD';
        opp2.RecordTypeId=recodrdtypeopp;
        insert opp2;
        
        Id pricebookId = Test.getStandardPricebookId();
        /*cccs sku  setSku1 Product*/
        product2 pdhccore = new product2();
        pdhccore.Name='accTeamMem2';
        pdhccore.Family='Survey';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-PS-HC-OSS-OA360T1';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp2, CrowdCompass2);
        insert oli2;
        opp2.StageName='Closed Won – Do Not Send to EBS';
        update opp2;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp2.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
    }
    
    static testmethod void validateEventNegative()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        /*cccs sku  setSku1 Product*/
        product2 pdhccore = new product2();
        pdhccore.Name='negative eventSKu';
        pdhccore.Family='Event';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-PS-HC-OSS-OA360T1';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    
    static testmethod void validateHC_planner1()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        /*cccs sku  setCSNplannerProd Product*/
        product2 pdhccore = new product2();
        pdhccore.Name='negative eventSKu';
        pdhccore.Family='Event';
        pdhccore.Product_Line__c='CSN Planner';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-EC-EVT-CSNPELBND';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_planner2()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        /*cccs sku  setCSNplannerProd Product*/
        product2 pdhccore = new product2();
        pdhccore.Name='negative eventSKu';
        pdhccore.Family='Event';
        pdhccore.Product_Line__c='CSN Planner';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-EC-EVT-RFPCUSF';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_planner3()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        /*cccs sku  setCSNplannerProd Product*/
        product2 pdhccore = new product2();
        pdhccore.Name=' eventSKu';
        pdhccore.Family='Event';
        pdhccore.Product_Line__c='CSN Planner';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-EC-EVT-RFPCUSF';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_planner4()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        /*cccs sku  setCSNplannerProd Product*/
        product2 pdhccore = new product2();
        pdhccore.Name=' eventSKu';
        pdhccore.Family='Event';
        pdhccore.Product_Line__c='CSN Planner';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-EC-EVT-RFPPO';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_AM1()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        /*cccs sku  setdiamond Product*/
        product2 pdhccore = new product2();
        pdhccore.Name=' eventSKu';
        pdhccore.Family='HC Core Products - Diamonds';
        
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-AD-HC-CSN-1DIA';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_AM2BundleFamily() 
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        update opp;
        Id pricebookId = Test.getStandardPricebookId();
        /*sku  no sku Product*/
        product2 pdhccore = new product2();
        pdhccore.Name=' bundle no sku';
        pdhccore.Family='HC Core Products - Bundles & Promo Hub';
        pdhccore.Product_Line__c='bundle';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-AD-HC-CSN-1DIA';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
      static testmethod void validateHC_AM2BundleFamilySBQuote() 
    {
         Id pricebookId = Test.getStandardPricebookId();
        /*sku  no sku Product*/
        product2 pdhccore = new product2();
        pdhccore.Name=' bundle no sku';
        pdhccore.Family='Software & Integrations';
        pdhccore.Product_Line__c='Bundles';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-HC-CSN-WHTLAPRO';
        insert pdhccore;
         PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        
          SBQQ__Quote__c  SbQuote = new SBQQ__Quote__c();
        
        insert SbQuote;
        SBQQ__QuoteLine__c SBqline= new SBQQ__QuoteLine__c();
        Sbqline.SBQQ__Quote__c=sbquote.Id;
        sbqline.SBQQ__NetPrice__c =1732;
        sbqline.SBQQ__Quantity__c=1;
        sbqline.SBQQ__Product__c=pdhccore.Id;
        //sbqline.SBQQ__ProductCode__c='CV-SW-HC-CSN-WHTLAPRO';
        insert sbqline;
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        SbQuote.SBQQ__Opportunity2__c=opp.Id;
        update SbQuote;
        opp.SBQQ__PrimaryQuote__c=SbQuote.Id;
        update opp;

        
        
       
       OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
       insert oli2;
        
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_AM2SoftwareIntegrations() 
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        account acc =[select Id ,name from account where name='TestAccount1'][0];
        acc.Venue_Type__c='Above- Property Account';
        update acc;
        opp.MSA_Code__c='sdhgh';
        opp.MSA_Received_Date__c= system.today()+7;
        opp.Other_MSA_Code__c='123jksh';
        opp.StageName = 'Verbal';
        update opp;
        Id pricebookId = Test.getStandardPricebookId();
        /*softwRE integration*/
        product2 pdhccore = new product2();
        pdhccore.Name=' bundle no sku';
        pdhccore.Family='Software & Integrations';
        //pdhccore.Product_Line__c='bundle';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-PS-HC-CSN-SUPFEAADVCUSPR';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_AM3SoftwareIntegrations() 
    {  
        Id recodrdtypeopp1=schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        
        account acc =[select Id ,name from account where name='TestAccount1'][0];
        acc.Venue_Type__c='Above- Property Account';
        update acc;
        opportunity opp = new opportunity();
        opp.Name='taskAutomation';
        opp.AccountId=acc.Id;
        opp.OptOutDate__c=system.today()+7;
        opp.closeDate=system.today();
		opp.RenewalDate__c = System.today() + 365;
        opp.StageName='Verbal';
        opp.Product__c='Event';
        opp.Contract_Implemented__c=false;
        opp.CurrencyIsoCode='USD';
        opp.RecordTypeId=recodrdtypeopp1;
        opp.MSA_Code__c='sdhgh';
        opp.MSA_Received_Date__c= system.today()+7;
        opp.Other_MSA_Code__c='123jksh';
        insert opp;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        /*softwRE integration*/
        product2 pdhccore = new product2();
        pdhccore.Name=' bundle no sku';
        pdhccore.Family='Analytics & RFP Performance';
        //pdhccore.Product_Line__c='bundle';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-HC-CSN-RFPRDDCON';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
        update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_supplier1()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        account acc =[select Id ,name from account where name='TestAccount1'][0];
        acc.Billingcountry='IN';
        update acc;
        product2 pdhccore = new product2();
        pdhccore.Name=' bundle no sku';
        pdhccore.Family='HC Core Products - Diamonds';
        pdhccore.Product_Line__c='bundle';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-AD-HC-CSN-1DIA';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
      static testmethod void validateHC_suppliernewFordiamond()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        account acc =[select Id ,name from account where name='TestAccount1'][0];
        acc.Billingcountry='IN';
        update acc;
        product2 pdhccore = new product2();
        pdhccore.Name=' bundle no sku';
        pdhccore.Family='HC Core Products - Diamonds';
        pdhccore.Product_Line__c='bundle';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-AD-HC-CSN-3DIA';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_supplier2()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name=' chain filter';
        pdhccore.Family='HC Core Products - Others';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-HC-CSN-CSNCHNFIL';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    
    static testmethod void validateHC_supplier3()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name=' google display ad';
        pdhccore.Family='HC Core Products - Others';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-AD-HC-CSN-GGLDISADS';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_supplier4()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name=' business Intelligence';
        pdhccore.Family='HC Core Products - Others';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-HC-CSN-RFPRCS';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
        static testmethod void validateHC_supplier4HCCoreNew()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name=' business Intelligence';
        pdhccore.Family='HC Core Products - Others';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-AD-HC-EMI-ELMPRMKTPRDGM';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_supplier5()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name=' video marketing';
        pdhccore.Family='HC Core Products - Others';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-AD-HC-CSN-VIDRET30';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_supplier5Sku30()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name=' video marketing';
        pdhccore.Family='HC Core Products - Others';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-AD-HC-CSN-VIDMAR';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
        static testmethod void validateHC_supplierSku31()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name=' video marketing';
        pdhccore.Family='HC Core Products - Others';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-HC-CSN-RFPRCS';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_supplierSku33()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name=' video marketing';
        pdhccore.Family='HC Core Products - Others';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-AD-HC-CSN-GGLDISADS';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_supplier6()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name=' Social wall';
        pdhccore.Family='Software & Integrations';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-HC-CSN-SW';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
        static testmethod void validateHC_supplier6SKU32()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name=' Social wall';
        pdhccore.Family='Software & Integrations';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-HC-CSN-CSNCHNFIL';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
     static testmethod void validateHC_supplier6SKU32Onsite()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name=' Social wall';
        pdhccore.Family='Onsite Solutions';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-EC-SUR-QSTNRLIC';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_supplier7()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name='Escalation/Routing Rules';
        pdhccore.Family='Software & Integrations';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-HC-CSN-SUPFEAESCREP';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_supplier8()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name='Enterprise Button';
        pdhccore.Family='Software & Integrations';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-HC-CSN-WHLABENT2';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_supplier9()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name='Cross Accountvisibility';
        pdhccore.Family='Software & Integrations';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-HC-CSN-SUPFEACRACV';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_supplier10()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name='CSN Professional License (Feature Bundle)';
        pdhccore.Family='Software & Integrations';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-HC-CSN-SPFEPRPKG';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_supplier11()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name='custom Proposal basic';
        pdhccore.Family='Software & Integrations';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-PS-HC-CSN-SUPFEABCUSPR';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_supplier12()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name='PRO Button';
        pdhccore.Family='Software & Integrations';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-HC-CSN-WHTLAPRO';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
      static testmethod void validateHC_supplier12part1()
    {
        opportunity opp = [select Id,name from opportunity where name='SBQuoteopp'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name='PRO Button';
        pdhccore.Family='Software & Integrations';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-HC-CSN-WHTLAPRO';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_supplier13()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name='promo hub';
        pdhccore.Family='HC Core Products - Bundles & Promo Hub';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-AD-HC-CSN-PRMHBSIL';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_supplier14()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name='promo hub';
        pdhccore.Family='HC Core Products - Bundles & Promo Hub';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-AD-HC-CSN-PRMHBGLD';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_supplier15()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name='promo hub';
        pdhccore.Family='HC Core Products - Suggested, Diamond Plus, Comp Market';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-AD-HC-CSN-CMARAD';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_supplier16()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name='promo hub diamond market';
        pdhccore.Family='HC Core Products - Suggested, Diamond Plus, Comp Market';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-AD-HC-CSN-DIAPLS';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_supplier17()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name='renewal EMI';
        pdhccore.Family='HC Core Products - Others';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-AD-HC-EMI-ELMENCMKTPGM';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateHC_supplier18()
    {
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        Id pricebookId = Test.getStandardPricebookId();
        product2 pdhccore = new product2();
        pdhccore.Name='CSN Professional License (Feature Bundle)';
        pdhccore.Family='Software & Integrations';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-HC-CSN-SPFEENPKG';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Won – Do Not Send to EBS';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        system.debug('linits SOQL'+Limits.getQueries());
        
    }
    
    static testmethod void validateEventforRenewalHCAMSKU12()
    {
        
        //user u =[select Id, name,Username from user where Username='deploymentuser@cvent.com'][0];
        
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        //opp.StageName='Closed Lost';
        //update opp;
        Id pricebookId = Test.getStandardPricebookId();
        /*cccs sku  setSku1 Product*/
        product2 pdhccore = new product2();
        pdhccore.Name='negative eventSKu';
        pdhccore.Family='Event';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-HC-SAI-SUPFERFPUSN2D';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
       opp.StageName = 'Closed Lost';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
     static testmethod void validateEventforRenewalHCAMSKU13()
    {
        
        //user u =[select Id, name,Username from user where Username='deploymentuser@cvent.com'][0];
        
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        //opp.StageName='Closed Lost';
        //update opp;
        Id pricebookId = Test.getStandardPricebookId();
        /*cccs sku  setSku1 Product*/
        product2 pdhccore = new product2();
        pdhccore.Name='negative eventSKu';
        pdhccore.Family='Event';
        pdhccore.isActive=True;
        pdhccore.ProductCode='CV-SW-HC-CSN-WHTLAPRO';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
        opp.StageName = 'Closed Lost';
        update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
    static testmethod void validateEventforRenewalHCAMSKUbundle()
    {
        
        //user u =[select Id, name,Username from user where Username='deploymentuser@cvent.com'][0];
        
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        //opp.StageName='Verbal';
        //update opp;
        Id pricebookId = Test.getStandardPricebookId();
        /*cccs sku  setSku1 Product*/
        product2 pdhccore = new product2();
        pdhccore.Name='Blog - Center Stag';
        pdhccore.Family='HC Core Products - Bundles & Promo Hub';
        pdhccore.isActive=True;
        pdhccore.Product_Line__c='Bundles';
        pdhccore.ProductCode='CV-AD-HC-CSN-BLCEST';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
       opp.StageName = 'Closed Won';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
     static testmethod void validateEventforRenewalHCAMSKUSKU16A()
    {
        
        //user u =[select Id, name,Username from user where Username='deploymentuser@cvent.com'][0];
        
        opportunity opp = [select Id,name from opportunity where name='taskAutomation1'][0];
        //opp.StageName='Verbal';
        //update opp;
        Id pricebookId = Test.getStandardPricebookId();
        /*cccs sku  setSku1 Product*/
        product2 pdhccore = new product2();
        pdhccore.Name='Blog - Center Stag';
        pdhccore.Family='HC Core Products - Suggested, Diamond Plus, Comp Market';
        pdhccore.isActive=True;
        pdhccore.Product_Line__c='Bundles';
        pdhccore.ProductCode='CV-AD-HC-CSN-BOONDT';
        insert pdhccore;
        
        
        PricebookEntry CrowdCompass2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pdhccore.Id,
            UnitPrice = 10000, IsActive = true);
        insert CrowdCompass2;
        OpportunityLineItem oli2 = testutil.createOpportunityLineItems(opp, CrowdCompass2);
        insert oli2;
       opp.StageName = 'Closed Won';
		update opp;
        test.startTest();
        set<id> opid = new set<Id>();
        opid.add(opp.Id);
        
        TaskAutomation.taskAutoCreation(opid);
        test.stopTest();
        
    }
}