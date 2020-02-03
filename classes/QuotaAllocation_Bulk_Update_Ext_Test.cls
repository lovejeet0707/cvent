@isTest
Public Class  QuotaAllocation_Bulk_Update_Ext_Test{
// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 02/03/2016
// Class : QuotaAllocation_Bulk_Update_Extension
// SPECIAL NOTES:
// ===============================
// Change History:
//
//==================================
    static ApexPages.StandardController contr;
    
    static User managedUser ; 
    @testsetup
    public static void createquota(){
    
    
    User u = [Select Profile.Name , UserRole.Name from User Where ID =: UserInfo.GetUserId()];
    
    //inserting User
    System.runAs(u){
        
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        
        managedUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, ManagerId = UserInfo.getUserId(),
        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert managedUser;
    }

    //Creating custom setting data to authorize current user to use Quota application
    Quota_Management_Securtity_Setting__c custSetting = new Quota_Management_Securtity_Setting__c ();
    custSetting.Name = 'Test123';
    custSetting.Profile_Name__c = u.Profile.Name ;
    custSetting.Role__c = u.UserRole.Name ;
    custSetting.Permission__c = 'Read/Write';
    insert custsetting ;
    
    
    //Inserting Quota Type
    Quota__c qType = new Quota__c();
    qType.Name = 'NBB Quota';
    qType.Comments__c = 'Test Comments';
    insert qType;
    
    
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
    qAllocation.User__c                 = managedUser.Id;
    qAllocation.Quota_Type__c           = qType.Id;
    qAllocation.Sales_Team_Members__c   = 'Hemant Rana (Sops)';
    qAllocation.Product_Team__c         = 'Event';
    qAllocation.Role_Name__c            = 'Salesforce Developer T2';
    qAllocation.Is_Apporved_New__c      = true;
    qAllocation.Is_Approved__c          = true;
    qAllocation.Year__c                 = String.ValueOf(Date.Today().Year());
    Insert qAllocation;
   

    contr = new ApexPages.StandardController(qAllocation);
    
    }
    
    
    public static testmethod void TestForSaving1(){
    
        //Inserting Quota Type
        Quota__c qType2 = new Quota__c();
        qType2.Name = 'Power Score Quota';
        qType2.Comments__c = 'Test Comments';
        insert qType2;
        
        PageReference pgRef1 = Page.QuotaAllocation_Bulk_Update_Page;
        pgRef1.getParameters().put('index' , '1');
        Test.setCurrentPage(pgRef1);
        
        
        
        //Getting Allocation Record Created in Setup method
        Quota_Allocation__c qAllocation = [Select Id, Amount_for_Jan__c, Amount_for_Feb__c, Amount_for_Mar__c, Quota_Type__c,Quota_Type__r.Name, User__c From Quota_Allocation__c Limit 1 ];
        
        Quota_Allocation__c qAllocationCloned = qAllocation.clone(true,true,true,true);
        
        System.debug(   '******* qAllocation ***'  +  qAllocation );
       
        
        //Creating instance of Extension Class
        QuotaAllocation_Bulk_Update_Extension qExt = new QuotaAllocation_Bulk_Update_Extension(contr);
        qExt.TeamOrUsers = 'All Users';

        //Calling all methods
        qExt.CheckPermission();
        
        qExt.getUserResults();
        
        
        if( qExt.userWrappers!=null && qExt.userWrappers.size()>0 ){
            qExt.userWrappers[0].isSelected =true;
        }
        
        
        qExt.ManageAllocations();
        qExt.selectedUserIds.add(qAllocation.User__c);

        
        qExt.RedirectToAllocation();
        qExt.initializeQuotaData();
            
            
        qExt.DeleteRow();
        
        //Updating values
        qAllocationCloned.Quota_Type__c           = qType2.Id;
        qAllocationCloned.Amount_for_Jan__c       = 3445; 
        qAllocationCloned.Amount_for_Feb__c       = 4444;
        qAllocationCloned.Amount_for_Mar__c       = 2222;
        qAllocationCloned.Amount_for_Apr__c       = 1111;
        qAllocationCloned.Amount_for_May__c       = 1224;
        qAllocationCloned.Amount_for_June__c       = 4566;
        qAllocationCloned.Amount_for_July__c       = 4467;
        qAllocationCloned.Amount_for_Aug__c       = 6677;
        qAllocationCloned.Amount_for_Sept__c       = 6788;
        qAllocationCloned.Amount_for_Oct__c       = 5555;
        qAllocationCloned.Amount_for_Nov__c       = 3321;
        qAllocationCloned.Amount_for_Dec__c       = 2345;     
        
        update qAllocationCloned;
        
        System.debug(    '*******  qAllocationCloned *****' + qAllocationCloned );
       
        
        qExt.userIdForNewQuota = qAllocation.User__c ;
        qExt.AddNewQuota();
        
        
        if(qExt.newQuotaInsertList!=null && qExt.newQuotaInsertList.size()>0){
            qExt.newQuotaInsertList.get(0).Quota_Type__c = qAllocation.Quota_Type__c ;
        }
        
        qExt.SaveNewQuota();
        
        qExt.doSave();
        qExt.SelectAll();
        qExt.Cancel();
        
        QuotaAllocation_Bulk_Update_Extension.QuotaWrapper qwrapper = new QuotaAllocation_Bulk_Update_Extension.QuotaWrapper(qAllocationCloned);
        qwrapper.getTotalAmount();
                  
    }
    
    public static testmethod void TestForSaving2(){
        
        PageReference pgRef1 = Page.QuotaAllocation_Bulk_Update_Page;
        pgRef1.getParameters().put('index' , '1');
        Test.setCurrentPage(pgRef1);
        
        
        
        //Getting Allocation Record Created in Setup method
        Quota_Allocation__c qAllocation = [Select Id, Is_Approved__c,Amount_for_Jan__c, Amount_for_Feb__c, Amount_for_Mar__c, Quota_Type__c,Quota_Type__r.Name, User__c From Quota_Allocation__c Limit 1 ];
        qAllocation.Is_Approved__c = false;
        update qAllocation;
        
        Quota_Allocation__c qAllocationCloned = qAllocation.clone(true,true,true,true);
        
        System.debug(   '******* qAllocation ***'  +  qAllocation );
       
        
        //Creating instance of Extension Class
        QuotaAllocation_Bulk_Update_Extension qExt = new QuotaAllocation_Bulk_Update_Extension(contr);
        qExt.TeamOrUsers = 'All Users';
        qExt.userIdForNewQuota = qAllocation.User__c ;
        
        //Calling all methods
        qExt.CheckPermission();
        
        qExt.getUserResults();
        
        
        if( qExt.userWrappers!=null && qExt.userWrappers.size()>0 ){
            qExt.userWrappers[0].isSelected =true;
        }
        
        
        qExt.ManageAllocations();
        qExt.selectedUserIds.add(qAllocation.User__c);

        
        qExt.RedirectToAllocation();
        qExt.initializeQuotaData();
            
            
        qExt.DeleteRow();
        
        //Updating values
        qAllocationCloned.Amount_for_Jan__c       = 3445; 
        qAllocationCloned.Amount_for_Feb__c       = 4444;
        qAllocationCloned.Amount_for_Mar__c       = 2222;
        qAllocationCloned.Amount_for_Apr__c       = 1111;
        qAllocationCloned.Amount_for_May__c       = 1224;
        qAllocationCloned.Amount_for_June__c       = 4566;
        qAllocationCloned.Amount_for_July__c       = 4467;
        qAllocationCloned.Amount_for_Aug__c       = 6677;
        qAllocationCloned.Amount_for_Sept__c       = 6788;
        qAllocationCloned.Amount_for_Oct__c       = 5555;
        qAllocationCloned.Amount_for_Nov__c       = 3321;
        qAllocationCloned.Amount_for_Dec__c       = 2345;     
        
        update qAllocationCloned;
        
        System.debug(    '*******  qAllocationCloned *****' + qAllocationCloned );
        
        qExt.FetchUserData();
        qExt.doNext();
        qExt.doPrevious();
        qExt.RedirectToQuota();
        
        qExt.doSave();
        qExt.SelectAll();
        qExt.Cancel();
                  
    }
    
    public static testmethod void TestForSaving3(){
        
        PageReference pgRef1 = Page.QuotaAllocation_Bulk_Update_Page;
        pgRef1.getParameters().put('index' , '1');
        Test.setCurrentPage(pgRef1);
        
        
        
        //Getting Allocation Record Created in Setup method
        Quota_Allocation__c qAllocation = [Select Id, Is_Approved__c,Amount_for_Jan__c, Amount_for_Feb__c, Amount_for_Mar__c, Quota_Type__c,Quota_Type__r.Name, User__c From Quota_Allocation__c Limit 1 ];
        qAllocation.Is_Approved__c = false;
        update qAllocation;
        
        Quota_Allocation__c qAllocationCloned = qAllocation.clone(true,true,true,true);
        
        System.debug(   '******* qAllocation ***'  +  qAllocation );
       
        
        //Creating instance of Extension Class
        QuotaAllocation_Bulk_Update_Extension qExt = new QuotaAllocation_Bulk_Update_Extension(contr);
        qExt.TeamOrUsers = 'All Users';
        qExt.userIdForNewQuota = qAllocation.User__c ;
        qExt.nameSearchTxt='Testing';
        
        qExt.productSearchTxt='Event';
        qExt.roleSearchTxt='AM';
        
        qExt.qAllocationDelete = qAllocation;
        qExt.quotaDeleteId = qAllocation.Id;
        
        //Calling all methods
        qExt.CheckPermission();
        
        qExt.getUserResults();
        
        
        if( qExt.userWrappers!=null && qExt.userWrappers.size()>0 ){
            qExt.userWrappers[0].isSelected =true;
        }
        
        
        qExt.ManageAllocations();
        qExt.selectedUserIds.add(qAllocation.User__c);

        
        qExt.RedirectToAllocation();
        qExt.initializeQuotaData();
            
      
        
        qExt.FetchUserData();
        qExt.totalPages=15;
        qExt.pageNo=3;
        
        qExt.doNext();
        qExt.doPrevious();
        qExt.RedirectToQuota();
        
        
                  
    }
            
        
}