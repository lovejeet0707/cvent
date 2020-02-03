@isTest
private class CreateFincanceShallFromOppTest {
    
    
    @isTest static void CreateFincanceShallFromOppRec() {
        Test.startTest();
        Account objAccount = CventMYDDataFactory.createAccounts(1);
        insert objAccount;
        
        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
        insert objContact;
        
        Opportunity objOpport = CventMYDDataFactory.createOpportunities(1,objAccount.Id,objContact.Id);
        insert objOpport;
        Test.stopTest();
        
        /*CreateFincanceShallFromOpp obj = new CreateFincanceShallFromOpp();
Database.executeBatch(obj,1);*/
        CreateFincanceShallFromOpp obj1 = new CreateFincanceShallFromOpp(objOpport.Id);
        Database.executeBatch(obj1,1);
        //CreateFincanceShallFromOpp obj 2 = new CreateFincanceShallFromOpp('2018-06-24','2018-06-24');
        
        CreateFincanceShallFromOppSingleRec obj2 = new CreateFincanceShallFromOppSingleRec(objOpport.Id);
        obj2.createFinanceShellRecord();
        
        
    }
    
    @isTest static void CreateFincanceShallFromOppDate() {
        Test.startTest();
        Account objAccount = CventMYDDataFactory.createAccounts(1);
        insert objAccount;
        
        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
        insert objContact;
        
        Opportunity objOpport = CventMYDDataFactory.createOpportunities(1,objAccount.Id,objContact.Id);
        insert objOpport;
        Test.stopTest();
        
        //CreateFincanceShallFromOpp obj = new CreateFincanceShallFromOpp();
        //CreateFincanceShallFromOpp obj1 = new CreateFincanceShallFromOpp(objOpport.Id);
        CreateFincanceShallFromOpp obj2 = new CreateFincanceShallFromOpp('2018-06-24','2018-06-24');
        
        CreateFincanceShallFromOppSingleRec obj = new CreateFincanceShallFromOppSingleRec(objOpport.Id);
        obj.createFinanceShellRecord();
        
        
    }
    
    @isTest static void CreateFincanceShallFromOppSet() {
        Test.startTest();
        Account objAccount = CventMYDDataFactory.createAccounts(1);
        insert objAccount;
        
        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
        insert objContact;
        
        Opportunity objOpport = CventMYDDataFactory.createOpportunities_Stage(1,objAccount.Id,objContact.Id);
        insert objOpport;
        
        Opportunity objOpport1 = CventMYDDataFactory.createOpportunities_Stage(1,objAccount.Id,objContact.Id);
        insert objOpport1;
        
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
        Set<Id> setOpp = new Set<Id>();
        setOpp.add(objOpport.Id);
        setOpp.add(objOpport1.Id);
        CreateFincanceShallFromOpp obj1 = new CreateFincanceShallFromOpp(setOpp);
        Database.executeBatch(obj1,1);
        //new CreateFincanceShallFromOpp(setOpp);
        
        CreateFincanceShallHandler.populateQuarter(System.Today());
        CreateFincanceShallHandler.populateQuarter(System.Today().addMonths(3));
        CreateFincanceShallHandler.populateQuarter(System.Today().addMonths(6));
        CreateFincanceShallHandler.populateQuarter(System.Today().addMonths(9));
    }
    
    @isTest static void CreateFincanceShallFromOppSetForMail() {
        Test.startTest();
        Account objAccount = CventMYDDataFactory.createAccounts(1);
        insert objAccount;
        
        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
        insert objContact;
        
        Opportunity objOpport = CventMYDDataFactory.createOpportunities_Stage(1,objAccount.Id,objContact.Id);
        insert objOpport;
        
        Opportunity objOpport1 = CventMYDDataFactory.createOpportunities_Stage(1,objAccount.Id,objContact.Id);
        insert objOpport1;
        
        Contract_Reviewing__c obj = new Contract_Reviewing__c();
        obj.Opportunity__c = objOpport1.Id;
        obj.Contract_Review_Ok__c = 'Yes';
        obj.Final_Review_Date__c = Date.today();
        insert obj;
        
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
        //  objQuote.jsonString__c = JSON.serialize(getTestQuoteObject());
        insert objQuote;       
        
        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,500));
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,null));
        
        insert lstQuoteLines;
        Test.stopTest();
        Set<Id> setOpp = new Set<Id>();
        setOpp.add(objOpport.Id);
        setOpp.add(objOpport1.Id);
        // CreateFincanceShallFromOpp obj1 = new CreateFincanceShallFromOpp(setOpp);
        CreateFincanceShallFromOpp obj1 = new CreateFincanceShallFromOpp('QUERY1');
        Database.executeBatch(obj1,1);
        //new CreateFincanceShallFromOpp(setOpp);
        
        CreateFincanceShallHandler.populateQuarter(System.Today());
        CreateFincanceShallHandler.populateQuarter(System.Today().addMonths(3));
        CreateFincanceShallHandler.populateQuarter(System.Today().addMonths(6));
        CreateFincanceShallHandler.populateQuarter(System.Today().addMonths(9));
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
        
        quoteObject.outyearMap = new Map<Integer,CventMyd_Outyear>();
        
        return quoteObject;
        
    }
}