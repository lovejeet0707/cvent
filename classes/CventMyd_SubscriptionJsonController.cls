public class CventMyd_SubscriptionJsonController {

	public SBQQ__Subscription__c subscription {get;set;}

	public CventMyd_SubscriptionJsonController (ApexPages.StandardController standardController) {

		Id subscriptionId;
	
        if(ApexPages.currentPage().getParameters().get('subscriptionId') != null) {

            subscriptionId = ApexPages.currentPage().getParameters().get('subscriptionId');

            this.subscription = [SELECT Id,jsonString__c FROM SBQQ__Subscription__c WHERE Id =: subscriptionId];

        }

        else {

            this.subscription = (SBQQ__Subscription__c)standardController.getRecord();

            this.subscription = [SELECT Id,jsonString__c FROM SBQQ__Subscription__c WHERE Id =: subscription.Id];

            subscriptionId = subscription.Id;

        }
		
	}
	
}