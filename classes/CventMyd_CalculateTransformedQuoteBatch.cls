/**
 * Created by ryandraper on 2018-07-06.
 */
global class CventMyd_CalculateTransformedQuoteBatch implements Database.Batchable<sObject>, Database.Stateful {

    private String queryString;
    private Integer queryLimit;
    private Integer batchSize;

    global CventMyd_CalculateTransformedQuoteBatch(Integer queryLimitP) {

        queryString = 'SELECT Id, Cloned_from_Quote__c,recalculationToggler__c, SBQQ__Primary__c,Cloned_from_Quote__r.ApprovalStatus__c '
                        + 'FROM SBQQ__Quote__c '
                        + 'WHERE Included_in_Primary_Batch_AW__c = true'
                        + ' AND recalculationToggler__c = false'; //Cloned_from_Quote__c != NULL AND SBQQ__Primary__c = FALSE';

        if(queryLimitP != null && queryLimitP > 0){
            queryString += ' LIMIT ' + String.valueOf(queryLimitP);
            queryLimit = queryLimitP;
        }

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('queryString-->' + queryString);
        return Database.getQueryLocator(queryString);

    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        if(batchSize == NULL || scope.size() > batchSize)
            batchSize = scope.size();

        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
        List<CpqAudit__c> cpqAudits = new List<CpqAudit__c>();

        for(SBQQ__Quote__c quote : (List<SBQQ__Quote__c>) scope){
            System.debug('batch: quote id: ' + quote.Id);
            System.debug('batch: quote: ' + quote);
            quote.recalculationToggler__c = true;
            quote.ApprovalStatus__c = quote.Cloned_from_Quote__r.ApprovalStatus__c;
            System.debug('quote-->' + quote);
            quotesToUpdate.add(quote);
        }

        Database.SaveResult[] srList;

        srList = Database.update(quotesToUpdate, false);

        for (Integer i = 0; i < quotesToUpdate.size(); i++) {
            Database.SaveResult sr = srList[i];
            if (!sr.isSuccess()) {                  
                cpqAudits.add(new CpqAudit__c(quote__c = quotesToUpdate.get(i).Id, processingInformation__c = String.valueOf(sr.getErrors())));
            }
        }

        if(!cpqAudits.isEmpty())
            insert cpqAudits;

    }

    global void finish(Database.BatchableContext BC) {

        if (batchSize == NULL)
            batchSize = 3;

        System.debug('finish method running');

        //can't chain 2 batches in a test class
       // if(!test.isRunningTest())
           // Database.executeBatch(new CventMyd_RetryTransformedQuoteBatch(1, queryLimit) , batchSize);

    }


}


/*

      Run the first batch:
      - queries all records needing to be updated
      - checks primary and updates the record
      - If there's an exception caused by the update: write to an audit log - maybe
      - finish
            - Call the 'RetryCalculateBatch'
                - Constructor takes a 'timesRun' parameter
                    - max times run will be a class variable set to 2
                    -
                    - Query all records that were transformed
                        - check the codeStatus on each record
                        - If not 'calc complete'
                            - try again
                        - finish method
                            - call a new instance of the RetryCalculateBatch class
                                - pass in 'times Run + 1'
*/