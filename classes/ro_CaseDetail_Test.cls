@isTest
private class ro_CaseDetail_Test {
    
    static testMethod void myUnitTest() {
        Case_Settings__c settings       = new Case_Settings__c();
        settings.Name                   = 'CaseStatus';
        settings.X24_hrs_SLA__c         = 'ReOpened,Escalated';
        settings.Case_Status__c         = 'Open - Investigating, Open - Waiting on 3rd Party, Open - Waiting on Customer Information, Updated,ReOpened,Re-Close,Closed by System,Updated Development/IT,Scheduled for Later,Repeating Task,Work in Progress,Escalated,Closed';
        settings.Quick_Responses__c     = 'StarCite,New_Passkey,New_Group_Meetings,New_Meeting';
        settings.Standard_Response__c   = 'New_Business_Transient,New_RegOnline,New_GenieConnect,New_Conference';
        settings.Status_where_SLA_deadline_apply__c = 'Open - Investigating, Updated, ReOpened';
        insert settings;
        
        TabConfiguration__c oTabConfiguration = new TabConfiguration__c();
        oTabConfiguration.Name = 'Internal';
        oTabConfiguration.Tabs__c = 'home,articles,training,guides,lanyoncommunities,ideas,support';
        insert oTabConfiguration;
        
        CategoryMapping__c oCategoryMapping = new CategoryMapping__c();
        oCategoryMapping.Name = 'Internal';
        oCategoryMapping.Actual_Community_Name__c = 'Internal';
        oCategoryMapping.Category__c = 'REGONLINE';
        oCategoryMapping.Category_Group__c = 'Products';
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
        ro_CaseDetail rcd = new ro_CaseDetail();
        
        oCase.Status = 'Open';
        update oCase;
        
        ApexPages.currentPage().getParameters().put('id',oCase.Id);
        rcd = new ro_CaseDetail();
        rcd.getCaseComments();
        rcd.getAttachments();
        rcd.getKav();
        rcd.getEmails();
        rcd.AddCaseComments();
        rcd.closeCase();
        rcd.done();
        rcd.AddAttachments();
        
    } 
}