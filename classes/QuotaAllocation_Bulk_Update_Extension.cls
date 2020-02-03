// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 15/03/2016
// PURPOSE     :  Manage Quota for Multiple Users at a time (Add/Update)
// TEST CLASS :   
// SPECIAL NOTES:
// ===============================
public class QuotaAllocation_Bulk_Update_Extension{
    
    //****START SEARCHING USERS FOR BULK QUOTA ALLOCATION *******//
    
    public string teamMembers  { get; set; }
    public boolean searchPicklist {get;set;}
    public String nameSearchTxt     { get; set; }
    public String productSearchTxt  { get; set; }
    public String roleSearchTxt     { get; set; }
    
    
    Id currentUserId = UserInfo.GetUserId();
    Id currentUserManagerId ;
    
    public boolean showResults      { get; set; }
    public string TeamOrUsers       { get; set; }
    
    
    public List<UserWrapper>  userWrappers {get;set;}
    
    //If user is authorized to access the page 
    public boolean isAuthorizedUser  {get;set;}
    public boolean  isFinanceProfile {get;set;}
    
    //Variables for Pagination
    //default page size
    private static final Integer PAGE_SIZE = 25;
    
    
    //pagination information
    public Integer pageNo{get;set;}
    public Integer totalRecords{get;set;}
    public Integer totalPages{get;set;}
    public Integer startIdx{get;set;}
    public Integer endIdx{get;set;}
 
    Set<ID> approverIds;
    
    public QuotaAllocation_Bulk_Update_Extension( ApexPages.StandardController controller ) {
        showResults = true;
        isNewQuotaAdded = false;
        isFinanceProfile = true;
        isSelectedAll=false;
        searchPicklist=false;

        //Getting ManagerId of Current User
        currentUserManagerId =  [Select ManagerId From User Where Id =:currentUserId].ManagerId;
        isAuthorizedUser = false;
        
        //Get Approvers from custom Label
        approverIds = new Set<ID>();
        List<Id> approversSplitted = Label.Quota_Approvers.split(',');
        approverIds.addAll(approversSplitted);
        
        //Enable Search by picklist for Non- Approvers
        if(!approverIds.contains(currentUserId)){
            searchPicklist=true;
        }
        System.debug('*****searchPicklist Action****' + searchPicklist);
        
        
        //set initial page
        this.pageNo = 1;
        
        //Load User Records
        getUserResults();
    }
    
    public PageReference FetchUserData(){
         this.pageNo=1;
         getUserResults();
         return null;
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

    //Getting User List 
    Set<ID> allUserIds;
    public List<UserWrapper> getUserResults(){
         
         String userQuery = '';
        
            
         //Users based on the downward hierarchy aligned with Manager (Top to bottom)
         allUserIds = UserHierarchyUtil.getUsersByHierarchy(currentUserId);
         
             //UserHierarchyUtil.getUsersByHierarchy(currentUserId);
        
       
        /************   Obsolete Code (Since July 2016 )*******************************
         * We were using this code to get list of users only aligned with current user 
         * We need to show all users downward in the hierarchy 
         ******************************************************************************
          
         userQuery = 'Select Id,Office_Location__c, FirstName,LastName,Name, UserRole.Name, Team__c,Sales_Rep_Tier__c,Manager.Name,'+
        'EmployeeNumber,CreatedDate,CreatedBy.Name,LastModifiedBy.Name,LastModifiedDate From User where ManagerId = \'' + currentUserId+ '\' And isActive = true ' ;
        
        System.debug('*********** ==> TeamOrUsers '+ TeamOrUsers);
        
        if( TeamOrUsers == 'My Team'){
         userQuery = 'Select Id,Office_Location__c, FirstName,LastName,Name, UserRole.Name, Team__c,Sales_Rep_Tier__c,Manager.Name,'+
        'EmployeeNumber,CreatedDate,CreatedBy.Name,LastModifiedBy.Name,LastModifiedDate From User where ManagerId = \'' + currentUserId+ '\' And isActive = true ' ;
        }
        
        else if(TeamOrUsers == 'All Users'){
         userQuery = 'Select Id,Office_Location__c, FirstName,LastName,Name, UserRole.Name, Team__c,Sales_Rep_Tier__c,Manager.Name,'+
        'EmployeeNumber,CreatedDate,CreatedBy.Name,LastModifiedBy.Name,LastModifiedDate From User WHERE IsPortalEnabled = false AND UserRoleId != null AND IsActive = true ' ;
        }
        */
        
        /****** Since July 2016 ( Getting all users based on the downward hierarchy)
         **************************************************************************/
        
         List<User> u = Database.query('Select Id,Office_Location__c, FirstName,LastName,Name, UserRole.Name, Team__c,Sales_Rep_Tier__c,Manager.Name,'+
        'EmployeeNumber,CreatedDate,CreatedBy.Name,LastModifiedBy.Name,LastModifiedDate From User where Id IN: allUserIds ' );
        System.debug('@@@@@@@ allUserIds @@@ ' + allUserIds.size() );
        

        userQuery = 'Select Id,Office_Location__c, FirstName,LastName,Name, UserRole.Name, Team__c,Sales_Rep_Tier__c,Manager.Name,'+
        'EmployeeNumber,CreatedDate,CreatedBy.Name,LastModifiedBy.Name,LastModifiedDate From User where ManagerId = \'' + currentUserId+ '\' And isActive = true ';
            //where ManagerId = \'' + currentUserId+ '\' And isActive = true ' ;
        
        System.debug('*********** ==> TeamOrUsers '+ TeamOrUsers);
        System.debug('*********** ==> searchPicklist '+ searchPicklist);
        //Approvers should see all reps 
        if(searchPicklist==false){
            userQuery = 'Select Id,Office_Location__c, FirstName,LastName,Name, UserRole.Name, Team__c,Sales_Rep_Tier__c,Manager.Name,'+
            'EmployeeNumber,CreatedDate,CreatedBy.Name,LastModifiedBy.Name,LastModifiedDate From User where isActive=true And (UserRole.Name like \'Direct Sales%\' OR UserRole.Name like \'Pre Sales%\' OR UserRole.Name like \'AM%\' OR UserRole.Name like \'AM Pre Sales%\') '  ;
        }else{

            if( TeamOrUsers == 'My Team'){
             //this.pageNo=1;
             userQuery = 'Select Id,Office_Location__c, FirstName,LastName,Name, UserRole.Name, Team__c,Sales_Rep_Tier__c,Manager.Name,'+
            'EmployeeNumber,CreatedDate,CreatedBy.Name,LastModifiedBy.Name,LastModifiedDate From User where ManagerId = \'' + currentUserId+ '\' And isActive = true ';
            }
            
            
            else if(TeamOrUsers == 'All Users'){
             userQuery = 'Select Id,Office_Location__c, FirstName,LastName,Name, UserRole.Name, Team__c,Sales_Rep_Tier__c,Manager.Name,'+
            'EmployeeNumber,CreatedDate,CreatedBy.Name,LastModifiedBy.Name,LastModifiedDate From User where Id IN: allUserIds '  ;
            }
        }
        
        
        
        
        /* SINCE JULY 2016 (OFF)
        else if(TeamOrUsers == 'All Users'){
         userQuery = 'Select Id,Office_Location__c, FirstName,LastName,Name, UserRole.Name, Team__c,Sales_Rep_Tier__c,Manager.Name,'+
        'EmployeeNumber,CreatedDate,CreatedBy.Name,LastModifiedBy.Name,LastModifiedDate From User WHERE IsPortalEnabled = false AND UserRoleId != null AND IsActive = true ' ;
        }
        */
        
        if( String.isNotBlank(nameSearchTxt) ){
         userQuery += ' And Name like \'%'+ nameSearchTxt + '%\' ' ;
        }
        
        if( String.isNotBlank(productSearchTxt)){
         userQuery += ' And UserRole.Name like \'%'+ productSearchTxt + '%\' ' ;
        }
        
        if( String.isNotBlank(roleSearchTxt) ){
         userQuery += ' And UserRole.Name like \'%'+ roleSearchTxt + '%\' ' ;
        }
        
        /*
            if(TeamOrUsers == 'All Users'){
                userQuery += ' LIMIT 10 ';
            }
        */
        
        userQuery += ' ORDER BY Manager.Name' ;
        
        System.debug('=========>  userQuery ==== > ' + userQuery);

        if(isSelectedAll==true){
            return  userWrappers;
        }
        else{
            return PopulateRoleAndProductOnUsers(userQuery);
        }
    }
    
    public PageReference ManageAllocations(){
     
     
      //Selected Users for Allocation
      selectedUserIds = new Set<ID>();
      For( UserWrapper uw : userWrappers){
            if(uw.IsSelected ==  true ){
                selectedUserIds.add(uw.usr.Id);
            }
        }
        return new PageReference ('/apex/QuotaAllocation_Bulk_Update_Page');
         
    }
    
    public boolean isSelectedAll{get;set;}
    //Selec All Users
    public PageReference SelectAll(){

        isSelectedAll=true;
        
        For( UserWrapper uw : userWrappers){
            uw.IsSelected =  true ;
        }
        return null;
         
    }
    
    
    public PageReference RedirectToAllocation(){
        
        return new PageReference ('/apex/QuotaAllocation_Creation_Bulk_Page');
         
    }
   
    public List<UserWrapper> PopulateRoleAndProductOnUsers( string userQuery){
        
         //calculate range of records for capture
         this.startIdx = (this.pageNo-1)*PAGE_SIZE;
         this.endIdx = this.pageNo*PAGE_SIZE;
         this.totalRecords = 0;         
        
        
        //If User is searching by entering keywords ( Allow IF condition on line no.320 to be satisfied to show results) 
        if(userQuery.contains('like')){
            this.startIdx = 0;
        }
        
        //clear container for records displayed
        if(this.userWrappers!=null)
        this.userWrappers.clear();
        
        
        string roleName = '';
        string product = '';

            userWrappers = new List<UserWrapper>();
            
            for ( User u : Database.Query(userQuery) ){
                    
                    if(u.UserRole.Name!=null){
                        roleName = u.UserRole.Name.substringBeforeLast('(');
                        product = u.UserRole.Name.substringAfterLast('(').RemoveEnd(')');
                    }
                
                System.debug('*****totalRecords ADDED ******** '+ totalRecords );
                System.debug('*****startIdx ADDED ******** '+ startIdx );
                System.debug('*****endIdx ADDED ******** '+ endIdx );
                    
                    if(this.totalRecords>=this.startIdx && this.totalRecords<this.endIdx){   
                        userWrappers.add(new UserWrapper(u , roleName, product)); 
                        System.debug('*****userWrappers ADDED ******** '+ userWrappers );
                    }
                
                  //count the total number of records
                  this.totalRecords++;
            }
        
        
        //calculate total pages
        Decimal pages = Decimal.valueOf(this.totalRecords);
        System.debug('****pages 1**   ' +  pages);
        pages = pages.divide(Decimal.valueOf(PAGE_SIZE), 2);
        System.debug('****pages 2**   ' +  pages);
        
        this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
        System.debug('****totalPages 1**   ' +  totalPages);
        
        //adjust start index e.g. 1, 11, 21, 31
        this.startIdx++;
        
        
        //adjust end index
        if(this.endIdx>this.totalRecords){
            this.endIdx = this.totalRecords;
        }
        
        
        System.debug('****** userWrappers**** '+  userWrappers.size());
        //this.pageNo=1;
        return userWrappers ;
        
    }
    
      /**** START Pagination Methods 
     ******************************/
    
    /*
    *   advance to next page
    */
    public void doNext(){
        
        system.debug('#### BEFORE HAS NEXT###');
        if(getHasNext()){
        system.debug('#### AFTER  HAS NEXT###');
            isSelectedAll=false;
            this.pageNo++;
            getUserResults();
        }
       
    }
    
    
    /*
    *   advance to previous page
    */
    public void doPrevious(){
        
        if(getHasPrevious()){
            isSelectedAll=false;
            this.pageNo--;
            getUserResults();
        }          
    }
    
    /*
    *   returns whether the previous page exists
    */
    public Boolean getHasPrevious(){
        //getUserResults();
        System.debug('*** pageNo ' + this.pageNo );
        if(this.pageNo>1){
            return true;
        }
        else{
            return false;
        }
    }
    
    /*
    *   returns whether the next page exists
    */
    public Boolean getHasNext(){
        //getUserResults();
        System.debug('****totalPages 2 **   ' +  this.totalPages);
        
        if(this.pageNo<this.totalPages){
            return true;
        }
        else{
            return false;
        }
       
    }
   
    /**** END Pagination Methods 
     *******************************/
    

    
    class UserWrapper {
        public User usr {get; set;}
        public string role  {get; set;}
        public string product  {get; set;}
        
        public boolean isSelected {get; set;}
        
        public UserWrapper (User usr0 , string role0, string product0){
            product = product0;
            role = role0;
            usr = usr0;
        }
    }
    //****END SEARCHING USERS FOR BULK QUOTA ALLOCATION *******//
    
    
    /**********************************************************
    ***********************************************************
    **************** BREAK FOR ANOTHER FUNCTIONALITY **********
    ***********************************************************
    **********************************************************/
    
    
    //**** START BULK UPDATING FOR QUOTA ALLOCATIONS *******//
    
    public Set<ID> selectedUserIds ;
    Map<Id,User> selectedUserMap ;
    String currentYear = String.ValueOf(Date.Today().Year());
    
    //Map of Quota Allocations per user
    Map<User, List<QuotaWrapper>> mapQuotaAllocations ;
    
    //List of User and Quota Allocation in one wrapper class 
    public List<QuotaAllocationUserWrapper> qAllocationUserWrapper {get;set;}
    
    //Map for Each User containing Monthly Sum (Key= UserId, Value = Sum of Each Month )
    public Map<Id,AggregateResult> mapUserMonthlyTotal ;
    
   
    

    //Variable for new Quota
    public boolean isNewQuotaAdded {get;set;}
    public Id userIdForNewQuota {get;set;}
    
    public Integer rowNum{get;set;}
    public Quota_Allocation__c qAllocationDelete {get;set;}
    public Id quotaDeleteId {get;set;}
    
    
    
    //Method to Calculate Monthly Sum of Each Quota For Given User
    public List<Decimal> CalculateMonthlySumOfQuota(Id userId){
      
        List<Decimal> quotaMonthlySum  = new List<Decimal>{
                 (Decimal)mapUserMonthlyTotal.Get(userId).get('Jan')  == NULL ? 0 :  (Decimal)mapUserMonthlyTotal.Get(userId).get('Jan') 
                ,(Decimal)mapUserMonthlyTotal.Get(userId).get('Feb')  == NULL ? 0 :  (Decimal)mapUserMonthlyTotal.Get(userId).get('Feb') 
                ,(Decimal)mapUserMonthlyTotal.Get(userId).get('Mar')  == NULL ? 0 :  (Decimal)mapUserMonthlyTotal.Get(userId).get('Mar') 
                ,(Decimal)mapUserMonthlyTotal.Get(userId).get('Apr')  == NULL ? 0 :  (Decimal)mapUserMonthlyTotal.Get(userId).get('Apr') 
                ,(Decimal)mapUserMonthlyTotal.Get(userId).get('May')  == NULL ? 0 :  (Decimal)mapUserMonthlyTotal.Get(userId).get('May') 
                ,(Decimal)mapUserMonthlyTotal.Get(userId).get('June')  == NULL ? 0 : (Decimal)mapUserMonthlyTotal.Get(userId).get('June')
                ,(Decimal)mapUserMonthlyTotal.Get(userId).get('July')  == NULL ? 0 : (Decimal)mapUserMonthlyTotal.Get(userId).get('July')
                ,(Decimal)mapUserMonthlyTotal.Get(userId).get('Aug')  == NULL ? 0 :  (Decimal)mapUserMonthlyTotal.Get(userId).get('Aug') 
                ,(Decimal)mapUserMonthlyTotal.Get(userId).get('Sept')  == NULL ? 0 : (Decimal)mapUserMonthlyTotal.Get(userId).get('Sept')
                ,(Decimal)mapUserMonthlyTotal.Get(userId).get('Oct')  == NULL ? 0 :  (Decimal)mapUserMonthlyTotal.Get(userId).get('Oct') 
                ,(Decimal)mapUserMonthlyTotal.Get(userId).get('Nov')  == NULL ? 0 :  (Decimal)mapUserMonthlyTotal.Get(userId).get('Nov') 
                ,(Decimal)mapUserMonthlyTotal.Get(userId).get('Dec')  == NULL ? 0 :  (Decimal)mapUserMonthlyTotal.Get(userId).get('Dec') 
                };
        return  quotaMonthlySum;  
    
    }
    
    //Method to Save Quotas
    public PageReference doSave(){
        
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
        Old_Amount_for_Oct__c,Old_Amount_for_Nov__c,Old_Amount_for_Dec__c  From Quota_Allocation__c Where Is_Deleted__c !=true And User__c IN: selectedUserIds and Year__c = :currentYear]);
        
        
        List<Quota_Allocation__c> qAllocationSaveList = new List<Quota_Allocation__c>();
        
        
        
        // New Values of Quota Allocation
        List<QuotaWrapper>  qWrapperListToSave = new List<QuotaWrapper>();
        
        for( List<QuotaWrapper> listQ : mapQuotaAllocations.values()){
            qWrapperListToSave.addAll(listQ);
        }
        
        System.debug('**** qAllocationSaveList  **** ' + qWrapperListToSave);
        System.debug('**** qAllocationOldMap **** ' +    qAllocationOldMap );
        
        
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
        
        System.debug('**** qAllocationSaveList **** ' + qAllocationSaveList);
        //Updating Quota Allocation values
        if(qAllocationSaveList.size()>0)
        Update qAllocationSaveList;
        
        //Updating Quota User History (first record)
        //if(qAllocationUserWrapper[0].qHistoryCurrentRec!=null)
        //Update qAllocationUserWrapper[0].qHistoryCurrentRec;
        
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
        For( Quota_Allocation__c qAllocation : [ Select Id,Is_Approved__c From Quota_Allocation__c Where ID IN: qaIdsForApproval ]){
            
            
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
        
        
        //If any of the Quotas needs to be created
        SaveNewQuota();
        
        //initializeQuotaData();
        return null;
        
        
    }
    
    
    //List of QuotaWrapper to Add New Quota
    List<QuotaWrapper> newQuotaWrapperList = new List<QuotaWrapper>();
    @testvisible
    List<Quota_Allocation__c> newQuotaInsertList = new List<Quota_Allocation__c>();
    List<QuotaWrapper> listQuotaWrapper;     
    
    //Add New Quota for User 
    public void AddNewQuota(){
    
       string quotaRole='';  
        
       System.Debug('***** userIdForNewQuota ****** ' + userIdForNewQuota);
       
       isNewQuotaAdded = true;
       
       //User details for New Quota Allocation
       User usr = selectedUserMap.Get(userIdForNewQuota);
       if(usr!=null)
       quotaRole =  usr.UserRole.Name;
       
       //Populating Quota types based on Product and Role
       String query = 'SELECT Name FROM Quota__c WHERE SF_Role__c =: quotaRole Order by name ' ;
       //=: quotaRole Order by name ' ;
       // LIKE \'%'  + quotaRole + '%\'' +' order by name';
       SelectOption[] qTypes = new SelectOption[]{};
    
       for (Quota__c q : Database.Query(query)) {  
            qTypes.add(new SelectOption(q.id, q.name ));  
        } 
        
       System.Debug('***** Database.Query(query) ****** ' + Database.Query(query));
       System.Debug('***** qTypes ****** ' +  quotaRole);
       
       Quota_Allocation__c qAllocation = new Quota_Allocation__c();
       
       //Setting Submitter Email for Notification in Email Alert 
       qAllocation.Submitter_Email__c = UserInfo.getUserEmail();
                
                
       qAllocation.Year__c = currentYear;
       qAllocation.User__c = userIdForNewQuota;
       
       //List of Quota for New Quota User
       listQuotaWrapper = mapQuotaAllocations.get(usr);
       
       //Adding New Row to Existing List of Quota 
       //listQuotaWrapper.Add(listQuotaWrapper.size()-1, new QuotaWrapper(qAllocation) );
       
       QuotaWrapper qwrapper =new QuotaWrapper(qAllocation);
       if(qTypes.size()>0)
       qwrapper.quotaTypes = qTypes;
       
       mapQuotaAllocations.get(usr).Add(listQuotaWrapper.size()-1, qwrapper );
       
       newQuotaInsertList.Add(qAllocation);
      
       System.Debug('***** rowNum ADD ****** ' + rowNum);
       System.Debug('***** mapQuotaAllocations ADD ****** ' + mapQuotaAllocations.values());
       System.Debug('***** newQuotaWrapperList ADD ****** ' + newQuotaWrapperList);
       
    }
    
    //Delete Quota 
    public void DeleteRow(){
        
        
        
        rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
        
        System.Debug('***** rowNum DELETE   ****** ' + rowNum);  
        
        //newQuotaWrapperList.remove(rowNum);
        
        System.Debug('***** newQuotaWrapperList DELETE  ****** ' + newQuotaWrapperList);
        System.Debug('***** listQuotaWrapper    DELETE  ****** ' + listQuotaWrapper);
        System.Debug('***** qAllocationUserWrapper ADD ****** ' + qAllocationUserWrapper);
        
        initializeQuotaData();
    
    }
    
    public void SaveNewQuota(){
        
        System.Debug('***** newQuotaInsertList ****** ' + newQuotaInsertList);
        List<Approval.ProcessSubmitRequest> ApprovalRequests = new List<Approval.ProcessSubmitRequest>();
        if(newQuotaInsertList!=null && newQuotaInsertList.size()>0){
            insert newQuotaInsertList;
        }
        
        //Processing for Approval
        for(Quota_Allocation__c q :  newQuotaInsertList){
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
        
        newQuotaInsertList.clear();
        initializeQuotaData();
    
    }
    
    
    /*
    //Delete Existing Quota  (Ashley asked to off delete function)
    public void DeleteQuota(){
        
        System.Debug('***** quotaDeleteId ****** ' + quotaDeleteId);
        
        //Setting a flag Is_Deleted__c= False on Quota Allocation
        Quota_Allocation__c qAllocation = new Quota_Allocation__c( Id =quotaDeleteId ,  Is_Deleted__c= true); 
        Update qAllocation;
        
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Deleted Sucessfully'));
        
        initializeQuotaData();
       
    }
     */
    
    //Quota Type Picklist Values
    /* public SelectOption[] getQuotaTypes() {  
        SelectOption[] qTypes = new SelectOption[]{};  
        for (Quota__c q : [select id, name from Quota__c where isdeleted = false order by name]) {  
            qTypes.add(new SelectOption(q.id, q.name ));  
        }  
        return qTypes;  
    }
    */
    
    
    //Redirect to User Selection page.
    public PageReference Cancel(){
        PageReference pgRef = Page.QuotaAllocation_User_Selection_Page ;
        pgRef.setRedirect(true);
        return pgRef;
    } 
    
    //User Id Selected for Viewing Quota
    public Id qUserId {get;set;}
    //Redirect to User Selection page.
    public PageReference RedirectToQuota(){
        
        //Settting Cookie to View Quota Info for Downwards People in The Hierarchy
        Cookie cookie=new Cookie('allowedToView','Yes',null,2,true);
        
        PageReference pgRef = Page.QuotaAllocation_Single_User_ViewPage ;
        pgRef.getParameters().put('uid',qUserId);
        pgRef.setCookies(new Cookie[]{cookie});
        pgRef.setRedirect(true);
        return pgRef;
    } 
    
    
    //Intialize Quotas for Displaying on Page 
    public void initializeQuotaData(){
        //selectedUserIds = new Set<ID>();
        //selectedUserIds.Add('005o0000002jzhH');
        //selectedUserIds.Add('005o0000002jzhM');
        
        //Filling User Map
        selectedUserMap = new Map<Id,User>([Select Id, EmployeeNumber, FirstName, LastName, Sales_Rep_Tier__c,
        LastModifiedBy.Id, LastModifiedBy.Name, LastModifiedDate, CreatedBy.Id, CreatedBy.Name, CreatedDate, Title, UserRoleId, UserRole.Name From User Where ID IN: selectedUserIds ]);
        
        
        //SOQL Query
        String  quotaQuery = 'Select Id,User__c,Year__c,Quota_Type__r.Name,Quota_Type__c,Amount_for_Jan__c,Old_Amount_for_Jan__c,Amount_for_Feb__c,Old_Amount_for_Feb__c,Amount_for_Mar__c,Old_Amount_for_Mar__c , ' + 
                                                  'Amount_for_Apr__c, Old_Amount_for_Apr__c ,Old_Amount_for_May__c,Old_Amount_for_June__c,Old_Amount_for_July__c,Old_Amount_for_Aug__c,Old_Amount_for_Sept__c , ' +
                                                  'Old_Amount_for_Oct__c , Old_Amount_for_Nov__c,Old_Amount_for_Dec__c , '+
                                                  'Amount_for_May__c,Amount_for_June__c, Amount_for_July__c,Amount_for_Aug__c,Amount_for_Sept__c,' +
                                                  'Amount_for_Oct__c,Amount_for_Nov__c,Amount_for_Dec__c  From Quota_Allocation__c Where Is_Deleted__c!=True And User__c IN: selectedUserIds And '  +  
                                                  'Is_Apporved_New__c = TRUE and Year__c =: currentYear order by Year__c,Quota_Type__r.Name ASC';
                                                  
                                                  
        String aggregateQuotaQuery = 'Select User__c, SUM(Amount_for_Jan__c) Jan,SUM(Amount_for_Feb__c) Feb,SUM(Amount_for_Mar__c) Mar,SUM(Amount_for_Apr__c) Apr,SUM(Amount_for_May__c) May,'+
                                                    'SUM(Amount_for_June__c) June,SUM(Amount_for_July__c) July,SUM(Amount_for_Aug__c) Aug,SUM(Amount_for_Sept__c) Sept,SUM(Amount_for_Oct__c) Oct,'+
                                                    'SUM(Amount_for_Nov__c) Nov ,SUM(Amount_for_Dec__c) Dec, Count(Quota_Type__r.Name)'+ 
                                                    'From Quota_Allocation__c Where Is_Deleted__c!=True And User__c IN: selectedUserIds And '  +  
                                                    'Is_Apporved_New__c = TRUE and Year__c =: currentYear ' +
                                                    'Group by User__c ';                                         
                                            
        System.debug(' *********** quotaQuery ************** ' + quotaQuery);
        
        //Populating Map for Monthly SUM for Each User
        mapUserMonthlyTotal = new Map<Id,AggregateResult>();
        For ( AggregateResult aResult :  Database.Query(aggregateQuotaQuery) )
        {
            mapUserMonthlyTotal.Put( (Id)(aResult.Get('User__c')), aResult );
        }

        mapQuotaAllocations = new Map<User, List<QuotaWrapper>>();
        //List of Quota Monthly Amount
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
                
                
                User usr = selectedUserMap.Get(qAllocation.User__c);
                
                If( mapQuotaAllocations.containsKey(usr) ){
                    mapQuotaAllocations.get(usr).Add(new QuotaWrapper(qAllocation.Quota_Type__r.Name, monthAmounts , qAllocation));
                }
                
                else{
                    mapQuotaAllocations.put(usr, new List<QuotaWrapper>{new QuotaWrapper(qAllocation.Quota_Type__r.Name, monthAmounts , qAllocation)}); 
                }  
                                                 
        }
        
            string roleName;
            string product;
            
            //Quota User History For Each User (Key = USerID, Value= User History)
            Map<Id,Quota_User_History__c> qHistoryMap = new Map<Id,Quota_User_History__c>();
            
            //Getting Quota User History current record from updating user
            for( Quota_User_History__c q : [ Select Id , Direct_Manager__c, User__r.UserRole.Name, Sales_Team_Members__c,
                                                Effective_Date__c, DS__c , Is_Current__c, User__c, Role__c ,  Title__c  
                                                From Quota_User_History__c Where User__c IN: selectedUserIds and Is_Current__c= True ]){
                qHistoryMap.put(q.User__c, q);  
            }
        
            qAllocationUserWrapper = new List<QuotaAllocationUserWrapper>();
        
            for( User usr : mapQuotaAllocations.KeySet() ){
            
                
                //Adding Row for Monthly Sum for Each User in quota allocation
                mapQuotaAllocations.Get(usr).Add(new QuotaWrapper('Monthly Total', CalculateMonthlySumOfQuota(usr.Id) , null));
                
                if( usr.UserRole.Name!=null){
                    roleName = usr.UserRole.Name.substringBeforeLast('(');
                    product = usr.UserRole.Name.substringAfterLast('(').RemoveEnd(')');
                }
                //Initializing User Results
                UserWrapper uWrapper = new UserWrapper(usr,roleName,product);
            
                qAllocationUserWrapper.add( new  QuotaAllocationUserWrapper(  uWrapper , qHistoryMap.Get(usr.Id), mapQuotaAllocations.Get(usr) ));
                
                System.debug('Last Index *******   '  +  mapQuotaAllocations.Get(usr).get(mapQuotaAllocations.Get(usr).size()-1));
            }   
        
        
       
    }
    
    
    //Wrapper Class for Managing list of Quotas
    public class QuotaWrapper {
        
        public String quotaName {get; set;}
        public Quota_Allocation__c qAllocationObj {get; set;}
        public List<Decimal> monthsAmount {get; set;}
        
        //Variables used for Adding New Quota
        public boolean isNewQuota {get; set;}
        public Integer rowNum {get; set;}
        public SelectOption[] quotaTypes {get;set;}
        
        //Constructor for Exisiting Quota
        public QuotaWrapper(String name0, List<Decimal> monthsAmount0 , Quota_Allocation__c qAllocationObj0){
            
            isNewQuota      = false;
            quotaName       = name0;
            monthsAmount    = monthsAmount0;
            qAllocationObj  = qAllocationObj0 ;
        }
        
        //Constructor for New Quota
        public QuotaWrapper(Quota_Allocation__c qAllocationObj0 ){
           
            isNewQuota      = true;
            qAllocationObj  = qAllocationObj0 ;
            
        }
       
           
        public Decimal getTotalAmount(){
            Decimal total = 0;
            
            if(monthsAmount==null){
                total = 0 ;
            }
            else{
                for(Decimal val: monthsAmount){
                    total = total + val;
                } 
            }
            return total;
        }        
        
    } 
    
    //Wrapper class to bind list of Quotas per user
    public class QuotaAllocationUserWrapper{
        
        public Quota_User_History__c qHistoryCurrentRec {get;set;}
        public UserWrapper uWrapper {get;set;}
        public List<QuotaWrapper> qWrapperList {get;set;}
        
        public QuotaAllocationUserWrapper(  UserWrapper uWrapper0, Quota_User_History__c qHistoryCurrentRec0, List<QuotaWrapper> qWrapperList0 ){         
            uWrapper= uWrapper0; 
            qHistoryCurrentRec= qHistoryCurrentRec0 ; 
            qWrapperList= qWrapperList0 ;               
        }
        
        public QuotaAllocationUserWrapper(List<QuotaWrapper> qWrapperList0 ){         
            qWrapperList= qWrapperList0 ;               
        }
    }
    
    
    //**** END BULK UPDATING FOR QUOTA ALLOCATIONS *******//
    
    
    
    
}