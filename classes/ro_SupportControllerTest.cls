@isTest
public class ro_SupportControllerTest {
 @isTest
	public static void unitTest(){
		TabConfiguration__c oTabConfiguration = new TabConfiguration__c();
	 oTabConfiguration.Name = 'Internal';
	 oTabConfiguration.Tabs__c = 'home,articles,training,guides,lanyoncommunities,ideas,support';
	 insert oTabConfiguration;
	 
	 CategoryMapping__c oCategoryMapping = new CategoryMapping__c();
	 oCategoryMapping.Name = 'Internal';
	 oCategoryMapping.Actual_Community_Name__c = 'Internal';
	 oCategoryMapping.Category__c = 'REGONLINE';
	 oCategoryMapping.Category_Group__c = 'CATEGORIES';
	 oCategoryMapping.Product__c = 'RegOnline';
	 oCategoryMapping.Product_Family_Name__c = 'RegOnline';
	 oCategoryMapping.OwnerId__c = userinfo.getUserId();
	 insert oCategoryMapping;
     
		ByPassTrigger__c oByPassTrigger = new ByPassTrigger__c();
	 oByPassTrigger.isDisabled__c = true;
	 insert oByPassTrigger;
	 
	 CaseView__c oCaseView = new CaseView__c();
	 oCaseView.ViewLabel__c = 'All My Cases';
	 oCaseView.ViewName__c= 'All_Cases';
	 oCaseView.Criteria__c = 'Status In (\'Open\',\'Closed\')';
	 insert oCaseView;
	 	 
	 Account oAccount = new Account();
		oAccount.Name = 'Lanyon Master';
  insert oAccount;
  
  Contact oContact = new Contact();
		oContact.AccountID = oAccount.id;
		oContact.FirstName = 'Fname';
		oContact.LastName = 'Lname';	
		oContact.Email = 'test@test.com';
		insert oContact;
		
		list<Case> lstCase = new list<Case>();
		Case oCase;
		
		oCase= new Case();
		oCase.AccountId = oAccount.id;
		oCase.ContactId = oContact.id;
		oCase.Origin = 'test1@test.com';
		oCase.Status = 'Open';
		lstCase.add(oCase);
		
		oCase= new Case();
		oCase.AccountId = oAccount.id;
		oCase.ContactId = oContact.id;
		oCase.Origin = 'test2@test.com';
		oCase.Status = 'Open';
		lstCase.add(oCase);
		
		oCase= new Case();
		oCase.AccountId = oAccount.id;
		oCase.ContactId = oContact.id;
		oCase.Origin = 'test3@test.com';
		oCase.Status = 'Closed';
		lstCase.add(oCase);
	
		insert lstCase;
		
		
		ro_SupportController cont = new ro_SupportController();
		cont.casePaginator.resultsPerPage = 2;
		cont.sortField = 'Subject';
		cont.doSort();
		cont.isAsc = false;
		cont.doSort();
		
		if(cont.casePaginator.hasNextPage){
		 cont.casePaginator.nextPage();
		}
		
		if(cont.casePaginator.hasPrevPage){
		 cont.casePaginator.prevPage();
		}
		
		if(cont.casePaginator.hasFirstPage){
		 cont.casePaginator.firstPage();
		}
		
		if(cont.casePaginator.hasLastPage){
		 cont.casePaginator.lastPage();
		}
		
		cont.casePaginator.refresh();
		Integer nCount = cont.casePaginator.totalResults;
		
	 cont.subject = 'test Subject';
	 cont.description = 'test Description';
	 cont.event = 'Button Click';
	 cont.createNewDeflection();
	 
	 cont.newCase();
	 
	}
}