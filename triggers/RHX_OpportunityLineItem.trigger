trigger RHX_OpportunityLineItem on OpportunityLineItem
    (after delete, after insert, after undelete, after update, before delete) {
    
      /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
      if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
          return;
      } 
        
     Type rollClass = System.Type.forName('rh2', 'ParentUtil');
     if(rollClass != null) {
        rh2.ParentUtil pu = (rh2.ParentUtil) rollClass.newInstance();
        if (trigger.isAfter) {
            pu.performTriggerRollups(trigger.oldMap, trigger.newMap, new String[]{'OpportunityLineItem'}, null);
        }
    }
}