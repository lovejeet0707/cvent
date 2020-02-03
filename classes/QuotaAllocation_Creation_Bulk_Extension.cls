public with sharing class QuotaAllocation_Creation_Bulk_Extension 
{
 
// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 11/02/2016
// PURPOSE     :  To Create Quota Records
// Test Class : QuotaAllocation_Creation_Bulk_Ext_Test
// SPECIAL NOTES:
// ===============================
// Change History:
//
//==================================


    public List<QuotaAllocationWrapper> wrappers {get; set;}
    public static Integer toDelIdent {get; set;}
    public static Integer addCount {get; set;}
    private Integer nextIdent=1;
    //Contains User Role for Populating Product/Team and Role field 
    Map<ID,String> usrRoles ;
    public integer rowIndex {get;set;}
    
    //If user is authorized to access the page 
    public boolean isAuthorizedUser{get;set;}
      
    //If User Id found in the URL for quota user (Clicked by Link "Click Here" from Quota Management tab)
    string userId = ApexPages.CurrentPage().GetParameters().Get('uid');
    
    Public QuotaAllocation_Creation_Bulk_Extension  (ApexPages.StandardController contr){
        isAuthorizedUser = false;
        wrappers=new List<QuotaAllocationWrapper>();
        //for (Integer idx=0; idx<3; idx++)
        //{
         wrappers.add(new QuotaAllocationWrapper(nextIdent++));
        //}
    }
    
    
    // Method to restrict the page or functionality if User is not authorized.
    public PageReference CheckPermission(){
        
        //Current User Information
        User currentUser = [ Select Id, UserRoleId, ProfileId, UserRole.Name , Profile.Name From User Where Id=:UserInfo.getUserId() ];
        
        //15 Character Id
        String currentUserId = String.valueOf(UserInfo.getUserId().substring(0, 15));
        
        
        /***** We were using all custom setting data without using SOQL query 
                But it imapcts performance where all data should not needed 
                
                Since July 2016 Moved to next piece of code (Using SOQL for required data )

        *********************************************************************
        
        //Map of Custom Setting  contains Key = Profile-Role and Value = related Permission (Read/Write)/Read Only
        Map<String, String> mapQuotaSecuritySetting = new Map<String, String>();
        
        //Map of Custom Setting  contains Key = Profile-Role and Value = Exceptional User Ids 
        Map<String, Set<String>> mapQuotaExceptionalUsers = new Map<String, Set<String>>(); 
        
        Set<String> exceptionalUserIdsSet;
        
    
        
        
        
        //Setting Map based on Profile-Role
        for( Quota_Management_Securtity_Setting__c qSecurity : Quota_Management_Securtity_Setting__c.getAll().Values() ){           
             
             
             
             mapQuotaSecuritySetting.put( qSecurity.Profile_Name__c + '-' + qSecurity.Role__c, qSecurity.Permission__c );
             mapQuotaExceptionalUsers.put( qSecurity.Profile_Name__c + '-' + qSecurity.Role__c, exceptionalUserIdsSet );
        }
       
         System.debug('**** mapQuotaSecuritySetting ' + mapQuotaSecuritySetting);
         
        ********/
        
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
            System.debug('**** currentUserId *** ' + currentUserId);
            
           // System.debug('**** exceptionalUserIds  ' + exceptionalUserIds.Contains(currentUserId));
            
            
            //If User permissions exist in Custom Setting
            if( permission !=null ){
            
                if( (permission == 'Read only' || permission == 'Read Only') && !exceptionalUserIds.Contains(currentUserId))
                    isAuthorizedUser = false;
                    
                else if( permission == 'Read/Write' || exceptionalUserIds.Contains(currentUserId) )
                    isAuthorizedUser = true;
            }
            
             
        }
        
        System.debug('**** ' + isAuthorizedUser );
        return null;
     }
        
    //Delete Rows   
    public void delWrapper(){
        
        Integer toDelPos=-1;
        for (Integer idx=0; idx<wrappers.size(); idx++){
           if (wrappers[idx].ident==toDelIdent){
            toDelPos=idx;
           }
        }
        if (-1!=toDelPos){
           wrappers.remove(toDelPos);
        }
    }
     
    //Add Rows
    public pageReference addRows()
    {
        for (Integer idx=0; idx<addCount; idx++){
         wrappers.add(new QuotaAllocationWrapper(nextIdent++));
       }
       return null;
    }

     String quotaRole;
     
    //Refereshing Quota Types and Sales Team Members on User lookup select 
    public pageReference RefereshQuotas(){
         
        SelectOption[] qTypes = new SelectOption[]{}; 
        quotaRole = '';
        Integer listIndex =0;
        
        User user ;            
        system.debug('******  rowIndex  ****** ' + rowIndex);
        system.debug('******  wrappers ******  ' + wrappers);
        
        QuotaAllocationWrapper wrapperFinal;
        
        if(rowIndex!=null){
            //Checking List index based on indent stored in wrapper (rowIndex and indent will have same value)
            for(QuotaAllocationWrapper w : wrappers ){
                if(rowIndex==w.ident){
                    wrapperFinal = w;
                    break;
                }
                listIndex++;
            }
        }
        
        Id selectedUserId = wrappers.get(listIndex).qAllocation.User__c ;
        
        system.debug('******  User  **  ' + selectedUserId);
        user  = [ Select Id, Name, UserRole.Name From User Where Id =:selectedUserId ];
        system.debug('******  Role **  ' + user.Name + '  ' +  user.UserRole.Name );
        quotaRole = user.UserRole.Name;

        
        //Sales Team Members Exist in System
        Quota_User_History__c [] qHistory = [Select Id , Sales_Team_Members__c From Quota_User_History__c Where User__c= :selectedUserId ] ;
        
        
        //Fetch Quota Types based on Role
        if(quotaRole!=null){
            string query = 'SELECT Name FROM Quota__c WHERE SF_Role__c =: quotaRole Order by name ' ;
                //LIKE \'%'  + quotaRole + '%\'' +' order by name';
            for (Quota__c q : Database.Query(query)) {  
                qTypes.add(new SelectOption(q.id, q.name ));  
            }
        }
        
        system.debug('****** qTypes **** ' + qTypes);
        system.debug('****** qHistory **** ' + qHistory);
        
        if(wrapperFinal!=null){

            if(qTypes.size()>0)
                wrapperFinal.QuotaTypes = qTypes;
                
            else{           
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, 'Quota type not defined for this user'));
             }
        
            if(qHistory.size()>0)
                wrapperFinal.salesTeamMembers = qHistory.get(0).Sales_Team_Members__c;
        }
       		 
            
        return null;
    }    
     
     
    public PageReference save(){
        
        List<Quota_Allocation__c> qAllocations = new List<Quota_Allocation__c>();
        usrRoles = new Map<ID,String>();
        Set<ID> userIds = new Set<ID>();
        
        List<Approval.ProcessSubmitRequest> ApprovalRequests = new List<Approval.ProcessSubmitRequest>();
        
        for ( QuotaAllocationWrapper wrap : wrappers )
        {
            userIds.add(wrap.qAllocation.User__c);
        }
        
        for ( User u : [Select Id, UserRole.Name From User Where ID IN: userIds ]){
           usrRoles.Put(u.Id, u.UserRole.Name);  
        }
        
        
        for ( QuotaAllocationWrapper wrap : wrappers ){
               
           Quota_Allocation__c qa = wrap.qAllocation ;
           
           qa.Sales_Team_Members__c =  wrap.salesTeamMembers ;
          
           //Setting Submitter Email for Notification in Email Alert 
           qa.Submitter_Email__c = UserInfo.getUserEmail();
           
           
           System.Debug('********** ROLE ****** ' + qa.User__r.UserRole.Name);

           If(usrRoles.get(qa.User__c)!=null){
           qa.Product_Team__c  =    usrRoles.get(qa.User__c).substringAfterLast('(').RemoveEnd(')');
           qa.Role_Name__c     =    usrRoles.get(qa.User__c).substringBeforeLast('(');
           }
           
           qAllocations.add(qa);        
           
        }
           
        try{
            insert qAllocations;
        }
        
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            return  null;
        }
        
        //Processing for Approval
        for(Quota_Allocation__c q :  qAllocations){
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(q.Id);
            req.setProcessDefinitionNameOrId('Quota_New_User_Approval');
            ApprovalRequests.add(req); 
        }
        
        //Approval Sent
        if(ApprovalRequests.size()>0){
            Approval.ProcessResult[] result = Approval.process(ApprovalRequests);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Records are saved sucessfully and Approval has been sent'));
        }

        return new PageReference('/apex/QuotaAllocation_User_Selection_Page');
    }
      
    public class QuotaAllocationWrapper{
        
      public Quota_Allocation__c qAllocation {get; set;}
      public Integer ident {get; private set;}
      Public string salesTeamMembers {get;set;}
      public SelectOption[] QuotaTypes{get;set;}
            
       public QuotaAllocationWrapper(Integer inIdent){
       ident=inIdent;
       qAllocation=new Quota_Allocation__c(Sales_Team_Members__c=salesTeamMembers);
       
       //Default to current year
       qAllocation.Year__c = String.ValueOf(System.Today().year());
      }      
    }
    
}