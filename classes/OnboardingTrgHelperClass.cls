/* Written By Udita : to send survey to onboarding contact*/
public class OnboardingTrgHelperClass{
  
  public void OnAfterUpdate(map<id,Onboarding__c> onboardOldMap,map<id,Onboarding__c> onboardNewMap){
     if(CheckRecursive.runTwentySeven()){
      if(Label.isOnboardingTrgUpdate == 'True'){
       sendPOCSurvey(onboardOldMap,onboardNewMap);
      }
     } 
  }
    
  public static void sendPOCSurvey(map<id,Onboarding__c> onboardOldMap,map<id,Onboarding__c> onboardNewMap){
       List<Messaging.SingleEmailMessage> emailMsgList = new List<Messaging.SingleEmailMessage>(); 
       Map<Id,Id> onboardingIdsVStemplateId =  new Map<Id,Id>();
       id ExistPasskeyHotelRecId = Schema.SObjectType.Onboarding__c.getRecordTypeInfosByName().get('Passkey Hotel - Existing Integration').getRecordTypeId();
       id NewPasskeyHotelRecId = Schema.SObjectType.Onboarding__c.getRecordTypeInfosByName().get('Passkey Hotel - New PMS').getRecordTypeId();
       Id btDemandFormRecId = Schema.SObjectType.Onboarding__c.getRecordTypeInfosByName().get('BT Demand Form').getRecordTypeId();
       map<id,Onboarding__c> onbUpdateMap = new map<id,Onboarding__c>();
       Id templateId = [Select Id From EmailTemplate Where DeveloperName =: Label.PasskeyHotelOnboarding].Id;
       Id templateId1 = [Select Id From EmailTemplate Where DeveloperName =: Label.BTDemandFormCSATSurveyNew].Id;
       for(Onboarding__c onb  : onboardNewMap.values()){
          system.debug('-----ExistPasskeyHotelRecId'+ExistPasskeyHotelRecId);
          system.debug('-----NewPasskeyHotelRecId'+NewPasskeyHotelRecId);
          system.debug('-----Status__c '+onb.Status__c );
          system.debug('-----onboardOldMap.get(onb.Id).Status__c '+ onboardOldMap.get(onb.Id).Status__c);
          if(onb.Status__c !=onboardOldMap.get(onb.Id).Status__c && onb.Status__c =='Closed')
          {
            if(onb.RecordtypeId == ExistPasskeyHotelRecId || onb.RecordtypeId == NewPasskeyHotelRecId)
              onboardingIdsVStemplateId.put(onb.id,templateId);
            else if(onb.RecordtypeId == btDemandFormRecId)
              onboardingIdsVStemplateId.put(onb.id,templateId1);
          }
       }        
      if(onboardingIdsVStemplateId.size() > 0 && !onboardingIdsVStemplateId.isEmpty()){
         System.debug('onboardingIdsVStemplateId>>>'+onboardingIdsVStemplateId);
         //List<Onboarding_Contact__c> objs = [select id,Contact__c,Contact__r.email,Onboarding__r.Survey_Invitation_Sent__c,Onboarding__c from Onboarding_Contact__c where Onboarding__c in :onboardingIdsVStemplateId.keySet() and Type__c = 'POC' ];
         //System.debug('objs>>>'+objs);
          for(Onboarding_Contact__c onbCon : [select id,Contact__c,Contact__r.email,Onboarding__r.Survey_Invitation_Sent__c from Onboarding_Contact__c  where Onboarding__c in :onboardingIdsVStemplateId.keySet() and Type__c = 'POC']){
            Messaging.SingleEmailMessage msg1 =  new Messaging.SingleEmailMessage();  
            msg1.setTemplateId(onboardingIdsVStemplateId.get(onbCon.Onboarding__c));
            msg1.setToAddresses(new List<String>{onbCon.Contact__r.email});  
            System.debug('msg1*****'+msg1);
            msg1.setOrgWideEmailAddressId(Label.Cvent_Client_Services);
            msg1.setSaveAsActivity(false);
            msg1.setTargetObjectId(onbCon.Contact__c);
            msg1.setWhatId(onbCon.id);
            msg1.setUseSignature(false);
            emailMsgList.add(msg1);
            Onboarding__c onbUpdate = new Onboarding__c(id=onbCon.Onboarding__c);
            onbUpdate.Survey_Invitation_Sent__c = system.now();   
            onbUpdateMap.put(onbUpdate.id,onbUpdate);  
             System.debug('onbCon>>>'+onbCon);
         }
         
          if(emailMsgList.size()>0){
            Messaging.sendEmail(emailMsgList);
            if(!onbUpdateMap.isEmpty()){
              update onbUpdateMap.values();
            }
          }  
      }
  }
}