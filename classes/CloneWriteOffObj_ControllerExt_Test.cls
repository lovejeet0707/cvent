@isTest
public class CloneWriteOffObj_ControllerExt_Test {   
    private Static Account accObj;
    private Static BillingCase__c billCaseObj;
    private Static WriteOff__c WrOffObj;
    private Static final RecordType recType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
    
    //Create new Account Record
    private static Id insertAccount(){
        if(accObj == null){
            accObj = new Account();
            accObj.Name = 'Test';
            accObj.Supplier_Type__c = 'Venue';
            accObj.Venue_Type__c = 'CVB';
            accObj.RecordTypeId = recType.Id;
            insert accObj;
        }            
        return accObj.Id;
    }
    
    //Create new Account Record
    private static Id insertBillingCase(){
        if(billCaseObj == null){
            billCaseObj = new BillingCase__c();
            billCaseObj.CustomersAccount__c = insertAccount();
            billCaseObj.CVII_Number__c = '32323';
            billCaseObj.Name = 'Test';
            insert billCaseObj;
        }            
        return billCaseObj.Id;
    }
    
    //test data setup method
    public static void testData(){   
        //Create new Write-Off Record        
        WrOffObj = new WriteOff__c();
        WrOffObj.Type_of_Cancellation__c = 'Billing Error';
        WrOffObj.Product__c = 'Event';
        WrOffObj.Contract__c = '25512';
        WrOffObj.Write_Off_Status__c = 'Initially Approved';
        WrOffObj.New_TCV_To_Be_Moved__c ='Yes';
        WrOffObj.Total_Contract_Billed__c = 100.00;
        WrOffObj.Total_Tax_Billed__c = 100.00;
        WrOffObj.Total_Overage_Billed__c = 100.00;
        WrOffObj.Office_Location__c = 'Test Location';
        WrOffObj.Shut_Down_Required__c = 'No';
        WrOffObj.Type_of_Shut_Down__c = 'Feature';
        WrOffObj.Contract_Value__c = 38250.0;
        WrOffObj.Total_Paid__c = 12750.0;
        WrOffObj.Amount_to_be_Written_Off__c = 12750.0;
        WrOffObj.Currency_Conversion_Rate__c = 	1.0;
        WrOffObj.Customer_Name__c = insertBillingCase();
        insert WrOffObj;
    }
    // Method tests the "Save" button.
    public static testmethod void insertWriteOffRecPositiveTest(){
        Test.startTest();
        TestData();
        Test.setCurrentPage(Page.CloneWriteOffObj_Page);     
        System.currentPageReference().getParameters().put('id', WrOffObj.Id);         
        // Initialising StandardController Extension
        ApexPages.StandardController sC = new ApexPages.StandardController(WrOffObj);  
        CloneWriteOffObj_ControllerExt clnWrtOffController = new CloneWriteOffObj_ControllerExt(sC);
        WrOffObj = new WriteOff__c();
        WrOffObj.Type_of_Cancellation__c = 'Billing Error';
        WrOffObj.Product__c = 'Event';
        WrOffObj.Contract__c = '25512';
        WrOffObj.Write_Off_Status__c = 'Initially Approved';
        WrOffObj.New_TCV_To_Be_Moved__c ='Yes';
        WrOffObj.Customer_Name__c = insertBillingCase();
        clnWrtOffController.saveWriteOff();
        Test.stopTest();
    }
    // Method tests the "Save & New" button.
    public static testmethod void insertandCreateWriteOffRec(){
        Test.startTest();
        TestData();
        Test.setCurrentPage(Page.CloneWriteOffObj_Page);
        System.currentPageReference().getParameters().put('id', WrOffObj.Id);         
        // Initialising StandardController Extension
        ApexPages.StandardController sC = new ApexPages.StandardController(WrOffObj);  
        CloneWriteOffObj_ControllerExt clnWrtOffController = new CloneWriteOffObj_ControllerExt(sC);
        WrOffObj = new WriteOff__c();
        WrOffObj.Type_of_Cancellation__c = 'Billing Error';
        WrOffObj.Product__c = 'Event';
        WrOffObj.Contract__c = '25512';
        WrOffObj.Write_Off_Status__c = 'Initially Approved';
        WrOffObj.New_TCV_To_Be_Moved__c ='Yes';
        WrOffObj.Customer_Name__c = insertBillingCase();
        clnWrtOffController.saveAndNewWriteOff();
        Test.stopTest();        
    }
    // Negative test for the "Save & New" button.
    public static testmethod void insertWriteOffRecNegativeTest1(){
        Test.startTest();
        TestData();
        Test.setCurrentPage(Page.CloneWriteOffObj_Page);     
        System.currentPageReference().getParameters().put('id', WrOffObj.Id);         
        // Initialising StandardController Extension
        ApexPages.StandardController sC = new ApexPages.StandardController(WrOffObj);  
        CloneWriteOffObj_ControllerExt clnWrtOffController = new CloneWriteOffObj_ControllerExt(sC);
        WrOffObj = new WriteOff__c();
        WrOffObj.Type_of_Cancellation__c = 'Billing Error';
        // WrOffObj.Product__c = 'Event';
        WrOffObj.Contract__c = '25512';
        WrOffObj.Write_Off_Status__c = 'Initially Approved';
        // WrOffObj.New_TCV_To_Be_Moved__c ='Yes';
        WrOffObj.Customer_Name__c = insertBillingCase();
        clnWrtOffController.saveWriteOff();
        clnWrtOffController.saveAndNewWriteOff();
        Test.stopTest();
    }
    // Negative test for the "Save" button.
    public static testmethod void insertWriteOffRecNegativeTest2(){
        Test.startTest();
        TestData();
        Test.setCurrentPage(Page.CloneWriteOffObj_Page);     
        System.currentPageReference().getParameters().put('id', WrOffObj.Id);         
        // Initialising StandardController Extension
        ApexPages.StandardController sC = new ApexPages.StandardController(WrOffObj);  
        CloneWriteOffObj_ControllerExt clnWrtOffController = new CloneWriteOffObj_ControllerExt(sC);
        WrOffObj = new WriteOff__c();
        WrOffObj.Type_of_Cancellation__c = 'Billing Error';
        // WrOffObj.Product__c = 'Event';
        WrOffObj.Contract__c = '25512';
        WrOffObj.Write_Off_Status__c = 'Initially Approved';
        // WrOffObj.New_TCV_To_Be_Moved__c ='Yes';
        WrOffObj.Customer_Name__c = insertBillingCase();
        clnWrtOffController.saveAndNewWriteOff();
        clnWrtOffController.saveWriteOff();
        Test.stopTest();
    }
}