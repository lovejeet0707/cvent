/* ===============================
AUTHOR     :     Udita Dwivedi
CREATED DATE   : 17 April 2018
PURPOSE     :    When a contact is marked GDPR it creates it's GDPR Persona data which is the related activities of the contact.
TEST CLASS :     testGDPR 
============================= 
*/
global class createGDPRPersonaBatch implements Database.Batchable<sObject>, Database.Stateful{
    public static boolean bypassGDPR=false; 
    global Database.QueryLocator start(Database.BatchableContext BC){
      string query ='select id,Id__c,sObject_type__c,Follow_Up_Created_Task__c from GDPR_Central_Repository__c where Is_GDPR__c = true  and Follow_Up_Created_Task__c = false';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,list<GDPR_Central_Repository__c> GDPRList){
        set<id> taskId = new set<id>();
        set<string> accountSobjectId = new set<string>();
        set<string> sobjectId = new set<string>();
        map<string,id> sobjectIdMap = new map<string,id>();
        map<id,id> personAccountsobjectIdMap = new map<id,id>();
        list<task> taskList = new list<task>();
        list<Event> eventList = new list<Event>();
        list<case> caseList = new list<case>();
        list<GDPR_Persona_Data__c> insertGDPR = new list<GDPR_Persona_Data__c>();
        set<id> caseId = new set<id>();
        String taskQuery;
        for(GDPR_Central_Repository__c gdpr : GDPRList){
           sobjectIdMap.put(gdpr.Id__c,gdpr.id); 
           gdpr.Follow_Up_Created_Task__c = true;
           if(gdpr.sObject_type__c =='Person Account' || gdpr.sObject_type__c =='Case'){
               accountSobjectId.add(gdpr.Id__c);
           }
           else if(gdpr.sObject_type__c !='Person Account'){
               sobjectId.add(gdpr.Id__c);
           }
           if(gdpr.sObject_type__c =='Case'){
               caseId.add(gdpr.id__c);
           }
        } 
        
        if(accountSobjectId.size() > 0){
            For(Task tasObj : [select id,Subject,RecordTypeId,Description,WhoId,WhatId from task where WhatId in : accountSobjectId])
            {   if(!taskId.contains(tasObj.id)){
                taskId.add(tasObj.id);
                taskList.add(tasObj); }   
            }
            For(Event eventObj : [select id,Subject,RecordTypeId,Description,WhoId,WhatId from event where WhatId in : accountSobjectId])
            {
                eventList.add(eventObj);
            }
        }
        if(sobjectId.size() > 0){
            For(Task tasObj : [select id,Subject,RecordTypeId,Description,WhoId,WhatId from task where WhoId in : sobjectId])
            {   if(!taskId.contains(tasObj.id)){
                taskId.add(tasObj.id);
                taskList.add(tasObj); }   
            }
            For(Event eventObj : [select id,Subject,RecordTypeId,Description,WhoId from event where WhoId in : sobjectId])
            {
                eventList.add(eventObj);
            }
        }
        System.debug('sobjectIdMap*************'+sobjectIdMap);
        if(!sobjectIdMap.isEmpty())
            caseList = [select id,SuppliedEmail,SuppliedPhone,CommunityId,Subject,ContactId,RecordTypeId,Description,accountId from case where (ContactId in : sobjectIdMap.keyset() or accountId in : sobjectIdMap.keyset()) and Recordtypeid != '0121N000000qsiP'];
        
        if(taskList.size() > 0){
            for(Task t : taskList){
                 GDPR_Persona_Data__c gdprChild = new GDPR_Persona_Data__c();
                 gdprChild.RecordTypeId__c= t.RecordTypeId;
                 gdprChild.Task_Subject__c ='GDPR- '+ t.Subject;
                 gdprChild.GDPR_Central_Repository__c = sobjectIdMap.get(t.WhoId)== null ?sobjectIdMap.get(t.WhatId):sobjectIdMap.get(t.WhoId);
                 gdprChild.Comments__c = 'GDPR- ' + t.Description;
                 gdprChild.sObject_type__c = 'Task';
                 gdprChild.Id__c = t.id;
                 insertGDPR.add(gdprChild);
                 t.Subject = 'GDPR Subject';
                 t.Description = 'GDPR- Description';
                 t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('GDPR').getRecordTypeId();
            }
       }
       if(eventList.size() > 0){
        for(Event evt : eventList){
             GDPR_Persona_Data__c gdprChild = new GDPR_Persona_Data__c();
             gdprChild.RecordTypeId__c= evt.RecordTypeId;
             gdprChild.Task_Subject__c ='GDPR- '+ evt.Subject;
             gdprChild.GDPR_Central_Repository__c = sobjectIdMap.get(evt.WhoId)== null ?sobjectIdMap.get(evt.WhatId):sobjectIdMap.get(evt.WhoId);
             gdprChild.Comments__c = 'GDPR- ' + evt.Description;
             gdprChild.sObject_type__c = 'Event';
             gdprChild.Id__c = evt.id;
             insertGDPR.add(gdprChild);
             evt.Subject = 'GDPR Subject';
             evt.Description = 'GDPR- Description';
             evt.RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('GDPR Record').getRecordTypeId();
        }
      }
       if(caseList.size() > 0){
        for(Case cs : caseList){
             caseId.add(cs.id);
             GDPR_Persona_Data__c gdprChild = new GDPR_Persona_Data__c();
             gdprChild.RecordTypeId__c= cs.RecordTypeId;
             gdprChild.Task_Subject__c ='GDPR- '+ cs.Subject;
             gdprChild.GDPR_Central_Repository__c = sobjectIdMap.get(cs.ContactId)== null ?sobjectIdMap.get(cs.accountId):sobjectIdMap.get(cs.ContactId);
             gdprChild.Comments__c = 'GDPR- ' + cs.Description;
             gdprChild.sObject_type__c = 'Case';
             gdprChild.Id__c = cs.id;
             gdprChild.Web_Email__c= cs.SuppliedEmail;
             gdprChild.Web_Phone__c= cs.SuppliedPhone;
             gdprChild.Web_Zone__c= cs.CommunityId;
             insertGDPR.add(gdprChild);
             
             cs.Subject = 'GDPR Subject';
             cs.Description = 'GDPR- Description';
             cs.SuppliedEmail= 'gdpr@gdpr.com';
             cs.SuppliedPhone= '';
             //cs.CommunityId= null;
             cs.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('GDPR').getRecordTypeId();
        }
    }
    
    list<EmailMessage> emailLst = new list<EmailMessage>();
    emailLst = [select id,FromAddress,FromName,TextBody,Parent.ContactId,ParentId from EmailMessage where ParentId in :caseId ];
    
     if(emailLst.size() > 0){
        for(EmailMessage em : emailLst){
             GDPR_Persona_Data__c gdprChild = new GDPR_Persona_Data__c();
             gdprChild.FromAddress__c= em.FromAddress;
             gdprChild.FromName__c = em.FromName;
             gdprChild.GDPR_Central_Repository__c = sobjectIdMap.get(em.Parent.ContactId) == null ? sobjectIdMap.get(em.ParentId) : sobjectIdMap.get(em.Parent.ContactId);
             gdprChild.TextBody__c = em.TextBody;
             gdprChild.sObject_type__c = 'Email Messages';
             gdprChild.Id__c = em.id;
             insertGDPR.add(gdprChild);
        }
    }
     
        IF(GDPRList.size() > 0){
            update GDPRList;
        }
        IF(emailLst.size() > 0){
            database.delete(emailLst);
        }
        IF(taskList.size() > 0){
            bypassGDPR = true;
            update taskList;
        }
        IF(eventList.size() > 0){
            bypassGDPR = true;
            update eventList;
        }
        IF(caseList.size() > 0){
            update caseList;
        }
        IF(insertGDPR.size() > 0){
            Database.upsert(insertGDPR);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}