@isTest
Public Class Quota_Allocation_Trigger_Handler_Test{

// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 02/03/2016
// PURPOSE     :  To Test Handler
// TRIGGER :    QuotaAllocationTrigger 
// CLASS : Quota_Allocation_Trigger_Handler
// SPECIAL NOTES:
// ===============================
// Change History:
//
//==================================

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
    
    Insert qAllocation;
    
    }
    
    
    public static testmethod void BeforeUpdateTest(){
        
        Quota_Allocation__c qAllocation = [Select Id From Quota_Allocation__c Limit 1 ];
        
        qAllocation.Is_Existing_Rejected__c  = true;
        Update qAllocation ;
        
        
    }
    
    


}