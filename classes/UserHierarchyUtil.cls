// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE : 06/28/2016
// PURPOSE     :  Get All Users aligned with Manager (Based on Downwards Hierarchy) For eg. IF user 'A' reports to 'B' and 'B' reports to 'C' , 'C' can get list of users A and B both. 
// TEST CLASS :   
// SPECIAL NOTES:
// ===============================
public class UserHierarchyUtil {
    
    public static Set<ID> getUsersByHierarchy(Id usId) {

        // get requested user's ManagerId
        Id userId = usId;
        // get all of the users underneath the Manager
        Set<Id> allSubUserIds = getAllSubUserIds(new Set<ID>{userId});
        // get all of the ids for the users in all Manager
        Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where 
          ID IN :allSubUserIds and isActive=true]);
        // return the ids as a set so you can do what you want with them
        return users.keySet();

  	}

  private static Set<ID> getAllSubUserIds(Set<ID> userIds) {

        Set<ID> currentUserIds = new Set<ID>();
    
        // get all of the users underneath the passed Manager
        for(User usr :[select Id from User where ManagerId 
          IN :userIds AND ManagerId != null and isActive=true])
        currentUserIds.add(usr.Id);
    
        // go fetch some more users!
        if(currentUserIds.size() > 0)
          currentUserIds.addAll(getAllSubUserIds(currentUserIds));

        return currentUserIds;

  }
    

}