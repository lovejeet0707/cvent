public class PSA_demoScopingRequestTriggerHandler {
    
    public static void setReviewerStatusReady(map<Id,Demo_Scoping_Request__c> newMap, map<Id,Demo_Scoping_Request__c> oldMap) {
        
        for(Demo_Scoping_Request__c dsr : newMap.values()) {
                
            if(dsr.Primary_Reviewer_1__c != NULL && oldMap.get(dsr.Id).Primary_Reviewer_1__c == NULL) {
                dsr.Reviewer_1_Status__c = 'Ready';
            }
            if(dsr.Primary_Reviewer_2__c != NULL && oldMap.get(dsr.Id).Primary_Reviewer_2__c == NULL) {
                dsr.Reviewer_2_Status__c = 'Ready';
            }
            if(dsr.Primary_Reviewer_3__c != NULL && oldMap.get(dsr.Id).Primary_Reviewer_3__c == NULL) {
                dsr.Reviewer_3_Status__c = 'Ready';
            }                
            if(dsr.Primary_Reviewer_4__c != NULL && oldMap.get(dsr.Id).Primary_Reviewer_4__c == NULL) {
                dsr.Reviewer_4_Status__c = 'Ready';
            }
            if(dsr.Primary_Reviewer_5__c != NULL && oldMap.get(dsr.Id).Primary_Reviewer_5__c == NULL) {
                dsr.Reviewer_5_Status__c = 'Ready';
            }
            if(dsr.Primary_Reviewer_5__c != NULL && oldMap.get(dsr.Id).Primary_Reviewer_5__c == NULL) {
                dsr.Reviewer_5_Status__c = 'Ready';
            }
            if(dsr.Primary_Reviewer_6__c != NULL && oldMap.get(dsr.Id).Primary_Reviewer_6__c == NULL) {
                dsr.Reviewer_6_Status__c = 'Ready';
            }
        }
    }
    
    public static void scopingReviewsCompleted(list<Demo_Scoping_Request__c> dsrList) {
        
        
        for(Demo_Scoping_Request__c dsr : dsrList) {
            
            integer reviewerCount = 0;
        	integer completeCount = 0;
            
            if(dsr.Primary_Reviewer_1__c != null) { reviewerCount++; }
            if(dsr.Primary_Reviewer_2__c != null) { reviewerCount++; }
            if(dsr.Primary_Reviewer_3__c != null) { reviewerCount++; }
            if(dsr.Primary_Reviewer_4__c != null) { reviewerCount++; }
            if(dsr.Primary_Reviewer_5__c != null) { reviewerCount++; }
            if(dsr.Primary_Reviewer_6__c != null) { reviewerCount++; }
            if(dsr.Reviewer_1_Status__c == 'Review Complete') { completeCount++; }
            if(dsr.Reviewer_2_Status__c == 'Review Complete') { completeCount++; } 
            if(dsr.Reviewer_3_Status__c == 'Review Complete') { completeCount++; } 
            if(dsr.Reviewer_4_Status__c == 'Review Complete') { completeCount++; } 
            if(dsr.Reviewer_5_Status__c == 'Review Complete') { completeCount++; } 
            if(dsr.Reviewer_6_Status__c == 'Review Complete') { completeCount++; }
                        
            if(reviewerCount == completeCount) {
                
                if(reviewerCount > 1) {
                    dsr.allReviewsCompleted__c = TRUE;
                }
                
                else if(reviewerCount == 1) {
                    dsr.Scoping_Status__c = 'Scoping Completed';
                }
            }
        }
    }
}