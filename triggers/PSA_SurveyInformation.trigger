trigger PSA_SurveyInformation on Survey_Q__c (before insert, before update, after insert, after update, before delete, after delete) {
    if(PSA_Utils.IsDataLoadMode && !test.IsRunningTest()) return;
    if(trigger.isBefore) {
        if(!trigger.isDelete) {
            PSA_surveyInfoTriggerHandler.answerToNumber(trigger.new);
        }
    }
    
    if(trigger.isAfter) {
        if(!trigger.isDelete) {
            PSA_surveyInfoTriggerHandler.sumTotalScore(trigger.newMap);
        }
        if(trigger.isDelete) {
            PSA_surveyInfoTriggerHandler.sumTotalScore(trigger.oldMap);
        }
        
    }

}