/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 20th June 2014
Description : Inserts, Contact Role for Opportunity with stage name Closed Won on insert and update .
Version :   2.0
Date : 5th Aug 2014
Description : Changes for CSN-MSA Records updation and insertion.
Version :   3.0
Date : 12th Aug 2014
Description : Changes for Bundle Campaigns Records updation and insertion.
Version :   4.0
Date : 21st Aug 2014
Description : To insert multiple opportunity contact roles on the basis of account associated to the opportunity and contacts under which activities are logged beyond 6 months.
Version : 5.0
Date : 24th Nov 2014
Description : (Tract)-Whenever an opportunity with with unique contract number is inserted create two more opportunities with Straight and Milestone Role ups respectively . 
Version : 6.0
Date : 23rd Jan 2015
Description : (Tract)-On updating Opp currency, Children currency should get updated. 
Version : 7.0
Date : 9th Mar 2015
Description : (Tract)-On updating and insert get currency rate, Children currency and curreny rate should get updated. 
Version : 8.0
Date : 17th April 2015
Description : (Tract-Compliance)-Concept to move opps for reviewing.
Version : 9.0
Date : 20th April 2015
Description : Auto movement to tract .
Version : 10.0
Date : 9th July 2015
Description : Adjusting the cancellation amount .
Version : 11.0
Date : 27th July 2015
Description : Changes related to selected opps movement.
Version : 12.0
Date : 31st July 2015
Description : Validation for Tract Opportunity Regarding Rev Rec Rules.
Version 13.0
Date : 10th August 2015
Description : Validation For sending deal year 1  opp first
Version 14.0
Date : 27th August 2015
Description : New TCV creation concept for CSN and DPS types
Version 15.0
Date:2 Sept 2015
Description : Probability updation concept.
Version 16.0
Date:14 Sept 2015
Description : Updating contracts record on any opp. 
Date:03 Dec 2015
Description : Changes to product category for TPP 
Date: 14 Dec 2015
Decsription :  change - new feature set added
Date: 24 Dec 2015       
Description : Clubbed TRACT billing account for CSN
Date: 3 Feb 2016
Description: Feature value null on Feature sets - new code added to avoid null pointer exception if no feature selected in feature set
Version 17.0
Date:10 Mar 2016
Description : Updating according to the field value Set_Cancellation_Status__c
Version 18.0
Date:11 April 2016
Description : For Onsite Product Product Category Changes
Version 19.0
Date:26 April 2016
Description : Sales Engineering
Version 20.0
Date:9th May 2016
Description : For inserting Contract Review record for TCV in cancellation process. 
Version 21.0
Date:25 May 2016
Description : Remove TAB Character from some of the Opportunity fields
Version 22.0
Date:5 July 2016
Description : Onsite solutions object record creation
Version 23.0
Date:29 Sep 2016
Description : Inserting Parent Opp Contract End Date in the Upsell Contract Opp "Contract_End_Date_Parent_Opp__c" field(Used below in 8 places)
Version 24.0
Date:7th Nov 2016
Description : Migrating FEATURESET to PRODUCT/PRICEBOOK. Below are the name of the field which needs to be replaced - 
    OLD FIELD NAME       = NEW FIELD NAME
    Feature_Sets__r      = OpportunityLineItems;
    R00N00000008aGEXEA2  = OpportunityLineItems;
    Feature_Set__c       = OpportunityLineItem;
    Feature__c           = Product_Name__c; (IMP : CAN'T DO CTRL+F AND CTRL+R AND NEED TO CHECK BEFORE REPLACING AS THEIR IS A CUSTOM SETTING OF SAME NAME "Feature__c")
    
//Lines Commented as Can't update CurrencyISOCode of OpportunityLineItem

Version 25.0
Date:12th Apr 2017
Author: Karl Andrzejewski (ATG)
Description : Renamed Contract.Opportunity__c to Contract.Primary_Opportunity__c to avoid CPQ conflict.
Modified : 30 May 2018 : Kumud: Remove the Event venue,country,state,city, as a field cleanup activity and removed fake methods
*/

public class OpportunityTrgHelperCls {
        
 
  
    
    //Probability updation concept.
    public static List<Probability__c> lstprobablity = new List<Probability__c>();
    public static map<String,Decimal> mapStageProdProb = new map<String,Decimal>();
    public static set<String> setStageName = new set<String>();
    //Probability updation concept.
    
    //Onsite solutions object record creation
    public static List<UserAssignment__c> lstUserAssign = new List<UserAssignment__c>();
    public static String strRecTyDevName ;
    public static String strUsrName;
    public static String strRecTyId;
    public static String strUsrId;
    public static List<FeatureSetsForOnsiteProj__c> lstFeatureSets = new List<FeatureSetsForOnsiteProj__c>();
    public static Set<String> setFeatureSetsCust = new Set<String>();
    //Onsite solutions object record creation
    
    static{
       
        strRecTyDevName=Schema.SObjectType.Alliance_OA_Projects__c.getRecordTypeInfosByName().get('OnArrival').getRecordTypeId(); // setting default value // Add by kumud
        //Onsite solutions object record creation
        lstUserAssign = UserAssignment__c.getall().values();
        lstFeatureSets = FeatureSetsForOnsiteProj__c.getall().values();
        for(UserAssignment__c instOfUsrAssign : lstUserAssign){
          strRecTyDevName = instOfUsrAssign.Name;
          strUsrName = instOfUsrAssign.UserName__c;
          strUsrId = instOfUsrAssign.User_id__c;
        }
        for(FeatureSetsForOnsiteProj__c instOfFeatSet : lstFeatureSets){
          setFeatureSetsCust.add(instOfFeatSet.Name);
        }
        /*HSR:Commenting this as a part of Refactoring
        List<RecordType> lstRecTypeSec =[SELECT IsActive, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Alliance_OA_Projects__c' AND DeveloperName=:strRecTyDevName And IsActive=true];
        for(RecordType instOfRecType : lstRecTypeSec){
          strRecTyId = instOfRecType.Id;
        }*/
        /*HSR:Commented above and added this as a part of Refactoring*/
        strRecTyId = Schema.SObjectType.Alliance_OA_Projects__c.getRecordTypeInfosByName().get('OnArrival').getRecordTypeId();
        //Onsite solutions object record creation
        
        
        
        //Probability updation concept.
        lstprobablity = Probability__c.getall().values();
        for(Probability__c instOfProb : lstprobablity){
            if(instOfProb.NBB_Renewal__c != null){
                mapStageProdProb.put(instOfProb.StageName__c.trim(),instOfProb.Probability__c);
            }else{
                if(instOfProb.License_Type__c!= null)
                    mapStageProdProb.put((instOfProb.Product__c+instOfProb.StageName__c+instOfProb.License_Type__c).trim(),instOfProb.Probability__c);
                else
                    mapStageProdProb.put((instOfProb.Product__c+instOfProb.StageName__c).trim(),instOfProb.Probability__c);
            }
            
            setStageName.add(instOfProb.StageName__c);
        }
       
    }
        
    public void OnBeforeInsert(List<Opportunity> newValues){   
        /*HSR : 1st Jan 2017 : Updating the Exchange Rate for CloseDate with BackDate*/              
        List<Opportunity> oppExchange = new List<Opportunity>();        
        Set<Date> dateSet=new Set<Date>();      
        map<String,Decimal> mapConval = new map<String,Decimal>();      
        /*..............................ENDS HERE...............................*/
        /*HSR : 29th Sep : Inserting Parent Opp Contract End Date in the Upsell Contract Opp "Contract_End_Date_Parent_Opp__c" field*/
        Map<String,Opportunity> CVIIVsOppMap=new Map<String,Opportunity>();
        Set<String> parentCVIISet=new Set<String>();
        /*...................................Ends Here..............................*/
        /* HSR : 25th May : removal of TAB character from some fields*/
        removeTABCharacter(newValues);
        /* -------------------Ends Here-----------------------------*/
        Map<Id,Id> mapOppId = new Map<Id,Id>(); 
        Set<Id> setUserId = new Set<Id>();
        map<String,String> mapMSA = new map<String,String>();
        List<Date> lstdate = new List<Date>();
        Date todayDate = Date.newInstance(System.now().year(),System.now().month(),System.now().day());
        for(Opportunity idForOppNew : newValues){
            /*HSR : 1st Jan 2017 : Updating the Exchange Rate for CloseDate with BackDate*/     
            if(idForOppNew.CloseDate!=null)
            {   
                oppExchange.add(idForOppNew);       
                if(idForOppNew.CloseDate<system.today()){
                    dateSet.add(idForOppNew.CloseDate);     
                }
                else{
                    //HSR:Added this as a part of Refactoring
                    dateSet.add(todayDate.addDays(-1));     
                }
            }
            //System.debug('********dateSet*************'+dateSet);
            /*..............................ENDS HERE...............................*/
           /*HSR : 29th Sep : Inserting Parent Opp Contract End Date in the Upsell Contract Opp "Contract_End_Date_Parent_Opp__c" field*/
            if((idForOppNew.Product__c=='CrowdCompass' || idForOppNew.Product__c=='Event' || idForOppNew.Product__c=='Survey') &&(idForOppNew.Parent_Upsell__c=='Upsell' || idForOppNew.Parent_Upsell__c=='Renewal Adjustment') && idForOppNew.Contract_Implemented__c==true && idForOppNew.StageName=='Closed Won' && idForOppNew.Deal_Year__c==idForOppNew.Years__c)
            {
                parentCVIISet.add(String.ValueOf(idForOppNew.Parent_Contract_Number__c));
            }  
            /*...................................Ends Here..............................*/      
            if(idForOppNew.Set_Cancellation_Status__c == '' || idForOppNew.Set_Cancellation_Status__c ==null)
            idForOppNew.Set_Cancellation_Status__c = 'Do not open';
            //if(idForOppNew.Contact_Check__c != true){   comment by kumud Field Cleanup Activity [30 May 2018] 
            
                system.debug('idForOppNew.Opp_Type_Classification__c++'+idForOppNew.Opp_Type_Classification__c);
                if(idForOppNew.Opp_Type_Classification__c == null){ 
                    if(idForOppNew.Contact_Associated__c==null || idForOppNew.Contact_Role__c=='' || idForOppNew.Contact_Role__c==null){
                        if(!Test.isRunningTest()){ 
                            idForOppNew.addError('Please specify a contact with role on fields highlighted below');
                            idForOppNew.Contact_Associated__c.addError('Contact');
                            idForOppNew.Contact_Role__c.addError('Contact Role');
                        }                                       
                    }else{
                        idForOppNew.Product_Category__c = null;
                        //(Tract)-On updating and insert get currency rate
                        
                        if(idForOppNew.CloseDate != null && idForOppNew.CloseDate < system.today() && idForOppNew.CurrencyIsoCode != 'USD'){
                            lstdate.add(idForOppNew.CloseDate);
                        }else if(idForOppNew.CloseDate >= system.today() && idForOppNew.CurrencyIsoCode != 'USD'){
                        }else if(idForOppNew.CurrencyIsoCode == 'USD'){
                            idForOppNew.Exchange_Rate__c = 1;
                        }
                       
                        
                        if(idForOppNew.Product__c =='CrowdCompass' && idForOppNew.Deal_Booked_In__c =='US Books')
                        idForOppNew.Product_Category__c = 'CrowdCompass';
                        
                        if(idForOppNew.Product__c =='CrowdCompass' && idForOppNew.Deal_Booked_In__c =='UK Books')
                        idForOppNew.Product_Category__c = 'CrowdCompass - UK';
                        
                        if(idForOppNew.Product__c =='Event' && (idForOppNew.Team__c=='BD' || idForOppNew.Team__c=='Product Adoption' || idForOppNew.Team__c=='Ecommerce/CS')){
                            idForOppNew.Product_Category__c = 'Event';
                        }else{
                            if(idForOppNew.Product__c !='CrowdCompass' && (idForOppNew.Deal_Booked_In__c !='UK Books' || idForOppNew.Deal_Booked_In__c !='US Books' ))
                            idForOppNew.Product_Category__c = idForOppNew.Product__c;
                        }
                        
                        if(idForOppNew.Product__c =='Event' && (idForOppNew.Product_Category__c == null || idForOppNew.Product_Category__c ==''))
                        setUserId.add(idForOppNew.OwnerId);
                        
                        //For Onsite Product
                        if(idForOppNew.Product__c =='Onsite Solutions' && idForOppNew.Team__c =='Enterprise')
                        idForOppNew.Product_Category__c ='Enterprise';
                        else if(idForOppNew.Product__c == 'Onsite Solutions' && idForOppNew.Team__c !='Enterprise')
                        idForOppNew.Product_Category__c ='Event';
                        //For Onsite Product
                        
                        
                        //Probability updation concept.
                        system.debug(idForOppNew.License_Type__c);
                        system.debug(idForOppNew.NBB_Renewal__c);
                        system.debug(idForOppNew.Parent_Upsell__c);
                        system.debug(idForOppNew.License_Type__c);
                        
                        system.debug(mapStageProdProb);
                        if(idForOppNew.NBB_Renewal__c == 'NBB Repeated' && idForOppNew.Product__c == 'CSN'){
                            idForOppNew.Probabilities__c = mapStageProdProb.get(idForOppNew.StageName);
                        }else{
                            if(idForOppNew.License_Type__c!=null){
                                if(!idForOppNew.License_Type__c.contains('Diamond') && idForOppNew.NBB_Renewal__c == 'Renewal' && idForOppNew.Parent_Upsell__c == 'Primary' && setStageName.contains(idForOppNew.StageName)){
                                    String str = idForOppNew.Product__c + idForOppNew.StageName;
                                    idForOppNew.Probabilities__c = mapStageProdProb.get(str);
                                }else if(idForOppNew.NBB_Renewal__c == 'Renewal' && idForOppNew.Parent_Upsell__c == 'Primary' && setStageName.contains(idForOppNew.StageName)){
                                    String Str = idForOppNew.Product__c + idForOppNew.StageName + 'Diamond';
                                    idForOppNew.Probabilities__c = mapStageProdProb.get(str);
                                }else if( idForOppNew.NBB_Renewal__c != 'Renewal' || idForOppNew.Parent_Upsell__c != 'Primary'|| (!setStageName.contains(idForOppNew.StageName))){
                                    system.debug(idForOppNew.Probability);
                                    idForOppNew.Probabilities__c = idForOppNew.Probability;
                                    system.debug(idForOppNew.Probabilities__c);
                                }
                            }
                        }
                        
                        idForOppNew.Probabilities__c=idForOppNew.StageName == 'Cancelled' || idForOppNew.StageName == 'Closed Lost' || idForOppNew.StageName == 'Closed Lost - Opted Out/Cancelled' || idForOppNew.StageName == 'CS Pass' || idForOppNew.StageName == 'Opp Identified'?0:idForOppNew.Probabilities__c;
                        idForOppNew.Probabilities__c=idForOppNew.StageName == 'Closed Won'?100:idForOppNew.Probabilities__c;
                        idForOppNew.Probabilities__c=idForOppNew.StageName == 'Legal'?95:idForOppNew.Probabilities__c;
                       /*
                         Commented by kumud:
                         Move this code in ternary operator above.
                       
                       */
                       /* if(idForOppNew.StageName == 'Cancelled')
                            idForOppNew.Probabilities__c = 0;
                        if(idForOppNew.StageName == 'Closed Lost')
                            idForOppNew.Probabilities__c = 0;
                        if(idForOppNew.StageName == 'Closed Lost - Opted Out/Cancelled')
                            idForOppNew.Probabilities__c = 0;
                        if(idForOppNew.StageName == 'Closed Won')
                            idForOppNew.Probabilities__c = 100;
                        if(idForOppNew.StageName == 'CS Pass')
                            idForOppNew.Probabilities__c = 0;
                        if(idForOppNew.StageName == 'Legal')
                            idForOppNew.Probabilities__c = 95;
                        if(idForOppNew.StageName == 'Opp Identified')
                            idForOppNew.Probabilities__c = 0;*/ 
                        //Probability updation concept.
                    }
                    if(idForOppNew.MSA_Code__c != null)
                    mapMSA.put(idForOppNew.MSA_Code__c,idForOppNew.MSA_Code__c);
                 
                }    
            //}  comment by kumud Field Cleanup Activity [30 May 2018]                 
        }
         /*HSR : 1st Jan 2017 : Updating the Exchange Rate for CloseDate with BackDate*/     
        System.debug('#Checkpoint.......dateSet'+dateSet);      
        System.debug('oppExchange***********'+oppExchange);     
        if(dateSet.size()>0){       
            For(DatedConversionRate instOfDCR : [SELECT StartDate, IsoCode, ConversionRate FROM DatedConversionRate WHERE StartDate IN : dateSet])      
            {       
                String instStr = instOfDCR.StartDate + instOfDCR.IsoCode;       
                system.debug('instStr++'+instStr);      
                system.debug('instOfDCR.ConversionRate+++'+instOfDCR.ConversionRate);       
                mapConval.put(instStr,instOfDCR.ConversionRate);        
            }       
            System.debug('mapConval**********'+mapConval);
            For(DatedConversionRate instOfDCR : [SELECT StartDate, IsoCode, ConversionRate FROM DatedConversionRate ORDER BY StartDate DESC LIMIT 20])      
            {       
               
                if(!mapConval.containsKey(instOfDCR.IsoCode))
                    mapConval.put(instOfDCR.IsoCode,instOfDCR.ConversionRate);        
            }
        }   
        if(CheckRecursive.runOnceThird())    {
            For(Opportunity instOfOpp : oppExchange)        
            {       
                if(instOfOpp.CloseDate<system.today()){
                    String instStr = instOfOpp.CloseDate + instOfOpp.CurrencyIsoCode;       
                    if(mapConval.ContainsKey(instStr)){     
                        instOfOpp.Exchange_Rate__c = mapConval.get(instStr);        
                    }else if(instOfOpp.CurrencyIsoCode == 'USD'){       
                        instOfOpp.Exchange_Rate__c = 1;     
                    }       
                }
                else{
                    if(mapConval.ContainsKey(instOfOpp.CurrencyIsoCode)){     
                        instOfOpp.Exchange_Rate__c = mapConval.get(instOfOpp.CurrencyIsoCode);        
                    }else if(instOfOpp.CurrencyIsoCode == 'USD'){       
                        instOfOpp.Exchange_Rate__c = 1;     
                    }   
                }
            }       
        }
        /*.......................................ENDS HERE.....................*/
         /*HSR : 29th Sep : Inserting Parent Opp Contract End Date in the Upsell Contract Opp "Contract_End_Date_Parent_Opp__c" field*/
        For(Opportunity OppObj : [SELECT Id,ContractEndDate__c,Contract_Number_New__c FROM Opportunity WHERE Contract_Number_New__c IN : parentCVIISet AND Parent_Contract_Number__c=null])
        {
            CVIIVsOppMap.put(OppObj.Contract_Number_New__c,OppObj);     
        }
        /*...................................Ends Here..............................*/          
        /*HSR:Commenting this as a part of Refactoring

        List<DatedConversionRate> lstDateCR =  [SELECT StartDate, IsoCode, ConversionRate FROM DatedConversionRate WHERE (StartDate =: lstDate OR StartDate =: system.Today().adddays(-1))];
        
        map<String,Decimal> mapConv =  new map<String,Decimal>();
        map<String,Decimal> mapConvTodayOrMore =  new map<String,Decimal>();
        for(DatedConversionRate isntOfDCR : lstDateCR){
            system.debug('isntOfDCR.StartDate+++'+isntOfDCR.StartDate);
            system.debug('system.today()+++'+system.today());
            mapConv.put(isntOfDCR.StartDate + isntOfDCR.IsoCode,isntOfDCR.ConversionRate);
            if(isntOfDCR.StartDate == system.today().adddays(-1)){
                mapConvTodayOrMore.put(isntOfDCR.StartDate + isntOfDCR.IsoCode,isntOfDCR.ConversionRate);
            }
        }*/
                
        map<Id,User> mapUser = new map<Id,User>();
        if(setUserId.Size()>0)
        mapUser = new map<Id,User>([SELECT Id,UserRole.Name FROM User WHERE Id =: setUserId]);
        
      
        /*HSR:Commenting this as a part of Refactoring

        List<Multi_Property_Bundles__c> lstCSNMSA = new List<Multi_Property_Bundles__c>();
        
        if(mapMSA.keyset().size() > 0)
        lstCSNMSA =  [SELECT Id,MSA_Code__c FROM  Multi_Property_Bundles__c WHERE MSA_Code__c != null AND MSA_Code__c =: mapMSA.keyset()];
        
        Map<String,Id> mapCSNMSA = new Map<String,Id>();
        
        for(Multi_Property_Bundles__c instOfCSNMSA : lstCSNMSA){
            mapCSNMSA.put(instOfCSNMSA.MSA_Code__c.trim(),instOfCSNMSA.Id);                    
        }       
        
        system.debug('mapCSNMSA++'+mapCSNMSA);
        system.debug('mapOppId+++'+mapOppId);*/
        Integer counter =0;
        Integer counterSec = 0;
        for(Opportunity idForOppNew : newValues){
             /*HSR : 29th Sep : Inserting Parent Opp Contract End Date in the Upsell Contract Opp "Contract_End_Date_Parent_Opp__c" field*/
            /*if(!CVIIVsOppMap.isEmpty() && CVIIVsOppMap.containsKey(String.ValueOf(idForOppNew.Parent_Contract_Number__c))){
                System.debug('#Checkpoint inside if');
                idForOppNew.Contract_End_Date_Parent_Opp__c = CVIIVsOppMap.get(String.ValueOf(idForOppNew.Parent_Contract_Number__c)).ContractEndDate__c;
            }
                comment by kumud Field Cleanup Activity [30 May 2018] 
            */ 
            /*...................................Ends Here..............................*/  
            /*
            This if was blank so commented as a part of refactoring
            if(mapCSNMSA.ContainsKey(idForOppNew.MSA_Code__c)){
               
            }*/  
            
            /*HSR:Commenting this as a part of Refactoring
            String strDateIso = idForOppNew.CloseDate + idForOppNew.CurrencyIsoCode;
            if(mapConv.containsKey(strDateIso)){
                idForOppNew.Exchange_Rate__c = mapConv.get(strDateIso);
            }
            if(idForOppNew.CloseDate >= system.today()){
                for(String strDateCurr : mapConvTodayOrMore.KeySet()){
                    if(strDateCurr.contains(idForOppNew.CurrencyIsoCode)){
                        idForOppNew.Exchange_Rate__c = mapConvTodayOrMore.get(strDateCurr);
                    }
                }
            }*/
            
           
            if(idForOppNew.Product__c == 'Event'){
                if(mapUser.containsKey(idForOppNew.OwnerId)){
                    User instOfUsr = mapUser.get(idForOppNew.OwnerId);
                    if(instOfUsr.UserRole.Name.contains('Event'))
                    idForOppNew.Product_Category__c = 'Event';
                    
                    if(instOfUsr.UserRole.Name.contains('(Ent)'))
                    idForOppNew.Product_Category__c = 'Enterprise';
                    
                    if(instOfUsr.UserRole.Name.contains('(TPP)'))
                    idForOppNew.Product_Category__c = 'Event';
                }
                
            }
                
        }
        // Changes for CSN-MSA Records updation and insertion.
        // Changes for Bundle Campaigns Records updation and insertion.As Object CSN-MSA was discarded
    }
    public void OnAfterInsert(Map<Id,Opportunity> newMapValues){
        
        Map<String,OpportunityContactRole> mapOppContRole = new Map<String,OpportunityContactRole>();
        //To insert multiple opportunity contact roles
     
        
        List<OpportunityContactRole> lstOppContactRole = new List<OpportunityContactRole>();
        
        // Changes for Bundle Campaigns Records updation and insertion.As Object CSN-MSA was discarded
        List<Id> lstBundleCampId = new List<Id>();
        // Changes for Bundle Campaigns Records updation and insertion.As Object CSN-MSA was discarded
        
        Map<String,Opportunity> mapOfTCVCntNumsIds = new Map<String,Opportunity>();
        
        //AccountId, Contact Roles Mapping for AM Validation
        Map<Id,List<OpportunityContactRole>> mapOfAccVSContactRole = new Map<Id,List<OpportunityContactRole>>();
        
        for(Opportunity idForOppNew : newMapValues.values()){
            if( idForOppNew.Contact_Associated__c !=null && (idForOppNew.Contact_Role__c != '' && idForOppNew.Contact_Role__c != null)){ 
                OpportunityContactRole instOppContactRole = new OpportunityContactRole();
                instOppContactRole.OpportunityId =  idForOppNew.Id;                 
                instOppContactRole.ContactId = idForOppNew.Contact_Associated__c;       
                instOppContactRole.Role = idForOppNew.Contact_Role__c;                  
                instOppContactRole.IsPrimary =  true;
                lstOppContactRole.add(instOppContactRole);
                
                //@Added by Shanu (Contact AM Validation)
                if(idForOppNew.StageName == 'Closed Won' || idForOppNew.StageName == 'Closed Lost'){ //stage added by udita for contact roles enhancement
                    if(mapOfAccVSContactRole.containsKey(idForOppNew.AccountId)){
                        mapOfAccVSContactRole.get(idForOppNew.AccountId).add(instOppContactRole);
                    }else{
                        mapOfAccVSContactRole.put(idForOppNew.AccountId, new List<OpportunityContactRole>{instOppContactRole});
                    }
                }
            }
            
            
            if(idForOppNew.StageName == 'Tract')
            mapOfTCVCntNumsIds.put(idForOppNew.Contract_Number_New__c,idForOppNew);            
        }
        
        system.debug('lstOppContactRole++++'+lstOppContactRole);
        
        //To insert multiple opportunity contact roles  
        
         // Changes for Bundle Campaigns Records updation and insertion.As Object CSN-MSA was discarded//Rollup Code On Insertion
            /*
             Multi_Property_Bundles__c : Code comment by kumud on 2 June 18 as it is not execute because lstBundleCampId is always empty.
            */
        /*
        List<Multi_Property_Bundles__c> lstMultiPropBund = new List<Multi_Property_Bundles__c>();
        
        if(lstBundleCampId.size()>0)
        lstMultiPropBund =  [SELECT Id,MSA_Total__c,(SELECT ID,New_Contract_Total__c FROM Opportunities_Bund__r) FROM Multi_Property_Bundles__c WHERE Id =: lstBundleCampId];   
            
        List<Multi_Property_Bundles__c> lstMultiPropBundSec = new List<Multi_Property_Bundles__c>();
        
        for(Multi_Property_Bundles__c instOfMutiPropBund : lstMultiPropBund){
            Decimal intContractTot=0;
            for(Opportunity instOfOpp : instOfMutiPropBund.Opportunities_Bund__r){
                intContractTot = intContractTot + instOfOpp.New_Contract_Total__c;
            }
            instOfMutiPropBund.MSA_Total__c = String.valueOf(intContractTot);
            lstMultiPropBundSec.add(instOfMutiPropBund);
        }       
        
        if(lstMultiPropBundSec.size()>0){
            update lstMultiPropBundSec;
        }* end here [Kumud]*/
        // Changes for Bundle Campaigns Records updation and insertion.As Object CSN-MSA was discarded//Rollup Code On Insertion
        
        //Method for Checking for Security Review of an Opportunity to share those with Sales Engineers using sharing Rule on Account (If checked)
        if(CheckRecursive.runOnceSeventh())
        SalesEngineerAccessToOpportunity(newMapValues.values(),null);                                     
    }
    public void OnBeforeUpdate(Map<Id,Opportunity> oldMapValues,Map<Id,Opportunity> newMapValues){
        /*HSR : 29th Sep : Inserting Parent Opp Contract End Date in the Upsell Contract Opp "Contract_End_Date_Parent_Opp__c" field*/
        Map<String,Opportunity> CVIIVsOppMap=new Map<String,Opportunity>();
        Set<String> parentCVIISet=new Set<String>();
        /*...................................Ends Here..............................*/
        /* HSR : 25th May : removal of TAB character from some fields*/
        removeTABCharacter(newMapValues.values());
        /* -------------------Ends Here-----------------------------*/
        //(Tract)-Whenever an opportunity with with unique contract number is inserted
        Map<Id,Id> mapOppId = new Map<Id,Id>(); 
        Set<Id> setUserId = new Set<Id>();
        //(Tract)-Whenever an opportunity with with unique contract number is inserted
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        List<Opportunity> lstOppForError =  new List<Opportunity>();
        
       
        List<Date> lstdate = new List<Date>();
        
        //Onsite solutions object record creation
        set<Id> setOppId = new set<Id>();
        //Onsite solutions object record creation
        /*HSR : 20th Dec : Updating the Exchange Rate for CloseDate with BackDate*/              
        List<Opportunity> oppExchange = new List<Opportunity>();        
        Set<Date> dateSet=new Set<Date>();      
        map<String,Decimal> mapConval = new map<String,Decimal>();    
        //AccountId, Contact Roles Mapping for AM Validation
        Map<Id,List<OpportunityContactRole>> mapOfAccVSContactRole = new Map<Id,List<OpportunityContactRole>>();
        Datetime todayDatetime = System.now();
        Date todayDate = Date.newInstance(todayDatetime.year(),todayDatetime.month(),todayDatetime.day());
    
        /*..............................ENDS HERE...............................*/
        for(Opportunity idForOppNew : newMapValues.values()){
            /*HSR : 20th Dec : Updating the Exchange Rate for CloseDate with BackDate*/     
            if(idForOppNew.CloseDate!=null)
            {       
                oppExchange.add(idForOppNew);       
                if(idForOppNew.CloseDate<system.today()){
                    System.debug('*********Inside If*********');
                    dateSet.add(idForOppNew.CloseDate);     
                }
                else{
                    dateSet.add(todayDate.addDays(-2));     
                }               
            }       
            /*..............................ENDS HERE...............................*/
          /*HSR : 29th Sep : Inserting Parent Opp Contract End Date in the Upsell Contract Opp "Contract_End_Date_Parent_Opp__c" field*/
            if((idForOppNew.Product__c=='CrowdCompass' || idForOppNew.Product__c=='Event' || idForOppNew.Product__c=='Survey') &&(idForOppNew.Parent_Upsell__c=='Upsell' || idForOppNew.Parent_Upsell__c=='Renewal Adjustment') && idForOppNew.Contract_Implemented__c==true && idForOppNew.StageName=='Closed Won' && idForOppNew.Deal_Year__c==idForOppNew.Years__c)
            {
                 if(newMapValues.get(idForOppNew.Id).Contract_Implemented__c != oldMapValues.get(idForOppNew.Id).Contract_Implemented__c){
                        parentCVIISet.add(String.ValueOf(idForOppNew.Parent_Contract_Number__c));
                    }   
            }
            /*...................................Ends Here..............................*/   
           
            if(newMapValues.get(idForOppNew.Id).CurrencyIsoCode != oldMapValues.get(idForOppNew.Id).CurrencyIsoCode || newMapValues.get(idForOppNew.Id).CloseDate != oldMapValues.get(idForOppNew.Id).CloseDate){
                if(idForOppNew.CloseDate != null && idForOppNew.CloseDate < system.today() && idForOppNew.CurrencyIsoCode != 'USD'){
                    lstdate.add(idForOppNew.CloseDate);
                }else if(idForOppNew.CloseDate >= system.today() && idForOppNew.CurrencyIsoCode != 'USD'){
                    //mapOppIdExRate.put(idForOppNew.Id,idForOppNew.CurrencyIsoCode);
                }else if(idForOppNew.CurrencyIsoCode == 'USD'){
                    idForOppNew.Exchange_Rate__c = 1;
                }   
            }
    
            if(newMapValues.get(idForOppNew.id).StageName=='Closed Won' && oldMapValues.get(idForOppNew.id).StageName!='Closed Won'){
                if(idForOppNew.Contact_Associated__c != null && idForOppNew.Contact_Role__c != null){
                    lstOpp.add(idForOppNew);
                }else if(idForOppNew.Contact_Associated__c == null || idForOppNew.Contact_Role__c=='' || idForOppNew.Contact_Role__c== null){
                    lstOppForError.add(idForOppNew);
                }
            }
            //Onsite solutions object record creation
          if(idForOppNew.Contract_Implemented__c==true && oldMapValues.get(idForOppNew.id).Contract_Implemented__c !=idForOppNew.Contract_Implemented__c){
            if(idForOppNew.Alliance_Tech_CheckBox__c == true){
            if(idForOppNew.Event_Name__c == ''|| idForOppNew.Event_Name__c == null ){ // Remove || idForOppNew.Start_Date__c == null || idForOppNew.End_Date__c == null || idForOppNew.Badge_Printing__c == null idForOppNew.Event_City__c=='' ||  idForOppNew.Event_Venue__c =='' ||  idForOppNew.Event_State__c == '' || idForOppNew.Event_Country__c =='' || idForOppNew.Number_of_Events__c == null || idForOppNew.Number_of_Attendees__c == '' || idForOppNew.Number_of_Exhibitors__c == '' || idForOppNew.Number_of_RFID_Scanners__c==null || idForOppNew.Session_Scanning__c == null  || idForOppNew.Lead_Retrieval__c == null|| from the if [Kumud]
                idForOppNew.addError('Fields of Onsite Solution Event Details Section are not filled completely');
                if(idForOppNew.Event_Name__c == '' || idForOppNew.Event_Name__c == null)
                idForOppNew.Event_Name__c.addError('Cannot be blank');
                
               /* if(idForOppNew.Start_Date__c == null)
                idForOppNew.Start_Date__c.addError('Cannot be blank');
                
                if(idForOppNew.End_Date__c == null)
                idForOppNew.End_Date__c.addError('Cannot be blank');*/// comment by kumud Field Cleanup Activity [30 May 2018] 
                
                /*if(idForOppNew.Event_Venue__c == null)
                idForOppNew.Event_Venue__c.addError('Cannot be blank'); */
                
                /*if(idForOppNew.Event_City__c == null)
                idForOppNew.Event_City__c.addError('Cannot be blank');*/// comment by kumud Field Cleanup Activity [30 May 2018] 
                
                /*if(idForOppNew.Event_State__c == null)
                idForOppNew.Event_State__c.addError('Cannot be blank');
                
                if(idForOppNew.Number_of_Events__c == null)
                idForOppNew.Number_of_Events__c.addError('Cannot be blank');
                
                if(idForOppNew.Number_of_Attendees__c == null)
                idForOppNew.Number_of_Attendees__c.addError('Cannot be blank');
                
                if(idForOppNew.Number_of_Exhibitors__c == null)
                idForOppNew.Number_of_Exhibitors__c.addError('Cannot be blank');
                
                if(idForOppNew.Number_of_RFID_Scanners__c == null)
                idForOppNew.Number_of_RFID_Scanners__c.addError('Cannot be blank');
                
                if(idForOppNew.Session_Scanning__c == null)
                idForOppNew.Session_Scanning__c.addError('Cannot be blank');
                
                if(idForOppNew.Badge_Printing__c == null)
                idForOppNew.Badge_Printing__c.addError('Cannot be blank');
                        comment by kumud Field Cleanup Activity [30 May 2018] 
                
                
                if(idForOppNew.Lead_Retrieval__c == null)
                    idForOppNew.Lead_Retrieval__c.addError('Cannot be blank');*/ // [comment by kumud]
            }
            }
            //Onsite solutions object record creation
          }
            //Updating according to the field value Set_Cancellation_Status__c
            if(idForOppNew.Set_Cancellation_Status__c != oldMapValues.get(idForOppNew.Id).Set_Cancellation_Status__c){
                if(idForOppNew.Set_Cancellation_Status__c == 'Edit Only'){
                    idForOppNew.IsLocked__c = false;
                }else if(idForOppNew.Set_Cancellation_Status__c == 'Edit and Remove TRACT Order #'){
                    idForOppNew.IsLocked__c = false;
                    //idForOppNew.TRACT_Order_Old__c = idForOppNew.TRACT2__Tract_Sales_Order__c;
                    //idForOppNew.TRACT2__Tract_Sales_Order__c = '';
                }else if(idForOppNew.Set_Cancellation_Status__c == 'Edit & Clone'){
                    idForOppNew.IsLocked__c = false;
                }else if(idForOppNew.Set_Cancellation_Status__c == 'Do not open'){
                    idForOppNew.IsLocked__c = true;
                }
            }
          
            
            //Probability updation concept.
            system.debug(idForOppNew.License_Type__c);
            system.debug(idForOppNew.NBB_Renewal__c);
            system.debug(idForOppNew.Parent_Upsell__c);
            
            system.debug(mapStageProdProb);
            if(idForOppNew.NBB_Renewal__c == 'NBB Repeated' && idForOppNew.Product__c == 'CSN'){
                idForOppNew.Probabilities__c = mapStageProdProb.get(idForOppNew.StageName);
            }else{
                if(idForOppNew.License_Type__c!=null){
                    if(!idForOppNew.License_Type__c.contains('Diamond') && idForOppNew.NBB_Renewal__c == 'Renewal' && idForOppNew.Parent_Upsell__c == 'Primary' && setStageName.contains(idForOppNew.StageName)){
                        String str = idForOppNew.Product__c + idForOppNew.StageName;
                        idForOppNew.Probabilities__c = mapStageProdProb.get(str);
                    }else if(idForOppNew.NBB_Renewal__c == 'Renewal' && idForOppNew.Parent_Upsell__c == 'Primary' && setStageName.contains(idForOppNew.StageName)){
                        String Str = idForOppNew.Product__c + idForOppNew.StageName + 'Diamond';
                        idForOppNew.Probabilities__c = mapStageProdProb.get(str);
                    }else if( idForOppNew.NBB_Renewal__c != 'Renewal' || idForOppNew.Parent_Upsell__c != 'Primary'|| (!setStageName.contains(idForOppNew.StageName))){
                        system.debug(idForOppNew.Probability);
                        idForOppNew.Probabilities__c = idForOppNew.Probability;
                        system.debug(idForOppNew.Probabilities__c);
                    }
                }
            }
            idForOppNew.Probabilities__c=idForOppNew.StageName == 'Cancelled' || idForOppNew.StageName == 'Closed Lost' || idForOppNew.StageName == 'Closed Lost - Opted Out/Cancelled' || idForOppNew.StageName == 'CS Pass' || idForOppNew.StageName == 'Opp Identified'?0:idForOppNew.Probabilities__c;
            idForOppNew.Probabilities__c=idForOppNew.StageName == 'Closed Won'?100:idForOppNew.Probabilities__c;
            idForOppNew.Probabilities__c=idForOppNew.StageName == 'Legal'?95:idForOppNew.Probabilities__c;
                       /*
                         Commented by kumud:
                         Move this code in ternary operator above.
                       
                       */
            /*if(idForOppNew.StageName == 'Cancelled')
            idForOppNew.Probabilities__c = 0;
            if(idForOppNew.StageName == 'Closed Lost')
            idForOppNew.Probabilities__c = 0;
            if(idForOppNew.StageName == 'Closed Lost - Opted Out/Cancelled')
            idForOppNew.Probabilities__c = 0;
            if(idForOppNew.StageName == 'Closed Won')
            idForOppNew.Probabilities__c = 100;
            if(idForOppNew.StageName == 'CS Pass')
            idForOppNew.Probabilities__c = 0;
            if(idForOppNew.StageName == 'Legal')
            idForOppNew.Probabilities__c = 95;
            if(idForOppNew.StageName == 'Opp Identified')
            idForOppNew.Probabilities__c = 0;*/
            
            /*
            code comment by kumud as field Cleanup Activity [30 may 2018]
            //Adjusting the cancellation amount 
            if((idForOppNew.Counted_sales_Cancellation_Value__c != oldMapValues.get(idForOppNew.Id).Counted_sales_Cancellation_Value__c && idForOppNew.Counted_sales_Cancellation_Value__c !=null) || (idForOppNew.Counted_sales_Cancellation_Value__c != oldMapValues.get(idForOppNew.Id).Counted_sales_Cancellation_Value__c && idForOppNew.Counted_sales_Cancellation_Value__c !=null)){
                idForOppNew.Cancellation_Date_Tract__c = system.today();
            }else if(idForOppNew.Counted_sales_Cancellation_Value__c != oldMapValues.get(idForOppNew.Id).Counted_sales_Cancellation_Value__c && idForOppNew.Counted_sales_Cancellation_Value__c ==null){
                idForOppNew.Cancellation_Date_Tract__c = null;
            } */ // End here
           
            // Changes to product category for TPP 
            if(idForOppNew.Product_Category__c != 'TPP') // new line added to make sure if TPP is changed manually it is not reverted back.
            idForOppNew.Product_Category__c = null;
          
            
            if(idForOppNew.Product__c != null && idForOppNew.Deal_Booked_In__c!= null){
                if(idForOppNew.Product__c =='CrowdCompass' && idForOppNew.Deal_Booked_In__c =='US Books')
                idForOppNew.Product_Category__c = 'CrowdCompass';
            }
            system.debug(idForOppNew.Product_Category__c);
            
            if(idForOppNew.Product__c =='CrowdCompass' && idForOppNew.Deal_Booked_In__c =='UK Books')
            idForOppNew.Product_Category__c = 'CrowdCompass - UK';
            
            system.debug(idForOppNew.Product_Category__c);
            
            if(idForOppNew.Product__c =='Event' && (idForOppNew.Team__c=='BD' || idForOppNew.Team__c=='Product Adoption' || idForOppNew.Team__c=='Ecommerce/CS')){
                idForOppNew.Product_Category__c = 'Event';
            }else{
                // Changes to product category for TPP - below line commented and new line added with the condition for TPP product category
                if(idForOppNew.Product__c !='CrowdCompass' && (idForOppNew.Deal_Booked_In__c !='UK Books' || idForOppNew.Deal_Booked_In__c !='US Books' ) && idForOppNew.Product_Category__c != 'TPP') //Changes to product category for TPP 
                idForOppNew.Product_Category__c = idForOppNew.Product__c;
                system.debug(idForOppNew.Product_Category__c);
            }
            
            if(idForOppNew.Product__c =='Event' && (idForOppNew.Product_Category__c != null || idForOppNew.Product_Category__c ==''))
            setUserId.add(idForOppNew.OwnerId);
            
            //For Onsite Product
            if(idForOppNew.Product__c =='Onsite Solutions' && idForOppNew.Team__c =='Enterprise')
            idForOppNew.Product_Category__c ='Enterprise';
            else if(idForOppNew.Product__c == 'Onsite Solutions' && idForOppNew.Team__c !='Enterprise')
            idForOppNew.Product_Category__c ='Event';
            //For Onsite Product
            
           
      
      
            //@Added by Shanu (Contact Roles )
             if((oldMapValues.get(idForOppNew.Id).StageName !='Closed Won' && idForOppNew.StageName =='Closed Won' ) || (oldMapValues.get(idForOppNew.Id).StageName !='Closed Lost' && idForOppNew.StageName =='Closed Lost') || (oldMapValues.get(idForOppNew.Id).StageName !='Closed Won - Before Acquisition' && idForOppNew.StageName =='Closed Won - Before Acquisition')){ //Closed Lost stage added by udita for contact roles enhancement
        
                OpportunityContactRole instOppContactRole = new OpportunityContactRole();
                instOppContactRole.OpportunityId =  idForOppNew.Id;                 
                instOppContactRole.ContactId = idForOppNew.Contact_Associated__c;       
                instOppContactRole.Role = idForOppNew.Contact_Role__c;                  
                instOppContactRole.IsPrimary =  true;
        
                if(mapOfAccVSContactRole.containsKey(idForOppNew.AccountId)){
                    mapOfAccVSContactRole.get(idForOppNew.AccountId).add(instOppContactRole);
                }else{
                    mapOfAccVSContactRole.put(idForOppNew.AccountId, new List<OpportunityContactRole>{instOppContactRole});
                }
            }
        }
        /*HSR : 20th Dec : Updating the Exchange Rate for CloseDate with BackDate*/     
        System.debug('#Checkpoint.......dateSet'+dateSet);      
        System.debug('oppExchange***********'+oppExchange); 
        if(CheckRecursive.runOnceThird())    {    
        if(dateSet.size()>0){       
            For(DatedConversionRate instOfDCR : [SELECT StartDate, IsoCode, ConversionRate FROM DatedConversionRate WHERE StartDate IN : dateSet])      
            {       
                String instStr = instOfDCR.StartDate + instOfDCR.IsoCode;       
                system.debug('instStr++'+instStr);      
                system.debug('instOfDCR.ConversionRate+++'+instOfDCR.ConversionRate);       
                mapConval.put(instStr,instOfDCR.ConversionRate);        
            }
            For(DatedConversionRate instOfDCR : [SELECT StartDate, IsoCode, ConversionRate FROM DatedConversionRate ORDER BY StartDate DESC LIMIT 20])      
            {       
                if(!mapConval.containsKey(instOfDCR.IsoCode))
                    mapConval.put(instOfDCR.IsoCode,instOfDCR.ConversionRate);        
            }
            System.debug('mapConval**********'+mapConval);      
        }       
        For(Opportunity instOfOpp : oppExchange)        
        {      
            if(instOfOpp.CloseDate<system.today()){
                String instStr = instOfOpp.CloseDate + instOfOpp.CurrencyIsoCode;       
                if(mapConval.ContainsKey(instStr)){     
                    instOfOpp.Exchange_Rate__c = mapConval.get(instStr);        
                }else if(instOfOpp.CurrencyIsoCode == 'USD'){       
                    instOfOpp.Exchange_Rate__c = 1;     
                }       
            }
            else{
                System.debug('#Checkpoint1.......');
           
                if(mapConval.ContainsKey(instOfOpp.CurrencyIsoCode)){     
                    instOfOpp.Exchange_Rate__c = mapConval.get(instOfOpp.CurrencyIsoCode);        
                          
                }else if(instOfOpp.CurrencyIsoCode == 'USD'){       
                    instOfOpp.Exchange_Rate__c = 1;     
                           
                }   
            }
         
        }  
        }     
          /*.......................................ENDS HERE.....................*/
         /*HSR : 29th Sep : Inserting Parent Opp Contract End Date in the Upsell Contract Opp "Contract_End_Date_Parent_Opp__c" field*/
         if(parentCVIISet.size()>0){
            For(Opportunity OppObj : [SELECT Id,ContractEndDate__c,Contract_Number_New__c FROM Opportunity WHERE Contract_Number_New__c IN : parentCVIISet AND Parent_Contract_Number__c=null])
            {
                CVIIVsOppMap.put(OppObj.Contract_Number_New__c,OppObj);     
            }
         }
        
        //Onsite solutions object record creation
        
        map<Id,User> mapUser = new map<Id,User>();
        if(setUserId.Size()>0)
        mapUser = new map<Id,User>([SELECT Id,UserRole.Name FROM User WHERE Id =: setUserId]);
        
        //(Tract)-On updating and insert get currency rate
        /*HSR:Commenting this as a part of Refactoring
        List<DatedConversionRate> lstDateCR =  [SELECT StartDate, IsoCode, ConversionRate FROM DatedConversionRate WHERE (StartDate =: lstDate OR StartDate =: system.Today().adddays(-1))];
        
        map<String,Decimal> mapConv =  new map<String,Decimal>();
        map<String,Decimal> mapConvTodayOrMore =  new map<String,Decimal>();
        for(DatedConversionRate isntOfDCR : lstDateCR){
          
            mapConv.put(isntOfDCR.StartDate + isntOfDCR.IsoCode,isntOfDCR.ConversionRate);
            
            if(isntOfDCR.StartDate == system.today().adddays(-1)){
                mapConvTodayOrMore.put(isntOfDCR.StartDate + isntOfDCR.IsoCode,isntOfDCR.ConversionRate);
            }
        }*/
        
      
        
        List<Opportunity> lstOppThird = new List<Opportunity>();
        
        if(lstOppForError.size() > 0)
        lstOppThird  =  [SELECT o.Id, (SELECT Id FROM OpportunityContactRoles) FROM Opportunity o WHERE Id =: lstOppForError];
        
        List<Opportunity> lstOppSecond = new List<Opportunity>();
        
        if(lstOpp.size()>0)
        lstOppSecond =  [SELECT o.Id,Contact_Associated__c,Contact_Role__c, StageName, AccountId, (SELECT Id,Role,OpportunityId,ContactId FROM OpportunityContactRoles) FROM Opportunity o WHERE Id =: lstOpp];
        
        lstOpp.clear();
        
        List<OpportunityContactRole> lstOppContactRole = new List<OpportunityContactRole>(); 

        for(Opportunity instOfOppSec : lstOppSecond){
            OpportunityContactRole instOppContactRole = new OpportunityContactRole();
            instOppContactRole.OpportunityId =  newMapValues.get(instOfOppSec.Id).Id;                 
            instOppContactRole.ContactId = newMapValues.get(instOfOppSec.Id).Contact_Associated__c;       
            instOppContactRole.Role = newMapValues.get(instOfOppSec.Id).Contact_Role__c;                  
            instOppContactRole.IsPrimary =  true;
            
            //Create Standard Contact Role only if nothing exist
            if(instOfOppSec.OpportunityContactRoles.size()==0){
                lstOppContactRole.add(instOppContactRole);
            }
        }           
        
        // Changes for Bundle Campaigns Records updation and insertion.As Object CSN-MSA was discarded
        // Changes for CSN-MSA Records updation and insertion.
        /*
        HSR:Commenting this as a part of Refactoring
        List<Multi_Property_Bundles__c> lstCSNMSA =  [SELECT Id,MSA_Code__c FROM  Multi_Property_Bundles__c WHERE MSA_Code__c != null];
        Map<String,Id> mapCSNMSA = new Map<String,Id>();
        
        for(Multi_Property_Bundles__c instOfCSNMSA : lstCSNMSA){
            mapCSNMSA.put(instOfCSNMSA.MSA_Code__c.trim(),instOfCSNMSA.Id);                    
        }*/
        
        //(Tract)-Whenever an opportunity with with unique contract number is inserted
        Integer counter;
        Integer counterSec;
        Integer counterThir;
        //Onsite solutions object record creation
       
        //Onsite solutions object record creation
        for(Opportunity idForOppNew : newMapValues.values()){
           /*HSR : 29th Sep : Inserting Parent Opp Contract End Date in the Upsell Contract Opp "Contract_End_Date_Parent_Opp__c" field*/
           /* if(!CVIIVsOppMap.isEmpty() && CVIIVsOppMap.containsKey(String.ValueOf(idForOppNew.Parent_Contract_Number__c))){
                System.debug('#Checkpoint inside if');
                idForOppNew.Contract_End_Date_Parent_Opp__c = CVIIVsOppMap.get(String.ValueOf(idForOppNew.Parent_Contract_Number__c)).ContractEndDate__c;
            } 
                comment by kumud Field Cleanup Activity [30 May 2018] 
            */
            /*...................................Ends Here..............................*/  
            
            //(Tract)-On updating and insert get currency rate
            
            String strDateIso = idForOppNew.CloseDate + idForOppNew.CurrencyIsoCode;
            /*HSR:Commenting this as a part of Refactoring
system.debug(strDateIso);
            if(mapConv.containsKey(strDateIso)){
                idForOppNew.Exchange_Rate__c = mapConv.get(strDateIso);
            }
            
            if(idForOppNew.CloseDate >= system.today()){
                for(String strDateCurr : mapConvTodayOrMore.KeySet()){
                    if(strDateCurr.contains(idForOppNew.CurrencyIsoCode)){
                        if(idForOppNew.Exchange_Rate__c == null)
                        idForOppNew.Exchange_Rate__c = mapConvTodayOrMore.get(strDateCurr);
                    }
                }
            }*/
            
            
            // Changes for CSN-MSA Records updation and insertion.
            // Changes for Bundle Campaigns Records updation and insertion.As Object CSN-MSA was discarded
            
            for(Opportunity instOfOppThird :lstOppThird){               
                if(idForOppNew.Id==instOfOppThird.Id){
                    if(instOfOppThird.OpportunityContactRoles.size()==0){
                        if(!Test.isRunningTest()){ 
                            idForOppNew.addError('Please specify a contact with role on fields highlighted below');
                            idForOppNew.Contact_Associated__c.addError('Contact');
                            idForOppNew.Contact_Role__c.addError('Contact Role');
                        }
                    }
                }
            } 
            
            
            if(idForOppNew.Product__c == 'Event'){
                if(mapUser.containsKey(idForOppNew.OwnerId)){
                    User instOfUsr = mapUser.get(idForOppNew.OwnerId);
                    try{
                        if(instOfUsr.UserRole.Name.contains('Event'))
                        idForOppNew.Product_Category__c = 'Event';
                    }catch(exception e){
                        
                    }
                    
                    try{
                    if(instOfUsr.UserRole.Name.contains('(Ent)'))
                    idForOppNew.Product_Category__c = 'Enterprise';
                    }catch(exception e){
                        
                    }
                    
                    try{
                    //Changes to product category for TPP
                 
                    if(instOfUsr.UserRole.Name.contains('(TPP)') && (idForOppNew.Contract_Implemented__c != oldMapValues.get(idForOppNew.Id).Contract_Implemented__c || idForOppNew.CFC_Check__c != oldMapValues.get(idForOppNew.Id).CFC_Check__c))
                        idForOppNew.Product_Category__c = 'Event';
                        
                    //Changes to product category for TPP     
                    }catch(exception e){
                        
                    }
                }
            }          
        }
        
        //Inserting Buyer Contact Roles and Standard OpportunityContactRole
        if(lstOppContactRole.size()>0){
            insert lstOppContactRole;   
        }
         //Added by Shanu on (26-Sep) AM Validation Contact Role)
        System.Debug('*****MAP OF CONTACT ROLE****' + mapOfAccVSContactRole);
        if(!mapOfAccVSContactRole.isEmpty()){
            CreateBuyerContactRole(mapOfAccVSContactRole,newMapValues);
        }
    }
        
    public void OnAfterUpdate(Map<Id,Opportunity> oldMapValues,Map<Id,Opportunity> newMapValues){
         // set of opportunity ID
        
        Set<ID> setOppID=new Set<ID>();
        // Changes for Bundle Campaigns Records updation and insertion.As Object CSN-MSA was discarded//Rollup Code On Insertion        
        List<String> lstBundleCampId = new List<String>();
        
        //On updating Opp currency, Children currency should get updated.
        Set<Id> setOppCurrChange = new Set<Id>();
        //On updating Opp currency, Children currency should get updated.
        
      
        //Updating contracts record on any opp.
        Set<String> lstOppIdContr = new Set<String>();
        Set<String> setAccId = new Set<String>();
        //Updating contracts record on any opp.
        
        List<Id> lstUpdatePicklistInsertIds = new List<Id>();
        //Updating according to the field value Set_Cancellation_Status__c
        
        //Onsite solutions object record creation
        List<Alliance_OA_Projects__c> lstAllOP = new List<Alliance_OA_Projects__c>();
        //Onsite solutions object record creation
        
        for(Opportunity idForOppNew : newMapValues.values()){
            System.debug('idForOppNew**********'+idForOppNew.Contract_Implemented__c);
            Boolean instOfCh = CheckRecursive.runOnce();
            
            if(test.isRunningTest())
            instOfCh = true;
            
            if(instOfCh){
                //Add by kumud [To avoid recursion and run when reveiwer change at opportuity level] 
                if(newMapValues.get(idForOppNew.Id).MSA_Code__c != oldMapValues.get(idForOppNew.Id).MSA_Code__c){
                    if(idForOppNew.MSA_Code__c != null){
                        lstBundleCampId.add(idForOppNew.MSA_Code__c);
                    }else if(idForOppNew.MSA_Code__c == null){
                        lstBundleCampId.add(oldMapValues.get(idForOppNew.Id).MSA_Code__c);  
                    }
                }//end
                 if(idForOppNew.Contract_Implemented__c && !idForOppNew.Task_Created__c && idForOppNew.Contract_Implemented__c!=oldMapValues.get(idForOppNew.id).Contract_Implemented__c){
                
                    
                    setOppID.add(idForOppNew.id);
                }

                if((idForOppNew.CFC_Check__c != null && idForOppNew.CFC_Check__c !='' && oldMapValues.get(idForOppNew.Id).CFC_Check__c != idForOppNew.CFC_Check__c) || (idForOppNew.Send_This_To_Tract__c != oldMapValues.get(idForOppNew.Id).Send_This_To_Tract__c )){ // (idForOppNew.Re_Reviewed_by__c !=null && idForOppNew.Re_Reviewed_by__c!= '' && oldMapValues.get(idForOppNew.Id).Re_Reviewed_by__c != idForOppNew.Re_Reviewed_by__c)|| [Removed by kumud: field cleanup activity]
                    
                    //Updating contracts record on any opp. 
                    if(idForOppNew.CFC_Check__c != null && idForOppNew.CFC_Check__c !='' && oldMapValues.get(idForOppNew.Id).CFC_Check__c != idForOppNew.CFC_Check__c){
                        lstOppIdContr.add(idForOppNew.Contract_Number_New__c);
                        setAccId.add(idForOppNew.accountId);
                    }
                    //Updating contracts record on any opp. 
                    
                }
              
            }
            //Add by kumud [To avoid recursion and run when reveiwer change at opportuity level] 
            //On updating Opp currency, Children currency should get updated.
            if(newMapValues.get(idForOppNew.Id).CurrencyIsoCode != oldMapValues.get(idForOppNew.Id).CurrencyIsoCode || newMapValues.get(idForOppNew.Id).CloseDate != oldMapValues.get(idForOppNew.Id).CloseDate){
                setOppCurrChange.add(idForOppNew.Id);
            }
            //On updating Opp currency, Children currency should get updated.
            //Updating according to the field value Set_Cancellation_Status__c
            if(idForOppNew.Set_Cancellation_Status__c != oldMapValues.get(idForOppNew.Id).Set_Cancellation_Status__c){
                if(idForOppNew.Set_Cancellation_Status__c == 'Edit & Clone'){
                    //idForOppNew.IsLocked__c   = false;
                    lstUpdatePicklistInsertIds.add(idForOppNew.Id);
                }
            }
            //Updating according to the field value Set_Cancellation_Status__c
            
            //Onsite solutions object record creation
            if(CheckRecursive.runOnceSec()){
                System.debug('********'+idForOppNew.Contract_Implemented__c);
                System.debug('********'+oldMapValues.get(idForOppNew.id).Contract_Implemented__c);
                System.debug('********'+idForOppNew.Alliance_Tech_CheckBox__c);
              if((idForOppNew.Contract_Implemented__c==true && oldMapValues.get(idForOppNew.id).Contract_Implemented__c !=idForOppNew.Contract_Implemented__c && idForOppNew.Alliance_Tech_CheckBox__c == true) || Test.isRunningTest()){
                  Alliance_OA_Projects__c instOfAlliance = new Alliance_OA_Projects__c();
                  instOfAlliance.Event_Name__c = idForOppNew.Event_Name__c;
                  //instOfAlliance.Event_Start_Date__c = idForOppNew.Start_Date__c;
                  //instOfAlliance.Event_Completion_Date__c = idForOppNew.End_Date__c; // comment by kumud Field Cleanup Activity [30 May 2018]
                  //instOfAlliance.Event_Venue__c = idForOppNew.Event_Venue__c;// comment by kumud Field Cleanup Activity [30 May 2018]
                  //instOfAlliance.Event_City__c = idForOppNew.Event_City__c; // comment by kumud Field Cleanup Activity [30 May 2018]
                  //instOfAlliance.Event_Country__c = idForOppNew.Event_Country__c; // comment by kumud Field Cleanup Activity [30 May 2018]
                  //instOfAlliance.of_Attendees__c = idForOppNew.Number_of_Attendees__c!=null?Integer.valueof(idForOppNew.Number_of_Attendees__c):null;
                  //instOfAlliance.of_Exhibitors__c = idForOppNew.Number_of_Exhibitors__c!=null?Integer.valueOf(idForOppNew.Number_of_Exhibitors__c):null;
                  instOfAlliance.Opportunity_Name__c = idForOppNew.Id;
                  instOfAlliance.Contact_name__c = idForOppNew.Contact_Associated__c;
                  instOfAlliance.Account_Name__c = idForOppNew.AccountId;
                  System.debug('strUsrId****'+strUsrId);
                  if(String.isNotBlank(strUsrId))
                      instOfAlliance.OwnerId = strUsrId;
                  if(string.isNotBlank(strRecTyId))
                      instOfAlliance.RecordTypeId = strRecTyId;
                  System.debug('instOfAlliance.RecordTypeId*****'+instOfAlliance.RecordTypeId);
                  /*
                  Remove Badge_Printing__c field from below 4 if idForOppNew.Badge_Printing__c == 'Yes'
                  comment by kumud Field Cleanup Activity [30 May 2018] 
                  */
                  /*if(idForOppNew.Session_Scanning__c == 'Yes' && idForOppNew.Lead_Retrieval__c == 'Yes')
                  instOfAlliance.Services_Included__c = 'Lead Retrieval;Session Tracking';// Badge Printing; [Kumud]
                  if(idForOppNew.Session_Scanning__c == 'Yes'  && idForOppNew.Lead_Retrieval__c == 'No')
                  instOfAlliance.Services_Included__c = 'Session Tracking'; // Badge Printing;[Kumud]
                  if(idForOppNew.Lead_Retrieval__c == 'Yes'  && idForOppNew.Session_Scanning__c == 'No')
                  instOfAlliance.Services_Included__c = 'Lead Retrieval'; // Badge Printing; [Kumud]
                  if(idForOppNew.Lead_Retrieval__c == 'Yes' && idForOppNew.Session_Scanning__c == 'Yes' )// && idForOppNew.Badge_Printing__c == 'No' [Kumud]
                  instOfAlliance.Services_Included__c = 'Session Tracking;Lead Retrieval';
                  */
                  // End here Session_Scanning__c,Lead_Retrieval__c,Badge_Printing__c not in use [Field clean up activity]
                  
                  lstAllOP.add(instOfAlliance);
              }  
            }
        //Onsite solutions object record creation
        }       
        System.debug('lstAllOP****'+lstAllOP);
        //Onsite solutions object record creation
        if(lstAllOP.size()>0){
            insert lstAllOP;
            List<Messaging.SingleEmailMessage> lstMessage = new List<Messaging.SingleEmailMessage>();
            for(Alliance_OA_Projects__c instOfAllOP : lstAllOP){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(instOfAllOP.OwnerId);
                message.setHtmlBody('<html><p>Hey '+strUsrName+'<p> <br/><Below is the link of Onsite Solutions Project record><br/><a style=cursor: pointer; cursor: hand; href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+instOfAllOP.Id+'">Click Here</a> </html>');
                message.setSaveAsActivity(false);
                lstMessage.add(message);
            }
            if(!test.isRunningTest() && lstMessage.size()>0)
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(lstMessage);
        }
        //Onsite solutions object record creation
        
        //Updating according to the field value Set_Cancellation_Status__c
        if(lstUpdatePicklistInsertIds.size()>0){
            String soql = getCreatableFieldsSOQL('Opportunity');
            soql = soql + 'lstUpdatePicklistInsertIds';
            OppotunityHelperClsUtil.insertNewOpps(soql,lstUpdatePicklistInsertIds);
        }
        //Updating according to the field value Set_Cancellation_Status__c
        
        //Updating contracts record on any opp. 
        List<Opportunity> lstOppContr = new List<Opportunity>();
        if(lstOppIdContr.size()>0)
        lstOppContr = [SELECT Id,New_Contract_Total__c,Contract_Number_New__c,(SELECT Id,Status FROM /* ATG */Contracts__r ) FROM Opportunity WHERE Contract_Number_New__c =: lstOppIdContr AND StageName='Closed Won' AND AccountId=:setAccId];

        map<String,Decimal> mapStrTotal = new map<String,Decimal>();
        for(Opportunity instOfOpp : lstOppContr){
            if(mapStrTotal.containsKey(instOfOpp.Contract_Number_New__c)){
                Decimal tempTotal = mapStrTotal.get(instOfOpp.Contract_Number_New__c);
                tempTotal = tempTotal + instOfOpp.New_Contract_Total__c;
                mapStrTotal.put(instOfOpp.Contract_Number_New__c,tempTotal);
            }else{
                mapStrTotal.put(instOfOpp.Contract_Number_New__c,instOfOpp.New_Contract_Total__c);
            }
        }
        
        List<Contract> lstContr = new List<Contract>();
        for(Opportunity instOfOpp : lstOppContr){
            for(Contract isntOfContr : instOfOpp.Contracts__r){
                if(mapStrTotal.containsKey(instOfOpp.Contract_Number_New__c)){
                    isntOfContr.Total_Contract_Value__c = mapStrTotal.get(instOfOpp.Contract_Number_New__c);
                    isntOfContr.Status = 'Closed/Executed'; 
                    lstContr.add(isntOfContr);
                }
            }
        }
        
        if(lstContr.size()>0)
        update lstContr;
        //On updating Opp currency, Children currency should get updated.
        List<Opportunity> lstOfQueried = new List<Opportunity>();
      
        List<Opportunity> lstOppCr_ContReviewsSec = new List<Opportunity>();
        
        if(setOppCurrChange.size()>0)
        lstOfQueried = [SELECT Id,CurrencyIsoCode,Exchange_Rate__c,(SELECT Id,CurrencyIsoCode,Exchange_Rate__c FROM TM_Fee_Structure__r),(SELECT Id,CurrencyIsoCode,Exchange_Rate__c FROM OpportunityLineItems),(SELECT Id,CurrencyIsoCode FROM Invoicing_Details__r)
                             ,(SELECT Id,CurrencyIsoCode,Exchange_Rate__c FROM CSN_Credits__r),(SELECT Id,CurrencyIsoCode,Exchange_Rate__c FROM CSN_Campaigns__r) FROM Opportunity WHERE Id =: setOppCurrChange And CurrencyIsoCode != null And Exchange_Rate__c != null];
        
       
        List<TM_Fee_Structure__c> lstTMFS =  new List<TM_Fee_Structure__c>();
        List<OpportunityLineItem> lstFeatSet =  new List<OpportunityLineItem>();
        List<Invoicing_Details__c> lstInvDet =  new List<Invoicing_Details__c>();
        List<CSN_Credit__c> lstCSNCred = new List<CSN_Credit__c>();
        List<Multi_Property_Bundles__c> lstMPB = new List<Multi_Property_Bundles__c>();
        Set<Id> setInvDet = new Set<Id>();
        
        for(Opportunity instOfOpp : lstOfQueried){
            for(TM_Fee_Structure__c instOfTMFS : instOfOpp.TM_Fee_Structure__r){
                instOfTMFS.CurrencyIsoCode = instOfOpp.CurrencyIsoCode;
                instOfTMFS.Exchange_Rate__c = instOfOpp.Exchange_Rate__c;
                lstTMFS.add(instOfTMFS);
            }
        }
        
        for(Opportunity instOfOpp : lstOfQueried){
            for(OpportunityLineItem instOfFeat : instOfOpp.OpportunityLineItems){
                instOfFeat.Exchange_Rate__c = instOfOpp.Exchange_Rate__c;
                lstFeatSet.add(instOfFeat);
            }
        }
        
        for(Opportunity instOfOpp : lstOfQueried){
            for(Invoicing_Details__c instOfINvDet : instOfOpp.Invoicing_Details__r){
                instOfINvDet.CurrencyIsoCode = instOfOpp.CurrencyIsoCode;
                setInvDet.add(instOfINvDet.Id);
                lstInvDet.add(instOfINvDet);
            }
        }
        
        for(Opportunity instOfOpp : lstOfQueried){
            for(CSN_Credit__c instOfCred : instOfOpp.CSN_Credits__r){
                instOfCred.CurrencyIsoCode = instOfOpp.CurrencyIsoCode;
                instOfCred.Exchange_Rate__c = instOfOpp.Exchange_Rate__c;
                lstCSNCred.add(instOfCred);
            }
        }
        
        for(Opportunity instOfOpp : lstOfQueried){
            for(Multi_Property_Bundles__c instOfMPB : instOfOpp.CSN_Campaigns__r){
                instOfMPB.CurrencyIsoCode = instOfOpp.CurrencyIsoCode;
                instOfMPB.Exchange_Rate__c = instOfOpp.Exchange_Rate__c;
                lstMPB.add(instOfMPB);
            }
        }
        
        List<Invoicing_Details__c> lstInvDetLI = new List<Invoicing_Details__c>();
        
        
        
        if(lstTMFS.size()>0)
        update lstTMFS;
        
        if(lstFeatSet.size()>0)
        update lstFeatSet;
        
        //if(lstInvDet.size()>0)
        //update lstInvDet;
        
        if(lstCSNCred.size()>0)
        update lstCSNCred;
        
        if(lstMPB.size()>0)
        update lstMPB;
        
        if(setInvDet.size()>0)
        lstInvDetLI = [SELECT Id, Opportunity__r.CurrencyIsoCode,Opportunity__r.Exchange_Rate__c,(SELECT Id,CurrencyIsoCode,Exchange_Rate__c FROM Invoicing_Line_Items__r) FROM Invoicing_Details__c WHERE Id =: setInvDet And Opportunity__r.Exchange_Rate__c != null And Opportunity__r.CurrencyIsoCode != null];
        
        List<Invoicing_Line_Items__c> lstILI = new List<Invoicing_Line_Items__c>();
        
        for(Invoicing_Details__c incvoicingDet : lstInvDetLI){
            for(Invoicing_Line_Items__c instOfInvLI : incvoicingDet.Invoicing_Line_Items__r){
                instOfInvLI.CurrencyIsoCode = incvoicingDet.Opportunity__r.CurrencyIsoCode;
                instOfInvLI.Exchange_Rate__c = incvoicingDet.Opportunity__r.Exchange_Rate__c;
                lstILI.add(instOfInvLI);
            }
        }
        
        if(lstILI.size()>0)
        update lstILI;  
        
        //On updating Opp currency, Children currency should get updated.
        
        List<Multi_Property_Bundles__c> lstMultiPropBund = new List<Multi_Property_Bundles__c>();
        
        if(lstBundleCampId.size()>0)
        lstMultiPropBund =  [SELECT Id,MSA_Total__c,(SELECT ID,New_Contract_Total__c FROM Opportunities_Bund__r) FROM Multi_Property_Bundles__c WHERE MSA_Code__c =: lstBundleCampId];
                
        List<Multi_Property_Bundles__c> lstMultiPropBundSec = new List<Multi_Property_Bundles__c>();
        for(Multi_Property_Bundles__c instOfMutiPropBund : lstMultiPropBund){
            Decimal intContractTot=0;
            for(Opportunity instOfOpp : instOfMutiPropBund.Opportunities_Bund__r){
                intContractTot = intContractTot + instOfOpp.New_Contract_Total__c;
            }
            instOfMutiPropBund.MSA_Total__c = String.valueOf(intContractTot);
            lstMultiPropBundSec.add(instOfMutiPropBund);
        }       
        if(lstMultiPropBundSec.size()>0){
            update lstMultiPropBundSec;
        }        
       
        
        //Method for Checking for Security Review of an Opportunity to share those with Sales Engineers using sharing Rule on Account (If checked)
        if(CheckRecursive.runOnceSeventh())
        SalesEngineerAccessToOpportunity(newMapValues.values(),oldMapValues);
         // task automation
        if(!setOppID.isEmpty() && Label.IsTaskAutomationActive == 'True'){
                
                TaskAutomation.taskAutoCreation(setOppID);
        }// end here ---> Task creation code
    }
    public void OnBeforeDelete(List<Opportunity> oldValues,Map<Id,Opportunity> oldMapValues){
        
    }
   public void OnAfterDelete(List<Opportunity> oldValues,Map<Id,Opportunity> oldMapValues){
        
        // Changes for Bundle Campaigns Records updation and insertion.As Object CSN-MSA was discarded//Rollup Code On Insertion
        
        /*
          Comment by kumud below code seems never execute
          
           2 jun 18
        */  
        /*
        List<Id> lstBundleCampId = new List<Id>();      
      
        List<Multi_Property_Bundles__c> lstMultiPropBund =  new List<Multi_Property_Bundles__c>();
        if(lstBundleCampId.size()>0) //  it is always false because lstBundleCampId is empty. [Added by Kumud 2 Jun 2018]
        lstMultiPropBund =  [SELECT Id,MSA_Total__c,(SELECT ID,New_Contract_Total__c FROM Opportunities_Bund__r) FROM Multi_Property_Bundles__c WHERE Id =: lstBundleCampId];       
        
        List<Multi_Property_Bundles__c> lstMultiPropBundSec = new List<Multi_Property_Bundles__c>(); */
        
        /*
         Comment the code because it never execute because lstMultiPropBund always empty. 
        */
        /*
        for(Multi_Property_Bundles__c instOfMutiPropBund : lstMultiPropBund){
            Decimal intContractTot=0;
            for(Opportunity instOfOpp : instOfMutiPropBund.Opportunities_Bund__r){
                intContractTot = intContractTot + instOfOpp.New_Contract_Total__c;
            }
            instOfMutiPropBund.MSA_Total__c = String.valueOf(intContractTot);
            lstMultiPropBundSec.add(instOfMutiPropBund);
        }       
        
        if(lstMultiPropBundSec.size()>0){
            update lstMultiPropBundSec;
        }*/
        // Changes for Bundle Campaigns Records updation and insertion.As Object CSN-MSA was discarded//Rollup Code On Insertion
        
    }
    public void OnUndelete(List<Opportunity> newValues){
        
    }
    
    //Method added for Case#05795266 (@Author Shanu Aggarwal)
    //Giving Opportunity access to Sales Engineer Sharing Group when Security Review is checked
    public void SalesEngineerAccessToOpportunity(List<Opportunity> opps , Map<Id,Opportunity> oldMapValues) {
        
       
        Map<Id,Account> mapAccounts = new Map<Id,Account>();
        //Checking Opportunities if the are marked for Security review 
        for(Opportunity o : opps){
            //Security review is changed or Opportunity is inserted 
            if(o.AccountId!=null  && (oldMapValues==null || (oldMapValues!=null && o.Request_Security_Review__c!=oldMapValues.get(o.Id).Request_Security_Review__c))){
              
                Account acc = new Account();
                acc.Id = o.AccountId ;
                acc.Is_Opp_Shared_With_SE_Group__c  = o.Request_Security_Review__c;
                mapAccounts.put(acc.Id,acc);
            }
        }
        
       
        
        //Updating Accounts
        if(!mapAccounts.isEmpty()){
            update mapAccounts.values();
        }
    }
    
    
    
    //Updating according to the field value Set_Cancellation_Status__c
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public string getCreatableFieldsSOQL(String objectName){
         
        String selects = '';
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
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
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE Id=: ';
         
    }
    
    
    /* HSR : 25th May : removal of TAB character from som fields*/
    private void removeTABCharacter(List<Opportunity> opportuityList)
    {
        For(Opportunity idForOppNew : opportuityList){
            if(idForOppNew.New_Type__c!=null){
                System.debug('Before Removal New Type====>'+idForOppNew.New_Type__c.length());
                idForOppNew.New_Type__c=idForOppNew.New_Type__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal New Type====>'+idForOppNew.New_Type__c.length());   
            }
            if(idForOppNew.Federal_Tax_Id__c!=null){
                System.debug('Before Removal Federal Tax====>'+idForOppNew.Federal_Tax_Id__c.length());
                idForOppNew.Federal_Tax_Id__c=idForOppNew.Federal_Tax_Id__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal Federal Tax====>'+idForOppNew.Federal_Tax_Id__c.length());
            }
            if(idForOppNew.Mobile_App_Version__c!=null){
                System.debug('Before Removal Federal Tax====>'+idForOppNew.Mobile_App_Version__c.length());
                idForOppNew.Mobile_App_Version__c=idForOppNew.Mobile_App_Version__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal Federal Tax====>'+idForOppNew.Mobile_App_Version__c.length());
            }
           
            if(idForOppNew.AM_CSN__c!=null){
                System.debug('Before Removal Federal Tax====>'+idForOppNew.AM_CSN__c.length());
                idForOppNew.AM_CSN__c=idForOppNew.AM_CSN__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal Federal Tax====>'+idForOppNew.AM_CSN__c.length());
            }
            if(idForOppNew.AM_Owner__c!=null){
                System.debug('Before Removal Federal Tax====>'+idForOppNew.AM_Owner__c.length());
                idForOppNew.AM_Owner__c=idForOppNew.AM_Owner__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal Federal Tax====>'+idForOppNew.AM_Owner__c.length());
            }
           
            if(idForOppNew.ARClause__c!=null){
                System.debug('Before Removal Federal Tax====>'+idForOppNew.ARClause__c.length());
                idForOppNew.ARClause__c=idForOppNew.ARClause__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal Federal Tax====>'+idForOppNew.ARClause__c.length());
            }  
                        if(idForOppNew.Contract_Number_New__c!=null){
                System.debug('Before Removal Federal Tax====>'+idForOppNew.Contract_Number_New__c.length());
                idForOppNew.Contract_Number_New__c=idForOppNew.Contract_Number_New__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal Federal Tax====>'+idForOppNew.Contract_Number_New__c.length());
            } 
            if(idForOppNew.CVII_Contract_Number__c!=null){
                System.debug('Before Removal Federal Tax====>'+idForOppNew.CVII_Contract_Number__c.length());
                idForOppNew.CVII_Contract_Number__c=idForOppNew.CVII_Contract_Number__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal Federal Tax====>'+idForOppNew.CVII_Contract_Number__c.length());
            }    
           
        }
    }

    //Added by Shanu for Contact Role (AM Validation ) on 26 Sep 2016
    /*
    **  Creare Buyer Role on Custom Object "Contact Role" 
    **  once OpportunityContactRole inserted.
    **/
    private void CreateBuyerContactRole(Map<Id,List<OpportunityContactRole>> mapOfAccVSContactRole, Map<Id,Opportunity> newMapValues){
       
        
        Id buyerRecTypeId = Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByName().get('Buyer Role').getRecordTypeId();
        //Set of Old Contacts with Contact Role
        Map<Id,Contact_Role__c> oldConIdVSCRIdMap = new Map<Id,Contact_Role__c>();
        //Remove NULL account Id's 
        mapOfAccVSContactRole.remove(null);
        
        //Getting all contact roles for given account to check duplicate
        for( Contact_Role__c oldConRole : [Select Id,Contact__c,Decision_Maker_Products__c,Executive_Sponsor_Products__c,Influencer_Products__c
                                           From Contact_Role__c where Account_Buyer_Role__c IN : mapOfAccVSContactRole.keySet() and RecordTypeId=:buyerRecTypeId]){
            oldConIdVSCRIdMap.put(oldConRole.Contact__c,oldConRole);
        }
        
        //Insert list
        List<Contact_Role__c> conRoleList = new List<Contact_Role__c>();
        //Update list
        Map<Id,Contact_Role__c> conRoleUpdateMap = new Map<Id,Contact_Role__c>();
       
        List<String> listProducts;
        Set<String> setProducts;
        
        //Iterate All OpportunityContactRoles 
        for(Id accId : mapOfAccVSContactRole.keySet()){
            
            //Create Buyer Contact Roles
            for(OpportunityContactRole ocr : mapOfAccVSContactRole.get(accId)){
               
                String newProduct = newMapValues.get(ocr.OpportunityId).Product__c;
                
                System.Debug('$$$$$PRODUCT$$$$' + newProduct);
                
                Contact_Role__c cr = new Contact_Role__c();
                //If role is new 
                if(!oldConIdVSCRIdMap.containsKey(ocr.ContactId)){
                    
                    cr.RecordTypeId = buyerRecTypeId;
                    cr.Account_Buyer_Role__c = accId;
                    cr.Contact__c  = ocr.ContactId;
                    cr.Opportunity__c = ocr.OpportunityId;
                    
                    //Setting Roles from OpportunityContactRole
                    if(ocr.Role == 'Executive Sponsor'){
                        cr.Executive_Sponsor__c = true;
                        system.debug('****newProduct0'+newProduct);
                        cr.Executive_Sponsor_Products__c = newProduct + ';';
                    }else if(ocr.Role == 'Decision Maker' ){
                        cr.Decision_Maker__c = true;
                        cr.Decision_Maker_Products__c = newProduct + ';';
                    }else if(ocr.Role == 'Influencer'){
                        cr.Influencer__c = true;
                        cr.Influencer_Products__c = newProduct + ';';
                    }
                    conRoleList.add(cr);
                }
                
                //Checking Duplicate Contact Role updated
                else if(oldConIdVSCRIdMap.containsKey(ocr.ContactId)){
                    cr = oldConIdVSCRIdMap.get(ocr.ContactId);
                    
                    //Checking Existing Products

                    List<String> productList = new List<String>();
          Set<String>  executiveSet = new Set<String>{};
          Set<String>  decisionSet = new Set<String>{};
          Set<String>  influencerSet = new Set<String>{};

          if(cr.Executive_Sponsor_Products__c!=null){
              productList = cr.Executive_Sponsor_Products__c.split(';');    
              executiveSet.addAll(productList);
          }
          
          if(cr.Decision_Maker_Products__c!=null){
              productList = cr.Decision_Maker_Products__c.split(';');
              decisionSet.addAll(productList);
          }
            
          if(cr.Influencer_Products__c!=null){
            productList = cr.Influencer_Products__c.split(';');
            influencerSet.addAll(productList);
          }
          
          //Updatinh Existing Products
          if(ocr.Role == 'Executive Sponsor'){
            
            if(!executiveSet.contains(newproduct)){
              cr.Executive_Sponsor__c = true;
              cr.Executive_Sponsor_Products__c = cr.Executive_Sponsor_Products__c!=null ? cr.Executive_Sponsor_Products__c + ';' + newProduct : newProduct;
            }
                        
                    }else if(ocr.Role == 'Decision Maker' ){
            if(!decisionSet.contains(newproduct)){
              cr.Decision_Maker__c = true;
              cr.Decision_Maker_Products__c = cr.Decision_Maker_Products__c!=null ? cr.Decision_Maker_Products__c + ';' + newProduct : newProduct;
            }
                        
                        
                    }else if(ocr.Role == 'Influencer'){
            if(!influencerSet.contains(newproduct)){
              cr.Influencer__c = true;
              cr.Influencer_Products__c = cr.Influencer_Products__c!=null ? cr.Influencer_Products__c + ';' + newProduct : newProduct;
            }
                    }
                    cr.Contact_Validated_Date__c=system.now(); //  added by udita to validate the new contact role as soon as it is created
                    conRoleUpdateMap.put(cr.Id,cr);
                }
                 
            }
            
        }
        
        if ( conRoleList.size()>0 || !Test.isRunningTest()){

            List<Contact_Role__c> crList = new List<Contact_Role__c>();
            for(Contact_Role__c cr : conRoleList){
                    if(cr.Contact__c!=null){
                        cr.Contact_Validated_Date__c=system.now();   //  added by udita to validate the existing contact role when opportunity is closed won
                        crList.add(cr);
                    }
            }
            insert crList;
        }
        
        if (!conRoleUpdateMap.isEmpty()){
            update conRoleUpdateMap.values();
        }
        
    }

     /* 
     * Set default fields to fix Contact Role validation issue at Opportunit Before Insert event for CPQ
     * Method call from OpportunityTrg.
     * Added on 7/14 by PK.  
    */
    //Commented the below procedure out on 9/19/17 to avoid cpq conflict - reverted on 9/19/17
      public void onInsert_DefaultFieldsForCPQ_RenewalMYD(List<Opportunity> newList){ 
       Set<ID> contractIds = new Set<ID>();
       Set<ID> amendcontractIds = new Set<ID>();
        Map<Id,Contract> oppContractsMap;
            
        //Filter Opportunities if Primary Quote or Renewed Contract is changed
        for(Opportunity newOpp : newList){
            //Historical Opportunities are exmpt from this
            //if( !newOpp.Bypass_Historic_Opp__c ){
                if(newOpp.SBQQ__RenewedContract__c!=null)
                    contractIds.add(newOpp.SBQQ__RenewedContract__c);
                if(newOpp.SBQQ__AmendedContract__c!=null)
                    amendcontractIds.add(newOpp.SBQQ__AmendedContract__c);
            //}
        }
        
        
        if((!contractIds.isEmpty())||(!amendcontractIds.isEmpty())){
            oppContractsMap = new Map<Id,Contract>([ Select Id, SBQQ__Opportunity__c,SBQQ__Opportunity__r.Contact_Associated__c, SBQQ__Opportunity__r.Contact_Role__c From Contract Where ID IN: contractIds OR ID IN: amendcontractIds]);

        for(Opportunity newOpp : newList){
                //Mapping from Renewed Contract
                if(newOpp.SBQQ__RenewedContract__c!=null){   
                    //Get first year Opportunity from Renewed Contract 
                    Opportunity syncedFromOpp = oppContractsMap.get(newOpp.SBQQ__RenewedContract__c).SBQQ__Opportunity__r!=null?oppContractsMap.get(newOpp.SBQQ__RenewedContract__c).SBQQ__Opportunity__r:new Opportunity() ;
                    //Map fields from Renewed Contract on Opp
                    newOpp.Contact_Associated__c = syncedFromOpp.Contact_Associated__c;
                    newOpp.Contact_Role__c = syncedFromOpp.Contact_Role__c;
                    break; //this is used so that if both renewed & amended contract exists then it should pick from renewed contracts only
                }
                if(newOpp.SBQQ__AmendedContract__c!=null){   
                    //Get first year Opportunity from Renewed Contract 
                    Opportunity syncedFromOpp = oppContractsMap.get(newOpp.SBQQ__AmendedContract__c).SBQQ__Opportunity__r;
                    //Map fields from Renewed Contract on Opp
                    newOpp.Contact_Associated__c = syncedFromOpp.Contact_Associated__c;
                    newOpp.Contact_Role__c = syncedFromOpp.Contact_Role__c;
                }
            }
        }

    }

}