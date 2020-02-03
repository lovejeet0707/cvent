public class doceboUserTrgHandler{
  
  public void OnBeforeInsert(List<docebo_v3__DoceboUser__c> newDocuboUsers){
     updateDoceboContact(newDocuboUsers,null);
  }
  
  public void OnBeforeUpdate(List<docebo_v3__DoceboUser__c> newDocuboUsers, Map<id,docebo_v3__DoceboUser__c> oldDoceboUserMap){
     updateDoceboContact(newDocuboUsers,oldDoceboUserMap);
  }
   
  public void updateDoceboContact(List<docebo_v3__DoceboUser__c> newDocuboUsers, Map<id,docebo_v3__DoceboUser__c> oldDoceboUserMap){
     set<id> userIds = new set<id>();
     Map<id,User> userMap = new Map<id,User>();
     for(docebo_v3__DoceboUser__c doc : newDocuboUsers){
       if((doc.docebo_v3__User__c != NULL && oldDoceboUserMap== NULL) || (!oldDoceboUserMap.isEmpty() && doc.docebo_v3__User__c !=oldDoceboUserMap.get(doc.Id).docebo_v3__User__c && doc.docebo_v3__User__c != NULL)){
          userIds.add(doc.docebo_v3__User__c);   
       }    
     }
     if(userIds.size() > 0){
       for(User u : [select id,ContactId from User where ID IN :userIds]){
         userMap.put(u.id,u);
       }    
       for(docebo_v3__DoceboUser__c doc : newDocuboUsers){
         if((doc.docebo_v3__User__c != NULL && oldDoceboUserMap== NULL) || (!oldDoceboUserMap.isEmpty() && doc.docebo_v3__User__c !=oldDoceboUserMap.get(doc.Id).docebo_v3__User__c && doc.docebo_v3__User__c != NULL)){
           User u= userMap.get(doc.docebo_v3__User__c);
           doc.docebo_v3__Contact__c = u.ContactId;
         }    
       }  
     }
  }
}