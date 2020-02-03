@isTest
private class DG_DFR_Class_TEST{ 
    
  static testMethod void CreateLeadDFR() {
    
      test.startTest();
       
        Country_Phone_Codes__c setting = new Country_Phone_Codes__c();
        setting.Name = 'IN';
        setting.ISD_Code__c = '91';
        insert setting;

      List<Lead> listLead = new List<Lead>();
          
      //Created as Suspect  
      Lead s1 = new Lead(        
        CC_Lead_Status__c = 'Suspect',
          LeadSource = 'Other', 
          Phone = '+1.213.111.1111', 
          LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net',CountryCode='IN',Other_Phone__c='039474464',MobilePhone='039474464');
          
      
       listLead.add(s1);
      
       //Created as Suspect  
       Lead s2 = new Lead(        
         SMM_Lead_Status__c = 'Suspect',
          LeadSource = 'Other', 
          Phone = '+1.213.111.1111', 
          LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
      
    listLead.add(s2);
      
      //Created as Suspect  
      Lead s3 = new Lead(        
          Event_Lead_Status__c = 'Suspect',
          LeadSource = 'Other', 
          Phone = '+1.213.111.1111', 
          LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
      
      listLead.add(s3);
      
      //Created as Suspect  
       Lead s4 = new Lead(        
          CSN_S_Lead_Status__c = 'Suspect',
          LeadSource = 'Other', 
          Phone = '+1.213.111.1111', 
          LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
      
      listLead.add(s4);
      
      //Created as Inquiry
      Lead p1 = new Lead(
          Inquisium_Lead_Status__c = 'Inquiry',
          LeadSource = 'Other', 
          Phone = '+1.213.111.1111', 
          LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
        
      listLead.add(p1);
      
      //Created as Inquiry
      Lead p2 = new Lead(
          CSN_P_Lead_Status__c = 'Inquiry',
          LeadSource = 'Other', 
          Phone = '+1.213.111.1111', 
          LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
        
      listLead.add(p2);
      
      //Created as Inquiry
      Lead p3 = new Lead(
          CC_Lead_Status__c = 'Inquiry',
          LeadSource = 'Other', 
          Phone = '+1.213.111.1111', 
          LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
        
      listLead.add(p3);
      
      //Created as Inquiry
      Lead p4 = new Lead(
          SMM_Lead_Status__c = 'Inquiry',
          LeadSource = 'Other', 
          Phone = '+1.213.111.1111', 
          LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
        
      listLead.add(p4);
      
      //Created as MQL
      Lead m1 = new Lead(
          Event_Lead_Status__c = 'Marketing Qualified',
          LeadSource = 'Other', 
            Phone = '+1.213.111.1111', 
           LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
        
    listLead.add(m1);
      
      //Created as MQL
      Lead m2 = new Lead(
          CSN_S_Lead_Status__c = 'Marketing Qualified',
          LeadSource = 'Other', 
          Phone = '+1.213.111.1111', 
          LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
        
      listLead.add(m2);
      
      //Created as MQL
      Lead m3 = new Lead(
          Inquisium_Lead_Status__c = 'Marketing Qualified',          
          LeadSource = 'Other', 
          Phone = '+1.213.111.1111', 
          LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
        
      listLead.add(m3);
        
      //Created as Sales Accepted
      Lead w1 = new Lead(
          CSN_P_Lead_Status__c = 'Sales Accepted',          
          LeadSource = 'Other', 
          Phone = '+1.213.111.1111', 
          LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
        
      listLead.add(w1);
      
      //Created as Sales Accepted
      Lead w2 = new Lead(
          CC_Lead_Status__c = 'Sales Accepted',          
          LeadSource = 'Other', 
           Phone = '+1.213.111.1111', 
          LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
        
      listLead.add(w2);
      
      //Created as Sales Qualified
      Lead q1 = new Lead(
          SMM_Lead_Status__c = 'Sales Qualified',          
          LeadSource = 'Other', 
           Phone = '+1.213.111.1111', 
          LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
        
      listLead.add(q1);
                   
        database.insert(listLead, true);
      
      test.stopTest();
      
      //Suspect to Inquiry
      s1.CC_Lead_Status__c = 'Inquiry';
      
      //Suspect to MQL
      s2.SMM_Lead_Status__c = 'Marketing Qualified';
      
      //Suspect to Sales Accepted
      s3.Event_Lead_Status__c = 'Sales Accepted';
      
      //Suspect to Sales Qualified
      s4.CSN_S_Lead_Status__c = 'Sales Qualified';
                  
      //Inquiry to MQL
      p1.Inquisium_Lead_Status__c = 'Marketing Qualified';
      
      //Inquiry to Sales Accepted
      p2.CSN_P_Lead_Status__c = 'Sales Accepted';
      
      //Inquiry to Sales Accepted
      p3.CC_Lead_Status__c = 'Sales Qualified';
            
      //Inquiry to Nurture
      p4.SMM_Lead_Status__c = 'Recycle';
      
      //MQL to Sales Accepted
      m1.Event_Lead_Status__c = 'Sales Accepted';      
      
      //MQL to Sales Qualified
      m2.CSN_S_Lead_Status__c = 'Sales Qualified';
      
      //MQL to Recyle
      m3.Inquisium_Lead_Status__c = 'Recycle';
      
      //Sales Accepted to Sales Qualified
      w1.CSN_P_Lead_Status__c = 'Sales Qualified';
            
      //Sales Accepted to Recycle
      w2.CC_Lead_Status__c = 'Recycle';             
      
      //Sales Qualified to Recycle
      q1.SMM_Lead_Status__c = 'Recycle';  
      
      database.update(listLead, true);
    }
    
     static testMethod void DFR_ContactStatusChange_Test() {   
     Country_Phone_Codes__c setting = new Country_Phone_Codes__c();
        setting.Name = 'IN';
        setting.ISD_Code__c = '91';
        insert setting;   
      Account a = new Account(
          Name = 'test account a',
            AccountNumber = 'TestAcct a',
            BillingCountryCode = 'IN',
            Phone = '9716549377'
        );
        
        insert a;
        
        List<Contact> newContacts = new List<Contact>();
                     
    Contact s1 = new Contact(
          CC_Contact_Status__c = 'Suspect', 
          LastName = 'last_a',
          FirstName = 'first_a',
          Email = 'contacta@testURL.com',
          AccountId = a.id);              
        newContacts.add(s1);
        
        Contact s2 = new Contact(
          SMM_Contact_Status__c = 'Suspect',
          LastName = 'last_a',
          FirstName = 'first_a',
          Email = 'contacta@testURL.com',
          AccountId = a.id);               
        newContacts.add(s2);
        
        Contact s3 = new Contact(
          Event_Contact_Status__c = 'Suspect',
          LastName = 'last_a',
          FirstName = 'first_a',
          Email = 'contacta@testURL.com',
          AccountId = a.id);               
        newContacts.add(s3);
        
        Contact s4 = new Contact(
          CSNS_Contact_Status__c  = 'Suspect',
          LastName = 'last_a',
          FirstName = 'first_a',
          Email = 'contacta@testURL.com',
          AccountId = a.id);               
        newContacts.add(s4);
        
        Contact p1 = new Contact(
          Survey_Contact_Status__c = 'Inquiry',
          LastName = 'last_a',
          FirstName = 'first_a',
          Email = 'contacta@testURL.com',
          AccountId = a.id);                   
    newContacts.add(p1);
        
        Contact p2 = new Contact(
          CSN_P_Contact_Status__c = 'Inquiry',
          LastName = 'last_a',
          FirstName = 'first_a',
          Email = 'contacta@testURL.com',
          AccountId = a.id);               
        newContacts.add(p2);
        
        Contact p3 = new Contact(
          CC_Contact_Status__c = 'Inquiry',
          LastName = 'last_a',
          FirstName = 'first_a',
          Email = 'contacta@testURL.com',
          AccountId = a.id);                  
        newContacts.add(p3);
        
        Contact p4 = new Contact(
          SMM_Contact_Status__c = 'Inquiry',
          LastName = 'last_a',
          FirstName = 'first_a',
          Email = 'contacta@testURL.com',
          AccountId = a.id,MailingCountry = 'IN',Phone='9716549377',MobilePhone='9716549377',OtherPhone='9716549377');                  
        newContacts.add(p4);
        
        Contact m1 = new Contact(
          Event_Contact_Status__c = 'Marketing Qualified',
          LastName = 'last_a',
          FirstName = 'first_a',
          Email = 'contacta@testURL.com',
          AccountId = a.id);                  
        newContacts.add(m1);
        
        Contact m2 = new Contact(
          CSNS_Contact_Status__c = 'Marketing Qualified',
          LastName = 'last_a',
          FirstName = 'first_a',
          Email = 'contacta@testURL.com',
          AccountId = a.id);                  
        newContacts.add(m2);
        
        Contact m3 = new Contact(
          Survey_Contact_Status__c = 'Marketing Qualified',
          LastName = 'last_a',
          FirstName = 'first_a',
          Email = 'contacta@testURL.com',
          AccountId = a.id);                  
        newContacts.add(m3);
        
        Contact w1 = new Contact(
          CSN_P_Contact_Status__c = 'Sales Accepted',
          LastName = 'last_a',
          FirstName = 'first_a',
          Email = 'contacta@testURL.com',
          AccountId = a.id);                 
        newContacts.add(w1);
        
        Contact w2 = new Contact(
          CC_Contact_Status__c = 'Sales Accepted',
          LastName = 'last_a',
          FirstName = 'first_a',
          Email = 'contacta@testURL.com',
          AccountId = a.id);                 
        newContacts.add(w2);        
        
        Contact q1 = new Contact(
          SMM_Contact_Status__c = 'Sales Qualified',
          LastName = 'last_a',
          FirstName = 'first_a',
          Email = 'contacta@testURL.com',
          AccountId = a.id);                 
        newContacts.add(q1);
        
             
        database.insert(newContacts, true);
        
      //Suspect to Inquiry
      s1.CC_Contact_Status__c = 'Inquiry';
      
      //Suspect to MQL
      s2.SMM_Contact_Status__c = 'Marketing Qualified';
      
      //Suspect to Sales Accepted
      s3.Event_Contact_Status__c = 'Sales Accepted';
      
      //Suspect to Sales Qualified
      s4.CSNS_Contact_Status__c = 'Sales Qualified';
                  
      //Inquiry to MQL
      p1.Survey_Contact_Status__c = 'Marketing Qualified';
      
      //Inquiry to Sales Accepted
      p2.CSN_P_Contact_Status__c = 'Sales Accepted';
      
      //Inquiry to Sales Accepted
      p3.CC_Contact_Status__c = 'Sales Qualified';
            
      //Inquiry to Nurture
      p4.SMM_Contact_Status__c = 'Recycle';
      
      //MQL to Sales Accepted
      m1.Event_Contact_Status__c = 'Sales Accepted';      
      
      //MQL to Sales Qualified
      m2.CSNS_Contact_Status__c = 'Sales Qualified';
      
      //MQL to Recyle
      m3.Survey_Contact_Status__c = 'Recycle';
      
      //Sales Accepted to Sales Qualified
      w1.CSN_P_Contact_Status__c = 'Sales Qualified';
            
      //Sales Accepted to Recycle
      w2.CC_Contact_Status__c = 'Recycle';  
      
      //Sales Qualified to Recycle
      q1.SMM_Contact_Status__c = 'Recycle'; 
        
    database.update(newContacts, true);
    }
     
    static testMethod void DFR_LeadConversion_Test() {
      test.startTest();
      
        List<Lead> listLead = new List<Lead>();
                
      //Created as Inquiry
      Lead p1 = new Lead(
          Inquisium_Lead_Status__c = 'Inquiry',
          LeadSource = 'Other', 
          Phone = '+1.213.111.1111', 
          LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
        
      listLead.add(p1);
      
      //Created as MQL
      Lead m1 = new Lead(
          Event_Lead_Status__c = 'Marketing Qualified',
          LeadSource = 'Other', 
            Phone = '+1.213.111.1111', 
           LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
        
    listLead.add(m1);
        
      //Created as Sales Accepted
      Lead w1 = new Lead(
          CSN_P_Lead_Status__c = 'Sales Accepted',          
          LeadSource = 'Other', 
          Phone = '+1.213.111.1111', 
          LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
        
      listLead.add(w1);
      
      //Created as Sales Qualified
      Lead q1 = new Lead(
          SMM_Lead_Status__c = 'Sales Qualified',          
          LeadSource = 'Other', 
           Phone = '+1.213.111.1111', 
          LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
        
      listLead.add(q1);
      
        database.insert(listLead, true);
      
        test.stopTest();
      
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
      
      List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();    
    
      for(Lead l : listLead){
          Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(l.Id);
            lc.setDoNotCreateOpportunity(true);    
            lc.setConvertedStatus(convertStatus.MasterLabel);
            //lc.setConvertedStatus('Qualified');
            leadConverts.add(lc);  
      }
    
      List<Database.LeadConvertResult> lcrList = Database.convertLead(leadConverts, true);
    
      for (Database.LeadConvertResult lcr : lcrList) {
            if (!lcr.isSuccess()) {        
              System.debug('Convert Error: ' + lcr.getErrors());       
          }
      }      
    }
    
  static testMethod void DFR_OpportunityStageChange_Test() {
      test.startTest();
      
        List<Lead> listLead = new List<Lead>();
        list<String> listProd = new list<String>{'Inquisium','Event','Venue Sourcing','CrowdCompass'};
                
      //Created as Inquiry
      Lead p1 = new Lead(
          Inquisium_Lead_Status__c = 'Inquiry',
          LeadSource = 'Other', 
          Phone = '+1.213.111.1111', 
          LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
        
      listLead.add(p1);
      
      //Created as MQL
      Lead m1 = new Lead(
          Event_Lead_Status__c = 'Marketing Qualified',
          LeadSource = 'Other', 
            Phone = '+1.213.111.1111', 
           LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
        
    listLead.add(m1);
        
      //Created as Sales Accepted
      Lead w1 = new Lead(
          CSN_P_Lead_Status__c = 'Sales Accepted',          
          LeadSource = 'Other', 
          Phone = '+1.213.111.1111', 
          LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
        
      listLead.add(w1);
      
      //Created as Sales Qualified
      Lead q1 = new Lead(
          SMM_Lead_Status__c = 'Sales Qualified',          
          LeadSource = 'Other', 
           Phone = '+1.213.111.1111', 
          LastName = 'TEST', 
          FirstName = 'TEST', 
          Company = 'Test Company',
          Email = 'atest@test.net');
        
      listLead.add(q1);
      
        database.insert(listLead, true);
      
        test.stopTest();
      
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
      
      List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();    
    
      for(Lead l : listLead){
          Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(l.Id);
            lc.setDoNotCreateOpportunity(true);    
            lc.setConvertedStatus(convertStatus.MasterLabel);
            leadConverts.add(lc);  
      }
    
      List<Database.LeadConvertResult> lcrList = Database.convertLead(leadConverts, true);
    
      for (Database.LeadConvertResult lcr : lcrList) {
            if (!lcr.isSuccess()) {        
              System.debug('Convert Error: ' + lcr.getErrors());       
          }
      }  
    
      list<Opportunity> listOpp = new list<Opportunity>();
      
      Integer x = 0;
    
      for (Database.LeadConvertResult lcr : lcrList){
        listOpp.clear();
          Opportunity o = new Opportunity();
          o.License_Type__c = 'Diamond Plus';
          o.Contract_Type_Test__c = 'Renewal';
          o.Counted_sales_Cancellation_Value__c =110;
          o.Liquidation_Fee__c  = 10;
          o.OptOutDate__c = system.today();
          o.Opp_End_Date__c  = system.today();
          o.AccountId = lcr.getAccountId();
          o.Name = 'DFR Test Opp';
          o.Product__c = 'Onsite Solutions';
          o.Product_Category__c = 'Event';
          o.Contract_Number_New__c = '25515';
          o.New_Type__c =  'Upsell-NBB';
          o.StageName = 'Prospect';
          o.CloseDate = system.today();
          o.RecordTypeId = '0120000000097UY';
          o.Year_1_at_Risk__c = 11;
          o.New_Type__c = 'Test';
          o.Deal_Booked_In__c = '1';
          //o.Price_per_lead__c = 1;
          o.Years__c= '1';
          o.LeadSource = 'ACD-PS';
          o.Contact_Associated__c = lcr.getContactId();
          o.Contact_Role__c = 'Primary User';
          //o.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
          o.Contract_Implemented__c = true;
          o.ContractReceived__c = system.today();
          o.MYD_Deal__c = 'First Year';
          o.Deal_Year__c = '2';
          o.New_Amount__c = 1000;
          o.Parent_Upsell__c = 'Primary';
          o.Send_This_To_Tract__c = true;          
          o.Forex_rate__c = 1;
          //o.Price_per_lead__c = 1;
          o.Clubbed_Opportunity__c = true;
         // o.Clubbed_Tract_Billing_Account__c = 'abcd1234'; // Comment by kumud
          listOpp.add(o); 
      }

      Database.SaveResult[] srInsert = database.insert(listOpp, true);
      system.debug('### Opp Insert:' + listOpp.size());
      
      map<Id, Opportunity> mapOpportunity = new map<Id, Opportunity>();
      list<String> listOppStage = new list<String>{'Closed Won','Closed Lost','Closed Won','Closed Lost'};
        
        Integer os = 0;
        
      for (Database.SaveResult sr : srInsert) {
        if (!sr.isSuccess()) {  
 
            System.debug('Opportunity Insert Error: ' + sr.getId());       
            
              for(Database.Error err : sr.getErrors()) {                  
                  System.debug('Opportunity Insert Error: ' + err.getMessage() + ' * ' + err.getFields() + ' * ' + err.getStatusCode());
              }
          }else{
                     
            mapOpportunity.put(sr.getId(), new Opportunity(Id = sr.getId(), StageName = listOppStage[os], ContractReceived__c = date.today(), ContractStartDate__c = date.today()));
            os = os + 1;  
          }
      }
      
      Database.SaveResult[] srUpdate = database.update(mapOpportunity.values(), true);
      
      for (Database.SaveResult sr : srUpdate) {
        if (!sr.isSuccess()) {     
            System.debug('Opportunity Map Update Error: ' + sr.getId());       
            
              for(Database.Error err : sr.getErrors()) {                  
                  System.debug('Opportunity Map Update Error: ' + err.getMessage() + ' * ' + err.getFields() + ' * ' + err.getStatusCode());
              }
          }
      }
      
      DG_DFR_Class.fakeMethod();
      
      
      Lead q11 = new Lead();
          q11.SMM_Lead_Status__c = 'Sales Qualified';
          q11.LeadSource = 'Other';
           q11.Phone = '+1.213.111.1111'; 
          q11.LastName = 'TEST'; 
          q11.FirstName = 'TEST';
          q11.Company = 'Test Company';
          q11.Email = 'atest@test.net';
        
      insert q11;
                   
      delete q11;      
      
    }
}