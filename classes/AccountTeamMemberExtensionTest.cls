// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE : 22/03/2016
// PURPOSE     :  Test Class for "AccountTeamMemberExtension"
// ===============================

@isTest
public class AccountTeamMemberExtensionTest{
     
    public static Account instofAcc = new Account();
    public static List<Account> listOfAcc=new List<Account>();
    public static Contact instofCon =  new Contact();
    public static AccountTeamMember  instofAccMember =  new AccountTeamMember ();
     public static List<AccountTeamMember>  listofAccMember =  new List<AccountTeamMember> ();
    public static Opportunity  instOfOpp = new Opportunity();


    static{
        
        
        
        //Inserting User...............
        Profile p = [SELECT Id FROM Profile WHERE Name='Finance - Management']; 

        USerrole[] testroleId=[select id from userRole where name ='AM (Event)' OR name ='Pre Sales - Special Projects' limit 2];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Sops', LanguageLocaleKey='en_US', FirstName='TestUser',
        LocaleSidKey='en_US', ProfileId = p.Id, userRoleId=testroleId[0].id,
        TimeZoneSidKey='America/Los_Angeles', UserName='Test'+'deploymentuser@cvent.com');
        
        insert u;
        
        /*User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Sops', LanguageLocaleKey='en_US', FirstName='TestUser',
        LocaleSidKey='en_US', ProfileId = p.Id, userRoleId=testroleId[0].id,
        TimeZoneSidKey='America/Los_Angeles', UserName='Test1'+'deploymentuser@cvent.com');
        insert u1;*/
        system.runAs(u){
        
            
              // custom setting for opportunity insert
            UserAssignment__c instUA = new UserAssignment__c();
            instUA.Name = 'OnArrival';
            instUA.User_id__c = userinfo.getUserID();
            instUA.UserName__c = 'Brett Wischow';
            insert instUA;
    
            instofAcc = TestUtil.createAccount('Test Account 1','Biz_Ac');
            instofAcc.Supplier_Type__c = 'Venue';
            instofAcc.Venue_Type__c = 'CVB';
            listOfAcc.add(instofAcc);
            
            instofAcc = TestUtil.createAccount('Test Account 2','Biz_Ac');
            instofAcc.Name = 'Test3';
            instofAcc.Supplier_Type__c = 'Venue';
            instofAcc.Venue_Type__c = 'CVB';
            listOfAcc.add(instofAcc);
            
            insert listOfAcc;
            
            instOfCon.LastName = 'Test';
            instOfCon.AccountId = instofAcc.Id;
            insert instOfCon;
                
            instOfOpp  = TestUtil.createOpportunityNew('Test Opportunity','Verbal',instOfCon.Id,instofAcc.Id); 
            //instOfOpp.AccountId = instofAcc.id;
            //instOfOpp.Name = 'Test';
            instOfOpp.Product__c = 'Event';
            instOfOpp.New_Type__c =  'Upsell-NBB';
            //instOfOpp.StageName = 'Verbal';
            instOfOpp.CloseDate = system.today();
            instOfOpp.New_Amount__c = 11;
            instOfOpp.Years__c= '1';
            instOfOpp.LeadSource = 'ACD-PS';
            //instOfOpp.Contact_Associated__c = instOfCon.Id;
            //instOfOpp.Contact_Role__c = 'Primary User';
            instOfOpp.ContractReceived__c = system.today();
            instOfOpp.Deal_Year__c = '1';
            instOfOpp.Logo_Classification__c = 'True New Logo';
            insert instOfOpp;
            
            system.debug('*****UserInfo.GetUserId()*******'+UserInfo.GetUserId());
            
            instofAccMember.AccountId = listOfAcc[0].Id;
            instofAccMember.TeamMemberRole = 'Multi-Product';
            instofAccMember.UserId = UserInfo.GetUserId();
            listofAccMember.add(instofAccMember);
            
            instofAccMember=new AccountTeamMember();
            instofAccMember.AccountId = listOfAcc[1].Id;
            instofAccMember.TeamMemberRole = 'Multi-Product';
            instofAccMember.UserId = u.id;
            listofAccMember.add(instofAccMember);
            insert listofAccMember;
        
        }
        
    }
    
    static testmethod void createTest1(){
       
        PageReference pr = Page.AccountTeamMemberPage;
        pr.getParameters().put('id',instofAcc.Id);
        Test.SetCurrentPage(pr);
        System.Debug('***** pr **** '+ pr);
        ApexPages.currentPage().getParameters().put('newid',instofAcc.Id);
        ApexPages.StandardController stdCtr = new ApexPages.StandardController(instofAcc);
        System.Debug('***** instofAcc **** '+ instofAcc);
        AccountTeamMemberExtension accExt = new AccountTeamMemberExtension(stdCtr);
        
        User u = [Select Id From User Where Profile.Name = 'System Administrator' and isActive =true and UserName !='deploymentuser@cvent.com' Limit 1 ];
        
        system.runAs(u){
            accExt.AddTeam();
        
            accExt.SendAMAlert();
        }
        //accExt.UpdateAMFieldsonAccount();
    
    }
    


}