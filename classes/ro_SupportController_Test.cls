@isTest
private class ro_SupportController_Test {

    static testMethod void myUnitTest() {
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
   CaseView__c oCaseView = new CaseView__c();
	 oCaseView.ViewLabel__c = 'All My Cases';
	 oCaseView.ViewName__c= 'All_Cases';
	 oCaseView.Criteria__c = 'Status In (\'Open\',\'Closed\')';
	 insert oCaseView;  
     
    	ByPassTrigger__c oByPassTrigger = new ByPassTrigger__c();
	 	oByPassTrigger.isDisabled__c = true;
	 	insert oByPassTrigger;
	 	 
	 	Account oAccount = new Account();
		oAccount.Name = 'Lanyon Master';
  		insert oAccount;
  
  		Contact oContact = new Contact();
		oContact.AccountID = oAccount.id;
		oContact.FirstName = 'Fname';
		oContact.LastName = 'Lname';	
		oContact.Email = 'test@test.com';
		insert oContact;
        
	 Case oCase = new Case();
		oCase.AccountId = oAccount.id;
		oCase.ContactId = oContact.id;
		oCase.Origin = 'test@test.com';
		oCase.Status = 'Closed';
		insert oCase;
    	
		ro_SupportController rsc = new ro_SupportController();
		rsc.newCase();
		rsc.createNewDeflection();
  rsc.doSort();
        
  CaseView__c cvc = new CaseView__c();
  cvc.Criteria__c = 'CreatedById=' + '\'$user.Id\'';
  cvc.ViewLabel__c = 'All My Cases';
  cvc.ViewName__c = 'All_Cases1';
  system.debug('The user id is'+cvc.Criteria__c);
  insert cvc;
    	
		rsc.fetchCaseViews();
		rsc.doSort();
		
		rsc.selectedCaseViewName = 'All_Cases1';
		rsc.doSort();
    	
		rsc.casePaginator.resultsPerPage = 10;
		rsc.casePaginator.currentPageNumber = 1;
		rsc.casePaginator.nextPage();
		rsc.casePaginator.prevPage();
		rsc.casePaginator.firstPage();
		rsc.casePaginator.lastPage();
		rsc.casePaginator.goToPage();
		
	}
}