/* Test coverage for the Release Management and Cvent Email Notification modules */
@isTest
class Test_ReleaseManagement2_0 {
    
    
    @testsetup
    static void createTestData(){
        
        ResourceProject__c crmRelease = new ResourceProject__c();
        crmRelease.Name = 'Test Release';
        crmRelease.Project_Name__c = 'Test Release';
        crmRelease.Requirements_Cut_Off_Date__c = System.today();
        crmRelease.UAT_Sign_Off_Date__c = system.today();
        crmRelease.UAT_Start_Date__c = System.today();
        crmRelease.Deployment_Date__c = System.today();        
        insert crmRelease;
       
        List<CRM_Project__c> projectList = new List<CRM_Project__c>();
        
        CRM_Project__c project = new CRM_Project__c();
        project.CRM_Release__c = crmRelease.Id;
        project.Project_Name__c = 'Test';
        project.Requestor__c = UserInfo.GetUserId();
        project.Status__c = 'Ready For UAT';
        
        CRM_Project__c project2 = new CRM_Project__c();
        project2.CRM_Release__c = crmRelease.Id;
        project2.Project_Name__c = 'Test';
        project2.Requestor__c = UserInfo.GetUserId();
        project2.Status__c = 'UAT Sign Off Received';
        
        projectList.add(project);
        projectList.add(project2);
        
        insert projectList; 
            
        crmRelease.Ready_for_UAT__c = true;
        crmRelease.Deployment_Initiated__c = true;
        crmRelease.Deployment_Complete__c = true;
        crmRelease.SignOff_Reminder_Sent__c=true;
        update crmRelease;
    
    }
    
    static testmethod void testCase1()
    {
    
        Id releaseId = [Select Id From ResourceProject__c Limit 1 ].Id; 
        
        CRM_EmailComponentController cntl = new CRM_EmailComponentController();
        cntl.setReleaseIdCtrl(releaseId);
        cntl.getReleaseIdCtrl();
        cntl.setRequestorIdCtrl(UserInfo.GetUserId());
        cntl.getRequestorIdCtrl();
        cntl.setReadyForUATCtrl(true);
        cntl.getReadyForUATCtrl();
        cntl.setProjectStatusCtrl('New');
        cntl.getProjectStatusCtrl();
        cntl.getProjects();
        cntl.getCRMRelease();
        
        System.debug('**** releaseId *** ' + releaseId);
    } 

    static testmethod void testCase2()
    {
        
        CRM_EmailComponentController cntl = new CRM_EmailComponentController();
        cntl.setRequestorIdCtrl(UserInfo.GetUserId());
        cntl.getRequestorIdCtrl();
        cntl.getProjects();

    }    
    
    static testmethod void testCaseTimeCards1()
    {
        
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' AND DeveloperName='Biz_Ac' And IsActive = true];

        Account instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        insert instofAcc;
    
        Contact instContact = new Contact();
        instContact.LastName = 'Test';
        instContact.AccountId = instofAcc.Id;
        instContact.CT_Contact_Status__c= 'Open Opportunity';
        instContact.Event_Contact_Status__c = 'Open Opportunity';
        instContact.TM_Contact_Status__c = 'Open Opportunity';
        instContact.LeadSource = 'WEB-Chat (CrowdCompass)';
        insert instContact;
    
        Id projectId = [Select Id From CRM_Project__c Limit 1 ].Id;
        
        CRM_Project_Item__c cItem = new CRM_Project_Item__c();
        cItem.CRM_Project__c =  projectId;
        cItem.Subject__c = 'Test';
        cItem.Estimated_Effort_Hours__c = 15;
        //cItem.Requestor__c  = instContact.Id ;
        insert cItem;
              
        
        CRM_Timecard__c t = new CRM_Timecard__c();
        t.Team_Member__c = UserInfo.getUserId();
        t.Approver_Email__c = 'test@testcvent.com';
        t.Start_Date__c = System.today() - 7;
        t.End_Date__c = System.today();
        t.Description__c = 'Test';
        insert t;
        
        CRM_Timecard_Entry__c cEntry = new CRM_Timecard_Entry__c();
        cEntry.CRM_Project_Work_Item__c = cItem.Id ;
        cEntry.User__c = UserInfo.getUserId();
        cEntry.Type__c = 'Cases';
        cEntry.CRM_Timecard__c = t.Id ;
        insert cEntry;
        
            
        CRM_MyTimeCardController cntl = new CRM_MyTimeCardController(new ApexPages.StandardController(t));
        cntl.selectedTimecardId = t.Id;
        cntl.refreshDropDowns();
        cntl.getSelectedTimecardId();
        cntl.reloadCurrentTimecard();
        cntl.selectTimecardAction();
        cntl.addEntryAction();
        
        List<CRM_Timecard_Entry__c> entries = [select Id from CRM_Timecard_Entry__c where CRM_Timecard__c =: t.Id limit 1];
        cntl.selectedEntryId = entries[0].Id;
        
        cntl.repopulateTimecardEntries();
        cntl.getIsValidTimecard();
        cntl.getEntryTypeOptions();
        cntl.saveAction();
        cntl.refreshAutoEntriesAction();
        cntl.autoGenerateEntriesAction();
        //cntl.deleteAction();
        cntl.doNothing();
        cntl.submitApprovalAction();
        cntl.approveAction();
        cntl.rejectAction();
        cntl.selectEntryTypeAction();
        cntl.getRecordCount();
        
        delete cEntry;
    }      
}