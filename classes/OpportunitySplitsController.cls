public class OpportunitySplitsController {

    public List<Custom_Opportunity_Split__c> splitRecords {get;set;}
    public List<SplitRow> splitRows {get;set;}
    public Id opportunityId {get;set;}
    public Id quoteId {get;set;}
    public Map<Id,BookingClassificationWrapper> bcIdToBcWrapper {get;set;}
    public String bcPicklistFieldName {get;set;}
    public String splitRowMapJson {get;set;}
    public String splitTypeToBcFieldName {get;set;}
    public String pageLoadUrlEnd {get;set;}
    public Opportunity opportunity {get;set;}
    public List<Booking_Classification__c> bcRecords {get;set;}
    public Map<Id,Integer> bcIdToIndex = new Map<Id,Integer>();
    public String errorMessage {get;set;}
    public String successMessage {get;set;}
    public String errorMessageStart {get;set;}
    public String splittingBy {get;set;}

    public static String getErrorMessageStart() {
        String errorMessageStart = 'An error has occurred...;';
        errorMessageStart += 'Provide the following information to your Salesforce admin...';
        return errorMessageStart;
    }

    public static Map<String,String> getSplitTypeMap() {
        Map<String,String> splitTypeToBcFieldName = new Map<String,String>();
        splitTypeToBcFieldName.put('NBB','Total_NBB_USD__c');
        splitTypeToBcFieldName.put('MYD','MYD_USD__c');
        splitTypeToBcFieldName.put('Renewal','Renewal_Value_USD__c');
        splitTypeToBcFieldName.put('Other','Others_USD__c');  
        return splitTypeToBcFieldName;
    }

    public class SplitRow {
        public Custom_Opportunity_Split__c splitRecord {get;set;}
        public Integer rowSpan {get;set;}
        public Boolean renderMergedCells {get;set;}
        public String rowId {get;set;}
        public String inputId {get;set;}
        public String outputId {get;set;}        
        public String toBeDeletedId {get;set;}
        public String deleteThisRowId {get;set;}
        public List<SelectOption> revenueTypes {get;set;}
        public String lookupTdId {get;set;}
        public Long msAtLastChange {get;set;}
        public Integer index {get;set;}
        public String rowColor {get;set;}
        public Decimal amount {get;set;}
        public string memberName {get;set;}
        public Decimal input {get;set;}
        public Decimal output {get;set;}

        public SplitRow(String rowId) {
            this.rowId = rowId;
            this.inputId = this.rowId + '-input';
            this.outputId = this.rowId + '-output';
            this.lookupTdId = this.rowId + '-lookupTdId';
            this.toBeDeletedId = this.rowId + '-toBeDeletedId';
            this.deleteThisRowId = this.rowId + '-deleteThisRowId';
            this.msAtLastChange = 0;
        }
    }   

    public class BookingClassificationWrapper {
        public Booking_Classification__c bookingClassification {get;set;}
        public List<SplitRow> splitRows {get;set;}
        public BookingClassificationWrapper() {
            this.splitRows = new List<SplitRow>();
        }
    }

    public void setSplitRows(Map<Id,BookingClassificationWrapper> bcIdToBcWrapper) {
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
            //this.splitRows.addAll(bcSplitRows);
        }
        List<Integer> indices = new List<Integer>(indexToSplitRow.keySet());
        indices.sort();
        for(Integer index : indices) {
            indexToSplitRow.get(index).revenueTypes = null;
            rowIdToSplitRow.put(indexToSplitRow.get(index).rowId,indexToSplitRow.get(index));
            SplitRow splitRow = indexToSplitRow.get(index).clone();
            System.debug('****************************** Split Row ******************************');
            System.debug('index: ' + index);
            splitRow.revenueTypes = getSelectOptions(splitRow.splitRecord.Booking_Classification_ID__r);
            System.debug('splitRow.rowId: ' + splitRow.rowId);
            System.debug('amount (before): ' + splitRow.amount);
            splitRow.amount = splitRow.amount.setScale(2);
            System.debug('amount (after): ' + splitRow.amount);
            Id bcId = splitRow.splitRecord.Booking_Classification_ID__c;
            splitRow.rowColor = (Math.mod(bcIdToIndex.get(bcId),2) == 0) ? '#e6f0ff' : '#ffffe6';
            System.debug('split row credit type: ' + splitRow.splitRecord.Credit_Type__c );
            splitRow.splitRecord.Split_Percent__c = (splitRow.amount / splitRow.splitRecord.Amount__c) * 100;
            splitRow.splitRecord.Split_Percent__c = splitRow.splitRecord.Split_Percent__c.setScale(2);              
            splitRow.input = (splittingBy == 'Amount') ? splitRow.amount : splitRow.splitRecord.Split_Percent__c;          
            splitRow.output = (splittingBy == 'Amount') ? splitRow.splitRecord.Split_Percent__c : splitRow.amount ;
            System.debug('splitRow.input: ' + splitRow.input);
            System.debug('splitRow.output: ' + splitRow.output);
            this.splitRows.add(splitRow);
        }
        System.debug('rowIdToSplitRow.keySet(): ' + rowIdToSplitRow.keySet());
        this.splitRowMapJson = JSON.serialize(rowIdToSplitRow);
    }

    public OpportunitySplitsController() {
        loadControllerValues();
    }

    public static String getQueryString(Id opportunityId) {
       Set<String> fieldNames = new Set<String> {
            'Amount__c','Booking_Classification__c','Credit_Type__c',
            'LastModifiedDate','CreatedDate',
            'Booking_Classification_ID__r.Product_Family__c',
            'Booking_Classification_ID__c',
            'Booking_Classification_ID__r.Name',
            'Booking_Classification_ID__r.UFR_Total__c',
            'Opportunity__c','Opportunity__r.name',
            'Opportunity__r.Opportunity_Type__c',
            'Opportunity__r.Amount','Opportunity__r.Owner.Name',
            'Opportunity__r.StageName',
            'Opportunity__r.SBQQ__PrimaryQuote__c',
            'Booking_Classification_ID__r.Total_NBB_USD__c',
            'Booking_Classification_ID__r.MYD_USD__c',
            'Booking_Classification_ID__r.Renewal_Value_USD__c',
            'Booking_Classification_ID__r.UFR_Total__c',
            'Booking_Classification_ID__r.Others_USD__c',
            'Booking_Classification_ID__r.Total_Price_Total__c',
            'index__c',
            'Product_Family__c','Split_Percent__c','splitAmount__c',
            'Team_Member__c','Team_Member__r.Name',
            'Total_Bookings_Classifications_Price__c'
        };
        String queryString = 'SELECT Id,Name,' + CventMyd_UtilityMethods.getFieldNamesStringFromStringSet(fieldNames);
        queryString += ' FROM Custom_Opportunity_Split__c WHERE ';
        queryString += 'Opportunity__c =: opportunityId ';
        queryString += ' ORDER BY Booking_Classification_ID__r.Name ASC, index__c ASC, CreatedDate ASC';
        return queryString;
    }

    public void loadControllerValues() {
        splitTypeToBcFieldName = JSON.serialize(getSplitTypeMap());
        errorMessageStart = getErrorMessageStart();
        setSplittingBy();
        this.pageLoadUrlEnd = 'apex/OpportunitySplits?opportunityIdString=';
        bcPicklistFieldName = 'Booking Classification 1';
        String opportunityIdString = ApexPages.currentPage().getParameters().get('opportunityIdString');
        String justSaved = ApexPages.currentPage().getParameters().get('justSaved');
        if(justSaved != null && Boolean.valueOf(justSaved)) {
            this.successMessage = 'Split records saved and validated.';
        }
        if(opportunityIdString != null) {
            this.opportunityId = Id.valueOf(opportunityIdString);
        }
        else if(this.opportunityId == null) {
            List<Custom_Opportunity_Split__c> splitRecords = [SELECT
                Opportunity__c
                FROM Custom_Opportunity_Split__c
                LIMIT 1500
            ];
            Integer listSize = splitRecords.size();
            Integer randomIndex = (Integer)Math.round(Math.random() * listSize);
            this.opportunityId = splitRecords[randomIndex].Opportunity__c;
        }
        this.pageLoadUrlEnd += this.opportunityId;
        this.splitRows = new List<SplitRow>();
        Map<Id,BookingClassificationWrapper> bcIdToBcWrapper = new Map<Id,BookingClassificationWrapper>();
        Integer index = 0;
        Set<Id> bcIds = new Set<Id>();
        this.bcRecords = new List<Booking_Classification__c>();
        String queryString = getQueryString(this.opportunityId);
        for(Custom_Opportunity_Split__c os : Database.query(queryString)) {
            this.quoteId = os.Opportunity__r.SBQQ__PrimaryQuote__c;
            this.opportunityId = os.Opportunity__c;
            this.opportunity = os.Opportunity__r;
            Id bcId = os.Booking_Classification_ID__c;
            if(!bcIds.contains(bcId)) {
                bcIds.add(bcId);
                this.bcRecords.add(os.Booking_Classification_ID__r);
            }
            BookingClassificationWrapper bcWrapper = bcIdToBcWrapper.get(bcId);
            SplitRow splitRow = new SplitRow(String.valueOf(os.Id));
            splitRow.memberName = os.Team_Member__r.Name;
            splitRow.index = index;
            index++;
            splitRow.amount = os.splitAmount__c;
            System.debug('CHECKING THE AMOUNT: ' + splitRow.amount);
            splitRow.splitRecord = os;
            if(bcWrapper == null) {
                bcWrapper = new BookingClassificationWrapper();
                bcWrapper.bookingClassification = os.Booking_Classification_ID__r;
            }
            splitRow.revenueTypes = getSelectOptions(bcWrapper.bookingClassification);
            bcWrapper.splitRows.add(splitRow);
            bcIdToBcWrapper.put(bcId,bcWrapper);
        }
        System.debug('in constructor, the key set size is: ' + bcIdToBcWrapper.keySet().size());
        for(Integer i = 0; i < this.bcRecords.size(); i++) {
            bcIdToIndex.put(this.bcRecords[i].Id,i);
        }
        setSplitRows(bcIdToBcWrapper);
    }    

    public static List<SelectOption> getSelectOptions(Booking_Classification__c bookingClassification) {
        List<SelectOption> selectOptions = new List<SelectOption>();
        Map<String,String> bcFieldNameToPicklistValue = new Map<String,String>();
        bcFieldNameToPicklistValue.put('Total_NBB_USD__c','NBB');
        bcFieldNameToPicklistValue.put('MYD_USD__c','MYD');
        bcFieldNameToPicklistValue.put('Renewal_Value_USD__c','Renewal');
        bcFieldNameToPicklistValue.put('Others_USD__c','Other');        
        for(String fieldName : bcFieldNameToPicklistValue.keySet()) {
            if((Decimal)bookingClassification.get(fieldName) > 0) {
                String pickListValue = bcFieldNameToPicklistValue.get(fieldName);
                SelectOption selectOption = new SelectOption(pickListValue,pickListValue);
                selectOptions.add(selectOption);
            }
        }
        return selectOptions;
    }

    public static Map<Id,BookingClassificationWrapper> getBcIdToBcWrapper(List<SplitRow> splitRows) {
        Map<Id,BookingClassificationWrapper> bcIdToBcWrapper = new Map<Id,BookingClassificationWrapper>();
        for(SplitRow splitRow : splitRows) {
            BookingClassificationWrapper bcWrapper = bcIdToBcWrapper.get(splitRow.splitRecord.Booking_Classification_Id__c);
            Id bcId = splitRow.splitRecord.Booking_Classification_Id__c;
            if(bcWrapper == null) {
                bcWrapper = new BookingClassificationWrapper();
                bcWrapper.bookingClassification = splitRow.splitRecord.Booking_Classification_Id__r;
            }
            bcWrapper.splitRows.add(splitRow);
            bcIdToBcWrapper.put(bcId,bcWrapper);
        }
        return bcIdToBcWrapper;
    }

    public Set<String> getSplitRowIds(List<SplitRow> splitRows) {
        Set<String> splitRowIds = new Set<String>();
        for(SplitRow splitRow : splitRows) {
            splitRowIds.add(splitRow.rowId);
        }
        return splitRowIds;
    }

    public String validateUserUniqueness(List<SplitRow> splitRows) {
        String errorMessage = '';
        Map<String,Set<Id>> bcComboToMemberIds = new Map<String,Set<Id>>();
        for(SplitRow splitRow : splitRows) {
            String productFamily = String.valueOf(splitRow.splitRecord.Booking_Classification_ID__r.Product_Family__c);
            String bcCombo = productFamily;
            bcCombo += '-' + splitRow.splitRecord.Booking_Classification__c;
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
                if(memberIds.contains(teamMemberId)){
                    errorMessage = 'Validation Error: Split row #' + (splitRow.index + 1);
                    errorMessage += ' has a duplicate team member for the "' + splitRow.splitRecord.Booking_Classification__c;
                    errorMessage += '" split type';
                    errorMessage += ' for the "' + productFamily + '" product family...';
                    break;
                }
            }
            bcComboToMemberIds.get(bcCombo).add(teamMemberId);
        }  
        return errorMessage;      
    }

    public void setSplittingBy() {
        System.debug('splitting by before: ' + splittingBy);
        String splittingByString = ApexPages.currentPage().getParameters().get('splittingBy');
        this.splittingBy = (splittingByString != null) ? splittingByString : 'Amount';
        System.debug('splitting by after: ' + splittingBy);
    }

    public void receiveSplitRowMap() {
        String mapJsonFromPage = ApexPages.currentPage().getParameters().get('splitRowMapJson');
        String trySaveString = ApexPages.currentPage().getParameters().get('trySave');
        String splittingByString = ApexPages.currentPage().getParameters().get('splittingBy');
        System.debug('splittingByString: ' + splittingByString);
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
        for(Integer index : indices) {
            SplitRow splitRow = indexToSplitRow.get(index);
            Id bcId = splitRow.splitRecord.Booking_Classification_ID__c;
            System.debug('bcId: ' + bcId);
            if(bcIdToBcWrapper.get(bcId) == null) {
                BookingClassificationWrapper bcWrapper = new BookingClassificationWrapper();
                bcWrapper.bookingClassification = splitRow.splitRecord.Booking_Classification_ID__r;
                bcIdToBcWrapper.put(bcId,bcWrapper);
            }
            BookingClassificationWrapper bcWrapper = bcIdToBcWrapper.get(bcId);
            splitRow.revenueTypes = getSelectOptions(bcWrapper.bookingClassification);
            splitRow.splitRecord.Team_Member__c = rowIdToMemberId.get(splitRow.rowId);
            bcWrapper.splitRows.add(splitRow);
        }
        setSplitRows(this.bcIdToBcWrapper);
        if(trySave) {
            System.debug('preparing to save records...');
            this.errorMessage = validateUserUniqueness(this.splitRows);
            if(String.isBlank(this.errorMessage)) {
                System.debug('no issues found, moving forward with save operation');
                List<Custom_Opportunity_Split__c> recordsToDelete = new List<Custom_Opportunity_Split__c>();
                List<Custom_Opportunity_Split__c> recordsToUpsert = new List<Custom_Opportunity_Split__c>();
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
                            System.debug('splitRecord.lastmodifieddate: ' + splitRow.splitRecord.lastmodifieddate);                        
                        }
                        splitRow.splitRecord.index__c = splitRow.index;
                        System.debug('splitRow.amount******: ' + splitRow.amount);
                        System.debug('splitRecord.Amount__c******: ' + splitRow.splitRecord.Amount__c);
                        splitRow.splitRecord.Split_Percent__c = (splitRow.amount / splitRow.splitRecord.Amount__c) * 100;
                        splitRow.splitRecord.Split_Percent__c = splitRow.splitRecord.Split_Percent__c.setScale(6);
                        System.debug('splitRecord.Split_Percent__c******: ' + splitRow.splitRecord.Split_Percent__c);
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
    }

    @RemoteAction
    public static String checkSaveSuccess(String opportunityIdString, Map<Integer,Decimal> expectedIndexToAmount) {
        Id opportunityId = Id.valueOf(opportunityIdString);
        String queryString = getQueryString(opportunityId);
        System.debug('expectedIndexToAmount: ' + expectedIndexToAmount);
        List<Custom_Opportunity_Split__c> splitRecords = Database.query(queryString);
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

    public static String validateSplitRecords(List<Custom_Opportunity_Split__c> splitRecords, Map<Integer,Decimal> expectedIndexToAmount) {
        Map<Integer,Decimal> actualIndexToAmount = new Map<Integer,Decimal>();
        Map<String,Total> bcComboToTotal = new Map<String,Total>();
        Map<String,String> splitTypeToBcFieldName = getSplitTypeMap();
        Map<Id,Booking_Classification__c> bcIdToBc = new Map<Id,Booking_Classification__c>();
        String errorMessage;
        for(Custom_Opportunity_Split__c splitRecord : splitRecords) {
            System.debug('======================');
            System.debug('index: ' + splitRecord.index__c);
            System.debug('splitRecord.Id: ' + splitRecord.Id);
            System.debug('splitRecord.splitAmount__c: ' + splitRecord.splitAmount__c);
            actualIndexToAmount.put((Integer)splitRecord.index__c,splitRecord.splitAmount__c);
            Booking_Classification__c bcRecord = splitRecord.Booking_Classification_ID__r;
            String splitType = splitRecord.Booking_Classification__c;
            String bcCombo = String.valueOf(bcRecord.Id);
            bcCombo += '-' + splitRecord.Booking_Classification__c;  
            if(bcComboToTotal.get(bcCombo) == null) {
                bcComboToTotal.put(bcCombo,new Total());
            }
            Total bcTotal = bcComboToTotal.get(bcCombo);
            System.debug('percent: ' + splitRecord.Split_Percent__c);
            System.debug('Amount__c: ' + splitRecord.Amount__c);
            Decimal multipliedAmount = (splitRecord.Split_Percent__c * splitRecord.Amount__c) / 100;
            System.debug('multiplied amount: ' + multipliedAmount);
            bcTotal.amount += (expectedIndexToAmount != null) ? splitRecord.splitAmount__c : multipliedAmount ;
            bcTotal.percent += splitRecord.Split_Percent__c;
            bcComboToTotal.put(bcCombo,bcTotal);
            bcIdToBc.put(bcRecord.Id,bcRecord);
        }
        System.debug('actualIndexToAmount: ' + actualIndexToAmount);
        if(expectedIndexToAmount != null && actualIndexToAmount.keySet() != expectedIndexToAmount.keySet()){
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
        else {
            for(String bcCombo : bcComboToTotal.keySet()) {
                String bcIdStr = bcCombo.split('-')[0];
                String splitType = bcCombo.split('-')[1];
                Id bcId = Id.valueOf(bcIdStr);
                Booking_Classification__c bcRecord = bcIdToBc.get(bcId);
                Decimal recordAmount = (Decimal)bcRecord.get(splitTypeToBcFieldName.get(splitType));
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
                if(Math.abs(summedPercentage - 100) > .001) {
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