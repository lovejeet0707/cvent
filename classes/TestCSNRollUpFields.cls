@isTest
public class TestCSNRollUpFields {

    static testMethod void myUnitTest() {

        Profile pf = [Select Id from Profile where Name = 'System Administrator'];

        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        insert u;

        system.runAs(u){

            Account o = new Account();
            o.Name = 'Test Account';
          //  o.of_Total_RFP_s_Received_New1__c = null;
         //   o.Value_of_RFPs_Received_New__c = null;
            insert o;
            
          //  system.assertEquals(o.of_Total_RFP_s_Received_New1__c, null);
      
            //Test payments on insert
            RFP__c p1 = new RFP__c();
            p1.Supplier_Account__c = o.Id;
            p1.Name = 'Test RFP';
            p1.RFP_Code__c = 'Test Code';
            p1.Unique_Code__c = 'Test Unique Code';
            p1.Status__c = 'Awarded';
            p1.RFP_Type__c = 'Request for Information';          
            insert p1;
            
            Account ou1 = [select name from Account where Id =:o.Id];
          //  System.AssertEquals(ou1.of_Total_RFP_s_Received_New1__c,null);

            //Test payments on update

            RFP__c p1u = [select Awarded_Value__c from RFP__c where Id = :p1.Id];
            p1u.Budgeted_Room_Rate__c = 0;
            update p1u;
            
            Account ou2 = [select name from Account where Id = :o.Id];
           // system.assertEquals(ou2.of_Total_RFP_s_Received_New1__c, null);

            //Test payments on second insert
            RFP__c p2 = new RFP__c();
            p2.Supplier_Account__c = o.Id;
            p2.Name = 'Test RFP2';
            p2.RFP_Code__c = 'Test Code2';
            p2.Unique_Code__c = 'Test Unique Code2';
            p2.Status__c = 'Awaiting Proposal';
            p2.RFP_Type__c = 'Request for Information';
            insert p2;

            Account ou3 = [select name from Account where Id =:o.Id];
          //  System.AssertEquals((Double)ou3.of_Total_RFP_s_Received_New1__c,null);
    
            //Test payment on delete
            delete p2;

            Account ou4 = [select name from Account where Id = :o.Id];
          //  System.AssertEquals(ou4.of_Total_RFP_s_Received_New1__c,null);

        }

    }

}