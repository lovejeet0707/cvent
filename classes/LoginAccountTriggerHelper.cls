public class LoginAccountTriggerHelper{
    public static void beforeDelete(List<Login_Account__c> oldValues,Map<Id,Login_Account__c> oldMapValues){
        /******TICCM-200 - Preventing Login Account from deletion.****/
        Set<String> authorizedUserSet = new Set<String>();
        //Accessing custom setting.....................
        For(LoginAccPayGo_Records_Delete_Prevention__c PG : LoginAccPayGo_Records_Delete_Prevention__c.getall().values()){
            authorizedUserSet.add(PG.Name);
        }
        For(Login_Account__c LARec : oldValues)
        {   
            if((authorizedUserSet.size()>0 && !authorizedUserSet.contains(UserInfo.getUserId())) || authorizedUserSet.size()==0)
            {
                LARec.addError('Login Account cannot be deleted');
            }
        }
        /****************Ends Here***********************/
    }
    
    //Added By Mohsin
    //Jira Ticket - TICCM-222
    //Description - Automation on "PayGo Account Status" field of Account. 
    public static void payGoAccountStatusUpdate(Map<Id,Login_Account__c> newMap,Map<Id,Login_Account__c> oldMap)
    {
        Map<Id,Id> mapOfAccVsLoginAcc = new Map<Id,Id>();
        List<Account> accToBeUpdated = new List<Account>();
        for(Login_Account__c loginAcc : newMap.values())
        {
            if(oldMap == NULL || loginAcc.Status__c != oldMap.get(loginAcc.Id).Status__c)
            {
                mapOfAccVsLoginAcc.put(loginAcc.Customer__c,loginAcc.Id);
            }
        }
        
        if(!mapOfAccVsLoginAcc.isEmpty())
        {
            Map<Integer,String> priorityMap = new Map<Integer,String>{1 => 'Account Request',2 => 'Account Open',3 => 'Event Create',4 => 'Event Launch'};
            for(Account acc : [select id,PayGo_Account_Status__c,(select Id,Status__c from Login_Accounts__r) from Account where Id IN :mapOfAccVsLoginAcc.keySet()])
            {
                Integer priorityOrder = 0;
                for(Login_Account__c loginAccount : acc.Login_Accounts__r)  
                {
                    switch on loginAccount.Status__c
                    {
                        when 'Event Launch'
                        {
                            if(priorityOrder < 4)
                                priorityOrder = 4;
                        }
                        when 'Event Create'
                        {
                            if(priorityOrder < 3)
                                priorityOrder = 3;
                        }
                        when 'Account Open'
                        {
                            if(priorityOrder < 2)
                                priorityOrder = 2;
                        }
                        when 'Account Request'
                        {
                            if(priorityOrder < 1)
                                priorityOrder = 1;
                        }
                    }
                }
                acc.PayGo_Account_Status__c = priorityMap.get(priorityOrder);
                accToBeUpdated.add(acc);
            }
        }
        
        if(!accToBeUpdated.isEmpty())
        {
            update accToBeUpdated;
        }
    }
}