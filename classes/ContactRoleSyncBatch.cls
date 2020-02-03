// ===============================
// AUTHOR           : Shanu Aggarwal    
// CREATED DATE     : 12 Jan 2017
// PURPOSE          : Customer Contact Role Synchronization
// TEST CLASS       :  CustomerRoleTriggerTest
// SPECIAL NOTES    :
// ===============================



global class ContactRoleSyncBatch implements Database.Batchable<sObject>,Schedulable {
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Id customerRecTypeId = Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByName().get('Customer Role').getRecordTypeId();
        string query = 'Select Id,Contact__c,Product__c,Advocate__c,User_Sub_Role__c,User_Status__c,Billing__c,Last_Login_Date__c From Contact_Role__c where Last_Login_Date__c!=NULL ' +
                       'And RecordTypeId =: customerRecTypeId ';
        
        return Database.getQueryLocator(query);

        
    }
        
    global void execute(Database.BatchableContext BC, List<Contact_Role__c> scope) {
        
        List<Contact_Role__c> conRoleUpdateList = new List<Contact_Role__c>();
        
        Set<ID> conIds = new Set<ID>();
        Set<ID> advocatecustomerConIds = new Set<ID>();
        Set<ID> communitycustomerConIds = new Set<ID>();
        Set<ID> engagedcustomerConIds = new Set<ID>();
        Set<ID> billPocConIds = new Set<ID>();
        Map<Id,Boolean> setCaseActivityFlagMap,setActivityHistoryFlagMap;
        
        for(Contact_Role__c  con : scope ){
          conIds.add(con.Contact__c);
        }
          
        if(conIds.size()>0){
            
            setCaseActivityFlagMap = new Map<Id,Boolean>();
            setActivityHistoryFlagMap = new Map<Id,Boolean>();
            //User Status (Engaged) & Advocate Hub & Billing POC
            for( Contact c : [Select Id, (Select Id From Cases Limit 1),
                                (Select Id From Tasks Where NOT (LastModifiedBy.Name like '%Sops%' 
                                 OR LastModifiedBy.Name ='Lead Management (Sops)') Limit 1),
                                (Select Id,AdvocateHub__Contact__c From AdvocateHub__AdvocacyActivities__r Limit 1),
                                (Select Id,User__c,RecordTypeId From R00N000000071h6REAQ__r),
                                (Select Id From Invoicing_Details__r Limit 1)                           
                                From Contact Where Id IN:conIds]){
                
                if(c.Cases.size()>0 || c.Tasks.size()>0){
                        engagedcustomerConIds.add(c.Id);
                        // Added by Sandeep Kumar
                         for(Contact_Role__c conRole : c.R00N000000071h6REAQ__r){                                          
                             if(c.Cases !=null && c.Cases.size() > 0){
                                 setCaseActivityFlagMap.put(conRole.Id,true);
                             }else{
                                 setCaseActivityFlagMap.put(conRole.Id,false);
                             }
                             if(c.Tasks != null && c.Tasks.size() > 0){
                                 setActivityHistoryFlagMap.put(conRole.Id,true);
                             }else{
                                 setActivityHistoryFlagMap.put(conRole.Id,false);
                             }
                        }                                                                      
                }
                                 
                if(c.AdvocateHub__AdvocacyActivities__r.size()>0)
                    advocatecustomerConIds.add(c.Id);
                
                if(c.Invoicing_Details__r.size()>0)
                    billPocConIds.add(c.Id);
                
            }
            
            //Get Community Useer
            for( User u : [Select Id,ContactId From User Where ContactId IN: conIds and isPortalEnabled=true]){
                communitycustomerConIds.add(u.ContactId);
            }
            
            Boolean subRolePresent; 
            
            for(Contact_Role__c cr : scope ){
                subRolePresent=false;
                //Advocate Checkbox
                /*if(advocatecustomerConIds.contains(cr.Contact__c))
                    cr.Advocate__c = true;
                else
                    cr.Advocate__c = false;*/ //  commented by udita for contact roles
                
                //Mark Billing POC 
                if(billPocConIds.contains(cr.Contact__c))
                    cr.Billing__c = true;
                else
                    cr.Billing__c = false;
                
                //Community User
                Set<String> products = new Set<String>();
                if(cr.Product__c!=null){
                    
                    List<String> prods = cr.Product__c.split(';');
                    products.addAll(prods);
                    
                }               
                  
                //All the exception handling + validation check + Duplication check etc...
                if(cr.User_Sub_Role__c==null && communitycustomerConIds.contains(cr.Contact__c) && !products.contains('CrowdCompass')){
                    cr.User_Sub_Role__c = 'Community Portal Administrator';
                }else{
                    // Modified by: Sandeep Kumar, Additional check IS provided to avoid numerous addition of "Community Portal Administrator"
                    if(communitycustomerConIds.contains(cr.Contact__c) && !products.contains('CrowdCompass') || Test.isRunningTest()){
                        subRolePresent = Boolean.valueOf('false');                    
                        for(String subRole : cr.User_Sub_Role__c.split(';')){
                            if(subRole == 'Community Portal Administrator'){
                                subRolePresent = true;
                            }
                        }
                        if(!subRolePresent){
                            cr.User_Sub_Role__c = cr.User_Sub_Role__c + ';Community Portal Administrator';
                        }
                    }
                }
                //by default
                cr.User_Status__c = 'Dormant';
                // Added by Sandeep Kumar - validate to check 
                if(setCaseActivityFlagMap != null && setCaseActivityFlagMap.get(cr.Id) != null){
                    cr.Case_Activity__c = setCaseActivityFlagMap.get(cr.Id); 
                    cr.User_Status__c = 'Engaged';
                }                
                if(setActivityHistoryFlagMap != null && setActivityHistoryFlagMap.get(cr.Id) != null){
                    cr.Activity_History__c = setActivityHistoryFlagMap.get(cr.Id);  
                    cr.User_Status__c = 'Engaged';
                }
                
                //User Status
                Date lastLoginDate = Date.ValueOf(cr.Last_Login_Date__c);
                
                // Added by Sandeep Kumar - Update User status and system login checkbox. 
                if( lastLoginDate != null && lastLoginDate.daysBetween(System.today()) < 365 && !engagedcustomerConIds.contains(cr.Contact__c)){
                    cr.User_Status__c = 'Active';
                    cr.System_Login__c = true;
                }                   
                if( lastLoginDate != null && lastLoginDate.daysBetween(System.today()) < 365 && engagedcustomerConIds.contains(cr.Contact__c)){
                    cr.System_Login__c = true;
                    cr.User_Status__c = 'Engaged';   
                }   
                if(lastLoginDate != null && lastLoginDate.daysBetween(System.today()) > 365 && !engagedcustomerConIds.contains(cr.Contact__c)){cr.User_Status__c = 'Dormant';}
                if(lastLoginDate != null && lastLoginDate.daysBetween(System.today()) > 365){cr.System_Login__c = false;}
                if(lastLoginDate == null && !engagedcustomerConIds.contains(cr.Contact__c)){cr.User_Status__c = 'Dormant';}
                
                        
                
                conRoleUpdateList.add(cr);
                
            }
            
            if(conRoleUpdateList.size()>0)
                Database.Update(conRoleUpdateList);
        }
    
    }
    
    global void execute(SchedulableContext sc)
    {
        
        // We now call the batch class to be scheduled
        ContactRoleSyncBatch b = new ContactRoleSyncBatch();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,2000);
    }
    
    
    global void finish(Database.BatchableContext BC) {
        
    }
        

}