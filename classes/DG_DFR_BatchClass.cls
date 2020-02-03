global class DG_DFR_BatchClass implements Database.Batchable<sObject> , Schedulable{
        global void execute(SchedulableContext sc)
        {
            if(!Test.isRunningTest()){
            Database.executeBatch(new DG_DFR_BatchClass());
            }
        }
    

    Set<Id> oppIdSet = new Set<Id>();
    list<Id> listConId = new list<Id>();
    list<Opportunity> listOpp = new list<Opportunity>();
    map<ID, String> mapOppFunnel = new map<ID, String>();
    public static map<String, DFR_Field_Mapping__c > getDFRFieldMapping(){
        map<String, DFR_Field_Mapping__c > mapFieldMapping = new map<String, DFR_Field_Mapping__c >();  
        if(!test.isRunningTest()){ 
            mapFieldMapping = DFR_Field_Mapping__c.getAll();
        }else{
            mapFieldMapping.put('1',new DFR_Field_Mapping__c(Name='1', Product__c='CrowdCompass', Lead__c='CC_Behavior_Score__c', Contact__c='CC_Behavior_Score__c', Inquiry__c='Inquiry_Behavior_Score__c', SAL__c='MQL_Behavior_Score__c', MQL__c='SAL_Behavior_Score__c', SQL__c='SQL_Behavior_Score__c', OS__c='OS_Behavior_Score__c', EOL__c='EOL_Behavior_Score__c'));

            mapFieldMapping.put('2',new DFR_Field_Mapping__c(Name='2', Product__c='Enterprise', Lead__c='Enterprise_Behavior_Score__c', Contact__c='Enterprise_Behavior_Score__c', Inquiry__c='Inquiry_Behavior_Score__c', MQL__c='MQL_Behavior_Score__c', SAL__c='SAL_Behavior_Score__c', SQL__c='SQL_Behavior_Score__c', OS__c='OS_Behavior_Score__c', EOL__c='EOL_Behavior_Score__c'));

            mapFieldMapping.put('3',new DFR_Field_Mapping__c(Name='3', Product__c='Event', Lead__c='Event_Behavior_Score__c', Contact__c='Event_Behavior_Score__c', Inquiry__c='Inquiry_Behavior_Score__c', MQL__c='MQL_Behavior_Score__c', SAL__c='SAL_Behavior_Score__c', SQL__c='SQL_Behavior_Score__c', OS__c='OS_Behavior_Score__c', EOL__c='EOL_Behavior_Score__c'));

            mapFieldMapping.put('4',new DFR_Field_Mapping__c(Name='4', Product__c='Inquisium', Lead__c='Survey_Behavior_Score__c', Contact__c='Survey_Behavior_Score__c', Inquiry__c='Inquiry_Behavior_Score__c', MQL__c='MQL_Behavior_Score__c', SAL__c='SAL_Behavior_Score__c', SQL__c='SQL_Behavior_Score__c', OS__c='OS_Behavior_Score__c', EOL__c='EOL_Behavior_Score__c'));

            mapFieldMapping.put('5',new DFR_Field_Mapping__c(Name='5', Product__c='Venue Sourcing', Lead__c='Planner_Behavior_Score__c', Contact__c='Planner_Behavior_Score__c', Inquiry__c='Inquiry_Behavior_Score__c', MQL__c='MQL_Behavior_Score__c', SAL__c='SAL_Behavior_Score__c', SQL__c='SQL_Behavior_Score__c', OS__c='OS_Behavior_Score__c', EOL__c='EOL_Behavior_Score__c'));

            mapFieldMapping.put('6',new DFR_Field_Mapping__c(Name='6', Product__c='Hospitality Cloud', Lead__c='Supplier_Behavior_Score__c', Contact__c='Supplier_Behavior_Score__c', Inquiry__c='Inquiry_Behavior_Score__c', MQL__c='MQL_Behavior_Score__c', SAL__c='SAL_Behavior_Score__c', SQL__c='SQL_Behavior_Score__c', OS__c='OS_Behavior_Score__c', EOL__c='EOL_Behavior_Score__c'));
        }
        return mapFieldMapping;
    }
    public static map<String, map<String, map<String,String>>> ContactStageFieldMapping(){
        map<String, Schema.SObjectField> mapCSchema = Schema.SObjectType.Contact.fields.getMap();
        map<String, Schema.SObjectField> mapDFSchema = Schema.SObjectType.Demand_Funnel__c.fields.getMap();
        map<String, DFR_Field_Mapping__c> mapCSFieldMapping = getDFRFieldMapping();
        map<String, DFRProductStatusField__c> mapCSProduct = getDFRProductStatusField();
        map<String, map<String, map<String,String>>> mapProdStageFieldMapping = new map<String, map<String, map<String,String>>>();        
        for(String prod : mapCSProduct.keySet()){
            map<String, map<String,String>> mapStageFieldMapping = new map<String, map<String,String>>();
            for(String k : mapCSFieldMapping.keySet()){  
                DFR_Field_Mapping__c fmap = mapCSFieldMapping.get(k);
                if(prod == fmap.Product__c){
                    if(mapCSchema.containsKey(fmap.Contact__c)){ //check if Lead field API name is valid
                        String InquiryField = fmap.Inquiry__c;                    
                        String MQLField = fmap.MQL__c;
                        String SALField = fmap.SAL__c;
                        String SQLField = fmap.SQL__c;  
                        String OSField = fmap.OS__c;
                        String EOLField = fmap.EOL__c;

                        //Inquiry Field Mapping
                        if(mapDFSchema.containsKey(InquiryField)){ //check if DFR field API name is valid
                            String vStage = 'Inquiry';
                            String vField = InquiryField;

                            map<String, String> mapFieldMapping = new map<String, String>();
                            if(mapStageFieldMapping.containsKey(vStage)){
                            mapFieldMapping = mapStageFieldMapping.get(vStage);
                            mapFieldMapping.put(fmap.Contact__c,vField);
                            }else{
                            mapFieldMapping.put(fmap.Contact__c,vField);
                            }
                            mapStageFieldMapping.put(vStage,mapFieldMapping);
                        }
                        //MQL Field Mapping
                        if(mapDFSchema.containsKey(MQLField)){ //check if DFR field API name is valid
                            String vStage = 'MQL';
                            String vField = MQLField;
                            map<String, String> mapFieldMapping = new map<String, String>();
                            if(mapStageFieldMapping.containsKey(vStage)){
                            mapFieldMapping = mapStageFieldMapping.get(vStage);
                            mapFieldMapping.put(fmap.Contact__c,vField);
                            }else{
                            mapFieldMapping.put(fmap.Contact__c,vField);
                            }
                            mapStageFieldMapping.put(vStage,mapFieldMapping);
                        }
                        //SAL Field Mapping
                        if(mapDFSchema.containsKey(SALField)){ //check if DFR field API name is valid
                            String vStage = 'SAL';
                            String vField = SALField;
                            map<String, String> mapFieldMapping = new map<String, String>();
                            if(mapStageFieldMapping.containsKey(vStage)){
                            mapFieldMapping = mapStageFieldMapping.get(vStage);
                            mapFieldMapping.put(fmap.Contact__c,vField);
                            }else{
                            mapFieldMapping.put(fmap.Contact__c,vField);
                            }
                            mapStageFieldMapping.put(vStage,mapFieldMapping);
                        }
                        //SQL Field Mapping
                        if(mapDFSchema.containsKey(SQLField)){ //check if DFR field API name is valid
                            String vStage = 'SQL';
                            String vField = SQLField;
                            map<String, String> mapFieldMapping = new map<String, String>();
                            if(mapStageFieldMapping.containsKey(vStage)){
                            mapFieldMapping = mapStageFieldMapping.get(vStage);
                            mapFieldMapping.put(fmap.Contact__c,vField);
                            }else{
                            mapFieldMapping.put(fmap.Contact__c,vField);
                            }
                            mapStageFieldMapping.put(vStage,mapFieldMapping);
                        }
                        //OS Field Mapping
                        if(mapDFSchema.containsKey(OSField)){ //check if DFR field API name is valid
                            String vStage = 'Opportunity Stage';
                            String vField = OSField;
                            map<String, String> mapFieldMapping = new map<String, String>();
                            if(mapStageFieldMapping.containsKey(vStage)){
                            mapFieldMapping = mapStageFieldMapping.get(vStage);
                            mapFieldMapping.put(fmap.Contact__c,vField);
                            }else{
                            mapFieldMapping.put(fmap.Contact__c,vField);
                            }
                            mapStageFieldMapping.put(vStage,mapFieldMapping);
                        }    
                        //EOL Field Mapping
                        if(mapDFSchema.containsKey(EOLField)){ //check if DFR field API name is valid
                            String vStage = 'EOL';
                            String vField = EOLField;
                            map<String, String> mapFieldMapping = new map<String, String>();
                            if(mapStageFieldMapping.containsKey(vStage)){
                            mapFieldMapping = mapStageFieldMapping.get(vStage);
                            mapFieldMapping.put(fmap.Contact__c,vField);
                            }else{
                            mapFieldMapping.put(fmap.Contact__c,vField);
                            }
                            mapStageFieldMapping.put(vStage,mapFieldMapping);
                        }                          
                    }
                }
            }
            mapProdStageFieldMapping.put(Prod, mapStageFieldMapping);
        }
        return mapProdStageFieldMapping;
    }    
    public static map<String, DFRProductStatusField__c > getDFRProductStatusField(){
        map<String, Schema.SObjectField> mapLSchema = Schema.SObjectType.Lead.fields.getMap();
        map<String, Schema.SObjectField> mapCSchema = Schema.SObjectType.Contact.fields.getMap();
        map<String, DFRProductStatusField__c > cs = new map<String, DFRProductStatusField__c >();  
        map<String, DFRProductStatusField__c> csValid = new map<String, DFRProductStatusField__c >();
        if(!test.isRunningTest()){ 
            cs = DFRProductStatusField__c.getAll();
        }else{
            cs.put('CrowdCompass',new DFRProductStatusField__c(Name='CrowdCompass', Lead_Status_Field__c='CC_Lead_Status__c', Contact_Status_Field__c='CC_Contact_Status__c'));
            cs.put('Enterprise',new DFRProductStatusField__c(Name='Enterprise', Lead_Status_Field__c='SMM_Lead_Status__c', Contact_Status_Field__c='SMM_Contact_Status__c'));
            cs.put('Event',new DFRProductStatusField__c(Name='Event', Lead_Status_Field__c='Event_Lead_Status__c', Contact_Status_Field__c='Event_Contact_Status__c'));
            cs.put('Inquisium',new DFRProductStatusField__c(Name='Inquisium', Lead_Status_Field__c='Inquisium_Lead_Status__c', Contact_Status_Field__c='Survey_Contact_Status__c'));
            cs.put('Venue Sourcing',new DFRProductStatusField__c(Name='Venue Sourcing', Lead_Status_Field__c='CSN_P_Lead_Status__c', Contact_Status_Field__c='CSN_P_Contact_Status__c'));
            cs.put('Hospitality Cloud',new DFRProductStatusField__c(Name='Hospitality Cloud', Lead_Status_Field__c='CSN_S_Lead_Status__c', Contact_Status_Field__c='CSNS_Contact_Status__c'));
        }
        for(String k : cs.keySet()){
            DFRProductStatusField__c psf = cs.get(k);
            if(mapLSchema.containsKey(psf.Lead_Status_Field__c) && mapCSchema.containsKey(psf.Contact_Status_Field__c)){
                csValid.put(k, psf);
            }
        }
        return csValid;
    }
    Date dateCriterias;   global Database.QueryLocator start(Database.BatchableContext BC){
        dateCriterias = System.Today().addDays(-1);
        String query='SELECT Id,IsClosed,IsWon,AccountId,Contact_Associated__c FROM Opportunity WHERE License_Type__c = '+'\''+'Cvent Connect'+'\''+' AND Contact_Associated__c!=NULL  AND LastModifiedDate >:dateCriterias';  //DWFProduct__c //AND DWFProduct__c!=NULL
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        System.debug('scope**********'+scope);
        oppIdSet = new Set<Id>();
        For(OpportunityLineItem oppLineItem : [SELECT Id,OpportunityId FROM OpportunityLineItem WHERE Product_Name__c!='Cvent Connect-Extended Registration' AND Product_Name__c!='Cvent Connect-Standard Registration' AND OpportunityId IN : scope])
        {
            oppIdSet.add(oppLineItem.OpportunityId);
        }
        System.debug('oppIdSet*****'+oppIdSet);
        for (Opportunity tn : scope){
            if(oppIdSet.contains(tn.Id)){
                //system.debug('### DWF Product (Insert): ' + tn.DWFProduct__c);
                system.debug('### Contact_Associated__c (Insert): ' + tn.Contact_Associated__c);
                //if (tn.Contact_Associated__c <> Null && tn.DWFProduct__c <> Null) {
                    listConId.add(tn.Contact_Associated__c);
                    if(tn.IsClosed == true){
                        if(tn.IsWon == true){
                            //Won Opp
                            listOpp.add(tn);
                            mapOppFunnel.put(tn.Id,'EOL-Won');
                        }else{
                            //Lost Opp
                            listOpp.add(tn);
                            mapOppFunnel.put(tn.Id,'EOL-Lost');
                        }
                    }else{
                        //OS
                        listOpp.add(tn);
                        mapOppFunnel.put(tn.Id,'Opportunity Stage');
                    }
                //} 
            }
        }
        system.debug('### DFR listOpp: ' + listOpp.size());
        system.debug('### DFR mapOppFunnel: ' + mapOppFunnel.size());
        if(!listOpp.IsEmpty()){
            map<String, DFRProductStatusField__c > mapDFRProductStatusField = getDFRProductStatusField();
            map<String, map<String, map<String,String>>> ProductContactStageFieldMapping = ContactStageFieldMapping();
            //Retrieve Contact field values related Contact_Associated__c
            String vContactFieldList = '';
            set<String> setContactField = new set<String>();
            for(String vProduct : ProductContactStageFieldMapping.keySet()){
                map<String, map<String,String>> ContactStageFieldMapping = ProductContactStageFieldMapping.get(vProduct);     
                map<String, String> mapEOLFieldMapping = ContactStageFieldMapping.get('EOL');
                for(String k:mapEOLFieldMapping.keySet()){  
                    setContactField.add(k);
                }        
            }
            for(String f : setContactField){  
                try {  
                vContactFieldList = vContactFieldList + f + ',';
                } catch(exception e) {}  
            }
            map<id, Contact> mapContact = new map<id, Contact>();
            if(vContactFieldList <> ''){
                try{
                    String soql = 'Select ' + vContactFieldList + ' DFR_StatusUpdateDate__c, id from Contact where id in :listConId';
                    list<Contact> listCon = Database.Query(soql);
                    if(listCon.size() > 0){
                    for(Contact c1 : listCon){
                    mapContact.put(c1.id,c1);
                    }
                    }
                } catch(exception e) {}  
            }
            //Mapping Contact/Product/DFR
            map<id, map<String, Demand_Funnel__c>> mapContactProdDFR = new map<id, map<String, Demand_Funnel__c>>();  
            map<Id, Demand_Funnel__c> mapOIDDFR = new map<Id, Demand_Funnel__c>();        
            for(Demand_Funnel__c d : [Select d.Contact__c, d.Opportunity__c, d.id, d.Pre_Opportunity_Status__c, d.Product__c From Demand_Funnel__c d 
            where d.Opportunity__c in :listOpp OR (d.Contact__c in :mapContact.keySet() AND d.Opportunity__c = Null AND d.Pre_Opportunity_Close_Reason__c = Null)]){
                map<String, Demand_Funnel__c> mapProdDFR = new map<String, Demand_Funnel__c>();
                if(mapContactProdDFR.containsKey(d.Contact__c)){          
                    mapProdDFR = mapContactProdDFR.get(d.Contact__c);
                }
                mapProdDFR.put(d.Product__c, d);
                mapContactProdDFR.put(d.Contact__c, mapProdDFR);
                if(d.Opportunity__c <> Null){
                    mapOIDDFR.put(d.Opportunity__c, d);
                }
            }
            //Mapping use to update existing DFR
            map<id,Demand_Funnel__c> mapDFRUpdate = new map<id,Demand_Funnel__c>();
            //List use to insert new DFRs
            list<Demand_Funnel__c> listDFRInsert = new list<Demand_Funnel__c>();
            //Mapping use to update Contacts
            map<id,Contact> mapContactUpdate = new map<id,Contact>();
            //Update/Insert DFR
            for(Opportunity o : listOpp){
                Contact c = mapContact.get(o.Contact_Associated__c);        
                String vFunnel = mapOppFunnel.get(o.Id);
                //String vProduct = o.DWFProduct__c;
                //system.debug('### DWFProduct: ' + o.DWFProduct__c);
                //if(mapDFRProductStatusField.containsKey(vProduct)){
                  //  String vStatusField = mapDFRProductStatusField.get(vProduct).Contact_Status_Field__c;
                   /* map<String, map<String,String>> ContactStageFieldMapping = ProductContactStageFieldMapping.get(vProduct);
                    map<String, String> mapInquiryFieldMapping = ContactStageFieldMapping.get('Inquiry');
                    map<String, String> mapMQLFieldMapping = ContactStageFieldMapping.get('MQL');
                    map<String, String> mapSALFieldMapping = ContactStageFieldMapping.get('SAL');
                    map<String, String> mapSQLFieldMapping = ContactStageFieldMapping.get('SQL');  
                    map<String, String> mapOSFieldMapping = ContactStageFieldMapping.get('Opportunity Stage');   
                    map<String, String> mapEOLFieldMapping = ContactStageFieldMapping.get('EOL');*/
                    Demand_Funnel__c DFR;
                    map<String, Demand_Funnel__c> mapProdDFR = new map<String, Demand_Funnel__c>();
                    if(mapOIDDFR.containsKey(o.Id)){  DFR = mapOIDDFR.get(o.Id);
                    }else if(mapContactProdDFR.containsKey(o.Contact_Associated__c)){ mapProdDFR = mapContactProdDFR.get(o.Contact_Associated__c);                                 /* if(mapProdDFR.containsKey(o.DWFProduct__c)){DFR = mapProdDFR.get(o.DWFProduct__c); }*/ }
                    if(DFR <> Null){ mapDFRUpdate.put(DFR.id, new Demand_Funnel__c(Id=DFR.id));   
                        mapDFRUpdate.get(DFR.id).put('Opportunity__c',o.Id);                         /* mapDFRUpdate.get(DFR.id).put('Product__c',vProduct);  */                  if(vFunnel == 'Opportunity Stage'){                            String vStage = 'Opportunity Stage';                            mapDFRUpdate.get(DFR.id).put('OS_Date_Entered__c',date.today());
                           /* for(String k:mapOSFieldMapping.keySet()){                              try {                            mapDFRUpdate.get(DFR.id).put(mapOSFieldMapping.get(k),c.get(k));                            } catch(exception e) {}                              } */                           mapDFRUpdate.get(DFR.id).put('OS_Entered_From__c', vStage);
                            if(DFR.Pre_Opportunity_Status__c == 'SQL'){                            mapDFRUpdate.get(DFR.id).put('SQL_Date_Exited__c',Date.Today());                            mapDFRUpdate.get(DFR.id).put('SQL_Exited_To__c',vStage);                            mapDFRUpdate.get(DFR.id).put('OS_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                            }else if(DFR.Pre_Opportunity_Status__c == 'SAL' || DFR.Pre_Opportunity_Status__c == 'SGL'){                            mapDFRUpdate.get(DFR.id).put('SAL_Date_Exited__c',Date.Today());                            mapDFRUpdate.get(DFR.id).put('SAL_Exited_To__c',vStage);                            mapDFRUpdate.get(DFR.id).put('OS_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                            }else if(DFR.Pre_Opportunity_Status__c == 'MQL' || DFR.Pre_Opportunity_Status__c == 'MRL'){                            mapDFRUpdate.get(DFR.id).put('MQL_Date_Exited__c',Date.Today());                            mapDFRUpdate.get(DFR.id).put('MQL_Exited_To__c',vStage);                            mapDFRUpdate.get(DFR.id).put('OS_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                            }else if(DFR.Pre_Opportunity_Status__c == 'Inquiry'){                            mapDFRUpdate.get(DFR.id).put('Inquiry_Date_Exited__c',Date.Today());                            mapDFRUpdate.get(DFR.id).put('Inquiry_Exited_To__c',vStage);                            mapDFRUpdate.get(DFR.id).put('OS_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                            }mapDFRUpdate.get(DFR.id).put('Pre_Opportunity_Status__c',vStage);                          }else if(vFunnel == 'EOL-Won' || vFunnel == 'EOL-Lost'){                            String vStage = 'EOL';                            mapDFRUpdate.get(DFR.id).put('EOL_Date_Entered__c',date.today());                       
                            /*for(String k:mapEOLFieldMapping.keySet()){                                try {                                mapDFRUpdate.get(DFR.id).put(mapEOLFieldMapping.get(k),c.get(k));                                } catch(exception e) {}  
                            }*/
                            if(vFunnel == 'EOL-Lost'){try{mapDFRUpdate.get(DFR.id).put('Opp_Stage_Before_Lost__c', o.StageName);
                                }catch(exception e){}                            }                            if(DFR.Pre_Opportunity_Status__c == 'Opportunity Stage'){                                                        mapDFRUpdate.get(DFR.id).put('OS_Date_Exited__c',Date.Today());                            mapDFRUpdate.get(DFR.id).put('OS_Exited_To__c', vStage);                            mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);                            }else if(DFR.Pre_Opportunity_Status__c == 'SQL'){                            mapDFRUpdate.get(DFR.id).put('SQL_Date_Exited__c',Date.Today());                            mapDFRUpdate.get(DFR.id).put('SQL_Exited_To__c',vStage);                            mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);                            }else if(DFR.Pre_Opportunity_Status__c == 'SAL' || DFR.Pre_Opportunity_Status__c == 'SGL'){                            mapDFRUpdate.get(DFR.id).put('SAL_Date_Exited__c',Date.Today());                            mapDFRUpdate.get(DFR.id).put('SAL_Exited_To__c',vStage);                            mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);                            }else if(DFR.Pre_Opportunity_Status__c == 'MQL' || DFR.Pre_Opportunity_Status__c == 'MRL'){                            mapDFRUpdate.get(DFR.id).put('MQL_Date_Exited__c',Date.Today());                            mapDFRUpdate.get(DFR.id).put('MQL_Exited_To__c',vStage);                            mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);                            }else if(DFR.Pre_Opportunity_Status__c == 'Inquiry'){                            mapDFRUpdate.get(DFR.id).put('Inquiry_Date_Exited__c',Date.Today());                            mapDFRUpdate.get(DFR.id).put('Inquiry_Exited_To__c',vStage);                            mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);                            }                                mapDFRUpdate.get(DFR.id).put('Pre_Opportunity_Status__c',vStage);                            system.debug('### EOL_Entered_From__c: ' + mapDFRUpdate.get(DFR.id).EOL_Entered_From__c);
                        }      
                    }else{// Contacts that move stages without active DFR
                        DFR = new Demand_Funnel__c();
                        DFR.Account__c = o.AccountId;
                        DFR.Contact__c = o.Contact_Associated__c;
                        DFR.Opportunity__c = o.Id;  
                       // DFR.Product__c = vProduct;
                        if(vFunnel == 'Opportunity Stage'){
                        String vStage = 'Opportunity Stage';
                        DFR.OS_Date_Entered__c = Date.Today();
                        DFR.OS_Entered_From__c = vStage;
                       /* for(String k:mapOSFieldMapping.keySet()){  
                        try {
                        DFR.put(mapOSFieldMapping.get(k),c.get(k));
                        } catch(exception e) {}  
                        }*/
                        DFR.Pre_Opportunity_Status__c = vStage;  
                        }else if(vFunnel == 'EOL-Won' || vFunnel == 'EOL-Lost'){
                        String vStage = 'EOL';
                        DFR.EOL_Date_Entered__c = Date.Today();
                        DFR.EOL_Entered_From__c = vStage;
                        /*for(String k:mapEOLFieldMapping.keySet()){  
                        try {
                        DFR.put(mapEOLFieldMapping.get(k),c.get(k));
                        } catch(exception e) {}  
                        }*/
                        DFR.Pre_Opportunity_Status__c = vStage;            
                        }
                        listDFRInsert.add(DFR);    
                    }         
                    //Update Contact Product Status
                    try{
                        mapContactUpdate.put(o.Contact_Associated__c, new Contact(Id=o.Contact_Associated__c));   
                        if(vFunnel == 'EOL-Won'){
                        //mapContactUpdate.get(o.Contact_Associated__c).put(vStatusField, 'Closed Won');
                        mapContactUpdate.get(o.Contact_Associated__c).put('DFR_StatusUpdateDate__c', datetime.now());
                        } else if(vFunnel == 'EOL-Lost'){
                        //mapContactUpdate.get(o.Contact_Associated__c).put(vStatusField, 'Closed Lost');
                        mapContactUpdate.get(o.Contact_Associated__c).put('DFR_StatusUpdateDate__c', datetime.now());
                        } else if(vFunnel == 'Opportunity Stage'){
                       // mapContactUpdate.get(o.Contact_Associated__c).put(vStatusField, 'Open Opportunity');
                        mapContactUpdate.get(o.Contact_Associated__c).put('DFR_StatusUpdateDate__c', datetime.now());
                        }
                    }catch(exception e){}
                //}                
            }
            if (listDFRInsert.size()> 0){
                Database.SaveResult[] srInsert = Database.insert(listDFRInsert, false);  
                System.debug('DFR Insert List*********'+srInsert);
                for (Database.SaveResult sr : srInsert) {
                    if (!sr.isSuccess()) {             
                        for(Database.Error err : sr.getErrors()) {
                        System.debug('DFR Creation Error: ' + err.getMessage() + ' * ' + err.getFields() + ' * ' + err.getStatusCode());
                        }
                    }
                }
            }
            if (mapDFRUpdate.size()> 0){ 
                Database.SaveResult[] srUpdate = Database.update(mapDFRUpdate.values(),false);
                System.debug('DFR Update List*********'+srUpdate);
                for (Database.SaveResult sr : srUpdate) {
                    if (!sr.isSuccess()) {  
                        System.debug('DFR Update Error: ' + sr.getId());            
                        for(Database.Error err : sr.getErrors()) {                   
                            System.debug('DFR Update Error: ' + err.getMessage() + ' * ' + err.getFields() + ' * ' + err.getStatusCode());
                        }
                    }
                }
            }

            if (mapContactUpdate.size()> 0){
                Database.SaveResult[] srUpdate = Database.update(mapContactUpdate.values(), false);  
                System.debug('Contact Update List*********'+srUpdate);
                for (Database.SaveResult sr : srUpdate) {
                    if (!sr.isSuccess()) {        
                        System.debug('Contact Update Error: ' + sr.getId());       
                        for(Database.Error err : sr.getErrors()) {                  
                            System.debug('Contact Update Error: ' + err.getMessage() + ' * ' + err.getFields() + ' * ' + err.getStatusCode());
                        }
                    }
                }
            }
        }
    }
    global void finish(Database.BatchableContext BC){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        String[] toAddresses = new String[] {'SBhalla@cvent.com'};  
        mail.setToAddresses(toAddresses);  
        mail.setSubject('Cvent Connect Batch Status ');  
        //mail.setPlainTextBody('The batch Apex job processed ' + a.JobItemsProcessed);
        String body='<span style='+'\''+'color:#1F497D; font-size:11.0pt;font-family:"Calibri",sans-serif;'+'\''+'><b>Hi Sunny,  </b></br></br>Cvent Connect Batch Successful<b>Thanks,</br>'+'Salesforce'+'<o:p></o:p></b></span>';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
    }
}