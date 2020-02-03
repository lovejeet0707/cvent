/*
//////////////////////////////////////
//      @author Vaibhav Jain     //
/////////////////////////////////////
Version :   1.0
Date : 13th July 2015

21 Sept 2015            //create task for mobile app for apple oid

5th Oct 2015 //Call back functionality for CS

14th Oct 2015 //Contact Priority matrix - Last RM case modified dateapp

22 june 2016 : implementation  Case segration for hospitality survey
@Author Kd thakur

Version : 2.0
Added : 28/06/2016 : HSR : Added due to the Financial Project
Description : Approval process will only fire when - 
a) Requestor - Department =='Finance' && SuppliedEmail!='Pbhateja' && CreatedById!='Paras' && RecordType =='CRM Management'
b) (If CreatedBy =='SOPS' and InternalCRMFinanceApproval__c== True) OR (Not CreatedBy 'SOPS')

Test Class  : CaseTriggerHandlerTest (Coverage 83%)                
*/
public class caseTrgHelperCls{
    
    
    Public Static Boolean byPassFcc=false; 
    Public Static Boolean isRunOnce1=false;
    
    /*
     * Added By: Mohsin
     * Added On: 18th October 2018
     * Description: This method fill 'Purchased License For' field on Case object while creating or updating on the basis of 'Purchased License For' field on Account object.
     */
    public static void purchasedLicenseFill(List<Case> newValues)
    {
        Set<Id> accIds = new Set<Id>();
        for(Case instanceOfCase : newValues)
        {
            if(instanceOfCase.AccountId != NULL)
            {
                accIds.add(instanceOfCase.AccountId);
            }
        }
        if(Limits.getQueries() < 100 && accIds.size() > 0)
        {
            Map<Id, Account> accountEntries = new Map<Id, Account>([select Id,Purchased_License__c from Account where id in :accIds]);
            for (Case caseRec : newValues) 
            {
                if(accountEntries.containsKey(caseRec.AccountId))
                {
                    caseRec.Purchase__c = accountEntries.get(caseRec.AccountId).Purchased_License__c; 
                }
            }
        }
    }
    
    public void caseAssignmentAutomation(List<Case> newValues)
    {
        //Set<Case> finalCases = new Set<Case>();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Billing Cases').getRecordTypeId();
        Group gpId= [select Id from Group where Name = 'Cvent Inc Billing Queue' and Type = 'Queue']; //getting queue - Cvent Inc Billing Queue id to assign if there are multiple billling case for an account
        Map<String,List<Case>> mapOfCaseIdAndEmail = new Map<String,List<Case>>();
        for(Case cObj : newValues)
        {
            if(cObj.RecordTypeId == recordTypeId && String.isNotBlank(cObj.SuppliedEmail))
            {
                //finalCases.add(cObj);
                if(mapOfCaseIdAndEmail.containsKey(cObj.SuppliedEmail))
                {
                    List<Case> cases = mapOfCaseIdAndEmail.get(cObj.SuppliedEmail);
                    cases.add(cObj);
                }
                else
                {
                    List<Case> cases = new List<Case>();
                    cases.add(cObj);
                    mapOfCaseIdAndEmail.put(cObj.SuppliedEmail,cases);
                }
            }
        }
        //System.debug('mapOfCaseIdAndEmail>>>'+mapOfCaseIdAndEmail);
        Map<Id,List<Case>> accIdsAndCaseIds = new Map<Id,List<Case>>();
        Map<Id,Id> accIdsAndBillingCaseIds = new Map<Id,Id>();
        Set<String> checkUniqunesOfEmails = new Set<String>();
        if(mapOfCaseIdAndEmail.size() > 0 && !mapOfCaseIdAndEmail.isEmpty())
        {
            for(Contact con : [select id,AccountId,Account.Purchased_License__c,Account.Billing_Case__c,Email from Contact WHERE Email IN :mapOfCaseIdAndEmail.keySet() AND AccountId != NULL AND Account.Purchased_License__c != NULL])
            {
                //System.debug('Inside Contact : '+con.id);
                if(!con.Account.Purchased_License__c.containsIgnoreCase('RFP'))
                {
                    if(!checkUniqunesOfEmails.contains(con.Email))
                    {
                        //System.debug('Inside First Time: '+con.Email);
                        checkUniqunesOfEmails.add(con.Email);
                        accIdsAndCaseIds.put(con.AccountId,mapOfCaseIdAndEmail.get(con.Email));
                        accIdsAndBillingCaseIds.put(con.Account.Billing_Case__c,con.AccountId);
                    }
                    else
                    {
                        if(accIdsAndCaseIds.containsKey(con.AccountId))
                            accIdsAndCaseIds.remove(con.AccountId);
                        if(accIdsAndBillingCaseIds.containsKey(con.Account.Billing_Case__c)){
                            accIdsAndBillingCaseIds.remove(con.Account.Billing_Case__c);
                            //System.debug('Inside First Time Deleted: '+con.Email);
                        }
                    }
                }
            }
        }
        set<string> accManagerName = new set<string>();
        map<string,user> userMap = new map<string,user>();
        if(accIdsAndBillingCaseIds.size() > 0 && !accIdsAndBillingCaseIds.isEmpty())
        {
            List<BillingCase__c> billingCases = [select id,Billing_Account_Manager__c from BillingCase__c where Id IN :accIdsAndBillingCaseIds.keySet()];
            for(BillingCase__c bc : billingCases){
                if(bc.Billing_Account_Manager__c != null){
                    accManagerName.add(bc.Billing_Account_Manager__c);      
                }   
            }
            if(accManagerName.size() > 0 && !accManagerName.isEmpty()){
                for(user uObj :[select id,name,IsActive from user where name in:accManagerName and IsActive=true and Profile.Name like '%Collections%']){
                    userMap.put(uObj.name.toUpperCase(),uObj);        
                }  
            }
            for(BillingCase__c bc : billingCases){
                
                List<Case> cases = accIdsAndCaseIds.get(accIdsAndBillingCaseIds.get(bc.Id));
                for(Case cObj : cases){
                    cObj.Billing_Case__c = bc.Id;
                    
                    if(bc.Billing_Account_Manager__c!=null && userMap.containsKey(bc.Billing_Account_Manager__c.toUpperCase())){
                        cObj.OwnerId = userMap.get(bc.Billing_Account_Manager__c.toUpperCase()).Id;
                        cObj.Owner_Already_Created__c = true;
                    }
                    else{
                        cObj.OwnerId = gpId.Id;
                    }
                }
            }
        }
    }
    
    public void  OnBeforeInsert(List<Case> newValues){
        
         purchasedLicenseFill(newValues);   //Added By Mohsin
         if(Label.CaseAssignmentAutomation == 'TRUE')
         {
            caseAssignmentAutomation(newValues);  //Added By Mohsin
         }
         ///code starts for email auto logging : udita   
        set<string> caseSubjectAccount = new set<string>();
        set<string> accManagerName = new set<string>();
        list<user> userList = new list<user>();
        map<string,user> userMap = new map<string,user>();
        Group gpId;
        
        for(case cObj : newValues){
            if(cObj.subject!=null && cObj.subject.startsWithIgnoreCase('Your recent Invoice') && (cObj.SuppliedEmail == 'invoices@cvent.com' || cObj.SuppliedEmail =='euinvoices@cvent.com')){
                caseSubjectAccount.add(cObj.subject.substringAfter(': '));       
            }   
        }
        map<string,list<BillingCase__c>> billingcaseMap = new map<string,list<BillingCase__c>>();
        
        if(caseSubjectAccount.size()>0){
            for(BillingCase__c bc : [select id,CustomersAccount__r.name,Billing_Account_Manager__c from BillingCase__c where CustomersAccount__r.name in:caseSubjectAccount]){
                if(!billingcaseMap.containsKey(bc.CustomersAccount__r.name)){
                    billingcaseMap.put(bc.CustomersAccount__r.name,new list<BillingCase__c>());     
                }
                billingcaseMap.get(bc.CustomersAccount__r.name).add(bc);
                
                if(bc.Billing_Account_Manager__c != null){
                    accManagerName.add(bc.Billing_Account_Manager__c);      
                }   
            }
        }
        if(accManagerName.size()>0){
            for(user uObj :[select id,name,IsActive from user where name in:accManagerName and IsActive=true and Profile.Name like '%Collections%']){
                userMap.put(uObj.name.toUpperCase(),uObj);        
            }         
        }
       if(caseSubjectAccount.size() > 0){
        gpId= [select Id from Group where Name = 'Cvent Inc Billing Queue' and Type = 'Queue']; //getting queue - Cvent Inc Billing Queue id to assign if there are multiple billling case for an account
        system.debug('---gpId'+gpId);
        for(case c : newValues){
            string accountName = c.subject.substringAfter(': ');
            system.debug('----billingcaseMap.containsKey(accountName)'+billingcaseMap.containsKey(accountName));
            if(billingcaseMap.containsKey(accountName)){
                if(billingcaseMap.get(accountName).size()==1){
                    for(BillingCase__c bcObj : billingcaseMap.get(accountName)){
                      c.Billing_Case__c = bcObj.id;
                      c.Status ='Closed';
                      if(!string.isBlank(bcObj.Billing_Account_Manager__c) && userMap.containsKey(bcObj.Billing_Account_Manager__c.toUpperCase())){
                        user u = userMap.get(bcObj.Billing_Account_Manager__c.toUpperCase());
                        if(u!=null)
                        c.OwnerId = u.id;
                      }else{
                        c.OwnerId = Label.BillingCaseUserId;
                      } 
                    }                   
                }else{
                  system.debug('---else'); 
                  c.OwnerId = gpId.id; 
                }   
            } system.debug('---c.Status' + c.Status);  
        }
      }
 
        ///code ends for email auto logging : udita 

        /*Sanjana Code................*/
        Set<Id> accountIdSet =new Set<Id>();
        /*Ends Here....................*/
        
        
        for(Case caseObj:newValues){
            
            /*Udita Code added to fetch CC Email on behalf of product type................ P-003761 */
            Map<string,CC_Email_To_Product_Type__c> mapEmail = CC_Email_To_Product_Type__c.getAll();  
           IF(caseObj.Product_Type__c != null && mapEmail.containsKey(caseObj.Product_Type__c)){
               if((caseObj.Client_is_Onsite__c == 'Yes' || caseObj.Client_is_Onsite__c == 'No') && mapEmail.get(caseObj.Product_Type__c).Onsite_Email__c != null){
                caseObj.CC_Email_To__c = mapEmail.get(caseObj.Product_Type__c).Onsite_Email__c ;
                }else{
                caseObj.CC_Email_To__c = mapEmail.get(caseObj.Product_Type__c).CC_Email_To__c;
                }
            }
            /*Ends Here....................*/
            
            
            /*Sanjana Code................*/
            if(caseObj.AccountId!=null)
            {
                accountIdSet.add(caseObj.AccountId);
            }
            /*Ends Here....................*/
            
            /* Added : 28/06/2016 : HSR : Added due to the Financial Project*/
            if(caseObj.SuppliedEmail == 'pbhateja@cvent.com' && caseObj.createdById=='005000000079DxB' || Test.isRunningTest())
            {
                caseObj.Approval_Status__c='Approved';
                caseObj.Approver__c='005000000079DxB';
            }
            /*.......................Ends Here...........................*/
            
            /******** GDPR Code begins to validate an email and mark case status accordingly:Udita : 5/15/2018 *******/ 
            if(caseObj.Developer_Use_GDPR__c =='WebToCase-GDPR' && caseObj.Type!= null){
                caseObj.Subject = caseObj.Type ;
            }
            if(caseObj.Developer_Use_GDPR__c =='WebToCase-GDPR' && caseObj.SuppliedEmail!=NULL){
                caseObj.Status ='Open - Waiting Approval';
                caseObj.RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GDPR Request').getRecordTypeId();
            }
            /*else if(caseObj.Developer_Use_GDPR__c =='WebToCase-GDPR' && (caseObj.SuppliedEmail!=NULL && !Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}[.]{0,1}[a-zA-Z]{0,2}', caseObj.SuppliedEmail))){
                caseObj.Status ='Closed - Invalid email'; 
                caseObj.RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GDPR Request').getRecordTypeId();
            }   
            SYSTEM.DEBUG('----caseObj'+caseObj);          */
            /*.........................Ends Here....................................................*/  
            
            
        }  // End of Loop
        /*Sanjana Code................*/
        Map<Id,String> accIdVsUserId = returnAccountTeamMap(accountIdSet);
    
        for(Case caseObj:newValues){
            if(accIdVsUserId.containsKey(caseObj.AccountId)){     
               caseObj.SA_Rep__c = accIdVsUserId.get(caseObj.AccountId);
            }
        }
        /*Ends Here....................*/ 
        
        
        //Added on 2/12/2018- Populate Requester Due Date 
        PopulateRequesterDueDate(newValues);
    }  // End of Method
    
  
    //@future 
    public static void setOwnerforContractCases(List<Case> setCaseIds){
        System.debug('Testing Checkpoint');
        
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Contracts').getRecordTypeId();    // get the case obj recTypeId
       
    }
    public void OnAfterInsert(Map<Id,Case> newMapValues){
    
         updateClientProficiencyContact(newMapValues.values(),null);  // code for client proficiency on contact : Udita 5/21/2018
         
        //Client Proficieny
       // Set<Id> setIdOfContact = new Set<Id>(); commented by udita for new client proficiency code    
        
        
       /* for(Case instOfCase: newMapValues.values()){  
            /*3rd March 2017: Commented as said by Lovejeet*/
           
           /* System.debug('====>RecordTypeID'+instOfCase.CreatedById);
            if(instOfCase.Client_Proficiency_Level__c != null){
                if(instOfCase.ContactId != null){
                    if(string.valueOf(instOfCase.ContactId).startsWith('003')){
                        setIdOfContact.add(instOfCase.ContactId);
                    }
                }
            }
        } *///commented by udita for new client proficiency code  
        
        
        /*3rd March 2017: Commented as said by Lovejeet*/
        /*
        Map<Id,User> userIdVsUser=new Map<Id,User>([SELECT Id,Name,Email FROM User WHERE Id IN : userIdSet]);*/
       /* List<Contact> lstContactCPL = new List<Contact>();
        if(setIdOfContact.size()>0)
            lstContactCPL = [SELECT Id,Client_Proficiency_Level__c,(SELECT Id,Client_Proficiency_Level__c FROM Cases WHERE Client_Proficiency_Level__c!=null ORDER By CreatedDate ASC) FROM Contact WHERE Id =: setIdOfContact];
        
        List<Contact> lstContactUpd = new List<Contact>(); 
        for(Contact instCont : lstContactCPL){
            if(instCont.Cases.size()>0){
                instCont.Client_Proficiency_Level__c =  instCont.Cases[instCont.Cases.size()-1].Client_Proficiency_Level__c;
                lstContactUpd.add(instCont);
            }
        }
        if(lstContactUpd.size()>0)
            update lstContactUpd;*///commented by udita for new client proficiency code 
        //Client Proficieny
        
        //create task for mobile app for apple oid
        
        Id rtID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New CrowdCompass').getRecordTypeId();
        system.debug('rtID : '+rtID);
        Set<String> oidSet = new Set<String>();
        
        for(Case instOfCase: newMapValues.values()){ 
            
            if(instOfCase.RecordtypeID == rtID){
                if(instOfCase.Subject!=null){         
                    if(instOfCase.Subject.length()>0){
                        if(instOfCase.Subject.contains('Ready for Sale')){
                            system.debug('inside for loop : '+instOfCase.Description);
                            if(instOfCase.Description!=null){
                                if(instOfCase.Description.length()>0){
                                    Integer result = instOfCase.Description.indexOf('App SKU:');
                                    system.debug('result : '+result);
                                    if(result>-1){
                                        String temp = instOfCase.Description.substring(result+9,result+22);
                                        system.debug('temp : '+temp);    
                                        oidSet.add(temp);
                                    }
                                }}
                        }}    }
            }
        }
        
        
        System.debug('oidSet : '+oidSet);
        List<Task> insertTasks = new List<Task>();
        Id rttaskID = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CS CrowdCompass').getRecordTypeId();
        system.debug('rttaskID : '+rttaskID);
        if(oidSet.size()>0){
            for(Mobile_Card__c instofMobCard : [Select id,OwnerId from Mobile_Card__c where Apple_OID__c =: oidSet]){
                Task t = new Task();
                t.whatId = instofMobCard.id;
                t.recordtypeId = rttaskID;
                t.ownerId = instofMobCard.Ownerid;
                t.Subject = 'App is ready for use on iTunes - Set it Live on Google';
                t.ActivityDate = System.Today();
                t.Priority = 'Normal';
                insertTasks.add(t);
            }
        }    
        if(insertTasks.size()>0)
            insert insertTasks;
        //create task for mobile app for apple oid
        
        //Contact Priority matrix - Last RM case modified date
        Id casertID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Client Management (Global)').getRecordTypeId();
        system.debug('casertID : '+casertID);
        Set<String> conidSet = new Set<String>();
        for(Case instofCase : newMapValues.values()){
            if(instofCase.ContactID!=null && instofCase.recordtypeid==casertID)
                conidSet.add(instofCase.ContactID);
        }
        List<Contact> updateCon = new List<Contact>();
        for(Contact instofCon : [Select id, Last_RM_Cases_Activity__c, (Select id,LastModifiedDate from Cases where recordtypeid=:casertID) from Contact where id in: conidSet]){
            List<DateTime> listDT = new List<DateTime>();
            for(Case instofCs : instofCon.Cases){
                listDT.add(instofCs.LastModifiedDate);
            }
            if(listDT.size()>0){
                listDT.sort();
                instofCon.Last_RM_Cases_Activity__c =  listDT[listDT.size()-1];
                updateCon.add(instofCon);                   
            }
        }
        if(updateCon.size()>0)
            update updateCon; 
        
        //Contact Priority matrix - Last RM case modified date
        Id recTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('CRM Management').getRecordTypeId();           
        /* Added : 28/06/2016 : HSR : Added due to the Financial Project for sending the approval*/
        /*3rd March 2017: Commented as said by Lovejeet*/
        /*for(Case c : newMapValues.values()){
        if(c.Requestor_Department__c == 'Finance' && c.SuppliedEmail != 'pbhateja@cvent.com' && c.createdById!='005000000079DxB' && c.RecordTypeId == recTypeId ){
        if((c.InternalCRMFinanceApproval__c==true && (userIdVsUser.ContainsKey(c.createdById) && (userIdVsUser.get(c.createdById).Name.contains('Sops') || !userIdVsUser.containsKey(c.SuppliedEmail)))) || (userIdVsUser.ContainsKey(c.createdById) && !userIdVsUser.get(c.createdById).Name.contains('Sops'))){                        SendApprovalForCase(c.Id);}
        }
        }*/
        /*.........................Ends Here....................................................*/
        
        /******** GDPR Code begins to send an email once web case is created :Udita : 5/11/2018 *******/ 
        List<Messaging.SingleEmailMessage> emailMsgList_GDPR = new List<Messaging.SingleEmailMessage>();
        set<id> gdprCaseId = new set<id>(); 
        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        Id GDPRMarketingId,AppSupportId;
        Map<String, GDPR_Vendor__c> vendors = GDPR_Vendor__c.getAll(); // Fetching all the Marketing vendors from custom setting 
        List<GDPR_Case_Follow_Up__c> followUpList = new list<GDPR_Case_Follow_Up__c>();
        Map<String, GDPRVendorAppSupport__c> vendorsAppSupport = GDPRVendorAppSupport__c.getAll();
        if(Boolean.ValueOf(Label.GDPR)){
            /*******Enhancements : create GDPR Follow Ups for marketing/appsupport cases UDITA : 2/2022019******/
            GDPRMarketingId = [select Id from Group where Type = 'Queue' AND DeveloperNAME = 'GDPR_Marketing'].Id;
            AppSupportId = [select Id from Group where Type = 'Queue' AND DeveloperNAME = 'App_Support_General_Misc'].Id;
            
            /*****/
        }
        
        for(Case instanceOfCase :newMapValues.values()){
            if((instanceOfCase.SuppliedName !=NULL && (Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}[.]{0,1}[a-zA-Z]{0,2}', instanceOfCase.SuppliedEmail))) && instanceOfCase.Developer_Use_GDPR__c =='WebToCase-GDPR' && instanceOfCase.Origin == 'Web2Case'){
                Messaging.SingleEmailMessage msg =  new Messaging.SingleEmailMessage();
                msg.setToAddresses(new List<String>{instanceOfCase.SuppliedEmail});                    
                msg.setSubject('Please confirm your Cvent Privacy request');
                msg.setHtmlBody('<p>Thank you'+' for your recent Privacy request form submission.  To validate that you are the person who submitted this request, please click the link below. If you believe you have received this message in error, please contact us '+'<a href="https://www.cvent.com/en/contact/customer-support"> here</a>' + '.</p>'+
                                '<p><a href="https://cvent.force.com/GDPR/?caseId='+instanceOfCase.Id +'">Request Confirmation Link</a><br/>'+ '<span style="color:red;font-size:15px;"> For security purposes, the Privacy request form will be deleted if the link is not approved within 24 business hours. </span></p>'+     
                                'Thank you,<br/>'+
                                '<b>Cvent Customer Support  </b>');
                
                msg.setOrgWideEmailAddressId('0D2000000008OzJ');
                msg.setSaveAsActivity(false);
                emailMsgList_GDPR.add(msg);
            }
           if(Boolean.ValueOf(Label.GDPR)){ 
            /**** Enhancements : create GDPR Follow up for marketing cases : Udita****/ 
            if(instanceOfCase.OwnerId == GDPRMarketingId && instanceOfCase.ParentId != null){
             for(GDPR_Vendor__c gv : vendors.values()){
               GDPR_Case_Follow_Up__c  gdprVendor =  new GDPR_Case_Follow_Up__c();
               gdprVendor.vendor__c = gv.name;
               gdprVendor.Case__c = instanceOfCase.id;
               followUpList.add(gdprVendor);
             }   
           }
           if(instanceOfCase.OwnerId == AppSupportId && instanceOfCase.ParentId != null){
            for(GDPRVendorAppSupport__c app : vendorsAppSupport.values()){
              GDPR_Case_Follow_Up__c  gdprAppVendor =  new GDPR_Case_Follow_Up__c();
              gdprAppVendor.vendor__c = app.name;
              gdprAppVendor.Case__c = instanceOfCase.id;
              followUpList.add(gdprAppVendor);
            }   
          }
          }
          /******ends *****/
           
        }
        if(emailMsgList_GDPR.size()>0){
            Messaging.sendEmail(emailMsgList_GDPR);
        } 
        
        if(followUpList.size() > 0){
           insert followUpList;
        }   
                     
        /*.........................Ends Here....................................................*/  
    }
    
    public void OnBeforeUpdate(Map<Id,Case> oldMapValues,Map<Id,Case> newMapValues){ 
        purchasedLicenseFill(newMapValues.values());    //Added By Mohsin
        //GDPR code starts this overrides the fields of cases when its marked gdpr : Udita - 5/17/2018
        set<id> caseIdsWithStatusChange= new set<id>(); //added by udita for gdpr follow up
        set<id> caseIds = new set<id>(); // added by udita for awaiting case response 
        List<Messaging.SingleEmailMessage> emailMsgList = new List<Messaging.SingleEmailMessage>();
        Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();
        case caseOld;
        Id templateId;
        For(case caseObj : newMapValues.values())
        {   caseOld = oldMapValues.get(caseObj.Id);
         if(caseObj.Is_GDPR__c && caseOld.Is_GDPR__c != caseObj.Is_GDPR__c)
         {
             caseObj.SuppliedName = 'GDPR First Name';
             caseObj.SuppliedEmail = 'GDPR@GDPR.com';
             caseObj.SuppliedCompany = 'GDPR';
             caseObj.Type = '';
             //caseObj.Are_you_a_Cvent_Customer__c = null;
             //caseObj.Agrrement__c = null;  
             caseObj.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('GDPR').getRecordTypeId();                    
         }
         if(caseOld.Is_GDPR__c == true && caseObj.Is_GDPR__c == true){    // added by Udita : Validation to prevent GDPR Case Deletion
             caseObj.addError('You cannot update a GDPR processed case.');
         }
         if(caseObj.Is_GDPR__c && (caseOld.SuppliedName != caseObj.SuppliedName || caseOld.SuppliedEmail != caseObj.SuppliedEmail || caseOld.SuppliedCompany != caseObj.SuppliedCompany|| caseOld.Type != caseObj.Type))
         {
             caseObj.SuppliedName = 'GDPR First Name';
             caseObj.SuppliedEmail = 'GDPR@GDPR.com';
             caseObj.SuppliedCompany = 'GDPR';
             caseObj.Type = '';
             //caseObj.Are_you_a_Cvent_Customer__c = null;
             //caseObj.Agrrement__c = null;  
             caseObj.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('GDPR').getRecordTypeId();  
         }   
         //Added by Udita : GDPR Case Follow Up
         if(caseObj.status != caseOld.status && (caseObj.status=='Closed' || caseObj.status=='Closed- Pending from Cvent') && caseObj.RecordTypeID ==Schema.SObjectType.case.getRecordTypeInfosByName().get('GDPR Request').getRecordTypeId()){
            caseIdsWithStatusChange.add(caseObj.id);
         } 
         //Udita added for P-004952
         if(caseObj.Status == 'Awaiting Response' && caseObj.Status != caseOld.Status && rt_map.get(caseObj.recordTypeID).getName().contains('App Support')){
            caseIds.add(caseObj.id);       
         }
         system.debug('-----caseIds'+caseIds); 
               
        }
        //GDPR code ends: Udita
        
        /*Sanjana Code................*/
        Set<Id> accountIdSet =new Set<Id>();
        /*Ends Here....................*/
        /*  
Below code add by Kumud to , put validtions on parent case record []
25 April 2016
*/
        set<Id> setCaseIds=new Set<Id>();
        Map<Id,List<Case>> mapIDvsChildCase =new Map<Id,List<Case>>();
        Map<Id,List<Case>> mapIDvsOpenChildCase =new Map<Id,List<Case>>();
        set<String> setRecordTypeIDs=new Set<String>();
        set<String> setClosedStatus=new Set<String>{'Closed'};
            Map<String,Id> emailVsUserId=new Map<String,Id>();
        for(Case caseObj : newMapValues.values()){
            
            /*Udita Code added to fetch CC Email on behalf of product type................P-003761 */
            if((caseObj.Product_Type__c != oldMapValues.get(caseObj.Id).Product_Type__c && caseObj.Product_Type__c != null) || (caseObj.Client_is_Onsite__c != oldMapValues.get(caseObj.Id).Client_is_Onsite__c)){
                Map<string,CC_Email_To_Product_Type__c> mapEmail = CC_Email_To_Product_Type__c.getAll();                  
                IF(mapEmail.containsKey(caseObj.Product_Type__c)){
                  if((caseObj.Client_is_Onsite__c == 'Yes' || caseObj.Client_is_Onsite__c == 'No') && mapEmail.get(caseObj.Product_Type__c).Onsite_Email__c != null){
                    caseObj.CC_Email_To__c = mapEmail.get(caseObj.Product_Type__c).Onsite_Email__c;}
                  else{
                    caseObj.CC_Email_To__c = mapEmail.get(caseObj.Product_Type__c).CC_Email_To__c;                  
                  }              
                }            
            }
            /* Ends Here....................*/
            
            /*Sanjana Code................*/
            if(caseObj.AccountId!=null)
            {
                accountIdSet.add(caseObj.AccountId);
            }
            /*Ends Here....................*/
            setCaseIds.add(caseObj.id);
        }
        /*Sanjana Code................*/
        Map<Id,String> accIdVsUserId = returnAccountTeamMap(accountIdSet);
        /*Ends Here....................*/
        
        for(String str:Label.Case_RecordType_Ids.split(',')){
            setRecordTypeIDs.add(str.substring(0,15));
        }
        if(setCaseIds.size()>0  || caseIds.size()>0 ){  // or check added by udita for P-004952
            for(Case childCaseObj:[select id,CaseNumber,parentid,parent.OwnerId,Parent.Owner.Name,IsClosed,status from case where parentid in : setCaseIds or id in :caseIds]){
              if(setCaseIds.size() > 0 && setCaseIds.contains(childCaseObj.parentid)){ 
                if(mapIDvsChildCase.containsKey(childCaseObj.parentId)){                        mapIDvsChildCase.get(childCaseObj.parentid).add(childCaseObj);}
                else {
                    mapIDvsChildCase.put(childCaseObj.parentid, new List<Case>{childCaseObj});}
                
                if(mapIDvsOpenChildCase.containsKey(childCaseObj.parentId) && !childCaseObj.isClosed){                        mapIDvsOpenChildCase.get(childCaseObj.parentid).add(childCaseObj);}
                else if(!childCaseObj.isClosed){
                    mapIDvsOpenChildCase.put(childCaseObj.parentid, new List<Case>{childCaseObj});  }
               }
               
               else if(caseIds.size()> 0 && caseIds.contains(childCaseObj.id)){
                 if(Boolean.ValueOf(Label.AwaitingResponse_AppSupport) && childCaseObj.parentId != NULL && childCaseObj.parent.OwnerId != NULL && !(String.ValueOf(childCaseObj.parent.OwnerId)).StartsWith('00G')){
                    system.debug('-----caseIds'+caseIds);
                    Messaging.SingleEmailMessage msg1 =  new Messaging.SingleEmailMessage();  
                    msg1.setSubject('AppSupport Escalation Case :'+ childCaseObj.CaseNumber +'is - Awaiting Response');
                    //msg1.setTemplateId(Label.AwaitingResponseEmailTempplateId);
                    msg1.setToAddresses(new List<String>{childCaseObj.parent.OwnerId});  
                    msg1.setHtmlBody('<p>'+
                                        'Dear '+ childCaseObj.Parent.Owner.Name + ','+
                                        '<br></br>'+
                                        'The Appsupport case is waiting for your response. Please review and take action on your case.<br></br>'+
                                        'Case URL: <a href="https://cvent.my.salesforce.com/'+childCaseObj.Id+'">Case</a><br/>'+
                                        'Parent Case URL: <a href="https://cvent.my.salesforce.com/'+childCaseObj.ParentId+'">Parent Case</a><br/>'+
                                        'Note : Do not reply to this email, access the appsupport case in SF or reply on the original email conversation'+
                                        '<br></br>'+
                                        'Thanks,<br>'+
                                        'Support Ops'+
                                       '</p>');
                    msg1.setOrgWideEmailAddressId('0D2000000008OwZ');
                    msg1.setSaveAsActivity(false);
                    msg1.setTargetObjectId(childCaseObj.parent.OwnerId);
                  //  msg1.setWhatId(childCaseObj.parent.OwnerId);
                    emailMsgList.add(msg1);   }  
              }       
              
            }
        }
        
        if(emailMsgList.size()>0){
            Messaging.sendEmail(emailMsgList);
        } 
        
        // End here 
        for(Case instCase:newMapValues.values()){
            /*Sanjana Code................*/
            if(accIdVsUserId.containsKey(instCase.AccountId)){
                instCase.SA_Rep__c = accIdVsUserId.get(instCase.AccountId);
            }
            else
                instCase.SA_Rep__c = '';
            /*Ends Here....................*/
            
            // start here 
            /*if(mapIDvsChildCase.containsKey(c.id) && mapIDvsChildCase.get(c.id).size()>0 && oldMapValues.get(c.id).Future_Customer_Contact__c !=newMapValues.get(c.id).Future_Customer_Contact__c && c.Future_Customer_Contact__c==true){
c.addError('Future Customer contact cannot be check by you,if it has  associate child cases');
}*/
            system.debug('**************------------------mapIDvsOpenChildCase>'+mapIDvsOpenChildCase);
            /* if(instCase.ownerID!=UserInfo.getUserId() &&  oldMapValues.get(instCase.id).Future_Customer_Contact__c !=newMapValues.get(instCase.id).Future_Customer_Contact__c &&  newMapValues.get(instCase.id).Future_Customer_Contact__c==false  ){

instCase.addError('You are not allowed to unchecked Future customer contact.Only owner can do ');
}*/
            String recordTypID=(String)instCase.RecordTypeID;
            system.debug('==========>'+setRecordTypeIDs.contains(recordTypID.substring(0,15))+'***---->'+oldMapValues.get(instCase.id).status+'=====>'+instCase.isClosed+'*-----------'+mapIDvsOpenChildCase.containsKey(instCase.id));
            /*
the validation will not fire for Cvent Overage High Volume Customer Portal User profile users 
*/               
            if((setRecordTypeIDs.contains(recordTypID.substring(0,15)) && (oldMapValues.get(instCase.id).status!='Pending PUFF' || oldMapValues.get(instCase.id).status!='Information requested' || oldMapValues.get(instCase.id).status!='Pending Autoclosure' )  && instCase.status=='Closed' && mapIDvsOpenChildCase.containsKey(instCase.id) && mapIDvsOpenChildCase.get(instCase.id).size()>0) && instCase.I_still_want_to_close_the_case__c!=true && userInfo.getprofileId().substring(0,15)!='00eo00000016QNc'){                    String error=' The case you are trying to close has an OPEN (Child/Associated) case. If you still want to close it please checkmark '+'\''+' I still want to close the case'+'\'';                    instCase.addError(error);
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      }
            
            
        }
        
      /****** Code added for GDPR Case Folloe Up Validation ******* : UDITA ******/
      if(Boolean.ValueOf(Label.GDPR)){
      if(caseIdsWithStatusChange.size() > 0){
          Map<id,GDPR_Case_Follow_Up__c> gdprFollowMap = new Map<id,GDPR_Case_Follow_Up__c>();
          List<GDPR_Case_Follow_Up__c>  gdprFollowUpList =  new List<GDPR_Case_Follow_Up__c>();
          gdprFollowUpList = [select Case__c,Action__c,Email_Sent__c,Response_Received__c,Vendor__c from GDPR_Case_Follow_Up__c where Case__c IN :caseIdsWithStatusChange AND (Action__c = null AND Email_Sent__c = NULL AND Response_Received__c = NULL)];
          for(GDPR_Case_Follow_Up__c gdpr : gdprFollowUpList){
             gdprFollowMap.put(gdpr.Case__c,gdpr);
          }
        
        for(case caseObj : newMapValues.values()){
          if(caseObj.status != caseOld.status && (caseObj.status=='Closed' || caseObj.status=='Closed- Pending from Cvent') && caseObj.RecordTypeID ==Schema.SObjectType.case.getRecordTypeInfosByName().get('GDPR Request').getRecordTypeId()){
             if(!gdprFollowMap.IsEmpty() && gdprFollowMap.containsKey(caseObj.id)){
                caseObj.addError('Atlease 1 row of GDPR Follow Up should be completed');
             }
          }
        }
      }
      }
    }
    
    //Return User name from AccountTeamMember
    public Map<Id,String> returnAccountTeamMap(Set<Id> accountIdSet){
        Map<Id,String> teamMap = new Map<Id,String>();
        if(accountIdSet.size()>0){
            For(AccountTeamMember accTeam : [Select Id, AccountId,UserId,User.Name,TeamMemberRole From AccountTeamMember WHERE AccountId IN : accountIdSet AND TeamMemberRole ='Client Success Manager']){
                teamMap.put(accTeam.AccountId, accTeam.User.Name);
            }
        }
        return teamMap;
    }

    //Added By Mohsin
    public void RollUpHelper(Map<Id,Case> oldMapValues,Map<Id,Case> newMapValues)
    {
       Map<Id,Case> mapOfSelectedContactsVsCases = new Map<Id,Case>();
        Set<Id> recordTypeIds = new Set<Id>();
        recordTypeIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Event').getRecordTypeId());
        recordTypeIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Closed').getRecordTypeId());
        recordTypeIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Inquisium').getRecordTypeId());
        recordTypeIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('New eMarketing').getRecordTypeId());
        
        for(Case caseObj : newMapValues.values())
        {
            if(caseObj.Total_Time_Spent_Dedicated_Enterprise__c != oldMapValues.get(caseObj.Id).Total_Time_Spent_Dedicated_Enterprise__c && caseObj.Call_Category__c == 'Dedicated Enterprise Support' && recordTypeIds.contains(caseObj.RecordTypeId))
            {
                mapOfSelectedContactsVsCases.put(caseObj.contactId,caseObj);
            }
        }
        
        List<Contact> conToBeUpdated = new List<Contact>();
        if(!mapOfSelectedContactsVsCases.isEmpty()){
            for(Contact con : [select id,Dedicated_Ent_Support_Minutes_Used__c from Contact where id IN :mapOfSelectedContactsVsCases.keySet()])
            {
                con.Dedicated_Ent_Support_Minutes_Used__c = mapOfSelectedContactsVsCases.get(con.Id).Total_Time_Spent_Dedicated_Enterprise__c;
                conToBeUpdated.add(con);
            }    
        }
        if(!conToBeUpdated.isEmpty() && conToBeUpdated.size() > 0)
            update conToBeUpdated;
    }
    
    public void OnAfterUpdate(Map<Id,Case> oldMapValues,Map<Id,Case> newMapValues){
        
        if(CheckRecursive.runFiftyOne()){
        //Added By Mohsin
        RollUpHelper(oldMapValues,newMapValues);
        }
        if((CheckRecursive.runFortySeven() || Test.isRunningTest()) && Boolean.valueOf(Label.CrowdCompassCasesCreation))
            CrowdCompassCasesCreation(oldMapValues,newMapValues);   
        updateClientProficiencyContact( newMapValues.values(), oldMapValues);  // Code updating for Client proficiency field on contact:Udita
         
        /*********GDPR Class called to create its related record in GDPR Repository if its marked GDPR****/
        trg_GDPRContactTrg.insertGDPR_case(newMapValues,oldMapValues);
        /*** ENDS *****/ 
        
        System.debug('Insert After Update Checkpoint');
        //Client Proficieny
        set<id> caseParentId = new set<id>();
        Set<Id> setIdOfContact = new Set<Id>();
        List<Case> caseGDPRStatusChangeList = new List<Case>();
        /*3rd March 2017: Commented as said by Lovejeet*/
        /*
Set<Id> userIdSet=new Set<Id>();
Set<String> emailIdSet=new Set<String>();
String userQuery='SELECT Id,Name,Email FROM User WHERE ';
*/
        
        for(case caseObj: newMapValues.values()){
            case caseOld = oldMapValues.get(caseObj.id);
            if(caseObj.Developer_Use_GDPR__c == 'WebToCase-GDPR' && caseObj.Is_GDPR__c != caseOld.Is_GDPR__c && caseObj.Is_GDPR__c == true)
            {
                caseParentId.add(caseObj.Id);
            }
            if(caseObj.Origin == 'Web2Case' && caseObj.RecordTypeId  == Schema.SObjectType.Case.getRecordTypeInfosByName().get('GDPR Request').getRecordTypeId() && caseObj.Developer_Use_GDPR__c == 'WebToCase-GDPR'){
                if(caseObj.Status!=caseOld.Status && caseObj.Status == 'Open – Approved')
                {
                    caseGDPRStatusChangeList.add(caseObj);
                }
            }            
        }
        
        //HSR:create GDPR child cases when a parent case is inserted
        if(caseParentId.size()>0)
            updateChildCasesGDPR(caseParentId);
        if(caseGDPRStatusChangeList.size()>0)
            createGDPRChildCases(caseGDPRStatusChangeList);
        
        for(Case instOfCase: newMapValues.values()){ 
            /*3rd March 2017: Commented as said by Lovejeet*/
            /*
            emailIdSet.add(instOfCase.SuppliedEmail);
            userIdSet.add(instOfCase.createdById);
            */
           /* if(instOfCase.Client_Proficiency_Level__c != oldMapValues.get(instOfCase.Id).Client_Proficiency_Level__c){
                if(instOfCase.ContactId != null){
                    if(string.valueOf(instOfCase.ContactId).startsWith('003')){
                        setIdOfContact.add(instOfCase.ContactId);
                    }
                }
            }*/ //commented by udita for new client proficiency code
        }
        
        
        /*3rd March 2017: Commented as said by Lovejeet*/
        /*
        if(emailIdSet.size()>0)
        {
        userQuery=userQuery + ' Email IN :emailIdSet ' ;
        }
        else{                    userQuery=userQuery + ' Id IN : userIdSet';                }
        
        Map<Id,User> userIdVsUser=new Map<Id,User>();
        Map<String,User> userEmailVsUser=new Map<String,User>();
        For(User userObj : Database.query(userQuery))
        {
        userEmailVsUser.put(userObj.Email,userObj);
        userIdVsUser.put(userObj.Id,userObj);
        }
        System.debug('userIdVsUser=======>>>'+userIdVsUser);*/
        
      /*  List<Contact> lstContactCPL = new List<Contact>();
        if(setIdOfContact.size()>0)
            lstContactCPL = [SELECT Id,Client_Proficiency_Level__c,(SELECT Id,Client_Proficiency_Level__c FROM Cases WHERE Client_Proficiency_Level__c!=null ORDER By LastModifiedDate) FROM Contact WHERE Id =: setIdOfContact];
        
        List<Contact> lstContactUpd = new List<Contact>(); 
        for(Contact instCont : lstContactCPL){
            if(instCont.Cases.size()>0){
                instCont.Client_Proficiency_Level__c =  instCont.Cases[instCont.Cases.size()-1].Client_Proficiency_Level__c;
                lstContactUpd.add(instCont);
            }
        }
        if(lstContactUpd.size()>0)
            update lstContactUpd;*/   //commented by udita for new client proficiency code
        //Client Proficieny    
        
        //Contact Priority matrix - Last RM case modified date
        Id casertID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Client Management (Global)').getRecordTypeId();
        system.debug('casertID : '+casertID);
        Set<String> conidSet = new Set<String>();
        for(Case instofCase : newMapValues.values()){
            if(instofCase.ContactID!=null && instofCase.recordtypeid==casertID)
                conidSet.add(instofCase.ContactID);
        }
        List<Contact> updateCon = new List<Contact>();
        if(conidSet.size()>0){
        for(Contact instofCon : [Select id, Last_RM_Cases_Activity__c, (Select id,LastModifiedDate from Cases where recordtypeid=:casertID) from Contact where id in: conidSet]){
            List<DateTime> listDT = new List<DateTime>();
            for(Case instofCs : instofCon.Cases){
                listDT.add(instofCs.LastModifiedDate);
            }
            if(listDT.size()>0){
                listDT.sort();
                instofCon.Last_RM_Cases_Activity__c =  listDT[listDT.Size()-1];
                updateCon.add(instofCon);                   
            }
        }
        if(updateCon.size()>0)
            update updateCon; 
        }
        //Contact Priority matrix - Last RM case modified date
        //Approval For Finance 
        /*3rd March 2017: Commented as said by Lovejeet*/
       
        //Approval For Finance 
        /* Added : 28/06/2016 : HSR : Added due to the Financial Project for sending the approval*/
        //Approval For Finance 
        /*3rd March 2017: Commented as said by Lovejeet*/
       
        /*.........................Ends Here....................................................*/
        //Avoid recursion
        if(CheckRecursive.runFifteen()){
            SendAppSupportAlerts(newMapValues.values(),oldMapValues);
            /*** Added by Shanu Aggarwal on 3/01/2018 - Update Total Time Spent from Case to Mobile App P-003390**/
            
            //Off on 05/02/2018 - Asked by Sushil Kapoor
            //UpdateTotalTimeSpentOnMobileApp(newMapValues.values(),oldMapValues);
            
        }
        
    }
    public void OnBeforeDelete(List<Case> oldValues,Map<Id,Case> oldMapValues){    
       //Accessing "GDPR Case Delete Access" Custom Setting.....
        GDPR_Case_Delete_Access__c mc = GDPR_Case_Delete_Access__c.getInstance(UserInfo.getUserId());
        //HSR : Preventing GDPR cases from deleting and bypassing all the users from the "GDPR Case Delete Access" Custom Setting....
        For(Case caseObj : oldValues)  
        {
            if(caseObj.Origin == 'Web2Case' && caseObj.RecordTypeId  == Schema.SObjectType.Case.getRecordTypeInfosByName().get('GDPR Request').getRecordTypeId()
             && (caseObj.Developer_Use_GDPR__c == 'WebToCase-GDPR' || caseObj.Developer_Use_GDPR__c == 'WebToCase-GDPR-Child') && mc.Id == null)
            {
                caseObj.addError('You are not allowed to delete GDPR cases.');
            }
        }
    }
    public void OnAfterDelete(List<Case> oldValues,Map<Id,Case> oldMapValues){
    }
    public void OnUndelete(List<Case> newValues){
    }
    
    /**** code for client proficiency : Udita 5/21/2018******/
   public static void updateClientProficiencyContact( List<case> newList, Map<Id,case> oldMapValues){
           set<id> conIds = new set<id>();
           map<id,contact>  mapContact;
           integer caseLevel;
           integer conLevel;
           decimal finalLevel;
           decimal finalLevelValue;
           integer denominator;
           for(case caseObj: newList){
               if((oldMapValues==null &&  caseObj.Client_Proficiency_Level__c != null &&  caseObj.contactId !=null) || (oldMapValues != null &&  caseObj.Client_Proficiency_Level__c != null && caseObj.contactId !=null && caseObj.Client_Proficiency_Level__c != oldMapValues.get(caseObj.id).Client_Proficiency_Level__c)){
                  conIds.add(caseObj.contactId);  // fetching all the related contact id's
             }
           }
           system.debug('----conIds'+conIds);
           if(conIds.size() > 0){
             mapContact = new map<id,contact>([select id,Client_Proficiency_Level__c,Client_Proficiency_level_Dev__c from contact where id in : conIds]); // creating map of contact id's and its related Client-Proficiency
           }
           if(conIds.size() > 0){
              Map<string,ClientProficiencyLevelMapping__c> mapLevel = ClientProficiencyLevelMapping__c.getAll(); // Getting values from custom setting in map 
              map<integer,string> clientProfMap = new map <integer,string>();  // reverse map of level number and client-proficiency
              // populating the map
              list<ClientProficiencyLevelMapping__c> customSettingList = [select Level__c,name from ClientProficiencyLevelMapping__c];
              for(ClientProficiencyLevelMapping__c cus : customSettingList){
                clientProfMap.put(integer.valueOf(cus.Level__c),cus.name);
              }
              for(case c: newList){
                 contact con = mapContact.get(c.ContactId);
                if(c.Client_Proficiency_Level__c != null){
                     caseLevel = integer.valueOf(mapLevel.get(c.Client_Proficiency_Level__c).Level__c); // getting level number related to client proficiency of case
                 }else{
                     caseLevel = 0;
                 } 
                 if(con!=null && con.Client_Proficiency_Level__c != null){
                     con.Client_Proficiency_level_Dev__c = integer.valueOf(mapLevel.get(con.Client_Proficiency_Level__c).Level__c);  // getting level number related to client proficiency of contact
                 }
                 else{
                     con.Client_Proficiency_level_Dev__c = 0;
                 } 
                 system.debug('----conLevel'+con.Client_Proficiency_level_Dev__c+'---caseLevel'+caseLevel);
                 if(caseLevel != 0 && con.Client_Proficiency_level_Dev__c != 0){
                     finalLevel = (caseLevel + con.Client_Proficiency_level_Dev__c )/ 2;
                     
                 }
                 else if(con.Client_Proficiency_level_Dev__c == 0){
                    finalLevel = (caseLevel + con.Client_Proficiency_level_Dev__c )/ 1;                 
                 }    
                 system.debug('----finalLevel'+finalLevel);           
                 if(finalLevel !=null){   
                     finalLevelValue = Math.FLOOR(finalLevel);}
                 if(con != null && finalLevelValue !=null){
                     con.Client_Proficiency_Level__c = clientProfMap.get(integer.valueOf(finalLevelValue));  
                     con.Client_Proficiency_level_Dev__c = finalLevelValue;}          
              }
              if(mapContact.size() > 0){
                update mapContact.values();  // updating the related contact of case with updated client proficiency
              }
           }
       }  
       /***** code ends *****/
           
    /*** Added by Shanu Aggarwal on 2/12/2018
**** Send alerts to app support cases when Parent is closed 
****/
    public void SendAppSupportAlerts(List<Case> newValues,Map<Id,Case> oldMapValues){
        
        String recTypeName; 
        Set<ID> parentIds = new Set<ID>();
        List<Messaging.SingleEmailMessage> emailMsgList = new List<Messaging.SingleEmailMessage>();
        
        //get parent cases recordtype name starts with new
        for(Case c : newValues){
            recTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(c.RecordTypeId).getName();
            if(c.isClosed==true && oldMapValues.get(c.Id).isClosed==false && recTypeName.startsWith('New')){
                parentIds.add(c.Id);
            }
        }
        //get app support cases and sent email to owners
        if(parentIds.size()>0){
            
            for(Case appSupportCase : [Select Id,Status, ParentId,OwnerId,Parent.CaseNumber,CaseNumber,Owner.Email From Case Where ParentId IN: parentIds and RecordType.Name like 'App Support%' and IsClosed=false]){
                
                //Owner should be User only
                if(string.valueOf(appSupportCase.OwnerId).startsWith('005')){
                    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                    msg.setToAddresses(new List<String>{appSupportCase.Owner.Email});                    
                    msg.setSubject('Client Services Case ' + appSupportCase.Parent.CaseNumber + ' is now closed');
                    msg.setHtmlBody('<p>Hi,</p>'+
                                    
                                    '<p>Please action your case ' +  appSupportCase.CaseNumber + ' as the parent case was closed by CS.</p>'+
                                    '<p>Case link: https://cvent.my.salesforce.com/'+ appSupportCase.Id+'</p>'+
                                    '<p>Parent Case link: https://cvent.my.salesforce.com/'+appSupportCase.ParentId +'</p>'+
                                    
                                    'Regards,<br/>'+
                                    'SF Notifications');
                    
                    msg.setOrgWideEmailAddressId('0D2000000008OzJ');
                    msg.setSaveAsActivity(false);
                    emailMsgList.add(msg);
                }
            }
        }
        
        if(emailMsgList.size()>0)
            Messaging.sendEmail(emailMsgList);
    }
    /*** Added by Shanu Aggarwal on 3/01/2018
**** Update Total Time Spent from Case to Mobile App P-003390
****/
    /*public void UpdateTotalTimeSpentOnMobileApp(List<Case> newValues,Map<Id,Case> oldMapValues){
        
        List<Mobile_Card__c> updateCardsList = new List<Mobile_Card__c>();
        Set<ID> mobileAppIds = new Set<ID>();
        
        for(Case c : newValues){
            //If Total Spent on Case is Changed
            if(c.Mobile_App__c!=null && c.Total_Time_Spent__c != oldMapValues.get(c.Id).Total_Time_Spent__c){
                mobileAppIds.add(c.Mobile_App__c);
            }
        }
        
        //Group Total Time Spent on Mobile Card 
        if(mobileAppIds.size()>0){
            
            for(AggregateResult ar : [Select Mobile_App__c, SUM(Total_Time_Spent__c) total from Case Where Mobile_App__c IN:mobileAppIds Group BY Mobile_App__c]){
                
                Mobile_Card__c mc = new Mobile_Card__c(Id= (Id)ar.get('Mobile_App__c'), Mobile_App_Support_Case_Time__c=Integer.ValueOf(ar.get('total'))/Decimal.valueOf(60));
                
                updateCardsList.add(mc);
            }
            
        }
        if(updateCardsList.size()>0)
            update updateCardsList;
    }*/
    
    
    /*** Added by Shanu Aggarwal on 2/12/2018
**** New Hire SF Account automation P# P-003314
**** Parse Description from HR Tools Cases
**** Populate Requester Due date from Description text
****/
    public void PopulateRequesterDueDate(List <Case> newList){
        
        
        for(Case c : newList){
            
            if(c.Subject!=null && c.Subject.contains('[HRTools][## ISHLP') && c.Subject.contains('Salesforce Account Request') && c.Description.Contains('Please create Salesforce account for the following new hire by')){
                
                c.Requester_Due_Date__c = setStringToDateFormat(c.Description.substringBetween('Please create Salesforce account for the following new hire by ',' :'));
            }
        }
    }
    
    
    //Convert Date from String 
    private Date setStringToDateFormat(String myDate) {
        String[] myDateOnly = myDate.split(' ');
        String[] strDate = myDateOnly[0].split('/');
        Integer myIntDate = integer.valueOf(strDate[1]);
        Integer myIntMonth = integer.valueOf(strDate[0]);
        Integer myIntYear = integer.valueOf(strDate[2]);
        Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
        return d;
    }
    /*HSR: create GDPR child cases when a parent case is inserted*/
 public void createGDPRChildCases(List<Case> newMapValues){
        Case caseInsert = new Case();
        List<Case> caseInsertList = new List<Case>();
        Id appSpportId = [select Id from Group where Type = 'Queue' AND DeveloperNAME = 'App_Support_General_Misc'].Id;
        Id GDPRMarketingId = [select Id from Group where Type = 'Queue' AND DeveloperNAME = 'GDPR_Marketing'].Id;
        Id GDPRFinanceId = [select Id from Group where Type = 'Queue' AND DeveloperNAME = 'GDPR_Finance'].Id;
        For(Case caseObj : newMapValues){
            if(caseObj.Origin == 'Web2Case' && caseObj.RecordTypeId  == Schema.SObjectType.Case.getRecordTypeInfosByName().get('GDPR Request').getRecordTypeId() && caseObj.Developer_Use_GDPR__c == 'WebToCase-GDPR'){
                //..........App support escalation queue case insert............
                if(caseObj.Type == 'Do Not Call'){
                    
                    caseInsert = new Case();
                    caseInsert = caseObj.Clone(false,true,true,true);
                    caseInsert.OwnerId = GDPRMarketingId;//'00G00000006w2Qv';
                    caseInsert.Developer_Use_GDPR__c  = 'WebToCase-GDPR-Child';
                    caseInsert.ParentId = caseObj.Id;
                    caseInsertList.add(caseInsert);
                    
                    
                    //..........GDPR/Marketing queue case insert............
                    caseInsert = new Case();
                    caseInsert = caseObj.Clone(false,true,true,true);
                    caseInsert.OwnerId = GDPRFinanceId;//'00G1N000002QCK2';
                    caseInsert.Developer_Use_GDPR__c  = 'WebToCase-GDPR-Child';
                    caseInsert.ParentId = caseObj.Id;
                    caseInsertList.add(caseInsert);
                }
                else if (caseObj.Type == 'Do not sell'){ 
                    caseInsert = new Case();
                    caseInsert = caseObj.Clone(false,true,true,true);
                    caseInsert.OwnerId = GDPRMarketingId;//'00G00000006w2Qv';
                    caseInsert.Developer_Use_GDPR__c  = 'WebToCase-GDPR-Child';
                    caseInsert.ParentId = caseObj.Id;
                    caseInsertList.add(caseInsert);
                }
                
                else{
                    caseInsert = new Case();
                    caseInsert = caseObj.Clone(false,true,true,true);
                    caseInsert.OwnerId = GDPRMarketingId;//'00G00000006w2Qv';
                    caseInsert.Developer_Use_GDPR__c  = 'WebToCase-GDPR-Child';
                    caseInsert.ParentId = caseObj.Id;
                    caseInsertList.add(caseInsert);
                    
                    //..........GDPR/Finance escalation queue case insert............
                    caseInsert = new Case();
                    caseInsert = caseObj.Clone(false,true,true,true);
                    caseInsert.OwnerId = GDPRFinanceId;//00G1N000002QCJx';//
                    caseInsert.Developer_Use_GDPR__c  = 'WebToCase-GDPR-Child';
                    caseInsert.ParentId = caseObj.Id;
                    caseInsertList.add(caseInsert);
                    
                    caseInsert = new Case();
                    caseInsert = caseObj.Clone(false,true,true,true);
                    caseInsert.OwnerId = appSpportId;//00G1N000002QCJx';//
                    caseInsert.Developer_Use_GDPR__c  = 'WebToCase-GDPR-Child';
                    caseInsert.ParentId = caseObj.Id;
                    caseInsertList.add(caseInsert);
                }
            }
        }
        System.debug('caseInsertList********'+caseInsertList);
        if(caseInsertList.size()>0){
            insert caseInsertList;
        }       
    }
    //When a paren case will be marked as GDPR true then all the child cases will be marked as GDPR
    public void updateChildCasesGDPR(Set<Id> caseSetId){
        List<Case> updateCase = new List<Case>();
        For(Case caseObj : [SELECT Id,Is_GDPR__c FROM Case WHERE ParentId IN : caseSetId])
        {
            caseObj.Is_GDPR__c = true;
            updateCase.add(caseObj);
        }
        if(updateCase.size()>0)
            update updateCase;
    }
    
    public void CrowdCompassCasesCreation(Map<Id,Case> oldMap,Map<Id,Case> newMap)
    {
        Map<String,CrowdCompassCases__c> crowdCompassCustomSetting = CrowdCompassCases__c.getAll();
        List<Case> finalCases = new List<Case>();
        
        List<Case> listOfCasesAppAffinity = new List<Case>();
        List<Case> listOfCasesAppBuildPlus = new List<Case>();
        List<Case> listOfCasesMobileAppAffinity = new List<Case>();
        List<Case> listOfCasesMobileAppBuildPlus = new List<Case>();
        List<CrowdCompassCases__c> appAffinity = new List<CrowdCompassCases__c>();
        List<CrowdCompassCases__c> appBuildPlus = new List<CrowdCompassCases__c>();
        List<CrowdCompassCases__c> mobileAppAffinity = new List<CrowdCompassCases__c>();
        List<CrowdCompassCases__c> mobileAppBuildPlus = new List<CrowdCompassCases__c>();
        
        for(CrowdCompassCases__c cs : crowdCompassCustomSetting.values())
        {
            switch on cs.Type__c
            {
                when 'App:Affinity'
                {
                    appAffinity.add(cs);
                }
                when 'App Build Plus'
                {
                    appBuildPlus.add(cs);
                }
                when 'MobileApp:Affinity'
                {
                    mobileAppAffinity.add(cs);
                }
                when 'MobileApp Build Plus'
                {
                    mobileAppBuildPlus.add(cs);
                }
            }
        }
        
        for(Case newCase : newMap.Values())
        {
            System.debug('New Case>>'+newCase.status+'>>>>oldCase>>>>'+oldMap.get(newCase.Id).status);
            if((newCase.status != oldMap.get(newCase.Id).status && newCase.status == 'Closed'))
            {
                if(newCase.Subject == 'App Review Call: Affinity')
                    listOfCasesAppAffinity.add(newCase);
                if(newCase.Subject == 'App Review Call: App Build Plus')
                    listOfCasesAppBuildPlus.add(newCase);  
                if(newCase.Subject == 'Mobile App Setup Call: Affinity')
                    listOfCasesMobileAppAffinity.add(newCase);   
                if(newCase.Subject == 'Mobile App Setup Call: App Build Plus')
                    listOfCasesMobileAppBuildPlus.add(newCase);   
            }
        }
        
        if(!listOfCasesAppAffinity.isEmpty())
        {
            finalCases.addAll(createCases(listOfCasesAppAffinity,appAffinity));
        }
        if(!listOfCasesAppBuildPlus.isEmpty())
        {
            finalCases.addAll(createCases(listOfCasesAppBuildPlus,appBuildPlus));
        }
        if(!listOfCasesMobileAppAffinity.isEmpty())
        {
            finalCases.addAll(createCases(listOfCasesMobileAppAffinity,appAffinity));
        }
        if(!listOfCasesMobileAppBuildPlus.isEmpty())
        {
            finalCases.addAll(createCases(listOfCasesMobileAppBuildPlus,appBuildPlus));
        }
        
        if(!finalCases.isEmpty())
            insert finalCases;
    }
    
    public List<Case> createCases(List<Case> parentCases,List<CrowdCompassCases__c> customSetting)
    {
        List<Case> finalCases = new List<Case>();
        for(Case parentCase : parentCases)
        {
            for(CrowdCompassCases__c record : customSetting)
            {
                Case c = new Case();
                c.BusinessHoursId = record.Business_Hours_ID__c;
                c.Client_Proficiency_Level__c = record.Client_Proficiency_Level__c;
                c.Complexity__c = record.Complexity__c;
                c.Mobile_App__c = parentCase.Mobile_App__c;
                c.Mood__c = record.Mood__c;
                c.Origin = record.Case_Origin__c;
                c.OwnerId = parentCase.OwnerId;
                c.ParentId = parentCase.Id;
                c.Product_Type__c = record.Product_Type__c;
                c.RecordTypeId = record.Record_Type_ID__c;
                c.Status = record.Status__c;
                c.Subject = record.Subject__c;
                finalCases.add(c);
            }
        }
        
        return finalCases;
    }
    
}