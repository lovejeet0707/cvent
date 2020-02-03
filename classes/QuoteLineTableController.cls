public class QuoteLineTableController {

	public List<SBQQ__QuoteLine__c> quoteLines {get;set;}

    public List<QuoteDocumentGenerationSettings__mdt> fieldSettingsRecords {get;set;}

    public List<QuoteDocumentGenerationSettings__mdt> headerSettingsRecords {get;set;}

    public Map<String,String> columnNameToFieldApiNameMap {get;set;}

    public Boolean isWithMatrixProducts {get;set;}

    public String colorString {get;set;}

    public List<String> columnNames {get;set;}

    public QuoteLineTableController() {

        List<QuoteDocumentGenerationSettings__mdt> settingsTemp = [SELECT Id,

            includedProductCodes__c,columnNames__c,columnFieldApiNames__c,type__c,sectionTitle__c,sectionDescriptionText__c

            FROM QuoteDocumentGenerationSettings__mdt

            WHERE type__c = 'Line Table Columns - Proposal' OR type__c = 'Quote Line Table Header'

        ]; 

        this.fieldSettingsRecords = new List<QuoteDocumentGenerationSettings__mdt>();

        this.headerSettingsRecords = new List<QuoteDocumentGenerationSettings__mdt>();

        for(QuoteDocumentGenerationSettings__mdt record : settingsTemp) {

            if(record.type__c == 'Line Table Columns - Proposal') {fieldSettingsRecords.add(record);}

            if(record.type__c == 'Quote Line Table Header') {headerSettingsRecords.add(record);}

        }

    }

    public class Column {

        public Integer index {get;set;}

        public String displayName {get;set;}

        public Column(Integer index, String displayName) {

            this.index = index;

            this.displayName = displayName;

        }

    }

    public class Row {

        public List<Cell> cells {get;set;}

        public Integer rowIndex {get;set;}

        public Row() {this.cells = new List<Cell>();}

    }	

    public class Cell {

        public String fontWeight {get;set;}

        public String textValue {get;set;}

        public Integer integerValue {get;set;}

        public Decimal decimalValue {get;set;}
        public Boolean quantityOfOne { get; set; }

        public Cell(String textValue, Integer integerValue, Decimal decimalValue) {

            this.textValue = textValue;

            this.integerValue = integerValue;

            this.decimalValue = decimalValue;

        }

    }

    public String getTitle() {

        return QuoteDocumentGenerationHelper.getMatchingListOfStrings(this.headerSettingsRecords,getProductCodeSet(this.quoteLines),'sectionTitle__c')[0];

    }

    public String getDescriptionText() {

        return QuoteDocumentGenerationHelper.getMatchingListOfStrings(this.headerSettingsRecords,getProductCodeSet(this.quoteLines),'sectionDescriptionText__c')[0];

    }

    public String getCurrencySign() {

        if(this.quoteLines.size() > 0) {

            return quoteLines[0].SBQQ__Quote__r.CurrencyIsoCode + ' ';

        }

        else {

            return '';

        }

    }

    public List<Column> getColumns() {

        if(this.quoteLines.size() > 0) {

            this.colorString = 'rgb(' + String.valueOf(quoteLines[0].SBQQ__Quote__r.Dynamic_Quote_Template_Color__c) + ')';

        }

        else {this.colorString = 'rgb(0, 160, 221)';}

        List<Column> columns = new List<Column>();

        Boolean hideUnitPriceColumn = false;

        if(this.quoteLines.size() > 0) {hideUnitPriceColumn = this.quoteLines[0].SBQQ__Quote__r.Hide_Unit_Prices_on_Contract__c;}
        
        this.columnNames = QuoteDocumentGenerationHelper.getMatchingListOfStrings(this.fieldSettingsRecords,getProductCodeSet(this.quoteLines),'columnNames__c');

        this.columnNameToFieldApiNameMap = new Map<String,String>();

        List<String> quoteLineFieldApiNames =  QuoteDocumentGenerationHelper.getMatchingListOfStrings(this.fieldSettingsRecords,getProductCodeSet(this.quoteLines),'columnFieldApiNames__c');

        Integer columnIndex = 0;

        for(Integer i = 0; i < columnNames.size(); i++) {

            String columnName = columnNames[i];

            String fieldApiName = quoteLineFieldApiNames[i];

            Column column = new Column(columnIndex,columnName);

            if(columnName == 'Unit Rate') {

                if(!hideUnitPriceColumn) {

                    this.columnNameToFieldApiNameMap.put(columnName,fieldApiName);

                    columns.add(column);

                }

                else {columnIndex = columnIndex - 1;}

            }

            else {

                this.columnNameToFieldApiNameMap.put(columnName,fieldApiName);

                columns.add(column);

            }

            columnIndex = columnIndex + 1;

        }

        return columns;

    }

    public List<Row> getRows() {

    	List<Row> rows = new List<Row>();

		Integer rowIndex = 0;

        Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap();

		for(SBQQ__QuoteLine__c ql : this.quoteLines) {

			List<String> quoteLineFieldApiNames =  QuoteDocumentGenerationHelper.getMatchingListOfStrings(this.fieldSettingsRecords,getProductCodeSet(this.quoteLines),'columnFieldApiNames__c');

			Row row = new Row();

			row.rowIndex = rowIndex;

            for(String columnName : this.columnNames) {

                String quoteLineFieldApiName = this.columnNameToFieldApiNameMap.get(columnName);

                if(quoteLineFieldApiName != null) {

                    Cell cell;

                    Schema.DisplayType fieldType = objectFieldMap.get(quoteLineFieldApiName).getDescribe().getType();
                    
                    if(String.valueOf(fieldType) == 'DOUBLE') {

                        cell = new Cell(null,Integer.valueOf(ql.get(quoteLineFieldApiName)),null);
                        cell.quantityOfOne = ql.SBQQ__Product__r.Quantity_of_One__c;
                    }

                    else if(String.valueOf(fieldType) == 'CURRENCY') {

                        cell = new Cell(null,null,((Decimal)ql.get(quoteLineFieldApiName)).setScale(2));
                        cell.quantityOfOne = ql.SBQQ__Product__r.Quantity_of_One__c;
                        if(quoteLineFieldApiName == 'SBQQ__NetPrice__c' && cell.quantityOfOne)
                        {
                            cell.decimalValue = ((Decimal)ql.get('SBQQ__NetTotal__c')).setScale(2);
                        }

                    }

                    else {

                        cell = new Cell(String.valueOf(ql.get(quoteLineFieldApiName)),null,null);
                        cell.quantityOfOne = ql.SBQQ__Product__r.Quantity_of_One__c;
                        if(cell.textValue.contains('&')) {

                            cell.textValue = cell.textValue.replace('&','+');

                        }

                    }  

                    if(columnName == 'Price') {cell.fontWeight = 'bold';}

                    else {cell.fontWeight = 'normal';}                                  
                    //cell.decimalValue = ql.SBQQ__NetPrice__c;  2,161.34  unit rate
                    Row.cells.add(cell);

                }                

            }

			rows.add(row);

			rowIndex = rowIndex + 1;

		}	  

		return rows;  	

    }

    public static Set<String> getProductCodeSet(List<SBQQ__QuoteLine__c> quoteLines) {

        Set<String> quoteLineProductCodes = new Set<String>();

        for(SBQQ__QuoteLine__c ql : quoteLines) {quoteLineProductCodes.add(ql.SBQQ__ProductCode__c);}

        return quoteLineProductCodes;

    }   

}