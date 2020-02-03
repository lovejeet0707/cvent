/*Author: Sandeep Kumar
* Date: 31 Mar 2017
* Description: EB Project Auto Assignemnt Workflow. 
* Class is reponsible for updating EB Project Owner based on the ceriteria shared by Client Services EB Team.
* Test Class : EBProjectAutoAssignment_TrigAct_Test
*/
public without sharing class EBProjectAutoAssignment_TrigAct extends TriggerAction{    
    public Set<Id> projIds;
    public Set<Id> eBAccIds;
    public Set<Id> eBAgentProfileIds;
    public Set<String> timeZonesSet;
    public Map<Id,Id> AccountIdOwnerIdMap;
    public Map<Id,Integer> agentIdToProjCountMap;
    public List<EB_SB_Builder__c> newEbProjectsList;
    public List<EB_SB_Builder__c> updatedEBOwnerList;  
    public List<EB_SB_Builder__c> EBNewOwnersToBeNotifiedList;
    public Map<Integer,List<Id>> agentScoreToAgentIdsMap;
    public List<EB_Agent_Profile__c> eBAgentProfilesToUpdateList;
    public Map<Id,EB_Agent_Profile__c> agentIdEBAgentProfileObjMap;    
    public Map<EB_SB_Builder__c,Map<Id,Integer>> EbProjToIdToScoreMap;    
    public Map<String,EB_Project_Score_Setting__c> EbCategToSettingMap;
    public Map<Integer,Map<Id,EB_Agent_Profile__c>> agentScoreToEBAgentProfileMap;
    public final String timeZoneLabel = Label.EB_Project_International_Time_Zone;
    public final static Id eventBuilderLeadersQueueId = Label.Event_Builder_Leaders_Queue_Id;
    
    public EBProjectAutoAssignment_TrigAct(){ 
        // Call super to set batch variables & context
        super();
        projIds = new Set<Id>();
        eBAccIds = new Set<Id>();
        eBAgentProfileIds = new Set<Id>();
        timeZonesSet = new Set<String>(); 
        newEbProjectsList = new List<EB_SB_Builder__c>();        
        updatedEBOwnerList = new List<EB_SB_Builder__c>(); 
        EBNewOwnersToBeNotifiedList = new List<EB_SB_Builder__c>();  
        AccountIdOwnerIdMap = new Map<Id,Id>();
        agentIdEBAgentProfileObjMap = new Map<Id,EB_Agent_Profile__c>();
        agentIdToProjCountMap = new Map<Id,Integer>();
        agentScoreToAgentIdsMap = new Map<Integer,List<Id>>();
        eBAgentProfilesToUpdateList = new List<EB_Agent_Profile__c>();
        EbProjToIdToScoreMap = new Map<EB_SB_Builder__c,Map<Id,Integer>>(); 
        agentScoreToEBAgentProfileMap = new Map<Integer,Map<Id,EB_Agent_Profile__c>>();
        for(String timeZone : timeZoneLabel.split(',')){
            timeZonesSet.add(timeZone);
        }
    }
    
    public override Boolean shouldRun(){
        if(this.isUpdate() && this.isAfter() && !this.hasRun()){
            for(EB_SB_Builder__c newEBProj: (List<EB_SB_Builder__c>)this.triggerMap.values()){
                EB_SB_Builder__c oldEBProj = (EB_SB_Builder__c)this.triggerOldMap.get(newEBProj.Id);
                if(oldEBProj.Project_Received_Date__c == null && newEBProj.Project_Received_Date__c != null && oldEBProj.EB_Agent_Profile__c == null){
                    projIds.add(newEBProj.Id);
                    eBAccIds.add(newEBProj.AccountCustom__c);
                }                    
            }  
        }
         system.debug(eBAccIds+'eBAccIds==projIds'+projIds);
        // Get Related objects details. Required in order to get the score of a EB Project.
        for(EB_SB_Builder__c  newEBProj : [Select Id,AccountCustom__c,AccountCustom__r.Service_Tier__c,Survey_Feedback__c,Project_Assigned_Date__c,Project_Type_del__c,OwnerId,EB_Agent_Profile__c,Project_Complexity__c From EB_SB_Builder__c where Id =:projIds]){
            system.debug('newEBProj=='+newEBProj);
            // SOQL to get records from database.
            newEbProjectsList.add(newEBProj);
        } 
        system.debug('====EB Projects Before Assignment Count====='+newEbProjectsList.Size());
        // Object Declaration.
        Map<String,Id> eBTypeToOwnerIdMap;
        // Get latest owner from an Account. If the new Eb Type is additional chnages.
        for(Account  acc : [Select Id,(Select Id,AccountCustom__c,Project_Type_del__c,OwnerId from EB_SB_Projects__r Order By LastModifiedDate DESC LIMIT 1) From Account Where Id IN:eBAccIds]){
            if(acc.EB_SB_Projects__r != null && acc.EB_SB_Projects__r.size() >0){
                AccountIdOwnerIdMap.put(acc.EB_SB_Projects__r[0].AccountCustom__c, acc.EB_SB_Projects__r[0].OwnerId);
            }
        }
        Integer currentWeekProjCount;
        // Get Related objects details. Required in order to get the score of a EB Project.
        for(EB_SB_Builder__c  EbProj : [Select Id,AccountCustom__c,AccountCustom__r.Service_Tier__c,Survey_Feedback__c,Project_Assigned_Date__c,Project_Type_del__c,OwnerId,EB_Agent_Profile__c,Project_Complexity__c From EB_SB_Builder__c where Project__c = 'Event Builder' AND EB_Agent_Profile__c != null]){
            currentWeekProjCount = 0;
            if(EbProj.Project_Assigned_Date__c != null && EbProj.Project_Assigned_Date__c.daysBetween(Date.today()) < 8 && EbProj.EB_Agent_Profile__c != null){
                if(agentIdToProjCountMap.containsKey(EbProj.OwnerId)){
                    currentWeekProjCount = agentIdToProjCountMap.get(EbProj.OwnerId);
                    currentWeekProjCount +=1;
                    agentIdToProjCountMap.put(EbProj.OwnerId, currentWeekProjCount);
                }else{
                    currentWeekProjCount = 1;
                    agentIdToProjCountMap.put(EbProj.OwnerId, currentWeekProjCount);
                }    
            } 
        }   
        return !newEbProjectsList.isEmpty();
    }
    
    public override void doAction(){
        Decimal ebProjectScore;
        EB_Agent_Profile__c eBAgentProfile;
        
        EbCategToSettingMap = new Map<String,EB_Project_Score_Setting__c>();        
        // Get the Score values based on the EB Project type, Cmplexity and Account Tier.
        for(EB_Project_Score_Setting__c EbProjSetting : EB_Project_Score_Setting__c.getAll().Values()){
            EbCategToSettingMap.put(EbProjSetting.Name, EbProjSetting);
        }
        
        // Prepare Agent score to EB Project Assignment Map
        List<Id> agentIdList; 
        for(EB_Agent_Profile__c AssignRec : [Select Id,Agent_Name__c,Agent_Score__c,Last_Project_Assignment__c,of_Projects__c,of_Projects_Agent__c,Max_Workload_Agent_Hrs__c,Max_of_Projects_Per_Week__c,Current_Assignment__c,Current_Work_Load_hrs__c,of_Simple_Projects__c,of_Medium_Projects__c,Millisecond__c,of_Advanced_Projects__c,of_Complex_Projects__c from EB_Agent_Profile__c where Agent_Shift__c != 'International' AND User_Active__c = true AND Agent_Score__c != null Order By Agent_Score__c,Last_Project_Assignment__c]){
            // Prepare a with User Id to EbAgent Profile Id.
            agentIdEBAgentProfileObjMap.put(AssignRec.Agent_Name__c, AssignRec);            
            // Instantiate List.            
            agentIdList = new List<Id>();
            // Prepare collection that will be used later in assignment process.           
            if(agentScoreToAgentIdsMap.containsKey(Integer.valueOf(AssignRec.Agent_Score__c))){
                agentIdList = agentScoreToAgentIdsMap.get(Integer.valueOf(AssignRec.Agent_Score__c));
                agentIdList.add(AssignRec.Agent_Name__c);
                agentScoreToAgentIdsMap.put(Integer.valueOf(AssignRec.Agent_Score__c), agentIdList);
            }else{
                agentIdList.add(AssignRec.Agent_Name__c);
                agentScoreToAgentIdsMap.put(Integer.valueOf(AssignRec.Agent_Score__c), agentIdList);
            }            
        }
        
        Map<Id,Integer> EbProjToScoreMap;
        // Method to calculate individual project score based on certain parameters.
        for(EB_SB_Builder__c EbProj : newEbProjectsList){
            ebProjectScore = 0;
            EbProjToScoreMap = new Map<Id,Integer>();
            if(EbProj.Project_Type_del__c != null && EbProj.Project_Complexity__c != null && EbProj.AccountCustom__r.Service_Tier__c != null){
                if(EbProj.Project_Type_del__c.contains('Additional Changes')){
                    ebProjectScore = 5;
                }else if(EbProj.Project_Type_del__c.contains('ARA - Inactive') || EbProj.Project_Type_del__c.contains('ARA - Active')){
                    ebProjectScore = 6;
                }else if(EbProj.Project_Type_del__c.contains('Enterprise Project')){
                    ebProjectScore = 7;
                }else if(EbProj.Project_Type_del__c.contains('Event Quarterback Project')){
                    ebProjectScore = 8;
                }else{
                    // Get the score based on Project type, Complexity Type and Tier of Account 
                    ebProjectScore =  getEbProjScore(EbProj.Project_Type_del__c,EbProj.Project_Complexity__c,EbProj.AccountCustom__r.Service_Tier__c);
                    if(ebProjectScore > 1.01 && ebProjectScore < 2.4){
                        ebProjectScore = 1;
                    }
                    if(ebProjectScore > 2.33 && ebProjectScore < 3.68){
                        ebProjectScore = 2;
                    }
                    if(ebProjectScore > 3.67){
                        ebProjectScore = 3;
                    }    
                }
                EbProjToScoreMap.put(EbProj.Id,Integer.Valueof(ebProjectScore));
                // Prepare Project to Score Map
                EbProjToIdToScoreMap.put(EbProj, EbProjToScoreMap);  
            }                                   
        }  
        // Object Declaration.
        EB_Agent_Profile__c EbProjAssignObj;
        // Variable Declaration
        String newAssigneeId;        
        for(EB_SB_Builder__c EbProj :EbProjToIdToScoreMap.keySet()){  
            newAssigneeId = '';
            // There should be always one score for each EB Project.
            for(Integer projScore : EbProjToIdToScoreMap.get(EbProj).Values()){
                system.debug('--------projScore------'+projScore);
                if(projScore == 5){
                    if(AccountIdOwnerIdMap.containsKey(EbProj.AccountCustom__c)){
                        // If the Agent Score is 5.Assign it to previous EB Project Owner for additional changes.
                        system.debug(projScore+'Inside Last Owner');
                        newAssigneeId = AccountIdOwnerIdMap.get(EbProj.AccountCustom__c);                        
                    }                                                  
                }else if(projScore == 6){
                    // Get all the Agents with Agent Score = 6.Their shall be multiple people falling under this criteria.
                    if(agentScoreToAgentIdsMap.containsKey(projScore)){
                        for(Id agentId :agentScoreToAgentIdsMap.get(projScore)){
                            if(agentIdEBAgentProfileObjMap.containsKey(agentId)){
                                if(agentIdEBAgentProfileObjMap.get(agentId).Current_Assignment__c == 'Available'){
                                    if(agentIdEBAgentProfileObjMap.get(agentId).of_Projects__c < agentIdEBAgentProfileObjMap.get(agentId).of_Projects_Agent__c && agentIdEBAgentProfileObjMap.get(agentId).Current_Work_Load_hrs__c < agentIdEBAgentProfileObjMap.get(agentId).Max_Workload_Agent_Hrs__c){
                                        // Check if projects are assigned in current week. This would return false if there is no project assigned in current week and the else part will execute.
                                        if(agentIdToProjCountMap.containsKey(agentId)){
                                            // If the below condition is not met. It indicates that user is already assigned with more than 2 project in current week and further projects will not be assigned.
                                            // Skip this user for assignment.
                                            if(agentIdToProjCountMap.get(agentId) < agentIdEBAgentProfileObjMap.get(agentId).Max_of_Projects_Per_Week__c){
                                                newAssigneeId = agentId;
                                                break;
                                            }
                                        }else{
                                            // Assign project to user in case current week assignment count is zero.
                                            newAssigneeId = agentId;
                                            break;
                                        }                                    
                                    }                    
                                }
                            } 
                        }
                    }
                }else if(projScore == 7){
                    // Get all the Agents with Agent Score = 6.Their shall be multiple people falling under this criteria.
                    if(agentScoreToAgentIdsMap.containsKey(projScore)){
                        for(Id agentId :agentScoreToAgentIdsMap.get(projScore)){
                            if(agentIdEBAgentProfileObjMap.containsKey(agentId)){
                                if(agentIdEBAgentProfileObjMap.get(agentId).Current_Assignment__c == 'Available'){
                                    if(agentIdEBAgentProfileObjMap.get(agentId).of_Projects__c < agentIdEBAgentProfileObjMap.get(agentId).of_Projects_Agent__c && agentIdEBAgentProfileObjMap.get(agentId).Current_Work_Load_hrs__c < agentIdEBAgentProfileObjMap.get(agentId).Max_Workload_Agent_Hrs__c){
                                        // Check if projects are assigned in current week. This would return false if there is no project assigned in current week and the else part will execute.
                                        if(agentIdToProjCountMap.containsKey(agentId)){
                                            // If the below condition is not met. It indicates that user is already assigned with more than 2 project in current week and further projects will not be assigned.
                                            // Skip this user for assignment.
                                            if(agentIdToProjCountMap.get(agentId) < agentIdEBAgentProfileObjMap.get(agentId).Max_of_Projects_Per_Week__c){
                                                newAssigneeId = agentId;
                                                break;
                                            }
                                        }else{
                                            // Assign project to user in case current week assignment count is zero.
                                            newAssigneeId = agentId;
                                            break;
                                        }                                    
                                    }                    
                                }
                            } 
                        }
                    }
                }else if(projScore == 8){
                    // Get all the Agents with Agent Score = 6.Their shall be multiple people falling under this criteria.
                    if(agentScoreToAgentIdsMap.containsKey(projScore)){
                        for(Id agentId :agentScoreToAgentIdsMap.get(projScore)){
                            if(agentIdEBAgentProfileObjMap.containsKey(agentId)){
                                if(agentIdEBAgentProfileObjMap.get(agentId).Current_Assignment__c == 'Available'){
                                    if(agentIdEBAgentProfileObjMap.get(agentId).of_Projects__c < agentIdEBAgentProfileObjMap.get(agentId).of_Projects_Agent__c && agentIdEBAgentProfileObjMap.get(agentId).Current_Work_Load_hrs__c < agentIdEBAgentProfileObjMap.get(agentId).Max_Workload_Agent_Hrs__c){
                                        // Check if projects are assigned in current week. This would return false if there is no project assigned in current week and the else part will execute.
                                        if(agentIdToProjCountMap.containsKey(agentId)){
                                            // If the below condition is not met. It indicates that user is already assigned with more than 2 project in current week and further projects will not be assigned.
                                            // Skip this user for assignment.
                                            if(agentIdToProjCountMap.get(agentId) < agentIdEBAgentProfileObjMap.get(agentId).Max_of_Projects_Per_Week__c){
                                                newAssigneeId = agentId;
                                                break;
                                            }
                                        }else{
                                            // Assign project to user in case current week assignment count is zero.
                                            newAssigneeId = agentId;
                                            break;
                                        }                                    
                                    }                    
                                }
                            } 
                        }
                    }
                }else if(projScore == 3 || projScore == 2){
                    // Assignment workflow when project score is greater than 2 and less than 3.
                    // Get all the Agents based on their Agent Score. Their shall be multiple people falling under this criteria.
                    if(agentScoreToAgentIdsMap.containsKey(projScore)){
                        for(Id agentId :agentScoreToAgentIdsMap.get(projScore)){
                            if(agentIdEBAgentProfileObjMap.containsKey(agentId)){
                                if(agentIdEBAgentProfileObjMap.get(agentId).Current_Assignment__c == 'Available'){
                                    if(agentIdEBAgentProfileObjMap.get(agentId).of_Projects__c < agentIdEBAgentProfileObjMap.get(agentId).of_Projects_Agent__c && agentIdEBAgentProfileObjMap.get(agentId).Current_Work_Load_hrs__c < agentIdEBAgentProfileObjMap.get(agentId).Max_Workload_Agent_Hrs__c){
                                        // Check if projects are assigned in current week. This would return false if there is no project assigned in current week and the else part will execute.
                                        if(agentIdToProjCountMap.containsKey(agentId)){
                                            // If the below condition is not met. It indicates that user is already assigned with more than 2 project in current week and further projects will not be assigned.
                                            // Skip this user for assignment.
                                            if(agentIdToProjCountMap.get(agentId) < agentIdEBAgentProfileObjMap.get(agentId).Max_of_Projects_Per_Week__c){
                                                newAssigneeId = agentId;
                                                break;
                                            }
                                        }else{
                                            // Assign project to user in case current week assignment count is zero.
                                            newAssigneeId = agentId;
                                            break;
                                        }                                    
                                    }                    
                                }
                            } 
                        }
                    }                   
                }else{
                    // Assignment workflow when project score is equal to 1.
                    // Get all the Agents based on their Agent Score. Their shall be multiple people falling under this criteria.
                    if(agentScoreToAgentIdsMap.containsKey(projScore)){
                        for(Id agentId :agentScoreToAgentIdsMap.get(projScore)){
                            if(agentIdEBAgentProfileObjMap.containsKey(agentId)){
                                if(agentIdEBAgentProfileObjMap.get(agentId).Current_Assignment__c == 'Available'){
                                    if(agentIdEBAgentProfileObjMap.get(agentId).of_Projects__c < agentIdEBAgentProfileObjMap.get(agentId).of_Projects_Agent__c && agentIdEBAgentProfileObjMap.get(agentId).Current_Work_Load_hrs__c < agentIdEBAgentProfileObjMap.get(agentId).Max_Workload_Agent_Hrs__c){
                                        // Check if projects are assigned in current week. This would return false if there is no project assigned in current week and the else part will execute.
                                        if(agentIdToProjCountMap.containsKey(agentId)){
                                            // If the below condition is not met. It indicates that user is already assigned with more than 2 project in current week and further projects will not be assigned.
                                            // Skip this user for assignment.
                                            if(agentIdToProjCountMap.get(agentId) < agentIdEBAgentProfileObjMap.get(agentId).Max_of_Projects_Per_Week__c){
                                                newAssigneeId = agentId;
                                                break;
                                            }
                                        }else{
                                            // Assign project to user in case current week assignment count is zero.
                                            newAssigneeId = agentId;
                                            break;
                                        }                                    
                                    }                    
                                }
                            } 
                        }
                    }
                    // Assign the project to people with score less than previous.Only works when previous score is 1 
                    if(newAssigneeId == ''){
                        projScore = projScore + 1;
                        if(agentScoreToAgentIdsMap.containsKey(projScore)){
                            for(Id agentId :agentScoreToAgentIdsMap.get(projScore)){
                                if(agentIdEBAgentProfileObjMap.containsKey(agentId)){
                                    if(agentIdEBAgentProfileObjMap.get(agentId).Current_Assignment__c == 'Available'){
                                        if(agentIdEBAgentProfileObjMap.get(agentId).of_Projects__c < agentIdEBAgentProfileObjMap.get(agentId).of_Projects_Agent__c && agentIdEBAgentProfileObjMap.get(agentId).Current_Work_Load_hrs__c < agentIdEBAgentProfileObjMap.get(agentId).Max_Workload_Agent_Hrs__c){
                                            // Check if projects are assigned in current week. This would return false if there is no project assigned in current week and the else part will execute.
                                            if(agentIdToProjCountMap.containsKey(agentId)){
                                                // If the below condition is not met. It indicates that user is already assigned with more than 2 project in current week and further projects will not be assigned.
                                                // Skip this user for assignment.
                                                if(agentIdToProjCountMap.get(agentId) < agentIdEBAgentProfileObjMap.get(agentId).Max_of_Projects_Per_Week__c){
                                                    newAssigneeId = agentId;
                                                    break;
                                                }
                                            }else{
                                                // Assign project to user in case current week assignment count is zero.
                                                newAssigneeId = agentId;
                                                break;
                                            }                                    
                                        }                    
                                    }
                                } 
                            }
                        }
                    }
                    // Assign the project to people with score less than previous.Only works when previous score is 2 
                    if(newAssigneeId == ''){
                        projScore = projScore + 1;
                        if(agentScoreToAgentIdsMap.containsKey(projScore)){
                            for(Id agentId :agentScoreToAgentIdsMap.get(projScore)){
                                if(agentIdEBAgentProfileObjMap.containsKey(agentId)){
                                    if(agentIdEBAgentProfileObjMap.get(agentId).Current_Assignment__c == 'Available'){
                                        if(agentIdEBAgentProfileObjMap.get(agentId).of_Projects__c < agentIdEBAgentProfileObjMap.get(agentId).of_Projects_Agent__c && agentIdEBAgentProfileObjMap.get(agentId).Current_Work_Load_hrs__c < agentIdEBAgentProfileObjMap.get(agentId).Max_Workload_Agent_Hrs__c){
                                            // Check if projects are assigned in current week. This would return false if there is no project assigned in current week and the else part will execute.
                                            if(agentIdToProjCountMap.containsKey(agentId)){
                                                // If the below condition is not met. It indicates that user is already assigned with more than 2 project in current week and further projects will not be assigned.
                                                // Skip this user for assignment.
                                                if(agentIdToProjCountMap.get(agentId) < agentIdEBAgentProfileObjMap.get(agentId).Max_of_Projects_Per_Week__c){
                                                    newAssigneeId = agentId;
                                                    break;
                                                }
                                            }else{
                                                // Assign project to user in case current week assignment count is zero.
                                                newAssigneeId = agentId;
                                                break;
                                            }                                    
                                        }                    
                                    }
                                } 
                            }
                        }                   
                    } 
                }
                system.debug(projScore+'======Before Assignment======='+newAssigneeId);
            }
            // Customer when filling up the Q:6: Time Zone for EST, PST Auto Assignment to work.
            // For all other time zone: it should trigger email to EB Leadership for manual assignment.
            if(newAssigneeId != null && newAssigneeId != '' && EbProj.Survey_Feedback__c != null && ( EbProj.Survey_Feedback__c.contains('Eastern Standard Time') || EbProj.Survey_Feedback__c.contains('Pacific Standard Time') || EbProj.Survey_Feedback__c.contains('Central Standard Time') || EbProj.Survey_Feedback__c.contains('Mountain Standard Time'))){
                // Assign new Agent Id
                EbProj.OwnerId =Id.valueOf(newAssigneeId);
                EbProj.Project_Assigned_Date__c = Date.today();
                EbProj.Project_Status_del__c= 'In Progress';                                
                EbProj.EB_Agent_Profile__c= agentIdEBAgentProfileObjMap.get(newAssigneeId).Id;
                updatedEBOwnerList.add(EbProj);
                EBNewOwnersToBeNotifiedList.add(EbProj);                
                
                if(agentIdEBAgentProfileObjMap.containsKey(newAssigneeId) && !eBAgentProfileIds.contains(agentIdEBAgentProfileObjMap.get(newAssigneeId).Id)){
                    // Update the Last Project Assignment Details on EB Agent Profile.
                    eBAgentProfile  = new EB_Agent_Profile__c();
                    eBAgentProfile.Id = agentIdEBAgentProfileObjMap.get(newAssigneeId).Id;
                    eBAgentProfile.Last_Project_Assignment__c = System.Datetime.now();
                    eBAgentProfile.Millisecond__c = System.Datetime.now().millisecondGMT();
                    eBAgentProfilesToUpdateList.add(eBAgentProfile);
                    // Add Agent Profile Id to avoid duplicate Ids.
                    eBAgentProfileIds.add(eBAgentProfile.Id);                    
                }                
            }else if(EbProj.Survey_Feedback__c != null && !EbProj.Survey_Feedback__c.contains('Eastern Standard Time') && !EbProj.Survey_Feedback__c.contains('Pacific Standard Time') && !EbProj.Survey_Feedback__c.contains('Central Standard Time') && !EbProj.Survey_Feedback__c.contains('Mountain Standard Time')){
                // Assign new Agent Id
                EbProj.OwnerId = Id.valueOf(Label.Owner_ID_For_Time_Zone);
                EbProj.Project_Assigned_Date__c = Date.today();
                EbProj.Project_Status_del__c= 'In Progress';                             
                EbProj.EB_Agent_Profile__c= Id.valueOf(Label.EB_Agent_Profile_For_Time_Zone);
                updatedEBOwnerList.add(EbProj);
                EBNewOwnersToBeNotifiedList.add(EbProj);                
                
                if(!agentIdEBAgentProfileObjMap.containsKey(Id.valueOf(Label.EB_Agent_Profile_For_Time_Zone))){
                    // Update the Last Project Assignment Details on EB Agent Profile.
                    eBAgentProfile  = new EB_Agent_Profile__c();
                    eBAgentProfile.Id = Id.valueOf(Label.EB_Agent_Profile_For_Time_Zone);
                    eBAgentProfile.Last_Project_Assignment__c = System.Datetime.now();
                    eBAgentProfile.Millisecond__c = System.Datetime.now().millisecondGMT();
                    eBAgentProfilesToUpdateList.add(eBAgentProfile);
                    // Add Agent Profile Id to avoid duplicate Ids.
                    eBAgentProfileIds.add(eBAgentProfile.Id); 
                }
            }else{
                system.debug('======Inside Leadership Assignment=======');
                // Assign to Queue if their is no available user found.                
                Database.DMLOptions dmo = new Database.DMLOptions(); 
                dmo.EmailHeader.triggerUserEmail = true; 
                EbProj.OwnerId = eventBuilderLeadersQueueId;
                EbProj.Project_Assigned_Date__c = Date.today();
                EbProj.setOptions(dmo);
                updatedEBOwnerList.add(EbProj);                
            }            
        }
        try{
            if(!updatedEBOwnerList.isEmpty()){
                // Updates new owners for Event Builders projects.
                update updatedEBOwnerList;
                // Updates EB Agent Profiles.
                update eBAgentProfilesToUpdateList;
                // Send email to newly assigned owner's. 
                // EBSurveyNotificationEmail class is taking care of sending email notification.
                EBSurveyNotificationEmail sendAssignementEmail = new EBSurveyNotificationEmail();
                sendAssignementEmail.sendEbProjectAssignmentEmail(EBNewOwnersToBeNotifiedList);
                this.markRun();
            }
        }Catch(Exception exp){
            system.debug('=====Exception====='+exp.getMessage());
            // Create new record in Logs WareHouse.
            LogsWarehouse__c newRec = new LogsWarehouse__c();
            newRec.Service_Name__c = 'Event Builder - Auto Assignment';
            newRec.Status__c = 'Failed';
            newRec.Error_description__c = exp.getMessage();
            insert newRec;  
        }
    }
    
    public Integer getEbProjScore(String eBType,String complexity,String tierOfAccount){
        Integer score = 0;
        // Get the score based on EB Project Type.
        if(EbCategToSettingMap.containsKey(eBType) && EbCategToSettingMap.get(eBType).Points__c != null && EbCategToSettingMap.get(eBType).Category_Weightage__c != null)
            score += Integer.valueOf((EbCategToSettingMap.get(eBType.trim()).Points__c)*(EbCategToSettingMap.get(eBType.trim()).Category_Weightage__c));
        // Get the score based on Complexity Type.
        if(EbCategToSettingMap.containsKey(complexity) && EbCategToSettingMap.get(complexity).Points__c != null && EbCategToSettingMap.get(complexity).Category_Weightage__c != null)
            score += Integer.valueOf((EbCategToSettingMap.get(complexity.trim()).Points__c)*(EbCategToSettingMap.get(complexity.trim()).Category_Weightage__c));
        // Get the score based on Complexity Type.
        if(EbCategToSettingMap.containsKey(tierOfAccount) && EbCategToSettingMap.get(tierOfAccount).Points__c != null && EbCategToSettingMap.get(tierOfAccount).Category_Weightage__c != null)
            score += Integer.valueOf((EbCategToSettingMap.get(tierOfAccount.trim()).Points__c)*(EbCategToSettingMap.get(tierOfAccount.trim()).Category_Weightage__c));
        // Return Project Score.
        return score/20;        
    }
}