/////////////////////////////////////////////////////////////////////////////////////
// 25 Feb 2015, Wednesday
// Author : Vaibhav Jain
// This trigger is created to update the status on Creative Services Project automatically from associated Event Builder Project
/////////////////////////////////////////////////////////////////////////////////////


trigger updateStatusCreative on EB_SB_Builder__c (after insert, after update) {
    
    Map<Id,EB_SB_Builder__c> ebMap = new Map<Id,EB_SB_Builder__c>();
    //List<EB_SB_Builder__c> eventCode = new List<EB_SB_Builder__c>();
    if(Trigger.isInsert){
        for(EB_SB_Builder__c eb : Trigger.new){
            if(eb.Project__c=='Event Builder' && eb.Event_Code__c != null)
                ebMap.put(eb.id,eb);
                //eventCode.add(eb);
        }
    }
    if(Trigger.isUpdate){
        for(EB_SB_Builder__c eb : Trigger.new){
            EB_SB_Builder__c beforeStatus = System.Trigger.oldMap.get(eb.id);
            if(eb.Project__c=='Event Builder' && beforeStatus.Project_Status_del__c != eb.Project_Status_del__c && eb.Event_Code__c != null)
                ebMap.put(eb.id,eb);
                //eventCode.add(eb);
        }
    }
    system.debug('@@@@@@ebMap.size() : '+ebMap.size());
    system.debug('@@@@@@ebMap : '+ebMap);
    Map<Id,EB_SB_Builder__c> statusMap = new Map<Id,EB_SB_Builder__c>();
    if(ebMap.size()>0){
        for(EB_SB_Builder__c eb : [Select id,Project_Status_del__c,Event_Code__c,Project_Completed_Date_del__c  from EB_SB_Builder__c where Event_Code__c =: ebMap.values().Event_Code__c and Project__c = 'Event Builder']){
                statusMap.put(eb.id,eb);
        }
    }
    system.debug('@@@@@@statusMap.size() : '+statusMap.size());
    system.debug('@@@@@@statusMap: '+statusMap);
    List<EB_SB_Builder__c> toUpdateList = new List<EB_SB_Builder__c>();
    if(statusMap.size()>0){
        for(EB_SB_Builder__c eb : [Select id,Project_Status_del__c,Event_Code__c,Project_Completed_Date_del__c  from EB_SB_Builder__c where Event_Code__c =: statusMap.values().Event_Code__c and Project__c = 'Creative Services']){
            for(ID eb1 : statusMap.keyset()){
                if(eb.Event_Code__c  == statusMap.get(eb1).Event_Code__c && eb.Project_Status_del__c != 'Completed'){
                    eb.Project_Status_del__c = statusMap.get(eb1).Project_Status_del__c;
                    eb.Project_Completed_Date_del__c = statusMap.get(eb1).Project_Completed_Date_del__c;
                    toUpdateList.add(eb);
                }    
            }    
        }
    }
    if(toUpdateList.size()>0)
        update toUpdateList;
}