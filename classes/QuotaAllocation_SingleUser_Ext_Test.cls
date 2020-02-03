@isTest
Public Class QuotaAllocation_SingleUser_Ext_Test{
// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 02/03/2016
// Class : QuotaAllocation_SingleUser_ViewExtension
// SPECIAL NOTES:
// ===============================
// Change History:
//
//==================================
    static ApexPages.StandardController contr;
    
    @testsetup
    public static void createquota(){
    
    //Inserting Quota Type
    Quota__c qType = new Quota__c();
    qType.Name = 'NBB Quota';
    qType.Comments__c = 'Test Comments';
    
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
    qAllocation.Year__c                 = String.ValueOf(Date.Today().Year());
    Insert qAllocation;
    /*
    Quota_Allocation__c qAllocation2  = new Quota_Allocation__c ();
    qAllocation2.Amount_for_Jan__c       = 6558; 
    qAllocation2.Amount_for_Feb__c       = 5465;
    qAllocation2.Amount_for_Mar__c       = 3545;
    qAllocation2.Amount_for_Apr__c       = 3244;
    qAllocation2.Amount_for_May__c       = 6544;
    qAllocation2.Amount_for_June__c       = 2214;
    qAllocation2.Amount_for_July__c       = 7988;
    qAllocation2.Amount_for_Aug__c       = 6547;
    qAllocation2.Amount_for_Sept__c       = 8987;
    qAllocation2.Amount_for_Oct__c       = 1324;
    qAllocation2.Amount_for_Nov__c       = 2146;
    qAllocation2.Amount_for_Dec__c       = 6544;
    qAllocation2.User__c                 = UserInfo.getUserId();
    qAllocation2.Quota_Type__c           = qType.Id;
    qAllocation2.Sales_Team_Members__c   = 'Hemant Rana (Sops)';
    qAllocation2.Product_Team__c         = 'C';
    qAllocation2.Role_Name__c            = 'Salesforce Developer T2';
    qAllocation2.Is_Apporved_New__c      = true;
    qAllocation2.Is_Approved__c          = false;
    qAllocation2.Year__c                 = String.ValueOf(Date.Today().Year());
    Insert qAllocation2;
    */
    
    
    User u = [Select Profile.Name , UserRole.Name from User Where ID =: UserInfo.GetUserId()];
    
    Quota_Management_Securtity_Setting__c custSetting = new Quota_Management_Securtity_Setting__c ();
    custSetting.Name = 'Test123';
    custSetting.Profile_Name__c = u.Profile.Name ;
    custSetting.Role__c = u.UserRole.Name ;
    custSetting.Permission__c = 'Read/Write';
    insert custsetting ;
    
    
    contr = new ApexPages.StandardController(qAllocation);
    }
    
    
    public static testmethod void TestForSaving(){
        
        PageReference pgRef = Page.QuotaAllocation_Single_User_ViewPage;
        pgRef.getParameters().put('uid' , userInfo.getUserId());
        Test.setCurrentPage(pgRef);
        
        
        //Getting Allocation Record Created in Setup method
        Quota_Allocation__c qAllocation = [Select Id,Quota_Type__c,User__c From Quota_Allocation__c Limit 1 ];
        
        //Creating instance of Extension Class
        QuotaAllocation_SingleUser_ViewExtension qExt = new QuotaAllocation_SingleUser_ViewExtension(contr);
       
        
        //Calling all methods
        qExt.CheckPermission();
        qExt.initializeQuotaData();
        qExt.doEdit();
        
        //Updating values
        qAllocation.Amount_for_Jan__c       = 3445; 
        qAllocation.Amount_for_Feb__c       = 4444;
        qAllocation.Amount_for_Mar__c       = 2222;
        qAllocation.Amount_for_Apr__c       = 1111;
        qAllocation.Amount_for_May__c       = 1224;
        qAllocation.Amount_for_June__c       = 4566;
        qAllocation.Amount_for_July__c       = 4467;
        qAllocation.Amount_for_Aug__c       = 6677;
        qAllocation.Amount_for_Sept__c       = 6788;
        qAllocation.Amount_for_Oct__c       = 5555;
        qAllocation.Amount_for_Nov__c       = 3321;
        qAllocation.Amount_for_Dec__c       = 2345;     
        
        update qAllocation;
        
        
        

        qExt.doSave();
        
        //qAllocation.Amount_for_Dec__c       = 2345;
        //qAllocation.Is_Approved__c          = false;
        //test.startTest();
        //update qAllocation;
        //test.StopTest();
        
       
        //qExt.doSave();
        
        qExt.getQuotaData_Current_Year();
        qExt.getQuotaData_Previous_1_Year();
        qExt.getQuotaData_Previous_2_Year();
        qExt.getQuotaData_Previous_3_Year();
        qExt.doReferesh();
        qExt.doCancel();
                  
    }
    
    
        
}