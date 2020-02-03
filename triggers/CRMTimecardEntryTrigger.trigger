trigger CRMTimecardEntryTrigger on CRM_Timecard_Entry__c (after update, after insert, after delete) {
    Set<Id> projectWorkItems = new Set<Id>();

    if(Trigger.isDelete) {
        for(CRM_Timecard_Entry__c entry: Trigger.old){
            if(entry.CRM_Project_Work_Item__c != null && !projectWorkItems.contains(entry.CRM_Project_Work_Item__c)){
                projectWorkItems.add(entry.CRM_Project_Work_Item__c);
            }
        }
    } else {
        for(CRM_Timecard_Entry__c entry: Trigger.new){
            if(entry.CRM_Project_Work_Item__c != null && !projectWorkItems.contains(entry.CRM_Project_Work_Item__c)){
                projectWorkItems.add(entry.CRM_Project_Work_Item__c);
            }
        }
   }
    
    if(projectWorkItems.size() > 0){
                   
        AggregateResult[] groupedResults = [SELECT sum(day_1__c), sum(day_2__c), sum(day_3__c), sum(day_4__c), sum(day_5__c), sum(day_6__c), sum(day_7__c), CRM_Project_Work_Item__c FROM CRM_Timecard_Entry__c Where 
                                                    User__c =:UserInfo.getUserId() GROUP BY CRM_Project_Work_Item__c];
                                                    
        List<CRM_Project_Item__c> projectItems = new List<CRM_Project_Item__c>();                                         
        for (AggregateResult ar : groupedResults)  {
            String projectItemId = ar.get('CRM_Project_Work_Item__c') != null ? String.valueof(ar.get('CRM_Project_Work_Item__c')) : null;
            if( projectItemId != null){
                CRM_Project_Item__c item = new CRM_Project_Item__c(id = projectItemId);
                item.Actual_Effort_Hours__c = Double.valueOf(ar.get('expr0')) + Double.valueOf(ar.get('expr1')) + Double.valueOf(ar.get('expr2')) + Double.valueOf(ar.get('expr3'))
                                                 + Double.valueOf(ar.get('expr4')) + Double.valueOf(ar.get('expr5')) + Double.valueOf(ar.get('expr6'));
               projectItems.add(item);                                   
            }
        }
        
        //Find Project Work Items for Delete cases that no longer have a timecard entry. Set the total hours to 0 for such work items
        for(Id original: projectWorkItems){
            boolean matchFound = false;
            for(CRM_Project_Item__c processed: projectItems){
                if(processed.Id == original){
                    matchFound = true;
                    break;
                }
            }
            if(!matchFound){
                CRM_Project_Item__c item = new CRM_Project_Item__c(id = original);
                item.Actual_Effort_Hours__c = 0;
                 projectItems.add(item);
            }
        }
        
        
        if(projectItems.size()>0){
            update projectItems;
        }
        
    }
}