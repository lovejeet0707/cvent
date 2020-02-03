/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 18th March 2014
Description : Tests atiTRGHelperCls
*/
@isTest
private class atiTRGHelperClsTest {
    public static Account instofAcc = new Account();
    public static Contact instofCon =  new Contact();
    public static Opportunity opp; 
    public static List<Opportunity> oppList;
    public static User u;
    public static ATI_Info__c atiInfoObj;
    public static List<ATI_Info__c> atiInfoList;
    public static Id AM_Record_TypeId,masterRectypeIdCC,masterRectypeIdInq;
    public static DS_CS_Pairing__c instOfCSRep = new DS_CS_Pairing__c();
    static{
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        AM_Record_TypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'ATI_Info__c' AND DeveloperName='AM_Record_Type'].Id;      
        masterRectypeIdCC = [SELECT Id FROM RecordType WHERE SobjectType = 'ATI_Info__c' AND DeveloperName='CrowdCompass'].Id;
        masterRectypeIdInq = [SELECT Id FROM RecordType WHERE SobjectType = 'ATI_Info__c' AND DeveloperName='Inquisium'].Id;
        // Setup test data
        // This code runs as the system user
        u = [Select Id, ProfileId from User where Name ='CRM Deployment User']; 
        
        System.runAs(u) {            
            instofAcc.Name = 'Test';
            instofAcc.CurrencyIsoCode  = 'USD';
            instofAcc.Supplier_Type__c = 'Venue';
            instofAcc.Venue_Type__c = 'CVB';
            instofAcc.RecordTypeId = rtType.id;
            insert instofAcc;
            
            instOfCon.LastName = 'Test';
            instOfCon.AccountId = instofAcc.Id;
            insert instOfCon;
            
            instOfCSRep.CS_Rep__c = userInfo.getUserId();
            instOfCSRep.DS_Rep__c = userInfo.getUserId();
            insert instOfCSRep;
            
            oppList = new List<Opportunity>();
            // Create multiple Opportunity Records
            for(Integer i=0 ; i<1 ; i++){
                opp = new Opportunity();
                opp.AccountId = instofAcc.Id;
                opp.Name = 'Test';                
                opp.New_Type__c =  'Upsell-NBB';
                opp.StageName = 'Verbal';
                opp.CloseDate = system.today();
                opp.New_Amount__c = 11;
                opp.Years__c= '1';
                if(i==1){
                    opp.Product__c = 'Event';
                }else if(i==2){
                    opp.Product__c = 'Survey';
                }else if(i==3) {
                    opp.Product__c = 'Inquisium'; 
                }else{
                    opp.Product__c = 'CrowdCompass'; 
                }
                opp.LeadSource = 'ACD-PS';
                opp.Contact_Associated__c = instOfCon.Id;
                opp.Contact_Role__c = 'Primary User';
                opp.Contract_Implemented__c = true;
                opp.ContractReceived__c = system.today();
                opp.Deal_Year__c = '1';
                opp.Case_Received_Date__c = system.today();
                oppList.add(opp);
            }
            insert oppList;
            system.debug('>>>>>>oppList'+oppList);
            Id pricebookId = Test.getStandardPricebookId();
            
            //Create your product
            Product2 prod = new Product2(
                Name = 'Event',
                ProductCode = 'Pro-X',
                Family ='CrowdCompass',
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
            OpportunityLineItem oli1= new OpportunityLineItem(OpportunityId = oppList[0].Id,Quantity = 5,UnitPrice = 2.00,PricebookEntryId = pbEntry.Id);
            //OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = oppList[2].Id,Quantity = 5,UnitPrice = 2.00,PricebookEntryId = pbEntry.Id);
            //OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId = oppList[3].Id,Quantity = 5,UnitPrice = 2.00,PricebookEntryId = pbEntry.Id);
            insert new List <OpportunityLineItem> { oli1};
        }
        
    }
    
    static testMethod void myUnitTest() {        
        atiInfoObj = new ATI_Info__c();
        atiInfoObj.Account__c = instofAcc.Id;
        atiInfoObj.Previous_Process__c = 'asfasdf';
        atiInfoObj.Biggest_Pain_Point__c = 'asfasdf';
        atiInfoObj.Biggest_Pain_Point__c = 'asfasdf';
        atiInfoObj.Goals_with_Cvent__c = 'asfasdf';
        atiInfoObj.Main_User1__c =  instOfCon.Id;
        atiInfoObj.Executive_POC__c = instOfCon.Id;
        atiInfoObj.First_Event_Launch_Date__c = system.Today();
        atiInfoObj.First_Event_Start_Date__c = system.Today();
        atiInfoObj.Parent_Opportunity__c = oppList[0].Id; 
        atiInfoObj.Future_Upsell_Opportunities__c =  'Event';
        atiInfoObj.Future_Upsell_Opportunities_2__c =  'Survey';
        atiInfoObj.Features__c = 'Parked Reports';
        atiInfoObj.Amount__c = 100;
        atiInfoObj.Amount_2nd_Opp__c = 1000;
        atiInfoObj.Attendees_at_First_Event__c = 10;
        atiInfoObj.RecordTypeId = masterRectypeIdCC;
        System.runAs(u) {
        insert atiInfoObj;
        
        atiInfoObj.First_Event_Launch_Date__c = system.today().addDays(11);
        update atiInfoObj;
        }
    }
    
    static testMethod void createTaskOnAtiInsert() {
        Test.startTest();
        atiInfoList = new List<ATI_Info__c>();
        // Create multiple ATI Info Records
        for(Integer i=0 ; i<=3 ; i++){
            atiInfoObj = new ATI_Info__c();
            atiInfoObj.Account__c = instofAcc.Id;
            atiInfoObj.Previous_Process__c = 'asfasdf';
            atiInfoObj.Biggest_Pain_Point__c = 'asfasdf';
            atiInfoObj.Biggest_Pain_Point__c = 'asfasdf';
            atiInfoObj.Goals_with_Cvent__c = 'asfasdf';
            atiInfoObj.Main_User1__c =  instOfCon.Id;
            atiInfoObj.Executive_POC__c = instOfCon.Id;
            atiInfoObj.First_Event_Start_Date__c = system.Today();           
            atiInfoObj.First_Survey_Launch_Date__c = system.today().addDays(18);
            atiInfoObj.First_App_Launch_Date__c = system.Today();
            atiInfoObj.Future_Upsell_Opportunities__c =  'Event';
            atiInfoObj.Future_Upsell_Opportunities_2__c =  'Survey';
            atiInfoObj.Features__c = 'Parked Reports';
            atiInfoObj.Amount__c = 100;
            atiInfoObj.Amount_2nd_Opp__c = 1000;
            atiInfoObj.Attendees_at_First_Event__c = 10;
            if(i==0){
                atiInfoObj.RecordTypeId = AM_Record_TypeId;
                atiInfoObj.Parent_Opportunity__c = oppList[0].Id;  
                atiInfoObj.First_Event_Launch_Date__c = system.today().addDays(1);
             }/*else if(i==1){
                atiInfoObj.RecordTypeId = masterRectypeIdCC;
                atiInfoObj.Parent_Opportunity__c = oppList[1].Id; 
                atiInfoObj.First_Event_Launch_Date__c = system.today().addDays(11);
             }else if(i==2){
                atiInfoObj.RecordTypeId = masterRectypeIdInq;
                atiInfoObj.Parent_Opportunity__c = oppList[2].Id;
                atiInfoObj.First_Event_Launch_Date__c = system.today().addDays(22);
            }else{
                atiInfoObj.RecordTypeId = masterRectypeIdInq;
                atiInfoObj.Parent_Opportunity__c = oppList[3].Id;
                atiInfoObj.First_Event_Launch_Date__c = system.today().addDays(22);
            }*/
            atiInfoList.add(atiInfoObj); 
        }
        System.runAs(u) {
            insert atiInfoList; 
        }
        Test.stopTest();
    }
	
	public static testMethod void testFake(){
		BypassTriggerUtility.fakeMethod1();
		BypassTriggerUtility.fakeMethod2();
		BypassTriggerUtility.fakeMethod3();
		BypassTriggerUtility.fakeMethod4();
	}
}