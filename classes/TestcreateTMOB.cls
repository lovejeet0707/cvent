//================================================================================================================================
        //Created By Rishi Ojha
        //Test class for the trigger on Opportunity : createTMOB
        //Unit testing for the child records creation on TM onboarding.
        //==================================================================================================================================
        
        @Istest(SeeAllData=True)
        public class TestcreateTMOB
        
        {
        public static testmethod void testcreateTMOBtrigger()
        
        {
        
        Account Acc = New Account (Name = 'testacc');
        insert Acc;
        
            Opportunity Opp=new Opportunity();
            Opp.Name='Oppabc';
            Opp.Type='New Manufacture';
            Opp.New_Type__c='test';
            Opp.StageName='Closed Won';
            Opp.CloseDate=Date.today();
            Opp.Product__c='Tickettest';
            Opp.Rating__c ='Test';
            Opp.Contract_Implemented__c = True;
            Opp.ContractReceived__c = system.today();
            Opp.Deal_Year__c = '1';
            insert Opp;
            
               TM_Buildout__c tm = new TM_Buildout__c ();
               tm.Name = opp.Id;
               tm.Name = opp.Account_Name_TM__c;
               insert tm;
               
               tm = [ Select Id, Name from TM_Buildout__c where id=:tm.id ];
               
             //  Opp = [Select Id, Name, StageName,Product__c from Opportunity where StageName = 'Closed Won' ];
               Update Opp;
             
     
        }
        
        
        }