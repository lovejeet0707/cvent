/*
    It is not anticipated that there will be a batch update for CRM Releases. So this trigger is intentionally written only for one record at a time 
*/
trigger CRM_Release_Trigger on ResourceProject__c (before update) {
    ResourceProject__c crmRelease = Trigger.new[0];     
    //Find all child Projects
    List<CRM_Project__c> projects = [select Id, Name, Status__c,Requestor__c, Requestor__r.Email, Requestor__r.FirstName, Requestor__r.LastName, CRM_Release__c from CRM_Project__c where CRM_Release__c=:crmRelease.Id];
    
    //Map<Id,String> userIdVsStatus=new Map<Id,String>();
    Set<Id> signOffRecievedUserIdSet=new Set<Id>();
    Set<Id> readyForUATsignOffRecievedUserIdSet=new Set<Id>();
    //Find all unique Requestors as there shall be only one email per requestor
    Set<Id> uniqueUsers = new Set<Id>();
    for(CRM_Project__c project: projects) {
        if(project.Status__c=='UAT Sign Off Received')
        {
            System.debug('#CheckPoint 1');
            signOffRecievedUserIdSet.add(project.Requestor__c);
        }else if(project.Status__c=='Ready For UAT'){
            readyForUATsignOffRecievedUserIdSet.add(project.Requestor__c);
        }
        
        if(!uniqueUsers.contains(project.Requestor__c)){
            uniqueUsers.add(project.Requestor__c);
        }
    }
    System.debug('#CheckPoint 2 UAT Sign Off UserId Set*******'+signOffRecievedUserIdSet);
    System.debug('#CheckPoint 3 uniqueUsers*******'+uniqueUsers);
    List<User> users = [select Id, Name, Email from User where Id IN: uniqueUsers];
    
    List<Cvent_Email_Notification__c> notifications = new List<Cvent_Email_Notification__c>();
    
    //Generate UAT Notification Email    
    If(crmRelease.Ready_for_UAT__c  != Trigger.oldMap.get(crmRelease.Id).Ready_for_UAT__c && crmRelease.Ready_for_UAT__c){
        for(User usr: users) {
            if(readyForUATsignOffRecievedUserIdSet.size()>0 && readyForUATsignOffRecievedUserIdSet.contains(usr.Id)){
            notifications.add(CventEmailNotificationHelper.createEmailNotification(usr.Id, usr.Name, 'Ready for UAT', usr.Email, 
                                                                    CventEmailNotificationHelper.SourceProcessName.ReleaseManagement, null, crmRelease.Id, 
                                                                        'ResourceProject__c', crmRelease.Project_Name__c, null,crmRelease.name.substringBefore(' ')));
            }
        }        
    }

    //Generate UAT Sign Off Follow up Notification Email    
    If(crmRelease.SignOff_Reminder_Sent__c != Trigger.oldMap.get(crmRelease.Id).SignOff_Reminder_Sent__c && crmRelease.SignOff_Reminder_Sent__c){
        for(User usr: users) {
            if(readyForUATsignOffRecievedUserIdSet.size()>0 && readyForUATsignOffRecievedUserIdSet.contains(usr.Id)){
            notifications.add(CventEmailNotificationHelper.createEmailNotification(usr.Id, usr.Name, 'Sign Off Reminder', usr.Email, 
                                                                    CventEmailNotificationHelper.SourceProcessName.ReleaseManagement, null, crmRelease.Id, 
                                                                        'ResourceProject__c', crmRelease.Project_Name__c, null,crmRelease.name.substringBefore(' ')));
            }
        }        
    }

    //Generate Pre-Deployment Notification Email    
    If(crmRelease.Deployment_Initiated__c   != Trigger.oldMap.get(crmRelease.Id).Deployment_Initiated__c && crmRelease.Deployment_Initiated__c){
        for(User usr: users) {
            if(signOffRecievedUserIdSet.size()>0 && signOffRecievedUserIdSet.contains(usr.Id)){
            notifications.add(CventEmailNotificationHelper.createEmailNotification(usr.Id, usr.Name, 'Pre-Deployment Notification', usr.Email, 
                                                                    CventEmailNotificationHelper.SourceProcessName.ReleaseManagement, null, crmRelease.Id, 
                                                                        'ResourceProject__c', crmRelease.Project_Name__c, null,crmRelease.name.substringBefore(' ')));
            }
        }        
    }

    //Generate Go Live Notification Email    
    If(crmRelease.Deployment_Complete__c != Trigger.oldMap.get(crmRelease.Id).Deployment_Complete__c && crmRelease.Deployment_Complete__c){
        for(User usr: users) {
            if(signOffRecievedUserIdSet.size()>0 && signOffRecievedUserIdSet.contains(usr.Id)){
            notifications.add(CventEmailNotificationHelper.createEmailNotification(usr.Id, usr.Name, 'Deployment Complete', usr.Email, 
                                                                    CventEmailNotificationHelper.SourceProcessName.ReleaseManagement, null, crmRelease.Id, 
                                                                        'ResourceProject__c', crmRelease.Project_Name__c, null,crmRelease.name.substringBefore(' ')));
            }
        }        
    }
    

    System.debug('******* isEmailSent*** ' + CventEmailNotificationHelper.isEmailSent);
    System.debug('*********** notifications ****** '+notifications);
    //Insert all Notifications
    if(notifications.size() > 0 && CventEmailNotificationHelper.isEmailSent==false){
        CventEmailNotificationHelper.isEmailSent=true;           
        insert notifications;
    }
    
}