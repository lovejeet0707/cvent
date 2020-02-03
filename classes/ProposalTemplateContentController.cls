public class ProposalTemplateContentController {

	public String title {get;set;}

	public List<ProposalTable> proposalTables {get;set;}

	public List<SBQQ__QuoteLine__c> additionalQuoteLines {get;set;}

	public Boolean onlyCrowdCompass {get;set;}

	public Boolean hasMatrixedProducts {get;set;}

	public String colorString {get;set;}

	public ProposalTemplateContentController() {

		Id quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');

		SBQQ__Quote__c quote = [SELECT SBQQ__Account__r.Name,showMarketingContent__c,Dynamic_Quote_Template_Color__c FROM SBQQ__Quote__c WHERE Id =: quoteId LIMIT 1];

		List<SBQQ__QuoteLine__c> quoteLines = [SELECT

			Id,SBQQ__Product__c,SBQQ__Optional__c,Send_Rollup_To_EBS__c,SBQQ__Product__r.doMatrixComparison__c,

			Rollup_Quantity__c,totalRollupPrice__c,Contract_Term_Years__c,SBQQ__Quantity__c,SBQQ__NetTotal__c,

			SBQQ__ProductName__c,SBQQ__ProductCode__c,SBQQ__RequiredBy__c,SBQQ__Group__r.groupType__c,

			Name,SBQQ__Number__c,SBQQ__Quote__r.Dynamic_Quote_Template_Color__c,SBQQ__ListPrice__c,Rollup_Price__c,

			SBQQ__NetPrice__c,SBQQ__Quote__r.Hide_Unit_Prices_on_Contract__c,Rack_Rate__c,SBQQ__RequiredBy__r.SBQQ__ProductCode__c,

			SBQQ__Quote__r.CurrencyIsoCode, SBQQ__Product__r.Quantity_of_One__c,SBQQ__Quote__r.Quantity_of_One__c

			FROM SBQQ__QuoteLine__c

			WHERE SBQQ__Quote__c =: quoteId

				AND (SBQQ__Product__r.doMatrixComparison__c = TRUE OR showOnGeneratedContract__c = TRUE)

			ORDER BY SBQQ__Number__c ASC

		];

        this.colorString = 'rgb(' + quote.Dynamic_Quote_Template_Color__c + ')';

		this.title = 'Cvent Proposal for ' + quote.SBQQ__Account__r.Name;

		this.title = this.title.replace('&','+');

		Map<Id,List<SBQQ__QuoteLine__c>> productIdToQuoteLines = new Map<Id,List<SBQQ__QuoteLine__c>>();

		Map<Id,Product2> productMap = new Map<Id,Product2>();

		this.additionalQuoteLines = new List<SBQQ__QuoteLine__c>();

		Set<String> additionalProductCodes = new Set<String>();

		for(SBQQ__QuoteLine__c ql : quoteLines) {

			Boolean isInComparableGroup = (ql.SBQQ__Group__r.groupType__c == 'Proposal Comparison Group');

			Boolean isMatrixable = ql.SBQQ__Product__r.doMatrixComparison__c;

			if(isInComparableGroup && isMatrixable) {

				Product2 product = new Product2(

					Id = ql.SBQQ__Product__c,

					ProductCode = ql.SBQQ__ProductCode__c,

					Name = ql.SBQQ__ProductName__c,

					Send_Rollup_To_EBS__c = ql.Send_Rollup_To_EBS__c

				);

				productMap.put(ql.SBQQ__Product__c,product);

				if(productIdToQuoteLines.get(ql.SBQQ__Product__c) == null) {

					productIdToQuoteLines.put(ql.SBQQ__Product__c,new List<SBQQ__QuoteLine__c>());

				}

				productIdToQuoteLines.get(ql.SBQQ__Product__c).add(ql);

			}

			else if(!ql.SBQQ__Optional__c) {

				this.additionalQuoteLines.add(ql);

				additionalProductCodes.add(ql.SBQQ__ProductCode__c);

			}

		}

		this.proposalTables = new List<ProposalTable>();

		this.hasMatrixedProducts = false;

		for(Id id : productIdToQuoteLines.keySet()) {

			Product2 product = productMap.get(id);

			ProposalProduct proposalProduct = new ProposalProduct(product,productIdToQuoteLines.get(id));

			ProposalTable proposalTable = new ProposalTable(proposalProduct);

			proposalTable.staticPagesShown = quote.showMarketingContent__c;

			this.proposalTables.add(proposalTable);

		}

		if(proposalTables.size() > 0) {

			if(proposalTables[0].isCrowdCompass) {

				ProposalTable proposalTable = proposalTables.remove(0);

				proposalTables.add(proposalTable);

			}

			this.hasMatrixedProducts = true;

		}

		this.onlyCrowdCompass = QuoteDocumentGenerationHelper.onlyHasCrowdCompass(additionalProductCodes);

	}

}