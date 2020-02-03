@istest
public class testOnboardingTrgHelperClass{
  static testMethod void testOnboarding(){
    
    Account acc = new Account();
    acc.name ='test acc';
    insert acc;
    
    Contact con = new Contact();
    con.AccountId = acc.id;
    con.Lastname = 'test contact';
    con.email ='test@gmail.com';
    insert con;
    
    Id RecordTypeIdOnb = Schema.SObjectType.Onboarding__c.getRecordTypeInfosByName().get('Passkey Hotel - Existing Integration').getRecordTypeId();
         
    Onboarding__c onb = new Onboarding__c();
    onb.RecordtypeId = RecordTypeIdOnb;
    onb.Account_Name__c = acc.id;
    onb.Contact_Name__c = con.id;
    onb.Status__c  ='Open';
    insert onb;
        
    Onboarding_Contact__c Onbcon =  new Onboarding_Contact__c ();
    Onbcon.Onboarding__c = onb.id;
    Onbcon.Type__c='POC';
    Onbcon.Contact__c = con.id;
    insert Onbcon;
    CheckRecursive.runTwentySeven= true;
    onb.Status__c ='Closed';
    update onb;
    
    system.debug('---onb'+onb);
    system.debug('---onb'+onb.RecordtypeId);
  }
}