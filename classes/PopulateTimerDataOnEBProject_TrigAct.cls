/******************************************************************************************
* Author : Sandeep Kumar
* Date : 21 Nov 2017
* Description : PopulateTimerDataOnEBProject_TrigAct class fullfills below functionalities,
* 1) Populate time exhausted on cases for on it's associated EB SB Projects.
* Handler called by - TimeEntryAfter Trigger
* Test Class : PopulateTimerDataEBProject_TrigAct_Test
*
* Last Modified By : Sandeep Kumar, Dated: 16 Jan, 2017
* Project :P-003178,P-003243
*******************************************************************************************/
public class PopulateTimerDataOnEBProject_TrigAct extends TriggerAction {
    public Set<Id> wrkItCaseIdSet;
    public Set<Id> ebsbCaseIdSet;
    public Map<Id,Decimal> ebCaseIdToTimerMap;
    public Map<Id,Decimal> creativeCaseIdToTimerMap;
    public Map<Id,Case> caseIdToCaseObjMap;
    public Map<Id,Decimal> caseIdToAllotedTimeMap;
    public Map<Id,Decimal> caseIdToConsumedTimeMap;        
    public List<EB_SB_Builder__c> ebProjToUpdate;    
    public Map<Id,Map<Id,Decimal>> ebsbIdToEventBuilderCaseIdToTimerMap; 
    public Map<Id,Map<Id,Decimal>> ebsbIdToCreativeServicesCaseIdToTimerMap; 
    public final String eventBuilderQueueId = Label.EB_Project_Event_Builder_Queue_ID;
    public final String creativeServicesQueueId = Label.EB_Project_Creative_Services_Queue_ID;
    public final Id eventBuilderCaseRecordtypeId = RecordtypeUtil.getRecordTypeIDByDevName('Case','Eventbuilder');
    public final Id creativeServicesCaseRecordtypeId = RecordtypeUtil.getRecordTypeIDByDevName('Case','Creative_Services');
    
    public PopulateTimerDataOnEBProject_TrigAct(){
        // Call super to set batch variables & context
        super();
        wrkItCaseIdSet = new Set<Id>();
        ebsbCaseIdSet = new Set<Id>();
        caseIdToCaseObjMap = new Map<Id,Case>();
        ebProjToUpdate = new List<EB_SB_Builder__c>();        
        caseIdToAllotedTimeMap = new Map<Id,Decimal>();
        caseIdToConsumedTimeMap = new Map<Id,Decimal>();         
        ebsbIdToEventBuilderCaseIdToTimerMap = new Map<Id,Map<Id,Decimal>>();
        ebsbIdToCreativeServicesCaseIdToTimerMap = new Map<Id,Map<Id,Decimal>>();
    }
    
    public override Boolean shouldRun(){
        // Code should fire in after update context/ operation
        if(this.isAfter()){
            if(this.isUpdate() && !this.hasRun()){  
                // Code should execute in the Update Operation.
                for(WorkIt2__Time_Entry__c newTimeEntry : (List<WorkIt2__Time_Entry__c>)this.triggerMap.values()){
                    WorkIt2__Time_Entry__c oldTimeEntry = (WorkIt2__Time_Entry__c)this.triggerOldMap.get(newTimeEntry.Id);
                    if(newTimeEntry.Case_Id__c != null && oldTimeEntry.WorkIt2__Heartbeat__c != null && newTimeEntry.WorkIt2__Heartbeat__c != null &&  oldTimeEntry.WorkIt2__Heartbeat__c != newTimeEntry.WorkIt2__Heartbeat__c){
                        wrkItCaseIdSet.add(newTimeEntry.Case_Id__c);                       
                    }           
                } 
            }else if(this.isInsert() && !this.hasRun()){
                // Code should execute in the Insert Operation.
                for(WorkIt2__Time_Entry__c newTimeEntry : (List<WorkIt2__Time_Entry__c>)this.triggerMap.values()){
                    if(newTimeEntry.Case_Id__c != null){
                        wrkItCaseIdSet.add(newTimeEntry.Case_Id__c);                    
                    }   
                }
            }
            system.debug('wrkItCaseIdSet========>>>'+wrkItCaseIdSet);
            // Query should only execute if time is updated on Case Object.
            if(!wrkItCaseIdSet.isEmpty()){
                // Add EBSB cases to set, to be used later to fetch all associated cases with EBSB Project ID
                for(Case cseObj : [Select Id,Event_Survey_Builder__c From Case Where Id IN :wrkItCaseIdSet AND Event_Survey_Builder__c != null AND Event_Survey_Builder__c != '' AND RecordTypeId IN (:eventBuilderCaseRecordtypeId,:creativeServicesCaseRecordtypeId)]){
                    ebsbCaseIdSet.add(cseObj.Event_Survey_Builder__c);
                } 
            }   
            system.debug('wrkItCaseIdSet========>>>'+wrkItCaseIdSet);
            system.debug('ebsbCaseIdSet========>>>'+ebsbCaseIdSet);
        }else{
            if(this.isUpdate() && !this.hasRun()){  
                // Code should execute in the Update Operation.
                for(Case newCase : (List<Case>)this.triggerMap.values()){
                    Case oldCase = (Case)this.triggerOldMap.get(newCase.Id);
                    // Time_Alloted_for_EBSB_Exceeded__c field should be unchecked whenever the case category is changed so that the email is trigger only once per milestone.
                    if(newCase.Time_Alloted_for_EBSB_Exceeded__c && newCase.Client_Services_Category__c != null && oldCase.Client_Services_Category__c != null 
                       && newCase.Client_Services_Category__c != null && oldCase.Client_Services_Category__c != newCase.Client_Services_Category__c){
                          // Uncheck the boolean field if the Case Category is changed.
                           newCase.Time_Alloted_for_EBSB_Exceeded__c = false;                       
                       }           
                } 
            }
        }
        return !wrkItCaseIdSet.isEmpty() && !ebsbCaseIdSet.isEmpty();
    }
    
    public override void doAction(){
        // Declare local variables and collection to be used in the code.
        Decimal wrkSessionTime;
        Decimal timeInHours;
       
        system.debug('ebsbCaseIdSet =====>>'+ebsbCaseIdSet.size());
        // Get EBSB Cases
        if(!ebsbCaseIdSet.isEmpty()){
            for(Case ebsbCase : [Select Id,OwnerId,Event_Survey_Builder__c,RecordTypeId,Event_Survey_Builder__r.Project_Stage__c,Client_Services_Category__c,Time_Alloted_for_EBSB_Exceeded__c,Time_Alloted_Milestone_for_EBSB__c,(Select Id,WorkIt2__Case__c,WorkIt2__Time_In_Seconds__c From WorkIt2__Timings__r) From Case Where Event_Survey_Builder__c IN :ebsbCaseIdSet Order By Event_Survey_Builder__c]){
                if(ebsbCase.WorkIt2__Timings__r != null){
                    wrkSessionTime = 0;                    
                    ebCaseIdToTimerMap = new Map<Id,Decimal>();
                    creativeCaseIdToTimerMap = new Map<Id,Decimal>();
                    // Aggregate the time for the parent case.
                    for(WorkIt2__Timing__c wrktTiming : ebsbCase.WorkIt2__Timings__r ){
                        wrkSessionTime += Integer.valueOf(wrktTiming.WorkIt2__Time_In_Seconds__c);
                    }
                    // Fill map information with EBSB Project ID as key and Map of Event Builder CaseID to TimerDate as Values.
                    if(eventBuilderCaseRecordtypeId == ebsbCase.RecordTypeId){
                        if(ebsbIdToEventBuilderCaseIdToTimerMap.containsKey(ebsbCase.Event_Survey_Builder__c)){
                            ebCaseIdToTimerMap.putAll(ebsbIdToEventBuilderCaseIdToTimerMap.get(ebsbCase.Event_Survey_Builder__c));
                            ebCaseIdToTimerMap.put(ebsbCase.Id, wrkSessionTime);    
                            ebsbIdToEventBuilderCaseIdToTimerMap.put(ebsbCase.Event_Survey_Builder__c,ebCaseIdToTimerMap);
                        }else{
                            ebCaseIdToTimerMap.put(ebsbCase.Id, wrkSessionTime);                    
                            ebsbIdToEventBuilderCaseIdToTimerMap.put(ebsbCase.Event_Survey_Builder__c,ebCaseIdToTimerMap);  
                        }  
                    }
                    // Fill map information with EBSB Project ID as key and Map of Creative Services CaseID to TimerDate as Values.
                    if(creativeServicesCaseRecordtypeId == ebsbCase.RecordTypeId){
                        if(ebsbIdToCreativeServicesCaseIdToTimerMap.containsKey(ebsbCase.Event_Survey_Builder__c)){
                            creativeCaseIdToTimerMap.putAll(ebsbIdToCreativeServicesCaseIdToTimerMap.get(ebsbCase.Event_Survey_Builder__c));
                            creativeCaseIdToTimerMap.put(ebsbCase.Id, wrkSessionTime);    
                            ebsbIdToCreativeServicesCaseIdToTimerMap.put(ebsbCase.Event_Survey_Builder__c,creativeCaseIdToTimerMap);
                        }else{
                            creativeCaseIdToTimerMap.put(ebsbCase.Id, wrkSessionTime);                    
                            ebsbIdToCreativeServicesCaseIdToTimerMap.put(ebsbCase.Event_Survey_Builder__c,creativeCaseIdToTimerMap);  
                        }  
                    }                    
                    
                    system.debug('wrkSessionTime===>>>'+wrkSessionTime);
                    
                    if(!ebsbCase.Time_Alloted_for_EBSB_Exceeded__c && ebsbCase.OwnerId != eventBuilderQueueId && ebsbCase.OwnerId != creativeServicesQueueId){
                        timeInHours = (wrkSessionTime/3600);
                        // Prepare Case Id to Case Object Map
                        caseIdToCaseObjMap.put(ebsbCase.Id, ebsbCase);
                        // Prepare Case Id to Alloted Time Map
                        caseIdToAllotedTimeMap.put(ebsbCase.Id, ebsbCase.Time_Alloted_Milestone_for_EBSB__c);
                        // Prepare Case Id to Consumed Time Map
                        caseIdToConsumedTimeMap.put(ebsbCase.Id, timeInHours);
                    }
                }
            }
        }
        system.debug('ebsbIdToEventBuilderCaseIdToTimerMap =====>>'+ebsbIdToEventBuilderCaseIdToTimerMap);
        system.debug('ebsbIdToCreativeServicesCaseIdToTimerMap =====>>'+ebsbIdToCreativeServicesCaseIdToTimerMap);
        system.debug('caseIdToCaseObjMap =====>>'+caseIdToCaseObjMap);
        system.debug('caseIdToAllotedTimeMap =====>>'+caseIdToAllotedTimeMap);
        system.debug('caseIdToConsumedTimeMap =====>>'+caseIdToConsumedTimeMap);
        List<Case> escalatedCasesList = new List<Case>();
        // Prepare a list of cases where email should be triggered.
        for(Id caseId : caseIdToAllotedTimeMap.keySet()){
            if(caseIdToConsumedTimeMap.get(caseId) > caseIdToAllotedTimeMap.get(caseId)){
                Case caseObj = caseIdToCaseObjMap.get(caseId);
                caseObj.Time_Alloted_for_EBSB_Exceeded__c = true;
                escalatedCasesList.add(caseObj);                
            }
        }                        
        
        EB_SB_Builder__c ebProjObj;
        Decimal totTimeSpentOnEventBuilderCases;
        Decimal totTimeSpentOnCreativeServicesCases;
        
        for(Id ebProjId : ebsbCaseIdSet){
            totTimeSpentOnEventBuilderCases = 0;
            totTimeSpentOnCreativeServicesCases = 0;
            // Check whether the cases stored in Map are Event Builder Cases.
            if(ebsbIdToEventBuilderCaseIdToTimerMap.containsKey(ebProjId)){
                for(Id caseId : ebsbIdToEventBuilderCaseIdToTimerMap.get(ebProjId).keySet()){
                    totTimeSpentOnEventBuilderCases += ebsbIdToEventBuilderCaseIdToTimerMap.get(ebProjId).get(caseId);
                }  
            }
            // Check whether the cases stored in Map are Creative Services Cases.
            if(ebsbIdToCreativeServicesCaseIdToTimerMap.containsKey(ebProjId)){
                for(Id caseId : ebsbIdToCreativeServicesCaseIdToTimerMap.get(ebProjId).keySet()){
                    totTimeSpentOnCreativeServicesCases += ebsbIdToCreativeServicesCaseIdToTimerMap.get(ebProjId).get(caseId);
                }
            }
            
            if(totTimeSpentOnEventBuilderCases != 0 || totTimeSpentOnCreativeServicesCases != 0){
                ebProjObj = new EB_SB_Builder__c(Id = ebProjId);
                ebProjObj.Time_Consumed_EB_Cases__c = (totTimeSpentOnEventBuilderCases/3600);
                ebProjObj.Time_Consumed_Creative_Cases__c = (totTimeSpentOnCreativeServicesCases/3600);
                // Add EBSB Project in the list
                ebProjToUpdate.add(ebProjObj);
            }                
        }
        system.debug('ebProjToUpdate =====>>'+ebProjToUpdate);
        if(!ebProjToUpdate.isEmpty()){
            update ebProjToUpdate;
            // Trigger email to Event Builder Leadership Time.
            if(!escalatedCasesList.isEmpty()){
                EBSurveyNotificationEmail.sendCaseLevelEscalationEmail(escalatedCasesList);
                update escalatedCasesList;
            }
            this.markRun();
        }        
    }    
}