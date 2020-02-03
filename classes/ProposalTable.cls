public class ProposalTable {

    public ProposalProduct proposalProduct {get;set;}

    public String tableName {get;set;}

    public List<String> columnNames {get;set;}

    public List<Row> rows {get;set;}

    public String sectionTitle {get;set;}

    public String sectionDescriptionText {get;set;}

    public String firstColumnName {get;set;} 

    public Boolean isCrowdCompass {Get;set;}

    public Boolean showRackRate {get;set;}

    public Boolean staticPagesShown {get;set;}

    public class ProposalException extends Exception {}   

    public class Row {

        public List<Cell> cells {get;set;}

        public Integer rowIndex {get;set;}

        public Row() {this.cells = new List<Cell>();}

    }

    public class Cell {

        public Integer volume {get;set;}

        public Decimal rackRate {get;set;}

        public Decimal price {get;set;}

        public Boolean showRackRate {get;set;}

        public Cell(Integer volume, Decimal rackRate, Decimal price) {

            this.volume = volume;

            this.rackRate = rackRate;

            this.price = price;

            this.showRackRate = (this.price != this.rackRate);

        }

    }

    public ProposalTable(ProposalProduct proposalProduct) {

        Set<String> productCodeSet = new Set<String>{proposalProduct.product.ProductCode};

        this.isCrowdCompass = QuoteDocumentGenerationHelper.onlyHasCrowdCompass(productCodeSet);

        this.showRackRate = !this.isCrowdCompass;

        this.proposalProduct = proposalProduct;

        getTableSettings();

        Set<Integer> termLengthSet = new Set<Integer>();

        Set<Integer> volumeSet = new Set<Integer>();

        this.tableName = proposalProduct.product.Name.subStringBefore('Fee');

        //this.tableName = this.tableName + ' - Options';

        Map<String,ProposalProduct.ProposalPrice> matrixMap = new Map<String,ProposalProduct.ProposalPrice>();

        for(ProposalProduct.ProposalPrice pp : proposalProduct.proposalPrices) {

            termLengthSet.add(pp.termLength);

            volumeSet.add(pp.volume);

            matrixMap.put(pp.matrixId,pp);

        }

        this.columnNames = new List<String>();

        this.rows = new List<Row>();

        List<Integer> termLengths = new List<Integer>(termLengthSet);

        List<Integer> volumes = new List<Integer>(volumeSet);

        termLengths.sort();

        volumes.sort();

        this.columnNames.add(this.firstColumnName);

        for(Integer tl : termLengths) {

            if(tl == 1) {this.columnNames.add(String.valueOf(tl) + ' year');}

            else {this.columnNames.add(String.valueOf(tl) + ' years');}

        }

        Integer rowIndex = 0;

        for(Integer v : volumes) {

            Row row = new Row();

            row.rowIndex = rowIndex;

            row.cells.add(new Cell(v,null,null));

            for(Integer tl : termLengths) {

                String matrixId = String.valueOf(tl) + 'x' + String.valueOf(v);

                ProposalProduct.ProposalPrice proposalPrice = matrixMap.get(matrixId);  

                //if(proposalPrice.rackRate != proposalPrice.price) {

                    if(proposalPrice == null) {

                        String exceptionMessage = 'There is a mismatch in your quote line groups. For the ';

                        exceptionMessage = exceptionMessage + proposalProduct.product.Name + ' product, you have a volume of ' + v + ', but no matching volume for term length of ' + tl + '. Please navigate back to the quote line editor for this quote to fix this.';

                        throw new ProposalException(exceptionMessage);

                    }

                    row.cells.add(new Cell(null,proposalPrice.rackRate,proposalPrice.price));

                //}

                //else {

                    //row.cells.add(new Cell(null,null,'$' + String.valueOf(proposalPrice.price)));

                //}

            }
                
            this.rows.add(row);

            rowIndex = rowIndex + 1;

        }

    }

    public void getTableSettings() {

        List<QuoteDocumentGenerationSettings__mdt> settingsTmp = [SELECT Id,

            includedProductCodes__c,sectionDescriptionText__c,sectionTitle__c,type__c,columnNames__c

            FROM QuoteDocumentGenerationSettings__mdt

            WHERE type__c = 'Matrix Table Header' OR type__c = 'Matrix Table Column'

        ];

        List<QuoteDocumentGenerationSettings__mdt> matrixTableHeaders = new List<QuoteDocumentGenerationSettings__mdt>();

        List<QuoteDocumentGenerationSettings__mdt> matrixTableColumns = new List<QuoteDocumentGenerationSettings__mdt>();

        for(QuoteDocumentGenerationSettings__mdt s : settingsTmp) {

            if(s.type__c == 'Matrix Table Header') {matrixTableHeaders.add(s);}

            else if(s.type__c == 'Matrix Table Column') {matrixTableColumns.add(s);}

        }

        Set<String> productCodeSet = new Set<String>();

        productCodeSet.add(this.proposalProduct.product.ProductCode);

        this.sectionTitle = QuoteDocumentGenerationHelper.getMatchingListOfStrings(matrixTableHeaders,productCodeSet,'sectionTitle__c')[0];

        this.sectionDescriptionText = QuoteDocumentGenerationHelper.getMatchingListOfStrings(matrixTableHeaders,productCodeSet,'sectionDescriptionText__c')[0]; 

        this.firstColumnName = QuoteDocumentGenerationHelper.getMatchingListOfStrings(matrixTableColumns,productCodeSet,'columnNames__c')[0]; 

    }

}