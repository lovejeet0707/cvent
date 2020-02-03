/**
* Author : Sandeep Kumar
* Date : 25 April 2017
* Description : It tests below mentioned class
* 1) EBAgentProfileManualShare_TrigAct
*/
@isTest(seeAllData= false)
public class EBAgentProfileManualShare_TrigAct_Test {
    private static Id userProfieId = UserProfileUtil.getProfileIDByName('Customer Care Rep - Product Consultant EB Team');     
    private static User depUser = [Select Id, ProfileId from User where Name = 'CRM Deployment User'];
    
    // Test for the manualShareRead method
    static testMethod void testManualShareRead(){
        system.runAs(depUser){
            Test.startTest();        
            User usr = TestUtil.createUser(userProfieId);          
            insert usr;  
            
            EB_Agent_Profile__c EBAgentProfile1 = TestUtil.createEBAgentProfile('Test EB Agent Profile',usr.Id,'1');
            insert EBAgentProfile1;
            
            // Query job sharing records.
            List<EB_Agent_Profile__Share> jShrs = [SELECT Id, UserOrGroupId, AccessLevel, 
                                                   RowCause FROM EB_Agent_Profile__Share WHERE ParentId = :EBAgentProfile1.Id];
            
            // Test for only one manual share on job.
            System.assertEquals(jShrs.size(), 2, 'Set the object\'s sharing model to Private.');
            system.debug(jShrs[0]);
                
            // Test attributes of manual share.
           // System.assertEquals(jShrs[0].AccessLevel, 'Read');
            // System.assertEquals(jShrs[0].RowCause, 'Manual');
            // System.assertEquals(jShrs[0].UserOrGroupId, usr.Id);            
            Test.stopTest();
        }        
    }      
}