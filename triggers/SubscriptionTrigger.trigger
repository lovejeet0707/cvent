trigger SubscriptionTrigger on SBQQ__Subscription__c (after insert,after update) {
    if(trigger.isInsert && trigger.isAfter)
        VistaSubscriptionHandler handler = new VistaSubscriptionHandler(trigger.new);
    
    if(Label.IsBCActive=='True' && trigger.isAfter && (trigger.isUpdate || trigger.isInsert)){
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> subsIdSet = new Set<Id>();
        For(SBQQ__Subscription__c subsObj : trigger.new)
        {
            if(trigger.isInsert) {
                subsIdSet.add(subsObj.Id);
            }
            else if(trigger.isUpdate){
                SBQQ__Subscription__c oldRec = trigger.oldMap.get(subsObj.Id);
                if(oldRec.Annual_Recurring_Revenue__c != subsObj.Annual_Recurring_Revenue__c)
                    subsIdSet.add(subsObj.Id);        
            }
        }
        if(subsIdSet.size()>0){
            For(SBQQ__Subscription__c subsRec : [SELECT Id,SBQQ__Contract__r.SBQQ__RenewalOpportunity__c FROM SBQQ__Subscription__c WHERE Id IN : subsIdSet])
            {
                if(subsRec.SBQQ__Contract__c!=null && subsRec.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c!=null)
                oppIdSet.add(subsRec.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c);
            }
        }
        if(oppIdSet.size()>0)
            SnapShotUtilityHelper.CreateOppProdSnapshot(trigger.new,oppIdSet,null,new Map<String,Id>());
    }
}