global with sharing class ExecuteCreateFincanceShallFromOppBatch{
   WebService static String createFincanceShallFromOpp(String oppId,String oppStage){
        Set<String> setOppStages = new Set<String>{
            
            'Closed -- Never Qualified',
            'Cancelled',
            'Opted-Out',
            'Closed Reassigned',
            'Closed Lost - Opted Out/Cancelled'
        };
        String recordId = '';
        if(!setOppStages.contains(oppStage)){       
            Opportunity opp = [SELECT Id, SBQQ__PrimaryQuote__c, 
                                (SELECT Opportunity__c
                                   FROM Contract_Reviews__r 
                                  WHERE Contract_Review_Ok__c = 'Yes')
                                   FROM Opportunity WHERE Id = :oppId                                                           
                                   LIMIT 1];   

            if(opp.Contract_Reviews__r != null && opp.SBQQ__PrimaryQuote__c != null){   
                if(opp.Contract_Reviews__r.size() > 0){
                    CreateFincanceShallFromOppSingleRec b = new CreateFincanceShallFromOppSingleRec(oppId);   
                    recordId = b.createFinanceShellRecord(); 
                    System.debug('recordId-->' + recordId);
                } 
            } 
        }
        else {
             Opportunity opp = [SELECT Id, SBQQ__PrimaryQuote__c
                                    FROM Opportunity WHERE Id = :oppId
                                    AND  StageName  IN (
                                                        'Closed -- Never Qualified',
                                                        'Cancelled',
                                                        'Opted-Out',
                                                        'Closed Reassigned',
                                                        'Closed Lost - Opted Out/Cancelled') 
                                   LIMIT 1]; 
            if(opp != null && opp.SBQQ__PrimaryQuote__c != null){
                CreateFincanceShallFromOppSingleRec b = new CreateFincanceShallFromOppSingleRec(oppId); 
                recordId = b.createFinanceShellRecord();                
                System.debug('recordId-->' + recordId);
            }           
        }       
        return recordId;
    }   
}