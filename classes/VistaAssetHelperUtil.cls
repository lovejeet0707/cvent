@isTest
public class VistaAssetHelperUtil {
    public VistaAssetHelperUtil() {
    }

    static Integer sObjectIdCounter = 1;

    public static String getFakeId(Schema.SobjectType sot) {
        String result = String.valueOf(sObjectIdCounter++);
        return sot.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
    }

    public Id pricebookId = Test.getStandardPricebookId();

    public Account createAccount(String acctName) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createAccount');
        Account account = new Account();
        account.Name = acctName;
        account.BillingCountryCode = 'US';
        account.BillingStateCode = 'AL';
        account.BillingPostalCode = '12345';
        insert account;
        return account;
    }

    public Contract createContract(Opportunity opportunity, Account account, String contractType, Date startdate) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createContract');
        Contract contract = new Contract();
        contract.AccountId = account.Id;
        contract.Status = 'In Review';
        contract.StartDate = startdate;
        contract.ContractTerm = 12;
        if (contractType != 'Master Agreement' && opportunity != null) {
            contract.SBQQ__Opportunity__c = opportunity.Id;
        }
        insert contract;
        return contract;
    }

    public List<Product2> initProductSet(Integer numProducts, String productGroup, String subPricingType) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.initProductSet');
        // subPricingType = 'Fixed Price' or 'Percent Of Total'
        List<Product2> productList = new List<Product2>();
        Integer p = 0;
        while (p < numProducts) {
            Product2 product = new Product2();
            product.ProductCode = 'product-' + p;
            product.Name = productGroup + ' Product ' + p;
            product.Description = productGroup + ' Product ' + p + ' Description';
            product.Family = productGroup + 'Family';
            product.Generate_Asset__c = true;
            product.IsActive = true;
            if (subPricingType != null) {
                if (subPricingType == 'Percent Of Total') {
                    product.SBQQ__SubscriptionPricing__c = 'Percent Of Total';
                    product.SBQQ__SubscriptionPercent__c = 10;
                    product.SBQQ__SubscriptionBase__c = 'List';
                } else if (subPricingType == 'One Time') {
                    product.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                    product.SBQQ__SubscriptionType__c = 'One-time';
                    product.SBQQ__SubscriptionTerm__c = 12;
                } else {
                    product.SBQQ__SubscriptionPricing__c = subPricingType;
                    product.SBQQ__SubscriptionType__c = 'Renewable';
                    product.SBQQ__SubscriptionTerm__c = 12;
                }
            } else {
                product.SBQQ__SubscriptionType__c = null;
            }
            product.SBQQ__QuantityEditable__c = true;
            product.SBQQ__IncludeInMaintenance__c = true;
            if (productGroup == 'Hardware') {
            }
            productList.add(product);
            p = p + 1;
        }
        insert productList;
        return productList;
    }

    public List<Product2> initProductSet(Integer numProducts, String productGroup, String subPricingType, String billingFreq) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.initProductSet');
        // subPricingType = 'Fixed Price' or 'Percent Of Total'
        List<Product2> productList = new List<Product2>();
        Integer p = 0;
        while (p < numProducts) {
            Product2 product = new Product2();
            product.ProductCode = 'product-' + p;
            product.Name = productGroup + ' Product ' + p;
            product.Description = productGroup + ' Product ' + p + ' Description';
            product.Family = productGroup + 'Family';
            product.Generate_Asset__c = true;
            product.IsActive = true;
            if (subPricingType != null) {
                if (subPricingType == 'Percent Of Total') {
                    product.SBQQ__SubscriptionPricing__c = 'Percent Of Total';
                    product.SBQQ__SubscriptionPercent__c = 10;
                    product.SBQQ__SubscriptionBase__c = 'List';
                } else if (subPricingType == 'One Time') {
                    product.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                    product.SBQQ__SubscriptionType__c = 'One-time';
                    product.SBQQ__SubscriptionTerm__c = 12;
                } else {
                    product.SBQQ__SubscriptionPricing__c = subPricingType;
                    product.SBQQ__SubscriptionType__c = 'Renewable';
                    product.SBQQ__SubscriptionTerm__c = 12;
                }
            } else {
                product.SBQQ__SubscriptionPricing__c = null;
                product.SBQQ__SubscriptionType__c = null;
            }
            product.SBQQ__QuantityEditable__c = true;
            product.SBQQ__IncludeInMaintenance__c = true;
            productList.add(product);
            p = p + 1;
        }
        insert productList;
        return productList;
    }

    public Map<Id, PricebookEntry> initPricebook(List<Product2> productList) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.initPricebook');
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        List<PricebookEntry> pbInsertList = new List<PricebookEntry>();
        Integer pb = 0;
        while (pb < productList.size()) {
            PricebookEntry pbEntry = new PricebookEntry();
            pbEntry.Pricebook2Id = pricebookId;
            pbEntry.Product2Id = productList[pb].Id;
            pbEntry.UnitPrice = 500 * pb + 1;
            pbEntry.IsActive = true;
            pbInsertList.add(pbEntry);
            pricebookEntries.put(pbEntry.Product2Id, pbEntry);
            pb = pb + 1;
        }
        insert pbInsertList;
        return pricebookEntries;
    }

    public Opportunity createNewOpportunity(String opportunityName, Account account, String recordType, String orderType, Contact contact) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createNewOpportunity');
        Opportunity opportunity = new Opportunity();
        opportunity.Name = opportunityName;
        opportunity.StageName = '1 - Plan';
        opportunity.CloseDate = System.today();
        opportunity.AccountId = account.Id;
        opportunity.LeadSource = 'SEO';
        opportunity.Description = 'Opp Desc';
        opportunity.Contact_Associated__c = contact.Id;
        insert opportunity;
        return opportunity;
    }

    // Karl added.
    public Contact createNewContact(String contactName, Account account) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createNewContact');
        Contact contact = new Contact();
        contact.LastName = contactName;
        contact.AccountId = account.Id;
        contact.Product_Desired__c = 'CSN';
        insert contact;
        return contact;
    }

    public SBQQ__Quote__c createSBQuote(Opportunity opportunity, Account account, Date startDate) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createSBQuote');
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = account.Id;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__StartDate__c = startDate;
        quote.SBQQ__SubscriptionTerm__c = 12;
        quote.SBQQ__Status__c = 'Approved';
        quote.Contract_Executed__c = true;
        insert quote;
        return quote;
    }

    public List<SBQQ__QuoteLine__c> createSBQuoteLines(SBQQ__Quote__c sbQuote
            , Map<Id, PricebookEntry> pricebookEntries
            , boolean existing
            , Integer quantityMultiplier) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createSBQuoteLines');
        List<SBQQ__QuoteLine__c> sbQuoteLines = new List<SBQQ__QuoteLine__c>();
        Integer q = 1;
        for (PricebookEntry pbEntry : pricebookEntries.values()) {
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
            quoteLine.SBQQ__Quote__c = sbQuote.Id;
            quoteLine.SBQQ__Product__c = pbEntry.Product2Id;
            quoteLine.SBQQ__Quantity__c = q * quantityMultiplier;
            quoteLine.SBQQ__Existing__c = existing;
            quoteLine.SBQQ__NetPrice__c = pbEntry.UnitPrice;
            quoteline.SBQQ__RenewedAsset__c = null;
            sbQuoteLines.add(quoteLine);
            q = q + 1;
        }
        insert sbQuoteLines;
        sbQuoteLines = [
                SELECT Id, SBQQ__Quote__c, SBQQ__Product__c, SBQQ__Quantity__c, SBQQ__Existing__c, SBQQ__NetPrice__c
                        , SBQQ__Product__r.SBQQ__SubscriptionPricing__c, SBQQ__Product__r.SBQQ__SubscriptionType__c
                        , SBQQ__RenewedAsset__c
                        , Annual_Recurring_Revenue__c, SBQQ__StartDate__c
                FROM SBQQ__QuoteLine__c
                WHERE Id in :sbQuoteLines
        ];
        return sbQuoteLines;
    }

    public List<OpportunityLineItem> createOppLineItems(Opportunity opportunity
            , List<SBQQ__Quoteline__c> quoteLines
            , Map<Id, PricebookEntry> pbEntries) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createOppLineItems');
        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        for (SBQQ__Quoteline__c quoteLine : quoteLines) {
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.SBQQ__QuoteLine__c = quoteLine.Id;
            oli.OpportunityId = opportunity.Id;
            if (quoteLine.SBQQ__Quantity__c == 0) {
                oli.Quantity = 1;
            } else {
                oli.Quantity = quoteLine.SBQQ__Quantity__c;
            }
            oli.TotalPrice = quoteLine.SBQQ__NetPrice__c;
            PricebookEntry pbe = pbEntries.get(quoteLine.SBQQ__Product__c);
            oli.PricebookEntryId = pbe.Id;
            opportunityLineItems.add(oli);
        }
        insert opportunityLineItems;
        opportunityLineItems = [
                SELECT Id, OpportunityId, ProductCode, SBQQ__QuoteLine__c, PricebookEntryId
                        , SBQQ__QuoteLine__r.SBQQ__Group__c
                        , SBQQ__QuoteLine__r.SBQQ__Group__r.SBQQ__Number__c, TotalPrice, Quantity
                        , SBQQ__QuoteLine__r.SBQQ__Group__r.Id, UnitPrice, ListPrice
                        , SBQQ__QuoteLine__r.SBQQ__Product__r.SBQQ__SubscriptionPricing__c
                        , SBQQ__QuoteLine__r.SBQQ__Product__r.SBQQ__SubscriptionType__c
                FROM OpportunityLineItem
                WHERE Id in :opportunityLineItems
        ];
        return opportunityLineItems;
    }

    public Opportunity closeWonOpportunity(Opportunity opportunity) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.closeWonOpportunity');
        opportunity.StageName = 'Closed Won';
        opportunity.SBQQ__Contracted__c = true;
        update opportunity;
        return opportunity;
    }

    public List<SBQQ__Subscription__c> createSubscriptions(List<SBQQ__Quoteline__c> quoteLines
            , Contract contract
            , Account account
            , Id revisedSubId) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createSubscriptions');
        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
        for (SBQQ__Quoteline__c quoteLine : quoteLines) {
            System.debug(LoggingLevel.WARN, 'ql inside create subscr: ' + quoteLine.SBQQ__Product__r.SBQQ__SubscriptionPricing__c);
            if (quoteLine.SBQQ__Product__r.SBQQ__SubscriptionPricing__c != null) {
                SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
                sub.SBQQ__Product__c = quoteLine.SBQQ__Product__c;
                if (quoteLine.SBQQ__Quantity__c == 0) {
                    sub.SBQQ__Quantity__c = 1;
                } else {
                    sub.SBQQ__Quantity__c = quoteLine.SBQQ__Quantity__c;
                }
                if (revisedSubId != null) {
                    sub.SBQQ__RevisedSubscription__c = revisedSubId;
                }

                sub.SBQQ__NetPrice__c = quoteLine.SBQQ__NetPrice__c;
                sub.Annual_Recurring_Revenue__c = quoteLine.Annual_Recurring_Revenue__c;
                sub.SBQQ__SubscriptionStartDate__c = quoteLine.SBQQ__StartDate__c;
                sub.SBQQ__Contract__c = contract.Id;
                sub.SBQQ__Contract__r = contract;
                sub.SBQQ__Account__c = account.Id;
                sub.SBQQ__QuoteLine__c = quoteLine.Id;
                subscriptionList.add(sub);

            }
        }
        insert subscriptionList;
        subscriptionList = [
                SELECT Id, SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Account__c
                        , SBQQ__Contract__c, SBQQ__Contract__r.EndDate, SBQQ__StartDate__c
                        , SBQQ__EndDate__c, SBQQ__Quantity__c, SBQQ__QuoteLine__c
                        , Subscribed_Asset_Count__c
                        , SBQQ__Product__r.Name, SBQQ__Product__r.Description
                        , SBQQ__NetPrice__c, Annual_Recurring_Revenue__c
                        , SBQQ__RevisedSubscription__c
                        , SBQQ__QuoteLine__r.Id, SBQQ__QuoteLine__r.SBQQ__Existing__c
                        , SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c, SBQQ__QuoteLine__r.SBQQ__Quantity__c
                FROM SBQQ__Subscription__c
                WHERE Id IN :subscriptionList
        ];
        System.debug(LoggingLevel.WARN, 'subscriptionList1: ' + subscriptionList);
        return subscriptionList;
    }

    public Asset createSFDCAsset(SBQQ__Quoteline__c quoteLine, Account account) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createSFDCAsset');
        Product2 product = [SELECT Id, Name, Description FROM Product2 WHERE Id = :quoteLine.SBQQ__Product__c];
        Asset newAsset = new Asset();
        newAsset.AccountId = account.Id;
        newAsset.Name = product.Name;
        newAsset.Product2Id = quoteLine.SBQQ__Product__c;
        newAsset.Price = quoteLine.SBQQ__NetPrice__c;
        newAsset.Quantity = quoteLine.SBQQ__Quantity__c;
        newAsset.SBQQ__QuoteLine__c = quoteLine.Id;
        newAsset.SBQQ__LatestQuoteLine__c = quoteLine.Id;

        insert newAsset;
        newAsset = [
                SELECT Id, AccountId, Name, Product2Id, Price, Quantity
                        , SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__Quantity__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__RenewedAsset__c
                FROM Asset
                WHERE Id = :newAsset.Id
        ];
        return newAsset;
    }

    public SBQQ__SubscribedAsset__c createSubscribedAsset(Boolean active, Asset sfdcAsset, SBQQ__Subscription__c subscription) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createSubscribedAsset');
        SBQQ__SubscribedAsset__c sbSubAsset = new SBQQ__SubscribedAsset__c();
        sbSubAsset.SBQQ__Active__c = active;
        sbSubAsset.SBQQ__Asset__c = sfdcAsset.Id;
        sbSubAsset.SBQQ__Subscription__c = subscription.Id;
        insert sbSubAsset;
        sbSubAsset = [
                SELECT Id
                        , SBQQ__Active__c, SBQQ__Asset__c, SBQQ__ContractId__c, SBQQ__Subscription__c
                        , SBQQ__Asset__r.AccountId, SBQQ__Asset__r.Contract__c
                        , SBQQ__Asset__r.SBQQ__RevisedAsset__c
                        , SBQQ__Asset__r.Price, SBQQ__Asset__r.Annual_Recurring_Revenue__c
                        , SBQQ__Asset__r.Product2Id, SBQQ__Asset__r.Product2.Name
                        , SBQQ__Asset__r.Product2.Description, SBQQ__Asset__r.Product2.Generate_Asset__c
                        , SBQQ__Subscription__r.SBQQ__RevisedSubscription__c, SBQQ__Subscription__r.CurrencyIsoCode
                        , SBQQ__Subscription__r.Subscribed_Asset_Count__c
                        , SBQQ__Subscription__r.SBQQ__NetPrice__c
                        , SBQQ__Subscription__r.SBQQ__StartDate__c, SBQQ__Subscription__r.SBQQ__EndDate__c
                        , SBQQ__Asset__r.SBQQ__QuoteLine__c
                        , SBQQ__Asset__r.SBQQ__QuoteLine__r.Id, SBQQ__Asset__r.SBQQ__QuoteLine__r.SBQQ__Existing__c
                        , SBQQ__Asset__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c, SBQQ__Asset__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c
                        , SBQQ__Asset__r.Contract__r.StartDate, SBQQ__Asset__r.Contract__r.EndDate
                FROM SBQQ__SubscribedAsset__c
                WHERE Id = :sbSubAsset.Id
        ];
        return sbSubAsset;
    }

    /** Create account */
    public static Account createAccount(Boolean doInsert) {
        return createAccount(null, doInsert);
    }

    public static Account createAccount(Contact contact, Boolean doInsert) {
        Account account = new Account();

        account.Name = 'Test Account for the Ages';
        account.BillingCity = 'Oxnard';
        account.BillingCountry = 'United States';
        account.BillingPostalCode = '93030';
        account.BillingState = 'California';
        account.BillingStreet = '121 North G Street';
        account.ShippingCity = 'Los Angeles';
        account.ShippingCountry = 'United States';
        account.ShippingPostalCode = '90033';
        account.ShippingState = 'California';
        account.ShippingStreet = '1600 Pennsylvania Avenue';
        if (!doInsert) {account.Id = getFakeId(Account.getSObjectType());}
        if (doInsert) {
            insert account;
            // Update
            if(contact != null && contact.accountId == null) { contact.AccountId = account.Id; }
        }
        return account;
    }

    /** Create contact for given account */
    public static Contact createContact(Boolean doInsert) {
        return createContact(null, doInsert);
    }
    public static Contact createContact(Account acct, Boolean doInsert) {
        Contact obj = new Contact();

        obj.Email='testUtilEmail@testUtil.com';
        obj.FirstName = 'Test';
        obj.LastName = 'Contact';
        obj.MailingCity = 'Los Angeles';
        obj.MailingCountry = 'United States';
        obj.MailingPostalCode = '90033';
        obj.MailingState = 'California';
        obj.MailingStreet = '1600 Pennsylvania Avenue';
        if(acct != null) {
            obj.AccountId = acct.Id;
        }
        if (!doInsert) {obj.Id = getFakeId(obj.getSObjectType());}
        if (doInsert) { insert obj; }
        return obj;
    }


    public static Pricebook2 createPricebook(Boolean doInsert) {
        Pricebook2 obj = new Pricebook2();

        if (!doInsert) {
            obj.Name = 'Test Pricebook';
            obj.Id = getFakeId(Pricebook2.getSObjectType());
        }
        if (doInsert) {
            obj.Id = Test.getStandardPricebookId();
        }
        return obj;
    }

    /** Create pricebook entry */
    public static PricebookEntry createPriceBookEntry(Product2 product, Pricebook2 pricebook, Boolean doInsert) {
        PricebookEntry obj = new PricebookEntry();

        obj.Pricebook2Id = pricebook.Id;
        obj.Pricebook2 = pricebook;
        obj.Product2Id = product.Id;
        obj.Product2 = product;
        obj.UnitPrice = 10;
        //obj.StandardPrice = 10;
        obj.IsActive = true;
        if (!doInsert) {obj.Id = getFakeId(PricebookEntry.getSObjectType());}
        if (doInsert) { insert obj; }
        return obj;
    }

    /** Create opportunity */
    public static Opportunity createOpportunity(Account acct, Contact billToContact, Pricebook2 pricebook, Boolean doInsert) {
        Opportunity obj = new Opportunity();

        obj.Name = 'test';
        obj.Type = 'New';
        obj.CloseDate = Date.today();
        obj.StageName = 'Proposal Sent';
        obj.Probability = 50;
        obj.AccountId = acct.Id;
        obj.Account = acct;

        obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        obj.Pricebook2Id = pricebook.Id;
        obj.Pricebook2 = pricebook;
        if (!doInsert) {obj.Id = getFakeId(obj.getSObjectType());}
        if (doInsert) { insert obj; }
        return obj;
    }

    /** Create opportunity line item WITHOUT SBQQ quote reference */
    public static OpportunityLineItem createOpportunityLine(Opportunity opp, PricebookEntry pbEntry, Boolean doInsert) {
        return createOpportunityLine(opp, pbEntry, null, doInsert);
    }

    /** Create opportunity line item WITH SBQQ quote reference */
    public static OpportunityLineItem createOpportunityLine(Opportunity opp, PricebookEntry pbEntry, SBQQ__QuoteLine__c quoteLine, Boolean doInsert) {
        OpportunityLineItem obj = new OpportunityLineItem();

        obj.OpportunityId = opp.Id;
        obj.Opportunity = opp;
        obj.Quantity = 1;
        obj.PricebookEntryId = pbEntry.Id;
        obj.PricebookEntry = pbEntry;
        obj.TotalPrice = obj.Quantity * pbEntry.UnitPrice;
        if (quoteLine != null) {
            obj.SBQQ__QuoteLine__c = quoteLine.Id;
            obj.SBQQ__QuoteLine__r = quoteLine;
        }
        if (!doInsert) {obj.Id = getFakeId(OpportunityLineItem.getSObjectType());}
        if (doInsert) { insert obj; }
        return obj;
    }

    public static Product2 createProduct(Boolean doInsert) {
        Product2 obj = new Product2();

        obj.Name = 'Test Product';
        obj.IsActive = true;
        obj.ProductCode = 'CL01';
        obj.Description = 'Product of Clip Licensing, used to quote for In Library videos';
        obj.SBQQ__OptionSelectionMethod__c = 'Click';
        obj.SBQQ__ConfigurationType__c = null;
        obj.SBQQ__QuantityEditable__c = true;
        obj.SBQQ__SubscriptionBase__c = 'List';
        obj.SBQQ__Taxable__c = false;
        obj.SBQQ__BlockPricingField__c = 'Quantity';
        obj.SBQQ__Component__c = false;
        obj.SBQQ__DefaultQuantity__c = 1;
        obj.SBQQ__ExcludeFromOpportunity__c = false;
        obj.SBQQ__PriceEditable__c = true;
        obj.SBQQ__PricingMethod__c = 'List';
        obj.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        obj.SBQQ__SubscriptionType__c = 'Renewable';
        obj.SBQQ__SubscriptionTerm__c = 12;
        obj.SBQQ__ChargeType__c = 'Recurring';
        obj.SBQQ__BillingType__c = 'Advance';
        obj.SBQQ__BillingFrequency__c = 'Monthly';
        obj.Generate_Asset__c = true;
        if (!doInsert) {obj.Id = getFakeId(Product2.getSObjectType());}
        if (doInsert) { insert obj; }
        return obj;
    }

    /** Create quote */
    public static SBQQ__Quote__c createQuote(Account acct, Opportunity opp, Pricebook2 pricebook, Boolean doInsert) {
        SBQQ__Quote__c obj = new SBQQ__Quote__c();

        obj.SBQQ__Status__c = 'Draft';
        obj.SBQQ__Primary__c = true;
        obj.SBQQ__StartDate__c = Date.today();
        obj.SBQQ__EndDate__c = Date.today().addMonths(1);
        obj.SBQQ__Opportunity2__c = opp.Id;
        obj.SBQQ__Opportunity2__r = opp;
        obj.SBQQ__SubscriptionTerm__c = 12;
        obj.SBQQ__ExpirationDate__c = Date.today() + 30;
        obj.SBQQ__Account__c = acct.Id;
        obj.SBQQ__Account__r = acct;
        obj.SBQQ__Type__c = 'Quote';
        obj.SBQQ__PriceBook__c = pricebook.Id;
        obj.SBQQ__PriceBook__r = pricebook;
        if (!doInsert) {obj.Id = getFakeId(SBQQ__Quote__c.getSObjectType());}
        if (doInsert) { insert obj; }
        return obj;
    }

    /** Create quote line */
    public static SBQQ__QuoteLine__c createQuoteLine(Product2 product, SBQQ__Quote__c quote, Boolean doInsert) {
        SBQQ__QuoteLine__c obj = new SBQQ__QuoteLine__c();

        obj.SBQQ__Quote__c = quote.Id;
        obj.SBQQ__Quote__r = quote;
        obj.SBQQ__Product__c = product.Id;
        obj.SBQQ__Product__r = product;
        obj.SBQQ__PricingMethod__c = 'List';
        obj.SBQQ__StartDate__c = Date.today();
        obj.SBQQ__ListPrice__c = 10;
        obj.SBQQ__Quantity__c = 1;
        obj.SBQQ__RegularPrice__c = 10;
        obj.SBQQ__NetPrice__c = 10;
        obj.SBQQ__Number__c = 1;
        obj.SBQQ__ProrateMultiplier__c = 1;
        obj.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        obj.SBQQ__SubscriptionScope__c = 'Quote';
        obj.SBQQ__DefaultSubscriptionTerm__c = 1;
        obj.SBQQ__ChargeType__c = product.SBQQ__ChargeType__c;
        obj.SBQQ__BillingType__c = product.SBQQ__BillingType__c;
        obj.SBQQ__BillingFrequency__c = product.SBQQ__BillingFrequency__c;
        if (!doInsert) {obj.Id = getFakeId(SBQQ__QuoteLine__c.getSObjectType());}
        if (doInsert) { insert obj; }
        return obj;
    }

    public static Contract createContract(Account account, Opportunity anOpportunity, Boolean doInsert) {
        Contract obj = new Contract();
        obj.Name = 'Test Contract';
        obj.AccountId = account.Id;
        obj.Account = account;
        obj.CurrencyIsoCode = 'USD';
        obj.SBQQ__Opportunity__r = anOpportunity;
        if (!doInsert) {obj.Id = getFakeId(Contract.getSObjectType());}
        if (doInsert) { insert obj; }
        return obj;
    }

    public static Map<String, SObject> createSBQQStack(Boolean doInsert) {
        Map<String, SObject> objectMap = new Map<String, SObject>();

        Account account = VistaAssetHelperUtil.createAccount(doInsert);
        Contact billingContact = VistaAssetHelperUtil.createContact(account, doInsert);

        Product2 product = VistaAssetHelperUtil.createProduct(doInsert);
        Pricebook2 priceBook = VistaAssetHelperUtil.createPricebook(doInsert);
        PricebookEntry pbEntry = VistaAssetHelperUtil.createPriceBookEntry(product, priceBook, doInsert);
        Opportunity opportunity = VistaAssetHelperUtil.createOpportunity(account, billingContact, pricebook, doInsert);
        Contract aContract = VistaAssetHelperUtil.createContract(account, opportunity, doInsert);
        SBQQ__Quote__c quote = VistaAssetHelperUtil.createQuote(account, opportunity, pricebook, doInsert);
        SBQQ__QuoteLine__c quoteLine = VistaAssetHelperUtil.createQuoteLine(product, quote, doInsert);
        OpportunityLineItem oli = VistaAssetHelperUtil.createOpportunityLine(opportunity, pbEntry, quoteLine, doInsert);

        objectMap.put(VistaAssetHelperUtil.ACCOUNT, account);
        objectMap.put(VistaAssetHelperUtil.CONTACT, billingContact);
        objectMap.put(VistaAssetHelperUtil.PRODUCT, product);
        objectMap.put(VistaAssetHelperUtil.PRICEBOOK_ENTRY, pbEntry);

        objectMap.put(VistaAssetHelperUtil.OPPORTUNITY, opportunity);
        objectMap.put(VistaAssetHelperUtil.QUOTE, quote);
        objectMap.put(VistaAssetHelperUtil.QUOTE_LINE, quoteLine);
        objectMap.put(VistaAssetHelperUtil.OPPORTUNITY_LINE_ITEM, oli);

        return objectMap;
    }

    public static String ACCOUNT = 'Account';
    public static String CONTACT = 'Contact';
    public static String PRODUCT = 'Product2';
    public static String PRICEBOOK_ENTRY = 'PricebookEntry';
    public static String OPPORTUNITY = 'Opportunity';
    public static String QUOTE = 'SBQQ__Quote__c';
    public static String QUOTE_LINE = 'SBQQ__QuoteLine__c';
    public static String OPPORTUNITY_LINE_ITEM = 'OpportunityLineItem';
}