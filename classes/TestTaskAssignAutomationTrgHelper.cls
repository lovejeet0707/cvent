/*    
 Author :Hemant Rana
 Desc: Test class for  TaskAssignAutomationTrgHelper class 
 //Commenting "SignUp4_Conversion__c" for now as we have to change the type of the field from checkbox to picklist.After changing we will roll it back
*/
@isTest//(seeAllData=True)
private class TestTaskAssignAutomationTrgHelper {
    Private Static Opportunity instOfOppFIF;
    Private static List<OpportunityLineItem> listfSet;
    Private static Multi_Property_Bundles__c mPropertyBundles;
    Private static AccountTeamMember teamMember;
    Private Static List<Opportunity> listOppty;
    private static string accId;
    private static string oppId;
    Private static User u;
    Private static  Mobile_Card__c card;
    Private static void createUser(string roleName,integer id ){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        String s = '%' + roleName + '%'; 
        USerrole testroleId=[select id from userRole where name like :s limit 1];
        u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, userRoleId=testroleId.id,
        TimeZoneSidKey='America/Los_Angeles', UserName=id+'deploymentuser@cvent.com');
    }
    public static List<TaskRRassignment__c> CreateCustomSetting()
    {
        List<TaskRRassignment__c> taskCSList=new List<TaskRRassignment__c>();
        createUser('Direct Sales (Event)',21);
        System.runAs (u) {
            TaskRRassignment__c taskCS=new TaskRRassignment__c();
            taskCS.Name='5';
            taskCS.CurrentAssignment__c=true;
            //taskCS.Indexing_del__c=1;
            taskCS.User_Id__c=u.id;
            taskCS.User_Name__c=u.name;
            taskCSList.add(taskCS);
            
            taskCS=new TaskRRassignment__c();
            taskCS.Name='6';
            taskCS.CurrentAssignment__c=false;
            //taskCS.Indexing_del__c=2;
            taskCS.User_Id__c=u.id;
            taskCS.User_Name__c=u.name;
            taskCSList.add(taskCS);
            
            taskCS=new TaskRRassignment__c();
            taskCS.Name='7';
            taskCS.CurrentAssignment__c=false;
            //taskCS.Indexing_del__c=3;
            taskCS.User_Id__c=u.id;
            taskCS.User_Name__c=u.name;
            taskCSList.add(taskCS);
            insert taskCSList;
        }
        return taskCSList;
    }
    public static Id createAccount(){
            RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
            Account instofAcc = new Account();
            instofAcc.Supplier_Type__c = 'Venue';
            instofAcc.Venue_Type__c = 'CVB';
            instofAcc.RecordTypeId = rtType.id;
            instofAcc.Name = 'Test';
            instofAcc.Named_Acct__c = 'Cvent Vendor';
            instofAcc.Country_Region__c='Asia';//'America';
            instofAcc.PA_Rep__c='Abby Glackin';
            instofAcc.AM_PA__c='Amy Chugh';
            instofAcc.CS_Rep__c='Alyson Toole';
            instofAcc.Original_A_C_Owner__c ='Erin Phelps';
            insert instofAcc;
            accId=instofAcc.id;
            
            Id EMIRecordTypeId = Schema.SObjectType.Onboarding__c.getRecordTypeInfosByName().get('EMI').getRecordTypeId();
            Onboarding__c onboardObj = new Onboarding__c();
            onboardObj.RecordTypeId = EMIRecordTypeId;
            onboardObj.Account_Name__c = accId;
            onboardObj.Status__c ='Open';
            insert onboardObj;

            return instofAcc.id;
            
            
    }
    public static Id createboard2(){ 
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
            Account instofAcc1 = new Account();
            instofAcc1.Supplier_Type__c = 'Venue';
            instofAcc1.Venue_Type__c = 'CVB';
            instofAcc1.RecordTypeId = rtType.id;
            instofAcc1.Name = 'Test12';
            instofAcc1.Named_Acct__c = 'Cvent Vendor';
            instofAcc1.Country_Region__c='Asia';//'America';
            instofAcc1.PA_Rep__c='Abby Glackin';
            instofAcc1.AM_PA__c='Amy Chugh';
            instofAcc1.CS_Rep__c='Alyson Toole';
            instofAcc1.Original_A_C_Owner__c ='Erin Phelps';
            insert instofAcc1;
            accId=instofAcc1.id;
     
            Id CSNSupplierRecordTypeId = Schema.SObjectType.Onboarding__c.getRecordTypeInfosByName().get('CSN-Supplier').getRecordTypeId();
            Onboarding__c onboardObj1 = new Onboarding__c();
            onboardObj1.RecordTypeId = CSNSupplierRecordTypeId;
            onboardObj1.Account_Name__c = accId;
            onboardObj1.Status__c ='Open';
            insert onboardObj1;
            return instofAcc.id;
        }
    Private static Multi_Property_Bundles__c createBundles() {
        //createAccount();
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Multi_Property_Bundles__c' And DeveloperName='MSA' And IsActive=true];
        mPropertyBundles =new Multi_Property_Bundles__c();
        mPropertyBundles.Account__c=accId;
        mPropertyBundles.TaskCreated__c=false;
        mPropertyBundles.End_Date__c=system.today().addDays(10);
        mPropertyBundles.Start_Date__c=system.today();
        mPropertyBundles.Opportunity__c=oppId;
        mPropertyBundles.RecordTypeId=rtType.Id;
        //mPropertyBundles.MSA_Code__c ='MSA1234';
        insert mPropertyBundles;
        return mPropertyBundles;
    }
    Private static void createAccountTeamMember(){
        //createAccount();
        List<User> userObj=[SELECT Id FROM User WHERE IsActive=True AND IsPortalEnabled=False Limit 10];// AND License__c != 'Chatter Free' 
        List<AccountTeamMember> teamMemberList=new List<AccountTeamMember>();
        teamMember =new AccountTeamMember();
        teamMember.TeamMemberRole='CS - HCloud - Implement/Onboard';
        teamMember.userId=userObj[0].Id;//userinfo.getUserId();
        teamMember.AccountId=accId;
        teamMemberList.add(teamMember);
        
        teamMember =new AccountTeamMember();
        teamMember.TeamMemberRole='AM - Inquisium';
        teamMember.userId=userObj[1].Id;//userinfo.getUserId();
        teamMember.AccountId=accId;
        teamMemberList.add(teamMember);
        
        teamMember =new AccountTeamMember();
        teamMember.TeamMemberRole='AM - CSN';
        teamMember.userId=userObj[2].Id;//userinfo.getUserId();
        teamMember.AccountId=accId;
        teamMemberList.add(teamMember);
        
        teamMember =new AccountTeamMember();
        teamMember.TeamMemberRole='AM - Event';
        teamMember.userId=userObj[3].Id;//userinfo.getUserId();
        teamMember.AccountId=accId;
        teamMemberList.add(teamMember);
        
        teamMember =new AccountTeamMember();
        teamMember.TeamMemberRole='AM - CrowdCompass';
        teamMember.userId=userObj[4].Id;//userinfo.getUserId();
        teamMember.AccountId=accId;
        teamMemberList.add(teamMember);
        //insert teamMemberList;
        
        teamMember =new AccountTeamMember();
        teamMember.TeamMemberRole='CS - HCloud - Corporate Rep';
        teamMember.userId=userObj[5].Id;//userinfo.getUserId();
        teamMember.AccountId=accId;
        teamMemberList.add(teamMember);
        insert teamMemberList;
    }  
    

    Public static void creatOpportunity(List<PricebookEntry> pricebookEntryList){
        //createBundles();
        listOppty=new List<Opportunity>();
        instOfOppFIF = new Opportunity();
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppFIF.Contract_Type_Test__c = 'Renewal';
        instOfOppFIF.Forex_rate__c = 1;
        instOfOppFIF.Liquidation_Fee__c  = 10;
        instOfOppFIF.OptOutDate__c = system.today();
        instOfOppFIF.Opp_End_Date__c  = system.today();
        instOfOppFIF.AccountId =accId;
        instOfOppFIF.Forex_rate__c = 1;
       // instOfOppFIF.Price_per_lead__c = 1;
        instOfOppFIF.Name = 'Test';
        instOfOppFIF.Counted_sales_Cancellation_Value__c =110;
        instOfOppFIF.Product__c = 'CSN';
        instOfOppFIF.Contract_Number_New__c = '12345';
        instOfOppFIF.New_Type__c =  'Upsell-NBB';
        instOfOppFIF.Parent_Upsell__c ='Primary'; 
        instOfOppFIF.NBB_Renewal__c ='NBB';
        instOfOppFIF.StageName = 'verbal';
        //instOfOppFIF.MSA_Code__c =mPropertyBundles.MSA_Code__c;
        instOfOppFIF.CloseDate = system.today();
        instOfOppFIF.EMI_Correlated_Ad_included__c='White Label – Pro';
       // instOfOppFIF.RecordTypeId = instOfRecType.Id;
        instOfOppFIF.Year_1_at_Risk__c = 11;
        instOfOppFIF.New_Type__c = 'Test';
        instOfOppFIF.Deal_Booked_In__c = '5';
      //  instOfOppFIF.Price_per_lead__c = 1;
        instOfOppFIF.Years__c= '1';
        instOfOppFIF.LeadSource = 'ACD-PS';
        instOfOppFIF.Contact_Associated__c = instOfCon.Id;
        instOfOppFIF.Contact_Role__c = 'Influencer';
        //instOfOppFIF.MSA_Code__c = '123456';
        instOfOppFIF.Contract_Implemented__c = false;
        instOfOppFIF.ContractReceived__c = system.today();
        instOfOppFIF.Deal_Year__c = '4';
        instOfOppFIF.MaintenanceFee__c = 1000;
        instOfOppFIF.New_Amount__c = 1000;
       // instOfOppFIF.Discount__c = 1000;
        instOfOppFIF.Convinience_Fee__c = 1000;
        instOfOppFIF.of_Leads_Purchased__c = 1000;
       //commented by kumud instOfOppFIF.Events__c = 1000;
        instOfOppFIF.Price_Adjustment__c = 1000;
        instOfOppFIF.MYD_Deal__c = 'First Year';
        instOfOppFIF.Parent_Upsell__c = 'Primary';
        instOfOppFIF.License_Type__c='2 Diamond';
        instOfOppFIF.NBB_Renewal__c='NBB';
        instOfOppFIF.ATI_Check__c =true;
        instOfOppFIF.ContractEndDate__c=system.today().addDays(30);
        instOfOppFIF.ContractStartDate__c=system.today();
        instOfOppFIF.Pricebook2Id = pricebookEntryList[0].Pricebook2Id;
        listOppty.add(instOfOppFIF);

        insert listOppty;
        oppId=listOppty[0].Id;
    }
    Public static List<PricebookEntry> createPricebookEntry(){
        //create Product and PriceBook
        
        List<Product2> prodList= new List<Product2>();
        
        Product2 prd1 = new Product2 ();
        
        prd1 = new Product2 ();
        prd1.Name='White Label - Pro';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);
        
        prd1 = new Product2 ();
        prd1.Name='Social Wall';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);
        
        prd1 = new Product2 ();
        prd1.Name='White Label - Enterprise';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);
        
        prd1 = new Product2 ();
        prd1.Name='EliteMeetings-Enhanced Marketing Program';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);
        
        prd1 = new Product2 ();
        prd1.Name='EliteMeetings-Premier Marketing Program Print';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);
        
        prd1 = new Product2 ();
        prd1.Name='Supplier Feature-CSN API Access';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);
        
        prd1 = new Product2 ();
        prd1.Name='Supplier Feature-Professional Package';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);
        
        prd1 = new Product2 ();
        prd1.Name='Supplier Feature-Enterprise Package';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);
        
        prd1 = new Product2 ();
        prd1.Name='Custom Proposal';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);
        
        prd1 = new Product2 ();
        prd1.Name='Supplier Feature-Routing Rules';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);
        
        /*prd1 = new Product2 ();
        prd1.Name='Video Marketing';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);*/
        
        prd1 = new Product2 ();
        prd1.Name='Cvent Connect - Print - 1 pg Display Ad';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);
        
        prd1 = new Product2 ();
        prd1.Name='Supplier Feature-RFP Usernames';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);
        
        prd1 = new Product2 ();
        prd1.Name='Recommended Ads';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);
        
        prd1 = new Product2 ();
        prd1.Name='SpeedRFP-Hero Ad';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);
        
        prd1 = new Product2 ();
        prd1.Name='EliteMeetings-Hero Ad - EM.com';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);
        
        prd1 = new Product2 ();
        prd1.Name='RFP Report-Comp Set';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);
        
        prd1 = new Product2 ();
        prd1.Name='Attendee Hub';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);
        
        insert prodList;

        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        //get standard pricebook
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standPriceBook= new PricebookEntry ();
        List<PricebookEntry> stndpricebookEntryList= new List<PricebookEntry>();
        List<PricebookEntry> pricebookEntryList= new List<PricebookEntry>();
        /*For(Integer i=0; i<prodList.size() ; i++)
        {
            standPriceBook= new PricebookEntry ();
            standPriceBook.Product2ID=prodList[i].id;
            standPriceBook.Pricebook2ID=pricebookId;
            standPriceBook.UnitPrice=50;
            standPriceBook.isActive=true;
            stndpricebookEntryList.add(standPriceBook);
        }
        System.debug('stndpricebookEntryList************'+stndpricebookEntryList);
        insert stndpricebookEntryList;*/
        
        //Inserting PriceBookEntry.........................
        PricebookEntry pbe1 = new PricebookEntry ();
        For(Integer i=0; i<prodList.size() ; i++)
        {
            pbe1 = new PricebookEntry ();
            pbe1.Product2ID=prodList[i].id;
            pbe1.Pricebook2ID=pricebookId;//pbk1.id;
            pbe1.UnitPrice=50;
            pbe1.isActive=true;
            pricebookEntryList.add(pbe1);
        }
        
        insert pricebookEntryList;
        System.debug('pricebookEntryList************'+pricebookEntryList);
        return pricebookEntryList;
        
        //opp.Pricebook2Id = pbe1.Pricebook2Id;

    }
Private static void createFeatureset(List<PricebookEntry> priceBookList){

    // creating OpportunityLineItem for the opp

    listfSet=new List<OpportunityLineItem>();
    OpportunityLineItem fSet;

    fSet=new OpportunityLineItem();
    fSet.OpportunityID=listOppty[0].id;
    fSet.Per_Item_Fee__c=5000;
    fSet.PriceBookEntryID=priceBookList[0].Id;
    fSet.of_Items__c=10;
    fSet.of_Comp_Items_Hrs__c=10;
    fSet.quantity=4;
    fSet.totalprice=200;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.OpportunityID=listOppty[0].id;
    fSet.Per_Item_Fee__c=5000;
    fSet.PriceBookEntryID=priceBookList[1].Id;
    fSet.Product__c='CSN - Social Wall';
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.of_Items__c=10;
    fSet.of_Comp_Items_Hrs__c=10;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.OpportunityID=listOppty[0].id;
    fSet.Per_Item_Fee__c=5000;
    fSet.PriceBookEntryID=priceBookList[2].Id;
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.of_Items__c=10;
    fSet.of_Comp_Items_Hrs__c=10;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.OpportunityID=listOppty[0].id;
    fSet.Per_Item_Fee__c=5000;
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.PriceBookEntryID=priceBookList[3].Id;
    fSet.of_Items__c=10;
    fSet.of_Comp_Items_Hrs__c=10;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.OpportunityID=listOppty[0].id;
    fSet.Per_Item_Fee__c=5000;
    fSet.PriceBookEntryID=priceBookList[4].Id;
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.of_Items__c=10;
    fSet.of_Comp_Items_Hrs__c=10;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.OpportunityID=listOppty[0].id;
    fSet.Per_Item_Fee__c=5000;
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.PriceBookEntryID=priceBookList[5].Id;
    fSet.of_Items__c=10;
    fSet.of_Comp_Items_Hrs__c=10;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.OpportunityID=listOppty[0].id;
    fSet.Per_Item_Fee__c=5000;
    fSet.PriceBookEntryID=priceBookList[6].Id;//SAME 0
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.of_Items__c=10;
    fSet.of_Comp_Items_Hrs__c=10;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.OpportunityID=listOppty[0].id;
    fSet.Per_Item_Fee__c=5000;
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.PriceBookEntryID=priceBookList[7].Id;//SAME 3
    fSet.of_Items__c=10;
    fSet.of_Comp_Items_Hrs__c=10;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.OpportunityID=listOppty[0].id;
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.Per_Item_Fee__c=5000;
    fSet.PriceBookEntryID=priceBookList[8].Id;
    fSet.of_Items__c=10;
    fSet.of_Comp_Items_Hrs__c=10;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.OpportunityID=listOppty[0].id;
    fSet.Per_Item_Fee__c=5000;
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.PriceBookEntryID=priceBookList[9].Id;
    fSet.of_Items__c=10;
    fSet.of_Comp_Items_Hrs__c=10;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.OpportunityID=listOppty[0].id;
    fSet.Per_Item_Fee__c=5000;
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.PriceBookEntryID=priceBookList[10].Id;
    fSet.of_Items__c=10;
    fSet.of_Comp_Items_Hrs__c=10;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.OpportunityID=listOppty[0].id;
    fSet.Per_Item_Fee__c=5000;
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.PriceBookEntryID=priceBookList[11].Id;
    fSet.of_Items__c=10;
    fSet.of_Comp_Items_Hrs__c=10;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.OpportunityID=listOppty[0].id;
    fSet.Per_Item_Fee__c=5000;
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.PriceBookEntryID=priceBookList[12].Id;
    fSet.of_Items__c=10;
    fSet.of_Comp_Items_Hrs__c=10;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.OpportunityID=listOppty[0].id;
    fSet.Per_Item_Fee__c=5000;
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.PriceBookEntryID=priceBookList[13].Id;
    fSet.of_Items__c=10;
    fSet.of_Comp_Items_Hrs__c=10;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.OpportunityID=listOppty[0].id;
    fSet.Per_Item_Fee__c=5000;
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.PriceBookEntryID=priceBookList[14].Id;
    fSet.of_Items__c=10;
    fSet.of_Comp_Items_Hrs__c=10;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.OpportunityID=listOppty[0].id;
    fSet.Per_Item_Fee__c=5000;
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.PriceBookEntryID=priceBookList[15].Id;//SAME
    fSet.of_Items__c=1;
    fSet.of_Comp_Items_Hrs__c=0;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.OpportunityID=listOppty[0].id;
    fSet.Per_Item_Fee__c=5000;
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.PriceBookEntryID=priceBookList[15].Id;//SAME
    fSet.of_Items__c=10;
    fSet.of_Comp_Items_Hrs__c=10;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.OpportunityID=listOppty[0].id;
    fSet.Per_Item_Fee__c=5000;
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.PriceBookEntryID=priceBookList[15].Id;//SAME
    fSet.of_Items__c=1;
    fSet.of_Comp_Items_Hrs__c=2;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem(); 
    fSet.PriceBookEntryID=priceBookList[16].Id; //SAME 1
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.OpportunityID=listOppty[0].Id;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.PriceBookEntryID=priceBookList[16].Id; //SAME 1
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.OpportunityID=listOppty[0].Id;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.PriceBookEntryID=priceBookList[6].Id; //SAME 0
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.OpportunityID=listOppty[0].Id;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    //fSet.Feature__c ='Attendee Hub';//SAME 1
    fSet.PriceBookEntryID=priceBookList[16].Id;
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.OpportunityID=listOppty[0].Id;
    listfSet.add(fSet);

    fSet=new OpportunityLineItem();
    fSet.PriceBookEntryID=priceBookList[7].Id;//SAME 3
    fSet.quantity=4;
    fSet.totalprice=200;
    fSet.OpportunityID=listOppty[0].Id;
    listfSet.add(fSet);

    insert listfSet;
}
    Private Static void createCard(){
        card =new Mobile_Card__c();
        card.Event_Date__c=system.today().addDays(10);
        card.Opportunity__c=listOppty[0].id;
        insert card;
    }
    
    static testMethod void validateTaskCreation_1(){
        CreateCustomSetting();
        List<String> userRole=new List<String>{'Direct Sales (Event)','Survey','Venue Sourcing','TPP','Direct Sales (Ent)','AM (Ent)'};
        createUser('Direct Sales (Event)',0);
        system.runAs(u){
            createAccount();
            
            List<Task> taskList = new List<Task>();
               Task t1 = new Task(Subject = 'Diamond Client - Client Check In',WhatId = accId);
               Task t2 = new Task(Subject = '1 Diamond Contract Signed – Reach Out',WhatId = accId);
               taskList.add(t1);
               taskList.add(t2);
               insert taskList;
               
               //TaskAssignAutomationTrgHelper.RoundRobinAssignment();
            List<PriceBookEntry> priceBookList = new List<PriceBookEntry>(createPricebookEntry());
            //priceBookList=;
            //System.debug('createPricebookEntry()*************'+createPricebookEntry());
            creatOpportunity(priceBookList);
            createFeatureset(priceBookList);
            createCard();
            createBundles();
            createAccountTeamMember();
            HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
            hybrid.Name='100';
            hybrid.HybridValue__c='Attendee Hub';
            insert hybrid;

            listOppty[0].MSA_Code__c = mPropertyBundles.MSA_Code__c;
            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            //Commented by kumud listOppty[0].Per_User__c=1000;
            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].Parent_Upsell__c='Primary';
            listOppty[0].NBB_Renewal__c='Renewal';
            listOppty[0].MYD_Deal__c='First Year';
            listOppty[0].ATI_Check__c =true;
            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
           //Commented by kumud  listOppty[0].Per_User__c=1000;
            update listOppty;
            
        } 
    }
    Private static testMethod void validateTaskCreation_2(){
        CreateCustomSetting();
        integer i=1;
        List<String> userRole=new List<String>{'Direct Sales (Event)','Survey','Venue Sourcing','TPP','Direct Sales (Ent)','AM (Ent)'};
        createUser('Survey',i);
        system.runAs(u){
            createAccount();
            List<PriceBookEntry> priceBookList = new List<PriceBookEntry>(createPricebookEntry());
            creatOpportunity(priceBookList);
            createFeatureset(priceBookList);
            createCard();
            createBundles();
            createAccountTeamMember();
            HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
            hybrid.Name='101';
            hybrid.HybridValue__c='Attendee Hub';
            insert hybrid;
            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].MSA_Code__c=mPropertyBundles.MSA_Code__c;
            listOppty[0].License_Type__c='Diamond Plus';
            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Promo Hub – Gold or Promo Hub- Silver';
            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Competitive Market Ad';
            Test.startTest();
            update listOppty;
            Test.stopTest();
        } 
    }
    Private static testMethod void validateTaskCreation_21(){
        CreateCustomSetting();
        integer i=1;
        createUser('Venue Sourcing',i);
        system.runAs(u){
            createAccount();
            List<PriceBookEntry> priceBookList = new List<PriceBookEntry>(createPricebookEntry());
            creatOpportunity(priceBookList);
            createFeatureset(priceBookList);
            createBundles();
            createAccountTeamMember();
            HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
            hybrid.Name='102';
            hybrid.HybridValue__c='Attendee Hub';
            insert hybrid;

            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Diamond Plus';
            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Promo Hub – Gold or Promo Hub- Silver';
            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Competitive Market Ad';
            Test.startTest();
            update listOppty;
            Test.stopTest();
        } 
    }
    Private static testMethod void validateTaskCreation_3(){
        CreateCustomSetting();
        integer i=2;
        createUser('Direct Sales (Event)',++i);
        system.runAs(u){
            createAccount();
            List<PriceBookEntry> priceBookList = new List<PriceBookEntry>(createPricebookEntry());
            creatOpportunity(priceBookList);
            createFeatureset(priceBookList);
            createCard();
            createBundles();
            createAccountTeamMember();
            HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
            hybrid.Name='103';
            hybrid.HybridValue__c='Attendee Hub';
            insert hybrid;

            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Supplier Feature - Enterprise Package';
            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Prepayment - Registrations Fee';
            listOppty[0].MYD_Deal__c='First Year';
            listOppty[0].NBB_Renewal__c='NBB';
            listOppty[0].ATI_Check__c =true;
            listOppty[0].of_Registrations__c =10;
            listOppty[0].Per_Registration_Fee__c =100;

            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Prepayment - Registrations Fee';
            listOppty[0].MYD_Deal__c='First Year';
            listOppty[0].NBB_Renewal__c='Renewal';
            listOppty[0].ATI_Check__c =true;
            listOppty[0].of_Registrations__c =10;
            listOppty[0].Per_Registration_Fee__c =100;
            Test.startTest();
            update listOppty;
            Test.stopTest();
        }
    }
    Private static testMethod void validateTaskCreation_3_Surveyrole(){
        CreateCustomSetting();
        integer i=3;
        createUser('Survey',++i);
        system.runAs(u){
            createAccount();
            List<PriceBookEntry> priceBookList = new List<PriceBookEntry>(createPricebookEntry());
            creatOpportunity(priceBookList);
            createFeatureset(priceBookList);
            createCard();
            createBundles();
            createAccountTeamMember();
            HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
            hybrid.Name='104';
            hybrid.HybridValue__c='Attendee Hub';
            insert hybrid;

            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='License-Basic';
            listOppty[0].MYD_Deal__c='First Year';
            listOppty[0].NBB_Renewal__c='NBB';
            listOppty[0].ATI_Check__c =true;
            listOppty[0].Early_Contract__c='Early';
            listOppty[0].Parent_Upsell__c='Primary';
            listOppty[0].OptOutDate__c=system.today();

            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='License-Basic';
            listOppty[0].MYD_Deal__c='First Year';
            listOppty[0].NBB_Renewal__c='Renewal';
            listOppty[0].ATI_Check__c =true;
            listOppty[0].Early_Contract__c='Early';
            listOppty[0].Parent_Upsell__c='Primary';
            listOppty[0].OptOutDate__c=system.today();

            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].Product__c='Survey';
            listOppty[0].License_Type__c='Professional Services';
            listOppty[0].MYD_Deal__c='First Year';
            listOppty[0].NBB_Renewal__c='NBB';
            listOppty[0].Parent_Upsell__c='Primary';
            listOppty[0].Early_Contract__c='Early';
            listOppty[0].ATI_Check__c =true;
            listOppty[0].OptOutDate__c=system.today();
            Test.startTest();
            update listOppty;
            Test.stopTest();
        }
    }
    Private static testMethod void validateTaskCreation_4(){
        CreateCustomSetting();
        integer i=10;
        createUser('Venue Sourcing',++i);
        system.runAs(u){
            createAccount();
            List<PriceBookEntry> priceBookList = new List<PriceBookEntry>(createPricebookEntry());
            creatOpportunity(priceBookList);
            createFeatureset(priceBookList);
            createBundles();
            createCard();
            createAccountTeamMember();
            HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
            hybrid.Name='105';
            hybrid.HybridValue__c='Attendee Hub';
            insert hybrid;

            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Mobile Events Solutions Fee';
            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Mobile Events Solutions Fee';
            listOppty[0].NBB_Renewal__c='Renewal';
            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Bundle';
            listOppty[0].NBB_Renewal__c='NBB';
            listOppty[0].Parent_Upsell__c='Primary';
            listOppty[0].MYD_Deal__c='First Year';
            listOppty[0].ATI_Check__c =true;
            Test.startTest();
            update listOppty;
            Test.stopTest();
        }
    }
    Private static testMethod void validateTaskCreation_4_AM(){
        CreateCustomSetting();
        integer i=5;
        createUser('AM (CrowdCompass)',++i);
        system.runAs(u){
            createAccount();
            List<PriceBookEntry> priceBookList = new List<PriceBookEntry>(createPricebookEntry());
            creatOpportunity(priceBookList);
            createFeatureset(priceBookList);
            createBundles();
            createCard();
            createAccountTeamMember();
            HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
            hybrid.Name='105';
            hybrid.HybridValue__c='Attendee Hub';
            insert hybrid;

            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Mobile Events Solutions Fee';
            listOppty[0].Parent_Upsell__c='Primary';
            listOppty[0].NBB_Renewal__c='Renewal';
            listOppty[0].ATI_Check__c =true;
            listOppty[0].MYD_Deal__c='First Year';
            listOppty[0].SignUp4_Conversion__c=True;
            Test.startTest();
            update listOppty;
            Test.stopTest();
        }
    }
    Private static testMethod void validateTaskCreation_4_AM_NoSignUp(){
        CreateCustomSetting();
        integer i=5;
        createUser('AM (CrowdCompass)',++i);
        system.runAs(u){
            createAccount();
            List<PriceBookEntry> priceBookList = new List<PriceBookEntry>(createPricebookEntry());
            creatOpportunity(priceBookList);
            createFeatureset(priceBookList);
            createBundles();
            createCard();
            createAccountTeamMember();
            HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
            hybrid.Name='106';
            hybrid.HybridValue__c='Attendee Hub';
            insert hybrid;
            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Mobile Events Solutions Fee';
            listOppty[0].Parent_Upsell__c='Primary';
            listOppty[0].NBB_Renewal__c='Renewal';
            listOppty[0].ATI_Check__c =true;
            Test.startTest();
            update listOppty;
            Test.stopTest();
        }
    }
    Private static testMethod void validateTaskCreation_PromoHubLicense(){
        CreateCustomSetting();
        integer i=11;
        createUser('Venue Sourcing',++i);
        system.runAs(u){
            createAccount();
            List<PriceBookEntry> priceBookList = new List<PriceBookEntry>(createPricebookEntry());
            creatOpportunity(priceBookList);
            createFeatureset(priceBookList);
            createBundles();
            createCard();
            createAccountTeamMember();
            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Promo Hub - Gold';
            listOppty[0].MYD_Deal__c='First Year';
            update listOppty;
        }
    }
    Private static testMethod void validateTaskCreation_5(){
        CreateCustomSetting();
        integer i=11;
        createUser('Venue Sourcing',++i);
        system.runAs(u){
            createAccount();
            List<PriceBookEntry> priceBookList = new List<PriceBookEntry>(createPricebookEntry());
            creatOpportunity(priceBookList);
            createFeatureset(priceBookList);
            createBundles();
            createCard();
            createAccountTeamMember();
            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Social Wall';
            update listOppty;
        }
    }
    Private static testMethod void validateTaskCreation_6(){
        CreateCustomSetting();
        integer i=5;
        createUser('Direct Sales (Ent)',++i);
        system.runAs(u){
            createAccount();
            List<PriceBookEntry> priceBookList = new List<PriceBookEntry>(createPricebookEntry());
            creatOpportunity(priceBookList);
            createFeatureset(priceBookList);
            createBundles();
            createCard();
            createAccountTeamMember();

            HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
            hybrid.Name='107';
            hybrid.HybridValue__c='Attendee Hub';
            insert hybrid;

            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Prepayment - Registrations Fee';
            listOppty[0].of_Registrations__c =10;
            listOppty[0].Per_Registration_Fee__c =100;
            listOppty[0].NBB_Renewal__c='Renewal';
            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Prepayment - Registrations Fee';
            listOppty[0].NBB_Renewal__c='NBB';
            listOppty[0].Parent_Upsell__c='Primary';
            listOppty[0].MYD_Deal__c='First Year';
            listOppty[0].of_Registrations__c =10;
            listOppty[0].Per_Registration_Fee__c =100;
            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Bundle';
            listOppty[0].NBB_Renewal__c='Renewal';
            listOppty[0].Parent_Upsell__c='Primary';
            listOppty[0].MYD_Deal__c='First Year';
            update listOppty;
        }  
    }
    
    Private static testMethod void validateTaskCreation_6_AMENT(){
        CreateCustomSetting();
        integer i=6;
        createUser('AM (Ent)',++i);
        system.runAs(u){
            createAccount();
            List<PriceBookEntry> priceBookList = new List<PriceBookEntry>(createPricebookEntry());
            creatOpportunity(priceBookList);
            createFeatureset(priceBookList);
            createCard();
            createBundles();
            createAccountTeamMember();

            HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
            hybrid.Name='108';
            hybrid.HybridValue__c='Attendee Hub';
            insert hybrid;

            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Prepayment - Registrations Fee';
            listOppty[0].of_Registrations__c =10;
            listOppty[0].Per_Registration_Fee__c =100;
            listOppty[0].NBB_Renewal__c='Renewal';
            listOppty[0].Parent_Upsell__c='Primary';
            listOppty[0].MYD_Deal__c='First Year';
            listOppty[0].SignUp4_Conversion__c=True;
            listOppty[0].OptOutDate__c=system.today();
            //listOppty[0].of_RFPs__c=10; // comment by kumud field cleanup activity
            listOppty[0].of_Total_Room_Nights_Committed__c=10;
            update listOppty;
        }  
    }
    Private static testMethod void validateTaskCreation_6_AMENT_NoSignUp(){
        CreateCustomSetting();
        integer i=12;
        createUser('AM (Ent)',++i);
        system.runAs(u){
            createAccount();
            List<PriceBookEntry> priceBookList = new List<PriceBookEntry>(createPricebookEntry());
            creatOpportunity(priceBookList);
            createFeatureset(priceBookList);
            createCard();
            createBundles();
            createAccountTeamMember();

            HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
            hybrid.Name='109';
            hybrid.HybridValue__c='Attendee Hub';
            insert hybrid;

            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Prepayment - Registrations Fee';
            listOppty[0].of_Registrations__c =10;
            listOppty[0].Per_Registration_Fee__c =100;
            listOppty[0].NBB_Renewal__c='Renewal';
            listOppty[0].Parent_Upsell__c='Primary';
            listOppty[0].MYD_Deal__c='First Year';
            update listOppty;
        }  
    }
    Private static testMethod void validateTaskCreation_7_VenueSourcing(){
        integer i=4;
        createUser('Venue Sourcing',++i);
        system.runAs(u){
            createAccount();
            List<PriceBookEntry> priceBookList = new List<PriceBookEntry>(createPricebookEntry());
            creatOpportunity(priceBookList);
            createFeatureset(priceBookList);
            createBundles();
            createCard();
            createAccountTeamMember();

            HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
            hybrid.Name='110';
            hybrid.HybridValue__c='Attendee Hub';
            insert hybrid;

            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='CSN Planner';
            listOppty[0].MYD_Deal__c='First Year';
            listOppty[0].NBB_Renewal__c='Renewal';
            listOppty[0].ATI_Check__c =true;
            listOppty[0].Early_Contract__c='Early';
            listOppty[0].Parent_Upsell__c='Primary';
            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='CSN Planner';
            listOppty[0].MYD_Deal__c='First Year';
            listOppty[0].NBB_Renewal__c='NBB';
            listOppty[0].Parent_Upsell__c='Primary';
            listOppty[0].Early_Contract__c='Early';
            listOppty[0].ATI_Check__c =true;
            update listOppty;
        }
    }
    
    
    
    Private static testMethod void validateTaskCreation_8_Bundle(){
        integer i=4;
        CreateCustomSetting();
        createUser('Venue Sourcing',++i);
        system.runAs(u){
            createAccount();
            List<PriceBookEntry> priceBookList = new List<PriceBookEntry>(createPricebookEntry());
            creatOpportunity(priceBookList);
            createFeatureset(priceBookList);
            createBundles();
            createCard();
            createAccountTeamMember();
            HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
            hybrid.Name='111';
            hybrid.HybridValue__c='Attendee Hub';
            insert hybrid;

            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Bundle';
            listOppty[0].MYD_Deal__c='First Year';
            listOppty[0].NBB_Renewal__c='Renewal';
            listOppty[0].Bundled_Package_Type__c='Bundled';
            listOppty[0].ATI_Check__c =true;
            listOppty[0].Early_Contract__c='Early';
            listOppty[0].Parent_Upsell__c='Upsell';

            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Bundle';
            listOppty[0].MYD_Deal__c='First Year';
            listOppty[0].NBB_Renewal__c='Renewal';
            listOppty[0].Bundled_Package_Type__c='Bundled';
            listOppty[0].ATI_Check__c =true;
            listOppty[0].Early_Contract__c='Early';
            listOppty[0].Parent_Upsell__c='Primary';

            listOppty[0].Contract_Implemented__c=true;
            listOppty[0].StageName='Closed Won';
            listOppty[0].License_Type__c='Bundle';
            listOppty[0].MYD_Deal__c='First Year';
            listOppty[0].NBB_Renewal__c='NBB';
            listOppty[0].Parent_Upsell__c='Primary';
            listOppty[0].Early_Contract__c='Early';
            listOppty[0].ATI_Check__c =true;
            listOppty[0].Bundled_Package_Type__c='Bundled';
            update listOppty;
        }
    }
    public static Account instofAcc = new Account();
    public static Contact instofCon =  new Contact();
    static testMethod void test()
    {
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        instofAcc.Name = 'Test';
        //instofAcc.CurrencyIsoCode  = 'USD';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        insert instofAcc;
        
        instOfCon.LastName = 'Test';
        instOfCon.AccountId = instofAcc.Id;
        insert instOfCon;
        
        Opportunity instOfOpp = new Opportunity();
        instOfOpp.AccountId = instofAcc.id;
        instOfOpp.Name = 'Test';
        instOfOpp.Product__c = 'Event';
        instOfOpp.New_Type__c =  'Upsell-NBB';
        instOfOpp.StageName = 'Verbal';
        instOfOpp.CloseDate = system.today();
        instOfOpp.New_Amount__c = 11;
        instOfOpp.Years__c= '1';
        instOfOpp.LeadSource = 'ACD-PS';
        instOfOpp.Contact_Associated__c = instOfCon.Id;
        instOfOpp.Contact_Role__c = 'Influencer';
        //instOfOpp.MSA_Code__c = lstMPB[0].MSA_Code__c;
        instOfOpp.Contract_Implemented__c = true;
        instOfOpp.ContractReceived__c = system.today();
        instOfOpp.Deal_Year__c = '1';
        instOfOpp.Case_Received_Date__c=system.today();
        insert instOfOpp;
        //instOfOpp.MSA_Code__c = lstMPB_New[0].MSA_Code__c;
       // instOfOpp.Name = 'Test1';
        //update instOfOpp;
        Delete instOfOpp;
        Database.undelete(instOfOpp.Id);
    }
     Private static testMethod void Test12(){
       integer i=40;
       CreateCustomSetting();
       createUser('Venue Sourcing',++i);
       system.runAs(u){
           createboard2();
           List<PriceBookEntry> priceBookList = new List<PriceBookEntry>(createPricebookEntry());
           creatOpportunity(priceBookList);
           createFeatureset(priceBookList);
           createBundles();
           createCard();
           createAccountTeamMember();
           HybridPicklistValue__c hybrid=new HybridPicklistValue__c();
           hybrid.Name='111';
           hybrid.HybridValue__c='Attendee Hub';
           insert hybrid;

           listOppty[0].Contract_Implemented__c=true;
           listOppty[0].StageName='Closed Won';
           listOppty[0].Bundled_Package_Type__c='Bundled';
           listOppty[0].ATI_Check__c =true;
           listOppty[0].Early_Contract__c='Early';
           

           listOppty[0].Contract_Implemented__c=true;
           listOppty[0].StageName='Closed Won';
           listOppty[0].Bundled_Package_Type__c='Bundled';
           listOppty[0].ATI_Check__c =true;
           listOppty[0].Early_Contract__c='Early';
           

           listOppty[0].Contract_Implemented__c=true;
           listOppty[0].StageName='Closed Won';
           listOppty[0].Early_Contract__c='Early';
           listOppty[0].ATI_Check__c =true;
           listOppty[0].Bundled_Package_Type__c='Bundled';
           //update listOppty;
       }
   }
   public static testMethod void testFake(){
   TaskAssignAutomationTrgHelper.fakeMethod();
   TaskAssignAutomationTrgHelper.fakeMethod1();
   TaskAssignAutomationTrgHelper.fakeMethod2();
   TaskAssignAutomationTrgHelper.fakeMethod3();
   TaskAssignAutomationTrgHelper.fakeMethod4();
   
}
}