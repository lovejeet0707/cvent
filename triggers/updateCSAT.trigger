trigger updateCSAT on Survey_Q__c (after insert) {
    
    Set<ID> caseIds = new Set<ID>();
    Set<ID> mobileAppIds = new Set<ID>();
    Set<ID> onboardingIds = new Set<ID>();  
    Set<Id> ebsbIds = new Set<Id>();    //Added By Mohsin on 31st oct 2018  
    List<Case> toUpdateCase = new List<Case>();
    List<Mobile_Card__c> toUpdateMobApp = new List<Mobile_Card__c>();
    List<Onboarding__c> toUpdateOnboarding = new List<Onboarding__c>();
    List<EB_SB_Builder__c> toUpdateEBSB = new List<EB_SB_Builder__c>(); //Added By Mohsin on 31st oct 2018
    
    for(Survey_Q__c s : Trigger.new){
        
        if(s.Case__c!=null){
            caseIds.add(s.Case__c);
        }
        else if(s.MobileApp__c!=null){
            mobileAppIds.add(s.MobileApp__c);
        }
        else if(s.Onboarding__c !=null){
            onboardingIds.add(s.Onboarding__c);
        }
        else if(s.EBSB__c != NULL)
        {
            ebsbIds.add(s.EBSB__c);
        }
    }
    
    
    //Update Cases
    if(caseIds.size()>0){
        for(Id cId : caseIds ){
            Case c = new Case(Id = cId);
            c.CSAT_Filled__c = true;
            c.Survey_Received_Date__c = system.today();  // added by Udita for P-005116
            toUpdateCase.add(c);
        }
    }
    //Update Mobile Apps
    if(mobileAppIds.size()>0){
        for(Id mId : mobileAppIds){
            Mobile_Card__c m = new Mobile_Card__c(Id = mId);
            m.Survey_Recieved__c = system.today();
            toUpdateMobApp.add(m);
        }
    }
    //Update Onboarding : Added by Udita for project  P-004030  Closed Loop Survey Email notification - Onboarding Object
    if(onboardingIds.size() > 0){
      for(id oId : onboardingIds){
        Onboarding__c onb = new Onboarding__c(id= oId);
        onb.Survey_Received_Date__c = system.today();
        toUpdateOnboarding.add(onb);
      }
    }
    
    /*
     * Added by Mohsin 
     * Date: 31th OCt 2018
     * Description: Update EBSB
     */
    if(ebsbIds.size() > 0){
      for(Id eId : ebsbIds){
        EB_SB_Builder__c ebsb = new EB_SB_Builder__c(Id = eId);
        ebsb.Survey_Received_Date__c  = System.Today();
        toUpdateEBSB.add(ebsb);
      }
    }
    
    /**
    **obsolete code - No need of SOQL because we only need to update the field. 
    for(Case c : [Select CSAT_Filled__c from Case where id in : caseIds]){
        c.CSAT_Filled__c = true;
        toUpdateCase.add(c);
    }*/
    
    if(toUpdateCase.size()>0){
        update toUpdateCase;
    }
    else if(toUpdateMobApp.size()>0){
        update toUpdateMobApp;
    }
    if(toUpdateOnboarding.size() > 0){
      update toUpdateOnboarding;
    }
    if(toUpdateEBSB.size() > 0){
      update toUpdateEBSB;
    }
}