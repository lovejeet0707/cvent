// ===============================
// AUTHOR           : Shanu Aggarwal    
// CREATED DATE     : 19 July 2016
// PURPOSE          : Batch To Send CSV file for setup and audit changes 
// TEST CLASS       :   
// SPECIAL NOTES    :
// ===============================

global class SetupAuditTrailReportBatch implements Database.Batchable<sObject> {


    global Database.QueryLocator start(Database.BatchableContext BC) {

        string filters = ' and (';
        //Getting filters from custom setting 
        Map<String, Setup_Audit_Filters__c> filtersMap = new Map<String, Setup_Audit_Filters__c>();
        filtersMap.putAll(Setup_Audit_Filters__c.getAll());
        
        String query = 'Select Id,CreatedDate,Action,CreatedById,CreatedBy.Name,DelegateUser,Display,Section FROM SetupAuditTrail Where CreatedDate ' 
        //Adding Date Range/Filter to Retrieve Records
        + filtersMap.get('Date Filter').Filter_Value__c ;
        
        //Removing first filter which is date we have already added it into SOQL query
        filtersMap.remove('Date Filter');
        
        for(Setup_Audit_Filters__c sFilter : filtersMap.Values() ){
            
            filters = filters + ' Action like \'%' + sFilter.Filter_Value__c +'%\' OR ';
            
        }
        
        //Removing Last OR
        filters = filters.removeEnd('OR ');
        
        //Adding All Filters
        if(!Test.isRunningTest()){
            query = query + filters + ' )';
        }
        
        System.Debug('****** filters **** ' + filters);
        System.Debug('****** query **** ' + query);

        
        return Database.getQueryLocator(query);
    
    }

    
    global void execute(Database.BatchableContext BC, List<SetupAuditTrail> scope) {
        
        //Insert Logs to Custom Object
        List<Setup_Logs__c> logList = new List<Setup_Logs__c>();
        
        
        System.debug('***size**** ' + scope.size());
        System.debug('***scope**** ' + scope);
        
        for( SetupAuditTrail audit : scope ){
            
            Setup_Logs__c log = new Setup_Logs__c();
            log.Log_Id__c        =  audit.Id;
            log.Action__c        =  audit.Action;
            log.CreatedById       =  audit.CreatedById;
            log.CreatedDate      =  audit.CreatedDate;
            log.Display__c       =  audit.Display;
            log.Section__c       =  audit.Section;
          
            logList.add(log);
            
        }
        
        if(logList!=null && logList.size()>0){
            insert logList;
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
    } 

}