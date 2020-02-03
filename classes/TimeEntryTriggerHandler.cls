/* ===============================
AUTHOR     :     Mohsin Siddiqui    
CREATED DATE   : 21 MAY 2019
PURPOSE     :    Time Entry Trigger Handler Code
TEST CLASS :     TimeEntryTriggerHandlerTest
SPECIAL NOTES:     
============================= 
*/
public class TimeEntryTriggerHandler 
{
    public static void onAfterInsert(Map<Id,WorkIt2__Time_Entry__c> newMap)
    {
        //Map<Id,WorkIt2__Time_Entry__c> selectedTimeEntries = new 
        List<Id> mobileCardIds = new List<Id>();
        List<Id> mobileCardIds2 = new List<Id>();
        List<Id> casesIds = new List<Id>();
        List<Id> bundleCardIds = new List<Id>();
        for(WorkIt2__Time_Entry__c timeEntry : newMap.values())
        {
            if(timeEntry.MobileApp_Id__c != NULL)
            {
                mobileCardIds.add((Id)timeEntry.MobileApp_Id__c);
            }
            if(timeEntry.Case_Id__c != NULL)
            {
                casesIds.add((Id)timeEntry.Case_Id__c);
            }
            if(String.isNotBlank(timeEntry.BundleCard_Id__c))
            {
                bundleCardIds.add((Id)timeEntry.BundleCard_Id__c);
            }
        }
        
        List<Mobile_Card__c> mcTobeUpdated = new List<Mobile_Card__c>();
        if(!mobileCardIds.isEmpty())
        {
            for(Mobile_Card__c mc: [select id,Time_Spent_On_Mobile_Card__c,OwnerId,(select id,WorkIt2__Time_In_Seconds__c,OwnerId from Timings__r) from Mobile_Card__c where Id IN :mobileCardIds])
            {
                Decimal totalSeconds = 0;
                for(WorkIt2__Timing__c timingObject : mc.Timings__r)
                {
                    if(timingObject.OwnerId == mc.OwnerId)
                      totalSeconds += timingObject.WorkIt2__Time_In_Seconds__c;
                }
                mc.Time_Spent_On_Mobile_Card__c = totalSeconds;
                mcTobeUpdated.add(mc);
            }
        }
        List<Mobile_Card__c> mcTobeUpdated2 = new List<Mobile_Card__c>();
        Map<Id,Decimal> mapOfMobileAppAndTotalSeconds = new Map<Id,Decimal>();
        if(!casesIds.isEmpty())
        {
            for(Case caseInstance : [select id,Mobile_App__c from Case where Id IN :casesIds AND Mobile_App__c != NULL])
            {
                if(caseInstance.Mobile_App__c != NULL)
                  mobileCardIds2.add(caseInstance.Mobile_App__c);
            }
            
            if(!mobileCardIds2.isEmpty())
            {
                for(Case finalCase: [select id,Mobile_App__c,Mobile_App__r.OwnerId,OwnerId,(select id,WorkIt2__Time_In_Seconds__c,OwnerId from WorkIt2__Timings__r) from Case where Mobile_App__c IN :mobileCardIds2])
                {
                    Decimal totalSeconds = 0;
                    for(WorkIt2__Timing__c timingObject : finalCase.WorkIt2__Timings__r)
                    {
                        if(timingObject.OwnerId == finalCase.OwnerId && finalCase.OwnerId == finalCase.Mobile_App__r.OwnerId)
                          totalSeconds += timingObject.WorkIt2__Time_In_Seconds__c;
                    }
                    if(mapOfMobileAppAndTotalSeconds.containsKey(finalCase.Mobile_App__c))
                    {
                        Decimal updatedSeconds = mapOfMobileAppAndTotalSeconds.get(finalCase.Mobile_App__c);
                        updatedSeconds += totalSeconds;
                        mapOfMobileAppAndTotalSeconds.put(finalCase.Mobile_App__c,updatedSeconds);
                    }
                    else
                    {
                        mapOfMobileAppAndTotalSeconds.put(finalCase.Mobile_App__c,totalSeconds);
                    }
                }
            }
            
            if(!mapOfMobileAppAndTotalSeconds.isEmpty())
            {
                for(Id mobileAppId : mapOfMobileAppAndTotalSeconds.keySet())
                {
                    Mobile_Card__c mobileCardInstance = new Mobile_Card__c(Id = mobileAppId);
                    mobileCardInstance.Time_Spend_On_Related_Cases__c = mapOfMobileAppAndTotalSeconds.get(mobileAppId);
                    mcTobeUpdated2.add(mobileCardInstance);
                }
            }
        }
        
        Map<Id,Decimal> mapOfBundleCardsVsTotalSeconds = new Map<Id,Decimal>();
        Map<Id,Bundle_Card__c> mapOfBundleCards = new Map<Id,Bundle_Card__c>();
        Set<Id> setOfBCI = new Set<Id>();
        if(!bundleCardIds.isEmpty())
        {
            for(Bundle_Card__c bundleCard : [select Id,Total_Time_Spent__c,(select id from Bundle_Card_Items__r),(select id,WorkIt2__Time_In_Seconds__c from Timings__r) from Bundle_Card__c where Id IN :bundleCardIds])
            {
                Decimal totalSeconds = 0;
                for(WorkIt2__Timing__c timingObject : bundleCard.Timings__r)
                {
                    totalSeconds += timingObject.WorkIt2__Time_In_Seconds__c;
                }
                
                for(Bundle_Card_Item__c bci : bundleCard.Bundle_Card_Items__r)
                {
                    setOfBCI.add(bci.Id);
                }
                mapOfBundleCardsVsTotalSeconds.put(bundleCard.Id, totalSeconds);
                mapOfBundleCards.put(bundleCard.Id,bundleCard);
            }
        }
        if(!setOfBCI.isEmpty())
        {
            for(Bundle_Card_Item__c bciInstance : [select Id,Bundle_Card__c,(select id,WorkIt2__Time_In_Seconds__c from Timings__r) from Bundle_Card_Item__c where Id IN :setOfBCI])
            {
                Decimal totalSeconds = 0;
                for(WorkIt2__Timing__c timingObject : bciInstance.Timings__r)
                {
                    totalSeconds += timingObject.WorkIt2__Time_In_Seconds__c;
                }
                if(mapOfBundleCardsVsTotalSeconds.containsKey(bciInstance.Bundle_Card__c))
                {
                    Decimal updatedSeconds = mapOfBundleCardsVsTotalSeconds.get(bciInstance.Bundle_Card__c);
                    updatedSeconds += totalSeconds;
                    mapOfBundleCardsVsTotalSeconds.put(bciInstance.Bundle_Card__c,updatedSeconds);
                }
            }
        }
        
        if(!mapOfBundleCardsVsTotalSeconds.isEmpty())
        {
            for(Id bundleCardId : mapOfBundleCardsVsTotalSeconds.keySet())
            {
                mapOfBundleCards.get(bundleCardId).Total_Time_Spent__c = (mapOfBundleCardsVsTotalSeconds.get(bundleCardId))/60;
            }
        }
        
        if(!mapOfBundleCards.isEmpty())
        {
            update mapOfBundleCards.values();
        }
        if(!mcTobeUpdated.isEmpty())
        {
            update mcTobeUpdated;
        }
        
        if(!mcTobeUpdated2.isEmpty())
        {
            update mcTobeUpdated2;
        }
    }
}