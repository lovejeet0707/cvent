global without sharing class CventMyd_AutoRenewContractSchedulable1 implements Schedulable {

    global Id chainMasterRecordId;

    global String jobName;

    global Id previousChainLinkId;

    global String previousJobName;

    global DateTime scheduledFinishDateTime;

    global class Settings {

        public Decimal maxHoursToRunRenewalChain;

        public Integer minutesBeforeFirstPulseCheck;

        public Integer minutesBetweenPulseChecks;

        public Integer secondsBeforeFirstQuoteJob;

        public Integer secondsBeforeLastQuoteJob;

        public Integer secondsBetweenQuoteJobs;

        public Integer secondsBetweenRenewalJobs;

        public Integer statusChecksPerQuote;

        public Time timeToStartRenewalJob; 

    }

    global static CventMyd_AutoRenewContractSchedulable.Settings settings = CventMyd_Settings.renewalGenerationSettings;

    global CventMyd_AutoRenewContractSchedulable1() {}

    global void execute(SchedulableContext sc) {

        // get chain master record

        CpqAudit__c chainMasterRecord = CventMyd_UtilityMethods.getAuditRecord(this.chainMasterRecordId,this.scheduledFinishDateTime,this.jobName);

        System.debug('chainMasterRecord: ' + chainMasterRecord);

        CventMyd_AutoRenewContractSchedulable.firstJobOfChain = (this.chainMasterRecordId == null);

        System.debug('CventMyd_AutoRenewContractSchedulable.firstJobOfChain: ' + CventMyd_AutoRenewContractSchedulable.firstJobOfChain);

        upsert chainMasterRecord;

        CventMyd_AutoRenewContractSchedulable.chainJobNumber = (Integer)chainMasterRecord.jobsInChain__c;

        this.chainMasterRecordId = chainMasterRecord.Id;    

        CventMyd_AutoRenewContractSchedulable.renewalChainMasterId = this.chainMasterRecordId;

        Boolean nextJobScheduled = false;

        Date todaysDate = System.today();      

        String queryString = 'SELECT Id,Failed_Auto_Renew_Message__c,isLegacy__c FROM Contract';

        queryString += ' WHERE RecordType.Name = \'Child Contract\'';

        queryString += ' AND SBQQ__RenewalQuoted__c != TRUE';

        queryString += ' AND Failed_Auto_Renew__c != TRUE';

        queryString += ' AND Renewal_Creation_Date__c <=: todaysDate';

        queryString += ' AND CreatedBy.Name LIKE \'P%\' LIMIT 2';
        
        List<Contract> contractsTmp = Database.query(queryString);

        Contract contract = ( (contractsTmp.size() > 0) ? contractsTmp[0] : null);
        
        System.debug('contractsTmp value = ' + contractsTmp);

        // contract = new Contract(Id=Id.valueOf('8001N000000Mnvk'));

        // get chain link record for this job

        Id contractId = (contract != null) ? contract.Id : null ;

        CpqAudit__c chainLinkRecord = CventMyd_UtilityMethods.getAuditRecord(this.chainMasterRecordId,contractId,this.previousChainLinkId);

        if(CventMyd_AutoRenewContractSchedulable.chainJobNumber > 0) {

            insert chainLinkRecord;

        }

        else if(CventMyd_AutoRenewContractSchedulable.chainJobNumber == 0) {

            scheduleMonitorJob(CventMyd_AutoRenewContractSchedulable.renewalChainMasterId,true);

        }

        Savepoint sp = Database.setSavepoint();     

        try {

            if(contractsTmp.size() == 1 && CventMyd_AutoRenewContractSchedulable.chainJobNumber == 0) {

                CventMyd_AutoRenewContractSchedulable.chainFinished = false;

            }

            else if(contractsTmp.size() == 2 && chainMasterRecord.scheduledFinishTime__c > DateTime.now()) {

                CventMyd_AutoRenewContractSchedulable.chainFinished = false;

            }

            else {

                CventMyd_AutoRenewContractSchedulable.chainFinished = true;

            }            

            if(contract != null && CventMyd_AutoRenewContractSchedulable.chainJobNumber > 0) {

                CventMyd_QuoteTriggerHandler.contractIdInRenewalJob = contract.Id;

                contract.SBQQ__RenewalQuoted__c = true;

                Database.update(contract);

            }

            if(!CventMyd_AutoRenewContractSchedulable.chainFinished) {

                System.debug('scheduling next job...');

                scheduleNextRenewalChainLinkJob(this.chainMasterRecordId,chainLinkRecord.Id,this.jobName);

                nextJobScheduled = true;

            }

            else if (CventMyd_AutoRenewContractSchedulable.chainFinished) {

                System.debug('appears the jobs are done');

                CventMyd_AutoRenewContractSchedulable.chainFinished = true;

                chainMasterRecord.chainFinished__c = true;

                update chainMasterRecord;

                scheduleNextRenewalChainMasterJob(false);

                scheduleMonitorJob(this.chainMasterRecordId,false);

            }            

            System.debug('contractsTmp.size(): ' + contractsTmp.size());

            System.debug('date time now: ' + DateTime.now());

            System.debug('scheduled finish time: ' + chainMasterRecord.scheduledFinishTime__c);

            System.abortJob(sc.getTriggerId());

        }

        catch(Exception e0) {

            Database.rollBack(sp);

            chainLinkRecord.processingInformation__c = 'Exception Occurred @ ';

            chainLinkRecord.processingInformation__c += CventMyd_UtilityMethods.getFormattedDateTimeString(DateTime.now(),true,true);

            chainLinkRecord.processingInformation__c += CventMyd_UtilityMethods.getExceptionString(e0);

            chainLinkRecord.exceptionOccurred__c = true;

            update chainLinkRecord;

            String exceptionString = '==================================================' + '\r\n';

            exceptionString += 'Exception Occurred in Link Record with Id \''  + chainLinkRecord.Id + '\'...';

            exceptionString += CventMyd_UtilityMethods.getExceptionString(e0);            

            chainMasterRecord.processingInformation__c = (chainMasterRecord.processingInformation__c == null) ? '' : chainMasterRecord.processingInformation__c + '\r\n';

            if(chainMasterRecord.processingInformation__c.length() < 100000) {

                chainMasterRecord.processingInformation__c += exceptionString;

            }

            chainMasterRecord.exceptionOccurred__c = true;

            update chainMasterRecord;

            if(contract != null & contract.isLegacy__c) {

                CventMyd_LegacyContractValidator.createGenerationFailureReport(contract,exceptionString,false);

            }

            if(contract != null) {

                contract.Failed_Auto_Renew__c = true;

                contract.Failed_Auto_Renew_Message__c = (contract.Failed_Auto_Renew_Message__c == null) ? '' : contract.Failed_Auto_Renew_Message__c + '\r\n';

                if(contract.Failed_Auto_Renew_Message__c.length() < 30000) {

                    contract.Failed_Auto_Renew_Message__c += exceptionString;

                }

                if(exceptionString.contains('There are less than 1 renewable products')) {

                    contract.hasNoRenewableProducts__c = true;

                }

                contract.SBQQ__RenewalQuoted__c = false;

                sp = Database.setSavepoint();     

                try {

                    update contract;

                }

                catch(Exception e1) {

                    Database.rollBack(sp);

                }

            }

            if(!nextJobScheduled && contractsTmp.size() == 2 && chainMasterRecord.scheduledFinishTime__c > DateTime.now()) {

                scheduleNextRenewalChainLinkJob(this.chainMasterRecordId,chainLinkRecord.Id,this.jobName);

                nextJobScheduled = true;

            }

            else {

                System.debug('appears the jobs are done');

                chainMasterRecord.chainFinished__c = true;

                CventMyd_AutoRenewContractSchedulable.chainFinished = true;

                update chainMasterRecord;

                scheduleNextRenewalChainMasterJob(false);

                scheduleMonitorJob(this.chainMasterRecordId,false);

                CpqAudit__c renewalJobAuditRecord = new CpqAudit__c(Name = 'Renewal Quote Job Master @ ' + DateTime.now(), isQuoteSchedulableMaster__c = true);

                renewalJobAuditRecord.chainMaster__c = CventMyd_AutoRenewContractSchedulable.renewalChainMasterId;

                insert renewalJobAuditRecord;

                String renewalCronString = CventMyd_UtilityMethods.getCronString(60);

                String renewalJobName = renewalJobAuditRecord.name + ', Id: ' + renewalJobAuditRecord.Id;

                renewalJobAuditRecord.Name = renewalJobName;

                update renewalJobAuditRecord;

                CventMyd_QuoteSchedulable renewalQuoteSchedulable = new CventMyd_QuoteSchedulable(new Set<Id>(),renewalJobName,renewalJobAuditRecord.Id);

                System.schedule(renewalJobName,renewalCronString,renewalQuoteSchedulable);             

            }                   

            System.abortJob(sc.getTriggerId());

        }

    }

    global static void scheduleNextRenewalChainLinkJob(Id chainMasterRecordId, Id runningChainLinkId, String runningJobName) {

        CventMyd_AutoRenewContractSchedulable1 autoRenewContractSchedulable = new CventMyd_AutoRenewContractSchedulable1();

        Integer secondsUntilNextJob = settings.secondsBetweenRenewalJobs;

        autoRenewContractSchedulable.previousJobName = runningJobName;

        autoRenewContractSchedulable.chainMasterRecordId = chainMasterRecordId;

        autoRenewContractSchedulable.previousChainLinkId = runningChainLinkId;

        Integer scheduledJobsRunning = CventMyd_UtilityMethods.queryScheduledJobCount();

        if(scheduledJobsRunning > CventMyd_Settings.scheduledJobMax) {

            secondsUntilNextJob = secondsUntilNextJob * 10;

        }

        String cronString = CventMyd_UtilityMethods.getCronString(secondsUntilNextJob);

        String nextJobName = CventMyd_UtilityMethods.getRenewalChainLinkJobName(DateTime.now().addSeconds(secondsUntilNextJob));

        nextJobName = nextJobName.replace('Link','L1NK');

        autoRenewContractSchedulable.jobName = nextJobName;        

        System.schedule(nextJobName,cronString,autoRenewContractSchedulable);        

    }

    global static void scheduleNextRenewalChainMasterJob(Boolean runNow) {

        DateTime currentDateTime = DateTime.now();

        Time timeToStartJob = settings.timeToStartRenewalJob;

        Time currentTime = currentDateTime.time();

        Date dateToRun = (currentTime < timeToStartJob) ? Date.today() : Date.today().addDays(1) ;

        DateTime jobStartDateTime = (!runNow) ? DateTime.newInstance(dateToRun,timeToStartJob) : currentDateTime.addSeconds(10);

        Integer maximumSecondsToRunChain = (Integer)(settings.maxHoursToRunRenewalChain * 3600);

        Decimal hoursUntilStart = CventMyd_UtilityMethods.getHoursBetweenDateTimes(currentDateTime,jobStartDateTime);

        Decimal secondsUntilStart = hoursUntilStart * 3600;

        String cronString = CventMyd_UtilityMethods.getCronString((Integer)secondsUntilStart);

        DateTime jobFinishDateTime = jobStartDateTime.addSeconds(maximumSecondsToRunChain);

        String jobName = CventMyd_UtilityMethods.getRenewalChainMasterJobName(jobStartDateTime,jobFinishDateTime);

        CventMyd_AutoRenewContractSchedulable1 autoRenewContractSchedulable = new CventMyd_AutoRenewContractSchedulable1();

        autoRenewContractSchedulable.jobName = jobName;

        autoRenewContractSchedulable.scheduledFinishDateTime = jobFinishDateTime; 
        
        System.schedule(jobName,cronString,autoRenewContractSchedulable);

    }

    global static void scheduleMonitorJob(Id renewalChainMasterId, Boolean isPulseCheck) {

        String jobName = 'Renewal Chain';

        jobName += (isPulseCheck) ? ' Pulse Check' : ' Completion';

        jobName += ' for Id \'' + String.valueOf(renewalChainMasterId) + '\'';

        jobName += ' @ ' + CventMyd_UtilityMethods.getFormattedDateTimeString(DateTime.now(),true,true);

        CventMyd_RenewalChainMonitor renewalChainMonitor = new CventMyd_RenewalChainMonitor(jobName,renewalChainMasterId,isPulseCheck);

        Integer secondsBeforeStartingJob = (isPulseCheck) ? ( (CventMyd_AutoRenewContractSchedulable.chainJobNumber == 0) ? settings.minutesBeforeFirstPulseCheck * 60 : settings.minutesBetweenPulseChecks * 60) : 10;

        String cronString = CventMyd_UtilityMethods.getCronString(secondsBeforeStartingJob);

        System.schedule(jobName,cronString,renewalChainMonitor);

    } 

}