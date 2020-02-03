global class CloneQuoteWithContractGroups implements Database.Batchable<sObject> {
    
  
    public String strQuoteStartDate {get;set;}
    public String strQuoteEndDate {get;set;}
    public String strQuoteId {get;set;}
    public Boolean boolpreserveId {get;set;}
    public Boolean boolisDeepClone {get;set;}
    public Boolean boolpreserveReadonlyTimestamps {get;set;}
    public Boolean boolpreserveAutonumber {get;set;}
    public Boolean boolTrueVal {get;set;}
    public String strQuery {get;set;}
    
    public Boolean boolFalseVal {get;set;}
    public Integer intMaxTerms {get;set;}
    public String strGroupName {get;set;}
    public Map<Id,List<SBQQ__QuoteLine__c>> mapIdOldQuote_lstQuoteLines {get;set;}
    public Database.SaveResult[] srList {get;set;}
    public Map<String,SBQQ__QuoteLine__c> mapRequiredBy = new Map<String,SBQQ__QuoteLine__c>();
    public List<String> preCalculationFieldNames {get;set;}
    public List<String> calculatedFieldNames {get;set;}   
    public Set<Id> tempQuotes {get;set;}


    /*
     * Constructor used when the batch is called on the basis of query before which to clone quotes
    **/
    public CloneQuoteWithContractGroups (String strDateQuoteStart,String strDateQuoteEndDate) {
        strQuoteStartDate = strDateQuoteStart;
        strQuoteEndDate = strDateQuoteEndDate;
        strQuoteId = '';
        boolpreserveId = false;
        boolisDeepClone = false;
        boolpreserveReadonlyTimestamps = false;
        boolpreserveAutonumber = false;
        boolTrueVal = true;
        boolFalseVal = false;
        intMaxTerms = 0;
        mapIdOldQuote_lstQuoteLines = new Map<Id,List<SBQQ__QuoteLine__c>>();
        strGroupName = 'Year ';
        preCalculationFieldNames = CloneQuoteWithContractGroups.getListOfStrings([SELECT preCalculationQuoteLineFieldNames__c FROM CventMyd_Settings__mdt WHERE DeveloperName='QcpSettings' LIMIT 1],'preCalculationQuoteLineFieldNames__c');
        calculatedFieldNames = CloneQuoteWithContractGroups.getListOfStrings([SELECT calculatedQuoteLineFieldNames__c FROM CventMyd_Settings__mdt WHERE DeveloperName='QcpSettings' LIMIT 1],'calculatedQuoteLineFieldNames__c');
    }
    
    /*
     * Constructor used when the batch is called from the Clone with Contract Groups button for a specific quote
    **/
    public CloneQuoteWithContractGroups (String strDateQuoteStart,String strDateQuoteEndDate, String strQuoteId) {
        strQuoteStartDate = strDateQuoteStart;
        strQuoteEndDate = strDateQuoteEndDate;
        this.strQuoteId = strQuoteId;
        boolpreserveId = false;
        boolisDeepClone = false;
        boolpreserveReadonlyTimestamps = false;
        boolpreserveAutonumber = false;
        boolTrueVal = true;
        boolFalseVal = false;
        intMaxTerms = 0;
        mapIdOldQuote_lstQuoteLines = new Map<Id,List<SBQQ__QuoteLine__c>>();
        strGroupName = 'Year ';
        preCalculationFieldNames = CloneQuoteWithContractGroups.getListOfStrings([SELECT preCalculationQuoteLineFieldNames__c FROM CventMyd_Settings__mdt WHERE DeveloperName='QcpSettings' LIMIT 1],'preCalculationQuoteLineFieldNames__c');
        calculatedFieldNames = CloneQuoteWithContractGroups.getListOfStrings([SELECT calculatedQuoteLineFieldNames__c FROM CventMyd_Settings__mdt WHERE DeveloperName='QcpSettings' LIMIT 1],'calculatedQuoteLineFieldNames__c');
    }

    public CloneQuoteWithContractGroups(String strQuery){
        strQuoteStartDate = '';
        strQuoteEndDate = '';
        this.strQuoteId = '';
        this.strQuery = strQuery;
        boolpreserveId = false;
        boolisDeepClone = false;
        boolpreserveReadonlyTimestamps = false;
        boolpreserveAutonumber = false;
        boolTrueVal = true;
        boolFalseVal = false;
        intMaxTerms = 0;
        mapIdOldQuote_lstQuoteLines = new Map<Id,List<SBQQ__QuoteLine__c>>();
        strGroupName = 'Year ';       
        preCalculationFieldNames = CloneQuoteWithContractGroups.getListOfStrings([SELECT preCalculationQuoteLineFieldNames__c FROM CventMyd_Settings__mdt WHERE DeveloperName='QcpSettings' LIMIT 1],'preCalculationQuoteLineFieldNames__c');
        calculatedFieldNames = CloneQuoteWithContractGroups.getListOfStrings([SELECT calculatedQuoteLineFieldNames__c FROM CventMyd_Settings__mdt WHERE DeveloperName='QcpSettings' LIMIT 1],'calculatedQuoteLineFieldNames__c');
    }
    


    public CloneQuoteWithContractGroups(Set<Id> lstQuotes){
        strQuoteStartDate = '';
        strQuoteEndDate = '';
        this.strQuoteId = '';
        this.strQuery = strQuery;
        boolpreserveId = false;
        boolisDeepClone = false;
        boolpreserveReadonlyTimestamps = false;
        boolpreserveAutonumber = false;
        boolTrueVal = true;
        boolFalseVal = false;
        intMaxTerms = 0;
        mapIdOldQuote_lstQuoteLines = new Map<Id,List<SBQQ__QuoteLine__c>>();
        strGroupName = 'Year ';
        tempQuotes = lstQuotes;
        preCalculationFieldNames = CloneQuoteWithContractGroups.getListOfStrings([SELECT preCalculationQuoteLineFieldNames__c FROM CventMyd_Settings__mdt WHERE DeveloperName='QcpSettings' LIMIT 1],'preCalculationQuoteLineFieldNames__c');
        calculatedFieldNames = CloneQuoteWithContractGroups.getListOfStrings([SELECT calculatedQuoteLineFieldNames__c FROM CventMyd_Settings__mdt WHERE DeveloperName='QcpSettings' LIMIT 1],'calculatedQuoteLineFieldNames__c');
    }
    
     global Database.QueryLocator start(Database.BatchableContext BC) {
        /*
         * Query quotes with a start date before the specified start date
        **/
        if(tempQuotes!= null && tempQuotes.size() > 0){
            String strQuery = CloneQuoteWithContractGroupsQueryMaker.getOuterQueryForQuoteLines('SBQQ__Quote__c',                                                
                                                ' ID IN :tempQuotes');
                    
            return Database.getQueryLocator(strQuery);
        }
        else if(String.isNotBlank(strQuery) && String.isBlank(strQuoteStartDate) && String.isBlank(strQuoteEndDate) && String.isBlank(strQuoteId)){
            if(strQuery == 'QUERY1'){                
                String strQuery = CloneQuoteWithContractGroupsQueryMaker.getOuterQueryForQuoteLines('SBQQ__Quote__c',                                                
                                                 Label.Data_Migration_MYD_Condtion +
                                                ' AND SBQQ__Primary__c = true' +
                                                ' AND Multiple_Years_Commitment__c = true' +
                                                ' and SBQQ__Opportunity2__r.isClosed = false' +                                              
                                                ' AND Contract_Term_Years__c!= null' +
                                                ' AND Cloned_from_Quote__c = null');
                    System.debug(strQuery);
                return Database.getQueryLocator(strQuery);
            }                           
            else if(strQuery == 'QUERY2'){
                String strQuery = CloneQuoteWithContractGroupsQueryMaker.getOuterQueryForQuoteLines('SBQQ__Quote__c',                                                
                                                Label.Data_Migration_NON_MYD_Condtion + 
                                                ' AND SBQQ__Primary__c = true' +
                                                ' AND Multiple_Years_Commitment__c = false' + 
                                                ' and SBQQ__Opportunity2__r.isClosed = false' +
                                                ' and Contract_Term_Years__c!= null'+
                                                ' AND Cloned_from_Quote__c = null');
                return Database.getQueryLocator(strQuery);
            }
            
            else if(strQuery == 'QUERY3'){                
                String strQuery = CloneQuoteWithContractGroupsQueryMaker.getOuterQueryForQuoteLines('SBQQ__Quote__c',
                                                 Label.Data_Migration_MYD_Condtion +
                                                ' AND SBQQ__Primary__c = true' +
                                                ' AND Multiple_Years_Commitment__c = true' +
                                                ' and SBQQ__Opportunity2__r.isClosed = true' +  
                                                ' AND SBQQ__Opportunity2__r.SBQQ__Contracted__c = false' +
                                                ' AND Cloned_from_Quote__c = null' +
                                                ' AND SBQQ__Opportunity2__r.Contract_Implemented__c = false');
                return Database.getQueryLocator(strQuery);
            }
            
            else if(strQuery == 'QUERY6'){ 
                Date greaterThanEndDate = Date.valueOf(Label.Data_Migration_Contract_GreaterThan_End_Date);
                Date createdDate = Date.valueOf(Label.Data_Migration_Contract_Created_Date);
                Set<Id> quoteIds = new Set<Id>();
                List<Contract> lstContracts = [SELECT Id,
                                                      SBQQ__Quote__c,
                                                      CreatedDate
                                                 FROM Contract
                                                 WHERE Upcoming_Renewal_Type__c = 'MYD Renewal' 
                                                 AND SBQQ__Quote__c !=null
                                                 AND EndDate > :greaterThanEndDate                                                
                                                 AND CreatedDate < :createdDate ];
                for(Contract lstItr : lstContracts){
                    quoteIds.add(lstItr.SBQQ__Quote__c);
                }
                String strQuery = CloneQuoteWithContractGroupsQueryMaker.getOuterQueryForQuoteLines('SBQQ__Quote__c',
                                                 'Id IN :quoteIds'+
                                                ' AND Multiple_Years_Commitment__c = false');
                return Database.getQueryLocator(strQuery);
            }
            else if(strQuery == 'QUERY7'){ 
                Set<Id> setQuoteIds = new Set<Id>();
                List<Clone_Quote_Refernces__c> lstClones = [SELECT Id,
                                                                   New_Quote__c,
                                                                   Old_Quote__c 
                                                              FROM Clone_Quote_Refernces__c
                                                             WHERE New_Quote__c = null 
                                                               AND Multiple_Years_Commitment__c = false];

                for(Clone_Quote_Refernces__c lstItr : lstClones){
                    setQuoteIds.add(lstItr.Old_Quote__c);
                }
                String strQuery = CloneQuoteWithContractGroupsQueryMaker.getOuterQueryForQuoteLines('SBQQ__Quote__c',                                                
                                                ' Contract_Term_Years__c!= null'+
                                                ' AND Cloned_from_Quote__c = null' + 
                                                ' AND Id IN :setQuoteIds');
                return Database.getQueryLocator(strQuery); 
            }         
            else if(strQuery == 'QUERY8'){ 
                Set<Id> setQuoteIds = new Set<Id>();
                List<Clone_Quote_Refernces__c> lstClones = [SELECT Id,
                                                                   New_Quote__c,
                                                                   Old_Quote__c 
                                                              FROM Clone_Quote_Refernces__c
                                                             WHERE New_Quote__c = null 
                                                               AND Multiple_Years_Commitment__c = true];

                for(Clone_Quote_Refernces__c lstItr : lstClones){
                    setQuoteIds.add(lstItr.Old_Quote__c);
                }
                String strQuery = CloneQuoteWithContractGroupsQueryMaker.getOuterQueryForQuoteLines('SBQQ__Quote__c',                                                
                                                ' Contract_Term_Years__c!= null'+
                                                ' AND Cloned_from_Quote__c = null' + 
                                                ' AND Id IN :setQuoteIds');
                return Database.getQueryLocator(strQuery); 
            }
            
            
        }

        else if(String.isNotBlank(strQuoteStartDate) && String.isNotBlank(strQuoteEndDate) && String.isBlank(strQuoteId) ) {
            String strQuery = CloneQuoteWithContractGroupsQueryMaker.getOuterQueryForQuoteLines('SBQQ__Quote__c',                                                
                                                ' SBQQ__StartDate__c > '+ strQuoteStartDate + ' and SBQQ__EndDate__c <= ' +strQuoteEndDate );
            return Database.getQueryLocator(strQuery);
        }
        /*
        //Query the specific quote whose ID is passed to the batch
        */
        else if(String.isBlank(strQuoteStartDate) && String.isNotBlank(strQuoteId)) {
            String strQuery = CloneQuoteWithContractGroupsQueryMaker.getOuterQueryForQuoteLines('SBQQ__Quote__c',
                                                ' Id = \''+ strQuoteId +
                                                '\' limit 1');
            return Database.getQueryLocator(strQuery);
        }
        return null;
    }

    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> scope) {
        if(!scope.isEmpty()) {
            if (SBQQ.TriggerControl.isEnabled()) {
                SBQQ.TriggerControl.disable();
            }
            List<SBQQ__Quote__c> lstNewQuotes = new List<SBQQ__Quote__c>();
            List<SBQQ__Quote__c> lstOldQuotes = new List<SBQQ__Quote__c>();
            Map<String,List<String>> mapClonedFromIds = new Map<String,List<String>>();
            List<String> lstGroupQleIds = new List<String>();
            List<Clone_Quote_Refernces__c> lstCloneRef = new List<Clone_Quote_Refernces__c>();
            Set<Id> setOldQuoteIds = new Set<Id>();
            SBQQ__Quote__c objSingleNewQuote;
            
            /*
            // For each old quote passed to the batch execute, clone that quote and add the lines associated 
            // with that quote into a mapIdOldQuote_lstQuoteLines with the 
                        
             quote Id as the Key
            */
            for(SBQQ__Quote__c eachOldQuote : scope) {
                if(String.isBlank(eachOldQuote.Cloned_from_Quote__c)) {
                    objSingleNewQuote = new SBQQ__Quote__c();
                    objSingleNewQuote = eachOldQuote.clone(boolpreserveId, boolisDeepClone, boolpreserveReadonlyTimestamps, boolpreserveAutonumber);
                    objSingleNewQuote.Cloned_from_Quote__c = eachOldQuote.Id;
                    System.debug('OLdQuoteId --> ' +eachOldQuote.Id );
                    objSingleNewQuote.Legacy_Quote_Id__c=null;
                    objSingleNewQuote.SBQQ__Primary__c = false;
                    objSingleNewQuote.Hold_Pre_Migrated_Pricing__c = true;                
                    /*
                    // Code to populate the jsonString__c field on the Quote object
                    */
                    CventMyd_QuoteObject quoteObject = new CventMyd_QuoteObject();
                    //quoteObject.startDate = eachOldQuote.SBQQ__StartDate__c;
                    quoteObject.settings  = new CventMyd_QuoteObject.Settings();

                    quoteObject.settings.msAtLastUpdate = null;
                    //quoteObject.settings.preCalculationFieldNames = CventMyd_UtilityMethods.getListOfStrings([SELECT preCalculationQuoteLineFieldNames__c FROM QcpSettings__mdt LIMIT 1],'preCalculationQuoteLineFieldNames__c');
                    quoteObject.settings.preCalculationFieldNames = preCalculationFieldNames;
                    quoteObject.settings.calculatedFieldNames = calculatedFieldNames;
                    quoteObject.outyearMap  = new Map<Integer,CventMyd_Outyear>();
                    
                    Date previousYearEndDate = eachOldQuote.SBQQ__EndDate__c;
                    SObject record = (SObject)(new SBQQ__Quote__c());
                    Map<Integer,String> yearToEndDateFieldMap = CventMyd_UtilityMethods.getStandardYearToEndDateFieldMap(record);
                  //  System.debug('yearToEndDateFieldMap-->' + yearToEndDateFieldMap);
                    for(Integer i =( Integer.valueOf(eachOldQuote.Current_Year__c)+1); i <= Integer.valueOf(eachOldQuote.Contract_Term_Years__c); i++) {
                        CventMyd_Outyear outyear = new CventMyd_Outyear();
                        outyear.startDate = previousYearEndDate.addDays(1);
                        //if(eachOldQuote.get(yearToEndDateFieldMap.get((i))) == null) { 
                        //    System.debug('yearToEndDateFieldMap.get((i))-->' + yearToEndDateFieldMap.get((i)));
                        //    System.debug('IF-->'+ eachOldQuote.get(yearToEndDateFieldMap.get((i))));
                        if(eachOldQuote.get(yearToEndDateFieldMap.get((i))) == null) {   
                            outyear.endDate = outyear.startDate.addMonths(12);
                            outyear.endDate = outyear.endDate.addDays(-1);
                        }
                        else {
                            outyear.endDate = (Date)eachOldQuote.get(yearToEndDateFieldMap.get(((i-Integer.valueOf(eachOldQuote.Current_Year__c)+1))));
                        }
                        quoteObject.outyearMap.put((i),outyear);
                        previousYearEndDate = outyear.endDate;
                    }
                    quoteObject.insertionId = CventMyd_UtilityMethods.getQleId();
                    quoteObject.automationStage = new CventMyd_QuoteAutomationStage();
                    quoteObject.automationStage.codeStatus = CventMyd_QuoteAutomationStage.CodeStatus.LAST_UPDATED_BY_SCHEDULABLE_JOB;
                    
                    if(eachOldQuote.Multiple_Years_Commitment__c){
                        for(Integer i = Integer.valueof(objSingleNewQuote.Current_Year__c); i <= Integer.valueof(objSingleNewQuote.Contract_Term_Years__c) ; i++) {
                            lstGroupQleIds.add(CventMyd_UtilityMethods.getQleId());
                        }
                    }

                    objSingleNewQuote.jsonString__c = JSON.serialize(quoteObject);
                    if(eachOldQuote.Multiple_Years_Commitment__c){
                        objSingleNewQuote.SBQQ__LineItemsGrouped__c = true;
                    }
                    else {
                        objSingleNewQuote.SBQQ__LineItemsGrouped__c = false;
                    }
                    lstNewQuotes.add(objSingleNewQuote);
                    mapIdOldQuote_lstQuoteLines.put(eachOldQuote.Id, eachOldQuote.SBQQ__LineItems__r);
                    
                    /*
                    // Updating the Primary checkbox to false for old quotes if its set. This needs to be done explicitly since we have set 
                    // the default package triggers to disabled.
                    */
                    objSingleNewQuote = eachOldQuote;
                    //objSingleNewQuote.SBQQ__Primary__c = false;
                    lstOldQuotes.add(eachOldQuote);

                    
                }                
            }

            if(!lstNewQuotes.isEmpty()) {
                try {
                    if(SBQQ.TriggerControl.isEnabled()) {
                        SBQQ.TriggerControl.disable();
                    }
                    Set<Id> setResultSet = new Set<ID>();
                    //insert lstNewQuotes;                   
                    //Database.SaveResult[] lsr = Database.insert(lstNewQuotes,false);
                    insert lstNewQuotes;

                    for(SBQQ__Quote__c lstItr : lstNewQuotes){
                        Clone_Quote_Refernces__c cloneRefObj = new Clone_Quote_Refernces__c();
                        cloneRefObj.Account__c = lstItr.SBQQ__Account__c;
                        cloneRefObj.Opportunity__c = lstItr.SBQQ__Opportunity2__c;
                        cloneRefObj.New_Quote__c = lstItr.Id;
                        cloneRefObj.Old_Quote__c = lstItr.Cloned_from_Quote__c;
                        lstCloneRef.add(cloneRefObj);
                    }
                    Set<Id> setExistingQuote = new Set<Id>();
                    Map<Id,Clone_Quote_Refernces__c> mapCloneRef = new Map<Id,Clone_Quote_Refernces__c>();
                    List<Clone_Quote_Refernces__c> lstNewCloneQuotes = new List<Clone_Quote_Refernces__c>();
                    for(Clone_Quote_Refernces__c lstItr : lstCloneRef){
                        setExistingQuote.add(lstItr.Old_Quote__c);
                    }
                    List<Clone_Quote_Refernces__c> lstCloneRefExist = new List<Clone_Quote_Refernces__c>();
                    lstCloneRefExist = [SELECT  Id,
                                                Name,
                                                New_Quote__c,
                                                Old_Quote__c,
                                                Opportunity__c
                                           FROM Clone_Quote_Refernces__c
                                           WHERE Old_Quote__c IN : setExistingQuote];
                        for(Clone_Quote_Refernces__c lstItr : lstCloneRefExist){
                            mapCloneRef.put(lstItr.Old_Quote__c,lstItr);
                        }
                        for (Clone_Quote_Refernces__c lstItr : lstCloneRef){
                            Clone_Quote_Refernces__c cloneRef = new Clone_Quote_Refernces__c();
                            if(mapCloneRef.containsKey(lstItr.Old_Quote__c)){
                                cloneRef = mapCloneRef.get(lstItr.Old_Quote__c);
                                cloneRef.New_Quote__c = lstItr.New_Quote__c;                    
                            }
                            else{
                                cloneRef.New_Quote__c = lstItr.New_Quote__c;
                                cloneRef.Old_Quote__c = lstItr.Old_Quote__c;
                                cloneRef.Opportunity__c = lstItr.Opportunity__c;
                                cloneRef.Account__c = lstItr.Account__c;                    
                            }
                            lstNewCloneQuotes.add(cloneRef);
                        }
                        if(!lstNewCloneQuotes.isEmpty() && lstNewCloneQuotes.size() > 0){
                            upsert lstNewCloneQuotes;
                        }
                    
                } catch(Exception e) {
                    System.debug('Error Occurred-->'+e.getMessage());
                    //System.abortJob(BC.getJobId());
                }
                
                List<SBQQ__QuoteLineGroup__c> lstQuoteLineGroups = new List<SBQQ__QuoteLineGroup__c>();
                 
                Integer intTerms = 0;
                SBQQ__QuoteLineGroup__c objNewQuoteLineGroup;
                Integer intNumberOfTermsComplete = 0;                
                /*
                // For each new quote inserted, check the field Contract_Term_Years__c and using that field and the number of future 
                // contract years pending based on the difference between Start Date of the quote and todays date 
                // create that many Quote Line Groups for the quote 1 for each year
                // 
                */
                for(SBQQ__Quote__c eachNewQuote : lstNewQuotes) {
                    if(eachNewQuote.Multiple_Years_Commitment__c){
                        if(String.isNotBlank(eachNewQuote.Contract_Term_Years__c)) {
                            intTerms = Integer.valueof(eachNewQuote.Contract_Term_Years__c);
                            intMaxTerms = intTerms + 1;
                            String oldQleId = '';
                            Integer groupnumber= 0; 
                            for(Integer i = Integer.valueof(eachNewQuote.Current_Year__c); i <=intTerms ; i++) {

                                    objNewQuoteLineGroup = new SBQQ__QuoteLineGroup__c();
                                    QuoteLineGroupObjectCloned quoteLineGroupObject = new QuoteLineGroupObjectCloned();
                                   
                                    objNewQuoteLineGroup.SBQQ__Quote__c = eachNewQuote.Id;
                                    objNewQuoteLineGroup.groupType__c = 'Variable MYD Group';
                                    objNewQuoteLineGroup.Created_from_Script__c = true;
                                    if(Integer.valueof(eachNewQuote.Current_Year__c) == i){
                                         objNewQuoteLineGroup.Name = strGroupName + i + ' (Current Year)';
                                    }
                                    else {
                                         objNewQuoteLineGroup.Name = strGroupName + i;
                                         objNewQuoteLineGroup.SBQQ__Optional__c = true;
                                    }

                                    quoteLineGroupObject.qleId = lstGroupQleIds[groupnumber];
                                    
                                    groupnumber = groupnumber + 1;
                                    objNewQuoteLineGroup.SBQQ__Number__c = groupnumber;
                                    objNewQuoteLineGroup.SBQQ__Account__c = eachNewQuote.SBQQ__Account__c;
                                    objNewQuoteLineGroup.term__c = i;


                                    Integer selYear = Integer.valueOf(objNewQuoteLineGroup.term__c - eachNewQuote.Current_Year__c) + 1;
                                    if(selYear == 1) {
                                        objNewQuoteLineGroup.SBQQ__StartDate__c = eachNewQuote.Effective_Year_1_Start_Date__c;
                                        objNewQuoteLineGroup.SBQQ__EndDate__c = eachNewQuote.Effective_Year_1_End_Date__c;
                                        oldQleId = quoteLineGroupObject.qleId;
                                    }
                                    else if(selYear == 2) {
                                        quoteLineGroupObject.clonedFromQleId = oldQleId;                                       
                                        oldQleId = quoteLineGroupObject.qleId;
                                        objNewQuoteLineGroup.SBQQ__StartDate__c = eachNewQuote.Effective_Year_2_Start_Date__c;
                                        objNewQuoteLineGroup.SBQQ__EndDate__c = eachNewQuote.Effective_Year_2_End_Date__c;
                                    }
                                    else if(selYear == 3) {
                                        quoteLineGroupObject.clonedFromQleId = oldQleId;                                       
                                        oldQleId = quoteLineGroupObject.qleId;   
                                        objNewQuoteLineGroup.SBQQ__StartDate__c = eachNewQuote.Effective_Year_3_Start_Date__c;
                                        objNewQuoteLineGroup.SBQQ__EndDate__c = eachNewQuote.Effective_Year_3_End_Date__c;
                                    }
                                    else if(selYear == 4) {
                                        quoteLineGroupObject.clonedFromQleId = oldQleId;                                       
                                        oldQleId = quoteLineGroupObject.qleId;
                                        objNewQuoteLineGroup.SBQQ__StartDate__c = eachNewQuote.Effective_Year_4_Start_Date__c;
                                        objNewQuoteLineGroup.SBQQ__EndDate__c = eachNewQuote.Effective_Year_4_End_Date__c;
                                    }
                                    else if(selYear == 5) {
                                        quoteLineGroupObject.clonedFromQleId = oldQleId;                                       
                                        oldQleId = quoteLineGroupObject.qleId;                                   
                                        objNewQuoteLineGroup.SBQQ__StartDate__c = eachNewQuote.Effective_Year_5_Start_Date__c;
                                        objNewQuoteLineGroup.SBQQ__EndDate__c = eachNewQuote.Effective_Year_5_End_Date__c;
                                    }

                                    quoteLineGroupObject.insertedWithApex = true;
                                    quoteLineGroupObject.wasJustCloned = false;
                                    quoteLineGroupObject.status = new QuoteLineGroupStatus();
                                    quoteLineGroupObject.status.creationType = QuoteLineGroupStatus.GroupCreationType.OUTYEAR_SCHEDULED_APEX_INSERTION;    

                                    objNewQuoteLineGroup.jsonString__c = JSON.serialize(quoteLineGroupObject);
                                    lstQuoteLineGroups.add(objNewQuoteLineGroup);
                               
                            }
                        }
                    }
                }
                
                if(!lstQuoteLineGroups.isEmpty()) {
                    try {
                        Database.SaveResult[] lsr = Database.insert(lstQuoteLineGroups,false);
                         //insert lstQuoteLineGroups;
                    } catch(Exception e) {
                        System.debug('Error Occurred-->'+e.getMessage());
                        //System.abortJob(BC.getJobId());
                    }
                    
                    Set<Id> setGroupIds = new Set<Id>();
                    for(SBQQ__QuoteLineGroup__c eachGroup : lstQuoteLineGroups) {
                        setGroupIds.add(eachGroup.Id);
                    }
                    
                    List<SBQQ__QuoteLine__c> lstNewQuoteLines = new List<SBQQ__QuoteLine__c>();
                    SBQQ__QuoteLine__c objNewQuoteLine;
                    mapRequiredBy = new Map<String,SBQQ__QuoteLine__c>();
                    
                    /*
                    // For each new Quote Line Group inserted, iterate over the list of Quote Lines retrieved using the old Quote ID lookup on the 
                    // Quote associated to the Group.
                    // Clone each quote line if the corresponding fields holding the Year values are populated on the original Quote Line
                    // Map the correct field values from the old quote lines to the new quote lines
                    */

                    List<SBQQ__QuoteLineGroup__c> lstNewGroupCreated = [SELECT Id, 
                                                                    g.SBQQ__Quote__r.Cloned_from_Quote__c,
                                                                    SBQQ__Number__c,
                                                                    SBQQ__Quote__r.Name,
                                                                    SBQQ__Quote__r.Id,
                                                                    SBQQ__Quote__r.Current_Year__c,
                                                                    SBQQ__Quote__r.Effective_Year_1_Start_Date__c,
                                                                    SBQQ__Quote__r.Effective_Year_1_End_Date__c,
                                                                    SBQQ__Quote__r.Effective_Year_2_Start_Date__c,
                                                                    SBQQ__Quote__r.Effective_Year_2_End_Date__c,
                                                                    SBQQ__Quote__r.Effective_Year_3_Start_Date__c,
                                                                    SBQQ__Quote__r.Effective_Year_3_End_Date__c,
                                                                    SBQQ__Quote__r.Effective_Year_4_Start_Date__c,
                                                                    SBQQ__Quote__r.Effective_Year_4_End_Date__c,
                                                                    SBQQ__Quote__r.Effective_Year_5_Start_Date__c,
                                                                    SBQQ__Quote__r.Effective_Year_5_End_Date__c,
                                                                    SBQQ__Quote__r.SBQQ__Type__c,
                                                                    term__c,
                                                                    SBQQ__Quote__c
                                                            FROM SBQQ__QuoteLineGroup__c g
                                                            WHERE Id in : setGroupIds
                                                            ORDER BY SBQQ__Number__c];
                    Set<Integer> groupYears = new Set<Integer>();
                    for(SBQQ__QuoteLineGroup__c eachGroup : lstNewGroupCreated){
                        groupYears.add(Integer.valueOf(eachGroup.SBQQ__Number__c));
                    }

                    Set<Id> upGradedSubsID = new Set<ID>();
                    SBQQ__Quote__c currentQuote = new SBQQ__Quote__c();
                    for(SBQQ__QuoteLineGroup__c eachGroup : lstNewGroupCreated) {
                        if(mapIdOldQuote_lstQuoteLines.containsKey(eachGroup.SBQQ__Quote__r.Cloned_from_Quote__c)) {  
                            for(SBQQ__QuoteLine__c eachQuoteLine : mapIdOldQuote_lstQuoteLines.get(eachGroup.SBQQ__Quote__r.Cloned_from_Quote__c)) {
                                if(eachGroup.SBQQ__Number__c == 1 ||
                                    (eachGroup.SBQQ__Number__c == 2 && (eachQuoteLine.Year_2_List_Price__c != null || 
                                    eachQuoteLine.Year_2_Effective_Quantity__c != null || eachQuoteLine.Year_2_Discount__c != null || eachQuoteLine.Year_2_Effective_Amount__c!= null)) ||
                                    (eachGroup.SBQQ__Number__c == 3 && (eachQuoteLine.Year_3_List_Price__c != null || 
                                    eachQuoteLine.Year_3_Effective_Quantity__c != null || eachQuoteLine.Year_3_Discount__c != null || eachQuoteLine.Year_3_Effective_Amount__c!= null)) ||
                                    (eachGroup.SBQQ__Number__c == 4 && (eachQuoteLine.Year_4_List_Price__c != null || 
                                    eachQuoteLine.Year_4_Effective_Quantity__c != null || eachQuoteLine.Year_4_Discount__c != null || eachQuoteLine.Year_4_Effective_Amount__c!= null)) ||
                                    (eachGroup.SBQQ__Number__c == 5 && (eachQuoteLine.Year_5_List_Price__c != null || 
                                    eachQuoteLine.Year_5_Effective_Quantity__c != null || eachQuoteLine.Year_5_Discount__c != null || eachQuoteLine.Year_5_Effective_Amount__c!= null))) {
                                    objNewQuoteLine = new SBQQ__QuoteLine__c();
                                    objNewQuoteLine.Created_from_Script__c = true;
                                    objNewQuoteLine = eachQuoteLine.clone(boolpreserveId, boolisDeepClone, boolpreserveReadonlyTimestamps, boolpreserveAutonumber);
                                 
                                   
                                    objNewQuoteLine.SBQQ__Group__c = eachGroup.Id;
                                    objNewQuoteLine.Quote_Line_Term__c = eachGroup.term__c;
                                    objNewQuoteLine.SBQQ__Quote__c = eachGroup.SBQQ__Quote__r.Id;
                                    objNewQuoteLine.Cloned_from_Quote_Line__c = eachQuoteLine.Id;
                                    objNewQuoteLine.Hold_Pre_Migrated_Pricing__c = true;

                                    Map<String,List<String>> mapPreCalculationFieldNames = new Map<String,List<String>>();
                                    Map<String,List<String>> mapCalculatedFieldNames = new Map<String,List<String>>();
                                    Map<String,String> mapContractedFieldNames = new Map<String,String>();

                                    CventMyd_QuoteLineObject quoteLineObject = new CventMyd_QuoteLineObject();
                                    quoteLineObject.quoteName = eachGroup.SBQQ__Quote__r.Name;
                                    quoteLineObject.qleId = CventMyd_UtilityMethods.getQleId();
                                    string mapKey = objNewQuoteLine.SBQQ__Quote__c + '' + eachQuoteLine.SBQQ__Product__c;
                                    List<String> existinQleId = new List<String>();
                                    if(mapClonedFromIds.containsKey(mapKey)){
                                        existinQleId = mapClonedFromIds.get(mapKey);
                                        existinQleId.add(quoteLineObject.qleId);
                                    }
                                    else {                                       
                                        existinQleId.add(quoteLineObject.qleId);
                                    }

                                    mapClonedFromIds.put(mapKey, existinQleId); 

                                    /*if(String.isNotBlank(eachQuoteLine.jsonString__c)) {
                                        String clonedFromQleId = eachQuoteLine.jsonString__c.substringAfter('"qleId":"');
                                        clonedFromQleId = clonedFromQleId.subStringBefore('"');
                                        quoteLineObject.clonedFromQleIds = new List<String>{
                                            clonedFromQleId
                                        };
                                    }*/

                                    quoteLineObject.insertedWithApex = true;
                                    

                                    if(eachGroup.SBQQ__Number__c == 1) {

                                        objNewQuoteLine.SBQQ__PriorQuantity__c = eachQuoteLine.SBQQ__PriorQuantity__c;
                                        if(eachQuoteLine.SBQQ__ListPrice__c == null || eachQuoteLine.SBQQ__ListPrice__c== 0){
                                            objNewQuoteLine.SBQQ__ListPrice__c = eachQuoteLine.SBQQ__SpecialPrice__c ;
                                        }
                                        else {
                                            objNewQuoteLine.SBQQ__ListPrice__c = eachQuoteLine.SBQQ__ListPrice__c;
                                        }
                                        objNewQuoteLine.SBQQ__Quantity__c = eachQuoteLine.SBQQ__Quantity__c;                                   
                                        objNewQuoteLine.SBQQ__Discount__c = eachQuoteLine.SBQQ__Discount__c;
                                        objNewQuoteLine.Custom_Discount__c = eachQuoteLine.Custom_Discount__c;                                        
                                        objNewQuoteLine.Brand__c           = eachQuoteLine.Y01Brand__c;
                                        objNewQuoteLine.Property__c        = eachQuoteLine.Y01Property__c;
                                        objNewQuoteLine.Total__c           = eachQuoteLine.Y01Total__c;
                                        objNewQuoteLine.SBQQ__Optional__c = boolFalseVal;
                                        objNewQuoteLine.SBQQ__StartDate__c = (eachQuoteLine.SBQQ__EffectiveStartDate__c!= null ? eachQuoteLine.SBQQ__EffectiveStartDate__c : eachGroup.SBQQ__Quote__r.Effective_Year_1_Start_Date__c);
                                        objNewQuoteLine.SBQQ__EndDate__c = (eachQuoteLine.SBQQ__EffectiveEndDate__c!= null ? eachQuoteLine.SBQQ__EffectiveEndDate__c : eachGroup.SBQQ__Quote__r.Effective_Year_1_End_Date__c);
                                        SBQQ__QuoteLine__c nexYearQuoteLine = eachQuoteLine.clone(boolpreserveId, boolisDeepClone, boolpreserveReadonlyTimestamps, boolpreserveAutonumber);
                                        
                                        /**Need to optimize** */
                                        if(eachQuoteLine.Year_2_List_Price__c == null || eachQuoteLine.Year_2_List_Price__c == 0 ){
                                            nexYearQuoteLine.SBQQ__ListPrice__c = eachQuoteLine.SBQQ__ListPrice__c;
                                        }
                                        else {
                                            nexYearQuoteLine.SBQQ__ListPrice__c = eachQuoteLine.Year_2_List_Price__c;  
                                        }
                                        
                                        nexYearQuoteLine.SBQQ__Quantity__c = eachQuoteLine.Year_2_Quantity__c;
                                        if(eachQuoteLine.Year_2_Quantity__c == null){                                         
                                            nexYearQuoteLine.SBQQ__Quantity__c = eachQuoteLine.Year_2_Effective_Quantity__c;
                                        }
                                        if(eachGroup.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment'){
                                          nexYearQuoteLine.SBQQ__PriorQuantity__c = null;  
                                        }                                     
                                        nexYearQuoteLine.SBQQ__StartDate__c = (eachQuoteLine.Year_2_Start_Date__c!= null ? eachQuoteLine.Year_2_Start_Date__c : eachGroup.SBQQ__Quote__r.Effective_Year_2_Start_Date__c);
                                        nexYearQuoteLine.SBQQ__EndDate__c = (eachQuoteLine.Year_2_End_Date__c!= null ? eachQuoteLine.Year_2_End_Date__c : eachGroup.SBQQ__Quote__r.Effective_Year_2_End_Date__c);
                                        nexYearQuoteLine.Overage_Fee__c = eachQuoteLine.Year_2_Overage_Fee__c;
                                        nexYearQuoteLine.Previous_Default_Overage_Fee__c = eachQuoteLine.Year_2_Previous_Default_Overage_Fee__c;
                                        nexYearQuoteLine.SBQQ__PriceEditable__c = eachQuoteLine.Year_2_Price_Editable_Calculated__c;
                                        nexYearQuoteLine.Rate_Parity_Quantity__c = eachQuoteLine.Year_2_Rate_Parity_Quantity__c;
                                        nexYearQuoteLine.Room_Night_Net_Total__c = eachQuoteLine.Year_2_Room_Night_Net_Total__c;
                                        nexYearQuoteLine.Room_Nights__c = eachQuoteLine.Year_2_Room_Nights_RFPs__c;
                                        nexYearQuoteLine.Event_Registration_Quantity__c = eachQuoteLine.Year_2_Event_Registration_Quantity__c;
                                        nexYearQuoteLine.Brand__c = eachQuoteLine.Y02Brand__c;
                                        nexYearQuoteLine.Property__c = eachQuoteLine.Y02Property__c;
                                        nexYearQuoteLine.Total__c = eachQuoteLine.Y02Total__c;
                                        nexYearQuoteLine.SBQQ__Optional__c = boolTrueVal;
                                        if(eachQuoteLine.SBQQ__UpgradedSubscription__c != null) {
                                            nexYearQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_2_Net_Price_X__c;
                                        }                                        
                                        else if(nexYearQuoteLine.SBQQ__Bundled__c||
                                                (eachQuoteLine.Year_2_Effective_Amount__c == null || 
                                                eachQuoteLine.Year_2_Effective_Amount__c == 0 || 
                                                eachQuoteLine.Year_2_Effective_Quantity__c == null || 
                                                eachQuoteLine.Year_2_Effective_Quantity__c== 0 )){
                                            nexYearQuoteLine.SBQQ__NetPrice__c = 0;   
                                        }
                                        else  if(eachQuoteLine.SBQQ__PricingMethod__c == 'Block' || eachQuoteLine.SBQQ__DiscountScheduleType__c == 'Slab'){
                                            if(eachQuoteLine.Year_2_Net_Amount__c == null){
                                                nexYearQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_2_Effective_Amount__c;
                                            }
                                            else {
                                            nexYearQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_2_Net_Amount__c;
                                            }
                                        }
                                        
                                        else if( eachQuoteLine.Year_2_Effective_Quantity__c!= null &&  
                                            eachQuoteLine.Year_2_Effective_Quantity__c!= 0) {
                                            nexYearQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_2_Effective_Amount__c / eachQuoteLine.Year_2_Effective_Quantity__c;
                                        } 
                                        else {
                                            nexYearQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_2_Net_Price__c;
                                        } 
                                        if(nexYearQuoteLine.SBQQ__ListPrice__c != 0 && nexYearQuoteLine.SBQQ__ListPrice__c != null){
                                            nexYearQuoteLine.Discount_Type__c = '%';
                                            nexYearQuoteLine.SBQQ__AdditionalDiscountAmount__c = null;
                                            nexYearQuoteLine.SBQQ__Discount__c= ((nexYearQuoteLine.SBQQ__ListPrice__c - nexYearQuoteLine.SBQQ__NetPrice__c)/nexYearQuoteLine.SBQQ__ListPrice__c) * 100;
                                            nexYearQuoteLine.Custom_Discount__c = nexYearQuoteLine.SBQQ__Discount__c;
                                        }
                                        else {
                                            nexYearQuoteLine.Discount_Type__c = 'Amt.';
                                            nexYearQuoteLine.SBQQ__AdditionalDiscountAmount__c = (0 - nexYearQuoteLine.SBQQ__NetPrice__c);
                                            nexYearQuoteLine.SBQQ__Discount__c = null;
                                            nexYearQuoteLine.Custom_Discount__c = nexYearQuoteLine.SBQQ__AdditionalDiscountAmount__c;
                                        }
                                    
                                        for(String fieldApiName :preCalculationFieldNames){
                                            List<String> fieldValue = new List<String>();
                                            fieldValue.add(String.valueOf(objNewQuoteLine.get(fieldApiName))); 
                                            if(groupYears.contains(Integer.valueOf(eachGroup.SBQQ__Number__c) + 1)){
                                                fieldValue.add(String.valueOf(nexYearQuoteLine.get(fieldApiName))); 
                                            }                                       
                                            mapPreCalculationFieldNames.put(fieldApiName,fieldValue);
                                            }
                                        for(String fieldApiName :calculatedFieldNames){
                                            List<String> fieldValue = new  List<String>();
                                            fieldValue.add(String.valueOf(objNewQuoteLine.get(fieldApiName))); 
                                            if(groupYears.contains(Integer.valueOf(eachGroup.SBQQ__Number__c) + 1)){
                                                fieldValue.add(String.valueOf(nexYearQuoteLine.get(fieldApiName))); 
                                            }                                      
                                            mapCalculatedFieldNames.put(fieldApiName,fieldValue);
                                            if(eachGroup.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment'){
                                                mapContractedFieldNames.put(fieldApiName,String.valueOf(objNewQuoteLine.get(fieldApiName)));
                                            }
                                        }
                                    }
                                    else if(eachGroup.SBQQ__Number__c == 2) {
                                        if(eachQuoteLine.Year_2_List_Price__c == null || eachQuoteLine.Year_2_List_Price__c == 0){
                                            objNewQuoteLine.SBQQ__ListPrice__c = eachQuoteLine.SBQQ__ListPrice__c;
                                        }
                                        else {
                                            objNewQuoteLine.SBQQ__ListPrice__c = eachQuoteLine.Year_2_List_Price__c;  
                                        }
                                         
                                        objNewQuoteLine.SBQQ__ProratedListPrice__c = objNewQuoteLine.SBQQ__ListPrice__c;
                                        objNewQuoteLine.SBQQ__ProrateMultiplier__c = 1;
                                     
                                        if(eachGroup.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment'  ){
                                            if(eachQuoteLine.SBQQ__UpgradedSubscription__c != null){
                                                objNewQuoteLine.SBQQ__PriorQuantity__c = eachQuoteLine.Year_2_Prior_Quantity_X__c;
                                            }
                                        }
                                        System.debug('achQuoteLine.Year_2_Quantity__c-->' + eachQuoteLine.Year_2_Quantity__c);
                                        System.debug('eachQuoteLine.Year_2_Effective_Quantity__c-->' + eachQuoteLine.Year_2_Effective_Quantity__c);
                                        if(eachQuoteLine.Year_2_Quantity__c == null){                                            
                                            objNewQuoteLine.SBQQ__Quantity__c = eachQuoteLine.Year_2_Effective_Quantity__c;
                                        } 
                                        else {
                                            objNewQuoteLine.SBQQ__Quantity__c = eachQuoteLine.Year_2_Quantity__c;
                                        }    
                                                
                                        

                                        objNewQuoteLine.SBQQ__StartDate__c = (eachQuoteLine.Year_2_Start_Date__c!= null ? eachQuoteLine.Year_2_Start_Date__c : eachGroup.SBQQ__Quote__r.Effective_Year_2_Start_Date__c);
                                        objNewQuoteLine.SBQQ__EndDate__c = (eachQuoteLine.Year_2_End_Date__c!= null ? eachQuoteLine.Year_2_End_Date__c : eachGroup.SBQQ__Quote__r.Effective_Year_2_End_Date__c);
                                        objNewQuoteLine.Overage_Fee__c = eachQuoteLine.Year_2_Overage_Fee__c;
                                        objNewQuoteLine.Previous_Default_Overage_Fee__c = eachQuoteLine.Year_2_Previous_Default_Overage_Fee__c;
                                        objNewQuoteLine.SBQQ__PriceEditable__c = eachQuoteLine.Year_2_Price_Editable_Calculated__c;
                                        objNewQuoteLine.Rate_Parity_Quantity__c = eachQuoteLine.Year_2_Rate_Parity_Quantity__c;
                                        objNewQuoteLine.Room_Night_Net_Total__c = eachQuoteLine.Year_2_Room_Night_Net_Total__c;
                                        objNewQuoteLine.Room_Nights__c = eachQuoteLine.Year_2_Room_Nights_RFPs__c;
                                        objNewQuoteLine.Event_Registration_Quantity__c = eachQuoteLine.Year_2_Event_Registration_Quantity__c;
                                        objNewQuoteLine.Brand__c = eachQuoteLine.Y02Brand__c;
                                        objNewQuoteLine.Property__c = eachQuoteLine.Y02Property__c;
                                        objNewQuoteLine.Total__c = eachQuoteLine.Y02Total__c;
                                        objNewQuoteLine.SBQQ__Optional__c = boolTrueVal;                                      
                                        if(eachQuoteLine.SBQQ__UpgradedSubscription__c != null) {
                                            objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_2_Net_Price_X__c;
                                        }                                        
                                        else if(objNewQuoteLine.SBQQ__Bundled__c||
                                                (eachQuoteLine.Year_2_Effective_Amount__c == null || 
                                                eachQuoteLine.Year_2_Effective_Amount__c == 0 || 
                                                eachQuoteLine.Year_2_Effective_Quantity__c == null || 
                                                eachQuoteLine.Year_2_Effective_Quantity__c== 0 )){
                                            objNewQuoteLine.SBQQ__NetPrice__c = 0;   
                                        }
                                        else  if(eachQuoteLine.SBQQ__PricingMethod__c == 'Block' || eachQuoteLine.SBQQ__DiscountScheduleType__c == 'Slab'){
                                            if(eachQuoteLine.Year_2_Net_Amount__c != null){
                                                objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_2_Net_Amount__c;
                                            }
                                            else {
                                                objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_2_Effective_Amount__c;
                                            }

                                        }
                                        else if( eachQuoteLine.Year_2_Effective_Quantity__c!= null &&  
                                            eachQuoteLine.Year_2_Effective_Quantity__c!= 0) {
                                            objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_2_Effective_Amount__c / eachQuoteLine.Year_2_Effective_Quantity__c;
                                        } 
                                        else {
                                            objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_2_Net_Price__c;
                                        }                                       

                                        objNewQuoteLine.SBQQ__RegularPrice__c = objNewQuoteLine.SBQQ__ListPrice__c;
                                        objNewQuoteLine.SBQQ__CustomerPrice__c = objNewQuoteLine.SBQQ__NetPrice__c;
                                        objNewQuoteLine.SBQQ__SpecialPrice__c = eachQuoteLine.SBQQ__ListPrice__c;

                                        if(objNewQuoteLine.SBQQ__ListPrice__c != 0 && objNewQuoteLine.SBQQ__ListPrice__c != null){
                                            objNewQuoteLine.Discount_Type__c = '%';
                                            objNewQuoteLine.SBQQ__AdditionalDiscountAmount__c = null;
                                            objNewQuoteLine.SBQQ__Discount__c= ((objNewQuoteLine.SBQQ__ListPrice__c - objNewQuoteLine.SBQQ__NetPrice__c)/objNewQuoteLine.SBQQ__ListPrice__c) * 100;
                                            objNewQuoteLine.Custom_Discount__c = objNewQuoteLine.SBQQ__Discount__c;
                                        }
                                        else {
                                            objNewQuoteLine.Discount_Type__c = 'Amt.';
                                            objNewQuoteLine.SBQQ__AdditionalDiscountAmount__c = (0 - objNewQuoteLine.SBQQ__NetPrice__c);
                                            objNewQuoteLine.SBQQ__Discount__c = null;
                                            objNewQuoteLine.Custom_Discount__c = objNewQuoteLine.SBQQ__AdditionalDiscountAmount__c;
                                        }
                                    
                                        for(String fieldApiName :preCalculationFieldNames){
                                            List<String> fieldValue = new List<String>();
                                            fieldValue.add(String.valueOf(objNewQuoteLine.get(fieldApiName))); 
                                                                           
                                            mapPreCalculationFieldNames.put(fieldApiName,fieldValue);
                                        }
                                        for(String fieldApiName :calculatedFieldNames){
                                            List<String> fieldValue = new  List<String>();
                                            fieldValue.add(String.valueOf(objNewQuoteLine.get(fieldApiName))); 
                                                                            
                                            mapCalculatedFieldNames.put(fieldApiName,fieldValue);
                                            if(eachGroup.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment'){
                                                mapContractedFieldNames.put(fieldApiName,String.valueOf(objNewQuoteLine.get(fieldApiName)));
                                            }
                                        }
                                        
                                    }
                                    else if(eachGroup.SBQQ__Number__c == 3) {
                                        if(eachQuoteLine.Year_3_List_Price__c == null || eachQuoteLine.Year_3_List_Price__c == 0){
                                            objNewQuoteLine.SBQQ__ListPrice__c = eachQuoteLine.SBQQ__ListPrice__c ;
                                        }
                                        else {
                                            objNewQuoteLine.SBQQ__ListPrice__c = eachQuoteLine.Year_3_List_Price__c;
                                        }
                                        
                                        objNewQuoteLine.SBQQ__ProratedListPrice__c = objNewQuoteLine.SBQQ__ListPrice__c;
                                        objNewQuoteLine.SBQQ__ProrateMultiplier__c = 1;
                                        //objNewQuoteLine.SBQQ__Quantity__c = eachQuoteLine.Year_3_Quantity__c;
                                        objNewQuoteLine.SBQQ__StartDate__c = (eachQuoteLine.Year_3_Start_Date__c!= null ? eachQuoteLine.Year_3_Start_Date__c : eachGroup.SBQQ__Quote__r.Effective_Year_3_Start_Date__c);
                                        objNewQuoteLine.SBQQ__EndDate__c = (eachQuoteLine.Year_3_End_Date__c!= null ? eachQuoteLine.Year_3_End_Date__c : eachGroup.SBQQ__Quote__r.Effective_Year_3_End_Date__c);
                                       
                                            objNewQuoteLine.SBQQ__Discount__c=eachQuoteLine.Year_3_Discount__c;
                                        
                                        if(eachGroup.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment'  ){
                                            if(eachQuoteLine.SBQQ__UpgradedSubscription__c != null){
                                                //upGradedSubsID.add(eachQuoteLine.SBQQ__UpgradedSubscription__c);
                                                objNewQuoteLine.SBQQ__PriorQuantity__c = eachQuoteLine.Year_3_Prior_Quantity_X__c;
                                            }
                                        }
                                        
                                        if(eachQuoteLine.Year_3_Quantity__c == null){                                         
                                            objNewQuoteLine.SBQQ__Quantity__c = eachQuoteLine.Year_3_Effective_Quantity__c;
                                        }
                                        else {
                                              objNewQuoteLine.SBQQ__Quantity__c = eachQuoteLine.Year_3_Quantity__c;
                                        } 
                                        
                                        objNewQuoteLine.Overage_Fee__c = eachQuoteLine.Year_3_Overage_Fee__c;
                                        objNewQuoteLine.Previous_Default_Overage_Fee__c = eachQuoteLine.Year_3_Previous_Default_Overage_Fee__c;
                                        objNewQuoteLine.SBQQ__PriceEditable__c = eachQuoteLine.Year_3_Price_Editable_Calculated__c;
                                        objNewQuoteLine.Rate_Parity_Quantity__c = eachQuoteLine.Year_3_Rate_Parity_Quantity__c;
                                        objNewQuoteLine.Room_Night_Net_Total__c = eachQuoteLine.Year_3_Room_Night_Net_Total__c;
                                        objNewQuoteLine.Room_Nights__c = eachQuoteLine.Year_3_Room_Nights_RFPs__c;
                                        objNewQuoteLine.Event_Registration_Quantity__c = eachQuoteLine.Year_3_Event_Registration_Quantity__c;
                                        objNewQuoteLine.Brand__c = eachQuoteLine.Y03Brand__c;
                                        objNewQuoteLine.Property__c = eachQuoteLine.Y03Property__c;
                                        objNewQuoteLine.Discount_Schedule_Quantity__c = eachQuoteLine.Year_3_Discount_Schedule_Quantity__c;
                                        objNewQuoteLine.Total__c = eachQuoteLine.Y03Total__c;
                                        objNewQuoteLine.SBQQ__Optional__c = boolTrueVal;
                                        
                                      
                                        if(eachQuoteLine.SBQQ__UpgradedSubscription__c != null) {
                                            objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_3_Net_Price_X__c;
                                        }                                        
                                        else if(objNewQuoteLine.SBQQ__Bundled__c||
                                                (eachQuoteLine.Year_3_Effective_Amount__c == null || 
                                                eachQuoteLine.Year_3_Effective_Amount__c == 0 || 
                                                eachQuoteLine.Year_3_Effective_Quantity__c == null || 
                                                eachQuoteLine.Year_3_Effective_Quantity__c== 0 )){
                                            objNewQuoteLine.SBQQ__NetPrice__c = 0;   
                                        }

                                        else if(eachQuoteLine.SBQQ__PricingMethod__c == 'Block' || eachQuoteLine.SBQQ__DiscountScheduleType__c == 'Slab'){
                                            if(eachQuoteLine.Year_3_Net_Amount__c != null){
                                                objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_3_Net_Amount__c;
                                            }
                                            else {
                                                objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_3_Effective_Amount__c;
                                            }
                                        }
                                        else if(eachQuoteLine.Year_3_Effective_Quantity__c!= null && 
                                                eachQuoteLine.Year_3_Effective_Quantity__c!= 0) {
                                            objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_3_Effective_Amount__c / eachQuoteLine.Year_3_Effective_Quantity__c;
                                        }
                                        else {
                                            objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_3_Net_Price__c;
                                        }                                       

                                        objNewQuoteLine.SBQQ__RegularPrice__c = objNewQuoteLine.SBQQ__ListPrice__c;
                                        objNewQuoteLine.SBQQ__CustomerPrice__c = objNewQuoteLine.SBQQ__NetPrice__c;
                                        objNewQuoteLine.SBQQ__SpecialPrice__c = eachQuoteLine.SBQQ__ListPrice__c;

                                        //Double discount = (objNewQuoteLine.SBQQ__ListPrice__c - objNewQuoteLine.SBQQ__NetPrice__c);
                                        if(objNewQuoteLine.SBQQ__ListPrice__c != 0 && objNewQuoteLine.SBQQ__ListPrice__c != null){
                                            objNewQuoteLine.Discount_Type__c = '%';
                                            objNewQuoteLine.SBQQ__AdditionalDiscountAmount__c = null;
                                            objNewQuoteLine.SBQQ__Discount__c= ((objNewQuoteLine.SBQQ__ListPrice__c - objNewQuoteLine.SBQQ__NetPrice__c)/objNewQuoteLine.SBQQ__ListPrice__c) * 100;
                                            objNewQuoteLine.Custom_Discount__c = objNewQuoteLine.SBQQ__Discount__c;
                                        }
                                        else {
                                            objNewQuoteLine.Discount_Type__c = 'Amt.';
                                            objNewQuoteLine.SBQQ__AdditionalDiscountAmount__c = (0 - objNewQuoteLine.SBQQ__NetPrice__c);
                                            objNewQuoteLine.SBQQ__Discount__c = null;
                                            objNewQuoteLine.Custom_Discount__c = objNewQuoteLine.SBQQ__AdditionalDiscountAmount__c;
                                        }
                                    

                                        for(String fieldApiName :preCalculationFieldNames){
                                            List<String> fieldValue = new List<String>();
                                            fieldValue.add(String.valueOf(objNewQuoteLine.get(fieldApiName))); 
                                            mapPreCalculationFieldNames.put(fieldApiName,fieldValue);
                                        }
                                        for(String fieldApiName :calculatedFieldNames){
                                            List<String> fieldValue = new  List<String>();
                                            fieldValue.add(String.valueOf(objNewQuoteLine.get(fieldApiName))); 
                                            mapCalculatedFieldNames.put(fieldApiName,fieldValue);
                                            if(eachGroup.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment'){
                                                mapContractedFieldNames.put(fieldApiName,String.valueOf(objNewQuoteLine.get(fieldApiName)));
                                            }
                                        }
                                        
                                    }
                                    else if(eachGroup.SBQQ__Number__c == 4) {
                                        if(eachQuoteLine.Year_4_List_Price__c== null || eachQuoteLine.Year_4_List_Price__c == 0){
                                            objNewQuoteLine.SBQQ__ListPrice__c = eachQuoteLine.SBQQ__ListPrice__c ;
                                        }
                                        else {
                                            objNewQuoteLine.SBQQ__ListPrice__c = eachQuoteLine.Year_4_List_Price__c;
                                        }
                                         
                                        objNewQuoteLine.SBQQ__ProratedListPrice__c = objNewQuoteLine.SBQQ__ListPrice__c;
                                        //objNewQuoteLine.SBQQ__Quantity__c = eachQuoteLine.Year_4_Quantity__c;
                                        objNewQuoteLine.SBQQ__ProrateMultiplier__c = 1;
                                        if(eachGroup.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment'  ){
                                            if(eachQuoteLine.SBQQ__UpgradedSubscription__c != null){
                                                //upGradedSubsID.add(eachQuoteLine.SBQQ__UpgradedSubscription__c);
                                                objNewQuoteLine.SBQQ__PriorQuantity__c = eachQuoteLine.Year_4_Prior_Quantity_X__c;
                                            }
                                        }
                                       
                                        if(eachQuoteLine.Year_4_Quantity__c == null){
                                            objNewQuoteLine.SBQQ__Quantity__c = eachQuoteLine.Year_4_Effective_Quantity__c;
                                        }
                                         else {
                                            objNewQuoteLine.SBQQ__Quantity__c = eachQuoteLine.Year_4_Quantity__c;
                                        }
                                        objNewQuoteLine.SBQQ__AdditionalDiscountAmount__c = null;
                                        objNewQuoteLine.SBQQ__StartDate__c = (eachQuoteLine.Year_4_Start_Date__c!= null ? eachQuoteLine.Year_4_Start_Date__c : eachGroup.SBQQ__Quote__r.Effective_Year_4_Start_Date__c);
                                        objNewQuoteLine.SBQQ__EndDate__c = (eachQuoteLine.Year_4_End_Date__c!= null ? eachQuoteLine.Year_4_End_Date__c : eachGroup.SBQQ__Quote__r.Effective_Year_4_End_Date__c);
                                        
                                        objNewQuoteLine.Overage_Fee__c = eachQuoteLine.Year_4_Overage_Fee__c;
                                        objNewQuoteLine.Previous_Default_Overage_Fee__c = eachQuoteLine.Year_4_Previous_Default_Overage_Fee__c;
                                        objNewQuoteLine.SBQQ__PriceEditable__c = eachQuoteLine.Year_4_Price_Editable_Calculated__c;
                                        objNewQuoteLine.Rate_Parity_Quantity__c = eachQuoteLine.Year_4_Rate_Parity_Quantity__c;
                                        objNewQuoteLine.Room_Night_Net_Total__c = eachQuoteLine.Year_4_Room_Night_Net_Total__c;
                                        objNewQuoteLine.Room_Nights__c = eachQuoteLine.Year_4_Room_Nights_RFPs__c;
                                        objNewQuoteLine.Event_Registration_Quantity__c = eachQuoteLine.Year_4_Event_Registration_Quantity__c;
                                        objNewQuoteLine.Brand__c = eachQuoteLine.Y04Brand__c;
                                        objNewQuoteLine.Property__c = eachQuoteLine.Y04Property__c;
                                        objNewQuoteLine.Discount_Schedule_Quantity__c = eachQuoteLine.Year_4_Discount_Schedule_Quantity__c;
                                        objNewQuoteLine.Total__c = eachQuoteLine.Y04Total__c;
                                        objNewQuoteLine.SBQQ__Optional__c = boolTrueVal;                                        
                                        
                                        if(eachQuoteLine.SBQQ__UpgradedSubscription__c != null) {
                                            objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_4_Net_Price_X__c;
                                        }                                        
                                        else if(objNewQuoteLine.SBQQ__Bundled__c ||
                                                (eachQuoteLine.Year_4_Effective_Amount__c == null || 
                                                eachQuoteLine.Year_4_Effective_Amount__c == 0 || 
                                                eachQuoteLine.Year_4_Effective_Quantity__c == null || 
                                                eachQuoteLine.Year_4_Effective_Quantity__c== 0 )){
                                            objNewQuoteLine.SBQQ__NetPrice__c = 0;                                            
                                        }
                                        else  if(eachQuoteLine.SBQQ__PricingMethod__c == 'Block' || eachQuoteLine.SBQQ__DiscountScheduleType__c == 'Slab'){
                                            if(eachQuoteLine.Year_4_Net_Amount__c != null){
                                                objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_4_Net_Amount__c;
                                            }
                                            else {
                                                objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_4_Effective_Amount__c;
                                            }
                                        }
                                        else if(eachQuoteLine.Year_4_Effective_Quantity__c!= null && 
                                                eachQuoteLine.Year_4_Effective_Quantity__c!= 0) {
                                            objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_4_Effective_Amount__c / eachQuoteLine.Year_4_Effective_Quantity__c;
                                        }
                                        else {
                                            objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_4_Net_Price__c;
                                        } 
                                        objNewQuoteLine.SBQQ__RegularPrice__c = objNewQuoteLine.SBQQ__ListPrice__c;
                                        objNewQuoteLine.SBQQ__CustomerPrice__c = objNewQuoteLine.SBQQ__NetPrice__c;
                                        objNewQuoteLine.SBQQ__SpecialPrice__c = eachQuoteLine.SBQQ__ListPrice__c;

                                        if(objNewQuoteLine.SBQQ__ListPrice__c != 0 && objNewQuoteLine.SBQQ__ListPrice__c != null){
                                            objNewQuoteLine.Discount_Type__c = '%';
                                            objNewQuoteLine.SBQQ__AdditionalDiscountAmount__c = null;
                                            objNewQuoteLine.SBQQ__Discount__c= ((objNewQuoteLine.SBQQ__ListPrice__c - objNewQuoteLine.SBQQ__NetPrice__c)/objNewQuoteLine.SBQQ__ListPrice__c) * 100;
                                            objNewQuoteLine.Custom_Discount__c = objNewQuoteLine.SBQQ__Discount__c;
                                        }
                                        else {
                                            objNewQuoteLine.Discount_Type__c = 'Amt.';
                                            objNewQuoteLine.SBQQ__AdditionalDiscountAmount__c = (0 - objNewQuoteLine.SBQQ__NetPrice__c);
                                            objNewQuoteLine.SBQQ__Discount__c = null;
                                            objNewQuoteLine.Custom_Discount__c = objNewQuoteLine.SBQQ__AdditionalDiscountAmount__c;
                                        }
                                    


                                        for(String fieldApiName :preCalculationFieldNames){
                                            List<String> fieldValue = new List<String>();
                                            fieldValue.add(String.valueOf(objNewQuoteLine.get(fieldApiName))); 
                                                                               
                                            mapPreCalculationFieldNames.put(fieldApiName,fieldValue);
                                        }
                                        for(String fieldApiName :calculatedFieldNames){
                                            List<String> fieldValue = new  List<String>();
                                            fieldValue.add(String.valueOf(objNewQuoteLine.get(fieldApiName))); 
                                                                              
                                            mapCalculatedFieldNames.put(fieldApiName,fieldValue);
                                            if(eachGroup.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment'){
                                                mapContractedFieldNames.put(fieldApiName,String.valueOf(objNewQuoteLine.get(fieldApiName)));
                                            }
                                        }
                                        
                                    }
                                    else if(eachGroup.SBQQ__Number__c == 5) {
                                        if(eachQuoteLine.Year_5_List_Price__c== null || eachQuoteLine.Year_5_List_Price__c== 0){
                                            objNewQuoteLine.SBQQ__ListPrice__c = eachQuoteLine.SBQQ__ListPrice__c ;
                                        }
                                        else {
                                            objNewQuoteLine.SBQQ__ListPrice__c = eachQuoteLine.Year_5_List_Price__c;
                                        }
                                        
                                        // objNewQuoteLine.SBQQ__Quantity__c = eachQuoteLine.Year_5_Quantity__c;
                                        if(eachGroup.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment'  ){
                                            if(eachQuoteLine.SBQQ__UpgradedSubscription__c != null){
                                                //upGradedSubsID.add(eachQuoteLine.SBQQ__UpgradedSubscription__c);
                                                objNewQuoteLine.SBQQ__PriorQuantity__c = eachQuoteLine.Year_5_Prior_Quantity_X__c;
                                            }
                                        }
                                       
                                        if(eachQuoteLine.Year_5_Quantity__c == null){                                            
                                            objNewQuoteLine.SBQQ__Quantity__c = eachQuoteLine.Year_5_Effective_Quantity__c;
                                        }
                                         else {
                                              objNewQuoteLine.SBQQ__Quantity__c = eachQuoteLine.Year_5_Quantity__c;
                                        }
                                        objNewQuoteLine.SBQQ__ProratedListPrice__c = objNewQuoteLine.SBQQ__ListPrice__c;
                                        objNewQuoteLine.SBQQ__ProrateMultiplier__c = 1;
                                        objNewQuoteLine.SBQQ__StartDate__c = (eachQuoteLine.Year_5_Start_Date__c!= null ? eachQuoteLine.Year_5_Start_Date__c : eachGroup.SBQQ__Quote__r.Effective_Year_5_Start_Date__c);
                                        objNewQuoteLine.SBQQ__EndDate__c = (eachQuoteLine.Year_5_End_Date__c!= null ? eachQuoteLine.Year_5_End_Date__c : eachGroup.SBQQ__Quote__r.Effective_Year_5_End_Date__c);
                                        
                                        objNewQuoteLine.SBQQ__Discount__c=eachQuoteLine.Year_5_Discount__c;
                                        objNewQuoteLine.Overage_Fee__c = eachQuoteLine.Year_5_Overage_Fee__c;
                                        objNewQuoteLine.Previous_Default_Overage_Fee__c = eachQuoteLine.Year_5_Previous_Default_Overage_Fee__c;
                                        objNewQuoteLine.SBQQ__PriceEditable__c = eachQuoteLine.Year_5_Price_Editable_Calculated__c;
                                        objNewQuoteLine.Rate_Parity_Quantity__c = eachQuoteLine.Year_5_Rate_Parity_Quantity__c;
                                        objNewQuoteLine.Room_Night_Net_Total__c = eachQuoteLine.Year_5_Room_Night_Net_Total__c;
                                        objNewQuoteLine.Room_Nights__c = eachQuoteLine.Year_5_Room_Nights_RFPs__c;
                                        objNewQuoteLine.Event_Registration_Quantity__c = eachQuoteLine.Year_5_Event_Registration_Quantity__c;
                                        objNewQuoteLine.Brand__c = eachQuoteLine.Y05Brand__c;
                                        objNewQuoteLine.Property__c = eachQuoteLine.Y05Property__c;
                                        objNewQuoteLine.Discount_Schedule_Quantity__c = eachQuoteLine.Year_5_Discount_Schedule_Quantity__c;
                                        objNewQuoteLine.Total__c = eachQuoteLine.Y05Total__c;
                                        objNewQuoteLine.SBQQ__Optional__c = boolTrueVal;                                        
                                       
                                        if(eachQuoteLine.SBQQ__UpgradedSubscription__c != null) {
                                            objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_5_Net_Price_X__c;
                                        }                                        
                                        else if(objNewQuoteLine.SBQQ__Bundled__c ||
                                                (eachQuoteLine.Year_5_Effective_Amount__c == null || 
                                                eachQuoteLine.Year_5_Effective_Amount__c == 0 || 
                                                eachQuoteLine.Year_5_Effective_Quantity__c == null || 
                                                eachQuoteLine.Year_5_Effective_Quantity__c== 0 )){
                                            objNewQuoteLine.SBQQ__NetPrice__c = 0;                                            
                                        }
                                        else  if(eachQuoteLine.SBQQ__PricingMethod__c == 'Block' || eachQuoteLine.SBQQ__DiscountScheduleType__c == 'Slab'){
                                            if(eachQuoteLine.Year_5_Net_Amount__c != null){
                                                objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_5_Net_Amount__c;
                                            }
                                            else {
                                                objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_5_Effective_Amount__c;
                                            }
                                        }
                                        else if(eachQuoteLine.Year_5_Effective_Quantity__c!= null && 
                                                eachQuoteLine.Year_5_Effective_Quantity__c!= 0) {
                                            objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_5_Effective_Amount__c / eachQuoteLine.Year_5_Effective_Quantity__c;
                                        }
                                        else {
                                            objNewQuoteLine.SBQQ__NetPrice__c = eachQuoteLine.Year_5_Net_Price__c;
                                        }                                       


                                        objNewQuoteLine.SBQQ__RegularPrice__c = objNewQuoteLine.SBQQ__ListPrice__c;
                                        objNewQuoteLine.SBQQ__CustomerPrice__c = objNewQuoteLine.SBQQ__NetPrice__c;
                                        objNewQuoteLine.SBQQ__SpecialPrice__c = eachQuoteLine.SBQQ__ListPrice__c;

                                        if(objNewQuoteLine.SBQQ__ListPrice__c != 0 && objNewQuoteLine.SBQQ__ListPrice__c != null){
                                            objNewQuoteLine.Discount_Type__c = '%';
                                            objNewQuoteLine.SBQQ__AdditionalDiscountAmount__c = null;
                                            objNewQuoteLine.SBQQ__Discount__c= ((objNewQuoteLine.SBQQ__ListPrice__c - objNewQuoteLine.SBQQ__NetPrice__c)/objNewQuoteLine.SBQQ__ListPrice__c) * 100;
                                            objNewQuoteLine.Custom_Discount__c = objNewQuoteLine.SBQQ__Discount__c;
                                        }
                                        else {
                                            objNewQuoteLine.Discount_Type__c = 'Amt.';
                                            objNewQuoteLine.SBQQ__AdditionalDiscountAmount__c = (0 - objNewQuoteLine.SBQQ__NetPrice__c);
                                            objNewQuoteLine.SBQQ__Discount__c = null;
                                            objNewQuoteLine.Custom_Discount__c = objNewQuoteLine.SBQQ__AdditionalDiscountAmount__c;
                                        }
                                    

                                        for(String fieldApiName :preCalculationFieldNames){
                                            List<String> fieldValue = new List<String>();
                                            fieldValue.add(String.valueOf(objNewQuoteLine.get(fieldApiName))); 
                                                                             
                                            mapPreCalculationFieldNames.put(fieldApiName,fieldValue);
                                        }
                                        for(String fieldApiName :calculatedFieldNames){
                                            List<String> fieldValue = new  List<String>();
                                            fieldValue.add(String.valueOf(objNewQuoteLine.get(fieldApiName))); 
                                                                               
                                            mapCalculatedFieldNames.put(fieldApiName,fieldValue);
                                            if(eachGroup.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment'){
                                                mapContractedFieldNames.put(fieldApiName,String.valueOf(objNewQuoteLine.get(fieldApiName)));
                                            }
                                        }
                                    }  

                                    quoteLineObject.insertOnNextCurrentYear = false;
                                    quoteLineObject.preCalculationFieldValueMap = mapPreCalculationFieldNames;
                                    quoteLineObject.contractedFieldValueMap = mapContractedFieldNames;
                                    quoteLineObject.calculatedFieldValueMap = mapCalculatedFieldNames;
                                    objNewQuoteLine.jsonString__c =  JSON.serialize(quoteLineObject);
                                    lstNewQuoteLines.add(objNewQuoteLine);
                                }
                            }
                        }
                    }

                    if(!lstNewQuoteLines.isEmpty()){
                        try {
                           // lstNewQuoteLines = CloneQuoteWithContractGroups.getPriorQuantityForSubscription(upGradedSubsID,lstNewQuoteLines,Integer.valueOf(objSingleNewQuote.Current_Year__c));
                            insert lstNewQuoteLines;
                           // Database.SaveResult[] lstQuoteLines = Database.insert(lstNewQuoteLines,false);
                            Map<Id,List<SBQQ__QuoteLine__c>> mapGroupListPrice =  new Map<Id,List<SBQQ__QuoteLine__c>>();
                           // List<SBQQ__QuoteLine__c> lstRequiredByPopulate = new List<SBQQ__QuoteLine__c>();
                            
                            for(SBQQ__QuoteLine__c lstItr : lstNewQuoteLines){
                                List<SBQQ__QuoteLine__c> lstPricing = new List<SBQQ__QuoteLine__c>();
                                if(mapGroupListPrice.containsKey(lstItr.SBQQ__Group__c)){
                                    lstPricing = mapGroupListPrice.get(lstItr.SBQQ__Group__c);
                                    lstPricing.add(lstItr);
                                    mapGroupListPrice.put(lstItr.SBQQ__Group__c,lstPricing);
                                }
                                else {
                                    lstPricing.add(lstItr);
                                    mapGroupListPrice.put(lstItr.SBQQ__Group__c,lstPricing);
                                }
                                
                                String mapKey = lstItr.Cloned_from_Quote_Line__c + ''+lstItr.SBQQ__Group__c + ''+lstItr.SBQQ__Quote__c;
                                mapRequiredBy.put(mapKey,lstItr);
                            }
                           
                            for(SBQQ__QuoteLineGroup__c lstItr : lstQuoteLineGroups){
                                if(mapGroupListPrice.containsKey(lstItr.Id)){
                                    List<SBQQ__QuoteLine__c> lstPricing = mapGroupListPrice.get(lstItr.Id);
                                    Decimal listTotal = 0;
                                    Decimal customerTotal = 0;
                                    Decimal netTotal = 0;
                                    for( SBQQ__QuoteLine__c eachLineItr : lstPricing){                                    
                                        listTotal += (eachLineItr.SBQQ__ListPrice__c == null ? 0: eachLineItr.SBQQ__ListPrice__c);
                                        customerTotal += (eachLineItr.SBQQ__CustomerPrice__c == null ? 0: eachLineItr.SBQQ__CustomerPrice__c);
                                        netTotal += (eachLineItr.SBQQ__NetTotal__c == null ? 0: eachLineItr.SBQQ__NetTotal__c);
                                    }
                                    lstItr.SBQQ__ListTotal__c = listTotal;
                                    lstItr.SBQQ__CustomerTotal__c = customerTotal;
                                    lstItr.SBQQ__NetTotal__c = netTotal;

                                }
                            } 
                            Database.SaveResult[] lstQuoteLineGroupsResult = Database.update(lstQuoteLineGroups,false);
                            for(SBQQ__QuoteLine__c lstItr :  lstNewQuoteLines){
                                if(lstItr.Cloned_from_Quote_Line__c!=null && lstItr.SBQQ__RequiredBy__c!=null ){                                   
                                    String mapKey = lstItr.SBQQ__RequiredBy__c + ''+lstItr.SBQQ__Group__c + ''+lstItr.SBQQ__Quote__c;
                                    if(lstItr.Id!= null){
                                        if(mapRequiredBy.containsKey(mapKey)){
                                            lstItr.SBQQ__RequiredBy__c = mapRequiredBy.get(mapKey).Id;
                                        }
                                    }
                                    else {
                                        System.debug('Quote LIne not inserted.. Cloned from  Quote is-- > ' + lstItr.SBQQ__Quote__c);
                                    }
                                    
                                }
                                CventMyd_QuoteLineObject quoteLineObjectwithJSON =  (CventMyd_QuoteLineObject)JSON.deserialize(lstItr.jsonString__c,CventMyd_QuoteLineObject.class);
                                String mapKey = lstItr.SBQQ__Quote__c + '' + lstItr.SBQQ__Product__c;
                                if(mapClonedFromIds.containsKey(mapKey)){
                                    if(lstItr.SBQQ__Group__r.SBQQ__Number__c != 1){
                                        quoteLineObjectwithJSON.clonedFromQleIds = mapClonedFromIds.get(mapKey);
                                    }
                                    else {
                                        quoteLineObjectwithJSON.clonedFromQleIds = new List<String>();
                                    }
                                }
                                lstItr.jsonString__c =  JSON.serialize(quoteLineObjectwithJSON); 
                            }
                            Database.SaveResult[] lstRequiredByPopulateResult = Database.update(lstNewQuoteLines,false);

                        } catch(Exception e) {
                            System.debug('Error Line Occurred-->'+e.getLineNumber());
                            System.debug('Message Occurred-->'+e.getMessage());
                            System.debug('Cause' + e.getCause());
                        }
                    }
                }

                // for non variable 
                else{
                    List<SBQQ__QuoteLine__c> lstNewQuoteLines = new List<SBQQ__QuoteLine__c>();
                    for(SBQQ__Quote__c eachNewQuote : lstNewQuotes) {
                        if(mapIdOldQuote_lstQuoteLines.containsKey(eachNewQuote.Cloned_from_Quote__c)) {
                            for(SBQQ__QuoteLine__c eachQuoteLine : mapIdOldQuote_lstQuoteLines.get(eachNewQuote.Cloned_from_Quote__c)) {
                                SBQQ__QuoteLine__c objNewQuoteLine = new SBQQ__QuoteLine__c();
                                objNewQuoteLine = eachQuoteLine.clone(boolpreserveId, boolisDeepClone, boolpreserveReadonlyTimestamps, boolpreserveAutonumber);

                                objNewQuoteLine.SBQQ__Quote__c = eachNewQuote.Id;
                                objNewQuoteLine.Cloned_from_Quote_Line__c = eachQuoteLine.Id;
                                //objNewQuoteLine.Hold_Pre_Migrated_Pricing__c = true;
                                
                                Map<String,List<String>> mapPreCalculationFieldNames = new Map<String,List<String>>();
                                Map<String,List<String>> mapCalculatedFieldNames = new Map<String,List<String>>();
                                Map<String,String> mapContractedFieldNames = new Map<String,String>();
                                
                                CventMyd_QuoteLineObject quoteLineObject = new CventMyd_QuoteLineObject();
                                quoteLineObject.quoteName = eachNewQuote.Name;
                                quoteLineObject.qleId = CventMyd_UtilityMethods.getQleId();
                                string mapKey = objNewQuoteLine.SBQQ__Quote__c + '' + eachQuoteLine.SBQQ__Product__c;
                                List<String> existinQleId = new List<String>();
                                if(mapClonedFromIds.containsKey(mapKey)){
                                    existinQleId = mapClonedFromIds.get(mapKey);
                                    existinQleId.add(quoteLineObject.qleId);
                                }
                                else {                                       
                                    existinQleId.add(quoteLineObject.qleId);
                                }

                                mapClonedFromIds.put(mapKey, existinQleId); 

                                if(String.isNotBlank(eachQuoteLine.jsonString__c)) {
                                    String clonedFromQleId = eachQuoteLine.jsonString__c.substringAfter('"qleId":"');
                                    clonedFromQleId = clonedFromQleId.subStringBefore('"');
                                    quoteLineObject.clonedFromQleIds = new List<String>{
                                        clonedFromQleId
                                    };
                                }

                                quoteLineObject.insertedWithApex = true;

                                objNewQuoteLine.SBQQ__ListPrice__c = eachQuoteLine.SBQQ__ListPrice__c;
                               
                                objNewQuoteLine.SBQQ__PriorQuantity__c = eachQuoteLine.SBQQ__PriorQuantity__c;
                                objNewQuoteLine.SBQQ__Quantity__c = eachQuoteLine.SBQQ__Quantity__c;                                   
                                objNewQuoteLine.SBQQ__Discount__c = eachQuoteLine.SBQQ__Discount__c;
                                objNewQuoteLine.Custom_Discount__c = eachQuoteLine.Custom_Discount__c;                                        
                                objNewQuoteLine.Brand__c           = eachQuoteLine.Y01Brand__c;
                                objNewQuoteLine.Property__c        = eachQuoteLine.Y01Property__c;
                                objNewQuoteLine.Total__c           = eachQuoteLine.Y01Total__c;
                                objNewQuoteLine.SBQQ__Optional__c = boolFalseVal;
                                objNewQuoteLine.SBQQ__StartDate__c = (eachQuoteLine.SBQQ__EffectiveStartDate__c!= null ? eachQuoteLine.SBQQ__EffectiveStartDate__c : eachNewQuote.Effective_Year_1_Start_Date__c);
                                objNewQuoteLine.SBQQ__EndDate__c = (eachQuoteLine.SBQQ__EffectiveEndDate__c!= null ? eachQuoteLine.SBQQ__EffectiveEndDate__c : eachNewQuote.Effective_Year_1_End_Date__c);

                                for(String fieldApiName :preCalculationFieldNames){
                                        List<String> fieldValue = new List<String>();
                                        fieldValue.add(String.valueOf(objNewQuoteLine.get(fieldApiName))); 
                                        mapPreCalculationFieldNames.put(fieldApiName,fieldValue);
                                }
                                for(String fieldApiName :calculatedFieldNames){
                                        List<String> fieldValue = new  List<String>();
                                        fieldValue.add(String.valueOf(objNewQuoteLine.get(fieldApiName))); 
                                        mapCalculatedFieldNames.put(fieldApiName,fieldValue);
                                        if(eachNewQuote.SBQQ__Type__c == 'Amendment'){
                                            mapContractedFieldNames.put(fieldApiName,String.valueOf(objNewQuoteLine.get(fieldApiName)));
                                        }
                                }
                                quoteLineObject.insertOnNextCurrentYear = false;
                                quoteLineObject.preCalculationFieldValueMap = mapPreCalculationFieldNames;
                                quoteLineObject.contractedFieldValueMap = mapContractedFieldNames;
                                quoteLineObject.calculatedFieldValueMap = mapCalculatedFieldNames;
                                objNewQuoteLine.jsonString__c =  JSON.serialize(quoteLineObject);
                                lstNewQuoteLines.add(objNewQuoteLine);
                            }
                        }  
                    }
                    if(!lstNewQuoteLines.isEmpty()){
                        try {
                            
                            Database.SaveResult[] lsr = Database.insert(lstNewQuoteLines,false);
                            for(SBQQ__QuoteLine__c lstItr : lstNewQuoteLines){
                                String mapKey = lstItr.Cloned_from_Quote_Line__c + ''+lstItr.SBQQ__Quote__c;
                                mapRequiredBy.put(mapKey,lstItr);
                            }
                            for(SBQQ__QuoteLine__c lstItr :  lstNewQuoteLines){
                                if(lstItr.Cloned_from_Quote_Line__c!=null && lstItr.SBQQ__RequiredBy__c!=null ){
                                    String mapKey = lstItr.SBQQ__RequiredBy__c + ''+lstItr.SBQQ__Quote__c;
                                    lstItr.SBQQ__RequiredBy__c = mapRequiredBy.get(mapKey).Id;
                                }
                                CventMyd_QuoteLineObject quoteLineObjectwithJSON =  (CventMyd_QuoteLineObject)JSON.deserialize(lstItr.jsonString__c,CventMyd_QuoteLineObject.class);
                                String mapKey = lstItr.SBQQ__Quote__c + '' + lstItr.SBQQ__Product__c;
                                if(mapClonedFromIds.containsKey(mapKey)){
                                    if(lstItr.SBQQ__Group__r.SBQQ__Number__c != 1){
                                        quoteLineObjectwithJSON.clonedFromQleIds = mapClonedFromIds.get(mapKey);
                                    }
                                    else {
                                        quoteLineObjectwithJSON.clonedFromQleIds = new List<String>();
                                    }
                                }
                                lstItr.jsonString__c =  JSON.serialize(quoteLineObjectwithJSON);
                            }
                            Database.SaveResult[] lsrlstRequiredByPopulate = Database.update(lstNewQuoteLines,false);
                        }
                        catch (Exception e){
                            System.debug('Error Occurred-->'+e.getMessage());
                        }
                    }
                }
            }
        }
    }
       
    global void finish(Database.BatchableContext BC) {       
            System.debug('*************Batch Execution Finish*******************');      
    }


    public static List<SBQQ__QuoteLine__c>  getPriorQuantityForSubscription (Set<ID> subRecords, List<SBQQ__QuoteLine__c> lstAmendmentLines,Integer currentYear){
        List<SBQQ__Subscription__c> lstSubRecord = [SELECT Id,
                                                  Year_2_Quantity_X__c,
                                                  Year_2_Effective_Quantity_X__c,
                                                  Year_3_Quantity_X__c,
                                                  Year_3_Effective_Quantity_X__c,
                                                  Year_4_Quantity_X__c,
                                                  Year_4_Effective_Quantity_X__c,
                                                  Year_5_Quantity_X__c,
                                                  Year_5_Effective_Quantity_X__c
                                             FROM SBQQ__Subscription__c 
                                            WHERE Id IN : subRecords];

        Map<Id,SBQQ__Subscription__c> mapSubRecord  = new Map<Id,SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c lstItr : lstSubRecord){
            mapSubRecord.put(lstItr.Id,lstItr);
        }
        for (SBQQ__QuoteLine__c lstItr : lstAmendmentLines){
            if(mapSubRecord.containsKey(lstItr.SBQQ__UpgradedSubscription__c)){
                SBQQ__Subscription__c subRecord = mapSubRecord.get(lstItr.SBQQ__UpgradedSubscription__c);
                Integer selYear = Integer.valueOf(lstItr.Quote_Line_Term__c - currentYear) + 1;
                if(selYear  == 2 ){
                    if(subRecord.Year_2_Quantity_X__c == 0 && subRecord.Year_2_Quantity_X__c!=null){
                        lstItr.SBQQ__PriorQuantity__c = subRecord.Year_2_Effective_Quantity_X__c;
                    }
                    else {
                        lstItr.SBQQ__PriorQuantity__c = subRecord.Year_2_Quantity_X__c;
                    }
                   
                }
                else if(selYear == 3){
                    if(subRecord.Year_3_Quantity_X__c == 0 && subRecord.Year_3_Quantity_X__c!= null){
                        lstItr.SBQQ__PriorQuantity__c = subRecord.Year_3_Effective_Quantity_X__c;
                    }
                    else {
                        lstItr.SBQQ__PriorQuantity__c = subRecord.Year_3_Quantity_X__c;
                    }
                 
                }
                else if(selYear== 4 ){
                    if(subRecord.Year_4_Quantity_X__c == 0 && subRecord.Year_4_Quantity_X__c!= null){
                        lstItr.SBQQ__PriorQuantity__c = subRecord.Year_4_Effective_Quantity_X__c;
                    }
                    else {
                        lstItr.SBQQ__PriorQuantity__c = subRecord.Year_4_Quantity_X__c;
                    }
                }
                else if(selYear == 5){
                    if(subRecord.Year_5_Quantity_X__c == 0 && subRecord.Year_5_Quantity_X__c!= null){
                        lstItr.SBQQ__PriorQuantity__c = subRecord.Year_5_Effective_Quantity_X__c;
                    }
                    else {
                        lstItr.SBQQ__PriorQuantity__c = subRecord.Year_5_Quantity_X__c;
                    }
                }
            }
        }
        return lstAmendmentLines;
    }
    
     public static List<String> getListOfStrings(CventMyd_Settings__mdt settingsRecord, String fieldApiName) {
        String stringToSplit = (String)settingsRecord.get(fieldApiName);
        List<String> stringList = new List<String>();
        Integer i = 0;

        if(stringToSplit != null) {

            while(i < stringToSplit.length()) {
                        
                if(stringToSplit.charAt(i) == 10 || stringToSplit.charAt(i) == 13) {

                    stringToSplit = stringToSplit.replace(stringToSplit.subString(i,i+1),';');

                    Integer lengthBefore = stringToSplit.length();

                    stringToSplit = stringToSplit.replace(';;',';');

                    Integer lengthAfter = stringToSplit.length();

                    if(lengthAfter == lengthBefore) {i = i - 1;}

                }

                i = i + 1; 

            }

            stringList = stringToSplit.split(';');

        }

        if(stringList.isEmpty()) {stringList.add('');}
        
        return stringList;

    }   

}