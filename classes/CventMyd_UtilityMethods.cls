global without sharing class CventMyd_UtilityMethods {

    global class NoContactsException extends Exception {}

    public static void createTestAccounts(Integer count) {

        List<Account> accounts = new List<Account>();

        List<Address__c> addresses = new List<Address__c>();

        for(Integer i = 0; i < count; i++) {

            Account account = new Account(Name = getQleId());

            account.BillingStateCode = 'GA';

            account.BillingCountryCode = 'US';

            account.BillingPostalCode = '23423';     

            accounts.add(account);

        }

        insert accounts;

        for(Account account : accounts) {

            Address__c billingAddress = new Address__c(Account__c = account.Id);

            billingAddress.Type__c = 'Billing';

            billingAddress.Primary_Sync__c = true;

            addresses.add(billingAddress);

            Address__c shippingAddress = new Address__c(Account__c = account.Id);

            shippingAddress.Primary_Sync__c = true;

            shippingAddress.Type__c = 'Shipping';   

            addresses.add(shippingAddress);    

        }

        insert addresses; // nice in-line comment

        List<Contact> contacts = new List<Contact>();

        for(Account account : accounts) {

            System.debug('account.Id: ' + account.Id);

            Contact contact = new Contact(LastName = getQleId(), AccountId = account.Id);

            contacts.add(contact);

        }

        insert contacts;

        for(Contact contact : contacts) {

            System.debug('contact.AccountId: ' + contact.AccountId);

        }

    }

    webservice static String createTestOpportunities(String accountIdString, Boolean amendments) {

        Set<Id> accountIds = getIdSet(accountIdString,';');

        Integer counter = 0;

        List<SObject> contacts = [SELECT
        
            Id,AccountId
            
            FROM Contact
            
            WHERE AccountId IN: accountIds

        ];

        Map<Id,List<Id>> accountIdToContactIds = CventMyd_UtilityMethods.getParentIdToChildrenIdList(contacts,'AccountId');

        accountIds.removeAll(accountIdToContactIds.keySet());

        if(!accountIds.isEmpty()) {

            throw new NoContactsException('There needs to exist at least one contact for every account');

        }

        List<Opportunity> opportunities = new List<Opportunity>();

        for(Id accountId : accountIdToContactIds.keySet()) {

            String opportunityName = 'Test ';
            
            opportunityName += (amendments) ? 'Amendment' : 'NBB'; opportunityName += ' Opp ' + counter;

            if(accountIdToContactIds.keySet().size() == 1) {

                opportunityName = opportunityName.replace(String.valueOf(counter), CventMyd_UtilityMethods.getFormattedDateTimeString(Datetime.now(), false, true) );

            }

            Opportunity opp = new Opportunity(Name = opportunityName, AccountId = accountId);

            Id contactId = accountIdToContactIds.get(accountId)[0];

            opp.Product__c = 'Event';

            opp.Contact_Associated__c = contactId;

            opp.Contact_Role__c = 'Influencer';

            opp.StageName = 'Verbal';

            opp.CloseDate = Date.today().addDays(300);

            System.debug('opp: ' + opp);

            opportunities.add(opp);

            counter++;

        }

        insert opportunities;

        String returnUrl = CventMyd_Settings.orgBaseUrl;

        returnUrl += (opportunities.size() == 1) ? String.valueOf(opportunities[0].Id) : '';

        return returnUrl;

    }

    public static final String newLine = '\r\n';

    public static final String doubleNewLine = newLine + newLine;

    public static Map<Id,List<Opportunity>> contractIdToRenewalOpportunities = new Map<Id,List<Opportunity>>();

    public static List<String> getListOfStrings(String stringToSplit) {

        List<String> stringList = new List<String>();

        Integer i = 0;

        if(stringToSplit != null) {

            while(i < stringToSplit.length()) {
                        
                if(stringToSplit.charAt(i) == 10 || stringToSplit.charAt(i) == 13) {

                    stringToSplit = stringToSplit.replace(stringToSplit.subString(i,i+1),';');

                    Integer lengthBefore = stringToSplit.length();

                    stringToSplit = stringToSplit.replace(';;',';');

                    Integer lengthAfter = stringToSplit.length();

                    if(lengthAfter < lengthBefore) {i = i - 1;}

                }

                i = i + 1; 

            }

            stringList = stringToSplit.split(';');

        }

        if(stringList.isEmpty()) {stringList.add('');}
        
        return stringList;

    }

    public static Map<Integer,String> getStandardYearToEndDateFieldMap(SObject record) {

        Map<Integer,String> yearToEndDateFieldMap = new Map<Integer,String>();

        String objectName = String.valueOf(record.getSObjectType());

        String currentYearEndDateFieldName = (objectName == 'SBQQ__Quote__c') ? 'SBQQ__EndDate__c' : 'EndDate';

        yearToEndDateFieldMap.put(1,currentYearEndDateFieldName);

        yearToEndDateFieldMap.put(2,'Year_2_End_Date__c');

        yearToEndDateFieldMap.put(3,'Year_3_End_Date__c');

        yearToEndDateFieldMap.put(4,'Year_4_End_Date__c');

        yearToEndDateFieldMap.put(5,'Year_5_End_Date__c');

        return yearToEndDateFieldMap;

    }

    public static List<String> getEndDateFieldNames(SObject record) {
        
        List<String> endDateFieldNames = new List<String>();
        
        String objectName = String.valueOf(record.getSObjectType());
        
        endDateFieldNames.add( (objectName == 'SBQQ__Quote__c') ? 'SBQQ__EndDate__c' : 'EndDate' );
        
        for(Integer i = 2; i <=5; i++) {endDateFieldNames.add('Year_' + i + '_End_Date__c');}
        
        return endDateFieldNames;
        
    }      

    public static Map<Integer,String> getYearToEndDateFieldName(SObject record) {
        
        String objectName = String.valueOf(record.getSObjectType());
        
        Boolean parentContract = (objectName == 'Contract' && (Id)record.get('RecordTypeId') == CventMyd_Settings.parentContractRecordTypeId);
        
        Boolean newQuote = (objectName == 'SBQQ__Quote__c' && Integer.valueOf(record.get('Current_Year__c')) == 1);
        
        if(parentContract || newQuote) {
            
            return getStandardYearToEndDateFieldMap(record);
            
        }
        
        else {
            
            Integer currentYear = Integer.valueOf(record.get('Current_Year__c'));

            Integer finalYear = Integer.valueOf( (objectName == 'SBQQ__Quote__c') ? record.get('Contract_Term_Years__c') : record.get('Parent_Contract_Term_Years__c') );
            
            Map<Integer,String> yearToEndDateFieldName = new Map <Integer,String>();

            system.debug('this is the final year: ' + finalYear);

            system.debug('this is the current year: ' + currentYear);

            for(Integer i = 0; i <= (finalYear - currentYear) ; i++) {

                Integer year = i + currentYear;

                yearToEndDateFieldName.put(year,getEndDateFieldNames(record)[i]);

            }

            return yearToEndDateFieldName;
            
        }
        
    }

    public static Map<Integer,CventMyd_Outyear> getOutYearMap(SObject record) {

        Map<Integer,CventMyd_Outyear> outyearMap = new Map<Integer,CventMyd_Outyear>();

        String objectName = String.valueOf(record.getSObjectType());

        Integer currentYear = Integer.valueOf(record.get('Current_Year__c'));

        Integer finalYear = Integer.valueOf( (objectName == 'SBQQ__Quote__c') ? record.get('Contract_Term_Years__c') : record.get('Parent_Contract_Term_Years__c') );

        Map<Integer,String> yearToEndDateFieldName = getYearToEndDateFieldName(record);

        String currentYearEndDateFieldName = yearToEndDateFieldName.get(currentYear);

        System.debug('currentYearEndDateFieldName: ' + currentYearEndDateFieldName);

        Date previousYearEndDate = Date.valueOf(record.get(currentYearEndDateFieldName));

        System.debug('previousYearEndDate: ' + previousYearEndDate);

        for(Integer year = currentYear + 1; year <= finalYear; year++) {

            CventMyd_Outyear outyear = new CventMyd_Outyear();

            outyear.startDate = Date.today();

            System.debug('year: ' + year);

            System.debug('previousYearEndDate: ' + previousYearEndDate);

            outyear.startDate = previousYearEndDate.addDays(1);

            String endDateFieldName = String.valueOf(yearToEndDateFieldName.get(year));

            System.debug('endDateFieldName: ' + endDateFieldName);

            Date endDateFieldValue = Date.valueOf(record.get(endDateFieldName));

            System.debug('endDateFieldValue: ' + endDateFieldValue);

            if(endDateFieldValue == null) {

                if(objectName == 'Contract' && (Id)record.get('RecordTypeId') == CventMyd_Settings.childContractRecordTypeId) {

                    SObject parentContractRecord = (SObject)((Contract)record).Parent_Contract__r;

                    endDateFieldValue = Date.valueOf(parentContractRecord.get(getStandardYearToEndDateFieldMap(parentContractRecord).get(year)));

                    System.debug('endDateFieldValue from parent contract: ' + endDateFieldValue);

                }
                
                if(endDateFieldValue == null) {

                    endDateFieldValue = outyear.startDate.addMonths(12);

                    endDateFieldValue = endDateFieldValue.addDays(-1);

                }

            }

            outyear.endDate = endDateFieldValue;

            previousYearEndDate = outyear.endDate;

            outyearMap.put(year,outyear);

        }

        System.debug('outyearMap: ' + JSON.serialize(outyearMap));

        return outyearMap;

    }

    public static String getApexContext() {

        if(System.isBatch()) {return 'Batch';}

        else if(System.isQueueable()) {return 'Queueable';}

        else if(System.isScheduled()) {return 'Schedulable';}

        else if(System.isFuture()) {return 'Future';}

        else {return 'Synchronous';}

    }    

    public static Map<String,Long> getApexLimitsMap() {

        Map<String,Long> apexLimitsMap = new Map<String,Long>();

        apexLimitsMap.put('SOQL Queries', (Long)Limits.getQueries());

        apexLimitsMap.put('Query Rows', (Long)Limits.getQueryRows());

        apexLimitsMap.put('DML Statements', (Long)Limits.getDMLStatements());

        apexLimitsMap.put('DML Rows', (Long)Limits.getDMLRows());

        apexLimitsMap.put('CPU MS', (Long)Limits.getCpuTime());

        apexLimitsMap.put('Heap Size Bytes', (Long)Limits.getHeapSize());

        apexLimitsMap.put('Callouts', (Long)Limits.getCallouts());

        apexLimitsMap.put('Future Calls', (Long)Limits.getFutureCalls());

        apexLimitsMap.put('Queueable Jobs', (Long)Limits.getQueueableJobs());

        return apexLimitsMap;

    }

    public static String getApexLimitsString() {

        String apexLimitsString = ''; Map<String,Long> apexLimitsMap = getApexLimitsMap();

        for(String apexLimit : apexLimitsMap.keySet()) {

            apexLimitsString += apexLimit + ': ' + apexLimitsMap.get(apexLimit) + '\r\n';

        }

        apexLimitsString = apexLimitsString.substringBeforeLast('\r\n');

        return apexLimitsString;        

    }

    public static void updatePreviousQuotes(Map<Id,Id> quoteIdToNextQuote) {

        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();

        for(Id quoteId : quoteIdToNextQuote.keySet()) {

            quotes.add(new SBQQ__Quote__c(Id= quoteId, nextQuote__c = quoteIdToNextQuote.get(quoteId)));

        }

        update quotes;

    }        

    public static CventMyd_RecalculationWrapper getRecalculationWrapper(Set<Id> quoteIds, Boolean forceRecalculation) {

        CventMyd_RecalculationWrapper recalculationWrapper = new CventMyd_RecalculationWrapper();

        recalculationWrapper.mapOfQuotesToRecalculate = new Map<Id,Boolean>();

        recalculationWrapper.opportunityIdToPrimaryQuoteId = new Map<Id,Id>();

        recalculationWrapper.quotes = new List<SBQQ__Quote__c>();

        for(SBQQ__Quote__c quote : [SELECT               

            SBQQ__Opportunity2__r.SBQQ__AmendedContract__r.contractedAmendmentQuote__c,

            Id,recalculationToggler__c,jsonString__c,SBQQ__Opportunity2__c,SBQQ__Type__c,

            SBQQ__Opportunity2__r.SBQQ__PrimaryQuote__c,SBQQ__Primary__c,isLockedIntratermRenewal__c

            FROM SBQQ__Quote__c

            WHERE Id IN: quoteIds

        ]) {

            recalculationWrapper.quotes.add(quote);

            CventMyd_QuoteObject quoteObject = (CventMyd_QuoteObject)JSON.deserialize(quote.jsonString__c,CventMyd_QuoteObject.class);

            Boolean outyearProcessingComplete = (quoteObject.automationStage.outyearProcessingStage == CventMyd_QuoteAutomationStage.OutyearProcessingStage.OUTYEAR_PROCESSING_COMPLETE);

            if(!outyearProcessingComplete || forceRecalculation) {

                if(quote.recalculationToggler__c) {

                    recalculationWrapper.mapOfQuotesToRecalculate.put(quote.Id,false);

                }

                else if(!quote.recalculationToggler__c) {

                    recalculationWrapper.mapOfQuotesToRecalculate.put(quote.Id,true);

                }

            }

            if(quote.SBQQ__Primary__c && quote.SBQQ__Opportunity2__r.SBQQ__PrimaryQuote__c == null) {

                recalculationWrapper.opportunityIdToPrimaryQuoteId.put(quote.SBQQ__Opportunity2__c,quote.Id);

            }

        }

        return recalculationWrapper;

    }

    // method that takes in a map of Id --> boolean and returns a list of quotes to recalculate

    public static List<SBQQ__Quote__c> getListOfQuotesToRecalculate(Map<Id,Boolean> mapOfQuotesToRecalculate) {

        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();

        for(Id quoteId : mapOfQuotesToRecalculate.keySet()) {

            quotes.add(new SBQQ__Quote__c(Id= quoteId, recalculationToggler__c = mapOfQuotesToRecalculate.get(quoteId) ));

        }

        return quotes;

    }    

    // method that takes in a map of opportunity Id --> quote Id and returns a list of opportunities to update primary quote

    public static List<Opportunity> getOpportunitiesToUpdatePrimaryQuote(Map<Id,Id> opportunityIdToPrimaryQuoteId) {

        List<Opportunity> opportunities = new List<Opportunity>();

        for(Id oppId : opportunityIdToPrimaryQuoteId.keySet()) {

            opportunities.add(new Opportunity(Id= oppId, SBQQ__PrimaryQuote__c = opportunityIdToPrimaryQuoteId.get(oppId) ));

        }

        return opportunities;

    }

    // method that takes in a set of quote ids and recalculates quotes where appropriate 

    @future

    public static void recalculateQuotes(Set<Id> quoteIds, Boolean forceRecalculation) {

        CventMyd_RecalculationWrapper recalculationWrapper = getRecalculationWrapper(quoteIds,forceRecalculation);

        List<SBQQ__Quote__c> quotesToRecalculate = getListOfQuotesToRecalculate(recalculationWrapper.mapOfQuotesToRecalculate);

        if(quotesToRecalculate.size() > 0) {

            update quotesToRecalculate;

        }

    }    

    // method that takes in a set of quote ids and updates opportunites where the primary quote field is null

    @future

    public static void updatePrimaryQuoteFieldOnOpportunities(Set<Id> quoteIds, Boolean forceRecalculation) {

        CventMyd_RecalculationWrapper recalculationWrapper = getRecalculationWrapper(quoteIds,forceRecalculation);

        List<Opportunity> opportunitiesToUpdate = getOpportunitiesToUpdatePrimaryQuote(recalculationWrapper.opportunityIdToPrimaryQuoteId);

        if(opportunitiesToUpdate.size() > 0) {

            update opportunitiesToUpdate;

        }

    }

    @future

    public static void uncheckPrimaryOnQuotes(Set<Id> quoteIds) {

        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();

        List<SBQQ__Quote__c> existingQuotes = [SELECT Id,SBQQ__Primary__c FROM SBQQ__Quote__c WHERE IsDeleted = FALSE AND Id IN: quoteIds];

        for(SBQQ__Quote__c quote : existingQuotes) {

            if(quote.SBQQ__Primary__c) {

                quotes.add(new SBQQ__Quote__c(Id= quote.Id, SBQQ__Primary__c = false));

            }

        }

        update quotes;

    }

    public static Map<String,Boolean> getQuoteStatusMap(CventMyd_QuoteObject quoteObject) {

        Map<String,Boolean> quoteStatusMap = new Map<String,Boolean>();

        quoteStatusMap.put('lastUpdatedByTrigger',

        (quoteObject.automationStage.codeStatus == CventMyd_QuoteAutomationStage.CodeStatus.LAST_UPDATED_BY_TRIGGER));

        quoteStatusMap.put('calculationCycleFinished',

        (quoteObject.automationStage.codeStatus == CventMyd_QuoteAutomationStage.CodeStatus.CALCULATION_CYCLE_FINISHED));

        quoteStatusMap.put('outyearProcessingInProgress',

        (quoteObject.automationStage.outyearProcessingStage == CventMyd_QuoteAutomationStage.OutyearProcessingStage.OUTYEAR_PROCESSING_IN_PROGRESS));

        quoteStatusMap.put('outyearProcessingComplete',

        (quoteObject.automationStage.outyearProcessingStage == CventMyd_QuoteAutomationStage.OutyearProcessingStage.OUTYEAR_PROCESSING_COMPLETE));

        quoteStatusMap.put('currentYearFinished',

        (quoteObject.automationStage.outyearProcessingStage == CventMyd_QuoteAutomationStage.OutyearProcessingStage.CURRENT_YEAR_FINISHED));

        quoteStatusMap.put('newlyInsertedVariable',

        (quoteObject.automationStage.outyearProcessingStage == CventMyd_QuoteAutomationStage.OutyearProcessingStage.NEWLY_INSERTED_VARIABLE));

        quoteStatusMap.put('newlyInsertedNonVariable',

        (quoteObject.automationStage.outyearProcessingStage == CventMyd_QuoteAutomationStage.OutyearProcessingStage.NEWLY_INSERTED_NON_VARIABLE));        

        return quoteStatusMap;

    }

    public static Map<String,Boolean> getQuoteStatusMap(SBQQ__Quote__c quote) {

        CventMyd_QuoteObject quoteObject = getQuoteObject(quote);

        return getQuoteStatusMap(quoteObject);

    }    

    public static CventMyd_QuoteObject getQuoteObject(SBQQ__Quote__c quote) {
       
        if(quote.jsonString__c != null) {

            return (CventMyd_QuoteObject)JSON.deserialize(quote.jsonString__c,CventMyd_QuoteObject.class);

        }

        else {

            return null;

        }

    }

    public static CventMyd_QuoteObject getQuoteObject(String jsonString) {

        if(jsonString != null) {

            return (CventMyd_QuoteObject)JSON.deserialize(jsonString,CventMyd_QuoteObject.class);

        }

        else {

            return null;

        }

    }

    public static CventMyd_QuoteLineObject getQuoteLineObject(SBQQ__QuoteLine__c quoteLine) {

        return (CventMyd_QuoteLineObject)JSON.deserialize(quoteLine.jsonString__c,CventMyd_QuoteLineObject.class);

    }

    public static CventMyd_QuoteLineObject getQuoteLineObject(String jsonString) {

        return (CventMyd_QuoteLineObject)JSON.deserialize(jsonString,CventMyd_QuoteLineObject.class);

    }    

    public static List<Integer> getQuoteOutyears(SBQQ__Quote__c quote, Boolean getAllYears) {

        List<Integer> years = new List<Integer>();

        if(quote.Multiple_Years_Commitment__c) {

            Integer firstYear = (quote.SBQQ__Type__c == 'Renewal') ? (Integer)quote.Current_Year__c : (Integer)quote.Current_Year__c + 1;

            if(getAllYears) {

                Integer finalYear = Integer.valueOf(quote.Contract_Term_Years__c);

                for(Integer year = firstYear; year <= finalYear; year++) {years.add(year);}

            }

            else if(quote.SBQQ__Type__c == 'Renewal') {years.add(firstYear);}

        }

        return years;

    }

    public static Map<Id,List<Integer>> getQuoteIdToAllOutyears(List<SBQQ__Quote__c> quotes) {

        Map<Id,List<Integer>>   quoteIdToOutyears = new Map<Id,List<Integer>>();

        for(SBQQ__Quote__c quote : quotes) {

            quoteIdToOutyears.put(quote.Id,getQuoteOutyears(quote,true));

        }

        return quoteIdToOutyears;

    }

    public static Integer getExpectedNumberOfQuoteLineGroups(SBQQ__Quote__c quote) {

        List<Integer> outyears = getQuoteOutyears(quote,true);

        return (quote.SBQQ__Type__c == 'Amendment') ? outyears.size() + 1 : outyears.size() ;

    }

    public static CpqAudit__c getAuditRecord(SBQQ__Quote__c quote, Boolean isInsertion, String apexLimitsString) {

        CpqAudit__c auditRecord = new CpqAudit__c(quote__c = quote.Id);

        auditRecord.Name = quote.Name + ( ( (quote.createdFromLegacyContract__c)) ? ' Legacy' : '') + ((isInsertion) ? ' insertion' : ' status check');

        auditRecord.Name += '; Type: ' + quote.SBQQ__Type__c;

        auditRecord.Name += (quote.Multiple_Years_Commitment__c) ? ', Variable' : ', Non-Variable';

        auditRecord.Name += '; Cloned: ' + String.valueOf(quote.SBQQ__Source__c != null);

        auditRecord.processingInformation__c = '==================================================';

        auditRecord.processingInformation__c += '\r\n' + 'Apex Context: ' + CventMyd_UtilityMethods.getApexContext();

        auditRecord.processingInformation__c += '\r\n' + 'Limits after insertion: ' + '\r\n' + apexLimitsString;

        auditRecord.processingInformation__c += '\r\n' + 'Trigger Size: ' + Trigger.size;

        auditRecord.processingInformation__c += '\r\n' + '==================================================';

        auditRecord.processingInformation__c += '\r\n' + 'User Id: ' + UserInfo.getUserId();

        auditRecord.processingInformation__c += '\r\n' + 'User Name: ' + UserInfo.getName();

        auditRecord.processingInformation__c += '\r\n' + 'User Email: ' + UserInfo.getUserEmail();

        auditRecord.processingInformation__c += '\r\n' + 'Time Zone: ' + UserInfo.getTimeZone();

        CventMyd_QuoteObject quoteObject = (CventMyd_QuoteObject)JSON.deserialize(quote.jsonString__c,CventMyd_QuoteObject.class);

        auditRecord.statusCheckCount__c = quote.statusCheckCount__c;

        auditRecord.outyearProcessingStage__c = String.valueOf(quoteObject.automationStage.outyearProcessingStage);

        auditRecord.statusCheckCount__c = 0;

        return auditRecord;

    }

    // get master chain audit record 

    public static CpqAudit__c getAuditRecord(Id chainMasterRecordId, DateTime scheduledFinishDateTime, String jobName) {

        CpqAudit__c auditRecord;

        if(chainMasterRecordId == null) {

            auditRecord = new CpqAudit__c();

            auditRecord.Name = jobName;

            auditRecord.scheduledFinishTime__c  = scheduledFinishDateTime;

            auditRecord.isChainMaster__c = true;

            auditRecord.jobsInChain__c = (!Test.isRunningTest()) ? 0 : 1 ;

        }

         else if(chainMasterRecordId != null) {

            auditRecord = [SELECT

                Id,jobsInChain__c,processingInformation__c,scheduledFinishTime__c,Name

                FROM CpqAudit__c

                WHERE Id =: chainMasterRecordId

            ];

            auditRecord.jobsInChain__c = auditRecord.jobsInChain__c + 1;

         }

        return auditRecord;

    }

    public static CpqAudit__c getAuditRecord(Id chainMasterRecordId, Id contractId, Id previousChainLinkId) {

        CpqAudit__c auditRecord = new CpqAudit__c(chainMaster__c = chainMasterRecordId, contract__c = contractId);

        auditRecord.Name = getRenewalChainLinkJobName(DateTime.now());

        auditRecord.previousJob__c = previousChainLinkId;

        return auditRecord;

    }

    public static String getRenewalChainLinkJobName(DateTime startDateTime) {

        return 'Renewal Chain Link @ ' + getFormattedDateTimeString(startDateTime,true,true);

    }

    public static String getRenewalChainMasterJobName(DateTime startDateTime, DateTime endDateTime) {

        String jobName = 'Renewal Chain Master ';

        String startTimeString = getFormattedDateTimeString(startDateTime,true,false);

        String yearSubstring = '/' + String.valueOf(endDateTime.year());

        String endTimeString = (getFormattedDateTimeString(endDateTime,true,true)).replace(yearSubstring,'');

        jobName += startTimeString + ' - ' + endTimeString;

        return jobName;

    }

    public static String getFormattedDateTimeString(DateTime dateTimeVar, Boolean showSeconds, Boolean showTimeZone) {

        String dateFormatString = (showSeconds) ? 'MM/dd/yyyy hh:mm:ss aaa' : 'MM/dd/yyyy hh:mm aaa';

        String timeZoneAbbreviation = UserInfo.getTimeZone().getDisplayName();

        timeZoneAbbreviation = timeZoneAbbreviation.replaceAll('\\B.|\\P{L}', '').toUpperCase();

        String timeZoneString = UserInfo.getTimeZone().toString();

        String dateTimeString = dateTimeVar.format(dateFormatString,timeZoneString);

        dateTimeString += (showTimeZone) ? ' ' + timeZoneAbbreviation : '' ;

        return dateTimeString;

    }

    public static void abortSchedulableJobs(Boolean useFuture, String previousJobName, String currentJobName, Boolean abortAllJobs) {

        if(useFuture) {

            abortSchedulableJobsFuture(previousJobName,currentJobName,abortAllJobs);

        }

        else {

            abortSchedulableJobs(previousJobName,currentJobName,abortAllJobs);

        }

    }

    @future

    public static void abortSchedulableJobsFuture(String previousJobName, String currentJobName, Boolean abortAllJobs) {

        abortSchedulableJobs(previousJobName,currentJobName,abortAllJobs);

    }

    public static void abortSchedulableJobs(String previousJobName, String currentJobName, Boolean abortAllJobs) {

        String queryString = 'SELECT Id,CronJobDetail.Name';

        queryString += ' FROM CronTrigger WHERE';

        Set<String> jobNamesToAbort = new Set<String>{previousJobName,currentJobName};

        for(CpqAudit__c auditRecord : [SELECT

            Id,Name,processingInformation__c

            FROM CpqAudit__c WHERE Name LIKE 'Abortion failure%'

            ORDER BY CreatedDate DESC

            LIMIT 5

        ]) {

            for(String jobName : auditRecord.processingInformation__c.split(';')) {

                jobNamesToAbort.add(jobName);

            }

        }

        if(!abortAllJobs) {

            queryString += ' CronJobDetail.Name IN: jobNamesToAbort';

        }

        else if(abortAllJobs) {

            queryString += ' CronJobDetail.NAME LIKE \'Renewal Quote Job Master%\'';

            queryString += ' OR CronJobDetail.NAME LIKE \'Renewal Chain Master%\'';

            queryString += ' OR CronJobDetail.NAME LIKE \'%status check; Type:%\'';

            queryString += ' OR CronJobDetail.NAME LIKE \'Renewal Chain Link%\'';

        }

        List<CronTrigger> cronTriggers = Database.query(queryString);

        try {

            for(CronTrigger cronTrigger : cronTriggers) {

                System.abortJob(cronTrigger.Id);

            }

        }

        catch(Exception e) {

            if(!cronTriggers.isEmpty()) {

                String dateTimeString = getFormattedDateTimeString(DateTime.now(),true,false);

                String jobNameString = '';

                for(CronTrigger cronTrigger : cronTriggers) {

                    jobNameString = cronTrigger.CronJobDetail.Name + ';';

                }

                CpqAudit__c auditRecord = new CpqAudit__c(Name = 'Abortion failure @ ' + dateTimeString);

                auditRecord.processingInformation__c = jobNameString;

                insert auditRecord;                

            }

        }

    }

    public static String getCronString(Integer secondsUntilJobStart) {

        DateTime currentDateTime = System.now();

        DateTime dateTimeForNextJob = currentDateTime.addSeconds(secondsUntilJobStart);

        Integer seconds = dateTimeForNextJob.second();

        Integer minutes = dateTimeForNextJob.minute();

        Integer hours = dateTimeForNextJob.hour();

        Integer dayOfMonth = dateTimeForNextJob.day();

        Integer month = dateTimeForNextJob.month();

        Integer year = dateTimeForNextJob.year();

        String cronString = seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ?' + ' ' + year;   

        return cronString;  

    }

    public static Decimal getHoursBetweenDateTimes(DateTime dateTime0, DateTime dateTime1) {

        Long dateTime0Ms = dateTime0.getTime();

        Long dateTime1Ms = dateTime1.getTime();

        Long msDifference = dateTime1Ms - dateTime0Ms;

        Long secondsDifference = msDifference / 1000;
      
        return ((Decimal)secondsDifference).divide(3600,5);

    }

    public static Decimal getMinutesBetweenDateTimes(DateTime dateTime0, DateTime dateTime1) {

        Decimal hours = getHoursBetweenDateTimes(dateTime0,dateTime1);

        return hours * 60;

    }

    public static Decimal getSecondsBetweenDateTimes(DateTime dateTime0, DateTime dateTime1) {

        Decimal hours = getHoursBetweenDateTimes(dateTime0,dateTime1);

        return hours * 3600;        

    }
    
    public static String getExceptionString(Exception e) { 

        String apexLimitsString = CventMyd_UtilityMethods.getApexLimitsString();

        String exceptionString = newLine + '==================================================';

        exceptionString += newLine + '##EXCEPTION##';

        exceptionString += newLine + 'CAUSE: '+ e.getCause();

        exceptionString += newLine + 'MESSAGE: ' + e.getMessage();

        exceptionString += newLine + 'STACK TRACE: ' + e.getStackTraceString();

        exceptionString += newLine + 'TYPE NAME: ' + e.getTypeName();

        exceptionString += newLine + '==================================================';

        exceptionString += newLine + 'Apex Limits: ' + newLine;

        exceptionString += apexLimitsString;

        return exceptionString; 

    }    

    @future

    public static void deleteOpportunities(Set<Id> opportunityIds) {

        List<Opportunity> opportunities = new List<Opportunity>();

        for(Id oppId : opportunityIds) {opportunities.add(new Opportunity(Id = oppId));}

        delete opportunities;

    }  

    public static String getQleId() {

        String characterString = 'abcdefghijklmnopqrstuvxwz';

        return getFiveRandomIntegerString() + '_' + getThreeRandomLetterString() + '_' + getFiveRandomIntegerString();

    }

    public static String getFiveRandomIntegerString() {

        String randomIntegerString = '';

        for(Integer i = 0; i < 5; i++) {

            Double randomDouble = Math.random() * (9);

            Integer randomInteger = Math.round(randomDouble);           

            randomIntegerString = randomIntegerString + String.valueOf(randomInteger);

        }

        return randomIntegerString;

    }

    public static String getThreeRandomLetterString() {

        String characterString = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

        String randomCharacterString = '';

        for(Integer i = 0; i < 3; i++) {

            Double randomDouble = Math.random() * (characterString.length() - 1);

            Integer randomInteger = Math.round(randomDouble);           

            randomCharacterString = randomCharacterString + characterString.subString(randomInteger,randomInteger + 1);

        }

        return randomCharacterString;

    }

    webservice static void recalculateQuote(Id quoteId) {

        SBQQ__Quote__c quote = [SELECT Id,recalculationToggler__c FROM SBQQ__Quote__c WHERE Id =: quoteId];

        if(quote.recalculationToggler__c) {

          quote.recalculationToggler__c = false;

        }

        else if(!quote.recalculationToggler__c) {

          quote.recalculationToggler__c = true;

        }  

        update quote;  

    }

    webservice static void clearSubscriptionJsonStrings(Id contractId) {

        List<SBQQ__Subscription__c> subscriptions = [SELECT Id FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c =: contractId];

        for(SBQQ__Subscription__c subscription : subscriptions) {

            subscription.jsonString__c = null;

        }

        update subscriptions;

    }    

    webservice static void closeWinOpportunity(Id opportunityId) {
        Opportunity opportunity = [SELECT Id,
            SBQQ__PrimaryQuote__c,
            SBQQ__PrimaryQuote__r.Contract_Executed__c
            FROM Opportunity WHERE Id =: opportunityId
        ];
        if(!opportunity.SBQQ__PrimaryQuote__r.Contract_Executed__c) {
            SBQQ__Quote__c quote = new SBQQ__Quote__c(Contract_Executed__c = true, Id = opportunity.SBQQ__PrimaryQuote__c);
            update quote;
        }
        opportunity.StageName = 'Closed Won';
        update opportunity;
    }

    public class TwinFieldException extends Exception {}

    public static Set<String> getSubscriptionQuoteLineTwinFieldNames() {       

        Map<String,Schema.SObjectField> quoteLineFieldNameToField = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap();
    
        Map<String,Schema.SObjectField> subscriptionFieldNameToField = Schema.getGlobalDescribe().get('SBQQ__Subscription__c').getDescribe().fields.getMap();

        Set<String> twinFields = new Set<String>();

        for(String fieldName0 : quoteLineFieldNameToField.keySet()) {

            Schema.SObjectField field = quoteLineFieldNameToField.get(fieldName0);

            String fieldType0 = getFieldType('SBQQ__QuoteLine__c',fieldName0,field);

            Boolean isString0 = (fieldType0 == 'PICKLIST' || fieldType0 == 'STRING');

            for(String fieldName1 : subscriptionFieldNameToField.keySet()) {
            
                if(fieldName0 == fieldName1 && fieldName0.containsIgnoreCase('__c')) {

                    field = subscriptionFieldNameToField.get(fieldName0);
                
                    String fieldType1 = getFieldType('SBQQ__Subscription__c',fieldName1,field);

                    Boolean isString1 = (fieldType1 == 'PICKLIST' || fieldType1 == 'STRING');

                    if(fieldType1 == fieldType0 || isString0 && isString1) {

                        twinFields.add(fieldName0);

                    }

                    else {

                        String exceptionString = 'Quote Line ---> Subscription twin fields should be the same type.';

                        exceptionString += ' For field ' + fieldName0;

                        exceptionString += ', ' + fieldType0 + ' != ' + fieldType1;

                        throw new TwinFieldException(exceptionString);

                    }
                    
                }

            }
            
        }

        return twinFields;   

    }

    public static String getFieldType(String objectName, String fieldName, Schema.SObjectField field) {

        Map<String,Schema.SObjectField> fieldNameToField = (field == null) ? Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap() : null ;

        field = (field != null) ? field : fieldNameToField.get(fieldName);

        Schema.DescribeFieldResult describeFieldResult = field.getDescribe();

        return String.valueOf(describeFieldResult.getType());

    }

    public static String getFieldNamesStringFromStringSet(Set<String> fieldNames) {

        String fieldNamesString = '';

        for(String fieldName : fieldNames) {

            fieldNamesString += fieldName + ',';

        }

        fieldNamesString = fieldNamesString.substringBeforeLast(',');

        return fieldNamesString;

    }

    public static Integer queryScheduledJobCount() {

        Integer scheduledJobCount = [SELECT

            count()

            FROM CronTrigger

            WHERE (STATE = 'waiting' or STATE = 'queued' or STATE = 'executing')

                AND (CronJobDetail.JobType = '7')

        ];

        return scheduledJobCount;

    }

    public static void sendEmail(List<String> additionalToAddresses, String htmlBodyString, String subjectString, String whatId) {

        Messaging.SingleEmailMessage singleEmailMessage = getSingleEmailMessage(additionalToAddresses, htmlBodyString, subjectString, whatId);

        sendEmail(singleEmailMessage);

    }

    public static Messaging.SingleEmailMessage getSingleEmailMessage(List<String> additionalToAddresses, String htmlBodyString, String subjectString, String whatId) {

        Messaging.SingleEmailMessage singleEmailMessage = new Messaging.SingleEmailMessage();

        String[] toAddresses = CventMyd_Settings.administratorEmails;

        if(additionalToAddresses != null && !additionalToAddresses.isEmpty()) {

            toAddresses.addAll(additionalToAddresses);

        }

        singleEmailMessage.setToAddresses(toAddresses);

        if(whatId != null) {

            singleEmailMessage.setWhatId(whatId);

        }

        singleEmailMessage.setSaveAsActivity(false);

        singleEmailMessage.setSubject(subjectString);

        singleEmailMessage.setHtmlBody(htmlBodyString);

        return singleEmailMessage;

    }

    public static void sendEmail(Messaging.SingleEmailMessage singleEmailMessage) {

        Messaging.reserveSingleEmailCapacity(1);

        Messaging.SingleEmailMessage[] singleEmailMessages = new Messaging.SingleEmailMessage[] {singleEmailMessage};

        Messaging.SendEmailResult[] sendEmailResults = Messaging.sendEmail(singleEmailMessages);

    }

    public static Map<Id,List<SObject>> getParentIdToChildrenRecords(List<SObject> childrenRecords, String lookupFieldName) {

        Map<Id,List<Id>> parentRecordIdToChildrenRecordIds = getParentIdToChildrenIdList(childrenRecords,lookupFieldName);

        Map<Id,SObject> childRecordIdToChildRecord = new Map<Id,SObject>(childrenRecords);

        Map<Id,List<SObject>> parentRecordIdToChildrenRecords = new Map<Id,List<SObject>>();

        for(Id parentRecordId : parentRecordIdToChildrenRecordIds.keySet()) {

            List<SObject> theseChildrenRecords = new List<SObject>();

            for(Id childRecordId : parentRecordIdToChildrenRecordIds.get(parentRecordId)) {

                theseChildrenRecords.add(childRecordIdToChildRecord.get(childRecordId));

            }

            parentRecordIdToChildrenRecords.put(parentRecordId,theseChildrenRecords);

        }

        return parentRecordIdToChildrenRecords;

    }
    
    public static Map<Id,Set<Id>> getParentIdToChildrenIdSet(List<SObject> childrenRecords, String lookupFieldName) {

        Map<Id,List<Id>> parentRecordIdToChildrenRecordIdList = getParentIdToChildrenIdList(childrenRecords,lookupFieldName);

        Map<Id,Set<Id>> parentRecordIdToChildrenRecordIdSet = new Map<Id,Set<Id>>();

        for(Id parentRecordId : parentRecordIdToChildrenRecordIdList.keySet()) {

            Set<Id> childrenRecordIds = new Set<Id>(parentRecordIdToChildrenRecordIdList.get(parentRecordId));

            parentRecordIdToChildrenRecordIdSet.put(parentRecordId,childrenRecordIds);

        }

        return parentRecordIdToChildrenRecordIdSet;        

    }    

    public static Map<Id,List<Id>> getParentIdToChildrenIdList(List<SObject> childrenRecords, String lookupFieldName) {

        Map<Id,List<Id>> parentRecordIdToChildrenRecordIds = new Map<Id,List<Id>>();

        for(SObject record : childrenRecords) {

            Id parentRecordId = (Id)record.get(lookupFieldName);

            if(parentRecordIdToChildrenRecordIds.get(parentRecordId) == null) {

                parentRecordIdToChildrenRecordIds.put(parentRecordId,new List<Id>());

            }

            parentRecordIdToChildrenRecordIds.get(parentRecordId).add(record.Id);

        }

        return parentRecordIdToChildrenRecordIds;

    }

    public static String getIdString(List<Id> recordIds, String separator) {

        String idString = '';

        for(Id recordId : recordIds) {idString += String.valueOf(recordId) + separator;}

        return idString;

    }    

    public static String getIdString(Set<Id> recordIds, String separator) {

        String idString = '';

        for(Id recordId : recordIds) {idString += String.valueOf(recordId) + separator;}

        return idString;

    }

    public static String getIdString(List<SObject> records, String separator) {

        String idString = '';

        Set<Id> recordIds = getIdSet(records);

        for(Id recordId : recordIds) {idString += String.valueOf(recordId) + separator;}

        return idString;

    }

    public static Set<Id> getIdSet(List<SObject> records) {

        Map<Id,SObject> recordIdToSObject = new Map<Id,SObject>(records);

        return recordIdToSObject.keySet();

    }

    public static Set<Id> getIdSet(List<SObject> records, String lookupFieldName) {

        Set<Id> recordIds = new Set<Id>();

        for(SObject record : records) {

            recordIds.add((Id)record.get(lookupFieldName));

        }

        return recordIds;

    }

    public static Set<Id> getIdSet(String idString, String separator) {

        Set<Id> ids = new Set<Id>();

        for(String idStr : idString.split(separator)) {

            ids.add(Id.valueOf(idStr));

        }

        return ids;

    }

    public static Set<Id> getIdSet(Set<String> idStrings) {

        Set<Id> ids = new Set<Id>();

        for(String idStr : idStrings) {

            ids.add(Id.valueOf(idStr));

        }

        return ids;

    }

    public static Boolean getBooleanFromProbability(Decimal probability) {

        Decimal randomDecimal = Math.random();

        return (randomDecimal < probability);

    }

    public static List<Object> getOldAndNewValues(SObject newRecord, String fieldApiName) {

        List<Object> oldValueNewValue = new List<Object>();

        SObject oldRecord = Trigger.oldMap.get(newRecord.Id);

        oldValueNewValue.add(oldRecord.get(fieldApiName));

        oldValueNewValue.add(newRecord.get(fieldApiName));

        return oldValueNewValue;

    }

    public static Boolean didFieldChange(SObject newRecord, String fieldApiName) {

        List<Object> oldValueNewValue = getOldAndNewValues(newRecord,fieldApiName);

        return (oldValueNewValue[0] != oldValueNewValue[1]);

    }

    @future

    public static void renewContractFuture(Id contractId) {

        CventMyd_ContractAmendmentController.contractIdsBeingAmended.add(contractId);

        update new Contract(Id = contractId,SBQQ__RenewalQuoted__c = true);

    }

    public static Map<Integer,CventMyd_Outyear> getFullYearToDatesMap(SBQQ__Quote__c quote) {

        CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(quote);

        Map<Integer,CventMyd_Outyear> yearToDates = quoteObject.outyearMap.clone();

        CventMyd_Outyear currentYear = new CventMyd_Outyear();

        currentYear.startDate = quote.SBQQ__StartDate__c;

        currentYear.endDate = quote.SBQQ__EndDate__c;

        yearToDates.put((Integer)quote.Current_Year__c,currentYear);

        return yearToDates;  

    }

    public static List<Integer> getYearsSorted(SBQQ__Quote__c quote) {

        Map<Integer,CventMyd_Outyear> yearToDates = getFullYearToDatesMap(quote);

        List<Integer> yearsSorted = new List<Integer>(yearToDates.keySet());

        yearsSorted.sort();

        System.debug('yearsSorted: ' + yearsSorted);

        return yearsSorted;

    }

    public static Integer getDaysBetween(Date startDate, Date endDate) {

        Integer daysBetween = startDate.daysBetween(endDate);

        daysBetween++;

        if(Date.isLeapYear(endDate.year())) {

            if(endDate.month() > 2 || endDate.month() == 2 && endDate.day() == 29) {

                daysBetween--;

            }

        }

        return daysBetween;

    }    

    public static String getTriggerContextString() {
        String contextString = '';
        if(Trigger.isExecuting) {
            contextString = 'Event: ';
            contextString += (Trigger.isBefore) ? ' before' : ' after';
            contextString += (Trigger.isInsert) ? ' insert' : '';
            contextString += (Trigger.isUpdate) ? ' update' : '';
            contextString += (Trigger.isDelete) ? ' delete' : '';
            contextString += (Trigger.isUndelete) ? ' undelete' : '';
            if(Trigger.new != null) {
                contextString += ', Trigger.new.size(): ' + String.valueOf(Trigger.new.size());
            }
            if(Trigger.old != null) {
                contextString += ', Trigger.old.size(): ' + String.valueOf(Trigger.old.size());
            }
            return contextString;
        }
        else {
            return 'Trigger is not executing...';
        }
    }   

    public static String replaceJsonStringKeyValue(String jsonString, String keyName, String newValue, Integer replacementIndex) {
        String arrayString = getArrayString(jsonString,keyName);
        List<String> values = getArrayValues(arrayString);
        List<Integer> indicesToReplace = new List<Integer>{};
        if(replacementIndex != -1) {indicesToReplace.add(replacementIndex);}
        else{
            for(Integer i = 0; i < values.size(); i++) {
                indicesToReplace.add(i);
            }
        }
        for(Integer index : indicesToReplace) {
            values[index] = newValue;
        }
        String replacementSubstring = '';
        Integer index = 0;
        for(String value : values) {
            replacementSubstring += value;
            if(index != (values.size() - 1)) {
                replacementSubstring += ',';
            }
            index++;
        }
        replacementSubstring = '[' + replacementSubstring + ']';
        replacementSubstring = '"' + keyName + '":' + replacementSubstring;
        String targetSubstring = '"' + keyName + '":' + arrayString;
        System.debug('targetSubstring: ' + targetSubString);
        System.debug('replacementSubstring: ' + replacementSubstring);
        jsonString = jsonString.replace(targetSubString,replacementSubstring);
        return jsonString;
    }     
     
    public static String getArrayString(String jsonString, String keyName) {
        String arrayString;
        if(jsonString.containsIgnoreCase(keyName)) {
            arrayString = jsonString.substringBetween(keyName + '":[',']');
            arrayString = '[' + arrayString + ']';
        }
        return arrayString;
    }

    public static List<String> getArrayValues(String jsonString, String keyName) {
        String arrayString = getArrayString(jsonString,keyName);
        return getArrayValues(arrayString);
    }

    public static List<String> getArrayValues(String arrayString) {
        arrayString = arrayString.substring(1,(arrayString.length()-1));
        List<String> values = new List<String>();
        List<String> splittedSubstrings = arrayString.split(',');
        Boolean skip = false;
        Integer index = 0;
        for(String str : splittedSubstrings) {
            if(skip) {skip = false; continue;}
            if( (str.charAt(0) == 34) && (str.charAt(str.length()-1) != 34) ) {
                String joinedValue = str + ',' + splittedSubstrings[index + 1];
                values.add(joinedValue);
                skip = true;
            }
            else {
                values.add(str);
            }
            index++;
        }
        return values;     
    }

    public static Set<Id> getKeyIdsToValueId(Map<Id,Id> keyIdToValueId, Id valueId, Boolean enforceOneToOne) {
        Set<Id> keyIds = new Set<Id>();
        for(Id keyId : keyIdToValueId.keySet()) {
            Id valueId0 = keyIdToValueId.get(keyId);
            if(valueId == valueId0) {
                keyIds.add(keyId);
            }
        }
        if(enforceOneToOne && keyIds.size() > 1) {
            String exceptionString = 'There are ';
            exceptionString += String.valueOf(keyIds.size()) + ' keys mapped to the value \'';
            exceptionString += String.valueOf(valueId) + '\'';
            exceptionString += ', where the keys were retrieved with one-to-one mapping expected';
            throw new CventMyd_UtilityMethods.TwinFieldException(exceptionString);
        }
        return keyIds;
    }
    
    public static Set<Integer> getIntegerSetBetween(Integer start, Integer finish) {
        Set<Integer> integerSet = new Set<Integer>();
        for(Integer i = start; i <= finish; i++) {
            integerSet.add(i);
        }
        return integerSet;
    }
    
    public static List<Integer> getIntegerListBetween(Integer start, Integer finish) {
        Set<Integer> integerSet = getIntegerSetBetween(start,finish);
        List<Integer> integerList = new List<Integer>(integerSet);
        integerList.sort();
        return integerList;
    }   

    public class Cvent_Exception extends Exception {}   

}