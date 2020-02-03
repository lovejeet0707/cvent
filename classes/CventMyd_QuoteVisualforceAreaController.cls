public class CventMyd_QuoteVisualforceAreaController {

    public SBQQ__Quote__c quote {get;set;}

    public List<SBQQ__QuoteLineGroup__c> quoteLineGroups {get;set;}

    public Map<Integer,CventMyd_Outyear> outyearMap {get;set;}

    public Boolean showOutyearTable {get;set;}

    public String outyearMapJson {get;set;}

    public Integer finalYear {get;set;}

    public CventMyd_QuoteObject quoteObject {get;set;}

    public String userMessage {get;set;}

    public String messageColor {get;set;}

    public String currentYearStartDate {get;set;}

    public String messageLocation {get;set;}

    public String queryString {get;set;}

    public Boolean parentContractExists {get;set;}

    public Boolean opportunityIsContracted {get;set;}

    public Integer extensionYears {get;set;}

    public Integer lowestEditableYear {get;set;}

    public Boolean lockDates {get;set;}

    public String userLocale {get;set;}

    public class QuoteField {

        public String fieldLabel {get;set;}

        public String fieldApiName {get;set;}

        public String fieldType {get;set;}

        public Boolean editable {get;set;}

        public Boolean isDate {get;set;}

    }

    public List<QuoteField> quotefields {get;set;}

    public CventMyd_QuoteVisualforceAreaController (ApexPages.StandardController standardController) {

        this.userLocale = UserInfo.getLocale();

        Id quoteId;

        this.messageLocation = '';

        if(ApexPages.currentPage().getParameters().get('quoteId') != null) {

            quoteId = ApexPages.currentPage().getParameters().get('quoteId');

            this.quote = [SELECT Id,Current_Year__c,jsonString__c,Contract_Term_Years__c,isLockedIntratermRenewal__c FROM SBQQ__Quote__c WHERE Id =: quoteId];

        }

        else {

            this.quote = (SBQQ__Quote__c)standardController.getRecord();

            quoteId = quote.Id;

        }

        List<Schema.FieldSetMember> fieldSetFields = SObjectType.SBQQ__Quote__c.FieldSets.Visualforce_Area_Fields.getFields();

        this.queryString = 'SELECT ';

        for(Schema.FieldSetMember f : fieldSetFields) {

            queryString += f.getFieldPath() + ',';

        }       

        queryString += 'Id,Name,RecordType.Name,jsonString__c,originalContractTerm__c,SBQQ__Opportunity2__c,SBQQ__Type__c FROM SBQQ__Quote__c WHERE Id =: quoteId LIMIT 1';

        this.quote = Database.query(queryString);

        this.currentYearStartDate = JSON.serialize(this.quote.SBQQ__StartDate__c);

        this.finalYear = Integer.valueOf(this.quote.Contract_Term_Years__c);

        this.quotefields = new List<QuoteField>();

        List<Opportunity> opportunity = [SELECT

            Id,SBQQ__Contracted__c,Master_Agreement__c,

            StageName,Master_Agreement__r.ContractNumber

            FROM Opportunity

            WHERE Id =: quote.SBQQ__Opportunity2__c 

        ];

        this.parentContractExists = false;

        String parentContractNumber;

        this.opportunityIsContracted = false;

        if(opportunity.size() > 0) {

            if(opportunity[0].Master_Agreement__c != null && (opportunity[0].StageName == 'Closed Won' || this.quote.SBQQ__Type__c == 'Renewal' && this.quote.Current_Year__c > 1)) {

                parentContractExists = true;

                parentContractNumber = opportunity[0].Master_Agreement__r.ContractNumber;

                this.opportunityIsContracted = opportunity[0].SBQQ__Contracted__c;

            }

        }

        for(Schema.FieldSetMember fsm : fieldSetFields) {

            QuoteField quoteField = new QuoteField();

            quoteField.fieldLabel = fsm.getLabel();

            quotefield.fieldApiName = fsm.getFieldPath();

            quoteField.fieldtype = String.valueOf(fsm.getType());

            quoteField.isDate = quoteField.fieldType.containsIgnoreCase('date');

            Boolean isCurrencyRate = (quotefield.fieldApiName == 'Quote_Currency_Rate__c');

            Boolean isCurrentYear = (quotefield.fieldApiName == 'Current_Year__c');

            Boolean isContractEndDate = (quoteField.fieldApiName == 'Contract_End_Date__c');

            Boolean isContractExtension = (quoteField.fieldApiName == 'Contract_Extension__c');

            quoteField.editable = (isCurrencyRate || isCurrentYear || isContractEndDate) ? false : true;

            if(this.quote.SBQQ__Type__c == 'Amendment') {

                quoteField.editable = ((isContractExtension || quotefield.fieldApiName == 'SBQQ__StartDate__c') && !this.opportunityIsContracted) ? true : false;

            }

            else if(this.quote.SBQQ__Type__c != 'Amendment') {

                if(parentContractExists) {

                    quoteField.editable = false;

                }

                else if(!parentContractExists) {

                    quoteField.editable = (!isCurrencyRate && !isCurrentYear && !isContractEndDate && !isContractExtension) ? true : false;

                }

            }

            this.quoteFields.add(quoteField);

            System.debug('quoteField.fieldApiName: ' + quoteField.fieldApiName);

            System.debug('quoteField.editable: ' + quoteField.editable);

        }

        if(this.quote.SBQQ__Type__c == 'Amendment') {

            QuoteField quoteField = new QuoteField();

            quoteField.fieldLabel = 'Original Contract Term (years)';

            quotefield.fieldApiName = 'originalContractTerm__c';

            quoteField.editable = false;

            this.quoteFields.add(quoteField);

        }

        if(parentContractExists && this.quote.SBQQ__Type__c != 'Amendment') {

            this.userMessage = 'The parent contract (';

            this.userMessage += parentContractNumber;

            this.userMessage += ') exists for this opportunity so any changes would occur through an amendment.';

            this.messageLocation = 'firstTable';

            this.messageColor = 'orange';            

        }

        else if (this.quote.SBQQ__Type__c == 'Amendment' && this.opportunityIsContracted) {

            this.userMessage = 'The opportunity for this amendment quote has been contracted.';

            this.messageLocation = 'firstTable';

            this.messageColor = 'orange'; 

        }

        else if (this.quote.RecordType.Name == 'Approved') {

            this.userMessage = 'This quote is approved so no changes can be saved.';

            this.messageLocation = 'firstTable';

            this.messageColor = 'orange';  

        }

        this.quoteLineGroups = new List<SBQQ__QuoteLineGroup__c>();

        this.quoteObject = new CventMyd_QuoteObject();

        List<Integer> yearsSorted = new List<Integer>();

        quoteObject = (CventMyd_QuoteObject)JSON.deserialize(this.quote.jsonString__c,CventMyd_QuoteObject.class);

        for(Integer year : quoteObject.outYearMap.keySet()) {yearsSorted.add(year);}

        yearsSorted.sort();

        this.outyearMap = new Map<Integer,CventMyd_Outyear>();

        this.lockDates = (parentContractExists && quote.SBQQ__Type__c != 'Amendment');   

        this.extensionYears = (quote.Contract_Extension__c != null) ? Integer.valueOf(quote.Contract_Extension__c) : null;

        this.lowestEditableYear = (extensionYears != null) ? (Integer)(quote.originalContractTerm__c + 1) : 10000;                       

        for(Integer year : yearsSorted) {

            SBQQ__QuoteLineGroup__c yearGroup = new SBQQ__QuoteLineGroup__c();

            yearGroup.Name = 'Year ' + String.valueOf(year);

            yearGroup.term__c = year;

            yearGroup.SBQQ__StartDate__c = quoteObject.outYearMap.get(year).startDate;

            yearGroup.SBQQ__EndDate__c = quoteObject.outYearMap.get(year).endDate;

            CventMyd_Outyear outyear = new CventMyd_Outyear();

            if(!lockDates && !(quote.SBQQ__Type__c == 'Amendment' && yearGroup.term__c < lowestEditableYear)) {

                yearGroup.SBQQ__Optional__c = true;

            }

            else {

                yearGroup.SBQQ__Optional__c = false;

            }            

            outyear.startDate = yearGroup.SBQQ__StartDate__c;

            outyear.endDate = yearGroup.SBQQ__EndDate__c;

            outyearMap.put(year,outyear);

            this.quoteLineGroups.add(yearGroup);

        }

        this.outyearMapJson = JSON.serialize(outyearMap);

        this.showOutyearTable = (this.quote.Current_Year__c != Integer.valueOf(this.quote.Contract_Term_Years__c) && this.quote.Contract_Term_Years__c != '1') ? true : false;

    }

    public void updateControllerDates() {

        Boolean currentYearChange = Boolean.valueOf(Apexpages.currentPage().getParameters().get('currentYearChange'));

        String outyearMapJsonString = Apexpages.currentPage().getParameters().get('outyearMap');

        Map<String,Object> outyearObjectMap = (Map<String,Object>)JSON.deserializeUntyped(outyearMapJsonString);

        this.outyearMap = new Map<Integer,CventMyd_Outyear>();

        for(String s : outyearObjectMap.keySet()) {

            Integer termYear = Integer.valueOf(s);

            Object outyearObject = outyearObjectMap.get(s);

            CventMyd_Outyear outyear = (CventMyd_Outyear)JSON.deserialize(JSON.serialize(outyearObject),CventMyd_Outyear.class);

            this.outyearMap.put(termYear,outyear);

        }

        this.quoteObject.outyearMap = this.outyearMap;

        this.quoteLineGroups.clear();

        List<Integer> yearsSorted = new List<Integer>();

        Integer originalTermLength = (Integer)quote.originalContractTerm__c;

        for(Integer year : this.outyearMap.keySet()) {yearsSorted.add(year);}

        yearsSorted.sort();

        this.extensionYears = (quote.Contract_Extension__c != null) ? Integer.valueOf(quote.Contract_Extension__c) : null;

        this.lowestEditableYear = (extensionYears != null) ? (Integer)(quote.originalContractTerm__c + 1) : 10000;           

        System.debug('quote.originalContractTerm__c: ' + quote.originalContractTerm__c);

        System.debug('lowestEditableYear: ' + lowestEditableYear);

        for(Integer year : yearsSorted) {

            SBQQ__QuoteLineGroup__c yearGroup = new SBQQ__QuoteLineGroup__c();

            yearGroup.Name = 'Year ' + String.valueOf(year);

            yearGroup.term__c = year;

            yearGroup.SBQQ__StartDate__c = quoteObject.outYearMap.get(year).startDate;

            yearGroup.SBQQ__EndDate__c = quoteObject.outYearMap.get(year).endDate;

            System.debug('yearGroup.term__c: ' + yearGroup.term__c);

            if(!lockDates && !(quote.SBQQ__Type__c == 'Amendment' && yearGroup.term__c < lowestEditableYear)) {

                yearGroup.SBQQ__Optional__c = true;

            }

            else {

                yearGroup.SBQQ__Optional__c = false;

            }

            System.debug('yearGroup.SBQQ__Optional__c: ' + yearGroup.SBQQ__Optional__c);

            this.quoteLineGroups.add(yearGroup);

        }

        this.quoteObject.outyearMap = this.outyearMap;

        this.finalYear = (yearsSorted.size() > 0) ? yearsSorted[yearsSorted.size() - 1] : (Integer)this.quote.Current_Year__c;

        this.quote.Contract_End_Date__c = (outyearMap.get(this.finalYear) != null) ? outyearMap.get(this.finalYear).endDate : this.quote.SBQQ__EndDate__c;

        if(currentYearChange) {

            this.userMessage = 'You\'ve changed the current year end date';

            this.messageLocation = 'firstTable';

            this.showOutyearTable = true;

            if(this.quoteLineGroups.size() == 0) {this.showOutyearTable = false;}

            else {this.userMessage = this.userMessage + ', which changes outyear dates.';}

        }

        else {

            if(this.quoteLineGroups.size() == 0) {

                this.userMessage = 'You\'ve removed your outyears.';

                this.messageLocation = 'firstTable';

                this.showOutyearTable = false;

            }

            else {

                this.userMessage = 'You\'ve changed outyear dates, which changes the end date of the parent contract.';

                this.messageLocation = 'secondTable';

                this.showOutyearTable = true;

            }

        }

        this.messageColor = 'orange';

        this.outyearMapJson = JSON.serialize(this.outyearMap);

        this.quote.jsonString__c = JSON.serialize(this.quoteObject);

        this.quote.Contract_Term_Years__c = String.valueOf(finalYear);

        if(this.quote.RecordType.Name != 'Approved') {

            this.userMessage = (this.userMessage != null) ? this.userMessage + ' Click save to finalize.' : null;

        }

        else {

            this.userMessage = (this.userMessage != null) ? this.userMessage + '.. But the quote is already approved.' : null;

        }
        
    }

    public void saveQuote() {

        quote.Year_2_End_Date__c = null;

        quote.Year_3_End_Date__c = null;

        quote.Year_4_End_Date__c = null;

        quote.Year_5_End_Date__c = null;

        this.quote.jsonString__c = JSON.serialize(this.quoteObject);

        Boolean proceedToUpdateQuote = true;

        if(this.quoteObject.automationStage != null) {

            Map<String,Boolean> quoteStatusMap = CventMyd_UtilityMethods.getQuoteStatusMap(this.quoteObject);

            Boolean renewalQuoteIsNewlyInserted = (quoteStatusMap.get('newlyInsertedVariable') || quoteStatusMap.get('newlyInsertedNonVariable'));

            Boolean currentYearFinished = quoteStatusMap.get('currentYearFinished');

            Boolean outyearInsertionInProgress = quoteStatusMap.get('outyearProcessingInProgress');

            if(quote.isLockedIntratermRenewal__c && (renewalQuoteIsNewlyInserted || currentYearFinished || outyearInsertionInProgress)) {

                this.userMessage = 'This renewal quote has not finished outyear processing. Please wait before making changes or log a defect if you cannot make a change after waiting.';

                this.messageColor = 'red';

                this.messageLocation = 'firstTable';                

                proceedToUpdateQuote = false;

            }

        }

        if(proceedToUpdateQuote) {

            Database.SaveResult sr = Database.update(quote);

            if(sr.isSuccess()) {

                Id quoteId = this.quote.Id;

                this.userMessage = 'Changes saved. Please refresh to check on the status of quote recalculation. Do not modify the quote while it is undergoing calculation.';

                this.messageColor = 'green';

                this.messageLocation = 'firstTable';

                this.quote = Database.query(this.queryString);

            }

        }

    }    

}