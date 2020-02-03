@isTest
public class CaseDeflectionTestClass{

    //Test method for SupportPage_Controller Class
    static testMethod void SupportPage_ControllerMethod(){
        //Create Custom Setting for recordtype Names.....
        Cvent_Community_Record_Types__c ccRecTypeName = new Cvent_Community_Record_Types__c();
        ccRecTypeName.name = 'New Event';
        insert ccRecTypeName;
        
        //Setting Page Name.....
        PageReference pageref = Page.SupportPage;
        Test.setCurrentPage(pageRef);
        
        //Insert cases........
        Case cc = new Case();
        cc.Subject = 'Test';
        cc.Status = 'Open';
        cc.recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Event').getRecordTypeId();
        insert cc;
        //Calling Class.....
        SupportPage_Controller controller = new SupportPage_Controller();
        //Calling method.....
        controller.createTracker();
        
    }
    //Test method for FindHelp_Class Class
    static testMethod void FindHelp_ClassMethod(){
        //Create Knowldege Articles....
        Download__kav newArticle = new Download__kav(Title='Event test article', UrlName='testarticleurl', Language='en_US');
        //Insert Article
        insert newArticle;
        
        Download__DataCategorySelection insftOfFAWDCS =  new Download__DataCategorySelection();
        insftOfFAWDCS.DataCategoryGroupName = 'Products';
        insftOfFAWDCS.DataCategoryName = 'Event';
        insftOfFAWDCS.ParentId = newArticle.Id;
        insert insftOfFAWDCS;
        
        Download__kav k = [SELECT Id,KnowledgeArticleId,ArticleNumber,ArticleType,IsLatestVersion,Title,UrlName FROM Download__kav WHERE Id = :newArticle.Id];    
        KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);
        
        //Setting this so that SOSL should return result....
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = k.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        //Create Case Deflection record......
        Case_Deflection_Track__c caseDeflectTrack = new Case_Deflection_Track__c();
        caseDeflectTrack.No_I_found_my_Answer_Count__c = 1;
        insert caseDeflectTrack;

        //Setting Page Name.....
        PageReference pageref = Page.FindHelp;
        Test.setCurrentPage(pageRef);
        
        //Calling Class.....
        FindHelp_Class controller = new FindHelp_Class();
        
        //Setting Parameter..........
        System.currentPageReference().getParameters().put('id', caseDeflectTrack.Id);

        //Calling method.....
        controller.updateNoTrackerCount();
        controller.updateTrackerCount();
        FindHelp_Class.actfast(caseDeflectTrack.Id,'Event__c','Event');
    }
    //Test method for CreateNewCase_Class Class
    static testMethod void CreateNewCase_ClassMethod(){
        //Inserting Custom Setting....
        Cvent_Category_Mapping__c categoryMapping = new Cvent_Category_Mapping__c();
        categoryMapping.Name = 'Test';
        categoryMapping.OwnerId__c = '00G00000006vs24';
        categoryMapping.Product__c= 'CrowdCompass';
        categoryMapping.RecordType_Id__c = '0120000000099RT';
        insert categoryMapping;
        
        //Setting Page Name.....
        PageReference pageref = Page.CreateNewCase;
        Test.setCurrentPage(pageRef);
        //Setting Parameter..........
        System.currentPageReference().getParameters().put('Subject', 'test subject');
        //Create Case Deflection record......
        Case_Deflection_Track__c caseDeflectTrack = new Case_Deflection_Track__c();
        caseDeflectTrack.No_I_found_my_Answer_Count__c = 1;
        insert caseDeflectTrack;
        
        //Calling Class.....
        CreateNewCase_Class controller = new CreateNewCase_Class();
        controller.save();
        
        

        //Calling method.....
        
        
        
        
        
        
        //Insert Account...
        Account accRec = new Account();
        accRec.name = 'Test Account';
        insert accRec;
        
        //Insert Contact......
        Contact conRec = new Contact();
        conRec.AccountId = accRec.id;
        conRec.LastName = 'test';
        insert conRec;
        
        User_Contact_Relation__c ucr = new User_Contact_Relation__c();
        ucr.User__c = Userinfo.getUserId();
        ucr.Related_Contact__c = conRec.Id;
        ucr.sfxId__c = 'NIK16514344';
        insert ucr;
     
        controller = new CreateNewCase_Class();
        controller.PopulateAccountId();
        controller.saveAndAddAttachment();
        controller.getContactName(conRec.id);
        
        /*controller.isSite = true;
        controller.sFirstName = 'fname';
        controller.sLastName = 'lname';
        controller.sEmail = 'email@email.com';
        controller.sCompanyName = 'compname';
        controller.save();*/

    }
     //Test method for CaseAddAttachmentController Class
    static testMethod void CaseAddAttachmentControllerMethod(){
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
        oCase.Subject = 'Test Closed Case';
        insert oCase;
        
        Apexpages.currentPage().getParameters().put('caseid',oCase.Id);
        CaseAddAttachmentController cont = new CaseAddAttachmentController();
        
        Attachment oAttachment = cont.getAttachment();
        cont.setAttachment(oAttachment);
        
        oAttachment.Name = 'test';
        oAttachment.body = Blob.valueOf('test');
        oAttachment.parentId = oCase.Id;
        
        cont.upload();
        cont.done();  
    
    }
    static testMethod void CaseDetail_ClassMethod(){
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
        CaseDetail_Class rcd = new CaseDetail_Class();
        
        oCase.Status = 'Open';
        update oCase;
        
        ApexPages.currentPage().getParameters().put('id',oCase.Id);
        rcd = new CaseDetail_Class();
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