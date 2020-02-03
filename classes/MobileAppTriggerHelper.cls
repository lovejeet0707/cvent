public class MobileAppTriggerHelper 
{
    public static void updateSurveyDateOnMobileApp(List<Mobile_Card__c> mobileCards,Map<Id,Mobile_Card__c> oldMap)
    {
        Map<Id,Mobile_Card__c> mobMap = new Map<Id,Mobile_Card__c>();
        List<Contact> contactList = new List<Contact>();
        List<Contact> updateContacts = new List<Contact>();
        
        /*Map<Id,Mobile_Card__c> testCase = new Map<Id,Mobile_Card__c>();
Map<Id,User> emailCase = new Map<Id,User>();
Id profileId=userinfo.getProfileId();
String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();*/
        
        for(Mobile_Card__c cs : mobileCards){
            if(cs.Primary_Contact__c!=null && cs.Survey_Invitation_Sent__c!=null && (cs.Survey_Invitation_Sent__c!=oldMap.get(cs.id).Survey_Invitation_Sent__c)){
                mobMap.put(cs.Primary_Contact__c,cs);
            }
        }
        if(mobMap.size()>0){
            contactList = [Select /*Profile_Name__c,*/Last_Experiential_Survey_Invitation__c from Contact where id in : mobMap.keySet()];//UD:Commented for FP:4thApril
        }    
        for(Contact c : contactList){
            c.Last_Experiential_Survey_Invitation__c = mobMap.get(c.id).Survey_Invitation_Sent__c;
            updateContacts.add(c);
        }
        
        if(updateContacts.size()>0)
            update updateContacts;
    }
    //Added By Mohsin
    public static void crowdCompassChatterAlert(Map<Id,Mobile_Card__c> newMap,Map<Id,Mobile_Card__c> oldMap)
    {
        Id recordTypeId = Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByName().get('CrowdCompass').getRecordTypeId();   //Getting "CrowdCompass" record type id
        List<FeedItem> posts = new List<FeedItem>();
        Map<Id,Id> mapOfOppIdAndMobileCard = new Map<Id,Id>();
        Map<Id,Id> mapOfUserIdAndMobileCard = new Map<Id,Id>();
        Map<Id,Opportunity> mapOfMobileCardAndOppName = new Map<Id,Opportunity>();
        Map<Id,String> mapOfMobileCardAndUserName = new Map<Id,String>();
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        for(Mobile_Card__c mobileCard : newMap.values())
        {
            if(mobileCard.RecordTypeId == recordTypeId && (oldMap == NULL || mobileCard.OwnerId != oldMap.get(mobileCard.id).OwnerId) && mobileCard.Contract_Account_New__c != NULL && mobileCard.Opportunity__c != NULL)
            {
                mapOfOppIdAndMobileCard.put(mobileCard.Opportunity__c,mobileCard.Id);
                mapOfUserIdAndMobileCard.put(mobileCard.OwnerId,mobileCard.Id);
            }
        }
        for(Opportunity opp : [select id,Name,Owner.Id from Opportunity where Id IN :mapOfOppIdAndMobileCard.keySet()])
        {
            mapOfMobileCardAndOppName.put(mapOfOppIdAndMobileCard.get(opp.Id),opp);
        }
        
        System.debug('mapOfMobileCardAndOppName>>>'+mapOfMobileCardAndOppName);
        for(User u : [select id,Name from User where Id IN :mapOfUserIdAndMobileCard.keySet()])
        {
            ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
            messageInput.messageSegments = new list<ConnectApi.MessageSegmentInput>();
            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = 'Hello ';
            messageInput.messageSegments.add(textSegment);
            
            ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
            mentionSegment.id = mapOfMobileCardAndOppName.get(mapOfUserIdAndMobileCard.get(u.Id)).Owner.Id;
            messageInput.messageSegments.add(mentionSegment);
            
            ConnectApi.TextSegmentInput textSegment1 = new ConnectApi.TextSegmentInput();
            textSegment1.text = ', The mobile card for '+mapOfMobileCardAndOppName.get(mapOfUserIdAndMobileCard.get(u.Id)).Name+' has been created and can be found here: '+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+mapOfUserIdAndMobileCard.get(u.Id)+' and the Mobile Card Owner is '+u.Name;
            messageInput.messageSegments.add(textSegment1);
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            input.body = messageInput;
            input.feedElementType = ConnectApi.FeedElementType.FeedItem;
            input.subjectId = newMap.get(mapOfUserIdAndMobileCard.get(u.Id)).Contract_Account_New__c;
            
            //Add post to batchInputs list for bulk posting
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
            batchInputs.add(batchInput);
        }
        if(!batchInputs.isEmpty() && batchInputs.size() > 0 && CheckRecursive.runThirtyFour())
            ConnectApi.ChatterFeeds.postFeedElementBatch(null,batchInputs);
        
    }
    
    public static void mobileAppChatterFieldNotificationforUpdate(List<Mobile_Card__c> mobileCards,Map<Id,Mobile_Card__c> oldMap)
    {
        List<Mobile_Card__c> newmobileCards = new List<Mobile_Card__c>();
        for(Mobile_Card__c cs : mobileCards)
        {
            if(cs.Oversold__c == true && cs.Oversold__c!=oldMap.get(cs.id).Oversold__c)
                newmobileCards.add(cs);
        }
        
        if(CheckRecursive.runThirtyFive() && newmobileCards.size() > 0 && !newmobileCards.isEmpty())
        {
            ChatterPostNotification.chatterPost(newmobileCards,'MobileApp','Oversold__c','Contract_Account_New__c',false,'Mobile App');
        } 
    }
    public static void mobileAppChatterFieldNotificationforInsert(List<Mobile_Card__c> mobileCards)
    {
        if(CheckRecursive.runFortyFive())
        {
            ChatterPostNotification.chatterPost(mobileCards,'MobileApp','Oversold__c','Contract_Account_New__c',false,'Mobile App');
        } 
    }
}