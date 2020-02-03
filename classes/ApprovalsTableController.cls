public class ApprovalsTableController {
    
    public Id objId {get; set;}
    
    public List<sbaa__Approval__c > getApprovalsList() {
        return [SELECT sbaa__Status__c, Assigned_Approver_Group__c, sbaa__ApprovalStep__c, Approved_By__c, sbaa__CommentsLong__c, 
                Approval_Rule__c, sbaa__Rule__r.Name, sbaa__Rule__c, sbaa__ApprovedBy__c    
                FROM sbaa__Approval__c  
                WHERE Quote__c  = :objId];
    }

}