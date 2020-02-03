public without sharing class QuotaAllocation_SingleUser_ViewExtension{

// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 15/02/2016
// PURPOSE     :  To View Quotas for Single User
// TEST CLASS: QuotaAllocation_SingleUser_Ext_Test
// SPECIAL NOTES:
// ===============================
// Change History:
//
//==================================

    public string teamMembers {get;set;}
    public User user {get;set;}
    public Integer currentYear {get;set;}
    public boolean showEditSection {get;set;}
    public boolean showViewSection {get;set;}
    public boolean showEditBtn {get;set;}
    public boolean showSaveBtn {get;set;}
    public boolean quotaExistForUser {get;set;}
    public boolean isCurrentuser {get;set;}

    
    //Wrapper of User information 
    public UserWrapper uWrapper {get;set;}
    
    //If user is authorized to access the page 
    public boolean isAuthorizedUser{get;set;}
    
    //Quota User History Current Record for Update
    public Quota_User_History__c qHistoryCurrentRec{get;set;}
    
    //Quota User History List
    public List<Quota_User_History__c> qHistoriesRecordsList {get;set;} 
    
    //Monthly Sum of Quota Amount
    List<Decimal> quotaMonthlySum ;
    //Map Containing Monthly Total for each Quota (Where Key = Year & Value = List of Monthly Amount for Each Quota based on Year)
    Map<Integer,AggregateResult> mapQuotaMonthlyTotal ;
    
    //Map Containing Quoata Allocation Records (Where Key = Year & Value = List of Quota Allocations)
    private Map<Integer, List<QuotaWrapper>> mapQuotaAllocations ;
    
    
    private Id currentUserId ;
    public Id quotaUserId {get;set;}
    
    public QuotaAllocation_SingleUser_ViewExtension(ApexPages.StandardController controller) {

        showEditSection = false;
        showViewSection = true;
        showEditBtn = true;
        showSaveBtn = false;
        isAuthorizedUser = false;
        quotaExistForUser = false;
        isCurrentuser = false;
        
        string roleName = '';
        string product = '';
        
        quotaUserId =  ApexPages.CurrentPage().GetParameters().Get('uid');
        
        currentYear = Date.Today().Year();
        
        //If User is logged in user or View by manager by selecting one specific user
        If( quotaUserId!= null ){
          currentUserId  = quotaUserId;
        } 
        else{
           showEditBtn = false;
           currentUserId = UserInfo.getUserId();
           isCurrentuser = true;
        }
        
        user = [Select Id, Name,FirstName, LastName, UserRole.Name, Team__c,Sales_Rep_Tier__c,Manager.Name,EmployeeNumber,CreatedDate,CreatedBy.Name,LastModifiedBy.Name,LastModifiedDate  From User Where Id =: currentUserId Limit 1];
        
      
        if(user.UserRole.Name!=null){
            roleName = user.UserRole.Name.substringBeforeLast('(');
            product = user.UserRole.Name.substringAfterLast('(').RemoveEnd(')');
        }
        
        
        //Initializing User Results
        uWrapper = new UserWrapper(user,roleName,product);
        
             
        InitializeUserHistory();
        initializeQuotaData();
    }
    
    
    
    Boolean allowedToView {get;set;}
     // Method to restrict the page or functionality if User is not authorized.
    public PageReference CheckPermission(){
        
        allowedToView = false;
        //Check for Cookie if the user is authorized to view Quota for defined user 
        Cookie cookie = ApexPages.currentPage().getCookies().get('allowedToView');
        
        If(cookie!=null)
            allowedToView = cookie.getValue()=='Yes'?true:false;
        //else
        //    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'Session is expired. Please click on Quota Management tab'));
            
        
        showEditBtn = false;
        
        Set<ID> managedUsersId = new Set<ID>();
        
        //Current User Information
        User currentUser = [ Select UserRoleId, ProfileId, UserRole.Name , Profile.Name 
                              , (Select Id From Managedusers) From User Where Id=:UserInfo.getUserId() ];
                               //15 Character Id
        String currentUserId = String.valueOf(UserInfo.getUserId().substring(0, 15));
        
        for(User mUser : currentUser.ManagedUsers){
            managedUsersId.add(mUser.Id);
        }
        
        /***** We were using all custom setting data without using SOQL query 
                But it imapcts performance where all data should not needed 
                
                Since July 2016 Moved to next piece of code (Using SOQL for required data )

        *********************************************************************
        //Map of Custom Setting  contains Key = Profile-Role and Value = related Permission (Read/Write)/Read Only
        Map<String, String> mapQuotaSecuritySetting = new Map<String, String>();
        
        //Setting Map based on Profile-Role
        for( Quota_Management_Securtity_Setting__c qSecurity : Quota_Management_Securtity_Setting__c.getAll().Values() ){           
             mapQuotaSecuritySetting.put( qSecurity.Profile_Name__c + '-' + qSecurity.Role__c, qSecurity.Permission__c );
        }
       
         System.debug('**** mapQuotaSecuritySetting ' + mapQuotaSecuritySetting);
        */
        
        
        //Setting Flag whether user should access this page
        if( currentUser.UserRoleId != null && currentUser.ProfileId !=null ){
            
            String permission;
            Set<String> exceptionalUserIds = new Set<String>{};
             
            //Getting Custom Setting Details for Quota Security     
            Quota_Management_Securtity_Setting__c [] qSecuritySetting = [ Select Id,Exceptional_Users__c,Permission__c From Quota_Management_Securtity_Setting__c
                                                where Role__c =: currentUser.UserRole.Name and Profile_Name__c=: currentUser.Profile.Name Limit 1];
                                                
            //If there is any matching data for current user in custom setting 
            if( qSecuritySetting!=null && qSecuritySetting.size()>0){
                
                permission = qSecuritySetting[0].Permission__c ;
                //Collecting Excpetional User Id's for Read/Write access
                 if(qSecuritySetting[0].Exceptional_Users__c!=null){
                    
                     exceptionalUserIds.addAll(qSecuritySetting[0].Exceptional_Users__c.split(','));
                 }
            }
             
            System.debug('**** permission  ' + permission );
            System.debug('**** exceptionalUserIds  ' + exceptionalUserIds );
            
            
            //If User Seeing his own Quota
            if( quotaUserId==null && permission !=null ){
                isAuthorizedUser = true;
            }
            else if ( ( quotaUserId!=null && ( managedUsersId.contains(quotaUserId) || allowedToView) ) 
                && ( permission !=null && ( permission == 'Read/Write' || exceptionalUserIds.Contains(currentUserId)) )){
                 isAuthorizedUser = true;
                 showEditBtn = true; 
            }
                         
        }
        
        System.debug('**** ' + isAuthorizedUser );
        return null;
     }
    
    
    //Method to Edit records
    Public PageReference doEdit(){
        initializeQuotaData();
        InitializeUserHistory();
        
        showEditSection = true;
        showViewSection = false;
        showEditBtn = false;
        showSaveBtn = true;
        
        return null;
        
    }
    
    //Method to Refersh records
    Public PageReference doReferesh(){
       
        initializeQuotaData();
        InitializeUserHistory();
        
        showEditSection = false;
        showViewSection = true;
        showEditBtn = true;
        showSaveBtn = false;
        
        return null;
        
    }
    
    //Method to Cancel Page
    Public PageReference doCancel(){
        
        initializeQuotaData();
        InitializeUserHistory();
        
        showEditSection = false;
        showViewSection = true;
        showEditBtn = true;
        showSaveBtn = false;
        
        return null;
        
    }
    
    //Method to Save records
    Public PageReference doSave(){
        
        Set<ID> qaIdsForApproval = new Set<ID>();
        //Old Values of Quota Allocation
        
        String query = '';
        Map<Id,Quota_Allocation__c> qAllocationOldMap = new Map<Id,Quota_Allocation__c>(
        
        [Select Id,Is_Approved__c,Year__c,User__r.Name, Quota_Type__r.Name,Quota_Type__c,
        
        Amount_for_Jan__c,Amount_for_Feb__c,Amount_for_Mar__c,
        Amount_for_Apr__c,Amount_for_May__c,Amount_for_June__c,
        Amount_for_July__c,Amount_for_Aug__c,Amount_for_Sept__c,
        Amount_for_Oct__c,Amount_for_Nov__c,Amount_for_Dec__c,
        
        Old_Amount_for_Jan__c,Old_Amount_for_Feb__c,Old_Amount_for_Mar__c,
        Old_Amount_for_Apr__c,Old_Amount_for_May__c,Old_Amount_for_June__c,
        Old_Amount_for_July__c,Old_Amount_for_Aug__c,Old_Amount_for_Sept__c,
        Old_Amount_for_Oct__c,Old_Amount_for_Nov__c,Old_Amount_for_Dec__c  From Quota_Allocation__c Where Is_Deleted__c!=True And User__c =:currentUserId and Year__c = :String.ValueOf(currentYear)]);
        
        
        List<Quota_Allocation__c> qAllocationSaveList = new List<Quota_Allocation__c>();
        
        // New Values of Quota Allocation
        List<QuotaWrapper>  qWrapperListToSave = mapQuotaAllocations.get(currentYear);
        
        For(QuotaWrapper q : qWrapperListToSave){
            
            
            Quota_Allocation__c  newQa = q.qAllocationObj ;
            Quota_Allocation__c  oldQa;
            
            
            if(newQa!= NULL){
                oldQa = qAllocationOldMap.get(newQa.Id) ;   
            }

            
            if( oldQa!= NULL ){
                
                System.debug('*******  NEW VALUE *****  ' +  newQa);
                System.debug('*******  OLD VALUE *****  ' +  oldQa );
                
                //Checking If Quota Amount is changed of any month 
                
                //JAN
                if( oldQa.Amount_for_Jan__c != newQa.Amount_for_Jan__c && oldQa.Amount_for_Jan__c!=null )
                {   
                    qaIdsForApproval.add(newQa.Id);
                    newqa.Is_Approved__c =  false ;
                    newQa.Old_Amount_for_Jan__c = oldQa.Amount_for_Jan__c == NULL ? 0 : oldQa.Amount_for_Jan__c; 
                }
                
                //FEB
                if( oldQa.Amount_for_Feb__c != newQa.Amount_for_Feb__c && oldQa.Amount_for_Feb__c!=null )
                {   
                    qaIdsForApproval.add(newQa.Id);
                    newqa.Is_Approved__c =  false ;
                    newQa.Old_Amount_for_Feb__c = oldQa.Amount_for_Feb__c == NULL ? 0 : oldQa.Amount_for_Feb__c; 
                }
                
                //MAR
                if( oldQa.Amount_for_Mar__c != newQa.Amount_for_Mar__c && oldQa.Amount_for_Mar__c!=null )
                {   
                    qaIdsForApproval.add(newQa.Id);
                    newqa.Is_Approved__c =  false ;
                    newQa.Old_Amount_for_Mar__c = oldQa.Amount_for_Mar__c == NULL ? 0 : oldQa.Amount_for_Mar__c; 
                }
                
                //APRIL
                if( oldQa.Amount_for_Apr__c != newQa.Amount_for_Apr__c && oldQa.Amount_for_Apr__c!=null )
                {   
                    qaIdsForApproval.add(newQa.Id);
                    newqa.Is_Approved__c =  false ;
                    newQa.Old_Amount_for_Apr__c = oldQa.Amount_for_Apr__c == NULL ? 0 : oldQa.Amount_for_Apr__c; 
                }
                
                //MAY
                if( oldQa.Amount_for_May__c != newQa.Amount_for_May__c && oldQa.Amount_for_May__c!=null )
                {   
                    qaIdsForApproval.add(newQa.Id);
                    newqa.Is_Approved__c =  false ;
                    newQa.Old_Amount_for_May__c = oldQa.Amount_for_May__c == NULL ? 0 : oldQa.Amount_for_May__c; 
                }
                
                //JUNE
                if( oldQa.Amount_for_June__c != newQa.Amount_for_June__c && oldQa.Amount_for_June__c!=null )
                {   
                    qaIdsForApproval.add(newQa.Id);
                    newqa.Is_Approved__c =  false ;
                    newQa.Old_Amount_for_June__c = oldQa.Amount_for_June__c == NULL ? 0 : oldQa.Amount_for_June__c; 
                }
                
                //JULY
                if( oldQa.Amount_for_July__c != newQa.Amount_for_July__c && oldQa.Amount_for_July__c!=null )
                {   
                    qaIdsForApproval.add(newQa.Id);
                    newqa.Is_Approved__c =  false ;
                    newQa.Old_Amount_for_July__c = oldQa.Amount_for_July__c == NULL ? 0 : oldQa.Amount_for_July__c; 
                }
                
                //AUG
                if( oldQa.Amount_for_Aug__c != newQa.Amount_for_Aug__c && oldQa.Amount_for_Aug__c!=null )
                {   
                    qaIdsForApproval.add(newQa.Id);
                    newqa.Is_Approved__c =  false ;
                    newQa.Old_Amount_for_Aug__c = oldQa.Amount_for_Aug__c == NULL ? 0 : oldQa.Amount_for_Aug__c; 
                }
                
                //SEPT
                if( oldQa.Amount_for_Sept__c != newQa.Amount_for_Sept__c && oldQa.Amount_for_Sept__c!=null )
                {   
                    qaIdsForApproval.add(newQa.Id);
                    newqa.Is_Approved__c =  false ;
                    newQa.Old_Amount_for_Sept__c = oldQa.Amount_for_Sept__c == NULL ? 0 : oldQa.Amount_for_Sept__c; 
                }
                
                //OCT
                if( oldQa.Amount_for_Oct__c != newQa.Amount_for_Oct__c && oldQa.Amount_for_Oct__c!=null )
                {   
                    qaIdsForApproval.add(newQa.Id);
                    newqa.Is_Approved__c =  false ;
                    newQa.Old_Amount_for_Oct__c = oldQa.Amount_for_Oct__c == NULL ? 0 : oldQa.Amount_for_Oct__c; 
                }
                
                //NOV
                if( oldQa.Amount_for_Nov__c != newQa.Amount_for_Nov__c && oldQa.Amount_for_Nov__c!=null )
                {   
                    qaIdsForApproval.add(newQa.Id);
                    newqa.Is_Approved__c =  false ;
                    newQa.Old_Amount_for_Nov__c = oldQa.Amount_for_Nov__c == NULL ? 0 : oldQa.Amount_for_Nov__c; 
                }
                
                //DEC
                if( oldQa.Amount_for_Dec__c != newQa.Amount_for_Dec__c && oldQa.Amount_for_Dec__c!=null )
                {   
                    qaIdsForApproval.add(newQa.Id);
                    newqa.Is_Approved__c =  false ;
                    newQa.Old_Amount_for_Dec__c = oldQa.Amount_for_Dec__c == NULL ? 0 : oldQa.Amount_for_Dec__c; 
                }
                
                //Setting Submitter Email for Notification in Email Alert 
                newQa.Submitter_Email__c = UserInfo.getUserEmail();
                
                qAllocationSaveList.add(newQa);
            }
            
        }
        
        //Updating Quota Allocation values
        if(qAllocationSaveList.size()>0)
        Update qAllocationSaveList;
        
        //Updating Quota User History
        if(qHistoryCurrentRec!=null)
        Update qHistoryCurrentRec;
        
        //Sending records for Approval 
        Messaging.SingleEmailMessage[] Emailmessages = new List<Messaging.SingleEmailMessage>();
        List<Approval.ProcessSubmitRequest> ApprovalRequests = new List<Approval.ProcessSubmitRequest>();
        
    
        
        //Getting List of Exsting Approvers based on Approval Processes (ONLY FOR CUSTOM EMAIL IF RECORD ALREADY WENT FOR APPROVAL)
        EmailTemplate eTemplate = [SELECT Id,EntityType  FROM EmailTemplate Where DeveloperName = 'Quota_Changes_VF_Template'];
        
        Map<Id, List<String>> approverEmailMap = new Map<Id, List<String>> ();
        For( ProcessInstance pi :   [SELECT Status, TargetObject.Name, TargetObjectId, TargetObject.Type, (SELECT Actor.Id, Actor.Name, Actor.Email, CreatedDate FROM WorkItems)
        FROM ProcessInstance WHERE ProcessDefinition.DeveloperName = 'Quota_Allocation_Changes' and Status='Pending' ]){
            
            for(ProcessInstanceWorkItem pw : pi.WorkItems ){
            
                if(approverEmailMap.containsKey(pi.TargetObjectId))
                approverEmailMap.get(pi.TargetObjectId).add(pw.Actor.Email);
            
                else
                approverEmailMap.put(pi.TargetObjectId, new List<String>{pw.Actor.Id});
            
            }
                
        }
        
        
        //Processing Approvals 
        For( Quota_Allocation__c qAllocation : [Select Id,Is_Approved__c From Quota_Allocation__c Where ID IN: qaIdsForApproval ]){
            
            
            //STANDARD PROCESS FOR APPROVAL
            if( qAllocationOldMap.Get(qAllocation.Id).Is_Approved__c == true){
                
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(qAllocation.Id);
                req.setProcessDefinitionNameOrId('Quota_Allocation_Changes');
                ApprovalRequests.add(req);  
                
            }
            
            
            
            //CUSTOM EMAIL IF RECORD IS ALREADY SENT FOR APPROVAL
            else if (qAllocationOldMap.Get(qAllocation.Id).Is_Approved__c == false){
                
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.templateId = eTemplate.Id ;
                message.WhatID = qAllocation.Id ;
                
                //First Index contains Approver Id
                if(approverEmailMap.Get(qAllocation.Id)!=null){
                    message.targetObjectId = approverEmailMap.Get(qAllocation.Id)[0];
                }
                
                else{
                 String err = 'Error. Record was not sumbmitted for approval ,Please Submit the record for Approval manually by Clicking <a href="/' + qAllocation.Id + '">here</a>.';
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,err));
                 return null;
                }
                
                //Removing ID on First Index from List to Get Rest Approver Emails
                approverEmailMap.Get(qAllocation.Id).Remove(0);
                message.ToAddresses = approverEmailMap.Get(qAllocation.Id);
                message.saveAsActivity = false;
                Emailmessages.add(message);
            }
            
        }
        
        //If Record needs first time approval
        if(ApprovalRequests.size()>0){
            Approval.ProcessResult[] result = Approval.process(ApprovalRequests);
        }   
        //If Record is already sent for Approval    
        if(Emailmessages.size()>0){
            messaging.sendEmail(Emailmessages);
        }
        if(ApprovalRequests.size()>0 ||  Emailmessages.size()>0)
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Changes are made successfully and record has been sent for approval'));
       
        
        showEditSection = false;
        showViewSection = true;
        showEditBtn = true;
        showSaveBtn = false;
        
        
        initializeQuotaData();
        return null;
        
        
    }
    
    public void InitializeUserHistory(){
       
        qHistoriesRecordsList =  [ Select Id,Name, User__r.UserRole.Name, Direct_Manager__c ,Sales_Team_Members__c, Title__c,Role__c,  User__c, DS__c, DS__r.Name , Effective_Date__c, Is_Current__c, CreatedDate From Quota_User_History__c Where User__c =: currentUserId
                                   order by Is_Current__c DESC ];
        
        //Getting only IsCurrent=True record from first Index
        if(qHistoriesRecordsList.size()>0){
           qHistoryCurrentRec = qHistoriesRecordsList[0];
           qHistoriesRecordsList.Remove(0);
        }
        
    }
    //Method to Calculate Monthly Sum of Each Quota For Given Year
    public List<Decimal> CalculateMonthlySumOfQuota(Integer year){
      
        quotaMonthlySum  = new List<Decimal>{
                 (Decimal)mapQuotaMonthlyTotal.Get(year).get('Jan')  == NULL ? 0 :  (Decimal)mapQuotaMonthlyTotal.Get(year).get('Jan') 
                ,(Decimal)mapQuotaMonthlyTotal.Get(year).get('Feb')  == NULL ? 0 :  (Decimal)mapQuotaMonthlyTotal.Get(year).get('Feb') 
                ,(Decimal)mapQuotaMonthlyTotal.Get(year).get('Mar')  == NULL ? 0 :  (Decimal)mapQuotaMonthlyTotal.Get(year).get('Mar') 
                ,(Decimal)mapQuotaMonthlyTotal.Get(year).get('Apr')  == NULL ? 0 :  (Decimal)mapQuotaMonthlyTotal.Get(year).get('Apr') 
                ,(Decimal)mapQuotaMonthlyTotal.Get(year).get('May')  == NULL ? 0 :  (Decimal)mapQuotaMonthlyTotal.Get(year).get('May') 
                ,(Decimal)mapQuotaMonthlyTotal.Get(year).get('June')  == NULL ? 0 : (Decimal)mapQuotaMonthlyTotal.Get(year).get('June')
                ,(Decimal)mapQuotaMonthlyTotal.Get(year).get('July')  == NULL ? 0 : (Decimal)mapQuotaMonthlyTotal.Get(year).get('July')
                ,(Decimal)mapQuotaMonthlyTotal.Get(year).get('Aug')  == NULL ? 0 :  (Decimal)mapQuotaMonthlyTotal.Get(year).get('Aug') 
                ,(Decimal)mapQuotaMonthlyTotal.Get(year).get('Sept')  == NULL ? 0 : (Decimal)mapQuotaMonthlyTotal.Get(year).get('Sept')
                ,(Decimal)mapQuotaMonthlyTotal.Get(year).get('Oct')  == NULL ? 0 :  (Decimal)mapQuotaMonthlyTotal.Get(year).get('Oct') 
                ,(Decimal)mapQuotaMonthlyTotal.Get(year).get('Nov')  == NULL ? 0 :  (Decimal)mapQuotaMonthlyTotal.Get(year).get('Nov') 
                ,(Decimal)mapQuotaMonthlyTotal.Get(year).get('Dec')  == NULL ? 0 :  (Decimal)mapQuotaMonthlyTotal.Get(year).get('Dec') 
                };
        return  quotaMonthlySum;  
    
    }
   
    //Adding Monthly Total for Quota   
    //Few lines commented to off Monthly Total Column in Page Block table
    
    public List<QuotaWrapper> getQuotaData_Current_Year(){
      
      if(mapQuotaAllocations!=null && mapQuotaAllocations.get(currentYear)!=null ){  
      
        //mapQuotaAllocations.get(currentYear).Add( new QuotaWrapper('Monthly Total', CalculateMonthlySumOfQuota(currentYear),null) );
  
      return mapQuotaAllocations.get(currentYear);
      }
      return null;
    }
    
    
    public List<QuotaWrapper> getQuotaData_Previous_1_Year(){
     
     if(mapQuotaAllocations!=null && mapQuotaAllocations.get(currentYear - 1)!=null ){  

       //mapQuotaAllocations.get(currentYear - 1).Add( new QuotaWrapper('Monthly Total', CalculateMonthlySumOfQuota(currentYear - 1),null) );
  
      return mapQuotaAllocations.get(currentYear - 1);
      }
      return null;
    }
    
    public List<QuotaWrapper> getQuotaData_Previous_2_Year(){
      if(mapQuotaAllocations!=null && mapQuotaAllocations.get(currentYear - 2)!=null ){
          
       
       //mapQuotaAllocations.get(currentYear - 2).Add( new QuotaWrapper('Monthly Total', CalculateMonthlySumOfQuota(currentYear - 2),null) );
   
       return mapQuotaAllocations.get(currentYear - 2);
      }
      return null;
    }
    
    public List<QuotaWrapper> getQuotaData_Previous_3_Year(){
              
        If(mapQuotaAllocations!=null && mapQuotaAllocations.get(currentYear - 3)!=null){
        
        //mapQuotaAllocations.get(currentYear - 3).Add( new QuotaWrapper('Monthly Total', CalculateMonthlySumOfQuota(currentYear - 3),null) );
        
        return mapQuotaAllocations.get(currentYear - 3);
        }
        return null;
    }
    
  
    
    public void initializeQuotaData(){
        
        String  quotaQuery = 'Select Id,Year__c,Quota_Type__r.Currency_Type__c, Quota_Type__r.Name,Quota_Type__c,Amount_for_Jan__c,Old_Amount_for_Jan__c,Amount_for_Feb__c,Old_Amount_for_Feb__c,Amount_for_Mar__c,Old_Amount_for_Mar__c , ' + 
                                                  'Amount_for_Apr__c, Old_Amount_for_Apr__c ,Old_Amount_for_May__c,Old_Amount_for_June__c,Old_Amount_for_July__c,Old_Amount_for_Aug__c,Old_Amount_for_Sept__c , ' +
                                                  'Old_Amount_for_Oct__c , Old_Amount_for_Nov__c,Old_Amount_for_Dec__c , '+
                                                  'Amount_for_May__c,Amount_for_June__c, Amount_for_July__c,Amount_for_Aug__c,Amount_for_Sept__c,' +
                                                  'Amount_for_Oct__c,Amount_for_Nov__c,Amount_for_Dec__c  From Quota_Allocation__c Where Is_Deleted__c!=True And User__c = \'' + currentUserId + '\' and '  +  
                                                  'Is_Apporved_New__c = TRUE and Year__c IN (' + '\'' + currentYear + '\',' + '\'' + Integer.ValueOf(currentYear-1) + '\',' + '\'' + Integer.ValueOf(currentYear-2) + '\',' + '\'' + Integer.ValueOf(currentYear-3)+ '\') order by Year__c,Quota_Type__r.Name ASC';
                                                  
                                                  
        String aggregateQuotaQuery = 'Select SUM(Amount_for_Jan__c) Jan,SUM(Amount_for_Feb__c) Feb,SUM(Amount_for_Mar__c) Mar,SUM(Amount_for_Apr__c) Apr,SUM(Amount_for_May__c) May,'+
                                                    'SUM(Amount_for_June__c) June,SUM(Amount_for_July__c) July,SUM(Amount_for_Aug__c) Aug,SUM(Amount_for_Sept__c) Sept,SUM(Amount_for_Oct__c) Oct,'+
                                                    'SUM(Amount_for_Nov__c) Nov ,SUM(Amount_for_Dec__c) Dec,Year__c, Count(Quota_Type__r.Name)'+ 
                                                    'From Quota_Allocation__c Where  Is_Deleted__c!=True And User__c = \'' + currentUserId + '\' and '  +  
                                                    'Is_Apporved_New__c = TRUE and Year__c IN (' + '\'' + currentYear + '\',' + '\'' + Integer.ValueOf(currentYear-1) + '\',' + '\'' + Integer.ValueOf(currentYear-2) + '\',' + '\'' + Integer.ValueOf(currentYear-3)+ '\')' +
                                                    'Group by Year__c';                                         
                                            
        System.debug(' *********** quotaQuery ************** ' + quotaQuery);
        
        //Populating Map for Monthly SUM for Each Quota per year
        mapQuotaMonthlyTotal = new Map<Integer,AggregateResult>();
        For ( AggregateResult aResult :  Database.Query(aggregateQuotaQuery) )
        {
            mapQuotaMonthlyTotal.Put(Integer.ValueOf(aResult.get('Year__c')) , aResult);
        }

        mapQuotaAllocations = new Map<Integer, List<QuotaWrapper>>();
        //List of Quota Mo;nthly Amount
        List<Decimal> monthAmounts ;
        
        For(Quota_Allocation__c qAllocation :  Database.Query(quotaQuery) ){
            
                  
             monthAmounts  = new List<Decimal>{
                 (Decimal)qAllocation.Amount_for_Jan__c == NULL ? 0 :  (Decimal)qAllocation.Amount_for_Jan__c 
                ,(Decimal)qAllocation.Amount_for_Feb__c == NULL ? 0 :  (Decimal)qAllocation.Amount_for_Feb__c
                ,(Decimal)qAllocation.Amount_for_Mar__c == NULL ? 0 :  (Decimal)qAllocation.Amount_for_Mar__c 
                ,(Decimal)qAllocation.Amount_for_Apr__c == NULL ? 0 :  (Decimal)qAllocation.Amount_for_Apr__c
                ,(Decimal)qAllocation.Amount_for_May__c == NULL ? 0 :  (Decimal)qAllocation.Amount_for_May__c
                ,(Decimal)qAllocation.Amount_for_June__c == NULL ? 0 : (Decimal)qAllocation.Amount_for_June__c
                ,(Decimal)qAllocation.Amount_for_July__c == NULL ? 0 : (Decimal)qAllocation.Amount_for_July__c
                ,(Decimal)qAllocation.Amount_for_Aug__c == NULL ? 0 :  (Decimal)qAllocation.Amount_for_Aug__c 
                ,(Decimal)qAllocation.Amount_for_Sept__c == NULL ? 0 : (Decimal)qAllocation.Amount_for_Sept__c
                ,(Decimal)qAllocation.Amount_for_Oct__c == NULL ? 0 :  (Decimal)qAllocation.Amount_for_Oct__c
                ,(Decimal)qAllocation.Amount_for_Nov__c == NULL ? 0 :  (Decimal)qAllocation.Amount_for_Nov__c
                ,(Decimal)qAllocation.Amount_for_Dec__c == NULL ? 0 :  (Decimal)qAllocation.Amount_for_Dec__c
                };
                
                
                //If month amount is NULL , it will show  0
                qAllocation.Amount_for_Jan__c  =  qAllocation.Amount_for_Jan__c == NULL ? 0  :  qAllocation.Amount_for_Jan__c;
                qAllocation.Amount_for_Feb__c  =  qAllocation.Amount_for_Feb__c == NULL ? 0  :  qAllocation.Amount_for_Feb__c;
                qAllocation.Amount_for_Mar__c  =  qAllocation.Amount_for_Mar__c == NULL ? 0  :  qAllocation.Amount_for_Mar__c;
                qAllocation.Amount_for_Apr__c  =  qAllocation.Amount_for_Apr__c == NULL ? 0  :  qAllocation.Amount_for_Apr__c;
                qAllocation.Amount_for_May__c  =  qAllocation.Amount_for_May__c == NULL ? 0  :  qAllocation.Amount_for_May__c;
                qAllocation.Amount_for_June__c =  qAllocation.Amount_for_June__c == NULL ? 0 : qAllocation.Amount_for_June__c;
                qAllocation.Amount_for_July__c =  qAllocation.Amount_for_July__c == NULL ? 0 : qAllocation.Amount_for_July__c;
                qAllocation.Amount_for_Aug__c  =  qAllocation.Amount_for_Aug__c == NULL ? 0  :  qAllocation.Amount_for_Aug__c;
                qAllocation.Amount_for_Sept__c =  qAllocation.Amount_for_Sept__c == NULL ? 0 : qAllocation.Amount_for_Sept__c;
                qAllocation.Amount_for_Oct__c  =  qAllocation.Amount_for_Oct__c == NULL ? 0  :  qAllocation.Amount_for_Oct__c;
                qAllocation.Amount_for_Nov__c  =  qAllocation.Amount_for_Nov__c == NULL ? 0  :  qAllocation.Amount_for_Nov__c;
                qAllocation.Amount_for_Dec__c  =  qAllocation.Amount_for_Dec__c == NULL ? 0  :  qAllocation.Amount_for_Dec__c;
                
                
                
                If( mapQuotaAllocations.containsKey(Integer.ValueOf(qAllocation.Year__c)) ){
                    mapQuotaAllocations.get(Integer.ValueOf(qAllocation.Year__c)).Add(new QuotaWrapper(qAllocation.Quota_Type__r.Name, monthAmounts , qAllocation));
                }
                
                else{
                    mapQuotaAllocations.put(Integer.ValueOf(qAllocation.Year__c), new List<QuotaWrapper>{new QuotaWrapper(qAllocation.Quota_Type__r.Name, monthAmounts , qAllocation)}); 
                }  
                                                 
        }
       
        if( mapQuotaAllocations.values()!=null && mapQuotaAllocations.values().size()>0 ){
            quotaExistForUser = true;
        }
        
        System.Debug('***** MAP ****  '+  mapQuotaAllocations);
    }
    
    public class UserWrapper {
        public User usr {get; set;}
        public String Role {get; set;}
        public String Product {get; set;}
        
        public UserWrapper(User usr0, String Role0, String Product0){
            usr = usr0 ;
            Role = Role0;
            Product = Product0;
        }
        
        
    }
    public class QuotaWrapper {
        public String quotaName {get; set;}
        public Quota_Allocation__c qAllocationObj {get; set;}
        public List<Decimal> monthsAmount {get; set;}
        public QuotaWrapper(String name0, List<Decimal> monthsAmount0 , Quota_Allocation__c qAllocationObj0){
            quotaName = name0;
            monthsAmount = monthsAmount0;
            qAllocationObj = qAllocationObj0 ;
        }
        
        public Decimal getTotalAmount(){
            Decimal total = 0;
            for(Decimal val: monthsAmount){
                total = total + val;
            } 
            return total;
        }        
        
    }   
    
}