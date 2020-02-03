public class AccountServiceHelperClass
{
    @InvocableMethod
    public static void AccountServiceHelperMethod(List<Id> accountIds)
    {
        System.debug('Account===>'+accountIds);
        List<HODI_Inventory__c> HODIUpdate_List=new List<HODI_Inventory__c>();
        Map<Id,Decimal> HODIIdVsPoint_Map=new Map<Id,Decimal>();
        if(accountIds!=null && accountIds.size()>0){
           For(Account accValue: [SELECT Id,HODI_Id_Dev__c,HODI_Count_Dev__c,Service_Tier__c,Desired_Tier_Dev__c FROM Account WHERE Id IN : accountIds AND Service_Tier__c!=''])// AND Share_of_Wallet_Client__c!=null
           {
               HODIIdVsPoint_Map.put(Id.ValueOf(accValue.HODI_Id_Dev__c),math.abs(accValue.HODI_Count_Dev__c));
           }
        }
        System.debug('HODIIdVsPoint_Map===>'+HODIIdVsPoint_Map);
        if(HODIIdVsPoint_Map!=null)
        {
                For(HODI_Inventory__c HODIRecord : [SELECT Id,Name,Head_of_Department__c,Head_of_Department__r.Name,Pool_Point__c FROM HODI_Inventory__c WHERE Id IN :HODIIdVsPoint_Map.keySet()])
                {
                    HODIRecord.Pool_Point__c = HODIRecord.Pool_Point__c + HODIIdVsPoint_Map.get(HODIRecord.Id);
                    HODIUpdate_List.add(HODIRecord);
                }
        }
        System.debug('HODIUpdate_List===>'+HODIUpdate_List);
        if(HODIUpdate_List!=null && HODIUpdate_List.size()>0)
        update HODIUpdate_List;
    
    
    }
}