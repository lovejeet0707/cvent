@isTest
private class CventMyd_ContractAmendController_Test {

    private static testMethod void CventMyd_ContractAmendmentControllerTest() {
        
        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();
        
        //MODIFIED BY: NDeGuzman 7.3.18
        //Corrected the test data
        Account TestAccount = new Account();
            TestAccount.Name = 'Test Account';
            TestAccount.BillingCountry = 'US';
            TestAccount.BillingCountryCode = 'US';
            TestAccount.BillingState = 'NY';
            TestAccount.BillingStateCode = 'NY';  
            
            TestAccount.ShippingCountry = 'US';
            TestAccount.ShippingCountryCode = 'US';
            TestAccount.ShippingState = 'NY';
            TestAccount.ShippingStateCode = 'NY';
            
        insert TestAccount;
        
        Contact contactPerson = TestUtil.createContact('Test FirstName', 'Lastname', 'test@mojonestworks.com', String.valueOf(TestAccount.id));
            contactPerson.MailingCountry = 'US';
            contactPerson.MailingCountryCode = 'US';
            contactPerson.MailingState = 'NY';
            contactPerson.MailingStateCode = 'NY';          
            
        insert contactPerson;
        //END
        
        // Create Product Record.
        List<Product2> products =  TestUtil.createProducts(new List<String>{'Web Design Support','CVENT Attendee Support'});
        insert products;
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();        
        PricebookEntry pbe1 =  TestUtil.createPricebookEntry(products[0],200);
        pbeList.add(pbe1);
        PricebookEntry pbe2 =  TestUtil.createPricebookEntry(products[1],400);
        pbeList.add(pbe2);        
        insert pbeList;   
        
        Address__c addr = new Address__c();
         addr.Account__c = TestAccount.Id;   
         addr.State__c = 'NY';
         addr.Country__c = 'US';
         addr.Type__c = 'Billing';
         addr.CountryCode__c = 'US';
        
        insert addr;
        
        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'MYD Created');
        opp.CurrencyIsoCode  = 'USD';
        opp.Contact_Associated__c  = contactPerson.id;
       // opp.Web_Design_Support_Minutes_Purchased__c = 180.00;  comment By kd
        opp.Account = TestAccount;
        opp.Bill_To_Address__c = addr.id;
        insert opp;
        
        System.debug('******* Opp in test class = ' + opp);
        
        OpportunityLineItem oli1 = TestUtil.createOpportunityLineItems(opp,pbe1);
        OpportunityLineItem oli2 = TestUtil.createOpportunityLineItems(opp,pbe2);
        
        //MODIFIED BY: NDeGuzman 7.3.18
        //Completed the test data
        Opportunity opp2 = TestUtil.createOpportunity('Test Opp', 'Renewal', 'MYD Created');
        /* opp2.CurrencyIsoCode  = 'USD';
        opp2.Bill_To_Address__c = addr.id;*/
        opp2.CurrencyIsoCode  = 'USD';
        opp2.Contact_Associated__c  = contactPerson.id;
       // opp2.Web_Design_Support_Minutes_Purchased__c = 180.00; comment by kd
        opp2.Account = TestAccount;
        opp2.Bill_To_Address__c = addr.id;
        
        insert opp2;
        //END
        
        //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c
        Contract ParentCont = new Contract();
        ParentCont.AccountId = TestAccount.id;
        ParentCont.Contract_Term_Years__c = '3';
        ParentCont.RecordTypeId = RecordTypeId;
        ParentCont.SBQQ__Opportunity__c = opp.id;
        insert ParentCont;
        
        //Child Contract
        Contract cont = new Contract();
        cont.RecordTypeId = ChildRecordTypeId;
        cont.AccountId = TestAccount.id;
        cont.Parent_Contract__c = ParentCont.id;
        //cont.Upcoming_Renewal_Type__c = 'Contract Renewal';
        cont.EndDate = System.today();
        //cont.Remaining_Master_Term__c = 0;
        cont.Current_Year__c = 1;
        cont.SBQQ__Opportunity__c = opp2.id;
        //cont.Is_Legacy__c = true;
        
         
        insert cont;

        Test.setCreatedDate(cont.Id,DateTime.newInstance(2015,1,1));
        
        opp.SBQQ__AmendedContract__c = cont.id;
        update opp;
        
        //Normal Quote
        //Try inserting a Quote SBQQ__Type__c == Renewal
        SBQQ__Quote__c TestQuote = new SBQQ__Quote__c();
        TestQuote.SBQQ__Opportunity2__c = opp.id;
        TestQuote.Contract_Term_Years__c = '2';
        //TestQuote.SBQQ__Type__c = 'Amendment';
        TestQuote.Current_Year__c = 1;
        TestQuote.Contract_Term_Years__c = '2';
        TestQuote.Contract_Executed__c = true;
        TestQuote.Multiple_Years_Commitment__c = true;
        //Date newDate = System.today().addYears(1);
        
        TestQuote.SBQQ__StartDate__c = System.today().addYears(-1); //System.today().year() - 1;
        TestQuote.SBQQ__EndDate__c = System.today();
        //TestQuote.jsonString__c = '{"startDate":"2018-04-17","settings":{"preCalculationFieldNames":["SBQQ__Quantity__c","SBQQ__Discount__c","Custom_Discount__c","Discount_Type__c","SBQQ__AdditionalDiscount__c","Rate__c","Zone_Level__c","Number_of_Guest_Rooms__c","Lanyon_Chain_Affiliation__c","Chain_Affiliation__c","Setup_Days__c","Travel_Days__c","Event_Start_Date__c","Event_End_Date__c","Attendees__c","OnArrival_360_Event_Selection__c"],"calculatedFieldNames":["SBQQ__OriginalPrice__c","SBQQ__ListPrice__c","SBQQ__RegularPrice__c","SBQQ__NetPrice__c","Rack_Rate__c"],"msAtLastUpdate":1525180814312},"outyearMap":{"2":{"year":2,"startDate":"2019-04-17","endDate":"2020-04-16"},"3":{"year":3,"startDate":"2020-04-17","endDate":"2021-04-16"},"4":{"year":4,"startDate":"2021-04-17","endDate":"2022-04-16"},"5":{"year":5,"startDate":"2022-04-17","endDate":"2023-04-16"}},"isManuallyCreatedFirstYear":null,"endDate":"2019-04-16","automationStage":{"renewalStage":null,"codeStatus":"CALCULATION_CYCLE_FINISHED"}}';
        insert TestQuote;
        TestQuote.SBQQ__Type__c = 'Amendment';
        update TestQuote;
        
        SBQQ__Quote__c TestQuote2 = new SBQQ__Quote__c();
        TestQuote2.SBQQ__Opportunity2__c = opp.id;
        TestQuote2.Contract_Term_Years__c = '2';
        TestQuote2.SBQQ__Type__c = 'Renewal';
        //TestQuote2.Contract_Executed__c = true;
        TestQuote2.SBQQ__StartDate__c = System.today().addYears(-1);
        TestQuote2.SBQQ__EndDate__c = System.today();
       // TestQuote2.SBQQ__Primary__c=null;
        //try{
        //   insert TestQuote2;
       // }Catch(exception e){
        //}
     
        
        //Quote Line Group
        SBQQ__QuoteLineGroup__c qlGroup = new SBQQ__QuoteLineGroup__c();
        qlGroup.Name = 'Group 1';
        qlGroup.SBQQ__Number__c = 10;
        qlGroup.SBQQ__ListTotal__c = 10;
        qlGroup.SBQQ__NetTotal__c = 100;
        qlGroup.SBQQ__CustomerTotal__c = 1000;
        qlGroup.SBQQ__Quote__c = TestQuote.id;
        insert qlGroup;
        
        //Quote Line Group for Quote 2
        SBQQ__QuoteLineGroup__c qlGroup2 = new SBQQ__QuoteLineGroup__c();
        qlGroup2.Name = 'Group 1';
        qlGroup2.SBQQ__Number__c = 10;
        qlGroup2.SBQQ__ListTotal__c = 10;
        qlGroup2.SBQQ__NetTotal__c = 100;
        qlGroup2.SBQQ__CustomerTotal__c = 1000;
        qlGroup2.SBQQ__Quote__c = TestQuote.id;
        insert qlGroup2;
        
        //Another Quote Line Group for Quote 1
        SBQQ__QuoteLineGroup__c qlGroup3 = new SBQQ__QuoteLineGroup__c();
        qlGroup3.Name = 'Group 2';
        qlGroup3.SBQQ__Number__c = 10;
        qlGroup3.SBQQ__ListTotal__c = 10;
        qlGroup3.SBQQ__NetTotal__c = 100;
        qlGroup3.SBQQ__CustomerTotal__c = 1000;
        qlGroup3.SBQQ__Quote__c = TestQuote.id;
        insert qlGroup3;
        
        cont.SBQQ__Quote__c = TestQuote.id;
        // cont.contractedAmendmentQuote__c = TestQuote2.id;
        cont.Multiple_Years_Commitment__c = true;
        update cont;
        
        Test.startTest();
        
        PageReference pageRef = Page.CventMyd_ContractAmendmentPage;
        //pageRef.getParameters().put('contractId', String.valueOf(cont.Id));
        ApexPages.currentPage().getParameters().put('contractIdString', String.valueOf(cont.Id));
        ApexPages.currentPage().getParameters().put('opportunityIdString', String.valueOf(opp.Id));
        ApexPages.currentPage().getParameters().put('quoteIdString', String.valueOf(TestQuote.Id));
        CventMyd_ContractAmendmentController controller = new CventMyd_ContractAmendmentController();
        CventMyd_ContractAmendmentController.AmendmentPageStatus contPage = new CventMyd_ContractAmendmentController.AmendmentPageStatus(ApexPages.currentPage().getParameters().get('quoteIdString'));
        
        TestQuote.Multiple_Years_Commitment__c = true;
        update TestQuote;
        
        CventMyd_ContractAmendmentController.AmendmentPageStatus.getAmendmentPageStatus(String.valueOf(TestQuote.Id),null,3);
        controller.clickAmendContract();
        CventMyd_ValidationHandler.settings.ruleNameToIsActive.put('Quote_Missing_Outyears',false);
        CventMyd_ValidationHandler.settings.ruleNameToIsActive.put('Quote_Dates_Validity',false);
        CventMyd_ContractAmendmentController.AmendmentPageStatus.amendOrCheckAmendmentStatus(true, String.valueOf(cont.Id), String.valueOf(opp.Id), String.valueOf(TestQuote.Id),null,100,5);
        
        //ADDED BY: NDeGuzman 7.3.18
        CventMyd_ContractAmendmentController.AmendmentPageStatus.amendContract(String.valueOf(cont.Id), String.valueOf(opp.Id));
        //END
        
        Test.stopTest();

    }

}