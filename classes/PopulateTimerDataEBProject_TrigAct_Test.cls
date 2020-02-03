/*************************************************
* Author : Sandeep Kumar
* Date : 21 Nov 2017
* Description : It tests below mentioned classes
* 1) PopulateTimerDataOnEBProject_TrigAct
**************************************************/
@isTest(seeAllData=false)
public class PopulateTimerDataEBProject_TrigAct_Test {
    private static Case caseObj,caseObj2;
    private static Account accObj; 
    private static AccountTeamMember atmObj;
    private static Contact conObj;
    private static EB_SB_Builder__c EBSBRec,EBSBRec2;
    private static List<Case> caseList;
    private static List<EB_SB_Builder__c> eBProjectList;
    private static User depUser = [Select Id, ProfileId from User where Name = 'CRM Deployment User'];  
    private static Id userProfieId = UserProfileUtil.getProfileIDByName('Customer Care Rep - Product Consultant EB Team');    
    
    public static void setupData(){        
        // Create Account Record.
        accObj = TestUtil.createAccount('EB Account 1', 'Biz_Ac');
        insert accObj;     
        
        atmObj = TestUtil.createATM(accObj.Id,depUser.Id);
        atmObj.TeamMemberRole = 'AM - Event';
        insert atmObj;
        
        // Create Contact Record.
        conObj = TestUtil.createContact(accObj.Id);
        insert conObj; 
        
        eBProjectList = new List<EB_SB_Builder__c>();
        // Create Eb Project.
        EBSBRec = new EB_SB_Builder__c();
        EBSBRec.Contact__c = conObj.Id;
        EBSBRec.AccountCustom__c = accObj.Id;                 
        EBSBRec.Project__c = 'Event Builder';
        EBSBRec.Project_Status_del__c = 'Yet To Start';            
        EBSBRec.Project_Stage__c = 'Information Received';
        EBSBRec.Project_Complexity__c = '1-Simple';
        EBSBRec.Project_Type_del__c = 'Event Builder - Regular';            
        EBSBRec.Event_Title__c = '';
        eBProjectList.add(EBSBRec);
        
        // Create Eb Project.
        EBSBRec2 = new EB_SB_Builder__c();
        EBSBRec2.Contact__c = conObj.Id;
        EBSBRec2.AccountCustom__c = accObj.Id;                 
        EBSBRec2.Project__c = 'Event Builder';
        EBSBRec2.Project_Status_del__c = 'Yet To Start';              
        EBSBRec2.Project_Stage__c = 'Information Received';
        EBSBRec2.Project_Complexity__c = '1-Simple';
        EBSBRec2.Project_Type_del__c = 'Additional Changes'; 
        eBProjectList.add(EBSBRec2);
        
        insert eBProjectList;
        
        caseList = new List<Case>();
        
        caseObj = new Case();
        caseObj.AccountId = accObj.Id;
        caseObj.SuppliedEmail = 'testcontact1@test.com';
        caseObj.RecordTypeId = RecordTypeUtil.getRecordTypeIDByDevName('Case','Eventbuilder');
        caseObj.Status = 'Open';
        caseObj.OwnerId = depUser.Id;
        caseObj.Priority = 'Medium';
        caseObj.Origin = 'Admin';
        caseObj.Client_Services_Category__c = 'Set-up Call';
        caseObj.Subject = 'Test Case for Timer Update 1.';
        caseObj.Description = 'Please refer the attached email for more information.'; 
        caseObj.Event_Survey_Builder__c = eBProjectList[0].Id;
        caseList.add(caseObj); 
        
        caseObj = new Case();
        caseObj.AccountId = accObj.Id;
        caseObj.SuppliedEmail = 'testcontact1@test.com';
        caseObj.RecordTypeId = RecordTypeUtil.getRecordTypeIDByDevName('Case','Eventbuilder');
        caseObj.Status = 'Open';
        caseObj.OwnerId = depUser.Id;
        caseObj.Priority = 'Medium';
        caseObj.Origin = 'Admin';
        caseObj.Client_Services_Category__c = 'Set-up Call';
        caseObj.Subject = 'Test Case for Timer Update 1.';
        caseObj.Description = 'Please refer the attached email for more information.'; 
        caseObj.Event_Survey_Builder__c = eBProjectList[0].Id;
        caseList.add(caseObj); 
        
        caseObj2 = new Case();
        caseObj2.AccountId = accObj.Id;
        caseObj2.SuppliedEmail = 'testcontact2@test.com';
        caseObj2.RecordTypeId = RecordTypeUtil.getRecordTypeIDByDevName('Case','Creative_Services');
        caseObj2.Status = 'Open';
        caseObj2.Priority = 'Medium';
        caseObj2.OwnerId = depUser.Id;
        caseObj2.Origin = 'Admin';
        caseObj2.Client_Services_Category__c = 'Set-up Call';
        caseObj2.Subject = 'Test Case for Timer Update 2.';
        caseObj2.Description = 'Please refer the attached email for more information.';   
        caseObj2.Event_Survey_Builder__c = eBProjectList[0].Id;
        caseList.add(caseObj2);
        
        caseObj2 = new Case();
        caseObj2.AccountId = accObj.Id;
        caseObj2.SuppliedEmail = 'testcontact2@test.com';
        caseObj2.RecordTypeId = RecordTypeUtil.getRecordTypeIDByDevName('Case','Creative_Services');
        caseObj2.Status = 'Open';
        caseObj2.Priority = 'Medium';
        caseObj2.OwnerId = depUser.Id;
        caseObj2.Origin = 'Admin';
        caseObj2.Client_Services_Category__c = 'Set-up Call';
        caseObj2.Subject = 'Test Case for Timer Update 2.';
        caseObj2.Description = 'Please refer the attached email for more information.';   
        caseObj2.Event_Survey_Builder__c = eBProjectList[0].Id;
        caseList.add(caseObj2);
        
        insert caseList;
        
        caseList[0].OwnerId = depUser.Id;
        caseList[1].OwnerId = depUser.Id;
        caseList[2].OwnerId = depUser.Id;
        caseList[3].OwnerId = depUser.Id;
        update caseList;
    }
    
    static testMethod void updateTimeOnEBSB(){
        Test.startTest();
        // Call below method to load test Data.
        setupData();
        // create Timing record for Case 1
        WorkIt2__Timing__c timingObj1 = new WorkIt2__Timing__c();
        timingObj1.WorkIt2__Case__c = caseList[0].Id;
        insert timingObj1;
        
        // create Time Entry record for the above Timing
        WorkIt2__Time_Entry__c timeEntryObj1 = new WorkIt2__Time_Entry__c();
        timeEntryObj1.WorkIt2__Timing__c = timingObj1.Id;
        timeEntryObj1.WorkIt2__Start__c = System.now().addHours(-10);
        timeEntryObj1.WorkIt2__Heartbeat__c = System.now().addHours(-9);
        insert timeEntryObj1;
        
        System.debug('Timing Record Cal 1 Before = '+[Select Id,WorkIt2__Time_In_Seconds__c From WorkIt2__Timing__c Where Id =:timingObj1.Id].WorkIt2__Time_In_Seconds__c);
        
        WorkIt2__Time_Entry__c timeEntryToUpdate = [Select Id From WorkIt2__Time_Entry__c Where Id =:timeEntryObj1.Id];
        // Update Timing Entry record
        timeEntryToUpdate.WorkIt2__Heartbeat__c = System.now().addHours(-8);
        update timeEntryToUpdate;
        
        System.debug('Timing Record Cal 1 After = '+[Select Id,WorkIt2__Time_In_Seconds__c From WorkIt2__Timing__c Where Id =:timingObj1.Id].WorkIt2__Time_In_Seconds__c);
        
        // create Timing record for Case 2
        WorkIt2__Timing__c timingObj2 = new WorkIt2__Timing__c();
        timingObj2.WorkIt2__Case__c = caseList[1].Id;
        TriggerAction.resetAllHasRun();
        insert timingObj2;
        
        // create Time Entry record for the above Timing
        WorkIt2__Time_Entry__c timeEntryObj2 = new WorkIt2__Time_Entry__c();
        timeEntryObj2.WorkIt2__Timing__c = timingObj2.Id;
        timeEntryObj2.WorkIt2__Start__c = System.now().addHours(-10);        
        timeEntryObj2.WorkIt2__Heartbeat__c = System.now().addHours(-9);
        insert timeEntryObj2;
        
        System.debug('Timing Record Cal 2 Before = '+[Select Id,WorkIt2__Time_In_Seconds__c From WorkIt2__Timing__c Where Id =:timingObj2.Id].WorkIt2__Time_In_Seconds__c);
        
        WorkIt2__Time_Entry__c timeEntryToUpdate2 = [Select Id From WorkIt2__Time_Entry__c Where Id =:timeEntryObj2.Id];
        // Update Timing Entry record
        timeEntryToUpdate2.WorkIt2__Heartbeat__c = System.now().addHours(-8);
        timeEntryToUpdate2.WorkIt2__Force_End__c = System.now().addHours(-7);
        update timeEntryToUpdate2;     
        
        System.debug('Timing Record Cal 2 After = '+[Select Id,WorkIt2__Time_In_Seconds__c From WorkIt2__Timing__c Where Id =:timingObj2.Id].WorkIt2__Time_In_Seconds__c);
        Test.stopTest();
    }
}