/**** Written to update LMS Groups on User for Docebo : 4/15/2019****/
public class MobileAppTrgHandler{

   public void onAfterInsert(List<Mobile_Card__c > newValues){
    set<Id> ContactIds = new set<Id>();
    Map<id,User> userMap = new Map<id,User>();
    List<User> userUpdateList = new List<User>();
      for(Mobile_Card__c  mob : newValues){
        if((mob.RecordtypeId == Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByName().get('Mobile - Onboarding Lite').getRecordTypeId() || mob.RecordtypeId == Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByName().get('Mobile - Onboarding Standard').getRecordTypeId()) && mob.Primary_Contact__c != NULL){
           ContactIds.add(mob.Primary_Contact__c);
        }
      }    
      if(ContactIds.size() > 0){
        
         for(User u :[select id,LMS_Groups__c,ContactId from User where ContactID IN :ContactIds AND IsPortalEnabled = TRUE]){
            userMap.put(u.ContactId,u); 
         }
         for(Mobile_Card__c  mob : newValues){
           if((mob.RecordtypeId == Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByName().get('Mobile - Onboarding Lite').getRecordTypeId() || mob.RecordtypeId == Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByName().get('Mobile - Onboarding Standard').getRecordTypeId()) && mob.Primary_Contact__c != NULL){
               if(userMap.containsKey(mob.Primary_Contact__c)){
                   user u = userMap.get(mob.Primary_Contact__c);
                   if(u.LMS_Groups__c != NULL){
                     u.LMS_Groups__c = mob.RecordtypeId == Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByName().get('Mobile - Onboarding Lite').getRecordTypeId() ? u.LMS_Groups__c + ';' + 'CC Onboarding Lite'  : u.LMS_Groups__c + ';' + 'CC Onboarding Standard';}
                   else{
                     u.LMS_Groups__c = mob.RecordtypeId == Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByName().get('Mobile - Onboarding Lite').getRecordTypeId() ? 'CC Onboarding Lite'  : 'CC Onboarding Standard';
                     }
                     u.LMS_Sync_Date__c= system.today();
                     userUpdateList.add(u);
                   }
               }
           }
         } 
         if(userUpdateList.size() > 0){
           update userUpdateList;}   
      }       
   
}