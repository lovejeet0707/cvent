@isTest
public class CloneQuoteWithContractGroupsTest {  

    static testMethod void validateMYD_Quotes() {
       // CventMYDCventMYDCventMYDDataFactory CventMYDCventMYDDataFactory = new CventMYDCventMYDDataFactory();
        Test.startTest();
        Account objAccount = CventMYDDataFactory.createAccounts(1);
        insert objAccount;

        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
        insert objContact;

        Opportunity objOpport = CventMYDDataFactory.createOpportunities(1,objAccount.Id,objContact.Id);
        insert objOpport;
        System.debug('objOpport-->' + objOpport);

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
        insert objQuote;       

        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,500));
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,null));
        
        insert lstQuoteLines;

        Test.stopTest();

        CloneQuoteWithContractGroups batchObj = new CloneQuoteWithContractGroups('','',objQuote.Id);
        ID batchprocessid=Database.executeBatch(batchObj,1);
    }

    static testMethod void validateNonMYD_Quotes() {
       // CventMYDCventMYDCventMYDDataFactory CventMYDCventMYDDataFactory = new CventMYDCventMYDDataFactory();
        Test.startTest();
        Account objAccount = CventMYDDataFactory.createAccounts(1);
        insert objAccount;

        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
        insert objContact;

        Opportunity objOpport = CventMYDDataFactory.createOpportunities(1,objAccount.Id,objContact.Id);
        insert objOpport;
        System.debug('objOpport-->' + objOpport);

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
        insert objQuote;
        
        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,500));
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,null));
        
        insert lstQuoteLines;

        Test.stopTest();

        CloneQuoteWithContractGroups batchObj = new CloneQuoteWithContractGroups('','',objQuote.Id);
        ID batchprocessid=Database.executeBatch(batchObj,1);
    }

    static testMethod void dateRange_Quotes() {
       // CventMYDCventMYDCventMYDDataFactory CventMYDCventMYDDataFactory = new CventMYDCventMYDDataFactory();
        Test.startTest();
        Account objAccount = CventMYDDataFactory.createAccounts(1);
        insert objAccount;

        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
        insert objContact;

        Opportunity objOpport = CventMYDDataFactory.createOpportunities(1,objAccount.Id,objContact.Id);
        insert objOpport;
        System.debug('objOpport-->' + objOpport);

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
        insert objQuote;
        
        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,500));
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,null));
        
        insert lstQuoteLines;

        Test.stopTest();

        CloneQuoteWithContractGroups batchObj = new CloneQuoteWithContractGroups('2018-04-16','2019-04-16');
        ID batchprocessid=Database.executeBatch(batchObj,1);
    }

    static testMethod void Query1_Quotes() {
       // CventMYDCventMYDCventMYDDataFactory CventMYDCventMYDDataFactory = new CventMYDCventMYDDataFactory();
        Test.startTest();
        Account objAccount = CventMYDDataFactory.createAccounts(1);
        insert objAccount;

        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
        insert objContact;

        Opportunity objOpport = CventMYDDataFactory.createOpportunities(1,objAccount.Id,objContact.Id);
        insert objOpport;
        System.debug('objOpport-->' + objOpport);

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
        insert objQuote;
        
        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,500));
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,null));
        
        insert lstQuoteLines;

        Test.stopTest();

        CloneQuoteWithContractGroups batchObj = new CloneQuoteWithContractGroups('QUERY2');
        ID batchprocessid=Database.executeBatch(batchObj,1);
    }

    static testMethod void Query2_Quotes() {
       // CventMYDCventMYDCventMYDDataFactory CventMYDCventMYDDataFactory = new CventMYDCventMYDDataFactory();
        Test.startTest();
        Account objAccount = CventMYDDataFactory.createAccounts(1);
        insert objAccount;

        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
        insert objContact;

        Opportunity objOpport = CventMYDDataFactory.createOpportunities(1,objAccount.Id,objContact.Id);
        insert objOpport;
        System.debug('objOpport-->' + objOpport);

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
        insert objQuote;
        
        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,500));
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,null));
        
        insert lstQuoteLines;

        Test.stopTest();

        CloneQuoteWithContractGroups batchObj = new CloneQuoteWithContractGroups('QUERY1');

        ID batchprocessid=Database.executeBatch(batchObj,1);
    }
}