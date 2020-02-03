/*Version 1.0
    Date:7th Nov 2016
    Description : Migrating FEATURESET to PRODUCT/PRICEBOOK. Below are the name of the field which needs to be replaced - 
    OLD FIELD NAME       = NEW FIELD NAME
    Feature_Sets__r      = OpportunityLineItems;
    R00N00000008aGEXEA2  = OpportunityLineItems;
    Feature_Set__c       = OpportunityLineItem;
    Feature__c           = Product_Name__c;
    OpportunityId    = OpportunityId;
    //Lines Commented as Can't update CurrencyISOCode of OpportunityLineItem*/
    
    
public class OppotunityHelperClsUtil {
    @future
    public static void insertNewOpps(String soql,List<Id> lstUpdatePicklistInsertIds){
        List<sobject> oppDynamicList = Database.query(soql);
        system.debug(oppDynamicList);
        
        String objectName = 'opportunity';
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        system.debug(fMap); 
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
        system.debug(selectFields); 
        List<sobject> sobjLstInsert = new List<sobject>();
        for(Sobject instOfOpp : oppDynamicList){
            sObject sObj = Schema.getGlobalDescribe().get('opportunity').newSObject() ;  
            for(String strFName : selectFields){
            
                //Skip one mob fields -  Added on 30 Aug 2017 - SA                      
                if(!Test.isRunningTest() || (Test.isRunningTest() && strFName!='ContractId' && !strFName.contains('onemob') )){
                    system.debug(strFName);
                    system.debug(instOfOpp.get(strFName));
                    sObj.put(strFName,instOfOpp.get(strFName));
                }
            }
            //sObj.put('Cloned_From_Opp_Id__c',String.valueOf(instOfOpp.Id));
            //sObj.put('Tract_Billing_Account_Number__c','');
            sObj.put('Contract_Implemented__c',false);
            sObj.put('Contract_Implemented_by__c','');
            /*if(Test.isRunningTest())
            sObj.put('Clubbed_Tract_Billing_Account__c','Wdecr12');
            else
            sObj.put('Clubbed_Tract_Billing_Account__c','');*/
            sobj.put('StageName','TRACT Clone');
            //sobj.put('TRACT2__Tract_Sales_Order__c','');
            sobjLstInsert.add(sObj);
        }
        system.debug(sobjLstInsert);
        if(sobjLstInsert.size()>0)
        insert sobjLstInsert;
        
        ///////For Feature Sets///////////////////////////////////////////////////////////////////////////////////////////////////////////
        String selects = '';
        // Get a map of field name and field token
        fMap = new Map<String, Schema.SObjectField>();
        fMap = Schema.getGlobalDescribe().get('OpportunityLineItem'.toLowerCase()).getDescribe().Fields.getMap();
        selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        String soqlFeatureSets = 'SELECT ' + selects + ' FROM ' + 'OpportunityLineItem' + ' WHERE OpportunityId=: lstUpdatePicklistInsertIds';
        List<sobject> oppFeatureList = Database.query(soqlFeatureSets);
        
        List<sobject> sobjLstInsertFeature = new List<sobject>();
        system.debug(sobjLstInsert);
        for(sObject instOfSobj : sobjLstInsert){
            
            for(sObject instOfObjFeature : oppFeatureList){
                system.debug(instOfObjFeature.get('OpportunityId'));
                system.debug(instOfObjFeature.get('Id'));
                //As "Cloned_From_Opp_Id__c" field is being purged so commenting this IF Clause
                /*if(instOfSobj.get('Cloned_From_Opp_Id__c') == instOfObjFeature.get('OpportunityId')){
                    sObject sObj = Schema.getGlobalDescribe().get('OpportunityLineItem').newSObject() ;
                    system.debug(instOfSobj.get('Id'));
                    sObj.put('OpportunityId',instOfSobj.get('Id'));
                    for(String strFName : selectFields){
                        system.debug(strFName);
                        system.debug(instOfObjFeature.get(strFName));
                        if(strFName!='OpportunityId')
                        sObj.put(strFName,instOfObjFeature.get(strFName));
                    }
                    sobjLstInsertFeature.add(sObj);
                }*/
            }
        }
        
        system.debug(sobjLstInsertFeature);
        if(sobjLstInsertFeature.size()>0)
        insert sobjLstInsertFeature;
        ///////For Feature Sets///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        ///////For Invoicing Dets///////////////////////////////////////////////////////////////////////////////////////////////////////////
        selects = '';
        // Get a map of field name and field token
        fMap = new Map<String, Schema.SObjectField>();
        fMap = Schema.getGlobalDescribe().get('Invoicing_Details__c'.toLowerCase()).getDescribe().Fields.getMap();
        selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
        String soqlInvoiceDets = 'SELECT ' + selects + ' FROM ' + 'Invoicing_Details__c' + ' WHERE Opportunity__c=: lstUpdatePicklistInsertIds';
        
        List<sobject> oppInvoiceList = Database.query(soqlInvoiceDets);
        system.debug(oppInvoiceList);
        //sobjLstInsert = new List<sobject>();
        List<sobject> sobjLstInsertInvoiceDets = new List<sobject>();
        system.debug(sobjLstInsert);
        Set<Id> setIdsInvoiceDets = new Set<Id>();
        for(sObject instOfSobj : sobjLstInsert){
            
            for(sObject instOfObjInvoice : oppInvoiceList){
                system.debug(instOfObjInvoice.get('Opportunity__c'));
                system.debug(instOfObjInvoice.get('Id'));
                setIdsInvoiceDets.add(string.valueOf(instOfObjInvoice.get('id')));
                /*Because "Cloned_From_Opp_Id__c" is purged so commenting this IF Clause
                if(instOfSobj.get('Cloned_From_Opp_Id__c') == instOfObjInvoice.get('Opportunity__c')){
                    sObject sObj = Schema.getGlobalDescribe().get('Invoicing_Details__c').newSObject() ;
                    system.debug(instOfSobj.get('Id'));
                    sObj.put('Opportunity__c',instOfSobj.get('Id'));
                    for(String strFName : selectFields){
                        system.debug(strFName);
                        system.debug(instOfObjInvoice.get(strFName));
                        if(strFName!='Opportunity__c')
                        sObj.put(strFName,instOfObjInvoice.get(strFName));
                    }
                    sObj.put('Invoicing_Details_Old_Id__c',instOfObjInvoice.get('Id'));
                    sobjLstInsertInvoiceDets.add(sObj);
                }*/
            }
        }
        
        system.debug(sobjLstInsertInvoiceDets);
        if(sobjLstInsertInvoiceDets.size()>0)
        insert sobjLstInsertInvoiceDets;
        ///////For Invoicing Dets///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        ///////For Invoicing Line Items///////////////////////////////////////////////////////////////////////////////////////////////////////////
        selects = '';
        // Get a map of field name and field token
        fMap = new Map<String, Schema.SObjectField>();
        fMap = Schema.getGlobalDescribe().get('Invoicing_Line_Items__c'.toLowerCase()).getDescribe().Fields.getMap();
        selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
        String soqlInvoiceLineItem = 'SELECT ' + selects + ' FROM ' + 'Invoicing_Line_Items__c' + ' WHERE Invoicing_Details__c=: setIdsInvoiceDets';
        
        List<sobject> invoiceLineItemsList = Database.query(soqlInvoiceLineItem);
        system.debug(invoiceLineItemsList);
        //sobjLstInsert = new List<sobject>();
        List<sobject> sobjLstInsertInvoiceLineItem = new List<sobject>();
        system.debug(sobjLstInsertInvoiceDets);
        for(sobject invoiceLineItemsSob : invoiceLineItemsList){
            for(Sobject instOfObIVD : sobjLstInsertInvoiceDets){
                system.debug(invoiceLineItemsSob.get('Invoicing_Details__c'));
                if(invoiceLineItemsSob.get('Invoicing_Details__c') == instOfObIVD.get('Invoicing_Details_Old_Id__c')){
                    sObject sObj = Schema.getGlobalDescribe().get('Invoicing_Line_Items__c').newSObject();
                    for(String strFName : selectFields){
                        system.debug(strFName);
                        system.debug(invoiceLineItemsSob.get(strFName));
                        sObj.put(strFName,invoiceLineItemsSob.get(strFName));
                    }
                    sObj.put('Invoicing_Details__c',instOfObIVD.get('Id'));
                    sobjLstInsertInvoiceLineItem.add(sObj);
                }
            }
        }
        system.debug(sobjLstInsertInvoiceLineItem);
        if(sobjLstInsertInvoiceLineItem.size()>0)
        insert sobjLstInsertInvoiceLineItem;
        
        
        ///////For Invoicing Line Items///////////////////////////////////////////////////////////////////////////////////////////////////////////
    }
}