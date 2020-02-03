@isTest
private class CventMyd_ValidationHandler_Test {

    public testmethod static void testContractedValidations() {
        User instUsr = TestUtil.CreateDeploymentUser();
        system.RunAs(instUsr){    
            System.debug('testContractedValidations execution is starting....');
            Account testAccount =TestUtil.createAccount('Test Account','Biz_Ac');
            testAccount.Supplier_Type__c = 'Venue';
            testAccount.Venue_Type__c = 'CVB';
            testAccount.BillingState='AK';
            testAccount.BillingCountryCode='US';            
            insert testAccount;
            Opportunity instOpp=TestUtil.createOpportunity('Test Opp','Event','Qualified');
            instOpp.StageName ='Closed Won';
            instOpp.Deal_Year__c ='1';
            instOpp.NBB_Renewal__c = 'NBB';
            instOpp.Parent_Upsell__c = 'Primary';
            instOpp.CloseDate = system.today().addmonths(12);
            // instOpp.Web_Design_Support_Minutes_Purchased__c =0;
            instOpp.Contract_Implemented__c = false;
            instOpp.ContractReceived__c = system.today();
            instOpp.Product__c ='TicketMob';
            instOpp.MYD_Deal__c='First Year';
            instOpp.pricebook2id=Test.getStandardPricebookID();
            Contact testContact =TestUtil.createContact(testAccount.id);
            instOpp.Contact_Associated__c=testContact.id; 
            //instopp.SBQQ__PrimaryQuote__c ='';
            //instopp.SBQQ__RenewedContract__c=con1.Id;
            insert instOpp;
            SBQQ__Quote__c sbqq = new SBQQ__Quote__c();
            sbqq.SBQQ__Opportunity2__c = instopp.id;
            sbqq.Current_Year__c = 4;
            sbqq.SBQQ__StartDate__c = Date.today();
            sbqq.SBQQ__EndDate__c = sbqq.SBQQ__StartDate__c.addYears(1);
            sbqq.Contract_Term_Years__c = '5';
            //sbqq.SBQQ__RenewedContract__c='';
            insert sbqq;
            instopp.SBQQ__PrimaryQuote__c=sbqq.id;
            sbqq.Contract_Executed__c = true;
            //instopp.SBQQ__RenewedContract__c=conId;
            Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();       
            Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();          
            Contract ParentCont = new Contract();
            ParentCont.AccountId = TestAccount.id;
            ParentCont.Contract_Term_Years__c = '5';
            ParentCont.RecordTypeId = RecordTypeId;
            ParentCont.SBQQ__Opportunity__c = instOpp.id;
            //ParentCont.Is_Legacy__c = true;
            ParentCont.SBQQ__RenewalQuoted__c = false;
            ParentCont.Failed_Auto_Renew__c = false;
            ParentCont.Renewal_Creation_Date__c = System.today().addYears(1);
            insert ParentCont;
            Product2 product1 = new Product2();
            product1.Name = 'Product 1';
            product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
            product1.Revenue_Type__c = 'Annual Recurring    ';
            insert product1;       
            Contract cont = new Contract();
            cont.RecordTypeId = ChildRecordTypeId;
            cont.AccountId = TestAccount.id;
            System.debug('ParentContract: ' + ParentCont);
            cont.Parent_Contract__c = ParentCont.id;
            cont.SBQQ__Opportunity__c = instOpp.Id;
            //cont.Upcoming_Renewal_Type__c = 'Contract Renewal';
            cont.EndDate = sbqq.SBQQ__EndDate__c;
            //cont.Remaining_Master_Term__c = 0;
            cont.Current_Year__c = 4;
            //cont.Is_Legacy__c = true;
            cont.SBQQ__RenewalQuoted__c = false;
            cont.Failed_Auto_Renew__c = false;
            cont.Multiple_years_Commitment__C = false;
            cont.Renewal_Creation_Date__c = Date.newInstance(2018,9,5); //System.today().addYears(1);
            cont.SBQQ__RenewalQuoted__c = false;          
            insert cont;
            sbqq.SBQQ__MasterContract__c = cont.Id;
            sbqq.SBQQ__MasterContract__r = cont;
            update sbqq;
            instOpp.SBQQ__AmendedContract__c = cont.Id;
            instOpp.SBQQ__Contracted__c = true;  
            try {
                update instOpp;
            }
            catch(Exception e0) {
                Boolean containsTypeError = e0.getMessage().contains('cannot contract an opportunity that has been used as both a renewal and an amendment');
                System.assert(containsTypeError);
                sbqq.SBQQ__Type__c = 'Amendment';
                Id quoteId = sbqq.Id;
                String jsonString = [SELECT jsonString__c FROM SBQQ__Quote__c where Id =: quoteId].jsonString__c;
                CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(jsonString);
                quoteObject.outyearMap = new Map<Integer,CventMyd_Outyear>();
                sbqq.jsonString__c = JSON.serialize(quoteObject);
                System.debug('new jsonstring 0: ' + sbqq.jsonString__c);
                CventMyd_ValidationHandler.settings.ruleNameToIsActive.put('Quote_Missing_Outyears',false);
                update sbqq;
                System.debug('new jsonstring 1: ' + sbqq.jsonString__c);
                CventMyd_ValidationHandler.validatedOpportunityIds = new Set<Id>();
                CventMyd_ValidationHandler.settings.ruleNameToIsActive.put('Quote_Missing_Outyears',true);
                instOpp.SBQQ__Contracted__c = true;
                System.debug('now proceeding to contract the opportunity again 0...');
                try {
                    update instOpp;
                }
                catch(Exception e1) {
                    Boolean containsOutyearError = e1.getMessage().contains('is missing outyear dates for year(s)');
                    System.assert(containsOutyearError);
                    sbqq.jsonString__c = jsonString;
                    update sbqq;
                    CventMyd_ValidationHandler.validatedOpportunityIds = new Set<Id>();
                    instOpp.SBQQ__Contracted__c = true;
                    System.debug('now proceeding to contract the opportunity again 1...');    
                    update instOpp;              
                }
            }

            CventMyd_ValidationHandler.getErrorStrings(sbqq);
            ParentCont.Contract_Term_Years__c = '3';  
            Boolean containsInvalidTermError;
            try {
                update parentCont;
            }          
            catch (Exception e) {
                containsInvalidTermError = e.getMessage().contains('has a current year less than its term');          
            }
            System.assert(containsInvalidTermError);
            //Insert Quote Line
            SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
            ql1.SBQQ__Quantity__c = 1;
            ql1.SBQQ__Product__c = product1.Id;
            ql1.SBQQ__ListPrice__c = 10;
            ql1.SBQQ__NetPrice__c = 10;
            ql1.Rack_Rate__c = 10;
            ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            ql1.SBQQ__Number__c = 1;
            ql1.SBQQ__Quote__c = sbqq.Id;
            ql1.Notes__c = 'abc';
            insert ql1;

            CventMyd_ValidationHandler.getErrors(ql1,false);        
            CventMyd_ValidationHandler.getErrors(ql1,true);
            instOpp.StageName = 'Verbal';
            instOpp.SBQQ__Contracted__c = false;
            update instOpp;
            instOpp.StageName = 'Closed Won';
            try {
            	update instOpp;
            }
            catch(Exception e) {
            	
            }
            String quoteIdString = String.valueOf(sbqq.Id);
            CventMyd_ValidationHandler.settings.groupingValidationSettings.validateOnApprovals = true;
            CventMyd_ValidationHandler.validateLineCountOnApproval(quoteIdString);
        }

    }     

}