/* Name - Rishi Ojha 
   Purpose - Portal 2.0
   Test class - TestMyCasesQuery */

global class MyCasesQuery {

    public List<Case> results {get;set;}
    public String filterId {get;set;}
    private Id accountId;
    private Id contactId;
    public string previousSortField;
    public MyCasesQuery (){
    
    contactId = [Select contactId from User where id=:userinfo.getuserid()].contactId;    
    
    results = [select Id, CaseNumber, AccountId, Subject, Priority, Status, CreatedDate, ContactId from Case 
            where ContactId = :contactId AND Status != 'Closed' AND IsVisibleInSelfService = true AND CreatedDate >= 2013-08-05T00:00:00.000Z AND OwnerId != '00G00000006wL57' AND 
            (RecordTypeId !='012o00000019PyS' AND RecordTypeId != '012000000009A0r' AND RecordTypeId != '012000000009AAr' AND RecordTypeId != '012o0000000oWbY' AND RecordTypeId != '0120000000098bB' AND RecordTypeId!='012o0000000GiLz') order by lastmodifieddate, CaseNumber desc limit 100]; 
    }
    
    public PageReference processRequests()
    
    {
            previousSortField = 'CaseNumber';
            
    if (filterId == 'All') {
            results = [select Id, CaseNumber, AccountId, Subject, Priority, Status, CreatedDate, ContactId, Origin, Case_Status_L2__c from Case 
            where ContactId = :contactId AND CreatedDate >= 2013-08-05T00:00:00.000Z AND OwnerId != '00G00000006wL57' AND
            RecordTypeId != '012000000009A0r' AND RecordTypeId != '012000000009AAr' AND  RecordTypeId != '012o0000000oWbY' AND RecordTypeId != '0120000000098bB' AND  RecordTypeId != '012o0000000GiLz' 
            AND RecordTypeId != '012o0000000p9zz' AND RecordTypeId !='012o00000019PyS' AND Case_Status_L2__c != 'Spam' AND Origin!='Email' AND Origin!='CS VM' AND Origin!='Sales' order by lastmodifieddate, CaseNumber desc limit 100];
        } else if (filterId == 'Open') {
            results = [select Id, CaseNumber, AccountId, Subject, Priority, Status, CreatedDate, ContactId from Case 
            where ContactId = :contactId AND Status != 'Closed' AND CreatedDate >= 2013-08-05T00:00:00.000Z AND OwnerId != '00G00000006wL57' AND
            RecordTypeId != '012000000009A0r' AND RecordTypeId != '012000000009AAr' AND  RecordTypeId != '012o0000000oWbY' AND RecordTypeId != '0120000000098bB' AND  RecordTypeId != '012o0000000GiLz' 
            AND RecordTypeId != '012o0000000p9zz' AND RecordTypeId !='012o00000019PyS' AND Case_Status_L2__c != 'Spam' AND Origin!='Email' AND Origin!='CS VM' AND Origin!='Sales' order by lastmodifieddate, CaseNumber desc limit 100]; 
        } 
          else {
            results = [select Id, CaseNumber, AccountId, Subject, Priority, Status, CreatedDate, ContactId from Case 
            where Status = :filterId AND ContactId = :contactId AND CreatedDate >= 2013-08-05T00:00:00.000Z AND OwnerId != '00G00000006wL57' AND
            RecordTypeId != '012000000009A0r' AND RecordTypeId != '012000000009AAr' AND  RecordTypeId != '012o0000000oWbY' AND RecordTypeId != '0120000000098bB' AND  RecordTypeId != '012o0000000GiLz' 
            AND RecordTypeId != '012o0000000p9zz' AND RecordTypeId !='012o00000019PyS' AND Case_Status_L2__c != 'Spam' AND Origin!='Email' AND Origin!='CS VM' AND Origin!='Sales' order by lastmodifieddate, CaseNumber desc limit 100]; 
        } 
        return null;
    }

    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Open', 'My Open Cases'));
        options.add(new SelectOption('Closed', 'My Closed Cases'));
        options.add(new SelectOption('All', 'All Cases'));
        
        return options;
    }
}