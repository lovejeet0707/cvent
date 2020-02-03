global with sharing class ExecuteCloneQuoteBatch{
   WebService static string cloneQuoteAndGroups(String strDateQuoteStart,String strEndQuoteStart, String strQuoteId){
        CloneQuoteWithContractGroups b = new CloneQuoteWithContractGroups(strDateQuoteStart,strEndQuoteStart, strQuoteId);
        ID batchprocessid=Database.executeBatch(b); 
        return batchprocessid;        
   }
}