trigger BundleCardTrigger on Bundle_Card__c (after update,after insert) 
{
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        List<Bundle_Card__c> bundleCards = new List<Bundle_Card__c>();
        for(Bundle_Card__c cs : Trigger.new)
            {
                if(cs.Oversold__c == true && cs.Oversold__c!=Trigger.oldMap.get(cs.id).Oversold__c)
                    bundleCards.add(cs);
            }
        if(CheckRecursive.runThirtyNine() && bundleCards.size() > 0 && !bundleCards.isEmpty())
        {
            ChatterPostNotification.chatterPost(bundleCards,'BundleCard','Oversold__c','Account__c',false,'Bundle Card');
        } 
    }
    if(Trigger.isAfter && Trigger.isInsert)
    {
        if(CheckRecursive.runFortyFour())
        {
            ChatterPostNotification.chatterPost(Trigger.new,'BundleCard','Oversold__c','Account__c',false,'Bundle Card');
        } 
    }
}