@isTest
private class Am_Checklist_Check_AM_Test_Class {

	    static testMethod void myUnitTest() {
        ApexPages.currentPage().getParameters().put('id', 'a03P0000002Yx0A');
        ApexPages.currentPage().getParameters().put('acc_name', '001P000000GF1fq');
        Id id = '001P000000GF1fq';
        Integer x;
		String id2,id3;
    	Am_Checklist_Check_AM_Class controller = new Am_Checklist_Check_AM_Class(); 
        Integer i = [select count() from AM_Checklist__c a where a.Account__c = :id];
        x = i;
		if (x>0)
		{
			AM_Checklist__c account = [select a.Id from AM_Checklist__c a where a.Account__c = :id limit 1];
			id2 = account.Id;
			id3 = id;
     	}
     	if (x==0)
		{
			String x1 = 'https://ssl.salesforce.com/apex/NoFeatureset';
		}
		else
		{	
			String xx;	
			xx = id2 + '&acc_name=' + id3 + '&tab_name=name1';
			String x1 = 'https://ssl.salesforce.com/apex/ViewAmFeatureSet?id=' + xx;
		}	
       		String nextPage = controller.validate().getUrl();
       
    }
}