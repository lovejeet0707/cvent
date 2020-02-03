global class revenueFieldsBatchClass implements Database.Batchable<sobject>{
    //global string query;
    /*global autoDeleteActvitiesBatch(){
        query='select ActivityId,ParentId from EmailMessage where ParentId!=null and CreatedDate>=:System.today() and ActivityId!=null';
    }*/
    
    //One date before for filtering Opportunities
    global Date oppDateFilter = System.today()-1;
    
    global Date q = System.today()-1;
    global string query='select Id,Account_Status__c,Total_Historic_Spent__c from Account ';
    global string oppQuery='select Id,AccountId from Opportunity Where LastModifiedDate >: oppDateFilter ';
    
    //Constructor
    global revenueFieldsBatchClass(){
        if(Label.RevenueBatchDate!='null'){
            oppDateFilter = Date.ValueOf(Label.RevenueBatchDate);
        }
    }
    
    
    global Database.querylocator start(Database.BatchableContext BC){
        system.debug('@@@@@oppQuery results '+database.getquerylocator(oppQuery));
        return database.getquerylocator(oppQuery);
    }
    
    
    
    global void execute(Database.BatchableContext BC, List<sobject> scope){
        Map<ID,Account> accIds = new Map<ID,Account>();
        Map<ID,Account> toupdateAcct = new Map<ID,Account>(); 
        List<Account> toupdateAccts = new List<Account>();
        List<Account> toupdateAccts1 = new List<Account>();
        List<Account> toupdateAccts2 = new List<Account>();
        /*for(sobject s : scope){
            Account a = (Account)s;
            accIds.put(a.Id,a);
        }*/
        
        //Account Id From Opportunities
        Set<ID> accIdsOpp = new Set<ID>();
        for(sobject s : scope){
            Opportunity o = (Opportunity)s;
            if(o.AccountId!=null){
                accIdsOpp.add(o.AccountId);
            }
        }
        
        system.debug('@@@@accIds : '+accIds);
        if(accIdsOpp.size()>0){
            /*AggregateResult[] groupedResults = [SELECT  AccountID,SUM(New_Contract_Total__c) sumTotal FROM Opportunity where AccountId in: accIds.keyset() and StageName = 'Closed Won' GROUP BY AccountId];
            for (AggregateResult ar : groupedResults)  {
                System.debug('Account Name' + ar.get('AccountID'));
                System.debug('Average amount' + ar.get('sumTotal'));
                toupdateAccts.add(new Account(Id = (ID)ar.get('AccountID'),Total_Historic_Spent__c = (Decimal)ar.get('sumTotal')));
            }
            AggregateResult[] groupedResults1 = [SELECT  AccountID,SUM(New_Contract_Total__c) sumTotal1 FROM Opportunity where AccountId in: accIds.keyset() and (NOT StageName Like '%Closed%') GROUP BY AccountId];
            for (AggregateResult ar : groupedResults1)  {
                System.debug('Account Name' + ar.get('AccountID'));
                System.debug('Average amount' + ar.get('sumTotal1'));
                toupdateAccts1.add(new Account(Id = (ID)ar.get('AccountID'),Expected_Revenue__c = (Decimal)ar.get('sumTotal1')));
            }*/
            AggregateResult[] groupedResults2 = [SELECT  AccountID,SUM(Net_Amount_opp_USD__c) sumTotal2 FROM Opportunity where AccountId in: accIdsOpp and StageName = 'Closed Won'  and CloseDate = LAST_N_DAYS:365  
                                                 GROUP BY AccountId];
                                                 
            for (AggregateResult ar : groupedResults2)  {
                System.debug('Account Name' + ar.get('AccountID'));
                System.debug('Average amount' + ar.get('sumTotal2'));
                toupdateAccts2.add(new Account(Id = (ID)ar.get('AccountID'),Last_12_month_spent__c= (Decimal)ar.get('sumTotal2')));
            }
        }
        /*for(Account a : toupdateAccts){
            toupdateAcct.put(a.Id,new Account(ID = a.Id,Total_Historic_Spent__c=a.Total_Historic_Spent__c,Apex_bypass__c = true));
        }
        for(Account a : toupdateAccts1){
            if(toupdateAcct.containskey(a.Id)){
                Account instOfAcc =  toupdateAcct.get(a.Id);
                instOfAcc.Expected_Revenue__c = a.Expected_Revenue__c;
                toupdateAcct.put(a.Id,instOfAcc);
            }else{
                toupdateAcct.put(a.Id,new Account(ID = a.Id,Expected_Revenue__c=a.Expected_Revenue__c,Apex_bypass__c = true));
            }
        }*/
        System.debug('toupdateAccts2**** ' + toupdateAccts2);
        for(Account a : toupdateAccts2){
            if(toupdateAcct.containskey(a.Id)){
                Account instOfAcc =  toupdateAcct.get(a.Id);
                instOfAcc.Last_12_month_spent__c = a.Last_12_month_spent__c;
                toupdateAcct.put(a.Id,instOfAcc);
            }else{
                toupdateAcct.put(a.Id,new Account(ID = a.Id,Last_12_month_spent__c=a.Last_12_month_spent__c/*,Apex_bypass__c = true*/));  //Commented By Mohsin on 21st June 2019 - FP Activity
            }
        }
        system.debug('toupdateAcct : '+toupdateAcct);
        if(toupdateAcct.size()>0){
            update toupdateAcct.values();
        }
       // if(toupdateAccts2.size()>0){
        //    update toupdateAccts2;
       // }
    }
    global void finish(Database.BatchableContext BC){
        ID idJob = BC.getJobId();
        AsyncApexJob apexjobUP =  [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                                    FROM AsyncApexJob WHERE Id = :idJob];
         Messaging.SingleEmailMessage emailNotify = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {apexjobUP.CreatedBy.Email};
        emailNotify.setToAddresses(toAddresses);
        emailNotify.setSubject('Revenue Fields Batch - Completed with Errors');
        emailNotify.setPlainTextBody(
            'Your Revenue Fields Batch request completed, however the job reported ' + apexjobUP.NumberOfErrors + 
            ' errors. If your Revenue Fields Batch still fails, contact your system administrator.');
            
        if (apexjobUP.Status == 'Failed'){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailNotify });
        }
    }
}