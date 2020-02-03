@istest
public class GroupControllerTest {
    
    
    @testsetup
    static void createCustomSetting(){
        
        //Custom Setting to manage Admins to allow Add/Delete Groups.
        Success_Group_Admins__c sAdmin = new Success_Group_Admins__c();
        sAdmin.Name = 'Test User';
        sAdmin.User_ID_15_Digit__c = userInfo.getUserId().substring(0,15);
        insert sAdmin;
    }
    
    static testmethod void createRegionalGroup(){
        
        GroupsController gController = new GroupsController();
        gController.groupName = 'Chatter Test Group';
        gController.groupCategory = 'Regional';
        gController.groupDescrition = 'Test Description';
        gController.groupType = 'Public';
        
       	//Create Regional Group
        gController.CreateGroup();
        gController.GetRecords();
        gController.getRegionalGroupList();
        
    }
    
    
    static testmethod void createVerticalGroup(){
     
        GroupsController gController = new GroupsController();
        gController.groupName = 'Chatter Test Group';
        gController.groupCategory = 'Vertical';
        gController.groupDescrition = 'Test Description';
        gController.groupType = 'Public';
        
        //Create Vertical Group
        gController.CreateGroup();
        gController.GetRecords();
        gController.getVerticalGroupList();
        
    }
    
    static testmethod void DeleteGroup(){

        GroupsController gController = new GroupsController();
        gController.groupName = 'Chatter Test Group';
        gController.groupCategory = 'Regional';
        gController.groupDescrition = 'Test Description';
        gController.groupType = 'Public';
        
       	//Create Regional Group
        gController.CreateGroup();
        
        
        gController.groupId = [Select Id From CollaborationGroup Limit 1].Id;
        gController.DeleteGroup();
        
    }

}