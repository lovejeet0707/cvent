@isTest
public class coachingSessionQuestionClassTest 
{
    static testMethod void testMethod1()
    {
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Sherlin', LastName='Manager', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtestmanager@testorg.com');
        insert user1;
        
         User user2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Sherlin', LastName='Lauren', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com', ManagerId = user1.Id);
        insert user2;
        
        Coaching_Session__c coachingSession = new Coaching_Session__c();
        coachingSession.Status__c = 'Draft';
        coachingSession.User_Evaluated__c = user2.Id;
        coachingSession.Session_Type__c = 'Client Success Coaching';
        coachingSession.PC_CSC_Team__c = 'Abstract';
        coachingSession.Is_this_a_P2P_coaching__c = 'Yes';
        coachingSession.Customer_Phone_and_Email_verified__c = 'Yes';
        coachingSession.Platform_Service_Discussed__c = 'Yes';
        coachingSession.Was_this_a_transfer_call__c = 'Yes';
        coachingSession.Used_during_a_calibration_session__c = 'Yes';
        coachingSession.Solvable_through_the_KB__c = 'Yes';
        coachingSession.Lead_Gen_opportunities_identified__c = 'Yes';
        coachingSession.Synopsis__c = 'Yes';
        coachingSession.X1_1_feedback_delivered__c = 'Yes';
        coachingSession.Case_Type__c = 'Chat';
        insert coachingSession;
        
        Coaching_Session_Question__c coachingQuestion = new Coaching_Session_Question__c();
        coachingQuestion.Coaching_Question_Category__c = 'Noncritical';
        coachingQuestion.Coaching_Session__c = coachingSession.id;
        insert coachingQuestion;
         
        PageReference pageRef = Page.CoachingSession;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(coachingSession.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(coachingSession);
        //coachingSessionQuestionClass testAccPlan = new SendEmailReceipt(sc);
        coachingSessionQuestionClass cs = new coachingSessionQuestionClass(sc);
        cs.savecoachingSessionQuestion();
        cs.editcoachingSessionQuestion();
    }
}