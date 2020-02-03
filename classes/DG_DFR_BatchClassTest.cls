/**
//////////////////////////////////////
//      @author Hemant Rana     //
/////////////////////////////////////
Version :   1.0
Date : 29th March 2017
 */

@isTest
//(seeAllData = True)

private class DG_DFR_BatchClassTest {
    public static Account instofAcc;
    public static Contact instofCon;
    static{
        instofAcc  = TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        insert instofAcc;
        
        instofCon = TestUtil.createContact(String.valueOf(instofAcc.Id));
        insert instOfCon;
    }
    static List<PricebookEntry> createPricebookEntry(){
        //create Product and PriceBook
        List<Product2> prodList= new List<Product2>();

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

        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;

        //get standard pricebook
        Id pricebookId = Test.getStandardPricebookId();
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];

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
        System.debug('pricebookEntryList************'+pricebookEntryList);
        return pricebookEntryList;
    }
    static testMethod void test()
    {
        List<Product2> prodList= new List<Product2>();

        Product2 prd1 = new Product2 ();

        prd1 = new Product2 ();
        prd1.Name='DG - Creative Services';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);
        
        insert prodList;
        
        List<PricebookEntry> pbE = new List<PricebookEntry>();
        
        PricebookEntry standPriceBook= new PricebookEntry ();
        standPriceBook.Product2ID=prodList[0].id;
        standPriceBook.Pricebook2ID=Test.getStandardPricebookId();
        standPriceBook.UnitPrice=50;
        standPriceBook.isActive=true;
        pbE.add(standPriceBook);
        
        insert pbE;
        
        List<Opportunity> instOfOppList = new List<Opportunity>();
        
        Opportunity instOfOpp = TestUtil.createOpportunityNew('test','Verbal',instOfCon.Id,instofAcc.Id);
        instOfOpp.Product__c = 'Event';
        instOfOpp.New_Type__c =  'Upsell-NBB';
        instOfOpp.New_Amount__c = 11;
        instOfOpp.Years__c= '1';
        instOfOpp.License_Type__c = 'Cvent Connect';
        instOfOpp.LeadSource = 'ACD-PS';
        instOfOpp.Contract_Implemented__c = true;
        instOfOpp.ContractReceived__c = system.today();
        instOfOpp.Deal_Year__c = '1';
         //instOfOpp.Pricebook2Id = pbE[0].Pricebook2Id;
        instOfOpp.Pricebook2Id =Test.getStandardPricebookId();
        insert instOfOpp;
        /*instOfOppList.add(instOfOpp);
        
        instOfOpp = new Opportunity();
        instOfOpp.AccountId = instofAcc.id;
        instOfOpp.Name = 'Test';
        instOfOpp.Product__c = 'Event';
        instOfOpp.New_Type__c =  'Upsell-NBB';
        instOfOpp.StageName = 'Closed Lost';
        instOfOpp.CloseDate = system.today();
        instOfOpp.New_Amount__c = 11;
        instOfOpp.Years__c= '1';
        instOfOpp.License_Type__c = 'Cvent Connect';
        instOfOpp.LeadSource = 'ACD-PS';
        instOfOpp.Contact_Associated__c = instOfCon.Id;
        instOfOpp.Contact_Role__c = 'Primary User';
        instOfOpp.Contract_Implemented__c = true;
        instOfOpp.ContractReceived__c = system.today();
        instOfOpp.Deal_Year__c = '1';
        instOfOpp.Pricebook2Id = pbE[0].Pricebook2Id;
        instOfOppList.add(instOfOpp);
        
        instOfOpp = new Opportunity();
        instOfOpp.AccountId = instofAcc.id;
        instOfOpp.Name = 'Test';
        instOfOpp.Product__c = 'Event';
        instOfOpp.New_Type__c =  'Upsell-NBB';
        instOfOpp.StageName = 'Verbal';
        instOfOpp.CloseDate = system.today();
        instOfOpp.New_Amount__c = 11;
        instOfOpp.Years__c= '1';
        instOfOpp.License_Type__c = 'Cvent Connect';
        instOfOpp.LeadSource = 'ACD-PS';
        instOfOpp.Contact_Associated__c = instOfCon.Id;
        instOfOpp.Contact_Role__c = 'Primary User';
        instOfOpp.Contract_Implemented__c = true;
        instOfOpp.ContractReceived__c = system.today();
        instOfOpp.Deal_Year__c = '1';
        instOfOpp.Pricebook2Id = pbE[0].Pricebook2Id;
        instOfOppList.add(instOfOpp);
                
        insert instOfOppList;*/
        
        List<OpportunityLineItem> lstOppLineItem = new List<OpportunityLineItem>();
        
        OpportunityLineItem instOfOppLineItem = new OpportunityLineItem();
        instOfOppLineItem.OpportunityID = instOfOpp.Id;
        instOfOppLineItem.PriceBookEntryID=pbE[0].Id;
        instOfOppLineItem.quantity=4;
        instOfOppLineItem.totalprice=200;
        insert instOfOppLineItem;
        /*lstOppLineItem.add(instOfOppLineItem);
        
        instOfOppLineItem = new OpportunityLineItem();
        instOfOppLineItem.OpportunityID = instOfOppList[1].Id;
        instOfOppLineItem.PriceBookEntryID=pbE[0].Id;
        instOfOppLineItem.quantity=4;
        instOfOppLineItem.totalprice=200;
        lstOppLineItem.add(instOfOppLineItem);
        
        instOfOppLineItem = new OpportunityLineItem();
        instOfOppLineItem.OpportunityID = instOfOppList[2].Id;
        instOfOppLineItem.PriceBookEntryID=pbE[0].Id;
        instOfOppLineItem.quantity=4;
        instOfOppLineItem.totalprice=200;
        lstOppLineItem.add(instOfOppLineItem);
        
        insert lstOppLineItem;
        System.debug('instOfOppList*********************'+instOfOppList);*/
        
        //DG_DFR_BatchClass sh1 = new DG_DFR_BatchClass();
        //String sch = '0 0 23 * * ?'; 
        //System.Schedule('DG DFR Batch Class', sch, sh1); 
        //Test.stopTest();
        Id batchid = Database.executeBatch(new DG_DFR_BatchClass());
        //instOfOpp.MSA_Code__c = lstMPB_New[0].MSA_Code__c;
        //update instOfOpp;
        //Delete instOfOpp;
        //Database.undelete(instOfOpp.Id);
    }
}