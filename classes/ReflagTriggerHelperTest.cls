@isTest
public class ReflagTriggerHelperTest 
{
    public static User userObj;
    public static AccountTeamMember atm;

    public static testmethod void test1()
    {
        List<Account> listOfAccounts = new List<Account>();
        List<Rebrand_Reflag__c> listOfReflags = new List<Rebrand_Reflag__c>();

        Account accObj = TestUtil.createAccount('Reflag Account Test 1', 'Biz_Ac');
        listOfAccounts.add(accObj);

        Account accObj2 = TestUtil.createAccount('Reflag Account Test 2', 'Biz_Ac');
        listOfAccounts.add(accObj2);
        
        insert listOfAccounts;
		
        Contact instOfCon = TestUtil.createContact(String.valueOf(listOfAccounts[0].Id));
		insert instOfCon;
        
        Opportunity oppObj2 = TestUtil.createOpportunityNew('Test Opportunity','Up for Renewal',instOfCon.Id,listOfAccounts[0].Id);
       	oppObj2.Event_Planner_Name__c = 'test User';
        oppObj2.Event_Planner_Email__c = 'testuser@cvent.com';
        oppObj2.CloseDate = Date.today().addDays(80);        
        insert oppObj2;
        
        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Family = 'Social Tables';
        product1.Contract_Output_Grouping__c = 'Social Tables';
        insert product1;
        
        Contract parentContract = new Contract();
        parentContract.AccountId = listOfAccounts[0].Id;
        parentContract.SBQQ__Opportunity__c = oppObj2.Id;
        parentContract.EndDate = System.today()+5;
        insert parentContract; 
        
        Contract childContract = new Contract();
        childContract.AccountId = listOfAccounts[0].Id;
        childContract.SBQQ__Opportunity__c = oppObj2.Id;
        childContract.Parent_Contract__c = parentContract.id;
        insert childContract;  
        
        Customer_Asset__c newAsset = new Customer_Asset__c();
        newAsset.Account__c = accObj.Id;
        newAsset.Contract__c = childContract.Id;
        newAsset.Product__c = product1.Id;
        newAsset.Term_Start_Date__c = Date.today().addDays(-30);
        newAsset.Term_End_Date__c = Date.today().addDays(30);  
        insert newAsset;
        
        userObj = TestUtil.CreateDeploymentUser();
        insert userObj;

        atm = TestUtil.createAccountTeamMember(listOfAccounts[0].Id,userObj.Id,'CS - HCloud - Implement/Onboard');
        insert atm;

        Rebrand_Reflag__c reflagRec = new Rebrand_Reflag__c();
        reflagRec.Reflagged_on_Date__c = System.today() + 5;
        reflagRec.Old_Supp_Ac__c = listOfAccounts[0].Id;
        listOfReflags.add(reflagRec);

        Rebrand_Reflag__c reflagRec2 = new Rebrand_Reflag__c();
        reflagRec2.Reflagged_on_Date__c = System.today() + 5;
        reflagRec2.Old_Supp_Ac__c = listOfAccounts[1].Id;
        listOfReflags.add(reflagRec2);

        insert listOfReflags;
    }
    
    public static testmethod void test2()
    {
        List<Account> listOfAccounts = new List<Account>();
        List<Rebrand_Reflag__c> listOfReflags = new List<Rebrand_Reflag__c>();

        Account accObj = TestUtil.createAccount('Reflag Account Test 1', 'Biz_Ac');
        listOfAccounts.add(accObj);

        Account accObj2 = TestUtil.createAccount('Reflag Account Test 2', 'Biz_Ac');
        listOfAccounts.add(accObj2);
        
        insert listOfAccounts;
		
        Contact instOfCon = TestUtil.createContact(String.valueOf(listOfAccounts[0].Id));
		insert instOfCon;
        
        Opportunity oppObj2 = TestUtil.createOpportunityNew('Test Opportunity','Up for Renewal',instOfCon.Id,listOfAccounts[0].Id);
       	oppObj2.Event_Planner_Name__c = 'test User';
        oppObj2.Event_Planner_Email__c = 'testuser@cvent.com';
        oppObj2.CloseDate = Date.today().addDays(80);        
        insert oppObj2;
        
        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Family = 'Social Tables';
        product1.Contract_Output_Grouping__c = 'Social Tables';
        insert product1;
        
        Contract parentContract = new Contract();
        parentContract.AccountId = listOfAccounts[0].Id;
        parentContract.SBQQ__Opportunity__c = oppObj2.Id;
        parentContract.EndDate = System.today()+5;
        insert parentContract; 
        
        Contract childContract = new Contract();
        childContract.AccountId = listOfAccounts[0].Id;
        childContract.SBQQ__Opportunity__c = oppObj2.Id;
        childContract.Parent_Contract__c = parentContract.id;
        insert childContract;  
        
        Customer_Asset__c newAsset = new Customer_Asset__c();
        newAsset.Account__c = accObj.Id;
        newAsset.Contract__c = childContract.Id;
        newAsset.Product__c = product1.Id;
        newAsset.Term_Start_Date__c = Date.today().addDays(-30);
        newAsset.Term_End_Date__c = Date.today().addDays(30);  
        insert newAsset;
        
        userObj = TestUtil.CreateDeploymentUser();
        insert userObj;

        Rebrand_Reflag__c reflagRec = new Rebrand_Reflag__c();
        reflagRec.Reflagged_on_Date__c = System.today() + 5;
        reflagRec.Old_Supp_Ac__c = listOfAccounts[0].Id;
        listOfReflags.add(reflagRec);

        Rebrand_Reflag__c reflagRec2 = new Rebrand_Reflag__c();
        reflagRec2.Reflagged_on_Date__c = System.today() + 5;
        reflagRec2.Old_Supp_Ac__c = listOfAccounts[1].Id;
        listOfReflags.add(reflagRec2);

        insert listOfReflags;
    }
}