/*
    Description: Trigger that computes the "Agent Time Spent" record and updates "Total_Time_Spent" on Case object.
    Author: Joseph Barrameda (Cloud Sherpas)
    Date: April 17,2013

    History:
    
        17-Apr-2013        - Created ( Insert/Update a record in AGENT_TIME_SPENT object everytime the Minutes_On_Case field is being changed )
        01-May-2013        - Added validation that checks if the User is a Portal User, if a Portal User then the process will be skipped
        
*/

public class CaseTriggerHandler{

    public static boolean isRun = true;
    
    public static boolean runOnce(){
        if(isRun){
            isRun=false;
            return true;
        }else{
            return isRun;
        }
    }

    /* Method that computes the Total Time Spent of an Agent everytime a Case is being updated/worked on */ 
    public static void updateCaseTotalTimeSpent(List<Case> caseList, Boolean isInsert){
        
     
        Set<Id> ownerIDSet = new Set<Id>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        Map<Id,Id> caseIdMap = new Map<Id,Id>();
        Map<Id,Id> agentIdMap = new Map<Id,Id>();      
        
        //Map to store the Agent Id and Case Id 
        Map<Id,Agent_Time_Spent__c> agentCaseMap = new Map<Id,Agent_Time_Spent__c>();
        Map<Id,Agent_Time_Spent__c> computeCaseMap = new Map<Id,Agent_Time_Spent__c>();
        
        //List to store the Agent_Time_Spent record that will be created/updated
        List<Agent_Time_Spent__c> newATSList = new List<Agent_Time_Spent__c>(); 
        List<case> processCaseList = new List<Case>();
        
        System.debug('##### CASE RECORD:' + caseList);
        
        if (runOnce() == true){
            
            for (Case c:caseList){
                if (c.Minutesoncase__c !=0 || c.Minutesoncase__c!=null){
                    ownerIdSet.add(c.ownerId);
                    processCaseList.add(c);
                }            
            }
            
            if (ownerIdSet.size() >0){
                  
                Id pUserProfileId = [SELECT Id FROM Profile WHERE Name='Cvent Customer Community User' LIMIT 1].Id;            
                Map<Id,User> ownerProfIdMap = new Map<Id,User>([SELECT Id, ProfileId FROM User WHERE Id IN: ownerIdSet and profileId != :pUserProfileId]);            //Map all the User Profile Ids
            
                if (ownerProfIdMap.size()!=0){
                    for (Case c:processCaseList){
                        String caseOwner = c.ownerId;
                        if (ownerProfIdMap.get(c.OwnerId)!=null){
                         if(caseOwner.startsWith('005')){                                                   //Validate if the OwnerId is in a USER Id format
                                caseMap.put(c.Id,c);
                                caseIdMap.put(c.Id,c.Id);
                                agentIdMap.put(c.ownerId, c.Id);
                            
                         }
                         }
                    }
                }
            }    
            
            if (caseMap.size() !=0){
            
                for (Agent_Time_Spent__c a:[SELECT Case__c, Agent__c, Total_Time_Spent__c from Agent_Time_Spent__c WHERE Case__c IN: caseMap.keySet() AND Agent__c IN:agentIdMap.keySet()]){
                    agentCaseMap.put(a.Case__c,a);
                }
                                
                for (Case c:[SELECT Id,Total_Time_Spent__c,Minutesoncase__c, OwnerId FROM Case where ID IN:caseMap.keyset()]){
                    if (isInsert){                    
                        //Trigger is After Insert
                        System.debug('##### isInsert ######');
                        Agent_Time_Spent__c ats = new Agent_Time_Spent__c();
                        ats.Case__c = c.Id;
                        ats.Agent__c = c.OwnerId;
                        ats.Total_Time_Spent__c = c.Minutesoncase__c;                 
                
                        newATSList.add(ats);
                        System.debug('##### INSERT RECORD'); 
                    }
                    else{                            
                        //Trigger is After Update
                        System.debug('##### isUpdate #####');
                        if (agentCaseMap.size()<>0){       
                            
                            if( agentCaseMap.get(c.Id)!= null && c.Id == agentCaseMap.get(c.Id).Case__c && c.OwnerId == agentCaseMap.get(c.Id).Agent__c ){
                                if(agentCaseMap.get(c.Id).Total_Time_Spent__c == Null)
                                    agentCaseMap.get(c.Id).Total_Time_Spent__c = c.Minutesoncase__c;
                                else
                                    agentCaseMap.get(c.Id).Total_Time_Spent__c += c.Minutesoncase__c ;   
                                   
                                newATSList.add(agentCaseMap.get(c.Id));                    
                                System.debug('##### UPDATE RECORD');                             
                            }
                        }                
                        else{
                            Agent_Time_Spent__c ats = new Agent_Time_Spent__c();
                            ats.Case__c = c.Id;
                            ats.Agent__c = c.OwnerId;
                            ats.Total_Time_Spent__c = c.Minutesoncase__c;                 
                        
                            newATSList.add(ats); 
                            System.debug('##### INSERT RECORD'); 
                       }
                    
                    }
                }
                
                if(newATSList.size()>0){
                    System.debug('##### NEWATSList:' + newATSList);        
                    upsert newATSList;
                }   
                
                // Commented after creating a rollup summary instead on manual computation
                /*
                Map<String,Integer> sumTimeSpent =new Map<String,Integer>();
            
                //Compute Total_Time_Spent
                for (AggregateResult a:[SELECT SUM(Total_Time_Spent__c),Case__c from Agent_Time_Spent__c WHERE Case__c IN: caseMap.keySet() GROUP BY Case__c]){
                    System.debug('##### COMPUTE TOTAL TIME SPENT:' + a.get('Expr0'));
                    System.debug('##### COMPUTE TOTAL TIME SPENT:' + a.get('Case__c'));
                    
                    String idStr = String.valueOf(a.get('Case__c'));
                    Integer res= Integer.valueof(a.get('Expr0'));
                    sumTimeSpent.put(idStr, res);
                }                
                
                //Update the Total_Time_Spent in Case object then reset the "Minutes On Case" field to 0
                */                        
                           
                List<Case> cList = new List<Case>();
                
                //Resets the value of Minute On Case in Case record
                for (Case c: [SELECT Total_Time_Spent__c , Minutesoncase__c FROM Case WHERE ID in:caseMap.keyset()]){
                    c.Minutesoncase__c =0;
                    cList.add(c);
                }    
                update cList;
            }
        }      
    }
    
    
}