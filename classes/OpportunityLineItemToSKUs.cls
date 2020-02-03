global class OpportunityLineItemToSKUs
{
    webservice static void MoveItemstoSKUs(Id oppId){ 
    
        //Product Vs Famliy for Fee Products (Discount,Convinience)
        Map<String,String> feeProductsVsFamily = new Map<String,String>();
        //License Products
        Map<Id,String> oppIdVsProduct = new Map<Id,String>();
        List<Opportunity> oppsToProcessList = new List<Opportunity>();
        Set<String> ISOCodeSet = new Set<String>();
        //Opp Id vs Set of PricebookEntryId
        Map<Id,Set<Id>> existingLineItemsMap = new  Map<Id,Set<Id>>();

        //Custom Setting For Product Mapping
        Map<String,LicenseVsProductSetting__c> licenseVsoppIdVsProductping = LicenseVsProductSetting__c.getAll();
        //Product Vs Family
        Map<String,ProductVsFamilySetting__c> productVsFamilyMapping = ProductVsFamilySetting__c.getAll();

        List<OpportunityLineItem> newlineItemsList = new List<OpportunityLineItem>();
        
        //Filtering Opps with Closed One stage - Custom Setting should exist 
        Opportunity opp = [Select Id,Product__c,Convinience_Fee__c,New_Amount__c,MaintenanceFee__c,CurrencyIsoCode,License_Type__c,of_Registrations__c,of_Leads_Purchased__c,Per_Registration_Fee__c,of_Complimentary_Leads__c
        ,(Select PricebookEntryId From OpportunityLineItems) From Opportunity Where Id=:oppId];
            //Discount__c
            //Opportunity is closed AND Mapping exist for current license
            //if(opp.StageName == 'Closed Won'){
                
            //Get Product from Custom Setting based on License Type
            if(licenseVsoppIdVsProductping.get(opp.License_Type__c)!=null){
                oppIdVsProduct.put(opp.Id,licenseVsoppIdVsProductping.get(opp.License_Type__c).Product__c);
            }
            //Get Product Family 
            if(productVsFamilyMapping.get(opp.Product__c)!=null){
                feeProductsVsFamily.put('Convenience Fee', productVsFamilyMapping.get(opp.Product__c).Family__c);
                feeProductsVsFamily.put('Discount' , productVsFamilyMapping.get(opp.Product__c).Family__c);
                feeProductsVsFamily.put('Maintenance Fee' , 'Event');
            }
            oppsToProcessList.add(opp);
            ISOCodeSet.add(opp.CurrencyIsoCode);
            //}

            //Existing Line Items From Current Opportunity 
            for(OpportunityLineItem lineItem : opp.OpportunityLineItems){
                if(existingLineItemsMap.containsKey(opp.Id)){
                    existingLineItemsMap.get(opp.Id).add(lineItem.PricebookEntryId);
                }else{
                    existingLineItemsMap.put(opp.Id,new Set<Id>{lineItem.PricebookEntryId});
                }               
            }           
        
        System.debug('**oppsToProcessList*******'+ oppsToProcessList);
        System.debug('**oppIdVsProduct*******'+ oppIdVsProduct);
        System.debug('**feeProductsVsFamily*******'+ feeProductsVsFamily);
        //Retrieve Products
        //Products ( key = 'Product Name' + 'ISO CODE' , Value = EntryId)
        Map<String,Id> licensePriceBookMap = new Map<String,Id>();
        Map<String,Id> feePriceBookMap = new Map<String,Id>();
        
        
        List<PricebookEntry> entryList;
        String query= 'Select Id,Product2.Name,Product2.Family,CurrencyIsoCode From PricebookEntry Where isActive=true AND CurrencyIsoCode IN: ISOCodeSet AND ( Product2.Name IN:oppIdVsProduct.values() OR (Product2.Name IN:feeProductsVsFamily.keySet() AND Product2.Family IN:feeProductsVsFamily.values())) And Pricebook2.IsStandard=false';
       
        //Test Class can not create custom pricebook , using below SOQL without filter isStandard
        if(!test.isRunningTest()){
            entryList = [Select Id,Product2.Name,Product2.Family,CurrencyIsoCode From PricebookEntry Where isActive=true AND CurrencyIsoCode IN: ISOCodeSet AND ( Product2.Name IN: oppIdVsProduct.values() OR (Product2.Name IN: feeProductsVsFamily.keySet() AND Product2.Family IN:feeProductsVsFamily.values())) And Pricebook2.IsStandard=false];
        }else{entryList = [Select Id,Product2.Name,Product2.Family,CurrencyIsoCode From PricebookEntry Where isActive=true AND CurrencyIsoCode IN: ISOCodeSet AND ( Product2.Name IN: oppIdVsProduct.values() OR (Product2.Name IN: feeProductsVsFamily.keySet() AND Product2.Family IN:feeProductsVsFamily.values()))];}
        
        for(PricebookEntry entry : entryList){
            licensePriceBookMap.put(entry.Product2.Name+entry.CurrencyIsoCode,entry.Id);
            feePriceBookMap.put(entry.Product2.Name+entry.CurrencyIsoCode+entry.Product2.Family,entry.Id);
        }
        System.debug('**licensePriceBookMap*******'+ licensePriceBookMap);
        System.debug('**feePriceBookMap*******'+ feePriceBookMap);

        //Creaintg Line Items 
        //Retrieve Current PricebookEntryIds from Opp
        Set<Id> existingEntryIdSet = existingLineItemsMap.get(opp.Id);
        Id priceBookEntryId=null;
    
        /**
        ** Processing License Type Products
        **/
        if(!oppIdVsProduct.isEmpty()){
            
            //Setting Default Value
            Decimal noOfItems = 1;
            Decimal perItemFee = opp.New_Amount__c;
            Decimal noOfCompItems = 0;
            
            //Setting Fees based on below Conditions 
    
            //Unit of Measure field
            if(opp.of_Registrations__c!=null){noOfItems = opp.of_Registrations__c;}
            //else if(opp.Events__c!=null){noOfItems = opp.Events__c;} // comment by kumud [6 june 2018 -Field remove ]
            //else if(opp.of_Transactions__c!=null){noOfItems = opp.of_Transactions__c;} //  [6 june 2018 -Field remove ]
            else if(opp.of_Leads_Purchased__c!=null){noOfItems = opp.of_Leads_Purchased__c;}
            
            //Per Unit price field
            if(opp.Per_Registration_Fee__c!=null){perItemFee = opp.Per_Registration_Fee__c;}
            //else if(opp.Per_Event_Fee__c!=null){perItemFee = opp.Per_Event_Fee__c;} field cleanup activity
            //else if(opp.Per_Transaction_Fee__c!=null){perItemFee = opp.Per_Transaction_Fee__c;}
            //else if(opp.Price_per_lead__c!=null){perItemFee = opp.Price_per_lead__c;}
            
            //Complementatry Units field
           // if(opp.of_Free_Registrations__c!=null){noOfCompItems = opp.of_Free_Registrations__c;}
          //  else if(opp.of_Free_Events__c!=null){noOfCompItems = opp.of_Free_Events__c;}
           // else if(opp.of_Free_Transactions__c!=null){noOfCompItems = opp.of_Free_Transactions__c;}
            else if(opp.of_Complimentary_Leads__c!=null){noOfCompItems = opp.of_Complimentary_Leads__c;}

            //Retrieve New  PricebookEntryIds
            priceBookEntryId = licensePriceBookMap.get(oppIdVsProduct.get(opp.Id)+opp.CurrencyIsoCode);
      
            System.debug('priceBookEntryId*******'+ priceBookEntryId);
            //If Product Entry exist for this Product and doesn't fall under existing line items....
            if( priceBookEntryId!=null && (existingEntryIdSet==null || !existingEntryIdSet.contains(priceBookEntryId))){
                
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.PricebookEntryId = priceBookEntryId;
                oli.OpportunityId = opp.Id;
                oli.Quantity= 1;
                oli.TotalPrice = 0;
                oli.Should_not_RollUp__c = true;
                oli.of_Items__c = noOfItems;
                oli.Per_Item_Fee__c = perItemFee;
                oli.of_Comp_Items_Hrs__c = noOfCompItems;
             
                newlineItemsList.add(oli);          
            }
        }
        
        /**
        ** Processing Fee Type Products
        **/
        if(opp.MaintenanceFee__c!=null){
            
            //Retrieve New  PricebookEntryIds
            priceBookEntryId = feePriceBookMap.get('Maintenance Fee'+opp.CurrencyIsoCode+
            feeProductsVsFamily.get('Maintenance Fee'));

            System.debug('priceBookEntryId***Maintenance Fee*******'+ priceBookEntryId);
            //If Product Entry exist for this Product and doesn't fall under existing line items....
            if( priceBookEntryId!=null && (existingEntryIdSet==null || !existingEntryIdSet.contains(priceBookEntryId))){
                
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.PricebookEntryId = priceBookEntryId;
                oli.OpportunityId = opp.Id;
                oli.Quantity= 1;
                oli.TotalPrice = 0;
                oli.Should_not_RollUp__c = true;
                oli.of_Items__c = 1;
                oli.Per_Item_Fee__c = opp.MaintenanceFee__c;
               
                newlineItemsList.add(oli);          
            }            
        }

        if(opp.Convinience_Fee__c!=null){
            
            //Retrieve New  PricebookEntryIds
            priceBookEntryId = feePriceBookMap.get('Convenience Fee'+opp.CurrencyIsoCode+
            feeProductsVsFamily.get('Convenience Fee'));

            System.debug('priceBookEntryId***ConvinienceFee*******'+ priceBookEntryId);
            //If Product Entry exist for this Product and doesn't fall under existing line items....
            if( priceBookEntryId!=null && (existingEntryIdSet==null || !existingEntryIdSet.contains(priceBookEntryId))){
                
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.PricebookEntryId = priceBookEntryId;
                oli.OpportunityId = opp.Id;
                oli.Quantity= 1;
                oli.TotalPrice = 0;
                oli.Should_not_RollUp__c = true;
                oli.of_Items__c = 1;
                oli.Per_Item_Fee__c = opp.Convinience_Fee__c;
                
                newlineItemsList.add(oli);          
            }
        }

        //if(opp.Discount__c!=null){  // comment by kumud 6 june field cleanup activity
            
            //Retrieve New  PricebookEntryIds
            priceBookEntryId = feePriceBookMap.get('Discount'+opp.CurrencyIsoCode+
            feeProductsVsFamily.get('Discount'));

            System.debug('priceBookEntryId***Discount*******'+ priceBookEntryId);
            //If Product Entry exist for this Product and doesn't fall under existing line items....
            if( priceBookEntryId!=null && (existingEntryIdSet==null || !existingEntryIdSet.contains(priceBookEntryId))){
                
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.PricebookEntryId = priceBookEntryId;
                oli.OpportunityId = opp.Id;
                oli.Quantity= 1;
                oli.TotalPrice = 0;
                oli.Should_not_RollUp__c = true;
                oli.of_Items__c = 1;
                //oli.Per_Item_Fee__c = opp.Discount__c;comment by kumud 6 june field cleanup activity
                
                newlineItemsList.add(oli);          
            }            
        //}


        
       
        System.debug('**newlineItemsList*******'+ newlineItemsList);
        if(newlineItemsList.size()>0){
            insert newlineItemsList;
        }
        //opp.LI_Synced__c = true; comment by kd
        update opp;
        
    }
}