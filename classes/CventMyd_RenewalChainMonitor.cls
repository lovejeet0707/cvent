global without sharing class CventMyd_RenewalChainMonitor implements Schedulable {

    global String jobName;

    global Id renewalChainMasterId;

    global Boolean isPulseCheck;

    global Boolean chainFinished;

    global static Decimal quotesCreated = 0;

    global static Decimal calculationFailedCount = 0;

    global CventMyd_RenewalChainMonitor(String jobName, Id renewalChainMasterId, Boolean isPulseCheck) {

        this.jobName = jobName;

        this.renewalChainMasterId = renewalChainMasterId;

        this.isPulseCheck = isPulseCheck;
        
    }

    global void execute(SchedulableContext sc) {

        CpqAudit__c chainMaster = [

            SELECT Id,Name,chainFinished__c,jobsInChain__c,LastModifiedDate

            FROM CpqAudit__c

            WHERE Id =: renewalChainMasterId

        ];

        chainFinished = (!isPulseCheck || chainMaster.chainFinished__c);

        DateTime currentDateTime = DateTime.now();

        Decimal hoursSinceChainUpdate = CventMyd_UtilityMethods.getHoursBetweenDateTimes(chainMaster.LastModifiedDate,currentDateTime);

        Decimal minutesSinceChainUpdate = hoursSinceChainUpdate * 60;

        System.debug('minutesSinceChainUpdate: ' + minutesSinceChainUpdate);

        Boolean isStuck = (chainMaster.jobsInChain__c < 1 || minutesSinceChainUpdate > 5);

        Messaging.SingleEmailMessage singleEmailMessage = getSingleEmailMessage(renewalChainMasterId,isPulseCheck,isStuck);

        String htmlBodyString = getHtmlBodyString(renewalChainMasterId,isPulseCheck,isStuck);

        String subjectString = singleEmailMessage.subject;

        if(quotesCreated > 0) {

            Decimal calculationSuccessfulCount = quotesCreated - calculationFailedCount;

            Decimal calculationSuccessRate = calculationSuccessfulCount.divide(quotesCreated,3);

            if(calculationSuccessRate < 0.5) {

                subjectString = '***URGENT*** ' + subjectString;

                htmlBodyString = htmlBodyString += '<br/><br/> URGENT: CALCULATION SUCCESS RATE IS: ' + String.valueOf(calculationSuccessRate);

            }

        }

        singleEmailMessage.setSubject(subjectString);

        singleEmailMessage.setHtmlBody(htmlBodyString);

        if(!isPulseCheck && chainFinished || isPulseCheck && !chainFinished) {

            Messaging.SingleEmailMessage[] singleEmailMessages = new Messaging.SingleEmailMessage[] {singleEmailMessage};

            Messaging.SendEmailResult[] sendEmailResults = Messaging.sendEmail(singleEmailMessages);

        }

        if(isPulseCheck && !chainFinished) {

            CventMyd_AutoRenewContractSchedulable.scheduleMonitorJob(renewalChainMasterId,true);

        }

        CventMyd_UtilityMethods.abortSchedulableJobs(true,'blah',this.jobName,false);

    }

    public static Messaging.SingleEmailMessage getSingleEmailMessage(Id renewalChainMasterId, Boolean isPulseCheck, Boolean isStuck) {

        Messaging.reserveSingleEmailCapacity(1);

        Messaging.SingleEmailMessage singleEmailMessage = new Messaging.SingleEmailMessage();

        String[] toAddresses = CventMyd_Settings.administratorEmails;

        singleEmailMessage.setToAddresses(toAddresses);

        singleEmailMessage.setWhatId(renewalChainMasterId);

        singleEmailMessage.setSaveAsActivity(false);

        singleEmailMessage.setUseSignature(true);

        String dateString = String.valueOf(Date.today());

        String subjectString = (isPulseCheck) ? 'Renewal Chain Pulse Check' : 'Renewal Chain Completion';

        subjectString += ' for ' + dateString;

        subjectString += (isStuck) ? ' ***URGENT*** ' : '';

        singleEmailMessage.setSubject(subjectString);

        return singleEmailMessage;

    }

    public static String getChainMasterLinkHtml(Id renewalChainMasterId) {

        String baseUrlString = String.valueOf(System.URL.getSalesforceBaseUrl());

        baseUrlString = baseUrlString.split('delegate=')[1];

        baseUrlString = baseUrlString.substringBeforeLast(']');     

        String linkUrl = '<a href="' + baseUrlString + '/' + String.valueOf(renewalChainMasterId) + '">Link to Chain Master<a/>';

        return linkUrl;     

    }

    public static String getHtmlBodyString(Id renewalChainMasterId, Boolean isPulseCheck, Boolean isStuck) {

        String htmlBodyString = 'Hi all,<br/><br/>';

        htmlBodyString += 'The master record for today\'s renewal chain is linked below for your convenience.<br/><br/>';

        htmlBodyString += getChainMasterLinkHtml(renewalChainMasterId) + '<br/><br/>';

        Integer scheduledJobsRunning = CventMyd_UtilityMethods.queryScheduledJobCount();

        htmlBodyString += 'There are ' + String.valueOf(scheduledJobsRunning) + ' Schedulable Apex jobs active as of this email delivery.<br/><br/>';     

        if(isPulseCheck && !isStuck) {

            htmlBodyString += 'Today\'s renewal chain is successfully renewing contracts as of the time of this email delivery.<br/>';

        }

        else if(isPulseCheck && isStuck) {

            htmlBodyString += 'Today\'s renewal chain has not renewed a contract in quite some time. It should revive; however, an adiminstrator should surely check its pulse.';

        }

        else if(!isPulseCheck) {

            htmlBodyString += 'Today\'s renewal chain is complete.<br/><br/>';

            List<SBQQ__Quote__c> quotes = [SELECT

                Id,Name,calculationCycleFinished__c

                FROM SBQQ__Quote__c

                WHERE renewalChainMaster__c =: renewalChainMasterId

            ];

            quotesCreated = (Decimal)quotes.size();

            htmlBodyString += String.valueOf(quotes.size()) + ' renewal quote';

            htmlBodyString += (quotes.size() == 1) ? ' was' : 's were';

            htmlBodyString += ' created.<br/><br/>';

            String quoteIdString = '';

            for(SBQQ__Quote__c quote : quotes) {

                if(!quote.calculationCycleFinished__c) {

                    calculationFailedCount++;

                    quoteIdString += String.valueOf(quote.Id) + ';';

                }

            }

            htmlBodyString += 'There';

            htmlBodyString += (quotes.size() == 1) ? ' was' : ' were';

            htmlBodyString += ' ' + String.valueOf(calculationFailedCount) + ' quote';

            htmlBodyString += (quotes.size() == 1) ? '' : 's';

            htmlBodyString += ' that did not complete calculation.<br/><br/>';

            if(calculationFailedCount > 0) {

                htmlBodyString += (quotes.size() == 1) ? ' Its Id is' : 'Their Ids are';

                htmlBodyString += ':<br/>' + quoteIdString + '<br/><br/>';

            }

            List<Contract> contracts = [SELECT

                Id,Name,Failed_Auto_Renew__c

                FROM Contract

                WHERE renewalChainMaster__c =: renewalChainMasterId

            ];

            Integer renewalFailedCount = 0;

            String contractIdString = '';

            for(Contract contract : contracts) {

                if(contract.Failed_Auto_Renew__c) {

                    renewalFailedCount++;

                    contractIdString += String.valueOf(contract.Id) + ';';

                }

            }

            htmlBodyString += 'There';

            htmlBodyString += (renewalFailedCount == 1) ? ' was' :' were';

            htmlBodyString += ' ' + String.valueOf(renewalFailedCount) + ' contract';

            htmlBodyString += (renewalFailedCount == 1) ? '' : 's';

            htmlBodyString += ' that could not be renewed.<br/>';

            if(renewalFailedCount > 0) {

                htmlBodyString += '<br/>';

                htmlBodyString += (renewalFailedCount == 1) ? ' Its Id is:' : ' Their Ids are:';

                htmlBodyString += '<br/>' + contractIdString + '<br/>';

            }

            htmlBodyString += '<br/>Please note that the CventMyd_QuoteSchedulable Apex class is running post chain completion to process and recalculate the generated renewal quotes where necessary.';

        }

        return htmlBodyString;

    }

}