@isTest

Private class TestCaseStatusExtension{
    
    Static Account accObj;
    Static Contact conObj;
    Static Case caseObj;
    
    
    Static{
        
        accObj=new Account(name='Test Account');
        insert accObj;
        
        conObj=new Contact(lastName='Test Con' ,AccountID=accObj.id);
        insert conObj;
        
        caseObj=new Case(subject='Test', contactId=conobj.id, AccountId=accobj.id,status='Open');
        insert caseObj;
        
        Case_Settings__c settings       = new Case_Settings__c();
        settings.Name                   = 'CaseStatus';
        settings.X24_hrs_SLA__c         = 'ReOpened,Escalated';
        settings.Case_Status__c         = 'Open - Investigating, Open - Waiting on 3rd Party, Open - Waiting on Customer Information, Updated,ReOpened,Re-Close,Closed by System,Updated Development/IT,Scheduled for Later,Repeating Task,Work in Progress,Escalated,Closed';
        settings.Quick_Responses__c     = 'StarCite,New_Passkey,New_Group_Meetings,New_Meeting';
        settings.Standard_Response__c   = 'New_Business_Transient,New_RegOnline,New_GenieConnect,New_Conference';
        settings.Status_where_SLA_deadline_apply__c = 'Open - Investigating, Updated, ReOpened';
        insert settings;
    }
    
    Private static testMethod void myUnitTest(){
        PageReference pageRef = Page.CaseClose;
        ApexPages.currentPage().getParameters().put('id', String.valueOf(CaseObj.Id));
        ApexPages.currentPage().getParameters().put('contactId', String.valueOf(CaseObj.contactId));
        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
        CaseStatusExtension testCaseObj= new CaseStatusExtension(sc);
        //Test.setCurrentPage(pageRef);
        testCaseObj.updateCase();
        testCaseObj.cancel();
    } 
    
    Private static testMethod void myUnitTestTwo(){
        CaseObj.status='Closed';
        update CaseObj;
        PageReference pageRef = Page.CaseClose;
        ApexPages.currentPage().getParameters().put('id', String.valueOf(CaseObj.Id));
        ApexPages.currentPage().getParameters().put('contactId', String.valueOf(CaseObj.contactId));
        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
        CaseStatusExtension testCaseObj= new CaseStatusExtension(sc);
        testCaseObj.updateCase();
        testCaseObj.cancel();
    }
}