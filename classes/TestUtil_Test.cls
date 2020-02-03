@isTest
private class TestUtil_Test {
    static testMethod void myUnitTest() {
        Account accountRec2 = TestUtil.createAccount('Test Name');
        Id userId = [SELECT Id FROM User WHERE IsActive = TRUE AND Name LIKE '%deployment%' LIMIT 1].Id;
        TestUtil.createEBAgentProfile('Test Name',userId,'Enterprise Project');
        Account accountRec = TestUtil.createAccount('test Account','Biz_Ac');
        insert accountRec;
        TestUtil.createATM(accountRec.Id,userId);
        TestUtil.createContact('Contact Test','Contact Last Name','test@test.com',accountRec.Id);
        TestUtil.createContact(accountRec.Id);
        Opportunity opportunityRec = TestUtil.createOpportunity('Test Opportunity','Event','Verbal');
        TestUtil.createcase();
        TestUtil.createtask();
        TestUtil.createrole();

        TestUtil.createoldcr();
        TestUtil.getProbability('Verbal');
        TestUtil.CreateDeploymentUser();
        //TestUtil.CreateContract(accountRec.id,opportunityRec.Id);
        
        EBS_Integration__c ebs = TestUtil.createEbsIntegration('Test','Account');
        Address__c add = TestUtil.createAccountAddress(accountRec.Id,'Billing');
        Id userProfieId = UserProfileUtil.getProfileIDByName('Customer Care Rep - Product Consultant EB Team');
        TestUtil.createUser(userProfieId);
        TestUtil.createUser(userProfieId,'test@test.com');
        
        List<Product2> products =  TestUtil.createProducts(new List<String>{'EOY Cvent Event Builder Promotion- Advanced','EOY Cvent Event Builder Promotion- Advanced with Mobile'});
        insert products;
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        PricebookEntry pbe1 =  TestUtil.createPricebookEntry(products[0],200);
        pbeList.add(pbe1);
        PricebookEntry pbe2 =  TestUtil.createPricebookEntry(products[1],400);
        pbeList.add(pbe2);        
        insert pbeList;   
        Contact con;
        con = TestUtil.createContact(accountRec.id);
        insert con;
        
        Opportunity o1 = TestUtil.createOpportunity('testOpp','Event','Bid Phase');
        o1.Contact_Associated__c = con.Id;
        o1.AccountId = accountRec.Id;
        o1.Event_Planner_Name__c = 'test User';
        o1.Event_Planner_Email__c = 'testuser@cvent.com';
        o1.CloseDate = Date.today().addDays(80);
        insert o1;
        EBS_Orders__c ebOrder = TestUtil.createEBSOrder(o1.Id,'test','test121431');
         OpportunityLineItem oli1 = TestUtil.createOpportunityLineItems(o1,pbe1);
        OpportunityLineItem oli2 = TestUtil.createOpportunityLineItems(o1,pbe2);
    }
}