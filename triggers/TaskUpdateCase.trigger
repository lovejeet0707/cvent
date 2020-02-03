//Created By Rishi Ojha
    //Trigger is created to update # of Delivered reports field on the Case level for Rfp reports
    //Utility class for this is CaseActivityCount
    //===========================================================================================
    trigger TaskUpdateCase on Task (after delete, after insert, after undelete, after update) {
       
        /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
        if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
                return;
        } 
        
        
        
    
        Set<ID> CaseIds = new Set<ID>();
            String prefix =  CaseActivityCount.casePrefix;
    
            if (Trigger.new != null) {
            for (Task t : Trigger.new) {
                if (t.WhatId != null && String.valueOf(t.whatId).startsWith(prefix) ) {
                    CaseIds.add(t.whatId);
                }
            }
        }
    
          if (Trigger.old != null) {
            for (Task t : Trigger.old) {
                if (t.WhatId != null && String.valueOf(t.whatId).startsWith(prefix) ) {
                    CaseIds.add(t.whatId);
                }
            }
        }
    
        if (CaseIds.size() > 0)
            CaseActivityCount.updateCaseCounts(CaseIds);
    
    }