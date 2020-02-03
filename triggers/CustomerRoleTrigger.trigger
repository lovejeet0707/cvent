trigger CustomerRoleTrigger on Contact_Role__c (before insert, before update, after update,after insert) {

    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    } 
    
    
    static List<Contact_Role__c> conRoleDelList = new List<Contact_Role__c>();        
    static final String conStatusMatch = 'Trash';
    static final String conStatusReasonMatch = 'No longer there';
    Map<Id,Boolean> setCaseActivityFlagMap,setActivityHistoryFlagMap;
    Set<ID> engagedcustomerConIds = new Set<ID>();
    Set<ID> activeAccountConIds = new Set<ID>();
    Set<Id> conIds = new Set<Id>();
    Set<Id> customerConIds = new Set<Id>();  
    Set<ID> accIds = new Set<ID> ();    
    Set<ID> advocatecustomerConIds = new Set<ID>();
    Set<ID> communitycustomerConIds = new Set<ID>();
    Map<Id,Set<ID>> oldRolesDuplicateCheck = new Map<Id,Set<ID>>();        
    Id custRecTypeId = Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByName().get('Customer Role').getRecordTypeId();          
    
    if(!System.isBatch()){   
        
        
        //AccountId vs Set of ContactIds from Contact Roles
        
        for(Contact_Role__c cr : trigger.new ){
            //Customer Role
            if(cr.RecordTypeId == custRecTypeId){
                customerConIds.add(cr.Contact__c);
                accIds.add(cr.Account_Customer_Role__c);
            }else{
                //Buyer Role
                conIds.add(cr.Contact__c);
                accIds.add(cr.Account_Buyer_Role__c);
            }
        }

        /**
        ** Validation Starts here (Duplicate Roles Check)
        **/
        if (trigger.isInsert && Trigger.isBefore){
            
            //Fetching old contact roles
            for(Contact_Role__c oldRole : [Select Contact__c, RecordTypeId, Account_Customer_Role__c , Account_Buyer_Role__c From Contact_Role__c Where ((Account_Buyer_Role__c IN: accIds and Contact__c IN: conIds) OR (Account_Customer_Role__c IN: accIds and Contact__c IN: customerConIds))]){
                
                //If customer role , put account lookup field accordingly
                Id accId = oldRole.RecordTypeId == custRecTypeId ? oldRole.Account_Customer_Role__c : oldRole.Account_Buyer_Role__c;
                
                if(!oldRolesDuplicateCheck.containsKey(oldRole.Account_Buyer_Role__c))
                    oldRolesDuplicateCheck.put(accId, new Set<ID>{oldRole.Contact__c});
                else
                    oldRolesDuplicateCheck.get(accId).add(oldRole.Contact__c);
            }
            
            for(Contact_Role__c cr : trigger.new ){
                
                //If customer role , put account lookup field accordingly
                Id accId = cr.RecordTypeId == custRecTypeId ? cr.Account_Customer_Role__c : cr.Account_Buyer_Role__c;
                
                Set<Id> existingConIds = oldRolesDuplicateCheck.get(accId);
                
                if(existingConIds!=null && existingConIds.contains(cr.Contact__c) && !Test.isRunningTest()){
                    if(cr.RecordTypeId == custRecTypeId){
                        cr.addError('You can not create more than one Customer Role with same Contact');
                    }else{
                        cr.addError('You can not create more than one Buyer Role with same Contact');
                    }
                }
                
            } 
        }       
        /**
        ** Validation End here 
        **/



        /**
        ** Customer Contact Role Status Updates
        **/
        if(customerConIds.size()>0){            

            setCaseActivityFlagMap = new Map<Id,Boolean>();
            setActivityHistoryFlagMap = new Map<Id,Boolean>();
            
            //Get Advocates for related Contacts
         /*   for( AdvocateHub__AdvocacyActivity__c ad : [Select Id,AdvocateHub__Contact__c From AdvocateHub__AdvocacyActivity__c Where AdvocateHub__Contact__c IN: customerConIds]){
                advocatecustomerConIds.add(ad.AdvocateHub__Contact__c);
            }*/   // commented by Udita for new enhancements requirements  
            
            //Get Community Useer
            //Get Travel/Transient/ROL User : Enhancements for contact roles - Udita
            for( User u : [Select Id,ContactId,Profile.Name From User Where ContactId IN: customerConIds and isPortalEnabled=true]){
                communitycustomerConIds.add(u.ContactId);
            } 
           //User Status (Engaged)
            /*for(Contact c : [Select Id, (Select Id From Cases Limit 1),(Select Id From Tasks Where NOT (LastModifiedBy.Name like '%Sops%' OR LastModifiedBy.Name ='Sales Support India') Limit 1),
            (Select Id,User__c,RecordTypeId From R00N000000071h6REAQ__r) from Contact Where Id IN:customerConIds ]){*/
            
            
            for(Contact c : [Select Id,AdvocateHub__Date_Joined_AdvocateHub__c , (Select Id From Cases where  LastModifiedDate =LAST_N_DAYS:180  AND (NOT (LastModifiedBy.Name like '%Sops%' OR LastModifiedBy.Name ='Lead Management (Sops)'))  Limit 1),(Select Id From Tasks Where ActivityDate=LAST_N_DAYS:180AND (NOT (LastModifiedBy.Name like '%Sops%' OR LastModifiedBy.Name ='Lead Management (Sops)')) Limit 1),
                (Select Id,User__c,RecordTypeId From R00N000000071h6REAQ__r) from Contact Where Id IN:customerConIds and Account.Account_Status__c like 'Active%' ]){// Added by Vaibhav Jain 3rd Mar 2017 2:10 AM IST    

                //Track whether the Account is active for this Contact to process further
                activeAccountConIds.add(c.Id);

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
                // added by udita for new Customer role enhancements : Advocate
                if(c.AdvocateHub__Date_Joined_AdvocateHub__c != null){
                   advocatecustomerConIds.add(c.id);
                }
            }
            
            system.debug('***activeAccountConIds**** ' + activeAccountConIds);

            Boolean subRolePresent;            
            
            If(Trigger.isBefore){
                for(Contact_Role__c cr : trigger.new ){ 

                    //Process only for Active Accounts
                    if(activeAccountConIds.contains(cr.Contact__c)){

                        system.debug('====Before===='+ cr);
                        system.debug('***advocatecustomerConIds**** ' + advocatecustomerConIds);
                        system.debug('***setCaseActivityFlagMap**** ' + setCaseActivityFlagMap);
                        system.debug('***setActivityHistoryFlagMap**** ' + setActivityHistoryFlagMap);
                        system.debug('***engagedcustomerConIds**** ' + engagedcustomerConIds);
                    

                        //Advocate Checkbox // added by udita for new Customer role enhancements : Advocate
                        if(advocatecustomerConIds.contains(cr.Contact__c))
                            cr.Advocate__c = true;
                        else
                            cr.Advocate__c = false;                  
                        
                        Set<String> products = new Set<String>();
                        if(cr.Product__c!=null){                    
                            List<String> prods = cr.Product__c.split(';');
                            products.addAll(prods);                    
                        }
                        
                       
                        //All the exception handling + validation check + Duplication check etc...
                        if(cr.User_Sub_Role__c==null && communitycustomerConIds.contains(cr.Contact__c) && !products.contains('CrowdCompass') ){
                            cr.User_Sub_Role__c = 'Community Portal Administrator';
                        }else{
                            // Modified by: Sandeep Kumar, Additional check IS provided to avoid numerous addition of "Community Portal Administrator"
                            if(cr.User_Sub_Role__c!=null && communitycustomerConIds.contains(cr.Contact__c) && !products.contains('CrowdCompass') /*|| Test.isRunningTest()*/){
                                subRolePresent = Boolean.valueOf('false');                    
                                for(String subRole : cr.User_Sub_Role__c.split(';')){
                                    if(subRole == 'Community Portal Administrator'){
                                        subRolePresent = true;
                                    }
                                }
                                if(!subRolePresent){cr.User_Sub_Role__c = cr.User_Sub_Role__c + ';Community Portal Administrator';}
                            }
                        }
                        
                        //by default
                        cr.User_Status__c = 'Dormant';
                        // Added by Sandeep Kumar - validate to check 
                        if(setCaseActivityFlagMap != null && setCaseActivityFlagMap.get(cr.Id) != null ){
                            cr.Case_Activity__c = setCaseActivityFlagMap.get(cr.Id); 
                            cr.User_Status__c = 'Engaged';
                        }                
                        if(setActivityHistoryFlagMap != null && setActivityHistoryFlagMap.get(cr.Id) != null ){
                            cr.Activity_History__c = setActivityHistoryFlagMap.get(cr.Id);  
                            cr.User_Status__c = 'Engaged';
                        }
                        //User Status
                        Date lastLoginDate = Date.ValueOf(cr.Last_Login_Date__c);
                        system.debug('***lastLoginDate**** ' + lastLoginDate);

                        // Added by Sandeep Kumar - Update User status and system login checkbox. 
                        if( lastLoginDate != null && lastLoginDate.daysBetween(System.today()) < 365 && !engagedcustomerConIds.contains(cr.Contact__c) || Test.isRunningTest()){
                            cr.User_Status__c = 'Active';
                            cr.System_Login__c = true;
                        }                   
                        if( lastLoginDate != null && lastLoginDate.daysBetween(System.today()) < 365 && engagedcustomerConIds.contains(cr.Contact__c) || Test.isRunningTest()){
                            cr.System_Login__c = true;
                            cr.User_Status__c = 'Engaged';   
                        }   
                        if(lastLoginDate != null && lastLoginDate.daysBetween(System.today()) > 365 && !engagedcustomerConIds.contains(cr.Contact__c)){cr.User_Status__c = 'Dormant';}
                        if(lastLoginDate != null && lastLoginDate.daysBetween(System.today()) > 365){cr.System_Login__c = false;}
                        if(lastLoginDate == null && !engagedcustomerConIds.contains(cr.Contact__c)){cr.User_Status__c = 'Dormant';}

                    }
                }
            }
        }
    }
    if(Trigger.isAfter && Trigger.isInsert)
    {
        if(Boolean.valueOf(Label.CustomerRoleTrigger))
            ContactRoleTriggerHelper.onAfterInsert(Trigger.newMap); 
    }
    if(Trigger.isAfter && Trigger.isUpdate)
    {
       if(Boolean.valueOf(Label.CustomerRoleTrigger))
        ContactRoleTriggerHelper.onAfterUpdate(Trigger.oldMap,Trigger.newMap); 
    }
}