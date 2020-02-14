/**** Written to update LMS Groups on Contact for Docebo : 4/15/2019****/
public class MobileAppTrgHandler{

   public void onAfterInsert(List<Mobile_Card__c > newValues){
    set<Id> ContactIds = new set<Id>();
    Map<id,Contact> ContactMap = new Map<id,Contact>();
    List<Contact> ContactUpdateList = new List<Contact>();
      for(Mobile_Card__c  mob : newValues){
        if((mob.RecordtypeId == Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByName().get('Mobile - Onboarding Lite').getRecordTypeId() || mob.RecordtypeId == Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByName().get('Mobile - Onboarding Standard').getRecordTypeId()) && mob.Primary_Contact__c != NULL){
           ContactIds.add(mob.Primary_Contact__c);
        }
      }    
      if(ContactIds.size() > 0){
        
         for(Contact u :[select id,LMS_Groups__c from Contact where ID IN :ContactIds AND User_Profile_Name__c = 'Cvent Customer Community User']){
            ContactMap.put(u.id,u); 
         }
         for(Mobile_Card__c  mob : newValues){
           if((mob.RecordtypeId == Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByName().get('Mobile - Onboarding Lite').getRecordTypeId() || mob.RecordtypeId == Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByName().get('Mobile - Onboarding Standard').getRecordTypeId()) && mob.Primary_Contact__c != NULL){
               if(ContactMap.containsKey(mob.Primary_Contact__c)){
                   Contact u = ContactMap.get(mob.Primary_Contact__c);
                   if(u.LMS_Groups__c != NULL){
                     u.LMS_Groups__c = mob.RecordtypeId == Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByName().get('Mobile - Onboarding Lite').getRecordTypeId() ? u.LMS_Groups__c + ';' + 'CC Onboarding Lite'  : u.LMS_Groups__c + ';' + 'CC Onboarding Standard';}
                   else{
                     u.LMS_Groups__c = mob.RecordtypeId == Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByName().get('Mobile - Onboarding Lite').getRecordTypeId() ? 'CC Onboarding Lite'  : 'CC Onboarding Standard';
                     }
                     u.LMS_Sync_Contact__c = True;
                     ContactUpdateList.add(u);
                   }
               }
           }
         } 
         if(ContactUpdateList.size() > 0){
           update ContactUpdateList;}   
      }       
   
}