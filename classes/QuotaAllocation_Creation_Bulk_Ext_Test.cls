@isTest
Public Class QuotaAllocation_Creation_Bulk_Ext_Test{
// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 02/03/2016
// Class : QuotaAllocation_Creation_Bulk_Extension
// SPECIAL NOTES:
// ===============================
// Change History:
//
//==================================
    static ApexPages.StandardController contr;
    static string currentUserRole='' ;
    @testsetup
    public static void createquota(){


    currentUserRole = [Select Name From UserRole where Id=: UserInfo.getUserRoleId()].Name;
    
    //Inserting Quota Type
    Quota__c qType = new Quota__c();
    qType.Name = 'NBB Quota';
    qType.Comments__c = 'Test Comments';
    qType.SF_Role__c = currentUserRole;
    Insert qType;
    
    
    //Inserting Quota Allocations
    Quota_Allocation__c qAllocation  = new Quota_Allocation__c ();
    qAllocation.Amount_for_Jan__c       = 6558; 
    qAllocation.Amount_for_Feb__c       = 5465;
    qAllocation.Amount_for_Mar__c       = 3545;
    qAllocation.Amount_for_Apr__c       = 3244;
    qAllocation.Amount_for_May__c       = 6544;
    qAllocation.Amount_for_June__c       = 2214;
    qAllocation.Amount_for_July__c       = 7988;
    qAllocation.Amount_for_Aug__c       = 6547;
    qAllocation.Amount_for_Sept__c       = 8987;
    qAllocation.Amount_for_Oct__c       = 1324;
    qAllocation.Amount_for_Nov__c       = 2146;
    qAllocation.Amount_for_Dec__c       = 6544;
    qAllocation.User__c                 = UserInfo.getUserId();
    qAllocation.Quota_Type__c           = qType.Id;
    qAllocation.Sales_Team_Members__c   = 'Hemant Rana (Sops)';
    qAllocation.Product_Team__c         = 'Event';
    qAllocation.Role_Name__c            = 'Salesforce Developer T2';
    qAllocation.Is_Apporved_New__c      = true;
    qAllocation.Is_Approved__c          = true;
    
    Insert qAllocation;
    
    User u = [Select Profile.Name , UserRole.Name from User Where ID =: UserInfo.GetUserId()];
    
    Quota_Management_Securtity_Setting__c custSetting = new Quota_Management_Securtity_Setting__c ();
    custSetting.Name = 'Test123';
    custSetting.Profile_Name__c = u.Profile.Name ;
    custSetting.Role__c = u.UserRole.Name ;
    custSetting.Permission__c = 'Read/Write';
    insert custsetting ;
    
    
    contr = new ApexPages.StandardController(qAllocation);
    }
    
    
    public static testmethod void insertNewQuota(){
        
        
        //Inserting Quota Type
        Quota__c qType2 = new Quota__c();
        qType2.Name = 'Power Score Quota';
        qType2.Comments__c = 'Test Comments';
        qType2.SF_Role__c = currentUserRole;
        Insert qType2;
        
    
        //Getting Allocation Record Created in Setup method
        Quota_Allocation__c qAllocation = [Select Id,Quota_Type__c,User__c From Quota_Allocation__c Limit 1 ];
        
        //Creating instance of Extension Class
        QuotaAllocation_Creation_Bulk_Extension qExt = new QuotaAllocation_Creation_Bulk_Extension(contr);
       
        //Creating instance of Wrapper Class of Extension
        QuotaAllocation_Creation_Bulk_Extension.QuotaAllocationWrapper qwrapper = new  QuotaAllocation_Creation_Bulk_Extension.QuotaAllocationWrapper (2);
        qwrapper.qAllocation = new Quota_Allocation__c(User__c= UserInfo.getUserId(), Quota_Type__c = qType2.Id);
        
        //Setting Wrapper List to Extension for Saving Records
        qExt.wrappers =  new List<QuotaAllocation_Creation_Bulk_Extension.QuotaAllocationWrapper>{qwrapper};      

        //Calling all methods
        qExt.addRows();
        qExt.RefereshQuotas();
        qExt.delWrapper();
        qExt.addRows();
        qExt.RefereshQuotas();
        qExt.CheckPermission();
        qExt.Save();
                 
    }
    //For Class Quota_DirectSales_Team_LookupController
    public static testmethod void SalesTeamLookupController(){
       
        
       
        UserRole role = [SELECT Id from UserRole Where Name like '%Direct Sales%' Limit 1]; 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'quser', Email='quotauserxyz@gmail.com', 
                          EmailEncodingKey='UTF-8', FirstName = 'QuotaUser', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId=role.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='quotauserxyz@sales.com');
       insert u;
        
       Quota_DirectSales_Team_LookupController qLookupContr = new Quota_DirectSales_Team_LookupController();
      
       qLookupContr.searchText = '';
        
       qLookupContr.search();
        
       qLookupContr.contextItem = u.Id;
       qLookupContr.doSelectItem();
       qLookupContr.go();
       qLookupContr.getSelectedCount();
       qLookupContr.doDeselectItem();
       
       
       qLookupContr.getHasNext();
       qLookupContr.doNext();
       qLookupContr.getHasPrevious();
       qLookupContr.doPrevious(); 
       qLookupContr.getPageNumber();
       qLookupContr.getTotalPages();
        
       test.startTest();

     
       
       
                 
    }
            
        
}