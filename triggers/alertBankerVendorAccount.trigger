trigger alertBankerVendorAccount on Task (after insert) {
    Map<Id,Task> taskMap = new Map<Id,Task>();
    Map<Id,Task> testTask = new Map<Id,Task>();
    Map<Task,Task> testTask1 = new Map<Task,Task>();
    Map<Id,User> emailTask = new Map<Id,User>();
    Map<Id,String> emailTask1 = new Map<Id,String>();
    Map<Id,String> emailTask2 = new Map<Id,String>();
    Map<Id,String> emailTask3 = new Map<Id,String>();
    String emailAdd = null;
    String firstMgrEmail = null;
    String secMgrEmail = null;
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
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
            system.debug('@@@@taskMap: '+taskMap);
            system.debug('@@@@testTask: '+testTask);
        }    
    }
    if(testTask.size()>0){
        for(User u : [Select Manager_Email__c, Name,Email,Second_Level_Manager_Email__c from user where id in: testTask.keyset()]){
            emailTask.put(testTask.get(u.id).whatId,u);
            if(u.Email != null)
                emailTask1.put(testTask.get(u.id).whatId,u.Email);
            if(u.Manager_Email__c != null)
                emailTask2.put(testTask.get(u.id).whatId,u.Manager_Email__c);
            if(u.Second_Level_Manager_Email__c != null)
                emailTask3.put(testTask.get(u.id).whatId,u.Second_Level_Manager_Email__c);
                
            system.debug('@@@@emailTask : '+emailTask);
            system.debug('@@@@emailTask1 : '+emailTask1);
            system.debug('@@@@emailTask2 : '+emailTask2);
            system.debug('@@@@emailTask3 : '+emailTask3);
        }
    }
    if(taskMap.size()>0){
        for(Account a : [Select Named_Acct__c,id,Name from Account where id in: taskMap.keyset() AND (Named_Acct__c INCLUDES ('Cvent Banker') OR Named_Acct__c INCLUDES  ('Cvent Vendor'))]){
            
            //Messaging.reserveSingleEmailCapacity(1);
            
            
            if(emailTask1.size()>0)
                emailAdd = emailTask1.get(a.id);
            if(emailTask2.size()>0)
                firstMgrEmail = emailTask2.get(a.id);
            if(emailTask3.size()>0)
                secMgrEmail = emailTask3.get(a.id);
            
            system.debug('emailAdd : '+emailAdd);
            system.debug('firstMgrEmail : '+firstMgrEmail);
            system.debug('secMgrEmail : '+secMgrEmail);
            
            if(emailAdd != null && firstMgrEmail != null && secMgrEmail != null)
                toAddresses = new String[]{emailAdd, firstMgrEmail, secMgrEmail};
            else if(emailAdd != null && firstMgrEmail != null)
                toAddresses = new String[]{emailAdd, firstMgrEmail};
            else 
                toAddresses = new String[]{emailAdd};   

            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('CVENT Notifications');
            mail.setSubject('CVENT Banker/Vendor Named Account');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            //mail.setHtmlBody ('Hi '+emailTask.get(a.id).Name + ',</br></br>'+
            mail.setHtmlBody ('Hi,</br></br>'+
            'A new task is created for Cvent Banker/Vendor Account. Please see details below: </br>' +
            'A/c Name : '+ a.Name + '</br>' +
            'A/c Link : https://cvent.my.salesforce.com/'+a.Id + '</br></br>' +
            'Please follow it accordingly. For additional information on this Vendor/Banker, please contact Jason Wooten. </br>'+
            '</br>'+
            'Regards,</br>'+ 
            'Sales Support India');
            mails.add(mail);
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}