/******************************************************************************************************************
* Author/ Created By: Sandeep Kumar
* Date: 10 Aug August 2018
* Description: CrowdCompass Automation - Mobile App Auto-Assignemnt workflow, created as a part of CC ABP Automation 
* Class is responsible for updating "App Builder" on CC Mobile App record.
* This auto assignment is triggered by the survey close loop and the agent is decided based on the Mobile App Score. 
* Test Class : CCMobileAppAutoAssignment_TrigAct_Test
*******************************************************************************************************************/
public without sharing class CCMobileAppAutoAssignment_TrigAct extends TriggerAction{
    private Set<Id> eBAgentProfileIds;
    private Map<Id,Mobile_Card__c> mobileAppMap;
    private Boolean setHighComplexityMobileAppAgentId;        
    private Boolean setLowComplexityMobileAppAgentId;  
    private Map<Id,Integer> agentIdToWeeklyProjCountMap;
    private Map<Id,Integer> agentIdToMonthlyProjCountMap;
    private Map<Integer,List<Id>> agentScoreToAgentIdsMap;
    private List<EB_Agent_Profile__c> eBAgentProfilesToUpdateList;
    private Map<Id,EB_Agent_Profile__c> agentIdEBAgentProfileObjMap; 
    private Map<Mobile_Card__c,Map<Id,Integer>> mobileAppToIdToScoreMap;
    private Map<String,List<EB_Agent_Profile__c>> priorityKeyToAgentProfileMap;
    private Map<Integer,Map<Id,EB_Agent_Profile__c>> agentScoreToEBAgentProfileMap;
    private static Set<String> highComplexityMobileAppSet = new Set<String>{'Advanced','Complex'};
        private static Set<String> lowComplexityMobileAppSet = new Set<String>{'Standard','Medium'};
            private static final String InvalidAgentPriority = Label.CC_Agent_Invalid_Assignment_Priority;
    private static final String ccLeadershipQueueId = Label.CC_Leadership_Queue_ID;
    
    public CCMobileAppAutoAssignment_TrigAct(){ 
        
        // Call super to set batch variables & context
        super();
        eBAgentProfileIds = new Set<Id>();
        mobileAppMap = new Map<Id,Mobile_Card__c>();
        agentIdToWeeklyProjCountMap = new Map<Id,Integer>();
        agentIdToMonthlyProjCountMap = new Map<Id,Integer>();
        agentScoreToAgentIdsMap = new Map<Integer,List<Id>>();
        eBAgentProfilesToUpdateList = new List<EB_Agent_Profile__c>();
        agentIdEBAgentProfileObjMap = new Map<Id,EB_Agent_Profile__c>();
        mobileAppToIdToScoreMap = new Map<Mobile_Card__c,Map<Id,Integer>>(); 
        priorityKeyToAgentProfileMap = new Map<String,List<EB_Agent_Profile__c>>();
        agentScoreToEBAgentProfileMap = new Map<Integer,Map<Id,EB_Agent_Profile__c>>();
    }
    
    public override Boolean shouldRun(){
        if(this.isUpdate() && this.isBefore() && !this.hasRun()){
            for(Mobile_Card__c newMobileApp: (List<Mobile_Card__c>)this.triggerMap.values()){
                Mobile_Card__c oldMobileApp = (Mobile_Card__c)this.triggerOldMap.get(newMobileApp.Id);
                
                // auto-assignment would only takes place if the Auto-Assignment Date is Not Null and Last Owner is not equal to CC Leadership and Agent Profile is Null
                if(newMobileApp.Auto_Assignment_Date__c != null && oldMobileApp.OwnerId <> ccLeadershipQueueId && oldMobileApp.Agent_Profile__c == null){
                    mobileAppMap.put(newMobileApp.Id, newMobileApp);
                }                
            }  
            /*
            // Query Only if there are Mobile Cards for Auto-Assignment.
            if(!mobileAppMap.isEmpty()){
                Integer currentWeekProjCount;   
                Integer currentMonthProjCount;
                Integer weeklyPeriod = Integer.valueOf(Label.CC_Agent_Profile_Max_Build_Per_Week);
                Integer monthlyPeriod = Integer.ValueOf(Label.CC_Agent_Profile_Max_Build_Per_Month);
                Integer rollUpPeriod = Integer.ValueOf(Label.CC_Agent_Profile_Roll_Up_Period);
                
                // Get CC Agent profile and project count information.
                for(Mobile_Card__c  mobApp : [Select Id,Ideal_App_Launch_Date__c,OwnerId,Agent_Profile__c,Auto_Assignment_Date__c,Complexity_Level__c From Mobile_Card__c where Agent_Profile__c != null]){
                    currentWeekProjCount = 0;
                    
                    // get the weekly and monthly count for the agent profile if the mobile app record passes the valid Roll-Up Period.
                    if(mobApp.Ideal_App_Launch_Date__c != null && mobApp.Ideal_App_Launch_Date__c.daysBetween(Date.today()) < rollUpPeriod){
                        
                        // prepare the weekly assignment count based on the Auto-Assignment Date
                        if(mobApp.Auto_Assignment_Date__c != null && mobApp.Auto_Assignment_Date__c.Date().daysBetween(Date.today()) < weeklyPeriod && mobApp.Agent_Profile__c != null){
                            if(agentIdToWeeklyProjCountMap.containsKey(mobApp.OwnerId)){
                                currentWeekProjCount = agentIdToWeeklyProjCountMap.get(mobApp.OwnerId);
                                currentWeekProjCount += 1;
                                agentIdToWeeklyProjCountMap.put(mobApp.OwnerId, currentWeekProjCount);
                            }else{
                                agentIdToWeeklyProjCountMap.put(mobApp.OwnerId, 1);
                            }    
                        } 
                        
                        // prepare the monthly assignment count based on the Auto-Assignment Date
                        if(mobApp.Auto_Assignment_Date__c != null && mobApp.Auto_Assignment_Date__c.Date().daysBetween(Date.today()) < monthlyPeriod && mobApp.Agent_Profile__c != null){
                            if(agentIdToMonthlyProjCountMap.containsKey(mobApp.OwnerId)){
                                currentMonthProjCount = agentIdToMonthlyProjCountMap.get(mobApp.OwnerId);
                                currentMonthProjCount += 1;
                                agentIdToMonthlyProjCountMap.put(mobApp.OwnerId, currentMonthProjCount);
                            }else{
                                agentIdToMonthlyProjCountMap.put(mobApp.OwnerId, 1);
                            }    
                        }
                    }                    
                } 
                // Get CC Agent Profile Record Type ID
                Id CCAgentProfileRecTypeId = Schema.SObjectType.EB_Agent_Profile__c.getRecordTypeInfosByName().get(Label.CC_Agent_Profile_RT_Label_Name).getRecordTypeId();
                
                String mapKey = '';
                for(EB_Agent_Profile__c agtProfile : [Select Id,Agent_Name__c,
                                                      Agent_Name__r.Name,
                                                      Max_of_projects_per_Month__c,
                                                      Standard_Build_Priority__c,
                                                      Medium_Build_Priority__c,
                                                      Advanced_Build_Priority__c,
                                                      Complex_Build_Priority__c,
                                                      Last_Project_Assignment__c,
                                                      of_Projects__c,of_Projects_Agent__c,
                                                      Max_Workload_Agent_Hrs__c,
                                                      Max_of_Projects_Per_Week__c,
                                                      Current_Assignment__c,
                                                      Current_Work_Load_hrs__c,
                                                      of_Simple_Projects__c,
                                                      of_Medium_Projects__c,
                                                      of_Advanced_Projects__c,
                                                      of_Complex_Projects__c,Agent_Shift__c,
                                                      Agent_Time_Zone__c,Agent_Time_Zone_Preference_1__c 
                                                      FROM EB_Agent_Profile__c 
                                                      WHERE RecordTypeId = :CCAgentProfileRecTypeId AND 
                                                      User_Active__c = true 
                                                      Order By Last_Project_Assignment__c])
                {
                    // Prepare a map with Salesforce User Id to EbAgent Profile Id.
                    agentIdEBAgentProfileObjMap.put(agtProfile.Agent_Name__c, agtProfile);            
                    
                    // prepare the priority based mapping, that will be used for auto-assignment.
                    if(agtProfile.Standard_Build_Priority__c != null && agtProfile.Standard_Build_Priority__c != InvalidAgentPriority){
                        mapKey = agtProfile.Standard_Build_Priority__c+'Standard';
                        if(priorityKeyToAgentProfileMap.containsKey(mapKey)){
                            priorityKeyToAgentProfileMap.get(mapKey).add(agtProfile);
                        }else{
                            priorityKeyToAgentProfileMap.put(mapKey,new List<EB_Agent_Profile__c>{agtProfile});
                        }
                    }
                    if(agtProfile.Medium_Build_Priority__c != null && agtProfile.Medium_Build_Priority__c != InvalidAgentPriority){
                        mapKey = agtProfile.Medium_Build_Priority__c+'Medium';
                        if(priorityKeyToAgentProfileMap.containsKey(mapKey)){
                            priorityKeyToAgentProfileMap.get(mapKey).add(agtProfile);
                        }else{
                            priorityKeyToAgentProfileMap.put(mapKey,new List<EB_Agent_Profile__c>{agtProfile});
                        }
                    }
                    if(agtProfile.Advanced_Build_Priority__c != null && agtProfile.Advanced_Build_Priority__c != InvalidAgentPriority){
                        mapKey = agtProfile.Advanced_Build_Priority__c+'Advanced';
                        if(priorityKeyToAgentProfileMap.containsKey(mapKey)){
                            priorityKeyToAgentProfileMap.get(mapKey).add(agtProfile);
                        }else{
                            priorityKeyToAgentProfileMap.put(mapKey,new List<EB_Agent_Profile__c>{agtProfile});
                        }
                    }
                    if(agtProfile.Complex_Build_Priority__c != null && agtProfile.Complex_Build_Priority__c != InvalidAgentPriority){
                        mapKey = agtProfile.Complex_Build_Priority__c+'Complex';
                        if(priorityKeyToAgentProfileMap.containsKey(mapKey)){
                            priorityKeyToAgentProfileMap.get(mapKey).add(agtProfile);
                        }else{
                            priorityKeyToAgentProfileMap.put(mapKey,new List<EB_Agent_Profile__c>{agtProfile});
                        }
                    }
                }               
            }        */    
        }    
        return !mobileAppMap.isEmpty();
    }
    
    public override void doAction(){ 
        // enable the flag to avoid recursion.
        this.markRun();
        /*
        // variable Declaration
        Boolean runAutoAssignmentLoop;
        String newAssigneeId; 
        String mobileAppKey;
        Integer mobileAppPriority;
        
        // Mobile Apps with Advanced and Complex Complexity
        Id highComplexityMobileAppAgentId;
        setHighComplexityMobileAppAgentId = false;
        
        // Mobile Apps with Simple and Medium Complexity
        Id lowComplexityMobileAppAgentId;    
        setLowComplexityMobileAppAgentId = false;
        EB_Agent_Profile__c eBAgentProfile;
        
        // get the invalid agent priority, to be used in the while loop below to iterate and to determine the auto-assignment.
        Integer InvalidPriority = Integer.valueOf(InvalidAgentPriority);
        
        for(Mobile_Card__c mobApp : mobileAppMap.values()){  
            newAssigneeId = '';
            mobileAppKey = '';
            mobileAppPriority = 1;
            
            // get all the Agents based on their Agent Priority per Complexity. There shall be multiple people falling under this criteria.
            runAutoAssignmentLoop = true;
            while(runAutoAssignmentLoop){
                if(!setHighComplexityMobileAppAgentId && highComplexityMobileAppSet.contains(mobApp.Complexity__c)) setHighComplexityMobileAppAgentId = true;
                if(!setLowComplexityMobileAppAgentId && lowComplexityMobileAppSet.contains(mobApp.Complexity__c)) setLowComplexityMobileAppAgentId = true;
                
                // prepare the mobile app key
                mobileAppKey = mobileAppPriority+mobApp.Complexity__c;
                if(priorityKeyToAgentProfileMap.containsKey(mobileAppKey)){
                    
                    // get all the agents matching the unique mobile app key
                    for(EB_Agent_Profile__c agentProfile : priorityKeyToAgentProfileMap.get(mobileAppKey)){
                        system.debug('Account Time Zone ===>>>>'+mobApp.Account_Time_Zone__c);
                        system.debug('Agent Profile Time Zone ===>>>>'+agentProfile.Agent_Time_Zone__c);
                        
                        // check mobile app time zone with agent time zone
                        if(mobApp.Account_Time_Zone__c != null && agentProfile.Agent_Time_Zone__c != null){
                            
                            // agent and mobile app timezone preference
                            if(agentProfile.Agent_Time_Zone__c.contains(mobApp.Account_Time_Zone__c) || (agentProfile.Agent_Time_Zone_Preference_1__c != null && agentProfile.Agent_Time_Zone_Preference_1__c.contains(mobApp.Account_Time_Zone__c))){
                                
                                // agent profile should be in a avaiable status, otherwise the agent will be skipped from the auto-assignment workflow.
                                if(agentIdEBAgentProfileObjMap.containsKey(agentProfile.Agent_Name__c) && agentIdEBAgentProfileObjMap.get(agentProfile.Agent_Name__c).Current_Assignment__c == 'Available'){
                                    
                                    // maximun number of project that can be assigned to user should be always greater than number of project assigned currently.
                                    if(agentIdEBAgentProfileObjMap.get(agentProfile.Agent_Name__c).of_Projects__c < agentIdEBAgentProfileObjMap.get(agentProfile.Agent_Name__c).of_Projects_Agent__c){
                                       
                                        // check if projects are assigned in current month. This would return false if there is no project assigned in current month and the else part will execute.
                                        if(agentIdToMonthlyProjCountMap.containsKey(agentProfile.Agent_Name__c) && agentIdToMonthlyProjCountMap.get(agentProfile.Agent_Name__c) < agentIdEBAgentProfileObjMap.get(agentProfile.Agent_Name__c).Max_of_projects_per_Month__c){
                                            
                                            // check if projects are assigned in current week. This would return false if there is no project assigned in current week and the else part will execute.
                                            if(agentIdToWeeklyProjCountMap.containsKey(agentProfile.Agent_Name__c) && agentIdToWeeklyProjCountMap.get(agentProfile.Agent_Name__c) < agentIdEBAgentProfileObjMap.get(agentProfile.Agent_Name__c).Max_of_Projects_Per_Week__c){
                                                
                                                // If the below condition is not met. It indicates that user is already assigned with Max of Projects Per Week and further projects will not be assigned.
                                                // Skip this user for assignment.
                                                newAssigneeId = agentProfile.Agent_Name__c;
                                                System.debug('LINE - 211');
                                                break;
                                            }else{
                                                
                                                // Assign project to user in case current week assignment count is zero.
                                                newAssigneeId = agentProfile.Agent_Name__c;
                                                System.debug('LINE - 216');
                                                break;
                                            }    
                                        }else{
                                            System.debug('LINE - 220');
                                            
                                            // Assign project to user in case current Month assignment count is zero.
                                            newAssigneeId = agentProfile.Agent_Name__c;
                                            break;
                                        }                                 
                                    }
                                }
                            }else{
                                System.debug('AGENT ASSIGNMENT SKIPPED');
                                
                                // continue if the agent time zone doesn't match with the account time zone
                                continue;
                            }                                   
                        }
                    }                            
                }
                System.debug('newAssigneeId====>'+newAssigneeId);
                System.debug('mobileAppPriority====>'+mobileAppPriority);
                // Re-run the logic if the Agent doesn't exist for the current Mobile App Priority
                // Increment the mobile App Score to assign the card to the higher score agent.
                if(String.isBlank(newAssigneeId)){
                    mobileAppPriority += 1;
                } 
                if(!String.isBlank(newAssigneeId)){
                    if(setHighComplexityMobileAppAgentId && highComplexityMobileAppAgentId == null) highComplexityMobileAppAgentId = Id.valueOf(newAssigneeId);
                    if(setLowComplexityMobileAppAgentId && lowComplexityMobileAppAgentId == null) lowComplexityMobileAppAgentId = Id.valueOf(newAssigneeId); 
                    runAutoAssignmentLoop = false;                    
                }else if(mobileAppPriority >= InvalidPriority){
                    runAutoAssignmentLoop = false;
                }                        
            }
            system.debug('setHighComplexityMobileAppAgentId'+setHighComplexityMobileAppAgentId+'==highComplexityMobileAppAgentId======='+highComplexityMobileAppAgentId);
            system.debug('setLowComplexityMobileAppAgentId'+setLowComplexityMobileAppAgentId+'==lowComplexityMobileAppAgentId======='+lowComplexityMobileAppAgentId);
        }
        if(setHighComplexityMobileAppAgentId || setLowComplexityMobileAppAgentId){
            
            // reassign all the mobile app to one agent
            // builder with highest priority will be given preference during reassignment
            for(Mobile_Card__c mobApp : mobileAppMap.values()){
                
                // Assign new Agent Id
                mobApp.Stage__c= 'Pending Project Plan';                
                mobApp.Auto_Assignment_Date__c = Date.today();
                if(setHighComplexityMobileAppAgentId && agentIdEBAgentProfileObjMap.containsKey(highComplexityMobileAppAgentId)){
                    mobApp.OwnerId = highComplexityMobileAppAgentId;
                    mobApp.App_Builder__c = highComplexityMobileAppAgentId;
                    mobApp.Agent_Profile__c= agentIdEBAgentProfileObjMap.get(highComplexityMobileAppAgentId).Id;
                    continue;
                }else if(!setHighComplexityMobileAppAgentId && setLowComplexityMobileAppAgentId && agentIdEBAgentProfileObjMap.containsKey(lowComplexityMobileAppAgentId)){
                    mobApp.OwnerId = lowComplexityMobileAppAgentId;
                    mobApp.App_Builder__c = lowComplexityMobileAppAgentId;
                    mobApp.Agent_Profile__c= agentIdEBAgentProfileObjMap.get(lowComplexityMobileAppAgentId).Id;
                    continue;
                }   
                // assign CrowdCompass Leadership Queue ID, if there are not valid App Builder profiles found for the corresponding complexity
                mobApp.OwnerId = Id.valueOf(ccLeadershipQueueId);                
            }          
        }*/ 
    }
}