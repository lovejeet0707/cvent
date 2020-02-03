/**************************************************************************************
* Author: Sandeep Kumar
* Date: 16 August 2018
* Description: CC Mobile App Auto Assignemnt Rollup, created as a part of CC ABP Automation  
* It is updating # of Projects(In Progress), # of Projects(Completed), Agent Workload etc.
* Class also creates cases for the newly assigned App Builder for the Mobile App fields Where the agents are suppose to connect with customer
* Test Class : CCMobileAppAutoAssignment_TrigAct_Test
****************************************************************************************/
public class CCMobileAppAssignmentRollup_TrigAct extends TriggerAction{    
    private Set<Id> OwnerIds; 
    private List<Case> casesToInsertList;    
    private Set<Id> newMobileAppAssignmentSet;
    private Map<Id,Integer> ownerIdToNoOfProjMap;
    private Map<Id,Integer> ownerIdToWorkLoadMap; 
    public Static Boolean autoAssignmentEmailSent;    
    private Map<Id,Integer> ownerIdToNoOfSimpleProjMap;
    private Map<Id,Integer> ownerIdToNoOfMediumProjMap; 
    private Map<Id,Integer> ownerIdToNoOfAdvancedProjMap;
    private Map<Id,Integer> ownerIdToNoOfComplexProjMap;
    private Map<Id,Integer> ownerIdToNoOfProjCompletedMap; 
    private List<EB_Agent_Profile__c> EbProjAssignmentList;    
    private Map<Id,List<Mobile_Card__c>> OwnerIdToMobileAppMap; 
    private Map<Id,EB_Agent_Profile__c> OwnerIdToEbProjAssignObj;
    private Boolean newCaseCreationFlag = Boolean.valueOf(Label.CC_Automation_Create_Cases_Per_Mobile_App);
    private final Id newNewCrowdCompassCaseRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CC_Automation_Case_RT_Label_Name).getRecordTypeId();                
    
    public CCMobileAppAssignmentRollup_TrigAct(){
        // Call super to set batch variables & context
        super();
        OwnerIds = new Set<Id>();
        casesToInsertList = new List<Case>();
        newMobileAppAssignmentSet = new Set<Id>();
        ownerIdToNoOfProjMap = new Map<Id,Integer>();
        ownerIdToWorkLoadMap = new Map<Id,Integer>();
        ownerIdToNoOfSimpleProjMap = new Map<Id,Integer>();
        ownerIdToNoOfMediumProjMap = new Map<Id,Integer>();
        ownerIdToNoOfAdvancedProjMap = new Map<Id,Integer>();
        ownerIdToNoOfComplexProjMap = new Map<Id,Integer>();    
        ownerIdToNoOfProjCompletedMap = new Map<Id,Integer>();
        EbProjAssignmentList = new List<EB_Agent_Profile__c>();
        OwnerIdToMobileAppMap = new Map<Id,List<Mobile_Card__c>>();
        OwnerIdToEbProjAssignObj = new Map<Id,EB_Agent_Profile__c>();
    }
    
    public override Boolean shouldRun(){
        if(this.isUpdate() && this.isAfter() && !this.hasRun()){
            // set the Auto-Assignment flag if this is null
            if(autoAssignmentEmailSent == null) autoAssignmentEmailSent = false;
            
            for(Mobile_Card__c newMobileApp: (List<Mobile_Card__c>)this.triggerMap.values()){
                if(newMobileApp.Agent_Profile__c != null){
                    OwnerIds.add(newMobileApp.OwnerId);   
                    Mobile_Card__c oldMobileApp = (Mobile_Card__c)this.triggerOldMap.get(newMobileApp.Id);
                    // below check is used to determine the newly inserted 
                    if(oldMobileApp.Agent_Profile__c == null && oldMobileApp.Agent_Profile__c != newMobileApp.Agent_Profile__c){
                        newMobileAppAssignmentSet.add(newMobileApp.OwnerId);
                        if(oldMobileApp.App_Builder__c == null && oldMobileApp.App_Builder__c != newMobileApp.App_Builder__c){
                            // sends auto-assignment email to the new mobile app builder
                            if(!autoAssignmentEmailSent){
                                EBSurveyNotificationEmail.sendCCMobileAppAssignmentEmail(newMobileApp.Opportunity__c,newMobileApp.App_Builder__c);
                                autoAssignmentEmailSent = true;
                            }
                            if(!newMobileApp.CC_Form_Sent__c){
                                // create new case if the CC Form Sent field is unchecked.
                                casesToInsertList.add(createCaseObj(newMobileApp));
                            }
                        }                           
                    }                        
                }                             
            }
        }
        
        if(!OwnerIds.isEmpty()){
            // Get Related objects details. Required in order to get the score of a EB Project.
            for(Mobile_Card__c  mobApp : [Select Id,Ideal_App_Launch_Date__c,Complexity__c,Stage__c,Agent_Profile__c,OwnerId,LastModifiedDate From Mobile_Card__c Where OwnerId IN:OwnerIds Order By OwnerId DESC]){
                if(mobApp.Agent_Profile__c != null){
                    // Prepare Opportunity Id to List of Opp Line Items.
                    if(OwnerIdToMobileAppMap.containsKey(mobApp.OwnerId)){
                        OwnerIdToMobileAppMap.get(mobApp.OwnerId).add(mobApp);
                    }else{
                        OwnerIdToMobileAppMap.put(mobApp.OwnerId,new List<Mobile_Card__c>{mobApp});
                    } 
                }                
            } 
        }
        return !OwnerIdToMobileAppMap.isEmpty();
    }
    
    public override void doAction(){
        // Enable the flag to avoid recursion.
        this.markRun();
        
        Integer noOfProj,noOfProjCompleted,workLoadHrs;
        Integer noOfSimpleProj,noOfMediumProj,noOfAdvancedProj,noOfComplexProj;  
        
        // Get CC Agent Profile Record Type ID
        Id CCAgentProfileRecTypeId = Schema.SObjectType.EB_Agent_Profile__c.getRecordTypeInfosByName().get(Label.CC_Agent_Profile_RT_Label_Name).getRecordTypeId();
        
        for(EB_Agent_Profile__c ebProjAssignRec :[Select Id,Agent_Name__c,of_Projects_Completed__c,Agent_Score__c,of_Projects__c,Max_of_projects_per_Month__c,Current_Assignment__c,Current_Work_Load_hrs__c,of_Simple_Projects__c,of_Medium_Projects__c,of_Advanced_Projects__c,of_Complex_Projects__c from EB_Agent_Profile__c Where RecordTypeId = :CCAgentProfileRecTypeId AND User_Active__c = true Order By Agent_Name__c DESC]){
            OwnerIdToEbProjAssignObj.put(ebProjAssignRec.Agent_Name__c, ebProjAssignRec);                
        }
        
        for(Id ownerId :OwnerIdToMobileAppMap.keySet()){
            noOfProj = 0;
            workLoadHrs = 0;
            noOfProjCompleted = 0;
            noOfSimpleProj = 0;            
            noOfMediumProj = 0;
            noOfAdvancedProj = 0;
            noOfComplexProj =0;
            Integer monthsBetween = 0;
            Integer projectLastModifiedDays = 0;
            
            for(Mobile_Card__c mobApp : OwnerIdToMobileAppMap.get(ownerId)){
                system.debug('========================================Mobile App = '+mobApp);                   
                noOfProj += 1;
                if(mobApp.Stage__c == 'Closed Out'){
                    noOfProjCompleted += 1; 
                }else{
                    if(mobApp.Complexity__c == 'Standard'){
                        noOfSimpleProj += 1;
                    }else if(mobApp.Complexity__c == 'Medium'){
                        noOfMediumProj += 1;
                    }else if(mobApp.Complexity__c == 'Advanced'){
                        noOfAdvancedProj += 1;
                    }else if(mobApp.Complexity__c == 'Complex'){
                        noOfComplexProj += 1;
                    }   
                }              
            }  
            ownerIdToNoOfProjMap.put(ownerId, noOfProj);
            ownerIdToNoOfSimpleProjMap.put(ownerId, noOfSimpleProj);
            ownerIdToNoOfMediumProjMap.put(ownerId, noOfMediumProj);
            ownerIdToNoOfAdvancedProjMap.put(ownerId, noOfAdvancedProj);
            ownerIdToNoOfComplexProjMap.put(ownerId, noOfComplexProj);
            ownerIdToNoOfProjCompletedMap.put(ownerId, noOfProjCompleted);
        } 
        
        for(Id agentId :OwnerIdToEbProjAssignObj.keySet()){
            if(OwnerIdToMobileAppMap.containsKey(agentId)){
                OwnerIdToEbProjAssignObj.get(agentId).of_Projects__c = ownerIdToNoOfProjMap.get(agentId);
                OwnerIdToEbProjAssignObj.get(agentId).of_Projects_Completed__c = ownerIdToNoOfProjCompletedMap.get(agentId);
                OwnerIdToEbProjAssignObj.get(agentId).of_Simple_Projects__c = ownerIdToNoOfSimpleProjMap.get(agentId);
                OwnerIdToEbProjAssignObj.get(agentId).of_Medium_Projects__c = ownerIdToNoOfMediumProjMap.get(agentId);
                OwnerIdToEbProjAssignObj.get(agentId).of_Advanced_Projects__c = ownerIdToNoOfAdvancedProjMap.get(agentId);
                OwnerIdToEbProjAssignObj.get(agentId).of_Complex_Projects__c = ownerIdToNoOfComplexProjMap.get(agentId);  
                if(newMobileAppAssignmentSet.contains(agentId)){
                    OwnerIdToEbProjAssignObj.get(agentId).Last_Project_Assignment__c = System.Datetime.now();
                    OwnerIdToEbProjAssignObj.get(agentId).Millisecond__c = System.Datetime.now().millisecondGMT();                  
                }
                EbProjAssignmentList.add(OwnerIdToEbProjAssignObj.get(agentId));                
            }            
        }
        system.debug('CCRollup=========EbProjAssignmentList= '+EbProjAssignmentList);  
        // perform DML - update Agent Profiles
        if(!EbProjAssignmentList.isEmpty()) update EbProjAssignmentList; 
        system.debug('CCRollup=========casesToInsertList= '+casesToInsertList);
        // perform DML - insert Cases
        if(newCaseCreationFlag && !casesToInsertList.isEmpty()) insert casesToInsertList;
    }    
    
    // creates case object
    private Case createCaseObj(Mobile_Card__c mobileApp){
        return new Case(Status = 'Open',
                        Priority = 'High',
                        Mobile_App__c = mobileApp.Id,
                        Case_Reason__c = 'App Build',
                        Origin = 'CC Project Coordinator',
                        Product_Type__c = 'CrowdCompass',
                        CC_Integration_Discussed__c = 'No',                        
                        OwnerId = mobileApp.App_Builder__c,
                        RecordTypeId = newNewCrowdCompassCaseRT,
                        Deadline_Date__c = Date.today().addDays(2),                        
                        Client_Services_Category__c = 'Mobile App',
                        Subject = Label.CC_Automation_Case_Subject,
                        ContactId = mobileApp.Primary_Contact__c,
                        AccountId = mobileApp.Contract_Account_New__c,                        
                        Description = Label.CC_Automation_Case_Description
                       );        
    }
}