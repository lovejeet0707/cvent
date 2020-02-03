@isTest
public class ro_CaseAddAttachmentControllerTest {
	@isTest
	public static void unitTest(){
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
		
		Apexpages.currentPage().getParameters().put('caseid',oCase.Id);
		ro_CaseAddAttachmentController cont = new ro_CaseAddAttachmentController();
		
		Attachment oAttachment = cont.getAttachment();
		cont.setAttachment(oAttachment);
		
		oAttachment.Name = 'test';
		oAttachment.body = Blob.valueOf('test');
		oAttachment.parentId = oCase.Id;
		
		cont.upload();
		cont.done();		 
	}
}