global without sharing class CventMyd_ContractingMonitorHandler {

    global static Boolean isRunning = false;

    global static CventMyd_ContractingMonitor.Settings settings = CventMyd_Settings.contractingMonitorSettings;

    global class ContractedResult {

        global Opportunity opportunity;

        global Boolean success;

        global String processingInformation;

        global List<ContractingIssue> issueTypes;

        global CpqAudit__c auditRecord;

        global ContractedResult(Opportunity opportunity) {

            this.opportunity = opportunity;

            this.success = false;

            this.processingInformation = getResultHeader(opportunity);

            this.issueTypes = new List<ContractingIssue>();

        }

    }


    global enum ContractingIssue {

        NO_PRIMARY_QUOTE,

        UNEXPECTED_CHILD_CONTRACT_STATE,

        UNEXPECTED_PARENT_CONTRACT_STATE,

        CHILD_CONTRACT_NOT_UPDATED,

        UNEXPECTED_CONTRACTED_AMENDMENT_QUOTE,

        FAILED_CONTRACTING_OPERATION,

        SUBSCRIPTIONS_NOT_UPDATED,

        CHILD_CONTRACT_MISMATCH,

        NO_AMENDED_CONTRACT

    }    

    global class Contracts {

        global List<Contract> parentContracts;

        global List<Contract> childContracts;

        global Integer duplicateParentCount;

        global Integer uniqueParentCount;

        global Contracts(List<Contract> parentContracts, List<Contract> childContracts) {

            this.parentContracts = parentContracts;

            this.childContracts = childContracts;

            this.duplicateParentCount = 0;

            for(Contract parentContract : parentContracts) {

                this.duplicateParentCount += (parentContract.Duplicate_Parent__c) ?  1 : 0 ;

            }

            this.uniqueParentCount = this.parentContracts.size() - this.duplicateParentCount;

        }

    }    

    global static String getReportResultsTableHtml(Map<Id,ContractedResult> opportunityIdToContractedResult) {

        String htmlString = '<table style="border: 1px solid black;">';

        htmlString += '<thead>';

        htmlString += '<th style="border: 1px solid black;">Link to Opportunity</th>';

        htmlString += '<th style="border: 1px solid black;">Link to Primary Quote</th>';

        htmlString += '<th style="border: 1px solid black;">Primary Quote Type</th>';

        htmlString += '<th style="border: 1px solid black;">Issue Types</th>';

        htmlString += '<th style="border: 1px solid black;">Link to Description of Issue</th>';

        htmlString += '</thead>';

        for(Id opportunityId : opportunityIdToContractedResult.keySet()) {

            ContractedResult contractedResult = opportunityIdToContractedResult.get(opportunityId);

            Opportunity opportunity = contractedResult.opportunity;

            htmlString += '<tr>';

            htmlString += '<td style="border: 1px solid black;">';

            htmlString += '<a href="' + CventMyd_Settings.orgBaseUrl + opportunityId + '">' + opportunity.Name + '</a>';

            htmlString += '</td>';

            htmlString += '<td style="border: 1px solid black;">';

            if(opportunity.SBQQ__PrimaryQuote__c != null) {

                htmlString += '<a href="' + CventMyd_Settings.orgBaseUrl + opportunity.SBQQ__PrimaryQuote__c + '">' + opportunity.SBQQ__PrimaryQuote__r.Name + '</a>';

            }

            htmlString += '</td>';

            htmlString += '<td style="border: 1px solid black;">';

            htmlString += (opportunity.SBQQ__PrimaryQuote__r.SBQQ__Type__c != null) ? opportunity.SBQQ__PrimaryQuote__r.SBQQ__Type__c : '' ;

            htmlString += '</td>';

            htmlString += '<td style="border: 1px solid black;">';

            for(ContractingIssue contractingIssue : contractedResult.issueTypes) {

                htmlString += String.valueOf(contractingIssue);

                htmlString += '<br/>';

            }

            htmlString += '</td>';  

            htmlString += '<td style="border: 1px solid black;">';

            htmlString += '<a href="' + CventMyd_Settings.orgBaseUrl + contractedResult.auditRecord.Id + '">Issue Description</a>';

            htmlString += '</td>';                                  

            htmlString += '</tr>';

        }

        htmlString += '</table>';

        return htmlString;

    }

    global class Settings {

        global Time timeToRunContractedMonitoring;

        global Decimal hoursToCheckContractedMonitoring;

        global Boolean createRecordsForSuccesses;

    }

    global static Map<Id,Contract> contractIdToContract = new Map<Id,Contract>();

    global static List<AsyncApexJob> failedApexJobs = new List<AsyncApexJob>();

    global static Map<Id,List<Contract>> opportunityIdToContracts = new Map<Id,List<Contract>>();

    global static List<String> getOpenCloseDateTimeStrings(List<DateTime> dateTimes) {

        List<String> dateTimeStrings = new List<String>();

        for(DateTime date_Time : dateTimes) {

            dateTimeStrings.add(CventMyd_UtilityMethods.getFormattedDateTimeString(date_Time ,false,true));

        }

        return dateTimeStrings;

    }

    global static String getContractingMonitorJobName(DateTime startTime, Set<Id> opportunityIds) {

        String jobName = 'Contracting Report... ';

        if(opportunityIds != null) {

            jobName += opportunityIds.size() + ' specified opportunity Ids... ' + CventMyd_UtilityMethods.getQleId();

        }

        else {

            List<DateTime> openCloseDateTimes = getOpenCloseDateTimes(startTime,null,false);

            List<String> dateTimeStrings = getOpenCloseDateTimeStrings(openCloseDateTimes) ;
            
            jobName += (dateTimeStrings[0] + ' - ' + dateTimeStrings[1]);

        }

        return jobName;

    }

    global static List<DateTime> getOpenCloseDateTimes(DateTime jobStartTime, List<Opportunity> opportunities, Boolean useSortedOpportunities) {

        List<DateTime> startDateEndDate = new List<DateTime>();

        if(useSortedOpportunities) {

            // assume opportunites are already sorted by contractedDateTime__c ascending

            startDateEndDate.add(opportunities[0].contractedDateTime__c);

            startDateEndDate.add(opportunities[opportunities.size() - 1].contractedDateTime__c);

        }

        else {

            DateTime closeDateTime = jobStartTime.addMinutes(-5);

            DateTime openDateTime = closeDateTime.addMinutes(-1 * getMinutesToCheck());

            startDateEndDate.add(openDateTime); startDateEndDate.add(closeDateTime);

        }

        return startDateEndDate;

    }

    global static Integer getMinutesToCheck() {

        if(settings.timeToRunContractedMonitoring == null) {

            return Math.round( settings.hoursToCheckContractedMonitoring * 60 );

        }

        else {

            return 24*60;

        }

    }

    @future

    global static void generateReport(Set<Id> opportunityIds) {

        isRunning = true;

        CpqAudit__c reportRecord = new CpqAudit__c();

        Set<String> opportunityFieldNames = new Set<String> {

            'contractedDateTime__c',

            'SBQQ__PrimaryQuote__r.SBQQ__Type__c',

            'LastModifiedBy.Email',

            'SBQQ__AmendedContract__c',

            'SBQQ__AmendedContract__r.ContractNumber',

            'SBQQ__PrimaryQuote__c',

            'SBQQ__PrimaryQuote__r.Name',

            'SBQQ__PrimaryQuote__r.Current_Year__c',

            'SBQQ__PrimaryQuote__r.Contract_Extension__c',

            'SBQQ__PrimaryQuote__r.SBQQ__MasterContract__c',

            'SBQQ__PrimaryQuote__r.SBQQ__MasterContract__r.ContractNumber',

            'Primary_Quote_Type__c'

        };

        String queryString = 'SELECT Id,Name';

        queryString += ',' + CventMyd_UtilityMethods.getFieldNamesStringFromStringSet(opportunityFieldNames);

        queryString += ' FROM Opportunity';

        List<DateTime> openCloseDateTimes = getOpenCloseDateTimes(DateTime.now(),null,false);

        DateTime openDateTime = openCloseDateTimes[0];

        DateTime closeDateTime = openCloseDateTimes[1];

        System.debug('dateTimeLowEnd: ' + openDateTime);

        System.debug('dateTimeHighEnd: ' + closeDateTime);

        System.debug('DateTime.now(): ' + DateTime.now());     

        if(opportunityIds != null) {
            
            queryString += ' WHERE Id IN: opportunityIds';
            
        }
        
        else {
            
            queryString += ' WHERE SystemModStamp >: openDateTime';

            queryString += ' AND contractedDateTime__c != null';

            queryString += ' AND contractedDateTime__c >: openDateTime ';

            queryString += ' AND contractedDateTime__c <: closeDateTime ';

            queryString += ' AND SBQQ__Contracted__c = true';

        }

        System.debug('queryString0: ' + queryString);

        List<Opportunity> opportunities = Database.query(queryString);

        Integer amendmentCount = 0; for(Opportunity o : opportunities) {amendmentCount += (o.Primary_Quote_Type__c == 'Amendment') ? 1 : 0;}

        openCloseDateTimes = getOpenCloseDateTimes(DateTime.now(),opportunities,(opportunityIds != null));

        queryString = 'SELECT Id,CreatedDate,CompletedDate,ExtendedStatus ';

        queryString += ' FROM AsyncApexJob';

        queryString += ' WHERE MethodName = \'contractQuotesDeferred\'';

        queryString += ' AND CreatedDate >: openDateTime';

        queryString += ' AND CompletedDate <: closeDateTime';

        System.debug('queryString0 : ' + queryString);

        Integer apexJobCount = (Database.query(queryString)).size();

        queryString = queryString.replace('SELECT COUNT(), ', 'SELECT Id,ExtendedStatus,Status,CreatedDate,CompletedDate');

        queryString += ' AND Status != \'Completed\'';

        System.debug('queryString1 : ' + queryString); 

        failedApexJobs = Database.query(queryString);

        reportRecord.processingInformation__c = 'This report is generated w.r.t. ' + opportunities.size() + ' opportunities...';

        reportRecord.processingInformation__c += CventMyd_UtilityMethods.doubleNewLine + amendmentCount + ' amendment(s) and ' + (opportunities.size() - amendmentCount) + ' non-amendment(s)...';

        List<String> openCloseDateTimeStrings = getOpenCloseDateTimeStrings(openCloseDateTimes);

        reportRecord.Name = getContractingMonitorJobName(DateTime.now(),opportunityIds);

        reportRecord.processingInformation__c += CventMyd_UtilityMethods.doubleNewLine + 'These opportunities were contracted between ' + openCloseDateTimeStrings[0] + ' and ' + openCloseDateTimeStrings[1] + '...';

        Set<Id> amendedContractIds = CventMyd_UtilityMethods.getIdSet(opportunities,'SBQQ__AmendedContract__c');

        opportunityIds = CventMyd_UtilityMethods.getIdSet((List<SObject>)opportunities);

        List<Contract> contracts = [SELECT Id,Name,ContractNumber,

            LastModifiedDate,contractedAmendmentQuote__c,

            contractedAmendmentQuote__r.Name,Current_Year__c,

            Parent_Contract_Term_Years__c,RecordType.Name,
            
            Duplicate_Parent__c,SBQQ__Opportunity__c,

            (SELECT Id,Name,CreatedDate,
            
            jsonString__c,LastModifiedDate
            
            FROM SBQQ__Subscriptions__r)

            FROM Contract

            WHERE SBQQ__Opportunity__c IN: opportunityIds

            OR Id IN: amendedContractIds

        ];

        contractIdToContract = new Map<Id,Contract>(contracts);

        opportunityIdToContracts = CventMyd_UtilityMethods.getParentIdToChildrenRecords( (List<SObject>)contracts,'SBQQ__Opportunity__c' );

        List<CpqAudit__c> opportunityAuditRecords = new List<CpqAudit__c>();

        Integer issueCount = 0;

        Map<Id,ContractedResult> opportunityIdToContractedResult = new Map<Id,ContractedResult>();
        
        for(Opportunity opportunity : opportunities) {

            ContractedResult contractedResult = (opportunity.Primary_Quote_Type__c == 'Amendment' ) ? getContractedAmendmentResult(opportunity) : getContractGenerationResult(opportunity);

            issueCount += (!contractedResult.success) ? 1 : 0 ;

            if(!contractedResult.success || settings.createRecordsForSuccesses) {

                String name = opportunity.Name + ' - contracting ';

                name += (contractedResult.success) ? '**SUCCESS**'  : '**ISSUE**';

                Integer endingPosition = (name.length() <= 80) ? name.length() : 80;

                name = name.substring(0,endingPosition);

                System.debug('name: ' + name);

                CpqAudit__c opportunityAuditRecord = new CpqAudit__c(Name = name,opportunity__c = opportunity.Id, chainMaster__c = reportRecord.Id, processingInformation__c = contractedResult.processingInformation);

                opportunityAuditRecords.add(opportunityAuditRecord);

                opportunityIdToContractedResult.put(opportunity.Id,contractedResult);

            }

        }

        reportRecord.processingInformation__c += CventMyd_UtilityMethods.doubleNewLine + 'Of these ' + opportunities.size() + ' opportunities, there were ' + issueCount + ' issues found...';

        reportRecord.processingInformation__c += CventMyd_UtilityMethods.doubleNewLine + 'There were ' + apexJobCount + ' contracting method invocations executed within the time frame where these opportunities were contracted...';

        reportRecord.processingInformation__c += CventMyd_UtilityMethods.doubleNewLine + failedApexJobs.size() + ' of these method executions failed...';

        String nextJobStartTime = CventMyd_UtilityMethods.getFormattedDateTimeString(getJobStartDateTime(false,null),true,true);

        reportRecord.processingInformation__c += CventMyd_UtilityMethods.doubleNewLine + 'The next monitoring job is scheduled to start at ' + nextJobStartTime + '...';

        insert reportRecord;

        if(!opportunityAuditRecords.isEmpty()) {

            for(CpqAudit__c record : opportunityAuditRecords) {

                record.chainMaster__c = reportRecord.Id;

            }

            insert opportunityAuditRecords;

            for(CpqAudit__c auditRecord : opportunityAuditRecords) {

                ContractedResult contractedResult = opportunityIdToContractedResult.get(auditRecord.opportunity__c);

                contractedResult.auditRecord = auditRecord;

                opportunityIdToContractedResult.put(auditRecord.opportunity__c,contractedResult);

            }

        }

        sendContractingReportEmail(reportRecord,opportunityIdToContractedResult);

    }

    global static Contracts getContracts(Opportunity opportunity) {

        List<Contract> contractRecords = opportunityIdToContracts.get(opportunity.Id);

        List<Contract> childContracts = new List<Contract>();

        List<Contract> parentContracts = new List<Contract>();

        if(contractRecords != null) {

            for(Contract contract : contractRecords) {

                if(contract.RecordType.Name == 'Child Contract') {

                    childcontracts.add(contract);

                }

                else if(contract.RecordType.Name == 'Parent Contract') {

                    parentContracts.add(contract);

                }

            }

        }

        Contracts contracts = new Contracts(parentContracts,childContracts);

        return contracts;

    }

    // only call this method for non-amendments (primary quote is NOT of type quote)

    global static ContractedResult getContractGenerationResult(Opportunity opportunity) {

        ContractedResult contractedResult = new ContractedResult(opportunity);

        Contracts contracts = getContracts(opportunity);

        Boolean needsParentContract;

        if(opportunity.SBQQ__PrimaryQuote__c == null) {

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'The Primary Quote field is blank...';

            contractedResult.issueTypes.add(ContractingIssue.NO_PRIMARY_QUOTE);

        }

        else {

            needsParentContract = (opportunity.SBQQ__PrimaryQuote__r.Current_Year__c != 1) ? false : true;

        }

        if(opportunity.SBQQ__PrimaryQuote__r.SBQQ__MasterContract__c != null || opportunity.SBQQ__AmendedContract__c != null) {

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'The SBQQ__Quote__c.SBQQ__MasterContract__c and/or Opportunity.SBQQ__AmendedContract__c is populated. This is not expected on a non-amendment quote.';

            contractedResult.issueTypes.add(ContractingIssue.CHILD_CONTRACT_MISMATCH);

        }

        if(needsParentContract != null && needsParentContract && contracts.uniqueParentCount != 1 && contracts.parentContracts.size() != 1) {

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'The primary quote is in year 1 hence 1 unique parent contract should exist...';

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'There are ' + contracts.parentContracts.size() + ' parent contracts...';

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + contracts.uniqueParentCount + ' are unique and ' + contracts.duplicateParentCount + ' are duplicate...';

            contractedResult.issueTypes.add(ContractingIssue.UNEXPECTED_PARENT_CONTRACT_STATE);

        }

        else if(opportunity.SBQQ__PrimaryQuote__c != null  && needsParentContract != null && !needsParentContract && contracts.parentContracts.size() != 0) {

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'The opportunity\'s primary quote is not in year 1 and is not an amendment hence there should be no parent contract...';

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'There are ' + contracts.parentContracts.size() + ' parent contracts...';

            contractedResult.issueTypes.add(ContractingIssue.UNEXPECTED_PARENT_CONTRACT_STATE);

        }

        if(opportunity.SBQQ__PrimaryQuote__c != null && contracts.childContracts.size() != 1) {

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'The primary quote of the opportunity is not an amendment hence there should be one child contract...';

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'There are ' + contracts.childContracts.size() + ' child contracts...';

            String asyncApexJobString = getAsyncApexJobString(crossReferenceApexJobs(opportunity));

            if(!asyncApexJobString.contains('We were not able to locate')) {

                contractedResult.issueTypes.add(ContractingIssue.FAILED_CONTRACTING_OPERATION);

            }

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + asyncApexJobString;

            contractedResult.issueTypes.add(ContractingIssue.UNEXPECTED_CHILD_CONTRACT_STATE);

        }

        if(contracts.childContracts.size() == 1 && contractedResult.processingInformation == getResultHeader(opportunity)) {

            contractedResult.success = true;

        }

        return contractedResult;

    }

    global static ContractedResult getContractedAmendmentResult(Opportunity opportunity) {

        ContractedResult contractedResult = new ContractedResult(opportunity);

        Contracts contracts = getContracts(opportunity);

        Contract amendedContract = contractIdToContract.get(opportunity.SBQQ__AmendedContract__c);

        Boolean needsParentContract = (opportunity.SBQQ__PrimaryQuote__r.Contract_Extension__c != null);

        if(needsParentContract && contracts.uniqueParentCount != 1) {

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'The primary quote was extended hence one unique parent contract should exist...';

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'There are ' + contracts.parentContracts.size() + ' parent contracts...';

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + contracts.uniqueParentCount + ' are unique and ' + contracts.duplicateParentCount + ' are duplicate...';

            contractedResult.issueTypes.add(ContractingIssue.UNEXPECTED_PARENT_CONTRACT_STATE);
        }

        else if(!needsParentContract && contracts.parentContracts.size() != 0) {

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'The opportunity\'s primary quote was not extended hence there should not be a parent contract...';

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'There are ' + contracts.parentContracts.size() + ' parent contracts...';

            contractedResult.issueTypes.add(ContractingIssue.UNEXPECTED_PARENT_CONTRACT_STATE);

        }

        if(opportunity.SBQQ__AmendedContract__c == null || opportunity.SBQQ__PrimaryQuote__r.SBQQ__MasterContract__c != opportunity.SBQQ__AmendedContract__c) {

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'The Opportunity.SBQQ__AmendedContract__c and/or SBQQ__Quote__c.SBQQ__MasterContract__c values appear to be incorrect...';

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'The Amended Contract is ' + opportunity.SBQQ__AmendedContract__r.ContractNumber + '\'';

            contractedResult.processingInformation +=  'whereas the quote\'s Amended Child Contract (SBQQ__MasterContract__c) is ' + opportunity.SBQQ__PrimaryQuote__r.SBQQ__MasterContract__r.ContractNumber + '...';

            contractedResult.issueTypes.add(ContractingIssue.CHILD_CONTRACT_MISMATCH);

        }

        if(contracts.childContracts.size() != 0) {

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'This opportunity is not an amendment hence there should be no child contracts...';

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'There are ' + contracts.childContracts.size() + ' child contracts...';

            contractedResult.issueTypes.add(ContractingIssue.UNEXPECTED_CHILD_CONTRACT_STATE);

        }

        if(amendedContract == null) {

            contractedResult.processingInformation += 'There is no amended contract...';

            contractedResult.issueTypes.add(ContractingIssue.NO_AMENDED_CONTRACT);

        }

        else if(amendedContract.contractedAmendmentQuote__c != opportunity.SBQQ__PrimaryQuote__c) {

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'Amended Contract ' + amendedContract.ContractNumber + ' has a "Contracted Amendment Quote" value';

            contractedResult.processingInformation += ' that does not match the primary quote of the contracted amendment opportunity...';

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + ' The value is ' + amendedContract.contractedAmendmentQuote__r.Name + ' however it appears it should be ' + opportunity.SBQQ__PrimaryQuote__r.Name + '...';

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'This could only be correct if two amendments were contracted within a short period of time...';

            contractedResult.issueTypes.add(ContractingIssue.UNEXPECTED_CONTRACTED_AMENDMENT_QUOTE);

        }

        else if(amendedContract.LastModifiedDate <= opportunity.contractedDateTime__c) {

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'Amended Contract ' + amendedContract.ContractNumber + ' was last modified at ';

            contractedResult.processingInformation += CventMyd_UtilityMethods.getFormattedDateTimeString(amendedContract.LastModifiedDate,true,true) + '...';

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'This is before the amendment opportunity was contracted...';

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'Hence it appears no contracting operation updated the amended contract...';

            contractedResult.issueTypes.add(ContractingIssue.CHILD_CONTRACT_NOT_UPDATED);

        }

        Id badSubscriptionId;

        if(amendedContract != null) {

            for(SBQQ__Subscription__c subscription : amendedContract.SBQQ__Subscriptions__r) {

                if(subscription.LastModifiedDate <= opportunity.contractedDateTime__c) {

                    badSubscriptionId = subscription.Id;

                    break;

                }

            }

        }

        if(badSubscriptionId != null) {

            contractedResult.processingInformation += CventMyd_UtilityMethods.doubleNewLine + 'One or more subscriptions on amended contract ' + amendedContract.ContractNumber;

            contractedResult.processingInformation += ' was last modified before the opportunity was contracted (example = \'' + badSubscriptionId + '\')...';

            contractedResult.issueTypes.add(ContractingIssue.SUBSCRIPTIONS_NOT_UPDATED);

        }

        contractedResult.success = (contractedResult.processingInformation == getResultHeader(opportunity));

        String asyncApexJobString = getAsyncApexJobString(crossReferenceApexJobs(opportunity));

        if(!asyncApexJobString.contains('We were not able to locate')) {

            contractedResult.success = false;

            contractedResult.issueTypes.add(ContractingIssue.FAILED_CONTRACTING_OPERATION);

        }        

        contractedResult.processingInformation += (contractedResult.success) ? '' : CventMyd_UtilityMethods.doubleNewLine + asyncApexJobString;

        return contractedResult;

    }
    global static List<AsyncApexJob> crossReferenceApexJobs(Opportunity opportunity) {

        List<AsyncApexJob> nearbyJobs = new List<AsyncApexJob>();

        for(AsyncApexJob job : failedApexJobs) {

            DateTime contractedDateTime = opportunity.contractedDateTime__c;

            DateTime jobCreatedTime = job.CreatedDate;

            Decimal hoursBetweenEvents = CventMyd_UtilityMethods.getHoursBetweenDateTimes(contractedDateTime,jobCreatedTime);

            Integer seconds = Math.abs(Math.round(hoursBetweenEvents * 3600));

            if(seconds <= 120) {

                nearbyJobs.add(job);

            }

        }

        return nearbyJobs;

    }

    global static String getAsyncApexJobString(List<AsyncApexJob> failedJobs) {

        String failedJobString = ( failedJobs.size() == 0 ) ? 'We were not able to locate any failed contracting operations...' : ('We found ' + failedJobs.size() + ' contracting operation failures that may be a match: ' + CventMyd_UtilityMethods.doubleNewLine);

        for(AsyncApexJob failedJob : failedJobs) {

            failedJobString += 'AsyncApexJob contracting operation with Id \'' + failedJob.Id + '\' was instantiated at ' + CventMyd_UtilityMethods.getFormattedDateTimeString(failedJob.CreatedDate,true,true) + CventMyd_UtilityMethods.doubleNewLine;

            failedJobString += 'It completed at ' + CventMyd_UtilityMethods.getFormattedDateTimeString(failedJob.CreatedDate,true,true) + CventMyd_UtilityMethods.doubleNewLine;

            failedJobString += 'Its extended status is:' + CventMyd_UtilityMethods.doubleNewLine + failedJob.ExtendedStatus + CventMyd_UtilityMethods.doubleNewLine;

        }

        return failedJobString;

    }    

    global static String getResultHeader(Opportunity opportunity) {

        String header = (opportunity.Primary_Quote_Type__c == 'Amendment') ? 'Amendment o' : 'O';

        header += 'pportunity with name \'' + opportunity.Name + '\'';

        header += ' and Id \'' + String.valueOf(opportunity.Id) + '\'';

        header += ' was marked contracted @ ' + CventMyd_UtilityMethods.getFormattedDateTimeString(opportunity.contractedDateTime__c,true,true) + '...';

        return header;

    }

    public static String getReportLinkHtml(Id reportRecordId) {

        String baseUrlString = String.valueOf(System.URL.getSalesforceBaseUrl());

        baseUrlString = baseUrlString.split('delegate=')[1];

        baseUrlString = baseUrlString.substringBeforeLast(']');     

        String linkUrl = '<a href="' + baseUrlString + '/' + String.valueOf(reportRecordId) + '">Link to Contract Monitoring Report<a/>';

        return linkUrl;     

    }    

    public static void sendContractingReportEmail(CpqAudit__c reportRecord, Map<Id,ContractedResult> opportunityIdToContractedResult) {

        String subjectString = reportRecord.Name;

        String htmlBodyString = 'Hi all,<br/><br/>';

        htmlBodyString += 'The master record for the latest monitoring report w.r.t. the operation of the \'Create Child Contract\' checkbox is linked below for your convenience...<br/><br/>';

        htmlBodyString += getReportLinkHtml(reportRecord.Id) + '<br/><br/>';

        htmlBodyString += reportRecord.processingInformation__c.substringBefore('issues found...').replace(CventMyd_UtilityMethods.newLine,'<br/>');

        htmlBodyString += ' issues detected...';

        htmlBodyString += '<br/><br/>Below, a summary of the issues discovered is shown...';
        
        htmlBodyString += '<br/><br/>You can either navigate to the above-linked report and view the issues recorded in the bottom-most related list,';
        
        htmlBodyString += ' or view the records from the below table...';

        htmlBodyString += '<br/><br/>' + getReportResultsTableHtml(opportunityIdToContractedResult);
        
        htmlBodyString += '<br/><br/>' + 'Thanks, ' + '<br/><br/>';

        htmlBodyString += 'Cvent CRM';

        CventMyd_UtilityMethods.sendEmail(CventMyd_ContractingMonitor.settings.additionalEmails, htmlBodyString, subjectString, reportRecord.Id);

    }

    public static void scheduleNextContractingMonitor(Boolean runNow, Set<Id> opportunityIds) {

        DateTime jobStartDateTime = getJobStartDateTime(runNow,opportunityIds);

        scheduleNextContractingMonitor(jobStartDateTime,opportunityIds);

    }    

    public static DateTime getJobStartDateTime(Boolean runNow, Set<Id> opportunityIds) {

        DateTime currentDateTime = DateTime.now();

        Date currentDate = Date.today();

        Time currentTime = currentDateTime.time();

        Time timeToStartJob = (runNow) ? currentDateTime.addSeconds(10).time() : ( (settings.timeToRunContractedMonitoring != null) ? settings.timeToRunContractedMonitoring : null ) ;

        // if timeToStartJob is null, then this means that current setting specifies duration

        // this also means that the this method is called without an attempt to run the job right now

        // this means that the next job will run a number of hours after 

        Date dateToRun;

        if(timeToStartJob == null) {

            Integer minutesUntilJobStart = Math.round(settings.hoursToCheckContractedMonitoring * 60);

            timeToStartJob = currentDateTime.addMinutes(minutesUntilJobStart).time();

            dateToRun = currentDateTime.addMinutes(minutesUntilJobStart).date();

        }

        else if(timeToStartJob != null) {

            dateToRun = (currentTime < timeToStartJob) ? Date.today() : Date.today().addDays(1) ;    

        }

        DateTime jobStartDateTime = DateTime.newInstance(dateToRun,timeToStartJob);

        return jobStartDateTime;

    }

    public static void scheduleNextContractingMonitor(DateTime jobStartDateTime, Set<Id> opportunityIds) {

        DateTime currentDateTime = DateTime.now();

        Decimal hoursUntilStart = CventMyd_UtilityMethods.getHoursBetweenDateTimes(currentDateTime,jobStartDateTime);

        Decimal secondsUntilStart = hoursUntilStart * 3600;

        String cronString = CventMyd_UtilityMethods.getCronString((Integer)secondsUntilStart);

        String jobName = getContractingMonitorJobName(jobStartDateTime,opportunityIds);

        CventMyd_ContractingMonitor generationMonitor = new CventMyd_ContractingMonitor(opportunityIds);

        System.schedule(jobName,cronString,generationMonitor);

    } 

}