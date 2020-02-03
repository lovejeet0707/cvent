@isTest
public class CaseDataMigrationDetail_Test{
    static testMethod void unitMethod(){
        ByPassTrigger__c oByPassTrigger = new ByPassTrigger__c();
        oByPassTrigger.isDisabled__c = true;
        insert oByPassTrigger;
        
        Account oAccount = new Account();
        oAccount.Name = 'Lanyon Master';
        oAccount.BillingCountryCode = 'IN';
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
        oCase.Subject= 'Closed';
        insert oCase;
        
        CaseComment ccmt = new CaseComment();
        ccmt.ParentId = oCase.Id;
        ccmt.IsPublished = true;
        ccmt.CommentBody = 'Test Comment';
        insert ccmt;
        
        Attachment oAtt = new Attachment(Name = 'test', body= Blob.valueOf('test'),parentId=oCase.Id);
        insert oAtt;
        
        EmailMessage EMS = new EmailMessage();
        EMS.ParentId = oCase.Id;
        EMS.FromAddress = 'testmail@yahoo.com';
        EMS.FromName = 'TEst';
        EMS.MessageDate = system.Today();
        EMS.Subject = 'Test Subject';
        insert EMS;
        
        ApexPages.currentPage().getParameters().put('id',oCase.Id);
        CaseDataMigrationDetail_Class rcd = new CaseDataMigrationDetail_Class();
        
        oCase.Status = 'Open';
        update oCase;
        
        ApexPages.currentPage().getParameters().put('id',oCase.Id);
        rcd = new CaseDataMigrationDetail_Class();
        rcd.getCaseComments();
        rcd.getAttachments();
        rcd.getKav();
        rcd.getEmails();
        rcd.AddCaseComments();
        rcd.AddAuthorization();
        //rcd.closeCase();
        rcd.done();
        rcd.AddAttachments();
    }
}