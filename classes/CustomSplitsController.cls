public class CustomSplitsController {

    public List<Custom_Opportunity_Splits__c> splitRecords {get;set;}
    public List<SplitRow> splitRows {get;set;}
    public Id opportunityId {get;set;}
    public Id quoteId {get;set;}
    public Map<Id,BookingClassificationWrapper> bcIdToBcWrapper {get;set;}
    public String bcPicklistFieldName {get;set;}
    public String splitRowMapJson {get;set;}
    public String bcTypeToBcFieldName {get;set;}
    public String pageLoadUrlEnd {get;set;}
    public Opportunity opportunity {get;set;}
    public List<Booking_Classification__c> bcRecords {get;set;}
    public Map<String,Integer> splitSectionToIndex = new Map<String,Integer>();
    public String errorMessage {get;set;}
    public String successMessage {get;set;}
    public String errorMessageStart {get;set;}
    public String splittingBy {get;set;}
    public Integer overlayRowCount {get;set;}
    public List<String> allProductFamilies {get;set;}
    public List<SelectOption> productFamilySelectOptions {get;set;}
    public String amountString {get;set;}

    public class SplitRow {

        public Custom_Opportunity_Splits__c splitRecord {get;set;}
        public Integer rowSpan {get;set;}
        public Boolean renderMergedCells {get;set;}
        public String rowId {get;set;}
        public String inputId {get;set;}
        public String outputId {get;set;}        
        public String toBeDeletedId {get;set;}
        public String deleteThisRowId {get;set;}
        public List<SelectOption> bcTypes {get;set;}
        public Boolean isOverlay {get;set;}
        public String lookupTdId {get;set;}
        public Long msAtLastChange {get;set;}
        public Integer index {get;set;}
        public String rowColor {get;set;}
        public Decimal amount {get;set;}
        public string memberName {get;set;}
        public Decimal input {get;set;}
        public Decimal output {get;set;}
        public Decimal percentage {get;set;}

        public SplitRow(Custom_Opportunity_Splits__c splitRecord) {
            this.rowId = String.valueOf(splitRecord.Id);
            this.splitRecord = splitRecord;
            this.memberName = splitRecord.Team_Member__r.Name;
            this.amount = splitRecord.Split_Amount__c;        
            this.inputId = this.rowId + '-input';
            this.outputId = this.rowId + '-output';
            this.lookupTdId = this.rowId + '-lookupTdId';
            this.toBeDeletedId = this.rowId + '-toBeDeletedId';
            this.deleteThisRowId = this.rowId + '-deleteThisRowId';
            this.percentage = (splitRecord.Split_Amount__c / splitRecord.BCT_Factor_Total__c) * 100;
            this.percentage = this.percentage.setScale(2);
            this.msAtLastChange = 0;
        }

    }
    
    public static String getErrorMessageStart() {
        String errorMessageStart = 'An error has occurred...;';
        errorMessageStart += 'Provide the following information to your Salesforce admin...';
        return errorMessageStart;
    }   

    public class BookingClassificationWrapper {
        public Booking_Classification__c bookingClassificationRecord {get;set;}
        public List<SplitRow> splitRows {get;set;}
        public BookingClassificationWrapper() {
            this.splitRows = new List<SplitRow>();
        }
    }

    public static Map<String,String> getBcTypeMap() {
        Map<String,String> bcTypeToBcFieldName = new Map<String,String>();
        //bcTypeToBcFieldName.put('NBB','Total_NBB_USD__c');
        bcTypeToBcFieldName.put('NBB','Total_NBB_Total__c');
        //bcTypeToBcFieldName.put('MYD','MYD_USD__c');
        bcTypeToBcFieldName.put('MYD','MYD_Total__c');
        //bcTypeToBcFieldName.put('Renewal','Renewal_Value_USD__c');
        bcTypeToBcFieldName.put('Renewal','Renewal_Value_Total__c');
        //bcTypeToBcFieldName.put('Other','Others_USD__c');  
        bcTypeToBcFieldName.put('Other','Others__c');  
        return bcTypeToBcFieldName;
    }

    public CustomSplitsController() {
        loadControllerValues();
    }

    public void loadControllerValues() {
        String opportunityIdString = ApexPages.currentPage().getParameters().get('opportunityIdString');
        this.bcTypeToBcFieldName = JSON.serialize(getBcTypeMap());
        this.allProductFamilies = new List<String>();
        this.productFamilySelectOptions = new List<SelectOption>();
        productFamilySelectOptions.add(getBlankSelectOption());
        setSplittingBy();
        System.debug('opportunityIdString: ' + opportunityIdString);
        this.pageLoadUrlEnd = 'apex/CustomSplits?opportunityIdString=';
        if(opportunityIdString != null) {
            this.opportunityId = Id.valueOf(opportunityIdString);
        }
        else if(this.opportunityId == null) {
            List<Custom_Opportunity_Splits__c> splitRecords = [SELECT
                Opportunity__c
                FROM Custom_Opportunity_Splits__c
                LIMIT 1500
            ];
            Integer listSize = splitRecords.size();
            Integer randomIndex = (Integer)Math.round(Math.random() * listSize);
            this.opportunityId = splitRecords[randomIndex].Opportunity__c;
        }          
        this.pageLoadUrlEnd += this.opportunityId;
        /*
            loop through the custom split object records
            for each record, initialize an instance of the SplitRow object 
            for split records with Split_Type__c of Revenue, place them within the BookingClassificationWrapper map
            ----> this map points from booking classification Id
            for split records with Split_Type__c of overlay, place them in a separate collection of custom split records
            pass the bcId map and the overlay split record collections to a separate method
            ----> separate method named setSplitRows takes the collections and outputs a list of SplitRow to be displayed on the page
        */
        this.bcRecords = new List<Booking_Classification__c>();    
        Map<Id,BookingClassificationWrapper> bcIdToBcWrapper = new Map<Id,BookingClassificationWrapper>();
        List<SplitRow> overlaySplitRows = new List<SplitRow>();        
        Set<Id> bcIds = new Set<Id>();
        Integer index = 0;
        for(Custom_Opportunity_Splits__c os : getCustomSplitRecords(opportunityId)) {
            SplitRow splitRow = new SplitRow(os);
            splitRow.index = index;
            if(os.Product_Family__c != null && !this.allProductFamilies.contains(os.Product_Family__c)) {
                this.allProductFamilies.add(os.Product_Family__c);
                SelectOption selectOption = new SelectOption(os.Product_Family__c,os.Product_Family__c);
                this.productFamilySelectOptions.add(selectOption);
            }
            if(os.Booking_Classification_Record__c != null) {
                BookingClassificationWrapper bcWrapper = bcIdToBcWrapper.get(os.Booking_Classification_Record__c);
                if(!bcIds.contains(os.Booking_Classification_Record__c)) {
                    this.bcRecords.add(os.Booking_Classification_Record__r);
                }
                bcIds.add(os.Booking_Classification_Record__c);
                if(bcWrapper == null) {
                    bcWrapper = new BookingClassificationWrapper();
                    bcWrapper.bookingClassificationRecord = os.Booking_Classification_Record__r;
                }
                System.debug('bcWrapper.bookingClassificationRecord: ' + bcWrapper.bookingClassificationRecord);
                splitRow.bcTypes = getSelectOptions(bcWrapper.bookingClassificationRecord);
                bcWrapper.splitRows.add(splitRow); 
                bcIdToBcWrapper.put(os.Booking_Classification_Record__c,bcWrapper);                
            }
            else if(os.Split_Type__c == 'Overlay') {
                overlaySplitRows.add(splitRow);
            }
            index++;
            setPageVariables(os);
        }
        Integer i = 0;
        while(i < this.bcRecords.size()) {
            Booking_Classification__c bcRecord = bcRecords[i];
            String splitSection = bcRecord.Product_Family__c;
            splitSectionToIndex.put(splitSection,i);
            i++;
        }
        if(!overlaySplitRows.isEmpty()) {
            splitSectionToIndex.put('Overlay', i + 1);
        }
        setSplitRows(bcIdToBcWrapper,overlaySplitRows);
    }

    public void setPageVariables(Custom_Opportunity_Splits__c os) {
        this.quoteId = os.Opportunity__r.SBQQ__PrimaryQuote__c;
        this.opportunityId = os.Opportunity__c;
        this.opportunity = os.Opportunity__r;
        this.amountString = 'Amount (' + this.opportunity.CurrencyIsoCode + ')';
    }

    public void setSplitRows(Map<Id,BookingClassificationWrapper> bcIdToBcWrapper, List<SplitRow> overlaySplitRows) {
        this.splitRows = new List<SplitRow>();
        System.debug('setting the split rows in the controller...');
        Map<String,SplitRow> rowIdToSplitRow = new Map<String,SplitRow>();
        Map<Integer,SplitRow> indexToSplitRow = new Map<Integer,SplitRow>();
        for(Id bcId : bcIdToBcWrapper.keySet()) {
            BookingClassificationWrapper bcWrapper = bcIdToBcWrapper.get(bcId);
            List<SplitRow> bcSplitRows = bcWrapper.splitRows;
            Boolean renderMergedCells = true;
            for(SplitRow splitRow : bcSplitRows) {
                splitRow.renderMergedCells = renderMergedCells;
                splitRow.rowSpan = bcSplitRows.size();
                renderMergedCells = false;
                indexToSplitRow.put(splitRow.index,splitRow);
            }
        }
        for(Integer i = 0; i < overlaySplitRows.size(); i++) {
            SplitRow splitRow = overlaySplitRows[i];
            splitRow.renderMergedCells = (i == 0);
            splitRow.rowSpan = overlaySplitRows.size();
            indexToSplitRow.put(splitRow.index,splitRow);
        }
        this.overlayRowCount = overlaySplitRows.size();
        List<Integer> indices = new List<Integer>(indexToSplitRow.keySet());
        indices.sort();
        Integer highestIndex = indices[indices.size() - 1];
        Set<String> uniqueBcTypes = new Set<String>();
        List<SelectOption> allBcTypeSelectOptions = new List<SelectOption>();
        allBcTypeSelectOptions.add(getBlankSelectOption());
        for(Integer index : indices) {
            indexToSplitRow.get(index).bcTypes = null;
            rowIdToSplitRow.put(indexToSplitRow.get(index).rowId,indexToSplitRow.get(index));
            SplitRow splitRow = indexToSplitRow.get(index).clone();
            Custom_Opportunity_Splits__c splitRecord = splitRow.splitRecord;
            System.debug('****************************** Split Row ******************************');
            System.debug('index: ' + index);
            if(splitRecord.Booking_Classification_Record__c != null) {
                List<SelectOption> theseSelectOptions = getSelectOptions(splitRecord.Booking_Classification_Record__r);
                splitRow.bcTypes = theseSelectOptions;
                for(SelectOption selectOption : theseSelectOptions) {
                    if(!uniqueBcTypes.contains(selectOption.getValue())) {
                        uniqueBcTypes.add(selectOption.getValue());
                        allBcTypeSelectOptions.add(selectOption);
                    }
                }                
            }
            System.debug('splitRow.rowId: ' + splitRow.rowId);
            System.debug('amount (before): ' + splitRow.amount);
            splitRow.amount = splitRow.amount.setScale(2);
            System.debug('amount (after): ' + splitRow.amount);
            Id bcId = splitRecord.Booking_Classification_Record__c;
            String splitSection = (splitRecord.Split_Type__c == 'Overlay') ? 'Overlay' : splitRecord.Product_Family__c ;
            System.debug('splitSection: ' + splitSection);
            System.debug('splitSectionToIndex: ' + JSON.serialize(splitSectionToIndex));
            if(splitRecord.Split_Type__c != 'Overlay') {
                splitRow.rowColor = (Math.mod(splitSectionToIndex.get(splitSection),2) == 0) ? '#e6f0ff' : '#ffffe6';
            }
            else if(splitRecord.Split_Type__c == 'Overlay') {
                splitRow.rowColor = '#ccccff';
                splitRow.bcTypes = allBcTypeSelectOptions;
            }
            System.debug('split row credit type: ' + splitRecord.Credit_Type__c );
            //splitRow.splitRecord.BCT_Factor_Pct__c = (splitRow.amount / splitRow.splitRecord.Split_Amount__c) * 100;
            //splitRow.splitRecord.BCT_Factor_Pct__c = splitRow.splitRecord.BCT_Factor_Pct__c.setScale(2);   
            //splitRow.percentage = (splitRow.amount / splitRow.splitRecord.BCT_Factor_Total__c);        
            splitRow.input = (splittingBy == 'Amount') ? splitRow.amount : splitRow.percentage;          
            splitRow.output = (splittingBy == 'Amount') ? splitRow.percentage : splitRow.amount ;
            System.debug('splitRow.input: ' + splitRow.input);
            System.debug('splitRow.output: ' + splitRow.output);
            System.debug('splitRow.percentage: ' + splitRow.percentage);
            System.debug('splitRow.deleteThisRowId: ' + splitRow.deleteThisRowId);
            this.splitRows.add(splitRow);
        }
        System.debug('rowIdToSplitRow.keySet(): ' + rowIdToSplitRow.keySet());
        this.splitRowMapJson = JSON.serialize(rowIdToSplitRow);
    }

    public static SelectOption getBlankSelectOption() {
        SelectOption selectOption = new SelectOption('','Not Specified');
        return selectOption;
    }

    public void setSplittingBy() {
        System.debug('splitting by before: ' + splittingBy);
        String splittingByString = ApexPages.currentPage().getParameters().get('splittingBy');
        this.splittingBy = (splittingByString != null) ? splittingByString : 'Amount';
        System.debug('splitting by after: ' + splittingBy);
    }

    public static List<SelectOption> getSelectOptions(Booking_Classification__c bookingClassification) {
        List<SelectOption> selectOptions = new List<SelectOption>();
        Map<String,String> bcFieldNameToPicklistValue = new Map<String,String>();
        //bcFieldNameToPicklistValue.put('Total_NBB_USD__c','NBB');
        bcFieldNameToPicklistValue.put('Total_NBB_Total__c','NBB');
        //bcFieldNameToPicklistValue.put('MYD_USD__c','MYD');
        bcFieldNameToPicklistValue.put('MYD_Total__c','MYD');
        //bcFieldNameToPicklistValue.put('Renewal_Value_USD__c','Renewal');
        bcFieldNameToPicklistValue.put('Renewal_Value_Total__c','Renewal');
        //bcFieldNameToPicklistValue.put('Others_USD__c','Other');        
        bcFieldNameToPicklistValue.put('Others__c','Other');        
        for(String fieldName : bcFieldNameToPicklistValue.keySet()) {
            if((Decimal)bookingClassification.get(fieldName) > 0) {
                String pickListValue = bcFieldNameToPicklistValue.get(fieldName);
                SelectOption selectOption = new SelectOption(pickListValue,pickListValue);
                selectOptions.add(selectOption);
            }
        }
        return selectOptions;
    }      

    public static String getQueryString(Id opportunityId) {
       Set<String> fieldNames = new Set<String> {
            'Credit_Type__c','index__c',
            'LastModifiedDate','CreatedDate',
            'Opportunity__c','Opportunity__r.name',
            'Opportunity__r.Opportunity_Type__c',
            'Opportunity__r.CurrencyIsoCode',
            'Split_Amount__c',
            'Opportunity__r.Amount','Opportunity__r.Owner.Name',
            'Opportunity__r.StageName',
            'BCT_Factor_Total__c','BCT_Factor_Pct__c',
            'Opportunity__r.SBQQ__PrimaryQuote__c',
            'Bookings_Classification__c',
            'Booking_Classification_Record__c',
            'Booking_Classification_Record__r.Product_Family__c',
            'Booking_Classification_Record__r.Name',
            'Booking_Classification_Record__r.UFR_Total__c',            
            'Booking_Classification_Record__r.Total_NBB_USD__c',
            'Booking_Classification_Record__r.Total_NBB_Total__c',
            'Booking_Classification_Record__r.MYD_USD__c',
            'Booking_Classification_Record__r.MYD_Total__c',
            'Booking_Classification_Record__r.Renewal_Value_USD__c',
            'Booking_Classification_Record__r.Renewal_Value_Total__c',
            'Booking_Classification_Record__r.Others_USD__c',
            'Booking_Classification_Record__r.Others__c',
            'Booking_Classification_Record__r.UFR_Total__c',
            'Booking_Classification_Record__r.Total_Price_Total__c',
            'Product_Family__c','Split_Type__c',
            'Team_Member__c','Team_Member__r.Name'
        };
        String queryString = 'SELECT Id,Name,' + CventMyd_UtilityMethods.getFieldNamesStringFromStringSet(fieldNames);
        queryString += ' FROM Custom_Opportunity_Splits__c WHERE';
        queryString += ' Opportunity__c =: opportunityId';
        queryString += ' AND Split_Amount__c != null AND Split_Amount__c != 0';
        queryString += ' ORDER BY Booking_Classification_Record__r.Name ASC NULLS LAST,Booking_Classification_Record__r.Product_Family__c ASC, index__c ASC, CreatedDate ASC';
        return queryString;
    }

    public void receiveSplitRowMap() {
        String mapJsonFromPage = ApexPages.currentPage().getParameters().get('splitRowMapJson');
        String trySaveString = ApexPages.currentPage().getParameters().get('trySave');
        String splittingByString = ApexPages.currentPage().getParameters().get('splittingBy');
        System.debug('splittingByString: ' + splittingByString);
        System.debug('split row list size before: ' + splitRows.size());
        setSplittingBy();
        this.errorMessage = null;
        this.successMessage = null;
        System.debug('trySaveString: ' + trySaveString);
        Boolean trySave = Boolean.valueOf(trySaveString);
        Map<String,SplitRow> splitRowMapFromPage = new Map<String,SplitRow>();
        Map<String,Object> splitRowMapObj = (Map<String,Object>)JSON.deserializeUntyped(mapJsonFromPage);
        for(String splitRowId : splitRowMapObj.keySet()) {
            Object splitRowObj = splitRowMapObj.get(splitRowId);
            SplitRow splitRow = (SplitRow)JSON.deserialize(JSON.serialize(splitRowObj),SplitRow.class);
            splitRowMapFromPage.put(splitRowId,splitRow);
        }
        System.debug('split row map key set size: ' + splitRowMapFromPage.keySet().size());
        this.bcIdToBcWrapper = new Map<Id,BookingClassificationWrapper>();
        Map<Integer,SplitRow> indexToSplitRow = new Map<Integer,SplitRow>();
        for(String splitRowId : splitRowMapFromPage.keySet()) {
            SplitRow splitRow = splitRowMapFromPage.get(splitRowId);
            indexToSplitRow.put(splitRow.index,splitRow);
        }
        List<Integer> indices = new List<Integer>(indexToSplitRow.keySet());
        indices.sort();
        Map<String,Id> rowIdToMemberId = new Map<String,Id>();
        for(SplitRow splitRow : this.splitRows) {
            rowIdToMemberId.put(splitRow.rowId,splitRow.splitRecord.Team_Member__c);
        }
        List<SplitRow> overlaySplitRows = new List<SplitRow>();
        Set<String> uniqueBcTypes = new Set<String>();   
        List<SelectOption> allBcTypeSelectOptions = new List<SelectOption>(); 
        for(Integer index : indices) {
            SplitRow splitRow = indexToSplitRow.get(index);
            Id bcId = splitRow.splitRecord.Booking_Classification_Record__c;
            Boolean isOverlay = (splitRow.splitRecord.Split_Type__c == 'Overlay');
            System.debug('bcId: ' + bcId);
            if(bcIdToBcWrapper.get(bcId) == null && !isOverlay && bcId != null) {
                BookingClassificationWrapper bcWrapper = new BookingClassificationWrapper();
                bcWrapper.bookingClassificationRecord = splitRow.splitRecord.Booking_Classification_Record__r;
                bcIdToBcWrapper.put(bcId,bcWrapper);
            }
            splitRow.splitRecord.Team_Member__c = rowIdToMemberId.get(splitRow.rowId);
            if(bcId != null && !isOverlay) {
                BookingClassificationWrapper bcWrapper = bcIdToBcWrapper.get(bcId);
                List<SelectOption> theseSelectOptions = getSelectOptions(bcWrapper.bookingClassificationRecord);
                splitRow.bcTypes = theseSelectOptions;
                for(SelectOption selectOption : theseSelectOptions) {
                    if(!uniqueBcTypes.contains(selectOption.getValue())) {
                        uniqueBcTypes.add(selectOption.getValue());
                        allBcTypeSelectOptions.add(selectOption);
                    }
                }
                bcWrapper.splitRows.add(splitRow);
            }
            else if(isOverlay) {
                if(!allBcTypeSelectOptions.isEmpty()) {
                    splitRow.bcTypes = allBcTypeSelectOptions;
                }
                overlaySplitRows.add(splitRow);
                System.debug('adding overlay row...');
            }
        }
        System.debug('overlayRowCount (before): ' + overlayRowCount);     
        setSplitRows(this.bcIdToBcWrapper,overlaySplitRows);
        System.debug('overlayRowCount (after): ' + overlayRowCount);   
        if(trySave) {
            System.debug('preparing to save records...');
            this.errorMessage = validateUserUniqueness(this.splitRows);
            if(String.isBlank(this.errorMessage)) {
                System.debug('no issues found, moving forward with save operation');
                List<Custom_Opportunity_Splits__c> recordsToDelete = new List<Custom_Opportunity_Splits__c>();
                List<Custom_Opportunity_Splits__c> recordsToUpsert = new List<Custom_Opportunity_Splits__c>();
                for(SplitRow splitRow : this.splitRows) {
                    if(splitRow.splitRecord.Id != null && splitRow.amount == 0) {
                        recordsToDelete.add(splitRow.splitRecord);
                    }
                    else {
                        System.debug('split record index: ' + splitRow.index);
                        Id splitRecordId = splitRow.splitRecord.Id;
                        System.debug('splitRecordId: ' + splitRecordId);
                        if(splitRecordId != null) {
                            System.debug('splitRecord.createdDate: ' + splitRow.splitRecord.createdDate);
                            System.debug('splitRecord.lastmodifieddate: ' + splitRow.splitRecord.LastModifiedDate);                        
                        }
                        splitRow.splitRecord.index__c = splitRow.index;
                        System.debug('splitRow.amount******: ' + splitRow.amount);
                        System.debug('splitRecord.BCT_Factor_Total__c******: ' + splitRow.splitRecord.BCT_Factor_Total__c);
                        splitRow.splitRecord.Split_Amount__c = splitRow.amount;
                        //splitRow.splitRecord.BCT_Factor_Pct__c = (splitRow.amount / splitRow.splitRecord.BCT_Factor_Total__c) * 100;
                        //splitRow.splitRecord.BCT_Factor_Pct__c = splitRow.splitRecord.BCT_Factor_Pct__c.setScale(6);
                        System.debug('splitRecord.BCT_Factor_Pct__c******: ' + splitRow.splitRecord.BCT_Factor_Pct__c);
                        recordsToUpsert.add(splitRow.splitRecord);
                    }
                }
                System.debug('recordsToDelete.size(): ' + recordsToDelete.size());
                System.debug('recordsToUpsert.size(): ' + recordsToUpsert.size());
                this.errorMessage = validateSplitRecords(recordsToUpsert,null);
                Savepoint savepoint = Database.setSavepoint();
                if(this.errorMessage == null && !recordsToDelete.isEmpty()) {                    
                    for(Database.DeleteResult deleteResult : Database.delete(recordsToDelete)) {
                        if(!deleteResult.isSuccess()){
                            this.successMessage = null;
                            this.errorMessage = 'Deletion failure for id ' + String.valueOf(deleteResult.getId());
                            break;
                        }
                    }
                }
                if(this.errorMessage == null && !recordsToUpsert.isEmpty()) {
                    for(Database.UpsertResult upsertResult : Database.upsert(recordsToUpsert)) {
                        System.debug('upsertResult.isCreated(): ' + upsertResult.isCreated());
                        System.debug('upsertResult.isSuccess(): ' + upsertResult.isSuccess());
                        System.debug('upsertResult.getId(): ' + upsertResult.getId());
                        if(!upsertResult.isSuccess()){
                            this.successMessage = null;
                            this.errorMessage = 'Upsertion failure: ' + String.valueOf(upsertResult.getErrors());
                            break;
                        }
                    }
                }
                if(this.errorMessage == null) {
                    loadControllerValues();
                    this.successMessage = 'Split records saved successfully... Validating records... Please wait...';
                }
                else {
                    Database.rollback(savepoint);
                }
            }
        }
        System.debug('split row list size after: ' + splitRows.size());    
    }
    
    public String validateUserUniqueness(List<SplitRow> splitRows) {
        String errorMessage = '';
        Map<String,Set<Id>> bcComboToMemberIds = new Map<String,Set<Id>>();
        for(SplitRow splitRow : splitRows) {
            String productFamily = String.valueOf(splitRow.splitRecord.Booking_Classification_Record__r.Product_Family__c);
            String bcCombo = productFamily;
            bcCombo += '-' + splitRow.splitRecord.Bookings_Classification__c;
            Id teamMemberId = splitRow.splitRecord.Team_Member__c;
            if(teamMemberId == null) {
                errorMessage = 'Validation Error: Split row with number ' + (splitRow.index + 1);
                errorMessage += ' has no team member user Id populated';
                break;
            }
            else if(bcComboToMemberIds.get(bcCombo) == null) {
                bcComboToMemberIds.put(bcCombo,new Set<Id>());
            }
            else {
                Set<Id> memberIds = bcComboToMemberIds.get(bcCombo);
                if(memberIds.contains(teamMemberId)) {
                    errorMessage = 'Validation Error: Split row #' + (splitRow.index + 1);
                    errorMessage += ' has a duplicate team member for the "' + splitRow.splitRecord.Bookings_Classification__c;
                    errorMessage += '" split type';
                    errorMessage += ' for the "' + productFamily + '" product family...';
                    break;
                }
            }
            bcComboToMemberIds.get(bcCombo).add(teamMemberId);
        }  
        return errorMessage;      
    }   

    public static List<Custom_Opportunity_Splits__c> getCustomSplitRecords(Id opportunityId) {
        String queryString = getQueryString(opportunityId);
        Integer i = 0;
        List<Custom_Opportunity_Splits__c> splitRecords = Database.query(queryString);
        for(Custom_Opportunity_Splits__c customSplit : splitRecords) {
            customSplit.index__c = i;
            i++;
        }
        return splitRecords;
    }

    @RemoteAction
    public static String checkSaveSuccess(String opportunityIdString, Map<Integer,Decimal> expectedIndexToAmount) {
        Id opportunityId = Id.valueOf(opportunityIdString);
        System.debug('expectedIndexToAmount: ' + expectedIndexToAmount);
        List<Custom_Opportunity_Splits__c> splitRecords = getCustomSplitRecords(opportunityId);
        String errorMessage = validateSplitRecords(splitRecords,expectedIndexToAmount);
        System.debug('errorMessage: ' + errorMessage);
        return errorMessage;
    }

    public class Total {
        public Decimal amount;
        public Decimal percent;
        public Total() {
            this.amount = 0;
            this.percent = 0;
        }
    }    

    public static String validateSplitRecords(List<Custom_Opportunity_Splits__c> splitRecords, Map<Integer,Decimal> expectedIndexToAmount) {
        System.debug('######## validating split records ########');
        Map<Integer,Decimal> actualIndexToAmount = new Map<Integer,Decimal>();
        Map<String,Total> bcComboToTotal = new Map<String,Total>();
        Map<String,String> bcTypeToBcFieldName = getBcTypeMap();
        Map<Id,Booking_Classification__c> bcIdToBc = new Map<Id,Booking_Classification__c>();
        String errorMessage;
        Decimal opportunityAmount = splitRecords[0].Opportunity__r.Amount;
        System.debug('opportunityAmount: ' + opportunityAmount);
        // first loop through the split records to get a map of BCxPF totals
        // also sum the totals for each member, where both revenue and overlay splits are included
        Map<Id,Decimal> teamMemberToTotal = new Map<Id,Decimal>();
        Map<String,Decimal> memberNameToOverTotalAmount = new Map<String,Decimal>();
        for(Custom_Opportunity_Splits__c splitRecord : splitRecords) {
            System.debug('======================');
            System.debug('index: ' + splitRecord.index__c);
            System.debug('splitRecord.Id: ' + splitRecord.Id);
            System.debug('splitRecord.Split_Amount__c: ' + splitRecord.Split_Amount__c);
            Id userId = splitRecord.Team_Member__c;
            Decimal userTotal = (teamMemberToTotal.get(userId) == null) ? 0 : teamMemberToTotal.get(userId);
            userTotal += splitRecord.Split_Amount__c;
            if(userTotal > opportunityAmount) {
                memberNameToOverTotalAmount.put(splitRecord.Team_Member__r.Name,userTotal);
            }
            teamMemberToTotal.put(userId,userTotal);
            actualIndexToAmount.put((Integer)splitRecord.index__c,splitRecord.Split_Amount__c);
            System.debug('percent: ' + splitRecord.BCT_Factor_Pct__c);
            System.debug('Amount__c: ' + splitRecord.Split_Amount__c);            
            if(splitRecord.Booking_Classification_Record__c != null && splitRecord.Split_Type__c != 'Overlay') {
                Booking_Classification__c bcRecord = splitRecord.Booking_Classification_Record__r;
                String bcCombo = String.valueOf(bcRecord.Id);
                bcCombo += '-' + splitRecord.Bookings_Classification__c;
                if(bcComboToTotal.get(bcCombo) == null) {
                    bcComboToTotal.put(bcCombo,new Total());
                }
                Total bcTotal = bcComboToTotal.get(bcCombo);
                bcTotal.amount += splitRecord.Split_Amount__c;
                // update the below line to ensure that the formula value is not added (it will not be updated via page)
                System.debug('splitRecord.BCT_Factor_Total__c: ' + splitRecord.BCT_Factor_Total__c);
                System.debug('splitRecord.Split_Amount__c: ' + splitRecord.Split_Amount__c);
                Decimal percentageToAdd = (splitRecord.Split_Amount__c / splitRecord.BCT_Factor_Total__c) * 100;
                System.debug('percentageToAdd: ' + percentageToAdd);
                bcTotal.percent += percentageToAdd;
                System.debug('thePercentTotalIsNow: ' + bcTotal.percent);
                bcTotal.percent = bcTotal.percent.setScale(6);
                bcComboToTotal.put(bcCombo,bcTotal);
                bcIdToBc.put(bcRecord.Id,bcRecord);
            }
        }
        System.debug('actualIndexToAmount: ' + actualIndexToAmount);
        if( expectedIndexToAmount != null && actualIndexToAmount.keySet() != expectedIndexToAmount.keySet() ){
            errorMessage = 'Validation Error: ' + getErrorMessageStart();
            List<Integer> actualIndices = new List<Integer>(actualIndexToAmount.keySet());
            actualIndices.sort();
            List<Integer> expectedIndices = new List<Integer>(expectedIndexToAmount.keySet());
            expectedIndices.sort();
            errorMessage += ';Expected row numbers: ';
            for(Integer index : expectedIndices) {
                errorMessage += (index + 1) + ',';
            }
            errorMessage.removeEnd(',');
            errorMessage += ';Actual row numbers: ';
            for(Integer index : actualIndices) {
                errorMessage += (index + 1) + ',';
            }
            errorMessage.removeEnd(',');
        }
        else if(!memberNameToOverTotalAmount.keySet().isEmpty()) {
            errorMessage = 'Validation Error: ' + getErrorMessageStart();
        }
        else {
            for(String bcCombo : bcComboToTotal.keySet()) {
                String bcIdStr = bcCombo.split('-')[0];
                String splitType = bcCombo.split('-')[1];
                Id bcId = Id.valueOf(bcIdStr);
                Booking_Classification__c bcRecord = bcIdToBc.get(bcId);
                Decimal recordAmount = (Decimal)bcRecord.get(bcTypeToBcFieldName.get(splitType));
                recordAmount = recordAmount.setScale(3);
                Decimal summedAmount = bcComboToTotal.get(bcCombo).amount;
                Decimal summedPercentage = bcComboToTotal.get(bcCombo).percent;
                System.debug('summedPercentage: ' + summedPercentage);
                System.debug('recordAmount: ' + recordAmount);
                System.debug('summedAmount: ' + summedAmount);
                System.debug('difference : ' + Math.abs(recordAmount - summedAmount) );                
                if(recordAmount != summedAmount) {
                    if(Math.abs(recordAmount - summedAmount) > .003) {
                        errorMessage = 'Validation Error: ' + getErrorMessageStart();
                        errorMessage += ';For the BC record with the ' + bcRecord.Product_Family__c + ' product family...';
                        errorMessage += ';The total BC amount splitted is ' + String.valueOf(recordAmount);
                        errorMessage += '...;However, the actual split sum is ' + String.valueOf(summedAmount) + '...';
                    }
                }
                if(Math.abs(summedPercentage - 100) > .01) {
                    errorMessage = (errorMessage == null) ? 'Validation Error: ' + getErrorMessageStart() : errorMessage;
                    errorMessage += ';For the BC record with the ' + bcRecord.Product_Family__c + ' product family...';
                    errorMessage += ';The total percentage allocated is ' + String.valueOf(summedPercentage);
                    errorMessage += '; To be correct it must be 100...';
                }
            }
        }   
        if(errorMessage == null && expectedIndexToAmount != null) {
            for(Integer index : expectedIndexToAmount.keySet()) {
                Decimal expectedAmount = expectedIndexToAmount.get(index);
                Decimal actualAmount = actualIndexToAmount.get(index);
                if(actualAmount != expectedAmount) {
                    if(Math.abs(actualAmount - expectedAmount) > .0044) {
                        errorMessage = (errorMessage == null) ? getErrorMessageStart() : errorMessage;
                        errorMessage += ';For row #' + String.valueOf(index + 1);
                        errorMessage += ' the expected amount is ' + String.valueOf(expectedAmount);
                        errorMessage += ' but the actual amount is ' + String.valueOf(actualAmount);
                    }
                }
            }            
        }
        System.debug('errorMessage: ' + errorMessage);
        return errorMessage;    
    }    

}