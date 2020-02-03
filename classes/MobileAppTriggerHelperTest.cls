@isTest(SeeAllData = TRUE)
public class MobileAppTriggerHelperTest{
    
    static testmethod void testPendingCompletionPost(){
    
    List<Product2> listOFProduct =new List<Product2>();
List<PricebookEntry> listOfPBE=new List<PricebookEntry>();



              Account instofAcc=TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.CSN_Status__c ='Using';
        instofAcc.Supplier_Status__c='Approved';
         instofAcc.BillingCountryCode='US';
        instOfAcc.BillingState='TX';
 
        insert instofAcc;
        
        Contact instofCon=TestUtil.createContact(instofAcc.id);
        insert instofCon;
        
        listOFProduct =TestUtil.createProducts(new List<String>{'CVENT Attendee Support','Cvent Creative Services'});
        listOFProduct[0].productcode='CV-AD-HC-CSN-1PPMP';
        listOFProduct[1].productcode='CV-EP-EC-EVT-CVTPYTSER';
        insert listOFProduct;
        PricebookEntry instPBE= TestUtil.createPricebookEntry(listOFProduct[0],100);
        listOfPBE.add(instPBE);
        PricebookEntry  instPBE1= TestUtil.createPricebookEntry(listOFProduct[1],100);
        listOfPBE.add(instPBE1);
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
        
        Address__c bAddress = new Address__c();
        bAddress.Type__c = 'Billing';
        bAddress.Account__c = instofAcc.Id;
        bAddress.City__c='Burnaby';
        bAddress.Province__c='BC';
        bAddress.Country__c='US';
        bAddress.CountryCode__c='US';
        bAddress.Postal_Code__c = '1001';
        bAddress.EBS_Site_Use_Id__c=null;
        insert bAddress;
        
        Opportunity instOpp=TestUtil.createOpportunity('Test Opp','Event','Qualified');
            instOpp.StageName ='Qualified';
            instOpp.Deal_Year__c ='1';
            instOpp.NBB_Renewal__c = 'NBB';
            instOpp.Parent_Upsell__c = 'Primary';
            instOpp.CloseDate = system.today().addmonths(12);
            instOpp.Web_Design_Support_Minutes_Purchased__c =0;
            //instOpp.Contract_Implemented__c = true;
            instOpp.ContractReceived__c = system.today();
            instOpp.Product__c ='TicketMob';
            instOpp.MYD_Deal__c='First Year';
            instOpp.pricebook2id=Test.getStandardPricebookID();
            instOpp.Contact_Associated__c=instofCon.id; 
            insert instOpp;
            
            List<Opportunity> listOfOpp=new List<Opportunity>{instOpp};
            List<OpportunityLineItem> listOlitem = new List<OpportunityLineItem>();
            
            OpportunityLineItem instOfOlitem=new OpportunityLineItem();
            instOfOlitem.OpportunityID = instOpp.Id;
            instOfOlitem.PriceBookEntryID=listOfPBE[0].Id;
            instOfOlitem.Product__c = 'CVENT Attendee Support';
            instOfOlitem.quantity=4;
            instOfOlitem.totalprice=200;
            
            listOlitem.add(instOfOlitem);
            
             instOfOlitem=new OpportunityLineItem();
            instOfOlitem.OpportunityID = instOpp.Id;
            instOfOlitem.PriceBookEntryID=listOfPBE[1].Id;
            instOfOlitem.Product__c = 'Cvent Creative Services';
            instOfOlitem.quantity=4;
            instOfOlitem.totalprice=200;
            
            listOlitem.add(instOfOlitem);
            
            insert listOlitem;
            
          Id mcRecordTypeId = Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByName().get('CrowdCompass').getRecordTypeId();
             
            Mobile_Card__c mobileCard1 = new Mobile_Card__c();
        mobileCard1.Name = 'Test Mobile App 2';
        mobileCard1.Primary_Contact__c = instofCon.Id;
        mobileCard1.Opportunity__c= instOpp.Id;
        mobileCard1.Survey_Invitation_Sent__c = system.today();
        mobileCard1.Oversold__c = true;
                mobileCard1.RecordTypeId = mcRecordTypeId;
                mobileCard1.Contract_Account_New__c=                 instofAcc.Id;
        insert mobileCard1;
            
    }
}