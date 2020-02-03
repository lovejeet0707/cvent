/**
* MYDBlendedTierDiscountHandler
*
* Called from:
* DiscountScheduleTrigger & DiscountTierTrigger
* 
*  SBQQ__DiscountTier__c and SBQQ__DiscountSchedule__c
*
* Date - Who - What
* 5.30.17 - Ed Harrold - created
* 5.30.17 - Ed Harrold - add handling for DiscountTier trigger
* 6.12.17 - Karl Andrzejewski - refactored to allow for different tier sizes and random tiers ordering.
*/
public without sharing class MYDBlendedTierDiscountHandler {
    
    /*
	*   updates Blended_Discount_Percent__c for Lists of DiscountTiers associated with DiscountSchedules
	*   based on the DiscountSchedule ID's in the List SBQQ__DiscountSchedule__c
	*/
    public static void updateDiscountTiers(List<SBQQ__DiscountSchedule__c> discountScheduleList) {
        List<SBQQ__DiscountTier__c> dtListToUpdate = new List<SBQQ__DiscountTier__c>();
        Integer numSchedules = discountScheduleList.size();
        System.debug('MYDBlendedTierDiscountHandler updateDiscountTiers() discountScheduleList.size():'+numSchedules);
        List<SBQQ__DiscountTier__c> discountTiers = new List<SBQQ__DiscountTier__c>();
        if (numSchedules>0){
            for (SBQQ__DiscountSchedule__c ds : discountScheduleList){
                if (ds.SBQQ__Type__c == 'Slab' && ds.SBQQ__DiscountUnit__c == 'Percent'){
                    Id discountScheduleID = ds.Id;
                    discountTiers = [select Id, SBQQ__Schedule__c, SBQQ__Schedule__r.Name, Blended_Discount_Percent__c, SBQQ__DiscountAmount__c, SBQQ__Discount__c, SBQQ__LowerBound__c, SBQQ__UpperBound__c, SBQQ__Number__c, SBQQ__Price__c from SBQQ__DiscountTier__c where SBQQ__Schedule__c =:discountScheduleID order by SBQQ__Number__c];
                    Map<Decimal, SBQQ__DiscountTier__c> discountTiersMap = new Map<Decimal, SBQQ__DiscountTier__c>();
                    for(SBQQ__DiscountTier__c tier : discountTiers) {
                        discountTiersMap.put(tier.SBQQ__Number__c, tier);
                    }
                    System.debug('DiscountTiersMap: ' + discountTiersMap);
                    Integer tiers = discountTiers.size();
                    Decimal discount = 0;
                    Decimal blended = 0;
                    Decimal lowerBound = 0;
                    if (tiers > 0){
                        for(Integer i=1; i<=discountTiers.size(); i++){
                            if (i == 1) {
                                if(discountTiersMap.get(i).Blended_Discount_Percent__c != discountTiersMap.get(i).SBQQ__Discount__c) {
                                	discountTiersMap.get(i).Blended_Discount_Percent__c = discountTiersMap.get(i).SBQQ__Discount__c;
                                    dtListToUpdate.add(discountTiersMap.get(i));
                                }
                                discount = discountTiersMap.get(i).SBQQ__Discount__c;
                                blended = (discountTiersMap.get(i).Blended_Discount_Percent__c==null ? 0.0 : discountTiersMap.get(i).Blended_Discount_Percent__c);
                                lowerBound = discountTiersMap.get(i).SBQQ__LowerBound__c;
                            } else {
                                blended = (blended * (lowerBound - 1) + discount * (discountTiersMap.get(i).SBQQ__LowerBound__c - lowerBound)) / (discountTiersMap.get(i).SBQQ__LowerBound__c - 1);
                                if(discountTiersMap.get(i).Blended_Discount_Percent__c != blended) {
                                    discountTiersMap.get(i).Blended_Discount_Percent__c = blended;
                                    dtListToUpdate.add(discountTiersMap.get(i));
                                }
                                discount = discountTiersMap.get(i).SBQQ__Discount__c;
                                lowerBound = discountTiersMap.get(i).SBQQ__LowerBound__c;
                            }
                        }
                    }
                }
            }
            System.debug('Size of DT to Update list: ' + dtListToUpdate.size());
            if(dtListToUpdate.size()>0){
                update dtListToUpdate;
            }
        }
    }


/*
* Called from DiscountTierTrigger
* Create list of DiscountSchedules and call updateDiscountTiers()
*/
    public static void updateDiscountTiers(List<SBQQ__DiscountTier__c> discountTierList) {
        System.debug('MYDBlendedTierDiscountHandler updateDiscountTiers() updateDiscountTiers: '+discountTierList);
        List<SBQQ__DiscountSchedule__c> discountScheduleList = new List<SBQQ__DiscountSchedule__c>();
        Map <Id,Integer> dsMap = new Map <Id,Integer>();
        if(discountTierList != null) {
            for(SBQQ__DiscountTier__c dt : discountTierList){
                System.debug('MYDBlendedTierDiscountHandler updateDiscountTiers() dt: '+dt);
                dsMap.put(dt.SBQQ__Schedule__c, 0);
            }
            System.debug('MYDBlendedTierDiscountHandler updateDiscountTiers() dsMap: '+dsMap);
            discountScheduleList = new List<SBQQ__DiscountSchedule__c>([select Id from SBQQ__DiscountSchedule__c where Id in :dsMap.keySet() and SBQQ__Type__c = 'Slab' and SBQQ__UserDefined__c = false]);
        }

        if(discountScheduleList.size() > 0) {
            update(discountScheduleList);
        }
        
    }
    
    public static void forceCalc(){
        List<SBQQ__DiscountSchedule__c> dsList = new List<SBQQ__DiscountSchedule__c>();
        dsList = [select Id, SBQQ__Type__c, SBQQ__DiscountUnit__c from SBQQ__DiscountSchedule__c where SBQQ__Type__c='Slab' and SBQQ__UserDefined__c = false];
        updateDiscountTiers(dsList);
    }
    
}