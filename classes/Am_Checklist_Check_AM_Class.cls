public class Am_Checklist_Check_AM_Class{
	
	 public AM_Checklist__c account {get; private set;}
	 public Account acct {get; private set;}
		Id id = ApexPages.currentPage().getParameters().get('id');
		Public Integer x;
		Public String id2,id3;
public Am_Checklist_Check_AM_Class() {
		
		Integer i = [select count() from AM_Checklist__c a where a.Account__c = :id];
		x = i;
		if (x>0)
		{
			account = [select a.Id from AM_Checklist__c a where a.Account__c = :id limit 1];
			id2 = account.Id;
			id3 = id;
					}
		}

public PageReference validate() {
	
if (x==0)
		{
String x1 = 'https://ssl.salesforce.com/apex/NoFeatureset';
PageReference opptyPage = new PageReference(x1);
//opptyPage.setRedirect(true);
//return opptyPage;
return opptyPage;
		}
		else
		{	
			String xx;	
			xx = id2 + '&acc_name=' + id3 + '&tab_name=name1';
			String x1 = 'https://ssl.salesforce.com/apex/ViewAmFeatureSet?id=' + xx;
PageReference opptyPage = new PageReference(x1);
opptyPage.setRedirect(true);
return opptyPage;
		}	
}
}