public class CustomRelatedListForOpenCasesCtrl 
{
    public List<Case> openCases{get;set;}
    public Contact contactInstance{get;set;}
    public CustomRelatedListForOpenCasesCtrl(ApexPages.StandardController controller) 
    {
        this.contactInstance= (Contact)controller.getRecord();
        System.debug('Contact Instance-'+contactInstance);
        getOpenCases();
    }
    public void getOpenCases()
    {
        openCases = [Select Id,CaseNumber,Owner.Name,OwnerId,Subject,Product_Type__c,Reason,Origin,CreatedDate,Status from Case where Status!='Closed' AND ContactId =:contactInstance.Id ORDER BY CreatedDate DESC LIMIT 1000];
        System.debug('openCases>>'+openCases);
    }
}