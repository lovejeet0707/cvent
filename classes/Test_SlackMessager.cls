@isTest
private class Test_SlackMessager 
{
    @testSetup static void testData()
    {
        //no test data needed.
    }
    
    @isTest static void loadClass()
    {
        test.starttest();
        
        SlackMessager.slackParams params = new SlackMessager.slackParams();
        params.slackURL = 'www.test.com';
        params.slackMsg = 'test';
        params.slackAttachTitle = 'test';
        params.slackAttachTitleUrl = 'test';
        params.slackAttachPre = 'test';
        params.slackAttachText = 'test';
        params.slackAttachColor = 'test';
        params.slackAttachImage = 'test';
        params.slackAttachFooter = 'test';
        params.slackAttachFooterIcon = 'test';
        
        test.stoptest();
    }
    
    @isTest static void postToSlack()
    {
        MockHTTPCallout mockclass = new MockHTTPCallout(200,'Ok','Ok',new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mockclass);
        
        test.starttest();
        
        SlackMessager.slackParams params = new SlackMessager.slackParams();
        params.slackURL = 'www.test.com';
        params.slackMsg = 'test';
        params.slackAttachTitle = 'test';
        params.slackAttachTitleUrl = 'test';
        params.slackAttachPre = 'test';
        params.slackAttachText = 'test';
        params.slackAttachColor = 'test';
        params.slackAttachImage = 'test';
        params.slackAttachFooter = 'test';
        params.slackAttachFooterIcon = 'test';
        
        SlackMessager.postToSlack(new List<SlackMessager.slackParams>{params});
        
        test.stoptest();
    }

}