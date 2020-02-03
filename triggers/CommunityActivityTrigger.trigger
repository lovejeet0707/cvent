trigger CommunityActivityTrigger on HL_Community_Activity__c (before insert) {
  Set<id> contactIds = new Set<id>();
  for(HL_Community_Activity__c ca : Trigger.new){
    contactIds.add(ca.Contact__c);    
  }
  Map<id,Contact> contactAccountMapping = 
    new Map<id,Contact>([SELECT Id, AccountId FROM Contact WHERE Id in :contactIds]); 

    for(HL_Community_Activity__c ca : Trigger.new){
        if(ca.Contact__c != null){
            ca.Account__c = contactAccountMapping.get(ca.Contact__c).AccountId;
        }
    }
}