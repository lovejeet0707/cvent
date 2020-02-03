trigger OnboardingTrg on Onboarding__c (after update,after insert) 
{
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        set<id> onboardingIDs = new set<id>();
        OnboardingTrgHelperClass  handler = new OnboardingTrgHelperClass();
        
        if(Trigger.isUpdate && Trigger.isAfter){
            handler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap); 
            
            //Added by Mohsin on 07th Dec 2018
            List<Onboarding__c> onboardings = new List<Onboarding__c>();
            for(Onboarding__c cs : Trigger.new)
            {
                if(cs.Oversold__c == true && cs.Oversold__c!=Trigger.oldMap.get(cs.id).Oversold__c)
                    onboardings.add(cs);
            }
            if(CheckRecursive.runThirtyEight() && onboardings.size() > 0 && !onboardings.isEmpty())
            {
                ChatterPostNotification.chatterPost(onboardings,'Onboarding','Oversold__c','Account_id__c',false,'Onboarding');
            } 
        }  
    }
    if(Trigger.isAfter && Trigger.isInsert)
    {
        if(CheckRecursive.runFortyThree())
        {
            ChatterPostNotification.chatterPost(Trigger.new,'Onboarding ','Oversold__c','Account_id__c',false,'Onboarding');
        }  
    }
}