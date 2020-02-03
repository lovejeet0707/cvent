public class LitmosProvisionClass {
    public String Email { get; set; }
    public List<User> userList{get;set;}
    String userQuery;
    Set<Id> userSet;
    public Boolean showUserList {get;set;}
    public Boolean showNoUserMessage {get;set;}
    public LitmosProvisionClass(){
        showUserList = false;
        showNoUserMessage = false;
    }
    public void SearchUser() {
        userQuery = 'SELECT Id,Name,Contact.Account.Name,ShowLitmosTab__c,Email,Litmos__Sync_Litmos__c,Litmos__Litmos_Activated__c,Litmos__LitmosUserId__c FROM User WHERE IsportalEnabled = TRUE AND ISACTIVE = TRUE AND ProfileId = \''+'00eo00000016QNc'+'\''+' AND Email = \''+Email+'\'';
        userList = new List<User>();
        userList = Database.query(userQuery);
        if(userList.size()>0)
        {
            showUserList = true;
            showNoUserMessage = false;
        }
        else
        {
            showUserList = false;
            showNoUserMessage = true;
        }
    }
    public void SyncLitmos(){
        update userList;
        userSet = new Set<Id>();
        For(User userRec : userList)
        {
            userSet.add(userRec.Id);
        }
        if(userSet.size()>0)
            AssignPermissionSet(userSet);
    }
    @future
    public static void AssignPermissionSet(Set<Id> userSet){
        
        List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
        if(userSet.size()>0){
            For(PermissionSetAssignment permissionObj : [SELECT AssigneeId,Id,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId IN : userSet AND PermissionSetId = '0PS1N000000W22o'])
            {
                userSet.remove(permissionObj.AssigneeId);
            }
        }
        if(userSet.size()>0)
        {
            For(Id userId : userSet){
                PermissionSetAssignment perSetAssign = new PermissionSetAssignment();
                perSetAssign.AssigneeId = userId;
                perSetAssign.PermissionSetId = '0PS1N000000W22o';
                permissionSetAssignmentList.add(perSetAssign);
            } 
        }
        if(permissionSetAssignmentList.size()>0)
            insert permissionSetAssignmentList;
    }
   
}