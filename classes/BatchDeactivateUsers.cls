/*

Desc: Batch class to deactivate users who does not login from last two months .
  */
global class BatchDeactivateUsers implements Database.Batchable<sObject>,Database.Stateful {
    Public String csvContent;
   
    Public string heading='Error Message';

    datetime myDateTime = datetime.now();
    datetime inactiveDateTime = myDateTime.addDays(-30);
    date inactivenewUSerDateTime = system.today().addDays(-15);
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        return Database.getQueryLocator([SELECT Id,name,lastLoginDate ,IsActive,createdDate FROM User WHERE License__c !='Guest User License' AND IsPortalEnabled = false AND isActive = true AND  ( (lastLoginDate=null and createdDate<=:inactivenewUSerDateTime) or lastLoginDate < :inactiveDateTime  ) and Exempted__c=false]);
        

    }
    
    global void execute(Database.BatchableContext BC,List<User> Inactiveuser){
        List<User> listOfInactiveUser=new List<User>();   //  create list to update user instead of update Inactiveuser as if we update Inactiveuser ,it will not reflect any change.
            
        for(User u :Inactiveuser){
               
                u.IsActive=False;
                u.UserPermissionsAvantgoUser            = false;    
                u.UserPermissionsCallCenterAutoLogin    = false;
                u.UserPermissionsChatterAnswersUser     = false;
                u.UserPermissionsInteractionUser        = false;
                u.UserPermissionsJigsawProspectingUser  = false;
                u.UserPermissionsKnowledgeUser          = false;
                u.UserPermissionsLiveAgentUser          = false;
                u.UserPermissionsMarketingUser          = false;
                u.UserPermissionsMobileUser             = false;
                u.UserPermissionsOfflineUser            = false;
                u.UserPermissionsSFContentUser          = false;
                u.UserPermissionsSupportUser            = false;
                u.UserPermissionsWorkDotComUserFeature  = false;
                
                listOfInactiveUser.add(u);
        }

        Database.SaveResult[] srList;
        if(listOfInactiveUser.size()>0)
            srList =  database.update(listOfInactiveUser,false);   //  here use database.update instead of update 

        //Delete Assigned Licenses for Managed Packages
        List<UserPackageLicense> assignedLicenseList = [ Select Id From UserPackageLicense Where UserId IN: listOfInactiveUser ];
        if(assignedLicenseList.size()>0)
            delete assignedLicenseList;
            
       
        
        System.debug('****srList**' + srList);
        
        for(Integer i=0;i<srList.size();i++){

            if (!srList.get(i).isSuccess()){
                // DML operation failed
                Database.Error error = srList.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                srList.get(i);//failed record from the list
                system.debug('Failed ID'+srList.get(i).Id);
                  if(i==0)               
                        csvContent+=heading+'\n'+ error.getMessage()+'USer Id-'+Inactiveuser.get(i).Id;
                  else              
                        csvContent +=+'\n'+ error.getMessage()+'USer Id-'+Inactiveuser.get(i).Id;
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
           
        if(csvContent!=null){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            Blob b=Blob.valueOf(csvContent);
      
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName('attachment.csv');
            efa.setBody(b);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});  
        
            String[] toAddresses = new String[] {UserInfo.getUserEmail()};  
            mail.setToAddresses(toAddresses);  
            mail.setSubject('Deactivate User Failure: ');  
            String body='User deactivate';
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }     
    }
}