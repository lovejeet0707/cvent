trigger LoginAccountTrigger on Login_Account__c (after insert, after update,before delete) 
{
    if(Trigger.isAfter)
    {
       if(Trigger.isUpdate)
       {
          LoginAccountTriggerHelper.payGoAccountStatusUpdate(Trigger.newMap,Trigger.oldMap);
       }
        if(Trigger.isInsert)
        {
          LoginAccountTriggerHelper.payGoAccountStatusUpdate(Trigger.newMap,null);
        }
    }
    if(Trigger.IsBefore && Trigger.IsDelete){
      LoginAccountTriggerHelper.beforeDelete(trigger.old,trigger.oldMap);
    }
    /*Login_Account__c oldLoginAccountRec;
    Set<Id> addressIdSet = new Set<Id>();
    Map<Id,Login_Account__c> addressIdVsLoginAcc = new Map<Id,Login_Account__c>();
    Map<Id,Login_Account__c> opportunityIdVsLoginAcc = new Map<Id,Login_Account__c>();
    Address__c addressRec = new Address__c();
    List<Address__c> addressRecList = new List<Address__c>();
    For(Login_Account__c loginAccountRec : trigger.new)
    {
        oldLoginAccountRec = trigger.oldMap.get(loginAccountRec.Id);
        if(loginAccountRec.Attention_To__c!=null && loginAccountRec.Attention_To__c != oldLoginAccountRec.Attention_To__c){
            if(loginAccountRec.Bill_To_Address__c!=null)
                addressIdVsLoginAcc.put(loginAccountRec.Bill_To_Address__c,loginAccountRec);
            if(loginAccountRec.Ship_To_Address__c!=null)
                addressIdVsLoginAcc.put(loginAccountRec.Ship_To_Address__c,loginAccountRec);
        }
    }
    if(addressIdVsLoginAcc!=null)
    {
        For(Id recordId : addressIdVsLoginAcc.keySet())
        {
            addressRec = new Address__c();
            addressRec.Id = recordId;
            addressRec.LA_Attention_To__c = addressIdVsLoginAcc.get(recordId).Attention_To__c;
            addressRecList.add(addressRec);
        }
        if(addressRecList.size()>0)
            update addressRecList;
    }*/
}