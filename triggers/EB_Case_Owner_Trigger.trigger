trigger EB_Case_Owner_Trigger on Case (after insert, before update)
{    


    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    } 


    public EB_SB_Builder__c EB_account {get; private set;}
    public RecordType rtype {get; private set;}
    integer icount;
    String xd12,xd13;
    icount = 0;
    ID related_to_id, Owner_Id;
    Set<Id> tasksInSet = new Set<Id> {};
    if (Trigger.isInsert)
    {
    for (Case t : Trigger.new)
    {
    tasksInSet.add(t.Id);
    icount = icount +1;
    }
    }
      
    if (Trigger.isUpdate)
    {
    for (Case t : Trigger.new)
    {
    tasksInSet.add(t.Id);
    icount = icount +1;
    }
    }
  
    if (icount<=1)
    {
        if (Trigger.isInsert)
        {
           // Case[] accs;
          //  accs = Trigger.new;
            for (Case a:Trigger.new){
            Date myDate = Date.Today();
            Owner_Id = a.OwnerId;
            String Case_Sub = a.Subject;
            String Case_Desc = a.Description;
            String contact_id = a.ContactId;
            String Record_type_id = a.RecordTypeId;
            rtype = [Select r.Name, r.Id, r.Description From RecordType r where  r.Id =:Record_type_id];
            xd12= rtype.Description+'';
            xd13= xd12.substring(0,3);
            if (xd13 == '005')
            {
            if (contact_id != null)
            {
            Integer j = [Select count() from RecordType r where  r.Id =:Record_type_id];
            if(j==1)
            {
                for (Case tmp : [Select e.Event_Survey_Builder__c, e.OwnerId From Case e where e.id = :a.id limit 1]) {
                tmp.OwnerId = rtype.Description;
                tmp.Description = xd12;
                update tmp;
            }
            }
            
            Integer i = [select count() from EB_SB_Builder__c EB_SB where EB_SB.Contact__c = :contact_id and EB_SB.OwnerId = :rtype.Description];
            if(i==1)
            {
                EB_account = [select tmp2.Id from EB_SB_Builder__c tmp2 where tmp2.Contact__c = :contact_id and tmp2.OwnerId = :rtype.Description limit 1];
                for (Case tmp : [Select e.Event_Survey_Builder__c, e.OwnerId From Case e where e.id = :a.id limit 1]) {
                tmp.Event_Survey_Builder__c = EB_account.id;
                tmp.OwnerId = rtype.Description;
                update tmp;
                }
            }
         }
         Task ecs = new Task(Description= Case_Desc, Subject=Case_Sub, ActivityDate=myDate,Status ='Not Started', OwnerId=rtype.Description, WhatId=a.Id);
         insert ecs;
         icount = icount +1;
         }
         
         
            }
         
         
         
        }
        
        
        
        
        
        
        
        
        

    } 
    }