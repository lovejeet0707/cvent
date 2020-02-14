public class UserTriggerHandler{

// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 02/03/2016
// PURPOSE     :  To handle user trigger methods
// TEST CLASS :   UserTriggerHandler_Test
// SPECIAL NOTES:
// ===============================
// Change History:
// HSR : 30th Jan 2018 : Removing Package License for Inactive User
// HSR : 30th Jan 2018 : Updating fields for Inactive User
// ===============================
    
    
    //Before Insert
    public void OnBeforeInsert( List<User> newValues ){
      set<id> accIdSet = new set<id>();
      list<Mobile_Card__c> mobCardList = new list<Mobile_Card__c> ();
      map<id,List<Mobile_Card__c>> mapOfMobileCards = new map<id,List<Mobile_Card__c>>();
      //set<id> accountIds = new set<id>();// account Ids for docebo
      //fetch all the users with profile 'Cvent Customer Community User'....
      Profile profileRec = [SELECT Id FROM Profile WHERE Name = 'Cvent Customer Community User'];
      for(user u : newValues){
         if(u.ProfileId==profileRec.Id){
             accIdSet.add(u.Account_Id_Dev__c);
         }
         if(u.FederationIdentifier != NULL && u.UserType != 'Standard' && Boolean.ValueOf(Label.EnablePortalProfile) && u.Profile.UserLicense.Name == 'Customer Community Login'){ //added for Validations required around Portal Users in SF - TICCM - 154
            u.ProfileId=profileRec.id;
         }
         //Added by Udita to populate contact Id for Docebo : 4/15/2019
        /* if(u.ContactId != null && Boolean.ValueOf(Label.IsDoceboCodeActive)){
             u.Contact_ID__c = String.ValueOf(u.ContactId);
             accountIds.add(u.Account_Id_Dev__c);
         }*/
       } 
       // Code for docebo : Udita
      /* if(accountIds.size() > 0 && Boolean.ValueOf(Label.IsDoceboCodeActive)){
          Map<Id,String> accIdMap = new Map<Id,String>();      
          for(Account acc : [select id,Product_Mix__c from account where id in : accountIds AND Product_Mix__c != NULL ]){
            accIdMap.put(acc.id,acc.Product_Mix__c);
          } 
          for(User u : newValues){
             if(u.ContactId != null && accIdMap.containsKey(u.Account_Id_Dev__c)){
                u.LMS_Groups__c  = accIdMap.get(u.Account_Id_Dev__c);
                /***************TICBP-74**************/
               // u.LMS_Sync_Date__c = System.today();
             //}
          //}
      //} */
    }
    
    public void OnAfterInsert( Map<Id,User> newMap){     
     // Added by Udita : To populate user ID & Profile name on user level : P-005084
      List<Contact> conList = new List<Contact>();   
      for(User u : newMap.values()){
         if(u.ContactId != NULL){
           Contact con = new Contact(id=u.ContactId);
           con.User_ID_SU4__c = String.ValueOf(u.id);
           con.User_Profile_Name__c = u.Profile_Name__c;
           conList.add(con);}}if(conList.size() >0){
           update conList;
           }
    }
    
    //Before Update
    public void OnBeforeUpdate( Map<Id,User> newMap , Map<Id,User> oldMap ){
        /*HSR : 30th Jan 2018 : Updating fields for Inactive User */
        if(Label.IsRemoveLicensePackage=='True')
            updateInactiveuserFields(newMap , oldMap);
            
          /* udita: for marking user GDPR */
        User oldUserValue;
        set<id> uIds = new set<id>();
        Profile profileRec = [SELECT Id FROM Profile WHERE Name = 'Cvent Customer Community User'];
        For(User userObj : newMap.values())
        {  
            oldUserValue = oldMap.get(userObj.Id);
            if(userObj.Is_GDPR__c && userObj.Is_GDPR__c != oldUserValue.Is_GDPR__c)
            {
            userObj.FirstName = 'GDPR First Name';            userObj.LastName = 'GDPR Last Name';            userObj.Email = 'GDPR@GDPR.com';            userObj.Phone = '';            userObj.UserName= 'GDPR@GDPR.com'+Math.Random();            userObj.MobilePhone = '';            userObj.Title= 'GDPR';
            }
            
            //added for Validations required around Portal Users in SF - TICCM - 154 : Udita
            if(userObj.IsActive == FALSE && userObj.IsActive != oldMap.get(userObj.id).IsActive && (userObj.IsPortalEnabled || userObj.FederationIdentifier != null) && Boolean.ValueOf(Label.EnablePortalProfile)){
                //userObj.IsPortalEnabled  = false;   
              //  userObj.FederationIdentifier = null;   
              uIds.add(userObj.id);
            } 
            if((userObj.FederationIdentifier != NULL || (userObj.FederationIdentifier !=  oldMap.get(userObj.id).FederationIdentifier)) && userObj.IsPortalEnabled== TRUE && Boolean.ValueOf(Label.EnablePortalProfile) && userObj.Profile.UserLicense.Name == 'Customer Community Login'){ //added for Validations required around Portal Users in SF - TICCM - 154
                 userObj.ProfileId=profileRec.id;
            }                       
        }
        if(uIds.size() > 0 && Boolean.ValueOf(Label.EnablePortalProfile) && !System.isBatch()){
          blankContactFedID(uIds);
        }
       /*GDPR code ends*/  
    }
    //After Update    
    public void OnAfterUpdate( Map<Id,User> newMap , Map<Id,User> oldMap ){
           
        Set<ID> userIds = new Set<ID>();
        
        MAP<ID,MAP<string,set<id>>> mobileCardVsRecType= new MAP<ID,MAP<string,set<id>>>() ;
        for( User u : [ Select Id, UserRole.Name, Title From User Where ID IN: newMap.values() and isActive=true ] ){
            userIds.add(u.Id);                    
        }
        if(userIds.size()>0 && System.IsBatch() == false && System.isFuture() == false) //System.isFuture() == false added by udita for executing GDPRCentralRepositoryHandler class
            CreateHistoryForExistingUser(userIds);   
        /*HSR : 30th Jan 2018 : Removing Package License for Inactive User */
        if(Label.IsRemoveLicensePackage=='True')
            removePackageLicense(newMap,oldMap);
            
       
       Set<Id> User_Ids = new Set<Id>(); //Udita : P-005084
       set<id> userIds_Inactive = new Set<Id>(); //Udita : P-005084
       for(user u : newMap.values()){
           // Added by Udita : To populate user ID & Profile name on user level : P-005084             
             if((u.Profile_Name__c != null && u.Profile_Name__c != oldMap.get(u.id).Profile_Name__c)  || (u.Vishal__c == True && u.Vishal__c  != oldMap.get(u.id).Vishal__c )){
                User_Ids.add(u.id);              
             } 
             if(u.IsActive == FALSE && u.IsActive != oldMap.get(u.id).IsActive){
                userIds_Inactive.add(u.id);              
             }                    
          //Ends 
      }           
      if(User_Ids.size()>0 && System.IsBatch() == false && System.isFuture() == false && Boolean.ValueOf(Label.UpdateContactProfileId)){
         UpdateContactProfileId(User_Ids,NULL);
      }
      if(userIds_Inactive.size()>0 && System.IsBatch() == false && System.isFuture() == false && Boolean.ValueOf(Label.UpdateContactProfileId)){
         UpdateContactProfileId(NULL,userIds_Inactive);
      }
      // code ends        
    }
    
    
       /* METHODS */
    
    //Method to Insert Quota History If Existing User Role/Title/EffectiveDate is changed
    @future(Callout=true)
    public static void CreateHistoryForExistingUser(Set<Id> uIds){
    
        List<Quota_User_History__c> qHistoryUpdateList = new List<Quota_User_History__c>();
        Map<Id,Quota_User_History__c> qHistoryMap = new Map<Id,Quota_User_History__c>();
        
        //Getting Quota User History current record from updating user
        for( Quota_User_History__c q : [ Select Id , Is_Current__c, User__c, Role__c ,  Title__c  From Quota_User_History__c Where User__c IN: uIds and Is_Current__c= True ]){
            qHistoryMap.put(q.User__c, q);  
        }
        
        
        for( User u : [ Select UserRole.Name, Title From User Where ID IN: uIds ] ){
            
            Quota_User_History__c qUserExist = qHistoryMap.Get(u.Id);
            
            //if updating user is exist in Quota User History table 
            if( qUserExist!=null ){
                 qUserExist.Role__c = u.UserRole.Name ;
                 qUserExist.Title__c =  u.Title ;
                 qHistoryUpdateList.Add(qUserExist);
            }
            
            system.debug('******* qHistoryUpdateList ***** ' + qHistoryUpdateList);
            if(qHistoryUpdateList.size()>0)
            Update qHistoryUpdateList;
        }
        
    }
    
    /*HSR : 30th Jan 2018 : Updating fields for Inactive User */
    public static void updateInactiveuserFields(Map<Id,User> newMap , Map<Id,User> oldMap){
        User oldUserValue;
        For(User userObj : newMap.values())
        {
            oldUserValue = oldMap.get(userObj.Id);
            if(!userObj.IsActive && userObj.IsActive!=oldUserValue.IsActive)
            {
                userObj.UserPermissionsAvantgoUser            = false;    
                userObj.UserPermissionsCallCenterAutoLogin    = false;
                userObj.UserPermissionsChatterAnswersUser     = false;
                userObj.UserPermissionsInteractionUser        = false;
            //    userObj.UserPermissionsJigsawProspectingUser  = false;  Commented by Lovejeeet Singh on 01/31/2020 as Data.Com has been retired by Salesforce
                userObj.UserPermissionsKnowledgeUser          = false;
                userObj.UserPermissionsLiveAgentUser          = false;
                userObj.UserPermissionsMarketingUser          = false;
                userObj.UserPermissionsMobileUser             = false;
                userObj.UserPermissionsOfflineUser            = false;
                userObj.UserPermissionsSFContentUser          = false;
                userObj.UserPermissionsSupportUser            = false;
                userObj.UserPermissionsWorkDotComUserFeature  = false;
            }
        }
    }
    /*HSR : 30th Jan 2018 : Removing Package License for Inactive User */
    public static void removePackageLicense(Map<Id,User> newMap , Map<Id,User> oldMap){
        List<User> listOfInactiveUser=new List<User>();   //  create list to update user instead of update Inactiveuser as if we update Inactiveuser ,it will not reflect any change.
        User oldUserValue;
        For(User userObj : newMap.values())
        {
            oldUserValue = oldMap.get(userObj.Id);
            if(!userObj.IsActive && userObj.IsActive!=oldUserValue.IsActive)
            {
                listOfInactiveUser.add(userObj);
            }
        }
        //Delete Assigned Licenses for Managed Packages
        if(listOfInactiveUser.size()>0){
            List<UserPackageLicense> assignedLicenseList = [ Select Id From UserPackageLicense Where UserId IN: listOfInactiveUser ];
            if(assignedLicenseList.size()>0)
                delete assignedLicenseList;
        }
    }
        
    @future(Callout=true)
    public static void UpdateContactProfileId(Set<Id> uIds,Set<Id> userIds_Inactive){
       List<Contact> conList =  new List<Contact>();
       for( User u : [Select Profile_Name__c,ContactId,IsActive From User Where ID IN: uIds OR ID IN : userIds_Inactive] ){
         if(uIds!= NULL){
          if(uIds.size()> 0 && uIds.contains(u.id) && u.ContactId != null){              Contact con = new Contact(id=u.ContactId);              con.User_ID_SU4__c = String.ValueOf(u.id);              con.User_Profile_Name__c = u.Profile_Name__c;              conList.add(con);}}
         if(userIds_Inactive!=NULL){     
          if(userIds_Inactive.size()> 0 && userIds_Inactive.contains(u.id) && u.ContactId != null){
              Contact con = new Contact(id=u.ContactId);              con.User_ID_SU4__c = NULL;              con.User_Profile_Name__c = NULL;              conList.add(con);
          }}
       }
            
       if(conList.size() >0){
         upsert conList;
       }
        
    }
    //added for Validations required around Portal Users in SF - TICCM - 154 : Udita
     @future(Callout=true)
     public static void blankContactFedID(Set<Id> uIds){
       list<user> userList= new list<user>();
          for(id uid:uIds){
            user u = new user(id= uid);
            u.IsPortalEnabled  = false; 
            userList.add(u); 
          } 
          if(userList.size() > 0){ 
             update userList;
          }      
      }        
   }