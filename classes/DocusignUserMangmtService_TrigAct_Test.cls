/*
 * Author : Sandeep Kumar
 * Date : 03 Jan, 2018
 * Description : It tests below mentioned classes
 * 1) DocusignUserMangementService_TrigAct
*/
@isTest
public class DocusignUserMangmtService_TrigAct_Test{
    private static User docuSignUser;
    private static Id userProfieId = UserProfileUtil.getProfileIDByName('System Administrator');
    
    static testmethod void createDocuSignUser(){
        // Create DocuSignUser Account
        docuSignUser = TestUtil.createUser(userProfieId, 'testdocusignuser@cvent.com');
        docuSignUser.DocuSign_User_Id__c = '81aa80b7-390e-4e06-ab74-2f70a1252faf';
        insert docuSignUser;
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new DocusignUserMangementServiceMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Test.startTest();
        // Deactivate DocuSignUser Account        
        User docuSignUserToUpdate = [Select Id from user Where Id = :docuSignUser.Id];
        docuSignUserToUpdate.IsActive = false;
        update docuSignUserToUpdate;
        Test.stopTest();
    }
}