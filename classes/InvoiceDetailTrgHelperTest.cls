/**
///////////////////////////////
//    @author Hemant Singh Rana    //
///////////////////////////////
Test Class of invoiceDetailTrg/InvoiceDetailTrgHelper
Version 1.0
Date: 29th May 2016
Version 2.0
Date:
Description:
*/
@isTest
private class InvoiceDetailTrgHelperTest{
    static Invoicing_Details__c instOfInvoice;
    static Invoicing_Details__c insertInvoiceDetails(){
        instOfInvoice=new Invoicing_Details__c();
        instOfInvoice.Billing_POC__c=createContact();
        instOfInvoice.Opportunity__c=creatOpportunity();
        instOfInvoice.Payment_Mode__c='Test';
        instOfInvoice.Payment_Terms__c='Test';
        instOfInvoice.Invoice_Note_1__c='Test';
        instOfInvoice.Billed_to_Company_Name__c='Test';
        instOfInvoice.Invoice_Note_2__c='Test';
        instOfInvoice.Subject_Note__c='Test';
        instOfInvoice.Email_Note__c='Test';
        instOfInvoice.PO__c='Test';
        instOfInvoice.Notes__c='Test';
        insert instOfInvoice;
        return instOfInvoice;
    }

    static Id createAccount(){
        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        instofAcc.Country_Region__c='America';
        insert instofAcc;
        return instofAcc.id;
    }
    static Id createContact(){
        Contact instOfCon = TestUtil.createContact(String.valueOf(createAccount()));
        insert instOfCon;
        return instOfCon.Id;
    }
    static Id creatOpportunity(){
        Opportunity instOfOppFIF = TestUtil.createOpportunityNew('test','Verbal',createContact(),createAccount());
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppFIF.Contract_Type_Test__c = 'Renewal';
        instOfOppFIF.Forex_rate__c = 1;
        instOfOppFIF.Liquidation_Fee__c  = 10;
        instOfOppFIF.OptOutDate__c = system.today();
        instOfOppFIF.Opp_End_Date__c  = system.today();
        instOfOppFIF.Forex_rate__c = 1;
       // instOfOppFIF.Price_per_lead__c = 1;
        instOfOppFIF.Counted_sales_Cancellation_Value__c =110;
        instOfOppFIF.Product__c = 'Event';
        instOfOppFIF.Contract_Number_New__c = '12345';
        instOfOppFIF.New_Type__c =  'Upsell-NBB';
        instOfOppFIF.CloseDate = system.today();
       // instOfOppFIF.RecordTypeId = instOfRecType.Id;
        instOfOppFIF.Year_1_at_Risk__c = 11;
        instOfOppFIF.New_Type__c = 'Test';
        instOfOppFIF.Deal_Booked_In__c = '5';
      //  instOfOppFIF.Price_per_lead__c = 1; // comment by kumud field cleanup activity
        instOfOppFIF.Years__c= '1';
        instOfOppFIF.LeadSource = 'ACD-PS';
        //instOfOppFIF.Contact_Associated__c = instOfCon.Id;
        //instOfOppFIF.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppFIF.Contract_Implemented__c = false;
        instOfOppFIF.ContractReceived__c = system.today();
        instOfOppFIF.Deal_Year__c = '4';
        instOfOppFIF.MaintenanceFee__c = 1000;
        instOfOppFIF.New_Amount__c = 1000;
       // instOfOppFIF.Discount__c = 1000;
        instOfOppFIF.Convinience_Fee__c = 1000;
        instOfOppFIF.of_Leads_Purchased__c = 1000;
        //instOfOppFIF.Events__c = 1000; // Comment by kumud [Field cleanuo activity]
        instOfOppFIF.Price_Adjustment__c = 1000;
        instOfOppFIF.MYD_Deal__c = 'First Year';
        instOfOppFIF.Parent_Upsell__c = 'Primary';
        instOfOppFIF.License_Type__c='1/2 Diamond';
        instOfOppFIF.NBB_Renewal__c='NBB';
        instOfOppFIF.ATI_Check__c =true;
        instOfOppFIF.ContractEndDate__c=system.today().addDays(30);
        instOfOppFIF.ContractStartDate__c=system.today();
        insert instOfOppFIF;
        return instOfOppFIF.Id;
    }
    static testMethod void unitTest1(){
        test.startTest();
        insertInvoiceDetails();
        instOfInvoice.Payment_Mode__c='Test 1';
        update instOfInvoice;
        delete instOfInvoice;
        undelete instOfInvoice;
        test.stopTest();
    }
}