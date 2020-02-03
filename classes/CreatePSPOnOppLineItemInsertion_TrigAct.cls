/**************************************************************************************** 
* Version 1
* Author : Sandeep Kumar
* Date : 18 May, 2017
* Description : CreatePSPOnOppLineItemInsertion_TrigAct class fullfills below functionalities,
* 1) Creates EB SB Project whenever Event Build Opportunity is implemented in Salesforce. 
* 2) Check for PSP ID for current year and if this doesn't exist, creates new add all the projects to it.
* 3) Sents EB Form to Opportunity Contact or Event Planner.
* Test Class - CreatePSPOnOppLineItem_TrigAct_Test  
*****************************************************************************************
* Last Modified By : Sandeep Kumar (Dated: 22 August, 2017)
* Previously this piece of code was called whenever opportunityLineItem were inserted in Salesforce. 
* As per new CPQ process in place this code is called from OpportunityAfter trigger. 
* It will still full fill the previous process by creating opportunities.
*****************************************************************************************
* Last Modified By : Sandeep Kumar (Dated: 02 November, 2017)
* Added additional check to fire automation trigger only one time per opportunity.
* This enhancement was done to avoid duplicate EB SB Project creation as the finance team was 
* toggliing Contract Implemented checkbox several times.
*****************************************************************************************
* Version 2: Merged Crowd Compass ABP Automation, created as a part of CC ABP Automation 
* Created By : Sandeep Kumar (Dated: 06 June, 2018)
* Last Modified By : Sandeep Kumar (Dated: 11 Nov, 2018)
* Description : This handler class also fullfills below functionalities,
* 1) Creates CC Mobile Apps whenever a Crowd Compass Opportunity is implemented in Salesforce.
* 2) Pre-Populate values on the Mobile App like App Version, Complexity Level, Onboaring checkbox(if required),
* PSP ID,Service Tier etc.
* 3) Creates PSP ID for current year(if that doesn't exist), otherwise utlizes the already existing PSP ID.
* 4) Sends CC form to Opportunity Primary Contact.
*****************************************************************************************
* Version 2.1: Enhancement for the Event Builder Rush Request process.
* Last Modified By : Sandeep Kumar (Dated: 31 July, 2018)
* Description : Below enhancement was added in the apex class.
* 1) Removed the Event Builder Rush Services product to not create a seperate EB SB Project, 
* Instead it should update the coressponding EB SB Project with the "Rush Request" Project Type.
********************************************************************************************
* Version 2.2: Enhancement for the Event Builder FLEX Conversion process.
* Last Modified By : Sandeep Kumar (Dated: 18 Oct, 2018)
* Description : Below enhancement was added in the apex class for the FLEX Conversion project type.
* The automation process remains the same like we have for Event Builder Team, however the triggering point is changed to Opportunity Stage
********************************************************************************************
* Version 2.3: Enhancement for the Event Builder Rush Request process.
* Last Modified By : Sandeep Kumar (Dated: 27 Jan, 2019)
* Description : Below enhancement was added in the apex class.
* 1) Removed the Event Builder Rush Services product to not create a seperate EB SB Project, 
* Instead it should update the coressponding EB SB Project with the "Rush Request" Project Type.
********************************************************************************************/
public without sharing class CreatePSPOnOppLineItemInsertion_TrigAct extends TriggerAction{    
    public Integer currentYear;
    public String baseUrl;
    public Set<Id> oppIdsToProcessSet;
    public Set<Id> accIdSet;
    public Set<Id> newPSPAccountSet;
    public Set<Id> newEBAccountSet;
    public Set<Id> newCCAccountSet;
    public Map<Id,Integer> accIdToEBCountMap;
    public Map<Id,Integer> accIdToCCMobileAppCountMap;
    public Map<Id,Opportunity> oppIdToOppMap;
    public Messaging.SingleEmailMessage mail;
    public Boolean executeEBAutomationWorkFlow;
    public Boolean executeCCAutomationWorkFlow;
    public Boolean createMobileApp;
    public List<Messaging.SingleEmailMessage> mailList;
    public Map<String,EBProjectStageToPendingHrsSetting__c> NameToHrsPendingMap; 
    public Map<String,EB_Project_Products_Mapping__c> prodNameToProdMappingMap;
    public List<Professional_Services_Project__c> PSPToBeInsertedList;
    public List<Professional_Services_Project__c> PSPToBeUpdatedList;
    public Map<Id,Professional_Services_Project__c> pspUpdateMap;
    public List<EB_SB_Builder__c> EBSBToBeInsertedList;
    public List<Mobile_Card__c> mobileAppsToBeInsertedList;
    public Map<Id,List<OpportunityLineItem>> oppIdToOppLineItemsMap;
    public Map<Id,List<Opportunity>> accIdToOpptsMap;
    public Map<Id,Boolean> accIdToARAFlagMap;
    public Set<String> validAutomationProductSet;    
    public Map<Id,Map<Integer,Professional_Services_Project__c>> accIdToPSPsMap;
    public Map<String,Integer> productNameToEBCountMap;
    public Map<String,Integer> crowdCompassProductKeyToCCMobileAppCountMap;
    public Map<String,Id> productNameToOppLineItemId;
    public final string runCCAutomationProcess = Label.Run_CC_Automation_Process;
    public final string oweaId = Label.EB_Project_Org_Wide_Address_Id;    
    public final static Id eventBuilderLeadersQueueId = Label.Event_Builder_Leaders_Queue_Id;
    public Set<Id> oppRecTypeIdToProcessSet = new Set<Id>{Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Event').getRecordTypeId(),
        Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CrowdCompass').getRecordTypeId()};
            
            // default Constructor
            public CreatePSPOnOppLineItemInsertion_TrigAct(){
                // call super to set batch variables & system context
                super();
                // initiliaze class level variables
                currentYear = System.today().year();
                accIdSet = new Set<Id>();
                createMobileApp = false;
                oppIdsToProcessSet = new Set<Id>(); 
                newCCAccountSet = new Set<Id>(); 
                newEBAccountSet = new Set<Id>();
                newPSPAccountSet = new Set<Id>();
                executeEBAutomationWorkFlow = false;
                executeCCAutomationWorkFlow = false;
                accIdToARAFlagMap = new Map<Id,Boolean>();                
                oppIdToOppMap = new Map<Id,Opportunity>();                
                accIdToEBCountMap = new Map<Id,Integer>(); 
                validAutomationProductSet = new Set<String>();                
                accIdToCCMobileAppCountMap = new Map<Id,Integer>();       
                productNameToOppLineItemId = new Map<String,Id>();
                EBSBToBeInsertedList = new List<EB_SB_Builder__c>();
                mobileAppsToBeInsertedList = new List<Mobile_Card__c>();
                accIdToOpptsMap = new Map<Id,List<Opportunity>>(); 
                productNameToEBCountMap = new Map<String,Integer>();
                crowdCompassProductKeyToCCMobileAppCountMap = new Map<String,Integer>();
                oppIdToOppLineItemsMap = new Map<Id,List<OpportunityLineItem>>();
                prodNameToProdMappingMap = new Map<String,EB_Project_Products_Mapping__c>();
                accIdToPSPsMap = new Map<Id,Map<Integer,Professional_Services_Project__c>>(); 
                validAutomationProductSet.addAll(Label.EB_Project_Flex_Conversion_Products.split(','));                        
            }
    
    public override Boolean shouldRun(){ 
        // turn on the EBSB Automation Triggered Flag so that it should run only once.
        if(this.isUpdate() && this.isBefore() && !this.hasRun()){
            for (Opportunity newOpp: (List<Opportunity>)this.triggerMap.values()){ 
                Opportunity oldOpp = (Opportunity)this.triggerOldMap.get(newOpp.Id);
                // for EB SB Automation
                if(oppRecTypeIdToProcessSet.contains(newOpp.RecordTypeId) && !newOpp.EBSB_Automation_Triggered_Dev__c && oldOpp.Contract_Implemented__c != newOpp.Contract_Implemented__c && oldOpp.Contract_Implemented__c == true)
                    newOpp.EBSB_Automation_Triggered_Dev__c = true;
                
                // for Flex Conversion Automation
                if(!newOpp.EBSB_Automation_Triggered_Dev__c && oldOpp.StageName != newOpp.StageName && oldOpp.StageName == 'Closed Won – Do Not Send to EBS')
                    newOpp.EBSB_Automation_Triggered_Dev__c = true;
            }               
        } 
        
        if(this.isUpdate() && this.isAfter() && !this.hasRun()){ 
            // check Opportunities and execute the EBSB Automation process if below criterias are met.
            for (Opportunity newOpp: (List<Opportunity>)this.triggerMap.values()){ 
                Opportunity oldOpp = (Opportunity)this.triggerOldMap.get(newOpp.Id);
                if(oppRecTypeIdToProcessSet.contains(newOpp.RecordTypeId) && !newOpp.EBSB_Automation_Triggered_Dev__c && newOpp.StageName == 'Closed Won' && oldOpp.Contract_Implemented__c != newOpp.Contract_Implemented__c && newOpp.Contract_Implemented__c != null && newOpp.Contract_Implemented__c){
                    oppIdsToProcessSet.add(newOpp.Id);
                }
                // added below code for Flex Conversion Automation                
                if(newOpp.StageName == 'Closed Won – Do Not Send to EBS' && oldOpp.StageName != 'Closed Won – Do Not Send to EBS'){
                    oppIdsToProcessSet.add(newOpp.Id);
                }              
            } 
            system.debug('oppIdsToProcessSet--->>>>'+oppIdsToProcessSet);
            if(oppIdsToProcessSet.size() > 0){
                String crowdCompassProductKey = '';
                for(OpportunityLineItem newItem : [Select Id,Complexity__c,Product2.Family,Product2.Name,Quantity,OpportunityId from OpportunityLineItem where OpportunityId IN :oppIdsToProcessSet]){
                    system.debug('newItem--->>>>'+newItem);
                    // Quantity Null Pointer Check, Skip the loop for Product having null or 0 Quantity.
                    if(newItem.Quantity != null && newItem.Quantity != 0){
                        // Do Not add the Product for Processing if the Product Name is below
                        if(newItem.Product2.Name == 'CrowdCompass Mobile App'){
                            createMobileApp = true;
                        }
                        // Decision Maker for EB SB Automation/ FLEX Conversion Workflow.
                        if((validAutomationProductSet.contains(newItem.Product2.Name) || newItem.Product2.Name.contains('Event Builder')) && newItem.Product2.Name != 'Event Builder Package'){
                            // set the flag to execute Event Builder Automation Workflow.
                            executeEBAutomationWorkFlow = true;
                            // Stores the Product Name to OpportunityLineItem Id.
                            productNameToOppLineItemId.put(newItem.Product2.Name, newItem.Id);
                            // Stores the prod name and project count.
                            productNameToEBCountMap.put(newItem.Product2.Name,Integer.ValueOf(newItem.Quantity));                        
                            // Prepare Opportunity Id to List of Opp Line Items.
                            if(oppIdToOppLineItemsMap.containsKey(newItem.OpportunityId)){
                                oppIdToOppLineItemsMap.get(newItem.OpportunityId).add(newItem);
                            }else{
                                oppIdToOppLineItemsMap.put(newItem.OpportunityId,new List<OpportunityLineItem>{newItem});
                            }
                        }
                        // Decision Maker for Crowd Compass ABP Automation Workflow.
                        if(Boolean.valueOf(runCCAutomationProcess) && newItem.Product2.Family == 'CrowdCompass' && newItem.Product2.Name.contains('App Build') && newItem.Complexity__c != null){
                            // set the flag to execute CrowdCompass Automation Workflow.
                            executeCCAutomationWorkFlow = true;
                            // Prepare the key with the help of Product Family and Complexity.
                            crowdCompassProductKey = newItem.Product2.Family+':'+newItem.Complexity__c;
                            // Stores the CrowdCompassProductKey to OpportunityLineItem Id.
                            productNameToOppLineItemId.put(crowdCompassProductKey, newItem.Id);                        
                            // Stores the CrowdCompassProductKey and project count.
                            crowdCompassProductKeyToCCMobileAppCountMap.put(crowdCompassProductKey,Integer.ValueOf(newItem.Quantity));                        
                            // Prepare Opportunity Id to List of Opp Line Items.
                            if(oppIdToOppLineItemsMap.containsKey(newItem.OpportunityId)){
                                oppIdToOppLineItemsMap.get(newItem.OpportunityId).add(newItem);
                            }else{
                                oppIdToOppLineItemsMap.put(newItem.OpportunityId,new List<OpportunityLineItem>{newItem});
                            }
                        }
                    }
                }
            }
        }
        system.debug('productNameToEBCountMap---->>>>>>'+productNameToEBCountMap);
        system.debug('crowdCompassProductKeyToCCMobileAppCountMap---->>>>>>'+crowdCompassProductKeyToCCMobileAppCountMap);
        return !productNameToEBCountMap.isEmpty() || (!crowdCompassProductKeyToCCMobileAppCountMap.isEmpty() && createMobileApp);       
    }
    
    public override void doAction(){
        // set the trigger flag to avoid recursion
        this.markRun();
        
        Professional_Services_Project__c PSPRec;
        PSPToBeInsertedList = new List<Professional_Services_Project__c>();
        PSPToBeUpdatedList = new List<Professional_Services_Project__c>(); 
        pspUpdateMap = new Map<Id,Professional_Services_Project__c>();
        NameToHrsPendingMap = new Map<String,EBProjectStageToPendingHrsSetting__c>();          
        
        // reconcile event builder products
        if(!productNameToEBCountMap.isEmpty()) reconcileEventBuilderProductMap();
        
        List<Opportunity> oppList;     
        for(Opportunity opp : (List<Opportunity>)this.triggerMap.values()){
            if(opp.CloseDate.year() == currentYear){
                accIdSet.add(opp.AccountId);
                oppIdToOppMap.put(opp.Id, opp);                    
                // prepare account Id to List of Opporunities.
                if(accIdToOpptsMap.containsKey(opp.AccountId)){
                    accIdToOpptsMap.get(opp.AccountId).add(opp);                    
                }else{
                    accIdToOpptsMap.put(opp.AccountId, new List<Opportunity>{opp});
                }
            }
        }
        // Check if the associated account is ARA account.
        for(Account acc : [Select Id,Active_ARA__c,(Select Id,Status__c from ARAs__r) from Account where Id IN :accIdSet]){
            if(acc.ARAs__r != null && acc.ARAs__r.Size() > 0 ){                    
                if(acc.Active_ARA__c){
                    accIdToARAFlagMap.put(acc.Id,true);    
                }else{
                    accIdToARAFlagMap.put(acc.Id,false);  
                }
            }
        }
        
        // collection declaration
        Map<Integer,Professional_Services_Project__c> currentYearToPSPMap;        
        for(Professional_Services_Project__c PSP : [Select Id,Account__c,Account__r.EventCenter_Account_URL__c,Account__r.Service_Tier__c ,Account__r.Name,PSP_Year__c,of_EB__c,of_CC_Mobile_App__c,of_CC_Mobile_App_Used__c,Contact__c,Event_Builder__c from Professional_Services_Project__c where Account__c IN :accIdSet]){
            // instantiate Map
            currentYearToPSPMap = new Map<Integer,Professional_Services_Project__c>();
            if(accIdToPSPsMap.containsKey(PSP.Account__c)){
                currentYearToPSPMap = accIdToPSPsMap.get(PSP.Account__c);
                currentYearToPSPMap.put(Integer.valueOf(PSP.PSP_Year__c), PSP);
                accIdToPSPsMap.put(PSP.Account__c, currentYearToPSPMap); 
            }else{
                // prepare a Map with Year as a Key.
                currentYearToPSPMap.put(Integer.valueOf(PSP.PSP_Year__c), PSP);
                accIdToPSPsMap.put(PSP.Account__c, currentYearToPSPMap);
            }
        }
        
        for(Id accId : accIdSet){ 
            // create new PSP record check.
            if(accIdToPSPsMap.isEmpty() || (accIdToPSPsMap != null && accIdToPSPsMap.get(accId) != null && !accIdToPSPsMap.get(accId).containsKey(currentYear))){
                newPSPAccountSet.add(accId);
            }else{
                // add new Account ID in the Set Based on the EB and CC Automation. 
                if(executeEBAutomationWorkFlow){
                    newEBAccountSet.add(accId);
                }
                if(executeCCAutomationWorkFlow){
                    newCCAccountSet.add(accId);
                }
            }                
        } 
        
        // get the product mapping to populate the project type and Complexity. 
        for(EB_Project_Products_Mapping__c prodMapping : [Select Id,Name,EB_Project_Type__c,EB_Project_Complexity__c from EB_Project_Products_Mapping__c]){
            prodNameToProdMappingMap.put(prodMapping.Name, prodMapping);
        }
        // get the Default pending Hours from the custom setting.
        for(EBProjectStageToPendingHrsSetting__c rec :EBProjectStageToPendingHrsSetting__c.getAll().Values()){
            NameToHrsPendingMap.put(rec.Name, rec);
        }      
        // Calculate EB Count for PSP Records.
        for(Id accId : accIdSet){
            Integer ofEB = 0;  
            Integer ofCCMobileApp = 0;
            for(Opportunity opp: accIdToOpptsMap.get(accId)){
                for(OpportunityLineItem oppLineItem : oppIdToOppLineItemsMap.get(opp.Id)){
                    if(oppLineItem.Quantity != null){
                        if(oppLineItem.Product2.Name.contains('Event Builder')){
                            ofEB += Integer.valueOf(oppLineItem.Quantity); 
                        }else if(oppLineItem.Product2.Family == 'CrowdCompass' && oppLineItem.Product2.Name.contains('App Build')){
                            ofCCMobileApp += Integer.valueOf(oppLineItem.Quantity);
                        }                        
                    }                    
                }
            }
            if(ofEB != 0) accIdToEBCountMap.put(accId, ofEB);
            if(ofCCMobileApp != 0) accIdToCCMobileAppCountMap.put(accId, ofCCMobileApp);            
        } 
        
        // create a list for inserting new PSP Records with EB Count & Account name.
        for(Id accId : newPSPAccountSet){
            PSPRec = new Professional_Services_Project__c();
            PSPRec.Account__c = accId;
            if(executeEBAutomationWorkFlow) PSPRec.of_EB__c = accIdToEBCountMap.get(accId);
            if(executeCCAutomationWorkFlow) PSPRec.of_CC_Mobile_App__c = accIdToCCMobileAppCountMap.get(accId);            
            PSPToBeInsertedList.add(PSPRec);
        }
        
        if(!PSPToBeInsertedList.isEmpty()){
            insert PSPToBeInsertedList;
            // call method to create new EB Project Records.
            if(executeEBAutomationWorkFlow) createNewEBProjects(PSPToBeInsertedList);
            if(executeCCAutomationWorkFlow) createNewCCMobileApps(PSPToBeInsertedList);
        }
        
        if(executeEBAutomationWorkFlow){
            // updates existing PSP record with new EB Count
            for(Id accId : newEBAccountSet){
                if(accIdToPSPsMap != null && accIdToPSPsMap.get(accId) != null && accIdToPSPsMap.get(accId).containsKey(currentYear)){
                    if(accIdToPSPsMap.get(accId).get(currentYear).of_EB__c != null){
                        if(pspUpdateMap.containsKey(accIdToPSPsMap.get(accId).get(currentYear).Id)){
                            pspUpdateMap.get(accIdToPSPsMap.get(accId).get(currentYear).Id).of_EB__c += accIdToEBCountMap.get(accId);
                            pspUpdateMap.put(accIdToPSPsMap.get(accId).get(currentYear).Id, pspUpdateMap.get(accIdToPSPsMap.get(accId).get(currentYear).Id));
                        }else{
                            accIdToPSPsMap.get(accId).get(currentYear).of_EB__c = accIdToEBCountMap.get(accId);
                            pspUpdateMap.put(accIdToPSPsMap.get(accId).get(currentYear).Id, accIdToPSPsMap.get(accId).get(currentYear));
                        }
                        //accIdToPSPsMap.get(accId).get(currentYear).of_EB__c += accIdToEBCountMap.get(accId);
                        //PSPToBeUpdatedList.add(accIdToPSPsMap.get(accId).get(currentYear));
                    }else{
                        accIdToPSPsMap.get(accId).get(currentYear).of_EB__c = accIdToEBCountMap.get(accId);
                        pspUpdateMap.put(accIdToPSPsMap.get(accId).get(currentYear).Id, accIdToPSPsMap.get(accId).get(currentYear));
                        //PSPToBeUpdatedList.add(accIdToPSPsMap.get(accId).get(currentYear));
                    }                
                }            
            } 
        }
        
        if(executeCCAutomationWorkFlow){
            // updates existing PSP record with new CC Mobile App Count
            for(Id accId : newCCAccountSet){
                if(accIdToCCMobileAppCountMap.containsKey(accId) && accIdToPSPsMap != null && accIdToPSPsMap.get(accId) != null && accIdToPSPsMap.get(accId).containsKey(currentYear)){
                    if(accIdToPSPsMap.get(accId).get(currentYear).of_CC_Mobile_App__c != null){
                        if(pspUpdateMap.containsKey(accIdToPSPsMap.get(accId).get(currentYear).Id)){
                            pspUpdateMap.get(accIdToPSPsMap.get(accId).get(currentYear).Id).of_CC_Mobile_App__c += accIdToEBCountMap.get(accId);
                            pspUpdateMap.put(accIdToPSPsMap.get(accId).get(currentYear).Id, pspUpdateMap.get(accIdToPSPsMap.get(accId).get(currentYear).Id));
                        }else{
                            accIdToPSPsMap.get(accId).get(currentYear).of_CC_Mobile_App__c = accIdToEBCountMap.get(accId);
                            pspUpdateMap.put(accIdToPSPsMap.get(accId).get(currentYear).Id, accIdToPSPsMap.get(accId).get(currentYear));
                        }
                       // accIdToPSPsMap.get(accId).get(currentYear).of_CC_Mobile_App__c += accIdToCCMobileAppCountMap.get(accId);
                       // PSPToBeUpdatedList.add(accIdToPSPsMap.get(accId).get(currentYear));
                    }else{
                        accIdToPSPsMap.get(accId).get(currentYear).of_CC_Mobile_App__c = accIdToCCMobileAppCountMap.get(accId);
                        pspUpdateMap.put(accIdToPSPsMap.get(accId).get(currentYear).Id, accIdToPSPsMap.get(accId).get(currentYear));
                        //PSPToBeUpdatedList.add(accIdToPSPsMap.get(accId).get(currentYear));
                    }                
                }         
            } 
        }
        
        if(!pspUpdateMap.isEmpty()){
            update pspUpdateMap.values();
            // call method to create new EB Project OR CC Mobile App Records.
            if(executeEBAutomationWorkFlow) createNewEBProjects(pspUpdateMap.values());
            if(executeCCAutomationWorkFlow) createNewCCMobileApps(pspUpdateMap.values());
        }
    }
    
    public void createNewEBProjects(List<Professional_Services_Project__c> PSPList){    
        // create EBSB Project record.
        EB_SB_Builder__c ebsbObj;
        
        for(Professional_Services_Project__c PSP : PSPList){
            for(String prodName :productNameToEBCountMap.keySet()){
                for(Integer i=0; i < Integer.valueOf(productNameToEBCountMap.get(prodName)); i++){
                    ebsbObj = new EB_SB_Builder__c();
                    ebsbObj.PSP_ID__c = PSP.Id;
                    ebsbObj.Contact__c = accIdToOpptsMap.get(PSP.Account__c)[0].Contact_Associated__c;
                    ebsbObj.Opportunity__c = accIdToOpptsMap.get(PSP.Account__c)[0].Id;
                    ebsbObj.AccountCustom__c = PSP.Account__c;                 
                    ebsbObj.Project__c = 'Event Builder';
                    ebsbObj.OpportunityLineItemID__c = productNameToOppLineItemId.get(prodName);
                    ebsbObj.Project_Status_del__c = 'Yet To Start';
                    if(accIdToARAFlagMap.containsKey(PSP.Account__c)){
                        if(accIdToARAFlagMap.get(PSP.Account__c)){
                            ebsbObj.Project_Type_del__c = 'ARA - Active';
                        }else{
                            ebsbObj.Project_Type_del__c = 'ARA - Inactive';   
                        }
                    }else{
                        ebsbObj.Project_Type_del__c = prodNameToProdMappingMap.get(prodName).EB_Project_Type__c;                        
                    }
                    ebsbObj.Project_Stage__c = 'Information Received';
                    ebsbObj.Event_Title__c = '';
                    ebsbObj.Project_Complexity__c = prodNameToProdMappingMap.get(prodName).EB_Project_Complexity__c;                   
                    if(ebsbObj.Project_Complexity__c == '1-Simple' && NameToHrsPendingMap != null && NameToHrsPendingMap.containsKey(ebsbObj.Project_Stage__c)){
                        ebsbObj.Hrs_Pending_for_Completion__c = NameToHrsPendingMap.get(ebsbObj.Project_Stage__c).SimplePendingHrs__c;
                    }else if(ebsbObj.Project_Complexity__c == '2-Medium' && NameToHrsPendingMap != null && NameToHrsPendingMap.containsKey(ebsbObj.Project_Stage__c)){
                        ebsbObj.Hrs_Pending_for_Completion__c = NameToHrsPendingMap.get(ebsbObj.Project_Stage__c).MediumPendingHrs__c;
                    }else if(ebsbObj.Project_Complexity__c == '3-Advanced' && NameToHrsPendingMap != null && NameToHrsPendingMap.containsKey(ebsbObj.Project_Stage__c)){
                        ebsbObj.Hrs_Pending_for_Completion__c = NameToHrsPendingMap.get(ebsbObj.Project_Stage__c).AdvancedPendingHrs__c;
                    }else if(ebsbObj.Project_Complexity__c == '4-Complex' && NameToHrsPendingMap != null && NameToHrsPendingMap.containsKey(ebsbObj.Project_Stage__c)){
                        ebsbObj.Hrs_Pending_for_Completion__c = NameToHrsPendingMap.get(ebsbObj.Project_Stage__c).ComplexPendingHrs__c;
                    }   
                    EBSBToBeInsertedList.add(ebsbObj);
                }
            }
        } 
    }
    
    // below method creates Mobile App records under the current year PSP.
    public void createNewCCMobileApps(List<Professional_Services_Project__c> PSPs){
        // create Mobile App Object
        Mobile_Card__c mobileCardObj;
        String crowdCompassProductComplexity = '';
        for(Professional_Services_Project__c pspObj : PSPs){
            Boolean onboardingFlagSet = false;
            for(String ccProductKey : crowdCompassProductKeyToCCMobileAppCountMap.keySet()){
                // get the Mobile App Complexity Level from the ccProductKey, will be used later.
                crowdCompassProductComplexity = ccProductKey.subStringAfter(':');
                for(Integer i=0; i < Integer.valueOf(crowdCompassProductKeyToCCMobileAppCountMap.get(ccProductKey)); i++){
                    mobileCardObj = new Mobile_Card__c();
                    mobileCardObj.PSP__c = pspObj.Id;
                    mobileCardObj.Primary_Contact__c = accIdToOpptsMap.get(pspObj.Account__c)[0].Contact_Associated__c;
                    mobileCardObj.Opportunity__c = accIdToOpptsMap.get(pspObj.Account__c)[0].Id;
                    mobileCardObj.EventCenter_Account_URL__c = pspObj.Account__r.EventCenter_Account_URL__c;
                    mobileCardObj.Contract_Account_New__c = pspObj.Account__c;
                    mobileCardObj.App_Version__c = Label.Mobile_App_Version;
                    mobileCardObj.App_Event__c = Label.Mobile_App_Event_Name;
                    mobileCardObj.Complexity__c = crowdCompassProductComplexity;
                    mobileCardObj.Stage__c = Label.Mobile_App_Stage_Value;
                    mobileCardObj.Auto_Assignment_Date__c = DateTime.now();
                    mobileCardObj.Complexity_Level__c = crowdCompassProductComplexity == 'Standard' ? 'Low' : (crowdCompassProductComplexity == 'Medium'? 'Medium' : (crowdCompassProductComplexity == 'Advanced'? 'High' : 'High'));
                    mobileCardObj.OpportunityLineItemID__c = productNameToOppLineItemId.get(ccProductKey);                    
                    mobileCardObj.RecordTypeId = Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByDeveloperName().get(Label.Mobile_App_RT_Label_Name).getRecordTypeId();
                    mobileCardObj.App_Name__c = pspObj.Account__r.Name;
                    if(!onboardingFlagSet && accIdToOpptsMap.get(pspObj.Account__c)[0].NBB_Renewal__c == 'NBB'){
                        onboardingFlagSet = true;
                        mobileCardObj.Onboarding__c = true;
                        mobileCardObj.Name = 'Pending Details – '+pspObj.Account__r.Service_Tier__c+' – 1 onboarding events '+currentYear;                    
                    }else{
                        if(accIdToOpptsMap.get(pspObj.Account__c)[0].NBB_Renewal__c == 'NBB'){
                            Integer count = (crowdCompassProductKeyToCCMobileAppCountMap.get(ccProductKey)-1) != 0 ? (crowdCompassProductKeyToCCMobileAppCountMap.get(ccProductKey)-1) : 1;
                            mobileCardObj.Name = 'Pending Details – '+pspObj.Account__r.Service_Tier__c+' – '+count+'  non-onboarding events '+currentYear; 
                        }else
                            mobileCardObj.Name = 'Pending Details – '+pspObj.Account__r.Service_Tier__c+' – '+crowdCompassProductKeyToCCMobileAppCountMap.get(ccProductKey)+'  non-onboarding events '+currentYear;                    
                    }
                    mobileAppsToBeInsertedList.add(mobileCardObj);
                }
            }
        }            
        // below block is executed for EB SB Automation
        if(!EBSBToBeInsertedList.isEmpty()){
           insert EBSBToBeInsertedList;
            // send email notification to customer.
           assignToEBLeadership(EBSBToBeInsertedList);           
        }
        // below block is executed for CC Automation        
        if(!mobileAppsToBeInsertedList.isEmpty()){
            if(!EBSBToBeInsertedList.isEmpty()){
                // convert to future to avoid SOQL 101 error, this code will be executed only when the opportunity would have both Event and CC products
                insertMobileApps(JSON.serialize(mobileAppsToBeInsertedList));
            }else{
                insert mobileAppsToBeInsertedList;
            } 
        }        
    }  
    
    Boolean sendExpressEmail = false;
    Boolean sendScopeEmail = false;
    Boolean expressEmailSent = false;
    Boolean scopeEmailSent = false;
    Integer sendScopeEmailLimit = 0;
    Integer sendExpressEmailLimit = 0;        
    
    // updates EB SB Project Owner to Event Builder Leadership
    private void assignToEBLeadership(List<EB_SB_Builder__c> EBProjectList){
        for(EB_SB_Builder__c ebproject : EBProjectList){
            if(ebproject.Project_Type_del__c != 'Enterprise Project' && ebproject.Project_Type_del__c != 'Event Quarterback Project'){
                if(ebproject.Project_Type_del__c == 'Event Builder - Express'){
                    sendExpressEmail = true;                
                }else{
                    sendScopeEmail = true;                
                }               
                if(sendExpressEmail && !expressEmailSent){
                    EBSurveyNotificationEmail.sendCustomEmail(ebproject.Id);
                    expressEmailSent = true;                
                }else if(sendScopeEmail && !scopeEmailSent){
                    EBSurveyNotificationEmail.sendCustomEmail(ebproject.Id);
                    scopeEmailSent = true;
                }    
            }  
            // Assign to Queue. 
            ebproject.OwnerId = eventBuilderLeadersQueueId;
        }    
        if(!EBProjectList.isEmpty()) update EBProjectList;
    }
    
    @future
    private static void insertMobileApps(String mobileJSON){
        List<Mobile_Card__c> mobileApps = (List<Mobile_Card__c>)JSON.deserialize(mobileJSON, List<Mobile_Card__c>.class);
        insert mobileApps;
    }
    
    private void reconcileEventBuilderProductMap(){
        // get all the products in the local map for processing
        Map<String,Integer> storedProductMap = productNameToEBCountMap;
        // event builder SKU names
        String eventBuilderSimpleProductName = Label.Event_Builder_Simple_Product_Label_Name;
        String eventBuilderMediumProductName = Label.Event_Builder_Medium_Product_Label_Name;
        String eventBuilderAdvancedProductName = Label.Event_Builder_Advanced_Product_Label_Name;
        String eventBuilderComplexProductName = Label.Event_Builder_Complex_Product_Label_Name;
        // premium event builder SKU names
        String eventBuilderPremiumSimpleProductName = Label.Event_Builder_Premium_Simple_Product_Label_Name;
        String eventBuilderPremiumMediumProductName = Label.Event_Builder_Premium_Medium_Product_Label_Name;
        String eventBuilderPremiumAdvancedProductName = Label.Event_Builder_Premium_Advanced_Product_Label_Name;
        String eventBuilderPremiumComplexProductName = Label.Event_Builder_Premium_Complex_Product_Label_Name;
        // rush event builder SKU names
        String eventBuilderSimpleRushProductName = Label.Event_Builder_Simple_Rush_Product_Label_Name;
        String eventBuilderMediumRushProductName = Label.Event_Builder_Medium_Rush_Product_Label_Name;
        String eventBuilderAdvancedRushProductName = Label.Event_Builder_Advanced_Rush_Product_Label_Name;
        String eventBuilderComplexRushProductName = Label.Event_Builder_Complex_Rush_Product_Label_Name;
        
        // local variable declaration
        Integer simpleProductCount,mediumProductCount,advancedProductCount,complexProductCount;
        Integer simpleRushProductCount,mediumRushProductCount,advancedRushProductCount,complexRushProductCount;
        
        // start processing map and update the product names with fresh quantities
        for(String productName : storedProductMap.keySet()){
            simpleProductCount = 0;
            simpleRushProductCount = 0;
            mediumProductCount = 0;
            mediumRushProductCount = 0;
            advancedProductCount = 0;
            advancedRushProductCount = 0;
            complexProductCount = 0;
            complexRushProductCount = 0;
            
            if(productName.equals(eventBuilderSimpleRushProductName)){
                simpleRushProductCount = storedProductMap.get(productName);
                // update new medium product count if there is a existing record in the map
                if(productNameToEBCountMap.containsKey(eventBuilderSimpleProductName)){
                    simpleProductCount = storedProductMap.get(eventBuilderSimpleProductName);
                    productNameToEBCountMap.put(eventBuilderSimpleProductName, simpleProductCount - simpleRushProductCount );
                }else if(productNameToEBCountMap.containsKey(eventBuilderPremiumSimpleProductName)){
                    simpleProductCount = storedProductMap.get(eventBuilderPremiumSimpleProductName);
                    productNameToEBCountMap.put(eventBuilderPremiumSimpleProductName, simpleProductCount - simpleRushProductCount );
                }                
            }else if(productName.equals(eventBuilderMediumRushProductName)){
                mediumRushProductCount = storedProductMap.get(productName);
                // update new simple product count if there is a existing record in the map
                if(productNameToEBCountMap.containsKey(eventBuilderMediumProductName)){
                    mediumProductCount = storedProductMap.get(eventBuilderMediumProductName);
                    productNameToEBCountMap.put(eventBuilderMediumProductName, mediumProductCount - mediumRushProductCount);
                }else if(productNameToEBCountMap.containsKey(eventBuilderPremiumMediumProductName)){
                    mediumProductCount = storedProductMap.get(eventBuilderPremiumMediumProductName);
                    productNameToEBCountMap.put(eventBuilderPremiumMediumProductName, mediumProductCount - mediumRushProductCount );
                }  
            }else if(productName.equals(eventBuilderAdvancedRushProductName)){
                advancedRushProductCount = storedProductMap.get(productName);
                // update new advance product count if there is a existing record in the map
                if(productNameToEBCountMap.containsKey(eventBuilderAdvancedProductName)){
                    advancedProductCount = storedProductMap.get(eventBuilderAdvancedProductName);                
                    productNameToEBCountMap.put(eventBuilderAdvancedProductName, advancedProductCount - advancedRushProductCount);
                }else if(productNameToEBCountMap.containsKey(eventBuilderPremiumAdvancedProductName)){
                    advancedProductCount = storedProductMap.get(eventBuilderPremiumAdvancedProductName);
                    productNameToEBCountMap.put(eventBuilderPremiumAdvancedProductName, advancedProductCount - advancedRushProductCount );
                }  
            }else if(productName.equals(eventBuilderComplexRushProductName)){
                complexRushProductCount = storedProductMap.get(productName);
                // update new complex product count if there is a existing record in the map
                if(productNameToEBCountMap.containsKey(eventBuilderComplexProductName)){
                    complexProductCount = storedProductMap.get(eventBuilderComplexProductName);
                    productNameToEBCountMap.put(eventBuilderComplexProductName, complexProductCount - complexRushProductCount);
                }else if(productNameToEBCountMap.containsKey(eventBuilderPremiumComplexProductName)){
                    complexProductCount = storedProductMap.get(eventBuilderPremiumComplexProductName);
                    productNameToEBCountMap.put(eventBuilderPremiumComplexProductName, complexProductCount - simpleRushProductCount );
                }  
            }
        }
    }
}