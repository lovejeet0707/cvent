@isTest
    public class RegOnlineDataMigrationTestClass{
  //Test method for CreateNewCase_Class Class
    static testMethod void unitMethod(){
        //Inserting Custom Setting....
        Cvent_Category_Mapping__c categoryMapping = new Cvent_Category_Mapping__c();
        categoryMapping.Name = 'Test';
        categoryMapping.OwnerId__c = '00G00000006vs24';
        categoryMapping.Product__c= 'CrowdCompass';
        categoryMapping.RecordType_Id__c = '0120000000099RT';
        insert categoryMapping;
        
        //Setting Page Name.....
        PageReference pageref = Page.RegOnlineDataMigrationPages;
        Test.setCurrentPage(pageRef);
        //Setting Parameter..........
        System.currentPageReference().getParameters().put('Subject', 'test subject');
        //Create Case Deflection record......
        Case_Deflection_Track__c caseDeflectTrack = new Case_Deflection_Track__c();
        caseDeflectTrack.No_I_found_my_Answer_Count__c = 1;
        insert caseDeflectTrack;
        
        //Calling Class.....
        RegOnlineDataMigrationClass controller = new RegOnlineDataMigrationClass();
        controller.save();
        //Calling method.....
        //Insert Account...
        Account accRec = new Account();
        accRec.name = 'Test Account';
        //accRec.BillingCountry ='India';
        accRec.BillingCountryCode ='IN';
        insert accRec;
        
        //Insert Contact......
        Contact conRec = new Contact();
        conRec.AccountId = accRec.id;
        conRec.LastName = 'test';
        insert conRec;
        
        User_Contact_Relation__c ucr = new User_Contact_Relation__c();
        ucr.User__c = Userinfo.getUserId();
        ucr.Related_Contact__c = conRec.Id;
        ucr.sfxId__c = 'NIK16514344';
        insert ucr;
     
        controller = new RegOnlineDataMigrationClass();
        controller.save();
    }
    }