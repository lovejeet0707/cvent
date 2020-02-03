/**
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 20th Nov 2014
Description : To Test AdvertDetailTrgHelperCls
 */
@isTest
private class AdvertDetailTrgHelperClsTest {
	
	public static Id createAccount(){
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType = 'Account' And DeveloperName = 'Biz_Ac' And IsActive=true];
        Account instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        insert instofAcc;
        return instofAcc.id;
    }
    static testMethod void myUnitTest() {
        List<Advertiser_Detail__c> lstAdvertDet = new List<Advertiser_Detail__c>();
        RecordType instRecType = [SELECT ID FROM RecordType WHERE SobjectType= 'Advertiser_Detail__c' AND DeveloperName = 'Advertised_with_Competitor' AND IsActive= true LIMIT 1];
         
        Advertiser_Detail__c instOfAdvtDet = new Advertiser_Detail__c();
        instOfAdvtDet.Supplier_Account__c = createAccount();
		instOfAdvtDet.Advertised_in_Year__c = '2009';
		instOfAdvtDet.Competitor_Name__c = 'Expedia';
		instOfAdvtDet.RecordTypeId = instRecType.Id;
		lstAdvertDet.add(instOfAdvtDet);
		
		Advertiser_Detail__c instOfAdvtDetSec = new Advertiser_Detail__c();
        instOfAdvtDetSec.Supplier_Account__c = createAccount();
		instOfAdvtDetSec.Advertised_in_Year__c = '2010';
		instOfAdvtDetSec.Competitor_Name__c = 'Bizbash';
		instOfAdvtDetSec.RecordTypeId = instRecType.Id;
		lstAdvertDet.add(instOfAdvtDetSec);
		
		insert lstAdvertDet;
		
		Account instOfAcc =[SELECT Id,Adv_w_Competitor__c FROM Account WHERE ID=:lstAdvertDet[0].Supplier_Account__c];
		system.debug(instOfAcc.Adv_w_Competitor__c);
		
		List<Advertiser_Detail__c> lstOfAdvtDetUpdt = new List<Advertiser_Detail__c>();
		lstAdvertDet[0].Advertised_in_Year__c = '2011';
		lstAdvertDet[0].Competitor_Name__c = 'Meeting Mart';
		lstOfAdvtDetUpdt.add(lstAdvertDet[0]);
		
		lstAdvertDet[1].Advertised_in_Year__c = '2012';
		lstAdvertDet[1].Competitor_Name__c = 'Starcite';
		
		lstOfAdvtDetUpdt.add(lstAdvertDet[1]);
		
		update lstOfAdvtDetUpdt;
		Account instOfAccSec =[ SELECT Id,Adv_w_Competitor__c FROM Account WHERE ID =: lstOfAdvtDetUpdt[0].Supplier_Account__c ];
		system.debug(instOfAccSec.Adv_w_Competitor__c);
		
		delete lstOfAdvtDetUpdt;
    }
}