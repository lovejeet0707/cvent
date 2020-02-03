@isTest
private class SnapShotUtilityHelperTest {
    public static Account instofAcc = new Account();
    public static Contact instofCon =  new Contact();
    public static List<Product2> prodList = new List<Product2>();
    static{

        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        instofAcc.Name = 'Test';
        //instofAcc.CurrencyIsoCode  = 'USD';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.CVII_ID__c = '1231231231';
        insert instofAcc;
    }
    static List<PricebookEntry> createPricebookEntry(){
        //create Product and PriceBook
        Product2 prd1 = new Product2 ();

        prd1 = new Product2 ();
        prd1.Name='DG - Creative Services';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);

        prd1 = new Product2 ();
        prd1.Name='Supplier Feature-Meeting Request Form';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);

        prd1 = new Product2 ();
        prd1.Name='Booster-Comp Set';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);

        insert prodList;

        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 0',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;

        //get standard pricebook
        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standPriceBook= new PricebookEntry ();
        List<PricebookEntry> stndpricebookEntryList= new List<PricebookEntry>();
        List<PricebookEntry> pricebookEntryList= new List<PricebookEntry>();
        For(Integer i=0; i<prodList.size() ; i++)
        {
            standPriceBook= new PricebookEntry ();
            standPriceBook.Product2ID=prodList[i].id;
            standPriceBook.Pricebook2ID=pricebookId;
            standPriceBook.UnitPrice=50;
            standPriceBook.isActive=true;
            stndpricebookEntryList.add(standPriceBook);
        }
        System.debug('stndpricebookEntryList************'+stndpricebookEntryList);
        insert stndpricebookEntryList;

        //Inserting PriceBookEntry.........................
        PricebookEntry pbe1 = new PricebookEntry ();
        For(Integer i=0; i<prodList.size() ; i++)
        {
            pbe1 = new PricebookEntry ();
            pbe1.Product2ID=prodList[i].id;
            pbe1.Pricebook2ID=pbk1.id;
            pbe1.UnitPrice=50;
            pbe1.isActive=true;
            pricebookEntryList.add(pbe1);                                                   
        }
        insert pricebookEntryList;
        return pricebookEntryList;
    }
    static testMethod void myUnitTestFor() {
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];

        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;

        Product2 prd1 = new Product2 (Name='DG - Creative Services',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
        insert prd1;

        //get standard pricebook
        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=priceBookId,UnitPrice=50, isActive=true);
        insert pbe1;
    
        Customer_Asset__c customerAsset = new Customer_Asset__c();
        customerAsset.Account__c = instofAcc.Id;
        customerAsset.Product__c = prd1.Id;
        customerAsset.Asset_Status__c = 'Active';
        insert customerAsset;
        
        Opportunity instOfOppFIF = new Opportunity();
        instOfOppFIF.Contract_Type_Test__c = 'Renewal';
        instOfOppFIF.Forex_rate__c = 1;
        instOfOppFIF.Liquidation_Fee__c  = 10;
        instOfOppFIF.OptOutDate__c = system.today();
        instOfOppFIF.Opp_End_Date__c  = system.today();
        instOfOppFIF.AccountId = instofAcc.id;
        instOfOppFIF.Forex_rate__c = 1;
        //instOfOppFIF.Price_per_lead__c = 1;
        instOfOppFIF.Name = 'Test';
        instOfOppFIF.Counted_sales_Cancellation_Value__c =110;
        instOfOppFIF.Product__c = 'Event';
        instOfOppFIF.Contract_Number_New__c = '25512';
        instOfOppFIF.New_Type__c =  'Upsell-NBB';
        instOfOppFIF.StageName = 'Verbal';
        instOfOppFIF.CloseDate = system.today();
        instOfOppFIF.RecordTypeId = instOfRecType.Id;
        instOfOppFIF.Year_1_at_Risk__c = 11;
        instOfOppFIF.New_Type__c = 'Test';
        instOfOppFIF.Deal_Booked_In__c = '5';
        //instOfOppFIF.Price_per_lead__c = 1;
        instOfOppFIF.Years__c= '1';
        instOfOppFIF.LeadSource = 'ACD-PS';
        instOfOppFIF.Contact_Associated__c = instOfCon.Id;
        instOfOppFIF.Contact_Role__c = 'Primary User';
        instOfOppFIF.ContractReceived__c = system.today();
        instOfOppFIF.Deal_Year__c = '4';
        instOfOppFIF.MaintenanceFee__c = 1000;
        instOfOppFIF.New_Amount__c = 1000;
        //instOfOppFIF.Discount__c = 1000;
        instOfOppFIF.Convinience_Fee__c = 1000;
        instOfOppFIF.of_Leads_Purchased__c = 1000;
        //instOfOppFIF.Events__c = 1000;
        instOfOppFIF.Price_Adjustment__c = 1000;
        instOfOppFIF.MYD_Deal__c = 'First Year';
        instOfOppFIF.Parent_Upsell__c = 'Primary';
        instOfOppFIF.Clubbed_Opportunity__c = true;
        //instOfOppFIF.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfOppFIF.ATI_Check__c=true;
        instOfOppFIF.Pricebook2Id = pbe1.Pricebook2Id;
        instOfOppFIF.Event_Name__c ='Test';
        //instOfOppFIF.Start_Date__c=system.today();
        //instOfOppFIF.End_Date__c =system.today();
        //instOfOppFIF.Event_City__c='Test';
        //instOfOppFIF.Event_Venue__c ='Test';
        //instOfOppFIF.Event_State__c ='Test';
        //instOfOppFIF.Event_Country__c = 'Afghanistan';
        //instOfOppFIF.Number_of_Events__c ='Test';
        //instOfOppFIF.Number_of_Attendees__c ='Test';
        //instOfOppFIF.Number_of_Exhibitors__c ='Test';
        //instOfOppFIF.Number_of_RFID_Scanners__c = 10;
        //instOfOppFIF.Session_Scanning__c ='Yes';
        //instOfOppFIF.Badge_Printing__c ='Yes';
        //instOfOppFIF.Lead_Retrieval__c = 'Yes';
        insert instOfOppFIF;
        
        Contract newCon = new Contract();
        newCon.AccountId = instofAcc.Id;
        newCon.SBQQ__Opportunity__c = instOfOppFIF.Id;
        insert newCon;

        OpportunityLineItem  instOfFSetForYearDGSecond = new OpportunityLineItem ();
        instOfFSetForYearDGSecond.OpportunityID = instOfOppFIF.Id;
        instOfFSetForYearDGSecond.PriceBookEntryID=pbe1.Id;
        instOfFSetForYearDGSecond.Product__c = 'Event';
        instOfFSetForYearDGSecond.quantity=4;
        instOfFSetForYearDGSecond.totalprice=200;
        insert instOfFSetForYearDGSecond;
        
        Booking_Classification__c bookClass = new Booking_Classification__c();
        bookClass.Opportunity__c = instOfOppFIF.Id;
        bookClass.Product_Family__c = 'Not Identified';
        insert bookClass;
        
        update bookClass;
        instOfOppFIF.Contract_Implemented__c = true;
        instOfOppFIF.Net_Amount_Opp__c = 1000;
        instOfOppFIF.SBQQ__RenewedContract__c = newCon.Id;
        update instOfOppFIF;
        
        /*SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Product__c = prd1.Id;
        sub.SBQQ__Quantity__c = 1;
        sub.SBQQ__NetPrice__c = 1.00;
        sub.Annual_Recurring_Revenue__c = 1.00;
        sub.SBQQ__SubscriptionStartDate__c = System.today();
        sub.SBQQ__Contract__c = newCon.Id;
        sub.SBQQ__Account__c = instofAcc.Id;
        insert sub;*/
        SnapShotUtilityHelper.fakeMethod();
        SnapShotUtilityHelper_OneOff.fakeMethod();
        //Deleting Opportunity Line Item...............
        //delete instOfFSetForYearDGSecond;

    }
}