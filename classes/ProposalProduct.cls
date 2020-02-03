public class ProposalProduct {

	public Product2 product {get;set;}

	public List<SBQQ__QuoteLine__c> quoteLines {get;set;}

	public List<ProposalPrice> proposalPrices {get;set;}

	public String currencySign {get;set;} 

    public class ProposalPrice {

        public Integer termLength {get;set;}

        public Integer volume {get;set;}

        public String matrixId {get;set;}

        public Decimal price {get;set;}

        public Decimal rackRate {get;set;}

    }	

	public ProposalProduct(Product2 product, List<SBQQ__QuoteLine__c> quoteLines) {

		this.product = product;

		this.proposalPrices = new List<ProposalPrice>();

		this.quoteLines = quoteLines;

		for(SBQQ__QuoteLine__c ql : quoteLines) {

			if(this.currencySign == null) {this.currencySign = ql.SBQQ__Quote__r.CurrencyIsoCode + ' ';}			

			ProposalPrice proposalPrice = new ProposalPrice();

			proposalPrice.termLength = Integer.valueOf(ql.Contract_Term_Years__c);

			if(ql.Send_Rollup_To_EBS__c) {

				proposalPrice.volume = (Integer)ql.Rollup_Quantity__c;

				proposalPrice.price = (ql.Rollup_Price__c).setScale(2);

			}

			else {

				proposalPrice.volume = (Integer)ql.SBQQ__Quantity__c;

				proposalPrice.price = (ql.SBQQ__NetPrice__c).setScale(2);

			}

			proposalPrice.rackRate = (ql.Rack_Rate__c).setScale(2);

			proposalPrice.matrixId = String.valueOf(proposalPrice.termLength + 'x' + proposalPrice.volume);

			this.proposalPrices.add(proposalPrice);

		}

	}

}