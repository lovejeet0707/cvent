/**
* Author : Sandeep Kumar
* Date : 18 May, 2017
* Description : CreateEBProject_ContExt class fullfills below functionalities,
* 1) This class is called from a custom button (Create EB Project) provided on the Opportunity standard page for EB Users. 
* 2) Show all the products asscoiated with opportunity and provides an option for user to easily create PSP ID, EB SB Projects etc with just one click.
* This functionality was provided to EB team so that they can still create eb projects on fly and this button is of no use for opportunities which are created after the automation went live.
* As the PSP Id and EB SB projects are automatically created on adding products.
* VF Page - CreateEBProject_Page
* Test Class - CreateEBProject_ContExt_Test
*/
public without sharing class CreateEBProject_ContExt {
    public Integer currentYear;
    public Opportunity opp{get;set;}    
    public String loggedUser{get;set;}
    public Boolean showProductsPanel{get;set;}
    public Boolean showAccountError{get;set;}
    public Boolean showNoProductSelectedError{get;set;}
    public List<WrapOppLineItem> WrapOppLineItemList{get;set;}
    public Set<String> oppProductSet;
    public Set<Id> newPSPAccountSet;
    public Set<Id> newEBAccountSet;
    public Map<Id,Boolean> accIdToARAFlagMap;    
    public Map<Id,Integer> accIdToEBCountMap;
    public Map<Id,Opportunity> oppIdToOppMap;
    public Map<String,Id> productNameToOppLineItemId;    
    public Map<String,Integer> productNameToEBCountMap;    
    public List<EB_SB_Builder__c> EBSBToBeInsertedList;    
    public List<Professional_Services_Project__c> PSPToBeInsertedList;
    public List<Professional_Services_Project__c> PSPToBeUpdatedList;
    public Map<String,EBProjectStageToPendingHrsSetting__c> NameToHrsPendingMap; 
    public Map<String,EB_Project_Products_Mapping__c> prodNameToProdMappingMap;
    public Map<Id,Map<Integer,Professional_Services_Project__c>> accIdToPSPsMap;
    public final static Id eventBuilderLeadersQueueId = Label.Event_Builder_Leaders_Queue_Id;
    
    //Wrapper for OppLineItems
    public class WrapOppLineItem{
        public Id id{get;set;}
        public Boolean selected{get;set;}
        public Integer noOfEBProjToCreate{get;set;}
        public OpportunityLineItem oppLineItem{get;set;}
        public WrapOppLineItem(OpportunityLineItem oppLineItem,Boolean selected,Integer noOfEBProjToCreate){
            this.id = oppLineItem.Id;
            this.selected = selected;
            this.oppLineItem = oppLineItem;
            this.noOfEBProjToCreate = noOfEBProjToCreate;
        }
    }
    
    public CreateEBProject_ContExt(ApexPages.StandardController stdController){
        loggedUser = UserInfo.getName();
        currentYear = System.today().year();
        oppProductSet = new Set<String>();
        accIdToEBCountMap = new Map<Id,Integer>();
        newEBAccountSet = new Set<Id>();
        newPSPAccountSet = new Set<Id>();
        oppIdToOppMap = new Map<Id,Opportunity>();        
        accIdToARAFlagMap = new Map<Id,Boolean>();
        prodNameToProdMappingMap = new Map<String,EB_Project_Products_Mapping__c>();
        productNameToEBCountMap = new Map<String,Integer>();         
        NameToHrsPendingMap = new Map<String,EBProjectStageToPendingHrsSetting__c>(); 
        WrapOppLineItemList = new List<WrapOppLineItem>();
        productNameToOppLineItemId = new Map<String,Id>();        
        opp = (Opportunity)stdController.getRecord();
        
        Opportunity[] oppArray = [select id,AccountId,Contact_Associated__c from Opportunity where id =:opp.id];
        if(oppArray != null && oppArray.size() > 0){
            this.opp = oppArray[0];
            if(this.opp.AccountId != null){
                oppIdToOppMap.put(this.opp.AccountId, this.opp);
            }else{
                showAccountError = true;
            }               
        }            
        
        for(OpportunityLineItem lineItem: [select Id,Product2.Name,Quantity From OpportunityLineItem where OpportunityId=:opp.id]){
            if(lineItem.Product2.Name.contains('Event Builder') && !oppProductSet.contains(lineItem.Product2.Name) && lineItem.Product2.Name != 'Event Builder Package'){
                // Stores the Product Name to OpportunityLineItem Id.
                productNameToOppLineItemId.put(lineItem.Product2.Name, lineItem.Id);                    
                oppProductSet.add(lineItem.Product2.Name);
                showProductsPanel = true;
                WrapOppLineItemList.add(new WrapOppLineItem(lineItem,false,1));
            }
        }
    }
    
    public pageReference showAllProducts(){
        for(OpportunityLineItem lineItem: [select Id,Product2.Name,Quantity From OpportunityLineItem where Product2.Name like '%Event Builder%']){
            if(lineItem.Product2.Name.contains('Event Builder') && lineItem.Product2.Name != 'Event Builder Package' && !oppProductSet.contains(lineItem.Product2.Name)){
                oppProductSet.add(lineItem.Product2.Name);
                showProductsPanel = true;
                WrapOppLineItemList.add(new WrapOppLineItem(lineItem,false,1));
            }
        }
        return null;
    }
    
    public pageReference CreateProjects(){
        EBSBToBeInsertedList = new List<EB_SB_Builder__c>();
        accIdToPSPsMap = new Map<Id,Map<Integer,Professional_Services_Project__c>>();         
        PSPToBeInsertedList = new List<Professional_Services_Project__c>();
        PSPToBeUpdatedList = new List<Professional_Services_Project__c>();
        // Get the product mapping to populate the project type and Complexity. 
        for(EB_Project_Products_Mapping__c prodMapping : [Select Id,Name,EB_Project_Type__c,EB_Project_Complexity__c from EB_Project_Products_Mapping__c]){
            prodNameToProdMappingMap.put(prodMapping.Name, prodMapping);
        }
        
        // Get the Default pending Hours from the custom setting.
        for(EBProjectStageToPendingHrsSetting__c rec :EBProjectStageToPendingHrsSetting__c.getAll().Values()){
            NameToHrsPendingMap.put(rec.Name, rec);
        }
        
        Boolean noProductSeleted = true;
        showNoProductSelectedError = false;
        
        for(WrapOppLineItem wrapItem :WrapOppLineItemList){
            // Prepare a map that stores Product Name to EB Project Count.            
            if(wrapItem.selected){
                noProductSeleted = false;
                productNameToEBCountMap.put(wrapItem.oppLineItem.Product2.Name, wrapItem.noOfEBProjToCreate);   
            }                
        }
        
        if(noProductSeleted){
            showNoProductSelectedError = true;
        }
        
        if(!noProductSeleted){            
            // Calculate the no of EB projects to be created.
            Integer noOfEBProj = 0;
            for(String prodName : productNameToEBCountMap.keySet()){
                noOfEBProj += productNameToEBCountMap.get(prodName);        
            }
            // Stores number of EB projects with Account.
            accIdToEBCountMap.put(opp.AccountId,noOfEBProj);
            
            // Check if the associated account is ARA account.
            Account acc = [Select Id,Active_ARA__c,(Select Id,Status__c from ARAs__r) from Account where Id =:opp.AccountId];
            if(acc.ARAs__r != null && acc.ARAs__r.Size() > 0 ){                    
                // Prepare Opportunity Id to List of Opp Line Items.
                if(acc.Active_ARA__c){
                    accIdToARAFlagMap.put(acc.Id,true);    
                }else{
                    accIdToARAFlagMap.put(acc.Id,false);  
                }
            }
            
            // Collection Declaration
            Map<Integer,Professional_Services_Project__c> currentYearToPSPMap;            
            for(Professional_Services_Project__c PSP :[Select Id,Account__c,PSP_Year__c,of_EB__c from Professional_Services_Project__c where Account__c =:opp.AccountId Order By PSP_Year__c DESC LIMIT 1]){
                system.debug('PSP'+PSP.PSP_Year__c);
                if(currentYear == Integer.valueOf(PSP.PSP_Year__c)){
                    //Create new EBSB record and increment the count. 
                    newEBAccountSet.add(PSP.Account__c);
                    // Prepare a Map with Year as a Key.
                    currentYearToPSPMap = new Map<Integer,Professional_Services_Project__c>();                
                    currentYearToPSPMap.put(Integer.valueOf(PSP.PSP_Year__c), PSP);  
                    accIdToPSPsMap.put(PSP.Account__c, currentYearToPSPMap);
                }
            }
            
            // Set that will store the account Id for PSP creation.
            if(!accIdToPSPsMap.containsKey(opp.AccountId)){
                newPSPAccountSet.add(opp.AccountId);
            }
                    
            Professional_Services_Project__c PSPRec;        
            // Create a list for inserting new PSP Records with EB Count & Account name.
            for(Id accId : newPSPAccountSet){
                PSPRec = new Professional_Services_Project__c();
                PSPRec.Account__c = accId;
                PSPRec.of_EB__c = accIdToEBCountMap.get(accId);
                PSPToBeInsertedList.add(PSPRec);
            }
            
            if(!PSPToBeInsertedList.isEmpty()){
               insert PSPToBeInsertedList;
                // Call method to create new EB Project Records.
               CreateNewEBProject(PSPToBeInsertedList);
            }
            
            // Updates existing PSP record with new EB count
            for(Id accId : newEBAccountSet){
                if(accIdToPSPsMap != null && accIdToPSPsMap.get(accId) != null && accIdToPSPsMap.get(accId).containsKey(currentYear)){
                    if(accIdToPSPsMap.get(accId).get(currentYear).of_EB__c != null){
                        accIdToPSPsMap.get(accId).get(currentYear).of_EB__c += 1;
                        PSPToBeUpdatedList.add(accIdToPSPsMap.get(accId).get(currentYear));
                    }else{
                        accIdToPSPsMap.get(accId).get(currentYear).of_EB__c = 1;
                        PSPToBeUpdatedList.add(accIdToPSPsMap.get(accId).get(currentYear));
                    }                
                }
            }
            if(!PSPToBeUpdatedList.isEmpty()){
                update PSPToBeUpdatedList;
                // Call method to create new EB Project Records.
                CreateNewEBProject(PSPToBeUpdatedList);
            }
            if(EBSBToBeInsertedList.size() == 1){            
                PageReference pageRefEBProjObj = new PageReference('/'+EBSBToBeInsertedList[0].Id);
                pageRefEBProjObj.setRedirect(true);
                return pageRefEBProjObj;          
            }else{
                PageReference pageRefPSPObj = new PageReference('/'+EBSBToBeInsertedList[0].PSP_ID__c);
                pageRefPSPObj.setRedirect(true);
                return pageRefPSPObj;
            }   
        }
        return null;
    }
    
    EB_SB_Builder__c EBSBRec;    
    public void CreateNewEBProject(List<Professional_Services_Project__c> newEBProjects){ 
        for(Professional_Services_Project__c PSP :newEBProjects){
            for(String prodName :productNameToEBCountMap.keySet()){
                for(Integer i=0; i<Integer.valueOf(productNameToEBCountMap.get(prodName)); i++){
                    EBSBRec = new EB_SB_Builder__c();
                    EBSBRec.PSP_ID__c = PSP.Id;
                    EBSBRec.Contact__c = oppIdToOppMap.get(PSP.Account__c).Contact_Associated__c;
                    EBSBRec.Opportunity__c = oppIdToOppMap.get(PSP.Account__c).Id;
                    EBSBRec.AccountCustom__c = PSP.Account__c;                 
                    EBSBRec.Project__c = 'Event Builder';
                    EBSBRec.Project_Status_del__c = 'Yet To Start';
                    if(accIdToARAFlagMap.containsKey(PSP.Account__c)){
                        if(accIdToARAFlagMap.get(PSP.Account__c)){
                            EBSBRec.Project_Type_del__c = 'ARA - Active';
                        }else{
                            EBSBRec.Project_Type_del__c = 'ARA - Inactive';   
                        }
                    }else{
                        EBSBRec.Project_Type_del__c = prodNameToProdMappingMap.get(prodName).EB_Project_Type__c;                        
                    }
                    EBSBRec.OpportunityLineItemID__c = productNameToOppLineItemId.get(prodName);                    
                    EBSBRec.Project_Stage__c = 'Information Received';
                    EBSBRec.Event_Title__c = '';
                    EBSBRec.Project_Complexity__c = prodNameToProdMappingMap.get(prodName).EB_Project_Complexity__c;                   
                    if(EBSBRec.Project_Complexity__c == '1-Simple' && NameToHrsPendingMap != null && NameToHrsPendingMap.containsKey(EBSBRec.Project_Stage__c)){
                        EBSBRec.Hrs_Pending_for_Completion__c = NameToHrsPendingMap.get(EBSBRec.Project_Stage__c).SimplePendingHrs__c;
                    }else if(EBSBRec.Project_Complexity__c == '2-Medium' && NameToHrsPendingMap != null && NameToHrsPendingMap.containsKey(EBSBRec.Project_Stage__c)){
                        EBSBRec.Hrs_Pending_for_Completion__c = NameToHrsPendingMap.get(EBSBRec.Project_Stage__c).MediumPendingHrs__c;
                    }else if(EBSBRec.Project_Complexity__c == '3-Advanced' && NameToHrsPendingMap != null && NameToHrsPendingMap.containsKey(EBSBRec.Project_Stage__c)){
                        EBSBRec.Hrs_Pending_for_Completion__c = NameToHrsPendingMap.get(EBSBRec.Project_Stage__c).AdvancedPendingHrs__c;
                    }else if(EBSBRec.Project_Complexity__c == '4-Complex' && NameToHrsPendingMap != null && NameToHrsPendingMap.containsKey(EBSBRec.Project_Stage__c)){
                        EBSBRec.Hrs_Pending_for_Completion__c = NameToHrsPendingMap.get(EBSBRec.Project_Stage__c).ComplexPendingHrs__c;
                    }   
                    EBSBToBeInsertedList.add(EBSBRec);
                }
            }
        }  
        if(!EBSBToBeInsertedList.isEmpty()){
            insert EBSBToBeInsertedList;
            // Serialize the list of EBSB Projects objects.
            String EBProjectListString = JSON.serialize(EBSBToBeInsertedList);
            assignToEBLeadership(EBProjectListString);           
        }                  
    }   
    
    public PageReference  back(){        
        PageReference oppPage = new ApexPages.StandardController(this.opp).view();
        oppPage.setRedirect(true);
        return oppPage;        
    }
    
    public static void assignToEBLeadership(String eBProjectsString){
        // Deserialize the list of EB_SB_Builder__c from the JSON string.
        List<EB_SB_Builder__c> EBProjectList = (List<EB_SB_Builder__c>)JSON.deserialize(eBProjectsString, List<EB_SB_Builder__c>.class);
        // List Declartion and instantiation.              
        List<EB_SB_Builder__c> updatedEBOwnerList = new List<EB_SB_Builder__c>();            
        // Assign projects to Event Builder Leaders queue.
        for(EB_SB_Builder__c ebproject : EBProjectList){
            ebproject.OwnerId = eventBuilderLeadersQueueId;
            updatedEBOwnerList.add(ebproject); 
        }    
        
        // Assign to Queue if their is no available user found.
        if(!updatedEBOwnerList.isEmpty()){
            update updatedEBOwnerList;
        }
    }
}