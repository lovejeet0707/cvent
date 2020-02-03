global without sharing class CventMyd_ValidationHandler {

    public static Map<Id,List<SBQQ__QuoteLine__c>> quoteIdToQuoteLines;
    public static Set<Id> validatedOpportunityIds = new Set<Id>();
    public static Set<Id> validatedClosedOpportunityIds = new Set<Id>();
    public static Settings settings = CventMyd_Settings.validationSettings;
    public static Integer queryFiredCount = 0;

    public class Settings {
        public Map<String,Boolean> ruleNameToIsActive;
        public Map<String,Boolean> eventToIsActive;
        public ClosedAttachmentSettings closedAttachmentSettings;
        public OutputGroupingValidationSettings groupingValidationSettings;
    }

    public class OutputGroupingValidationSettings {
        public List<String> groupingsToPrevent;
        public Boolean validateOnDocument;
        public Boolean validateOnApprovals;
        public Boolean onlyCheckNewLinesOnAmendments;
    }

    public class ClosedAttachmentSettings {
        public Boolean isActive;
        public Boolean allowEmails;
        public Boolean validatePaygo;
        public Boolean requireElectronicSignature;
        public Boolean requireEnvelopeId;
        public Boolean validateErrorMessage;
        public Integer queryCountMax;
        public Integer triggerSizeMax;  
        public Boolean checkQuote;
        public String errorMessage;
        public Set<String> profileIdsToBypass;
        public Set<String> userIdsToBypass;
        public Boolean validateMyds;
    }

    public class ClosedEnvelope {

        Id opportunityId;
        List<Attachment> attachments;
        List<SBQQ__QuoteDocument__c> quoteDocuments;
        Boolean hasOpportunityAttachment;
        Boolean hasOpportunityQuoteDocument;
        Boolean hasQuoteAttachment;
        Boolean hasQuoteQuoteDocument;  
        Boolean isValid;

        public ClosedEnvelope() {
            this.attachments = new List<Attachment>();
            this.quoteDocuments = new List<SBQQ__QuoteDocument__c>();
            this.hasOpportunityAttachment = false;
            this.hasOpportunityQuoteDocument = false;
            this.hasQuoteAttachment = false;
            this.hasQuoteQuoteDocument = false;         
        }

        public void setEnvelopeBooleans() {
            for(Attachment attachment : this.attachments) {
                if(attachment.ParentId == this.opportunityId) {
                    this.hasOpportunityAttachment = true;
                }
                else {
                    this.hasQuoteAttachment = true;
                }
            }
            for(SBQQ__QuoteDocument__c quoteDocument : this.quoteDocuments) {
                Boolean isValidQuoteDocument = true;
                if(settings.closedAttachmentSettings.requireElectronicSignature) {
                    isValidQuoteDocument = quoteDocument.SBQQ__ElectronicSignature__c;              
                }
                if(settings.closedAttachmentSettings.requireEnvelopeId) {
                    isValidQuoteDocument = (isValidQuoteDocument && quoteDocument.SBQQDS__EnvelopeId__c != null);
                }
                if(settings.closedAttachmentSettings.validateErrorMessage) {
                    isValidQuoteDocument = (isValidQuoteDocument && quoteDocument.SBQQDS__ErrorMessage__c == null);
                }                
                if(quoteDocument.SBQQ__Opportunity__c == this.opportunityId && isValidQuoteDocument) {
                    this.hasOpportunityQuoteDocument = true;
                }
                if(quoteDocument.SBQQ__Opportunity__c != this.opportunityId && isValidQuoteDocument) {
                    this.hasQuoteQuoteDocument = true;
                }               
            }
            Boolean bool0 = this.hasOpportunityAttachment;
            Boolean bool1 = this.hasOpportunityQuoteDocument;
            Boolean bool2 = this.hasQuoteAttachment;
            Boolean bool3 = this.hasQuoteQuoteDocument;     
            if(!bool0 && !bool1 && !bool2 && !bool3) {
                this.isValid = false;
            }
            else {
                this.isValid = true;
            }
        }

    }

    public static String getBeforeUpdateErrors(SBQQ__Quote__c quote) {
        String errorString;
        errorString = CventMyd_ValidationHandler.getYearErrorString(quote);
        if(errorString != null) {
            return errorString;
        }
        else {
            CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(quote);
            if(quoteObject != null && quoteObject.qcpConfigurationErrors != null) {
                if(quoteObject.qcpConfigurationErrors.size() > 0) {
                    errorString = 'Quote ' + quote.Name + ' cannot be saved due to following validation(s)... ';
                    for(String validationName : quoteObject.qcpConfigurationErrors) {
                        errorString += validationName + ';';
                    }
                }
            }
        }
        return errorString;
    }

    public static Set<Id> getQuoteIdsFromOpportunityTrigger() {
        Set<Id> quoteIds = new Set<Id>();
        Boolean checkContracted = CventMyd_ValidationHandler.settings.eventToIsActive.get('Contracted');
        Boolean checkClosedWon = CventMyd_ValidationHandler.settings.eventToIsActive.get('Closed_Won');
        Boolean checkContractImplemented = CventMyd_ValidationHandler.settings.eventToIsActive.get('Contract_Implemented');
        for(Opportunity opportunity : (List<Opportunity>)Trigger.new){
            checkContracted = (checkContracted && CventMyd_UtilityMethods.didFieldChange(opportunity,'SBQQ__Contracted__c'));
            checkContracted = (checkContracted && opportunity.SBQQ__Contracted__c);
            checkClosedWon = (checkClosedWon && CventMyd_UtilityMethods.didFieldChange(opportunity,'StageName'));
            checkClosedWon = (checkClosedWon && opportunity.StageName == 'Closed Won');
            checkContractImplemented = (checkContractImplemented && CventMyd_UtilityMethods.didFieldChange(opportunity,'Contract_Implemented__c'));
            checkContractImplemented = (checkContractImplemented && opportunity.Contract_Implemented__c);
            Boolean hasQuote = (opportunity.SBQQ__PrimaryQuote__c != null);
            Boolean alreadyChecked = validatedOpportunityIds.contains(opportunity.Id);
            if((hasQuote && !alreadyChecked) && (checkContractImplemented || checkClosedWon || checkContracted)) {
                quoteIds.add(opportunity.SBQQ__PrimaryQuote__c);
                validatedOpportunityIds.add(opportunity.Id);
            }
        }
        return quoteIds;
    }   

    public static void validateQuotes(Set<Id> quoteIds){
        if(!quoteIds.isEmpty() && quoteIds.size() < 10) {
            String queryString = 'SELECT Id,Name,';
            Set<String> fieldNames = new Set<String> {
                'SBQQ__Opportunity2__c','SBQQ__MasterContract__c',
                'jsonString__c','Current_Year__c',
                'Current_Year__c','CreatedDate',
                'SBQQ__StartDate__c','SBQQ__EndDate__c',
                'SBQQ__MasterContract__r.Current_Year__c',
                'SBQQ__MasterContract__r.Parent_Contract_Term_Years__c',
                'SBQQ__MasterContract__r.Multiple_Years_Commitment__c',
                'SBQQ__MasterContract__r.SBQQ__RenewalOpportunity__r.StageName',
                'SBQQ__MasterContract__r.SBQQ__RenewalOpportunity__r.SBQQ__Contracted__c',
                'SBQQ__MasterContract__r.SBQQ__RenewalQuoted__c',
                'SBQQ__MasterContract__r.Last_Amended_Opportunity_Contracted__c',
                'SBQQ__MasterContract__r.EndDate',
                'Contract_Term_Years__c'
            };
            queryString += CventMyd_UtilityMethods.getFieldNamesStringFromStringSet(fieldNames);
            fieldNames = new Set<String> {
                'jsonString__c',
                'SBQQ__Quote__c',
                'SBQQ__Group__c',
                'term__c',
                'SBQQ__EffectiveQuantity__c',
                'SBQQ__RequiredBy__r.SBQQ__Quote__c',
                'SBQQ__RequiredBy__r.SBQQ__Group__c',
                'SBQQ__Group__r.SBQQ__Quote__c'
            };
            queryString += ',(SELECT Id,';
            queryString += CventMyd_UtilityMethods.getFieldNamesStringFromStringSet(fieldNames);
            queryString += ' FROM SBQQ__LineItems__r LIMIT 200)';
            queryString += ' FROM SBQQ__Quote__c WHERE Id IN: quoteIds';
            for(SBQQ__Quote__c quote : Database.query(queryString)) {
                Opportunity opportunity = (Opportunity)Trigger.newMap.get(quote.SBQQ__Opportunity2__c);
                Boolean matchingAmendedContract = (opportunity.SBQQ__AmendedContract__c == quote.SBQQ__MasterContract__c);
                matchingAmendedContract = (matchingAmendedContract && quote.SBQQ__MasterContract__c != null);
                Boolean renewalClosed = false; 
                String errorString = CventMyd_ValidationHandler.getYearErrorString(quote);
                System.debug('quote json string ***: ' + quote.jsonString__c);
                System.debug('error string: ' + errorString);
                if(matchingAmendedContract) {
                    opportunity.amendedContractValues__c = '{';
                    opportunity.amendedContractValues__c += '"endDate":"';
                    String endDateString = String.valueOf(quote.SBQQ__MasterContract__r.EndDate);
                    opportunity.amendedContractValues__c += endDateString + '"';
                    opportunity.amendedContractValues__c += ',"currentYear":';
                    opportunity.amendedContractValues__c += quote.SBQQ__MasterContract__r.Current_Year__c;
                    Boolean quoteOutOfDate = (quote.CreatedDate < quote.SBQQ__MasterContract__r.Last_Amended_Opportunity_Contracted__c);
                    opportunity.amendedContractValues__c += ',"quoteOutOfDate":';
                    opportunity.amendedContractValues__c += String.valueOf(quoteOutOfDate);
                    String termLength = quote.SBQQ__MasterContract__r.Parent_Contract_Term_Years__c;
                    System.debug('quote.SBQQ__MasterContract__r****: ' + quote.SBQQ__MasterContract__r);
                    if(termLength != null) {
                        opportunity.amendedContractValues__c += ',"isVariable":';
                        Boolean isVariable = quote.SBQQ__MasterContract__r.Multiple_Years_Commitment__c;
                        opportunity.amendedContractValues__c += String.valueOf(isVariable);
                        opportunity.amendedContractValues__c += ',"termLength":';
                        opportunity.amendedContractValues__c += Integer.valueOf(termLength);
                    }
                    opportunity.amendedContractValues__c += '}';
                    System.debug('opportunity Id: ' + opportunity.Id);
                    System.debug('opportunity.amendedContractValues__c: ***: ' + opportunity.amendedContractValues__c);
                    Opportunity renewalOpportunity = quote.SBQQ__MasterContract__r.SBQQ__RenewalOpportunity__r;                 
                    if(renewalOpportunity != null) {
                        renewalClosed = (renewalOpportunity.StageName == 'Closed Won');
                        renewalClosed = (renewalOpportunity.SBQQ__Contracted__c) ? true : renewalClosed;
                    }
                }
                if(String.isBlank(errorString)) {
                    try {
                        for(SBQQ__QuoteLine__c quoteLine : quote.SBQQ__LineItems__r) {
                            Boolean outyearLine = (quoteLine.term__c> quote.Current_Year__c);
                            Boolean contractedRenewalClosed = (outyearLine && renewalClosed);
                            errorString = CventMyd_ValidationHandler.getErrorString(quoteLine,contractedRenewalClosed);
                            if(!String.isBlank(errorString)) {
                                break;
                            }
                        }
                    }
                    catch(Exception e) {
                        System.debug('Presumably we got a query locator error. Code execution shall continue nevertheless.');
                    }
                }                
                if(!String.isBlank(errorString)) {
                    if(Trigger.newMap != null) {
                        if(Trigger.newMap.get(quote.SBQQ__Opportunity2__c) != null) {
                            Trigger.newMap.get(quote.SBQQ__Opportunity2__c).addError(errorString);
                        }
                        else if(Trigger.newMap.get(quote.Id) != null) {
                            Trigger.newMap.get(quote.Id).addError(errorString);
                        }
                    }
                    break;
                }                
            }
        }
    }    

    public static void getQuoteLines(Set<Id> quoteIds) {
        quoteIdToQuoteLines = (Map<Id,List<SBQQ__QuoteLine__c>>)CventMyd_UtilityMethods.getParentIdToChildrenRecords(
            [SELECT 
                Id,Name,CreatedDate,jsonString__c,SBQQ__Quote__c
                FROM SBQQ__QuoteLine__c
                WHERE SBQQ__Quote__c IN: quoteIds
            ],
            'SBQQ__Quote__c'
        );
    }

    public static Set<Integer> getExpectedOutyears(SBQQ__Quote__c quote) {
        Integer termLength = Integer.valueOf(quote.Contract_Term_Years__c);
        Set<Integer> expectedOutyears = new Set<Integer>();
        for(Integer year = (Integer)quote.Current_Year__c + 1; year <= termLength; year++) {
            expectedOutYears.add(year);
        }
        return expectedOutyears;
    }

    public static Set<Integer> getActualOutyears(String jsonString) {
        Set<Integer> actualOutyears = new Set<Integer>();
        if(jsonString != null) {
            CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(jsonString);
            for(Integer year : quoteObject.outyearMap.keySet()) {
                CventMyd_Outyear outyear = quoteObject.outyearMap.get(year);
                if(outyear.startDate != null && outyear.endDate != null) {
                    actualOutyears.add(year);
                }
            }
        }
        return actualOutyears;
    }

    public static Set<Integer> getMissingOutyears(SBQQ__Quote__c quote) {
        if(settings.ruleNameToIsActive.get('Quote_Missing_Outyears')) {
            Set<Integer> expectedOutyears = getExpectedOutyears(quote);
            Set<Integer> actualOutyears = getActualOutyears(quote.jsonString__c);
            Set<Integer> missingOutyears = expectedOutyears.clone(); missingOutyears.removeAll(actualOutyears);
            return missingOutyears;
        }
        else {
            return new Set<Integer>();
        }
    }

    public static Map<Integer,CventMyd_Outyear> getInvalidYears(SBQQ__Quote__c quote) {
        Map<Integer,CventMyd_Outyear> yearToInvalidDates = new Map<Integer,CventMyd_Outyear>();
        if(settings.ruleNameToIsActive.get('Quote_Dates_Validity') && quote.jsonString__c != null) {
            CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(quote);
            Map<Integer,CventMyd_Outyear> yearToDates = CventMyd_UtilityMethods.getFullYearToDatesMap(quote);
            List<Integer> yearsSorted = CventMyd_UtilityMethods.getYearsSorted(quote);
            System.debug('years sorted ----->: ' + yearsSorted);
            Date previousEndDate = Date.valueOf('1970-01-01');
            Set<Integer> expectedOutyears = getExpectedOutyears(quote);
            for(Integer year : yearsSorted) {
                CventMyd_Outyear dates = yearToDates.get(year);
                Date startDate = dates.startDate;
                Date endDate = dates.endDate;
                Boolean startBeforeLastYear = (startDate <= previousEndDate);
                Boolean startBeforeEnd = (endDate <= startDate && !(year == quote.Current_Year__c && endDate == startDate));
                Boolean gapBetweenYears = (year != quote.Current_Year__c && startDate > previousEndDate.addDays(1));
                if(startBeforeLastYear || startBeforeEnd || gapBetweenYears) {
                    if(year == quote.Current_Year__c || expectedOutyears.contains(year)) {
                        yearToInvalidDates.put(year,dates);
                    }
                }
                previousEndDate = endDate;
            }
        }
        return yearToInvalidDates;
    }

    public static String getYearErrorString(SBQQ__Quote__c quote) {
        Set<Integer> missingOutyears = getMissingOutyears(quote);
        Set<Integer> invalidYears = getInvalidYears(quote).keySet();
        String errorString = 'NOTIFY CRM MANAGEMENT: ' + quote.Name;
        if(!missingOutyears.isEmpty() || !invalidYears.isEmpty()) {
            Set<Integer> years = (!missingOutyears.isEmpty()) ? missingOutyears : invalidYears ;
            errorString += (!missingOutyears.isEmpty()) ? ' is missing outyear ' : ' has unchronological ';
            errorString += 'dates for year(s): ';
            for(Integer year : years) {
                errorString += year + ',';
            }
            errorString = errorString.removeEnd(',');
        }
        else {
            errorString = null;
        }
        return errorString;
    }

    public static Set<String> getErrorStrings(SBQQ__Quote__c quote) {
        Set<String> errorStrings = new Set<String>();
        errorStrings.add(getYearErrorString(quote));
        errorStrings.remove(null);
        errorStrings.remove('');
        return errorStrings;
    }

    public static String getErrorString(SBQQ__QuoteLine__c quoteLine, Boolean contractedRenewalClosed) {
        List<String> errors = getErrors(quoteLine,contractedRenewalClosed);
        if(!errors.isEmpty()) {
            return errors[0] + ' for record with Id ' + quoteLine.Id;
        }
        else {
            return null;
        }
    }

    public static List<String> getErrors(SBQQ__QuoteLine__c quoteLine, Boolean contractedRenewalClosed) {
        List<String> errors = new List<String>();
        Boolean checkJson = settings.ruleNameToIsActive.get('Quote_Line_JSON');
        Boolean checkGrouping = settings.ruleNameToIsActive.get('Group_on_Wrong_Quote');
        Boolean checkRequiredBy = settings.ruleNameToIsActive.get('Line_Required_By');
        Boolean checkClosedRenewal = settings.ruleNameToIsActive.get('Closed_Renewal_Line_Check');
        if(checkJson && quoteLine.jsonString__c == null) {
            errors.add('JSON is null on quote line');
        }
        if(checkGrouping && quoteLine.SBQQ__Group__c != null) {
            if(quoteLine.SBQQ__Group__r.SBQQ__Quote__c != quoteLine.SBQQ__Quote__c) {
                errors.add('Quote line is in group of different quote');
            }
        }
        if(checkRequiredBy && quoteLine.SBQQ__RequiredBy__c != null) {
            Boolean wrongRequiredQuote = (quoteLine.SBQQ__RequiredBy__r.SBQQ__Quote__c != quoteLine.SBQQ__Quote__c);
            Boolean wrongRequiredGroup = (quoteLine.SBQQ__RequiredBy__r.SBQQ__Group__c != quoteLine.SBQQ__Group__c);
            if(wrongRequiredQuote) {
                errors.add('Quote line is required by a line on a different quote');
            }
            if(wrongRequiredGroup) {
                errors.add('Quote line is required by a line on a different group');
            }
        }
        if(checkClosedRenewal && contractedRenewalClosed) {
            if(quoteLine.SBQQ__EffectiveQuantity__c != 0) {
                String errorString = 'There is a renewal already closed for the contract being amended';
                errorString += '. Changes to outyear products should be made on next year\'s contract';
                errors.add(errorString);
            }
        }
        return errors;
    }

    public static String getNegativeTermErrors(Set<Id> parentContractIds) {
        String errorString = '';
        if(settings.ruleNameToIsActive.get('Parent_Contract_Term_Check')) {
            for(Contract childContract : [SELECT
                Id,Current_Year__c,Parent_Contract__c,
                Parent_Contract__r.Id,
                Parent_Contract__r.Contract_Term_Years__c
                FROM Contract
                WHERE Parent_Contract__c IN: parentContractIds
            ]) {
                Contract parentContract = childContract.Parent_Contract__r;
                if(childContract.Current_Year__c == null) {
                    errorString  += 'Child contract with Id ' + childContract.Id + ' has a null current year...';
                }
                if(parentContract.Contract_Term_Years__c == null) {
                    errorString  += 'Parent contract with Id ' + parentContract.Id + ' has a null current year...';
                }
                else {
                    Integer termLength = Integer.valueOf(parentContract.Contract_Term_Years__c);
                    if(childContract.Current_Year__c > termLength) {
                        errorString += 'Child contract with Id ' + childContract.Id + ' has a current year less than its term length...';
                    }
                }
            }
        }
        return errorString;
    }



    public static Map<Id,Id> getClosedOpportunityMap() {
        Map<Id,Id> opportunityIdToQuoteId = new Map<Id,Id>();
        Boolean checkPaygo = (settings.closedAttachmentSettings.validatePaygo);
        Boolean validateMyds = settings.closedAttachmentSettings.validateMyds;
        for(Opportunity opportunity : (List<Opportunity>)Trigger.new) {
            if(CventMyd_UtilityMethods.didFieldChange(opportunity,'StageName')) {
                Boolean isPaygo = (opportunity.License_Type__c == 'PayGo');
                System.debug('isPaygo: ' + isPaygo);
                Boolean justClosed = (opportunity.StageName == 'Closed Won');
                System.debug('justClosed: ' + justClosed);
                Boolean alreadyHandled = validatedClosedOpportunityIds.contains(opportunity.Id);
                System.debug('alreadyHandled: ' + alreadyHandled);
                Boolean isMyd = (opportunity.Deal_Year__c != null) ? (Integer.valueOf(opportunity.Deal_Year__c) > 1) : false;
                if(opportunity.SBQQ__PrimaryQuote__c != null) {
                    isMyd = (isMyd && opportunity.Primary_Quote_Type__c == 'Renewal');
                }
                Boolean skipMyd = (!validateMyds && isMyd);
                Boolean skipPaygo = (!checkPaygo && isPaygo);
                if(justClosed && !skipMyd && !skipPaygo && !alreadyHandled) {
                    opportunityIdToQuoteId.put(opportunity.Id,opportunity.SBQQ__PrimaryQuote__c);
                }
            }
        }
        System.debug('opportunityIdToQuoteId: ' + opportunityIdToQuoteId);
        return opportunityIdToQuoteId;        
    }

    public static void validateClosedOpportunityAttachments(Map<Id,Id> opportunityIdToQuoteId){
        Map<Id,ClosedEnvelope> opportunityIdToClosedEnvelope = new Map<Id,ClosedEnvelope>();
        Set<Id> bypassProfileIds = new Set<Id>();
        Set<Id> bypassUserIds = new Set<Id>();
        for(String str : settings.closedAttachmentSettings.profileIdsToBypass) {
            bypassProfileIds.add(Id.valueOf(str));
        }
        for(String str : settings.closedAttachmentSettings.userIdsToBypass) {
            bypassUserIds.add(Id.valueOf(str));
        }        
        for(Id opportunityId : opportunityIdToQuoteId.keySet()) {
            if(!validatedClosedOpportunityIds.contains(opportunityId)) {
                validatedClosedOpportunityIds.add(opportunityId);
                opportunityIdToClosedEnvelope.put(opportunityId,new ClosedEnvelope());
            }
        }
        Set<Id> opportunityIds = opportunityIdToQuoteId.keySet();
        List<Id> quoteIds =  opportunityIdToQuoteId.values();
        Boolean isActive = settings.closedAttachmentSettings.isActive;
        Id userId = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        Boolean userIsBypassed = bypassUserIds.contains(userId);
        Boolean profileIsBypassed = bypassProfileIds.contains(profileId);
        if(userIsBypassed || profileIsBypassed) {
            isActive = false;
        }
        System.debug('isActive: ' + isActive);
        if(isActive && !opportunityIds.isEmpty() && queryFiredCount < settings.closedAttachmentSettings.queryCountMax) {
            String queryString = 'SELECT Id,Name,BodyLength,ContentType,';
            querySTring += 'CreatedById,CreatedDate,';
            queryString += 'Description,LastModifiedById,';
            queryString += 'OwnerId,ParentId,SystemModstamp';
            queryString += ' FROM Attachment';
            queryString += ' WHERE ParentId IN: opportunityIds';
            queryString += (settings.closedAttachmentSettings.checkQuote) ? ' OR ParentId IN: quoteIds' : '' ;
            queryString += (!settings.closedAttachmentSettings.allowEmails) ? ' AND (NOT NAME LIKE \'%.msg\')' : '' ;
            queryFiredCount++;
            System.debug('queryFiredCount0: ' + queryFiredCount);
            for(Attachment attachment : Database.query(queryString)) {
                Id opportunityId;
                if(opportunityIdToQuoteId.containsKey(attachment.ParentId)) {
                    opportunityId = attachment.ParentId;
                }
                else if(settings.closedAttachmentSettings.checkQuote) {
                    for(Id opportunityId0 : CventMyd_UtilityMethods.getKeyIdsToValueId(opportunityIdToQuoteId,attachment.ParentId,false)) {
                        opportunityId = opportunityId0;
                        break;
                    }
                }
                ClosedEnvelope closedEnvelope = opportunityIdToClosedEnvelope.get(opportunityId);
                closedEnvelope.attachments.add(attachment);
            }
            Set<Id> opportunityIdsNoAttachment = new Set<Id>();
            for(Id opportunityId : opportunityIdToClosedEnvelope.keySet()){
                //System.debug('######## opportunity Id: ' + opportunityId);
                ClosedEnvelope closedEnvelope = opportunityIdToClosedEnvelope.get(opportunityId);
                //System.debug('attachment count: ' + closedEnvelope.attachments.size());
                if(closedEnvelope.attachments.isEmpty()){
                    opportunityIdsNoAttachment.add(opportunityId);
                }
            }
            if(!opportunityIdsNoAttachment.isEmpty() && queryFiredCount < settings.closedAttachmentSettings.queryCountMax) {
                queryString = 'SELECT Id,Name,SBQQ__quote__c,SBQQ__OutputFormat__c,';
                queryString += 'SBQQ__Template__c,SBQQ__NetAmount__c,SBQQ__SignatureStatus__c';
                queryString += ',SBQQ__Opportunity__c,SBQQ__ElectronicSignature__c,SBQQDS__ErrorMessage__c';
                queryString += ',SBQQDS__EnvelopeId__c,SBQQ__ListAmount__c';
                queryString += ' FROM SBQQ__QuoteDocument__c';
                queryString += ' WHERE SBQQ__Opportunity__c IN: opportunityIdsNoAttachment';
                queryFiredCount++;
                System.debug('queryFiredCount1: ' + queryFiredCount);
                List<SBQQ__QuoteDocument__c> quoteDocuments = Database.query(queryString);
                for(SBQQ__QuoteDocument__c quoteDocument : quoteDocuments){
                    ClosedEnvelope closedEnvelope = opportunityIdToClosedEnvelope.get(quoteDocument.SBQQ__Opportunity__c);
                    closedEnvelope.quoteDocuments.add(quoteDocument);
                }
            }
            opportunityIdsNoAttachment.clear();
            for(Id opportunityId : opportunityIdToClosedEnvelope.keySet()) {
                ClosedEnvelope closedEnvelope = opportunityIdToClosedEnvelope.get(opportunityId);
                closedEnvelope.setEnvelopeBooleans();
                if(!closedEnvelope.isValid) {
                    opportunityIdsNoAttachment.add(opportunityId);
                }
            }
            System.debug('total opportunity count: ' + opportunityIdToClosedEnvelope.keySet().size());
            Set<Id> oppIdsWithAttachments = opportunityIdToClosedEnvelope.keySet().clone();
            oppIdsWithAttachments.removeAll(opportunityIdsNoAttachment);
            System.debug('opportunity ids WITH attachments ' + CventMyd_UtilityMethods.newLine + CventMyd_UtilityMethods.getIdString(oppIdsWithAttachments,CventMyd_UtilityMethods.newLine));
            System.debug('opportunity ids WITHOUT attachments ' + CventMyd_UtilityMethods.newLine + CventMyd_UtilityMethods.getIdString(opportunityIdsNoAttachment,CventMyd_UtilityMethods.newLine));
            System.debug('total opportunity count: ' + opportunityIdToClosedEnvelope.keySet().size());
            System.debug('opportunities with attachment count: ' + oppIdsWithAttachments.size());
            System.debug('opportunities without attachment count: ' + opportunityIdsNoAttachment.size());
            //createDumpRecords(oppIdsWithAttachments,'Valid Opportunity Record');
            //createDumpRecords(noAttachments,'Invalid Opportunity Record');
            //debugOpportunityData(opportunityIdsNoAttachment);
            //checkDocusignStatuses(opportunityIdsNoAttachment);
            if(Trigger.new != null) {
                for(Id badOppId : opportunityIdsNoAttachment) {
                    System.debug('THROWING AN ERROR FOR OPPORTUNITY ID: ' + badOppId);
                    Trigger.newMap.get(badOppId).addError(settings.closedAttachmentSettings.errorMessage);
                }
            }
        }
    }

    public static void validateClosedWonAttachmentsFromTrigger() {
        System.debug('***CventMyd_ValidationHandler.validateClosedWonAttachmentsFromTrigger()***');
        Map<Id,Id> opportunityIdToQuoteId = getClosedOpportunityMap();
        if(!opportunityIdToQuoteId.keySet().isEmpty()) {
            validateClosedOpportunityAttachments(opportunityIdToQuoteId);
        }  
    }

    public static List<SBQQ__QuoteLine__c> getLinesHavingFieldValue(List<SBQQ__QuoteLine__c> quoteLines, String fieldName, String fieldValue) {
        List<SBQQ__QuoteLine__c> matchingLines = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c quoteLine : quoteLines) {
            String actualValue = String.valueOf(quoteLine.get(fieldName));
            System.debug('product name: ' + quoteLine.SBQQ__ProductName__c);
            System.debug('actualValue: ' + actualValue);
            System.debug('filterValue: ' + fieldValue);
            System.debug('does the actualValue match the filter value?: ' + String.valueOf(actualValue == fieldValue) );
            if(actualValue == fieldValue) {
                matchingLines.add(quoteLine);
            }
        }
        return matchingLines;
    }

    public static List<SBQQ__QuoteLine__c> getLinesOutsideOfFieldValueSet(List<SBQQ__QuoteLine__c> quoteLines, String fieldName, Set<String> fieldValues) {
        List<SBQQ__QuoteLine__c> returnedLines = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c quoteLine : quoteLines) {
            String actualValue = String.valueOf(quoteLine.get(fieldName));
            System.debug('actualValue: ' + actualValue);
            System.debug('fieldValues: ' + fieldValues);
            if(!fieldValues.contains(actualValue) && !quoteLine.SBQQ__ProductName__c.containsIgnoreCase('onarrival premium') && quoteLine.SBQQ__ProductName__c != 'Onsite Training - # hours') {
                returnedLines.add(quoteLine);
            }
        }
        return returnedLines;
    }
        

    public static void validateOnArrivalLineCounts(List<SBQQ__QuoteLine__c> quoteLines) {
        Map<String,List<SBQQ__QuoteLine__c>> fieldValueToLines = new Map<String,List<SBQQ__QuoteLine__c>>();
        for(String grouping : settings.groupingValidationSettings.groupingsToPrevent) {
            fieldValueToLines.put(grouping,getLinesHavingFieldValue(quoteLines,'Contract_Output_Grouping__c',grouping));
        }
        List<SBQQ__QuoteLine__c> nonOa360QuoteLines = new List<SBQQ__QuoteLine__c>();
        Set<String> groupings = new Set<String>(settings.groupingValidationSettings.groupingsToPrevent);
        Set<String> itemsToBypass = new Set<String>();
        for(SBQQ__QuoteLine__c quoteLine : getLinesOutsideOfFieldValueSet(quoteLines,'Contract_Output_Grouping__c',groupings)) {
            SBQQ__Quote__c quote = quoteLine.SBQQ__Quote__r;
            if(quote.itemsToBypass__c != null) {
                itemsToBypass = new Set<String>(quote.itemsToBypass__c.split(';'));
            }
            if(settings.groupingValidationSettings.onlyCheckNewLinesOnAmendments && quote.SBQQ__Type__c =='Amendment') {
                if(quoteLine.SBQQ__PriorQuantity__c  != null) {
                    nonOa360QuoteLines.add(quoteLine);
                }
            }
            else {
                nonOa360QuoteLines.add(quoteLine);
            }
        }
        Set<String> nonZeroValues = new Set<String>();
        for(String fieldValue : fieldValueToLines.keySet()) {
            List<SBQQ__QuoteLine__c> lines = fieldValueToLines.get(fieldValue);
            if(lines.size() > 0) {
                nonZeroValues.add(fieldValue);
            }
        }
        System.debug('nonZeroValues: ' + nonZeroValues);
        if(nonOa360QuoteLines.size() > 0 && !itemsToBypass.contains('Contract Output Grouping')) {
            Boolean throwException = false;
            for(String fieldValue : nonZeroValues) {
                System.debug('fieldValue: ' + fieldValue);
                List<SBQQ__QuoteLine__c> lines = fieldValueToLines.get(fieldValue);
                System.debug('line count: ' + lines.size());
                SBQQ__Quote__c quote = lines[0].SBQQ__Quote__r;
                Boolean isMyd = (quote.SBQQ__Type__c == 'Renewal' && quote.Current_Year__c > 1);
                if(!isMyd) {
                    System.debug('not an MYD...');
                    if(settings.groupingValidationSettings.onlyCheckNewLinesOnAmendments && quote.SBQQ__Type__c =='Amendment') {
                        Boolean allNewLines = true;
                        System.debug('debug0');
                        for(SBQQ__QuoteLine__c line : lines) {
                            System.debug('debug1');
                            if(line.SBQQ__PriorQuantity__c  != null) {
                                System.debug('debug2');
                                allNewLines = false;
                            }
                        }
                        if(allNewLines) {
                            System.debug('debug3');
                            throwException = true;
                        }
                    }
                    else {
                        System.debug('debug4');
                        throwException = true;
                    }
                }
            }
            if(throwException) {
                throw new CventMyd_UtilityMethods.Cvent_Exception(getOutputGroupingExceptionMessage());
            }
        }  
    }     

    public static String getOutputGroupingExceptionMessage() {
        String exceptionString = 'Products sold in the following Contract Output Groupings cannot be sold with products outside of these groupings. ';
        for(String grouping : settings.groupingValidationSettings.groupingsToPrevent) {
            exceptionString += CventMyd_UtilityMethods.newLine + grouping + ',';
        }
        return exceptionString;
    }   

    webservice static void validateLineCountOnApproval(String quoteIdString) {
        if(settings.groupingValidationSettings.validateOnApprovals) {
            Id quoteId = Id.valueOf(quoteIdString);
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id,
                Contract_Output_Grouping__c,
                SBQQ__PriorQuantity__c,SBQQ__ProductName__c,
                SBQQ__Quote__r.SBQQ__Type__c,
                SBQQ__Quote__r.Current_Year__c,
                SBQQ__Quote__r.itemsToBypass__c
                FROM SBQQ__Quoteline__c
                WHERE SBQQ__Quote__c =: quoteId
            ];
            validateOnArrivalLineCounts(quoteLines);
        }
    }

}