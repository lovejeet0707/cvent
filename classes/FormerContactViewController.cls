/* Udita : To show former contacts and there related activities on Contacts */
public class FormerContactViewController{

  public id contactId{get;set;}
  public map<id,FormPos__Former_Position__c > formerPosMap{get;set;}
  public map<id,string> formerPosDateMap{get;set;}
  public string accName{get;set;}
  public List<eEventTTask> taskEventList{get;set;}
  
  public FormerContactViewController(ApexPages.StandardController  std){
    contactId = Apexpages.currentPage().getParameters().get('id'); 
    formerPosMap= new map<id,FormPos__Former_Position__c>();   
    taskEventList = new List<eEventTTask>();
    formerPosDateMap = new map<id,string>();   
    system.debug('USER IP ADDRESS: ' + ApexPages.currentPage().getHeaders().get('True-Client-IP'));
    system.debug('USER IP ADDRESS: ' +ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP'));
    system.debug('USER IP ADDRESS: ' +ApexPages.currentPage().getHeaders().get('X-Forwarded-For'));

  }
    public SelectOption[] getselectValues() { 
         list<FormPos__Former_Position__c> formerList = new list<FormPos__Former_Position__c >();
         date lastCreatedDate;
         string optionValue;
         formerPosMap.clear();
         SelectOption[] options = new SelectOption[]{};
         options.add(new SelectOption('--None--','--None--'));
         formerList = [select id,Name,Current_Account_Type__c ,Former_Account_CSN_Id__c,Current_Account_CSN_Id__c,FormPos__Current_Account__c,Current_Account_Id__c,FormPos__Account__c,FormPos__Account__r.name,FormPos__Account__r.Type,FormPos__Account__r.createdDate,FormPos__Contact__c,FormPos__Title__c,FormPos__End_Date__c,FormPos__Start_Date__c from FormPos__Former_Position__c where FormPos__Contact__c =:contactId ORDER BY Createddate desc];       
         system.debug('----formerList'+formerList);
         for(FormPos__Former_Position__c form: formerList){
            system.debug('---formerPosMap'+formerPosMap);
            lastCreatedDate = (formerList[formerList.size()-1].FormPos__End_Date__c);
            if(!formerPosMap.containskey(form.FormPos__Account__c) || !formerPosMap.containskey(form.Current_Account_Id__c)){
                 system.debug('---Account'+ form.FormPos__Account__c);
                 if(!formerPosMap.containskey(form.Current_Account_Id__c)){
                    optionValue = ((form.Current_Account_CSN_Id__c != null && form.Current_Account_Type__c != null) ? (' - ' + form.Current_Account_CSN_Id__c + ' - ' + form.Current_Account_Type__c) : (form.Current_Account_CSN_Id__c == null && form.Current_Account_Type__c != null) ? ' - ' + form.Current_Account_Type__c : (form.Current_Account_CSN_Id__c != null && form.Current_Account_Type__c == null) ? ' - ' + form.Current_Account_CSN_Id__c : '');
                    options.add(new SelectOption(String.valueOf(form.Current_Account_Id__c),form.FormPos__Current_Account__c + optionValue)); 
                    formerPosMap.put(form.Current_Account_Id__c,form);  
                 }   
                 
                 
                 if(!formerPosMap.containskey(form.FormPos__Account__c)){   
                     system.debug('---form.FormPos__Account__c'+form.FormPos__Account__c);
                     optionValue = ((form.Former_Account_CSN_Id__c != null && form.FormPos__Account__r.Type != null) ? (' - ' + form.Former_Account_CSN_Id__c + ' - ' + form.FormPos__Account__r.Type) : (form.Former_Account_CSN_Id__c == null && form.FormPos__Account__r.Type != null) ? ' - ' + form.FormPos__Account__r.Type : (form.Former_Account_CSN_Id__c != null && form.FormPos__Account__r.Type == null) ? ' - ' + form.Former_Account_CSN_Id__c : '');
                     options.add(new SelectOption(String.valueOf(form.FormPos__Account__c),form.FormPos__Account__r.name + optionValue));
                     formerPosMap.put(form.FormPos__Account__c,form); 
                     
                 }
                 
                 if(form.FormPos__Start_Date__c == null){
                    system.debug('---form.FormPos__Start_Date__c'+ form.FormPos__Start_Date__c);
                    form.FormPos__Start_Date__c=Date.ValueOf(form.FormPos__Account__r.createdDate);
                    system.debug('---form.FormPos__Start_Date__c'+ form.FormPos__Start_Date__c);
                 }
                 if(form.FormPos__End_Date__c == null){
                    form.FormPos__End_Date__c =form.FormPos__Start_Date__c;
                 }
                 
                 formerPosDateMap.put(form.FormPos__Account__c,form.FormPos__Start_Date__c+'/'+form.FormPos__End_Date__c);
                 formerPosDateMap.put(form.Current_Account_Id__c,lastCreatedDate+'/'+System.Today());
                 
             }else{
                 string finalDate;
                 string dt;
                 if(formerPosDateMap.containsKey(form.FormPos__Account__c)){
                   dt = formerPosDateMap.get(form.FormPos__Account__c);}
                 else{
                   dt = formerPosDateMap.get(form.Current_Account_Id__c);
                 }
                 string d1 = dt.substringBefore('/');
                 string d2 = dt.substringAfter('/');
                     if(date.valueOf(d1) < form.FormPos__Start_Date__c ){
                        finalDate =string.valueOf(date.valueOf(d1));
                     }else{
                        finalDate =string.valueOf(form.FormPos__Start_Date__c);
                     }
                 
                     if(date.valueOf(d2) < form.FormPos__End_Date__c){
                        finalDate=+finalDate+'/'+   string.valueOf(form.FormPos__End_Date__c);                 
                     }else{
                        finalDate=+finalDate+'/'+ date.valueOf(d2);
                     }
                 
                 formerPosDateMap.put(form.FormPos__Account__c,finalDate);
             } 
          }            
         return options;               
  }
  
  public void fetchActivities(){
    taskEventList.clear();
    system.debug('----formerPosDateMap'+formerPosDateMap);
    if(accName != '--None--'){       
        string accNameFinal =  id.valueOf(accName.SubstringBefore('-'));
        string dateString = formerPosDateMap.get(accName);
        if(String.isNotBlank(dateString)){
        date d1 = date.valueOf(dateString.substringBefore('/')) ;
        date d2 = date.valueOf(dateString.substringAfter('/'));    
        system.debug('=====d1'+d1);
        system.debug('=====d2'+d2);  
        for(task t: [select id,WhatId ,subject,description,ActivityDate,What.name,LastModifiedDate,OwnerId,Owner.Name,Status,Priority from task where (DAY_ONLY(createdDate) >= :d1 and DAY_ONLY(createdDate) <= :d2) and WhoId=:contactId]){
          taskEventList.add(new eEventTTask(t.Subject, t.What.name, t.Owner.Name, t.ActivityDate,t.id,t.Status,t.Priority,true,t.WhatId));
        }
        for(event e: [select id,WhatId ,subject,description,ActivityDate,What.name,LastModifiedDate,OwnerId,Owner.Name from event where  (DAY_ONLY(createdDate) >= :d1 and DAY_ONLY(createdDate) <= :d2) and WhoId=:contactId]){
          taskEventList.add(new eEventTTask(e.Subject, e.What.name, e.Owner.Name, e.ActivityDate,e.id,'','',false,e.WhatId));
        }
        }
    }   
  }

    public class eEventTTask {
        public String subject { get; set; }
        public string whatName { get; set; }
        public string ownerId { get; set; }
        public Date activityDate { get; set;}
        public string status{ get; set;}
        public string Priority{ get; set;}
        public boolean taskOrEvent{ get; set;}
        public id RecordId{ get; set;}
        public id whatId{ get; set;}
        
        public eEventTTask(String sub, string wht, string own, Date act,id lmd,string sta,string pri,boolean tsk,id whtid) {
        subject = sub;
        whatName = wht;
        ownerId = own;
        activityDate = act;
        RecordId = lmd;
        status=sta;
        Priority = pri;
        taskOrEvent=tsk;
        whatId =whtid; 
      }
 }
}