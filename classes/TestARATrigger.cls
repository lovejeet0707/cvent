@Istest



// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 02/03/2016
// PURPOSE     :  To handle trigger methods
// CLASS :   ARATriggerHandler
// SPECIAL NOTES:
// ===============================


private class TestARATrigger
{
//      
        @testsetup 
        static void TestOpenARA() {
        
            
            
            
            Account acct = new Account(name='test account',Emergency_Notes__c='Testing emergency notes');
            insert acct;
            
            Contact instOfCon = new Contact();
            instOfCon.LastName = 'Test';
            instOfCon.AccountId = acct.Id;
            insert instOfCon;
            
            Opportunity instOfOpp = new Opportunity();
            instOfOpp.AccountId = acct.id;
            instOfOpp.Name = 'Test';
            instOfOpp.Product__c = 'Event';
            instOfOpp.New_Type__c =  'Upsell-NBB';
            instOfOpp.StageName = 'Verbal';
            instOfOpp.CloseDate = system.today();
            instOfOpp.New_Amount__c = 11;
            instOfOpp.Years__c= '1';
            instOfOpp.LeadSource = 'ACD-PS';
            instOfOpp.Contact_Associated__c = instOfCon.Id;
            instOfOpp.Contact_Role__c = 'Primary User';
            instOfOpp.Contract_Implemented__c = true;
            instOfOpp.ContractReceived__c = system.today();
            instOfOpp.Deal_Year__c = '1';
            insert instOfOpp;
            
            ARA__c araobj =new ARA__c();
            araobj.Status__c='Open';
            araobj.ARA_Emergency_Notes__c='Test Emergrncy notes';
            araobj.Account__C=acct.id;
            araobj.Opportunity__c = instOfOpp.Id;
            
            Test.startTest();  
           // insert araobj;
                   
            
            
            
            araobj.Status__c='Closed-Lost';
            //update araobj;
            Test.stopTest();
        
        }
        
        static testMethod void TestClosedARA() {

            //Account acct = new Account(name='test account',Emergency_Notes__c='Testing emergency notes');
            //insert acct;
            Account acct = [Select Id From Account Limit 1];
           
            Id pId = [Select Id From Profile WHere name= 'System Administrator'].Id;
            User adminUsr = [ Select Id From User Where  isActive = True and ProfileId =:pId Limit 1];
            
            
            ARA__c araobj =new ARA__c();
            araobj.Status__c='Open';
            araobj.ARA_Emergency_Notes__c='Test Emergrncy notes';
            araobj.Assigned_To__c = UserInfo.GetUserId();
            araobj.Account__C=acct.id;
    
                Test.startTest();  
                
                   system.RunAs(adminUsr){
                       insert araobj;
                       araobj.Status__c='Closed Won';
                       araobj.ARA_Emergency_Notes__c='hello test';
                       araobj.Status__c='Open';
                       update araobj;
                   }
                Test.stopTest();
        }
}