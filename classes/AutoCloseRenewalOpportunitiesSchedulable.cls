global without sharing class AutoCloseRenewalOpportunitiesSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        AutoCloseRenewalOpportunities b = new AutoCloseRenewalOpportunities();
        database.executeBatch(b, 1);
    }
}