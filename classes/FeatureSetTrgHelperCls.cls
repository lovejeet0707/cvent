/**
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 6th Jan 2015
Description : To update field Milestone Check on feature creation and updation. 
Version :   2.0
Date:5 July 2016
Description : Onsite solutions object record creation
Version :   3.0
Date:30 Sep 2016
Modified By : HSR
Description : Non-renewable/Renewable field status update


Version 4.0
Date:7th Nov 2016
Description : Migrating FEATURESET to PRODUCT/PRICEBOOK. Below are the name of the field which needs to be replaced - 

OLD FIELD NAME       = NEW FIELD NAME

Feature_Sets__r      = OpportunityLineItems;
R00N00000008aGEXEA2  = OpportunityLineItems;
Feature_Set__c       = OpportunityLineItem;
Feature__c           = Product_Name__c;
Opportunity_N__c     = OpportunityId;

//Lines Commented as Can't update CurrencyISOCode of OpportunityLineItem

Version 5.0
Date : 29th June 2017
Description : Updating the values of "NBB New Account / New Logo,NBB – Cross Sell,NBB – Upsell,MYD" for CPQ process
*/

public class FeatureSetTrgHelperCls {
    
    public static List<Feature__c> listLFeature = new List<Feature__c>();
    public static map<String,String> mapPickValAssign = new map<String,String>();
    public set<Id> setIdOpp = new set<Id>();
    public List<Date> lstDate = new List<Date>();
    
    Set<String> NRFeatureSet=new Set<String>();
    
    //Onsite solutions object record creation
    public static List<FeatureSetsForOnsiteProj__c> lstFeatureSets = new List<FeatureSetsForOnsiteProj__c>();
    public static Set<String> setFeatureSetsCust = new Set<String>();
    //Onsite solutions object record creation
    static{
        listLFeature = Feature__c.getall().values();
        for(Feature__c instOfFeature : listLFeature){
            if(instOfFeature.Assignment__c.trim() == 'Milestone')
            mapPickValAssign.put(instOfFeature.Picklist_Values__c.trim(),instOfFeature.Assignment__c.trim());
        }
        //Onsite solutions object record creation
        lstFeatureSets = FeatureSetsForOnsiteProj__c.getall().values();
        for(FeatureSetsForOnsiteProj__c instOfFeatSet : lstFeatureSets){
          setFeatureSetsCust.add(instOfFeatSet.Name);
        }
        //Onsite solutions object record creation
    }
    
    /*
     Constructor
     Add by : Kumud
    */
    public FeatureSetTrgHelperCls(){
        
        String tempData;
        List<OpportunityLineItem> featureSetList=new List<OpportunityLineItem >();
        For(String NRFeature : Label.Non_Renewable_Feature_Set.Split(','))
        {
            tempData=NRFeature.replaceAll( '\\s+', '');
            NRFeatureSet.add(tempData);
        }
        For(String NRFeature : Label.Non_Renewable_Feature_Set2.Split(','))
        {
            tempData=NRFeature.replaceAll( '\\s+', '');
            NRFeatureSet.add(tempData);
        }
        For(String NRFeature : Label.Non_Renewable_Feature_Set3.Split(','))
        {
            tempData=NRFeature.replaceAll( '\\s+', '');
            NRFeatureSet.add(tempData);
        }
        For(String NRFeature : Label.Non_Renewable_Feature_Set4.Split(','))
        {
            tempData=NRFeature.replaceAll( '\\s+', '');
            NRFeatureSet.add(tempData);
        }
        
        
    }
    public void OnBeforeInsert(List<OpportunityLineItem> newValues){
        /* 29th June 2017 HSR : Updating the values of "NBB New Account / New Logo,NBB – Cross Sell,NBB – Upsell,MYD"  for CPQ process*/
        //Replaced with BCT updateReportingClassification(newValues);
        /*...............................ENDS HERE...................................*/
        /* 09/30/2016 Hemant: Non-renewable/Renewable field status update*/
        
        /*.....................ENDS HERE........................*/
        for(OpportunityLineItem instOfFeature : newValues){
            system.debug('SizeOfnew values::'+newvalues.size()+ 'List '+newValues);
            system.debug('Product__c'+instOfFeature.Product__c);
              /* 09/30/2016 Hemant: Non-renewable/Renewable field status update*/
            if(instOfFeature.Product__c=='Event' || instOfFeature.Product__c=='Survey' || instOfFeature.Product__c=='Cvent Connect')
            {
                String tempFeatureSet=instOfFeature.Product_Name__c.replaceAll( '\\s+', '');
                if(NRFeatureSet.contains(tempFeatureSet))
                {
                    System.debug('*****#CheckPoint*********');
                    instOfFeature.Renewable_Non_Renewable__c='Non Renewable Feature(Event/Survey/CC)';
                    //featureSetList.add(fsObj);
                }
            }
            /*................................ENDS HERE......................*/
            if(mapPickValAssign.containsKey(instOfFeature.Product_Name__c)){
                instOfFeature.Milestone_Check__c = true;
            }
            if(instOfFeature.OpportunityId != null)
            setIdOpp.add(instOfFeature.OpportunityId);
             
        }
        
        map<Id,Opportunity> mapOpp = new map<Id,Opportunity>();
        
        if(setIdOpp.size() > 0)
        mapOpp = new map<Id,Opportunity>([SELECT Id,CloseDate,CurrencyIsoCode,Exchange_Rate__c FROM Opportunity WHERE Id =:setIdOpp]);
        
        //map<Id,Id> mapOppId = new map<Id,Id>();
        
        for(OpportunityLineItem instOfFeature : newValues){
            if(mapOpp.containsKey(instOfFeature.OpportunityId)){
                //instOfFeature.CurrencyIsoCode = mapOpp.get(instOfFeature.OpportunityId).CurrencyIsoCode;//Lines Commented as Can't update CurrencyISOCode of OpportunityLineItem
                instOfFeature.Exchange_Rate__c = mapOpp.get(instOfFeature.OpportunityId).Exchange_Rate__c;
            }
        }
        /*
        for(Opportunity instOfOpp : mapOpp.Values()){
            if(instOfOpp.CloseDate != null)
            lstDate.add(instOfOpp.CloseDate); 
            
            
            
            if(instOfOpp.CloseDate >= system.today()){
                mapOppId.put(instOfOpp.Id,instOfOpp.Id);
            }
            
        }*/
        /*
        List<DatedConversionRate> lstDateCR =  [SELECT StartDate, IsoCode, ConversionRate FROM DatedConversionRate WHERE (StartDate =: lstDate OR StartDate =: system.Today())];
        
        map<String,Decimal> mapConv =  new map<String,Decimal>();
        for(DatedConversionRate isntOfDCR : lstDateCR){
            system.debug('isntOfDCR.StartDate+++'+isntOfDCR.StartDate);
            system.debug('system.today()+++'+system.today());
            if(isntOfDCR.StartDate == system.today()){
                mapConv.put(isntOfDCR.IsoCode,isntOfDCR.ConversionRate);
            }
        }
        
        for(OpportunityLineItem instOfFeature : newValues){
            if(instOfFeature.OpportunityId != null){
                if(mapOppId.ContainsKey(instOfFeature.OpportunityId)){
                    Opportunity instOfOpp = mapOpp.get(instOfFeature.OpportunityId);
                    if(mapConv.containsKey(instOfOpp.CurrencyIsoCode))
                    instOfFeature.Exchange_Rate__c  = mapConv.get(instOfOpp.CurrencyIsoCode);
                }else{
                    Opportunity instOfOpp = mapOpp.get(instOfFeature.OpportunityId);
                    for(DatedConversionRate isntOfDCR : lstDateCR ){
                        if(instOfOpp.CloseDate ==  isntOfDCR.StartDate && instOfOpp.CurrencyIsoCode == isntOfDCR.IsoCode){
                            instOfFeature.Exchange_Rate__c =  isntOfDCR.ConversionRate;  
                        }
                    } 
                }
            }
        }*/
    }
    public void OnAfterInsert(Map<Id,OpportunityLineItem> newMapValues){
        Map<String,Id> reassignToVsFromIdMap = new Map<String,Id>();
        Set<String> reassignIdSet = new Set<String>();
        Set<Id> renewedOppIdSet = new Set<Id>();
        //Onsite solutions object record creation
        Set<Id> setOpptId = new Set<Id>();
         
        for(OpportunityLineItem instOfFeature : newMapValues.Values()){
            if(String.isNotBlank(instOfFeature.ReassignedFromOpportunityId__c)){
                reassignIdSet.add(instOfFeature.ReassignedFromOpportunityId__c);
                reassignToVsFromIdMap.put(instOfFeature.ReassignedFromOpportunityId__c,instOfFeature.OpportunityId);
            }
            renewedOppIdSet.add(instOfFeature.OpportunityId);
          if(instOfFeature.Product__c != null){
            if(setFeatureSetsCust.contains(instOfFeature.Product__c)){
              setOpptId.add(instOfFeature.OpportunityId);
            }  
          }
        }
        System.debug('renewedOppIdSet*******'+renewedOppIdSet);
        List<Opportunity> lstOppQ = new List<Opportunity>();
        
        if(setOpptId.size()>0)
        lstOppQ = [SELECT ID FROM Opportunity WHERE Id=: setOpptId];
        
        List<Opportunity> lstOppUpd = new List<Opportunity>();
        
        for(Id oppID:setOpptId){
            
            Opportunity instOfOpp=new Opportunity(id=oppID,Alliance_Tech_CheckBox__c=true);
            lstOppUpd.add(instOfOpp);
        }
        
        /*for(Opportunity instOfOpp : lstOppQ){
          instOfOpp.Alliance_Tech_CheckBox__c = true;
          lstOppUpd.add(instOfOpp);
        }  comment by kumud*/
        
        if(!lstOppUpd.isEmpty())
            update lstOppUpd;
        
        //Onsite solutions object record creation
        System.debug('Inside Method');
        //Opportunity SnapShot Object created..........
        if(renewedOppIdSet.size()>0 && CheckRecursive.runEleven() && Label.IsBCActive=='True'){// && UserInfo.getUserId() == '005o0000002jzhMAAQ'
            SnapShotUtilityHelper.CreateOppProdSnapshot(null,renewedOppIdSet,reassignIdSet,reassignToVsFromIdMap);
        }
        //Opportunity SnapShot Object created for one-off Opportunity..........
        if(renewedOppIdSet.size()>0 && CheckRecursive.runTwentyTwo() && Label.IsOneOffBCActive=='True'){// && UserInfo.getUserId() == '005o0000002jzhMAAQ'
            SnapShotUtilityHelper_OneOff.CreateOppProdSnapshot(renewedOppIdSet);
        }

        //Added on 3/06/2018 to Rollup Quantity on Web Design Support on Opp
        RollupWebDesignSupportOnOpp(renewedOppIdSet);

    }
    public void OnBeforeUpdate(Map<Id,OpportunityLineItem> oldMapValues,Map<Id,OpportunityLineItem> newMapValues){
        /* 09/30/2016 Hemant: Non-renewable/Renewable field status update*/
       
        List<OpportunityLineItem> listOppLineItem = new List<OpportunityLineItem>();
       /*...............................ENDS HERE................................*/
        for(OpportunityLineItem instOfFeature : newMapValues.Values()){
            OpportunityLineItem oldLineVal = oldMapValues.get(instOfFeature.Id);
            /*if(oldLineVal.NBB_Value__c != instOfFeature.NBB_Value__c || oldLineVal.Renewal_Value__c != instOfFeature.Renewal_Value__c)
                listOppLineItem.add(instOfFeature);*/
            /* 29th June 2017 HSR : Updating the values of "NBB New Account / New Logo,NBB – Cross Sell,NBB – Upsell,MYD"  for CPQ process*/
            /*OpportunityLineItem oldLineVal = oldMapValues.get(instOfFeature.Id);
            if(oldLineVal.NBB_Value__c != instOfFeature.NBB_Value__c)
            {
                instOfFeature.NBB_Upsell__c = instOfFeature.NBB_Value__c;
                
                else if(instOfFeature.MYD__c !=null && instOfFeature.MYD__c >0)
                {
                    instOfFeature.MYD__c = instOfFeature.NBB_Value__c;
                    instOfFeature.Renewal_Value__c = 0;
                }
                else if(instOfFeature.NBB_Cross_Sell__c !=null && instOfFeature.NBB_Cross_Sell__c >0)
                {
                    instOfFeature.NBB_Cross_Sell__c= instOfFeature.NBB_Value__c;
                }
                listOppLineItem.add(instOfFeature);
            }*/
            /*if(instOfFeature.Renewal_Value__c!=null && instOfFeature.Renewal_Value__c>0){
                instOfFeature.MYD__c = instOfFeature.Renewal_Value__c;
                instOfFeature.Renewal_Value__c = 0;
            }*/
            /*...............................ENDS HERE...................................*/
            /* 09/30/2016 Hemant: Non-renewable/Renewable field status update*/
            if(instOfFeature.Product__c=='Event' || instOfFeature.Product__c=='Survey' || instOfFeature.Product__c=='Cvent Connect')
            {
                String tempFeatureSet=instOfFeature.Product_Name__c.replaceAll( '\\s+', '');
                if(NRFeatureSet.contains(tempFeatureSet))
                {
                    System.debug('*****#CheckPoint*********');
                    instOfFeature.Renewable_Non_Renewable__c='Non Renewable Feature(Event/Survey/CC)';
                    //featureSetList.add(fsObj);
                }
            }
            /*..............................ENDS HERE..................................*/
            if(mapPickValAssign.containsKey(instOfFeature.Product_Name__c)){
                instOfFeature.Milestone_Check__c = true;
            }else{
                instOfFeature.Milestone_Check__c = false;
            }
        }
        
        /* 29th June 2017 HSR : Updating the values of "NBB New Account / New Logo,NBB – Cross Sell,NBB – Upsell,MYD"  for CPQ process*/
        /*Replaced by BCT
            if(listOppLineItem.size()>0)
            updateReportingClassification(listOppLineItem);*/
        /*...............................ENDS HERE...................................*/
    }
    public void OnAfterUpdate(Map<Id,OpportunityLineItem> oldMapValues,Map<Id,OpportunityLineItem> newMapValues){
      //Onsite solutions object record creation
        Map<String,Id> reassignToVsFromIdMap = new Map<String,Id>();
        Set<Id> setOpptId = new Set<Id>();
        Set<Id> renewedOppIdSet = new Set<Id>();
        Set<Id> oppIdWebdesignSet= new Set<Id>();
        //....Reaasigned To Opp Id Set....
        Set<String> reassignIdSet = new Set<String>();
         //Booking Classification One-off Opportunity....
        Set<Id> setOneOffOpptId = new Set<Id>();
        for(OpportunityLineItem instOfFeature : newMapValues.Values()){
            //If quantity is changed, rollup to Web Design Support
            if(instOfFeature.Quantity!=oldMapValues.get(instOfFeature.Id).Quantity){
                oppIdWebdesignSet.add(instOfFeature.OpportunityId);
            }
            //....Reaasigned To Opp Id Check....
            if(String.isNotBlank(instOfFeature.ReassignedFromOpportunityId__c)){//&& instOfFeature.ReassignedFromOpportunityId__c != oldMapValues.get(instOfFeature.Id).ReassignedFromOpportunityId__c
                reassignIdSet.add(instOfFeature.ReassignedFromOpportunityId__c);
                  reassignToVsFromIdMap.put(instOfFeature.ReassignedFromOpportunityId__c,instOfFeature.OpportunityId);
              }
              if(instOfFeature.Quantity!=oldMapValues.get(instOfFeature.Id).Quantity ||instOfFeature.UnitPrice!=oldMapValues.get(instOfFeature.Id).UnitPrice||  instOfFeature.TotalPrice!=oldMapValues.get(instOfFeature.Id).TotalPrice){
                  setOneOffOpptId.add(instOfFeature.OpportunityId);
              }
          renewedOppIdSet.add(instOfFeature.OpportunityId);
          if(instOfFeature.Product__c != null && instOfFeature.Product__c  != oldMapValues.get(instOfFeature.Id).Product__c){
            if(setFeatureSetsCust.contains(instOfFeature.Product__c)){
              setOpptId.add(instOfFeature.OpportunityId);
            }  
          }
        }
        //Opportunity SnapShot Object created for one-off Opportunity..........
        if(setOneOffOpptId.size()>0 && CheckRecursive.runTwentyTwo() && Label.IsOneOffBCActive=='True'){// && UserInfo.getUserId() == '005o0000002jzhMAAQ'
            SnapShotUtilityHelper_OneOff.CreateOppProdSnapshot(setOneOffOpptId);
        }
         //Opportunity SnapShot Object created..........
        if(renewedOppIdSet.size()>0 && CheckRecursive.runEleven() && Label.IsBCActive=='True')//  && UserInfo.getUserId() == '005o0000002jzhMAAQ'
            SnapShotUtilityHelper.CreateOppProdSnapshot(null,renewedOppIdSet,reassignIdSet,reassignToVsFromIdMap);
        List<Opportunity> lstOppQ = new List<Opportunity>();
        
        //if(setOpptId.size()>0)
        //lstOppQ = [SELECT ID FROM Opportunity WHERE Id=: setOpptId];
        
        List<Opportunity> lstOppUpd = new List<Opportunity>();
        
        for(Id oppId:setOpptId){
            
            Opportunity instOfOpp=new Opportunity(ID=oppId,Alliance_Tech_CheckBox__c = true);
            lstOppUpd.add(instOfOpp);
        }
        /*for(Opportunity instOfOpp : lstOppQ){
          instOfOpp.Alliance_Tech_CheckBox__c = true;
          lstOppUpd.add(instOfOpp);
        }*/
        
        if(!lstOppUpd.isEmpty())
            update lstOppUpd;
        //Onsite solutions object record creation
        if(CheckRecursive.runTwentyThree())
        RollupWebDesignSupportOnOpp(oppIdWebdesignSet);
    }
    public void OnBeforeDelete(List<OpportunityLineItem> oldValues,Map<Id,OpportunityLineItem> oldMapValues){        
        
    }
    public void OnAfterDelete(List<OpportunityLineItem> oldValues,Map<Id,OpportunityLineItem> oldMapValues){
        if(Label.IsBCActive=='True')
            SnapShotUtilityHelper.deleteBookingClassification(oldValues);
        //updateReportingClassification(oldValues);
      //Onsite solutions object record creation
      Set<Id> oppIds = new Set<Id>();
      Set<Id> setOpptId = new Set<Id>();
      Set<Id> renewedOppIdSet = new Set<Id>();
        for(OpportunityLineItem instOfFeature : oldMapValues.Values()){
            renewedOppIdSet.add(instOfFeature.OpportunityId);
           if(instOfFeature.Product__c != null){
            if(setFeatureSetsCust.contains(instOfFeature.Product__c)){
              setOpptId.add(instOfFeature.OpportunityId);
            }  
          }
        }
        
        List<Opportunity> lstOppQ = new List<Opportunity>();
        
        if(setOpptId.size()>0)
        lstOppQ = [SELECT ID,(SELECT Id,Product__c FROM OpportunityLineItems) FROM Opportunity WHERE Id=: setOpptId]; //Alliance_Tech_CheckBox__c  comment by kd
        
        List<Opportunity> lstOppUpd = new List<Opportunity>();
        
        Integer counter = 0;
        for(Opportunity instOfOpp : lstOppQ){
        counter = 0;
          for(OpportunityLineItem instOfFeatSet : instOfOpp.OpportunityLineItems){
            if(setFeatureSetsCust.contains(instOfFeatSet.Product__c)){
              counter++;
            }
          }
          /*if(counter == 0)
          instOfOpp.Alliance_Tech_CheckBox__c = false;*/
          
          lstOppUpd.add(instOfOpp);
        }
        
        if(lstOppUpd.size()>0)
        update lstOppUpd;
      
      //Onsite solutions object record creation

      //Added on 3/06/2018 to Rollup Quantity on Web Design Support on Opp
      RollupWebDesignSupportOnOpp(renewedOppIdSet);
    
    }
    public void OnUndelete(List<OpportunityLineItem> newValues){
        
    }
    /*This is replaced by BCT
    public void updateReportingClassification(List<OpportunityLineItem> oppListItemList){
        System.debug('Inside this Method Chekc');
        Set<String> productFamilySet = new Set<String>();
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        Map<Id,Opportunity> oppIdVsOppObjMap = new Map<Id,Opportunity>();
        Boolean check = false;
        Boolean checkFirst = false;
        For(OpportunityLineItem oppItem : oppListItemList)
        {
            oppIdSet.add(oppItem.OpportunityId);
            productFamilySet.add(oppItem.Product_Family__c);
        }
        For(Opportunity oppRec : [SELECT Id,AccountId,NBB_Renewal__c , SBQQ__PrimaryQuote__r.Current_Year__c FROM Opportunity WHERE Id IN : oppIdSet])
        {
            oppIdVsOppObjMap.put(oppRec.Id,oppRec);
            accIdSet.add(oppRec.AccountId);
        }
        Map<Id,List<Customer_Asset__c>> accIdVsCustomAssetMap = new Map<Id,List<Customer_Asset__c>>();
        For(Customer_Asset__c customerAssetRec : [SELECT Id,Account__c,Asset_Status__c,Product_Family__c,Annual_Recurring_Revenue__c,Product__c FROM Customer_Asset__c WHERE Account__c IN : accIdSet AND (Asset_Status__c='Active' OR Asset_Status__c='On Maintenance')])
        {
            if(!accIdVsCustomAssetMap.containsKey(customerAssetRec.Account__c))
            {
                accIdVsCustomAssetMap.put(customerAssetRec.Account__c,new List<Customer_Asset__c>{customerAssetRec});
            }
            else{
                accIdVsCustomAssetMap.get(customerAssetRec.Account__c).add(customerAssetRec);
            }
        }
        System.debug('accIdVsCustomAssetMap******'+accIdVsCustomAssetMap);
        For(OpportunityLineItem oppLineObj : oppListItemList)
        {
            /*
            ***
            This condition is for current year = 1 deal................
            ***
            
            if(oppIdVsOppObjMap.get(oppLineObj.OpportunityId).SBQQ__PrimaryQuote__r.Current_Year__c == 1)
            {
                if(accIdVsCustomAssetMap.containsKey(oppIdVsOppObjMap.get(oppLineObj.OpportunityId).AccountId))
                {
                    For(Customer_Asset__c customerAssetRec : accIdVsCustomAssetMap.get(oppIdVsOppObjMap.get(oppLineObj.OpportunityId).AccountId))
                    {
                        if(oppLineObj.Product_Family__c == customerAssetRec.Product_Family__c)
                        {
                            oppLineObj.NBB_Cross_Sell__c =0;
                            oppLineObj.NBB_Upsell__c = oppLineObj.NBB_Value__c;
                            break;
                        }
                        else
                        {
                            oppLineObj.NBB_Upsell__c = 0;
                            oppLineObj.NBB_Cross_Sell__c = oppLineObj.NBB_Value__c;
                        }
                    }
                }
                else{
                    oppLineObj.NBB_New_Account_New_Logo__c = oppLineObj.NBB_Value__c;
                }
            }
            /*............................ENDS HERE.......................*/
            /*
            ***
           This condition is for current year > 1 deal................
            ***
            *
            else{
                if(accIdVsCustomAssetMap.containsKey(oppIdVsOppObjMap.get(oppLineObj.OpportunityId).AccountId))
                {
                    For(Customer_Asset__c customerAssetRec : accIdVsCustomAssetMap.get(oppIdVsOppObjMap.get(oppLineObj.OpportunityId).AccountId))
                    {
                        oppLineObj.NBB_Cross_Sell__c = 0;
                        if(oppLineObj.Product_Family__c == customerAssetRec.Product_Family__c && oppLineObj.Product2Id == customerAssetRec.Product__c)
                        {
                            oppLineObj.MYD__c = oppLineObj.Renewal_Value__c;
                            oppLineObj.NBB_Upsell__c = oppLineObj.NBB_Value__c;
                            oppLineObj.Renewal_Value__c = 0;
                            break;
                        }
                        else
                        {
                            oppLineObj.NBB_Cross_Sell__c = oppLineObj.NBB_Value__c;
                        }
                    }
                }
                else{
                    oppLineObj.NBB_Upsell__c = 0 ;
                    oppLineObj.NBB_Cross_Sell__c = oppLineObj.NBB_Value__c;
                }
            }
        }
    }

    */
    /**
    ** Added By: Shanu Aggarwal
    ** Web Design Support Roll up 
    ** Roll up Quantity From OpportunityLineItem to Web Design Support on Opportunity 
    ** Added on 03/06/2018
    **/
    public static void RollupWebDesignSupportOnOpp(Set<Id> oppIds){
        
        List<Opportunity> updateList = new List<Opportunity>();
        Map<Id,Decimal> oppVsDesignSupport = new Map<Id,Decimal>();

        for(AggregateResult ar: [Select SUM(Quantity)qty, OpportunityId from OpportunityLineItem Where OpportunityId IN:oppIds AND product2.productcode = 'CV-SU-EC-EVT-WEBDESSUP' AND (Opportunity.StageName='Closed Won' OR Opportunity.StageName='Follow-up – Missing/Erroneous Contract' OR Opportunity.StageName='Pushed – Missing/Erroneous Contract' OR Opportunity.StageName='Closed Won – Do Not Send to EBS' OR Opportunity.StageName='Closed Won - AR Settlement' OR Opportunity.StageName='Closed Won – Legal Opt Out' OR Opportunity.StageName='Closed Won - PreAcquisition') Group BY OpportunityId]){
            
            oppVsDesignSupport.put((Id)ar.get('OpportunityId'),(Decimal)ar.get('qty'));
            
        }
        //Remaining Opportunities which doesn't have any line item , reset to 0
        oppIds.removeAll(oppVsDesignSupport.keySet());

        if(oppIds.size()>0){
            for(Id oppId : oppIds){
                oppVsDesignSupport.put(oppId,0);
            }
        }
        
        //Update the count
        if(!oppVsDesignSupport.isEmpty()){
            //  change by kumud
            for(Id instOppID:oppVsDesignSupport.keySet()){
                
               /* if(instOppID!=null && string.valueOf(instOppID).startsWith('006')){  comment by kd
                    
                    Opportunity oppObj = new Opportunity(Id=instOppID, Web_Design_Support_Minutes_Purchased__c=oppVsDesignSupport.get(instOppID));
                    updateList.add(oppObj);
                }*/
                
                
            } // end 
            
            /*for(Opportunity opp: [Select Id From Opportunity Where ID IN: oppVsDesignSupport.keySet() and (StageName='Closed Won' OR StageName='Follow-up – Missing/Erroneous Contract' OR StageName='Pushed – Missing/Erroneous Contract' OR StageName='Closed Won – Do Not Send to EBS' OR StageName='Closed Won - AR Settlement' OR StageName='Closed Won – Legal Opt Out' OR StageName='Closed Won - PreAcquisition')]){
            
                Opportunity oppObj = new Opportunity(Id=opp.Id, Web_Design_Support_Minutes_Purchased__c=oppVsDesignSupport.get(opp.Id));
                updateList.add(oppObj);
            }*/
            if(!updateList.isEmpty()){
                update updateList;
            }

        }
    }
}