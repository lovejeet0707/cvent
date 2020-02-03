@isTest
private class EmailMessageTriggerTest
{
    Private static User userRec;

     Private static void createUser(integer id ){
    
      Profile profileR = [SELECT Id FROM Profile WHERE Name='Standard User']; 
      //String s = '%' + roleName + '%'; 
      //USerrole testroleId=[select id from userRole where name like :s limit 1];
      userRec= new User(Alias = 'standt', Email='standarduser@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = profileR.Id,TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest'+id+'@testorg.com');
      
    }

    static void setupEmailMessage(Case caseObj){
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = InsertCase().Id)); 
        insert newEmail;
        try{
        Delete newEmail;
        }
        catch(Exception e)
        {}
    }

    static Case InsertCase()
    {
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = CaseRecordTypeInfo.get('Billing Cases').getRecordTypeId();
        Case caseObj=new Case();
        caseObj.Status='Information Requested';
        caseObj.Subject='Test Case';
        caseObj.RecordTypeId=rtId ;
        insert caseObj;
        return caseObj;
    }
    static testMethod void OnBeforeDeleteTest()
    {
        Case caseObj=InsertCase();
        createUser(1);
        system.runas(userRec){
            Test.startTest();
                setupEmailMessage(caseObj);
            Test.stopTest();
        }
    }
}