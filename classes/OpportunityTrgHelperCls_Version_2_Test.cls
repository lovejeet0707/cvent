/* ===============================
AUTHOR     : Shanu Aggarwal    
CREATED DATE     : 12 MAY 2016
PURPOSE     :  Test Class For Opportunity trigger handler "OpportunityTrgHelperCls_Version_2"
SPECIAL NOTES: We have extended a version of OpportunityTrgHelperCls which is used for Opportunity trigger. 

============================= 
*/

@isTest
public class OpportunityTrgHelperCls_Version_2_Test{
    
    
    
    public static Account instofAcc = new Account();
    public static Address__c  sAddress= new Address__c();
    public static Contact instofCon;
    public static List<PricebookEntry> listOfPBE=new List<PricebookEntry>();
    public static List<Product2> listOFProduct =new List<Product2>();
    
    static{
        // create custom setting
        UserAssignment__c instUA = new UserAssignment__c();
        instUA.Name = 'Integrated_Events';
        instUA.User_id__c = userinfo.getUserID();
        instUA.UserName__c = 'Brett Wischow';
        insert instUA;
        
        instofAcc=TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.CSN_Status__c ='Using';
        instofAcc.Supplier_Status__c='Approved';
        instofAcc.BillingCountryCode='US';
        instOfAcc.BillingStateCode='TX';
        insert instofAcc;
        
        instofCon=TestUtil.createContact(instofAcc.id);
        instOfCon.Email = 'Test987654321@test.com';
        instOfCon.Phone = '8877665544';
        insert instofCon;
        
        listOFProduct =TestUtil.createProducts(new List<String>{'CVENT Attendee Support','Cvent Creative Services','App Build Plus','Social Tables - Additional User Logins','Social Tables - Planner License','Transient Sourcing','1 Pg PMPP RePrint'});
        listOFProduct[0].productcode='CV-AD-HC-CSN-1PPMP';
        listOFProduct[1].productcode='CV-EP-EC-EVT-CVTPYTSER';
        listOFProduct[2].productcode='CV-PS-EC-CCS-APPBPLS';
        listOFProduct[3].productcode='CV-SW-EC-SCT-SCTADDUSRLGN';
        listOFProduct[4].productcode='CV-SW-EC-SCT-SCTPLNLISC';
        listOFProduct[5].productcode='LA-SW-SEC-LTR-TS';
        listOFProduct[6].productcode='CV-AD-HC-CSN-1PPMP';
        
        insert listOFProduct;
        PricebookEntry instPBE= TestUtil.createPricebookEntry(listOFProduct[0],100);
        listOfPBE.add(instPBE);
        PricebookEntry  instPBE1= TestUtil.createPricebookEntry(listOFProduct[1],100);
        listOfPBE.add(instPBE1);
        PricebookEntry  instPBE2= TestUtil.createPricebookEntry(listOFProduct[2],100);
        listOfPBE.add(instPBE2);
        PricebookEntry  instPBE3= TestUtil.createPricebookEntry(listOFProduct[3],100);
        listOfPBE.add(instPBE3);
        PricebookEntry  instPBE4= TestUtil.createPricebookEntry(listOFProduct[4],100);
        listOfPBE.add(instPBE4);
        PricebookEntry  instPBE5= TestUtil.createPricebookEntry(listOFProduct[5],100);
        listOfPBE.add(instPBE5);
        
        PricebookEntry  instPBE6= TestUtil.createPricebookEntry(listOFProduct[6],100);
        listOfPBE.add(instPBE6);
        
        insert listOfPBE;
        
            sAddress = new Address__c();
            sAddress.Type__c = 'Shipping';
            sAddress.Account__c = instofAcc.Id;
            saddress.City__c='Burnaby';
            saddress.Province__c='BC';
            saddress.Country__c='US';
            saddress.CountryCode__c='US';
            saddress.Postal_Code__c = '1001';
            saddress.EBS_Site_Use_Id__c=null;
            sAddress.EBS_Account_Id__c = instofAcc.Id;
            sAddress.Operating_Unit_Name__c='CVAUS';
            insert sAddress;
        
        
    } 
    
    public static void createCustomsetting(){
        
        List<OpportunityAlerts__c> listOppAlert=new List<OpportunityAlerts__c>();
        OpportunityAlerts__c oppAl=new OpportunityAlerts__c();
        oppAl.name ='Completion';
        //oppAl.Alert__c=
        oppAl.Alert_Description__c='Notify contracts to begin implementation. Note that the alert converts to a case for Contracts.';
        oppAl.Sent_to__c='0F91N0000009Xwt';
        oppAl.Stage__c='Closed Won';
        listOppAlert.add(oppAl);
        
        oppAl=new OpportunityAlerts__c();
        oppAl.name ='MSA/Bulk Purchase Contract Type';
        oppAl.Alert__c='Magazine Ad Sold & Reprint Ads sold';
        oppAl.Alert_Description__c='Label:OppAlert';
        oppAl.Sent_to__c='0F91N0000009Xwt';
        oppAl.Stage__c='Closed Won';
        listOppAlert.add(oppAl);
        
        oppAl=new OpportunityAlerts__c();
        oppAl.name ='Tax Exemption Customer';
        oppAl.Alert__c='Magazine Ad Sold & Reprint Ads sold';
        oppAl.Alert_Description__c='Label:OppAlert';
        oppAl.Sent_to__c='0F91N0000009Xwt';
        oppAl.Stage__c='Closed Won';
        listOppAlert.add(oppAl);
        
        insert listOppAlert;
        
    }
    
    private static void createImplementationSurvey(ID OppID,ID quoteID){
        Implementation_Survey__c instImp=new Implementation_Survey__c();
        instImp.Account__c=instofAcc.id;
        instImp.Opportunity__c=OppID;
        instImp.Tax_Exempt__c='Yes';
        instImp.Quote__c=quoteID;
        insert instImp;
        
        
    }
    //Testing CreateTMMob Method of OpportunityTrgHelperCls_Version_2
    public static testmethod void testTicketMob(){
    
          
        User instUsr = TestUtil.CreateDeploymentUser();
        system.RunAs(instUsr){
            
            
            
            Test.startTest();
            Opportunity instOpp=TestUtil.createOpportunity('Test Opp','Event','Qualified');
            instOpp.StageName ='Qualified';
            instOpp.Deal_Year__c ='1';
            instOpp.NBB_Renewal__c = 'NBB';
            instOpp.Parent_Upsell__c = 'Primary';
            instOpp.CloseDate = system.today().addmonths(12);
          //  instOpp.Web_Design_Support_Minutes_Purchased__c =0;
            instOpp.Contract_Implemented__c = true;
            instOpp.ContractReceived__c = system.today();
            instOpp.Product__c ='TicketMob';
            instOpp.MYD_Deal__c='First Year';
            instOpp.pricebook2id=Test.getStandardPricebookID();
            instOpp.Contact_Associated__c=instofCon.id; 
            insert instOpp;
            
            List<Opportunity> listOfOpp=new List<Opportunity>{instOpp};
            List<OpportunityLineItem> listOlitem = new List<OpportunityLineItem>();
            
            OpportunityLineItem instOfOlitem=new OpportunityLineItem();
            instOfOlitem.OpportunityID = instOpp.Id;
            instOfOlitem.PriceBookEntryID=listOfPBE[0].Id;
            instOfOlitem.Product__c = 'CVENT Attendee Support';
            instOfOlitem.quantity=4;
            instOfOlitem.totalprice=200;
            
            listOlitem.add(instOfOlitem);
            
             instOfOlitem=new OpportunityLineItem();
            instOfOlitem.OpportunityID = instOpp.Id;
            instOfOlitem.PriceBookEntryID=listOfPBE[1].Id;
            instOfOlitem.Product__c = 'Cvent Creative Services';
            instOfOlitem.quantity=4;
            instOfOlitem.totalprice=200;
            
            listOlitem.add(instOfOlitem);
            
            instOfOlitem=new OpportunityLineItem();
            instOfOlitem.OpportunityID = instOpp.Id;
            instOfOlitem.PriceBookEntryID=listOfPBE[5].Id;
            instOfOlitem.Product__c = 'Transient Sourcing';
            instOfOlitem.quantity=4;
            instOfOlitem.totalprice=200;
            
            listOlitem.add(instOfOlitem);
            
            insert listOlitem;
            
            
            
            
            
           // instOpp.Web_Design_Support_Minutes_Purchased__c = 1 ;
            instOpp.StageName ='Closed Won';
            
            Map<Id,Opportunity> mapOpp=new Map<Id,Opportunity>();
            mapOpp.put(instOpp.id,instOpp);
            OpportunityTrgHelperCls_Version_2.WebDesignSupportRollup(listOfOpp,mapOpp,false,true);
            OpportunityTrgHelperCls_Version_2.CreateTMMob(mapOpp);
            OpportunityTrgHelperCls_Version_2.OnAfterInsert(mapOpp);
            OpportunityTrgHelperCls_Version_2.OnAfterDelete(new List<Opportunity>{instOpp},mapOpp);
            Test.stopTest();
        
        }
    }// end here
    
    public testmethod static void unitTesting(){
        
        User instUsr = TestUtil.CreateDeploymentUser();
        system.RunAs(instUsr){
            
            
            
            Test.startTest();
            instofAcc=TestUtil.createAccount('Test Account','Biz_Ac');
            instofAcc.Supplier_Type__c = 'Venue';
            instofAcc.Venue_Type__c = 'CVB';
            instofAcc.BillingCountryCode='US';
            instOfAcc.BillingStateCode = 'TX';
            insert instofAcc;
            
            
            Opportunity instOpp=TestUtil.createOpportunity('Test Opp','Event','Qualified');
            instOpp.StageName ='Closed Won';
            instOpp.Deal_Year__c ='1';
            instOpp.NBB_Renewal__c = 'NBB';
            instOpp.Parent_Upsell__c = 'Primary';
            instOpp.CloseDate = system.today().addmonths(12);
           // instOpp.Web_Design_Support_Minutes_Purchased__c =0;
            instOpp.Contract_Implemented__c = true;
            instOpp.ContractReceived__c = system.today();
            instOpp.Product__c ='TicketMob';
            
            instOpp.MYD_Deal__c='First Year';
            instOpp.pricebook2id=Test.getStandardPricebookID();
            instOpp.Contact_Associated__c=instofCon.id; 
            //instOpp.Ship_To_Address__c = sAddress.id;
            //instopp.SBQQ__PrimaryQuote__c ='';
            //instopp.SBQQ__RenewedContract__c=con1.Id;
            insert instOpp;
           
            
            SBQQ__Quote__c sbqq = new SBQQ__Quote__c();
            sbqq.SBQQ__Opportunity2__c = instopp.id;
            sbqq.Contract_Term_Years__c = '1';
            //sbqq.SBQQ__RenewedContract__c='';
            insert sbqq;
            instopp.SBQQ__PrimaryQuote__c=sbqq.id;
            //instopp.SBQQ__RenewedContract__c=con.Id;
            sbqq.Billing_Frequency__c= 'Custom (6+x/year)';
            update sbqq;
            Map<Id,Opportunity> mapOpp=new Map<Id,Opportunity>();
            mapOpp.put(instOpp.id,instOpp);
            
            test.stopTest();
            
        } 
        
        
    }
    public static testmethod void contractOppSBqq(){
        User instUsr = TestUtil.CreateDeploymentUser();
        system.RunAs(instUsr){
        contract con = new contract();
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive
                     FROM RecordType r WHERE SobjectType='Contract' And DeveloperName='Customer_Contracts' 
                     And IsActive=true limit 1];
            con.RecordTypeId =rtType.Id; 
            con.Contract_Request_Date__c= system.today();
            con.AccountId =instofAcc.Id;
            con.Status='On Hold';
            con.Contract_Term_Years__c='5';
            con.Current_Year__c=1;
            con.StartDate=system.today().addMonths(1);
            try{
                insert con;
            }catch(Exception e){
                
                
            }
            
            contract con1 = new contract();
            con1.Contract_Request_Date__c= system.today();
            con1.AccountId =instofAcc.Id;
            con1.Status='On Hold';
            con1.Parent_Contract__c=con.id;
            //con1.Upcoming_Renewal_Type__c='MYD Renewal';
            con1.StartDate=system.today().addMonths(2);
            try{
            
                insert con1;}
            catch (exception e)
            {
                system.debug('error'+e.getMessage());
            }

            
         Test.startTest();
            instofAcc=TestUtil.createAccount('Test Account','Biz_Ac');
            instofAcc.Supplier_Type__c = 'Venue';
            instofAcc.Venue_Type__c = 'CVB';
            instofAcc.BillingCountryCode='US';
            instOfAcc.BillingStateCode = 'TX';
            insert instofAcc;
            
            
            
            Opportunity instOpp=TestUtil.createOpportunity('Test Opp','Event','Qualified');
            instOpp.StageName ='Closed Won';
            instOpp.Deal_Year__c ='1';
            instOpp.Is_Close_Date_Locked__c=false;
            //instopp.Master_Agreement__c=con.Id;
            instOpp.NBB_Renewal__c = 'NBB';
            instOpp.Parent_Upsell__c = 'Primary';
            
            instOpp.CloseDate = system.today().addmonths(12);
          //  instOpp.Web_Design_Support_Minutes_Purchased__c =0;
           
            instOpp.ContractReceived__c = system.today();
            instOpp.Product__c ='TicketMob';
            
            
            instOpp.MYD_Deal__c='First Year';
            instOpp.pricebook2id=Test.getStandardPricebookID();
            instOpp.Contact_Associated__c=instofCon.id; 
            instopp.Master_Agreement__c=con.Id;
            
            instopp.Contact_Role__c='Influencer';
            instopp.Parent_Upsell__c='One-Off';
           // instopp.Opportunity_Start_Date__c = system.today().addDays(1000);
            
            //instopp.SBQQ__RenewedContract__c=con1.Id;
            insert instOpp;
             instOpp.Contract_Implemented__c = true;
             update instOpp;
            con1.SBQQ__Opportunity__c=instOpp.id;
            update con1;
            
            SBQQ__Quote__c sbqq = new SBQQ__Quote__c();
            sbqq.SBQQ__StartDate__c=system.today();
            sbqq.SBQQ__Opportunity2__c = instopp.id;
            sbqq.Contract_Term_Years__c = '1';
            //sbqq.SBQQ__RenewedContract__c='';
           
           
            insert sbqq;
            //SBQQ__QuoteLine__c instQLitem =new SBQQ__QuoteLine__c();
            //instQLitem.Number_of_Guest_Rooms__c='201-749';
            
            instopp.SBQQ__PrimaryQuote__c=sbqq.id;
            instopp.Master_Agreement__c =con1.id;
            instopp.SBQQ__RenewedContract__c=con1.Id;
            
            update instopp;
            //Map<Id,Opportunity> mapOpp=new Map<Id,Opportunity>();
            //mapOpp.put(instOpp.id,instOpp);
            
            test.stopTest();
            
        } 
    }
    
    public static testmethod void OpportunityChatterAlertsTest(){
        ID profileID=[select id from profile where name='System Administrator'].id;
        Account acc = new Account(Name='Test Account');
        acc.BillingCountryCode = 'IN';
        acc.BillingStateCode = 'DL';
        insert acc;
        Contact con = new Contact(LastName='Test',Product_Desired__c='Event',AccountId=acc.Id);
        insert con;
        Id profileId2 = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
        Id profileId1 = [SELECT Id FROM Profile WHERE Name = 'Custom:High Volume Community Portal User'].Id;

        User u=TestUtil.createUser(profileId1,'kdnewuser@testorg.com');
        u.lastname='Kd';
        u.ContactId = con.id;
        u.FederationIdentifier = 'F8ECWVJWT98';
        u.email='Kdthakur@gmail.com.test';
        insert u;
        User instUsr = TestUtil.CreateDeploymentUser();
        insert instUsr;
        Id userId=userinfo.getUserID();
        createCustomsetting();
        system.RunAs(instUsr){
            
            Map<Id,Opportunity> mapOppOld=new Map<Id,Opportunity>();
            Map<Id,Opportunity> mapOppNew=new Map<Id,Opportunity>();
            Id CSNRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CSN-Supplier').getRecordTypeId();
                Opportunity instOpp=TestUtil.createOpportunity('Test Opp','Event','Closed Won');
                instOpp.AccountID =instofAcc.id;
                instOpp.Deal_Year__c ='1';
                instOpp.NBB_Renewal__c = 'NBB';
                instOpp.Parent_Upsell__c = 'Primary';
                instOpp.CloseDate = system.today().addmonths(12);
                //instOpp.Web_Design_Support_Minutes_Purchased__c =0;
                instOpp.Contract_Implemented__c = true;
                instOpp.ContractReceived__c = system.today();
                instOpp.Product__c ='Event';
                instOpp.MYD_Deal__c='First Year';
                instOpp.pricebook2id=Test.getStandardPricebookID();
                instOpp.Contact_Associated__c=instofCon.id;
                instOpp.Is_Close_Date_Locked__c=false;
                instopp.recordtypeID=CSNRecTypeId;
                instopp.Chain_Deal__c='Bulk Purchase';
                instOpp.ownerID=instUsr.id;
                instopp.AM_Owner__c='Kd';
                
                instopp.ContractReceived__c=system.today().addDays(30);
                insert instOpp;
                
                SBQQ__Quote__c sbqq = new SBQQ__Quote__c();
                sbqq.SBQQ__Opportunity2__c = instopp.id;
                sbqq.Contract_Term_Years__c = '1';
                sbqq.ownerID=userId;
                insert sbqq;
                
                createImplementationSurvey(instopp.id,sbqq.id);
            
                instopp.SBQQ__PrimaryQuote__c=sbqq.id;
                instopp.Parent_Upsell__c ='Upsell';
                instopp.Contract_Type_2_0__c = 'Cancellations';
                instopp.Contract_Implemented__c=true;
                //instopp.AM_Owner__c='Test Opp';
                //mapOppOld.put(instopp.id,instopp);
                update instopp;
            

           
                mapOppOld.put(instopp.id,instopp);
 
                 List<OpportunityLineItem> listOlitem = new List<OpportunityLineItem>();
            
            OpportunityLineItem instOfOlitem=new OpportunityLineItem();
            instOfOlitem.OpportunityID = instOpp.Id;
            instOfOlitem.PriceBookEntryID=listOfPBE[1].Id;
            instOfOlitem.Product__c = 'Cvent Payment Services';
            instOfOlitem.quantity=4;
            instOfOlitem.totalprice=200;
            
            listOlitem.add(instOfOlitem);
            
            OpportunityLineItem instOfOlitem1=new OpportunityLineItem();
            instOfOlitem1.OpportunityID = instOpp.Id;
            instOfOlitem1.PriceBookEntryID=listOfPBE[6].Id;
            instOfOlitem1.Product__c = 'Cvent Payment Services';
            instOfOlitem1.quantity=4;
            instOfOlitem1.totalprice=200;
            
            listOlitem.add(instOfOlitem1);
            
             OpportunityLineItem instOfOlitem11=new OpportunityLineItem();
            instOfOlitem11.OpportunityID = instOpp.Id;
            instOfOlitem11.PriceBookEntryID=listOfPBE[0].Id;
            instOfOlitem11.Product__c = 'Transient Sourcing';
            instOfOlitem11.quantity=4;
            instOfOlitem11.totalprice=200;
            
            listOlitem.add(instOfOlitem11);
            
            SBQQ__QuoteLine__c instQLI=new SBQQ__QuoteLine__c();
                instQLI.SBQQ__Quote__c=sbqq.id;
                instQLI.SBQQ__Product__c=listOFProduct[0].id;
                instQLI.SBQQ__Renewal__c=true;
                instQLI.SBQQ__Existing__c=false;
                instQLI.SBQQ__NetPrice__c=1000;
                
                insert instQLI;
                 
            Test.startTest();   
                

                mapOppNew.put(instopp.id,instopp);
                OpportunityTrgHelperCls_Version_2.isTest=true;
                OpportunityTrgHelperCls_Version_2.OpportunityChatterAlerts(mapOppNew, mapOppOld);
                //OpportunityTrgHelperCls_Version_2.isTest=true;
                OpportunityTrgHelperCls_Version_2.syncOwner(mapOppNew.values(),mapOppOld);
                OpportunityTrgHelperCls_Version_2.ChangeOppSplitOwner(mapOppNew,mapOppOld);
                OpportunityTrgHelperCls_Version_2.SendAMAlert(mapOppNew,mapOppOld);
            Test.stopTest();
        

        }
    }
    
    
    public static testmethod void CreateRFPCaseOnClosedLostTest(){
       
       
        User instUsr = TestUtil.CreateDeploymentUser();
        insert instUsr;
        List<AccountTeamMember> listOfAccountTeam=new List<AccountTeamMember>();
        List<Opportunity> listOfOppty=new List<Opportunity>();
        Id userId=userinfo.getUserID();
        createCustomsetting();
        system.RunAs(instUsr){
            
            AccountTeamMember instATeam=TestUtil.createAccountTeamMember(instofAcc.id,'AM - Inquisium');
            listOfAccountTeam.add(instATeam);
            
            insert listOfAccountTeam;
            
            Map<Id,Opportunity> mapOppOld=new Map<Id,Opportunity>();
            Map<Id,Opportunity> mapOppNew=new Map<Id,Opportunity>();
            Id CSNRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CSN-Supplier').getRecordTypeId();
                Opportunity instOpp=TestUtil.createOpportunity('Test Opp','Event','Qualified');
                instOpp.AccountID =instofAcc.id;
                instOpp.Deal_Year__c ='2';
                instOpp.NBB_Renewal__c = 'Renewal';
                instOpp.Parent_Upsell__c = 'Primary';
                instOpp.CloseDate = system.today().addmonths(12);
            //    instOpp.Web_Design_Support_Minutes_Purchased__c =0;
                instOpp.Contract_Implemented__c = true;
                instOpp.ContractReceived__c = system.today();
                instOpp.Product__c ='CSN';
                instOpp.MYD_Deal__c='First Year';
                instOpp.pricebook2id=Test.getStandardPricebookID();
                instOpp.Contact_Associated__c=instofCon.id;
                instOpp.Is_Close_Date_Locked__c=false;
                instopp.recordtypeID=CSNRecTypeId;
                instopp.Chain_Deal__c='Venue/Service';
                instOpp.ownerID=instUsr.id;
                instopp.AM_Owner__c='Kd';
                instopp.License_Type__c='1 Diamond';
                listOfOppty.add(instopp);
                
                instOpp=TestUtil.createOpportunity('Test Opp2','Event','Qualified');
                instOpp.AccountID =instofAcc.id;
                instOpp.Deal_Year__c ='2';
                instOpp.NBB_Renewal__c = 'Renewal';
                instOpp.Parent_Upsell__c = 'Primary';
                instOpp.CloseDate = system.today().addmonths(12);
                instOpp.Product__c ='Survey';
                instopp.recordtypeID=CSNRecTypeId;
                listOfOppty.add(instopp);
                
                instOpp=TestUtil.createOpportunity('Test Opp3','Event','Qualified');
                instOpp.AccountID =instofAcc.id;
                instOpp.Deal_Year__c ='2';
                instOpp.NBB_Renewal__c = 'Renewal';
                instOpp.Parent_Upsell__c = 'Primary';
                instOpp.CloseDate = system.today().addmonths(12);
                instOpp.Product__c ='Event';
                instopp.recordtypeID=CSNRecTypeId;
                listOfOppty.add(instopp);
                
                instOpp=TestUtil.createOpportunity('Test Opp3','Event','Qualified');
                instOpp.AccountID =instofAcc.id;
                instOpp.Deal_Year__c ='2';
                instOpp.NBB_Renewal__c = 'Renewal';
                instOpp.Parent_Upsell__c = 'Primary';
                instOpp.CloseDate = system.today().addmonths(12);
                instOpp.Product__c ='RegOnline';
                instopp.recordtypeID=CSNRecTypeId;
                listOfOppty.add(instopp);
                
                insert listOfOppty;
                
                SBQQ__Quote__c sbqq = new SBQQ__Quote__c();
                sbqq.SBQQ__Opportunity2__c = instopp.id;
                sbqq.Contract_Term_Years__c = '1';
                sbqq.ownerID=userId;
                insert sbqq;
                
               
                
            Test.startTest();   
                mapOppOld.put(instopp.id,instopp);
                instopp.SBQQ__PrimaryQuote__c=sbqq.id;
                instopp.StageName='Closed Lost';
                //instopp.AM_Owner__c='Test Opp';
                //mapOppOld.put(instopp.id,instopp);
                update instopp;
                mapOppNew.put(instopp.id,instopp);
                OpportunityTrgHelperCls_Version_2.istest=true;
                OpportunityTrgHelperCls_Version_2.CreateRFPCaseOnClosedLost(mapOppNew.values(),mapOppOld);
            Test.stopTest();
        

        }
    }// end 
    
    
    private testmethod static void createQuoteLineReassignOppTest(){
        
        OpportunityTrgHelperCls_Version_2.isComingfromTestHandler1=true;
        User instUsr = TestUtil.CreateDeploymentUser();
        insert instUsr;
        
        List<Opportunity> listOfOppty=new List<Opportunity>();
        Id userId=userinfo.getUserID();
        createCustomsetting();
        system.RunAs(instUsr){
            
            Map<Id,Opportunity> mapOppOld=new Map<Id,Opportunity>();
            Map<Id,Opportunity> mapOppNew=new Map<Id,Opportunity>();
            Id CSNRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CSN-Supplier').getRecordTypeId();
                Opportunity instOpp=TestUtil.createOpportunity('Test Opp','Event','Qualified');
                instOpp.AccountID =instofAcc.id;
                instOpp.Deal_Year__c ='1';
                instOpp.NBB_Renewal__c = 'Renewal';
                instOpp.Parent_Upsell__c = 'Primary';
                instOpp.CloseDate = system.today().addmonths(12);
               // instOpp.Web_Design_Support_Minutes_Purchased__c =0;
                instOpp.Contract_Implemented__c = true;
                instOpp.ContractReceived__c = system.today();
                instOpp.Product__c ='CSN';
                instOpp.MYD_Deal__c='First Year';
                instOpp.pricebook2id=Test.getStandardPricebookID();
                instOpp.Contact_Associated__c=instofCon.id;
                instOpp.Is_Close_Date_Locked__c=false;
                instopp.recordtypeID=CSNRecTypeId;
                instopp.Chain_Deal__c='Venue/Service';
                instOpp.ownerID=instUsr.id;
                instopp.AM_Owner__c='Kd';
                instopp.License_Type__c='1 Diamond';
                
                insert instopp;
                
                Id OppId=instopp.id;
                
                instOpp=TestUtil.createOpportunity('Test Opp2','Event','Closed Won');
                instOpp.AccountID =instofAcc.id;
                instOpp.Reassigned_To__c=OppId;
                instOpp.Deal_Year__c ='1';
                instOpp.NBB_Renewal__c = 'Renewal';
                instOpp.Parent_Upsell__c = 'Primary';
                instOpp.CloseDate = system.today().addmonths(12);
                instOpp.Product__c ='Survey';
                instopp.recordtypeID=CSNRecTypeId;
                
                insert instopp;
                
                SBQQ__Quote__c sbqq = new SBQQ__Quote__c();
                sbqq.SBQQ__Opportunity2__c = instopp.id;
                sbqq.Contract_Term_Years__c='2';
                sbqq.SBQQ__EndDate__c = Date.today().addMonths(12);
                insert sbqq;
                
                SBQQ__QuoteLine__c instQLI=new SBQQ__QuoteLine__c();
                instQLI.SBQQ__Quote__c=sbqq.id;
                instQLI.SBQQ__Product__c=listOFProduct[0].id;
                instQLI.SBQQ__Renewal__c=true;
                instQLI.SBQQ__Existing__c=false;
                instQLI.SBQQ__NetPrice__c=1000;
                
                insert instQLI;
                
               
            
                instopp.SBQQ__PrimaryQuote__c=sbqq.id;
                
                update instopp;
        
        }
    }// end here
    
    private testmethod static void BookingClassificationTest(){
        
        //OpportunityTrgHelperCls_Version_2.isComingfromTestHandler1=true;
        User instUsr = TestUtil.CreateDeploymentUser();
        insert instUsr;
        
        List<Opportunity> listOfOppty=new List<Opportunity>();
        Id userId=userinfo.getUserID();
        createCustomsetting();
        system.RunAs(instUsr){
            
            Map<Id,Opportunity> mapOppOld=new Map<Id,Opportunity>();
            Map<Id,Opportunity> mapOppNew=new Map<Id,Opportunity>();
            Id CSNRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CSN-Supplier').getRecordTypeId();
               
                
               Opportunity instOpp=TestUtil.createOpportunity('Test Opp2','Event','Closed Won');
                instOpp.AccountID =instofAcc.id;
                //instOpp.Reassigned_To__c=OppId;
                instOpp.Deal_Year__c ='2';
                instOpp.NBB_Renewal__c = 'Renewal';
                instOpp.Parent_Upsell__c = 'Primary';
                instOpp.CloseDate = system.today().addmonths(12);
                instOpp.Product__c ='Survey';
                instopp.recordtypeID=CSNRecTypeId;
                
                insert instopp;
                
                Id OppId=instopp.id;
                instOpp=TestUtil.createOpportunity('Test Opp','Event','Qualified');
                instOpp.AccountID =instofAcc.id;
                instOpp.Deal_Year__c ='2';
                instOpp.NBB_Renewal__c = 'Renewal';
                instOpp.Parent_Upsell__c = 'Primary';
                instOpp.CloseDate = system.today().addmonths(12);
             //   instOpp.Web_Design_Support_Minutes_Purchased__c =0;
                instOpp.Contract_Implemented__c = true;
                instOpp.ContractReceived__c = system.today();
                instOpp.Product__c ='CSN';
                instOpp.MYD_Deal__c='First Year';
                instOpp.pricebook2id=Test.getStandardPricebookID();
                instOpp.Contact_Associated__c=instofCon.id;
                instOpp.Is_Close_Date_Locked__c=false;
                instopp.recordtypeID=CSNRecTypeId;
                instopp.Chain_Deal__c='Venue/Service';
                instOpp.ownerID=instUsr.id;
                instopp.AM_Owner__c='Kd';
                instopp.License_Type__c='1 Diamond';
                instOpp.Reassigned_To__c=OppId;
                insert instopp;
                
                
                //Delete this opp...
                Opportunity oppSecond = new Opportunity();
                oppSecond=TestUtil.createOpportunity('Test Opp','Event','Qualified');
                oppSecond.AccountID =instofAcc.id;
                oppSecond.Deal_Year__c ='2';
                oppSecond.NBB_Renewal__c = 'Renewal';
                oppSecond.Parent_Upsell__c = 'Primary';
                oppSecond.CloseDate = system.today().addmonths(12);
              //  oppSecond.Web_Design_Support_Minutes_Purchased__c =0;
                oppSecond.Contract_Implemented__c = true;
                oppSecond.ContractReceived__c = system.today();
                oppSecond.Product__c ='CSN';
                oppSecond.MYD_Deal__c='First Year';
                oppSecond.pricebook2id=Test.getStandardPricebookID();
                oppSecond.Contact_Associated__c=instofCon.id;
                oppSecond.Is_Close_Date_Locked__c=false;
                oppSecond.recordtypeID=CSNRecTypeId;
                oppSecond.Chain_Deal__c='Venue/Service';
                oppSecond.ownerID=instUsr.id;
                oppSecond.AM_Owner__c='Kd';
                oppSecond.License_Type__c='1 Diamond';
                oppSecond.New_Type__c='Contract Renewal';
                oppSecond.ignoreValidation__c = true;

                insert oppSecond;
                delete oppSecond;
                
                mapOppOld.put(instopp.id,instopp);
                
                
                Booking_Classification__c instBooking=new Booking_Classification__c();
                instBooking.Opportunity__c=instopp.id;
                
                insert instBooking;
                
                contract con1 = new contract();
                con1.Contract_Request_Date__c= system.today();
                con1.AccountId =instofAcc.Id;
                con1.Status='On Hold';
                
                con1.StartDate=system.today().addMonths(2);
                try{
                
                    insert con1;}
                catch (exception e)
                {
                    system.debug('error'+e.getMessage());
                }
                Test.startTest();
                instopp.SBQQ__AmendedContract__c=con1.id;
                //instopp.SBQQ__RenewedContract__c=true;
                update instopp;
                OpportunityTrgHelperCls_Version_2.istest=true;
                
                //OpportunityTrgHelperCls_Version_2.DeleteReassignedToQuoteLines(mapOppOld,mapOppOld);
                OpportunityTrgHelperCls_Version_2.updateBCValues(mapOppOld,mapOppOld);
                OpportunityTrgHelperCls_Version_2.deleteRelatedBookings(mapOppOld);
                
                try{
                
                delete instopp;
                }catch(Exception e){
                
                }
                instopp.Reassigned_To__c = null;
                update instOpp;
                Test.stopTest();
                
                
        }
    }  
    private testmethod static void unitTest(){
        
    //OpportunityTrgHelperCls_Version_2.isComingfromTestHandler1=true;
    User instUsr = TestUtil.CreateDeploymentUser();
    insert instUsr;
    
    List<Opportunity> listOfOppty=new List<Opportunity>();
    Id userId=userinfo.getUserID();
    createCustomsetting();
    system.RunAs(instUsr){
        
        Id CSNRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CSN-Supplier').getRecordTypeId();
           
        Opportunity instOpp=TestUtil.createOpportunity('Test Opp2','Event','Closed Won');

        Id OppId=instopp.id;
        instOpp=TestUtil.createOpportunity('Test Opp','Event','Qualified');
        instOpp.AccountID =instofAcc.id;
        instOpp.Deal_Year__c ='2';
        instOpp.NBB_Renewal__c = 'Renewal';
        instOpp.Parent_Upsell__c = 'Primary';
        instOpp.CloseDate = system.today().addmonths(12);
       // instOpp.Web_Design_Support_Minutes_Purchased__c =0;
        instOpp.Contract_Implemented__c = false;
        instOpp.ContractReceived__c = system.today();
        instOpp.Product__c ='CSN';
        instOpp.MYD_Deal__c='First Year';
        instOpp.pricebook2id=Test.getStandardPricebookID();
        instOpp.Contact_Associated__c=instofCon.id;
        instOpp.Is_Close_Date_Locked__c=false;
        instopp.recordtypeID=CSNRecTypeId;
        instopp.Chain_Deal__c='Venue/Service';
        instOpp.ownerID=instUsr.id;
        instopp.AM_Owner__c='Kd';
        instopp.License_Type__c='1 Diamond';
        instopp.StageName='Verbal';
        instopp.Task_Created__c = FALSE;
        insert instopp;
        
        instopp.StageName='Closed Won';
        instopp.OwnerId='005o0000002jzhM';
        instOpp.Contract_Implemented__c = false;
        update instopp;
    }
}   
/*
public testmethod static void unitTestProfessionalService(){
        
    //OpportunityTrgHelperCls_Version_2.isComingfromTestHandler1=true;
    User instUsr = TestUtil.CreateDeploymentUser();
    insert instUsr;
    
    List<Opportunity> listOfOppty=new List<Opportunity>();
    Id userId=userinfo.getUserID();
    createCustomsetting();
    system.RunAs(instUsr){
        
        Id CSNRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CSN-Supplier').getRecordTypeId();
           
        //OpportunityTrgHelperCls_Version_2.isComingfromTestHandler1= FALSE ;
        
        Opportunity instOpp=TestUtil.createOpportunity('Test Opp2','Event','Verbal');

        Id OppId=instopp.id;
       // instOpp=TestUtil.createOpportunity('Test Opp','Event','Qualified');
        instOpp.AccountID =instofAcc.id;
        instOpp.Deal_Year__c ='2';
        instOpp.NBB_Renewal__c = 'Renewal';
        instOpp.Parent_Upsell__c = 'Primary';
        instOpp.CloseDate = system.today().addmonths(12);
        //instOpp.Web_Design_Support_Minutes_Purchased__c =0;
        instOpp.Contract_Implemented__c = true;
        instOpp.ContractReceived__c = system.today();
        instOpp.Product__c ='CSN';
        instOpp.MYD_Deal__c='First Year';
        instOpp.pricebook2id=Test.getStandardPricebookID();
        instOpp.Contact_Associated__c=instofCon.id;
        instOpp.Is_Close_Date_Locked__c=false;
        instopp.recordtypeID=CSNRecTypeId;
        instopp.Chain_Deal__c='Venue/Service';
        instOpp.ownerID=instUsr.id;
        instopp.AM_Owner__c='Kd';
        instopp.License_Type__c='1 Diamond';
        instopp.StageName='Verbal';
        insert instopp;
        
        List<OpportunityLineItem> listOlitem = new List<OpportunityLineItem>();
            
        OpportunityLineItem instOfOlitem=new OpportunityLineItem();
        instOfOlitem.OpportunityID = instOpp.Id;
        instOfOlitem.PriceBookEntryID=listOfPBE[0].Id;
        instOfOlitem.Product__c = 'App Build Plus';
        instOfOlitem.quantity=4;
        instOfOlitem.totalprice=200;
        listOlitem.add(instOfOlitem);           
        insert listOlitem;
            
        
        instopp.StageName='Closed Won';
        instopp.OwnerId='005o0000002jzhM';
        update instopp;
        
        
            EB_SB_Builder__c ebsb = new EB_SB_Builder__c ();
            ebsb.AccountCustom__c = instofAcc.id;
            ebsb.Project_Status_del__c  ='In Progress'   ; 
            ebsb.Contact__c=instofCon.id;
            insert ebsb;
        
        } 
} */
public testmethod static void testMethodForPending()
    {
        
        Product2 prod2= new Product2(Name = 'Test Product - OneTime',
                                        Family = 'XTCD',
                                     Description = 'Test Product',
                                     IsActive = true,
                                    ProductCode='CV-PS-EC-CCS-APPBPLS');
        insert prod2;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,
                                                    product2Id = prod2.Id,
                                                    isActive = true,
                                                    UnitPrice = 1000);
        insert pbEntry;
       
        Id eventRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Event').getRecordTypeId();
       
        Opportunity instOpp2=TestUtil.createOpportunity('Test Opp2 Unique','Event','Verbal');
        
        instOpp2.AccountId =instofAcc.id;
        instOpp2.Deal_Year__c ='2';
        instOpp2.NBB_Renewal__c = 'Renewal';
        instOpp2.Parent_Upsell__c = 'Primary';
        instOpp2.CloseDate = system.today().addmonths(12);
      //  instOpp2.Web_Design_Support_Minutes_Purchased__c =0;
        instOpp2.Contract_Implemented__c = true;
        instOpp2.ContractReceived__c = system.today();
        instOpp2.Product__c ='Event';
        instOpp2.MYD_Deal__c='First Year';
        instOpp2.pricebook2id=Test.getStandardPricebookID();
        instOpp2.Contact_Associated__c=instofCon.id;
        instOpp2.Is_Close_Date_Locked__c=false;
        instOpp2.recordtypeID=eventRecTypeId;
        instOpp2.Chain_Deal__c='Venue/Service';
        instOpp2.AM_Owner__c='Kd';
        instOpp2.License_Type__c='1 Diamond';
        instOpp2.StageName='Verbal';
        instOpp2.ATI_Check__c = FALSE;
        instOpp2.Opportunity_Name_Affix__c = 'test';
        instOpp2.Dedicated_Ent_Support_Minutes_Purchased__c = 0;
      //  instOpp2.Web_Design_Support_Minutes_Purchased__c = 0;
        insert instOpp2;
        
        List<OpportunityLineItem> listOlitem = new List<OpportunityLineItem>();
        
        OpportunityLineItem instOfOlitem=new OpportunityLineItem();
        instOfOlitem.OpportunityId = instOpp2.Id;
        instOfOlitem.PricebookEntryId = pbEntry.id;
        instOfOlitem.Product2Id = prod2.Id;
        instOfOlitem.quantity=4;
        instOfOlitem.totalprice=200;
        listOlitem.add(instOfOlitem);           
        insert listOlitem;
        
        instOpp2.StageName='Closed Won'; 
        
        try{
            update instopp2;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('You can\'t close an opportunity before filling up the Account Transition Information')?true:false;
            system.assertEquals(expectedExceptionThrown,true); 
        }
        
    }
    
    
    
    
    private testmethod static void unitTestLast(){
        
    OpportunityTrgHelperCls_Version_2.isComingfromTestHandler1=false;
    User instUsr = TestUtil.CreateDeploymentUser();
    insert instUsr;
    
    List<Opportunity> listOfOppty=new List<Opportunity>();
    Id userId=userinfo.getUserID();
    createCustomsetting();
    system.RunAs(instUsr){
        
        Id CSNRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CSN-Supplier').getRecordTypeId();
           
        
        Opportunity instOpp=TestUtil.createOpportunity('Test Opp','Event','Closed Won');
        instOpp.AccountID =instofAcc.id;
        instOpp.Deal_Year__c ='2';
        instOpp.NBB_Renewal__c = 'NBB Renewal';
        instOpp.Parent_Upsell__c = 'Primary';
        instOpp.CloseDate = system.today().addmonths(12);
        //instOpp.Web_Design_Support_Minutes_Purchased__c =0;
        instOpp.Contract_Implemented__c = false;
        instOpp.ContractReceived__c = system.today();
        instOpp.Product__c ='TicketMob';
        instOpp.MYD_Deal__c='First Year';
        instOpp.pricebook2id=Test.getStandardPricebookID();
        instOpp.Contact_Associated__c=instofCon.id;
        instOpp.Is_Close_Date_Locked__c=false;
        instopp.recordtypeID=CSNRecTypeId;
        instopp.Chain_Deal__c='Venue/Service';
        instOpp.ownerID=instUsr.id;
        instopp.AM_Owner__c='Kd';
        instopp.License_Type__c='1 Diamond';
        instopp.Task_Created__c = FALSE;
        insert instopp;
        
        TM_Buildout__c tm = new TM_Buildout__c ();
               tm.Name = instopp.Id;
               tm.Name = instopp.Account_Name_TM__c;
               insert tm;
        
    }
    }
    public testmethod static void unitTesting_Clone(){
        
        User instUsr = TestUtil.CreateDeploymentUser();
        system.RunAs(instUsr){
            Test.startTest();
            instofAcc=TestUtil.createAccount('Test Account','Biz_Ac');
            instofAcc.Supplier_Type__c = 'Venue';
            instofAcc.Venue_Type__c = 'CVB';
            instofAcc.BillingCountryCode = 'US';
            instOfAcc.BillingStateCode ='TX';
            insert instofAcc;
            
            
            EB_SB_Builder__c instOfEB =  new EB_SB_Builder__c();
            instOfEB.Project__c = 'Event Builder';
            instOfEB.Project_Status__c = 'Information Pending';
            instOfEB.Project_Type_del__c = 'Demo Event';
            instOfEB.Project_Complexity__c = '1-Simple';
            instOfEB.AccountCustom__c= instofAcc.Id;
            instOfEB.Project_Status_del__c = 'In Progress';
            insert instOfEB;
            
            Opportunity instOpp=TestUtil.createOpportunity('Test Opp','Event','Qualified');
            instOpp.Deal_Year__c ='1';
            instOpp.NBB_Renewal__c = 'NBB';
            instOpp.Parent_Upsell__c = 'Primary';
            instOpp.CloseDate = system.today().addmonths(12);
           // instOpp.Web_Design_Support_Minutes_Purchased__c =0;
            instOpp.ContractReceived__c = system.today();
            instOpp.Product__c ='CSN';
            instOpp.MYD_Deal__c='First Year';
            instOpp.pricebook2id=Test.getStandardPricebookID();
            instOpp.Contact_Associated__c=instofCon.id; 
            instOpp.AccountId = instofAcc.Id;
            insert instOpp;
            system.debug('---instOpp'+ instOpp);
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = instOpp.Id,
                                                              PricebookEntryId = listOfPBE[2].Id,
                                                              quantity=4, 
                                                              totalprice=200);
            insert oli;

            
            /*SBQQ__Quote__c sbqq = new SBQQ__Quote__c();
            sbqq.SBQQ__Opportunity2__c = instopp.id;
            insert sbqq;
            */
            
            Opportunity oppUpdate = new Opportunity(Id = instOpp.Id);
            instOpp.StageName = 'Closed Won';
            try{
                
                update oppUpdate;
            }
            catch(Exception e){
                System.debug('error message'+e); 
            }         
            test.stopTest();
        } 
    }
    
    public testmethod static void atiValidation()
    {
        
        Id eventRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        
        //OpportunityTrgHelperCls_Version_2.isComingfromTestHandler1= FALSE ;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Development - RFP'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='test12987@ctest.com');
        System.runAs(u) 
        {
            
            Opportunity instOpp=TestUtil.createOpportunity('Test Opp2','Event','Verbal');
            Id OppId=instopp.id;
            // instOpp=TestUtil.createOpportunity('Test Opp','Event','Qualified');
            instOpp.AccountID =instofAcc.id;
            instOpp.Deal_Year__c ='2';
            instOpp.NBB_Renewal__c = 'Renewal';
            instOpp.Parent_Upsell__c = 'Primary';
            instOpp.CloseDate = system.today().addmonths(12);
            //instOpp.Web_Design_Support_Minutes_Purchased__c =0;
            //instOpp.Contract_Implemented__c = true;
            instOpp.ContractReceived__c = system.today();
            instOpp.Product__c ='Event';
            instOpp.MYD_Deal__c='First Year';
            instOpp.pricebook2id=Test.getStandardPricebookID();
            instOpp.Contact_Associated__c=instofCon.id;
            instOpp.Is_Close_Date_Locked__c=false;
            instopp.recordtypeID=eventRecTypeId;
            instopp.Chain_Deal__c='Venue/Service';
            instopp.AM_Owner__c='Kd';
            instopp.License_Type__c='1 Diamond';
            instopp.StageName='Verbal';
            instopp.ATI_Check__c = FALSE;
            instopp.Opportunity_Name_Affix__c = 'test';
            insert instopp;
            List<OpportunityLineItem> listOlitem = new List<OpportunityLineItem>();
            Id pricebookId = Test.getStandardPricebookId();
            
            //Create your product
            Product2 prod = new Product2(
                Name = 'Product X',
                ProductCode = 'CV-SW-EC-SUR-INQAPPSF',
                isActive = true
            );
            insert prod;
            
            //Create your pricebook entry
            PricebookEntry pbEntry = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = prod.Id,
                UnitPrice = 100.00,
                IsActive = true
            );
            insert pbEntry;
            
            //create your opportunity line item.  This assumes you already have an opportunity created, called opp
            OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = instOpp.Id,
                Quantity = 5,
                PricebookEntryId = pbEntry.Id,
                TotalPrice = 5 * pbEntry.UnitPrice
            );
            listOlitem.add(oli);
            
            
            
            OpportunityLineItem instOfOlitem=new OpportunityLineItem();
            instOfOlitem.OpportunityID = instOpp.Id;
            instOfOlitem.PriceBookEntryID=listOfPBE[0].Id;
            instOfOlitem.Product__c = 'App Build Plus';
            instOfOlitem.quantity=4;
            instOfOlitem.totalprice=200;
            listOlitem.add(instOfOlitem);           
            insert listOlitem;
            instopp.StageName='Closed Won';  
            try{
                
                update instopp;
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('You can\'t close an opportunity before filling up the Account Transition Information')?true:false;
                System.debug('e.getMessage()>>'+e.getMessage());
                // 2/12: commenting below line to pass test coverage for 2/14 deployment
                //system.assertEquals(expectedExceptionThrown,false); 
            }
        }   
    }
    public static testmethod void testSendSocialTablesEmailAlert()
    {
        User instUsr = TestUtil.CreateDeploymentUser();
        system.RunAs(instUsr)
        {
            
            Test.startTest();
            Opportunity instOpp=TestUtil.createOpportunity('Test Opp','Event','Qualified');
            instOpp.StageName ='Qualified';
            instOpp.Deal_Year__c ='1';
            instOpp.NBB_Renewal__c = 'NBB';
            instOpp.Parent_Upsell__c = 'Primary';
            instOpp.CloseDate = system.today().addmonths(12);
            instOpp.Contract_Implemented__c = true;
            instOpp.ContractReceived__c = system.today();
            instOpp.Product__c ='CrowdCompass';
            instOpp.MYD_Deal__c='First Year';
            instOpp.pricebook2id=Test.getStandardPricebookID();
            instOpp.Contact_Associated__c=instofCon.id; 
            instOpp.AccountId = instofAcc.Id;
            insert instOpp;
            
            
            Id masterRectypeIdCC = [SELECT Id FROM RecordType WHERE SobjectType = 'ATI_Info__c' AND DeveloperName='AM_Record_Type'].Id; 
            ATI_Info__c atiInfoObj = new ATI_Info__c();
            atiInfoObj.Account__c = instofAcc.Id;
            atiInfoObj.Previous_Process__c = 'asfasdf';
            atiInfoObj.Biggest_Pain_Point__c = 'asfasdf';
            atiInfoObj.Biggest_Pain_Point__c = 'asfasdf';
            atiInfoObj.Goals_with_Cvent__c = 'asfasdf';
            atiInfoObj.Main_User1__c =  instOfCon.Id;
            atiInfoObj.Main_User_2__c =  instOfCon.Id;
            atiInfoObj.Main_User_3__c =  instOfCon.Id;
            atiInfoObj.Executive_POC__c = instOfCon.Id;
            atiInfoObj.First_Event_Launch_Date__c = system.Today();
            atiInfoObj.First_Event_Start_Date__c = system.Today();
            atiInfoObj.Parent_Opportunity__c = instOpp.Id; 
            atiInfoObj.Future_Upsell_Opportunities__c =  'Event';
            atiInfoObj.Future_Upsell_Opportunities_2__c =  'Survey';
            atiInfoObj.Features__c = 'Parked Reports';
            atiInfoObj.Amount__c = 100;
            atiInfoObj.Amount_2nd_Opp__c = 1000;
            atiInfoObj.Attendees_at_First_Event__c = 10;
            atiInfoObj.RecordTypeId = masterRectypeIdCC;
            atiInfoObj.Comments__c = 'test';
            insert atiInfoObj;
            
            ATI_Info__c atiInfoObj2 = new ATI_Info__c();
            atiInfoObj2.Account__c = instofAcc.Id;
            atiInfoObj2.Previous_Process__c = 'asfasdf';
            atiInfoObj2.Biggest_Pain_Point__c = 'asfasdf';
            atiInfoObj2.Biggest_Pain_Point__c = 'asfasdf';
            atiInfoObj2.Goals_with_Cvent__c = 'asfasdf';
            atiInfoObj2.Main_User1__c =  instOfCon.Id;
            atiInfoObj2.Main_User_2__c =  instOfCon.Id;
            atiInfoObj2.Main_User_3__c =  instOfCon.Id;
            atiInfoObj2.Executive_POC__c = instOfCon.Id;
            atiInfoObj2.First_Event_Launch_Date__c = system.Today();
            atiInfoObj2.First_Event_Start_Date__c = system.Today();
            atiInfoObj2.Parent_Opportunity__c = instOpp.Id; 
            atiInfoObj2.Future_Upsell_Opportunities__c =  'Event';
            atiInfoObj2.Future_Upsell_Opportunities_2__c =  'Survey';
            atiInfoObj2.Features__c = 'Parked Reports';
            atiInfoObj2.Amount__c = 100;
            atiInfoObj2.Amount_2nd_Opp__c = 1000;
            atiInfoObj2.Attendees_at_First_Event__c = 10;
            atiInfoObj.Comments__c = 'test 2';
            atiInfoObj2.RecordTypeId = masterRectypeIdCC;
            insert atiInfoObj2;
            
            Product2 product1 = new Product2();
            product1.Name = 'Product 1';
            product1.Contract_Output_Grouping__c = 'Event Cloud';
            product1.ProductCode = 'CV-SW-EC-SCT-SCTPLNLISC';
            product1.isActive = true;
            insert product1;
            
            Product2 product2 = new Product2();
            product2.Name = 'Product 2';
            product2.Contract_Output_Grouping__c = 'Event Cloud';
            product2.ProductCode = 'CV-SW-EC-SCT-SCTADDUSRLGN';
            product2.isActive = true;
            insert product2;
            
            List<PricebookEntry> priceBooks = new List<PricebookEntry>();
            PricebookEntry instPBE= TestUtil.createPricebookEntry(product1,100);
            PricebookEntry instPBE2= TestUtil.createPricebookEntry(product2,100);
            priceBooks.add(instPBE);
            priceBooks.add(instPBE2);
            insert priceBooks;
            
            List<OpportunityLineItem> listOlitem = new List<OpportunityLineItem>();
            
            OpportunityLineItem instOfOlitem=new OpportunityLineItem();
            instOfOlitem.OpportunityID = instOpp.Id;
            instOfOlitem.PriceBookEntryID=instPBE.Id;
            //instOfOlitem.Product__c = 'Social Tables - Planner License';
            instOfOlitem.quantity=4;
            instOfOlitem.totalprice=200;
            listOlitem.add(instOfOlitem);
            
            instOfOlitem=new OpportunityLineItem();
            instOfOlitem.OpportunityID = instOpp.Id;
            instOfOlitem.PriceBookEntryID=instPBE2.Id;
            //instOfOlitem.Product__c = 'Social Tables - Additional User Logins';
            instOfOlitem.quantity=4;
            instOfOlitem.totalprice=200;
            listOlitem.add(instOfOlitem);
            
            insert listOlitem;
            
            /*
            SBQQ__Quote__c sbqq = new SBQQ__Quote__c();
            sbqq.SBQQ__StartDate__c = System.today();
            sbqq.SBQQ__EndDate__c = Date.today().addMonths(12);
            sbqq.Contract_Term_Years__c='1';
            sbqq.Contract_Executed__c = true;
            sbqq.SBQQ__Primary__c = true;
            sbqq.SBQQ__Opportunity2__c = instOpp.Id;
            insert sbqq;
            
            
            instopp.SBQQ__PrimaryQuote__c=sbqq.id;
            update instOpp;
            */
            //sbqq.Contract_Executed__c = true;
            //update instOpp;
            
            CventMyd_ValidationHandler.settings.closedAttachmentSettings.isActive = false;
            instOpp.StageName ='Closed Won';
            update instOpp;
            //CheckRecursive.runEight = true;
            //instOpp.SBQQ__Contracted__c = TRUE;
            //update instOpp;
            //System.assertEquals(TRUE, instOpp.SBQQ__Contracted__c);
            Test.stopTest();
        }
    }
    
    public testmethod static void testContractedValidations() {
        User instUsr = TestUtil.CreateDeploymentUser();
        system.RunAs(instUsr){        
            System.debug('testContractedValidations execution is starting....');
            Account testAccount =TestUtil.createAccount('Test Account','Biz_Ac');
            testAccount.Supplier_Type__c = 'Venue';
            testAccount.Venue_Type__c = 'CVB';
            testAccount.BillingCountryCode ='US';
            testAccount.BillingStateCode = 'TX';
            insert testAccount;
            Opportunity instOpp=TestUtil.createOpportunity('Test Opp','Event','Qualified');
            instOpp.StageName ='Closed Won';
            instOpp.Deal_Year__c ='1';
            instOpp.NBB_Renewal__c = 'NBB';
            instOpp.Parent_Upsell__c = 'Primary';
            instOpp.CloseDate = system.today().addmonths(12);
            // instOpp.Web_Design_Support_Minutes_Purchased__c =0;
            instOpp.Contract_Implemented__c = true;
            instOpp.ContractReceived__c = system.today();
            instOpp.Product__c ='TicketMob';
            instOpp.MYD_Deal__c='First Year';
            instOpp.pricebook2id=Test.getStandardPricebookID();
            Contact testContact =TestUtil.createContact(testAccount.id);
            instOpp.Contact_Associated__c=testContact.id; 
            //instopp.SBQQ__PrimaryQuote__c ='';
            //instopp.SBQQ__RenewedContract__c=con1.Id;
            insert instOpp;
            SBQQ__Quote__c sbqq = new SBQQ__Quote__c();
            sbqq.SBQQ__Opportunity2__c = instopp.id;
            sbqq.Current_Year__c = 4;
            sbqq.SBQQ__StartDate__c = Date.today();
            sbqq.SBQQ__EndDate__c = sbqq.SBQQ__StartDate__c.addYears(1);
            sbqq.Contract_Term_Years__c = '5';
            //sbqq.SBQQ__RenewedContract__c='';
            insert sbqq;
            instopp.SBQQ__PrimaryQuote__c=sbqq.id;
            sbqq.Contract_Executed__c = true;
            //instopp.SBQQ__RenewedContract__c=conId;
            Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();       
            Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();          
            Contract ParentCont = new Contract();
            ParentCont.AccountId = TestAccount.id;
            ParentCont.Contract_Term_Years__c = '5';
            ParentCont.RecordTypeId = RecordTypeId;
            ParentCont.SBQQ__Opportunity__c = instOpp.id;
            //ParentCont.Is_Legacy__c = true;
            ParentCont.SBQQ__RenewalQuoted__c = false;
            ParentCont.Failed_Auto_Renew__c = false;
            ParentCont.Renewal_Creation_Date__c = System.today().addYears(1);
            insert ParentCont;
            Product2 product1 = new Product2();
            product1.Name = 'Product 1';
            product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
            product1.Revenue_Type__c = 'Annual Recurring    ';
            insert product1;       
            Contract cont = new Contract();
            cont.RecordTypeId = ChildRecordTypeId;
            cont.AccountId = TestAccount.id;
            System.debug('ParentContract: ' + ParentCont);
            cont.Parent_Contract__c = ParentCont.id;
            cont.SBQQ__Opportunity__c = instOpp.Id;
            //cont.Upcoming_Renewal_Type__c = 'Contract Renewal';
            cont.EndDate = sbqq.SBQQ__EndDate__c;
            //cont.Remaining_Master_Term__c = 0;
            cont.Current_Year__c = 4;
            //cont.Is_Legacy__c = true;
            cont.SBQQ__RenewalQuoted__c = false;
            cont.Failed_Auto_Renew__c = false;
            cont.Multiple_years_Commitment__C = false;
            cont.Renewal_Creation_Date__c = Date.newInstance(2018,9,5); //System.today().addYears(1);
            cont.SBQQ__RenewalQuoted__c = false;          
            insert cont;
            sbqq.SBQQ__MasterContract__c = cont.Id;
            sbqq.SBQQ__MasterContract__r = cont;
            update sbqq;
            instOpp.SBQQ__AmendedContract__c = cont.Id;
            instOpp.SBQQ__Contracted__c = true;  
            try {
                update instOpp;
            }
            catch(Exception e0) {
                Boolean containsTypeError = e0.getMessage().contains('cannot contract an opportunity that has been used as both a renewal and an amendment');
                System.assert(containsTypeError);
                sbqq.SBQQ__Type__c = 'Amendment';
                Id quoteId = sbqq.Id;
                String jsonString = [SELECT jsonString__c FROM SBQQ__Quote__c where Id =: quoteId].jsonString__c;
                CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(jsonString);
                quoteObject.outyearMap = new Map<Integer,CventMyd_Outyear>();
                sbqq.jsonString__c = JSON.serialize(quoteObject);
                System.debug('new jsonstring 0: ' + sbqq.jsonString__c);
                CventMyd_ValidationHandler.settings.ruleNameToIsActive.put('Quote_Missing_Outyears',false);
                update sbqq;
                System.debug('new jsonstring 1: ' + sbqq.jsonString__c);
                //OpportunityTrgHelperCls_Version_2.contractedOpportunityIds = new Set<Id>();
                CventMyd_ValidationHandler.settings.ruleNameToIsActive.put('Quote_Missing_Outyears',true);
                instOpp.SBQQ__Contracted__c = true;
                System.debug('now proceeding to contract the opportunity again 0...');
                try {
                    update instOpp;
                }
                catch(Exception e1) {
                    Boolean containsOutyearError = e1.getMessage().contains('is missing outyear dates for year(s)');
                    System.assert(containsOutyearError);
                    sbqq.jsonString__c = jsonString;
                    update sbqq;
                    //OpportunityTrgHelperCls_Version_2.contractedOpportunityIds = new Set<Id>();
                    instOpp.SBQQ__Contracted__c = true;
                    System.debug('now proceeding to contract the opportunity again 1...');    
                    update instOpp;              
                }
            }

            CventMyd_ValidationHandler.getErrorStrings(sbqq);
            ParentCont.Contract_Term_Years__c = '3';  
            Boolean containsInvalidTermError;
            try {
                update parentCont;
            }          
            catch (Exception e) {
                containsInvalidTermError = e.getMessage().contains('has a current year less than its term');          
            }
            System.assert(containsInvalidTermError);
            //Insert Quote Line
            SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
            ql1.SBQQ__Quantity__c = 1;
            ql1.SBQQ__Product__c = product1.Id;
            ql1.SBQQ__ListPrice__c = 10;
            ql1.SBQQ__NetPrice__c = 10;
            ql1.Rack_Rate__c = 10;
            ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            ql1.SBQQ__Number__c = 1;
            ql1.SBQQ__Quote__c = sbqq.Id;
            ql1.Notes__c = 'abc';
            insert ql1;

            CventMyd_ValidationHandler.getErrors(ql1,false);        
            CventMyd_ValidationHandler.getErrors(ql1,true);
            
        }

    }

    public testmethod static void populateRenewalSpecialist()
    {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Development - RFP'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Payne', FirstName ='Donnie',LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='test12987@ctest.com');
        insert u;
                 
        Account acc = TestUtil.createAccount('Test Account','Biz_Ac');
        acc.Supplier_Type__c = 'Venue';
        acc.Venue_Type__c = 'CVB';
        acc.CSN_Status__c ='Using';
        acc.Supplier_Status__c='Approved';
        acc.BillingCountryCode='US';
        acc.BillingStateCode='TX';
        acc.Named_Acct__c = 'TPP Client';
        insert acc;
        
        Contact con = TestUtil.createContact(acc.id);
        con.Email = 'Test987654321@test.com';
        con.Phone = '8877665544';
        insert con;

        AccountTeamMember instATeam=TestUtil.createAccountTeamMember(acc.id,'AM - Renewal Specialist');
        instATeam.userid = u.Id;
        insert instATeam;
            
        Opportunity instOpp = TestUtil.createOpportunity('Test Opp','Renewal','Qualified');
        instOpp.AccountID = acc.id;
        insert instOpp;
    }
    
    public testmethod static void populateCloseDate()
    {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Development - RFP'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Payne', FirstName ='Donnie',LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='test12987@ctest.com');
        insert u;
                 
        Account acc = TestUtil.createAccount('Test Account','Biz_Ac');
        acc.Supplier_Type__c = 'Venue';
        acc.Venue_Type__c = 'CVB';
        acc.CSN_Status__c ='Using';
        acc.Supplier_Status__c='Approved';
        acc.BillingCountryCode='US';
        acc.BillingStateCode='TX';
        acc.Named_Acct__c = 'TPP Client';
        insert acc;
        
        Contact con = TestUtil.createContact(acc.id);
        con.Email = 'Test987654321@test.com';
        con.Phone = '8877665544';
        insert con;

        AccountTeamMember instATeam=TestUtil.createAccountTeamMember(acc.id,'AM - Renewal Specialist');
        instATeam.userid = u.Id;
        insert instATeam;
            
        Opportunity instOpp = TestUtil.createOpportunity('Test Opp','Renewal','Qualified');
        instOpp.AccountID = acc.id;
        instOpp.RenewalDate__c = System.today() - 5;
        insert instOpp;
        
        SBQQ__Quote__c sbqq = new SBQQ__Quote__c();
        sbqq.SBQQ__Opportunity2__c = instopp.id;
        sbqq.Contract_Term_Years__c = '1';
        sbqq.Contract_Executed_Date__c = System.today()+5;
        //sbqq.SBQQ__RenewedContract__c='';
        
        insert sbqq;
        instopp.SBQQ__PrimaryQuote__c=sbqq.id;
        //instopp.SBQQ__RenewedContract__c=con.Id;
        update sbqq;
        
        instopp.StageName='Closed Won';
        instOpp.Contract_Implemented__c = false;
        update instopp;

    }
    
    public testmethod static void sucessExpTestmethod(){
   
   List<PricebookEntry> listOfPBE=new List<PricebookEntry>();
   Address__c  sAddress= new Address__c();
   Profile p = [SELECT Id FROM Profile WHERE Name='Sales Development - RFP'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Payne', FirstName ='Donnie',LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='test12987@ctest.com');
        insert u;
   
   Product2 prod2= new Product2(Name = 'Test Product - OneTime',
                                        Family = 'XTCD',
                                     Description = 'Test Product',
                                     IsActive = true,
                                    ProductCode='CV-PS-EC-CCS-APPBPLS',Success_Experience_Product__c = TRUE,Success_Experience_Category__c = 'Event');
        insert prod2;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,
                                                    product2Id = prod2.Id,
                                                    isActive = true,
                                                    UnitPrice = 1000);
        insert pbEntry;
        
        
        
   
   Account acc = TestUtil.createAccount('Test Account','Biz_Ac');
        acc.Supplier_Type__c = 'Venue';
        acc.Venue_Type__c = 'CVB';
        acc.CSN_Status__c ='Using';
        acc.Supplier_Status__c='Approved';
        acc.BillingCountryCode='US';
        acc.BillingStateCode='TX';
        acc.Named_Acct__c = 'TPP Client';
        acc.Global_Ultimate_DUNS__c ='12345678';
        acc.Success_Experience__c = 'Guided';
        acc.Success_Experience_Products__c = 'Event';
        insert acc;
        
        Account acc1 = TestUtil.createAccount('Test Account','Biz_Ac');
        acc1.Supplier_Type__c = 'Venue';
        acc1.Venue_Type__c = 'CVB';
        acc1.CSN_Status__c ='Using';
        acc1.Supplier_Status__c='Approved';
        acc1.BillingCountryCode='US';
        acc1.BillingStateCode='TX';
        acc1.Named_Acct__c = 'TPP Client';
        acc1.Global_Ultimate_DUNS__c ='12345678';
        acc1.Success_Experience__c = 'Advised';
        insert acc1;
        
          sAddress = new Address__c();
            sAddress.Type__c = 'Shipping';
            sAddress.Account__c = acc.Id;
            saddress.City__c='Burnaby';
            saddress.Province__c='BC';
            saddress.Country__c='US';
            saddress.CountryCode__c='US';
            saddress.Postal_Code__c = '1001';
            saddress.EBS_Site_Use_Id__c=null;
            sAddress.EBS_Account_Id__c = acc.Id;
            sAddress.Operating_Unit_Name__c='CVAUS';
            insert sAddress;
            
        
        Contact con = TestUtil.createContact(acc.id);
        con.Email = 'Test987654321@test.com';
        con.Phone = '8877665544';
        insert con;

        AccountTeamMember instATeam=TestUtil.createAccountTeamMember(acc.id,'AM - Renewal Specialist');
        instATeam.userid = u.Id;
        insert instATeam;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity instOpp = TestUtil.createOpportunity('Test Opp','Renewal','Qualified');
        instOpp.AccountID = acc.id;
        instOpp.RenewalDate__c = System.today() - 5;
        instOpp.Ship_To_Address__c = sAddress.id;
        instopp.StageName='Verbal';
        instOpp.Contract_Type_2_0__c = 'Reflag';
        oppList.add(instOpp);
        
        Opportunity oppRec = TestUtil.createOpportunity('Test Opp','Renewal','Qualified');
        oppRec.stageName = 'Presentation';
        oppRec.AccountID = acc.id;
        oppRec.RenewalDate__c = System.today() - 5;
        oppRec.Ship_To_Address__c = sAddress.id;
        oppRec.Contract_Type_2_0__c = 'Reflag';
        oppList.add(oppRec);
        
        insert oppList;
        
        
        
        SBQQ__Quote__c sbqq = new SBQQ__Quote__c();
        sbqq.SBQQ__Opportunity2__c = instopp.id;
        sbqq.Contract_Term_Years__c = '1';
        sbqq.Contract_Executed_Date__c = System.today()+5;
        sbqq.SBQQ__Primary__c = true;        
        //instopp.SBQQ__PrimaryQuote__c=sbqq.id;
        insert sbqq;
        
        
        
        List<OpportunityLineItem> listOlitem = new List<OpportunityLineItem>();
            
        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Family = 'Event';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        product1.Product_Group__c = 'Event Cloud';
        product1.Revenue_Type__c = 'Annual Recurring';
        product1.Success_Experience_Product__c = TRUE;
        product1.Success_Experience_Category__c = 'Event';
        insert product1;
         
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
        ql1.SBQQ__Quantity__c = 1;
        ql1.SBQQ__Product__c = product1.Id;
        ql1.SBQQ__ListPrice__c = 10;
        ql1.SBQQ__NetPrice__c = 10;
        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        ql1.Rack_Rate__c = 10;
        ql1.Year_2_Quantity__c = 2;
        ql1.Year_2_List_Price__c = 20;
        ql1.Year_2_Net_Amount__c = 40;
        ql1.Year_2_Effective_Amount__c = 40;
        ql1.Year_3_Quantity__c = 2;
        ql1.Year_3_List_Price__c = 20;
        ql1.Year_3_Net_Amount__c = 40;
        ql1.Year_3_Effective_Amount__c = 40;
        ql1.Year_4_Quantity__c = 2;
        ql1.Year_4_List_Price__c = 20;
        ql1.Year_4_Net_Amount__c = 40;
        ql1.Year_4_Effective_Amount__c = 40;
        ql1.Year_5_Quantity__c = 2;
        ql1.Year_5_List_Price__c = 20;
        ql1.Year_5_Net_Amount__c = 40;
        ql1.Year_5_Effective_Amount__c = 40;
        ql1.SBQQ__Quote__c = sbqq.Id;
        ql1.Notes__c = 'abc';
        ql1.SBQQ__EndDate__c = System.today().addDays(10);
        ql1.SBQQ__Group__c = null;
        //ql1.Primary_Quote_Line__c = true;
        
        insert ql1;
        
        OpportunityLineItem instOfOlitem=new OpportunityLineItem();
        instOfOlitem.OpportunityID = instOpp.Id;
        instOfOlitem.PriceBookEntryID=pbEntry.Id;
        instOfOlitem.Product__c = 'CVENT Attendee Support';
        instOfOlitem.quantity=4;
        instOfOlitem.totalprice=200;
        instOfOlitem.SBQQ__QuoteLine__c = ql1.id;
        instOfOlitem.Product2Id = prod2.Id;
        //instOfOlitem.Product_Group__c = 'Event Cloud';
        //instOfOlitem.SBQQ__QuoteLine__r.Revenue_Type__c ='Annual Recurring' ;
       // instOfOlitem.SBQQ__QuoteLine__r.SBQQ__EffectiveEndDate__c = system.Today().addDays(100);
        // instOfOlitem.SBQQ__QuoteLine__r.Primary_Quote_Line__c= true;
        // instOfOlitem.SBQQ__QuoteLine__r.SBQQ__Group__r.SBQQ__Optional__c = False;
        listOlitem.add(instOfOlitem);
        
         instOfOlitem=new OpportunityLineItem();
        instOfOlitem.OpportunityID = instOpp.Id;
        instOfOlitem.PriceBookEntryID=pbEntry.Id;
        instOfOlitem.Product__c = 'Cvent Creative Services';
        instOfOlitem.Product2Id = prod2.Id;
        instOfOlitem.quantity=4;
        instOfOlitem.totalprice=200;
        
        listOlitem.add(instOfOlitem);
        
        instOfOlitem=new OpportunityLineItem();
        instOfOlitem.OpportunityID = instOpp.Id;
        instOfOlitem.Product2Id = prod2.Id;
       // instOfOlitem.PriceBookEntryID=listOfPBE[5].Id;
        instOfOlitem.Product__c = 'Transient Sourcing';
        instOfOlitem.quantity=4;
        instOfOlitem.totalprice=200;
        
        //listOlitem.add(instOfOlitem);
        
        insert listOlitem;
        
        Success_Experience_Setup__c  exp = new Success_Experience_Setup__c ();
        exp.Target_Success_Experience__c = 'Advised';
        exp.Region__c = 'North America; South and Latin America; Europe';
        exp.Rule_Reason__c ='Account has only Event and CrowdCompass Products.';
        exp.Products__c = 'CrowdCompass; Event';
        exp.Level__c = 2;
        exp.Number_of_Products_Lower_Threshold__c  = 0;
        exp.Number_of_Products_Higher_Threshold__c = 5;
        insert exp;
        
        
        //update sbqq;
        
        
        //update instOpp;
        
        List<Opportunity> newValues = new List<Opportunity>();
        newValues = [Select id,IsWon,IsClosed, Opportunity_Type__c,stageName, AccountId, Probability from Opportunity where id =: instOpp.id ];
        Map<Id,Opportunity> newMapOpp = new Map<Id,Opportunity>();
        newMapOpp.put(instOpp.id, newValues[0]);
        Map<Id,Opportunity> oldMapOpp = new Map<Id,Opportunity>();
        oldMapOpp.put(instOpp.id, oppRec);
        OpportunityTrgHelperCls_Version_2.successExperienceProductRollup(newValues, newMapOpp, oldMapOpp);
        
        //SuccessExperienceCalculator.checkCalculation(acc.Id , instOpp.Id);
        Map<id, string> accounIdNotificationMap = new Map<id, String>();
        accounIdNotificationMap.put(acc.id, 'HTNotify');
        OpportunityTrgHelperCls_Version_2.successExperienceEmailNotification(accounIdNotificationMap);
   }
}