public class ApprovalTriggerHandler {
    public static void approvalHistoryTracking(List<sbaa__Approval__c> approvalList, Boolean isInsert){        
        Set<String> oppIds = new Set<String>();
        Set<String> quoteIds = new Set<String>();
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(); //This will map the approval's parent Opportunity Id to it values
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>(); //This will map the approval's parent Quote Id to it values with quote lines
        Map<String, Approval_History__c> mapApprovalToHistory = new Map<String, Approval_History__c>();
        List<Approval_History__c> approvalHistoryList = new List<Approval_History__c>();
        
        for(sbaa__Approval__c approvalRec : approvalList){
            if(approvalRec.sbaa__Opportunity__c != null){
                oppIds.add(approvalRec.sbaa__Opportunity__c);
            }
            
            if(approvalRec.Quote__c != null){
                quoteIds.add(approvalRec.Quote__c);
            }
        }
        
        if(!oppIds.isEmpty()){
            system.debug('oppIds >> ' + oppIds);
            opportunityMap = new Map<Id, Opportunity>([SELECT Id, StageName FROM Opportunity WHERE Id IN: oppIds]);
            system.debug('opportunityMap >> ' + opportunityMap);
        }
        
        system.debug(':::DEBUG opportunityMap ' + opportunityMap);
        
        if(!quoteIds.isEmpty()){
            quoteMap = new Map<Id, SBQQ__Quote__c>([SELECT Id, SBQQ__NetAmount__c,SBQQ__RegularAmount__c, SBQQ__TotalCustomerDiscountAmount__c, SBQQ__LineItemCount__c,
                                                    SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.StageName,
                                                    (SELECT Id, SBQQ__ProductName__c FROM SBQQ__LineItems__r),
                                                    (SELECT Id, Min_Price__c, Max_Price__c FROM Approval_Histories__r Order By CreatedDate DESC LIMIT 1)
                                                    FROM SBQQ__Quote__c WHERE Id IN: quoteIds]);
        }
        
        system.debug(':::DEBUG quoteMap ' + quoteMap);
        
        if(!isInsert){
            List<Approval_History__c> existingApprovalHistory = [SELECT Id, Approval__c, Submission_Date_Time__c, Response_Date_Time__c FROM Approval_History__c WHERE Approval__c IN: approvalList];
            
            system.debug(':::DEBUG existingApprovalHistory ' + existingApprovalHistory);
            
            for(Approval_History__c approvalHistory : existingApprovalHistory){
                mapApprovalToHistory.put(approvalHistory.Approval__c, approvalHistory);
            }
            system.debug(':::DEBUG mapApprovalToHistory ' + mapApprovalToHistory);
        }
        
        
        for(sbaa__Approval__c approvalRec : approvalList){
            Approval_History__c approvalHistory = new Approval_History__c();
            if(isInsert){
                String oppStage = '';
                if(approvalRec.sbaa__Opportunity__c != null && opportunityMap.get(approvalRec.sbaa__Opportunity__c) != null){
                    oppStage = opportunityMap.get(approvalRec.sbaa__Opportunity__c).StageName;
                    system.debug('opportunityMap >> ' + opportunityMap.get(approvalRec.sbaa__Opportunity__c));
                }
                system.debug('oppStage >> ' + oppStage);
                
                if(approvalRec.Quote__c != null && quoteMap.get(approvalRec.Quote__c) != null){
                    String productNames = ''; //Product names per quote line will be stored here.
                    if(quoteMap.get(approvalRec.Quote__c).SBQQ__LineItems__r != null && !quoteMap.get(approvalRec.Quote__c).SBQQ__LineItems__r.isEmpty()){
                        for(SBQQ__QuoteLine__c ql : quoteMap.get(approvalRec.Quote__c).SBQQ__LineItems__r){
                            if(productNames == ''){
                                productNames = ql.SBQQ__ProductName__c;
                            }else{
                                productNames = productNames + ' | ' + ql.SBQQ__ProductName__c;
                            }
                        } 
                    }
                    //Filling up fields of Approval base on Quote and quote lines values.
                    approvalHistory.SKU_List__c = productNames;
                    approvalHistory.SKU_Count__c =  quoteMap.get(approvalRec.Quote__c).SBQQ__LineItemCount__c;
                    approvalHistory.Quote__c = approvalRec.Quote__c;
                    approvalHistory.Approval__c = approvalRec.Id;
                    approvalHistory.Approval_Name__c = approvalRec.Name;
                    approvalHistory.Submitted_By__c = userInfo.getUserId();                    
                    approvalHistory.Approval_Status__c = approvalRec.sbaa__Status__c;
                    approvalHistory.Approval_Rule_Name__c = approvalRec.Approval_Rule__c;
                    approvalHistory.Approval_Notes__c = approvalRec.sbaa__CommentsLong__c;
                    
                    if(approvalHistory.Opportunity_Stage__c == null){
                        approvalHistory.Opportunity_Stage__c = quoteMap.get(approvalRec.Quote__c).SBQQ__Opportunity2__c != null ? quoteMap.get(approvalRec.Quote__c).SBQQ__Opportunity2__r.StageName : '';
                    }
                    
                    Decimal quoteNetAmount = quoteMap.get(approvalRec.Quote__c).SBQQ__NetAmount__c;
                    if(quoteMap.get(approvalRec.Quote__c).Approval_Histories__r != null && !quoteMap.get(approvalRec.Quote__c).Approval_Histories__r.isEmpty()){
                        Decimal minPrice = quoteMap.get(approvalRec.Quote__c).Approval_Histories__r[0].Min_Price__c;
                        Decimal maxPrice = quoteMap.get(approvalRec.Quote__c).Approval_Histories__r[0].Max_Price__c;
                        if(minPrice != null){
                            if(minPrice > quoteNetAmount){
                                approvalHistory.Min_Price__c = quoteNetAmount;
                            }else{
                                approvalHistory.Min_Price__c = minPrice;
                            }
                            
                        }else {
                            approvalHistory.Min_Price__c = quoteNetAmount;
                        }
                        
                        if(maxPrice != null){
                            if(maxPrice < quoteNetAmount){
                                approvalHistory.Max_Price__c = quoteNetAmount;
                            }else{
                                approvalHistory.Max_Price__c = maxPrice;
                            }
                            
                        }else {
                            approvalHistory.Max_Price__c = quoteNetAmount;
                        }
                    }else{
                        approvalHistory.Max_Price__c =  quoteNetAmount;
                        approvalHistory.Min_Price__c =  quoteNetAmount;
                    }
                    
                    /*
                     * approvalHistory.Total_Quote_Amount__c =  quoteMap.get(approvalRec.Quote__c).SBQQ__NetAmount__c;
                    approvalHistory.Total_Quote_Regular_Price__c =  quoteMap.get(approvalRec.Quote__c).SBQQ__RegularAmount__c;
                    approvalHistory.Total_Quote_Discount__c =  quoteMap.get(approvalRec.Quote__c).SBQQ__RegularAmount__c - quoteMap.get(approvalRec.Quote__c).SBQQ__NetAmount__c;
                    if(approvalRec.Opportunity_Stage__c == null){
                        approvalRec.Opportunity_Stage__c = quoteMap.get(approvalRec.Quote__c).SBQQ__Opportunity2__c != null ? quoteMap.get(approvalRec.Quote__c).SBQQ__Opportunity2__r.StageName : '';
                    }
                    */
                }
            }else{
                approvalHistory = mapApprovalToHistory.get(approvalRec.Id);
                if(approvalHistory != null){
                    approvalHistory.Approval_Status__c = approvalRec.sbaa__Status__c;
                    approvalHistory.Approval_Notes__c = approvalRec.sbaa__CommentsLong__c;
                    approvalHistory.Approval_Rule_Name__c = approvalRec.Approval_Rule__c;
                }
                
                system.debug('After update --> ' + approvalHistory);
            }
            
            /* Approval Sent Date will be stamped with the date and time when the 
             * approval status becomes Requested for the first time.
             */
            if(approvalRec.sbaa__Status__c == 'Requested' && approvalHistory != null && approvalHistory.Submission_Date_Time__c == null){
                approvalHistory.Submission_Date_Time__c = Datetime.now();
            }
            
            /* Approval Response Date will be stamped with the date and time when the 
             * approval status becomes any of Approved, Rejected, Revoked or Recalled for the first time.
             */
            if((approvalRec.sbaa__Status__c == 'Approved' || approvalRec.sbaa__Status__c == 'Rejected' || 
                approvalRec.sbaa__Status__c == 'Revoked' || approvalRec.sbaa__Status__c == 'Recalled') && approvalHistory != null && approvalHistory.Response_Date_Time__c == null){
                approvalHistory.Response_Date_Time__c = Datetime.now();
            }
            if(approvalHistory != null){
                approvalHistoryList.add(approvalHistory);
            }
        }
        system.debug(':::DEBUG approvalHistoryList ' + approvalHistoryList);
        if(isInsert){
            try {
                insert approvalHistoryList;
            }catch(Exception e) {
                system.debug(':::DEBUG ' + e);
            }
            
        } else {
            try {
                update approvalHistoryList;
            }catch(Exception e) {
                system.debug(':::DEBUG ' + e);
            }
        }
    }
}