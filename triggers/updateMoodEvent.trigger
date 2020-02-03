/*
//////////////////////////////////////
//      @author Vaibhav Jain     //
/////////////////////////////////////
Version :   1.0
Version :   2.0
Date : 14th March 2016
Description : Add link for mood record
Apex Test Clas : TestActivityTriggerEvent
*/
trigger updateMoodEvent on Event (after insert, after update) {

    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    }
    
    Map<Id,Event> eventMap = new Map<Id,Event>();
    Map<Id,Event> testEvent = new Map<Id,Event>();
    Map<Id,User> emailEvent = new Map<Id,User>();
    Id profileId=userinfo.getProfileId();
    String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
    Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Event.getRecordTypeInfosById();
    for(Event t : Trigger.New){
        if(t.whoId!=null && string.valueOf(t.WhoId).startsWith('003')&& t.Description!=null && t.Mood__c!=null)
            eventMap.put(t.whoId,t);
            testEvent.put(t.ownerId,t);
            system.debug('@@@@new event : '+t.whoId);
            system.debug('@@@@new event : '+t.ownerId);
            system.debug('@@@@testEvent : '+testEvent);
    }
    if(testEvent.size()>0){
        for(User u : [Select Manager_Email__c, Name from user where id in: testEvent.keyset()]){
            emailEvent.put(testEvent.get(u.id).whoId,u);
            system.debug('@@@@emailEvent: '+emailEvent);
        }
    }    
    List<Contact> updateContacts = new List<Contact>();
    boolean flag=false;
    system.debug('######event map'+eventMap.size());
    if(eventMap.size()>0){
        for(Contact c : [Select Mood_Level__c/*,Profile_Name__c*/ from Contact where id in : eventMap.keySet()]){//UD:Commented for FP:4thApril
           // c.Profile_Name__c = profileName;//UD:Commented for FP:4thApril
            if(Trigger.isUpdate){
                system.debug('#####ENTERING UPDATE');
                Event beforeUpdateMood = System.Trigger.oldMap.get(eventMap.get(c.id).id);
                if(beforeUpdateMood.Mood__c != eventMap.get(c.id).Mood__c){
                    c.Mood_Level__c = Decimal.valueof(eventMap.get(c.id).Mood__c.substring(0,1));
                    if((eventMap.get(c.id).Mood__c=='1 - Irate')||(eventMap.get(c.id).Mood__c=='2 - Frustrated')){
                        String urlString = System.URL.getSalesforceBaseUrl().toExternalForm();
                        string Url='<a href=' + urlString + '/' + eventMap.get(c.id).id + '>Please click on this Link to review the activity and take the appropriate action.</a>';
                        c.Mood_Text__c = eventMap.get(c.id).Mood__c.substring(4,Integer.valueof((eventMap.get(c.id).Mood__c).length()));
                        //c.Manager_Email__c = emailEvent.get(c.id).Manager_Email__c;//UD:Commented for FP:4thApril
                        /*c.Template_FIelds__c = 'Product: ' + rtMap.get(eventMap.get(c.id).RecordTypeId).getName() +'<br>' +
                           'Mood Origin: Task' + '<br>' + 
                           'Mood Creator: ' + emailEvent.get(c.id).Name + '<br>' +
                           'Mood Set Date/Time: ' + system.now() + '<br>' +
                           'Subject: '+ eventMap.get(c.id).Subject + '<br>' +
                           'Primary Reason for mood: '+ eventMap.get(c.id).Primary_Reason_for_Mood_Driver__c + '<br>' +
                           'Driver: ' + eventMap.get(c.id).Reason__c + '<br>' +
                            Url + '<br>';*///UD:Commented for FP:4thApril
                        // Add link for mood record
                        c.Mood_Changed_From_Id__c = null;
                        if(eventMap.get(c.id).WhatId!=null)
                            c.Mood_Changed_From_Id__c = eventMap.get(c.id).WhatId;
                        // Add link for mood record
                    }
                    flag=true;
                }
                system.debug('#####EXITING UPDATE');
            }    
            else{
                system.debug('#####ENTERING INSERT');
                c.Mood_Level__c = Decimal.valueof(eventMap.get(c.id).Mood__c.substring(0,1));
                if((eventMap.get(c.id).Mood__c=='1 - Irate')||(eventMap.get(c.id).Mood__c=='2 - Frustrated')){
                    String urlString = System.URL.getSalesforceBaseUrl().toExternalForm();
                    string Url='<a href=' + urlString + '/' + eventMap.get(c.id).id + '>Please click on this Link to review the activity and take the appropriate action.</a>';
                    c.Mood_Text__c = eventMap.get(c.id).Mood__c.substring(4,Integer.valueof((eventMap.get(c.id).Mood__c).length()));
                    //c.Manager_Email__c = emailEvent.get(c.id).Manager_Email__c;//UD:Commented for FP:4thApril
                    /*c.Template_FIelds__c = 'Product: ' + rtMap.get(eventMap.get(c.id).RecordTypeId).getName() +'<br>' +
                       'Mood Origin: Task' + '<br>' + 
                       'Mood Creator: ' + emailEvent.get(c.id).Name + '<br>' +
                       'Mood Set Date/Time: ' + system.now() + '<br>' +
                       'Subject: '+ eventMap.get(c.id).Subject + '<br>' +
                       'Primary Reason for mood: '+ eventMap.get(c.id).Primary_Reason_for_Mood_Driver__c + '<br>' +
                       'Driver: ' + eventMap.get(c.id).Reason__c + '<br>' +
                        Url + '<br>';*///UD:Commented for FP:4thApril
                    // Add link for mood record
                    c.Mood_Changed_From_Id__c = null;
                    if(eventMap.get(c.id).WhatId!=null)
                        c.Mood_Changed_From_Id__c = eventMap.get(c.id).WhatId;
                    // Add link for mood record
                }
                flag=true;
                system.debug('#####EXITING INSERT');
            }
        if(flag==true)
            updateContacts.add(c);
        }    
    }
    if(updateContacts.size()>0)
        update updateContacts;
}