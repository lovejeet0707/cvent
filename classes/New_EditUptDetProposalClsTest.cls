/**
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 12th December 2014
Description : Test Class for whole Proposal Project Classes:New_EditProposalCls,UpdateProposalCls,ProposalDetailAltCls
 */
@isTest
private class New_EditUptDetProposalClsTest {
    static testMethod void myUnitTest(){
    	RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        Account instofAcc = new Account();
        instofAcc.Name = 'Test';
        //instofAcc.CurrencyIsoCode  = 'USD';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        insert instofAcc;
        
    	Contact instContact = new Contact();        
        instContact.LastName = 'Test';
        instContact.AccountId = instofAcc.Id;
        insert instContact;
        
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
        instOfOpp.Contact_Associated__c = instContact.Id;
        instOfOpp.Contact_Role__c = 'Primary User';
        instOfOpp.Contract_Implemented__c = true;
        instOfOpp.ContractReceived__c = system.today();
        instOfOpp.Deal_Year__c = '1';
        insert instOfOpp;
        
    	Proposal__c instOFProp = new Proposal__c();
    	instOFProp.Opportunity_Name__c =  instOfOpp.Id;
    	instOFProp.Contact_Name__c = instContact.Id;
    	instOFProp.Product__c = 'Crowd Compass';
    	insert instOFProp;
    	
    	list<Proposal__c> lsProp = new list<Proposal__c>();
    	lsProp.add(instOFProp);
    	
    	apexpages.currentpage().getparameters().put('OppId',instOfOpp.Id);
    	
    	ApexPages.StandardController sc = new ApexPages.StandardController(instOFProp);
        New_EditProposalCls instOfMEOC = new New_EditProposalCls(sc);
        instOfMEOC.cancelNow();
        instOfMEOC.test();
        String allValues = 1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1;
        allValues = allValues +','+ instContact.Id +','+ instOfOpp.Id +','+ 'Event' +','+ '' +','+ instOfOpp.Id;
        String [] lstOfValues = allValues.split(',', -2);
        system.debug(lstOfValues[34]);
        system.debug(lstOfValues[35]);
        system.debug(lstOfValues[36]);
        New_EditProposalCls.save(allValues);
        
    }
    static testMethod void myUnitTestSec(){
    	RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        Account instofAcc = new Account();
        instofAcc.Name = 'Test';
        //instofAcc.CurrencyIsoCode  = 'USD';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        insert instofAcc;
        
    	Contact instContact = new Contact();        
        instContact.LastName = 'Test';
        instContact.AccountId = instofAcc.Id;
        insert instContact;
        
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
        instOfOpp.Contact_Associated__c = instContact.Id;
        instOfOpp.Contact_Role__c = 'Primary User';
        instOfOpp.Contract_Implemented__c = true;
        instOfOpp.ContractReceived__c = system.today();
        instOfOpp.Deal_Year__c = '1';
        insert instOfOpp;
        
    	Proposal__c instOFProp = new Proposal__c();
    	instOFProp.Opportunity_Name__c =  instOfOpp.Id;
    	instOFProp.Contact_Name__c = instContact.Id;
    	instOFProp.Product__c = 'Event & Crowd Compass';
    	insert instOFProp;
    	
    	list<Proposal__c> lsProp = new list<Proposal__c>();
    	lsProp.add(instOFProp);
    	
    	apexpages.currentpage().getparameters().put('OppId',instOfOpp.Id);
    	
    	ApexPages.StandardController sc = new ApexPages.StandardController(instOFProp);
        New_EditProposalCls instOfMEOC = new New_EditProposalCls(sc);
        instOfMEOC.cancelNow();
        instOfMEOC.test();
        String allValues = 1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1;
        allValues = allValues +','+ instContact.Id +','+ instOfOpp.Id +','+ 'Event & Crowd Compass' +','+ '' +','+ instOfOpp.Id;
        allValues = allValues +','+ 1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1;
        New_EditProposalCls.save(allValues);
    }
    static testMethod void myUnitTestThird(){
    	
    	RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        
        Account instofAcc = new Account();
        instofAcc.Name = 'Test';
        //instofAcc.CurrencyIsoCode  = 'USD';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        insert instofAcc;
        
    	Contact instContact = new Contact();        
        instContact.LastName = 'Test';
        instContact.AccountId = instofAcc.Id;
        insert instContact;
        
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
        instOfOpp.Contact_Associated__c = instContact.Id;
        instOfOpp.Contact_Role__c = 'Primary User';
        instOfOpp.Contract_Implemented__c = true;
        instOfOpp.ContractReceived__c = system.today();
        instOfOpp.Deal_Year__c = '1';
        insert instOfOpp;
        
    	Proposal__c instOFProp = new Proposal__c();
    	instOFProp.Opportunity_Name__c =  instOfOpp.Id;
    	instOFProp.Contact_Name__c = instContact.Id;
    	instOFProp.Product__c = 'Event & Crowd Compass';
    	insert instOFProp;
    	
    	Integer counter = 0;
    	List<Contract_Year__c> lstContYear = new List<Contract_Year__c>();
    	for(Integer i=0;i<8;i++){
    		Contract_Year__c instOfContY = new Contract_Year__c();
    		counter++;
    		instOfContY.Row__c = counter;
    		instOfContY.Annual_Registrants__c = 1;
    		instOfContY.Second_Year_Term__c = 1;
    		instOfContY.Third_Year_Term__c = 1;
    		instOfContY.Fourth_Year_Term__c = 1;
    		instOfContY.Annual_Registrants__c = 1;
    		instOfContY.Second_Year_Term_Rack__c = 1;
    		instOfContY.Third_Year_Term_Rack__c = 1;
    		instOfContY.Fourth_Year_Term_Rack__c = 1;
    		instOfContY.Proposal__c = instOFProp.Id;
    		lstContYear.add(instOfContY);
    	}	
    	
    	insert lstContYear;
    	
    	apexpages.currentpage().getparameters().put('id',instOFProp.Id);
    	ApexPages.StandardController sc = new ApexPages.StandardController(instOFProp);
    	UpdateProposalCls instOFUpdatePro = new UpdateProposalCls(sc);
    	instOFUpdatePro.cancelNow();
    	String allValues = 1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1;
        allValues = allValues +','+ instContact.Id +','+ instOfOpp.Id +','+ 'Event & Crowd Compass' +','+ instOFProp.Id;
        allValues = allValues +','+ 1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1+','+1;
    	for(Contract_Year__c instOfContY : lstContYear){
    		allValues = allValues +','+ instOfContY.Id;
    	}
    	
    	allValues =  allValues + ','+ 3 +','+ 3;
    	UpdateProposalCls.save(allValues);
    }
    
    static testMethod void myUnitTestFourth(){
    	
    	RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        
        Account instofAcc = new Account();
        instofAcc.Name = 'Test';
        //instofAcc.CurrencyIsoCode  = 'USD';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        insert instofAcc;
        
    	Contact instContact = new Contact();        
        instContact.LastName = 'Test';
        instContact.AccountId = instofAcc.Id;
        insert instContact;
        
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
        instOfOpp.Contact_Associated__c = instContact.Id;
        instOfOpp.Contact_Role__c = 'Primary User';
        instOfOpp.Contract_Implemented__c = true;
        instOfOpp.ContractReceived__c = system.today();
        instOfOpp.Deal_Year__c = '1';
        insert instOfOpp;
        
    	Proposal__c instOFProp = new Proposal__c();
    	instOFProp.Opportunity_Name__c =  instOfOpp.Id;
    	instOFProp.Contact_Name__c = instContact.Id;
    	instOFProp.Product__c = 'Event & Crowd Compass';
    	insert instOFProp;
    	
    	Integer counter = 0;
    	List<Contract_Year__c> lstContYear = new List<Contract_Year__c>();
    	for(Integer i=0;i<8;i++){
    		Contract_Year__c instOfContY = new Contract_Year__c();
    		counter++;
    		instOfContY.Row__c = counter;
    		instOfContY.Annual_Registrants__c = 1;
    		instOfContY.Second_Year_Term__c = 1;
    		instOfContY.Third_Year_Term__c = 1;
    		instOfContY.Fourth_Year_Term__c = 1;
    		instOfContY.Annual_Registrants__c = 1;
    		instOfContY.Second_Year_Term_Rack__c = 1;
    		instOfContY.Third_Year_Term_Rack__c = 1;
    		instOfContY.Fourth_Year_Term_Rack__c = 1;
    		instOfContY.Proposal__c = instOFProp.Id;
    		lstContYear.add(instOfContY);
    	}	
    	
    	insert lstContYear;
    	
    	apexpages.currentpage().getparameters().put('id',instOFProp.Id);
    	ApexPages.StandardController sc = new ApexPages.StandardController(instOFProp);
    	ProposalDetailAltCls instOFUpdatePro = new ProposalDetailAltCls(sc);
    	instOFUpdatePro.deleteNow();
    	instOFUpdatePro.editNow();
    	instOFUpdatePro.sendPropNow();
    }
}