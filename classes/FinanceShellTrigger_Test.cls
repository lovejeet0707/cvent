@isTest
private class FinanceShellTrigger_Test {
    
    Public Static List<String> calculatedFieldNames = new List<String>();
    Public Static List<String> preCalculationFieldNames = new List<String>();
    
    Public FinanceShellTrigger_Test(){
        calculatedFieldNames = new List<String>{
            'SBQQ__OriginalPrice__c',
                'SBQQ__ListPrice__c',
                'SBQQ__RegularPrice__c',
                'SBQQ__CustomerPrice__c',
                'SBQQ__PartnerPrice__c',
                'SBQQ__NetPrice__c',
                'Rack_Rate__c',
                'SBQQ__ProrateMultiplier__c'
                };
                    preCalculationFieldNames = new List<String>{
                        'SBQQ__Quantity__c',
                            'SBQQ__Discount__c',
                            'Custom_Discount__c',
                            'SBQQ__DistributorDiscount__c',
                            'SBQQ__PartnerDiscount__c',
                            'SBQQ__AdditionalDiscountAmount__c',
                            'Discount_Type__c',
                            'SBQQ__StartDate__c',
                            'SBQQ__EndDate__c'
                            };
                                }
    
    @testSetup static void setupRecords() {
        Currency_Conversion_Table__c newCCT = new Currency_Conversion_Table__c();
        newCCT.Currency_Conversion_Rate__c = 1.400000;
        newCCT.CurrencyIsoCode = 'USD';
        insert newCCT;
        
        //Create New Account
        Account objAccount = CventMYDDataFactory.createAccounts(1);
        insert objAccount;
        
        //Create New Contact
        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
        insert objContact;
        
        //Create New Opportunity
        Opportunity objOpport = CventMYDDataFactory.createOpportunities_Stage(1,objAccount.Id,objContact.Id);
        objOpport.ContractReceived__c = System.today();
        insert objOpport;
        
        //adding Oppsplits
        //add another user
        //inserting User
        List<User> userList = new List<User>();
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest1@testorg.com');
        userList.add(u1);
        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest2@testorg.com');
        userList.add(u2);
        insert userList;
        
        List<OpportunitySplit> opportunitySplitList = new List<OpportunitySplit>();
        OpportunitySplit objOppSplit1 = new OpportunitySplit();
        objOppSplit1.OpportunityId = objOpport.Id;
        objOppSplit1.SplitPercentage = 20;
        objOppSplit1.SplitOwnerId = u1.Id;
        objOppSplit1.Lanyon_Migrated_ID__c = 'a123';
        opportunitySplitList.add(objOppSplit1);
        OpportunitySplit objOppSplit2 = new OpportunitySplit();
        objOppSplit2.OpportunityId = objOpport.Id;
        objOppSplit2.SplitPercentage = 20;
        objOppSplit2.SplitOwnerId = u2.Id;
        objOppSplit2.Lanyon_Migrated_ID__c = 'b123';
        opportunitySplitList.add(objOppSplit2);
        insert opportunitySplitList;
        
        List<Product2> lstProducts = CventMYDDataFactory.createProducts(2);
        insert lstProducts; 
        
        List<PricebookEntry> lstPBE = CventMYDDataFactory.createPriceBookEntry(lstProducts);
        insert lstPBE;
        
        SBQQ__ProductOption__c objProductOption = new SBQQ__ProductOption__c();
        objProductOption =  CventMYDDataFactory.createProductOptions(lstProducts[0].Id,lstProducts[1].Id,(1));
        insert objProductOption;
        
        SBQQ__Quote__c objQuote = CventMYDDataFactory.createQuote(objAccount.Id,objOpport.Id,true);
        objQuote.jsonString__c = JSON.serialize(getTestQuoteObject());
        insert objQuote;
        
        List<SBQQ__QuoteLineGroup__c> lstQuoteLineGroups= new List<SBQQ__QuoteLineGroup__c>();
        SBQQ__QuoteLineGroup__c qLineGroup = new SBQQ__QuoteLineGroup__c();
        qLineGroup = CventMYDDataFactory.createQuoteLineGroup(objAccount.Id, objQuote.Id, 1);
        lstQuoteLineGroups.add(qLineGroup);
        qLineGroup = new SBQQ__QuoteLineGroup__c();
        qLineGroup = CventMYDDataFactory.createQuoteLineGroup(objAccount.Id, objQuote.Id, 2);
        lstQuoteLineGroups.add(qLineGroup);
        qLineGroup = new SBQQ__QuoteLineGroup__c();
        qLineGroup = CventMYDDataFactory.createQuoteLineGroup(objAccount.Id, objQuote.Id, 3);
        lstQuoteLineGroups.add(qLineGroup);
        qLineGroup = new SBQQ__QuoteLineGroup__c();
        qLineGroup = CventMYDDataFactory.createQuoteLineGroup(objAccount.Id, objQuote.Id, 4);
        lstQuoteLineGroups.add(qLineGroup);
        qLineGroup = new SBQQ__QuoteLineGroup__c();
        qLineGroup = CventMYDDataFactory.createQuoteLineGroup(objAccount.Id, objQuote.Id, 5);
        lstQuoteLineGroups.add(qLineGroup);
        insert lstQuoteLineGroups;
    }
    
    static testMethod void test_oneOppProposalSent() {
        List<SBQQ__Quote__c> quoteList = [SELECT Id, SBQQ__Account__c, SBQQ__Opportunity2__c FROM SBQQ__Quote__c LIMIT 1];
        List<Product2> productList = [SELECT Id FROM Product2 LIMIT 1];
        List<SBQQ__QuoteLineGroup__c> quoteLineGroupList = [SELECT Id FROM SBQQ__QuoteLineGroup__c ORDER By SBQQ__Number__c ASC];
        
        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qline = new SBQQ__QuoteLine__c();
        qLine = CventMYDDataFactory.createQuoteLine(quoteList[0],productList[0].Id,500);
        qLine.SBQQ__Group__c = quoteLineGroupList[0].Id;
        lstQuoteLines.add(qLine);
        qline = new SBQQ__QuoteLine__c();
        qLine = CventMYDDataFactory.createQuoteLine(quoteList[0],productList[0].Id,500);
        qLine.SBQQ__Group__c = quoteLineGroupList[1].Id;
        lstQuoteLines.add(qLine);
        qLine = CventMYDDataFactory.createQuoteLine(quoteList[0],productList[0].Id,500);
        qLine.SBQQ__Group__c = quoteLineGroupList[2].Id;
        lstQuoteLines.add(qLine);
        qLine = CventMYDDataFactory.createQuoteLine(quoteList[0],productList[0].Id,500);
        qLine.SBQQ__Group__c = quoteLineGroupList[3].Id;
        lstQuoteLines.add(qLine);
        qLine = CventMYDDataFactory.createQuoteLine(quoteList[0],productList[0].Id,500);
        qLine.SBQQ__Group__c = quoteLineGroupList[4].Id;
        lstQuoteLines.add(qLine);
        insert lstQuoteLines;
        
        Test.startTest();
        CreateFincanceShallFromOpp batchObj = new CreateFincanceShallFromOpp(quoteList[0].SBQQ__Opportunity2__c);
        ID batchprocessid = Database.executeBatch(batchObj,1);
        Test.stopTest();
        //CreateFincanceShallFromOpp batchObj2 = new CreateFincanceShallFromOpp(objOpport.Id);
        //ID batchprocessid2 = Database.executeBatch(batchObj2,1);
    }
    
    static testMethod void test_oneOppProposalSentNonMYD() {
        List<SBQQ__Quote__c> quoteList = [SELECT Id, SBQQ__Account__c, SBQQ__Opportunity2__c FROM SBQQ__Quote__c LIMIT 1];
        List<Product2> productList = [SELECT Id FROM Product2 LIMIT 1];
        List<SBQQ__QuoteLineGroup__c> quoteLineGroupList = [SELECT Id FROM SBQQ__QuoteLineGroup__c ORDER By SBQQ__Number__c ASC];
        
        quoteList[0].Multiple_Years_Commitment__c = false;
        update quoteList;
        
        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qline = new SBQQ__QuoteLine__c();
        qLine = CventMYDDataFactory.createQuoteLine(quoteList[0],productList[0].Id,500);
        qLine.SBQQ__Group__c = quoteLineGroupList[0].Id;
        lstQuoteLines.add(qLine);
        insert lstQuoteLines;
        
        Test.startTest();
        CreateFincanceShallFromOpp batchObj = new CreateFincanceShallFromOpp(quoteList[0].SBQQ__Opportunity2__c);
        ID batchprocessid = Database.executeBatch(batchObj,1);
        Test.stopTest();
        //CreateFincanceShallFromOpp batchObj2 = new CreateFincanceShallFromOpp(objOpport.Id);
        //ID batchprocessid2 = Database.executeBatch(batchObj2,1);
    }
    
    /*static testMethod void test_oneOpp() {
        //Opportunity opp = testDate();
        
        Test.startTest();
        Currency_Conversion_Table__c newCCT = new Currency_Conversion_Table__c();
        newCCT.Currency_Conversion_Rate__c = 1.400000;
        newCCT.CurrencyIsoCode = 'USD';
        insert newCCT;
        
        Account objAccount = CventMYDDataFactory.createAccounts(1);
        insert objAccount;
        
        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
        insert objContact;
        
        Opportunity objOpport = CventMYDDataFactory.createOpportunities(1,objAccount.Id,objContact.Id);
        objOpport.ContractReceived__c = System.today();
        insert objOpport;
        
        //adding Oppsplits
        //add another user
        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest1@testorg.com');
        insert u1;
        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest2@testorg.com');
        insert u2;
        
        OpportunitySplit objOppSplit1 = new OpportunitySplit();
        objOppSplit1.OpportunityId = objOpport.Id;
        objOppSplit1.SplitPercentage = 20;
        objOppSplit1.SplitOwnerId = u1.Id;
        objOppSplit1.Lanyon_Migrated_ID__c = 'a123';
        insert objOppSplit1;
        OpportunitySplit objOppSplit2 = new OpportunitySplit();
        objOppSplit2.OpportunityId = objOpport.Id;
        objOppSplit2.SplitPercentage = 20;
        objOppSplit2.SplitOwnerId = u2.Id;
        objOppSplit2.Lanyon_Migrated_ID__c = 'b123';
        insert objOppSplit2;
        
        List<Product2> lstProducts = CventMYDDataFactory.createProducts(2);
        insert lstProducts; 
        
        List<PricebookEntry> lstPBE = CventMYDDataFactory.createPriceBookEntry(lstProducts);
        insert lstPBE;
        
        SBQQ__ProductOption__c objProductOption = new SBQQ__ProductOption__c();
        //for(Integer i = 0; i< lstProducts.size() ; i++){
        objProductOption =  CventMYDDataFactory.createProductOptions(lstProducts[0].Id,lstProducts[1].Id,(1));
        //}
        insert objProductOption; 
        
        SBQQ__Quote__c objQuote = CventMYDDataFactory.createQuote(objAccount.Id,objOpport.Id,true);
        objQuote.jsonString__c = JSON.serialize(getTestQuoteObject());
        insert objQuote;       
        
        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,500));
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,null));
        //lstQuoteLines[1].SBQQ__RequiredBy__c = lstQuoteLines[0].Id;
        insert lstQuoteLines;
        
        Test.stopTest();
        CreateFincanceShallFromOpp batchObj = new CreateFincanceShallFromOpp(objOpport.Id);
        ID batchprocessid = Database.executeBatch(batchObj,1);
        
        CreateFincanceShallFromOpp batchObj2 = new CreateFincanceShallFromOpp(objOpport.Id);
        ID batchprocessid2 = Database.executeBatch(batchObj2,1);
    }
    
    static testMethod void test_oneOppDate() {
        //Opportunity opp = testDate();
        Test.startTest();
        Currency_Conversion_Table__c newCCT = new Currency_Conversion_Table__c();
        newCCT.Currency_Conversion_Rate__c = 1.400000;
        newCCT.CurrencyIsoCode = 'USD';
        insert newCCT;
        
        Account objAccount = CventMYDDataFactory.createAccounts(1);
        insert objAccount;
        
        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
        insert objContact;
        
        Opportunity objOpport = CventMYDDataFactory.createOpportunities(1,objAccount.Id,objContact.Id);
        insert objOpport;
        System.debug('objOpport-->' + objOpport);
        
        //adding Oppsplits
        //add another user
        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest1@testorg.com');
        insert u1;
        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest2@testorg.com');
        insert u2;
        
        OpportunitySplit objOppSplit1 = new OpportunitySplit();
        objOppSplit1.OpportunityId = objOpport.Id;
        objOppSplit1.SplitPercentage = 20;
        objOppSplit1.SplitOwnerId = u1.Id;
        objOppSplit1.Lanyon_Migrated_ID__c = 'a123';
        insert objOppSplit1;
        OpportunitySplit objOppSplit2 = new OpportunitySplit();
        objOppSplit2.OpportunityId = objOpport.Id;
        objOppSplit2.SplitPercentage = 20;
        objOppSplit2.SplitOwnerId = u2.Id;
        objOppSplit2.Lanyon_Migrated_ID__c = 'b123';
        insert objOppSplit2;
        
        List<Product2> lstProducts = CventMYDDataFactory.createProducts(2);
        insert lstProducts; 
        
        List<PricebookEntry> lstPBE = CventMYDDataFactory.createPriceBookEntry(lstProducts);
        insert lstPBE;
        
        SBQQ__ProductOption__c objProductOption = new SBQQ__ProductOption__c();
        //for(Integer i = 0; i< lstProducts.size() ; i++){
        objProductOption =  CventMYDDataFactory.createProductOptions(lstProducts[0].Id,lstProducts[1].Id,(1));
        //}
        insert objProductOption; 
        
        SBQQ__Quote__c objQuote = CventMYDDataFactory.createQuote(objAccount.Id,objOpport.Id,true);
        objQuote.jsonString__c = JSON.serialize(getTestQuoteObject());
        insert objQuote;       
        
        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,500));
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,null));
        
        insert lstQuoteLines;
        
        Test.stopTest();
        Date startDate = System.today();
        Date endDate = System.today() + 365;
        CreateFincanceShallFromOpp batchObj = new CreateFincanceShallFromOpp(String.valueOf(startDate),String.valueOf(endDate));
        ID batchprocessid = Database.executeBatch(batchObj,1);
        
        //Date startDate = System.today();
        //Date endDate = System.today() + 365;
        //CreateFincanceShallFromOpp classCall = new CreateFincanceShallFromOpp(String.valueOf(startDate),String.valueOf(endDate));
    }
    
    static testMethod void test_oneOppList() {
        //Opportunity opp = testDate();
        Test.startTest();
        Currency_Conversion_Table__c newCCT = new Currency_Conversion_Table__c();
        newCCT.Currency_Conversion_Rate__c = 1.400000;
        newCCT.CurrencyIsoCode = 'USD';
        insert newCCT;
        
        Account objAccount = CventMYDDataFactory.createAccounts(1);
        insert objAccount;
        System.debug('objAccount-->' + objAccount);
        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
        insert objContact;
        System.debug('objContact-->' + objContact);
        Opportunity objOpport = CventMYDDataFactory.createOpportunities(1,objAccount.Id,objContact.Id);
        insert objOpport;
        System.debug('objOpport-->' + objOpport);
        Contract objContract = new Contract();
        objContract.AccountId= objAccount.Id; 
        objContract.SBQQ__Opportunity__c=objOpport.Id;
        insert objContract;
        Set<Id> expireContractID= new Set<Id>();
        expireContractID.add(objContract.Id);
        Map<Id,String> renewalStage = new Map<Id,String>();
        renewalStage.put(objContract.Id,'Test');
        
        
        CreateFincanceShallHandler.expireParentContracts(expireContractID,renewalStage);
        //adding Oppsplits
        //add another user
        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest1@testorg.com');
        insert u1;
        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest2@testorg.com');
        insert u2;
        
        OpportunitySplit objOppSplit1 = new OpportunitySplit();
        objOppSplit1.OpportunityId = objOpport.Id;
        objOppSplit1.SplitPercentage = 20;
        objOppSplit1.SplitOwnerId = u1.Id;
        objOppSplit1.Lanyon_Migrated_ID__c = 'a123';
        insert objOppSplit1;
        OpportunitySplit objOppSplit2 = new OpportunitySplit();
        objOppSplit2.OpportunityId = objOpport.Id;
        objOppSplit2.SplitPercentage = 20;
        objOppSplit2.SplitOwnerId = u2.Id;
        objOppSplit2.Lanyon_Migrated_ID__c = 'b123';
        insert objOppSplit2;
        
        List<Product2> lstProducts = CventMYDDataFactory.createProducts(2);
        insert lstProducts; 
        System.debug('lstProducts-->' + lstProducts);
        
        List<PricebookEntry> lstPBE = CventMYDDataFactory.createPriceBookEntry(lstProducts);
        insert lstPBE;
        System.debug('lstPBE-->' + lstProducts);
        
        SBQQ__ProductOption__c objProductOption = new SBQQ__ProductOption__c();
        //for(Integer i = 0; i< lstProducts.size() ; i++){
        objProductOption =  CventMYDDataFactory.createProductOptions(lstProducts[0].Id,lstProducts[1].Id,(1));
        //}
        insert objProductOption; 
        System.debug('objProductOption-->' + objProductOption);
        
        SBQQ__Quote__c objQuote = CventMYDDataFactory.createQuote(objAccount.Id,objOpport.Id,true);
        objQuote.jsonString__c = JSON.serialize(getTestQuoteObject());
        
        insert objQuote;       
        System.debug('objQuote-->' + objQuote);
        
        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,500));
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,null));
        
        insert lstQuoteLines;
        System.debug('lstQuoteLines-->' + lstQuoteLines);
        
        Test.stopTest();
        Set<ID> lst_Opp = new Set<ID>();
        lst_Opp.clear();
        lst_Opp.add(objOpport.Id);
        System.debug(lst_Opp);
        CreateFincanceShallFromOpp batchObj = new CreateFincanceShallFromOpp(objOpport.Id);
        ID batchprocessid = Database.executeBatch(batchObj,1);
        System.debug('batchprocessid-->' + batchprocessid);
        
    }
    
    static testMethod void test_oneOppListMYD() {
        System.debug('test_oneOppListNONMYD');
        //Opportunity opp = testDate();
        Test.startTest();
        Currency_Conversion_Table__c newCCT = new Currency_Conversion_Table__c();
        newCCT.Currency_Conversion_Rate__c = 1.400000;
        newCCT.CurrencyIsoCode = 'USD';
        insert newCCT;
        
        Account objAccount = CventMYDDataFactory.createAccounts(1);
        insert objAccount;
        System.debug('objAccount-->' + objAccount);
        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
        insert objContact;
        System.debug('objContact-->' + objContact);
        Opportunity objOpport = CventMYDDataFactory.createOpportunities(1,objAccount.Id,objContact.Id);
        insert objOpport;
        System.debug('objOpport-->' + objOpport);
        
        //adding Oppsplits
        //add another user
        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest1@testorg.com');
        insert u1;
        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest2@testorg.com');
        insert u2;
        
        OpportunitySplit objOppSplit1 = new OpportunitySplit();
        objOppSplit1.OpportunityId = objOpport.Id;
        objOppSplit1.SplitPercentage = 20;
        objOppSplit1.SplitOwnerId = u1.Id;
        objOppSplit1.Lanyon_Migrated_ID__c = 'a123';
        insert objOppSplit1;
        OpportunitySplit objOppSplit2 = new OpportunitySplit();
        objOppSplit2.OpportunityId = objOpport.Id;
        objOppSplit2.SplitPercentage = 20;
        objOppSplit2.SplitOwnerId = u2.Id;
        objOppSplit2.Lanyon_Migrated_ID__c = 'b123';
        insert objOppSplit2;
        
        
        List<Product2> lstProducts = CventMYDDataFactory.createProducts(2);
        insert lstProducts; 
        System.debug('lstProducts-->' + lstProducts);
        
        List<PricebookEntry> lstPBE = CventMYDDataFactory.createPriceBookEntry(lstProducts);
        insert lstPBE;
        System.debug('lstPBE-->' + lstProducts);
        
        SBQQ__ProductOption__c objProductOption = new SBQQ__ProductOption__c();
        //for(Integer i = 0; i< lstProducts.size() ; i++){
        objProductOption =  CventMYDDataFactory.createProductOptions(lstProducts[0].Id,lstProducts[1].Id,(1));
        //}
        insert objProductOption; 
        System.debug('objProductOption-->' + objProductOption);
        
        SBQQ__Quote__c objQuote = CventMYDDataFactory.createQuote(objAccount.Id,objOpport.Id,false);
        objQuote.jsonString__c = JSON.serialize(getTestQuoteObject());
        objQuote.Multiple_Years_Commitment__c = true;
        insert objQuote;       
        System.debug('objQuote-->' + objQuote);
        
        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,500));
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,null));
        
        insert lstQuoteLines;
        System.debug('lstQuoteLines-->' + lstQuoteLines);
        
        Test.stopTest();
        Set<ID> lst_Opp = new Set<ID>();
        lst_Opp.add(objOpport.Id);
        //CreateFincanceShallFromOpp batchObj = new CreateFincanceShallFromOpp(objOpport.Id);
        CreateFincanceShallFromOpp batchObj = new CreateFincanceShallFromOpp(lst_Opp);
        ID batchprocessid = Database.executeBatch(batchObj,1);
        System.debug('batchprocessid-->' + batchprocessid);
        
        //CreateFincanceShallFromOpp classCall = new CreateFincanceShallFromOpp(lst_Opp);
        
        
    }
    
    static testMethod void test_oneOppListNONMYD() {
        System.debug('test_oneOppListNONMYD');
        //Opportunity opp = testDate();
        Test.startTest();
        Currency_Conversion_Table__c newCCT = new Currency_Conversion_Table__c();
        newCCT.Currency_Conversion_Rate__c = 1.400000;
        newCCT.CurrencyIsoCode = 'USD';
        insert newCCT;
        
        Account objAccount = CventMYDDataFactory.createAccounts(1);
        insert objAccount;
        System.debug('objAccount-->' + objAccount);
        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
        insert objContact;
        System.debug('objContact-->' + objContact);
        Opportunity objOpport = CventMYDDataFactory.createOpportunities(1,objAccount.Id,objContact.Id);
        insert objOpport;
        System.debug('objOpport-->' + objOpport);
        
        //adding Oppsplits
        //add another user
        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest1@testorg.com');
        insert u1;
        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest2@testorg.com');
        insert u2;
        
        OpportunitySplit objOppSplit1 = new OpportunitySplit();
        objOppSplit1.OpportunityId = objOpport.Id;
        objOppSplit1.SplitPercentage = 20;
        objOppSplit1.SplitOwnerId = u1.Id;
        objOppSplit1.Lanyon_Migrated_ID__c = 'a123';
        insert objOppSplit1;
        OpportunitySplit objOppSplit2 = new OpportunitySplit();
        objOppSplit2.OpportunityId = objOpport.Id;
        objOppSplit2.SplitPercentage = 20;
        objOppSplit2.SplitOwnerId = u2.Id;
        objOppSplit2.Lanyon_Migrated_ID__c = 'b123';
        insert objOppSplit2;
        
        
        List<Product2> lstProducts = CventMYDDataFactory.createProducts(2);
        insert lstProducts; 
        System.debug('lstProducts-->' + lstProducts);
        
        List<PricebookEntry> lstPBE = CventMYDDataFactory.createPriceBookEntry(lstProducts);
        insert lstPBE;
        System.debug('lstPBE-->' + lstProducts);
        
        SBQQ__ProductOption__c objProductOption = new SBQQ__ProductOption__c();
        //for(Integer i = 0; i< lstProducts.size() ; i++){
        objProductOption =  CventMYDDataFactory.createProductOptions(lstProducts[0].Id,lstProducts[1].Id,(1));
        //}
        insert objProductOption; 
        System.debug('objProductOption-->' + objProductOption);
        
        SBQQ__Quote__c objQuote = CventMYDDataFactory.createQuote(objAccount.Id,objOpport.Id,false);
        objQuote.jsonString__c = JSON.serialize(getTestQuoteObject());
        insert objQuote;       
        System.debug('objQuote-->' + objQuote);
        
        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,500));
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,null));
        
        insert lstQuoteLines;
        System.debug('lstQuoteLines-->' + lstQuoteLines);
        
        Test.stopTest();
        Set<ID> lst_Opp = new Set<ID>();
        lst_Opp.add(objOpport.Id);
        //CreateFincanceShallFromOpp batchObj = new CreateFincanceShallFromOpp(objOpport.Id);
        CreateFincanceShallFromOpp batchObj = new CreateFincanceShallFromOpp(lst_Opp);
        ID batchprocessid = Database.executeBatch(batchObj,1);
        System.debug('batchprocessid-->' + batchprocessid);
        
        //CreateFincanceShallFromOpp classCall = new CreateFincanceShallFromOpp(lst_Opp);
        
        
    }
    */
    static testMethod void test_method_NonBatch() {
        //Commented Out for the meantime
        //Opportunity opp = testDate();
        /*Test.startTest();
        Currency_Conversion_Table__c newCCT = new Currency_Conversion_Table__c();
        newCCT.Currency_Conversion_Rate__c = 1.400000;
        newCCT.CurrencyIsoCode = 'USD';
        insert newCCT;
        
        Account objAccount = CventMYDDataFactory.createAccounts(1);
        insert objAccount;
        
        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
        insert objContact;
        
        Opportunity objOpport = CventMYDDataFactory.createOpportunities(1,objAccount.Id,objContact.Id);
        insert objOpport;
        System.debug('objOpport-->' + objOpport);
        
        //adding Oppsplits
        //add another user
        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest1@testorg.com');
        insert u1;
        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest2@testorg.com');
        insert u2;
        //User u3 = new User(Alias = 'standt3', Email='standarduser3@testorg.com', 
        //EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
        //LocaleSidKey='en_US', ProfileId = p.Id, 
        //TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest3@testorg.com');
        //insert u3;
        //User u4 = new User(Alias = 'standt4', Email='standarduser4@testorg.com', 
        //EmailEncodingKey='UTF-8', LastName='Testing4', LanguageLocaleKey='en_US', 
        //LocaleSidKey='en_US', ProfileId = p.Id, 
        //TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest4@testorg.com');
        //insert u4;
        //User u5 = new User(Alias = 'standt5', Email='standarduser5@testorg.com', 
        //EmailEncodingKey='UTF-8', LastName='Testing5', LanguageLocaleKey='en_US', 
        //LocaleSidKey='en_US', ProfileId = p.Id, 
        //TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest5@testorg.com');
        //insert u5;
        
        OpportunitySplit objOppSplit1 = new OpportunitySplit();
        objOppSplit1.OpportunityId = objOpport.Id;
        objOppSplit1.SplitPercentage = 20;
        objOppSplit1.SplitOwnerId = u1.Id;
        objOppSplit1.Lanyon_Migrated_ID__c = 'a123';
        insert objOppSplit1;
        OpportunitySplit objOppSplit2 = new OpportunitySplit();
        objOppSplit2.OpportunityId = objOpport.Id;
        objOppSplit2.SplitPercentage = 20;
        objOppSplit2.SplitOwnerId = u2.Id;
        objOppSplit2.Lanyon_Migrated_ID__c = 'b123';
        insert objOppSplit2;
        //OpportunitySplit objOppSplit3 = new OpportunitySplit();
        //objOppSplit3.OpportunityId = objOpport.Id;
        //objOppSplit3.SplitPercentage = 20;
        //objOppSplit3.SplitOwnerId = u3.Id;
        //objOppSplit3.Lanyon_Migrated_ID__c = 'c123';
        //insert objOppSplit3;
        //OpportunitySplit objOppSplit4 = new OpportunitySplit();
        //objOppSplit4.OpportunityId = objOpport.Id;
        //objOppSplit4.SplitPercentage = 20;
        //objOppSplit4.SplitOwnerId = u4.Id;
        //objOppSplit4.Lanyon_Migrated_ID__c = 'd123';
        //insert objOppSplit4;
        //OpportunitySplit objOppSplit5 = new OpportunitySplit();
        //objOppSplit5.OpportunityId = objOpport.Id;
        //objOppSplit5.SplitPercentage = 20;
        //objOppSplit5.SplitOwnerId = u5.Id;
        //objOppSplit5.Lanyon_Migrated_ID__c = 'e123';
        //insert objOppSplit5;
        
        List<Product2> lstProducts = CventMYDDataFactory.createProducts(2);
        insert lstProducts; 
        
        List<PricebookEntry> lstPBE = CventMYDDataFactory.createPriceBookEntry(lstProducts);
        insert lstPBE;
        
        SBQQ__ProductOption__c objProductOption = new SBQQ__ProductOption__c();
        //for(Integer i = 0; i< lstProducts.size() ; i++){
        objProductOption =  CventMYDDataFactory.createProductOptions(lstProducts[0].Id,lstProducts[1].Id,(1));
        //}
        insert objProductOption; 
        
        SBQQ__Quote__c objQuote = CventMYDDataFactory.createQuote(objAccount.Id,objOpport.Id,false);
        objQuote.jsonString__c = JSON.serialize(getTestQuoteObject());
        insert objQuote;       
        
        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,500));
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,null));
        
        insert lstQuoteLines;
        
        Test.stopTest();
        List<Opportunity> lst_Opp =[
            SELECT Id 
            , AccountId 
            , SBQQ__PrimaryQuote__c 
            , Master_Agreement__c 
            , ContractId 
            , Amount 
            , SBQQ__AmendedContract__c 
            , SBQQ__RenewedContract__c 
            , Contract_Implemented_Date__c  
            , ContractReceived__c 
            , CloseDate 
            , SBQQ__PrimaryQuote__r.Multiple_Years_Commitment__c
            , Type 
            , ( Select Id  
               ,  StartDate  
               ,  EndDate from SBQQ__Contracts__r)  
            , SBQQ__AmendedContract__r.SBQQ__Opportunity__c 
            , SBQQ__RenewedContract__r.SBQQ__Opportunity__c 
            , Master_Agreement__r.StartDate
            , Master_Agreement__r.EndDate 
            , SBQQ__PrimaryQuote__r.Contract_Term_Years__c 
            , SBQQ__PrimaryQuote__r.Current_Year__c 
            , SBQQ__PrimaryQuote__r.SBQQ__Type__c 
            , SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c 
            , SBQQ__PrimaryQuote__r.jsonString__c 
            , SBQQ__PrimaryQuote__r.SBQQ__StartDate__c 
            , SBQQ__PrimaryQuote__r.SBQQ__EndDate__c 
            , SBQQ__PrimaryQuote__r.Contract_Executed_Date__c 
            , ( SELECT Id  
               , OpportunityId 
               , SplitOwnerId 
               , SplitPercentage 
               ,   SplitType.MasterLabel  
               FROM OpportunitySplits  
              ) 
            FROM Opportunity WHERE Id = :objOpport.Id];
        Finance_Shell__c newFS = getFinanceShellInstance(lst_Opp[0]);
        try{
            insert newFS;
            update newFS;
        }
        catch(Exception e) {
            System.debug('Error Line Occurred-->'+e.getLineNumber());
            System.debug('Message Occurred-->'+e.getMessage());
            System.debug('Cause' + e.getCause());
        }
        */
        //CreateFincanceShallHandler.deleteRelatedFinancialRecords(lst_Opp);
        // Implement test code
        
        ///////////////////////////
        
        
        /*   objQuote = new SBQQ__Quote__c();
objQuote = CventMYDDataFactory.createQuote(objAccount.Id,objOpport.Id,true);
insert objQuote; 

objQuote = new SBQQ__Quote__c();
objQuote = CventMYDDataFactory.createQuote(objAccount.Id,objOpport.Id,true);
insert objQuote;*/
        
        //Commented Out for the meantime
        //CreateFincanceShallHandler.getFinanceShellInstance(objOpport,newFS.Id);
    } 
    
    public static Finance_Shell__c getFinanceShellInstance(Opportunity opportunity) {
        if( null == opportunity ) {
            return new Finance_Shell__c();
        }
        String jsonString = '';
        Finance_Shell__c financeShell = new Finance_Shell__c();
        financeShell.Account_ID__c = opportunity.AccountId;
        financeShell.Opportunity_ID__c = opportunity.Id;
        if(opportunity.SBQQ__PrimaryQuote__r.jsonString__c == null && opportunity.SBQQ__Quotes2__r.size() > 0){
            financeShell.Quote_ID__c = opportunity.SBQQ__Quotes2__r[0].Id;
            //financeShell.Quote_ID__c = opportunity.SBQQ__PrimaryQuote__c;
            financeShell.Opportunity_type__c = opportunity.SBQQ__Quotes2__r[0].SBQQ__Type__c;
            financeShell.Primary_Contact__c = opportunity.SBQQ__Quotes2__r[0].SBQQ__PrimaryContact__c;
            financeShell.Contract_Year_1_start_date__c = opportunity.SBQQ__Quotes2__r[0].SBQQ__StartDate__c;
            financeShell.Contract_Year_1_end_date__c = opportunity.SBQQ__Quotes2__r[0].SBQQ__EndDate__c;
            financeShell.Total_Duration__c = opportunity.SBQQ__Quotes2__r[0].Contract_Term_Years__c != null ? Decimal.valueOf(opportunity.SBQQ__Quotes2__r[0].Contract_Term_Years__c) : null;
            financeShell.Current_term__c = opportunity.SBQQ__Quotes2__r[0].Current_Year__c;
            financeShell.Year_Signed__c = opportunity.SBQQ__Quotes2__r[0].Contract_Executed_Date__c;
            financeShell.Variable_Options__c = opportunity.SBQQ__Quotes2__r[0].Multiple_Years_Commitment__c;
            jsonString = opportunity.SBQQ__Quotes2__r[0].jsonString__c; 
        }
        else {
            if( opportunity.SBQQ__PrimaryQuote__r.jsonString__c != null){
                financeShell.Quote_ID__c = opportunity.SBQQ__PrimaryQuote__c;
                financeShell.Opportunity_type__c = opportunity.SBQQ__PrimaryQuote__r.SBQQ__Type__c;
                financeShell.Primary_Contact__c = opportunity.SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c;
                financeShell.Contract_Year_1_start_date__c = opportunity.SBQQ__PrimaryQuote__r.SBQQ__StartDate__c;
                financeShell.Contract_Year_1_end_date__c = opportunity.SBQQ__PrimaryQuote__r.SBQQ__EndDate__c;
                financeShell.Total_Duration__c = opportunity.SBQQ__PrimaryQuote__r.Contract_Term_Years__c != null ? Decimal.valueOf(opportunity.SBQQ__PrimaryQuote__r.Contract_Term_Years__c) : null;
                financeShell.Current_term__c = opportunity.SBQQ__PrimaryQuote__r.Current_Year__c;
                jsonString = opportunity.SBQQ__PrimaryQuote__r.jsonString__c;
                financeShell.Year_Signed__c = opportunity.SBQQ__PrimaryQuote__r.Contract_Executed_Date__c;
                financeShell.Variable_Options__c = opportunity.SBQQ__PrimaryQuote__r.Multiple_Years_Commitment__c;
            }
        }
        
        financeShell.Parent_Contract__c = opportunity.Master_Agreement__c;
        if(opportunity.SBQQ__AmendedContract__c != null) {
            financeShell.Child_Contract__c  = opportunity.SBQQ__AmendedContract__c;
            financeShell.Child_Contract_Start_Date__c = opportunity.SBQQ__AmendedContract__r.StartDate;
            financeShell.Child_Contract_End_Date__c = opportunity.SBQQ__AmendedContract__r.EndDate;
            
        }
        else if(opportunity.SBQQ__Contracts__r.size()>0){
            
            financeShell.Child_Contract__c = opportunity.SBQQ__Contracts__r[0].Id;
            financeShell.Child_Contract_Start_Date__c = opportunity.SBQQ__Contracts__r[0].StartDate;
            financeShell.Child_Contract_End_Date__c = opportunity.SBQQ__Contracts__r[0].EndDate;
        }
        
        financeShell.Parent_Contract_Start_Date__c = opportunity.Master_Agreement__r.StartDate;
        financeShell.Parent_Contract_End_Date__c = opportunity.Master_Agreement__r.EndDate;
        financeShell.Opportunity_Amount__c = opportunity.Amount;
        financeShell.Primary_Contact__c = opportunity.SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c;
        financeShell.Year_Signed__c = opportunity.ContractReceived__c; // .year()
        financeShell.Contract_implemented_Date__c = opportunity.Contract_Implemented_Date__c;
        financeShell.Contract_Received_Date__c = opportunity.ContractReceived__c;
        
        financeShell.Accountable_Quarter__c = CreateFincanceShallHandler.populateQuarter(opportunity.ContractReceived__c);
        //CJ-- add fields
        financeShell.Closed_Date__c = opportunity.CloseDate;
        String str_Type = opportunity.Type;
        //financeShell.Contract_Expired__c = str_Type.contains('Renewal') ? :
        if(!String.isEmpty(jsonString) && jsonString != null)  {
            Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = CreateFincanceShallHandler.MapreturnDates(jsonString);
            if(map_quoteLineGroups.containsKey(2))
            {
                financeShell.Contract_Year_2_start_date__c = map_quoteLineGroups.get(2).SBQQ__StartDate__c;
                financeShell.Contract_Year_2_end_date__c = map_quoteLineGroups.get(2).SBQQ__EndDate__c;
            }
            if(map_quoteLineGroups.containsKey(3))
            {
                financeShell.Contract_Year_3_start_date__c = map_quoteLineGroups.get(3).SBQQ__StartDate__c;
                financeShell.Contract_Year_3_end_date__c = map_quoteLineGroups.get(3).SBQQ__EndDate__c;
            }
            if(map_quoteLineGroups.containsKey(4))
            {
                financeShell.Contract_Year_4_start_date__c = map_quoteLineGroups.get(4).SBQQ__StartDate__c;
                financeShell.Contract_Year_4_end_date__c = map_quoteLineGroups.get(4).SBQQ__EndDate__c;
            }
            if(map_quoteLineGroups.containsKey(5))
            {
                financeShell.Contract_Year_5_start_date__c = map_quoteLineGroups.get(5).SBQQ__StartDate__c;
                financeShell.Contract_Year_5_end_date__c = map_quoteLineGroups.get(5).SBQQ__EndDate__c;
            }
        }
        return financeShell;
    }
    
    public static CventMyd_QuoteLineObject getTestQuoteLineObject() {
        
        CventMyd_QuoteLineObject quoteLineObject = new CventMyd_QuoteLineObject();
        
        quoteLineObject.qleId = CventMyd_UtilityMethods.getQleId();
        
        quoteLineObject.insertOnNextCurrentYear = false;
        
        quoteLineObject.clonedFromQleIds = new List<String>();
        
        quoteLineObject.deleteThisLine = false;
        
        quoteLineObject.preCalculationFieldValueMap = new Map<String,List<String>>();
        
        quoteLineObject.calculatedFieldValueMap = new Map<String,List<String>>();
        
        for(List<String> fieldNameList : CventMyd_Settings.fieldValueMapFieldNameLists) {
            
            Integer index = CventMyd_Settings.fieldValueMapFieldNameLists.indexOf(fieldNameList);
            
            for(String fieldName : fieldNameList) {
                
                if(index == 0) {
                    
                    quoteLineObject.preCalculationFieldValueMap.put(fieldName, new List<String>());
                    
                    quoteLineObject.preCalculationFieldValueMap.get(fieldName).add('2018-01-01');
                    
                }
                
            }
            
        }
        
        quoteLineObject.nextYearQleId = CventMyd_UtilityMethods.getQleId();
        
        return quoteLineObject;
        
        
    }
    
    public static CventMyd_QuoteObject getTestQuoteObject() {
        
        CventMyd_QuoteObject quoteObject = new CventMyd_QuoteObject();
        
        quoteObject.insertionId = CventMyd_UtilityMethods.getQleId();
        
        quoteObject.settings = new CventMyd_QuoteObject.Settings();
        
        quoteObject.settings.preCalculationFieldNames = CventMyd_Settings.fieldValueMapFieldNameLists[0];
        
        quoteObject.settings.calculatedFieldNames = CventMyd_Settings.fieldValueMapFieldNameLists[1];
        
        quoteObject.settings.msAtLastUpdate = null;
        
        quoteObject.automationStage = new CventMyd_QuoteAutomationStage();
        
        quoteObject.automationStage.codeStatus = CventMyd_QuoteAutomationStage.CodeStatus.LAST_UPDATED_BY_TRIGGER;
        
        quoteObject.outyearMap = CventMYDDataFactory.createCventMyd_Outyear(date.today().year(), 5);
        
        return quoteObject;
        
    }
    
}