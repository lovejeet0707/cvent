@isTest
public class ro_AddCaseCommentTest {
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
		
		CaseComment oCaseComment = new CaseComment();
		oCaseComment.ParentId = oCase.Id;
		oCaseComment.IsPublished = true;
		oCaseComment.CommentBody = 'Test Comment';
	 insert oCaseComment;
	 
	 ro_AddCaseComment oController = new ro_AddCaseComment();
	 	 
		Apexpages.currentPage().getParameters().put('ccId',oCase.Id);
		oController = new ro_AddCaseComment();
		oController.SubmitComment();
		
		oController.CommentBody = 'Test Comment';
		oController.SubmitComment();
		oController.Cancel();
	}
}