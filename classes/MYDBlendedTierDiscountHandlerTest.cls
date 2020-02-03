/**
 * Created by Ed Harrold on 6/1/2017
 *
 * 2017-06-02 : Ed Harrold : update to get >90% coverage
 * 
*/

@IsTest
private class MYDBlendedTierDiscountHandlerTest {
    static testMethod void testBehavior() {
        //==========<Start Test>==========
        Test.startTest();
        //create discount schedule and tier lists
        List<SBQQ__DiscountSchedule__c> dsList = new List<SBQQ__DiscountSchedule__c>();
        List<SBQQ__DiscountTier__c> dtList = new List<SBQQ__DiscountTier__c>();

        // upsert a schedule
        dsList.add(new SBQQ__DiscountSchedule__c(Name='SCHEDULE-1',SBQQ__Type__c='Slab', SBQQ__DiscountUnit__c='Percent'));
        upsert dsList;

        // verify it was inserted
        System.assertNotEquals(dsList[0].Id,null);

        // add three tiers
        dtList.add(new SBQQ__DiscountTier__c(Name='TIER-1',SBQQ__Number__c=1, SBQQ__Schedule__c=dsList[0].Id,SBQQ__Discount__c=10,SBQQ__LowerBound__c=0,SBQQ__UpperBound__c=201,Blended_Discount_Percent__c=0));
        dtList.add(new SBQQ__DiscountTier__c(Name='TIER-2',SBQQ__Number__c=2, SBQQ__Schedule__c=dsList[0].Id,SBQQ__Discount__c=20,SBQQ__LowerBound__c=201,SBQQ__UpperBound__c=301,Blended_Discount_Percent__c=0));
        dtList.add(new SBQQ__DiscountTier__c(Name='TIER-3',SBQQ__Number__c=3, SBQQ__Schedule__c=dsList[0].Id,SBQQ__Discount__c=30,SBQQ__LowerBound__c=301,SBQQ__UpperBound__c=401,Blended_Discount_Percent__c=0));
        upsert dtList;

        // verify a tier was inserted
        System.assertNotEquals(dtList[0].Id,null);

        // force an update trigger on the discount schedule
        dsList[0].Name = 'SCHEDULE-1a';
        update dsList;

        // query the tiers and then verify the blended calcs are correct
        List<SBQQ__DiscountTier__c> dtList2 = [select Id, Name, SBQQ__Discount__c, SBQQ__LowerBound__c, SBQQ__UpperBound__c, Blended_Discount_Percent__c from SBQQ__DiscountTier__c where Id=:dsList[0].Id];
        for (Integer i=0; i<dtList2.size(); i++){
            System.debug('>> Blended_Discount_Percent__c: '+dtList2.get(i).Blended_Discount_Percent__c);
            if (i==0){
                // blended rate on first tier is the same as the discount
                System.assertEquals(dtList2[i].Blended_Discount_Percent__c,dtList2[i].SBQQ__Discount__c);
            }else{
                // blended rate on subsequent tiers is the previous tier (discount+blended)/2
                System.assertEquals(dtList2[i].Blended_Discount_Percent__c,(dtList2[i-1].SBQQ__Discount__c+dtList2[i-1].Blended_Discount_Percent__c)/2);
            }

        }

        //call static methods unrelated directly to triggers
        //Integer count = MYDBlendedTierDiscountHandler.countSchedulesWithSlab();
        MYDBlendedTierDiscountHandler.forceCalc();
        //called by forceCalc(): List<SBQQ__DiscountSchedule__c> newSchedules = MYDBlendedTierDiscountHandler.getDiscountScheduleIDWithSlab();
        //MYDBlendedTierDiscountHandler.updateDiscountTiers(dsList[0].Id);
        //called by updateDiscountTiers() List<SBQQ__DiscountTier__c> getDiscountTiersForSchedule(Id discountScheduleID)

        //==========<End Test>==========
        Test.stopTest();

    }
}