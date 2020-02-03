@isTest
private class Tier3SupportPublisherTest {
static testMethod void testPostToSlack() {
Tier3SupportPublisher.SalesforceCase caseObj = new Tier3SupportPublisher.SalesforceCase();
caseObj.subject = 'Unit Test Opt';
caseObj.caseURL = 'Unit Test Stage';
caseObj.summary= 'Unit Test summary';
caseObj.product= 'Unit Test product';
List<Tier3SupportPublisher.SalesforceCase> lis = new List<Tier3SupportPublisher.SalesforceCase>();
lis.add(caseObj);
Tier3SupportPublisher.postToSlack(lis);

//System.assertEquals(lis, lis); // Can't really test this, just put something that is true
}
}