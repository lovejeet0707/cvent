@isTest
private class AddressValidatorTest {
    
    public static Account instofAcc = new Account();
    public static List<Contact> instofConList =  new List<Contact>();
    
    
    @isTest static void testCallout() {
        
        //enable sync
        ByPassTrigger__c bp = new ByPassTrigger__c();
        bp.SetupOwnerId = UserInfo.getUserId();
        bp.Enable_EBS_Sync__c =true;
        insert bp;
        
        EBS_Integration__c eIntegration = TestUtil.createEbsIntegration('Address Integration','Address__c');
        eIntegration.Field__c = 'City__c';
		insert eIntegration;
        
        AddressValidationUsers__c setting = new AddressValidationUsers__c();

        User u = [Select Id From User Where Name like '%deployment%' limit 1];
        setting.SetupOwnerId = u.Id;
        insert setting;
        System.debug('user>>>'+u);        
        SBQQ__Quote__c quote;
        
        system.RunAs(u){
        
            CountryCode__c country = new CountryCode__c();
            country.Name = 'US';
            country.Code__c  = 'United States';
            insert country;
            
            Id rtTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
            instofAcc.Name = 'Test';
            instofAcc.Supplier_Type__c = 'Venue';
            instofAcc.Venue_Type__c = 'CVB';
            instofAcc.RecordTypeId = rtTypeId ;
            instofAcc.BillingCountry = 'US';
            instofAcc.BillingState='PA';
            insert instofAcc;
            
            
            Contact instOfCon = new Contact();
            instOfCon.LastName = 'Test 1';
            instOfCon.AccountId = instofAcc.Id;
            
            Contact instOfCon2 = new Contact();
            instOfCon2.LastName = 'Test 2';
            instOfCon2.AccountId = instofAcc.Id;
            
            instofConList.add(instOfCon);
            instofConList.add(instOfCon2);
            insert instofConList;
            
            AddressValidator__c add = new AddressValidator__c();
            add.Name = '1';
            add.FormatType__c = 'ALL' ;
            add.Login_Id__c = '165520';
            add.MatchingScope__c = 'LOCALITY_LEVEL' ;
            add.Password__c= 'im22NUdN';
            add.Rest_URL__c= 'https://rest-adcloud.informaticadaas.com/adcloud/verifyaddress?';
            insert add;
            
            set<id> setId=new set<Id>();
            Address__c sAddress = new Address__c();
            sAddress.Type__c = 'Shipping';
            sAddress.Account__c = instofAcc.Id;
            saddress.City__c='Burnaby';
            saddress.Province__c='BC';
            saddress.Country__c='US';
            saddress.CountryCode__c='US';
            saddress.Postal_Code__c = '1001';
            saddress.EBS_Site_Use_Id__c=null;
            sAddress.EBS_Account_Id__c = instofAcc.Id;
            insert sAddress;
            setId.add(sAddress.id);
            
            Opportunity instOfOpp = new Opportunity();
            instOfOpp.AccountId = instofAcc.id;
            instOfOpp.Name = 'Test';
            instOfOpp.Product__c = 'TicketMob';
            instOfOpp.NBB_Renewal__c = 'NBB';
            instOfOpp.Parent_Upsell__c = 'Primary';
            instOfOpp.MYD_Deal__c = 'First Year';
            instOfOpp.New_Type__c =  'Upsell-NBB';
            instOfOpp.StageName = 'Closed Won';
            instOfOpp.CloseDate = system.today();
            instOfOpp.New_Amount__c = 11;
            instOfOpp.Years__c= '1';
            instOfOpp.LeadSource = 'ACD-PS';
            instOfOpp.Contact_Associated__c = instofConList.get(0).Id;
            instOfOpp.Contact_Role__c = 'Influencer';
            instOfOpp.Contract_Implemented__c = true;
            instOfOpp.ContractReceived__c = system.today();
           // instOfOpp.Web_Design_Support_Minutes_Purchased__c =0; comment by kd
            instOfOpp.Deal_Year__c = '1';
            instOfopp.Ship_To_Address__c = sAddress.Id;
            insert instOfOpp;
            
            quote = new SBQQ__Quote__c();
            quote.Effective_Year_1_Start_Date__c =  system.today();
            quote.Contract_Term_Years__c = '1';
            quote.Effective_Year_1_End_Date__c  = system.today()+50;
            quote.SBQQ__Opportunity2__c = instofOpp.Id;
            insert quote;
            

            
            // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new AddressValidatorMockGenerator());
            
            //change address
            saddress.Postal_Code__c = '122002';            
            update saddress;
            
            
            // Call method to test.
            // This causes a fake response to be sent
            // from the class that implements HttpCalloutMock. 
            boolean isValid = AddressValidator.validateAddress(quote.Id);
            
              Test.StartTest();
           AddressValidator.validateShippingAddressBulk(setId);
           Test.StopTest();
        }

    }
    
    
    @isTest static void testCalloutWithoutUS() {
        
        //enable sync
        ByPassTrigger__c bp = new ByPassTrigger__c();
        bp.SetupOwnerId = UserInfo.getUserId();
        bp.Enable_EBS_Sync__c =true;
        insert bp;
        
        
        AddressValidationUsers__c setting = new AddressValidationUsers__c();

        User u = [Select Id From User Where Name like '%deployment%' limit 1];
        setting.SetupOwnerId = u.Id;
        insert setting;
                
        SBQQ__Quote__c quote;
        
        system.RunAs(u){
        
            CountryCode__c country = new CountryCode__c();
            country.Name = 'IN';
            country.Code__c  = 'IN';
            insert country;
            
            Id rtTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
            instofAcc.Name = 'Test';
            instofAcc.Supplier_Type__c = 'Venue';
            instofAcc.Venue_Type__c = 'CVB';
            instofAcc.RecordTypeId = rtTypeId ;
            instofAcc.BillingCountry = 'IN';
            insert instofAcc;
            
            
            Contact instOfCon = new Contact();
            instOfCon.LastName = 'Test 1';
            instOfCon.AccountId = instofAcc.Id;
            
            Contact instOfCon2 = new Contact();
            instOfCon2.LastName = 'Test 2';
            instOfCon2.AccountId = instofAcc.Id;
            
            instofConList.add(instOfCon);
            instofConList.add(instOfCon2);
            insert instofConList;
            
            AddressValidator__c add = new AddressValidator__c();
            add.Name = '1';
            add.FormatType__c = 'ALL' ;
            add.Login_Id__c = '165520';
            add.MatchingScope__c = 'LOCALITY_LEVEL' ;
            add.Password__c= 'im22NUdN';
            add.Rest_URL__c= 'https://rest-adcloud.informaticadaas.com/adcloud/verifyaddress?';
            insert add;
            
            
            Address__c sAddress = new Address__c();
            sAddress.Type__c = 'Shipping';
            sAddress.Account__c = instofAcc.Id;
            saddress.City__c='Burnaby';
            saddress.Province__c='BC';
            saddress.Country__c='IN';
            saddress.CountryCode__c='IN';
            saddress.Postal_Code__c = '1001';
            saddress.EBS_Site_Use_Id__c=null;
            insert sAddress;
            
            Opportunity instOfOpp = new Opportunity();
            instOfOpp.AccountId = instofAcc.id;
            instOfOpp.Name = 'Test';
            instOfOpp.Product__c = 'TicketMob';
            instOfOpp.NBB_Renewal__c = 'NBB';
            instOfOpp.Parent_Upsell__c = 'Primary';
            instOfOpp.MYD_Deal__c = 'First Year';
            instOfOpp.New_Type__c =  'Upsell-NBB';
            instOfOpp.StageName = 'Closed Won';
            instOfOpp.CloseDate = system.today();
            instOfOpp.New_Amount__c = 11;
            instOfOpp.Years__c= '1';
            instOfOpp.LeadSource = 'ACD-PS';
            instOfOpp.Contact_Associated__c = instofConList.get(0).Id;
            instOfOpp.Contact_Role__c = 'Influencer';
            instOfOpp.Contract_Implemented__c = true;
            instOfOpp.ContractReceived__c = system.today();
            //instOfOpp.Web_Design_Support_Minutes_Purchased__c =0; comment by kd
            instOfOpp.Deal_Year__c = '1';
            instOfopp.Ship_To_Address__c = sAddress.Id;
            insert instOfOpp;
            
            quote = new SBQQ__Quote__c();
            quote.Effective_Year_1_Start_Date__c =  system.today();
            quote.Contract_Term_Years__c = '1';
            quote.Effective_Year_1_End_Date__c  = system.today()+50;
            quote.SBQQ__Opportunity2__c = instofOpp.Id;
            insert quote;
            

            
            // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new AddressValidatorMockGenerator());
            
            //change address
            saddress.Postal_Code__c = null;            
            update saddress;
            
            
            // Call method to test.
            // This causes a fake response to be sent
            // from the class that implements HttpCalloutMock. 
            boolean isValid = AddressValidator.validateAddress(quote.Id);
        }

    }
    
    @isTest static void testCountryCode() {
        
        User u = [Select Id From User Where Name like '%deployment%' limit 1];
        
        //enable sync
        ByPassTrigger__c bp = new ByPassTrigger__c();
        bp.SetupOwnerId = UserInfo.getUserId();
        bp.Enable_EBS_Sync__c =true;
        insert bp;
        
        system.RunAs(u){
            CountryCode__c country = new CountryCode__c();
            country.Name = 'US';
            country.Code__c  = 'United States';
            insert country;
            
            Id rtTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
            instofAcc.Name = 'Test';
            instofAcc.Supplier_Type__c = 'Venue';
            instofAcc.Venue_Type__c = 'CVB';
            instofAcc.RecordTypeId = rtTypeId ;
            instofAcc.BillingCountry = 'US';
            instofAcc.BillingState='PA';
            insert instofAcc;
            
            
            Contact instOfCon = new Contact();
            instOfCon.LastName = 'Test 1';
            instOfCon.AccountId = instofAcc.Id;
            
            Contact instOfCon2 = new Contact();
            instOfCon2.LastName = 'Test 2';
            instOfCon2.AccountId = instofAcc.Id;
            
            instofConList.add(instOfCon);
            instofConList.add(instOfCon2);
            insert instofConList;
            
            
            Address__c sAddress = new Address__c();
            sAddress.Type__c = 'Shipping';
            sAddress.Account__c = instofAcc.Id;
            saddress.City__c='Burnaby';
            saddress.Province__c='BC';
            saddress.Country__c='US';
            saddress.CountryCode__c='US';
            saddress.Postal_Code__c = '1001';
            saddress.EBS_Site_Use_Id__c=null;
            insert sAddress;
          
            
        }

    }
    
    
}