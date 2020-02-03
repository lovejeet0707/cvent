trigger CustomOppSplitTrg on Custom_Opportunity_Splits__c (before insert,before update) {
  CustomOppSplitTrgHandler instCustOppTrg = new CustomOppSplitTrgHandler();
    if(Trigger.isInsert && Trigger.isBefore){
        
           // instCustOppTrg.OnBeforeInsert(Trigger.new);
       
    }
    
    else if(Trigger.isUpdate && Trigger.isBefore){
        
           // instCustOppTrg.OnBeforeUpdate(Trigger.new, Trigger.oldMap,Trigger.newMap); 
    }
}