public without sharing class CventMyd_RenewalSchedulerController {

    public Account account {get;set;}

    public String contractNumbers {get;set;}

    public Boolean renewalChainScheduled {get;set;}

    public List<AuditRecordWrapper> auditRecords {get;set;}

    public List<AuditRecordWrapper> chainMasters {get;set;}

    public DateTime dateTimeAtScheduling {get;set;}

    public Boolean doAmendments {get;set;}

    public class AuditRecordWrapper {

        public CpqAudit__c auditRecord {get;set;}

        public String createdDateString {get;set;}

        public String lastModifiedDateString {get;set;}

        public AuditRecordWrapper(CpqAudit__c auditRecord) {

            this.auditRecord = auditRecord;

            createdDateString = CventMyd_UtilityMethods.getFormattedDateTimeString(auditRecord.CreatedDate,true,true);

            lastModifiedDateString = CventMyd_UtilityMethods.getFormattedDateTimeString(auditRecord.LastModifiedDate,true,true);

        }

    }

    public CventMyd_RenewalSchedulerController() {

        this.doAmendments = false;
        
        this.account = new Account();

        this.account.First_Response_Date__c = DateTime.now();

        this.account.Last_Response_Date__c = DateTime.now().addHours(1);

        this.contractNumbers = 'enter semi-colon-separated contract #\'s (optional)';

        this.chainMasters = new List<AuditRecordWrapper>();

        for(CpqAudit__c auditRecord : [SELECT 

            Name,Id,jobsInChain__c,CreatedDate,

            LastModifiedDate

            FROM CpqAudit__c

            WHERE isChainMaster__c = true

            ORDER BY CreatedDate DESC

            LIMIT 20

        ]) {

            chainMasters.add(new AuditRecordWrapper(auditRecord));

        }  

    }

    public class SchedulingException extends Exception {}

    public void scheduleJob() {

        this.renewalChainScheduled = false;

        DateTime currentDateTime = DateTime.now();

        DateTime startTime = this.account.First_Response_Date__c;

        Decimal hourDifference = CventMyd_UtilityMethods.getHoursBetweenDateTimes(startTime,currentDateTime);

        Decimal secondsDifference = hourDifference * 3600;

        if(secondsDifference < 0 ) {

            if(Math.abs(secondsDifference) > 90) {

                throw new SchedulingException('You cannot schedule a job that starts in the past');

            }

            else {

                secondsDifference = 10.0;

            }

        }

        System.debug('secondsDifference: ' + secondsDifference);

        String cronString = CventMyd_UtilityMethods.getCronString((Integer)secondsDifference);

        DateTime finishTime = this.account.Last_Response_Date__c;

        String jobName = CventMyd_UtilityMethods.getRenewalChainMasterJobName(startTime,finishTime);

        if(!doAmendments) {

            CventMyd_AutoRenewContractSchedulable autoRenewContractSchedulable = new CventMyd_AutoRenewContractSchedulable();

            autoRenewContractSchedulable.jobName = jobName;

            autoRenewContractSchedulable.scheduledFinishDateTime = finishTime;

            System.schedule(jobName,cronString,autoRenewContractSchedulable);

        }

        else if(doAmendments) {

            /*

            CventMyd_AutoAmendContractSchedulable autoAmendContractSchedulable = new CventMyd_AutoAmendContractSchedulable();

            jobName = jobName.replace('Renewal','Amendment');

            autoAmendContractSchedulable.jobName = jobName;

            autoAmendContractSchedulable.scheduledFinishDateTime = finishTime;

            System.schedule(jobName,cronString,autoAmendContractSchedulable);

            */

        }

        this.renewalChainScheduled = true;

        this.dateTimeAtScheduling = DateTime.now();

    }

    public void refreshAuditRecords() {

        this.auditRecords = new List<AuditRecordWrapper>();

        for(CpqAudit__c auditRecord: [SELECT

            Id,Name,contract__r.ContractNumber,contract__c,jobEncounteredException__c,

            isQuoteSchedulableMaster__c,isChainMaster__c,CreatedDate,

            quote__r.Name,quote__c,LastModifiedDate

            FROM CpqAudit__c

            WHERE CreatedDate >=: dateTimeAtScheduling

            ORDER BY CreatedDate ASC

            LIMIT 30

        ]) {

            auditRecords.add(new AuditRecordWrapper(auditRecord));

        }

    }

}