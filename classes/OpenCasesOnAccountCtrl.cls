/*
*****Author: Mohsin Siddiqui
*****Test Class: Test_CustomRelatedListForOpenCasesCtrl
*/
public class OpenCasesOnAccountCtrl 
{
    public List<Case> openCases{get;set;}
    public Account accountInstance{get;set;}
    public OpenCasesOnAccountCtrl(ApexPages.StandardController controller) 
    {
        this.accountInstance= (Account)controller.getRecord();
        System.debug('Account Instance-'+accountInstance);
        getOpenCases();
    }
    public void getOpenCases()
    {
        List<Id> excludeGroupIds = new List<Id>();
        for(Group groupInstance : [select Id from Group where Type = 'Queue' AND (NAME = 'Client Services Case Queue - for Delete' OR NAME = 'Cvent Training Queue' OR (NAME LIKE '%CLS%'))])
        {
            excludeGroupIds.add(groupInstance.Id);
        }

        openCases = [Select Id,CaseNumber,ContactId,Contact.Name,Owner.Name,OwnerId,Subject,Product_Type__c,Origin,CreatedDate,Status from Case where (NOT(Status LIKE '%Closed%')) AND (NOT(OwnerId IN :excludeGroupIds)) AND (NOT(Status LIKE '%Cancelled%'))  AND AccountId =:accountInstance.Id ORDER BY CreatedDate DESC LIMIT 1000];
        System.debug('openCases>>'+openCases);
    }
}