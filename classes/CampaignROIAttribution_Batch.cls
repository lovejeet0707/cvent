global class CampaignROIAttribution_Batch implements Database.Batchable<sObject>{
    
    List<Opportunity> oppObj_List;
    Set<Id> accountIdSet ;
    List<Task> tasksList ;
    
    Map<Id,List<Task>> accountIdVstaskList_Map;
        


    Map<Id,Opportunity> oppIdVsOppObj_Map;
    Map<String,Decimal> oppConIdVsTaskCount;
    Decimal taskCount;
    Map<Id,Decimal> oppIdVsTotalTask_Map;
    Decimal totalTaskOpp;
    
    List<String> listType;
    List<String> listProject;
    List<String> listTactic;
    List<String> listSource;
    List<String> listStatus;
    
    
    Map<String,Decimal> oppIdConIdVsAmount_Map;
    String campaignMemberQuery;

    //Later Variables
    //Contains All Opps related to filtered Contacts
    List<Opportunity> opptyList;
    Set<ID> conIds;
    Map<String,List<Opportunity_Campaign_Attribution__c>> concatVsObj_Map;
    Map<Id,List<CampaignMember>> campaignMemberMap;
    
    List<Task> tasksRecList;    
    
    Integer count ;
    Integer count2;
    Integer count3;
    Integer count4;
    
    Decimal remaingAmount1;
    decimal temp_90DaysValue;
    decimal temp_180DaysValue;
    decimal temp_270DaysValue;
    decimal temp_360DaysValue;
    
    Boolean flag1;
    Boolean flag2;
    Boolean flag3;
    Boolean flag4;
    

    Id opportunityId1;
    
    Decimal totalTaskCount=0;
    Decimal amountCalculate=0;    
    
    string oppId='';
    String oppConIdConcat='';
    
    Datetime closeDateOneYearBack1;
    Integer daysBetween;
    
    Id ContactId ;
    DateTime closeDate;
    Datetime closeDateOneYearBack;
    Id opportunityId;
    
    List <CampaignMember> listCampaignMemb ;
    Set<Id> contactIdSet;
        
    global CampaignROIAttribution_Batch(List<String> listType, List<String> listProject,List<String> listTactic,List<String> listSource,List<String> listStatus)
    {   
    
        accountIdSet = new Set<Id>();
        tasksList = new List<Task>();
        contactIdSet = new Set<ID>();
        
        oppIdConIdVsAmount_Map=new Map<String,Decimal>();
        oppIdVsTotalTask_Map=new Map<Id,Decimal>();
        oppConIdVsTaskCount=new Map<String,Decimal>();
        oppIdVsOppObj_Map=new Map<Id,Opportunity> ();
        taskCount=0;
        
        accountIdVstaskList_Map=new Map<Id,List<Task>>();
       
        oppObj_List=new List<Opportunity>();

        //Later Variables
        conIds = new Set<ID> ();
        concatVsObj_Map=new Map<String,List<Opportunity_Campaign_Attribution__c>>();
        campaignMemberMap = new Map<Id,List<CampaignMember>>();
        opptyList = new List<Opportunity>();
        tasksRecList = new List<Task>();
        listCampaignMemb = new List <CampaignMember> () ;
        

        this.listType=listType;
        this.listProject=listProject;
        this.listTactic=listTactic;
        this.listSource=listSource;
        this.listStatus=listStatus;
    }
    
    global Database.querylocator start(Database.BatchableContext BC){
       
        campaignMemberQuery='SELECT Id,Contact.AccountId,CampaignId,ContactId FROM CampaignMember WHERE ';
        if(listType!=null && listType.size()>0){
             campaignMemberQuery+=' Campaign.Type in:listType AND ';
        }
        if(listProject!=null && listProject.size()>0){
             campaignMemberQuery+=' Campaign.Project__c in:listProject AND ';
        }
        if(listSource!=null && listSource.size()>0){
             campaignMemberQuery+=' Campaign.Source__c in:listSource AND ';
        }
        if(listTactic!=null && listTactic.size()>0){
             campaignMemberQuery+='Campaign.Tactic__c  in:listTactic AND ';
        }
        if(listStatus!=null && listStatus.size()>0){
             campaignMemberQuery+=' Status in:listStatus AND ';
        }
        if((listType==null|| listType.size()==0) && (listProject==null|| listProject.size()==0)&& (listSource==null|| listSource.size()==0) &&  (listTactic==null|| listTactic.size()==0) && (listStatus==null|| listStatus.size()==0))
        campaignMemberQuery=campaignMemberQuery.removeEnd(' WHERE ');
        //system.debug('campaignMemberQuery 1st'+campaignMemberQuery); 
        campaignMemberQuery=campaignMemberQuery.removeEnd(' AND ');
        
        //system.debug('*** QUERY **** ' +  campaignMemberQuery);
        return Database.getQueryLocator(campaignMemberQuery);
    }

    global void execute(Database.BatchableContext BC, List<CampaignMember> scope){

       
        //system.debug('***** accountIdSet **** ' + accountIdSet.size());
        For(CampaignMember camMemRec : scope)
        {
            accountIdSet.add(camMemRec.Contact.AccountId);
            contactIdSet.add(camMemRec.ContactId);
            
        }
     
        //Contains all Contacts with Tasks and Opp       
        For(Contact contactRec : [SELECT Id,AccountId,
                                        (SELECT Id, CloseDate, Product__c,Contact_Associated__c,Contact_Associated__r.AccountId,New_Contract_Total__c FROM Opportunities_Cust__r WHERE StageName!='Closed Won' AND StageName!='Closed Lost' and Product__c!=null And Contact_Associated__c IN : contactIdSet),
                                        (SELECT WhatId, Id,WhoId, Task_Assigned_Role__c,ActivityDate  FROM Tasks where Task_Assigned_Role__c!=null)
                                        FROM Contact WHERE AccountId IN : accountIdSet]){   
            
         
            
            //Adding All Tasks into List
            for(Task t : contactRec.Tasks){              
                tasksRecList.add(t);
            }
            
            
            //Adding All Opps into List
            for( Opportunity o : contactRec.Opportunities_Cust__r){
                opptyList.add(o);
            }
            
        
        }
        //Collecting Tasks
        for(Task tsk : tasksRecList ){
                
                if(!accountIdVstaskList_Map.containsKey(tsk.WhatId)){
                   
                    accountIdVstaskList_Map.put(tsk.WhatId, new List<Task>{tsk});
                }   
                else 
                accountIdVstaskList_Map.get(tsk.WhatId).Add(tsk);
        }
        
        
        System.debug('******** HEAP SIZE *** '+ Limits.getHeapSize());
        
        
        //For Reducing Heap Size
        contactIdSet.clear();
        tasksRecList.clear();
        accountIdSet.clear();

        //Collecting Opps
        For(Opportunity oppObj : opptyList)
        {
                tasksList.clear();
                oppId = (String)(oppObj.Id);
                //Below code is used for the calculateion purpose
                if(!oppIdVsOppObj_Map.containsKey(oppObj.Id))
                {
                    oppIdVsOppObj_Map.put(oppObj.Id,oppObj);
                }
                //Ends Here.....................................................
                closeDateOneYearBack1 = oppObj.CloseDate.addYears(-1);
                
                tasksList = accountIdVstaskList_Map.get(oppObj.Contact_Associated__r.AccountId)== null ? new List<Task>() : accountIdVstaskList_Map.get(oppObj.Contact_Associated__r.AccountId);
                ////system.debug('******** tasksList *** ' + tasksList );
                For(Task taskObjRec : tasksList )
                {
                    
                    if( taskObjRec.Task_Assigned_Role__c.contains(oppObj.Product__c) && closeDateOneYearBack1<=taskObjRec.ActivityDate && taskObjRec.ActivityDate<=oppObj.CloseDate)
                    {
                        if(!oppIdVsTotalTask_Map.containsKey(oppObj.Id))
                        {
                            totalTaskOpp=1;
                            oppIdVsTotalTask_Map.put(oppObj.Id,totalTaskOpp);
                        }
                        else{
                            oppIdVsTotalTask_Map.put(oppObj.Id,totalTaskOpp++);
                        }
                        
                        //Below code is used for the calculateion purpose
                        oppConIdConcat = oppId + (String)(taskObjRec.WhoId);
                        
                        if(!oppConIdVsTaskCount.containsKey(oppConIdConcat))
                        {   
                            taskCount=1 ;
                            oppConIdVsTaskCount.put(oppConIdConcat,taskCount);
                        }
                        else{
                            oppConIdVsTaskCount.put(oppConIdConcat,taskCount++);
                        }
                        
                        //...............................Ends Here................................
                        
                        
                    }
                }
            }
            
            
        //Reducing Heap Size 
        opptyList.clear();  
        accountIdVstaskList_Map.clear();    
        
        //Below for loop is used for Amount CaLculation.........
        For(String oppConId : oppConIdVsTaskCount.keySet())
        {
                opportunityId1=oppConId.subString(0,18);
                totalTaskCount=oppIdVsTotalTask_Map.containsKey(opportunityId1)?oppIdVsTotalTask_Map.get(opportunityId1):1;
                amountCalculate=((oppConIdVsTaskCount.containsKey(oppConId)?oppConIdVsTaskCount.get(oppConId):0)/totalTaskCount)*((oppIdVsOppObj_Map.containsKey(opportunityId1)&&oppIdVsOppObj_Map.get(opportunityId1).New_Contract_Total__c!=null)?oppIdVsOppObj_Map.get(opportunityId1).New_Contract_Total__c:0);
                oppIdConIdVsAmount_Map.put(oppConId,amountCalculate);
                conIds.add(oppConId.subString(18,36));  
        }
       
        //Reducing Heap Size 
        oppIdVsTotalTask_Map.clear();
        
        
        for( CampaignMember cm : [SELECT Member_Associated_Date_Time__c,CampaignId,ContactId,Contact.AccountId FROM CampaignMember WHERE ContactId IN: conIds]){
            
            if(!campaignMemberMap.containsKey(cm.ContactId)){
                campaignMemberMap.put(cm.contactId, new List<CampaignMember>{cm});
            }
            else
                campaignMemberMap.get(cm.contactId).add(cm);
                
        }
        
       

        
        
        For(String oppConId : oppConIdVsTaskCount.keySet())
        {
            listCampaignMemb.clear();
            opportunityId=oppConId.subString(0,18);
            ContactId = oppConId.subString(18,33);
            
            closeDate=oppIdVsOppObj_Map.get(opportunityId).CloseDate;
            closeDateOneYearBack=closeDate.addYears(-1);
            //opptyTotalAmount=oppIdConIdVsAmount_Map.get(opportunityId);
            
 
            
            listCampaignMemb = campaignMemberMap.get(ContactId) == null ? new List <CampaignMember>() : campaignMemberMap.get(ContactId);
            
            For(CampaignMember campMemObj : listCampaignMemb)
            {    
                if(closeDateOneYearBack<=campMemObj.Member_Associated_Date_Time__c && campMemObj.Member_Associated_Date_Time__c<=closeDate)
                {
                   
                    daysBetween=(date.newinstance(campMemObj.Member_Associated_Date_Time__c.year(), campMemObj.Member_Associated_Date_Time__c.month(), campMemObj.Member_Associated_Date_Time__c.day())).daysBetween(date.newinstance(closeDate.year(), closeDate.month(), closeDate.day()));
                    Opportunity_Campaign_Attribution__c oppCamObj = new Opportunity_Campaign_Attribution__c();
                        oppCamObj.BatchId__c = BC.getJobID();
                        oppCamObj.Opportunity__c=opportunityId;
                        oppCamObj.Campaign__c=campMemObj.CampaignId;
                       
                        oppCamObj.Contact__c=ContactId;
                       
                        oppCamObj.Days__c=daysBetween;
                        
                        string key = ((String)(oppCamObj.Opportunity__c)) + ((String)(oppCamObj.Contact__c))+((String)(oppCamObj.Campaign__c));
                        if(!concatVsObj_Map.containsKey(key))
                        {
                            concatVsObj_Map.put(key,new List<Opportunity_Campaign_Attribution__c>{oppCamObj});
                        }
                        else
                            concatVsObj_Map.get(key).add(oppCamObj);                                           
                }
            }
        }
        
        
        //Reducing Heap Size
        oppConIdVsTaskCount.clear();
        listCampaignMemb.clear();
        
        
        Map<String,Opportunity_Campaign_Attribution__c> mapIdVsOpptyCampaign = new Map<String,Opportunity_Campaign_Attribution__c>();
        Map<String,Decimal> mapDaysTotalAmount =new Map<String,Decimal>();
        
        flag1=false;
        flag2=false;
        flag3=false;
        flag4=false;
        count=0;
        count2=0;
        count3=0;
        count4=0; 
        remaingAmount1=0.0;  
        
        List<Opportunity_Campaign_Attribution__c> listCampaignAttribute = new List<Opportunity_Campaign_Attribution__c> ();   
        
        For(String ss : concatVsObj_Map.keySet())
        {
            flag1=false;
            flag2=false;
            flag3=false;
            flag4=false;
            count=0;
            count2=0;
            count3=0;
            count4=0;       
            remaingAmount1=0.0;   
                      
            ////system.debug('*****************--------------ssssss-'+ss);
            
            For(Opportunity_Campaign_Attribution__c oppCamObj : concatVsObj_Map.get(ss))
            {
                //system.debug('**********oppCamObj  **** -'+ oppCamObj);
                
                
                String opportunityIdContactIdConcat= ((String)(oppCamObj.Opportunity__c))+((String)(oppCamObj.Contact__c));
                //system.debug('**********opptyTotalAmount  **** -'+ oppIdConIdVsAmount_Map.get(opportunityIdContactIdConcat));
                Decimal opptyTotalAmount= oppIdConIdVsAmount_Map.get(opportunityIdContactIdConcat)==null ?0: oppIdConIdVsAmount_Map.get(opportunityIdContactIdConcat) ;

                if(oppCamObj.days__c <=90){

                    mapIdVsOpptyCampaign.put(ss,oppCamObj);
                     if(!flag1){
                        flag1=true;
                        oppCamObj.Amount__C=opptyTotalAmount*0.5;
                        remaingAmount1=opptyTotalAmount-oppCamObj.Amount__C;
                        mapDaysTotalAmount.put('90',oppCamObj.Amount__C);
                     }
                     if(flag1){
                         count+=2;
                     }
                }
                else if(oppCamObj.days__c >90 && oppCamObj.days__c <=180){
                    mapIdVsOpptyCampaign.put(ss,oppCamObj);
                     if(!flag2){
                         if(remaingAmount1>0){
                              oppCamObj.Amount__C=remaingAmount1*0.25;
                              mapDaysTotalAmount.put('180',oppCamObj.Amount__C);
                              remaingAmount1=remaingAmount1-oppCamObj.Amount__C;
                         }else{
                              oppCamObj.Amount__C=opptyTotalAmount*0.25;
                               mapDaysTotalAmount.put('180',oppCamObj.Amount__C);
                              remaingAmount1=remaingAmount1-oppCamObj.Amount__C;
                         }
                         flag2=true; 
                     }
                    if(flag2){
                          count2+=2;
                     }
                }else if(oppCamObj.days__c >180 && oppCamObj.days__c <=270){
                            mapIdVsOpptyCampaign.put(ss,oppCamObj);
                      if(!flag3){
                            if(remaingAmount1>0){
                              oppCamObj.Amount__C=remaingAmount1*0.15;
                               mapDaysTotalAmount.put('270',oppCamObj.Amount__C);
                              remaingAmount1=remaingAmount1-oppCamObj.Amount__C;
                         }else{
                             
                               oppCamObj.Amount__C=opptyTotalAmount*0.15;
                                mapDaysTotalAmount.put('270',oppCamObj.Amount__C);
                              remaingAmount1=remaingAmount1-oppCamObj.Amount__C;
                         }
                        flag3=true; 
                     }
                     if(flag3){
                          count3+=2;
                     }
                }else if(oppCamObj.days__c >270 && oppCamObj.days__c <=366){
                            mapIdVsOpptyCampaign.put(ss,oppCamObj);
                     if(!flag4){
                          if(remaingAmount1>0){
                               oppCamObj.Amount__C=remaingAmount1*0.10;
                               mapDaysTotalAmount.put('366',oppCamObj.Amount__C);
                               remaingAmount1=remaingAmount1-oppCamObj.Amount__C;
                         }else{
                               oppCamObj.Amount__C=opptyTotalAmount*0.10;
                               mapDaysTotalAmount.put('366',oppCamObj.Amount__C);
                               remaingAmount1=remaingAmount1-oppCamObj.Amount__C;
                         }
                         flag4=true; 
                     }
                     if(flag4){
                          count4+=2;
                     }
                }
                listCampaignAttribute.add(oppCamObj);
            }

        temp_90DaysValue  = mapDaysTotalAmount.containsKey('90')?(mapDaysTotalAmount.get('90')/(count==0?1:count)):0;
        temp_180DaysValue = mapDaysTotalAmount.containsKey('180')?(mapDaysTotalAmount.get('180')/(count2==0?1:count2)):0; //mapDaysTotalAmount.get('180')/count1;
        temp_270DaysValue = mapDaysTotalAmount.containsKey('270')?(mapDaysTotalAmount.get('270')/(count3==0?1:count3)):0;//mapDaysTotalAmount.get('270')/count2;
        temp_360DaysValue = mapDaysTotalAmount.containsKey('366')?(mapDaysTotalAmount.get('366')/(count4==0?1:count4)):0;//mapDaysTotalAmount.get('366')/count3;
        ////system.debug('**********temp_360DaysValue'+temp_360DaysValue+'*********temp_180DaysValue**-----'+temp_180DaysValue+'==========temp_270DaysValue'+temp_270DaysValue+'********------temp_360DaysValue'+temp_360DaysValue);
        //newLIstUpdate=new List<Opportunity_Campaign_Attribution__c>();
        
        ////system.debug('-------***************listCampaignAttribute'+listCampaignAttribute);
        for(Opportunity_Campaign_Attribution__c instanceObj:listCampaignAttribute){
            
            if(mapIdVsOpptyCampaign.containsKey(ss)){
                    
                if( mapIdVsOpptyCampaign.get(ss).days__c<=90){
                    instanceObj.Amount__C=temp_90DaysValue;
                   
                }else if((mapIdVsOpptyCampaign.get(ss).days__c>90  && mapIdVsOpptyCampaign.get(ss).days__c<=180)){
                     instanceObj.Amount__C=temp_180DaysValue;
                  
                }else if((mapIdVsOpptyCampaign.get(ss).days__c>180  && mapIdVsOpptyCampaign.get(ss).days__c<=270)){
                      instanceObj.Amount__C=temp_270DaysValue;
                     
                }else if((mapIdVsOpptyCampaign.get(ss).days__c>270  && mapIdVsOpptyCampaign.get(ss).days__c<=366)){
                        instanceObj.Amount__C=temp_360DaysValue; 
                     
                }
            }
        }
    }
         //system.debug('******* listCampaignAttribute *****  '+ listCampaignAttribute.size());
         insert listCampaignAttribute;
}
    global void finish(Database.BatchableContext BC){
        CampaignROIBatchJobId__c customSettingValue=CampaignROIBatchJobId__c.getInstance('BatchId');
        customSettingValue.BatchJobId__c = '';
        update customSettingValue;
         //Get the AsyncApexJob that represents the Batch job using the Id from the BatchableContext  
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,  
        TotalJobItems, CreatedBy.Email, ExtendedStatus  
        from AsyncApexJob where Id = :BC.getJobId()];  
        //Email the Batch Job's submitter that the Job is finished.  
        User_Batch_History__c userBatchHistoryRec = [SELECT Batch_Id__c,Status__c, Batch_Completed_Date__c FROM User_Batch_History__c ORDER BY CreatedDate Desc limit 1];
        userBatchHistoryRec.Batch_Id__c=a.Id;
        userBatchHistoryRec.Status__c=a.Status;
        userBatchHistoryRec.Batch_Completed_Date__c=system.now();
        update userBatchHistoryRec;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        String[] toAddresses = new String[] {a.CreatedBy.Email};  
        mail.setToAddresses(toAddresses);  
        mail.setSubject('BatchJobXYZ Status: ' + a.Status);  
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems );//+          ' batches with '+ a.NumberOfErrors + ' failures. ExtendedStatus: ' + a.ExtendedStatus);  
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
    }
}