public class CventMyd_LegacyValidationQueueable implements Queueable {

    public List<Id> quoteIdsRemaining;

    public Boolean deleteOldReports;

    public CventMyd_LegacyValidationQueueable(List<Id> quoteIds, Boolean deleteOldReports) {

        this.quoteIdsRemaining = quoteIds;

        this.deleteOldReports = deleteOldReports;

    }

    public void execute(QueueableContext context) {

        Integer quotesPerJob = CventMyd_Settings.quotesPerLegacyValidationJob;

        System.debug('quoteIdsRemaining0: ' + quoteIdsRemaining);

        List<Id> quoteIdsToValidate;

        if(quoteIdsRemaining.size() <= quotesPerJob) {

            quoteIdsToValidate = quoteIdsRemaining;

            quoteIdsRemaining = new List<Id>();

        }

        else {

            quoteIdsToValidate = new List<Id>();

        }

        System.debug('quoteIdsToValidate: ' + quoteIdsToValidate);

        System.debug('quoteIdsRemaining1: ' + quoteIdsRemaining);

        while(quoteIdsToValidate.size() < quotesPerJob && !quoteIdsRemaining.isEmpty()) {

            Id quoteId = quoteIdsRemaining.remove(0);

            quoteIdsToValidate.add(quoteId);

        }

        CventMyd_LegacyContractValidator.validateAgainstLegacyContracts(null,new Set<Id>(quoteIdsToValidate),deleteOldReports);

        if(quoteIdsRemaining.size() > 0) {

            CventMyd_LegacyValidationQueueable validationQueueable = new CventMyd_LegacyValidationQueueable(quoteIdsRemaining,this.deleteOldReports);

            if(!Test.isRunningTest()) {System.enqueueJob(validationQueueable);}

        }

    }

}