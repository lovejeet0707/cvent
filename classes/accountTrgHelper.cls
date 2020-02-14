/**
///////////////////////////////
//    @author Rohit Saxena    //
///////////////////////////////
Test Class in salesResourcesTrgHelperClsTest
Version 1.0
Date: 10th July 2015
Description: Update/Insert 2 fields at Sales Resource Object with the same value Account has for same fields.
Version 2.0
Date: 16th July 2015
Description: Update Billing Country
*/
public class accountTrgHelper{
    //Update Billing Country
    public static List<ISOSetting__c> lstOFISO = new List<ISOSetting__c>();
    public static map<String,String> mapISO = new map<String,String>();
    static{
        lstOFISO = ISOSetting__c.getall().values();
        for(ISOSetting__c instOf : lstOFISO){
            mapISO.put(instOf.Country_Name__c.trim(),instOf.ISO__c.trim());
        }
    }
    //Update Billing Country
    public void OnBeforeInsert(List<Account> newValues){    
        
         //GDPR : Udita 
        //HSR: Validate before creating if the account Email is not under GDPR request.....
        Set<String> emailSetToValidate = new Set<String>();
        Set<String> GDPREmailSet = new Set<String>();
        //Ends here.............
                                
                //trigger.new for loop (before insert)
                For(Account instOFAccount : newValues){
                 if(instOFAccount.isPersonAccount == true){
                    if(String.IsNotBlank(instOFAccount.PersonEmail))
                        emailSetToValidate.add(instOFAccount.PersonEmail);
                    if(String.IsNotBlank(instOFAccount.Alternate_Email__pc))
                        emailSetToValidate.add(instOFAccount.Alternate_Email__pc);
                  }
                }  
                if(emailSetToValidate.size() > 0){              
                   GDPREmailSet = trg_GDPRContactTrg.returnGDPREmail(emailSetToValidate,'Person Account');
                }                //...................................................                        
                                
        For(Account accObj : newValues)
        {
            //HSR: Validate before creating if the contact Email is not under GDPR request.....
            if(GDPREmailSet.size()>0 && ((String.IsNotBlank(accObj.PersonEmail) && GDPREmailSet.contains(accObj.PersonEmail)) || (String.IsNotBlank(accObj.Alternate_Email__pc) && GDPREmailSet.contains(accObj.Alternate_Email__pc))))
            {
                accObj.addError('You cannot update Email on this account as its email is GDPR processed.');
            }
            //Ends here.............
            
            //TICS-451----------
            if(Boolean.ValueOf(Label.IsBillingValidationActive)==True && String.IsBlank(accObj.Creation_Source_System_External_ID__c) && UserInfo.getUserId()!='0051N000004XBmaQAG'
                        && UserInfo.getUserId()!=Label.OpprtunityDeleteUserID){
                System.debug('accObjj**********'+accObj);
                System.debug('accObjjBC**********'+accObj.BillingCountryCode);
                System.debug('accObjjBCState**********'+accObj.BillingStateCode);
                if(accObj.BillingCountryCode==null){
                    accObj.addError('Billing Country is required.');
                }
                else if(accObj.BillingCountryCode!=null && (accObj.BillingCountryCode== 'US'
                                                            || accObj.BillingCountryCode== 'USA' 
                                                            || accObj.BillingCountryCode== 'CA' 
                                                            || accObj.BillingCountryCode== 'AU')){
                    if(accObj.BillingStateCode== null){
                        accObj.addError('Billing State is required.');
                    }                                           
                }
            }
            //Ends Here---------
            
        }
        //GDPR CODE ENDS: Udita  
        
        /* HSR : 25th May : removal of TAB character from som fields*/
        removeTABCharacter(newValues);
        /* -------------------Ends Here-----------------------------*/
        //Update Billing Country   
        for(Account instOFAcc : newValues){
            /*  if(String.IsNotBlank(instOFAcc.Website))
                instOFAcc.Domain__c = instOFAcc.Website.substringAfter('.').removeEnd('/'); */
            //To update ISO value with respecitve country.
            system.debug('SFDC Account info: ' + instOFAcc);
            system.debug('SFDC Billing Country: ' + instOFAcc.BillingCountryCode);
            system.debug(mapISO.containsKey(instOFAcc.BillingCountryCode));
            system.debug(mapISO);
            if(instOFAcc.BillingCountryCode!= null){        
                if(mapISO.containsKey(instOFAcc.BillingCountryCode.trim()))
                instOFAcc.Iso_Tract__c = mapISO.get(instOFAcc.BillingCountryCode.trim());
            }
            //To update ISO value with respecitve country.  
        }
        //Update Billing Country
        if(CheckRecursive.runTwentySix() && Label.PhoneNumberValidator =='True')
        PhoneNumberValidator_Clone.updateAccountPhoneNumber(newValues,new Map<Id,Account>());
    }
    public void OnAfterInsert(Map<Id,Account> newMapValues)
    { 
        if(Boolean.ValueOf(Label.IsDoceboCodeActive))
      updateLMSOnDoceboUser(newMapValues,null);
      //For #P-005059 - Added By Mohsin
      if(Boolean.valueOf(Label.Update_Source_Rep))
        updateSourceRep(null,newMapValues);
    }
    public void OnBeforeUpdate(Map<Id,Account> oldMapValues,Map<Id,Account> newMapValues){ 
        
         //GDPR code starts: Udita
        Account AccountOld;
        For(Account accObj : newMapValues.values())
        {   AccountOld = oldMapValues.get(accObj.Id);
            if(accObj.Is_GDPR__pc && AccountOld.Is_GDPR__pc != accObj.Is_GDPR__pc)
            {
                            accObj.FirstName = 'GDPR First Name';
                            accObj.LastName = 'GDPR Last Name';
                            accObj.PersonEmail = 'GDPR@GDPR.com';
                            accObj.Phone = '';
                            accObj.PersonMobilePhone= '';
                            accObj.Alternate_Email__pc = 'GDPR@GDPR.com';
                            accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GDPR').getRecordTypeId();

            }
            if(!accObj.Is_GDPR__pc && AccountOld.Is_GDPR__pc != accObj.Is_GDPR__pc)
            {
                //accObj.RecordTypeId = null;
            }
             if(accObj.Is_GDPR__pc && (AccountOld.FirstName != accObj.FirstName || AccountOld.LastName != accObj.LastName || AccountOld.PersonEmail != accObj.PersonEmail || AccountOld.Phone != accObj.Phone || AccountOld.PersonMobilePhone != accObj.PersonMobilePhone|| AccountOld.Alternate_Email__pc != accObj.Alternate_Email__pc))
            {
                            accObj.FirstName = 'GDPR First Name';
                            accObj.LastName = 'GDPR Last Name';
                            accObj.PersonEmail = 'GDPR@GDPR.com';
                            accObj.Phone = '';
                            accObj.PersonMobilePhone= '';
                            accObj.Alternate_Email__pc = 'GDPR@GDPR.com';
                            accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GDPR').getRecordTypeId();

            }
            
            
            
        }
       //GDPR code ends: Udita
       
        /* HSR : 25th May : removal of TAB character from som fields*/
        removeTABCharacter(newMapValues.values());
        Account oldAccount;
        /* -------------------Ends Here-----------------------------*/
        //Update Billing Country
        for(Account instOFAcc : newMapValues.values()){
            //oldAccount =oldMapValues.get(instOFAcc.id); 
             //&& oldAccount.Website != instOFAcc.Website
           /* if(String.IsNotBlank(instOFAcc.Website))
                instOFAcc.Domain__c = instOFAcc.Website.substringAfter('.').removeEnd('/'); */
            //To update ISO value with respecitve country.
            system.debug('SFDC Billing Country: ' + instOFAcc.BillingCountryCode);
            //if(instOFAcc.BillingCountryCode != oldMapValues.get(instOFAcc.Id).BillingCountryCode && instOFAcc.BillingCountryCode !=null){
            system.debug('SFDC Billing Country: ' + instOFAcc.BillingCountryCode);
            if(mapISO.containsKey(instOFAcc.BillingCountryCode))
                instOFAcc.Iso_Tract__c = mapISO.get(instOFAcc.BillingCountryCode);
            //}
            //To update ISO value with respecitve country.  
        }
        //Update Billing Country
        //Added by Shanu
        //Send post to chatter group "All Cvent" for HODI Approval or Rejection
        //We are using button click for HODI approval, need only 1st record
        Account firstAcc = newMapValues.values()[0];
        Account oldFirstAcc = oldMapValues.values()[0];
        if( firstAcc.IsHODI_Dev__c && (firstAcc.IsHODI_Dev__c != oldFirstAcc.IsHODI_Dev__c)){
            Map<Id,User> useridVsUser_Map=new Map<Id,User>([SELECT Id,Name FROM User WHERE Id = : firstAcc.HODI_Approver_Dev__c]);
            System.debug('useridVsUser_Map======>'+useridVsUser_Map);
            String body='<b>Hi,</b><p>Your HODI request has been approved:</p><p><ul> <li><b>Account:</b>'+  firstAcc.Acc_Name_Dev__c+'</li>  <li><b>Desired Tier:</b>'+ firstAcc.Service_Tier__c+'</li> <li><b>Approver:</b>'+  useridVsUser_Map.get(firstAcc.HODI_Approver_Dev__c).Name+'</li>    <li><b>Request Date:</b>'+  firstAcc.HODI_Request_Date_Dev__c.format()+'</li></ul></p> <p>Changes reflect in the system immediately.</p><b><p>Thanks,</p></b><b>'+useridVsUser_Map.get(firstAcc.HODI_Approver_Dev__c).Name+'</b>';
            
            AccountHODIPage_Controller.AddGroupPost(firstAcc.Id,body);
        }
        
        
        
        /*else if( firstAcc.IsRejected_Dev__c  && (firstAcc.IsRejected_Dev__c != oldFirstAcc.IsRejected_Dev__c) ){
            String body='<b>Hi,</b><p>Your HODI request has been rejected:</p><p><ul>    <li><b>Account:</b>'+  firstAcc.Acc_Name_Dev__c+'</li>  <li><b>Desired Tier:</b>'+ firstAcc.Service_Tier__c+'</li> <li><b>Approver:</b>'+  useridVsUser_Map.get(firstAcc.HODI_Approver_Dev__c).Name+'</li>    <li><b>Request Date:</b>'+  firstAcc.HODI_Request_Date_Dev__c.format()+'</li>  <li><b>Comments:</b>'+  firstAcc.Comments__c+'</li> </ul></p> <p>You may not appeal,re-open or edit this HODI request. If you wish to discuss this with the approver, please contact them directly. </p><p>Note: Any additional consideration does require submitting a new HODI request for this account. </p><b><p>Thanks,</p></b><b>'+useridVsUser_Map.get(firstAcc.HODI_Approver_Dev__c).Name+'</b>';        
            AccountHODIPage_Controller.AddGroupPost(firstAcc.Id,body);
        }
        */
        if(CheckRecursive.runThirtyTwo() && Label.PhoneNumberValidator == 'True')
        PhoneNumberValidator_Clone.updateAccountPhoneNumber(newMapValues.values(),oldMapValues);
        
    }
    public void OnAfterUpdate(Map<Id,Account> oldMapValues,Map<Id,Account> newMapValues){ 
         //GDPR Class  : udita || inserts its related record in GDPR Rep if account is gdpr
          trg_GDPRContactTrg.insertGDPR_Account(newMapValues,oldMapValues);
           //For #P-005059 - Added By Mohsin
        if(Boolean.valueOf(Label.Update_Source_Rep))
            updateSourceRep(oldMapValues,newMapValues);
        //RecordType instRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Sales_Engineering' And SobjectType = 'Sales_Resources__c' And IsActive = true];
        Set<Id> setAccId = new Set<Id>();
        //P-004391
        Set<Id> accIdSet = new Set<Id>();
        /*HSR: Continuation: Assigning CSC Automation - CrowdCompass*/
        CSC_Automation__c cscObject = new CSC_Automation__c();
        List<CSC_Automation__c> cscObjectList = new List<CSC_Automation__c>();
        for(Account instAcc : newMapValues.values()){
            Account oldAcc = oldMapValues.get(instAcc.Id);
            /*HSR: Continuation: Assigning CSC Automation - CrowdCompass*/
            if(Boolean.ValueOf(Label.CSCAutomation_Account) && instAcc.Service_Tier__c != oldAcc.Service_Tier__c && (instAcc.Service_Tier__c=='Silver' && oldAcc.Service_Tier__c=='Bronze') && instAcc.Account_Assignment_Value__c>7500){
                cscObject = new CSC_Automation__c();
                cscObject.Account_Id__c = instAcc.Id;
                cscObject.Account__c = instAcc.Id;
                cscObjectList.add(cscObject);
            }
            //P-004391
            if(instAcc.Service_Tier__c != oldAcc.Service_Tier__c|| instAcc.Active_ARA__c!= oldAcc.Active_ARA__c)
            {
                accIdSet.add(instAcc.Id);
            }
            if(instAcc.API_connected_with__c != oldMapValues.get(instAcc.Id).API_connected_with__c || instAcc.Back_Office_System__c != oldMapValues.get(instAcc.Id).Back_Office_System__c){
            setAccId.add(instAcc.Id);
            }
        }
        if(Boolean.ValueOf(Label.IsDoceboCodeActive))
        updateLMSOnDoceboUser(newMapValues,oldMapValues);
        /*HSR: Continuation: Assigning CSC Automation - CrowdCompass*/
        if(cscObjectList.size()>0)
            insert cscObjectList;
        //P-004391
        //if(accIdSet.size()>0 && Label.IsUpdateProjectRiskCategoryClassActive == 'True')
            //UpdateProjectRiskCategoryClass.UpdateProjectRiskCategoryValue(accIdSet);
        List<Account> lstAccount = new List<Account>();
        if(setAccId.size()>0){
            RecordType instRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Sales_Engineering' And SobjectType = 'Sales_Resources__c' And IsActive = true];
            lstAccount = [SELECT Id,API_connected_with__c,Back_Office_System__c,(SELECT Id,Back_Office_System_New__c,API_connected_with__c,RecordTypeId FROM Sales_RFP__r WHERE RecordTypeId=:instRecType.Id)FROM Account WHERE Id=: setAccId];
        }
        List<Sales_Resources__c> lstSalRes = new List<Sales_Resources__c>();
        for(Account instOfAcc:lstAccount ){
            for(Sales_Resources__c instOfSalRes :instOfAcc.Sales_RFP__r){
                if(instOfAcc.Back_Office_System__c != null && instOfAcc.Back_Office_System__c!= '')
                    instOfSalRes.Back_Office_System_New__c = instOfAcc.Back_Office_System__c;
                else
                    instOfSalRes.Back_Office_System_New__c = '';
                if(instOfAcc.API_connected_with__c != null && instOfAcc.API_connected_with__c != '')
                    instOfSalRes.API_connected_with__c = instOfAcc.API_connected_with__c;
                else
                    instOfSalRes.API_connected_with__c = '';
                lstSalRes.add(instOfSalRes);
            }
        }
        if(lstSalRes.size()>0){
            update lstSalRes;
        }
    }
    public void OnBeforeDelete(List<Account> oldValues,Map<Id,Account> oldMapValues){
        PreventAccountDeletion(oldValues);
        //Uncheck Primary Sync on Slave Addresses when two Accounts are merged
        UnchecekPrimarySyncAddress(oldValues);
        //HSR : 16Feb2018: Stop Account Merge if Slave Account has value in either "EBS Account ID"/"EBS Account Number"/"Creation Source System External ID".............
        String errorROLMessage = 'You can'+'\'t merge an ROL Account.';
        String errorEBSMessage = 'You can'+'\'t merge an Account with EBS Id.';
        /******Preventing PayGo account from deletion.****/
        Set<String> authorizedUserSet = new Set<String>();
        //Accessing custom setting.....................
        For(AccountPayGo_Records_Delete_Prevention__c PG : AccountPayGo_Records_Delete_Prevention__c.getall().values()){
            authorizedUserSet.add(PG.Name);
        }
        if((authorizedUserSet.size()>0 && !authorizedUserSet.contains(UserInfo.getUserId())) || authorizedUserSet.size()==0)
        {
            For(Account accTrgHelper : [SELECT Id,(SELECT Id FROM Login_Accounts__r) FROM Account WHERE ID IN : Trigger.old])
            {
                if(accTrgHelper.Login_Accounts__r.size()>0)
                {
                    Account actualRecord = oldMapValues.get(accTrgHelper.Id); 
                    actualRecord.addError('PayGo Account can not be deleted or merged');
                }
            } 
        }
         /************Ends Here***********/
        Boolean MethodIsActive = ExecuteMethodHelper.isActive('PreventSTDeletion');
        For(Account accObj : oldValues)
        {
            // Added by Dishank Jain on Sunny's request 10537022
            //if(String.IsNotBlank(accObj.QM_Migrated_Account_ID__c))
                //accObj.addError('QM Account Cannot be deleted');  :   TICCM-422 : Udita
            /*else*/ if(AccountValidationByPass__c.getInstance(UserInfo.getUserId()).Name==null && (String.IsNotBlank(accObj.EBS_Account_ID__c) || String.IsNotBlank(accObj.EBS_Account_Number__c)))
                accObj.addError(errorEBSMessage);
            else if(String.IsNotBlank(accObj.Creation_Source_System_External_ID__c))
                accObj.addError(errorROLMessage);

        //Removed field for JIRA Ticket # TICCM-1294    -- Modified by Nishant Goswami   
         /* if(accObj.ST_Migrated_ID__c != null && MethodIsActive == True){
            accObj.addError('ST Migrated Account Cannot be Deleted');
         }   */
        }
        //............ENDS HERE.............................
         
    }
    public void OnAfterDelete(List<Account> oldValues,Map<Id,Account> oldMapValues){  
        //HSR : 16Feb2018: Stop Account Merge if the Master Account has value in "Creation Source System External ID" field.............  
        Set<Id> masterAccountIdSet = new Set<Id>();
        String errorMessage = 'You can'+'\'t merge an ROL Account.';
        For(Account accObj : oldValues)
        {
            if(accObj.MasterRecordId!=null)
                masterAccountIdSet.add(accObj.MasterRecordId);
        }
        if(masterAccountIdSet.size()>0){
            For(Account masterAcc : [SELECT Id,Creation_Source_System_External_ID__c FROM Account WHERE Id IN : masterAccountIdSet])
            {
                if(String.IsNotBlank(masterAcc.Creation_Source_System_External_ID__c))
                    masterAcc.addError(errorMessage);
            }
        }
        //............ENDS HERE.............................
    }
    
    public void OnUndelete(List<Account> newValues){
    }



    /** Uncheck Primary Sync on Slave Addresses when two Accounts are merged
    **  Added on - 1/31/2018
    **/
    public void UnchecekPrimarySyncAddress(List<Account> oldAccList){
        
      
        // Part of merge operation get the deleted account ids
        Set<Id> accIds = new Set<Id>();
        List<Address__c> adrList = new List<Address__c>();

       
        for(Address__c adr : [Select Id,Primary_Sync__c From Address__c Where Account__c IN: oldAccList and Primary_Sync__c=true]){
            adr.Primary_Sync__c=false;
            adrList.add(adr);
        }
        
        if(adrList.size()>0){
            update adrList;
        }

    }
    
    public static void updateSourceRep(Map<Id,Account> oldMapValues,Map<Id,Account> newMapValues)
    {
        Map<Id,Account> mapOfSelectedAccounts = new Map<Id,Account>();
        Map<Id,Account> mapOfAccountsToBeRemoved = new Map<Id,Account>();
        Map<String,Id> mapOfUserNameVsAccountIds = new Map<String,Id>();
        List<AccountTeamMember> atmToBeDeleted = new List<AccountTeamMember>();
        List<AccountTeamMember> atmToBeInserted = new List<AccountTeamMember>();
        Map<Id,Id> mapOfAccountIdVsUserId = new Map<Id,Id>();
        Set<Id> accountIdSet = new Set<Id>();
        for(Account acc : newMapValues.values())
        {
            if(oldMapValues == null || oldMapValues.get(acc.Id).PA_Rep__c != acc.PA_Rep__c)
            {
                if(acc.PA_Rep__c != NULL)
                {
                    mapOfSelectedAccounts.put(acc.Id,acc);
                    mapOfUserNameVsAccountIds.put(acc.PA_Rep__c,acc.Id);
                }
                else
                {
                    mapOfAccountsToBeRemoved.put(acc.Id,acc);
                }
                accountIdSet.add(acc.Id);
            }
        }

        if(!mapOfUserNameVsAccountIds.isEmpty())
        {
            for(User u : [select Id,Name from User where isActive=TRUE AND IsPortalEnabled=FALSE AND Name IN :mapOfUserNameVsAccountIds.keySet()])
            {
                mapOfAccountIdVsUserId.put(mapOfUserNameVsAccountIds.get(u.Name),u.Id);        
            }
        }
        List<AccountTeamMember> listOfAccountTeamMembers = new List<AccountTeamMember>();
        if(accountIdSet.size()>0)
            listOfAccountTeamMembers = [select Id,TeamMemberRole,AccountId from AccountTeamMember where TeamMemberRole ='Sourcing Consultants' AND AccountId IN :accountIdSet];
        if(listOfAccountTeamMembers.size() > 0)
        {
            for(AccountTeamMember atm : listOfAccountTeamMembers)
            {
                    atmToBeDeleted.add(atm);
                    //mapOfSelectedAccounts.remove(atm.AccountId);
            }
        }
        
        if(!atmToBeDeleted.isEmpty())
        {
            delete atmToBeDeleted;
        }

        for(Account acc : mapOfSelectedAccounts.values())
        {
            if(mapOfAccountIdVsUserId.containsKey(acc.Id))
            {
                AccountTeamMember atm = new AccountTeamMember();
                atm.AccountId = acc.Id;
                atm.UserId = mapOfAccountIdVsUserId.get(acc.Id);
                atm.TeamMemberRole = 'Sourcing Consultants';
                atmToBeInserted.add(atm);
            }
        }
        
        if(!atmToBeInserted.isEmpty())
        {
            insert atmToBeInserted;
        }
    }
    
    /* HSR : 25th May : removal of TAB character from som fields*/
    private void removeTABCharacter(List<Account> accountList)
    {
        For(Account instOFAcc : accountList)
        {
            if(instOFAcc.CVII_ID__c!=null){
                System.debug('Before Removal====>'+instOFAcc.CVII_ID__c.length());
                instOFAcc.CVII_ID__c=instOFAcc.CVII_ID__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal====>'+instOFAcc.CVII_ID__c.length());
            }
            if(instOFAcc.Federal_Tax_ID_VAT_Number__c!=null){
               System.debug('Before Removal====>'+instOFAcc.Federal_Tax_ID_VAT_Number__c.length());
                instOFAcc.Federal_Tax_ID_VAT_Number__c=instOFAcc.Federal_Tax_ID_VAT_Number__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal====>'+instOFAcc.Federal_Tax_ID_VAT_Number__c.length());
            }
            if(instOFAcc.Region__c!=null){
                System.debug('Before Removal====>'+instOFAcc.Region__c.length());
                instOFAcc.Region__c=instOFAcc.Region__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal====>'+instOFAcc.Region__c.length());
            }
            if(instOFAcc.AM_CrowdCompass__c!=null){
                System.debug('Before Removal====>'+instOFAcc.AM_CrowdCompass__c.length());
                instOFAcc.AM_CrowdCompass__c=instOFAcc.AM_CrowdCompass__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal====>'+instOFAcc.AM_CrowdCompass__c.length());
            }
            /* Commented By Mohsin on 21st June 2019 - FP Activity
            if(instOFAcc.AM_CrowdTorch__c!=null){
                System.debug('Before Removal====>'+instOFAcc.AM_CrowdTorch__c.length());
                instOFAcc.AM_CrowdTorch__c=instOFAcc.AM_CrowdTorch__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal====>'+instOFAcc.AM_CrowdTorch__c.length());
            }*/
            if(instOFAcc.AM_CSN__c!=null){
                System.debug('Before Removal====>'+instOFAcc.AM_CSN__c.length());
                instOFAcc.AM_CSN__c=instOFAcc.AM_CSN__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal====>'+instOFAcc.AM_CSN__c.length());
            }
            /* Commented By Mohsin on 21st June 2019 - FP Activity
            if(instOFAcc.AM_CT_TM__c!=null){
                System.debug('Before Removal====>'+instOFAcc.AM_CT_TM__c.length());
                instOFAcc.AM_CT_TM__c=instOFAcc.AM_CT_TM__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal====>'+instOFAcc.AM_CT_TM__c.length());
            }*/
            if(instOFAcc.AM_Event__c!=null){
                System.debug('Before Removal====>'+instOFAcc.AM_Event__c.length());
                instOFAcc.AM_Event__c=instOFAcc.AM_Event__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal====>'+instOFAcc.AM_Event__c.length());
            }
            if(instOFAcc.AM_PA__c!=null){
                System.debug('Before Removal====>'+instOFAcc.AM_PA__c.length());
                instOFAcc.AM_PA__c=instOFAcc.AM_PA__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal====>'+instOFAcc.AM_PA__c.length());
            }
            if(instOFAcc.AM_Survey__c!=null){
                System.debug('Before Removal====>'+instOFAcc.AM_Survey__c.length());
                instOFAcc.AM_Survey__c=instOFAcc.AM_Survey__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal====>'+instOFAcc.AM_Survey__c.length());
            }
            if(instOFAcc.CS_Rep__c!=null){
                System.debug('Before Removal====>'+instOFAcc.CS_Rep__c.length());
                instOFAcc.CS_Rep__c=instOFAcc.CS_Rep__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal====>'+instOFAcc.CS_Rep__c.length());
            }
        }
    }
    // adding By KUMUD 
    public void PreventAccountDeletion(List<Account> listOFOldAccount){
        
        map<String,String> mapIdId = new map<String,String>();
        //List<Account> lstOfAcc =  new List<Account>();
        Set<ID> setAccstatusId=new Set<Id>();
        final String profileId = UserInfo.getProfileId();
        String profileName;
    
        List<ClientAccountDelete__c> lstCAD = ClientAccountDelete__c.getall().values();
        for(ClientAccountDelete__c instOfCAD : lstCAD){
            mapIdId.put(instOfCAD.UserId__c,instOfCAD.UserId__c);
        }
        for(Account instOfAcc : listOFOldAccount){
            //Prevent deletion of Accounts having "Lanyon Migrated Id" in it.
            /*if(String.IsNotBlank(instOfAcc.Lanyon_Migrated_ID__c))
            {
                instOfAcc.addError('Error: Lanyon Migrated Account cannot be DELETED/MERGED.');
            }*/
            //adding by KUMUD
            if(String.IsNotBlank(instOfAcc.Account_Status__c)){
                setAccstatusId.add(instOfAcc.id); 
                //system.debug('lstOfAcc+++'+lstOfAcc);
            }
        }
        if(!setAccstatusId.isEmpty()){
            profileName =  [SELECT id,Name FROM Profile where id =: ProfileId ].name;
            //accountTrgHelper.Accts(Trigger.New);
            for (Account Accts : listOFOldAccount){
                //for(Account instOfAcc : lstOfAcc )
                    if(setAccstatusId.contains(Accts.id)){
                        if(AccountValidationByPass__c.getInstance(UserInfo.getUserId()).Name==null &&  profileName!='System Administrator' && !mapIdId.containsKey(String.valueOf(UserInfo.getUserId()))){
                            Accts.addError('Error: You cannot Delete/Merge a Client Account , Please contact Contract\'/s Team/Paras Bhateja for assistance.');
                        }
                    }
                //}s
            }
        
        }// end of if 
    
    }// end of method
    
     //Method to update LMS Group on User for Docebo : Udita : 4/10/2019
    public void updateLMSOnDoceboUser(Map<ID,Account> newAccMap,Map<ID,Account> oldAccMap){
      system.debug('----method called');
      Map<Id,String> accIdMap = new Map<Id,String>();      
      for(Account acc :newAccMap.values()){
         if((acc.Product_Mix__c != NULL && oldAccMap== NULL) || (oldAccMap!= NULL && /*acc.Product_Mix__c != NULL &&*/ acc.Product_Mix__c != oldAccMap.get(acc.id).Product_Mix__c )){
            accIdMap.put(acc.id,acc.Product_Mix__c);
         }
      }
        system.debug('---accIdMap'+accIdMap);
       set<string> lmsGrp = new set<string>();
       List<Contact> userList = new List<Contact>();
       if(accIdMap!= null)
       for(Contact u : [Select Id,LMS_Groups__c,AccountId from Contact where AccountId IN :accIdMap.keyset() AND User_Profile_Name__c = 'Cvent Customer Community User']){
          system.debug('---accIdMap.containsKey(u.AccountId)'+ accIdMap.containsKey(u.AccountId));
          if(accIdMap.containsKey(u.AccountId)){
             String s = accIdMap.get(u.AccountId);
             if(u.LMS_Groups__c != null){
               u.LMS_Groups__c= u.LMS_Groups__c + ';' + s;
               system.debug('----u.LMS_Groups__c'+u.LMS_Groups__c);
               system.debug('----u.LMS_Groups__c.split'+u.LMS_Groups__c.split(';'));
               for(string str : u.LMS_Groups__c.split(';')){
                 system.debug('-----str'+str);
                 lmsGrp.add(str);
               }
               
               system.debug('----lmsGrp'+lmsGrp);
               String joinedString = String.join(new list<String>(lmsGrp), ';');
               system.debug('----joinedString'+joinedString);
               u.LMS_Groups__c = joinedString;
             }else{
                u.LMS_Groups__c = s;
             }
             u.LMS_Sync_Contact__c = True;
             //u.LMS_Groups__c =u.LMS_Groups__c != null ? u.LMS_Groups__c + ';' + s : s;
             userList.add(u);
           }

       }
       if(userList.size() >0){
         update userList;
       }
    } 
}