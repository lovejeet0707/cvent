global without sharing class CventMyd_RecalculateQuotes implements Schedulable {

	global Map<Id,Integer> quoteIdToRecalculationAttempts;

	global List<SBQQ__Quote__c> quotes;

	global Settings settings;

	global Integer jobNumber;

	global class RecalculationException extends Exception {}

	global class Settings {

		global Boolean forceRecalculation;

		global Integer attemptsPerQuote;

		global Integer quotesPerAttempt;

		global Integer secondsBetweenJobs;

		global Decimal minutesBeforeFirstJob;

		global Boolean recalculateMsaQuotes;

		global Integer quoteLimit;

	}

	global CventMyd_RecalculateQuotes(Map<Id,Integer> quoteIdToRecalculationAttempts, Integer jobNumber) {

		this.quoteIdToRecalculationAttempts = quoteIdToRecalculationAttempts;

		this.settings = CventMyd_Settings.recalculationSettings;

		this.jobNumber = jobNumber;

		if(quoteIdToRecalculationAttempts.keySet().size() > this.settings.quoteLimit) {

			throw new RecalculationException('You can only recalculate a maximum of ' + String.valueOf(this.settings.quoteLimit) + ' quotes using the schedulable chain');

		}
		
	}

	global Map<Integer,Set<Id>> getAttemptsToQuoteIds() { 

		Map<Integer,Set<Id>> attemptsToQuoteIds = new Map<Integer,Set<Id>>();

		for(Id quoteId : this.quoteIdToRecalculationAttempts.keySet()) {

			Integer attempts = quoteIdToRecalculationAttempts.get(quoteId);

			if(attemptsToQuoteIds.get(attempts) == null) {

				attemptsToQuoteIds.put(attempts, new Set<Id>());

			}

			attemptsToQuoteIds.get(attempts).add(quoteId);

		}

		return attemptsToQuoteIds;

	}

	global String getProcessingInformationString() {

		Map<Integer,Set<Id>> attemptsToQuoteIds = getAttemptsToQuoteIds();

		String processingInformationString = 'This recalculation chain is against ' + this.quotes.size() + ' quotes...';

		processingInformationString += CventMyd_UtilityMethods.doubleNewLine + 'The format used for quotes is: (quote number)/(calculation completed)...';

		Map<Id,SBQQ__Quote__c> quoteIdToQuote = new Map<Id,SBQQ__Quote__c>(quotes);

		for(Integer attempts : attemptsToQuoteIds.keySet()) {

			processingInformationString += CventMyd_UtilityMethods.doubleNewLine + 'The following quotes have received ' + attempts + ' recalculation checks...';

			processingInformationString += CventMyd_UtilityMethods.doubleNewLine;

			for(Id quoteId : attemptsToQuoteIds.get(attempts)) {

				processingInformationString += (quoteIdToQuote.get(quoteId)).Name + '/';

				processingInformationString += (quoteIdToQuote.get(quoteId)).calculationCycleFinished__c;

				processingInformationString += ';';

			}

		}

		return processingInformationString;

	}

	global void upsertAuditRecord(Boolean scheduleNextRecalulationJob) {

		CpqAudit__c auditRecord = new CpqAudit__c();

		if(this.jobNumber == 0) {

			auditRecord.chainFinished__c = false;

			auditRecord.processingInformation__c = 'The recalculation job is warming up...';

		}

		else {

			List<CpqAudit__c> cpqAuditTmp = [SELECT
			
				Id FROM CpqAudit__c
				
				WHERE Name LIKE
				
				'Quote Recalculate - forceRecalculation%'
				
				AND chainFinished__c = false
				
			];

			if(cpqAuditTmp.isEmpty() || cpqAuditTmp.size() > 1) {

				throw new RecalculationException('There must only exist 1 unfinished recalculation job record at a time');

			}

			else if(cpqAuditTmp.size() == 1) {

				auditRecord.Id = cpqAuditTmp[0].Id;

			}

			auditRecord.chainFinished__c = (!scheduleNextRecalulationJob);

			auditRecord.processingInformation__c = getProcessingInformationString();

		}

		auditRecord.Name = getJobName();

		auditRecord.jobsInChain__c = this.jobNumber;

		upsert auditRecord;

	}

	global Boolean shouldRecalculate(SBQQ__Quote__c quote) {

		Integer attemptsSoFar = quoteIdToRecalculationAttempts.get(quote.Id);

		Boolean recalculate = false;

		if(this.settings.attemptsPerQuote > attemptsSoFar) {

			System.debug('debug 0: ');

			if(this.settings.forceRecalculation) {

				recalculate = true;

				System.debug('debug 1');

			}

			else {

				System.debug('debug 2');

				Boolean calculationFinished = (quote.calculationCycleFinished__c);

				Boolean productCountMismatch = (quote.nonOptionalLineCount__c != quote.opportunityLineItemCount__c);

				recalculate = ( !calculationFinished || productCountMismatch );

			}

		}

		System.debug('recalculate boolean: ' + recalculate);

		return recalculate;

	}

	global void execute(SchedulableContext sc) {

		try {

			this.jobNumber++;

			this.settings = CventMyd_Settings.recalculationSettings;

			Integer quotesReculated = 0;

			for(Integer attempts : quoteIdToRecalculationAttempts.values()) {

				quotesReculated += attempts;

			}

			Set<Id> quoteIds = this.quoteIdToRecalculationAttempts.keySet();

			Set<String> fieldsToQuery = new Set<String> {

				'msaUpload__c',

				'lastCalculationCycleDateTime__c',

				'calculationCycleFinished__c',

				'recalculationToggler__c',

				'opportunityLineItemCount__c',

				'nonOptionalLineCount__c',

				'LastModifiedDate'

			};

			String queryString = 'SELECT Id,Name,' + CventMyd_UtilityMethods.getFieldNamesStringFromStringSet(fieldsToQuery);

			queryString += ' FROM SBQQ__Quote__c WHERE (Id IN: quoteIds)';

			if(this.settings.recalculateMsaQuotes) {

				DateTime openWindow = DateTime.now().addDays(-1);

				DateTime closeWindow = DateTime.now().addMinutes(-5);

				queryString += 'OR (msaUpload__c = TRUE AND CreatedDate >: openWindow AND CreatedDate <: closeWindow AND SBQQ__LineItemCount__c > 0)';

			}

			queryString += ' ORDER BY CreatedDate DESC LIMIT ' + String.valueOf(this.settings.quoteLimit);

			this.quotes = Database.query(queryString);

			for(SBQQ__Quote__c quote : this.quotes) {

				if(!this.quoteIdToRecalculationAttempts.containsKey(quote.Id)) {

					this.quoteIdToRecalculationAttempts.put(quote.Id,0);

				}

			}

			List<SBQQ__Quote__c> quotesToRecalculate = new List<SBQQ__Quote__c>();

			System.debug('this.settings.quotesPerAttempt: ' + this.settings.quotesPerAttempt);

			for(SBQQ__Quote__c quote : quotes) {

				Integer recalculationAttempts = quoteIdToRecalculationAttempts.get(quote.Id);

				System.debug('quote id: ' + quote.Id);

				Decimal minutesSinceLastModified = CventMyd_UtilityMethods.getMinutesBetweenDateTimes(quote.LastModifiedDate,DateTime.now());

				Boolean lastModifiedRecently = (minutesSinceLastModified <= this.settings.minutesBeforeFirstJob);

				Boolean shouldRecalculate = shouldRecalculate(quote);		

				if(shouldRecalculate && !lastModifiedRecently && quotesToRecalculate.size() < this.settings.quotesPerAttempt) {

					quote.recalculationToggler__c = !quote.recalculationToggler__c;

					quotesToRecalculate.add(quote);

					quoteIdToRecalculationAttempts.put( quote.Id, (recalculationAttempts + 1) );

				}

				if(quotesToRecalculate.size() == this.settings.quotesPerAttempt) {

					break;

				}

			}

			System.debug('quotesToRecalculate.size(): ' + quotesToRecalculate.size());

			if(quotesToRecalculate.size() > 0) {

				update quotesToRecalculate;

			}

			Boolean scheduleNextRecalulationJob = false;

			Set<Integer> recalculationAttempts = new Set<Integer>(quoteIdToRecalculationAttempts.values());

			Map<Id,SBQQ__Quote__c> quoteIdToQuote = new Map<Id,SBQQ__Quote__c>(this.quotes);

			for(Id quoteId : quoteIdToRecalculationAttempts.keySet()) {

				SBQQ__Quote__c quote = quoteIdToQuote.get(quoteId);

				if(shouldRecalculate(quote)) {

					scheduleNextRecalulationJob = true;

					break;

				}

			}

			System.abortJob(sc.getTriggerId());

			if(scheduleNextRecalulationJob) {

				scheduleNextRecalulationJob();

			}

			upsertAuditRecord(scheduleNextRecalulationJob);

		}

		catch(Exception e) {

			String subjectString = 'Apex Exception in class CventMyd_RecalculateQuotes @ ';

			subjectString += CventMyd_UtilityMethods.getFormattedDateTimeString(DateTime.now(),true,true);

			String htmlBodyString = CventMyd_UtilityMethods.getExceptionString(e);

			CventMyd_UtilityMethods.sendEmail(null,htmlBodyString,subjectString,null);	

			if(e.getMessage().contains('UNABLE_TO_LOCK_ROW')) {

				scheduleNextRecalulationJob();

			}

			else {

				List<CpqAudit__c> auditRecords = [SELECT
			
					Id FROM CpqAudit__c
					
					WHERE Name LIKE
					
					'Quote Recalculate - forceRecalculation%'
					
					AND chainFinished__c = false

				];

				for(CpqAudit__c auditRecord : auditRecords) {

					auditRecord.exceptionOccurred__c = true;

					auditRecord.chainFinished__c = true;

				}

				update auditRecords;

			}

			System.abortJob(sc.getTriggerId());

		}

	}

	global String getJobName() {

		Integer quoteCount = this.quoteIdToRecalculationAttempts.keySet().size();

		return 'Quote Recalculate - forceRecalculation ' + this.settings.forceRecalculation + ', ' + this.settings.attemptsPerQuote + ' attempts per quote, ' + quoteCount + ' quotes';

	}

	global void scheduleNextRecalulationJob() {

		CventMyd_RecalculateQuotes recalculateQuotes = new CventMyd_RecalculateQuotes(this.quoteIdToRecalculationAttempts,this.jobNumber);

		Integer secondsBeforeJobStart = CventMyd_Settings.recalculationSettings.secondsBetweenJobs;

		String jobName = getJobName();

		String cronString = CventMyd_UtilityMethods.getCronString(secondsBeforeJobStart);

		System.schedule(jobName,cronString,recalculateQuotes);

	}

}