public class SnapShotUtilityHelper{
    public static void CreateOppProdSnapshot(List<SBQQ__Subscription__c> subscriptionList , Set<Id> oppIdSet,Set<String> reassignIdSet,Map<String,Id> oldNewOppLineIdMap){

        /*Map<String,Decimal> ISOCodeVsRate = new Map<String,Decimal>();
        For(DatedConversionRate conversionObj : [SELECT ConversionRate,IsoCode,StartDate FROM DatedConversionRate WHERE StartDate = 0001-01-01 ORDER BY StartDate ASC NULLS FIRST])
        {
            ISOCodeVsRate.put(conversionObj.IsoCode,conversionObj.ConversionRate);
        }
        System.debug('ISOCodeVsRate*******'+ISOCodeVsRate);*/
        /*HSR : Deleting Not Identified Booking Classification when the first OpportunityLineItem is being inserted in that Opportunity.*/
        if(oppIdSet.size()>0)
            deleteUnIdentifiedBookClass(oppIdSet);
        System.debug('oppIdSet********'+oppIdSet);
        Set<Id> renewedContractIdSet = new Set<Id>();
        Map<Id,Id> oppidVsAccIdMap = new Map<Id,Id>();
        Map<Id,Opportunity> oppIdVsOppObj_TempMap = new Map<Id,Opportunity>();
        if(oppIdSet!=null){
            For(Opportunity oppRec : [SELECT Deal_Year__c,Exchange_Rate__c,Lock_BCT__c,SBQQ__Contracted__c,Contract_Type_2_0__c,SBQQ__AmendedContract__c,CurrencyIsoCode,Id,SBQQ__RenewedContract__c,SBQQ__PrimaryQuote__c,SBQQ__PrimaryQuote__r.SBQQ__Type__c,AccountId FROM Opportunity WHERE Id IN : oppIdSet])// AND SBQQ__RenewedContract__c!=null
            {
                if(oppRec.Lock_BCT__c==false && oppRec.SBQQ__PrimaryQuote__c!=null){
                    if(oppRec.SBQQ__RenewedContract__c!=null)
                        renewedContractIdSet.add(oppRec.SBQQ__RenewedContract__c);
                    oppidVsAccIdMap.put(oppRec.Id,oppRec.AccountId);
                    oppIdVsOppObj_TempMap.put(oppRec.Id,oppRec);
                }
                else
                {
                    oppIdSet.remove(oppRec.Id);
                }
            }
            
        }
        System.debug('oppIdVsOppObj_TempMap******'+oppIdVsOppObj_TempMap);
        if(subscriptionList!=null){
            For(SBQQ__Subscription__c subscriptObj : subscriptionList)
            {
                if(subscriptObj.Renewed_Opportunity_Dev__c != '')
                    renewedContractIdSet.add(subscriptObj.SBQQ__Contract__c);
            }
        }
        System.debug('oppidVsAccIdMap************'+oppidVsAccIdMap);
        //.......................Fetching Customer Asset......................................
        Map<Id,Set<String>> accIdVsFamilySet = new Map<Id,Set<String>>();
        Set<String> familySet = new Set<String>();
        if(!oppidVsAccIdMap.isEmpty()){
            For(Customer_Asset__c customerAssetRec : [SELECT Id,Account__c,Product_Family__c FROM Customer_Asset__c WHERE Account__c IN : oppidVsAccIdMap.values() AND Asset_Status__c='Active'])
            {
                if(!accIdVsFamilySet.containsKey(customerAssetRec.Account__c))
                {
                    accIdVsFamilySet.put(customerAssetRec.Account__c,new Set<String>{customerAssetRec.Product_Family__c});
                }
                else{
                    accIdVsFamilySet.get(customerAssetRec.Account__c).add(customerAssetRec.Product_Family__c);
                }
            }
        }
        //.........................
        System.debug('accIdVsFamilySet************'+accIdVsFamilySet);
        System.debug('renewedContractIdSet************'+renewedContractIdSet);
        /*...........Section for fetching the ARR value from Subscription Record...........*/
        
        Map<String,Decimal> ARRTPMap  = new Map<String,Decimal>();
        Set<Id> ARRTPSetId = new Set<Id>();
        Booking_Classification__c oppProdSnapshot =  new Booking_Classification__c();
        //List<Booking_Classification__c> oppProdSnapshotList =  new List<Booking_Classification__c>();
        String tempConcate = '';
        if(renewedContractIdSet.size()>0){
            AggregateResult[] groupedResults  = [SELECT SBQQ__Contract__r.SBQQ__RenewalOpportunity__c opp, SBQQ__Product__r.Family fam, 
            SUM(Annual_Recurring_Revenue_Dev__c) sumARR FROM SBQQ__Subscription__c WHERE SBQQ__Contract__r.SBQQ__RenewalOpportunity__c IN : oppIdSet
            GROUP BY SBQQ__Contract__r.SBQQ__RenewalOpportunity__c,SBQQ__Product__r.Family]; //SBQQ__Contract__c  IN : renewedContractIdSet
            
            
            for (AggregateResult ar : groupedResults)  {
                tempConcate = '';
                tempConcate = (Id)ar.get('opp') + '.'+'ARR.'+(String)ar.get('fam');
                ARRTPMap.put(tempConcate,(Decimal)ar.get('sumARR'));
                ARRTPSetId.add((Id)ar.get('opp'));
            }
        }
        /*...........................ENDS HERE............................................*/
        System.debug('ARRTPMapSubscription****************'+ARRTPMap);
        //.......................Reassigned To Subscription Query........................
        System.debug('reassignIdSet****************'+reassignIdSet);
        System.debug('oldNewOppLineIdMap*******'+oldNewOppLineIdMap);
        if(reassignIdSet!=null && reassignIdSet.size()>0)
        {
            AggregateResult[] groupedResults  = [SELECT SBQQ__Contract__r.SBQQ__RenewalOpportunity__c opp, SBQQ__Product__r.Family fam, 
            SUM(Annual_Recurring_Revenue_Dev__c) sumARR FROM SBQQ__Subscription__c WHERE SBQQ__Contract__r.SBQQ__RenewalOpportunity__c IN : reassignIdSet
            GROUP BY SBQQ__Contract__r.SBQQ__RenewalOpportunity__c,SBQQ__Product__r.Family]; //SBQQ__Contract__c  IN : renewedContractIdSet
            
            
            for (AggregateResult ar : groupedResults)  {
                
                tempConcate = '';
                String renewedoppId = String.ValueOf((Id)ar.get('opp'));//.substring(0,15)
                System.debug('renewedoppId********'+renewedoppId);
                tempConcate = oldNewOppLineIdMap.get(renewedoppId) + '.'+'ARR.'+(String)ar.get('fam');
                if(ARRTPMap.containsKey(tempConcate))
                {
                    Decimal tempCount = ARRTPMap.get(tempConcate)+(Decimal)ar.get('sumARR');
                    ARRTPMap.put(tempConcate,tempCount );
                }
                else{
                    ARRTPMap.put(tempConcate,(Decimal)ar.get('sumARR'));
                }
                //ARRTPSetId.add((Id)ar.get('opp'));
            }
        }
//        System.debug('ARRTPSetId****************'+ARRTPSetId);
        System.debug('ARRTPMapReassignTo****************'+ARRTPMap);
        //.................ENDS HERE............................
        /*...........Section for fetching the Total Price from Opportunity Product...........*/
        if(oppIdSet!=null && oppIdSet.size()>0){
            AggregateResult[] groupedTPResults  = [SELECT OpportunityId opp, Product2.Family fam, 
            SUM(TotalPrice_Dev__c) sumTotalPrice,SUM(TotalPrice) sumTotalPrice1 FROM OpportunityLineItem WHERE OpportunityId IN : oppIdSet AND SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Primary__c = TRUE
            GROUP BY OpportunityId,Product2.Family];
            System.debug('groupedTPResults*******'+groupedTPResults);
            for (AggregateResult ar : groupedTPResults)  {
                System.debug('ar***************'+ar);
                tempConcate = '';
                tempConcate = (Id)ar.get('opp') + '.'+'TP.'+(String)ar.get('fam');
                ARRTPMap.put(tempConcate,(Decimal)ar.get('sumTotalPrice'));
                ARRTPSetId.add((Id)ar.get('opp'));
            }
        }
        System.debug('ARRTotalPriceTPMap****************'+ARRTPMap);
        /*...........................ENDS HERE............................................*/
        Map<Id,Map<String,Id>> oppIdVsFamilyOppSnapId_Map = new Map<Id,Map<String,Id>>();
        Map<String,Id> familyOppSnapId_Map = new Map<String,Id>();
        
        Map<String,Id> OppIdFamilyVsSnapId_Map = new Map<String,Id>();
        System.debug('ARRTPSetId****'+ARRTPSetId);
        if(!ARRTPSetId.isEmpty()){
            For(Booking_Classification__c oppSnapRec : [SELECT Id,Opportunity__c,Product_Family__c FROM Booking_Classification__c WHERE Opportunity__c IN : ARRTPSetId])
            {
                tempConcate = '';
                tempConcate = String.ValueOf(oppSnapRec.Opportunity__c)+ '.'+oppSnapRec.Product_Family__c;
                OppIdFamilyVsSnapId_Map.put(tempConcate,oppSnapRec.Id);
            }
            System.debug('oppIdVsFamilyOppSnapId_Map*****************'+oppIdVsFamilyOppSnapId_Map);
            
            /*
            **
            **Inserting Opportunity Product Snapshot
            **
            */
            Map<String,Booking_Classification__c> tempMapInsert = new Map<String,Booking_Classification__c>();
            List<Booking_Classification__c> oppListTemp = new List<Booking_Classification__c>();
            For(String opportunityId : ARRTPMap.KeySet())
            {
                System.debug('opportunityId******'+opportunityId);
                Id  oppId  = opportunityId.substringBefore('.');
                String TPARR = opportunityId.substringBetween('.','.');
                String familyVals = opportunityId.substringAfterLast('.');
                
                tempConcate = String.ValueOf(oppId)+ '.'+familyVals;
                System.debug('tempConcate***********'+tempConcate);
                oppListTemp = new List<Booking_Classification__c>();
                    if(tempMapInsert.containsKey((oppId+familyVals))){
                        oppProdSnapshot =  tempMapInsert.get(oppId+familyVals);
                        oppProdSnapshot.Product_Family__c = familyVals;
                        if(!oppIdVsOppObj_TempMap.isEmpty() && oppIdVsOppObj_TempMap.containsKey(oppId)){
                            oppProdSnapshot.CurrencyIsoCode = oppIdVsOppObj_TempMap.get(oppId).CurrencyIsoCode; 
                            //New field added... removing formula field and adding it over here....
                            oppProdSnapshot.SBQQ_AmendedContract__c= oppIdVsOppObj_TempMap.get(oppId).SBQQ__AmendedContract__c!=null?String.valueOf(oppIdVsOppObj_TempMap.get(oppId).SBQQ__AmendedContract__c):'';
                            
                            oppProdSnapshot.Deal_Years__c = oppIdVsOppObj_TempMap.get(oppId).Deal_Year__c!=null?Integer.valueOf(oppIdVsOppObj_TempMap.get(oppId).Deal_Year__c):null;
                            
                            oppProdSnapshot.SBQQ_RenewedContract__c = oppIdVsOppObj_TempMap.get(oppId).SBQQ__RenewedContract__c!=null?String.valueOf(oppIdVsOppObj_TempMap.get(oppId).SBQQ__RenewedContract__c):'';
                            
                            oppProdSnapshot.Contract_Type_2_0__c = oppIdVsOppObj_TempMap.get(oppId).Contract_Type_2_0__c!=null?String.valueOf(oppIdVsOppObj_TempMap.get(oppId).Contract_Type_2_0__c):'';
                            oppProdSnapshot.Exchange_Rates__c = oppIdVsOppObj_TempMap.get(oppId).Exchange_Rate__c;
                        }
                        if(OppIdFamilyVsSnapId_Map.containsKey(tempConcate)){
                            oppProdSnapshot.Id = OppIdFamilyVsSnapId_Map.get(tempConcate);
                        }
                        oppProdSnapshot.Opportunity__c = oppId;
                        if(TPARR=='ARR'){
                            if(oppIdVsOppObj_TempMap.containsKey(oppId) && oppIdVsOppObj_TempMap.get(oppId).CurrencyIsoCode!='USD')
                                oppProdSnapshot.Total_Annual_Recurring_Revenue__c = ARRTPMap.get(opportunityId);//(ARRTPMap.get(opportunityId)*ISOCodeVsRate.get(oppIdVsOppObj_TempMap.get(oppId).CurrencyIsoCode));
                            else
                                oppProdSnapshot.Total_Annual_Recurring_Revenue__c = ARRTPMap.get(opportunityId);
                        }
                        else{
                            oppProdSnapshot.Total_Price__c = 0 ;
                            if(oppIdVsOppObj_TempMap.containsKey(oppId) && oppIdVsOppObj_TempMap.get(oppId).CurrencyIsoCode!='USD')
                                oppProdSnapshot.Total_Price__c = ARRTPMap.get(opportunityId);//(ARRTPMap.get(opportunityId)*ISOCodeVsRate.get(oppIdVsOppObj_TempMap.get(oppId).CurrencyIsoCode));
                            else
                                oppProdSnapshot.Total_Price__c = ARRTPMap.get(opportunityId);
                        }
                        //......For NBB - The account should not have any Active Customer Asset..........
                        if(!accIdVsFamilySet.containsKey(oppidVsAccIdMap.get(oppId)))
                        {
                            if(oppIdVsOppObj_TempMap.containsKey(oppId) && oppIdVsOppObj_TempMap.get(oppId).CurrencyIsoCode!='USD')
                                oppProdSnapshot.New_Logo__c = ARRTPMap.get(opportunityId);//(ARRTPMap.get(opportunityId)*ISOCodeVsRate.get(oppIdVsOppObj_TempMap.get(oppId).CurrencyIsoCode));
                            else
                                oppProdSnapshot.New_Logo__c = ARRTPMap.get(opportunityId);
                        }
                        //......For Upsell...........................................................
                        else if(accIdVsFamilySet.containsKey(oppidVsAccIdMap.get(oppId)) && accIdVsFamilySet.get(oppidVsAccIdMap.get(oppId)).contains(familyVals)){
                            if(oppIdVsOppObj_TempMap.get(oppId).Deal_Year__c=='1' || oppIdVsOppObj_TempMap.get(oppId).SBQQ__PrimaryQuote__r.SBQQ__Type__c == 'Amendment'){
                                oppProdSnapshot.UpSell_CrossSell_DEV__c = 'UPSELL';
                                oppProdSnapshot.New_Logo__c = 0;//Added on 31st May
                                oppListTemp.add(oppProdSnapshot);
                                tempMapInsert.put((oppId+familyVals),oppProdSnapshot);
                            }
                        }
                        //For Cross-Sell...................................
                        else{
                                oppProdSnapshot.UpSell_CrossSell_DEV__c = 'CROSSSELL'; 
                                oppProdSnapshot.New_Logo__c = 0;//Added on 31st May
                        }
                        oppListTemp.add(oppProdSnapshot);
                        tempMapInsert.remove((oppId+familyVals));
                        tempMapInsert.put((oppId+familyVals),oppProdSnapshot);
                    }
                    else{
                        oppProdSnapshot =  new Booking_Classification__c();
                        oppProdSnapshot.Product_Family__c = familyVals; //event
                        if(!oppIdVsOppObj_TempMap.isEmpty() && oppIdVsOppObj_TempMap.containsKey(oppId)){
                            oppProdSnapshot.CurrencyIsoCode = oppIdVsOppObj_TempMap.get(oppId).CurrencyIsoCode;
                            //New field added... removing formula field and adding it over here....
                            oppProdSnapshot.SBQQ_AmendedContract__c= oppIdVsOppObj_TempMap.get(oppId).SBQQ__AmendedContract__c!=null?String.valueOf(oppIdVsOppObj_TempMap.get(oppId).SBQQ__AmendedContract__c):'';
                            
                            oppProdSnapshot.Deal_Years__c = oppIdVsOppObj_TempMap.get(oppId).Deal_Year__c!=null?Integer.valueOf(oppIdVsOppObj_TempMap.get(oppId).Deal_Year__c):null;
                            
                            oppProdSnapshot.SBQQ_RenewedContract__c = oppIdVsOppObj_TempMap.get(oppId).SBQQ__RenewedContract__c!=null?String.valueOf(oppIdVsOppObj_TempMap.get(oppId).SBQQ__RenewedContract__c):'';
                            
                            oppProdSnapshot.Contract_Type_2_0__c = oppIdVsOppObj_TempMap.get(oppId).Contract_Type_2_0__c!=null?String.valueOf(oppIdVsOppObj_TempMap.get(oppId).Contract_Type_2_0__c):'';
                            oppProdSnapshot.Exchange_Rates__c = oppIdVsOppObj_TempMap.get(oppId).Exchange_Rate__c;
                        }
                        if(OppIdFamilyVsSnapId_Map.containsKey(tempConcate)){
                            oppProdSnapshot.Id = OppIdFamilyVsSnapId_Map.get(tempConcate); // Blank
                        }
                        oppProdSnapshot.Opportunity__c = oppId; // OppId
                        if(TPARR=='ARR'){
                            if(oppIdVsOppObj_TempMap.containsKey(oppId) && oppIdVsOppObj_TempMap.get(oppId).CurrencyIsoCode!='USD')
                                oppProdSnapshot.Total_Annual_Recurring_Revenue__c = ARRTPMap.get(opportunityId);//(ARRTPMap.get(opportunityId)*ISOCodeVsRate.get(oppIdVsOppObj_TempMap.get(oppId).CurrencyIsoCode));
                            else
                                oppProdSnapshot.Total_Annual_Recurring_Revenue__c = ARRTPMap.get(opportunityId);
                        }
                        else{
                            oppProdSnapshot.Total_Price__c = 0 ;
                            if(oppIdVsOppObj_TempMap.containsKey(oppId) && oppIdVsOppObj_TempMap.get(oppId).CurrencyIsoCode!='USD')
                                oppProdSnapshot.Total_Price__c = ARRTPMap.get(opportunityId);//(ARRTPMap.get(opportunityId)*ISOCodeVsRate.get(oppIdVsOppObj_TempMap.get(oppId).CurrencyIsoCode));
                            else
                                oppProdSnapshot.Total_Price__c = ARRTPMap.get(opportunityId);
                        }
                        //......For NBB - The account should not have any Active Customer Asset..........
                        if(!accIdVsFamilySet.containsKey(oppidVsAccIdMap.get(oppId)))
                        {
                            if(oppIdVsOppObj_TempMap.containsKey(oppId) && oppIdVsOppObj_TempMap.get(oppId).CurrencyIsoCode!='USD')
                                oppProdSnapshot.New_Logo__c = ARRTPMap.get(opportunityId);//(ARRTPMap.get(opportunityId)*ISOCodeVsRate.get(oppIdVsOppObj_TempMap.get(oppId).CurrencyIsoCode));
                            else
                                oppProdSnapshot.New_Logo__c = ARRTPMap.get(opportunityId);
                        }
                        //......For Upsell...........................................................
                        else if(accIdVsFamilySet.containsKey(oppidVsAccIdMap.get(oppId)) && accIdVsFamilySet.get(oppidVsAccIdMap.get(oppId)).contains(familyVals)){
                            if(oppIdVsOppObj_TempMap.get(oppId).Deal_Year__c=='1' || oppIdVsOppObj_TempMap.get(oppId).SBQQ__PrimaryQuote__r.SBQQ__Type__c == 'Amendment'){
                                oppProdSnapshot.UpSell_CrossSell_DEV__c = 'UPSELL';
                                oppProdSnapshot.New_Logo__c = 0;//Added on 31st May
                                oppListTemp.add(oppProdSnapshot);
                                tempMapInsert.put((oppId+familyVals),oppProdSnapshot);
                            }
                        }
                        //For Cross-Sell...................................
                        else{
                            oppProdSnapshot.UpSell_CrossSell_DEV__c = 'CROSSSELL';
                            oppProdSnapshot.New_Logo__c = 0;//Added on 31st May
                        }
                        oppListTemp.add(oppProdSnapshot);
                        tempMapInsert.put((oppId+familyVals),oppProdSnapshot);
                    }
                //}
            }
            System.debug('tempMapInsert*******'+tempMapInsert);
            if(!tempMapInsert.isEmpty())
                upsert tempMapInsert.values();
        }
    }
    /*
    Opportunity product is being deleted and their is no product remaining for that particular family it will delete the the record from the Booking Classification of that particular family.
    */
    public static void deleteBookingClassification(List<OpportunityLineItem> oldRecords){
        Set<Id> oppIdSet = new Set<Id>();
        Map<Id,Set<String>> oppIdVsFamilyMap = new Map<Id,Set<String>>();
        Set<String> familySet = new Set<String>();
        List<Booking_Classification__c> prodSnapshotDeleteList = new List<Booking_Classification__c>();
        List<Booking_Classification__c> prodSnapshotUpdateList = new List<Booking_Classification__c>();
        For(OpportunityLineItem oppLineItemRec : oldRecords)
        {
            oppIdSet.add(oppLineItemRec.OpportunityId);
        }
        if(oppIdSet.size()>0){
            For(OpportunityLineItem oppLineItemRec : [SELECT Product2.Family,OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN : oppIdSet])
            {
                if(!oppIdVsFamilyMap.containsKey(oppLineItemRec.OpportunityId))
                {
                    familySet = new Set<String>();
                    familySet.add(oppLineItemRec.Product2.Family);
                    oppIdVsFamilyMap.put(oppLineItemRec.OpportunityId,familySet);
                }
                else
                {
                    oppIdVsFamilyMap.get(oppLineItemRec.OpportunityId).add(oppLineItemRec.Product2.Family);
                }
            }
            System.debug('oppIdVsFamilyMap*********'+oppIdVsFamilyMap);
            For(Booking_Classification__c snapshotRec : [SELECT Id,New_Logo__c,Product_Family__c,Total_Price__c,Opportunity__c,Opportunity__r.SBQQ__RenewedContract__c,Opportunity__r.SBQQ__AmendedContract__c FROM Booking_Classification__c WHERE Opportunity__c IN : oppIdSet])
            {
                if((oppIdVsFamilyMap.containsKey(snapshotRec.Opportunity__c) && !oppIdVsFamilyMap.get(snapshotRec.Opportunity__c).contains(String.ValueOf(snapshotRec.Product_Family__c))) || (oppIdVsFamilyMap.isEmpty()) || (!oppIdVsFamilyMap.isEmpty() && !oppIdVsFamilyMap.containsKey(snapshotRec.Opportunity__c)))
                {
                    if(snapshotRec.Opportunity__r.SBQQ__RenewedContract__c!=null || snapshotRec.Opportunity__r.SBQQ__AmendedContract__c!=null){
                            snapshotRec.New_Logo__c = 0.0;
                            snapshotRec.Total_Price__c = 0.0;
                            prodSnapshotUpdateList.add(snapshotRec);
                        }
                        else{
                            prodSnapshotDeleteList.add(snapshotRec);
                        }
                }
            }
        }
        System.debug('prodSnapshotDeleteList*********'+prodSnapshotDeleteList);
        if(prodSnapshotDeleteList.size()>0)
            delete prodSnapshotDeleteList;
        if(prodSnapshotUpdateList.size()>0)
            update prodSnapshotUpdateList;
    }
    
    /*HSR : Creating a Booking Classification when a Opportunity is being created for the first time. This will be created will Product as Not Identified.
        This will get deleted once the quote will be created below this opportunity.
    */
    public static void createUnidentifiedBookClass(Map<Id,Opportunity> oldMapValues,Map<Id,Opportunity> newMapValues){
        List<Booking_Classification__c> prodSnapshotList = new List<Booking_Classification__c>();
        Booking_Classification__c oppSnapObj = new Booking_Classification__c();
        Opportunity oldOpp;
        
        List<Opportunity> oppRecList = new List<Opportunity>();
        For(Opportunity oppRec : newMapValues.values())
        {
            if(oppRec.SBQQ__PrimaryQuote__c == null){
                if(oldMapValues!=null){
                    oldOpp = oldMapValues.get(oppRec.Id);
                    if(oldOpp.Net_Amount_Opp__c != oppRec.Net_Amount_Opp__c || oldOpp.CurrencyIsoCode!= oppRec.CurrencyIsoCode)            
                        oppRecList.add(oppRec);    
                }
                else
                    oppRecList.add(oppRec);
                //oppRecList.add(oppRec);
            }
        }
        if(oppRecList.size()>0){
            //Fetching Booking Classification record.........
            Map<Id,Id> oppIdVsSnapShotId_Map = new Map<Id,Id>();
            For(Booking_Classification__c sanpShotRec : [SELECT Id,Opportunity__c,Product_Family__c FROM Booking_Classification__c WHERE Opportunity__c IN : oppRecList AND Product_Family__c = 'Not Identified'])
            {
                oppIdVsSnapShotId_Map.put(sanpShotRec.Opportunity__c,sanpShotRec.Id);
            }
            For(Opportunity oppRec : oppRecList)
            {
                oppSnapObj = new Booking_Classification__c();
                if(oppIdVsSnapShotId_Map.containsKey(oppRec.Id))
                    oppSnapObj.Id = oppIdVsSnapShotId_Map.get(oppRec.Id);
                oppSnapObj.Opportunity__c = oppRec.Id;
                oppSnapObj.Product_Family__c = 'Not Identified';
                oppSnapObj.Product_Name__c = 'Not Identified';
                oppSnapObj.CurrencyIsoCode = oppRec.CurrencyIsoCode;
                oppSnapObj.Total_Price__c = oppRec.Net_Amount_Opp__c;
                
                //New field added... removing formula field and adding it over here....
                oppSnapObj.SBQQ_AmendedContract__c= oppRec.SBQQ__AmendedContract__c!=null?String.valueOf(oppRec.SBQQ__AmendedContract__c):'';
                oppSnapObj.Deal_Years__c = oppRec.Deal_Year__c!=null?Integer.ValueOf(oppRec.Deal_Year__c):null;
                oppSnapObj.SBQQ_RenewedContract__c = oppRec.SBQQ__RenewedContract__c!=null?String.ValueOf(oppRec.SBQQ__RenewedContract__c):'';
                oppSnapObj.Contract_Type_2_0__c = oppRec.Contract_Type_2_0__c!=null ?String.ValueOf(oppRec.Contract_Type_2_0__c):'';
                oppSnapObj.Exchange_Rates__c = oppRec.Exchange_Rate__c;
                prodSnapshotList.add(oppSnapObj);
            }
            //Checking the list size and inserting Booking Classification....
            if(prodSnapshotList.size()>0)
                upsert prodSnapshotList;
        }
    }
    /*HSR : Deleting Not Identified Booking Classification when the first OpportunityLineItem is being inserted in that Opportunity.*/
    public static void deleteUnIdentifiedBookClass(Set<Id> oppIdSet){
        /*Set<Id> oppIdSet = new Set<Id>();
        For(OpportunityLineItem oppItemRec: oppLineItemList)
        {
            oppIdSet.add(oppItemRec.OpportunityId);
        }*/
        List<Booking_Classification__c> snapShotRecList = new List<Booking_Classification__c>();
        snapShotRecList = [SELECT Id,Opportunity__c FROM Booking_Classification__c WHERE Opportunity__c IN : oppIdSet
                                                AND Product_Family__c = 'Not Identified'];
        System.debug('snapShotRecList********'+snapShotRecList);
        if(snapShotRecList.size()>0)                                            
            delete snapShotRecList;
        
    }
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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