/**********************************************************************************
Class to update AccountTeamMemberInformation on Account
**********************************************************************************/
global class BatchUpdateAccountTeamMembersOnAccount implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Fetching account and its associated team members
        return Database.getQueryLocator([Select id/*,AM_CrowdTorch__c*/,AM_CSN__c,/*AM_CT_TM__c,*/AM_Event__c,AM_Survey__c,AM_PA__c,/*AM_TicketMob__c,*/AM_Pre_Sales_Event__c,CS_Rep__c,(Select TeamMemberRole,User.Name From AccountTeamMembers) FROM Account where Account_Status__c Like 'Active%']);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        //try{
        //Crating a map of customsetting
        Map<String,String>teamRoleFieldAPIMap = new Map<String,String>();
        
        List<AccountAndTeamMembersSetting__c> teamFieldAPI = AccountAndTeamMembersSetting__c.getall().values();
        for(AccountAndTeamMembersSetting__c st: teamFieldAPI) {
            if(!teamRoleFieldAPIMap.containsKey(st.Name)) {
                teamRoleFieldAPIMap.put(st.Name,st.FieldAPIName__c);
            }
        }
        
        //Looping over account
        List<Account> accountsToUpdate = new List<Account>();
        for(Account acc: scope){
            String csRepValue = '';
            Map<String,String> fieldAndValueMap = new Map<String,String>();
            Set<String> alreadyExistCSRep = new Set<String>();
            
            for(AccountTeamMEmber actm: acc.AccountTeamMembers) {
                
                //creating map of fieldapiname and value to populate 
                if(teamRoleFieldAPIMap.containsKey(actm.TeamMemberRole) && actm.TeamMemberRole.startsWith('CS -') && !alreadyExistCSRep.contains(actm.TeamMemberRole)) {
                    csRepValue = csRepValue + actm.User.Name  + ';';
                    alreadyExistCSRep.add(actm.TeamMemberRole);
                    fieldAndValueMap.put(teamRoleFieldAPIMap.get(actm.TeamMemberRole),csRepValue);
                }
                if(teamRoleFieldAPIMap.containsKey(actm.TeamMemberRole) && !actm.TeamMemberRole.startsWith('CS -')) {
                    fieldAndValueMap.put(teamRoleFieldAPIMap.get(actm.TeamMemberRole),actm.User.Name);
                }
                
            }
            
            //loop over customsetting fields to populate values in fields used in custom setting
            for(String fname: teamRoleFieldAPIMap.values()) {
                //Added by Shanu : August 2016 ( Check If Field is being changed only updates) 
                if(fieldAndValueMap.containsKey(fname) && acc.get(fname)!=fieldAndValueMap.get(fname)) {
                    acc.put(fname,fieldAndValueMap.get(fname));
                } 
            }
            
            accountsToUpdate.add(acc);
        }
        
        if(accountsToUpdate.size() > 0) {
            update accountsToUpdate;
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
    } 
}