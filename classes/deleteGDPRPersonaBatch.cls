/* ===============================
AUTHOR     :     Udita Dwivedi
CREATED DATE   : 17 April 2018
PURPOSE     :    When a contact is removed from GDPR it deletes it's info from GDPR Persona data and restores it in task.
TEST CLASS :     testGDPR 
============================= 
*/
global class deleteGDPRPersonaBatch implements Database.Batchable<sobject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        string query='select id,Id__c,Follow_Up_Created__c,sObject_type__c from GDPR_Central_Repository__c where Is_GDPR__c = false  and Follow_Up_Created__c= true';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,list<GDPR_Central_Repository__c> gdprList){
     
     list<Task> taskList = new list<Task>();
     list<Event> eventList = new list<Event>();
     list<Case> caseList = new list<Case>();
     list<GDPR_Persona_Data__c> deleteGDP = new list<GDPR_Persona_Data__c>();
     map<id,GDPR_Central_Repository__c> gdprMap = new map<id,GDPR_Central_Repository__c>();
     
    for(GDPR_Central_Repository__c gdpr : gdprList){  
        gdprMap.put(gdpr.id,gdpr);  
    } 
           
    deleteGDP =[SELECT Comments__c,CreatedById,CreatedDate,CurrencyIsoCode,Email__c,FromAddress__c,FromName__c,GDPR_Central_Repository__c,
                 Id,Id__c,IsDeleted,LastModifiedById,LastModifiedDate,Name,Name__c,Phone__c, 
                 RecordTypeId__c,sObject_type__c,SystemModstamp,Task_Subject__c,TextBody__c,Web_Email__c,Web_Phone__c,Web_Zone__c
                 FROM GDPR_Persona_Data__c where GDPR_Central_Repository__c in : gdprMap.keyset()];
                     
     for(GDPR_Persona_Data__c gdp : deleteGDP ){
       if(gdp.sObject_type__c =='Task'){
         Task t = new task(id= gdp.id__c); 
         t.RecordTypeId = gdp.RecordTypeId__c;
         t.Subject = gdp.Task_Subject__c.substringAfter('GDPR- ');
         t.Description = gdp.Comments__c.substringAfter('GDPR- ');
         GDPR_Central_Repository__c gdpObject = gdprMap.get(gdp.GDPR_Central_Repository__c);
         gdpObject.Follow_Up_Created__c = false;  
         taskList.add(t);
       }
      if(gdp.sObject_type__c =='Event'){
         Event evt  = new Event(id= gdp.id__c);      
         evt.RecordTypeId = gdp.RecordTypeId__c;
         evt.Subject = gdp.Task_Subject__c.substringAfter('GDPR- ');
         evt.Description = gdp.Comments__c.substringAfter('GDPR- ');
         GDPR_Central_Repository__c gdpObject = gdprMap.get(gdp.GDPR_Central_Repository__c);
         gdpObject.Follow_Up_Created__c = false;  
         eventList.add(evt);
       }
      if(gdp.sObject_type__c =='Case'){
         Case cs  = new Case(id= gdp.id__c);      
         cs.RecordTypeId = gdp.RecordTypeId__c;
         cs.Subject = gdp.Task_Subject__c.substringAfter('GDPR- ');
         cs.Description = gdp.Comments__c.substringAfter('GDPR- ');
         cs.RecordTypeId = gdp.RecordTypeId__c;
         cs.Subject = gdp.Task_Subject__c.substringAfter('GDPR- ');
         GDPR_Central_Repository__c gdpObject = gdprMap.get(gdp.GDPR_Central_Repository__c);
         gdpObject.Follow_Up_Created__c = false;  
         caseList.add(cs);
       }
     }
     
     if(caseList.size() > 0){
       update caseList;
     } 
     if(eventList.size() > 0){
       update eventList;
     } 
     if(taskList.size() > 0){
       update taskList;
     }   
     
     if(gdprMap.size() > 0){
        update gdprMap.values();
     } 
     if(deleteGDP.size() > 0){
      delete deleteGDP;
     }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}