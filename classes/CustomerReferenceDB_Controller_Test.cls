@isTest
public class CustomerReferenceDB_Controller_Test {
    //Global variables
    private static Account acc;
    private static Contact con;
    private static Advocates__c advRec;
    private static AdvocateHub__AdvocacyActivity__c advActivity;
    private static List<Account> accList;
    private static List<Contact> conList;
    private static User testUser;
    
    //test data setup method
    @testsetup public static void testData(){        
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        accList = new List<Account>();
        Integer recCount =0;
        for(Integer i = 0; i < 5; i++){            
            acc = new Account(of_Employees_New__c = '51 to 200 employees', 
                              Revenue__c  = 200.00, 
                              Purchased_License__c = 'Event - Enterprise',
                              Account_Status__c = 'Active',
                              BillingCountryCode = 'US',
                              BillingCity = 'Arlington',
                              BillingStateCode = 'VA',
                              Name = 'Aerospace Industries Association'+i, 
                              AM_Event__c = 'Scott Ritter', 
                              Back_Office_System__c = 'TMA Resources',
                              Account_Management_Tier__c = 'Tier - 1',
                              Sic = '861'+i,
                              SicDesc ='Business Associations',
                              Segment__c = 'Association',
                              Industry_Sub_Segment_for_Hospitality__c = 'Aerospace & Defense',
                              Industry_for_Hospitality__c = 'Manufacturing');
            accList.add(acc);
        }
        insert accList;
        
        conList = new List<Contact>();
        con = new Contact(AccountId = accList[0].Id,
                          FirstName = 'Jean', 
                          LastName = 'Spaulding', 
                          Title = 'Director, Sales & Marketing', 
                          Email = 'jspaulding@omnihotels.com', 
                          Phone = '4072836520', 
                          Job_Function__c = 'Marketing', 
                          /*Manager_Email__c = 'rkonwar@cvent.com.test', */
                          RoleinDecision__c = 'Decision-maker', 
                          MailingCity = 'Championsgate', 
                          MailingState = 'FL', 
                          MailingCountry = 'US',
                          AdvocateHub__Date_Joined_AdvocateHub__c = system.now());
        conList.add(con);
        insert conList;       
    }
    
    public static testmethod void validateLastDataDump(){
        TestData();
        Test.startTest();
        advActivity = new AdvocateHub__AdvocacyActivity__c();            
        advActivity.Name = '#TuesdayTip - Send a Save the Date';
        advActivity.AdvocateHub__Description__c = 'Cvent Blog - Read tips on how to drive registration by sending a save the date.';
        advActivity.AdvocateHub__Contact__c = conList[0].Id;
        advActivity.AdvocateHub__ExternalId__c = 28388;
        advActivity.AdvocateHub__Status__c = 'Active';
        insert advActivity;
        
        advRec = new Advocates__c();
        advRec.Status__c = 'Active';
        advRec.Contact__c = conList[0].Id;
        insert advRec;
        
        Test.setCurrentPage(Page.CustomerReferenceDB_Search);        
        // Initialising StandardSetController Extension
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(accList);  
        // This method gives selected records
        setCon.setSelected(accList);   
        CustomerReferenceDB_Controller cusRefController = new CustomerReferenceDB_Controller();
        cusRefController.con = setCon;
        cusRefController.acc.Segment__c = 'Education';
        cusRefController.acc.Industry_for_Hospitality__c = 'Manufacturing';
        cusRefController.acc.Industry_Sub_Segment_for_Hospitality__c = 'Aerospace & Defense';
        cusRefController.acc.BillingStateCode = 'VA';
        cusRefController.advocateOnly = true;
        update conList;
        
        cusRefController.getLstDataDump();  
        cusRefController.saveExportCirteriaAction();
        cusRefController.generateExportDataAction();
        cusRefController.previous();
        cusRefController.next();
        Test.stopTest();
    }
    
    public static testmethod void validateSearchAction(){
        testData();
        Test.startTest();
        Test.setCurrentPage(Page.CustomerReferenceDB_Search);        
        // Initialising StandardSetController Extension
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(accList);  
        // This method gives selected records
        setCon.setSelected(accList);   
        CustomerReferenceDB_Controller cusRefController = new CustomerReferenceDB_Controller();
        cusRefController.con = setCon;
        cusRefController.acc.Segment__c = 'Education';
        cusRefController.acc.Industry_for_Hospitality__c = 'Manufacturing';
        cusRefController.acc.Industry_Sub_Segment_for_Hospitality__c = 'Aerospace & Defense';
        cusRefController.acc.BillingStateCode = 'VA';
        cusRefController.advocateOnly = true;        
        cusRefController.selectedProduct = 'Event';        
        cusRefController.advocateOnly = false;
        cusRefController.searchAction();
        cusRefController.selectedProduct = 'Survey';
        cusRefController.searchAction();
        cusRefController.selectedProduct = 'SMM';
        cusRefController.searchAction();
        cusRefController.selectedProduct = 'CSN';
        cusRefController.searchAction();
        cusRefController.selectedProduct = 'RFP';
        cusRefController.searchAction();
        cusRefController.selectedProduct = 'CrowdCompass';
        cusRefController.searchAction();
        cusRefController.getLstDataDumpDownload();        
        Test.stopTest();
        //cusRefController = new CustomerReferenceDB_Controller(setCon); 
    }
    
    // Test method for CustomerReferenceDBBatch
    public static testmethod void CustomerReferenceDBBatch(){
        Test.startTest();
        Profile prof = [select id from profile where name='System Administrator'];
        User usr = new User(alias = 'usr123', email='us123.name@vmail.com',
                            emailencodingkey='UTF-8', lastname='lstname123',
                            timezonesidkey='America/Los_Angeles',
                            languagelocalekey='en_US',
                            localesidkey='en_US', profileid = prof.Id,
                            username='testuser128123@testorg.com');
        insert usr;
        Account accRec = new Account(name='TestName', Ownerid = usr.id);
        accRec.BillingCountry='MX';
        insert accRec ;
        
        Boolean CustRefDBBatch = false;        
        CustomerReferenceDBBatch objBatch = new CustomerReferenceDBBatch(CustRefDBBatch);
        ID batchprocessid1 = Database.executeBatch(objBatch); 
        CustRefDBBatch = true;
        objBatch = new CustomerReferenceDBBatch(CustRefDBBatch);
        ID batchprocessid2 = Database.executeBatch(objBatch); 
        Test.stopTest();
    }
}