/*
//////////////////////////////////////
//		@author Abhishek Pandey		//
/////////////////////////////////////
Version :	1.0
Date : 3rd July 2014
Description : Validation to restrict user from creating another Advocate record with same recordtype that is already present under the parent contact. 
Version :	2.0
Date : 20th Aug 2014
Description : Rollup on after insert and after update so whenever under one contact there is any advocate with Status Active Contact field "Advocate Status" should show Active otherwise Inactive or if no
				Advocate is there under Contact ,"Advocate Status" should show blank.   
*/
public with sharing class AdvocateTrgHelperCls {
	
	public static Boolean flag=true;
	public void OnBeforeInsert(List<Advocates__c> newValues){
		
		Map<Id,List<Advocates__c>> mapOfConIdAdvocate =  new Map<Id,List<Advocates__c>>();
		
		for(Advocates__c instofAdvoNew : newValues){
			if(mapOfConIdAdvocate.containskey(instofAdvoNew.Contact__c)){
				List<Advocates__c> lstAdvocate = new List<Advocates__c>();
				lstAdvocate = mapOfConIdAdvocate.get(instofAdvoNew.Contact__c);
				lstAdvocate.add(instofAdvoNew);
				mapOfConIdAdvocate.put(instofAdvoNew.Contact__c,lstAdvocate);
			}else{
				List<Advocates__c> lstAdvocate = new List<Advocates__c>();
				lstAdvocate.add(instofAdvoNew);
				mapOfConIdAdvocate.put(instofAdvoNew.Contact__c,lstAdvocate);
			}
		}
		
		List<Advocates__c> lstAdvocate =  new List<Advocates__c>();
		system.debug('mapOfConIdAdvocate++++'+mapOfConIdAdvocate);
		for(Id idofmapOfConIdAdvocate : mapOfConIdAdvocate.keyset()){
			Map<Id,Advocates__c> mapIdOfRectypeAdvo = new Map<Id,Advocates__c>();	
			List<Advocates__c> lstAdvoc = new List<Advocates__c>();
			lstAdvoc = mapOfConIdAdvocate.get(idofmapOfConIdAdvocate);
			for(Advocates__c instOfAdvoc : lstAdvoc){	
				
				system.debug('mapOfConIdAdvocate.get(idofmapOfConIdAdvocate)+++'+mapOfConIdAdvocate.get(idofmapOfConIdAdvocate));
				system.debug('mapIdOfRectypeAdvo.containskey(instOfAdvoc.RecordTypeId)+++'+mapIdOfRectypeAdvo.containskey(instOfAdvoc.RecordTypeId));
				system.debug('mapIdOfRectypeAdvo+++'+mapIdOfRectypeAdvo);			
				if(mapIdOfRectypeAdvo.containskey(instOfAdvoc.RecordTypeId)){
					Advocates__c instOfAdvocSec = mapIdOfRectypeAdvo.get(instOfAdvoc.RecordTypeId);				
					lstAdvocate.add(instOfAdvoc);		
					lstAdvocate.add(instOfAdvocSec);
				}else{					
					mapIdOfRectypeAdvo.put(instOfAdvoc.RecordTypeId,instOfAdvoc);
					system.debug('mapIdOfRectypeAdvo+Else++'+mapIdOfRectypeAdvo);	
				}				
			}
		}		
		system.debug('lstAdvocate++++'+lstAdvocate);
		Set<Advocates__c> setAdvocate =  new Set<Advocates__c>();
		setAdvocate.addAll(lstAdvocate);
		system.debug('setAdvocate++++'+setAdvocate);
		Map<Id,Advocates__c> mapIdAdocSorted  = new Map<Id,Advocates__c>();
		for(Advocates__c instofAdvoNew : newValues){
			for(Advocates__c instOfSetId : setAdvocate){
				system.debug('setAdvocate++++'+instofAdvoNew.id);
				system.debug('instOfSetId++++'+instOfSetId);
				if(instofAdvoNew.RecordTypeId==instOfSetId.RecordTypeId && instofAdvoNew.Contact__c==instOfSetId.Contact__c){	
					system.debug('setAdvocate++++2'+setAdvocate);
					system.debug('instOfSetId++++2'+instofAdvoNew.id);				
					instofAdvoNew.addError('Records with same record types on one contact is not allowed');
					mapIdAdocSorted.put(instofAdvoNew.Id,instofAdvoNew);					
				}
			}
		}
		
		List<Id> lstOfContactIds =  new List<Id>();
		
		system.debug('mapIdAdocSorted+++'+mapIdAdocSorted);
		for(Advocates__c instofAdvoNew : newValues){
			if(!mapIdAdocSorted.containskey(instofAdvoNew.id)){
				lstOfContactIds.add(instofAdvoNew.Contact__c);				
			}
		}
		
		system.debug('lstOfContactIds++++'+lstOfContactIds);
		
		List<Contact> lstOfContact  =  [SELECT AccountId, (SELECT Id,RecordTypeId,Contact__c FROM References_Testimonials__r) FROM Contact WHERE Id=:lstOfContactIds];
		
		for(Contact instOfCon : lstOfContact){
			for(Advocates__c instOfAdvoc : instOfCon.References_Testimonials__r){
				for(Advocates__c instofAdvoNew : newValues){
					if(instofAdvoNew.Contact__c == instOfCon.Id){
						if(instofAdvoNew.RecordTypeId == instOfAdvoc.RecordTypeId){
							system.debug('instofAdvoNew+++'+instofAdvoNew);
							instofAdvoNew.addError('Advocate Record with same Recordtype and Contact Associated already exists');
						}
					}
				}
			}
		}
	}
	public void OnAfterInsert(Map<Id,Advocates__c> newMapValues){
		//Rollup on after insert and after update on Advocate Status
		List<Id> lstIdContact =  new List<Id>();
		for(Advocates__c instOfAdvoc : newMapValues.values()){
			if(instOfAdvoc.Status__c!=null || instOfAdvoc.Status__c!=''){
				if(instOfAdvoc.Contact__c!=null)
				lstIdContact.add(instOfAdvoc.Contact__c);
			}
		}
		List<Contact> lstContact = new List<Contact>();
		if(lstIdContact.size()>0)
		lstContact = [SELECT Id,Advocate_Status__c,(SELECT Id,Status__c FROM References_Testimonials__r) FROM Contact WHERE Id =: lstIdContact];
		
		List<Contact> lstContactSec = new List<Contact>();
		
		for(Contact instOfCont : lstContact){
			Integer instCount = 0;
			if(instOfCont.References_Testimonials__r.size()!=0){
				for(Advocates__c instOfAdvoc : instOfCont.References_Testimonials__r){
					if(instOfAdvoc.Status__c=='Active')
					instCount++;
				}
				if(instCount>0){
					instOfCont.Advocate_Status__c = 'Active';
					lstContactSec.add(instOfCont);
				}else if(instCount==0){
					instOfCont.Advocate_Status__c = 'InActive';
					lstContactSec.add(instOfCont);
				}
			}
		}
		
		if(lstContactSec.size()>0)
		update lstContactSec;
		//Rollup on after insert and after update on Advocate Status
	}
	public void OnBeforeUpdate(Map<Id,Advocates__c> oldMapValues,Map<Id,Advocates__c> newMapValues){
		if(flag==true){				
			Map<Id,List<Advocates__c>> mapOfConIdAdvocate =  new Map<Id,List<Advocates__c>>();
			
			for(Advocates__c instofAdvoNew : newMapValues.values()){
				if(instofAdvoNew.RecordTypeId!=oldMapValues.get(instofAdvoNew.id).RecordTypeId){
					if(mapOfConIdAdvocate.containskey(instofAdvoNew.Contact__c)){
						List<Advocates__c> lstAdvocate = new List<Advocates__c>();
						lstAdvocate = mapOfConIdAdvocate.get(instofAdvoNew.Contact__c);
						lstAdvocate.add(instofAdvoNew);
						mapOfConIdAdvocate.put(instofAdvoNew.Contact__c,lstAdvocate);
					}else{
						List<Advocates__c> lstAdvocate = new List<Advocates__c>();
						lstAdvocate.add(instofAdvoNew);
						mapOfConIdAdvocate.put(instofAdvoNew.Contact__c,lstAdvocate);
					}
				}
			}
			
			system.debug('mapOfConIdAdvocate+++oldnew'+mapOfConIdAdvocate);
			
			List<Id> lstAdvocate =  new List<Id>();
			
			for(Id idofmapOfConIdAdvocate : mapOfConIdAdvocate.keyset()){
				Map<Id,Advocates__c> mapIdOfRectypeAdvo = new Map<Id,Advocates__c>();		
				for(Advocates__c instOfAdvoc : mapOfConIdAdvocate.get(idofmapOfConIdAdvocate)){
					if(mapIdOfRectypeAdvo.containskey(instOfAdvoc.RecordTypeId)){
						Advocates__c instOfAdvocSec = mapIdOfRectypeAdvo.get(instOfAdvoc.RecordTypeId);	
						lstAdvocate.add(instOfAdvoc.id);				
						lstAdvocate.add(instOfAdvocSec.id);
					}else{
						mapIdOfRectypeAdvo.put(instOfAdvoc.RecordTypeId,instOfAdvoc);
					}				
				}
			}
			
			system.debug('lstAdvocate+++ShudbeEmpty'+lstAdvocate);
			
			Set<Id> setAdvocate =  new Set<Id>();
			setAdvocate.addAll(lstAdvocate);		
			
			Map<Id,Advocates__c> mapIdAdocSorted  = new Map<Id,Advocates__c>();
			
			for(Advocates__c instofAdvoNew : newMapValues.values()){
				for(Id instOfSetId : setAdvocate){
					if(instofAdvoNew.id==instOfSetId){
						instofAdvoNew.addError('Records with same record types on one contact is not allowed');
						mapIdAdocSorted.put(instofAdvoNew.Id,instofAdvoNew);					
					}
				}
			}
			
			system.debug('mapIdAdocSorted+++ShudbeEmpty'+mapIdAdocSorted);
			
			List<Id> lstOfContactIds =  new List<Id>();
			
			Map<Id,Id> mapAdvocId =  new Map<Id,Id>();
			
			Map<Id,List<Advocates__c>> mapConIdLstAdvoc = new Map<Id,List<Advocates__c>>();
			 
			system.debug('mapIdAdocSorted+++'+mapIdAdocSorted);
			
			for(Advocates__c instofAdvoNew : newMapValues.values()){
				if(!mapIdAdocSorted.containskey(instofAdvoNew.id)){
					lstOfContactIds.add(instofAdvoNew.Contact__c);	
					if(mapConIdLstAdvoc.containskey(instofAdvoNew.Contact__c)){
						List<Advocates__c> lstAdvoc = new List<Advocates__c>();
						lstAdvoc = mapConIdLstAdvoc.get(instofAdvoNew.Contact__c);
						lstAdvoc.add(instofAdvoNew);
						mapConIdLstAdvoc.put(instofAdvoNew.Contact__c,lstAdvoc);
					}else{
						List<Advocates__c> lstAdvoc = new List<Advocates__c>();
						lstAdvoc.add(instofAdvoNew);
						mapConIdLstAdvoc.put(instofAdvoNew.Contact__c,lstAdvoc);
					}
					mapAdvocId.put(instofAdvoNew.Id,instofAdvoNew.Id);		
				}
			} 
			
			List<Contact> lstOfContact  =  [SELECT AccountId, (SELECT ID, RecordTypeId, Contact__c FROM References_Testimonials__r WHERE ID !=: newMapValues.keyset()) FROM Contact WHERE ID=:lstOfContactIds];
			
			for(Contact instOfCon: lstOfContact){
				for(Advocates__c instOfAdvoc : instOfCon.References_Testimonials__r){
					for(Advocates__c instOfAdvocSec : mapConIdLstAdvoc.get(instOfAdvoc.Contact__c)){
						if(instOfAdvoc.Contact__c == instOfAdvocSec.Contact__c && instOfAdvoc.RecordTypeId == instOfAdvocSec.RecordTypeId){	
							newMapValues.get(instOfAdvocSec.id).addError('Advocate Record with same Recordtype and Contact Associated already exists');		
						}
					}
				}
			}
			/*system.debug('mapIdAdocSorted+++'+mapIdAdocSorted);
			system.debug('mapAdvocId+++'+mapAdvocId);
			system.debug('mapConIdLstAdvoc++++'+mapConIdLstAdvoc);
			Set<ID> idAdvocates =  new Set<ID>();
			idAdvocates.addall(mapIdAdocSorted.keySet());
			idAdvocates.addall(mapAdvocId.keyset());
			system.debug('idAdvocates+++'+idAdvocates);
			system.debug('lstOfContactIds+++'+lstOfContactIds);
			List<Contact> lstOfContact  =  [SELECT AccountId, (SELECT ID, RecordTypeId, Contact__c FROM References_Testimonials__r WHERE ID !=: idAdvocates) FROM Contact WHERE ID=:lstOfContactIds];
			
			system.debug('lstOfContact+++'+lstOfContact);
			
			for(Contact instOfCon : lstOfContact){
				for(Advocates__c instOfAdvoc : instOfCon.References_Testimonials__r){
					system.debug('instOfAdvoc++++++++111'+instOfCon.References_Testimonials__r);
					for(Advocates__c instOfAdvocSec : mapConIdLstAdvoc.get(instOfAdvoc.Contact__c)){
						system.debug('instOfAdvoc.Contact__c++++++++111'+instOfAdvoc.Contact__c);
						system.debug('instOfAdvocSec.Contact__c++++++++111'+instOfAdvocSec.Contact__c);
						system.debug('instOfAdvoc.Contact__c++++++++111'+instOfAdvoc.RecordTypeId);
						system.debug('instOfAdvocSec.Contact__c++++++++111'+instOfAdvocSec.RecordTypeId);					
						if(instOfAdvoc.Contact__c == instOfAdvocSec.Contact__c && instOfAdvoc.RecordTypeId == instOfAdvocSec.RecordTypeId){	
							system.debug('instOfAdvoc.id++'+instOfAdvoc.id);
							system.debug('instOfAdvocSec.id++'+instOfAdvocSec.id);		
							system.debug('instOfAdvoc.RecordTypeId++'+instOfAdvoc.RecordTypeId);
							system.debug('instOfAdvocSec.RecordTypeId++'+instOfAdvocSec.RecordTypeId);			
							newMapValues.get(instOfAdvocSec.id).addError('Advocate Record with same Recordtype and Contact Associated already exists');						
						}
					}
				}
			}*/
			flag=false;
		}
	}
	public void OnAfterUpdate(Map<Id,Advocates__c> oldMapValues,Map<Id,Advocates__c> newMapValues){
		
		//Rollup on after insert and after update on Advocate Status
		
		List<Id> lstIdContact =  new List<Id>();
		for(Advocates__c instOfAdvoc : newMapValues.values()){
			if(instOfAdvoc.Status__c != oldMapValues.get(instOfAdvoc.Id).Status__c){
				if(instOfAdvoc.Contact__c!=null)
				lstIdContact.add(instOfAdvoc.Contact__c);
			}
		}
		
		List<Contact> lstContact = new List<Contact>();
		if(lstIdContact.size()>0)
		lstContact = [SELECT Id,Advocate_Status__c,(SELECT Id,Status__c FROM References_Testimonials__r) FROM Contact WHERE Id =: lstIdContact];
		
		List<Contact> lstContactSec = new List<Contact>();
		
		for(Contact instOfCont : lstContact){
			Integer instCount = 0;
			if(instOfCont.References_Testimonials__r.size()!=0){
				for(Advocates__c instOfAdvoc : instOfCont.References_Testimonials__r){
					if(instOfAdvoc.Status__c=='Active')
					instCount++;
				}
				if(instCount>0){
					instOfCont.Advocate_Status__c = 'Active';
					lstContactSec.add(instOfCont);
				}else if(instCount==0){
					instOfCont.Advocate_Status__c = 'InActive';
					lstContactSec.add(instOfCont);
				}
			}
		}
		
		if(lstContactSec.size()>0)
		update lstContactSec;
		//Rollup on after insert and after update on Advocate Status
	}
	public void OnBeforeDelete(List<Advocates__c> oldValues,Map<Id,Advocates__c> oldMapValues){        
        
    }
    public void OnAfterDelete(List<Advocates__c> oldValues,Map<Id,Advocates__c> oldMapValues){
    	//Rollup on after insert and after update on Advocate Status
    	List<Id> lstIdContact =  new List<Id>();
    	
		for(Advocates__c instOfAdvoc : oldValues){
			if(instOfAdvoc.Contact__c!=null)
			lstIdContact.add(instOfAdvoc.Contact__c);
		}
		
		List<Contact> lstContact = new List<Contact>();
		if(lstIdContact.size()>0)
		lstContact = [SELECT Id,Advocate_Status__c,(SELECT Id,Status__c FROM References_Testimonials__r) FROM Contact WHERE Id =: lstIdContact];
		
		List<Contact> lstContactSec = new List<Contact>();
		
		for(Contact instOfCont : lstContact){
			Integer instCount = 0;
			if(instOfCont.References_Testimonials__r.size()!=0){
				for(Advocates__c instOfAdvoc : instOfCont.References_Testimonials__r){
					if(instOfAdvoc.Status__c=='Active')
					instCount++;
				}
				if(instCount>0){
					instOfCont.Advocate_Status__c = 'Active';
					lstContactSec.add(instOfCont);
				}else if(instCount==0){
					instOfCont.Advocate_Status__c = 'InActive';
					lstContactSec.add(instOfCont);
				}
			}else if(instOfCont.References_Testimonials__r.size()==0){
				instOfCont.Advocate_Status__c = '';
				lstContactSec.add(instOfCont);
			}
			
		}
		
		if(lstContactSec.size()>0)
		update lstContactSec;
    	//Rollup on after insert and after update on Advocate Status
    }
    public void OnUndelete(List<Advocates__c> newValues){
        
    }
    
}