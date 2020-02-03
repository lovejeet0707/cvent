@isTest
public class OpportunityAuditTest{
    static testmethod void  unitTest(){
        
        Id ParentRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();
        
        Account instofAcc=TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.CSN_Status__c ='Using';
        instofAcc.Supplier_Status__c='Approved';
        insert instofAcc;
        
        Contact instofCon=TestUtil.createContact(instofAcc.id);
        insert instofCon;
        
        List<Product2> listOFProduct =new List<Product2>();
        List<PricebookEntry> listOfPBE=new List<PricebookEntry>();


        listOFProduct =TestUtil.createProducts(new List<String>{'CVENT Attendee Support','Cvent Creative Services','App Build Plus'});
        listOFProduct[0].productcode='CV-AD-HC-CSN-1PPMP';
        listOFProduct[1].productcode='CV-EP-EC-EVT-CVTPYTSER';
        listOFProduct[2].productcode='CV-PS-EC-CCS-APPBPLS';
        insert listOFProduct;
        PricebookEntry instPBE= TestUtil.createPricebookEntry(listOFProduct[0],100);
        listOfPBE.add(instPBE);
        PricebookEntry  instPBE1= TestUtil.createPricebookEntry(listOFProduct[1],100);
        listOfPBE.add(instPBE1);
        PricebookEntry  instPBE2= TestUtil.createPricebookEntry(listOFProduct[2],100);
        listOfPBE.add(instPBE2);
        insert listOfPBE;
        
         Address__c sAddress = new Address__c();
            sAddress.Type__c = 'Shipping';
            sAddress.Account__c = instofAcc.Id;
            saddress.City__c='Burnaby';
            saddress.Province__c='BC';
            saddress.Country__c='US';
            saddress.CountryCode__c='US';
            saddress.Postal_Code__c = '1001';
            saddress.EBS_Site_Use_Id__c=null;
            insert sAddress;
        
        Address__c billAddr = new Address__c();
         billAddr.Account__c = instofAcc.Id;   
         billAddr.State__c = 'NY';
         billAddr.Country__c = 'US';
         billAddr.Type__c = 'Billing';
         billAddr.CountryCode__c = 'US';
        
        insert billAddr;
        
        Opportunity instOpp1=TestUtil.createOpportunity('Test Opp','Event','Qualified');
        instOpp1.Deal_Year__c ='1';
        instOpp1.AccountId = instofAcc.Id;
        instOpp1.MSA_Code__c = null;
        instOpp1.NBB_Renewal__c = 'NBB';
        instOpp1.Parent_Upsell__c = 'Primary';
        instOpp1.CloseDate = system.today().addmonths(12);
        instOpp1.Web_Design_Support_Minutes_Purchased__c =0;
        instOpp1.Contract_Implemented__c = true;
        instOpp1.ContractReceived__c = system.today();
        instOpp1.Product__c ='TicketMob';
        instOpp1.MYD_Deal__c='First Year';
        instOpp1.pricebook2id=Test.getStandardPricebookID();
        instOpp1.Contact_Associated__c=instofCon.id; 
        instOpp1.Net_Amount_Opp__c = 100;
        instOpp1.Bill_To_Address__c = billAddr.id;
        instOpp1.Ship_To_Address__c = sAddress.Id;
        insert instOpp1;
        
        Opportunity instOpp=TestUtil.createOpportunity('Test Opp','Event','Qualified');
        instOpp.Deal_Year__c ='1';
        instOpp.AccountId = instofAcc.Id;
        instOpp.MSA_Code__c = null;
        instOpp.NBB_Renewal__c = 'NBB';
        instOpp.Parent_Upsell__c = 'Primary';
        instOpp.CloseDate = system.today().addmonths(12);
        instOpp.Web_Design_Support_Minutes_Purchased__c =0;
        instOpp.Contract_Implemented__c = true;
        instOpp.ContractReceived__c = system.today();
        instOpp.Product__c ='TicketMob';
        instOpp.MYD_Deal__c='First Year';
        instOpp.pricebook2id=Test.getStandardPricebookID();
        instOpp.Contact_Associated__c=instofCon.id; 
        instOpp.Net_Amount_Opp__c = 100;
        instOpp.Bill_To_Address__c = billAddr.id;
        instOpp.Ship_To_Address__c = sAddress.Id;
        insert instOpp;
            
         //Insert Quote
        SBQQ__Quote__c TestQuote = new SBQQ__Quote__c();
        TestQuote.SBQQ__Opportunity2__c = instOpp.id;
        TestQuote.Contract_Term_Years__c = '2';
        TestQuote.SBQQ__Type__c = 'Renewal';
        TestQuote.Current_Year__c = 1;
        TestQuote.Contract_Executed__c = true;
        TestQuote.SBQQ__StartDate__c = Date.today().addDays(-5);
        TestQuote.SBQQ__EndDate__c = Date.today().addYears(1);
        TestQuote.createdFromLegacyContract__c = true;
        TestQuote.Multiple_Years_Commitment__c = true;
        insert TestQuote;
        
        //Quote Line Group
        SBQQ__QuoteLineGroup__c qlGroup = new SBQQ__QuoteLineGroup__c();
        qlGroup.Name = 'Group 1';
        qlGroup.SBQQ__Number__c = 10;
        qlGroup.SBQQ__ListTotal__c = 10;
        qlGroup.SBQQ__NetTotal__c = 100;
        qlGroup.SBQQ__CustomerTotal__c = 1000;
        qlGroup.SBQQ__Quote__c = TestQuote.id;
        insert qlGroup;
        
        //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c
        Contract ParentCont = new Contract();
        ParentCont.AccountId = instofAcc.id;
        ParentCont.Contract_Term_Years__c = '2';
        ParentCont.RecordTypeId = ParentRecordTypeId;
        ParentCont.SBQQ__Opportunity__c = instOpp.id;
        ParentCont.Current_Year__c = 1;
        ParentCont.Year_2_End_Date__c = Date.today().addYears(1);
        ParentCont.EndDate = Date.today().addYears(1);
        insert ParentCont;
        
        //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c
        Contract ParentCont1 = new Contract();
        ParentCont1.AccountId = instofAcc.id;
        ParentCont1.Contract_Term_Years__c = '1';
        ParentCont1.RecordTypeId = ParentRecordTypeId;
        ParentCont1.SBQQ__Opportunity__c = instOpp.id;
        ParentCont1.Current_Year__c = 1;
        ParentCont1.Year_2_End_Date__c = Date.today().addYears(1);
        ParentCont1.EndDate = Date.today().addYears(1);
        insert ParentCont1;
        
        Contract ChildCont = new Contract();
        ChildCont.AccountId = instofAcc.id;
        ChildCont.Contract_Term_Years__c = ParentCont.Contract_Term_Years__c;
        ChildCont.RecordTypeId = ChildRecordTypeId;
        ChildCont.Parent_Contract__c = ParentCont.Id;
        ChildCont.SBQQ__Opportunity__c = instOpp.id;
        ChildCont.Current_Year__c = 1;
        ChildCont.Year_2_End_Date__c = ParentCont.Year_2_End_Date__c;
        ChildCont.EndDate = ParentCont.EndDate;
        insert ChildCont;
        
        Contract ChildCont1 = new Contract();
        ChildCont1.AccountId = instofAcc.id;
        ChildCont1.Contract_Term_Years__c = ParentCont1.Contract_Term_Years__c;
        ChildCont1.RecordTypeId = ChildRecordTypeId;
        ChildCont1.Parent_Contract__c = ParentCont1.Id;
        ChildCont1.SBQQ__Opportunity__c = instOpp.id;
        ChildCont1.Current_Year__c = 1;
        ChildCont1.Year_2_End_Date__c = ParentCont.Year_2_End_Date__c;
        ChildCont1.EndDate = ParentCont.EndDate;
        insert ChildCont1;
        
        //Product
        Product2 product0 = new Product2();
        product0.Name = 'Product 0';
        product0.Contract_Output_Grouping__c = 'Bundle Advertisements';
        insert product0;

        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        insert product1;        
        
        //Insert Subscription
        SBQQ__Subscription__c parentSub = new SBQQ__Subscription__c();
        parentSub.SBQQ__Product__c = product0.id;
        parentSub.SBQQ__Account__c = instofAcc.id;
        parentSub.SBQQ__Contract__c = ParentCont1.id;
        parentSub.SBQQ__Quantity__c = 1;
        parentSub.SBQQ__SubscriptionStartDate__c = Date.today().addDays(-5);
        insert parentSub;
        
        //Insert Subscription
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Product__c = product1.id;
        sub.SBQQ__Account__c = instofAcc.id;
        sub.SBQQ__Contract__c = ChildCont.id;
        sub.SBQQ__Quantity__c = 1;
        sub.SBQQ__SubscriptionStartDate__c = Date.today().addDays(-5);
        insert sub;
        
        //Insert Subscription
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c();
        sub1.SBQQ__Product__c = product1.id;
        sub1.SBQQ__Account__c = instofAcc.id;
        sub1.SBQQ__Contract__c = ChildCont.id;
        sub1.SBQQ__Quantity__c = 1;
        sub1.SBQQ__SubscriptionStartDate__c = Date.today().addDays(-5);
        sub1.SBQQ__RequiredById__c = String.valueOf(sub.Id);
        sub1.SBQQ__TerminatedDate__c = ChildCont.EndDate;
        sub1.SBQQ__RenewalQuantity__c = 0;
        insert sub1;
        
        //Insert Quote Line
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c();
        testQuoteLine.SBQQ__Quantity__c = 1;
        testQuoteLine.SBQQ__Product__c = product0.Id;
        testQuoteLine.SBQQ__ListPrice__c = 10;
        testQuoteLine.SBQQ__NetPrice__c = 10;
        testQuoteLine.Rack_Rate__c = 10;
        testQuoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        testQuoteLine.SBQQ__Number__c = 1;
        testQuoteLine.SBQQ__Group__c = qlGroup.id;
        testQuoteLine.SBQQ__Quote__c = TestQuote.Id;
        testQuoteLine.Notes__c = 'abc';
        testQuoteLine.SBQQ__UpgradedSubscription__c = sub.id;
        testQuoteLine.jsonString__c = '{"deleteThisLine": true,"startDate":"2018-04-17","settings":{"preCalculationFieldNames":["SBQQ__Quantity__c","SBQQ__Discount__c","Custom_Discount__c","Discount_Type__c","SBQQ__AdditionalDiscount__c","Rate__c","Zone_Level__c","Number_of_Guest_Rooms__c","Lanyon_Chain_Affiliation__c","Chain_Affiliation__c","Setup_Days__c","Travel_Days__c","Event_Start_Date__c","Event_End_Date__c","Attendees__c","OnArrival_360_Event_Selection__c"],"calculatedFieldNames":["SBQQ__OriginalPrice__c","SBQQ__ListPrice__c","SBQQ__RegularPrice__c","SBQQ__NetPrice__c","Rack_Rate__c"],"msAtLastUpdate":1525180814312},"outyearMap":{"2":{"year":2,"startDate":"2019-04-17","endDate":"2020-04-16"},"3":{"year":3,"startDate":"2020-04-17","endDate":"2021-04-16"},"4":{"year":4,"startDate":"2021-04-17","endDate":"2022-04-16"},"5":{"year":5,"startDate":"2022-04-17","endDate":"2023-04-16"}},"isManuallyCreatedFirstYear":null,"endDate":"2019-04-16","automationStage":{"renewalStage":null,"codeStatus":"CALCULATION_CYCLE_FINISHED"}}';
        insert testQuoteLine;
        
        //Insert Quote Line
        SBQQ__QuoteLine__c testQuoteLine1 = new SBQQ__QuoteLine__c();
        testQuoteLine1.SBQQ__Quantity__c = 1;
        testQuoteLine1.SBQQ__Product__c = product1.Id;
        testQuoteLine1.SBQQ__ListPrice__c = 10;
        testQuoteLine1.SBQQ__NetPrice__c = 10;
        testQuoteLine1.Rack_Rate__c = 10;
        testQuoteLine1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        testQuoteLine1.SBQQ__Number__c = 1;
        testQuoteLine1.SBQQ__Group__c = qlGroup.id;
        testQuoteLine1.SBQQ__Quote__c = TestQuote.Id;
        testQuoteLine1.Notes__c = 'abc';
        testQuoteLine1.SBQQ__UpgradedSubscription__c = sub1.id;
        testQuoteLine1.jsonString__c = '{"deleteThisLine": true}';
        testQuoteLine1.SBQQ__RequiredBy__c = String.valueOf(testQuoteLine.Id);
        testQuoteLine1.SBQQ__Number__c = 2;

        SBQQ.TriggerControl.disable();

        insert testQuoteLine1;       

        SBQQ.TriggerControl.enable();
        
        
            
        /*OpportunitySplit ost1 = new OpportunitySplit();  
        ost1.OpportunityId=instOpp.id;  
        ost1.SplitOwnerId = Userinfo.getUserId();
        insert ost1;*/
        
        
        Database.executeBatch(new OpportunityAudit());
    }
}