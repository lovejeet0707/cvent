@isTest
public class ApprovalTriggerHandlerTest {
    @testSetup static void testRecords(){
        Account objAccount = CventMYDDataFactory.createAccounts(1);
        insert objAccount;
        
        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
        insert objContact;
        
        Id addressRecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Address').getRecordTypeId();
        List<Address__c> addresses = new List<Address__c>();
        Address__c newAddress = new Address__c(Type__c = 'Billing', Account__c = objAccount.Id, Address__c = '720 South Michigan Avenue', City__c = 'Chicago',
                                              Postal_Code__c = '60605', Country__c = 'US', State__c = 'IL', RecordTypeId = addressRecordTypeId);
        addresses.add(newAddress);
        newAddress = new Address__c(Type__c = 'Shipping', Account__c = objAccount.Id, Address__c = '720 South Michigan Avenue', City__c = 'Chicago',
                                              Postal_Code__c = '60605', Country__c = 'US', State__c = 'IL', RecordTypeId = addressRecordTypeId);
        addresses.add(newAddress);
        insert addresses;
        
        Opportunity objOpport = CventMYDDataFactory.createOpportunities(1,objAccount.Id,objContact.Id);
        objOpport.ContractReceived__c = System.today();
        objOpport.Bill_To_Address__c = addresses[0].Id;
        objOpport.Ship_To_Address__c = addresses[1].Id;
        insert objOpport;
        
        Opportunity objOpport2 = CventMYDDataFactory.createOpportunities(1,objAccount.Id,objContact.Id);
        objOpport2.ContractReceived__c = System.today();
        objOpport2.Bill_To_Address__c = addresses[0].Id;
        objOpport2.Ship_To_Address__c = addresses[1].Id;
        insert objOpport2;
        
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
        
        List<SBQQ__Quote__c> objQuoteList = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c objQuote = CventMYDDataFactory.createQuote(objAccount.Id,objOpport.Id,true);
        objQuote.jsonString__c = JSON.serialize(getTestQuoteObject());
        objQuoteList.add(objQuote);
        objQuote = new SBQQ__Quote__c();
        objQuote = CventMYDDataFactory.createQuote(objAccount.Id,objOpport2.Id,true);
        objQuote.jsonString__c = JSON.serialize(getTestQuoteObject());
        objQuoteList.add(objQuote);
        insert objQuoteList;       
        
        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuoteList[0],lstProducts[0].Id,500));
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuoteList[0],lstProducts[0].Id,null));
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuoteList[1],lstProducts[0].Id,500));
        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuoteList[1],lstProducts[0].Id,null));
        insert lstQuoteLines;
        
        List<sbaa__Approver__c> approverList = new List<sbaa__Approver__c>();
        approverList.add(new sbaa__Approver__c(Name = u1.Name,sbaa__User__c = u1.Id));
        approverList.add(new sbaa__Approver__c(Name = u2.Name,sbaa__User__c = u2.Id));
        insert approverList;
    }
    
    @isTest static void submitApproval(){
        List<SBQQ__Quote__c> lstQuote = [SELECT Id, SBQQ__Opportunity2__c, SBQQ__Account__c, (SELECT Id, SBQQ__ProductName__c, SBQQ__Quantity__c FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c LIMIT 1];
        List<sbaa__Approver__c> lstApprover = [SELECT Id FROM sbaa__Approver__c LIMIT 1];
        
        sbaa__ApprovalRule__c newApprovalRule = new sbaa__ApprovalRule__c(sbaa__TargetObject__c = 'SBQQ__Quote__c', sbaa__ConditionsMet__c = 'All', sbaa__ApproverField__c = 'CPQ_Approval_Manager__c');
        insert newApprovalRule;
        
        sbaa__Approval__c newApproval = new sbaa__Approval__c();
        newApproval.Quote__c = lstQuote[0].Id;
        newApproval.sbaa__Opportunity__c = lstQuote[0].SBQQ__Opportunity2__c;
        newApproval.Account__c = lstQuote[0].SBQQ__Account__c;
        newApproval.sbaa__Approver__c = lstApprover[0].Id;
        newApproval.sbaa__Status__c = 'Requested';
        newApproval.sbaa__ApprovalStep__c = 1;
        newApproval.sbaa__RecordField__c = 'Quote__c';
        newApproval.sbaa__Rule__c = newApprovalRule.Id;
        
        Test.startTest();
        
        insert newApproval;
        
        newApproval.sbaa__Status__c = 'Approved';
        
        update newApproval;
        
        SBQQ__QuoteLine__c ql = lstQuote[0].SBQQ__LineItems__r[0];
        ql.SBQQ__Quantity__c = 2;
        update ql;
        
        sbaa__Approval__c newApprovalClone = new sbaa__Approval__c();
        newApprovalClone = newApproval.clone(false, false, false, false);
        newApprovalClone.Quote__c = lstQuote[0].Id;
        insert newApprovalClone;
        
        Test.stopTest();
        
        //sbaa__Approval__c updatedApproval = [SELECT Id, Approval_Response_Date__c FROM sbaa__Approval__c WHERE Id = :newApproval.Id ];
        
        //System.assertEquals(date.today(), updatedApproval.Approval_Response_Date__c.date());
    }
    
    @isTest static void approvedApproval(){
        List<SBQQ__Quote__c> lstQuote = [SELECT Id, SBQQ__Opportunity2__c, SBQQ__Account__c FROM SBQQ__Quote__c LIMIT 1];
        List<sbaa__Approver__c> lstApprover = [SELECT Id FROM sbaa__Approver__c LIMIT 1];
        
        sbaa__ApprovalRule__c newApprovalRule = new sbaa__ApprovalRule__c(sbaa__TargetObject__c = 'SBQQ__Quote__c', 	sbaa__ConditionsMet__c = 'All', sbaa__ApproverField__c = 'CPQ_Approval_Manager__c');
        insert newApprovalRule;
        
        sbaa__Approval__c newApproval = new sbaa__Approval__c();
        newApproval.Quote__c = lstQuote[0].Id;
        //newApproval.sbaa__Opportunity__c = lstQuote[0].SBQQ__Opportunity2__c;
        newApproval.Account__c = lstQuote[0].SBQQ__Account__c;
        newApproval.sbaa__Approver__c = lstApprover[0].Id;
        newApproval.sbaa__Status__c = 'Requested';
        newApproval.sbaa__ApprovalStep__c = 1;
        newApproval.sbaa__RecordField__c = 'Quote__c';
        newApproval.sbaa__Rule__c = newApprovalRule.Id;
        
        Test.startTest();
        
        insert newApproval;
        
        newApproval.sbaa__Status__c = 'Approved';
        
        update newApproval;
        
        Test.stopTest();
        
        //sbaa__Approval__c updatedApproval = [SELECT Id, Approval_Response_Date__c FROM sbaa__Approval__c WHERE Id = :newApproval.Id ];
        
        //System.assertEquals(date.today(), updatedApproval.Approval_Response_Date__c.date());
    }
    
    @isTest static void approvedApprovalBulkified(){
        List<SBQQ__Quote__c> lstQuote = [SELECT Id, SBQQ__Opportunity2__c, SBQQ__Account__c FROM SBQQ__Quote__c LIMIT 2];
        List<sbaa__Approver__c> lstApprover = [SELECT Id FROM sbaa__Approver__c LIMIT 1];
        
        sbaa__ApprovalRule__c newApprovalRule = new sbaa__ApprovalRule__c(sbaa__TargetObject__c = 'SBQQ__Quote__c', 	sbaa__ConditionsMet__c = 'All', sbaa__ApproverField__c = 'CPQ_Approval_Manager__c');
        insert newApprovalRule;
        
        List<sbaa__Approval__c> newApprovalList = new List<sbaa__Approval__c>();
        sbaa__Approval__c newApproval = new sbaa__Approval__c();
        newApproval.Quote__c = lstQuote[0].Id;
        //newApproval.sbaa__Opportunity__c = lstQuote[0].SBQQ__Opportunity2__c;
        newApproval.Account__c = lstQuote[0].SBQQ__Account__c;
        newApproval.sbaa__Approver__c = lstApprover[0].Id;
        newApproval.sbaa__Status__c = 'Requested';
        newApproval.sbaa__ApprovalStep__c = 1;
        newApproval.sbaa__RecordField__c = 'Quote__c';
        newApproval.sbaa__Rule__c = newApprovalRule.Id;
        newApprovalList.add(newApproval);
        
        newApproval = new sbaa__Approval__c();
        newApproval.Quote__c = lstQuote[0].Id;
        newApproval.Account__c = lstQuote[0].SBQQ__Account__c;
        newApproval.sbaa__Approver__c = lstApprover[0].Id;
        newApproval.sbaa__Status__c = 'Requested';
        newApproval.sbaa__ApprovalStep__c = 1;
        newApproval.sbaa__RecordField__c = 'Quote__c';
        newApproval.sbaa__Rule__c = newApprovalRule.Id;
        newApprovalList.add(newApproval);
        Test.startTest();
        
        insert newApprovalList;
        
        newApprovalList[0].sbaa__Status__c = 'Approved';
        
        update newApprovalList;
        
        Test.stopTest();
        
        //sbaa__Approval__c updatedApproval = [SELECT Id, Approval_Response_Date__c FROM sbaa__Approval__c WHERE Id = :newApprovalList[0].Id ];
        
        //System.assertEquals(date.today(), updatedApproval.Approval_Response_Date__c.date());
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