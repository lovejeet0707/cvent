@isTest
public class AutoLoginIntegrationTest{
    static testMethod void unitTest(){
        
        KapowCredentials__c kapowCred = new KapowCredentials__c();
        kapowCred.Name = 'Test';
        kapowCred.EndPointURL__c = 'test@test.com';
        kapowCred.LoginPassSecure__c = '1234';
        insert kapowCred;
        
        SocialTableCredentials__c STCred = new SocialTableCredentials__c();
        STCred.Name = 'Test';
        STCred.EndPointURL__c = 'test@test.com';
        STCred.LoginPassSecure__c = '1234';
        insert STCred;
        
        
        QuickMobileCredentials__c QMCred = new QuickMobileCredentials__c();
        QMCred.Name = 'Test';
        QMCred.EndPointURL__c = 'test@test.com';
        QMCred.LoginPassSecure__c = '1234';
        insert QMCred;

        DoubleDutchCredentials__c DDCred = new DoubleDutchCredentials__c();
        DDCred.Name = 'Test';
        DDCred.EndPointURL__c = 'test@test.com';
        DDCred.LoginPassSecure__c = '1234';
        insert DDCred;
        
        WSCredentials__c WSCred = new WSCredentials__c();
        WSCred.Name = 'Test';
        WSCred.EndPointURL__c = 'test@test.com';
        WSCred.LoginPassSecure__c = '1234';
        insert WSCred;
        
        Account accRec = new Account();
        accRec.Name = 'Test Account';
        accRec.Supplier_Type__c = 'Venue';
        accRec.Venue_Type__c = 'CVB';
        accRec.CSN_Status__c ='Using';
        accRec.Supplier_Status__c='Approved';
        accRec.BillingCountryCode='US';
        accRec.BillingStateCode='TX';
        insert accRec;
        
        Acquisition__c acquisitionObj= new Acquisition__c();
        acquisitionObj.Account__c = accRec.Id;
        acquisitionObj.Account_Owner_for_Acquired_Org__c ='Test Owner';
        acquisitionObj.Account_Type_for_Aquired_Org__c = 'Prospect';
        acquisitionObj.Company_Name__c = 'QuickMobile';
        acquisitionObj.Migrated_Record_ID__c = String.valueOf(accRec.Id);
        acquisitionObj.Migrated_Record__c = 'Migrated';
        
        insert acquisitionObj;
        
        /*KAPOW*/
        PageReference pageRef = Page.Link_to_A_Kapow;
        pageRef.getParameters().put('id', acquisitionObj.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acquisitionObj);
        AutoLogin_AKapow autoLoginKapow= new AutoLogin_AKapow(sc);
        
        autoLoginKapow.OpenKapowAccount();
        /*ENDS HERE*/
        
        /*SOCIAL TABLES*/
        pageRef = Page.Link_to_AST;
        pageRef.getParameters().put('id', acquisitionObj.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController ST = new ApexPages.StandardController(acquisitionObj);
        AutoLogin_AST autoLoginST= new AutoLogin_AST(ST);
        
        autoLoginST.OpenSTAccount();
        /*ENDS HERE*/
        
        /*Quick Mobile*/
        pageRef = Page.Quick_Mobile_Link;
        pageRef.getParameters().put('id', acquisitionObj.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController QM = new ApexPages.StandardController(acquisitionObj);
        AutoLogin_QM autoLoginQM= new AutoLogin_QM(ST);
        
        autoLoginQM.OpenAMAccount();
        /*ENDS HERE*/

        /*Double Dutch*/
        pageRef = Page.Link_to_DD;
        pageRef.getParameters().put('id', acquisitionObj.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController DD = new ApexPages.StandardController(acquisitionObj);
        AutoLogin_ADD autoLoginDD = new AutoLogin_ADD(DD);

        autoLoginDD.OpenDDAccount();
        /*ENDS HERE*/

        /*Wedding Spot*/
        pageRef = Page.Link_to_WS;
        pageRef.getParameters().put('id', acquisitionObj.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController WS = new ApexPages.StandardController(acquisitionObj);
        AutoLogin_WS autoLoginWS = new AutoLogin_WS(WS);

        autoLoginWS.OpenWSAccount();
        /*ENDS HERE*/
    }
}