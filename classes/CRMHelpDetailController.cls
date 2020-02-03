public class CRMHelpDetailController{
    public List<Attachment> crmAttachment{get;set;}
    public Id caseId{get;set;}
    public Id helpId{get;set;}
    public Boolean showSuccessMessage{get;set;}
    public CRMHelpDetailController(ApexPages.StandardController controller) {
        showSuccessMessage = false;
        if(ApexPages.currentPage().getParameters().get('caseId') != null)
            caseId = ApexPages.currentPage().getParameters().get('caseId');
        if(ApexPages.currentPage().getParameters().get('id') != null)
            helpId = apexpages.currentpage().getparameters().get('id');
        System.debug('caseId*****'+caseId);
        crmAttachment = new List<Attachment>();
        crmAttachment = [SELECT Id,Name FROM Attachment WHERE ParentId = :helpId];
        System.debug('crmAttachment*****'+crmAttachment );
    }

    public void attachCase(){
        Integer sfRec = [SELECT count() FROM Salesforce_Article__c WHERE Case_Number__c = : caseId AND CRM_Help__c =:helpId];
        if(sfRec==0){
            showSuccessMessage = true;
            Salesforce_Article__c salesforceArticleObject = new Salesforce_Article__c();
            salesforceArticleObject.Case_Number__c = caseId;
            salesforceArticleObject.CRM_Help__c = helpId;
            insert salesforceArticleObject;
        }
        else{
            showSuccessMessage = true;
        }
    }
   
}