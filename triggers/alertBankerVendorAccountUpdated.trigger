trigger alertBankerVendorAccountUpdated on Task (after insert) {

    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    } 


    Map<Id,Task> taskMap = new Map<Id,Task>();
    Map<Id,Task> testTask = new Map<Id,Task>();
    Map<Task,Task> testTask1 = new Map<Task,Task>();
    Map<Task,Task> testTask2 = new Map<Task,Task>();
    Map<Id,User> emailTask = new Map<Id,User>();
    Map<Id,String> emailTask1 = new Map<Id,String>();
    Map<Id,String> emailTask2 = new Map<Id,String>();
    Map<Id,String> emailTask3 = new Map<Id,String>();
    String emailAdd = null;
    String firstMgrEmail = null;
    String secMgrEmail = null;
    List<Id> accIds = new List<Id>();
    Map<Id,Account> actualAccIds = new Map<Id,Account>();
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    //Set<Messaging.SingleEmailMessage> mailset = new Set<Messaging.SingleEmailMessage>();
    String[] toAddresses = new String[]{};
    String userName = userinfo.getName();
    system.debug('!!!!!!!!!username'+username);
    /*String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
    Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Task.getRecordTypeInfosById();*/
    for(Task t : Trigger.New){
        if(t.whatId!=null && string.valueOf(t.WhatId).startsWith('001') && userName.contains('Sops')){
            taskMap.put(t.whatId,t);
            testTask.put(t.ownerId,t);
            testTask1.put(t,t);
            accIds.add(t.whatId);
            system.debug('@@@@taskMap: '+taskMap);
            system.debug('@@@@testTask: '+testTask);
        }    
    }
    system.debug('!!!!taskMap.size()'+taskMap.size());
    if(taskMap.size()>0){
        for(Account a : [Select Named_Acct__c,id,Name from Account where id in: taskMap.keySet() AND (Named_Acct__c INCLUDES ('Cvent Banker') OR Named_Acct__c INCLUDES  ('Cvent Vendor'))]){
            //Messaging.reserveSingleEmailCapacity(1);
            actualAccIds.put(a.id,a);
        }
    }
    system.debug('!!!!actualAccIds.size()'+actualAccIds.size());
    if(actualAccIds.size()>0){
        for(Id a : actualAccIds.keyset()){
            for(Task t : testTask1.keyset()){
                if(t.whatId==a){
                    testTask2.put(t,t);
                    system.debug('!!!!!testTask2'+testTask2.size());
                }
            }
        }    
    }
    
    List<Id> taskOwner = new List<Id>();
    if(testTask2.size()>0){
        for(Task t : testTask2.keyset()){
            taskOwner.add(t.OwnerId);
        }
    } 
    system.debug('@@@@taskOwner'+taskOwner.size());
    if(taskOwner.size()>0){
       for(User u : [Select Manager_Email__c, Name,Email,Second_Level_Manager_Email__c from user where id in: taskOwner]){ 
              if(u.Second_Level_Manager_Email__c != null){
                  emailTask3.put(u.id,u.Second_Level_Manager_Email__c);
                  emailTask2.put(u.id,u.Manager_Email__c);
                  emailTask1.put(u.id,u.Email);
                  system.debug('@@@@emailTask3'+emailTask3);
              }
              else if (u.Manager_Email__c != null){
                  emailTask2.put(u.id,u.Manager_Email__c);
                  emailTask1.put(u.id,u.Email);
                  system.debug('@@@@emailTask2'+emailTask2);     
              }
              else{
                  emailTask1.put(u.id,u.Email);
                  system.debug('@@@@emailTask1'+emailTask1);
              }    
       }
    }
    
    for(Task t : testTask2.keyset()){        
            
            system.debug('@@@@t'+t.ownerid);
            if(emailTask1.size()>0)
                emailAdd = emailTask1.get(t.OwnerId);
            if(emailTask2.size()>0)
                firstMgrEmail = emailTask2.get(t.OwnerId);
            if(emailTask3.size()>0)
                secMgrEmail = emailTask3.get(t.OwnerId);
            
            system.debug('emailAdd : '+emailAdd);
            system.debug('firstMgrEmail : '+firstMgrEmail);
            system.debug('secMgrEmail : '+secMgrEmail);
            
            /*if(emailAdd != null && firstMgrEmail != null && secMgrEmail != null)
                toAddresses = new String[]{emailAdd, firstMgrEmail, secMgrEmail};
            else if(emailAdd != null && firstMgrEmail != null)
                toAddresses = new String[]{emailAdd, firstMgrEmail};
            else */
            if(emailAdd != null)
                toAddresses = new String[]{emailAdd};   
            system.debug('#####toAddresses'+toAddresses);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            //mail.setSenderDisplayName('CVENT Notifications');
            mail.setOrgWideEmailAddressId('0D2000000008Oy6');
            mail.setSubject('CVENT Banker/Vendor Named Account');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            //mail.setHtmlBody ('Hi '+emailTask.get(a.id).Name + ',</br></br>'+
            mail.setHtmlBody ('Hi,</br></br>'+
            'A new task has been assigned to you in an account that is a current Cvent Banker/Vendor account, meaning we have an existing business relationship with them. Please see details below: </br>' +
            'A/c Name : '+ actualAccIds.get(t.whatId).Name + '</br>' +
            'A/c Link : https://cvent.my.salesforce.com/'+ t.whatId + '</br></br>' +
            'Before following up on this task please coordinate with Cvent Operations (Jason Wooten) so you can potentially leverage this existing relationship while pursuing this Account. </br>'+
            '</br>'+
            'Regards,</br>'+ 
            'Lead Management (Sops)');
            mails.add(mail);
            
    }
    system.debug('####mailset'+mails.size());
    /*Set<Messaging.SingleEmailMessage> myset = new Set<Messaging.SingleEmailMessage>();
    myset.addAll(mails);
    mails.clear();
    mails.addAll(mailset);*/
    if(mails.size()>0)
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>(mails));
}