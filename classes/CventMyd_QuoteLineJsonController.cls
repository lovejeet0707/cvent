public class CventMyd_QuoteLineJsonController {

	public SBQQ__QuoteLine__c quoteLine {get;set;}

	public CventMyd_QuoteLineJsonController (ApexPages.StandardController standardController) {

		Id quoteLineId;
	
        if(ApexPages.currentPage().getParameters().get('quoteLineId') != null) {

            quoteLineId = ApexPages.currentPage().getParameters().get('quoteLineId');

            this.quoteLine = [SELECT Id,jsonString__c FROM SBQQ__QuoteLine__c WHERE Id =: quoteLineId];

        }

        else {

            this.quoteLine = (SBQQ__QuoteLine__c)standardController.getRecord();

            this.quoteLine = [SELECT Id,jsonString__c FROM SBQQ__QuoteLine__c WHERE Id =: quoteLine.Id];

            quoteLineId = quoteLine.Id;

        }
		
	}
	
}