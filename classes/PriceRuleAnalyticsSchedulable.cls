global class PriceRuleAnalyticsSchedulable implements Schedulable {
   /* ADD J.DECASTRO 03.27.2019 
    * Scheduled to be run every 7th Day of the month at 3am EST
    */
	global void execute(SchedulableContext sc) {
		PriceRuleAnalyticsBatch priceRuleAnalytics = new PriceRuleAnalyticsBatch();
		database.executebatch(priceRuleAnalytics);
	}
}