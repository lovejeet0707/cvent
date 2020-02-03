/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 15th Sept 2015
Description : Score roll-up.
*/
public class qualityCheckRespTrgHelperCls{
    public static map<String,Decimal> mapQuesScore = new map<String,Decimal>();
    public static List<CSScoring__c> lstQCR = new List<CSScoring__c>();
    static{
        lstQCR = CSScoring__c.getall().values();
        for(CSScoring__c isntOfQCR : lstQCR ){
             mapQuesScore.put(isntOfQCR.Question__c+isntOfQCR.Response__c+isntOfQCR.Question_Type__c,isntOfQCR.Score__c);
        }
    }
    public void OnBeforeInsert(List<Quality_Check_Response__c> newValues){    
        for(Quality_Check_Response__c instOfQCR : newValues){
            if(mapQuesScore.containsKey(instOfQCR.Question__c+instOfQCR.Quality_Check_Filled_Response__c+instOfQCR.Question_Type__c)){
                instOfQCR.Score__c = mapQuesScore.get(instOfQCR.Question__c+instOfQCR.Quality_Check_Filled_Response__c+instOfQCR.Question_Type__c);
            }
        }
    }
    public void OnAfterInsert(Map<Id,Quality_Check_Response__c> newMapValues){ 
        Set<Id> setIdQCDone = new Set<Id>();
        for(Quality_Check_Response__c instOfQCR : newMapValues.values()){
            setIdQCDone.add(instOfQCR.Quality_Check_Done__c);
        }
        List<Quality_Check_Done__c> lstQCDone = [SELECT ID,(SELECT ID,Score__c,Criticality__c,Quality_Check_Filled_Response__c,Max_Score__c FROM Quality_Check_Response__r) FROM Quality_Check_Done__c WHERE Id=:setIdQCDone];
        
        List<Quality_Check_Done__c> lstQCDoneUpd = new List<Quality_Check_Done__c>(); 
        for(Quality_Check_Done__c instQCDone : lstQCDone){
            Decimal maxScore = 0;
            Integer criticalCount = 0;
            Integer naCount = 0;
            Decimal score =0; 
            //totalCount++; 
            for(Quality_Check_Response__c instQCRes : instQCDone.Quality_Check_Response__r){
                if(instQCRes.Criticality__c == 'Critical' && instQCRes.Score__c == 0){
                    criticalCount++;
                }
                if(instQCRes.Quality_Check_Filled_Response__c != 'NA'){
                    score = score + instQCRes.Score__c;
                    maxScore = maxScore + instQCRes.Max_Score__c;
                }
            }
            //instQCDone.Score__c = score;
            
            instQCDone.Score__c = 0;
            
            if(criticalCount == 0)
            instQCDone.Score__c = score/maxScore *100;
            
            lstQCDoneUpd.add(instQCDone);
        }
        
        if(lstQCDoneUpd.size()>0)
        update lstQCDoneUpd;
    }
    public void OnBeforeUpdate(Map<Id,Quality_Check_Response__c> oldMapValues,Map<Id,Quality_Check_Response__c> newMapValues){ 
        for(Quality_Check_Response__c instOfQCR : newMapValues.values()){
            if(mapQuesScore.containsKey(instOfQCR.Question__c+instOfQCR.Quality_Check_Filled_Response__c+instOfQCR.Question_Type__c)){
                instOfQCR.Score__c = mapQuesScore.get(instOfQCR.Question__c+instOfQCR.Quality_Check_Filled_Response__c+instOfQCR.Question_Type__c);
            }
        }
    }
    public void OnAfterUpdate(Map<Id,Quality_Check_Response__c> oldMapValues,Map<Id,Quality_Check_Response__c> newMapValues){ 
        Set<Id> setIdQCDone = new Set<Id>();
        for(Quality_Check_Response__c instOfQCR : newMapValues.values()){
            setIdQCDone.add(instOfQCR.Quality_Check_Done__c);
        }
        List<Quality_Check_Done__c> lstQCDone = [SELECT ID,Score__c,(SELECT ID,Score__c,Criticality__c,Quality_Check_Filled_Response__c,Max_Score__c FROM Quality_Check_Response__r) FROM Quality_Check_Done__c WHERE Id=:setIdQCDone];
        
        List<Quality_Check_Done__c> lstQCDoneUpd = new List<Quality_Check_Done__c>(); 
        for(Quality_Check_Done__c instQCDone : lstQCDone){
            Decimal maxScore = 0;
            Integer criticalCount = 0;
            Integer naCount = 0;
            Decimal score =0; 
            //totalCount++; 
            for(Quality_Check_Response__c instQCRes : instQCDone.Quality_Check_Response__r){
                system.debug('instQCRes.Score__c++'+instQCRes.Criticality__c);
                system.debug('instQCRes.Score__c++'+instQCRes.Score__c);
                if(instQCRes.Criticality__c == 'Critical' && instQCRes.Score__c == 0){
                    criticalCount++;
                }
                if(instQCRes.Quality_Check_Filled_Response__c != 'NA'){
                    score = score + instQCRes.Score__c;
                    maxScore = maxScore + instQCRes.Max_Score__c;
                }
            }
            //instQCDone.Score__c = score;
            
            instQCDone.Score__c = 0;
            system.debug('instQCDone.Score__c+++'+instQCDone.Score__c);
            system.debug('criticalCount+++'+criticalCount);
            
            if(criticalCount == 0)
            instQCDone.Score__c = score/maxScore * 100;
            
            lstQCDoneUpd.add(instQCDone);
        }
        
        if(lstQCDoneUpd.size()>0)
        update lstQCDoneUpd;
    }
    public void OnBeforeDelete(List<Quality_Check_Response__c> oldValues,Map<Id,Quality_Check_Response__c> oldMapValues){
    }
    public void OnAfterDelete(List<Quality_Check_Response__c> oldValues,Map<Id,Quality_Check_Response__c> oldMapValues){
    }
    public void OnUndelete(List<Quality_Check_Response__c> newValues){     
    }
}