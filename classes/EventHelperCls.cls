/**
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 23rd July 2014
 */
public class EventHelperCls {
    
    public static Boolean recursiveFlag=true;
    
    public void OnBeforeInsert(List<Event> newValues){
        //system.debug('Insert');
    }
    public void OnAfterInsert(Map<Id,Event> newMapValues){          
        
        // Blue Release check box functionality
        map<Id,List<Event>> mapContIdLstTsk = new map<Id,List<Event>>(); 
        //Merged trigger "Eventtriggerbulk" on after update and after insert
        List<Id> idESB =  new List<Id>();
        List<Id> idProjActi = new List<Id>();
        //Merged trigger "Eventtriggerbulk" on after update and after insert
        for(Event instOfEvent : newMapValues.values()){
            //Merged trigger "Eventtriggerbulk" on after update and after insert
            if(instOfEvent.WhatId!=null){
                String instOfStr = instOfEvent.WhatId;
                if(instOfStr.startsWith('a0B')){
                    idESB.add(instOfEvent.WhatId);
                }else if(instOfStr.startsWith('a07')){
                    idProjActi.add(instOfEvent.WhatId);
                }
            }
            //Merged trigger "Eventtriggerbulk" on after update and after insert
        }
                
        //Merged trigger "Eventtriggerbulk" on after update and after insert
        List<EB_SB_Builder__c> lstEBSB = new List<EB_SB_Builder__c>();
        List<EB_SB_Builder__c> lstEBSBCase = new List<EB_SB_Builder__c>();
        List<EB_SB_Builder__c> lstEBSBEvent = new List<EB_SB_Builder__c>();
        if(idESB.size()>0){
            lstEBSB = [SELECT Id,Build_Out_Time_Exhausted__c,(SELECT Id,Minutes_on_tasks__c FROM Tasks) FROM EB_SB_Builder__c WHERE Id =: idESB ];
            //Changes for getting complete total
            lstEBSBEvent = [SELECT Id,Build_Out_Time_Exhausted__c,Talktime_Exhausted__c,(SELECT  Minutes_on_tasks__c,DurationInMinutes,Id FROM Events) FROM EB_SB_Builder__c WHERE Id =: idESB ];
            lstEBSBCase = [SELECT Id,Build_Out_Time_Exhausted__c,(SELECT Min_s_Spent__c,Id FROM Cases__r) FROM EB_SB_Builder__c WHERE Id =: idESB ];
            //Changes for getting complete total
        }
        
        List<Project_Activity__c> lstProjActEvent = new List<Project_Activity__c>();
        List<Project_Activity__c> lstProjAct = new List<Project_Activity__c>();
        if(idProjActi.size()>0){
            lstProjAct = [SELECT Id,Actual_Time_Spent__c,(SELECT Id,Minutes_on_tasks__c FROM Tasks) FROM Project_Activity__c WHERE Id =: idProjActi ];
            //Changes for getting complete total
            lstProjActEvent = [SELECT Id,Actual_Time_Spent__c,(SELECT DurationInMinutes,Minutes_on_tasks__c FROM Events) FROM Project_Activity__c WHERE Id=: idProjActi];
            //Changes for getting complete total
        }
        
        //Changes for getting complete total
        Map<Id,EB_SB_Builder__c> mapEBSBIdCount = new Map<Id,EB_SB_Builder__c>();
       
        
        for(EB_SB_Builder__c instOfEBSBSec : lstEBSB){
            Double Sum = 0;
            for(Task instOfTsk : instOfEBSBSec.Tasks){
                if(instOfTsk.Minutes_on_tasks__c != null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c;
            }
            instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60;
            //lstEBSBSec.add(instOfEBSBSec);
            mapEBSBIdCount.put(instOfEBSBSec.Id,instOfEBSBSec);
        }
        
        for(EB_SB_Builder__c instOfEBSBSec : lstEBSBCase){
            Double Sum = 0;
            for(Case instOfTsk : instOfEBSBSec.Cases__r){
                if(instOfTsk.Min_s_Spent__c != null)
                Sum = Sum + instOfTsk.Min_s_Spent__c;
            }
            Double taskValue = mapEBSBIdCount.get(instOfEBSBSec.Id).Build_Out_Time_Exhausted__c;
            instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60 + taskValue;
            mapEBSBIdCount.put(instOfEBSBSec.Id,instOfEBSBSec);
        }
        
        
        for(EB_SB_Builder__c instOfEBSBSec : lstEBSBEvent){
            Double Sum = 0;
            Double SumSec = 0;
            for(Event instOfTsk : instOfEBSBSec.Events){
                if(instOfTsk.Minutes_on_tasks__c != null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c;
                SumSec = SumSec + instOfTsk.DurationInMinutes;
            }
            Double taskValue = mapEBSBIdCount.get(instOfEBSBSec.Id).Build_Out_Time_Exhausted__c;
            instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60 + taskValue;
            instOfEBSBSec.Talktime_Exhausted__c = SumSec/60;
            mapEBSBIdCount.put(instOfEBSBSec.Id,instOfEBSBSec);
        }
        
        if(mapEBSBIdCount.values().size()>0)
        update mapEBSBIdCount.values();
        
        //Changes for getting complete total
        
        Map<Id,Project_Activity__c> mapProjActIdCount = new Map<Id,Project_Activity__c>();
        
        for(Project_Activity__c instOfProjAct : lstProjAct){
            Double Sum = 0;
            for(Task instOfTsk : instOfProjAct.Tasks){
                if(instOfTsk.Minutes_on_tasks__c != null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c;
            }
            instOfProjAct.Actual_Time_Spent__c = Sum/60;
            //lstProjActSec.add(instOfProjAct);
            mapProjActIdCount.put(instOfProjAct.Id,instOfProjAct);
        }
        
        for(Project_Activity__c instOfProjAct : lstProjActEvent){
            Double Sum = 0;
            for(Event instOfTsk : instOfProjAct.Events){
                if(instOfTsk.Minutes_on_tasks__c != null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c ;
                Sum = Sum + instOfTsk.DurationInMinutes;
            }
            Double taskValue = mapProjActIdCount.get(instOfProjAct.Id).Actual_Time_Spent__c;
            instOfProjAct.Actual_Time_Spent__c = Sum/60 + taskValue;
            //lstProjActSec.add(instOfProjAct);
            mapProjActIdCount.put(instOfProjAct.Id,instOfProjAct);
        }
        
        if(mapProjActIdCount.values().size()>0)
        update mapProjActIdCount.values();
        //Merged trigger "Eventtriggerbulk" on after update and after insert
        
        futureMethod(newMapValues.keySet());

        UpdateStatusSQL(newMapValues);  
    }
    public void OnBeforeUpdate(Map<Id,Event> oldMapValues,Map<Id,Event> newMapValues){   
                        
    }
    public void OnAfterUpdate(Map<Id,Event> oldMapValues,Map<Id,Event> newMapValues){
        if(recursiveFlag == true){
            // Blue Release check box functionality
            map<Id,List<Event>> mapContIdLstTsk = new map<Id,List<Event>>(); 
            
            //Merged trigger "Eventtriggerbulk" on after update and after insert
            List<Id> idESB =  new List<Id>();
            List<Id> idProjActi = new List<Id>();
            //Merged trigger "Eventtriggerbulk" on after update and after insert
            
            for(Event instOfEvent: newMapValues.values()){
                //Merged trigger "Eventtriggerbulk" on after update and after insert
                if(instOfEvent.WhatId!=null){
                    String instOfWhatId = instOfEvent.WhatId;
                    if((instOfEvent.Minutes_on_tasks__c != oldMapValues.get(instOfEvent.id).Minutes_on_tasks__c || instOfEvent.DurationInMinutes != oldMapValues.get(instOfEvent.id).DurationInMinutes) && instOfWhatId.startsWith('a0B')){
                        idESB.add(instOfEvent.Whatid);
                    }else if((instOfEvent.Minutes_on_tasks__c != oldMapValues.get(instOfEvent.id).Minutes_on_tasks__c || instOfEvent.DurationInMinutes != oldMapValues.get(instOfEvent.id).DurationInMinutes) && instOfWhatId.startsWith('a07')){
                        idProjActi.add(instOfEvent.Whatid);
                    }
                }
                //Merged trigger "Eventtriggerbulk" on after update and after insert
            }
            
      //Merged trigger "Eventtriggerbulk" on after update and after insert
            List<EB_SB_Builder__c> lstEBSB = new List<EB_SB_Builder__c>();
            List<EB_SB_Builder__c> lstEBSBCase = new List<EB_SB_Builder__c>();
            List<EB_SB_Builder__c> lstEBSBEvent = new List<EB_SB_Builder__c>();
            
            if(idESB.size()>0){
                lstEBSB = [SELECT Id,Build_Out_Time_Exhausted__c,(SELECT Id,Minutes_on_tasks__c FROM Tasks) FROM EB_SB_Builder__c WHERE Id =: idESB ];
                //Changes for getting complete total
                lstEBSBEvent = [SELECT Id,Build_Out_Time_Exhausted__c,Talktime_Exhausted__c,(SELECT  Minutes_on_tasks__c, DurationInMinutes,Id FROM Events) FROM EB_SB_Builder__c WHERE Id =: idESB ];
                lstEBSBCase = [SELECT Id,Build_Out_Time_Exhausted__c,(SELECT Min_s_Spent__c,Id FROM Cases__r) FROM EB_SB_Builder__c WHERE Id =: idESB ];
                //Changes for getting complete total
            }
            
            List<Project_Activity__c> lstProjActEvent = new List<Project_Activity__c>();
            List<Project_Activity__c> lstProjAct = new List<Project_Activity__c>();
            if(idProjActi.size()>0){
                lstProjAct = [SELECT Id,Actual_Time_Spent__c,(SELECT Id,Minutes_on_tasks__c FROM Tasks) FROM Project_Activity__c WHERE Id =: idProjActi ];
                //Changes for getting complete total
                lstProjActEvent = [SELECT Id,Actual_Time_Spent__c,(SELECT DurationInMinutes,Minutes_on_tasks__c FROM Events) FROM Project_Activity__c WHERE Id=: idProjActi];
                //Changes for getting complete total
            }
            
            //Changes for getting complete total
            Map<Id,EB_SB_Builder__c> mapEBSBIdCount = new Map<Id,EB_SB_Builder__c>();
           
            
            for(EB_SB_Builder__c instOfEBSBSec : lstEBSB){
                Double Sum = 0;
                for(Task instOfTsk : instOfEBSBSec.Tasks){
                    if(instOfTsk.Minutes_on_tasks__c != null)
                    Sum = Sum + instOfTsk.Minutes_on_tasks__c;
                }
                instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60;
                //lstEBSBSec.add(instOfEBSBSec);
                mapEBSBIdCount.put(instOfEBSBSec.Id,instOfEBSBSec);
            }
            
            for(EB_SB_Builder__c instOfEBSBSec : lstEBSBCase){
                Double Sum = 0;
                for(Case instOfTsk : instOfEBSBSec.Cases__r){
                    if(instOfTsk.Min_s_Spent__c != null)
                    Sum = Sum + instOfTsk.Min_s_Spent__c;
                }
                Double taskValue = mapEBSBIdCount.get(instOfEBSBSec.Id).Build_Out_Time_Exhausted__c;
                instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60 + taskValue;
                mapEBSBIdCount.put(instOfEBSBSec.Id,instOfEBSBSec);
            }
            
            
            for(EB_SB_Builder__c instOfEBSBSec : lstEBSBEvent){
                Double Sum = 0;
                Double SumSec = 0;
                for(Event instOfTsk : instOfEBSBSec.Events){
                    if(instOfTsk.Minutes_on_tasks__c != null)
                    Sum = Sum + instOfTsk.Minutes_on_tasks__c;
                    if(instOfTsk.DurationInMinutes != null)
                    SumSec = SumSec + instOfTsk.DurationInMinutes;
                }
                Double taskValue = mapEBSBIdCount.get(instOfEBSBSec.Id).Build_Out_Time_Exhausted__c;
                instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60 + taskValue;
                instOfEBSBSec.Talktime_Exhausted__c = SumSec/60;
                mapEBSBIdCount.put(instOfEBSBSec.Id,instOfEBSBSec);
            }
            system.debug('mapEBSBIdCount.values()+++'+mapEBSBIdCount.values());
            if(mapEBSBIdCount.values().size()>0)
            update mapEBSBIdCount.values();
            //Changes for getting complete total
            
            Map<Id,Project_Activity__c> mapProjActIdCount = new Map<Id,Project_Activity__c>();
        
            for(Project_Activity__c instOfProjAct : lstProjAct){
                Double Sum = 0;
                for(Task instOfTsk : instOfProjAct.Tasks){
                    if(instOfTsk.Minutes_on_tasks__c != null)
                    Sum = Sum + instOfTsk.Minutes_on_tasks__c;
                }
                instOfProjAct.Actual_Time_Spent__c = Sum/60;
                //lstProjActSec.add(instOfProjAct);
                mapProjActIdCount.put(instOfProjAct.Id,instOfProjAct);
            }
            
            for(Project_Activity__c instOfProjAct : lstProjActEvent){
                Double Sum = 0;
                for(Event instOfTsk : instOfProjAct.Events){
                    if(instOfTsk.Minutes_on_tasks__c != null)
                    Sum = Sum + instOfTsk.Minutes_on_tasks__c ;
                    Sum = Sum + instOfTsk.DurationInMinutes;
                }
                Double taskValue = mapProjActIdCount.get(instOfProjAct.Id).Actual_Time_Spent__c;
                instOfProjAct.Actual_Time_Spent__c = Sum/60 + taskValue;
                //lstProjActSec.add(instOfProjAct);
                mapProjActIdCount.put(instOfProjAct.Id,instOfProjAct);
            }
            
            if(mapProjActIdCount.values().size()>0)
            update mapProjActIdCount.values();
            
            
            //Update Sales Qualified Contact Status  Added by Shanu on 26-04-2017
            UpdateStatusSQL(newMapValues);


            //Merged trigger "Eventtriggerbulk" on after update and after insert
            if(System.IsBatch() == false && System.isFuture() == false){   // added by udita for gdpr batch createPersonaDatabatch
              futureMethod(newMapValues.keySet());
            }
        }
    }
    
    public void OnBeforeDelete(List<Event> oldValues,Map<Id,Event> oldMapValues){
        system.debug('Delete');
    }
    
    public void OnAfterDelete(List<Event> oldValues,Map<Id,Event> oldMapValues){
        system.debug('Delete');
        //Merged trigger "Eventtriggerbulk" on after update and after insert
        List<Id> idESB =  new List<Id>();
        List<Id> idProjActi = new List<Id>();
        for(Event instOfEvent : oldValues){
            if(instOfEvent.WhatId!=null){
                String instOfStr = instOfEvent.WhatId;
                if(instOfStr.startsWith('a0B') ){
                    idESB.add(instOfEvent.WhatId);
                }else if(instOfStr.startsWith('a07')){
                    idProjActi.add(instOfEvent.WhatId);
                }
            }
        }
        List<EB_SB_Builder__c> lstEBSB = new List<EB_SB_Builder__c>();
        List<EB_SB_Builder__c> lstEBSBCase = new List<EB_SB_Builder__c>();
        List<EB_SB_Builder__c> lstEBSBEvent = new List<EB_SB_Builder__c>();
        
        if(idESB.size()>0){
            lstEBSB = [SELECT Id,Build_Out_Time_Exhausted__c,(SELECT Id,Minutes_on_tasks__c FROM Tasks) FROM EB_SB_Builder__c WHERE Id =: idESB ];
            //Changes for getting complete total
            lstEBSBEvent = [SELECT Id,Build_Out_Time_Exhausted__c,Talktime_Exhausted__c,(SELECT  Minutes_on_tasks__c, DurationInMinutes,Id FROM Events) FROM EB_SB_Builder__c WHERE Id =: idESB ];
            lstEBSBCase = [SELECT Id,Build_Out_Time_Exhausted__c,(SELECT Min_s_Spent__c,Id FROM Cases__r) FROM EB_SB_Builder__c WHERE Id =: idESB ];
            //Changes for getting complete total
        }
        
        List<Project_Activity__c> lstProjActEvent = new List<Project_Activity__c>();
        List<Project_Activity__c> lstProjAct = new List<Project_Activity__c>();
        
        if(idProjActi.size()>0){
            lstProjAct = [SELECT Id,Actual_Time_Spent__c,(SELECT Id,Minutes_on_tasks__c FROM Tasks) FROM Project_Activity__c WHERE Id =: idProjActi ];
            //Changes for getting complete total
            lstProjActEvent = [SELECT Id,Actual_Time_Spent__c,(SELECT DurationInMinutes,Minutes_on_tasks__c FROM Events) FROM Project_Activity__c WHERE Id=: idProjActi];
            //Changes for getting complete total
        }
        
        //Changes for getting complete total
        Map<Id,EB_SB_Builder__c> mapEBSBIdCount = new Map<Id,EB_SB_Builder__c>();
        
        for(EB_SB_Builder__c instOfEBSBSec : lstEBSB){
            Double Sum = 0;
            for(Task instOfTsk : instOfEBSBSec.Tasks){
                if(instOfTsk.Minutes_on_tasks__c != null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c;
            }
            instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60;
            //lstEBSBSec.add(instOfEBSBSec);
            mapEBSBIdCount.put(instOfEBSBSec.Id,instOfEBSBSec);
        }
        
        for(EB_SB_Builder__c instOfEBSBSec : lstEBSBCase){
            Double Sum = 0;
            for(Case instOfTsk : instOfEBSBSec.Cases__r){
                if(instOfTsk.Min_s_Spent__c != null)
                Sum = Sum + instOfTsk.Min_s_Spent__c;
            }
            Double taskValue = mapEBSBIdCount.get(instOfEBSBSec.Id).Build_Out_Time_Exhausted__c;
            instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60 + taskValue;
            mapEBSBIdCount.put(instOfEBSBSec.Id,instOfEBSBSec);
        }
        
        
        for(EB_SB_Builder__c instOfEBSBSec : lstEBSBEvent){
            Double Sum = 0;
            Double SumSec = 0;
            for(Event instOfTsk : instOfEBSBSec.Events){
                if(instOfTsk.Minutes_on_tasks__c != null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c;
                if(instOfTsk.DurationInMinutes != null)
                SumSec = SumSec + instOfTsk.DurationInMinutes;
            }
            Double taskValue = mapEBSBIdCount.get(instOfEBSBSec.Id).Build_Out_Time_Exhausted__c;
            instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60 + taskValue;
            instOfEBSBSec.Talktime_Exhausted__c = SumSec/60;
            mapEBSBIdCount.put(instOfEBSBSec.Id,instOfEBSBSec);
        }
        
        if(mapEBSBIdCount.values().size()>0)
        update mapEBSBIdCount.values();
        //Changes for getting complete total
        
        Map<Id,Project_Activity__c> mapProjActIdCount = new Map<Id,Project_Activity__c>();
        
        for(Project_Activity__c instOfProjAct : lstProjAct){
            Double Sum = 0;
            for(Task instOfTsk : instOfProjAct.Tasks){
                if(instOfTsk.Minutes_on_tasks__c != null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c;
            }
            instOfProjAct.Actual_Time_Spent__c = Sum/60;
            //lstProjActSec.add(instOfProjAct);
            mapProjActIdCount.put(instOfProjAct.Id,instOfProjAct);
        }
        
        for(Project_Activity__c instOfProjAct : lstProjActEvent){
            Double Sum = 0;
            for(Event instOfTsk : instOfProjAct.Events){
                if(instOfTsk.Minutes_on_tasks__c != null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c ;
                Sum = Sum + instOfTsk.DurationInMinutes;
            }
            Double taskValue = mapProjActIdCount.get(instOfProjAct.Id).Actual_Time_Spent__c;
            instOfProjAct.Actual_Time_Spent__c = Sum/60 + taskValue;
            //lstProjActSec.add(instOfProjAct);
            mapProjActIdCount.put(instOfProjAct.Id,instOfProjAct);
        }
        
        if(mapProjActIdCount.values().size()>0)
        update mapProjActIdCount.values();
        //Merged trigger "Eventtriggerbulk" on after update and after insert
    }
    public void OnUndelete(List<Event> newValues){
        system.debug('Delete');
    }
    
    /*
    **  Update Sales Qualified Contact Status 
    **  Added on 26-04-2017 by Shanu
    **/
    public void UpdateStatusSQL(Map<Id,Event> newMapValues){
    
        String conStatusField;
        Map<Id,Contact> updateConList = new Map<Id,Contact>();
        Integer order=0;
            
        Map<Id,Id> eventVsContactMap = new Map<Id,Id>();

        for(Event instOfEvent : newMapValues.values()){
            if(instOfEvent.WhoId != null && instOfEvent.CSN_Show__c==true && !instOfEvent.Subject.containsIgnoreCase('Telecon') && !instOfEvent.Subject.ContainsIgnoreCase('Qualifying')){
                if(string.valueOf(instOfEvent.WhoId).startsWith('003')){
                    eventVsContactMap.put(instOfEvent.Id,instOfEvent.WhoId);                    
                }
            }
        } 
        if(!eventVsContactMap.isEmpty()){
            Map<Id,Contact> contactMap = new Map<Id,Contact>([Select Id,CC_Contact_Status__c,CSN_P_Contact_Status__c,CSNS_Contact_Status__c,Event_Contact_Status__c,Survey_Contact_Status__c From Contact Where ID IN: eventVsContactMap.values()]);
            
            for(Id eventId : eventVsContactMap.keySet()){
                Event eventobj = newMapValues.get(eventId);
                Contact conObj = contactMap.get(eventobj.WhoId);
                
                //Product is not null
                if(eventobj.Product__c != null){ 
                    Map<String,DWF_Product_Vs_Status_Vs_Owner_Field__c> dwfSettingMap = DWF_Product_Vs_Status_Vs_Owner_Field__c.getAll();                   
                    for(String product : eventobj.Product__c.split(';')){
                        order=0;
                        //if(DWF_Product_Vs_Status_Vs_Owner_Field__c.getValues(product) != null ){ // commented on 13 Nov - Custom setting 40 char limitation on Name 
                        if(dwfSettingMap.containsKey(product)){
                            conStatusField = dwfSettingMap.get(product).Contact_Status_Field__c;
                            DWF_Contact_Status_Order__c orderSetting  = DWF_Contact_Status_Order__c.getValues(String.ValueOf(conObj.get(conStatusField)));
                            if(conStatusField!=null && (conObj.get(conStatusField)==null || (orderSetting!=null && orderSetting.Order__c<6))){
                                conObj.put(conStatusField,'Sales Qualified');
                            }
                        }
                    }
                }else{
                    DWF_Product_Vs_Status_Vs_Owner_Field__c roleSetting = DWF_Product_Vs_Status_Vs_Owner_Field__c.getValues(eventobj.Task_Assigned_Role__c);
                    
                    if(roleSetting!=null){
                        conStatusField = roleSetting.Contact_Status_Field__c;
                        DWF_Contact_Status_Order__c orderSetting  = DWF_Contact_Status_Order__c.getValues(String.ValueOf(conObj.get(conStatusField)));
                        
                        if(conStatusField!=null && (conObj.get(conStatusField)==null || (orderSetting!=null && orderSetting.Order__c<6))){
                            conObj.put(conStatusField,'Sales Qualified');
                        }
                    }
                }
                updateConList.put(conObj.Id,conObj);
            }
            if(updateConList.size()>0 && !updateConList.isEmpty())
                update updateConList.values();
        }
    }

        
        
    @future
    public static void futureMethod(Set<Id> newMapValues){
        if(recursiveFlag==true){
            RecordType instRecType = [SELECT Name, IsActive, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Event' And IsActive = true And DeveloperName = 'SMM_BD_Presentations'];      
            List<Event> lstEvent =  [SELECT AccountId,Account.Name,Who.Name,DS_Approved__c,CreatedById,StartDateTime,Attachment__c, (SELECT Id FROM Attachments) FROM Event WHERE Id =: newMapValues And RecordTypeId =: instRecType.id];     
            List<Event> lstEventSec = new List<Event>();
            String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            map<Id,Event> mapUserId = new map<Id,Event>();
            for(Event instEvent : lstEvent){
                if((instEvent.Attachments.size()>0) && instEvent.Attachment__c != true){
                    instEvent.Attachment_Link__c = sfdcBaseURL+'/servlet/servlet.FileDownload?file='+instEvent.Attachments[0].id;
                    instEvent.Attachment__c = true;
                    mapUserId.put(instEvent.CreatedById,instEvent);
                    lstEventSec.add(instEvent);
                }           
            }
            map<Id,Event> mapUserIdSec = new map<Id,Event>();
            List<Event_Attachment_Email_Sending_Mapping__c> lstEventAESM = Event_Attachment_Email_Sending_Mapping__c.getall().values();
            for(Id userId : mapUserId.keySet()){
                for(Event_Attachment_Email_Sending_Mapping__c userIdSec : lstEventAESM){
                    if(userId == userIdSec.User_Creating__c){
                        mapUserIdSec.put(userIdSec.User_Mapped__c,mapUserId.get(userId));
                    }
                }
            }
            List<User> lstUserSec = [SELECT Id,Name FROM User WHERE Id=:mapUserId.keySet()];
            List<User> lstUser = [SELECT Id,Email From User WHERE Id =: mapUserIdSec.keySet()];
            if(lstUser.size()>0){
                Messaging.SingleEmailMessage email =  new  Messaging.SingleEmailMessage();
                email.setTargetObjectId(lstUser[0].id); 
                //String strdate = mapUserIdSec.get(lstUser[0].id).StartDateTime.format(); 
                email.setSubject('Presentation created-'+mapUserIdSec.get(lstUser[0].id).Account.Name+'-'+'-'+mapUserIdSec.get(lstUser[0].id).StartDateTime.format()); 
                email.setHtmlBody('A new file has been added for your approval please'+' '+'<a href="'+sfdcBaseURL+'/'+mapUserIdSec.get(lstUser[0].id).Id+'">Click Here</a>'+
                '<br><br><br>'+'<b>Account Name</b>'+'&nbsp;&nbsp;'+'-'+'&nbsp;&nbsp;'+'<b>'+mapUserIdSec.get(lstUser[0].id).Account.Name+'</b>'+
                '<br>'+'<b>Contact Name</b>'+'&nbsp;&nbsp;'+'-'+'&nbsp;&nbsp;'+'<b>'+mapUserIdSec.get(lstUser[0].id).Who.Name+'</b>'+
                '<br>'+'<b>Presentation Creator</b>'+'&nbsp;&nbsp;'+'-'+'&nbsp;&nbsp;'+'<b>'+lstUserSec[0].Name+'</b>'+
                '<br>'+'<b>Date of presentation</b>'+'&nbsp;&nbsp;'+'-'+'&nbsp;&nbsp;'+'<b>'+mapUserIdSec.get(lstUser[0].id).StartDateTime.format()+'</b>'); 
                email.setSaveAsActivity(false);
                Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
            }
            recursiveFlag = false;
            update lstEventSec;         
        }
    }    
}