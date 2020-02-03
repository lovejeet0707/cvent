//WRITTEN by : Udita - Posting to slack 
//Test class : Tier3SupportPublisherTest 
public class Tier3SupportPublisher {
    private static final String slackURL = 'https://hooks.slack.com/services/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';
     
    public class SalesforceCase {
        @InvocableVariable(label='Subject')
        public String subject;
        @InvocableVariable(label='Case URL')
        public String caseURL;
        @InvocableVariable(label='Escalation Summary')
        public String summary;
        @InvocableVariable(label='Product Version')
        public String product;
    }
     
    @InvocableMethod(label='Post to Slack')
    public static void postToSlack(List<SalesforceCase> salesforceCases) {
        SalesforceCase salesforceCase = salesforceCases[0]; // If bulk, only post first to avoid overloading Slack channel
        String caseURL = extractURL(salesforceCase.caseURL);
        Map<String,Object> msg = new Map<String,Object>();
        msg.put('text', 'The following Case has been escalated to Tier 3:' + 
                (caseURL != null ? '\nURL: <' + caseURL + '>' : '') +
                '\nProduct: *' + salesforceCase.product + '*' + 
                '\nSubject: *' + salesforceCase.subject + '*' +
                '\nSummary: ' + salesforceCase.summary);
        msg.put('mrkdwn', true);
        String body = JSON.serialize(msg);    
        System.enqueueJob(new QueueableSlackCall(slackURL, 'POST', body));
    }
     
    public class QueueableSlackCall implements System.Queueable, Database.AllowsCallouts {
         
        private final String url;
        private final String method;
        private final String body;
         
        public QueueableSlackCall(String url, String method, String body) {
            this.url = url;
            this.method = method;
            this.body = body;
        }
         
        public void execute(System.QueueableContext ctx) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod(method);
            req.setBody(body);
            Http http = new Http();
            if (!Test.isRunningTest()) {
            HttpResponse res = http.send(req);}
            
        }
 
    }
    
    public static String extractURL(String rawUrl) {
        try {
            String[] urlParts = rawUrl.split('_HL_ENCODED_');
            return urlParts[1].split('_HL_')[0];
        } catch (Exception e) {
            return null;
        }
    }
}