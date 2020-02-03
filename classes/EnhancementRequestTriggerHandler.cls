/*  
Author :Kumud Thakur
Desc:Trigger Handler for EnhancementRequestTrigger 
Test class-EnhancementRequestTriggerHandlerTest
V1.0: Implemet auto assignment of the request as per the product and area of Request.
CreatedDate :5 july 2016
*/  
public class EnhancementRequestTriggerHandler {

/* To control recursion on this trigger, assuming a scenario where anything in this trigger updates another object which in turn again updates Enhancement_Request__c, a static 
variable could be used to prevent such a condition. A static variable retains its value in a transactional context 
*/
public static boolean isCurrentlyInExecution = false;

    public void processAllTriggerEvents(List<Enhancement_Request__c> triggerNew, Map<Id, Enhancement_Request__c> triggerNewMap,  List<Enhancement_Request__c> triggerOld, Map<Id, Enhancement_Request__c> triggerOldMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isBefore, Boolean isAfter, Boolean isUnDelete){

        if(isCurrentlyInExecution){
            //Dont do anything. Simply return as this is a recursion. This will break the flow.
            return;
        } else {
            //Set the flag for the first time this trigger is called in a transaction.
            isCurrentlyInExecution = true;
        }

     
        
     
    
        /*  BEFORE INSERT. You can also join multiple BEFORE Events like Before Update/Before Insert if you like. */
        if(isInsert && isBefore){
           onBeforeInsert(triggerNew);
        }
        
        /* BEFORE UPDATE Event 
        if(isUpdate && isBefore){
            OnBeforeUpdate(triggerOld, triggerOldMap, TriggerNew, triggerNewMap);
        }

         AFTER UPDATE Event 
        if(isUpdate && isAfter){
            OnAfterUpdate(triggerOld, triggerOldMap, TriggerNew, triggerNewMap);
        }
        
        /* BEFORE DELETE Event 
        if(isBefore && isDelete){
            OnBeforeDelete(triggerOld, triggerOldMap);
        }*/

    }

/* Event Handlers */
   public void onBeforeInsert(List<Enhancement_Request__c> triggerNew){
        
        Set<String> setProduct=new Set<String>();
        Set<String> setArea=new Set<String>();
        Map<String,String> mapProAreaVsuserId=new Map<String,String>();
        for(Enhancement_Request__c instEnhnceReq:triggerNew){
                setProduct.add(instEnhnceReq.Product__c);
                setArea.add(instEnhnceReq.Area__c);
            
            
        }
        for(Manage_Assignment__c instaManageAssgn:[select UserId__c,Area__c,Product__c from Manage_Assignment__c where Product__c in : setProduct and Area__c in : setArea]){
            
            String key=instaManageAssgn.Product__c.trim()+instaManageAssgn.Area__c.trim();
            mapProAreaVsuserId.put(key,instaManageAssgn.UserId__c);
        }
        
        for(Enhancement_Request__c instEnhnceReq:triggerNew){
            
            string key=instEnhnceReq.Product__c.trim()+instEnhnceReq.Area__c.trim();
            instEnhnceReq.Assigned_To__c=mapProAreaVsuserId.containsKey(key)?mapProAreaVsuserId.get(key):null;
        }
        
        
    }
  /*  public void OnBeforeUpdate(List<Enhancement_Request__c>  triggerOld, Map<ID, Enhancement_Request__c> triggerOldMap, List<Enhancement_Request__c>  triggerNew, Map<ID, Enhancement_Request__c> triggerNewMap){
        //Do all your before update logic here. 
    }

    public void OnBeforeDelete( List<Enhancement_Request__c> triggerOld, Map<Id, Enhancement_Request__c> triggerOldMap){
    }

    
    public void OnAfterUpdate(List<Enhancement_Request__c> triggerNew, Map<Id, Enhancement_Request__c> triggerNewMap,  List<Enhancement_Request__c> triggerOld, Map<Id, Enhancement_Request__c> triggerOldMap){
        
    }*/
  
}