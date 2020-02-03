public class PayGoSummaryTriggerHelper{
    public static void beforeDelete(List<PayGo_Summary__c> oldValues,Map<Id,PayGo_Summary__c> oldMapValues){
        /******Preventing Summary Records from deletion.****/
        Set<String> authorizedUserSet = new Set<String>();
        //Accessing custom setting.....................
        For(PayGoSummary_Records_Delete_Prevention__c PG : PayGoSummary_Records_Delete_Prevention__c.getall().values()){
            authorizedUserSet.add(PG.Name);
        }
        For(PayGo_Summary__c PSRec : oldValues)
        {   
            /******TICCM-200 - Preventing PayGoSummary from deletion.****/
            if((authorizedUserSet.size()>0 && !authorizedUserSet.contains(UserInfo.getUserId())) || authorizedUserSet.size()==0)
            {
                PSRec.addError('No user should be able to delete PayGo Summary');
            }
            /****************Ends Here***********************/
        }
    }
}