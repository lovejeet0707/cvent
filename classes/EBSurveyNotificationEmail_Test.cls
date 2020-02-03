/**
* Author : Sandeep Kumar
* Date : 12 April, 2017
* Description : It tests below mentioned classes
* 1) EBProjectAutoAssignment_TrigAct
*/
@isTest(seeAllData=false)
public class EBSurveyNotificationEmail_Test {
    private static Opportunity opp;
    private static Account acc; 
    private static Contact con;
    private static User testUser;
    private static Professional_Services_Project__c PSP;    
    private static User depUser = [Select Id, ProfileId from User where Name = 'CRM Deployment User'];
    private static Id newEBProjectOwnerId = [Select Id, ProfileId from User where Name != 'CRM Deployment User' AND Profile.Name = 'System Administrator' AND isActive = true LIMIT 1].Id;
    private static Id userProfieId = UserProfileUtil.getProfileIDByName('Customer Care Rep - Product Consultant EB Team');
    
    // sends an email to Customer buying the EB Products.
    static testMethod void sendEBNotificationToCustomer(){
        System.runAs(depUser){
            Test.startTest();
            // Create Account Record.
            acc = TestUtil.createAccount('EB Account 1', 'Biz_Ac');
            insert acc;     
            
            // Create Contact Record.
            con = TestUtil.createContact(acc.id);
            insert con;   
            
            // Create PSP Record.
            Professional_Services_Project__c PSPRec = new Professional_Services_Project__c();
            PSPRec.Account__c = acc.Id;
            PSPRec.of_EB__c = 5;
            insert PSPRec;  
            
            Opportunity o2 = TestUtil.createOpportunity('testOpp','Event','Bid Phase');
            o2.Contact_Associated__c = con.Id;
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
            
            List<Case> caseList = new List<Case>();
            // Case testing.        
            Id recTypeCase  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Eventbuilder').getRecordTypeId();
            // Insert Case Record
            Case caseObj = new Case();
            caseObj.recordTypeId = recTypeCase ;
            caseObj.Status = 'Open';
            caseObj.Event_Survey_Builder__c = eBProjList[0].Id;
            caseObj.Minutesoncase__c = 30; 
            caseObj.AccountId = acc.Id;
            caseObj.OwnerId = depUser.Id;
            caseObj.subject='Test Hosp Cloud Implementation Survey';
            caseObj.Origin ='Email';       
            caseObj.description = 'Test Case 1';
            caseList.add(caseObj);
            
            // Insert Case Record
            Case caseObj2 = new Case();
            caseObj2.recordTypeId = recTypeCase ;
            caseObj2.Status = 'Open';
            caseObj2.Event_Survey_Builder__c = eBProjList[1].Id;
            caseObj2.Minutesoncase__c = 30; 
            caseObj2.AccountId = acc.Id;
            caseObj2.OwnerId = depUser.Id;
            caseObj2.subject='Test Hosp Cloud Implementation Survey';
            caseObj2.Origin ='Email';       
            caseObj2.description = 'Test Case 2';
            caseList.add(caseObj2);
            
            insert caseList;
            
            Map<Id,Id> accIdToOwnerMap = new Map<Id,Id>();
        	Map<Id,List<String>> accIdToUserEmailMap = new Map<Id,List<String>>();
            Map<Id,EB_SB_Builder__c> accIdToEBSBProjMap = new Map<Id,EB_SB_Builder__c>();
            
            List<EB_SB_Builder__c> ebProjectList = [Select Id,AccountCustom__c,AccountCustom__r.Service_Tier__c,Survey_Feedback__c,Project_Assigned_Date__c,Project_Type_del__c,OwnerId,EB_Agent_Profile__c,Project_Complexity__c From EB_SB_Builder__c where Id IN :eBProjList];
            ebProjectList[0].OwnerId = newEBProjectOwnerId;
            ebProjectList[1].OwnerId = newEBProjectOwnerId;            
            update ebProjectList;
            
            List<String> newUserEmailList = new List<String>{'test@test.com'};
            accIdToUserEmailMap.put(ebProjectList[0].AccountCustom__c, newUserEmailList);
            accIdToOwnerMap.put(ebProjectList[0].AccountCustom__c, ebProjectList[0].OwnerId);
            accIdToEBSBProjMap.put(ebProjectList[0].Id, ebProjectList[0]);
            
            // Calls a sendCustomEmail Method from the "EBSurveyNotificationEmail" class.
            EBSurveyNotificationEmail.sendCustomEmail(ebProjectList[0].Id); 
            EBSurveyNotificationEmail.sendCaseLevelEscalationEmail(caseList); 
            EBSurveyNotificationEmail.sendCustomEmail(ebProjectList[1].Id); 
            EBSurveyNotificationEmail.sendEBSBProjectOwnerChangeEmail(accIdToOwnerMap,accIdToUserEmailMap,accIdToEBSBProjMap);
            
            EBSurveyNotificationEmail sendEmail = new EBSurveyNotificationEmail();            
            sendEmail.sendEbProjectAssignmentEmail(ebProjectList);            
            sendEmail.sendEbProjectDuplicateLinkUsageInfo(ebProjectList[0]);            
            ebProjectList[0].Project_Stage__c = 'Setup Call Done';
            update ebProjectList;            
            Test.stopTest();     
        }   
    } 
}