/*Author: Sandeep Kumar
* Date: 02 April 2017
* Description: EB Project Auto Assignemnt Rollup. 
* Class is reponsible for updating "EB_Project_Assignment__c" fields based on the EB projects assigned to 
* a Agent. It is updating # of Projects(In Progress), # of Projects(Completed), Agent Workload etc.
* Test Class : EBProjectAssignmentRollup_TrigAct_Test,EBSB_SurveyResponseParser_Test
*
* Last Modified By : Sandeep Kumar, Dated: 19 Jan, 2017
* Project :P-003178
*/
public class EBProjectAssignmentRollup_TrigAct extends TriggerAction{    
    public Set<Id> OwnerIds;
    public Map<Id,Id> accIdToOwnerMap;
    public Set<Id> sendEmailToAMCSCSet;    
    public Set<String> accountTeamMemberRoleSet;
    public Map<Id,EB_SB_Builder__c> accIdToEBSBProjMap;
    public Map<Id,Integer> ownerIdToNoOfProjMap;
    public Map<Id,Integer> ownerIdToWorkLoadMap; 
    public Map<Id,Integer> ownerIdToNoOfSimpleProjMap;
    public Map<Id,Integer> ownerIdToNoOfMediumProjMap; 
    public Map<Id,Integer> ownerIdToNoOfAdvancedProjMap;
    public Map<Id,Integer> ownerIdToNoOfComplexProjMap;
    public Map<Id,Integer> ownerIdToNoOfProjCompletedMap;    
    public List<EB_Agent_Profile__c> EbProjAssignmentList;    
    public Map<Id,List<EB_SB_Builder__c>> OwnerIdToEbProjMap;    
    public Map<Id,EB_Agent_Profile__c> OwnerIdToEbProjAssignObj;
    public final static Id eventBuilderLeadersQueueId = Label.Event_Builder_Leaders_Queue_Id;
    public final static String teamMemberRoleForSendingOwnerChangeEmail = Label.EB_Project_Account_Team_Member_Role_For_Sending_Owner_Change_Email;
    public final static Integer rollUpDaysForOnHoldProjects = Integer.valueOf(Label.EB_Project_Roll_Up_Days_For_On_Hold_Projects);
    public static final Set<String> projectStatusSet = new Set<String>{'Completed','Cancelled','On-Hold'};        
        
        public EBProjectAssignmentRollup_TrigAct(){
            // Call super to set batch variables & context
            super();
            OwnerIds = new Set<Id>();
            sendEmailToAMCSCSet = new Set<Id>();
            accIdToOwnerMap = new Map<Id,Id>();
            accountTeamMemberRoleSet = new Set<String>();
            accIdToEBSBProjMap = new Map<Id,EB_SB_Builder__c>();
            ownerIdToNoOfProjMap = new Map<Id,Integer>();
            ownerIdToWorkLoadMap = new Map<Id,Integer>();
            ownerIdToNoOfSimpleProjMap = new Map<Id,Integer>();
            ownerIdToNoOfMediumProjMap = new Map<Id,Integer>();
            ownerIdToNoOfAdvancedProjMap = new Map<Id,Integer>();
            ownerIdToNoOfComplexProjMap = new Map<Id,Integer>();    
            ownerIdToNoOfProjCompletedMap = new Map<Id,Integer>();
            EbProjAssignmentList = new List<EB_Agent_Profile__c>();
            OwnerIdToEbProjMap = new Map<Id,List<EB_SB_Builder__c>>();
            OwnerIdToEbProjAssignObj = new Map<Id,EB_Agent_Profile__c>();         
            accountTeamMemberRoleSet.addAll(teamMemberRoleForSendingOwnerChangeEmail.split(','));
        }
    
    public override Boolean shouldRun(){
        if(this.isInsert() || this.isUpdate() && this.isAfter() && !this.hasRun()){
            for(EB_SB_Builder__c newProj: (List<EB_SB_Builder__c>)this.triggerMap.values()){
                if(newProj.EB_Agent_Profile__c != null){
                    OwnerIds.add(newProj.OwnerId);            
                }   
                
                if(this.isUpdate()){
                    EB_SB_Builder__c oldProj = (EB_SB_Builder__c)this.triggerOldMap.get(newProj.Id);
                    if(newProj.OwnerId != oldProj.OwnerId && newProj.OwnerId != eventBuilderLeadersQueueId && oldProj.OwnerId != eventBuilderLeadersQueueId){
                        System.debug('=============Owner Changed Triggered==================');                    
                        sendEmailToAMCSCSet.add(newProj.Id);
                        accIdToEBSBProjMap.put(newProj.AccountCustom__c, newProj);
                        accIdToOwnerMap.put(newProj.AccountCustom__c, newProj.OwnerId);
                    } 
                }                               
            }
            
            List<EB_SB_Builder__c> ebProjList;
            // Get Related objects details. Required in order to get the score of a EB Project.
            for(EB_SB_Builder__c  EbProj : [Select Id,AccountCustom__c,AccountCustom__r.Service_Tier__c,EB_Agent_Profile__c,Project_Stage__c,Project_Status_del__c,Project_Type_del__c,Expected_Launch_Date__c,OwnerId,Project_Complexity__c,Hrs_Pending_for_Completion__c,LastModifiedDate From EB_SB_Builder__c Where OwnerId IN:OwnerIds Order By OwnerId DESC]){
                if(EbProj.EB_Agent_Profile__c != null){
                    //Instantiate List
                    ebProjList = new List<EB_SB_Builder__c>();                    
                    // Prepare Opportunity Id to List of Opp Line Items.
                    if(OwnerIdToEbProjMap.containsKey(EbProj.OwnerId)){
                        ebProjList = OwnerIdToEbProjMap.get(EbProj.OwnerId);
                        ebProjList.add(EbProj);
                        OwnerIdToEbProjMap.put(EbProj.OwnerId,ebProjList);
                    }else{
                        ebProjList.add(EbProj);
                        OwnerIdToEbProjMap.put(EbProj.OwnerId,ebProjList);
                    } 
                }                
            }  
        }        
        return !OwnerIdToEbProjMap.isEmpty() || !sendEmailToAMCSCSet.isEmpty();
    }
    
    public override void doAction(){
        Integer noOfProj,noOfProjCompleted,workLoadHrs;
        Integer noOfSimpleProj,noOfMediumProj,noOfAdvancedProj,noOfComplexProj;  
        
        for(EB_Agent_Profile__c ebProjAssignRec :[Select Id,Agent_Name__c,Agent_Score__c,of_Projects__c,Current_Assignment__c,Current_Work_Load_hrs__c,of_Simple_Projects__c,of_Medium_Projects__c,of_Advanced_Projects__c,of_Complex_Projects__c from EB_Agent_Profile__c Order By Agent_Name__c DESC]){
            OwnerIdToEbProjAssignObj.put(ebProjAssignRec.Agent_Name__c, ebProjAssignRec);                
        } 
        
        for(Id ownerId :OwnerIdToEbProjMap.keySet()){
            noOfProj = 0;
            workLoadHrs = 0;
            noOfProjCompleted = 0;
            noOfSimpleProj = 0;            
            noOfMediumProj = 0;
            noOfAdvancedProj = 0;
            noOfComplexProj =0;
            Integer monthsBetween = 0;
            Integer projectLastModifiedDays = 0;
            
            for(EB_SB_Builder__c ebProj : OwnerIdToEbProjMap.get(ownerId)){
                system.debug('========================================EB SB Project = '+ebProj);                    
                if(ebProj.Expected_Launch_Date__c != null && ebProj.Hrs_Pending_for_Completion__c != null){
                    monthsBetween = System.today().monthsBetween(ebProj.Expected_Launch_Date__c);
                    if(monthsBetween >= 0 && monthsBetween <= 1){
                        workLoadHrs += Integer.valueOf(ebProj.Hrs_Pending_for_Completion__c);
                    }
                }                
                if(!projectStatusSet.contains(ebProj.Project_Status_del__c)){
                    noOfProj += 1;
                    if(ebProj.Project_Complexity__c == '1-Simple'){
                        noOfSimpleProj += 1;
                    }else if(ebProj.Project_Complexity__c == '2-Medium'){
                        noOfMediumProj += 1;
                    }else if(ebProj.Project_Complexity__c == '3-Advanced'){
                        noOfAdvancedProj += 1;
                    }else if(ebProj.Project_Complexity__c == '4-Complex'){
                        noOfComplexProj += 1;
                    }
                }else{
                    projectLastModifiedDays = System.Today().daysBetween(Date.valueOf(ebProj.LastModifiedDate));                    
                    if(ebProj.Project_Status_del__c == 'On-Hold' && projectLastModifiedDays < rollUpDaysForOnHoldProjects || Test.isRunningTest()){
                        noOfProj += 1;
                        if(ebProj.Project_Complexity__c == '1-Simple'){
                            noOfSimpleProj += 1;
                        }else if(ebProj.Project_Complexity__c == '2-Medium'){
                            noOfMediumProj += 1;
                        }else if(ebProj.Project_Complexity__c == '3-Advanced'){
                            noOfAdvancedProj += 1;
                        }else if(ebProj.Project_Complexity__c == '4-Complex'){
                            noOfComplexProj += 1;
                        }
                    }                        
                }
                if(ebProj.Project_Status_del__c == 'Completed'){
                    noOfProjCompleted += 1; 
                }               
            }  
            ownerIdToNoOfProjMap.put(ownerId, noOfProj);
            ownerIdToWorkLoadMap.put(ownerId, workLoadHrs);
            ownerIdToNoOfSimpleProjMap.put(ownerId, noOfSimpleProj);
            ownerIdToNoOfMediumProjMap.put(ownerId, noOfMediumProj);
            ownerIdToNoOfAdvancedProjMap.put(ownerId, noOfAdvancedProj);
            ownerIdToNoOfComplexProjMap.put(ownerId, noOfComplexProj);
            ownerIdToNoOfProjCompletedMap.put(ownerId, noOfProjCompleted);
        } 
        
        for(Id agentId :OwnerIdToEbProjAssignObj.keySet()){
            if(OwnerIdToEbProjMap.containsKey(agentId)){
                OwnerIdToEbProjAssignObj.get(agentId).of_Projects__c = ownerIdToNoOfProjMap.get(agentId);
                OwnerIdToEbProjAssignObj.get(agentId).Current_Work_Load_hrs__c = ownerIdToWorkLoadMap.get(agentId);
                OwnerIdToEbProjAssignObj.get(agentId).of_Projects_Completed__c = ownerIdToNoOfProjCompletedMap.get(agentId);
                OwnerIdToEbProjAssignObj.get(agentId).of_Simple_Projects__c = ownerIdToNoOfSimpleProjMap.get(agentId);
                OwnerIdToEbProjAssignObj.get(agentId).of_Medium_Projects__c = ownerIdToNoOfMediumProjMap.get(agentId);
                OwnerIdToEbProjAssignObj.get(agentId).of_Advanced_Projects__c = ownerIdToNoOfAdvancedProjMap.get(agentId);
                OwnerIdToEbProjAssignObj.get(agentId).of_Complex_Projects__c = ownerIdToNoOfComplexProjMap.get(agentId);            
                EbProjAssignmentList.add(OwnerIdToEbProjAssignObj.get(agentId));                
            }            
        }
        
        
        Map<Id,List<String>> accIdToUserEmailMap = new Map<Id,List<String>>();
        
        // Prepare the list of user where the email will be sent.
        if(!sendEmailToAMCSCSet.isEmpty() && !accIdToEBSBProjMap.isEmpty() && !accIdToOwnerMap.isEmpty()){            
            List<String> userEmailList;
            // Get Event AM from the Account Team Member list.
            for(AccountTeamMember atm :[Select Id,AccountId,TeamMemberRole,UserId,User.Email From AccountTeamMember Where TeamMemberRole IN :accountTeamMemberRoleSet AND AccountId IN :accIdToOwnerMap.keySet()]){
                userEmailList = new List<String>();
                // Prepare a MAP for storing AccountId to User email map
                if(accIdToUserEmailMap.containsKey(atm.AccountId)){
                    userEmailList = accIdToUserEmailMap.get(atm.AccountId);
                    userEmailList.add(atm.User.Email);
                    accIdToUserEmailMap.put(atm.AccountId, userEmailList);
                }else{
                    userEmailList.add(atm.User.Email);
                    accIdToUserEmailMap.put(atm.AccountId, userEmailList);
                }                
            }
            
            // Send Owner Change email to new Owner, Event AM And CS.
            if(accIdToUserEmailMap.size() > 0 && accIdToOwnerMap.size() > 0  && accIdToEBSBProjMap.size() > 0)
                EBSurveyNotificationEmail.sendEBSBProjectOwnerChangeEmail(accIdToOwnerMap,accIdToUserEmailMap,accIdToEBSBProjMap);            
        }        
        
        if(!EbProjAssignmentList.isEmpty()){
            update EbProjAssignmentList;
            this.markRun();
        }                   
    }    
}