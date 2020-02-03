public class QuoteReconfigureClass{
    public Boolean showInfo{get;set;}
    public Boolean showNextInfo{get;set;}
    
    public QuoteReconfigureClass(){
        showInfo = false;
        showNextInfo = false;
    }
    public void reconfigureQuote(){
        List<Quote_Reconfigure__c> ccList = new List<Quote_Reconfigure__c>();
        List<Quote_Reconfigure__c> ccListUpdate = new List<Quote_Reconfigure__c>();
        String query = 'SELECT Name,Processed__c,strDateQuoteStart__c,strEndQuoteStart__c FROM Quote_Reconfigure__c WHERE Processed__c=False AND Batch__c = \''+Label.BatchName+'\''+' LIMIT '+Label.QueryLimit;
        ccList = Database.Query(query);
        if(ccList.size()==0)
        {
            showInfo = true;
            showNextInfo = false;
        }
        else{
            showInfo = false;
            For(Quote_Reconfigure__c cc : ccList){
                CloneQuoteWithContractGroups b = new CloneQuoteWithContractGroups(cc.strDateQuoteStart__c,cc.strEndQuoteStart__c, cc.Name);
                ID batchprocessid=Database.executeBatch(b,1);
                cc.Processed__c = True;
                ccListUpdate.add(cc);
            }
            if(ccListUpdate.size()>0)
                update ccListUpdate ;   
            showNextInfo = true;
        }
    }
}