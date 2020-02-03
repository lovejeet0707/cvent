public with sharing class SlackMessager {
     
    //Slack Documentation for message attachment options: https://api.slack.com/docs/message-attachments
     
    public class slackParams {
        @InvocableVariable(label='Slack Webhook URL')  //Inbound Webhook example: https://hooks.slack.com/services/###XXX
        public String slackURL;
        @InvocableVariable(label='Slack Message')  //Any text
        public String slackMsg;
        @InvocableVariable(label='Slack Attachment Title') //Headline text
        public String slackAttachTitle;
        @InvocableVariable(label='Slack Attachment Title URL') //https://api.slack.com/
        public String slackAttachTitleUrl;
        @InvocableVariable(label='Slack Attachment Pretext') //Text
        public String slackAttachPre;
        @InvocableVariable(label='Slack Attachment Text') //Text
        public String slackAttachText;        
        @InvocableVariable(label='Slack Attachment Color') //#36a64f
        public String slackAttachColor;
        @InvocableVariable(label='Slack Attachment Image URL') //https://slack.com/img.png
        public String slackAttachImage;
        @InvocableVariable(label='Slack Attachment Footer') //Text
        public String slackAttachFooter;
        @InvocableVariable(label='Slack Attachment Footer Icon URL') //https://platform.slack-edge.com/img/default_application_icon.png
        public String slackAttachFooterIcon;
        
    }
    
    @InvocableMethod(label='Post to SlackMessager')
    public static void postToSlack(List<slackParams> params) {
        slackParams p = params[0]; // If bulk, only post first to avoid overloading Slack channel
        
        Map<String, Object> m = new Map<String, Object>(); 
        m.put('text', p.slackMsg);
        m.put('mrkdwn', true);  //Makes message text use formatting
        
        List<Object> a = new List<Object>();
        m.put('attachments', a);
        
        Map<String, Object> atch = new Map<String, Object>();
        a.add(atch);
          atch.put('title',p.slackAttachTitle);
          atch.put('text',p.slackAttachText); 
          atch.put('title_link',p.slackAttachTitleUrl);
          atch.put('pretext',p.slackAttachPre); 
          atch.put('color',p.slackAttachColor);
          atch.put('footer',p.slackAttachFooter);  
          atch.put('footer_icon',p.slackAttachFooterIcon); 
          atch.put('image_url',p.slackAttachImage); 
        
        String body = JSON.serialize(m);  
        System.enqueueJob(new QueueableSlackCall(p.slackURL, 'POST', body));
    }
     
    public class QueueableSlackCall implements System.Queueable, Database.AllowsCallouts {
         
        private final String url;
        private final String method;
        private final String body;
         
        public QueueableSlackCall(String url, String method, String body) {
            this.url = url;
            this.method = method;
            this.body = body.replace('<br/>','\n').replace('_BR_ENCODED_','\n').replace('BR()','\n'); // transforms BR() from process builder into a New Line
        }
         
        public void execute(System.QueueableContext ctx) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod(method);
            req.setBody(body);
            System.debug('req.getbody:' + req.getBody());
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug(res.getBody());
        }
 
    }
    
}