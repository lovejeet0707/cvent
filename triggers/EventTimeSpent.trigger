//Roll-up of timeframe.
//Average of total time spent on events.
trigger EventTimeSpent on event (after insert, after update, before delete, after delete){

    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    }
    
    public Set<Id> evids = new Set<id>();    
    public List<Mobile_Card__c> ee = new List<Mobile_Card__c>();
    // public List<Mobile_Event__c> mm = new List<Mobile_Event__c>();
    
    if(Trigger.isInsert || Trigger.isUnDelete || Trigger.isUpdate){
        for(Event e: Trigger.new){
            if((e.WhatId <> null && e.Minutes_on_tasks__c <> null )){
                evids.add(e.WhatId);
            }
        }
    }
    
    if(Trigger.isDelete){
        for(Event e: Trigger.old){
            if((e.WhatId <> null && e.Minutes_on_tasks__c <> null)){
                evids.add(e.WhatId);
            }
        }
    }
    
    //Map<Id, AggregateResult> arMap = new Map<Id, AggregateResult>([SELECT WhatId Id, SUM(Minutes_on_tasks__c)sumeve FROM Event WHERE WhatId IN :evids GROUP BY WhatId limit 1]);
    
    
    List<aggregateResult> arMap = new List<aggregateResult>();
    arMap = [SELECT WhatId Name, SUM(Minutes_on_tasks__c)sumeve FROM Event WHERE WhatId IN :evids GROUP BY WhatId ];     
    for(aggregateResult ar: arMap){        
        for(Mobile_Card__c sc : [SELECT Id, Total_Time_Spent_Event_Hrs__c FROM Mobile_Card__c WHERE Id != null AND Id IN :evids])            
        {
            sc.Total_Time_Spent_Event_Hrs__c = Decimal.valueOf('' + (ar.get('sumeve')))/60;            
            ee.add(sc);
        }       
    }
    update ee;
    
    /* for(Mobile_Event__c me : [SELECT Id, TTS_Event__c FROM Mobile_Event__c WHERE Id != null AND Id IN :evids])

{
me.TTS_Event__c = Decimal.valueOf ('' + (ar.get('sumeve')))/60;

mm.add(me);
}

update mm;}
*/
    
}//catch(Exception e){
//System.debug('Error:' +e);
//}}