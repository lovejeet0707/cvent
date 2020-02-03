/* ===============================
AUTHOR     :     Udita Dwivedi
CREATED DATE   : 12 May 2018
PURPOSE     :    It marks the portal user is gdpr true when its related contact is marked GDPR.. It is called from class - trg_GDPRContactTrg
TEST CLASS :     GDPRCentralRepositoryHandler_Test
============================= 
*/

public class GDPRCentralRepositoryHandler_User{
   @future
   public static void updateGDPR_User(set<id> userIds,set<id> contactIds){
     list<user> newUserList = new list<user>();
     newUserList=[select id,FirstName,LastName,Username,MobilePhone,IsPortalSelfRegistered,IsActive,Email,ContactId,Is_GDPR__c,Phone,Title from user where id in :userIds and  ContactId in : contactIds and IsPortalEnabled = true];
   
     for(User UserObj :newUserList){
            UserObj.Is_GDPR__c = true;
            UserObj.IsActive=false;           
     }
     if(newUserList.size() > 0){
      update newUserList;
     }   
   } 
}