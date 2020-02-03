trigger aggregateTotalOnParentCase on WorkIt2__Time_Entry__c (after update, after delete) {
    Set<ID> TimingIds = new Set<ID>();
    Set<ID> CaseIds = new Set<ID>();
    Set<ID> ParentCaseIds = new Set<ID>();
    //if(Trigger.isInsert || Trigger.isUpdate){
    if(Trigger.isUpdate){
        for (WorkIt2__Time_Entry__c instofTE : Trigger.New){
            /*if(instofTE.WorkIt2__Timing__c != null){
                TimingIds.add(instofTE.WorkIt2__Timing__c);
            }
            if(Trigger.isUpdate){*/
                if (trigger.oldmap.get(instofTE.id).WorkIt2__Timing__c != null && instofTE.WorkIt2__Timing__c == null) {
                    TimingIds.add(trigger.oldmap.get(instofTE.id).WorkIt2__Timing__c);
                }
            //} 
        }
    }
    else if(Trigger.isDelete){
        for (WorkIt2__Time_Entry__c instofTE : Trigger.Old) {
            if(instofTE.WorkIt2__Timing__c != null) {
                TimingIds.add(instofTE.WorkIt2__Timing__c);
            }
        }
    }
    system.debug('TimingIds : '+TimingIds);
    if(TimingIds.size()>0){
        for(WorkIt2__Timing__c instofTim : [Select WorkIt2__Case__c from WorkIt2__Timing__c where id in: TimingIds]){
            if(instofTim.WorkIt2__Case__c != null){
                CaseIds.add(instofTim.WorkIt2__Case__c);
            }
        }
    }
    system.debug('CaseIds : '+CaseIds);
    if(CaseIds.size()>0){
        for(Case instOfCase : [Select ParentID from Case where id in:CaseIds]){
            if(instOfCase.ParentId != null){
                ParentCaseIds.add(instOfCase.ParentId);
            }
        }
    }
    AggregateResult[] groupedResults = new AggregateResult[]{};
    system.debug('ParentCaseIds : '+ParentCaseIds);
    if(ParentCaseIds.size()>0){
        groupedResults = [Select ParentId,Sum(WorkIt2__Case_Time_Total__r.WorkIt2__Calculated_Business_Seconds__c)sum1 from Case where ParentId in: ParentCaseIds Group By ParentId];
    }
    Map<Id,Decimal> valuesToUpdate = new Map<Id,Decimal>();
    system.debug('groupedResults : '+groupedResults);
    for(AggregateResult ar : groupedResults){
        valuesToUpdate.put((ID)ar.get('ParentId'),(Decimal)ar.get('sum1'));
    }
    List<Case> updateCaseList = new List<Case>();
    for(Case instOfCase : [Select Total_Time_from_Child__c,ParentId,Id from Case where id in:valuesToUpdate.keyset()]){
        if(instOfCase.Total_Time_from_Child__c != valuesToUpdate.get(instOfCase.id)){
            instOfCase.Total_Time_from_Child__c = valuesToUpdate.get(instOfCase.id);
            updateCaseList.add(instOfCase);
        }    
    }
    system.debug('updateCaseList : '+updateCaseList);
    if(updateCaseList.size()>0)
        update updateCaseList;
}