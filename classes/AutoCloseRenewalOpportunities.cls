public without sharing class AutoCloseRenewalOpportunities implements Database.Batchable<sObject>, Database.AllowsCallouts {
    /* batch job to close opportunities that ended in the past */ 
    Date dt = System.Today();
    Boolean f = false;
    Date n = null;
    String query = 'SELECT Id, StageName, OwnerId FROM Opportunity WHERE Auto_Close_Date__c <=: dt AND IsClosed =: f AND Auto_Close_Date__c !=: n';
 
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        if(scope.size() > 1) {return;} //only process 1 opp at a time
        for(Opportunity o: scope) {
            if(o.StageName != 'Closed Won') {
                o.StageName = 'Closed Won';
            }
        }
        try { 
            update scope;
        } catch (exception e) {
            sendEmail((Id)scope[0].get('Id'), (Id)scope[0].get('OwnerId'),e.getMessage());
        }
        
    }
    @TestVisible
    private void sendEmail(Id oppId, Id userId,String errorMessage) {
        //build cc list from custom setting
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //mail.setTargetObjectId(userId);
        mail.setToAddresses(new String[] {'salesforce@cvent.com'});  //add other emails here.
        mail.setPlainTextBody('Failed to auto close Opportunity. ID: ' + oppId);
        mail.setHtmlBody('Failed to auto close Opportunity. ID: ' + oppId+'.</b>'+errorMessage);
        mail.setSubject('Failed to auto close Opportunity. ID: ' + oppId);
        mail.setUseSignature(false);
        mail.setsaveAsActivity(false);
        // Send the email you have created.
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    mail
            });
        }
    }
    public void finish(Database.BatchableContext BC) {
        
    }
    
}