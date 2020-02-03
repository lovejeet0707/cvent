public class QuoteDocumentGenerationHelper {

	public SBQQ__Quote__c quote {get;set;}

	public String mailingAddressLine1 {get;set;}

	public String mailingAddressLine2 {get;set;}

	public Boolean useEventManagementCoverPage {get;set;}

	public Boolean useContractRenewalCoverPage {get;set;}

	public QuoteDocumentGenerationHelper() {

		Id quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');

		this.quote = [SELECT showProposalCoverPage__c,CrowdCompass_Logo_Conditional_Print__c,showCrowdCompassStaticPages__c,showEventManagementStaticPages__c,

			showMarketingContent__c,SBQQ__Account__r.Name,SBQQ__Opportunity2__r.Owner.Name,SBQQ__Opportunity2__r.Owner.Email,

			SBQQ__Opportunity2__r.Contact_Associated__r.Name,
			SBQQ__Account__r.BillingStreet, SBQQ__Account__r.BillingCity, SBQQ__Account__r.BillingState, 
			SBQQ__Account__r.BillingPostalCode,SBQQ__Account__r.BillingCountry, 
			SBQQ__Opportunity2__r.Contact_Associated__r.Phone,

			SBQQ__Opportunity2__r.Contact_Associated__r.Email,SBQQ__Opportunity2__r.Owner.Phone,onlyOnsiteSolutionsProducts__c,

			onlyInquisiumProducts__c,showContractRenewalStaticPages__c,onlyCsnPlannerProducts__c,SBQQ__Opportunity2__r.RecordType.DeveloperName

			FROM SBQQ__Quote__c

			WHERE Id =: quoteId LIMIT 1

		];

		quote.SBQQ__Account__r.Name = quote.SBQQ__Account__r.Name.replace('&','+');

		if(this.quote.SBQQ__Account__r.BillingStreet != null) {

			this.mailingAddressLine1 = this.quote.SBQQ__Account__r.BillingStreet;

			this.mailingAddressLine2 = this.quote.SBQQ__Account__r.BillingStreet + ', ' + this.quote.SBQQ__Account__r.BillingState + ' ' + this.quote.SBQQ__Account__r.BillingPostalCode;

		}

		System.debug(quote.CrowdCompass_Logo_Conditional_Print__c != 'true');

		System.debug(!quote.onlyOnsiteSolutionsProducts__c);

		System.debug(!quote.onlyInquisiumProducts__c);

		System.debug(quote.showContractRenewalStaticPages__c != 'true');

		if(quote.CrowdCompass_Logo_Conditional_Print__c != 'true'

			&& !quote.onlyOnsiteSolutionsProducts__c

			&& !quote.onlyInquisiumProducts__c

			&& !quote.onlyCsnPlannerProducts__c

			&& quote.SBQQ__Opportunity2__r.RecordType.DeveloperName == 'Renewal'

		) {

			useContractRenewalCoverPage = true;

		}		

		else if(quote.CrowdCompass_Logo_Conditional_Print__c != 'true'

			&& !quote.onlyOnsiteSolutionsProducts__c

			&& !quote.onlyInquisiumProducts__c

			&& !quote.onlyCsnPlannerProducts__c

		) {

			useEventManagementCoverPage = true;

		}		

	}

	public static List<String> getListOfStrings(QuoteDocumentGenerationSettings__mdt settingsRecord, String fieldApiName) {

		String stringToSplit = (String)settingsRecord.get(fieldApiName);

		List<String> stringList = new List<String>();

		Integer i = 0;

		if(stringToSplit != null) {

			while(i < stringToSplit.length()) {
			            
				if(stringToSplit.charAt(i) == 10 || stringToSplit.charAt(i) == 13) {

					stringToSplit = stringToSplit.replace(stringToSplit.subString(i,i+1),';');

					Integer lengthBefore = stringToSplit.length();

					stringToSplit = stringToSplit.replace(';;',';');

					Integer lengthAfter = stringToSplit.length();

					if(lengthAfter < lengthBefore) {i = i - 1;}

				}

				i = i + 1; 

			}

			stringList = stringToSplit.split(';');

		}

		if(stringList.isEmpty()) {stringList.add('');}
		
		return stringList;

	}

    public static List<String> getMatchingListOfStrings(List<QuoteDocumentGenerationSettings__mdt> settingsRecords, Set<String> quoteLineProductCodes, String fieldApiName) {

        List<String> stringList = null;

        Boolean breakLoop = false;

        for(QuoteDocumentGenerationSettings__mdt sr : settingsRecords) {

            Set<String> settingsProductCodes = new Set<String>(getListOfStrings(sr,'includedProductCodes__c'));

            for(String qlpc : quoteLineProductCodes) {

                if(settingsProductCodes.contains('all') || settingsProductCodes.contains(qlpc)) {

                    stringList = getListOfStrings(sr,fieldApiName);

                    if(!settingsProductCodes.contains('all')) {breakLoop = true; break;}

                }

            }

            if(breakLoop) {break;}

        }

        return stringList;  

    } 

    public static Boolean onlyHasCrowdCompass(Set<String> productCodes) {

    	QuoteDocumentGenerationSettings__mdt settingsRecord = [SELECT Id,includedProductCodes__c FROM QuoteDocumentGenerationSettings__mdt WHERE type__c = 'CrowdCompass Product Codes' LIMIT 1];

    	Set<String> crowdCompassProductCodes = new Set<String>(getListOfStrings(settingsRecord,'includedProductCodes__c'));

		Boolean onlyCrowdCompassBundles = null;

		for(String pc : productCodes) {

			if(crowdCompassProductCodes.contains(pc)) {onlyCrowdCompassBundles = true; continue;}

			else {

				onlyCrowdCompassBundles = false;

				break;

			}

		}

		return onlyCrowdCompassBundles;    	

    }

}