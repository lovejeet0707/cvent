@isTest
private class CventMyd_AutoRenewContractSched_Test {

    private static testMethod void test0() {
        
            //Insert Opp
            Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
                opp.CurrencyIsoCode  = 'USD';
                insert opp;
                
                //Account
                Account TestAccount = new Account();
                TestAccount.Name = 'Test Account';
                insert TestAccount;
                
                Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
                Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();
                
            //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c
                Contract ParentCont = new Contract();
                ParentCont.AccountId = TestAccount.id;
                ParentCont.Contract_Term_Years__c = '1';
                ParentCont.RecordTypeId = RecordTypeId;
                ParentCont.SBQQ__Opportunity__c = opp.id;
                //ParentCont.Is_Legacy__c = true;
                ParentCont.SBQQ__RenewalQuoted__c = false;
                ParentCont.Failed_Auto_Renew__c = false;
                ParentCont.Renewal_Creation_Date__c = System.today().addYears(1);
                insert ParentCont;

                Test.setCreatedDate(ParentCont.Id,DateTime.newInstance(2015,1,1));
                
                //Child Contract
                Contract cont = new Contract();
                cont.RecordTypeId = ChildRecordTypeId;
                cont.AccountId = TestAccount.id;
                cont.Parent_Contract__c = ParentCont.id;
                //cont.Upcoming_Renewal_Type__c = 'Contract Renewal';
                cont.EndDate = System.today();
                //cont.Remaining_Master_Term__c = 0;
                cont.Current_Year__c = 1;
                //cont.Is_Legacy__c = true;
                cont.SBQQ__RenewalQuoted__c = false;
                cont.Failed_Auto_Renew__c = false;
                cont.Renewal_Creation_Date__c = Date.newInstance(2018,9,5); //System.today().addYears(1);
                insert cont;

                Test.setCreatedDate(cont.Id,DateTime.newInstance(2015,1,1));
                
            //Insert Quote
                SBQQ__Quote__c TestQuote = new SBQQ__Quote__c();
                TestQuote.SBQQ__Opportunity2__c = opp.id;
                TestQuote.Contract_Term_Years__c = '2';
                TestQuote.SBQQ__Type__c = 'Amendment';
                TestQuote.Current_Year__c = 2;
                TestQuote.Contract_Executed__c = true;
                TestQuote.SBQQ__StartDate__c = System.today().addYears(-1);
                TestQuote.SBQQ__EndDate__c = System.today();
                TestQuote.createdFromLegacyContract__c = true;
                //TestQuote.Multiple_Years_Commitment__c = true;
                TestQuote.statusCheckCount__c = 0;
                insert TestQuote;
                
                TestQuote.Multiple_Years_Commitment__c = true;
                update TestQuote;
            
                //Insert CPQ Audit record
                CpqAudit__c testAudit = new CpqAudit__c();
                testAudit.Name = 'Test Audit';
                testAudit.quote__c = TestQuote.id;
                testAudit.contract__c = ParentCont.id;
                insert testAudit;
                
                Test.startTest();
                
                //Run batch
                CventMyd_AutoRenewContractSchedulable BatchRun = new CventMyd_AutoRenewContractSchedulable();
                //CventMyd_QuoteSchedulable renewalQuoteSchedulable = new CventMyd_QuoteSchedulable(renewalQuoteMap.keySet(),renewalJobName,renewalJobAuditRecord.Id);
                //ID batchprocessid = Database.executeBatch(BatchRun,200);
                String sch = '0 0 23 * * ?';
                system.schedule('Test Run', sch, BatchRun);
                
                Test.stopTest();

        }
            
        private static testMethod void test1() {

                /*
                
            Test.startTest();
                
                //Run batch
                CventMyd_AutoRenewContractSchedulable BatchRun = new CventMyd_AutoRenewContractSchedulable();
                //CventMyd_QuoteSchedulable renewalQuoteSchedulable = new CventMyd_QuoteSchedulable(renewalQuoteMap.keySet(),renewalJobName,renewalJobAuditRecord.Id);
                //ID batchprocessid = Database.executeBatch(BatchRun,200);
                
                Test.stopTest();
                
                String sch = '0 0 23 * * ?';
                system.schedule('Test Run', sch, BatchRun);

                */
        
    }

                
        private static testMethod void test2() {
                    


        }

}