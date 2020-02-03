/*   
  Author : Kumud 
  SOC: 23 Dec 15
  

*/
trigger ContractReviewTrigger on Contract_Reviewing__c (before update,after update,before delete) {
    ContractTriggerHelper handler = new ContractTriggerHelper();
   if(trigger.isBefore && trigger.isUpdate){
     Set<Id> setOpptyId=new Set<Id>();
     for(Contract_Reviewing__c objContract:trigger.new){
          setOpptyId.add(objContract.Opportunity__C);
     }
     
     Map<Id,Opportunity> mapIdvsOppty=new Map<Id,Opportunity>([select id from opportunity where id in :setOpptyId and recordtype.developername!='Tract']);
      if(mapIdvsOppty.size()>0 && !ContractTriggerHelper.isRunOnce)
       {
          
        Map<Id,Contract_Reviewing__c> mapidContract=  ContractTriggerHelper.updateTractContract(trigger.new,trigger.newMap,trigger.oldMap);
       
       for(Contract_Reviewing__c objContract:trigger.new){
            system.debug('***************'+mapidContract);
            objContract=mapidContract.get(objContract.id);
          
       }
      } 
       if(!ContractTriggerHelper.isRunOnce){
       Map<Id,Contract_Reviewing__c> mapidContract =ContractTriggerHelper.onBeforeUpdate(trigger.new,trigger.newMap,trigger.oldMap);
       for(Contract_Reviewing__c objContract:trigger.new){
            system.debug('***************'+mapidContract);
            objContract=mapidContract.get(objContract.id);
          
       }
     }
   }else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap);        
    }else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);        
    }
    
}