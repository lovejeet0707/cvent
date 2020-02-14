/*
//////////////////////////////////////
//      @author Vaibhav Jain     //
/////////////////////////////////////
Version :   1.0
Version :   2.0
Date : 14th March 2016
Description : Add link for mood record
*/
trigger updateMoodFrmCase on Case (after insert,after update) {

    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    } 

    
    Map<Id,Case> caseMap = new Map<Id,Case>();
    Map<Id,Case> testCase = new Map<Id,Case>();
    Map<Id,User> emailCase = new Map<Id,User>();
    Id profileId=userinfo.getProfileId();
    //String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
    Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();
    for(Case cs : Trigger.new){
        if(cs.ContactID!=null && cs.Mood__c!=null){
            caseMap.put(cs.ContactId,cs);
            testCase.put(UserInfo.getUserId(),cs);
        }
    }
    if(testCase.size()>0){
        for(User u : [Select Manager_Email__c,Name,Profile.Name from user where id in: testCase.keyset()]){
            emailCase.put(testCase.get(u.id).ContactId,u);
        }
    }
    List<Contact> updateContacts = new List<Contact>();
    boolean flag=false;
    if(caseMap.size()>0){
        for(Contact c : [Select Mood_Level__c/*,Profile_Name__c*/ from Contact where id in : caseMap.keySet()]){//UD:Commented for FP:4thApril
            //c.Profile_Name__c = emailCase.values()[0].Profile.Name;//UD:Commented for FP:4thApril
            if(Trigger.isUpdate){
                Case beforeUpdateMood = System.Trigger.oldMap.get(caseMap.get(c.id).id);
                system.debug('@@@@@beforeUpdateMood  : '+beforeUpdateMood);
                system.debug('@@@@@caseMap.get(c.id).Mood__c : '+caseMap.get(c.id).Mood__c);
                if(beforeUpdateMood.Mood__c != caseMap.get(c.id).Mood__c){
                    c.Mood_Level__c = Decimal.valueof(caseMap.get(c.id).Mood__c.substring(0,1));
                    if((caseMap.get(c.id).Mood__c=='1 - Irate')||(caseMap.get(c.id).Mood__c=='2 - Frustrated')){
                        String urlString = System.URL.getSalesforceBaseUrl().toExternalForm();
                        string Url='<a href=' + urlString + '/' + caseMap.get(c.id).id + '>Please click on this Link to review the case and take the appropriate action.</a>';
                        c.Mood_Text__c = caseMap.get(c.id).Mood__c.substring(4,Integer.valueof((caseMap.get(c.id).Mood__c).length()));
                       // c.Manager_Email__c = emailCase.get(c.id).Manager_Email__c;//UD:Commented for FP:4thApril
                        /*c.Template_FIelds__c = 'Product: ' + rtMap.get(caseMap.get(c.id).RecordTypeId).getName() +'<br>' +
                           'Mood Origin: Case' + '<br>' + 
                           'Mood Creator: ' + emailCase.get(c.id).Name + '<br>' +
                           'Subject: '+ caseMap.get(c.id).Subject + '<br>' +
                           'Primary Reason for mood: '+ caseMap.get(c.id).Primary_Reason_for_Mood_Driver__c + '<br>' +
                           'Driver: ' + caseMap.get(c.id).Reason__c + '<br>' +
                            Url + '<br>';*///UD:Commented for FP:4thApril
                        // Add link for mood record
                        c.Mood_Changed_From_Id__c = caseMap.get(c.id).Id;
                        // Add link for mood record
                    }
                   // c.Apex_context__c = true;//UD:Commented for FP:4thApril
                    flag=true;
                }
            }    
            else{
                    c.Mood_Level__c = Decimal.valueof(caseMap.get(c.id).Mood__c.substring(0,1));
                    if((caseMap.get(c.id).Mood__c=='1 - Irate')||(caseMap.get(c.id).Mood__c=='2 - Frustrated')){
                        String urlString = System.URL.getSalesforceBaseUrl().toExternalForm();
                        string Url='<a href=' + urlString + '/' + caseMap.get(c.id).id + '>Please click on this Link to review the case and take the appropriate action.</a>';
                        c.Mood_Text__c = caseMap.get(c.id).Mood__c.substring(4,Integer.valueof((caseMap.get(c.id).Mood__c).length()));
                       // c.Manager_Email__c = emailCase.get(c.id).Manager_Email__c;//UD:Commented for FP:4thApril
                        /*c.Template_FIelds__c = 'Product: ' + rtMap.get(caseMap.get(c.id).RecordTypeId).getName() +'<br>' +
                           'Mood Origin: Case' + '<br>' + 
                           'Mood Creator: ' + emailCase.get(c.id).Name + '<br>' +
                           'Subject: '+ caseMap.get(c.id).Subject + '<br>' +
                           'Primary Reason for mood: '+ caseMap.get(c.id).Primary_Reason_for_Mood_Driver__c + '<br>' +
                           'Driver: ' + caseMap.get(c.id).Reason__c + '<br>' +
                            Url + '<br>';*///UD:Commented for FP:4thApril
                        // Add link for mood record
                        c.Mood_Changed_From_Id__c = caseMap.get(c.id).Id;
                        // Add link for mood record
                    }
                   // c.Apex_context__c = true;//UD:Commented for FP:4thApril
                    flag=true;
            }
            if(flag==true)
              updateContacts.add(c);
        }
    }    
    if(updateContacts.size() > 0 && !updateContacts.isEmpty())
        update updateContacts;
}