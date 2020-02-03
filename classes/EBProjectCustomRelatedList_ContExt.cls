/*Author: Sandeep Kumar
* Date: 12 April 2017
* Description: Update Pending Hrs for Project Completion. 
* Class is used for displaing records on EBProjectCustomRelatedList_Page and EBProjectCapacityDashboard_Page.
* Test Class : EBProjectCustomRelatedList_ContExt_Test
* VF - EBProjectCustomRelatedList_Page and EBProjectCapacityDashboard_Page
*/
public class EBProjectCustomRelatedList_ContExt {
    
    public List<EB_SB_Builder__c> eBProjList;
    public Boolean showDashboard{get;set;} 
    public Boolean showChildRecords{get;set;} 
    public Map<Id,List<EB_SB_Builder__c>> agentIdToEBProjMap{get;set;} 
    public Map<EB_Agent_Profile__c,List<EB_SB_Builder__c>> agentProfileToEBProjMap{get;set;} 
    public String loggedUser{get;set;}
    // The extension constructor initializes the private member
    // variable writeOff by using the getRecord method from the standard
    // controller.
    public EBProjectCustomRelatedList_ContExt(ApexPages.StandardController stdController){
        loggedUser = UserInfo.getName();
        showChildRecords = false;
        showDashboard = false;
        string str = apexpages.currentpage().getparameters().get('id');
        /// Collection used for showing related records with agent on the agent profile.
        agentIdToEBProjMap = new Map<Id,List<EB_SB_Builder__c>>();
        // Collection used for showing all EB projects on PCS Capacity Dashboard to Leadership.
        agentProfileToEBProjMap = new Map<EB_Agent_Profile__c,List<EB_SB_Builder__c>>();
        if(str != null){
            for(EB_SB_Builder__c EbProj : [Select Id,Name,EB_Agent_Profile__c,Project__c,Project_Launched_del__c,
                                           Project_Stage__c,Project_Reviewed__c,Project_Health__c,Hrs_Pending_for_Completion__c,Day_s_To_Go__c,
                                           Project_Received_Date__c,Project_Type_del__c,Project_Status__c,
                                           Project_Complexity__c,PSP_ID__c,Opportunity__c,Project_Status_del__c,
                                           AccountCustom__c,Expected_Launch_Date__c
                                           from EB_SB_Builder__c where EB_Agent_Profile__c =:str AND Project_Status_del__c NOT IN ('Completed','Cancelled') Order By Expected_Launch_Date__c ASC])
            {
                //Instantiate List
                eBProjList = new List<EB_SB_Builder__c>();            
                // Prepare Opportunity Id to List of Opp Line Items.
                if(agentIdToEBProjMap.containsKey(EbProj.EB_Agent_Profile__c)){
                    eBProjList = agentIdToEBProjMap.get(EbProj.EB_Agent_Profile__c);
                    eBProjList.add(EbProj);
                    agentIdToEBProjMap.put(EbProj.EB_Agent_Profile__c, eBProjList);
                }else{
                    eBProjList.add(EbProj);
                    agentIdToEBProjMap.put(EbProj.EB_Agent_Profile__c, eBProjList);
                }
            }   
            if(agentIdToEBProjMap.size() > 0){
                showChildRecords =true;
            }
        }else{
            for(EB_Agent_Profile__c EbAgentProfile : [Select Id,Name,of_Advanced_Projects__c,of_Complex_Projects__c,of_Medium_Projects__c,of_Projects__c,of_Projects_Agent__c,of_Projects_Completed__c,of_Simple_Projects__c,
                                                      Agent_Name__c,Agent_Score__c,Agent_Shift__c,Agent_Skill_Group__c ,Agent_Status__c,Agent_Status_Indicator__c,Current_Assignment__c,Current_FY_Quality_Score__c,Current_Work_Load_hrs__c,
                                                      Max_Workload_Agent_Hrs__c,Process_Scores__c,Quality_Scores_Overall__c,VSAT_Current_FY__c,Max_of_Projects_Per_Week__c,VSAT_Overall__c,(Select Id,Name,EB_Agent_Profile__c,Project__c,Project_Launched_del__c,
                                                                                                                                                                Project_Stage__c,Project_Reviewed__c,Project_Health__c,Hrs_Pending_for_Completion__c,Day_s_To_Go__c,Project_Received_Date__c,Project_Type_del__c,Project_Status__c,Project_Complexity__c,PSP_ID__c,Opportunity__c,Project_Status_del__c,AccountCustom__c,Expected_Launch_Date__c
                                                                                                                                                                from EB_SB_Projects__r where EB_Agent_Profile__c !=null AND Project_Status_del__c NOT IN ('Completed','Cancelled') Order By Expected_Launch_Date__c ASC) from EB_Agent_Profile__c Order By Name ASC])
            {
                //Instantiate List
                eBProjList = new List<EB_SB_Builder__c>();           
                // Get all the projects with this Agent Profile.
                for(EB_SB_Builder__c EbProj : EbAgentProfile.EB_SB_Projects__r){
                    // Prepare Opportunity Id to List of Opp Line Items.
                    eBProjList.add(EbProj);
                } 
                agentProfileToEBProjMap.put(EbAgentProfile, eBProjList);
            }
            if(!agentProfileToEBProjMap.isEmpty()){
                showDashboard = true;
            }
        }     
    }        
}