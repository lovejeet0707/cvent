@isTest
private class ScheduledFinanceShellBatch_Test{

    @isTest static void ScheduledFinanceShellBatchTest() {
        user u = TestUtil.CreateDeploymentUser();
        insert u;
        
        system.runAs(u)
        {
        
            Account objAccount = CventMYDDataFactory.createAccounts(1);
            insert objAccount;
            
            Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
            insert objContact;
            
            Opportunity objOpport = CventMYDDataFactory.createOpportunities(1,objAccount.Id,objContact.Id);
            insert objOpport;
            
            Date todayDate = Date.today();
            Date lastWeekDate = todayDate.addDays(-10);
            
            Contract_Reviewing__c conRev = new Contract_Reviewing__c();
            conRev.Accounting_Hybrid_Review_Ok__c='Yes';
            conRev.Contract_Review_Ok__c = 'Yes';
            conRev.Contract_Reviewer__c=u.Id;
            conRev.Opportunity__c =objOpport.Id;
            conRev.Final_Review_Date__c = lastWeekDate;
            conrev.Final_Review_Date__c = todayDate.addDays(-5);
            //conRev.Opportunity_Contract__c =123;
            insert conRev;
            
            Test.startTest();
            ScheduledFinanceShellBatch sh1 = new ScheduledFinanceShellBatch();
            String sch = '0 0 2 * * ?'; 
            system.schedule('Test Schedule Class', sch, sh1); 
            Test.stopTest();
        }
    }
}