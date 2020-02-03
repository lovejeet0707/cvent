/**********************************************************************************************************
* Author : Sandeep Kumar
* Date : 04 Dec, 2017
* Description : AccountPlanning_ContExt class acts as controller to provide data on account planning VF page,
* It pulls data from different objects and displays it on the page.
* Project :P-001480 
* VF Page - AccountPlanning_Page
* Test Class - AccountPlanning_ContExt_Test 
*
* Last Modified By : Sandeep Kumar, Dated: 16 Jan, 2017
* Project :P-003181 
* Last Modified By : Sandeep Kumar, Dated: 07 Feb, 2017
* Project :P-003338 

* Last Modified By : Udita Dwivedi, Dated: August, 2018
* Project : P-004508
************************************************************************************************************/
public class AccountPlanning_ContExt{
    public Account acc;
    public Integer noOfOnsites {get;set;}
    public String accBuyerRole {get;set;}
    public String backOfficeSystem {get;set;}
    public String isCSRConducted {get;set;}    
    public List<ARA__c> arasList {get;set;} 
    public String contractLength {get;set;} 
    public Integer noOfLauncedEvents{get;set;}
    public String customerLargestEvent{get;set;}
    public String isAttendedCustomerEvent {get;set;}    
    public Date oppRenewableDate {get;set;}
    public Boolean growthPotential {get;set;}
    public Date firstNBBDealWithCvent {get;set;}
    public Date lastAMTouchPoint {get;set;}
    public String accBuyerRoleInfluencer {get;set;} 
    public String accBuyerRoleDecisionMaker {get;set;} 
    public Integer noOfEventsGreaterThan200 {get;set;}
    public String accBuyerRoleExecutiveSponsor {get;set;} 
    public Boolean showfirstNBBDealWithCvent {get;set;}    
    public Integer accWalletSize {get;set;}
    public Integer accLast12MonthSpent {get;set;}
    public Decimal penetrationPercent {get;set;}
    public Decimal yoyGrowth {get;set;}
    public Decimal lifeTimeGrowth {get;set;}
    public Boolean showDetailedView {get;set;}
    public Boolean showOppRenewableDate {get;set;}
    public Boolean showDetailedViewButton {get;set;}  
    public String productSoldToCustomer {get;set;}
    public String cventBusinessGoals {get;set;}
    public string accEmployeeRange {get;set;}
    
    public String integrationProducts {get;set;}
    public String isAccountHavingARAHistory {get;set;}    
    public Integer eventManagementProducts {get;set;}
    public Integer CPSRevenue{get;set;} // added by udita
    public Integer LeadCaptureRevenue{get;set;} // added by udita
    public Integer crowdCompassProducts {get;set;}
    public Integer onsiteSolutionsProducts {get;set;}
    public Integer csnProducts {get;set;}
    public String cventAccountStrategy {get;set;}
    public Integer inquisiumProducts {get;set;}
    public Map<String,List<OpportunityLineItem>> prodNameToOppLineItemMap;
    public Map<String,List<OpportunityLineItem>> prodFamilyToOppLineItemMap;
    public String accPlanningProductsLabel = Label.Account_Planning_Integration_Products;
    public String accPlanningClosedWonOpportunityLabel = Label.Account_Planning_Closed_Won_Opportunity_Stages;
    public String accPlanningClosedLostOpportunityLabel = Label.Account_Planning_Closed_Lost_Opportunity_Stages;
    public String accPlanningRenewalOpportunityLabel = Label.Account_Planning_Renewal_Opportunity_Stages;
    public Set<String> accPlanningProductSet;
    public Set<Id> contactIdSet;    
    public Set<Id> oppContractIdSet;
    public Set<Id> closedWonOppIdSet;    
    public Set<String> accPlanningRenewalOppStagesSet;    
    public Set<String> accPlanningClosedWonOppStagesSet;
    public Set<String> accPlanningClosedLostOppStagesSet;
    public List<Customer_Asset__c> cusAssetList{get;set;}
    public List<OpportunityLineItem> oppLineItemList {get;set;}
    public List<Opportunity> openOpportunitiesList {get;set;}
    public List<Customer_Success_Review__c> CustomerSuccessReviewList {get;set;}
    public List<ATI_Info__c> ATIList {get;set;} //added by udita
    public List<Contact_Role__c> buyerRoleList {get;set;}
    public final Id masterContractRecordtypeId = RecordtypeUtil.getRecordTypeIDByDevName('Contract','Master_Agreement');
    public Id accMemberId;
    public list<Selectoption> relatedAcc{get;set;}
    public String accName{get;set;}
    //added on 04/17/2018
    public Decimal contractedArr{get;set;}
    public List<Campaign> customerLiveEvents{get;set;}


    public AccountPlanning_ContExt(ApexPages.StandardController stdController){
        CPSRevenue = 0; 
        LeadCaptureRevenue= 0;
        noOfOnsites = 0;
        contractLength = '';
        accEmployeeRange ='';
        noOfEventsGreaterThan200 = 0;
        noOfLauncedEvents = 0; 
        eventManagementProducts = 0;
        crowdCompassProducts = 0;
        onsiteSolutionsProducts = 0;
        csnProducts = 0;
        inquisiumProducts = 0;
        accBuyerRole = '';
        backOfficeSystem = '';
        accBuyerRoleInfluencer = '';
        accBuyerRoleDecisionMaker = '';
        accBuyerRoleExecutiveSponsor = '';
        accWalletSize = 0;  
        isCSRConducted = 'No';        
        showDetailedView = true; // changed by udita on Chris Request
        productSoldToCustomer = '';
        integrationProducts = '';
        cventBusinessGoals = '';
        penetrationPercent = 0.0;
        accLast12MonthSpent = 0;
        growthPotential = false;
        showfirstNBBDealWithCvent = false;
        showOppRenewableDate = false;        
        showDetailedViewButton = false; // changed by udita on Chris Request
        isAttendedCustomerEvent = 'No';
        isAccountHavingARAHistory = 'No';
        closedWonOppIdSet = new Set<Id>();
        contactIdSet = new Set<Id>();
        oppContractIdSet = new Set<Id>();
        accPlanningProductSet = new Set<String>();
        accPlanningRenewalOppStagesSet = new Set<String>();
        accPlanningClosedWonOppStagesSet = new Set<String>();
        accPlanningClosedLostOppStagesSet = new Set<String>();
        prodFamilyToOppLineItemMap = new Map<String,List<OpportunityLineItem>>(); 
        prodNameToOppLineItemMap = new Map<String,List<OpportunityLineItem>>();   
        oppLineItemList = new List<OpportunityLineItem> ();
        buyerRoleList = new List<Contact_Role__c>();
        cusAssetList = new List<Customer_Asset__c>();
        arasList = new List<ARA__c>();
        openOpportunitiesList = new List<Opportunity>();
        CustomerSuccessReviewList = new List<Customer_Success_Review__c>();
        ATIList  = new List<ATI_Info__c>();
        customerLiveEvents=new List<Campaign>();
        
        // Get the record using standard controller method.
        this.acc = (Account)stdController.getRecord();
        // get ultimate parent id from url : udita
        
        //added by udita  starts
        relatedAcc = new list<Selectoption>();
        //added by udita ends   
        
        // Get all Integration relation Products
        accPlanningProductSet.addAll(accPlanningProductsLabel.split(','));   
        // Get all Closed Won Opportunity Stages
        accPlanningClosedWonOppStagesSet.addAll(accPlanningClosedWonOpportunityLabel.split(','));
        // Get all Closed Lost Opportunity Stages
        accPlanningClosedLostOppStagesSet.addAll(accPlanningClosedLostOpportunityLabel.split(','));
        // Get all Renewal Opportunity Stages
        accPlanningRenewalOppStagesSet.addAll(accPlanningRenewalOpportunityLabel.split(','));
        
        //added on 04/17/2018 - Exclude these stages
        accPlanningClosedLostOppStagesSet.add('Tract');
        accPlanningClosedLostOppStagesSet.add('Legacy Open');
        
        //Get Customer Live Events
        for(Campaign camp : [Select Name,Project__c,StartDate/*Type,Status*/ From Campaign Where ID IN (Select CampaignId From CampaignMember Where Contact.AccountId =:acc.Id and Status='Attended' ) and Type = 'Live Event']){
            customerLiveEvents.add(camp);
        }
        
        //Get Account Manager to populate to filter ActivityHistories and populate lastAMTouchPoint
        for( AccountTeamMember acMember : [ Select UserId From AccountTeamMember Where AccountId =:acc.Id and ( TeamMemberRole like 'AM%' OR  TeamMemberRole = 'Multi-Product')  Limit 1]){
            accMemberId=acMember.UserId;
        }


        // Check if the account is having ARA history.
        for(Account acc : [Select Id,Share_of_Wallet_Client__c ,of_Employees_Range_Parent__c,Account_Assignment_Value__c,Back_Office_System__c,Wallet_Size_Parent__c,Account_Planning_Strategy__c,Last_12_month_spent__c,Share_of_Wallet__c,Active_ARA__c,/*Total_of_Events_Year__c*/Registrations_Last_12_Months__c,Account_Planning_Business_Goals__c,(Select Id,Name,Account__c,ARA_Category__c,Relevant_Account_History_Previous_Issue__c,Product_Line_Impacted__c,Severity_Level__c,Primary_Contact__c,Renewal_Opportunity_Value__c,Current_Account_ARR__c,Status__c,Secondary_ARA_Category__c,CreatedBy.Name from ARAs__r),(SELECT Id,LastModifiedDate,Subject FROM ActivityHistories Where LastModifiedById=:accMemberId Order By LastModifiedDate DESC LIMIT 1) from Account where Id =:acc.Id]){
            // Populate ARA History
            if(acc.ARAs__r != null && acc.ARAs__r.Size() > 0 ){                    
                this.isAccountHavingARAHistory = 'Yes';
                for(ARA__c ara : acc.ARAs__r){
                    arasList.add(ara);                                        
                }                
            }
            // Populate Growth Potential
            if(acc.of_Employees_Range_Parent__c > '1000' && acc.Share_of_Wallet__c > 100000){
                this.growthPotential = true;
            }
            // Populate Wallet Size
            if(acc.Wallet_Size_Parent__c != null){
                this.accWalletSize = Integer.valueOf(acc.Wallet_Size_Parent__c);
            }
            // # of Employees Range (Parent): added by Udita 
             if(acc.of_Employees_Range_Parent__c!= null){
                this.accEmployeeRange = acc.of_Employees_Range_Parent__c;
            }
            // Calculate Penetration
            if(acc.Account_Assignment_Value__c != null){
                this.accLast12MonthSpent = Integer.valueOf(acc.Account_Assignment_Value__c);
                if(acc.Wallet_Size_Parent__c != null){
                    this.penetrationPercent = ((acc.Account_Assignment_Value__c/acc.Wallet_Size_Parent__c)*100).setScale(2);
                }                
            }
            if(acc.Account_Planning_Business_Goals__c != null){
                this.cventBusinessGoals = acc.Account_Planning_Business_Goals__c;
            }
            if(acc.Account_Planning_Strategy__c != null){
                this.cventAccountStrategy = acc.Account_Planning_Strategy__c;
            }
          /*  if(acc.Total_of_Events_Year__c != null){
                this.noOfLauncedEvents = Integer.valueOf(acc.Total_of_Events_Year__c);
            }*/
            if(acc.Back_Office_System__c != null){
                this.backOfficeSystem = acc.Back_Office_System__c;
            }
            if(acc.Share_of_Wallet_Client__c!=null){
                this.contractedArr = acc.Share_of_Wallet_Client__c;
            }
            
            system.debug('acc.ActivityHistories'+acc.ActivityHistories.Size());
            // Get the Task and Events from the Activity History Object 
            for(ActivityHistory actHistoryObj : acc.ActivityHistories){                
                if(lastAMTouchPoint == null){
                    this.lastAMTouchPoint = Date.valueOf(actHistoryObj.LastModifiedDate);
                }
            }

           
        }
        
        // Get all contacts asscoaited with the Account
        for(Contact con : [Select Id,Name From Contact Where AccountId = :acc.Id]){
            contactIdSet.add(con.Id);
        }
        
        // Check for # of Lifetime Onsite
        for(Event evtObj : [Select Id,LastModifiedDate,Subject From Event Where WhoId IN :contactIdSet Order By LastModifiedDate DESC]) {
            if(evtObj.Subject != null && evtObj.Subject.contains('Presentation-Onsite')){
                this.noOfOnsites += 1;
            }
        }
        
        String largestEventName = '';
        Integer largestEventCount = 0;
        // Get all contacts asscoaited with the Account
        for(CVII_Event_Data__c eventData : [Select Id,Event_Name__c,Event_Start_Date__c,Event_End_Date__c,Total_Accepted__c,Total_Invited__c,Event_Status__c From CVII_Event_Data__c Where Account__c = :acc.Id and Event_Start_Date__c = LAST_N_DAYS:365 Order BY Total_Accepted__c ]){
            if(eventData.Total_Accepted__c != null){
                if(eventData.Total_Accepted__c > 0 && eventData.Total_Accepted__c > largestEventCount){
                    largestEventCount = Integer.valueOf(eventData.Total_Accepted__c);
                    largestEventName = eventData.Event_Name__c+' | Attendees = '+eventData.Total_Accepted__c;
                }
                // Get all events that has more than 200 Attendies
                if(eventData.Total_Accepted__c > 200){
                    this.noOfEventsGreaterThan200 += 1;
                }
            } 
            this.noOfLauncedEvents +=1;           
        }
        
        this.customerLargestEvent = largestEventName;
               
        // Check if the CSR is conducted in Last 12 Months.
        for(Customer_Success_Review__c csrObj : [Select Id,Name,Account__c,Status__c,Date_of_Review__c,MRF_Score__c,Sourcing_Score__c,AM_Score__c,Overall_Score__c,Type_of_Review__c,Budget_Score__c,Opportunity__c,Goals_with_Cvent__c From Customer_Success_Review__c Where Account__c =:acc.Id Order By LastModifiedDate]){
            if(csrObj.Goals_with_Cvent__c != null && this.cventBusinessGoals == '')
                this.cventBusinessGoals = csrObj.Goals_with_Cvent__c;
            if(csrObj.Status__c == 'CSR Conducted')
                this.isCSRConducted = 'Yes';
            // Add Customer Success Review in the List.
            customerSuccessReviewList.add(csrObj);
        }
        
        //Include “Account Transition Information”  object Info of the account : udita
        for(ATI_Info__c ati : [select Role_of_Events__c,Previous_Process__c,Level_of_Competency__c,name from ATI_Info__c where Account__c =:acc.Id]){
           ATIList.add(ati);
        }
        
        // Check if the Customer Attended Live Event.
        for(CampaignMember campaignMemberObj : [Select Id,Status From CampaignMember Where ContactId =:contactIdSet AND Status = 'Attended' AND Campaign.Type = 'Live Event' Order By LastModifiedDate LIMIT 1]){
            this.isAttendedCustomerEvent = 'Yes';
        }        
        
        // Get all Buyer Role for Account.
        for(Contact_Role__c buyerRole : [Select Id,Name,Contact__c,Contact__r.Name,Executive_Sponsor__c,Decision_Maker__c,Influencer__c,Executive_Sponsor_Products__c,Decision_Maker_Products__c,Influencer_Products__c From Contact_Role__c Where Account_Buyer_Role__c =:acc.Id]){
            if(accBuyerRoleExecutiveSponsor == ''){
                if(buyerRole.Executive_Sponsor__c != null && buyerRole.Executive_Sponsor__c)
                    this.accBuyerRoleExecutiveSponsor += buyerRole.Contact__r.Name;
            }else{
                if(buyerRole.Executive_Sponsor__c != null && buyerRole.Executive_Sponsor__c)
                    this.accBuyerRoleExecutiveSponsor +=', ' +buyerRole.Contact__r.Name;
            }
            
            if(accBuyerRoleDecisionMaker == ''){
                if(buyerRole.Decision_Maker__c != null && buyerRole.Decision_Maker__c)
                    this.accBuyerRoleDecisionMaker += buyerRole.Contact__r.Name;
            }else{
                if(buyerRole.Decision_Maker__c != null && buyerRole.Decision_Maker__c)
                    this.accBuyerRoleDecisionMaker +=', ' +buyerRole.Contact__r.Name;
            }
            
            if(accBuyerRoleInfluencer == ''){
                if(buyerRole.Influencer__c != null && buyerRole.Influencer__c)
                    this.accBuyerRoleInfluencer += buyerRole.Contact__r.Name;
            }else{
                if(buyerRole.Influencer__c != null && buyerRole.Influencer__c)
                    this.accBuyerRoleInfluencer +=', ' +buyerRole.Contact__r.Name;
            }
            // Add the records for the detailed view.
            buyerRoleList.add(buyerRole);
        }
        
        // Variable Declaration
        Boolean productInfoUpdated = false;
        Boolean renewableDateSet = false;
        Set<Id> oppIdSet = new Set<Id>();
        
        // Get the upcoming opportunity "Renewable Date" information.
        for(Opportunity opp : [Select Id,Name,Amount,CloseDate,StageName,Net_Amount_Opp__c,New_Contract_Total__c From Opportunity Where AccountId =:acc.Id AND StageName NOT IN :accPlanningClosedLostOppStagesSet AND CloseDate >= LAST_YEAR Order By CloseDate]){
            if(accPlanningClosedWonOppStagesSet.contains(opp.StageName) && opp.CloseDate <= System.Today() && (opp.New_Contract_Total__c != null || opp.Net_Amount_Opp__c != null) && !productInfoUpdated){
                oppIdSet.add(opp.Id);
            }             
            if(!accPlanningClosedWonOppStagesSet.contains(opp.StageName)){
                openOpportunitiesList.add(opp);
            }            
        }
        
        // Method Called to update the Product Information.
        if(!oppIdSet.isEmpty()){
            productInfoUpdated = true;                
            getSoldProductInformation(oppIdSet);
        }  
        
        Decimal currentYearNetOppAmount = 0.0;
        Decimal lastYearNetOppAmount = 0.0;
        Decimal firstNBBDealNetOppAmount = 0.0;
        // Calculate Year on Year Growth and Lifetime growth.
        for(Opportunity opp : [Select Id,CloseDate,StageName,Net_Amount_Opp__c,NBB_Renewal__c,New_Contract_Total__c From Opportunity Where AccountId =:acc.Id AND StageName IN :accPlanningClosedWonOppStagesSet Order By CloseDate]){
            if(opp.Net_Amount_Opp__c != null || opp.New_Contract_Total__c != null){
                closedWonOppIdSet.add(opp.Id);                
                if(opp.CloseDate.monthsBetween(Date.today()) <= 12){
                    if(opp.Net_Amount_Opp__c != null){
                        currentYearNetOppAmount += opp.Net_Amount_Opp__c;
                    }else{
                        currentYearNetOppAmount += opp.New_Contract_Total__c;
                    }
                }
                
                if(opp.CloseDate.monthsBetween(Date.today()) > 12 && opp.CloseDate.monthsBetween(Date.today()) <= 24){
                    if(opp.Net_Amount_Opp__c != null){
                        lastYearNetOppAmount += opp.Net_Amount_Opp__c;
                    }else{
                        lastYearNetOppAmount += opp.New_Contract_Total__c;
                    }
                }
                
                // Get First NBB Contract Year with Cvent Value
                if(!showfirstNBBDealWithCvent && opp.NBB_Renewal__c != null && opp.NBB_Renewal__c == 'NBB'){
                    if(opp.Net_Amount_Opp__c != null){
                        firstNBBDealNetOppAmount = opp.Net_Amount_Opp__c;
                    }else{
                        firstNBBDealNetOppAmount = opp.New_Contract_Total__c;
                    }
                    firstNBBDealWithCvent = opp.CloseDate;
                    showfirstNBBDealWithCvent = true;
                } 
            }                            
        } 
        
        // Populate Year-On-Year Growth
        if(currentYearNetOppAmount != 0.0 && lastYearNetOppAmount != 0.0){
            yoyGrowth = ((currentYearNetOppAmount-lastYearNetOppAmount)/lastYearNetOppAmount*100).setScale(2);
        }else{
            yoyGrowth = 0;
        }
        // Populate Lifetime Growth
        if(currentYearNetOppAmount != 0.0 && firstNBBDealNetOppAmount != 0.0){
            lifeTimeGrowth = ((currentYearNetOppAmount- firstNBBDealNetOppAmount)/firstNBBDealNetOppAmount*100).setScale(2);
        }else{
            lifeTimeGrowth = 0;
        }
        
        // Get the Contract Length.
        for(Contract masterContract : [Select Id,StartDate,EndDate,Contract_Term_Years__c From Contract Where SBQQ__Opportunity__c IN :closedWonOppIdSet AND RecordTypeId = :masterContractRecordtypeId Order By EndDate DESC LIMIT 1]){
            this.contractLength = masterContract.Contract_Term_Years__c;
        }
        // Added By : Sandeep Kumar, Dated: 07 Feb, 2017
        for(Customer_Asset__c cusAsset : [Select Id,Quantity__c,Product_Family__c,Total_One_Time_Fee_s__c,Master_Contract_End_Date__c ,Name,Contract__r.Name,Term_End_Date__c,Product__r.Name,Contract__r.Primary_Opportunity__r.Name,Contract__r.Primary_Opportunity__c,Contract__c,Annual_Recurring_Revenue__c,Product__r.Product_Family__c From Customer_Asset__c Where Account__c = :acc.Id AND Term_Start_Date__c < TODAY AND Term_End_Date__c > TODAY AND Annual_Recurring_Revenue__c != null Order By Term_End_Date__c]){
            // Get the upcoming opportunity "Renewable Date" information.
            if(oppRenewableDate == null){
                renewableDateSet = true;
                showOppRenewableDate = true;
                //oppRenewableDate = cusAsset.Term_End_Date__c; 
                //Change to master contract end date - added on 04/17/2018 
                oppRenewableDate = cusAsset.Master_Contract_End_Date__c; 
                
            }                   
            cusAssetList.add(cusAsset);
            system.debug('cusAsset.Product__r'+cusAsset.Product__r.Name);
            system.debug('cusAsset.Product__r'+cusAsset.Product__r.Product_Family__c);
            if(cusAsset.Product__r.Product_Family__c != null){
                if(cusAsset.Product__r.Product_Family__c.contains('Event')){
                    eventManagementProducts += Integer.valueOf(cusAsset.Annual_Recurring_Revenue__c);
                }else if(cusAsset.Product__r.Product_Family__c.contains('CrowdCompass')){
                    crowdCompassProducts += Integer.valueOf(cusAsset.Annual_Recurring_Revenue__c);
                }else if(cusAsset.Product__r.Product_Family__c.contains('Onsite Solutions')){
                    onsiteSolutionsProducts += Integer.valueOf(cusAsset.Annual_Recurring_Revenue__c);
                }else if(cusAsset.Product__r.Product_Family__c.contains('CSN')){
                    csnProducts += Integer.valueOf(cusAsset.Annual_Recurring_Revenue__c);
                }else if(cusAsset.Product__r.Product_Family__c.contains('Survey')){
                    inquisiumProducts += Integer.valueOf(cusAsset.Annual_Recurring_Revenue__c);
                } 
            } 
            //added by uditA
            if(cusAsset.Product_Family__c != null && cusAsset.Product__r.Name != null){
                if(cusAsset.Product_Family__c =='Event' && cusAsset.Product__r.Name.contains('Cvent Payment Services')){
                   CPSRevenue +=Integer.valueOf(cusAsset.Annual_Recurring_Revenue__c);            
                }
                if(cusAsset.Product_Family__c =='Onsite Solutions' && cusAsset.Product__r.Name.contains('LeadCapture')){
                   LeadCaptureRevenue +=Integer.valueOf(cusAsset.Annual_Recurring_Revenue__c);            
                }
            }                
        }  
    }
    
    public void getSoldProductInformation(Set<Id> oppIdSet){
        // Declaration and Instantiate Map for Product Name to Product Price
        Map<String,Decimal> prodNameToTotalPriceMap = new Map<String,Decimal>();
        Map<String,Decimal> prodFamilyToTotalPriceMap = new Map<String,Decimal>();
        // Declaration and Instantiate Map for Product Name to Product Price
        Map<String,String> prodNameToOpportunityMap = new Map<String,String>();
        List<OpportunityLineItem> oppItemList;
        
        for(OpportunityLineItem oppLineItem : [Select Id,TotalPrice,Product2.Name,Product2.Family,Opportunity.Name,Opportunity.CloseDate,OpportunityId From OpportunityLineItem Where OpportunityId IN :oppIdSet]){
            oppLineItemList.add(oppLineItem);
            oppItemList = new List<OpportunityLineItem>();       
            // Prepare product name to product list map
            if(prodNameToOppLineItemMap.containsKey(oppLineItem.Product2.Name)){
                oppItemList = prodNameToOppLineItemMap.get(oppLineItem.Product2.Name);
                oppItemList.add(oppLineItem);
                prodNameToOppLineItemMap.put(oppLineItem.Product2.Name, oppItemList);
            }else{
                oppItemList.add(oppLineItem);
                prodNameToOppLineItemMap.put(oppLineItem.Product2.Name, oppItemList);
            }              
        }
        
        Decimal totalProdPrice;
        for(String prodName : prodNameToOppLineItemMap.keySet()){
            totalProdPrice = 0;
            for(OpportunityLineItem oppLineItem : prodNameToOppLineItemMap.get(prodName)){
                totalProdPrice += oppLineItem.TotalPrice;
                prodNameToOpportunityMap.put(prodName, oppLineItem.Opportunity.Name);
            }  
            // Prepare a Map of Product Name to Total Price
            prodNameToTotalPriceMap.put(prodName, totalProdPrice);
        }
        
        for(String prodName :prodNameToTotalPriceMap.keySet()){
            // Fields shall be used to populate Integration/ API related products.
            if(accPlanningProductSet.contains(prodName) || prodName.contains('Integration') || prodName.contains('API') || prodName.contains('Connector')){
                if(integrationProducts == '')
                    integrationProducts += prodName;
                else
                    integrationProducts += ', '+prodName;
            }               
        }
    }
    
    // Method to save the data and return user to account detail page.
    public pageReference Save(){        
        acc.Account_Planning_Business_Goals__c = this.cventBusinessGoals;
        acc.Account_Planning_Strategy__c = this.cventAccountStrategy;
        update acc;
        PageReference acctPage = new ApexPages.StandardController(this.acc).view();        
        acctPage.setRedirect(true);
        return acctPage;
    }
    
    // Method to Display Related Lists.
    public void showDetailedView(){
        this.showDetailedView =  true;
        this.showDetailedViewButton = false;
    }
    
    // Method to Hide Related Lists.
    public void hideDetailedView(){
        this.showDetailedView =  false;
        this.showDetailedViewButton =  true;
    }
    
    // Method to return user to account detail page.
    public pageReference Cancel(){        
        PageReference acctPage = new ApexPages.StandardController(this.acc).view();        
        acctPage.setRedirect(true);
        return acctPage;
    }
    
    // create picklist of account having AM team role:Udita
    Public List<Selectoption> getselectedAccNameFields(){
             
     if(acc.Id !=null)
        relatedAcc = new list<Selectoption>();
        relatedAcc.add(new selectOption(acc.id, acc.name));
        for(Account acc :[select id,name,(SELECT AccountId ,Account.name FROM AccountTeamMembers where (TeamMemberRole LIKE 'AM -%' OR TeamMemberRole = 'Multi-Product') AND UserId  =: UserInfo.getUserId() LIMIT 1) from account WHERE OwnerId = :UserInfo.getUserId() and id != : ApexPages.currentPage().getParameters().get('id')]){
             if(acc.AccountTeamMembers.size() > 0)
             relatedAcc.add(new selectoption(acc.id,acc.name));
        }
        system.debug('----accName'+accName);
        return relatedAcc;
    }
}