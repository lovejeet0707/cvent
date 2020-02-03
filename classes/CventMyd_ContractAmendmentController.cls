public class CventMyd_ContractAmendmentController {

    public Opportunity opportunity {get;set;}

    public List<Contract> childContracts {get;set;}

    public Id contractId {get;set;}

    public Boolean amendmentCreationStarted {get;set;}

    public List<OutyearStatus> outyearStatuses {get;set;}

    public SBQQ__Quote__c previousQuote {get;set;}

    public String recalculationMessageString {get;set;}

    public String exceptionMessageString {get;set;}

    public String largeQuoteWarningString {get;set;}

    public Integer maxLineCount {get;set;}

    public Contract amendedContract {get;set;}

    public Integer secondsBeforeForceReroutingAmendment {get;set;}

    public static Id amendedContractId = null;

    public String sessionIdString {get;set;}

    public static Set<Id> contractIdsBeingAmended = new Set<Id>();

    public Integer lineCount {get;set;}

    public static Id amendmentOpportunityId {get;set;}

    public String cannotAmendString {get;set;}

    public CventMyd_ContractAmendmentController() {

        sessionIdString = CventMyd_UtilityMethods.getQleId();

        recalculationMessageString = 'Your amendment quote was created, but has not finished calculating.';

        recalculationMessageString += ' You will now be taken to its record page.';

        recalculationMessageString += ' Use the "Recalculate" button to recalculate, if the quote is not already undergoing calculation.';

        exceptionMessageString =  'An error occurred. Please provide the following information to your Salesforce administrator: ';

        largeQuoteWarningString = ' The child contract you are amending has a large volume of quote lines.';

        largeQuoteWarningString += ' It will need to be processed asynchronously, so the wait time will be longer.';

        largeQuoteWarningString += ' If you are unable to access your quote within 5 minutes, please contact your Salesforce administrator.';

        largeQuoteWarningString += ' A link to your amendment quote should appear below; there is a high probability you will need to recalculate it.';

        String opportunityIdString = ApexPages.currentPage().getParameters().get('opportunityIdString');

        String contractIdString = ApexPages.currentPage().getParameters().get('contractIdString');

        this.maxLineCount = CventMyd_Settings.quoteLineMaxCount;

        this.secondsBeforeForceReroutingAmendment = CventMyd_Settings.secondsBeforeForceReroutingAmendment;

        if(opportunityIdString != null) {

            Id opportunityId = Id.valueOf(opportunityIdString);

            amendmentOpportunityId = opportunityId;

            this.opportunity = [SELECT

                Id,Name,AccountId,SBQQ__RenewedContract__c,SBQQ__Contracted__c,

                (SELECT Id FROM SBQQ__Contracts__r WHERE RecordType.Name = 'Child Contract')
                
                FROM Opportunity WHERE Id =: opportunityId
                
            ];

            Date currentDate = Date.today();

            this.childContracts = [SELECT

                Id,SBQQ__Opportunity__r.Name,Name,ContractNumber,

                StartDate,EndDate,RecordType.Name,isLegacy__c,Upcoming_Renewal_Type__c

                FROM Contract

                WHERE RecordType.Name = 'Child Contract'

                    AND AccountId =: opportunity.AccountId

                    AND EndDate >=: currentDate

                ORDER BY LastModifiedDate DESC

            ];

            this.amendmentCreationStarted = false;

        }

        else if(contractIdString != null) {

            clickAmendContract();

        }

    }

    public void clickAmendContract() {

        String contractIdString = ApexPages.currentPage().getParameters().get('contractIdString');

        this.contractId = Id.valueOf(contractIdString);

        this.amendedContract = [SELECT

            Id,Current_Year__c,Parent_Contract_Term_Years__c,EndDate,

            Multiple_Years_Commitment__c,Upcoming_Renewal_Type__c,

            isLegacy__c,(SELECT Id FROM SBQQ__Subscriptions__r)

            FROM Contract WHERE Id=: contractId

        ];

        System.debug('amendedContract.Id: ' + amendedContract.Id);

        Boolean byPass = false;

        Map<String,Boolean> ruleNameToIsActive = CventMyd_Settings.validationSettings.ruleNameToIsActive;

        Boolean validateEndDate = ruleNameToIsActive.get('Amend_Past_End_Date');

        Boolean validateRenewedContract = ruleNameToIsActive.get('Amend_with_Renewed_Contract');

        Boolean validateContracted = ruleNameToIsActive.get('Amend_with_Contracted');

        Boolean validateOppChildren = ruleNameToIsActive.get('Amend_with_Opportunity_Having_Children');

        if(this.amendedContract.EndDate < Date.today() && validateEndDate) {

            System.debug('this happened 000: ');

            this.cannotAmendString = 'It is not permitted to amend a child contract whose end date has already passed.';

        }

        else if(this.opportunity != null && this.opportunity.SBQQ__RenewedContract__c != null && validateRenewedContract) {

            System.debug('this happened 001: ');

            this.cannotAmendString = 'It is not permitted to use an opportunity with "Renewed Contract" populated for an amendment.';

        }

        else if(this.opportunity != null && this.opportunity.SBQQ__Contracted__c && validateContracted) {

            this.cannotAmendString = 'It is not permitted to use an already contracted opportunity for an amendment.';

        }

        else if(this.opportunity != null && !this.opportunity.SBQQ__Contracts__r.isEmpty() && validateOppChildren) {

            this.cannotAmendString = 'The amendment opportunity being used has had a child contract generated from it.';

        }

        else {

            System.debug('this happened 002: ');

            this.amendmentCreationStarted = true;

            contractIdsBeingAmended.add(amendedContract.Id);

            this.previousQuote = getPreviousQuote(contractId);

            this.outyearStatuses = (!this.amendedContract.Multiple_Years_Commitment__c || (previousQuote != null && previousQuote.numberOfQuoteLineGroups__c <= 1)) ? new List<OutyearStatus>() : getOutyearStatusesFromAmendedContract(this.amendedContract);

            this.lineCount = getLineCount(amendedContract,previousQuote);

            System.debug('line count in controller 0: ' + this.lineCount);            

        }

    }

    // method to get a rough estimation of the number of quote lines required for processing

    // this line count is checked against the CventMyd_Settings quote line max count

    // if the line count is greater than the threshold max, generate amendment asynchronously

    public static Integer getLineCount(Contract contract, SBQQ__Quote__c previousQuote) {

        Integer lineCount;

        if(previousQuote != null) {

            System.debug('this happened previousQuote: ' + previousQuote);

            lineCount = contract.SBQQ__Subscriptions__r.size();

            System.debug('line count from subscriptions: ' + lineCount);

            System.debug('optional line count: ' + (Integer)(previousQuote.SBQQ__LineItemCount__c - previousQuote.nonOptionalLineCount__c));

            lineCount += (Integer)(previousQuote.SBQQ__LineItemCount__c - previousQuote.nonOptionalLineCount__c);

        }

        else if(contract.isLegacy__c && previousQuote == null) {

            List<SBQQ__Subscription__c> legacySubscriptions;

            Set<Id> contractIds = new Set<Id>{contract.Id};

            legacySubscriptions = CventMyd_LegacyContractHandler.getAndSetLegacySubscriptions(contractIds);

            System.debug('this happened legacySubscriptions: ' + legacySubscriptions);

            lineCount = CventMyd_LegacyContractHandler.getExpectedQuoteLineCount(legacySubscriptions,'Amendment');

            if(contract.Multiple_Years_Commitment__c) {

                Integer finalYear = Integer.valueOf(contract.Parent_Contract_Term_Years__c);

                Integer currentYear = (Integer)contract.Current_Year__c;

                Integer yearMultiplier = (finalYear - currentYear + 1);

                lineCount = lineCount * yearMultiplier;

            }

        }

        System.debug('lineCount in controller 1: ' + lineCount);

        return lineCount;

    }       

    public static SBQQ__Quote__c getPreviousQuote(Id contractId) {

        Contract contract = [SELECT

            Id,SBQQ__Quote__c,contractedAmendmentQuote__c,

            Multiple_Years_Commitment__c,isLegacy__c,Upcoming_Renewal_Type__c

            FROM Contract

            WHERE Id =: contractId

        ];

        Id previousQuoteId = (contract.contractedAmendmentQuote__c != null) ? contract.contractedAmendmentQuote__c : contract.SBQQ__Quote__c;

        if(contract.isLegacy__c) {

            previousQuoteId = (contract.contractedAmendmentQuote__c != null) ? previousQuoteId : null ;

        }

        if(previousQuoteId != null) {

            SBQQ__Quote__c previousQuote = [SELECT

                Id,Current_Year__c,Multiple_Years_Commitment__c,

                Contract_Term_Years__c,numberOfQuoteLineGroups__c,

                Upcoming_Renewal_Type__c,SBQQ__LineItemCount__c,

                nonOptionalLineCount__c

                FROM SBQQ__Quote__c

                WHERE Id =: previousQuoteId

            ];

            return previousQuote;

        }

        else {return null;}

    }

    @RemoteAction

    public static AmendmentPageStatus amendOrCheckAmendmentStatus(Boolean makeApiCall, String contractIdString, String opportunityIdString, String quoteIdString, String sessionIdString, Integer lineCount, Integer statusCheckCount) {

        Id contractId = Id.valueOf(contractIdString);

        Contract contract = [SELECT

            Id,Name,SBQQ__Quote__c,contractedAmendmentQuote__c,

            SBQQ__Quote__r.SBQQ__LineItemCount__c,SBQQ__Quote__r.nonOptionalLineCount__c,

            SBQQ__Quote__r.jsonString__c,

            Parent_Contract_Term_Years__c,Current_Year__c,

            Upcoming_Renewal_Type__c,isLegacy__c,

            (SELECT Id FROM SBQQ__Subscriptions__r)

            FROM Contract WHERE Id =: contractId

        ];       

        if(makeApiCall) {

            AmendmentPageStatus amendmentPageStatus;

            Integer subscriptionCount = contract.SBQQ__Subscriptions__r.size();

            Integer optionalLineCount = ( contract.SBQQ__Quote__c != null ) ? (Integer) contract.SBQQ__Quote__r.SBQQ__LineItemCount__c - (Integer) contract.SBQQ__Quote__r.nonOptionalLineCount__c : 0;

            if(lineCount > CventMyd_Settings.quoteLineMaxCount) {

                System.debug('sessionIdString1: ' + sessionIdString);

                amendContractFuture(contractIdString,opportunityIdString,sessionIdString);

                return null;

            }

            else {

                return amendContract(contractIdString,opportunityIdString);

            }

        }

        else {

            return getAmendmentPageStatus(quoteIdString,sessionIdString,statusCheckCount);

        }

    }  

    @future

    public static void amendContractFuture(String contractIdString, String opportunityIdString, String sessionIdString) {

        CventMyd_QuoteTriggerHandler.sessionIdString = sessionIdString;

        System.debug('CventMyd_QuoteTriggerHandler.sessionIdString (in future method): ' + CventMyd_QuoteTriggerHandler.sessionIdString);

        amendContract(contractIdString,opportunityIdString);

    }

    public static AmendmentPageStatus amendContract(String contractIdString, String opportunityIdString) {

        Id contractId = Id.valueOf(contractIdString);

        amendedContractId = contractId;

        if(opportunityIdString != null) {

            Opportunity opportunity = new Opportunity(Id = Id.valueOf(opportunityIdString));

            opportunity.SBQQ__AmendedContract__c = contractId;

            update opportunity;

            CventMyd_QuoteTriggerHandler.amendedContractIdToAmendmentOpportunityId.put(contractId,opportunity.Id);

        }

        Contract contract = [SELECT

            Id,Name,SBQQ__Quote__c,contractedAmendmentQuote__c,isLegacy__c,

            Parent_Contract_Term_Years__c,Current_Year__c,Upcoming_Renewal_Type__c,

            (SELECT Id FROM SBQQ__Subscriptions__r)

            FROM Contract WHERE Id =: contractId

        ];

        contractIdsBeingAmended.add(contractId);

        List<SBQQ__Subscription__c> legacySubscriptions;

        if(contract.isLegacy__c && contract.contractedAmendmentQuote__c == null) {

            Set<Id> contractIds = new Set<Id>{contract.Id};

            Date goLiveDate = Date.newInstance(2018,8,4);

            List<SBQQ__Subscription__c> gapSubscriptions = [SELECT

                Id,SBQQ__Quantity__c,SBQQ__TerminatedDate__c,SBQQ__RequiredById__c,

                Year_2_Quantity_X__c,Year_3_Quantity_X__c,Year_4_Quantity_X__c,Year_5_Quantity_X__c,

                (SELECT Id,Name,SBQQ__Quantity__c FROM SBQQ__Revisions__r)

                FROM SBQQ__Subscription__c

                WHERE SBQQ__RevisedSubscription__c = null

                AND SBQQ__Quantity__c = 0

                AND SBQQ__Contract__c IN: contractIds

                AND (Year_2_Quantity_X__c != 0 OR Year_3_Quantity_X__c != 0 OR Year_4_Quantity_X__c != 0 OR Year_5_Quantity_X__c != 0)

                AND CreatedDate <: goLiveDate

            ];

            Boolean updateGapSubscriptions = false;

            for(SBQQ__Subscription__c subscription : gapSubscriptions) {

                Boolean year2NotBlank = (subscription.Year_2_Quantity_X__c != 0 && subscription.Year_2_Quantity_X__c != null);

                Boolean year3NotBlank = (subscription.Year_3_Quantity_X__c != 0 && subscription.Year_3_Quantity_X__c != null);

                Boolean year4NotBlank = (subscription.Year_4_Quantity_X__c != 0 && subscription.Year_4_Quantity_X__c != null);

                Boolean year5NotBlank = (subscription.Year_5_Quantity_X__c != 0 && subscription.Year_5_Quantity_X__c != null);

                if(year2NotBlank || year3NotBlank || year4NotBlank || year5NotBlank) {

                    subscription.SBQQ__Quantity__c = -6969;

                    updateGapSubscriptions = true;

                }

            }

            if(updateGapSubscriptions) {

                update gapSubscriptions;

            }

            legacySubscriptions = CventMyd_LegacyContractHandler.getAndSetLegacySubscriptions(contractIds);

            if(legacySubscriptions.size() > 0) {

                update legacySubscriptions;

            }            

        }

        Id originalQuoteId = (contract.contractedAmendmentQuote__c != null) ? contract.contractedAmendmentQuote__c : contract.SBQQ__Quote__c;

        // make API call to amend contract

        String qmodelJson = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', contractId, null);

        String quoteIdString = qmodelJson.substringAfter('"Id":"'); 

        quoteIdString = quoteIdString.subStringBefore('"');

        Id quoteId = Id.valueOf(quoteIdString);

        SBQQ__Quote__c quote = [SELECT

            Id, previousQuote__r.SBQQ__LineItemCount__c,Multiple_Years_Commitment__c,

            previousQuote__r.nonOptionalLineCount__c,previousQuote__c,

            SBQQ__LineItemCount__c,nonOptionalLineCount__c,createdFromLegacyContract__c,

            Contract_Term_Years__c,Current_Year__c,SBQQ__Type__c,recalculationToggler__c

            FROM SBQQ__Quote__c

            WHERE Id =: quoteId

        ];

        AmendmentPageStatus amendmentPageStatus = new AmendmentPageStatus(quoteIdString);

        amendmentPageStatus.quoteIdString = quoteIdString;

        return amendmentPageStatus;

    }

    public class OutyearStatus {

        public Integer year {get;set;}

        public String outyearName {get;set;}

        public String status {get;set;}

    }

    public class AmendmentPageStatus {

        public String quoteIdString {get;set;}

        public CventMyd_QuoteObject quoteObject {get;set;}

        public String quoteCreationStatus {get;set;}

        public String currentYearCalculationStatus {get;set;}

        public String outyearCalculationStatus {get;set;}

        public List<OutyearStatus> outyearStatuses {Get;set;}

        public Map<Integer,OutyearStatus> outyearStatusMap {get;set;}

        public String redirectUrl {get;set;}

        public AmendmentPageStatus(String quoteIdString) {

            this.redirectUrl = CventMyd_Settings.orgBaseUrl + quoteIdString;

            this.quoteIdString = quoteIdString;

            this.outyearStatuses = new List<OutyearStatus>();

            this.outyearStatusMap = new Map<Integer,OutyearStatus>();

        }

        public AmendmentPageStatus() {}

    }

    // this method is called from JavaScript remoting every time after the initial amendment API call has been made

    public static AmendmentPageStatus getAmendmentPageStatus(String quoteIdString, String sessionIdString, Integer statusCheckCount) {

        String queryString = 'SELECT Id,Name,jsonString__c,Current_Year__c,Contract_Term_Years__c';

        queryString += ',Multiple_Years_Commitment__c,numberOfQuoteLineGroups__c,createdFromLegacyContract__c,';

        queryString += 'SBQQ__Opportunity2__r.SBQQ__AmendedContract__c,SBQQ__Type__c,';

        queryString += 'previousQuote__r.numberOfQuoteLineGroups__c,recalculationToggler__c,';

        queryString += '(SELECT Id,SBQQ__StartDate__c,term__c FROM SBQQ__LineItemGroups__r ORDER BY term__c ASC)';

        queryString += ' FROM SBQQ__Quote__c';

        Id quoteId = (quoteIdString != null && quoteIdString != '') ? Id.valueOf(quoteIdString) : null;

        queryString += (quoteId != null) ? ' WHERE Id =: quoteId' : ' WHERE sessionIdString__c =: sessionIdString';

        System.debug('queryString: ' + queryString);

        List<SBQQ__Quote__c> quotes = Database.query(queryString);

        SBQQ__Quote__c quote = (quotes.size() > 0) ? quotes[0] : null;

        AmendmentPageStatus amendmentPageStatus = new AmendmentPageStatus(String.valueOf(quoteId));

        amendmentPageStatus.outyearCalculationStatus = 'In Progress';

        amendmentPageStatus.currentYearCalculationStatus = 'In Progress';

        Date goLiveDate = Date.newInstance(2018,8,4);

        if(quote != null) {

            quoteId = quote.Id;

            if(quote.createdFromLegacyContract__c) {

                List<SBQQ__QuoteLine__c> badQuoteLines = [SELECT

                    Id,SBQQ__UpgradedSubscription__c FROM SBQQ__QuoteLine__c

                    WHERE SBQQ__Quote__c =: quoteId AND SBQQ__Quantity__c = -6969

                    AND SBQQ__UpgradedSubscription__r.CreatedDate <: goLiveDate

                    AND SBQQ__UpgradedSubscription__r.SBQQ__Quantity__c = -6969

                ];

                if(badQuoteLines.size() > 0) {

                    List<SBQQ__Subscription__c> gapSubscriptions = new List<SBQQ__Subscription__c>();

                    for(SBQQ__QuoteLine__c quoteLine : badQuoteLines) {

                        SBQQ__Subscription__c gapSubscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 0, Id = quoteLine.SBQQ__UpgradedSubscription__c);

                        gapSubscriptions.add(gapSubscription);

                    }

                    delete badQuoteLines;

                    update gapSubscriptions;

                }

            }

            amendmentPageStatus.redirectUrl = amendmentPageStatus.redirectUrl.replace('null',String.valueOf(quote.Id));

            amendmentPageStatus.outyearCalculationStatus = ( !quote.Multiple_Years_Commitment__c || quote.previousQuote__r != null && quote.previousQuote__r.numberOfQuoteLineGroups__c <= 1 ) ? 'Not Needed' : 'In Progress';

            amendmentPageStatus.quoteIdString = String.valueOf(quote.Id);
            
            System.debug('&&& Quote value = ' + quote);

            amendmentPageStatus.quoteCreationStatus = 'Complete';

            amendmentPageStatus.quoteObject = CventMyd_UtilityMethods.getQuoteObject(quote);

            Boolean outyearProcessingStarted = false;

            if(quote.Multiple_Years_Commitment__c && quote.numberOfQuoteLineGroups__c > 1) {

                Map<Integer,SBQQ__QuoteLineGroup__c> yearToQuoteLineGroupMap = new Map<Integer,SBQQ__QuoteLineGroup__c>();

                for(SBQQ__QuoteLineGroup__c qlg : quote.SBQQ__LineItemGroups__r) {

                    yearToQuoteLineGroupMap.put((Integer)qlg.term__c,qlg);

                }

                for(Integer i = (Integer)quote.Current_Year__c + 1; i <= Integer.valueOf(quote.Contract_Term_Years__c); i++) {

                    OutyearStatus outyearStatus = new OutyearStatus();

                    outyearStatus.year = i;

                    outyearStatus.outyearName = 'Year ' + i;            

                    if(yearToQuoteLineGroupMap.get(outyearStatus.year) == null) {

                        outyearStatus.status = 'Not yet started';

                    }

                    else if(yearToQuoteLineGroupMap.get(outyearStatus.year) != null) {

                        outyearProcessingStarted = true;

                        outyearStatus.status = (yearToQuoteLineGroupMap.get(outyearStatus.year).SBQQ__StartDate__c == null) ? 'In Progress' : 'Complete';

                    }

                    amendmentPageStatus.outyearStatuses.add(outyearStatus);

                    amendmentPageStatus.outyearStatusMap.put(i,outyearStatus);

                }

            }

            Map<String,Boolean> quoteStatusMap = CventMyd_UtilityMethods.getQuoteStatusMap(quote);
            
            System.debug('quoteStatusMap = ' + quoteStatusMap);
            
            Boolean calculationCycleFinished = quoteStatusMap.get('calculationCycleFinished');

            amendmentPageStatus.currentYearCalculationStatus = (calculationCycleFinished || outyearProcessingStarted) ? 'Complete' : 'In Progress';

            if(quote.Multiple_Years_Commitment__c && quote.numberOfQuoteLineGroups__c > 1) {amendmentPageStatus.outyearCalculationStatus = (outyearProcessingStarted) ? 'In Progress' : 'Not yet started';}

            Boolean outyearProcessingComplete = quoteStatusMap.get('outyearProcessingComplete');

            Boolean onlyOneGroup = (quote.numberOfQuoteLineGroups__c == CventMyd_UtilityMethods.getExpectedNumberOfQuoteLineGroups(quote) && quote.numberOfQuoteLineGroups__c == 1);

            if(calculationCycleFinished && (outyearProcessingComplete || !quote.Multiple_Years_Commitment__c || onlyOneGroup)) {

                amendmentPageStatus.outyearCalculationStatus = (quote.Multiple_Years_Commitment__c) ? 'Complete' : amendmentPageStatus.outyearCalculationStatus; 

                String urlString = CventMyd_Settings.qleUrlBeforeQuoteId + String.valueOf(quote.Id);   

                amendmentPageStatus.redirectUrl = urlString;

            }

            else if(!calculationCycleFinished && statusCheckCount == 19) {

                quote.recalculationToggler__c = !quote.recalculationToggler__c;

                update quote;

            }

        }         

        return amendmentPageStatus;

    }

    public static List<OutyearStatus> getOutyearStatusesFromAmendedContract(Contract contract) {

        List<OutyearStatus> outyearStatuses = new List<OutyearStatus>();

        for(Integer i = (Integer)contract.Current_Year__c + 1; i <= Integer.valueOf(contract.Parent_Contract_Term_Years__c); i++) {

            OutyearStatus outyearStatus = new OutyearStatus();

            outyearStatus.year = i;

            outyearStatus.outyearName = 'Year ' + i;

            outyearStatus.status = 'In Progress';

            outyearStatuses.add(outyearStatus);

        }

        System.debug('outyear statuses: ' + outyearStatuses);

        return outyearStatuses;

    }      

}