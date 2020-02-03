@isTest
public class updateSurveyDateTest{
    public static Id createContact(){
        Contact instContact = new Contact();        
        instContact.LastName = 'Test';
        instContact.AccountId = createAccount();
        insert instContact;
        return instContact.id;
    }
    public static Id createAccount(){
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        Account instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.BillingCountry='US';
        instOfAcc.BillingState='TX';
        insert instofAcc;
        return instofAcc.id;
    }
    private static testMethod void unittest(){
        test.starttest();
        
        EB_SB_Builder__c instOfEB =  new EB_SB_Builder__c();
        instOfEB.Contact__c = createContact();
        instOfEB.Survey_Invitation_Sent__c = System.NOW()-10;
        insert instOfEB;
        instOfEB.Survey_Invitation_Sent__c = System.NOW();
        update instOfEB;
        
        Mobile_Card__c instOfMobCard = new Mobile_Card__c();
        instOfMobCard.Name = 'Test';
        instOfMobCard.Primary_Contact__c = createContact();
        instOfMobCard.Survey_Invitation_Sent__c = System.NOW()-10;
        insert instOfMobCard;
        instOfMobCard.Survey_Invitation_Sent__c = System.NOW();
        update instOfMobCard;
                
        test.stoptest();
        
    }
}