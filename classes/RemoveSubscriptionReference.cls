global class RemoveSubscriptionReference implements Database.Batchable<sObject>{
    Map<String,Id> quoteLineIdVsQCId = new Map<String,Id>();
    Map<String,Id> subscriptionIdVsQCId = new Map<String,Id>();
    Quote_Reconfigure__c QC;
    SBQQ__Subscription__c ss;
    List<Quote_Reconfigure__c> QCQuoteList = new LIst<Quote_Reconfigure__c>();
    global Database.querylocator start(Database.BatchableContext BC){
        String query = 'SELECT Quote_Line_Id__c,Subscription_Id__c,Subscription_Deleted__c,Processed__c FROM Quote_Reconfigure__c WHERE Batch__c='+'\''+'DeleteSubscription'+'\''+' AND Subscription_Deleted__c = FALSE';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Quote_Reconfigure__c> scope){
        For(Quote_Reconfigure__c QC : scope)
        {
            subscriptionIdVsQCId.put(QC.Subscription_Id__c,QC.Id);
        }
        /*..... Removing Subscription_Id__c from Quote Line Record..........*/
        List<SBQQ__QuoteLine__c> quoteLineRecList = new List<SBQQ__QuoteLine__c>();
        For(SBQQ__QuoteLine__c quoteLineRec : [SELECT Id,SBQQ__RenewedSubscription__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RenewedSubscription__c  IN : subscriptionIdVsQCId.keySet()])
        {
            quoteLineRec.SBQQ__RenewedSubscription__c = null;
            quoteLineRecList.add(quoteLineRec);
        }
        /*.............ENDS HERE..................*/
        
        /*.............Removing Quote Line reference from Subscription and Deleting Subscription*/
        List<SBQQ__Subscription__c> subscriptionRecUpdateList = new List<SBQQ__Subscription__c>();
        For(SBQQ__Subscription__c subscriptionRec : [SELECT Id,SBQQ__QuoteLine__c FROM SBQQ__Subscription__c WHERE Id IN : subscriptionIdVsQCId.keySet()])
        {
            ss = new SBQQ__Subscription__c(Id= subscriptionRec.Id);
            ss.SBQQ__QuoteLine__c = null;
            subscriptionRecUpdateList.add(ss);
            
            QC = new Quote_Reconfigure__c(Id = subscriptionIdVsQCId.get(subscriptionRec.Id));
            QC.Subscription_Deleted__c = TRUE;
            QCQuoteList.add(QC);
        }
        if(SBQQ.TriggerControl.isEnabled()) {
            SBQQ.TriggerControl.disable();
            update quoteLineRecList;
            update subscriptionRecUpdateList;//Removing the Quote Line Reference From Subscription..
            delete subscriptionRecUpdateList;//Deleting Subscription....
        }
        update QCQuoteList;//Updating the checkbox for the processed records...
    }
    global void finish(Database.BatchableContext BC){
    }
}