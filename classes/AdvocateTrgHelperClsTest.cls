/*
//////////////////////////////////////
//		@author Abhishek Pandey		//
/////////////////////////////////////
Version :	1.0
Date : 8th July 2014
Description : Supplies Data to page Report_Budget_Actual_page for showing opportunity data on the basis of filters given on page binded with this controller
*/
@isTest
private class AdvocateTrgHelperClsTest {
	
	public static Account instofAcc = new Account();
	public static Contact instofCon =  new Contact();
	public static Contact instofConThird =  new Contact();
	public static Contact instofConSec =  new Contact();
	public static List<RecordType> rtTypeAdvoc =  new List<RecordType>();
	static{				
		RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
	    rtTypeAdvoc = [SELECT Id, SobjectType, Name FROM RecordType Where SobjectType='Advocates__c' AND IsActive = true];
    	instofAcc.Name = 'Test';    
    	instofAcc.Supplier_Type__c = 'Venue';
    	instofAcc.Venue_Type__c = 'CVB';
    	instofAcc.RecordTypeId = rtType.id;
    	insert instofAcc;
    	
		instOfCon.LastName = 'Test';
    	instOfCon.AccountId = instofAcc.Id;
    	insert instOfCon;
    	
    	instofConSec.LastName = 'Test';
    	instofConSec.AccountId = instofAcc.Id;
    	insert instofConSec;   
    	 	
    	instofConThird.LastName = 'Test';
    	instofConThird.AccountId = instofAcc.Id;
    	insert instofConThird;
	}
	
    static testMethod void myUnitTest() {
   		
   		List<Advocates__c> lstAdvoc =  new List<Advocates__c>();
   		
   		Advocates__c instOfAdvoc =  new Advocates__c();
   		instOfAdvoc.RecordTypeId =  rtTypeAdvoc[0].id;
   		instOfAdvoc.contact__c  = instOfCon.Id;
   		lstAdvoc.add(instOfAdvoc);
   		
   		Advocates__c instOfAdvocSec =  new Advocates__c();
   		instOfAdvocSec.RecordTypeId =  rtTypeAdvoc[0].id; 
   		instOfAdvocSec.contact__c  =  instOfCon.Id;
   		lstAdvoc.add(instOfAdvocSec);
   		
   		Advocates__c instOfAdvocTh =  new Advocates__c();
   		instOfAdvocTh.RecordTypeId =  rtTypeAdvoc[1].id;
   		instOfAdvocTh.contact__c  =  instOfCon.Id;
   		lstAdvoc.add(instOfAdvocTh);
   		
   		try{
   			insert lstAdvoc;
   		}catch(Exception e){
        	system.debug('Exception');
        }
   		
   		lstAdvoc.clear();
   		Advocates__c instOfAdvocSeven =  new Advocates__c();
   		instOfAdvocSeven.RecordTypeId =  rtTypeAdvoc[2].id; 
   		instOfAdvocSeven.contact__c  =  instofConSec.id;
   		lstAdvoc.add(instOfAdvocSeven);
   		
   		Advocates__c instOfAdvocForth =  new Advocates__c();
   		instOfAdvocForth.RecordTypeId =  rtTypeAdvoc[3].id; 
   		instOfAdvocForth.contact__c  =  instofConSec.id;
   		lstAdvoc.add(instOfAdvocForth);
   		
   		Advocates__c instOfAdvocEight =  new Advocates__c();
   		instOfAdvocEight.RecordTypeId =  rtTypeAdvoc[1].id; 
   		instOfAdvocEight.contact__c  =  instofConSec.id;
   		lstAdvoc.add(instOfAdvocEight);
   		   		   		
   		Advocates__c instOfAdvocFift =  new Advocates__c();
   		instOfAdvocFift.RecordTypeId =  rtTypeAdvoc[1].id; 
   		instOfAdvocFift.contact__c  =  instOfCon.id;
   		lstAdvoc.add(instOfAdvocFift);   		
   		
   		Advocates__c instOfAdvocNine =  new Advocates__c();
   		instOfAdvocNine.RecordTypeId =  rtTypeAdvoc[3].id; 
   		instOfAdvocNine.contact__c  =  instOfCon.id;
   		lstAdvoc.add(instOfAdvocNine);
   		insert lstAdvoc; 	  	
   		
   		Advocates__c instOfAdvocSixth =  new Advocates__c();
   		instOfAdvocSixth.RecordTypeId =  rtTypeAdvoc[1].id; 
   		instOfAdvocSixth.contact__c  =  instOfCon.Id;
   		try{
   			insert instOfAdvocSixth;
   		}catch(Exception e){
        	system.debug('Exception');
        }
   		
   		List<Advocates__c> lstAdvoc1 = [SELECT ID,RecordTypeId,Contact__c FROM Advocates__c  WHERE id=:lstAdvoc];
   		system.debug('lstAdvoc1++'+lstAdvoc1);
   		system.debug('lstAdvoc1++'+lstAdvoc1.size());
   		map<Id,list<Advocates__c>> mapIdLstAdvoc =  new map<Id,List<Advocates__c>>();
   		
   		for(Advocates__c instOfAdvocmap : lstAdvoc1){
   			if(mapIdLstAdvoc.containskey(instOfAdvocmap.Contact__c)){
   				List<Advocates__c> lstAdvocSec = mapIdLstAdvoc.get(instOfAdvocmap.Contact__c);
   				lstAdvocSec.add(instOfAdvocmap);	
   				mapIdLstAdvoc.put(instOfAdvocmap.Contact__c,lstAdvocSec);
   			}else{
   				List<Advocates__c> lstAdvocSec =  new List<Advocates__c>();
   				lstAdvocSec.add(instOfAdvocmap);
   				mapIdLstAdvoc.put(instOfAdvocmap.Contact__c,lstAdvocSec);
   			}
   		}
   		
   		system.debug('mapIdLstAdvoc+++'+mapIdLstAdvoc);
   		List<Advocates__c> lstAdvocSec = new List<Advocates__c>();
   		for(Id idofMapContact :mapIdLstAdvoc.keyset()){
   			system.debug('mapIdLstAdvoc.get(idofMapContact).size()++++'+mapIdLstAdvoc.get(idofMapContact).size());
   			if(mapIdLstAdvoc.get(idofMapContact).size()==3){
   				for(Advocates__c instsofAdvoc2 : mapIdLstAdvoc.get(idofMapContact)){
   					system.debug('instsofAdvoc2++'+instsofAdvoc2.RecordTypeId);
	   				instsofAdvoc2.RecordTypeId = rtTypeAdvoc[2].id;
	   				system.debug('instsofAdvoc2++'+instsofAdvoc2.RecordTypeId);
	   				lstAdvocSec.add(instsofAdvoc2);
   				}
   			}else{
   				Advocates__c instsofAdvoc1 = mapIdLstAdvoc.get(idofMapContact)[0];
   				Advocates__c instsofAdvoc2=  mapIdLstAdvoc.get(idofMapContact)[1];
   				instsofAdvoc2.RecordTypeId = instsofAdvoc2.RecordTypeId;
   				lstAdvocSec.add(instsofAdvoc2);   				
   			}
   		}    
   		try{
   			update lstAdvocSec;	 
   		}catch(Exception e){
        	system.debug('Exception');
        }  		
    }
    
    static testMethod void myUnitTestSec(){
    	
    	Advocates__c instOfAdvocTen =  new Advocates__c();
   		instOfAdvocTen.RecordTypeId =  rtTypeAdvoc[1].id; 
   		instOfAdvocTen.contact__c  =  instofConThird.id;
   		instOfAdvocTen.Status__c = 'InActive';
   		insert instOfAdvocTen;
   		
    	Advocates__c instOfAdvocNine =  new Advocates__c();
   		instOfAdvocNine.RecordTypeId =  rtTypeAdvoc[3].id; 
   		instOfAdvocNine.contact__c  =  instofConThird.id;
   		instOfAdvocNine.Status__c = 'Active';
   		insert instOfAdvocNine;   		
   		
   		Advocates__c lstAdvoc1 = [SELECT ID,RecordTypeId,Contact__c,Status__c FROM Advocates__c  WHERE id =: instOfAdvocNine.id];
   		lstAdvoc1.Status__c = 'InActive';
   		update lstAdvoc1;
   		
   		Advocates__c lstAdvocThir = [SELECT ID,RecordTypeId,Contact__c,Status__c FROM Advocates__c  WHERE id =: lstAdvoc1.id];
   		lstAdvocThir.Status__c = 'Active';
   		update lstAdvocThir;
   		
   		Advocates__c lstAdvocSec = [SELECT ID,RecordTypeId,Contact__c,Status__c FROM Advocates__c  WHERE id =: lstAdvocThir.id];
   		delete lstAdvocSec;
    }
}