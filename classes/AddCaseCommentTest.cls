@isTest
public class AddCaseCommentTest {
    @isTest
  public static void unitTest(){
    
     
    Cvent_Category_Mapping__c categoryMapping = new Cvent_Category_Mapping__c();
        categoryMapping.Name = 'Test';
        categoryMapping.OwnerId__c = '00G00000006vs24';
        categoryMapping.Product__c= 'CrowdCompass';
        categoryMapping.RecordType_Id__c = '0120000000099RT';
        insert categoryMapping;
    
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
   
   AddCaseComment oController = new AddCaseComment();
      
    Apexpages.currentPage().getParameters().put('ccId',oCase.Id);
    oController = new AddCaseComment();
    oController.SubmitComment();
    
    oController.CommentBody = 'Test Comment';
    oController.SubmitComment();
    oController.SubmitComments();
    
    AddCaseComment.updaeComment('test Case Comment',oCase.id);
    //oController.Cancel();
  }
}