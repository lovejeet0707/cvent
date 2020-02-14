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
        openCases = [Select Id,CaseNumber,ContactId,Contact.Name,Owner.Name,OwnerId,Subject,Product_Type__c,Origin,CreatedDate,Status from Case where (NOT(Status LIKE '%Closed%')) AND AccountId =:accountInstance.Id ORDER BY CreatedDate DESC LIMIT 1000];
        System.debug('openCases>>'+openCases);
    }
}