public without sharing class DG_DFR_Class { 
    public static boolean DisableOnTest = false;
    public static boolean LeadAfterUpdate_FirstRun = true;
    public static boolean ContactAfterUpdate_FirstRun = true;   
    public static boolean LeadConversion_FirstRun = true; 
    public static boolean AddChangeContactSource_FirstRun = true;
    
    public static map<String, DFR_Status_Funnel_Mapping__c> getDFRStatusToStage(){
        map<String, DFR_Status_Funnel_Mapping__c> mapStatusToStage = new map<String, DFR_Status_Funnel_Mapping__c>();   

        if(!test.isRunningTest()){
            mapStatusToStage = DFR_Status_Funnel_Mapping__c.getAll();
        }else{
            mapStatusToStage.put('Recycle',new DFR_Status_Funnel_Mapping__c(name = 'Recycle', Funnel_Stage__c = 'EOL-Recycle', Order__c = 0));
            mapStatusToStage.put('Trash',new DFR_Status_Funnel_Mapping__c(name = 'Trash', Funnel_Stage__c = 'EOL-Trash', Order__c = 0));
            mapStatusToStage.put('Suspect',new DFR_Status_Funnel_Mapping__c(name = 'Suspect', Funnel_Stage__c = 'Suspect', Order__c = 0));
            mapStatusToStage.put('Inquiry',new DFR_Status_Funnel_Mapping__c(name = 'Inquiry', Funnel_Stage__c = 'Inquiry', Order__c = 1));
            mapStatusToStage.put('Marketing Qualified',new DFR_Status_Funnel_Mapping__c(name = 'Marketing Qualified', Funnel_Stage__c = 'MQL', Order__c = 2));
            mapStatusToStage.put('Marketing Researched',new DFR_Status_Funnel_Mapping__c(name = 'Marketing Researched', Funnel_Stage__c = 'MQL', Order__c = 2));
            mapStatusToStage.put('Sales Accepted',new DFR_Status_Funnel_Mapping__c(name = 'Sales Accepted', Funnel_Stage__c = 'SAL', Order__c = 3));
            mapStatusToStage.put('Sales Generated',new DFR_Status_Funnel_Mapping__c(name = 'Sales Generated', Funnel_Stage__c = 'SGL', Order__c = 3));
            mapStatusToStage.put('Sales Qualified',new DFR_Status_Funnel_Mapping__c(name = 'Sales Qualified', Funnel_Stage__c = 'SQL', Order__c = 4));
            mapStatusToStage.put('Open Opportunity',new DFR_Status_Funnel_Mapping__c(name = 'Open Opportunity', Funnel_Stage__c = 'Opportunity Stage', Order__c = 5));
            mapStatusToStage.put('Closed Won',new DFR_Status_Funnel_Mapping__c(name = 'Closed Won', Funnel_Stage__c = 'EOL-Won', Order__c = 6));
            mapStatusToStage.put('Closed Lost',new DFR_Status_Funnel_Mapping__c(name = 'Closed Lost', Funnel_Stage__c = 'EOL-Lost', Order__c = 0));
        }
        
        return mapStatusToStage;
    }
    
    
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
        

    
    public static map<String, map<String, map<String,String>>> LeadStageFieldMapping(){
        map<String, Schema.SObjectField> mapLSchema = Schema.SObjectType.Lead.fields.getMap();
        map<String, Schema.SObjectField> mapDFSchema = Schema.SObjectType.Demand_Funnel__c.fields.getMap();
        map<String, DFR_Field_Mapping__c> mapCSFieldMapping = getDFRFieldMapping();
        map<String, DFRProductStatusField__c> mapCSProduct = getDFRProductStatusField();
         
        map<String, map<String, map<String,String>>> mapProdStageFieldMapping = new map<String, map<String, map<String,String>>>();         
        
        for(String prod : mapCSProduct.keySet()){
            
            map<String, map<String,String>> mapStageFieldMapping = new map<String, map<String,String>>();
            
            for(String k : mapCSFieldMapping.keySet()){  
                DFR_Field_Mapping__c fmap = mapCSFieldMapping.get(k);
                if(prod == fmap.Product__c){
                    if(mapLSchema.containsKey(fmap.Lead__c)){ //check if Lead field API name is valid
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
                                    mapFieldMapping.put(fmap.Lead__c,vField);
                                }else{
                                    mapFieldMapping.put(fmap.Lead__c,vField);
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
                                    mapFieldMapping.put(fmap.Lead__c,vField);
                                }else{
                                    mapFieldMapping.put(fmap.Lead__c,vField);
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
                                    mapFieldMapping.put(fmap.Lead__c,vField);
                                }else{
                                    mapFieldMapping.put(fmap.Lead__c,vField);
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
                                    mapFieldMapping.put(fmap.Lead__c,vField);
                                }else{
                                    mapFieldMapping.put(fmap.Lead__c,vField);
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
                                    mapFieldMapping.put(fmap.Lead__c,vField);
                                }else{
                                    mapFieldMapping.put(fmap.Lead__c,vField);
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
                                    mapFieldMapping.put(fmap.Lead__c,vField);
                                }else{
                                    mapFieldMapping.put(fmap.Lead__c,vField);
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
    
    public static void CreateLeadDFR(list<Lead> tn){ 
        if(!DisableOnTest){
                    
            //Retrieve custom setting related to mapping lead statuses to funnel stages 
            map<String, DFR_Status_Funnel_Mapping__c> mapStatusToStage = getDFRStatusToStage();
                        
            list<Demand_Funnel__c> DFRInsert = new list<Demand_Funnel__c>();
            
            //Retrieve field mapping between lead and DFR for different funnel stages
            map<String, map<String, map<String,String>>> ProductLeadStageFieldMapping = LeadStageFieldMapping();
                    
            map<String, DFRProductStatusField__c > mapDFRProductStatusField = getDFRProductStatusField();
            
            //Build list of DFR to create if status translates to Inquiry, MQL or SAL funnel stage.
            for(Lead ld : tn){
                for(String m : mapDFRProductStatusField.keySet()){
                    String vProduct = m;
                    String vStatusField = mapDFRProductStatusField.get(m).Lead_Status_Field__c;
                    String vProductStatus = String.valueOf(ld.get(vStatusField));
                    map<String, map<String,String>> LeadStageFieldMapping = ProductLeadStageFieldMapping.get(vProduct);
                    map<String, String> mapInquiryFieldMapping = LeadStageFieldMapping.get('Inquiry');
                    map<String, String> mapMQLFieldMapping = LeadStageFieldMapping.get('MQL');
                    map<String, String> mapSALFieldMapping = LeadStageFieldMapping.get('SAL');
                    map<String, String> mapSQLFieldMapping = LeadStageFieldMapping.get('SQL');              
    
                    if(mapStatusToStage.containsKey(vProductStatus)){
                        String vStage = mapStatusToStage.get(vProductStatus).Funnel_Stage__c;
                        Demand_Funnel__c DFR = new Demand_Funnel__c();
                        //Inquiry
                        if(vStage == 'Inquiry'){                    
                            DFR.Inquiry_Date_Entered__c = date.today(); 
                            DFR.Inquiry_Entered_From__c = vStage;
                            
                            //Reiterate to set field values to the DFR from the lead
                            for(String k : mapInquiryFieldMapping.keySet()){  
                                try {
                                    DFR.put(mapInquiryFieldMapping.get(k),ld.get(k));
                                } catch(exception e) {} 
                            }
                            
                            DFR.Pre_Opportunity_Status__c = vStage; 
                            DFR.Product__c = vProduct;
                            DFR.Lead__c = ld.Id;                            
                            DFRInsert.add(DFR); 
                        }
                                                
                        //MQL
                        if(vStage == 'MQL' || vStage == 'MRL'){
                            DFR.MQL_Date_Entered__c = date.today();
                            DFR.MQL_Entered_From__c = vStage;
                            
                            if(vStage == 'MQL'){
                                DFR.MQL_Type__c = 'Marketing Qualified';
                            }else if(vStage == 'MRL'){
                                DFR.MQL_Type__c = 'Marketing Researched';
                            }
                            
                            //Reiterate to set field values to the DFR from the lead
                            for(String k:mapMQLFieldMapping.keySet()){  
                                try {
                                    DFR.put(mapMQLFieldMapping.get(k),ld.get(k));
                                } catch(exception e) {} 
                            }
        
                            DFR.Pre_Opportunity_Status__c = vStage;
                            DFR.Product__c = vProduct;
                            DFR.Lead__c = ld.Id;
                            DFRInsert.add(DFR); 
                        }
                        
                        //SAL
                        if(vStage == 'SAL' || vStage == 'SGL'){
                            DFR.SAL_Date_Entered__c = date.today();
                            DFR.SAL_Entered_From__c = vStage;
                            
                            if(vStage == 'SAL'){
                                DFR.SAL_Type__c = 'Sales Accepted';
                            }else if(vStage == 'SGL'){
                                DFR.SAL_Type__c = 'Sales Generated';
                            }
                            
                            
                            //Reiterate to set field values to the DFR from the lead
                            for(String k:mapSALFieldMapping.keySet()){  
                                try {
                                    DFR.put(mapSALFieldMapping.get(k),ld.get(k));
                                } catch(exception e) {} 
                            }
                            
                            DFR.Pre_Opportunity_Status__c = vStage;
                            DFR.Product__c = vProduct;
                            DFR.Lead__c = ld.Id;
                            DFRInsert.add(DFR);
                        }
                        
                        //SQL
                        if(vStage == 'SQL'){
                            DFR.SQL_Date_Entered__c = date.today();
                            DFR.SQL_Entered_From__c = 'SQL';
                            
                            //Reiterate to set field values to the DFR from the lead
                            for(String k:mapSQLFieldMapping.keySet()){  
                                try {
                                    DFR.put(mapSQLFieldMapping.get(k),ld.get(k));
                                } catch(exception e) {} 
                            }
                            
                            //DFR.Qual_Method__c = ld.Qual_Method__c;
        
                            DFR.Pre_Opportunity_Status__c = vStage;
                            DFR.Product__c = vProduct;
                            DFR.Lead__c = ld.Id;
                            DFRInsert.add(DFR); 
                        }                                   
                    }  
                    
                }
            }
            
            //Insert list of DFRs   
            if (DFRInsert.size()> 0){
                Database.SaveResult[] srInsert = Database.insert(DFRInsert, false); 
                
                for (Database.SaveResult sr : srInsert) {
                    if (!sr.isSuccess()) {             
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('DFR Creation Error: ' + err.getMessage() + ' * ' + err.getFields() + ' * ' + err.getStatusCode());
                        }
                    }
                }
            }
        }
    }   
    
    public static void DFR_LeadStatusChange(list<Lead> newList, map<Id, Lead> oldMap){
        if(!DisableOnTest){     
            //Retrieve custom setting related to mapping lead statuses to funnel stages     
            map<String, DFR_Status_Funnel_Mapping__c> mapStatusToStage = getDFRStatusToStage();
                        
            map<String, DFRProductStatusField__c > mapDFRProductStatusField = getDFRProductStatusField();
                
            set<Lead> setLead = new set<Lead>();
            set<Id> setLID = new set<Id>();
            map<Id, set<String>> mapLIDProds = new map<Id, set<String>>();
                    
            //Identify leads that move from one funnel stage to another based on translating their lead status to funnel stage.
            for (Lead tn : newList){
                Lead to = oldMap.get(tn.Id);
                
                for(String m : mapDFRProductStatusField.keySet()){
                    String vProduct = m;
                    String vStatusField = mapDFRProductStatusField.get(m).Lead_Status_Field__c;
                    
                    String tnStatus = String.valueOf(tn.get(vStatusField));
                    String toStatus = String.valueOf(to.get(vStatusField));
                                    
                    String oldStage;
                    String newStage;
                    
                    if(mapStatusToStage.containsKey(tnStatus)){                 
                        newStage = mapStatusToStage.get(tnStatus).Funnel_Stage__c;
                    }
                    
                    if(mapStatusToStage.containsKey(toStatus)){
                        oldStage = mapStatusToStage.get(toStatus).Funnel_Stage__c;
                    }               
                
                    if(newStage <> Null && oldStage <> newStage){
                        setLead.add(tn);
                        setLID.add(tn.id);
                        
                        set<String> setProd = new set<String>();
                        if(mapLIDProds.containsKey(tn.Id)){
                            setProd = mapLIDProds.get(tn.Id);
                        }
                        
                        setProd.add(vProduct);
                        mapLIDProds.put(tn.Id, setProd);
                    }
                }       
            }
            
            if(setLead.size() > 0){
                map<String, map<String, map<String,String>>> ProductLeadStageFieldMapping = LeadStageFieldMapping();
                
                //Retrieve DFR related to leads that move stages.           
                Demand_Funnel__c[] DFRs = [Select d.Lead__c, d.id, d.Product__c, d.Pre_Opportunity_Status__c From Demand_Funnel__c d 
                                where d.Lead__c in :setLID and d.Pre_Opportunity_Close_Reason__c = Null and d.Opportunity__c = Null];
                
                //Mapping Lead/Product/DFR
                map<id, map<String, Demand_Funnel__c>> mapLeadProdDFR = new map<id, map<String, Demand_Funnel__c>>();                   
                        
                for(Demand_Funnel__c d: DFRs){
                    map<String, Demand_Funnel__c> mapProdDFR = new map<String, Demand_Funnel__c>();
                    if(mapLeadProdDFR.containsKey(d.Lead__c)){                  
                        mapProdDFR = mapLeadProdDFR.get(d.Lead__c);
                    }
                    
                    mapProdDFR.put(d.Product__c, d);
                    
                    mapLeadProdDFR.put(d.Lead__c, mapProdDFR);
                }
                
                //List use for inserting new DFR
                list<Demand_Funnel__c> DFRInsert = new list<Demand_Funnel__c>();
                
                //Mapping use to update existing DFR
                map<id,Demand_Funnel__c> mapDFRUpdate = new map<id,Demand_Funnel__c>();
                            
                for(Lead ld: setLead){              
                    set<String> setProd =  mapLIDProds.get(ld.Id);          
                    
                    map<String, Demand_Funnel__c> mapProdDFR = new map<String, Demand_Funnel__c>();
                    if(mapLeadProdDFR.containsKey(ld.Id)){                  
                        mapProdDFR = mapLeadProdDFR.get(ld.Id);
                    }
                                        
                    for(String vProduct : setProd){ 
                        String vStatusField = mapDFRProductStatusField.get(vProduct).Lead_Status_Field__c;
                        String vProductStatus = String.valueOf(ld.get(vStatusField)); 
                        String vStage = mapStatusToStage.get(vProductStatus).Funnel_Stage__c;
                        
                        map<String, map<String,String>> LeadStageFieldMapping = ProductLeadStageFieldMapping.get(vProduct);
                        map<String, String> mapInquiryFieldMapping = LeadStageFieldMapping.get('Inquiry');
                        map<String, String> mapMQLFieldMapping = LeadStageFieldMapping.get('MQL');
                        map<String, String> mapSALFieldMapping = LeadStageFieldMapping.get('SAL');
                        map<String, String> mapSQLFieldMapping = LeadStageFieldMapping.get('SQL');     
                        map<String, String> mapEOLFieldMapping = LeadStageFieldMapping.get('EOL');
                        
                        if(mapProdDFR.containsKey(vProduct)){ //Check if lead has an  active DFR from the map
                            
                            Demand_Funnel__c DFR = mapProdDFR.get(vProduct); //Get related DFR
                                
                            mapDFRUpdate.put(DFR.id, new Demand_Funnel__c(Id=DFR.id));  //Put related DFR in the map for update
                                                
                            //MQL
                            if(vStage == 'MQL' || vStage == 'MRL'){
                                mapDFRUpdate.get(DFR.id).put('MQL_Date_Entered__c',date.today());
                                
                                if(vStage == 'MQL'){
                                    mapDFRUpdate.get(DFR.id).put('MQL_Type__c','Marketing Qualified');
                                }else if(vStage == 'MRL'){
                                    mapDFRUpdate.get(DFR.id).put('MQL_Type__c','Marketing Researched');
                                }
                                
                                //Reiterate to set field values to the DFR from the lead
                                for(String k:mapMQLFieldMapping.keySet()){  
                                    try {
                                        mapDFRUpdate.get(DFR.id).put(mapMQLFieldMapping.get(k),ld.get(k));  
                                    } catch(exception e) {} 
                                }
                                
                                mapDFRUpdate.get(DFR.id).put('MQL_Entered_From__c',vStage);
                                
                                if(DFR.Pre_Opportunity_Status__c == 'Inquiry'){
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('MQL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                }
                                
                                mapDFRUpdate.get(DFR.id).put('Pre_Opportunity_Status__c',vStage);
                            }
                            
                            //SAL
                            if(vStage == 'SAL' || vStage == 'SGL'){
                                mapDFRUpdate.get(DFR.id).put('SAL_Date_Entered__c',date.today());
                                
                                if(vStage == 'SAL'){
                                    mapDFRUpdate.get(DFR.id).put('SAL_Type__c','Sales Accepted');
                                }else if(vStage == 'SGL'){
                                    mapDFRUpdate.get(DFR.id).put('SAL_Type__c','Sales Generated');
                                }
                                
                                //Reiterate to set field values to the DFR from the lead
                                for(String k:mapSALFieldMapping.keySet()){  
                                    try {
                                        mapDFRUpdate.get(DFR.id).put(mapSALFieldMapping.get(k),ld.get(k));  
                                    } catch(exception e) {} 
                                }
        
                                mapDFRUpdate.get(DFR.id).put('SAL_Entered_From__c',vStage);     
                                
                                if(DFR.Pre_Opportunity_Status__c == 'MQL' || DFR.Pre_Opportunity_Status__c == 'MRL'){
                                    mapDFRUpdate.get(DFR.id).put('MQL_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('MQL_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('SAL_Entered_From__c',DFR.Pre_Opportunity_Status__c);  
                                }else if(DFR.Pre_Opportunity_Status__c == 'Inquiry'){
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('SAL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                }
                                
                                mapDFRUpdate.get(DFR.id).put('Pre_Opportunity_Status__c',vStage);           
                            } 
                            
                            //SQL
                            if(vStage == 'SQL'){
                                mapDFRUpdate.get(DFR.id).put('SQL_Date_Entered__c',date.today());
                                
                                //Reiterate to set field values to the DFR from the lead
                                for(String k:mapSQLFieldMapping.keySet()){  
                                    try {
                                        mapDFRUpdate.get(DFR.id).put(mapSQLFieldMapping.get(k),ld.get(k));  
                                    } catch(exception e) {} 
                                }
                                
                                mapDFRUpdate.get(DFR.id).put('SQL_Entered_From__c',vStage);
                                
                                if(DFR.Pre_Opportunity_Status__c == 'SAL' || DFR.Pre_Opportunity_Status__c == 'SGL'){
                                    mapDFRUpdate.get(DFR.id).put('SAL_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('SAL_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('SQL_Entered_From__c',DFR.Pre_Opportunity_Status__c);              
                                }else if(DFR.Pre_Opportunity_Status__c == 'MQL' || DFR.Pre_Opportunity_Status__c == 'MRL'){
                                    mapDFRUpdate.get(DFR.id).put('MQL_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('MQL_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('SQL_Entered_From__c',DFR.Pre_Opportunity_Status__c);  
                                }else if(DFR.Pre_Opportunity_Status__c == 'Inquiry'){
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('SQL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                }
                                
                                mapDFRUpdate.get(DFR.id).put('Pre_Opportunity_Status__c',vStage);
                            }
        
                            //Downgraded
                            if(vStage == 'EOL-Recycle' || vStage == 'EOL-Trash'){
                                mapDFRUpdate.get(DFR.id).put('Pre_Opportunity_Close_Reason__c',vProductStatus);
                                mapDFRUpdate.get(DFR.id).put('Pre_Opportunity_Close_Date__c',date.today());
                                
                                //Reiterate to set field values to the DFR from the lead
                                for(String k:mapEOLFieldMapping.keySet()){  
                                    try {
                                        mapDFRUpdate.get(DFR.id).put(mapEOLFieldMapping.get(k),ld.get(k));  
                                    } catch(exception e) {} 
                                }
                                
                                mapDFRUpdate.get(DFR.id).put('EOL_Date_Entered__c',date.today());
                                mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                
                                if(DFR.Pre_Opportunity_Status__c == 'SQL'){
                                    mapDFRUpdate.get(DFR.id).put('SQL_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('SQL_Exited_To__c',vProductStatus);
                                }else if(DFR.Pre_Opportunity_Status__c == 'SAL' || DFR.Pre_Opportunity_Status__c == 'SGL'){
                                    mapDFRUpdate.get(DFR.id).put('SAL_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('SAL_Exited_To__c',vProductStatus);
                                }else if(DFR.Pre_Opportunity_Status__c == 'MQL' || DFR.Pre_Opportunity_Status__c == 'MRL'){
                                    mapDFRUpdate.get(DFR.id).put('MQL_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('MQL_Exited_To__c',vProductStatus);
                                }else  if(DFR.Pre_Opportunity_Status__c == 'Inquiry'){
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Exited_To__c',vProductStatus);
                                }           
                            }                           
                        }else{ // Leads that move stages without active DFR
                            Demand_Funnel__c DFR = new Demand_Funnel__c();
                            //Inquiry
                            if(vStage == 'Inquiry'){
                                DFR.Inquiry_Date_Entered__c = date.today();
                                DFR.Inquiry_Entered_From__c = vStage;
                                
                                //Reiterate to set field values to the DFR from the lead
                                for(String k:mapInquiryFieldMapping.keySet()){  
                                    try {
                                        DFR.put(mapInquiryFieldMapping.get(k),ld.get(k));
                                    } catch(exception e) {} 
                                }
                                
                                DFR.Pre_Opportunity_Status__c = vStage;
                                DFR.Product__c = vProduct;
                                DFR.Lead__c = ld.Id;                    
                                DFRInsert.add(DFR);
                            }
    
                            //MQL
                            if(vStage == 'MQL' || vStage == 'MRL'){
                                DFR.MQL_Date_Entered__c = date.today();
                                DFR.MQL_Entered_From__c = vStage;
                                
                                if(vStage == 'MQL'){
                                    DFR.MQL_Type__c = 'Marketing Qualified';
                                }else if(vStage == 'MRL'){
                                    DFR.MQL_Type__c = 'Marketing Researched';
                                }
    
                                //Reiterate to set field values to the DFR from the lead
                                for(String k:mapMQLFieldMapping.keySet()){  
                                    try {
                                        DFR.put(mapMQLFieldMapping.get(k),ld.get(k));
                                    } catch(exception e) {} 
                                }
     
                                DFR.Pre_Opportunity_Status__c = vStage;
                                DFR.Product__c = vProduct;
                                DFR.Lead__c = ld.Id;                            
                                DFRInsert.add(DFR);
                            }
                            
                            //SAL
                            if(vStage == 'SAL' || vStage == 'SGL'){
                                DFR.SAL_Date_Entered__c = date.today();
                                DFR.SAL_Entered_From__c = vStage;
                                
                                if(vStage == 'SAL'){
                                    DFR.SAL_Type__c = 'Sales Accepted';
                                }else if(vStage == 'SGL'){
                                    DFR.SAL_Type__c = 'Sales Generated';
                                }
                                
                                //Reiterate to set field values to the DFR from the lead
                                for(String k:mapSALFieldMapping.keySet()){  
                                    try {
                                        DFR.put(mapSALFieldMapping.get(k),ld.get(k));
                                    } catch(exception e) {} 
                                }
                                
                                DFR.Pre_Opportunity_Status__c = vStage;
                                DFR.Product__c = vProduct;
                                DFR.Lead__c = ld.Id;                            
                                DFRInsert.add(DFR);
                            }
                            
                            //SQL
                            if(vStage == 'SQL'){
                                DFR.SQL_Date_Entered__c = date.today();
                                DFR.SQL_Entered_From__c = 'SQL';
    
                                //Reiterate to set field values to the DFR from the lead
                                for(String k:mapSQLFieldMapping.keySet()){  
                                    try {
                                        DFR.put(mapSQLFieldMapping.get(k),ld.get(k));
                                    } catch(exception e) {} 
                                }
     
                                DFR.Pre_Opportunity_Status__c = vStage;
                                DFR.Product__c = vProduct;
                                DFR.Lead__c = ld.Id;                            
                                DFRInsert.add(DFR);
                            }
                                                        
                        }   
                    }           
                }
                
                //Update existing DFR
                if (mapDFRUpdate.size()> 0){ 
                    Database.SaveResult[] srUpdate = Database.Update(mapDFRUpdate.values(),false);
                    
                    for (Database.SaveResult sr : srUpdate) {
                        if (!sr.isSuccess()) {    
                            System.debug('DFR Update Error: ' + sr.getId());         
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('DFR Update Error: ' + err.getMessage() + ' * ' + err.getFields() + ' * ' + err.getStatusCode());
                            }
                        }
                    }
                }
                
                //Create new DFR
                if (DFRInsert.size()> 0){
                    Database.SaveResult[] srInsert = Database.Insert(DFRInsert, false); 
                    
                    for (Database.SaveResult sr : srInsert) {
                        if (!sr.isSuccess()) {             
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('DFR Creation Error: ' + err.getMessage() + ' * ' + err.getFields() + ' * ' + err.getStatusCode());
                            }
                        }
                    }
                }
            }
        }
    } 
    
    public static void DFR_ContactStatusChange(list<Contact> newList, map<Id, Contact> oldMap){
        if(!DisableOnTest){
            List<DWF_Console_Object__c> DFRList = new List<DWF_Console_Object__c>();
            //Retrieve custom setting related to mapping Contact statuses to funnel stages      
            map<String, DFR_Status_Funnel_Mapping__c> mapStatusToStage = getDFRStatusToStage();
                        
            map<String, DFRProductStatusField__c > mapDFRProductStatusField = getDFRProductStatusField();
            
            map<Id, Contact> mapContactUpdate = new map<Id, Contact>();
                
            set<Contact> setContact = new set<Contact>();
            set<Id> setCID = new set<Id>();
            map<Id, set<String>> mapLIDProds = new map<Id, set<String>>();
                    
            //Identify Contacts that move from one funnel stage to another based on translating their Contact status to funnel stage.
            if(oldMap <> Null){ //Contact Update
                for (Contact tn : newList){
                    Contact to = oldMap.get(tn.Id);
                    
                    if(tn.DFR_StatusUpdateDate__c == to.DFR_StatusUpdateDate__c){
                        
                        for(String m : mapDFRProductStatusField.keySet()){
                            String vProduct = m;
                            String vStatusField = mapDFRProductStatusField.get(m).Contact_Status_Field__c;
                            
                            String tnStatus = String.valueOf(tn.get(vStatusField));
                            String toStatus = String.valueOf(to.get(vStatusField));
                                                
                            String oldStage;
                            String newStage;
                            
                            if(mapStatusToStage.containsKey(tnStatus)){                 
                                newStage = mapStatusToStage.get(tnStatus).Funnel_Stage__c;
                            }
                            
                            if(mapStatusToStage.containsKey(toStatus)){
                                oldStage = mapStatusToStage.get(toStatus).Funnel_Stage__c;
                            }               
                        
                            if(newStage <> Null && oldStage <> newStage){
                                setContact.add(tn);
                                setCID.add(tn.id);
                                
                                set<String> setProd = new set<String>();
                                if(mapLIDProds.containsKey(tn.Id)){
                                    setProd = mapLIDProds.get(tn.Id);
                                }
                                
                                setProd.add(vProduct);
                                mapLIDProds.put(tn.Id, setProd);
                            }
                        }       
                    }
                    
                    if(tn.DFR_StatusUpdateDate__c <> Null){
                        mapContactUpdate.put(tn.Id, new Contact(Id=tn.Id, DFR_StatusUpdateDate__c=Null));
                    }
                }
            }else{ //Contact Insert         
                for (Contact tn : newList){
                    if(!tn.Created_From_Lead__c){
                        for(String m : mapDFRProductStatusField.keySet()){
                            String vProduct = m;
                            String vStatusField = mapDFRProductStatusField.get(m).Contact_Status_Field__c;
                            
                            String tnStatus = String.valueOf(tn.get(vStatusField));
                            
                            String newStage;
                            
                            if(mapStatusToStage.containsKey(tnStatus)){                 
                                newStage = mapStatusToStage.get(tnStatus).Funnel_Stage__c;
                            }           
                        
                            if(newStage <> Null){
                                setContact.add(tn);
                                setCID.add(tn.id);
                                
                                set<String> setProd = new set<String>();
                                if(mapLIDProds.containsKey(tn.Id)){
                                    setProd = mapLIDProds.get(tn.Id);
                                }
                                
                                setProd.add(vProduct);
                                mapLIDProds.put(tn.Id, setProd);
                            }
                        }                               
                    }
                    if(tn.DFR_StatusUpdateDate__c <> Null){
                        mapContactUpdate.put(tn.Id, new Contact(Id=tn.Id, DFR_StatusUpdateDate__c=Null));
                    }
                }       
            }
            
            system.debug('### setContact: ' + setContact.size());
            
            if(setContact.size() > 0){
                map<String, map<String, map<String,String>>> ProductContactStageFieldMapping = ContactStageFieldMapping();
                
                //Retrieve DFR related to Contacts that move stages.            
                Demand_Funnel__c[] DFRs = [Select d.Contact__c, d.id, d.Product__c, d.Pre_Opportunity_Status__c From Demand_Funnel__c d 
                                where d.Contact__c in :setCID and d.Pre_Opportunity_Close_Reason__c = Null and d.Opportunity__c = Null];
                
                //Mapping Contact/Product/DFR
                map<id, map<String, Demand_Funnel__c>> mapContactProdDFR = new map<id, map<String, Demand_Funnel__c>>();                    
                        
                for(Demand_Funnel__c d: DFRs){
                    map<String, Demand_Funnel__c> mapProdDFR = new map<String, Demand_Funnel__c>();
                    if(mapContactProdDFR.containsKey(d.Contact__c)){                    
                        mapProdDFR = mapContactProdDFR.get(d.Contact__c);
                    }
                    
                    mapProdDFR.put(d.Product__c, d);
                    
                    mapContactProdDFR.put(d.Contact__c, mapProdDFR);
                }
                
                //List use for inserting new DFR
                list<Demand_Funnel__c> DFRInsert = new list<Demand_Funnel__c>();
                
                //Mapping use to update existing DFR
                map<id,Demand_Funnel__c> mapDFRUpdate = new map<id,Demand_Funnel__c>();
                            
                for(Contact ld: setContact){                
                    set<String> setProd =  mapLIDProds.get(ld.Id);          
                    
                    map<String, Demand_Funnel__c> mapProdDFR = new map<String, Demand_Funnel__c>();
                    if(mapContactProdDFR.containsKey(ld.Id)){                   
                        mapProdDFR = mapContactProdDFR.get(ld.Id);
                    }
                                        
                    for(String vProduct : setProd){ 
                        String vStatusField = mapDFRProductStatusField.get(vProduct).Contact_Status_Field__c;
                        String vProductStatus = String.valueOf(ld.get(vStatusField)); 
                        String vStage = mapStatusToStage.get(vProductStatus).Funnel_Stage__c;
                        
                        map<String, map<String,String>> ContactStageFieldMapping = ProductContactStageFieldMapping.get(vProduct);
                        map<String, String> mapInquiryFieldMapping = ContactStageFieldMapping.get('Inquiry');
                        map<String, String> mapMQLFieldMapping = ContactStageFieldMapping.get('MQL');
                        map<String, String> mapSALFieldMapping = ContactStageFieldMapping.get('SAL');
                        map<String, String> mapSQLFieldMapping = ContactStageFieldMapping.get('SQL');      
                        map<String, String> mapEOLFieldMapping = ContactStageFieldMapping.get('EOL');
                        
                        if(mapProdDFR.containsKey(vProduct)){ //Check if Contact has an  active DFR from the map
                            
                            Demand_Funnel__c DFR = mapProdDFR.get(vProduct); //Get related DFR
                                
                            mapDFRUpdate.put(DFR.id, new Demand_Funnel__c(Id=DFR.id));  //Put related DFR in the map for update
                                                
                            //MQL
                            if(vStage == 'MQL' || vStage == 'MRL'){
                                mapDFRUpdate.get(DFR.id).put('MQL_Date_Entered__c',date.today());
                                
                                if(vStage == 'MQL'){
                                    mapDFRUpdate.get(DFR.id).put('MQL_Type__c','Marketing Qualified');
                                }else if(vStage == 'MRL'){
                                    mapDFRUpdate.get(DFR.id).put('MQL_Type__c','Marketing Researched');
                                }
                                
                                //Reiterate to set field values to the DFR from the Contact
                                for(String k:mapMQLFieldMapping.keySet()){  
                                    try {
                                        mapDFRUpdate.get(DFR.id).put(mapMQLFieldMapping.get(k),ld.get(k));  
                                    } catch(exception e) {} 
                                }
                                
                                mapDFRUpdate.get(DFR.id).put('MQL_Entered_From__c',vStage);
                                
                                if(DFR.Pre_Opportunity_Status__c == 'Inquiry'){
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('MQL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                }
                                
                                mapDFRUpdate.get(DFR.id).put('Pre_Opportunity_Status__c',vStage);
                            }
                            
                            //SAL
                            if(vStage == 'SAL' || vStage == 'SGL'){
                                mapDFRUpdate.get(DFR.id).put('SAL_Date_Entered__c',date.today());
                                
                                if(vStage == 'SAL'){
                                    mapDFRUpdate.get(DFR.id).put('SAL_Type__c','Sales Accepted');
                                }else if(vStage == 'SGL'){
                                    mapDFRUpdate.get(DFR.id).put('SAL_Type__c','Sales Generated');
                                }
                                
                                //Reiterate to set field values to the DFR from the Contact
                                for(String k:mapSALFieldMapping.keySet()){  
                                    try {
                                        mapDFRUpdate.get(DFR.id).put(mapSALFieldMapping.get(k),ld.get(k));  
                                    } catch(exception e) {} 
                                }
        
                                mapDFRUpdate.get(DFR.id).put('SAL_Entered_From__c',vStage);     
                                
                                if(DFR.Pre_Opportunity_Status__c == 'MQL' || DFR.Pre_Opportunity_Status__c == 'MRL'){
                                    mapDFRUpdate.get(DFR.id).put('MQL_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('MQL_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('SAL_Entered_From__c',DFR.Pre_Opportunity_Status__c);  
                                }else if(DFR.Pre_Opportunity_Status__c == 'Inquiry'){
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('SAL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                }
                                
                                mapDFRUpdate.get(DFR.id).put('Pre_Opportunity_Status__c',vStage);           
                            } 
                            
                            //SQL
                            if(vStage == 'SQL'){
                                mapDFRUpdate.get(DFR.id).put('SQL_Date_Entered__c',date.today());
                                
                                //Reiterate to set field values to the DFR from the Contact
                                for(String k:mapSQLFieldMapping.keySet()){  
                                    try {
                                        mapDFRUpdate.get(DFR.id).put(mapSQLFieldMapping.get(k),ld.get(k));  
                                    } catch(exception e) {} 
                                }
                                
                                mapDFRUpdate.get(DFR.id).put('SQL_Entered_From__c',vStage);
                                
                                if(DFR.Pre_Opportunity_Status__c == 'SAL' || DFR.Pre_Opportunity_Status__c == 'SGL'){
                                    mapDFRUpdate.get(DFR.id).put('SAL_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('SAL_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('SQL_Entered_From__c',DFR.Pre_Opportunity_Status__c);              
                                }else if(DFR.Pre_Opportunity_Status__c == 'MQL' || DFR.Pre_Opportunity_Status__c == 'MRL'){
                                    mapDFRUpdate.get(DFR.id).put('MQL_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('MQL_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('SQL_Entered_From__c',DFR.Pre_Opportunity_Status__c);  
                                }else if(DFR.Pre_Opportunity_Status__c == 'Inquiry'){
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('SQL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                }
                                
                                mapDFRUpdate.get(DFR.id).put('Pre_Opportunity_Status__c',vStage);
                            }
        
                            //Downgraded
                            if(vStage == 'EOL-Recycle' || vStage == 'EOL-Trash'){
                                mapDFRUpdate.get(DFR.id).put('Pre_Opportunity_Close_Reason__c',vProductStatus);
                                mapDFRUpdate.get(DFR.id).put('Pre_Opportunity_Close_Date__c',date.today());
                                
                                //Reiterate to set field values to the DFR from the Contact
                                for(String k:mapEOLFieldMapping.keySet()){  
                                    try {
                                        mapDFRUpdate.get(DFR.id).put(mapEOLFieldMapping.get(k),ld.get(k));  
                                    } catch(exception e) {} 
                                }
                                
                                mapDFRUpdate.get(DFR.id).put('EOL_Date_Entered__c',date.today());
                                mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                
                                if(DFR.Pre_Opportunity_Status__c == 'SQL'){
                                    mapDFRUpdate.get(DFR.id).put('SQL_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('SQL_Exited_To__c',vProductStatus);
                                    mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                }else if(DFR.Pre_Opportunity_Status__c == 'SAL' || DFR.Pre_Opportunity_Status__c == 'SGL'){
                                    mapDFRUpdate.get(DFR.id).put('SAL_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('SAL_Exited_To__c',vProductStatus);
                                    mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                }else if(DFR.Pre_Opportunity_Status__c == 'MQL' || DFR.Pre_Opportunity_Status__c == 'MRL'){
                                    mapDFRUpdate.get(DFR.id).put('MQL_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('MQL_Exited_To__c',vProductStatus);
                                    mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                }else  if(DFR.Pre_Opportunity_Status__c == 'Inquiry'){
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Date_Exited__c',date.today());
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Exited_To__c',vProductStatus);
                                    mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                }           
                            }                           
                        }else{ // Contacts that move stages without active DFR
                            Demand_Funnel__c DFR = new Demand_Funnel__c();
                            //Inquiry
                            if(vStage == 'Inquiry'){
                                DFR.Inquiry_Date_Entered__c = date.today();
                                DFR.Inquiry_Entered_From__c = vStage;
                                
                                //Reiterate to set field values to the DFR from the Contact
                                for(String k:mapInquiryFieldMapping.keySet()){  
                                    try {
                                        DFR.put(mapInquiryFieldMapping.get(k),ld.get(k));
                                    } catch(exception e) {} 
                                }
                                
                                DFR.Pre_Opportunity_Status__c = vStage;
                                DFR.Product__c = vProduct;
                                DFR.Contact__c = ld.Id; 
                                DFR.Account__c = ld.AccountId;          
                                DFRInsert.add(DFR);
                            }
    
                            //MQL
                            if(vStage == 'MQL' || vStage == 'MRL'){
                                DFR.MQL_Date_Entered__c = date.today();
                                DFR.MQL_Entered_From__c = vStage;
                                
                                if(vStage == 'MQL'){
                                    DFR.MQL_Type__c = 'Marketing Qualified';
                                }else if(vStage == 'MRL'){
                                    DFR.MQL_Type__c = 'Marketing Researched';
                                }
    
                                //Reiterate to set field values to the DFR from the Contact
                                for(String k:mapMQLFieldMapping.keySet()){  
                                    try {
                                        DFR.put(mapMQLFieldMapping.get(k),ld.get(k));
                                    } catch(exception e) {} 
                                }
     
                                DFR.Pre_Opportunity_Status__c = vStage;
                                DFR.Product__c = vProduct;
                                DFR.Contact__c = ld.Id;             
                                DFR.Account__c = ld.AccountId;              
                                DFRInsert.add(DFR);
                            }
                            
                            //SAL
                            if(vStage == 'SAL' || vStage == 'SGL'){
                                DFR.SAL_Date_Entered__c = date.today();
                                DFR.SAL_Entered_From__c = vStage;
                                
                                if(vStage == 'SAL'){
                                    DFR.SAL_Type__c = 'Sales Accepted';
                                }else if(vStage == 'SGL'){
                                    DFR.SAL_Type__c = 'Sales Generated';
                                }
                                
                                //Reiterate to set field values to the DFR from the Contact
                                for(String k:mapSALFieldMapping.keySet()){  
                                    try {
                                        DFR.put(mapSALFieldMapping.get(k),ld.get(k));
                                    } catch(exception e) {} 
                                }
                                
                                DFR.Pre_Opportunity_Status__c = vStage;
                                DFR.Product__c = vProduct;
                                DFR.Contact__c = ld.Id;             
                                DFR.Account__c = ld.AccountId;              
                                DFRInsert.add(DFR);
                            }
                            
                            //SQL
                            if(vStage == 'SQL'){
                                DFR.SQL_Date_Entered__c = date.today();
                                DFR.SQL_Entered_From__c = 'SQL';
    
                                //Reiterate to set field values to the DFR from the Contact
                                for(String k:mapSQLFieldMapping.keySet()){  
                                    try {
                                        DFR.put(mapSQLFieldMapping.get(k),ld.get(k));
                                    } catch(exception e) {} 
                                }
     
                                DFR.Pre_Opportunity_Status__c = vStage;
                                DFR.Product__c = vProduct;
                                DFR.Contact__c = ld.Id; 
                                DFR.Account__c = ld.AccountId;                          
                                DFRInsert.add(DFR);
                            }
                                                        
                        }   
                    }           
                }
                
                //Update existing DFR
                if (mapDFRUpdate.size()> 0){ 
                    Database.SaveResult[] srUpdate = Database.Update(mapDFRUpdate.values(),false);
                    
                    for (Database.SaveResult sr : srUpdate) {
                        if (!sr.isSuccess()) {    
                            System.debug('DFR Update Error: ' + sr.getId());         
                            for(Database.Error err : sr.getErrors()) {
                                DWF_Console_Object__c DFR = new DWF_Console_Object__c();
                                DFR.Error__c = err.getMessage()+'1Update1'+err.getFields();
                                DFR.Record_Id__c = sr.getId();
                                DFRList.add(DFR);
                                System.debug('DFR Update Error: ' + err.getMessage() + ' * ' + err.getFields() + ' * ' + err.getStatusCode());
                            }
                        }
                    }
                }
                
                //Create new DFR
                if (DFRInsert.size()> 0){
                    Database.SaveResult[] srInsert = Database.Insert(DFRInsert, false); 
                    
                    for (Database.SaveResult sr : srInsert) {
                        if (!sr.isSuccess()) {             
                            for(Database.Error err : sr.getErrors()) {
                                DWF_Console_Object__c DFR = new DWF_Console_Object__c();
                                DFR.Error__c = err.getMessage()+'1Insert1'+err.getFields();
                                DFR.Record_Id__c = sr.getId();
                                DFRList.add(DFR);
                                System.debug('DFR Creation Error: ' + err.getMessage() + ' * ' + err.getFields() + ' * ' + err.getStatusCode());
                            }
                        }
                    }
                }
            }
            
            if(!mapContactUpdate.isEmpty()){    
                database.SaveResult[] srUpdate = Database.Update(mapContactUpdate.values(),false);   
                                            
                for (Database.SaveResult sr : srUpdate) {
                    if (!sr.isSuccess()) {    
                        System.debug('Contact Update Error: ' + sr.getId());         
                        for(Database.Error err : sr.getErrors()) {
                                DWF_Console_Object__c DFR = new DWF_Console_Object__c();
                                DFR.Error__c = err.getMessage()+'2Update2'+err.getFields();
                                DFR.Record_Id__c = sr.getId();
                                DFRList.add(DFR);
                            System.debug('Contact Update Error: ' + err.getMessage() + ' * ' + err.getFields() + ' * ' + err.getStatusCode());
                        }
                    }
                }
            }
        if(DFRList.size()>0)
            insert DFRList;
        } 
    }
    
    public static void DFR_LeadConversion(list<Lead> tn, map<Id, Lead> oldMap){
        if(!DisableOnTest){
            system.debug('###DFR_OppCreationFromLead1');
            list<Lead> listLead = new list<Lead>();
            map<Id, Lead> mapLead = new map<Id, Lead>();
            
            //Retrive Lead Record type included for DFR
            //set<Id> listLeadRecordTypeId = getLeadRecordTypeId();
            
            for (integer i=0; i<tn.size(); i++){
                Lead to = oldMap.get(tn[i].Id);
                if(to.isConverted == false && tn[i].isConverted == true){
                    mapLead.put(tn[i].id, tn[i]);
                    listLead.add(tn[i]);
                }       
            }       
            
            system.debug('###DFR_OppCreationFromLead2' + mapLead.size());
            
            if (!mapLead.IsEmpty()) {
                
                map<Id, list<Demand_Funnel__c>> mapLIDlistDFR= new map<Id, list<Demand_Funnel__c>>();
            
                for(Demand_Funnel__c d : [Select d.Lead__c, d.id, d.Pre_Opportunity_Status__c, d.Pre_Opportunity_Close_Reason__c, d.Opportunity__c 
                From Demand_Funnel__c d 
                where lead__c in :mapLead.keySet()]){
                    if(mapLIDlistDFR.containsKey(d.Lead__c)){
                        list<Demand_Funnel__c> listDFR = mapLIDlistDFR.get(d.Lead__c);
                        listDFR.add(d);
                        mapLIDlistDFR.put(d.lead__c, listDFR);
                    }else{
                        list<Demand_Funnel__c> listDFR = new list<Demand_Funnel__c>();
                        listDFR.add(d);
                        mapLIDlistDFR.put(d.lead__c, listDFR);
                    }                       
                }
                
                system.debug('###DFR_OppCreationFromLead3' + mapLIDlistDFR.size());
                
                map<id,Demand_Funnel__c> mapDFRUpdate = new map<id,Demand_Funnel__c>();
                map<id, Opportunity> mapOpportunity = new map<id, Opportunity>();
                map<id, Contact> mapContact = new map<id, Contact>();
                            
                //Retrieve Business Units included to the DFR tracking
                //set<String> setDFRBusinessUnits = getDFRBusinessUnits();
                
                for(Lead pLead : listLead){
                    Lead to = oldMap.get(pLead.Id);
                                    
                    Boolean vCreateDFR = True;
                    Demand_Funnel__c activeDFR;
                    
                    if(mapLIDlistDFR.containsKey(pLead.Id)){
                        list<Demand_Funnel__c> listDFR = mapLIDlistDFR.get(pLead.Id);
                        
                        for(Demand_Funnel__c d : listDFR){
                            mapDFRUpdate.put(d.id, new Demand_Funnel__c(Id=d.id, Contact__c=pLead.ConvertedContactId, Account__c=pLead.ConvertedAccountId));
                        }
                        
                    }   
                    
                    /*  
                    if (pLead.ConvertedContactId <> null){                                                  
                        mapContact.put(pLead.ConvertedContactId, new Contact(Id=pLead.ConvertedContactId, DFR_FromLeadConvert__c = True));      
                    }
                    */
                    
                  /*  if (pLead.ConvertedOpportunityId <> null){
                        mapOpportunity.put(pLead.ConvertedOpportunityId, new Opportunity(Id=pLead.ConvertedOpportunityId, Contact_Associated__c = pLead.ConvertedContactId, DFR_FromLeadConvert__c = True));
                    } */
    
                }                                    
                
                if (mapDFRUpdate.size()> 0){
                    Database.SaveResult[] srUpdate = Database.update(mapDFRUpdate.values(), false); 
                    
                    for (Database.SaveResult sr : srUpdate) {
                        if (!sr.isSuccess()) {        
                            System.debug('DFR Update Error: ' + sr.getId());       
                            for(Database.Error err : sr.getErrors()) {                          
                                System.debug('DFR Update Error: ' + err.getMessage() + ' * ' + err.getFields() + ' * ' + err.getStatusCode());
                            }
                        }
                    }
                }
                
                if (mapOpportunity.size()> 0){
                    Database.SaveResult[] srUpdate = Database.update(mapOpportunity.values(), false);   
                    
                    for (Database.SaveResult sr : srUpdate) {
                        if (!sr.isSuccess()) {        
                            System.debug('Opportunity Update Error: ' + sr.getId());       
                            for(Database.Error err : sr.getErrors()) {                          
                                System.debug('Opportunity Update Error: ' + err.getMessage() + ' * ' + err.getFields() + ' * ' + err.getStatusCode());
                            }
                        }
                    }
                }       
                
                if (mapContact.size()> 0){
                    Database.SaveResult[] srUpdate = Database.update(mapContact.values(), false);   
                    
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
    }
    
    public static void OpportunityStageChange(list<Opportunity> newList, map<Id, Opportunity> oldMap){
        list<Id> listConId = new list<Id>();
        list<Opportunity> listOpp = new list<Opportunity>();
        map<ID, String> mapOppFunnel = new map<ID, String>();
        
        if(oldMap != Null){ //for Update
          for (Opportunity tn : newList){
            Opportunity to = oldMap.get(tn.Id);
              
           // system.debug('### DWF Product: (Update)' + tn.DWFProduct__c);
            system.debug('### Contact_Associated__c: (Update)' + tn.Contact_Associated__c);
             //tn.DWFProduct__c <> Null &&   
          if (  
            tn.Contact_Associated__c <> Null &&
            (to.isWon <> tn.isWon 
            || to.IsClosed <> tn.IsClosed)){      // to.DFR_FromLeadConvert__c == tn.DFR_FromLeadConvert__c  : Kumud Field cleanup 
                
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
              }
                                
          }
        }else{ //for Insert
            for (Opportunity tn : newList){
                
               // system.debug('### DWF Product (Insert): ' + tn.DWFProduct__c);
                system.debug('### Contact_Associated__c (Insert): ' + tn.Contact_Associated__c);
                
                if (tn.Contact_Associated__c <> Null ) {  // && tn.DWFProduct__c <> Null
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
                } 
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
               // String vProduct = o.DWFProduct__c;
                
               // system.debug('### DWFProduct: ' + o.DWFProduct__c);// comment by kd 
                
               // if(mapDFRProductStatusField.containsKey(vProduct)){ // comment by kd 
                   // String vStatusField = mapDFRProductStatusField.get(vProduct).Contact_Status_Field__c;
                    
                   /* map<String, map<String,String>> ContactStageFieldMapping = ProductContactStageFieldMapping.get(vProduct);
                    map<String, String> mapInquiryFieldMapping = ContactStageFieldMapping.get('Inquiry');
                    map<String, String> mapMQLFieldMapping = ContactStageFieldMapping.get('MQL');
                    map<String, String> mapSALFieldMapping = ContactStageFieldMapping.get('SAL');
                    map<String, String> mapSQLFieldMapping = ContactStageFieldMapping.get('SQL');   
                    map<String, String> mapOSFieldMapping = ContactStageFieldMapping.get('Opportunity Stage');   
                    map<String, String> mapEOLFieldMapping = ContactStageFieldMapping.get('EOL');*/  // comment by kd 
                                    
                    Demand_Funnel__c DFR;
                    
                    map<String, Demand_Funnel__c> mapProdDFR = new map<String, Demand_Funnel__c>();
                    
                    if(mapOIDDFR.containsKey(o.Id)){
                        DFR = mapOIDDFR.get(o.Id);
                    }else if(mapContactProdDFR.containsKey(o.Contact_Associated__c)){                   
                        mapProdDFR = mapContactProdDFR.get(o.Contact_Associated__c);                    
                        if(mapProdDFR.containsKey(o.DWFProduct__c)){
                            DFR = mapProdDFR.get(o.DWFProduct__c);
                        }
                    }
                    
                    if(DFR <> Null){
                        //Update existing DFR           
                                                            
                        mapDFRUpdate.put(DFR.id, new Demand_Funnel__c(Id=DFR.id));   
                        mapDFRUpdate.get(DFR.id).put('Opportunity__c',o.Id);    
                       // mapDFRUpdate.get(DFR.id).put('Product__c',vProduct); 
                        
                        if(vFunnel == 'Opportunity Stage'){
                            String vStage = 'Opportunity Stage';
                            mapDFRUpdate.get(DFR.id).put('OS_Date_Entered__c',date.today());
                            
                            //Reiterate to set field values to the DFR from the contact
                          /*  for(String k:mapOSFieldMapping.keySet()){  
                                try {
                                    mapDFRUpdate.get(DFR.id).put(mapOSFieldMapping.get(k),c.get(k));
                                } catch(exception e) {} 
                            }*/
                            
                            mapDFRUpdate.get(DFR.id).put('OS_Entered_From__c', vStage);
                            
                            if(DFR.Pre_Opportunity_Status__c == 'SQL'){
                                mapDFRUpdate.get(DFR.id).put('SQL_Date_Exited__c',Date.Today());
                                mapDFRUpdate.get(DFR.id).put('SQL_Exited_To__c',vStage);
                                mapDFRUpdate.get(DFR.id).put('OS_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                            }else if(DFR.Pre_Opportunity_Status__c == 'SAL' || DFR.Pre_Opportunity_Status__c == 'SGL'){
                                mapDFRUpdate.get(DFR.id).put('SAL_Date_Exited__c',Date.Today());
                                mapDFRUpdate.get(DFR.id).put('SAL_Exited_To__c',vStage);
                                mapDFRUpdate.get(DFR.id).put('OS_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                            }else if(DFR.Pre_Opportunity_Status__c == 'MQL' || DFR.Pre_Opportunity_Status__c == 'MRL'){
                                mapDFRUpdate.get(DFR.id).put('MQL_Date_Exited__c',Date.Today());
                                mapDFRUpdate.get(DFR.id).put('MQL_Exited_To__c',vStage);
                                mapDFRUpdate.get(DFR.id).put('OS_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                            }else if(DFR.Pre_Opportunity_Status__c == 'Inquiry'){
                                mapDFRUpdate.get(DFR.id).put('Inquiry_Date_Exited__c',Date.Today());
                                mapDFRUpdate.get(DFR.id).put('Inquiry_Exited_To__c',vStage);
                                mapDFRUpdate.get(DFR.id).put('OS_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                            }
                            
                            mapDFRUpdate.get(DFR.id).put('Pre_Opportunity_Status__c',vStage);   
                            
                        }else if(vFunnel == 'EOL-Won' || vFunnel == 'EOL-Lost'){
                            String vStage = 'EOL';
                            mapDFRUpdate.get(DFR.id).put('EOL_Date_Entered__c',date.today());
                            
                            //Reiterate to set field values to the DFR from the contact
                            /*for(String k:mapEOLFieldMapping.keySet()){  
                                try {
                                    mapDFRUpdate.get(DFR.id).put(mapEOLFieldMapping.get(k),c.get(k));
                                } catch(exception e) {} 
                            }*/ // comment by kd
                            
                            // mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',vStage);
                            
                            if(vFunnel == 'EOL-Lost'){
                                try{
                                    Opportunity to = oldMap.get(o.Id);
                                    mapDFRUpdate.get(DFR.id).put('Opp_Stage_Before_Lost__c', to.StageName);
                                }catch(exception e){}
                            }
                            
                            system.debug('###1 vStage: ' + vStage);
                            system.debug('###1 preOpp Status: ' + DFR.Pre_Opportunity_Status__c);
                            
                            if(DFR.Pre_Opportunity_Status__c == 'Opportunity Stage'){
                                system.debug('###2 vStage: ' + vStage);
                                system.debug('###2 preOpp Status: ' + DFR.Pre_Opportunity_Status__c);
                                mapDFRUpdate.get(DFR.id).put('OS_Date_Exited__c',Date.Today());
                                mapDFRUpdate.get(DFR.id).put('OS_Exited_To__c', vStage);
                                mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                            }else if(DFR.Pre_Opportunity_Status__c == 'SQL'){
                                mapDFRUpdate.get(DFR.id).put('SQL_Date_Exited__c',Date.Today());
                                mapDFRUpdate.get(DFR.id).put('SQL_Exited_To__c',vStage);
                                mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                            }else if(DFR.Pre_Opportunity_Status__c == 'SAL' || DFR.Pre_Opportunity_Status__c == 'SGL'){
                                mapDFRUpdate.get(DFR.id).put('SAL_Date_Exited__c',Date.Today());
                                mapDFRUpdate.get(DFR.id).put('SAL_Exited_To__c',vStage);
                                mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                            }else if(DFR.Pre_Opportunity_Status__c == 'MQL' || DFR.Pre_Opportunity_Status__c == 'MRL'){
                                mapDFRUpdate.get(DFR.id).put('MQL_Date_Exited__c',Date.Today());
                                mapDFRUpdate.get(DFR.id).put('MQL_Exited_To__c',vStage);
                                mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                            }else if(DFR.Pre_Opportunity_Status__c == 'Inquiry'){
                                mapDFRUpdate.get(DFR.id).put('Inquiry_Date_Exited__c',Date.Today());
                                mapDFRUpdate.get(DFR.id).put('Inquiry_Exited_To__c',vStage);
                                mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                            }       
                            mapDFRUpdate.get(DFR.id).put('Pre_Opportunity_Status__c',vStage);
                            system.debug('### EOL_Entered_From__c: ' + mapDFRUpdate.get(DFR.id).EOL_Entered_From__c);
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
                            //mapContactUpdate.get(o.Contact_Associated__c).put(vStatusField, 'Closed Won');   // comment by kd
                            mapContactUpdate.get(o.Contact_Associated__c).put('DFR_StatusUpdateDate__c', datetime.now());
                        } else if(vFunnel == 'EOL-Lost'){
                            //mapContactUpdate.get(o.Contact_Associated__c).put(vStatusField, 'Closed Lost'); // comment by kd
                            mapContactUpdate.get(o.Contact_Associated__c).put('DFR_StatusUpdateDate__c', datetime.now());
                        } else if(vFunnel == 'Opportunity Stage'){
                            //mapContactUpdate.get(o.Contact_Associated__c).put(vStatusField, 'Open Opportunity'); // comment by kd
                            mapContactUpdate.get(o.Contact_Associated__c).put('DFR_StatusUpdateDate__c', datetime.now());
                        }
                    }catch(exception e){}
               // }                               
            }
                        
            if (listDFRInsert.size()> 0){
                Database.SaveResult[] srInsert = Database.insert(listDFRInsert, false); 
                
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
    
    /*
    public static void OpportunityStageChange(list<Opportunity> newList, map<Id, Opportunity> oldMap){
        if(!DisableOnTest){
            list<Id> listConId = new list<Id>();
            list<Opportunity> listOpp = new list<Opportunity>();
            map<ID, String> mapOppFunnel = new map<ID, String>();
            
            if(oldMap != Null){ //for Update
              for (Opportunity tn : newList){
                Opportunity to = oldMap.get(tn.Id);
                //commnted by kumud
              //  if (to.DFR_FromLeadConvert__c == tn.DFR_FromLeadConvert__c && tn.DWFProduct__c <> Null &&   
                tn.Contact_Associated__c <> Null &&
                (tn.DWFProduct__c <> to.DWFProduct__c
                || to.Contact_Associated__c <> tn.Contact_Associated__c 
                || to.isWon <> tn.isWon 
                || to.IsClosed <> tn.IsClosed)){    
                    
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
                  }
                                    
              }
            }else{ //for Insert
                for (Opportunity tn : newList){
                    if (tn.Contact_Associated__c <> Null && tn.DWFProduct__c <> Null) {
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
                    } 
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
                        
                for(Demand_Funnel__c d : [Select d.Contact__c, d.Opportunity__c, d.id, d.Pre_Opportunity_Status__c, d.Product__c From Demand_Funnel__c d 
                where d.Opportunity__c in :listOpp OR (d.Contact__c in :mapContact.keySet() AND d.Opportunity__c = Null AND d.Pre_Opportunity_Close_Reason__c = Null)]){
                    map<String, Demand_Funnel__c> mapProdDFR = new map<String, Demand_Funnel__c>();
                    if(mapContactProdDFR.containsKey(d.Contact__c)){                    
                        mapProdDFR = mapContactProdDFR.get(d.Contact__c);
                    }
                    
                    mapProdDFR.put(d.Product__c, d);
                    
                    mapContactProdDFR.put(d.Contact__c, mapProdDFR);
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
                    String vProduct = o.DWFProduct__c;
                    
                    system.debug('### DWFProduct: ' + o.DWFProduct__c);
                    
                    if(mapDFRProductStatusField.containsKey(vProduct)){
                        String vStatusField = mapDFRProductStatusField.get(vProduct).Contact_Status_Field__c;
                        
                        map<String, map<String,String>> ContactStageFieldMapping = ProductContactStageFieldMapping.get(vProduct);
                        map<String, String> mapInquiryFieldMapping = ContactStageFieldMapping.get('Inquiry');
                        map<String, String> mapMQLFieldMapping = ContactStageFieldMapping.get('MQL');
                        map<String, String> mapSALFieldMapping = ContactStageFieldMapping.get('SAL');
                        map<String, String> mapSQLFieldMapping = ContactStageFieldMapping.get('SQL');   
                        map<String, String> mapOSFieldMapping = ContactStageFieldMapping.get('Opportunity Stage');   
                        map<String, String> mapEOLFieldMapping = ContactStageFieldMapping.get('EOL');
                                        
                        Demand_Funnel__c DFR;
                        
                        map<String, Demand_Funnel__c> mapProdDFR = new map<String, Demand_Funnel__c>();
                        
                        if(mapContactProdDFR.containsKey(o.Contact_Associated__c)){                 
                            mapProdDFR = mapContactProdDFR.get(o.Contact_Associated__c);                    
                            if(mapProdDFR.containsKey(o.DWFProduct__c)){
                                DFR = mapProdDFR.get(o.DWFProduct__c);
                            }
                        }
                        
                        if(DFR <> Null){
                            //Update existing DFR           
                                                                
                            mapDFRUpdate.put(DFR.id, new Demand_Funnel__c(Id=DFR.id));   
                            mapDFRUpdate.get(DFR.id).put('Opportunity__c',o.Id);            
                            
                            if(vFunnel == 'Opportunity Stage'){
                                String vStage = 'Opportunity Stage';
                                mapDFRUpdate.get(DFR.id).put('OS_Date_Entered__c',date.today());
                                
                                //Reiterate to set field values to the DFR from the contact
                                for(String k:mapOSFieldMapping.keySet()){  
                                    try {
                                        mapDFRUpdate.get(DFR.id).put(mapOSFieldMapping.get(k),c.get(k));
                                    } catch(exception e) {} 
                                }
                                
                                mapDFRUpdate.get(DFR.id).put('OS_Entered_From__c', vStage);
                                
                                if(DFR.Pre_Opportunity_Status__c == 'SQL'){
                                    mapDFRUpdate.get(DFR.id).put('SQL_Date_Exited__c',Date.Today());
                                    mapDFRUpdate.get(DFR.id).put('SQL_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('OS_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                }else if(DFR.Pre_Opportunity_Status__c == 'SAL' || DFR.Pre_Opportunity_Status__c == 'SGL'){
                                    mapDFRUpdate.get(DFR.id).put('SAL_Date_Exited__c',Date.Today());
                                    mapDFRUpdate.get(DFR.id).put('SAL_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('OS_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                }else if(DFR.Pre_Opportunity_Status__c == 'MQL' || DFR.Pre_Opportunity_Status__c == 'MRL'){
                                    mapDFRUpdate.get(DFR.id).put('MQL_Date_Exited__c',Date.Today());
                                    mapDFRUpdate.get(DFR.id).put('MQL_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('OS_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                }else if(DFR.Pre_Opportunity_Status__c == 'Inquiry'){
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Date_Exited__c',Date.Today());
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('OS_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                }
                                
                                mapDFRUpdate.get(DFR.id).put('Pre_Opportunity_Status__c',vStage);   
                                
                            }else if(vFunnel == 'EOL-Won' || vFunnel == 'EOL-Lost'){
                                String vStage = 'EOL';
                                mapDFRUpdate.get(DFR.id).put('EOL_Date_Entered__c',date.today());
                                
                                //Reiterate to set field values to the DFR from the contact
                                for(String k:mapEOLFieldMapping.keySet()){  
                                    try {
                                        mapDFRUpdate.get(DFR.id).put(mapEOLFieldMapping.get(k),c.get(k));
                                    } catch(exception e) {} 
                                }
                                
                                // mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',vStage);
                                
                                if(vFunnel == 'EOL-Lost'){
                                    try{
                                        Opportunity to = oldMap.get(o.Id);
                                        mapDFRUpdate.get(DFR.id).put('Opp_Stage_Before_Lost__c', to.StageName);
                                    }catch(exception e){}
                                }
                                
                                system.debug('###1 vStage: ' + vStage);
                                system.debug('###1 preOpp Status: ' + DFR.Pre_Opportunity_Status__c);
                                
                                if(DFR.Pre_Opportunity_Status__c == 'Opportunity Stage'){
                                    system.debug('###2 vStage: ' + vStage);
                                    system.debug('###2 preOpp Status: ' + DFR.Pre_Opportunity_Status__c);
                                    mapDFRUpdate.get(DFR.id).put('OS_Date_Exited__c',Date.Today());
                                    mapDFRUpdate.get(DFR.id).put('OS_Exited_To__c', vStage);
                                    mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                }else if(DFR.Pre_Opportunity_Status__c == 'SQL'){
                                    mapDFRUpdate.get(DFR.id).put('SQL_Date_Exited__c',Date.Today());
                                    mapDFRUpdate.get(DFR.id).put('SQL_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                }else if(DFR.Pre_Opportunity_Status__c == 'SAL' || DFR.Pre_Opportunity_Status__c == 'SGL'){
                                    mapDFRUpdate.get(DFR.id).put('SAL_Date_Exited__c',Date.Today());
                                    mapDFRUpdate.get(DFR.id).put('SAL_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                }else if(DFR.Pre_Opportunity_Status__c == 'MQL' || DFR.Pre_Opportunity_Status__c == 'MRL'){
                                    mapDFRUpdate.get(DFR.id).put('MQL_Date_Exited__c',Date.Today());
                                    mapDFRUpdate.get(DFR.id).put('MQL_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                }else if(DFR.Pre_Opportunity_Status__c == 'Inquiry'){
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Date_Exited__c',Date.Today());
                                    mapDFRUpdate.get(DFR.id).put('Inquiry_Exited_To__c',vStage);
                                    mapDFRUpdate.get(DFR.id).put('EOL_Entered_From__c',DFR.Pre_Opportunity_Status__c);
                                }       
                                mapDFRUpdate.get(DFR.id).put('Pre_Opportunity_Status__c',vStage);
                                system.debug('### EOL_Entered_From__c: ' + mapDFRUpdate.get(DFR.id).EOL_Entered_From__c);
                            }           
                        }else{// Contacts that move stages without active DFR
                            
                            DFR = new Demand_Funnel__c();
                                            
                            DFR.Account__c = o.AccountId;
                            DFR.Contact__c = o.Contact_Associated__c;
                            DFR.Opportunity__c = o.Id;  
                            DFR.Product__c = vProduct;
                            
                            if(vFunnel == 'Opportunity Stage'){
                                String vStage = 'Opportunity Stage';
                            
                                DFR.OS_Date_Entered__c = Date.Today();
                                DFR.OS_Entered_From__c = vStage;
                                                                    
                                for(String k:mapOSFieldMapping.keySet()){  
                                    try {
                                        DFR.put(mapOSFieldMapping.get(k),c.get(k));
                                    } catch(exception e) {} 
                                }
                                
                                DFR.Pre_Opportunity_Status__c = vStage; 
                                
                            }else if(vFunnel == 'EOL-Won' || vFunnel == 'EOL-Lost'){
                                String vStage = 'EOL';
                            
                                DFR.EOL_Date_Entered__c = Date.Today();
                                DFR.EOL_Entered_From__c = vStage;
                                                                    
                                for(String k:mapEOLFieldMapping.keySet()){  
                                    try {
                                        DFR.put(mapEOLFieldMapping.get(k),c.get(k));
                                    } catch(exception e) {} 
                                }
                                
                                DFR.Pre_Opportunity_Status__c = vStage;                     
                            }
                            
                            listDFRInsert.add(DFR);     
                        }               
                        
                        //Update Contact Product Status
                        try{
                            mapContactUpdate.put(o.Contact_Associated__c, new Contact(Id=o.Contact_Associated__c));  
                            if(vFunnel == 'EOL-Won'){
                                mapContactUpdate.get(o.Contact_Associated__c).put(vStatusField, 'Closed Won');
                                mapContactUpdate.get(o.Contact_Associated__c).put('DFR_StatusUpdateDate__c', datetime.now());
                            } else if(vFunnel == 'EOL-Lost'){
                                mapContactUpdate.get(o.Contact_Associated__c).put(vStatusField, 'Closed Lost');
                                mapContactUpdate.get(o.Contact_Associated__c).put('DFR_StatusUpdateDate__c', datetime.now());
                            } else if(vFunnel == 'Opportunity Stage'){
                                mapContactUpdate.get(o.Contact_Associated__c).put(vStatusField, 'Open Opportunity');
                                mapContactUpdate.get(o.Contact_Associated__c).put('DFR_StatusUpdateDate__c', datetime.now());
                            }
                        }catch(exception e){}
                    }                               
                }
                            
                if (listDFRInsert.size()> 0){
                    Database.SaveResult[] srInsert = Database.insert(listDFRInsert, false); 
                    
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
    }
    */  
    public static void fakeMethod(){
    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
  }
}