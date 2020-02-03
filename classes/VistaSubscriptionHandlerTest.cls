@isTest
private class VistaSubscriptionHandlerTest {
    public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();

    @isTest static void subscriptionTriggerTest() {
        System.debug(LoggingLevel.INFO, 'VistaSubscriptionHandlerTest.subscriptionTriggerTest');

        List<Product2> productList = new List<Product2>();
        productList.addAll(util.initProductSet(1, 'Hardware', 'Fixed Price'));

        Test.startTest();
                SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
                sub.SBQQ__Product__c = productList[0].Id;
                    sub.SBQQ__Quantity__c = 1;
                sub.SBQQ__NetPrice__c = 1.00;
                sub.Annual_Recurring_Revenue__c = 1.00;
                sub.SBQQ__SubscriptionStartDate__c = System.today();
        insert sub;

        System.assertEquals(1, sub.SBQQ__Quantity__c);

        Test.stopTest();
    }

    @isTest
    static void createNewSubscriptionTest() {
        VistaSubscriptionHandlerDatabaseMockImpl mockImpl = new VistaSubscriptionHandlerDatabaseMockImpl();
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        Map<String, SObject> sbObjectMap = VistaAssetHelperUtil.createSBQQStack(false);

        Product2 product = (Product2) sbObjectMap.get(VistaAssetHelperUtil.PRODUCT);
        SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) sbObjectMap.get(VistaAssetHelperUtil.QUOTE_LINE);
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c();
        subscription.SBQQ__Quantity__c = 5;
        subscription.SBQQ__Product__r = product;
        subscription.SBQQ__QuoteLine__c = quoteLine.Id;
        subscription.SBQQ__QuoteLine__r = quoteLine;

        subscription.Id = VistaAssetHelperUtil.getFakeId(subscription.getSObjectType());

        mockImpl.returnQuerySubscriptionsBySubscriptionList.add(subscription);
        subscriptions.add(subscription);
        VistaSubscriptionHandler handler = new VistaSubscriptionHandler(subscriptions, mockImpl);

    }

    @isTest
    static void createAmendmentsSubscriptionTest() {
        VistaSubscriptionHandlerDatabaseMockImpl mockImpl = new VistaSubscriptionHandlerDatabaseMockImpl();
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        Map<String, SObject> sbObjectMap = VistaAssetHelperUtil.createSBQQStack(false);

        Product2 product = (Product2) sbObjectMap.get(VistaAssetHelperUtil.PRODUCT);
        SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) sbObjectMap.get(VistaAssetHelperUtil.QUOTE_LINE);
        SBQQ__Subscription__c subscriptionAmended = new SBQQ__Subscription__c();
        subscriptionAmended.Id = VistaAssetHelperUtil.getFakeId(subscriptionAmended.getSObjectType());
        subscriptionAmended.SBQQ__Quantity__c = 5;
        subscriptionAmended.SBQQ__Product__r = product;
        subscriptionAmended.SBQQ__QuoteLine__c = quoteLine.Id;
        subscriptionAmended.SBQQ__QuoteLine__r = quoteLine;

        SBQQ__Subscription__c subscriptionOriginal = new SBQQ__Subscription__c();
        subscriptionOriginal.Id = VistaAssetHelperUtil.getFakeId(subscriptionAmended.getSObjectType());
        subscriptionOriginal.SBQQ__Quantity__c = 5;
        subscriptionOriginal.SBQQ__Product__r = product;

        quoteLine.SBQQ__UpgradedSubscription__c = subscriptionOriginal.Id;
        quoteLine.SBQQ__UpgradedSubscription__r = subscriptionOriginal;

        mockImpl.returnQuerySubscriptionsBySubscriptionList.add(subscriptionAmended);
        subscriptions.add(subscriptionAmended);
        VistaSubscriptionHandler handler = new VistaSubscriptionHandler(subscriptions, mockImpl);

    }

    public class VistaSubscriptionHandlerDatabaseMockImpl implements VistaSubscriptionHandler.VistaSubscriptionHandlerDatabaseInterface {
        public List<SBQQ__Subscription__c> returnQuerySubscriptionsBySubscriptionList = new List<SBQQ__Subscription__c>();
        public List<SBQQ__Subscription__c> returnQuerySubscriptionsByQuerySetAmendedSet = new List<SBQQ__Subscription__c>();
        public List<Customer_Asset__c> returnQueryCustomerAssetByQuerySet = new List<Customer_Asset__c>();
        public List<Customer_Asset__c> valueUpsertCustomerAssets = new List<Customer_Asset__c>();

        public List<SBQQ__Subscription__c> querySubscriptionsBySubscriptionList(List<SBQQ__Subscription__c> subscriptionList) {
            return returnQuerySubscriptionsBySubscriptionList;
        }

        public List<SBQQ__Subscription__c> querySubscriptionsByQuerySetAmendedSet(Set<Id> querySet, Set<Id> amendedSet) {
            return returnQuerySubscriptionsByQuerySetAmendedSet;
        }

        public List<Customer_Asset__c> queryCustomerAssetByQuerySet(Set<Id> querySet) {
            return returnQueryCustomerAssetByQuerySet;
        }

        public void upsertCustomerAssets(List<Customer_Asset__c> customerAssets) {
            valueUpsertCustomerAssets.addAll(customerAssets);
        }
    }
}