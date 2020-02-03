public without sharing class CventMyd_CpqAuditTriggerHandler {
    
    public static void handleBeforeInsert() {

        Map<Id,SBQQ__Quote__c> renewalQuoteMap = new Map<Id,SBQQ__Quote__c>();

        Map<Id,SBQQ__Quote__c> amendmentQuoteMap = new Map<Id,SBQQ__Quote__c>();

        Integer statusCheckMax = CventMyd_Settings.renewalGenerationSettings.statusChecksPerQuote;

        Boolean inRenewalSchedulable = (CventMyd_AutoRenewContractSchedulable.firstJobOfChain != null);

        Boolean firstJobOfChain = CventMyd_AutoRenewContractSchedulable.firstJobOfChain;

        Boolean inQuoteSchedulableChain = (CventMyd_QuoteSchedulable.renewalChainMasterId != null);

        Boolean inChain = (inQuoteSchedulableChain || inRenewalSchedulable);

        Id renewalChainMasterId = CventMyd_AutoRenewContractSchedulable.renewalChainMasterId;

        renewalChainMasterId = (renewalChainMasterId != null) ? renewalChainMasterId : CventMyd_QuoteSchedulable.renewalChainMasterId ;

        Integer chainLinkNumber = (CventMyd_AutoRenewContractSchedulable.chainJobNumber != null) ? CventMyd_AutoRenewContractSchedulable.chainJobNumber : -1 ;

        Boolean chainFinishedInQuote = (CventMyd_QuoteSchedulable.chainFinished != null) ? CventMyd_QuoteSchedulable.chainFinished : false;

        Boolean chainFinishedInRenewal =  (CventMyd_AutoRenewContractSchedulable.chainFinished != null) ? CventMyd_AutoRenewContractSchedulable.chainFinished : false;

        Boolean chainFinished = (chainFinishedInQuote || chainFinishedInRenewal);        

        for(CpqAudit__c auditRecord : (List<CpqAudit__c>)Trigger.new) {

            auditRecord.chainMaster__c = (renewalChainMasterId != null) ? renewalChainMasterId : auditRecord.chainMaster__c;

            SBQQ__Quote__c quote = new SBQQ__Quote__c (

                Current_Year__c = auditRecord.quoteCurrentYear__c,

                Contract_Term_Years__c = String.valueOf(auditRecord.quoteFinalYear__c),

                SBQQ__Type__c = auditRecord.quoteType__c,

                Multiple_Years_Commitment__c = auditRecord.quoteIsVariableOptions__c,

                Id = auditRecord.quote__c

            );

            Boolean recordLock = (auditRecord.processingInformation__c != null) ? auditRecord.processingInformation__c.contains('UNABLE_TO_LOCK_ROW') : false;

            Boolean quotesFinishedInChain = (auditRecord.processingInformation__c != null) ? auditRecord.processingInformation__c.contains('no more quotes to process') : false;

            Boolean exceptionOccurred = auditRecord.exceptionOccurred__c;

            Boolean statusChecksRemaining = (auditRecord.quoteStatusCheckCount__c < statusCheckMax);

            statusChecksRemaining = (chainFinishedInQuote) ? true : statusChecksRemaining;

            Boolean isQuoteMaster = auditRecord.isQuoteSchedulableMaster__c;
            
            if(statusChecksRemaining && (inChain || recordLock || !exceptionOccurred) && !isQuoteMaster && !quotesFinishedInChain) {

                if(auditRecord.quoteType__c == 'Renewal') {

                    renewalQuoteMap.put(quote.Id,quote);

                }

                else if (auditRecord.quoteType__c == 'Amendment' && auditRecord.quoteIsVariableOptions__c) {

                    amendmentQuoteMap.put(quote.Id,quote);

                }

            }

        }

        Integer renewalCount = renewalQuoteMap.keySet().size();

        Boolean isEvenJobNumber = (Math.mod(chainLinkNumber,2) == 0);

        Boolean scheduleFromChain = ( isEvenJobNumber || chainFinished && inQuoteSchedulableChain || !isEvenJobNumber && chainFinished );

        if( renewalCount > 0 && (!inChain || scheduleFromChain) ) {

            CpqAudit__c renewalJobAuditRecord = new CpqAudit__c(Name = 'Renewal Quote Job Master @ ' + DateTime.now(), isQuoteSchedulableMaster__c = true);

            renewalJobAuditRecord.chainMaster__c = renewalChainMasterId;

            insert renewalJobAuditRecord;

            Boolean quoteInsertion = false;

            Boolean lastStatusCheck = false;

            for(CpqAudit__c auditRecord : (List<CpqAudit__c>)Trigger.new) {

                if(auditRecord.quoteType__c == 'Renewal') {

                    auditRecord.quoteJobMaster__c = renewalJobAuditRecord.Id;

                    if(auditRecord.Name.containsIgnoreCase('insertion')) {

                        quoteInsertion = true;

                    }

                    if(auditRecord.quoteStatusCheckCount__c == statusCheckMax - 1) {

                        lastStatusCheck = true;

                    }

                }

            }

            Integer secondsBeforeJobStart = (quoteInsertion) ? CventMyd_Settings.renewalGenerationSettings.secondsBeforeFirstQuoteJob : CventMyd_Settings.renewalGenerationSettings.secondsBetweenQuoteJobs;

            inRenewalSchedulable = CventMyd_QuoteSchedulable.renewalChainMasterId != null;

            if(!inChain && lastStatusCheck) {

                secondsBeforeJobStart = CventMyd_Settings.renewalGenerationSettings.secondsBeforeLastQuoteJob;

            }

            else if(inChain) {

                secondsBeforeJobStart = (firstJobOfChain != null && firstJobOfChain) ? CventMyd_Settings.renewalGenerationSettings.secondsBeforeFirstQuoteJob : CventMyd_Settings.renewalGenerationSettings.secondsBetweenQuoteJobs ;

                if(chainFinished && inQuoteSchedulableChain) {

                    secondsBeforeJobStart = 10;

                }

            }

            String renewalCronString = CventMyd_UtilityMethods.getCronString(secondsBeforeJobStart);            

            String renewalJobName = renewalJobAuditRecord.name + ', Id: ' + renewalJobAuditRecord.Id;

            renewalJobAuditRecord.Name = renewalJobName;

            update renewalJobAuditRecord;

            CventMyd_QuoteSchedulable renewalQuoteSchedulable = new CventMyd_QuoteSchedulable(renewalQuoteMap.keySet(),renewalJobName,renewalJobAuditRecord.Id);

            System.schedule(renewalJobName,renewalCronString,renewalQuoteSchedulable);

        }

    }

}