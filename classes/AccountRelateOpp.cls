public without sharing class AccountRelateOpp {
public List<Opportunity> ListOpp{get;set;}
public String AccountId{get;set;}
public boolean checklist{get;set;}
    public AccountRelateOpp(ApexPages.StandardController controller) 
    {
    AccountId=ApexPages.currentPage().getParameters().get('id');
    ListOpp=new List<Opportunity>();
    checklist=false;
    getListOpp();
    
    }
    
    public List<Opportunity> getListOpp()
    {
       ListOpp=[Select id,Name,Owner.Name,New_Type__c,CloseDate,StageName,Product__c FROM Opportunity WHERE ((IsClosed = False)OR (IsClosed= True and CloseDate = THIS_QUARTER and (New_Type__c LIKE 'Early NBB%' OR New_Type__c LIKE 'NBB%'))) and AccountId=:AccountId];
       if(ListOpp.size()>0)
       {
         checklist=true;
         return ListOpp; 
       }
       else
       {
       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'There are No Opportunities');
       ApexPages.addMessage(myMsg);
       return null;
       }
    }

}