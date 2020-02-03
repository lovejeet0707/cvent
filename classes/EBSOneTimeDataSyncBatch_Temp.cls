Global class EBSOneTimeDataSyncBatch_Temp implements Database.Batchable<sObject>{
    
    global final String Query;
    global final String Entity;
    
    global EBSOneTimeDataSyncBatch_Temp(String queryStr, String objectName){
        
        Query = queryStr; 
        Entity = objectName;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //String q = 'select Id, OLD_EBS_Account_Id__c, OLD_Contact_Id__c, ebs_contact_id__c, account.ebs_account_id__c, ebs_account_id__c from contact where ebs_contact_id__c != null and lastmodifieddate > 2017-05
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        if(Entity.equalsIgnoreCase('Contact')){
            List<Contact> objList = (List<Contact>)scope;
            List<Contact> updateList = new List<Contact>();
            for(Contact obj : objList){
                //Process only the ones which were tied to a different account in Lanyon SF and hence causing an ID mismatch
                // OR the ones which are new contacts tied to a recently EBS synced account
                if((obj.account.ebs_account_id__c != null && obj.EBS_Account_ID__c != obj.account.ebs_account_id__c) || obj.EBS_Account_ID__c == null){
                    //select Id, ebs_contact_id__c, lastmodifiedby.name, account.ebs_account_id__c, ebs_account_id__c from contact where lastmodifieddate = yesterday and ebs_contact_id__c != null and ebs_account_id__c = null and account.ebs_account_id__c != null limit 10
                    obj.OLD_Contact_Id__c = obj.EBS_Contact_ID__c;
                    obj.OLD_EBS_Account_Id__c = obj.EBS_Account_ID__c;
                    obj.ebs_account_id__c = obj.account.ebs_account_id__c;
                    obj.EBS_Contact_ID__c = null;
                    updateList.add(obj);
                }
            }
            update updateList;
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}