/**
* Author : Sandeep Kumar
* Date : 23 Jun, 2017
* Description : It tests below mentioned class
* 1) ScopeRequestSurvey_Cont
* 2) RushRequestSurvey_Cont
*/
@isTest(seeAllData = false)
public class ScopeRushRequestSurvey_Cont_Test{
    private static Opportunity opp;
    private static Account acc; 
    private static Contact con;
    private static List<Event_Builder_Survey_Q_A__c> eventBuilderList;
    private static User depUser = [Select Id, ProfileId from User where Name = 'CRM Deployment User'];
    private static Id userProfieId = UserProfileUtil.getProfileIDByName('Customer Care Rep - Product Consultant EB Team'); 
    
    public static Void setupData(){
        // Create Account Record.
        acc = TestUtil.createAccount('EB Account 1', 'Biz_Ac');
        insert acc;
        
        // Create Contact Record.
        con = TestUtil.createContact(acc.id);
        insert con; 
        
        Opportunity o1 = TestUtil.createOpportunity('testOpp','Event','Bid Phase');
        o1.Contact_Associated__c = con.Id;
        o1.AccountId = acc.Id;
        o1.CloseDate = Date.today().addDays(80);
        insert o1;
        
        // Create Salesforce Users for which will be assigned to EB Agent Profile later.
        User usr1 = TestUtil.createUser(userProfieId);
        insert usr1;
        
         // Create EB Agent Profile Records.   
        EB_Agent_Profile__c EBAgentProfile = TestUtil.createEBAgentProfile('Profile 1',usr1.Id,'1');
        EBAgentProfile.Current_Work_Load_hrs__c = 30;
        EBAgentProfile.of_Projects__c = 3;
        EBAgentProfile.of_Projects_Agent__c = 5;
        EBAgentProfile.Is_also_Handling_Scope_Request__c = true;
        insert EBAgentProfile;
        
        eventBuilderList = new List<Event_Builder_Survey_Q_A__c>();
        
        // Rush Request Survey Questions.
        Event_Builder_Survey_Q_A__c testQuestion1 = TestUtil.createEventBuilderQuestionAnswer('Test Question 1','Text',1,'Rush Request');
        eventBuilderList.add(testQuestion1);
        Event_Builder_Survey_Q_A__c testQuestion2 = TestUtil.createEventBuilderQuestionAnswer('Test Question 2','Text',2,'Rush Request');
        eventBuilderList.add(testQuestion2);
        Event_Builder_Survey_Q_A__c testQuestion3 = TestUtil.createEventBuilderQuestionAnswer('Test Question 3','Text',3,'Rush Request');
        eventBuilderList.add(testQuestion3);
        Event_Builder_Survey_Q_A__c testQuestion4 = TestUtil.createEventBuilderQuestionAnswer('Test Question 4','Sub Questions',4,'Rush Request');
        eventBuilderList.add(testQuestion4);
        Event_Builder_Survey_Q_A__c testQuestion5 = TestUtil.createEventBuilderQuestionAnswer('Test Question 5','Country Name',5,'Rush Request');
        eventBuilderList.add(testQuestion5);
        Event_Builder_Survey_Q_A__c testQuestion6 = TestUtil.createEventBuilderQuestionAnswer('Test Question 6','MultiSelect1',6,'Rush Request');
        eventBuilderList.add(testQuestion6);
        Event_Builder_Survey_Q_A__c testQuestion7 = TestUtil.createEventBuilderQuestionAnswer('Test Question 7','Picklist - Yes/No',7,'Rush Request');
        eventBuilderList.add(testQuestion7);
        Event_Builder_Survey_Q_A__c testQuestion8 = TestUtil.createEventBuilderQuestionAnswer('Test Question 8','Date',8,'Rush Request');
        eventBuilderList.add(testQuestion8);
        Event_Builder_Survey_Q_A__c testQuestion9 = TestUtil.createEventBuilderQuestionAnswer('Test Question 9','Date',9,'Rush Request');
        eventBuilderList.add(testQuestion9);
        Event_Builder_Survey_Q_A__c testQuestion10 = TestUtil.createEventBuilderQuestionAnswer('Test Question 10','Picklist - Complexity',10,'Rush Request');
        eventBuilderList.add(testQuestion10);
        Event_Builder_Survey_Q_A__c testQuestion11 = TestUtil.createEventBuilderQuestionAnswer('Test Question 11','Static Display',11,'Rush Request');
        eventBuilderList.add(testQuestion11);
        Event_Builder_Survey_Q_A__c testQuestion12 = TestUtil.createEventBuilderQuestionAnswer('Test Question 12','Picklist - Yes/No',12,'Rush Request');
        eventBuilderList.add(testQuestion12);
        Event_Builder_Survey_Q_A__c testQuestion13 = TestUtil.createEventBuilderQuestionAnswer('Test Question 13','MultiSelect2',13,'Rush Request');
        eventBuilderList.add(testQuestion13);
        Event_Builder_Survey_Q_A__c testQuestion14 = TestUtil.createEventBuilderQuestionAnswer('Test Question 14','Text Area',14,'Rush Request');
        eventBuilderList.add(testQuestion14);
        Event_Builder_Survey_Q_A__c testQuestion15 = TestUtil.createEventBuilderQuestionAnswer('Test Question 15','',15,'Rush Request');
        eventBuilderList.add(testQuestion15);
        Event_Builder_Survey_Q_A__c testQuestion16 = TestUtil.createEventBuilderQuestionAnswer('Test Question 16','Attachment1',16,'Rush Request');
        eventBuilderList.add(testQuestion16);
        Event_Builder_Survey_Q_A__c testQuestion17 = TestUtil.createEventBuilderQuestionAnswer('Test Question 17','Attachment2',17,'Rush Request');
        eventBuilderList.add(testQuestion17);
        
        // Scope Request Survey Questions.
        Event_Builder_Survey_Q_A__c testQuestionScopeReq1 = TestUtil.createEventBuilderQuestionAnswer('Test Question 1','Text',1,'Scope Request');
        eventBuilderList.add(testQuestionScopeReq1);
        Event_Builder_Survey_Q_A__c testQuestionScopeReq2 = TestUtil.createEventBuilderQuestionAnswer('Test Question 2','Text',2,'Scope Request');
        eventBuilderList.add(testQuestionScopeReq2);
        Event_Builder_Survey_Q_A__c testQuestionScopeReq3 = TestUtil.createEventBuilderQuestionAnswer('Test Question 3','Country Name',3,'Scope Request');
        eventBuilderList.add(testQuestionScopeReq3);
        Event_Builder_Survey_Q_A__c testQuestionScopeReq4 = TestUtil.createEventBuilderQuestionAnswer('Test Question 4','Text',4,'Scope Request');
        eventBuilderList.add(testQuestionScopeReq4);
        Event_Builder_Survey_Q_A__c testQuestionScopeReq5 = TestUtil.createEventBuilderQuestionAnswer('Test Question 5','Text Area',5,'Scope Request');
        eventBuilderList.add(testQuestionScopeReq5);
        Event_Builder_Survey_Q_A__c testQuestionScopeReq6 = TestUtil.createEventBuilderQuestionAnswer('Test Question 6','DateTime',6,'Scope Request');
        eventBuilderList.add(testQuestionScopeReq6);
        Event_Builder_Survey_Q_A__c testQuestionScopeReq7 = TestUtil.createEventBuilderQuestionAnswer('Test Question 7','DateTime',7,'Scope Request');
        eventBuilderList.add(testQuestionScopeReq7);
        Event_Builder_Survey_Q_A__c testQuestionScopeReq8 = TestUtil.createEventBuilderQuestionAnswer('Test Question 8','MultiSelect1',8,'Scope Request');
        eventBuilderList.add(testQuestionScopeReq8);
        Event_Builder_Survey_Q_A__c testQuestionScopeReq9 = TestUtil.createEventBuilderQuestionAnswer('Test Question 9','Picklist - Yes/No',9,'Scope Request');
        eventBuilderList.add(testQuestionScopeReq9);
        insert eventBuilderList;
    }
    
    static testMethod void loadScopeRequestSurvey(){
        System.runAs(depUser){
            setupData();            
            Test.startTest();
            apexpages.currentpage().getparameters().put('surveyType','scopeRequest');
            apexpages.currentpage().getparameters().put('id',acc.Id);               
            ScopeRequestSurvey_Cont contObj = new ScopeRequestSurvey_Cont();
            // User enters on the Scope Request First Page.
            contObj.respondentFirstName = 'Test 1';
            contObj.respondentLastName = 'Test 2';
            contObj.respondentEmailAddress = 'test@test.com';
            // Selects the continue button after filling some information.
            contObj.scopeRequestStartPage();
            contObj.getCountries();
            contObj.getAnswers();
            contObj.selectedMultiSelect1Question = 'Yes';
            contObj.selectedMultiSelectYesNoQuestion = 'Test Details';
            contObj.MultiSelect1QuestionVisibility();
            contObj.surQuestnAnsList[0].Answer__c = 'Test Account';
            contObj.surQuestnAnsList[1].Answer__c = 'Test Planner Name';
            contObj.surQuestnAnsList[2].Answer__c = 'Test Country Name';
            contObj.surQuestnAnsList[3].Answer__c = 'Test Opportunity Link';
            contObj.surQuestnAnsList[4].Answer__c = 'Test Registration Link';
            contObj.surQuestnAnsList[5].Answer__c = String.valueOf(System.now());
            contObj.surQuestnAnsList[6].Answer__c = String.valueOf(System.now());
            contObj.surQuestnAnsList[7].Answer__c = 'Yes';
            contObj.surQuestnAnsList[8].Answer__c = 'Test Detail';
            contObj.scopeRequestFinish();
            contObj.scopeRequestCancel();            
            Test.stopTest();
        }
    }
    
    static testMethod void previewScopeRequestSurvey(){
        System.runAs(depUser){
            setupData();   
            List<EB_Agent_Profile__c> EBObjList = new List<EB_Agent_Profile__c>();
            for(EB_Agent_Profile__c AssignRec : [Select Id,Agent_Name__c,Agent_Score__c,Last_Project_Assignment__c,of_Projects__c,of_Projects_Agent__c,Max_Workload_Agent_Hrs__c,Max_of_Projects_Per_Week__c,Current_Assignment__c,Current_Work_Load_hrs__c,of_Simple_Projects__c,of_Medium_Projects__c,Millisecond__c,of_Advanced_Projects__c,of_Complex_Projects__c from EB_Agent_Profile__c where Is_also_Handling_Scope_Request__c = true AND User_Active__c = true Order By Agent_Score__c,Last_Project_Assignment__c]){
                AssignRec.Is_also_Handling_Scope_Request__c = false;
                EBObjList.add(AssignRec);
            }
            update EBObjList;
            Test.startTest();
            apexpages.currentpage().getparameters().put('surveyType','scopeRequest');
            apexpages.currentpage().getparameters().put('id',acc.Id);   
            ScopeRequestSurvey_Cont contObj = new ScopeRequestSurvey_Cont();
            // User enters on the Scope Request First Page.
            contObj.respondentFirstName = 'Test 1';
            contObj.respondentLastName = 'Test 2';
            contObj.respondentEmailAddress = 'test@test.com';
            // Selects the continue button after filling some information.
            contObj.scopeRequestStartPage();
            contObj.getCountries();
            contObj.surQuestnAnsList[0].Answer__c = 'Test Account';
            contObj.surQuestnAnsList[1].Answer__c = 'Test Planner Name';
            contObj.surQuestnAnsList[2].Answer__c = 'Test Country Name';
            contObj.surQuestnAnsList[3].Answer__c = 'Test Opportunity Link';
            contObj.surQuestnAnsList[4].Answer__c = 'Test Registration Link';
            contObj.surQuestnAnsList[5].Answer__c = String.valueOf(System.now());
            contObj.surQuestnAnsList[6].Answer__c = String.valueOf(System.now());
            contObj.scopeRequestFinish();
            contObj.scopeRequestCancel();
            List<Internal_Survey_for_EB__c> InterSurveyFOrEB = [Select Id from Internal_Survey_for_EB__c Where Account__c =:acc.Id];
            apexpages.currentpage().getparameters().put('surveyType','test'); 
            apexpages.currentpage().getparameters().put('id',InterSurveyFOrEB[0].Id); 
            ScopeRequestSurvey_Cont contObj2 = new ScopeRequestSurvey_Cont();  
            Test.stopTest();
        }
    }    
    
    static testMethod void loadRushRequestSurvey(){
        System.runAs(depUser){
            setupData();            
            Test.startTest();
            apexpages.currentpage().getparameters().put('surveyType','rushRequest');
            apexpages.currentpage().getparameters().put('id',acc.Id);               
            RushRequestSurvey_Cont contObj = new RushRequestSurvey_Cont();
            // User enters on the Scope Request First Page.
            contObj.respondentFirstName = 'Test 1';
            contObj.respondentLastName = 'Test 2';
            contObj.respondentEmailAddress = 'test@test.com';
            // Selects the continue button after filling some information.
            contObj.rushRequestStartPage();
            contObj.getCountries();
            contObj.getAnswers();
            contObj.getMultiSelect2Answers();
            contObj.getComplexities();
            contObj.getAnswers();
            contObj.selectedCountry = 'India';
            contObj.selectedComplexity = 'Simple';
            contObj.selectedMultiSelect1Question = 'Yes';
            contObj.MultiSelect1QuestionVisibility();
            contObj.selectedMultiSelect2Question = 'Paid';
            contObj.MultiSelect2QuestionVisibility();
            contObj.selectedMultiSelect1Question = '';
            contObj.MultiSelect1QuestionVisibility();
            contObj.selectedMultiSelect2Question = 'test';
            contObj.MultiSelect2QuestionVisibility();
            contObj.surQuestnAnsList[0].Answer__c = 'Test Account';
            contObj.surQuestnAnsList[1].Answer__c = 'Test Planner Name';
            contObj.surQuestnAnsList[2].Answer__c = 'Test Country Name';
            contObj.surQuestnAnsList[3].Answer__c = 'Test Opportunity Link';
            contObj.surQuestnAnsList[4].Answer__c = 'Test Registration Link';
            contObj.surQuestnAnsList[5].Answer__c = String.valueOf(System.now());
            contObj.surQuestnAnsList[6].Answer__c = String.valueOf(System.now());
            contObj.rushRequestSubmit();
            contObj.attachment1.Name='Unit Test Attachment';
            contObj.attachment1.body=Blob.valueOf('Unit Test Attachment Body');
            contObj.attachment2.Name='Unit Test Attachment';
            contObj.attachment2.body=Blob.valueOf('Unit Test Attachment Body');
            contObj.uploadAttachments();
            contObj.submitSurvey();  
            
            List<Internal_Survey_for_EB__c> InterSurveyFOrEB = [Select Id from Internal_Survey_for_EB__c Where Account__c =:acc.Id];
            apexpages.currentpage().getparameters().put('surveyType','test'); 
            apexpages.currentpage().getparameters().put('id',InterSurveyFOrEB[0].Id); 
            RushRequestSurvey_Cont contObj2 = new RushRequestSurvey_Cont();  
            
            Test.stopTest();
        }
    }
}