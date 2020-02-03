@isTest(seeAllData=false)
public class CoachingFormSelection_Controller_Test {
    
    static testMethod void testOldCoachingFormPage(){
        List<Alliance_OA_Projects__c> onsiteProjectList = new List<Alliance_OA_Projects__c>();
        
        // Get the AllianceTech RecordTypeId
        Id recTypeAllianceTech1  = RecordTypeUtil.getRecordTypeIDByDevName('Alliance_OA_Projects__c','Alliance_Tech');
        Id recTypeAllianceTech2  = RecordTypeUtil.getRecordTypeIDByDevName('Alliance_OA_Projects__c','Universal_Lead_Retrieval');        
        
        Alliance_OA_Projects__c onsiteProjectObj = new Alliance_OA_Projects__c();
        onsiteProjectObj.RecordTypeId = recTypeAllianceTech1;
        onsiteProjectList.add(onsiteProjectObj);
        
        Alliance_OA_Projects__c onsiteProjectObj2 = new Alliance_OA_Projects__c();
        onsiteProjectObj2.RecordTypeId = recTypeAllianceTech2;
        onsiteProjectList.add(onsiteProjectObj2);                
        insert onsiteProjectList;
        
        Test.startTest();
        Test.setCurrentPage(Page.CoachingFormSelection_Page);
        ApexPages.Currentpage().getparameters().put('id',onsiteProjectList[0].Id);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(onsiteProjectList);
        CoachingFormSelection_Controller controller = new CoachingFormSelection_Controller(stdSetController); 
        // Load Record type Option
        controller.getRecTypeOptions();
        // Redirect User to Coaching Form Page
        controller.redirectUserToEditPage();
        // Redirect User to Source Page
        controller.Cancel();
        Test.stopTest();
    }
    
    static testMethod void testNewCoachingFormPage(){
        List<Alliance_OA_Projects__c> onsiteProjectList = new List<Alliance_OA_Projects__c>();
        
        // Get the AllianceTech RecordTypeId
        Id recTypeAllianceTech1  = RecordTypeUtil.getRecordTypeIDByDevName('Alliance_OA_Projects__c','Alliance_Tech');
        Id recTypeAllianceTech2  = RecordTypeUtil.getRecordTypeIDByDevName('Alliance_OA_Projects__c','Universal_Lead_Retrieval');        
        
        Alliance_OA_Projects__c onsiteProjectObj = new Alliance_OA_Projects__c();
        onsiteProjectObj.RecordTypeId = recTypeAllianceTech1;
        onsiteProjectList.add(onsiteProjectObj);
        
        Alliance_OA_Projects__c onsiteProjectObj2 = new Alliance_OA_Projects__c();
        onsiteProjectObj2.RecordTypeId = recTypeAllianceTech2;
        onsiteProjectList.add(onsiteProjectObj2);                
        insert onsiteProjectList;
        
        Test.startTest();
        Test.setCurrentPage(Page.CoachingFormSelection_Page2);
        ApexPages.Currentpage().getparameters().put('id',onsiteProjectList[0].Id);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(onsiteProjectList);
        CoachingFormSelection_Controller controller = new CoachingFormSelection_Controller(stdSetController);        
        // Load Record type Option
        controller.getRecTypeOptions();
        // Redirect User to Coaching Form Page
        controller.redirectUserToEditPage();
        // Redirect User to Source Page
        controller.Cancel();
        Test.stopTest();
    }
    
    static testMethod void testAllObjectPage(){
        List<Case> caseList = new List<Case>();
        List<Bundle_Card_Item__c> bundleCardItemList = new List<Bundle_Card_Item__c>();
        List<Mobile_Card__c> mobileCardList = new List<Mobile_Card__c>();
        List<Onboarding__c> onboardingList = new List<Onboarding__c>();
        List<TM_Buildout__c> tmbuildList = new List<TM_Buildout__c>();
        
        // Create Account Record.
        Account acc = TestUtil.createAccount('EB Account 1', 'Biz_Ac');
        insert acc;     
        
        // Create Contact Record.
        Contact con = TestUtil.createContact(acc.id);
        insert con;   
        
        // Create PSP Record.
        Professional_Services_Project__c PSPRec = new Professional_Services_Project__c();
        PSPRec.Account__c = acc.Id;
        PSPRec.of_EB__c = 5;
        insert PSPRec;  
        
        Opportunity o2 = TestUtil.createOpportunity('testOpp','Event','Bid Phase');
        o2.Contact_Associated__c = con.Id;
        o2.Contact_Role__c = 'Influencer';
        o2.AccountId = acc.Id;
        o2.Event_Planner_Name__c = 'test User';
        o2.Event_Planner_Email__c = 'testuser@cvent.com';
        o2.CloseDate = Date.today().addDays(80);
        insert o2;
        
        List<EB_SB_Builder__c> eBProjList = new List<EB_SB_Builder__c>();
        // Create Eb Project.
        EB_SB_Builder__c EBSBRec = new EB_SB_Builder__c();
        EBSBRec.PSP_ID__c = PSPRec.Id;
        EBSBRec.Contact__c = con.Id;
        EBSBRec.Opportunity__c = o2.Id;
        EBSBRec.AccountCustom__c = acc.Id;                 
        EBSBRec.Project__c = 'Event Builder';
        EBSBRec.Project_Type_del__c = 'Event Builder - Regular';
        EBSBRec.Project_Status_del__c = 'In Progress';            
        EBSBRec.Project_Stage__c = 'Information Received';
        EBSBRec.Event_Title__c = '';
        eBProjList.add(EBSBRec);
        
        EB_SB_Builder__c EBSBRec2 = new EB_SB_Builder__c();
        EBSBRec2.PSP_ID__c = PSPRec.Id;
        EBSBRec2.Contact__c = con.Id;
        EBSBRec2.Opportunity__c = o2.Id;
        EBSBRec2.AccountCustom__c = acc.Id;                 
        EBSBRec2.Project__c = 'Event Builder';
        EBSBRec2.Project_Type_del__c = 'Event Builder - Express';
        EBSBRec2.Project_Status_del__c = 'In Progress';            
        EBSBRec2.Project_Stage__c = 'Information Received';
        EBSBRec2.Event_Title__c = '';
        eBProjList.add(EBSBRec2);
        insert eBProjList;
        
        Test.startTest();
        Test.setCurrentPage(Page.CoachingFormSelection_Page);
        ApexPages.Currentpage().getparameters().put('id',eBProjList[0].Id);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(eBProjList);
        CoachingFormSelection_Controller controller = new CoachingFormSelection_Controller(stdSetController); 
        
        // Mobile Card testing.
        Mobile_Card__c mobCard1 = new Mobile_Card__c();        
        mobileCardList.add(mobCard1);
        
        Mobile_Card__c mobCard2 = new Mobile_Card__c();        
        mobileCardList.add(mobCard2);
        
        insert mobileCardList;
        
        ApexPages.Currentpage().getparameters().put('id',mobileCardList[0].Id);
        ApexPages.StandardSetController stdSetController1 = new ApexPages.StandardSetController(mobileCardList);
        CoachingFormSelection_Controller controller1 = new CoachingFormSelection_Controller(stdSetController1);
        
        // Case testing.        
        Id recTypeCase  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        // Insert Case Record
        Case caseObj = new Case();
        caseObj.recordTypeId = recTypeCase ;
        caseObj.Status = 'Open';
        caseObj.Minutesoncase__c = 30; 
        caseObj.AccountId=acc.Id;
        caseObj.subject='Test Hosp Cloud Implementation Survey';
        caseObj.Origin ='Email';       
        caseObj.description = 'Test Case 1';
        caseList.add(caseObj);
        
        // Insert Case Record
        Case caseObj2 = new Case();
        caseObj2.recordTypeId = recTypeCase ;
        caseObj2.Status = 'Open';
        caseObj2.Minutesoncase__c = 30; 
        caseObj2.AccountId=acc.Id;
        caseObj2.subject='Test Hosp Cloud Implementation Survey';
        caseObj2.Origin ='Email';       
        caseObj2.description = 'Test Case 2';
        caseList.add(caseObj2);
        
        insert caseList;
        
        ApexPages.Currentpage().getparameters().put('id',caseList[0].Id);
        ApexPages.StandardSetController stdSetController2 = new ApexPages.StandardSetController(caseList);
        CoachingFormSelection_Controller controller2 = new CoachingFormSelection_Controller(stdSetController2);    
        
        // Onboarding testing.        
        Onboarding__c onboardingObj = new Onboarding__c();
        onboardingObj.Account_Name__c = acc.Id;
        onboardingList.add(onboardingObj);
        
        Onboarding__c onboardingObj2 = new Onboarding__c();
        onboardingObj2.Account_Name__c = acc.Id;
        onboardingList.add(onboardingObj2);
        
        insert onboardingList;
        
        ApexPages.Currentpage().getparameters().put('id',onboardingList[0].Id);
        ApexPages.StandardSetController stdSetController3 = new ApexPages.StandardSetController(onboardingList);
        CoachingFormSelection_Controller controller3 = new CoachingFormSelection_Controller(stdSetController3);   
        
        Bundle_Card__c bundleCardObj = new Bundle_Card__c();
        bundleCardObj.Account__c = acc.Id;
        insert bundleCardObj;
        
        // Bundle Card Item testing.        
        Bundle_Card_Item__c bundleCardItemObj = new Bundle_Card_Item__c();
        bundleCardItemObj.Bundle_Card__c = bundleCardObj.Id;
        bundleCardItemList.add(bundleCardItemObj);
        
        Bundle_Card_Item__c bundleCardItemObj2 = new Bundle_Card_Item__c();
        bundleCardItemObj.Bundle_Card__c = bundleCardObj.Id;
        bundleCardItemList.add(bundleCardItemObj2);
        
        insert bundleCardItemList;
        
        ApexPages.Currentpage().getparameters().put('id',bundleCardItemList[0].Id);
        ApexPages.StandardSetController stdSetController4 = new ApexPages.StandardSetController(bundleCardItemList);
        CoachingFormSelection_Controller controller4 = new CoachingFormSelection_Controller(stdSetController4);  
        
        List<SMM_Implementations__c> smmImplementationList = new List<SMM_Implementations__c>();
        // SMM_Implementations__c testing.        
        SMM_Implementations__c smmImplementationObj = new SMM_Implementations__c();
        smmImplementationObj.Account__c = acc.Id;
        smmImplementationList.add(smmImplementationObj);
        
        SMM_Implementations__c smmImplementationObj2 = new SMM_Implementations__c();
        smmImplementationObj2.Account__c = acc.Id;
        smmImplementationList.add(smmImplementationObj2);
        
        insert smmImplementationList;
        
        ApexPages.Currentpage().getparameters().put('id',smmImplementationList[0].Id);
        ApexPages.StandardSetController stdSetController5 = new ApexPages.StandardSetController(smmImplementationList);
        CoachingFormSelection_Controller controller5 = new CoachingFormSelection_Controller(stdSetController5);   
        
        List<TM_Buildout__c> tmBuildOutList = new List<TM_Buildout__c>();
        // TM_Buildout__c testing.        
        TM_Buildout__c tmBuildOutObj = new TM_Buildout__c();
        tmBuildOutObj.Account__c = acc.Id;
        tmBuildOutList.add(tmBuildOutObj);
        
        TM_Buildout__c tmBuildOutObj2 = new TM_Buildout__c();
        tmBuildOutObj.Account__c = acc.Id;
        tmBuildOutList.add(tmBuildOutObj2);
        
        insert tmBuildOutList;
        
        ApexPages.Currentpage().getparameters().put('id',tmBuildOutList[0].Id);
        ApexPages.StandardSetController stdSetController6 = new ApexPages.StandardSetController(tmBuildOutList);
        CoachingFormSelection_Controller controller6 = new CoachingFormSelection_Controller(stdSetController6);   
        Test.stopTest();
    }
}