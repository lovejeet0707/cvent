/*
File Name :TaskAutomation
Date :18 Aug 2018
Author :Kumud Thakur
DESC: This is use to create task,case and onbaording during the contractImplement on opportunity. Class call by opportunity trugger helper class 
      on after update.
Vesrion 1.0
======================================================================================================    
Modified by |   Modified Date | Version | Desc|  


*/

public class TaskAutomation {
 
    static list<case> listCaseInsert = new list<case>();
    static list<task> listTaskInsert = new list<task>();  // need to check if it can be reused
    static list<Onboarding__c> listOnboardInsertCon1HcPlannerCS= new list<Onboarding__c>(); 
    static Id oppRecTyperenewal = schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
    static map<string,Id> mapSourceRep = new map<string,id>();
    static map<id,Alliance_OA_Projects__c>  OppIdVsOnsite = new map<id,Alliance_OA_Projects__c>();
    static list<Onboarding__c> listOnsiteInsert = new list<Onboarding__c>();
    static set<string> setProdLine= new set<string>();
    static map<Id, string> mapOpIDvsProdName = new map<id,string>();
    static  map<Id,string> mapdiamondvalue = new map<Id,string>();
    static map<Id,string> mapOpidvsProductcodesoftwareInt = new map<id,string>();
    static Map<Id,Onboarding__c> mapOnboarding=new Map<Id,Onboarding__c>();
    static string bundleMSACode ='';
    static date bundleMSAEndDate;
    static Integer i=0;
    static Map<Id,Boolean> mapOpptyHasBundle=new Map<Id,Boolean>();
    static Map<Id,Opportunity> mapOpportunity;
    static Set<Id> setOfOpportunityForFirstCondition = new Set<Id>();
    static Set<Id> setOfOpportunityForSecondCondition = new Set<Id>();
    @future
    public static void taskAutoCreation(set<ID> setOppId){
        //HC-CS Supplier #11, #12
        map<String,Decimal> SKUNameVsSalesPrice = new Map<String,Decimal>();
        //For HC-AM planner set (will be changed to custom setting/metadata)
        set<string> setDiamondCode = new set<string>();
        setDiamondCode.addAll(label.DiamondCode.split(','));
        //for product family "Analytics & Rfp performace" used in HC-AM
        Set<string> AnalyticRfpperformace = new set<string>();//{'CV-SW-HC-CSN-RFPRCS','CV-SW-HC-CSN-RFPRCS1-500',
                        //'CV-SW-HC-CSN-RFPRCS500+','CV-SW-HC-CSN-RFPRE',
                         //'CV-SW-HC-CSN-RFPRA','CV-SW-HC-CSN-RFPREENTDASH',
                         //'CV-SW-HC-CSN-RFPRDDCON','CV-SW-HC-CSN-SCADSCAT'};
                   AnalyticRfpperformace.addAll(label.AnalyticRfpperformace.split(','));    
        //for product family Software & Integration used in HC-AM
        Set<string> setSoftwareIntegration = new set<string>();//{'CV-PS-HC-CSN-SUPFEAADVCUSPR',
                         //'CV-PS-HC-CSN-SUPFEABCUSPR'}; 
                   setSoftwareIntegration.addAll(label.SoftwareIntegration.split(','));
        set<String> setOppSKU=new Set<String>();
        set<Id> setAccIdOfOpp = new set<Id>(); // for  account team member
        
        Set<ID> setQuoteId=new Set<ID>();
        set<string> setofnameOfsourcingRep = new set<string>();
       
        ID currentuser=userinfo.getUserId(); //default user
        set<String> setProdCode = new set<string>();//To add sKU code 
        mapOpportunity=new Map<ID,Opportunity>([select Id,AccountId,Bundle_Campaigns__c,Contact_Associated__c,
                                         Bundle_Campaigns__r.MSA_code__c,account.PA_Rep__c,Contract_Number_New__c,
                                         Bundle_Campaigns__r.End_date__c,Task_Created__c,
                                         contract_Implemented__c,name,SBQQ__PrimaryQuote__c,SBQQ__PrimaryQuote__r.Contract_Opt_Out_Deadline__c,Account.Name 
                                         from opportunity where Id In:setOppId]
        
        );
        List<opportunity> listOpp = new List<Opportunity>();
        listOpp.addAll(mapOpportunity.values());
        List<opportunityLineItem> olilist =[Select Id,PriceBookEntry.Product2Id,Product_Line__c,Product2.Product_Line__c,Product_Name__c, opportunityId,
                            productCode from opportunityLineItem where opportunityId In:setOppId];
        List< Alliance_OA_Projects__c> ListOnsiteSolution = new list<Alliance_OA_Projects__c>();
        ListOnsiteSolution = [Select Id,Event_Start_Date__c,Opportunity_Name__c,Project_Owner__c,
                  Event_Completion_Date__c,Ownerid
                 ,name,Account_Name__c from Alliance_OA_Projects__c where Opportunity_Name__c In: setOppId ];
        if(!ListOnsiteSolution.isEmpty()){
        for(Alliance_OA_Projects__c instOfonsite :ListOnsiteSolution)
        {
            OppIdVsOnsite.put(instOfonsite.Opportunity_Name__c, instOfonsite); // need to make unique  key 
          }
        }
        


        for(opportunityLineItem instofOli : Olilist){
          
            setProdLine.add(instofOli.Product2.Product_Line__c);
            //condition for setCSNplannerProd 1,2,3 sku in the set
            
            setOppSKU.add(instofOli.productcode);
            
           
            //logic for product name in task in Hc-AM 2nd condition*/
            if(setDiamondCode.contains(instofOli.productcode))
            {
                //mapOpIDvsProdName.put(instofOli.OpportunityId,instofOli.Product_Name__c);
                mapdiamondvalue.put(instofOli.Id,instofOli.Product_Name__c);
            }
            
           

            if(setSoftwareIntegration.contains(instofOli.productcode))
            { 
                mapOpidvsProductcodesoftwareInt.put(instofOli.id,instofOli.Product_Name__c);
            }
           

        }// end of loop
        
         
        for(opportunity instOfop :listOpp){
            
            bundleMSACode=instofOp.Bundle_Campaigns__r.MSA_code__c;
             setofnameOfsourcingRep.add(instOfop.account.PA_Rep__c);
             if(bundleMSAEndDate!= null)
             {
                bundleMSAEndDate =instofOp.Bundle_Campaigns__r.End_date__c;
             }
             else
             {
                 bundleMSAEndDate= system.today();
             }
            setAccIdOfOpp.add(instOfop.accountId);
            setQuoteId.add(instOfop.SBQQ__PrimaryQuote__c);     
        }
        //finding Account team member role here and respected userId
        map<string,Id> mapAccTeam = new map<String,Id>();
       
        list<accountTeamMember> accteam = [select Id,accountId,account.PA_Rep__c,userId,TeamMemberrole
                               from accountTeamMember where accountId In:setAccIdOfOpp];
        for(accountTeamMember acMem :accteam)
        {
            mapAccTeam.put(acMem.TeamMemberRole,acmem.UserId);
           
        }
        for(user instofuser :[select id ,name from user where (NOT Profile.Name like '%Community%') AND isActive = true AND name in:setofnameOfsourcingRep])
        {
            mapSourceRep.put(instofuser.Name, instofuser.Id);
        }
        
        if(!setQuoteId.isEmpty()){
            
            for(SBQQ__QuoteLine__c instQtln:[select SBQQ__ProductCode__c,SBQQ__NetTotal__c,SBQQ__Product__r.Product_Line__c,Product_Line__c,SBQQ__Quote__r.SBQQ__Opportunity2__c from SBQQ__QuoteLine__c where SBQQ__Quote__c in :setQuoteId]){
                
                if(instQtln.SBQQ__Product__r.Product_Line__c!=null && instQtln.SBQQ__Product__r.Product_Line__c=='Bundles'){
                    
                    mapOpptyHasBundle.put(instQtln.SBQQ__Quote__r.SBQQ__Opportunity2__c,true);
                }
                if(instQtln.SBQQ__ProductCode__c=='CV-SW-HC-CSN-WHTLAPRO')
                {
                    SKUNameVsSalesPrice.put('CV-SW-HC-CSN-WHTLAPRO',instQtln.SBQQ__NetTotal__c);
                }
                
            }
        } // Product__c
        list<booking_classification__c> bClassList = [select Id,name,opportunity__c,New_Logo_Total__c,UpSell_Total__c,
                                      Cross_Sell_Total__c,Opportunity__r.Name,Opportunity__r.contract_Implemented__c,Renewal_Value_Total__c,
                                      Opportunity__r.StageName,Opportunity__r.Opp_End_Date__c,Product_family__c,
                                      Opportunity__r.AccountId,Opportunity__r.Contract_Implemented_Date__c,
                                      Opportunity__r.MSA_Code__c,Opportunity__r.Opportunity_Start_Date_EBS__c,Opportunity__r.OptOutDate__c,
                                      Opportunity__r.Opportunity_Start_Date__c,Opportunity__r.recordtypeId,
                                      Opportunity__r.Other_MSA_Code__c,Opportunity__r.ContractEndDate__c,
                                      Opportunity__r.CloseDate,Opportunity__r.ContractStartDate__c,Opportunity__r.Contract_Number_New__c,
                                      Opportunity__r.Account.Venue_Type__c, Opportunity__r.account.PA_Rep__c,Opportunity__r.Account.Billingcountry,Opportunity__r.Product__c,
                                      Opportunity__r.ownerId,Opportunity__r.Account.OwnerId,
                                      Opportunity__r.SBQQ__PrimaryQuote__c,
                                      Opportunity__r.Opportunity_Type__c,
                                      MYD_Total__c,Opportunity__r.RenewalDate__c,Opportunity__r.SBQQ__PrimaryQuote__r.Opt_Out__c,Opportunity__r.Ship_To_Contact__c     from booking_classification__c where opportunity__c In:setOppId];
               system.debug('booking'+bClassList);
          
            for(booking_classification__c instBooking :bClassList)
            {    system.debug('booking'+instBooking.Product_Family__c);
                HC_Planner(instBooking,mapAccTeam,setOppSKU,oppRecTyperenewal);
                //  HC-Planner CS Ends *//
                //*for HC-AM*//
                HC_AM(instBooking,mapAccTeam,setOppSKU,oppRecTyperenewal);
                // CS-Supplies task creation
                if(instBooking.Opportunity__r.Stagename.contains('Closed Won')){
                    
                    HCSupplier_Task(instBooking,mapAccTeam,setOppSKU,oppRecTyperenewal,SKUNameVsSalesPrice);
                }   
                
                //Ec-AM 
                ECAM_Task(instBooking,mapAccTeam,setOppSKU,oppRecTyperenewal);
                //CCCS-task //AMA //CSN-planner for sales
                CCCS_Task(instBooking,mapAccTeam,setOppSKU,oppRecTyperenewal);
            }

    /*Insert Everything here after null check*/
    /*  Insertion task/Onboarding Insertion*/
        System.debug('listOnboardInsertCon1HcPlannerCS*****'+listOnboardInsertCon1HcPlannerCS.size());
            if(!listOnboardInsertCon1HcPlannerCS.isEmpty())
            {
                insert listOnboardInsertCon1HcPlannerCS;
            }
            if(!listCaseInsert.isEmpty())
            { try{
                insert listCaseInsert;
            }
             catch(exception e)
             {
                 system.debug('emessga'+e.getMessage());
             }
            }
            if(!listTaskInsert.isEmpty())
            {    system.debug('listTaskInsert'+listTaskInsert);
                insert listTaskInsert;
            }
            if(!listOnsiteInsert.isEmpty())
            {
                System.debug('size***'+listOnsiteInsert.size());
                insert listOnsiteInsert;
            }
            
            setTaskCreatedField(listOpp);

    } // end of method
    /*
      CS- supplier
    */
    private static void HCSupplier_Task(booking_classification__c instBookingClsf,Map<string,ID> mapAccTeam, Set<String> setOppSKU,Id oppRecType,Map<String,Decimal> SKUNameVsNetToal){
        
                        // List<Task> listTaskInsert=new List<Task>();
            final set<String> setSKU6=new Set<String>();//{'CV-AD-HC-EMI-ELMENCMKTPGM','CV-AD-HC-EMI-ELMPRMKTPRD','CV-AD-HC-EMI-ELMPRMKTPRDGM','CV-AD-HC-EMI-ELMSTMKTPGM','CV-AD-HC-EMI-SPDRFPENCVISPKG','CV-AD-HC-EMI-SPDPRVISPKG','CV-AD-HC-EMI-SPDSTVISPKG'};
            setSKU6.addAll(label.SKU5.split(','));
            final set<String> setSKU8=new Set<String>();//{'CV-AD-HC-EMI-ELMPRMKTPRDGM'};
            setSKU8.addAll(label.SKU8.split(','));
            final set<String> setSKU9=new Set<String>();//{'CV-AD-HC-CSN-1DIA','CV-AD-HC-CSN-2DIA',
                                      //'CV-AD-HC-CSN-3DIA','CV-AD-HC-CSN-4DIA'};
            setSKU9.addAll(label.SKU9.split(','));
            final Set<String> setSKU3=new Set<String>();//{'CV-AD-HC-CSN-1DIA'}'
            final set<String> setSKU5=new Set<String>();
            setSKU5.addAll(label.SKU.split(','));
            //,'CV-AD-HC-CSN-2DIA',
            //'CV-AD-HC-CSN-3DIA','CV-AD-HC-CSN-4DIA'};
            setSKU3.addAll(label.SKU3Diamond.split(','));
            final set<string> setSku10=new Set<String>();//{'CV-AD-HC-EMI-ELMENCMKTPGM','CV-AD-HC-EMI-ELMPRMKTPRD','CV-AD-HC-EMI-ELMPRMKTPRDGM','CV-AD-HC-EMI-ELMSTMKTPGM','CV-AD-HC-EMI-SPDRFPENCVISPKG','CV-AD-HC-EMI-SPDPRVISPKG','CV-AD-HC-EMI-SPDSTVISPKG'};
            setSKU10.addAll(label.SKU10.split(','));
            final set<String> setSKU11=new Set<String>();//{'CV-SW-HC-CSN-WHTLAPRO'};
            setSKU11.addAll(label.SKU11.split(','));
            final set<string> setsku12= new set<string>();//{'CV-PS-HC-CSN-SUPFEABCUSPR'};
            setSKU12.addAll(label.SKU12.split(','));
            final set<string> setsku13= new set<string>();//{'CV-PS-HC-CSN-SUPFEAADVCUSPR'}; 
            setSKU13.addAll(label.SKU13.split(','));
            final set<String> setSKU16A=new Set<String>(); // CV-SW-HC-CSN-BNDSGTDADSCORPPOOL,CV-AD-HC-CSN-BOONDT
            setSKU16A.addAll(label.SKU16A.split(','));
            final set<String> setSKU16B=new Set<String>(); //CV-AD-HC-CSN-BNDSGADSPCP,CV-AD-HC-CSN-BOONDT
            setSKU16B.addAll(label.SKU16B.split(','));
            final set<String> setSKU16C=new Set<String>(); // CV-SW-HC-EMI-SGDADSHILT,CV-SW-HC-CSN-BOONDTHL
            setSKU16C.addAll(label.SKU16C.split(','));
            final set<String> setSKU16D=new Set<String>(); // CV-SW-EC-SUR-SGDADBLKSNGLP,CV-AD-HC-CSN-BOONDT
            setSKU16D.addAll(label.SKU16D.split(',')); 
            final set<string> setsku17 = new set<string>();//{'CV-AD-HC-CSN-DIAPLS'};
            setSKU17.addAll(label.SKU17.split(','));
            final set<string> setsku18 = new set<string>();//{'CV-AD-HC-CSN-CMARAD'};
            setSKU18.addAll(label.SKU18.split(','));
            final Set<String> setCountry=new Set<String>{'US','CA','MX'};
            final Set<String> setCountryInternationalRenewal = new Set<String>{'US','CA','VI'};//Added on 16th Nov on request of Ashna
            final set<string> setsku19 = new set<string>();//{'CV-AD-HC-CSN-PRMHBSIL'};//promo hub silver
            setSKU19.addAll(label.SKU19.split(','));
            final set<string> setsku20 = new set<string>();//{'CV-AD-HC-CSN-PRMHBGLD'};//promo hub gold//
            setSKU20.addAll(label.SKU20.split(','));
            final set<string> setsku22 = new set<string>();//{'CV-SW-HC-CSN-SPFEENPKG'};//CSN Enterprise License (Feature Bundle)
            setSKU22.addAll(label.SKU22.split(','));
            final set<string> setsku23 = new set<string>();//{'CV-SW-HC-CSN-SPFEPRPKG'};//CSN Professional License (Feature Bundle)
            setSKU23.addAll(label.SKU23.split(','));
            final set<string> setsku24 = new set<string>();//{'CV-SW-HC-CSN-WHLABENT2'};//Enterprise Button
            setSKU24.addAll(label.SKU24.split(','));
            final set<string> setsku26 = new set<string>();//{'CV-SW-HC-CSN-SUPFEACRACV'};//Cross Accountvisibility
            setSKU26.addAll(label.SKU26.split(','));
            final set<string> setsku28 = new set<string>();//{'CV-SW-HC-CSN-SUPFEAESCREP','CV-SW-HC-CSN-SUPFEARTR'};//Escalation/Routing Rules
            setSKU28.addAll(label.SKU28.split(','));
            final set<string> setsku29 = new set<string>();//{'CV-SW-HC-CSN-SW'};//Social Wall
            setSKU29.addAll(label.SKU29.split(','));
            final set<string> setsku30 = new set<string>();//{'CV-AD-HC-CSN-VIDRET30','CV-AD-HC-CSN-VIDMAR','CV-AD-HC-CSN-VIDRET15'};//Video Marketing
            setSKU30.addAll(label.SKU30.split(','));
            final set<String> setsku30B=new Set<String>();
            setsku30B.addAll(Label.SKU30B.split(','));
            final set<string> setsku31 = new set<string>();//{'CV-SW-HC-CSN-RFPRCS'};//Business Intelligence (BI) Compset Dashboard
            setSKU31.addAll(label.SKU31.split(','));
            final set<string> setsku32 = new set<string>();//{'CV-SW-HC-CSN-CSNCHNFIL'};//Chain Filter
            setSKU32.addAll(label.SKU32.split(','));
            final set<string> setsku33 = new set<string>();//{'CV-AD-HC-CSN-GGLDISADS'};//Google Display Ad
            setSKU33.addAll(label.SKU33.split(','));
            final set<string> setsku34 = new set<string>();//{'CV-SW-HC-APF-SLCTSRVCSCR','CV-SW-HC-APF-LDSCFTSC'}; //Cvent Lead Scoring
            setsku34.addAll(label.sku34.split(','));
            final set<string> setsku36 = new set<string>();//{'CV-SW-HC-CSN-RFPSCORELT'};//Cvent Lead Scoring
            setsku36.addAll(label.sku36.split(','));
			final set<string> setsku37 = new set<string>();//{'CV-SW-HC-COT-CSNLVABVPRPT','CV-SW-HC-COT-CSNLVEADDUSR','CV-SW-HC-COT-MLUPRPTUSRACS'};
            setsku37.addAll(label.sku37.split(','));
            date ContractImplementDate=instBookingClsf.Opportunity__r.Contract_Implemented_Date__c;
            string AssignTo=UserInfo.getUserID();
            Id OppAccountID =instBookingClsf.Opportunity__r.AccountId;
        
            //1st condition

            if(instBookingClsf.Product_Family__c=='HC Core Products - Bundles & Promo Hub' && (instBookingClsf.UpSell_Total__c>0 
            || instBookingClsf.New_Logo_Total__c>0 || instBookingClsf.Cross_Sell_Total__c>0)
            && mapOpptyHasBundle.containsKey(instBookingClsf.opportunity__c) && mapOpptyHasBundle.get(instBookingClsf.opportunity__c)){

                ContractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                string subject='New Bundle Client (Start Date -'+instBookingClsf.opportunity__r.ContractStartDate__c+') - Create Bundle Card and Send Tech Specs';
                //AssignTo=Userinfo.getUserID();
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '1 Condition';

                listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                     subject,ContractImplementDate,'High',AssignTo,description));

            }
        
            // 2nd condition
            if(instBookingClsf.Product_Family__c=='HC Core Products - Bundles & Promo Hub' && instBookingClsf.Renewal_Value_Total__c>0 && mapOpptyHasBundle.containsKey(instBookingClsf.opportunity__c) && mapOpptyHasBundle.get(instBookingClsf.opportunity__c)){
                
                ContractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                string subject='Upsell/Renewal Bundle Client (Start Date -'+instBookingClsf.opportunity__r.ContractStartDate__c+') - Create Bundle Card and Collect or Reuse Creative';
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;//Userinfo.getUserID();
               
                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '2 Condition';
                listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                         subject,ContractImplementDate,'High',AssignTo,description));
                
            }
            // 3rd condition

            if(instBookingClsf.Product_Family__c=='HC Core Products - Diamonds' && instBookingClsf.Opportunity__r.Opportunity_Type__c != 'Renewal' && (instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0) && checkSKUContains(setOppSKU,setSKU3) && setCountry.contains(instBookingClsf.Opportunity__r.Account.Billingcountry)){
                
                
                ContractImplementDate=ContractImplementDate!=null?ContractImplementDate+30:ContractImplementDate;
                string subject='1 Diamond Contract Signed – Reach Out';
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;

                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '3 Condition';
                listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                subject,ContractImplementDate,'High',AssignTo,description));
                     
                 

            }// 4th condition (3 and 4 sKU  same)
            else if(instBookingClsf.Product_Family__c=='HC Core Products - Diamonds' && instBookingClsf.Opportunity__r.Opportunity_Type__c != 'Renewal' && (instBookingClsf.New_Logo_Total__c>0 || instBookingClsf.Cross_Sell_Total__c>0) && !setCountry.contains(instBookingClsf.Opportunity__r.Account.Billingcountry) && checkSKUContains(setOppSKU,setSKU3)){
                   
                   
                    ID ownerIdCSNplanner=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                    
                    string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '4 Condition';
                    listOnboardInsertCon1HcPlannerCS.add(onboardingCreate(OppAccountID,'Open',ownerIdCSNplanner,'CSN-Supplier',description));
                
            }   
            // 5th condition
            //if((instBookingClsf.Product_Family__c=='HC Core Products - Diamonds' && (instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0)) || (instBookingClsf.Product_Family__c=='HC Core Products - Diamonds' && instBookingClsf.UpSell_Total__c>=0 && checkSKUContains(setOppSKU,setSKU) )){
            if(instBookingClsf.Product_Family__c=='HC Core Products - Diamonds' && (instBookingClsf.New_Logo_Total__c>0 || instBookingClsf.Cross_Sell_Total__c>0 || instBookingClsf.UpSell_Total__c>0) && checkSKUContains(setOppSKU,setSKU5) && instBookingClsf.Opportunity__r.Opportunity_Type__c!='Renewal'){    //Country Condition Removed By Mohsin On Ashna Request. Date - 06Feb2019
                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '5 Condition';
                ID ownerIdCSNplanner=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                listOnboardInsertCon1HcPlannerCS.add(onboardingCreate(OppAccountID,'Open',ownerIdCSNplanner,'CSN-Supplier',description));
            }
            // 6th
            System.debug('setOppSKU*****'+setOppSKU);
            System.debug('setSKU5*********'+setSKU6);
            System.debug('check Here*****'+checkSKUContains(setOppSKU,setSKU5));
            //if((instBookingClsf.Product_Family__c=='HC Core Products - Others' && (instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0)) || (instBookingClsf.Product_Family__c=='HC Core Products - Others' && instBookingClsf.UpSell_Total__c>=0 && checkSKUContains(setOppSKU,setSKU5))){
            if(instBookingClsf.Product_Family__c=='HC Core Products - Others' && instBookingClsf.Opportunity__r.Opportunity_Type__c != 'Renewal' && (instBookingClsf.New_Logo_Total__c>0 || instBookingClsf.Cross_Sell_Total__c>0 || instBookingClsf.UpSell_Total__c>0) && checkSKUContains(setOppSKU,setSKU6)){
                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '6 Condition';
                ID ownerIdCSNplanner=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                listOnboardInsertCon1HcPlannerCS.add(onboardingCreate(OppAccountID,'Open',ownerIdCSNplanner,'EMI',description));

            }        
            // 7th .. Commented on request of Kevin.... as Hannah is not a active user now.....
            /*if((instBookingClsf.Product_Family__c=='HC Core Products - Others' && (instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.Renewal_Value_Total__c>=0) ) || (instBookingClsf.Product_Family__c=='HC Core Products - Others' && instBookingClsf.UpSell_Total__c>=0 && checkSKUContains(setOppSKU,setSKU5))){

                string subject='Write and Implement Elite Overview';
                Date duedate=system.today()+7;
                //AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Userinfo.getUserID();
                AssignTo=system.label.Hanah_Prince; // change by label later -Hannah Prince ID

                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '7 Condition';
                
                listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                subject,duedate,'High',AssignTo,description));
                   
                

            }*/
            // 8th
            //if((instBookingClsf.Product_Family__c=='HC Core Products - Others' && (instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.Renewal_Value_Total__c>=0) ) || (instBookingClsf.Product_Family__c=='HC Core Products - Others' && instBookingClsf.UpSell_Total__c>=0 && checkSKUContains(setOppSKU,setSKU8))){
            if(instBookingClsf.Product_Family__c=='HC Core Products - Others' && (instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.Renewal_Value_Total__c>=0 || instBookingClsf.UpSell_Total__c>=0) && checkSKUContains(setOppSKU,setSKU8)){

                
                ContractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                string subject='NBB/Renewal PMPP';
                //AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Userinfo.getUserID();
                AssignTo=system.label.Pete_Murray; // change by label later -Pete murray ID
                
                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '8 Condition';
                  
                listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                subject,ContractImplementDate,'High',AssignTo,description));
                  
                

            }   

            //9th
            if(instBookingClsf.Product_Family__c=='HC Core Products - Diamonds' && instBookingClsf.Renewal_Value_Total__c>0  && checkSKUContains(setOppSKU,setSKU9) && !setCountryInternationalRenewal.contains(instBookingClsf.Opportunity__r.Account.Billingcountry)  && instBookingClsf.Opportunity__r.Opportunity_Type__c =='Renewal'){    //Country and Opportunity Type Condition added on Ashna Request. Date - 06Feb2019
                
                string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Userinfo.getUserID();
                string subject='Renewal INTL Diamond Client - Check in with property';
                
                                          
                
                ContractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                //AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Userinfo.getUserID();
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                
                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '9 Condition';
                    
                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 
                    
                    /*listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                 subject,ContractImplementDate,'Medium',AssignTo));*/
                                             
                
            }   // end 

            // 10th
            if(instBookingClsf.Product_Family__c=='HC Core Products - Others' && instBookingClsf.Renewal_Value_Total__c>0  && checkSKUContains(setOppSKU,setSKU10)){
                
                string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Userinfo.getUserID();
                string subject='Renewal EMI Marketing Package - Reach out to review purchases';
                
                                          
                
                ContractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                //AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Userinfo.getUserID();
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                
                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '10 Condition';
                    
                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 
                    
                    /*listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                 subject,ContractImplementDate,'Medium',AssignTo));*/
                                            
                
            }   // end  

            //11  --Sales price 0 condition is pending
            if(instBookingClsf.Product_Family__c=='Software & Integrations' && (instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.Renewal_Value_Total__c>=0)  && checkSKUContains(setOppSKU,setSKU11)){
                
                string ownerIdCSNSupplier;
                string subject;
                string description;
                //Commented CS11 
                if(SKUNameVsNetToal.get('CV-SW-HC-CSN-WHTLAPRO')==0){
                ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                subject='SRFP PRO Button Comped – Reach Out';
                
                                          
                
                ContractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                //AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Userinfo.getUserID();
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                
                description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '11 Condition';    
                    
                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 
                }
                if(SKUNameVsNetToal.get('CV-SW-HC-CSN-WHTLAPRO')>0){
                //12 th condition
                 ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                 subject='SRFP PRO Button PAID – Reach Out';
                
                                          
                
                ContractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                //AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Userinfo.getUserID();
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                
                description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '12 Condition';   
                    
                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 
                }   
                    /*listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                 subject,ContractImplementDate,'High',AssignTo));*/
                                             
                
            }   // end

                //13th new sku11 set can be reused here (same)
             if(instBookingClsf.Product_Family__c=='Software & Integrations' && instBookingClsf.Opportunity__r.Opportunity_Type__c=='Renewal' && (instBookingClsf.Renewal_Value_Total__c>=0) && checkSKUContains(setOppSKU,setSKU11)){
                
                string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                string subject='SRFP PRO Button Renewal - Is button still live?';

                ContractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                //AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Userinfo.getUserID();
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
              
                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '13 Condition';      
                  
                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 
                    
                   // listTaskInsert.add(taskCreat(OppAccountID,'Not Started',subject,ContractImplementDate,'High',AssignTo));
                                 
                                           
                
             }   // 13th condition end

                        //14th new sku12-->setSKU12 defined above //custom Proposal basic
             if(instBookingClsf.Product_Family__c=='Software & Integrations' && (instBookingClsf.Renewal_Value_Total__c>=0||instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.UpSell_Total__c>=0) && checkSKUContains(setOppSKU,setsku12)){
                
                string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                string subject='Custom Proposal Basic (Start Date – '+instBookingClsf.Opportunity__r.ContractStartDate__c+') - Reach out for Training';

                ContractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                //AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Userinfo.getUserID();
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                
                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '14 Condition';         
                    
                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 
                    
                   // listTaskInsert.add(taskCreat(OppAccountID,'Not Started',subject,ContractImplementDate,'High',AssignTo));
                                 
                                           
                
            }   // 14th condition end

                                //15th new sku13-->setSKU13 defined above //custom Proposal advance
            if(instBookingClsf.Product_Family__c=='Software & Integrations' && (instBookingClsf.Renewal_Value_Total__c>=0||instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.UpSell_Total__c>=0) && checkSKUContains(setOppSKU,setsku13)){
                
                string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                string subject='Custom Proposal Advance (Start Date – '+instBookingClsf.Opportunity__r.ContractStartDate__c+') - Reach out for Implementation';

                ContractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                //AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Userinfo.getUserID();
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
               
               string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '15 Condition';  
               
                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                                          subject,ownerIdCSNSupplier,'',description)); 
                    
                   /* listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                 subject,ContractImplementDate,'High',AssignTo));*/
                                             
                
            }   // 15th condition end
            
            // 16th Condition
            
            if(instBookingClsf.Product_Family__c=='HC Core Products - Suggested, Diamond Plus, Comp Market' && 
            (instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.UpSell_Total__c>=0 || instBookingClsf.Renewal_Value_Total__c>=0)
            && checkBothSKU(setOppSKU,setSkU16A,setSkU16B,setSkU16C,setSKU16D)){
                
                 string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                 string subject='Suggested Ad Need Dates Booster Sold';

                contractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
             
                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '16 Condition';  
                    
                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                                          subject,ownerIdCSNSupplier,'',description)); 
                    
                /*listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                 subject,ContractImplementDate,'High',AssignTo));*/
                                           
                
                
            }// end of 16th

            //17th new sku-->setSKU17 defined above //HC Core Products - Suggested, Diamond Plus, Comp Market

            if(instBookingClsf.Product_Family__c=='HC Core Products - Suggested, Diamond Plus, Comp Market' && 
            (instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.UpSell_Total__c>=0)
            && checkSKUContains(setOppSKU,setsku17)){
                
            string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
            string subject='Diamond Plus Ads (Start Date – '+instBookingClsf.Opportunity__r.ContractStartDate__c+') -  Reach out and share ads';

            contractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
            AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
             
                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '17 Condition';  
                                
                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                                          subject,ownerIdCSNSupplier,'',description)); 
                    
                /*listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                 subject,ContractImplementDate,'High',AssignTo));*/
                }                             
                
               // 17th condition end

              //18th condition new sku -->sku18 defined

            if(instBookingClsf.Product_Family__c=='HC Core Products - Suggested, Diamond Plus, Comp Market' && 
            (instBookingClsf.Renewal_Value_Total__c>=0||instBookingClsf.New_Logo_Total__c>=0 || 
            instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.UpSell_Total__c>=0)
            && checkSKUContains(setOppSKU,setsku18)){

                string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                string subject='Competitive Market Ad (Start Date – '+instBookingClsf.Opportunity__r.ContractStartDate__c+') - Reach out and share ad';

                contractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;

                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '18 Condition';  
                
                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 

               /* listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                 subject,ContractImplementDate,'High',AssignTo));*/
                                             
                
            }   // 18th condition end

               //19th condition new sku -->sku19 defined
            if(instBookingClsf.Product_Family__c=='HC Core Products - Bundles & Promo Hub' && 
            (instBookingClsf.New_Logo_Total__c>=0 ||instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.UpSell_Total__c>=0)
            && checkSKUContains(setOppSKU,setsku19)){
                
                string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                string subject='Promo Hub (Start Date – '+instBookingClsf.Opportunity__r.ContractStartDate__c+') Silver';

                contractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;

                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '19 Condition';  

                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 

                /*listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                subject,ContractImplementDate,'High',AssignTo));*/

                
            }   // 19th condition end
               //20th condition new sku -->sku20 defined

            if(instBookingClsf.Product_Family__c=='HC Core Products - Bundles & Promo Hub' && 
            (instBookingClsf.New_Logo_Total__c>=0 ||instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.UpSell_Total__c>=0)
            && checkSKUContains(setOppSKU,setsku20)){
                
                string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                string subject='Promo Hub (Start Date – '+instBookingClsf.Opportunity__r.ContractStartDate__c+') Gold';

                contractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;

                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '20 Condition';  

                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 

                /*listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                subject,ContractImplementDate,'High',AssignTo));*/
                                          
                
            }   // 20th condition end
               // skipping 21st ,22nd condition new sku -->sku22 defined

            if(instBookingClsf.Product_Family__c=='Software & Integrations' && 
            (instBookingClsf.New_Logo_Total__c>=0 ||instBookingClsf.Cross_Sell_Total__c>=0 ) && checkSKUContains(setOppSKU,setsku22)){       
            string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
            string subject='CSN Enterprise License (Feature Bundles) - Reach out for Implementation';

            contractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
            AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;

                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '21 OR 22 Condition';  
                    
                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 

                /* listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                subject,ContractImplementDate,'High',AssignTo));*/
                                             
                
            }   // 22nd condition end

               // 23rd condition new sku -->sku23 defined

            if(instBookingClsf.Product_Family__c=='Software & Integrations' && 
            (instBookingClsf.New_Logo_Total__c>=0 ||instBookingClsf.Cross_Sell_Total__c>=0 )
            && checkSKUContains(setOppSKU,setsku23)){
                
                string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                string subject='CSN Professional License  (Feature Bundles)- Reach out for Implementation';

                contractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;

                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '23 Condition'; 
                
                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 

                /*listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                subject,ContractImplementDate,'High',AssignTo));*/
                                           
                
            }   // 23rd condition end
               // 24th condition new sku -->sku24 defined
            if(instBookingClsf.Product_Family__c=='Software & Integrations' && 
            (instBookingClsf.New_Logo_Total__c>=0 ||instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.UpSell_Total__c>=0)
            && checkSKUContains(setOppSKU,setsku24)){
                
                string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                string subject='SRFP Enterprise Button - Reach Out to Sales';

                contractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;

                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '24 Condition'; 

                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 

                /*listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                subject,ContractImplementDate,'High',AssignTo));*/
                                             
                
            }   // 24th condition end
            //25th condition
            if(instBookingClsf.Product_Family__c=='Software & Integrations' && instBookingClsf.Renewal_Value_Total__c>=0 && instBookingClsf.Opportunity__r.Stagename.contains('Closed Won')&& checkSKUContains(setOppSKU,setsku24) && instBookingClsf.Renewal_Value_Total__c>0){//instBookingClsf.Product_Family__c=='Software & Integrations' &&             (instBookingClsf.Renewal_Value_Total__c>=0)&& 
                
                string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                string subject='Renewal SRFP Enterprise Button – Everything going smooth?';

                contractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;

                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '25 Condition'; 
                
                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 

                /* listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                subject,ContractImplementDate,'High',AssignTo));*/
                                             
                
            }   // 25th condition end
               // 26th condition new sku -->sku26 defined
               
               /*Important -Please check Task 'assigned to' as per business rule*/
            if(instBookingClsf.Product_Family__c=='Software & Integrations' && 
            (instBookingClsf.Renewal_Value_Total__c>=0||instBookingClsf.New_Logo_Total__c>=0 ||
            instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.UpSell_Total__c>=0)
            && checkSKUContains(setOppSKU,setsku26)){
                
                string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                string subject='CAV Purchased - Reach out for Next Steps';

                contractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;

                
                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '26 Condition'; 

                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 

                /* listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                subject,ContractImplementDate,'High',AssignTo));*/
                                            
                
            }   // 26th condition end
              //27th condition 
              /*Contract number?*///(instBookingClsf.Opportunity__r.recordtypeId != oppRecType)                &&
            if((instBookingClsf.Opportunity__r.account.Venue_Type__c=='Above- Property Account')
                &&((!string.isBlank(instBookingClsf.Opportunity__r.MSA_Code__c))||
                (!string.isBlank(instBookingClsf.Opportunity__r.Other_MSA_Code__c)))
                && (instBookingClsf.Opportunity__r.Product__c =='CSN' || instBookingClsf.Opportunity__r.Product__c =='EMI')
            ){  
                    if (i==0){
                        AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                        contractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                        string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                        Id ownerIdAcc = instBookingClsf.Opportunity__r.Account.OwnerId;
                        string subject='MSA purchased ('+instBookingClsf.Opportunity__r.Other_MSA_Code__c+')('+instBookingClsf.Opportunity__r.Contract_Number_New__c+')(Start Date - '+instBookingClsf.Opportunity__r.ContractStartDate__c+') - Set Kickoff Call and Reach out to Property CS Rep';

                        string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '27 Condition'; 
                        
                        listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                        subject,ownerIdCSNSupplier,'',description)); 

                        //listTaskInsert.add(taskCreat(OppAccountID,'Not Started',subject,ContractImplementDate,'High',AssignTo,description));
                        i++;        
                    }

            }//27th condition Ends
               // 28th condition new sku -->sku28 defined
            /*Important -Please check Task 'assigned to' as per business rule*/
            if(instBookingClsf.Product_Family__c=='Software & Integrations' && 
            (instBookingClsf.Renewal_Value_Total__c>=0||
            instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.UpSell_Total__c>=0)
            && checkSKUContains(setOppSKU,setsku28)){
                
                string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                string subject='Escalation/Routing Rules (Start Date - '+instBookingClsf.Opportunity__r.ContractStartDate__c+') - Reach out for Implementation';

                contractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;

                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '28 Condition';

                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 

                /*listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                subject,ContractImplementDate,'High',AssignTo));*/

                
            }   // 28th condition end
              // 29th condition new sku -->sku29 defined

            if(instBookingClsf.Product_Family__c=='Software & Integrations' && 
            (instBookingClsf.Renewal_Value_Total__c>=0||
            instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.UpSell_Total__c>=0)
            && checkSKUContains(setOppSKU,setsku29)){
                
                string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                string subject='Social Wall - Reach out for Implementation';

                contractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;

                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '29 Condition';
                
                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 

                /* listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                subject,ContractImplementDate,'High',AssignTo));*/
                                            
                
            }   // 29th condition end
               // 30th condition new sku -->sku30 defined


            /*if(instBookingClsf.Product_Family__c=='HC Core Products - Others' && 
            (instBookingClsf.Renewal_Value_Total__c>=0||instBookingClsf.New_Logo_Total__c>=0 ||
            instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.UpSell_Total__c>=0)
            && checkSKUContains(setOppSKU,setsku30)){
                
            string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Userinfo.getUserID();
            string subject='Video Marketing - Reach out for Content ';

            contractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
            AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Userinfo.getUserID();
             
                    
                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                                          subject,ownerIdCSNSupplier,'')); 
             
                                             
                
            }*/   // 30th condition end

            // 30th condition  A Part   
            if(instBookingClsf.Product_Family__c=='HC Core Products - Others' && 
            (instBookingClsf.Renewal_Value_Total__c>=0||instBookingClsf.New_Logo_Total__c>=0 ||
            instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.UpSell_Total__c>=0)
            && checkSKUContains(setOppSKU,setsku30)){

                string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                string subject='Video ADs Sold - Reach out for Content';

                contractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;

                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '30a Condition';
                
                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 
            } // end    


            // 30th condition  B Part   
            if(instBookingClsf.Product_Family__c=='HC Core Products - Others' && 
            (instBookingClsf.Renewal_Value_Total__c>=0||instBookingClsf.New_Logo_Total__c>=0 ||
            instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.UpSell_Total__c>=0)
            && checkSKUContains(setOppSKU,setsku30B)){

                string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                string subject='Video Retargeting Sold - Reach out for Content ';

                contractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;

                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '30b Condition';
                
                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 
            } // end        
            // 31st condition new sku -->sku31 defined
            if(instBookingClsf.Product_Family__c=='HC Core Products - Others' && 
            (instBookingClsf.New_Logo_Total__c>=0 ||
            instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.UpSell_Total__c>=0)
            && checkSKUContains(setOppSKU,setsku31)){
                
                string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                string subject='Set BI Dashboard Call';

                contractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;

                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '31 Condition';

                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 

                /*listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                subject,ContractImplementDate,'High',AssignTo));*/
                                             
                
            }   // 31st condition end
               // 32th condition new sku -->sku32 defined
              if(instBookingClsf.Product_Family__c=='Software & Integrations' && 
            (instBookingClsf.New_Logo_Total__c>=0 ||instBookingClsf.Cross_Sell_Total__c>=0 )&& checkSKUContains(setOppSKU,setsku32))
            {
                string subject='New Chain Filter Purchased (Start date -'+instBookingClsf.Opportunity__r.ContractStartDate__c+')';
                contractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;

                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '32 Condition';
                
                listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                subject,ContractImplementDate,'High',AssignTo,description));
                                            
                
            }   // 32th condition end

            // 33rd condition new sku -->sku33 defined
            if(instBookingClsf.Product_Family__c=='HC Core Products - Others' && 
            (instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Renewal_Value_Total__c>=0||
            instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.UpSell_Total__c>=0)
            && checkSKUContains(setOppSKU,setsku33)){
                
                string ownerIdCSNSupplier=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;
                string subject='Google Display Ad - Reach out for Content';

                contractImplementDate=ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
                AssignTo=mapAccTeam.containsKey('CS - HCloud - Implement/Onboard')?mapAccTeam.get('CS - HCloud - Implement/Onboard'):Label.Becky;

                string description=instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '33 Condition';
                
                listCaseInsert.add(caseCreate('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject,ownerIdCSNSupplier,'',description)); 

                /*listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                subject,ContractImplementDate,'High',AssignTo));*/
                                            
                
            }   // 33rd condition end
            
            // 34th condition new sku -->sku34 defined
            if(instBookingClsf.Product_Family__c=='Analytics & RFP Performance' && 
            (instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.UpSell_Total__c>=0)
            && checkSKUContains(setOppSKU,setsku34)){
                
                String owner1 = Label.RFPBuilderInbox;
                String owner2 = Label.Lead_Scoring_Solutions_Specialists;
                String subject1 = 'NBB Lead Scoring - Create Username and User Role';
                String subject2 = 'Kick Off Call & Initial Implementation';

                string description = instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '34 Condition';
                
                listCaseInsert.add(caseCreateNew('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject1,owner1,description,'CSN_Builder')); 
                
                listCaseInsert.add(caseCreateNew('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'Lead Scoring',
                subject2,owner2,description,'Client_Management_Global')); 
            }   // 34th condition end

            
            // 35th condition new sku -->sku36 defined
            if(instBookingClsf.Product_Family__c=='Analytics & RFP Performance' && 
            (instBookingClsf.New_Logo_Total__c>=0 ||
            instBookingClsf.Cross_Sell_Total__c>=0 || instBookingClsf.UpSell_Total__c>=0)
            && checkSKUContains(setOppSKU,setsku36)){
                
                String owner1 = Label.RFPBuilderInbox;
                String owner2 = Label.Lead_Scoring_Solutions_Specialists;
                String subject1 = 'NBB Lead Scoring - Create Username and User Role';
                String subject2 = 'RFP Score Implementation & Training';

                string description = instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '35 Condition';
                
                listCaseInsert.add(caseCreateNew('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN – Supplier',
                subject1,owner1,description,'CSN_Builder')); 
                
                listCaseInsert.add(caseCreateNew('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'Lead Scoring',
                subject2,owner2,description,'Client_Management_Global')); 
            }   // 35th condition end
			
			// 36th condition new sku -->sku37 defined
            if(instBookingClsf.Product_Family__c=='Software & Integrations' && 
            checkSKUContains(setOppSKU,setsku37)){
                
                String owner = Label.RFPBuilderInbox;
                String subject = mapOpportunity.get(instBookingClsf.Opportunity__c).Account.Name+' - RFP Visibility';
                string description = instBookingClsf.Opportunity__c+'-HC-Supplier CS-'+ '36 Condition';
                
                Case caseInstance = caseCreateNew('Feature Implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN - Supplier',
                subject,owner,description,'CSN_Builder'); 
				caseInstance.ContactId = instBookingClsf.Opportunity__r.Ship_To_Contact__c;
				listCaseInsert.add(caseInstance);
            }   // 36th condition end
    }   //  end 
    
    
     /*
      EC-AM
    */
    private static void ECAM_Task(booking_classification__c instBookingClsf,Map<string,ID> mapAccTeam, Set<String> setOppSKU,Id oppRecType)
    {
       // List<Task> listTaskInsert=new List<Task>();
        date ContractImplementDate=instBookingClsf.Opportunity__r.Contract_Implemented_Date__c;
        string AssignTo=UserInfo.getUserID();
        Id OppAccountID =instBookingClsf.Opportunity__r.AccountId;
        
        final set<string> setSKU1 = new set<string>();//{'CV-SW-EC-EVT-ENTLICCORE','CV-SW-EC-EVT-PRFLIC-CORE',
                        //'CV-SW-EC-EVT-EXPLIC-CORE','CV-SW-EC-EVT-EXPLIC-ENT',
                        //'CV-SW-EC-EVT-PRFLIC-ENT','CV-SW-EC-EVT-ENTLIC-ENT',
                        //'CV-SW-EC-EVT-ENTSWWDBUN','CV-SW-EC-EVT-ENTSWWDBUNCRE',
                       // 'CV-SW-EC-EVT-CSNPLALICENT','CV-SW-EC-EVT-CSNPLALICENTENT',
                        //'CV-SW-EC-EVT-CSNPSTRBUNENT','CV-SW-EC-EVT-CSNPETBUN',
                       // 'CV-SW-EC-EVT-CSNPSTRBUN','CV-SW-EC-EVT-CSNPALAC',
                        //'CV-SW-EC-EVT-CSNPETBUNENT'};
        setSKU1.addAll(label.SKU1.split(','));
        /*
        **** Edit By: Mohsin Siddiqui
        **** Date: 17 sept 2019
        **** Changes: Removed 4 SKUs from setSKU2 on request of Kaitlin (JIRA Ticket - TICCM-218).
        **** Original Content: {'CV-SW-EC-EVT-ENTSWWDBUNCRE','CV-SW-EC-EVT-ENTLICCORE',
                        //'CV-SW-EC-EVT-EXPLIC-CORE','CV-SW-EC-EVT-PRFLIC-CORE',
                        //'CV-SW-EC-EVT-CSNPALAC','CV-SW-EC-EVT-CSNPETBUN',
                        //'CV-SW-EC-EVT-CSNPLALICENT','CV-SW-EC-EVT-CSNPSTRBUN'}
        */   
        final set<string> setSKU2 = new set<string>();//{'CV-SW-EC-EVT-ENTSWWDBUNCRE','CV-SW-EC-EVT-ENTLICCORE',
                        //'CV-SW-EC-EVT-EXPLIC-CORE','CV-SW-EC-EVT-PRFLIC-CORE'};
        setSKU2.addAll(label.SKU2.split(','));
        final set<string> setSKU3 = new set<string>();//{'CV-SW-EC-SUR-PSGREVRECREP','CV-SW-EC-SUR-INQAPPSF',
                        //'CV-SW-EC-SUR-INQSMBDL','CV-SW-EC-SUR-QSTNRLIC'};
        setSKU3.addAll(label.SKU3.split(','));      
        /*
        **** Edit By: Mohsin Siddiqui
        **** Date: 17 sept 2019
        **** Changes: Removed 4 SKUs from setSKU5 on request of Kaitlin (JIRA Ticket - TICCM-218).
        **** Original Content: {'CV-SW-EC-EVT-ENTSWWDBUNCRE','CV-SW-EC-EVT-ENTLICCORE',
                                //'CV-SW-EC-EVT-EXPLIC-CORE','CV-SW-EC-EVT-PRFLIC-CORE', 
                                //'CV-SW-EC-EVT-CSNPALAC','CV-SW-EC-EVT-CSNPETBUN',
                            // 'CV-SW-EC-EVT-CSNPLALICENT','CV-SW-EC-EVT-CSNPSTRBUN'}
        */                         
        final set<string> setSKU5 = new set<string>();//{ 'CV-SW-EC-EVT-CSNPALAC','CV-SW-EC-EVT-CSNPETBUN',
                       // 'CV-SW-EC-EVT-CSNPLALICENT','CV-SW-EC-EVT-CSNPSTRBUN'};  
        setSKU5.addAll(label.ECAM_TaskSku5.split(','));
        final set<string> setSKU6and7 = new set<string>();//{'CV-SW-EC-EVT-CSNPLALICENT','CV-SW-EC-EVT-CSNPLALICENTENT',
                        //'CV-SW-EC-EVT-CSPADCLPOR','CV-SW-EC-EVT-CSPCLPRTENT10', 
                        //'CV-SW-EC-EVT-CSPCLPRTPR1','CV-SW-EC-EVT-CSNPSTRBUNENT',
                        //'CV-SW-EC-EVT-CSNPETBUN','CV-SW-EC-EVT-CSNPSTRBUN',
                        //'CV-SW-EC-EVT-CSNPALAC','CV-SW-EC-EVT-CSNPETBUNENT'};
        setSKU6and7.addAll(label.SKU6and7.split(','));                         
        final set<string> setSKU8 = new set<string>();//{'CV-SW-EC-CC-CCMBAP50-CCMBAP50','CV-SW-EC-CC-CCMBAP51-CCMBAP51',
                        //'CV-SW-EC-CC-CCMBAP501-CCMBAP501','CV-SW-EC-CC-CCMBAP5001-CCMBAP5001 ', 
                        //'CV-SW-EC-CC-CCMBAP3001-CCMBAP3001','CV-SW-EC-CC-CCMBAP251-CCMBAP251',
                        //'CV-SW-EC-CC-CCMBAP1501-CCMBAP1501','CV-SW-EC-CC-CCMBAP126-CCMBAP126',
                        //'CV-SW-EC-CC-CCMBAP10001-CCMBAP10001'};
        setSKU8.addAll(label.ECAM_SKU8.split(','));
    final set<string> setSKU12 = new set<string>();//{CV-SW-EC-OSS-DEDOAPSOW,CV-SW-EC-OSS-OA360(OSS),CV-PS-HC-OSS-OA360STD,CV-PS-HC-OSS-OA360T1,CV-SW-EC-OSS-OAPREMXL,CV-SW-EC-EVT-OAPREM50,CV-SW-EC-EVT-OAPREM250,CV-SW-EC-EVT-OAPREM500,CV-SW-EC-EVT-OAPREM750,CV-SW-EC-EVT-OAPREM125,CV-SW-EC-EVT-OAPREM1000,CV-SW-EC-EVT-OAPREM};
        setSKU12.addAll(label.SKU10EC.split(','));
    final set<string> setSKU14 = new set<string>();//{CV-SW-EC-SCT-SCTPLNLISC};
        setSKU14.addAll(label.SKU14EC.split(','));
    final set<string> setSKU16 = new set<string>();//{CV-SW-EC-QML-CENSE114,CV-SW-EC-QML-CENSE110,CV-SW-EC-QML-YEAR130,CV-SW-EC-QML-DAYS127,CV-SW-EC-QML-CENSE122,CV-SW-EC-QML-CENSE121,CV-SW-EC-QML-NDEES115,CV-SW-EC-QML-CENSE8,CV-SW-EC-QML-CENSE7,CV-SW-EC-QML-CENSE6,CV-SW-EC-QML-CENSE5};
        setSKU16.addAll(label.SKU16EC.split(','));
    
        //conditon 1 new sku -->setsku1                                     
        if(instBookingClsf.Product_Family__c=='Event'&& (instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0
            ||instBookingClsf.Renewal_Value_Total__c>=0)&& checkSKUContains(setOppSKU,setSKU1) &&(mapOpportunity.get(instBookingClsf.opportunity__c).SBQQ__PrimaryQuote__r.Contract_Opt_Out_Deadline__c!=null) && !setOfOpportunityForFirstCondition.contains(instBookingClsf.opportunity__c))  //Added OptOutDate condition on request of Cristina - TICCM-217
            {
                setOfOpportunityForFirstCondition.add(instBookingClsf.opportunity__c);
                 string subject='Opt out ends today - '+instBookingClsf.opportunity__r.Name;
         Date duedate = mapOpportunity.get(instBookingClsf.opportunity__c).SBQQ__PrimaryQuote__r.Contract_Opt_Out_Deadline__c; 
         
                if (mapAccTeam.containsKey('AM - Event Cloud'))
                      {
                        AssignTo =mapAccTeam.get('AM - Event Cloud');
                       }
                   /* else if(mapAccTeam.containsKey('Multi-Product'))
                        {
                            AssignTo =mapAccTeam.get('Multi-Product');
                            }
                        else if(mapAccTeam.containsKey('AM - Renewal Specialist'))
                            {
                            AssignTo =mapAccTeam.get('AM - Renewal Specialist');
                            } */  //MS: This conditions are commented on a request of Cristina
                    else{
                            AssignTo =Userinfo.getUserID();
                        }
                    
                    
                        string description=instBookingClsf.Opportunity__c+'-ECAM_Task-'+ '1 Condition';
                        listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                     subject,duedate,'High',AssignTo,description));
                       
            }//condition 1 ends
      
            //conditon 2 new sku -->setsku2                                     
        if(instBookingClsf.Product_Family__c=='Event'
            && (instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0)&& checkSKUContains(setOppSKU,setSKU2) && !setOfOpportunityForSecondCondition.contains(instBookingClsf.opportunity__c))
            {
                setOfOpportunityForSecondCondition.add(instBookingClsf.opportunity__c);
                 string subject='New client, intro and set hand-off mtg w/DS - '+instBookingClsf.opportunity__r.Name;
                 Date duedate=ContractImplementDate;
                    
                if (mapAccTeam.containsKey('AM - Event Cloud'))
                      {
                            AssignTo =mapAccTeam.get('AM - Event Cloud');
                        }
                  /*  else if(mapAccTeam.containsKey('Multi-Product'))
                        {
                            AssignTo =mapAccTeam.get('Multi-Product');
                            }
                        else if(mapAccTeam.containsKey('AM - Renewal Specialist'))
                            {
                            AssignTo =mapAccTeam.get('AM - Renewal Specialist');
                                } */   //MS: This conditions are commented on a request of Cristina
                    else{
                            AssignTo =Userinfo.getUserID();
                        }
                    
                    
                        string description=instBookingClsf.Opportunity__c+'-ECAM_Task-'+ '2 Condition';
                        listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                     subject,duedate,'High',AssignTo,description));
                      
            }//condition 2 ends
                    //conditon 3 new sku -->setsku3     /*Important -- check with business */                               
        if(instBookingClsf.Product_Family__c=='Survey'
            && (instBookingClsf.New_Logo_Total__c>0 || instBookingClsf.Cross_Sell_Total__c>0||instBookingClsf.Renewal_Value_Total__c>0)
            && checkSKUContains(setOppSKU,setSKU3) && (mapOpportunity.get(instBookingClsf.opportunity__c).SBQQ__PrimaryQuote__r.Contract_Opt_Out_Deadline__c!=null))   //Added OptOutDate checkbox condition on request of Cristina - TICCM-217
            {
                 string subject='Opt out ends today - '+instBookingClsf.opportunity__r.Name; // subject check
                 Date duedate = mapOpportunity.get(instBookingClsf.opportunity__c).SBQQ__PrimaryQuote__r.Contract_Opt_Out_Deadline__c;
                    
        AssignTo=mapAccTeam.containsKey('AM - Inquisium')?mapAccTeam.get('AM - Inquisium'):Userinfo.getUserID();
                    
                  
                        string description=instBookingClsf.Opportunity__c+'-ECAM_Task-'+ '3 Condition';
                        listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                     subject,duedate,'High',AssignTo,description));
                     
            }//condition 3 ends                                                                                           
                //conditon 4 old sku -->setsku3                                     
        if(instBookingClsf.Product_Family__c=='Survey'
            && (instBookingClsf.New_Logo_Total__c>0 || instBookingClsf.Cross_Sell_Total__c>0)&& checkSKUContains(setOppSKU,setSKU3))
            {
                 string subject='New Client Handoff Call set by DS? - '+instBookingClsf.opportunity__r.Name;
                 Date duedate=ContractImplementDate;
                  AssignTo=mapAccTeam.containsKey('AM - Inquisium')?mapAccTeam.get('AM - Inquisium'):Userinfo.getUserID();
                  
                    string description=instBookingClsf.Opportunity__c+'-ECAM_Task-'+ '4 Condition';

                    listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                    subject,duedate,'High',AssignTo,description));
                      
            }//condition 4 ends
            //conditon 5 old sku -->setsku5                                     
        if(instBookingClsf.Product_Family__c=='Event'
            && (instBookingClsf.New_Logo_Total__c>0 || instBookingClsf.Cross_Sell_Total__c>0)&& checkSKUContains(setOppSKU,setSKU5))
            {
                 string subject='New Client Intro (DS/AM to Sched. Kick-off Call) - '+instBookingClsf.opportunity__r.Name;
                 Date duedate=ContractImplementDate;
                    AssignTo=mapAccTeam.containsKey('CS - CSN Planner')?mapAccTeam.get('CS - CSN Planner'):Userinfo.getUserID();
                    
                    string description=instBookingClsf.Opportunity__c+'-ECAM_Task-'+ '5 Condition';

                        listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                     subject,duedate,'High',AssignTo,description));
                      
            }//condition 5 ends
                    //conditon 6 new sku -->setsku6and7  adding 7th condition here as well                                  
        if(instBookingClsf.Product_Family__c=='Event'
            && (instBookingClsf.New_Logo_Total__c>0 || instBookingClsf.Cross_Sell_Total__c>0)&& checkSKUContains(setOppSKU,setSKU6and7))
            {
            string subject='New Client Intro (Introduce CS rep to Client) - '+instBookingClsf.opportunity__r.Name;
                 Date duedate=ContractImplementDate!=null?ContractImplementDate+5:ContractImplementDate;
                string subject2 ='New Sourcing Client: First Quarter- Check Usage - '+instBookingClsf.opportunity__r.Name;
                date duedate2 =instBookingClsf.Opportunity__r.closedate;
                duedate2=duedate2!=null?duedate2+90:duedate2;
               AssignTo=mapAccTeam.containsKey('CS - CSN Planner')?mapAccTeam.get('CS - CSN Planner'):Userinfo.getUserID();
               Id AssignTosourcerep = mapAccTeam.containsKey('AM - Sourcing')?mapAccTeam.get('AM - Sourcing'):Userinfo.getUserID();  //MS: Added new assign to on request of Cristina
         //Id AssignTosourcerep = mapSourceRep.containsKey(instBookingClsf.Opportunity__r.account.PA_Rep__c)?mapSourceRep.get(instBookingClsf.Opportunity__r.account.PA_Rep__c):Userinfo.getUserID();  // MS: commented this line on request of Cristina. It will be assigned to the person having AM - Sourcing role in account team member. //need to check for Id here  
                   
                        string description=instBookingClsf.Opportunity__c+'-ECAM_Task-'+ '6 OR 7 Condition';

                        listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                     subject,duedate,'High',AssignTo,description));
                    
                
                        
                        listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                     subject2,duedate2,'High',AssignTosourcerep,description));
                     
            }//condition 6 and 7 ends
                //conditon 8 and 9 new sku -->setsku8                                   
        if(instBookingClsf.Product_Family__c=='CrowdCompass'
            && (instBookingClsf.New_Logo_Total__c>0 || instBookingClsf.Cross_Sell_Total__c>0 ||instBookingClsf.Renewal_Value_Total__c>0)
            && checkSKUContains(setOppSKU,setSKU8))
            {
            string subject='New CC Client Check-In - '+instBookingClsf.opportunity__r.Name;
                string subject2='Pre-Event check In - '+instBookingClsf.opportunity__r.Name;
                 Date duedate=ContractImplementDate;
                    duedate =duedate!=null?duedate+30:duedate;
                //date duedate =    //need to pass duedate 2 of the mobile event mobile level <1st Event Start Date> (Mobile Apps) - 14 Days
        if (mapAccTeam.containsKey('AM - Event Cloud'))
                      {
                            AssignTo =mapAccTeam.get('AM - Event Cloud');
                        }
                    /*else if(mapAccTeam.containsKey('AM - CrowdCompass'))
                        {
                            AssignTo =mapAccTeam.get('AM - CrowdCompass');
                            } */ //MS: commented this condition on a request of cristina
                            else{
                            AssignTo=Userinfo.getUserID();
                            }
                    
                    
                        string description=instBookingClsf.Opportunity__c+'-ECAM_Task-'+ '8 OR 9 Condition';

                        listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                     subject,duedate,'High',AssignTo,description));
                    
                
                        
                        listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                     subject2,duedate,'High',AssignTo,description)); //check duedate2 here
                    
            }//condition 8 and 9 ends
                
                //condition 10 old sku -->sku8
        if(instBookingClsf.Product_Family__c=='CrowdCompass'
            && (instBookingClsf.New_Logo_Total__c>0 || instBookingClsf.Cross_Sell_Total__c>0 ||instBookingClsf.Renewal_Value_Total__c>0)
            && checkSKUContains(setOppSKU,setSKU8) && (mapOpportunity.get(instBookingClsf.opportunity__c).SBQQ__PrimaryQuote__r.Contract_Opt_Out_Deadline__c!=null || Test.isRunningTest()) && !setOfOpportunityForFirstCondition.contains(instBookingClsf.opportunity__c))   //Added Opt Out date condition on request of Cristina - TICCM-217
            {
                setOfOpportunityForFirstCondition.add(instBookingClsf.opportunity__c);
            string subject='Opt out ends today - '+instBookingClsf.opportunity__r.Name;    //Changed subject line on final request of Kaitlin - TICCM - 218 -----Original Subject - Opt Out – CC

                 Date duedate = mapOpportunity.get(instBookingClsf.opportunity__c).SBQQ__PrimaryQuote__r.Contract_Opt_Out_Deadline__c;
        if (mapAccTeam.containsKey('AM - Event Cloud'))
                      {
                            AssignTo =mapAccTeam.get('AM - Event Cloud');
                        }
                    else if(mapAccTeam.containsKey('AM - CrowdCompass'))
                        {
                            AssignTo =mapAccTeam.get('AM - CrowdCompass');
                            }
                            else{
                            AssignTo=Userinfo.getUserID();
                            }
                    
                   
                        string description=instBookingClsf.Opportunity__c+'-ECAM_Task-'+ '10 Condition';

                        listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                     subject,duedate,'High',AssignTo,description));
                    
          
               }//condition 10 ends
                
                //condition 11 old sku -->sku8
        if(instBookingClsf.Product_Family__c=='CrowdCompass'
            && (instBookingClsf.New_Logo_Total__c>0 || instBookingClsf.Cross_Sell_Total__c>0)
            && checkSKUContains(setOppSKU,setSKU8) && !setOfOpportunityForSecondCondition.contains(instBookingClsf.opportunity__c))
            {
                setOfOpportunityForSecondCondition.add(instBookingClsf.opportunity__c);
            string subject='New client, intro and set hand-off mtg w/ DS - '+instBookingClsf.opportunity__r.Name; //Original Subject Line was changed on final request of Kaitlin ---- TICCM - 218 --- ORIGINAL SUBJECT - Set up Handoff Call with AM
            //AssignTo =instBookingClsf.opportunity__r.ownerId!=null?instBookingClsf.opportunity__r.ownerId:Userinfo.getUserID();

            if (mapAccTeam.containsKey('AM - Event Cloud'))
                      {
                            AssignTo =mapAccTeam.get('AM - Event Cloud');
                        }
                        else{
                            AssignTo =Userinfo.getUserID();
                        }
                 Date duedate=ContractImplementDate;
                    
                        string description=instBookingClsf.Opportunity__c+'-ECAM_Task-'+ '11 Condition';

                        listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                     subject,duedate,'High',AssignTo,description));
                     

                    
            }//condition 11 ends
             

        //Added By Mohsin
        //conditon 12 new sku -->setSKU12                                     
        if(instBookingClsf.Product_Family__c=='Onsite Solutions'&& (instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0
            ||instBookingClsf.Renewal_Value_Total__c>=0)&& checkSKUContains(setOppSKU,setSKU12) && (mapOpportunity.get(instBookingClsf.opportunity__c).SBQQ__PrimaryQuote__r.Contract_Opt_Out_Deadline__c!=null || Test.isRunningTest()))  //Added OptOutDate condition on request of Cristina - TICCM-217
            {
                 string subject='Opt out ends today - '+instBookingClsf.opportunity__r.Name;
                 Date duedate = mapOpportunity.get(instBookingClsf.opportunity__c).SBQQ__PrimaryQuote__r.Contract_Opt_Out_Deadline__c; 
                if (mapAccTeam.containsKey('AM - Event Cloud'))
                      {
                        AssignTo =mapAccTeam.get('AM - Event Cloud');
                       }
                   else{
                            AssignTo =Userinfo.getUserID();
                        }
                    
                    
                        string description=instBookingClsf.Opportunity__c+'-ECAM_Task-'+ '12 Condition';
                        listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                     subject,duedate,'High',AssignTo,description));
                       
            }//condition 12 ends
      
      //conditon 13 new sku -->setSKU12                                     
        if(instBookingClsf.Product_Family__c=='Onsite Solutions'&& (instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0)&& checkSKUContains(setOppSKU,setSKU12))
            {
                 string subject='New client, intro and set hand-off mtg w/ DS - '+instBookingClsf.opportunity__r.Name;
                 Date duedate=ContractImplementDate; 
                if (mapAccTeam.containsKey('AM - Event Cloud'))
                      {
                        AssignTo =mapAccTeam.get('AM - Event Cloud');
                       }
                   else{
                            AssignTo =Userinfo.getUserID();
                        }
                    
                    
                        string description=instBookingClsf.Opportunity__c+'-ECAM_Task-'+ '13 Condition';
                        listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                     subject,duedate,'High',AssignTo,description));
                       
            }//condition 13 ends
      
      //conditon 14 new sku -->setSKU14                                     
        if(instBookingClsf.Product_Family__c=='Social Tables'&& (instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0
            ||instBookingClsf.Renewal_Value_Total__c>=0)&& checkSKUContains(setOppSKU,setSKU14) && (mapOpportunity.get(instBookingClsf.opportunity__c).SBQQ__PrimaryQuote__r.Contract_Opt_Out_Deadline__c!=null || Test.isRunningTest()))  //Added OptOutDate condition on request of Cristina - TICCM-217
            {
                 string subject='Opt out ends today - '+instBookingClsf.opportunity__r.Name;
                 Date duedate = mapOpportunity.get(instBookingClsf.opportunity__c).SBQQ__PrimaryQuote__r.Contract_Opt_Out_Deadline__c; 
                if (mapAccTeam.containsKey('AM - Event Cloud'))
                      {
                        AssignTo =mapAccTeam.get('AM - Event Cloud');
                       }
                   else{
                            AssignTo =Userinfo.getUserID();
                        }
                    
                    
                        string description=instBookingClsf.Opportunity__c+'-ECAM_Task-'+ '14 Condition';
                        listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                     subject,duedate,'High',AssignTo,description));
                       
            }//condition 14 ends
      
      //conditon 15 new sku -->setSKU14                                     
        if(instBookingClsf.Product_Family__c=='Social Tables'&& (instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0)&& checkSKUContains(setOppSKU,setSKU14))
            {
                 string subject='New client, intro and set hand-off mtg w/ DS - '+instBookingClsf.opportunity__r.Name;
                 Date duedate=ContractImplementDate; 
                if (mapAccTeam.containsKey('AM - Event Cloud'))
                      {
                        AssignTo =mapAccTeam.get('AM - Event Cloud');
                       }
                   else{
                            AssignTo =Userinfo.getUserID();
                        }
                    
                    
                        string description=instBookingClsf.Opportunity__c+'-ECAM_Task-'+ '15 Condition';
                        listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                     subject,duedate,'High',AssignTo,description));
                       
            }//condition 15 ends
      
      //conditon 16 new sku -->setSKU16                                     
        if(instBookingClsf.Product_Family__c=='QuickMobile'&& (instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0
            ||instBookingClsf.Renewal_Value_Total__c>=0)&& checkSKUContains(setOppSKU,setSKU16) && (mapOpportunity.get(instBookingClsf.opportunity__c).SBQQ__PrimaryQuote__r.Contract_Opt_Out_Deadline__c!=null || Test.isRunningTest()))  //Added OptOutDate condition on request of Cristina - TICCM-217
            {
                 string subject='Opt out ends today - '+instBookingClsf.opportunity__r.Name;
                 Date duedate = mapOpportunity.get(instBookingClsf.opportunity__c).SBQQ__PrimaryQuote__r.Contract_Opt_Out_Deadline__c; 
                if (mapAccTeam.containsKey('AM - Event Cloud'))
                      {
                        AssignTo =mapAccTeam.get('AM - Event Cloud');
                       }
                   else{
                            AssignTo =Userinfo.getUserID();
                        }
                    
                    
                        string description=instBookingClsf.Opportunity__c+'-ECAM_Task-'+ '16 Condition';
                        listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                     subject,duedate,'High',AssignTo,description));
                       
            }//condition 14 ends
      
      //conditon 17 new sku -->setSKU16                                     
        if(instBookingClsf.Product_Family__c=='QuickMobile'&& (instBookingClsf.New_Logo_Total__c>=0 || instBookingClsf.Cross_Sell_Total__c>=0)&& checkSKUContains(setOppSKU,setSKU16))
            {
                 string subject='New client, intro and set hand-off mtg w/ DS - '+instBookingClsf.opportunity__r.Name;
                 Date duedate=ContractImplementDate; 
                if (mapAccTeam.containsKey('AM - Event Cloud'))
                      {
                        AssignTo =mapAccTeam.get('AM - Event Cloud');
                       }
                   else{
                            AssignTo =Userinfo.getUserID();
                        }
                    
                    
                        string description=instBookingClsf.Opportunity__c+'-ECAM_Task-'+ '17 Condition';
                        listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                     subject,duedate,'High',AssignTo,description));
                       
            }//condition 15 ends
        /*EC-AM Ends*/
    }//method ends
    /*
      CC CS,EC CS,CSN Planner
    */
    private static void CCCS_Task(booking_classification__c instBookingClsf,Map<string,ID> mapAccTeam, Set<String> setOppSKU,Id oppRecType)
    {
    
        // List<Task> listTaskInsert=new List<Task>();
        date ContractImplementDate=instBookingClsf.Opportunity__r.Contract_Implemented_Date__c;
        string AssignTo=UserInfo.getUserID();
        Id OppAccountID =instBookingClsf.Opportunity__r.AccountId;
        
        // comment cc CS task -24 sept 2018 
        /*final set<string> setSKU1 = new set<string>();//{'CV-SW-EC-CC-CCMBAP50-CCMBAP50','CV-SW-EC-CC-CCMBAP51-CCMBAP51',
                                    //'CV-SW-EC-CC-CCMBAP501-CCMBAP501','CV-SW-EC-CC-CCMBAP5001-CCMBAP5001 ', 
                                    //'CV-SW-EC-CC-CCMBAP3001-CCMBAP3001','CV-SW-EC-CC-CCMBAP251-CCMBAP251',
            //'CV-SW-EC-CC-CCMBAP1501-CCMBAP1501','CV-SW-EC-CC-CCMBAP126-CCMBAP126'};

        setSKU1.addAll(label.CCCS_TaskSku.split(','));
        //cccs task start 
        if(instBookingClsf.Product_Family__c=='CrowdCompass'
        && (instBookingClsf.New_Logo_Total__c>0 || instBookingClsf.Cross_Sell_Total__c>0||instBookingClsf.Renewal_Value_Total__c>0)
        && checkSKUContains(setOppSKU,setSKU1))
        {
            AssignTo=mapAccTeam.containsKey('CrowdCompass PC')?mapAccTeam.get('CrowdCompass PC'):Userinfo.getUserID();
            //1st condition CCCS task
            string subject1='Confirm Kickoff call is scheduled (reach out internally to DS/AM) or Send Intro email';
            Date duedate1=ContractImplementDate;
            duedate1=duedate1!=null?duedate1+1:duedate1;

            string description=instBookingClsf.Opportunity__c+'-CC CS-'+ '1 Condition';
            listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
            subject1,duedate1,'High',AssignTo,description));
            //1st condition CCCS ends  

            //2nd condition CCCS task
            description=instBookingClsf.Opportunity__c+'-CC CS-'+ '2 Condition';
            string subject2='Schedule Setup Call';
            Date duedate2=ContractImplementDate;
            duedate2=duedate2!=null?duedate2+3:duedate2;


            listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
            subject2,duedate2,'High',AssignTo,description));
            //2nd condition CCCS ends  

            //CCCS_Task ends

            //3rd condition CCCS task //please check again/*Important due date
            string subject3='Next Event Kickoff';
            Date duedate3=ContractImplementDate;
            duedate3=duedate3!=null?duedate1+3:duedate3;// need to check daTe  //ideal launch date- 3 months

            description=instBookingClsf.Opportunity__c+'-CC CS-'+ '3 Condition';
            listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
            subject3,duedate3,'Medium',AssignTo,description));
            //3rd condition CCCS ends  



            //4th condition CCCS task //please check again/*Important due date
            string subject4='Non-onboarding project: confirm EC is updated and next steps with planner';
            Date duedate4=ContractImplementDate;
            duedate4=duedate4!=null?duedate4+3:duedate4;// need to check daTe  //ideal launch date- 3 months

            description=instBookingClsf.Opportunity__c+'-CC CS-'+ '4 Condition';
            listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
            subject4,duedate4,'Medium',AssignTo,description));
            //4th condition CCCS ends  




            //5th condition CCCS task //please check onboarding duplication
            string subject5='Pending Details - Service Tier - # of events to onboard/calendar year ';
            Date duedate5=ContractImplementDate;

            /*listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
            subject5,duedate5,'Medium',AssignTo));
            description=instBookingClsf.Opportunity__c+'-CC CS-'+ '5 Condition';
            listOnboardInsertCon1HcPlannerCS.add(onboardingCreate(OppAccountID,'Open',AssignTo,'EMI',description));
            //5th condition CCCS ends  

            //6th condition CCCS task //please check onboarding duplication
            string subject6='Pending Details - Service Tier - # of events left in agreement to not onboard/calendar year';
            Date duedate6=ContractImplementDate;

            /*listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
            subject6,duedate6,'Medium',AssignTo));
            description=instBookingClsf.Opportunity__c+'-CC CS-'+ '6 Condition';
            listOnboardInsertCon1HcPlannerCS.add(onboardingCreate(OppAccountID,'Open',AssignTo,'EMI',description));
            //5th condition CCCS ends 

        }//CCCS_Task condition ends */
            /*Added here CSn-supplier only two condtions*/
        final set<string> setSKU3event = new set<string>();//{'CV-SW-EC-EVT-CSNPETBUN','CV-SW-EC-EVT-CSNPSTRBUN',
        //'CV-SW-EC-EVT-CSPADCLPOR','CV-SW-EC-EVT-CSPCLPRTENT10','CV-SW-EC-EVT-CSPCLPRTPR1',
        //'CV-SW-EC-EVT-CSNPETBUNENT','CV-SW-EC-EVT-CSNPSTRBUNENT','CV-SW-EC-EVT-CSNPLALICENTENT','CV-SW-EC-EVT-CSNPLALICENT',
        //'CV-SW-EC-EVT-CSNPALAC'};

        setSKU3event.addAll(label.SKU3event.split(',')); 
        string description='';      
        //conditon 1 new sku -->setSKU3event                                
        if(instBookingClsf.Product_Family__c=='Event'
        && (instBookingClsf.New_Logo_Total__c>0 || instBookingClsf.Cross_Sell_Total__c>0)
        && !checkSKUContains(setOppSKU,setSKU3event))
        {
            string subject='Follow up for Sourcing – New Client';
            Date duedate=ContractImplementDate;
            duedate =duedate!=null?duedate.addMonths(6):duedate;
            Id AssignTosourcerep = mapSourceRep.containsKey(instBookingClsf.Opportunity__r.account.PA_Rep__c)?mapSourceRep.get(instBookingClsf.Opportunity__r.account.PA_Rep__c):Userinfo.getUserID();  //need to check for Id here  

            description=instBookingClsf.Opportunity__c+'-CSN Planner-'+ '1 Condition';
            listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
            subject,duedate,'High',AssignTosourcerep,description));
                  

        }//condition 2 ends
        if(instBookingClsf.Product_Family__c=='Event'
        && (instBookingClsf.New_Logo_Total__c>0 || instBookingClsf.Cross_Sell_Total__c>0)
        && checkSKUContains(setOppSKU,setSKU3event))
        {
            string subject='New Sourcing Client: First Quarter- Check Usage';
            Date duedate=ContractImplementDate;
            duedate =duedate!=null?duedate.addMonths(3):duedate;
            Id AssignTosourcerep = mapSourceRep.containsKey(instBookingClsf.Opportunity__r.account.PA_Rep__c)?mapSourceRep.get(instBookingClsf.Opportunity__r.account.PA_Rep__c):Userinfo.getUserID();  //need to check for Id here  

            description=instBookingClsf.Opportunity__c+'-CSN Planner-'+ '2 Condition';
            listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
            subject,duedate,'High',AssignTosourcerep,description));
                 

        }//condition 2 ends
            
                //conditon 1 //no sku added for the AMA Tab // check business logic                           
        if(instBookingClsf.Product_Family__c=='Event'
        && (instBookingClsf.Renewal_Value_Total__c>0))
        {
            string subject='T-210 Renewal '+instBookingClsf.opportunity__r.ContractStartDate__c;
            Date duedate=instBookingClsf.opportunity__r.ContractStartDate__c;
            duedate =duedate!=null?duedate-210:duedate;
            AssignTo=mapAccTeam.containsKey('AM Associate')?mapAccTeam.get('AM Associate'):Userinfo.getUserID(); //check AMA role
            
            description=instBookingClsf.Opportunity__c+'-AMA-'+ '1 Condition';

            listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
            subject,duedate,'High',AssignTo,description));

            
            

        }//condition 1 ends
           //system.debug('listTaskInsert__'+listTaskInsert); 
           //
           
        ////EC-CS Task Creations
        final set<string> setSkuECCS =new set<string>();//{'CV-PS-HC-OSS-OA360T1','CV-PS-HC-OSS-OA360STD','CV-SW-EC-OSS-OA360(OSS)'};
        setSkuECCS.addAll(label.SkuECCS.split(','));
        
        final set<string> SetECCSSku9 = new set<string>();
        SetECCSSku9.addAll(label.ECCS_SKU9.split(','));
        System.debug('Inside This Method'+instBookingClsf.Product_Family__c);
        /*if(instBookingClsf.Product_Family__c=='Onsite Solutions'
        && (instBookingClsf.New_Logo_Total__c>0 || instBookingClsf.Cross_Sell_Total__c>0)
        && checkSKUContains(setOppSKU,SetECCSSku9))
        {  
            
            
            Onboarding__c onsitenew = new Onboarding__c();
            onsitenew.Opportunity_Name__c=instBookingClsf.opportunity__r.Id;
            onsitenew.Account_Name__c=instBookingClsf.opportunity__r.AccountId;
            onsitenew.Status__c = 'Open';
            onsitenew.Kick_off_Date__c = system.today();
            listOnsiteInsert.add(onsitenew);
            System.debug('listOnsiteInsert*****'+listOnsiteInsert);
        }*/
        if(instBookingClsf.Product_Family__c=='Onsite Solutions'
        && (instBookingClsf.New_Logo_Total__c>0 || instBookingClsf.Cross_Sell_Total__c>0)
        && checkSKUContains(setOppSKU,SetECCSSku9))
        {
            date duedate= instBookingClsf.opportunity__r.ContractStartDate__c;
            
            string subject1='Project Kickoff';
            string subject2 ='Confirm Badge artwork and send to print';
            string subject3 ='Confirm Shipping';
            //string subject4 ='Confirm IT requirements';
            //string subject5 ='Confirm Badge logic';
            //string subject6 ='Onsite technician assigned, if applicable';
            //string subject7 ='Complete testing (QR code, badge logic, registration process)';
            string subject8 ='Complete playbook';
            string subject9='Post Event Debrief';
            
            duedate= duedate!= null?duedate.addMonths(3):duedate;
            description=instBookingClsf.Opportunity__c+'-EC-CS-'+ '9 Condition';
            AssignTo = UserInfo.getUserId();//OppIdVsOnsite.get(instBookingClsf.opportunity__r.Id).Ownerid!=null?OppIdVsOnsite.get(instBookingClsf.opportunity__r.Id).Ownerid:Userinfo.getUserID();
            mapOnboarding=getOnboardingWithOppId(mapOpportunity,description); // get opportunity onbaording
            ID taskWhatId=mapOnboarding.containsKey(instBookingClsf.Opportunity__c)?mapOnboarding.get(instBookingClsf.Opportunity__c).id:OppAccountID;
            
            listTaskInsert.add(taskCreat(taskWhatId,'Not Started',
            subject1,duedate,'High',AssignTo,description));


            description=instBookingClsf.Opportunity__c+'-EC-CS-'+ '10 Condition';
            listTaskInsert.add(taskCreat(taskWhatId,'Not Started',
            subject2,duedate,'High',AssignTo,description));

            description=instBookingClsf.Opportunity__c+'-EC-CS-'+ '11 Condition';
            listTaskInsert.add(taskCreat(taskWhatId,'Not Started',
            subject3,duedate,'High',AssignTo,description));

            /*description=instBookingClsf.Opportunity__c+'-EC-CS-'+ '12 Condition';
            listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
            subject4,duedate,'High',AssignTo,description));

            description=instBookingClsf.Opportunity__c+'-EC-CS-'+ '13 Condition';
            listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
            subject5,duedate,'High',AssignTo,description));

            description=instBookingClsf.Opportunity__c+'-EC-CS-'+ '14 Condition';
            listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
            subject6,duedate,'High',AssignTo,description));

            description=instBookingClsf.Opportunity__c+'-EC-CS-'+ '15 Condition';
            listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
            subject7,duedate,'High',AssignTo,description));*/
            
            description=instBookingClsf.Opportunity__c+'-EC-CS-'+ '16 Condition';
            listTaskInsert.add(taskCreat(taskWhatId,'Not Started',
            subject8,duedate,'High',AssignTo,description));

            description=instBookingClsf.Opportunity__c+'-EC-CS-'+ '17 Condition';
            listTaskInsert.add(taskCreat(taskWhatId,'Not Started',
            subject9,duedate,'High',AssignTo,description));


        }
    //EC-Cs Task Creation Ends
    }//method ends
    
     //HC-Planner method
    private static void HC_Planner(booking_classification__c instBookingClsf,Map<string,ID> mapAccTeam, Set<String> setOppSKU,Id oppRecType)
    {
        //for HC- Planener cs
        Set<String> setCSNplannerProd = new Set<String>();//{'CV-SW-EC-EVT-CSNPETBUN','CV-SW-EC-EVT-CSNPSTRBUN','CV-SW-EC-EVT-CSNPETBUNENT',
        //'CV-SW-EC-EVT-CSNPSTRBUNENT','CV-SW-EC-EVT-CSNPLALICENT','CV-SW-EC-EVT-CSNPLALICENT5','CV-SW-EC-EVT-CSNPSTRBU2',
        //'CV-SW-EC-EVT-CSNPSTRBU','CV-SW-EC-EVT-CSNPELBND','CV-SW-EC-EVT-CSNPLALICENT2','CV-SW-EC-EVT-CSNPRLICPRF',
        // 'CV-SW-EC-EVT-CSNPLALICENT3','CV-SW-EC-EVT-CSNPLALICENT4','CV-SW-EC-EVT-CSNPALAC'};
        setCSNplannerProd.addAll(label.CSNplannerProd.split(','));
        Set<String> setCSNplannerCon4 = new Set<String>();//{'CV-SW-EC-EVT-CTWRFPFUN','CV-SW-EC-EVT-CUSQUES','CV-SW-EC-EVT-PRPREF',
        //'CV-SW-EC-EVT-RFPCAN','CV-SW-EC-EVT-RFPCUSBRG','CV-SW-EC-EVT-RFPCUSF',
        //'CV-SW-EC-EVT-RFPCUSFL','CV-SW-EC-EVT-RFPCUSQUES',
        //'CV-SW-EC-EVT-RFPSH','CV-SW-EC-EVT-RTRFPHISST','CV-SW-EC-EVT-RFPAPPPR',
        //'CV-SW-EC-EVT-NSOCON'};
        setCSNplannerCon4.addAll(label.CSNplannerCon4.split(','));
        set<string> setCSNplannerCon6 = new set<string>{'CV-SW-EC-EVT-RFPPO'};
        setCSNplannerCon6.addAll(label.CSNplannerCon6.split(','));

        date ContractImplementDate=instBookingClsf.Opportunity__r.Contract_Implemented_Date__c;
        string AssignTo=UserInfo.getUserID();
        Id OppAccountID =instBookingClsf.Opportunity__r.AccountId;
        AssignTo=mapAccTeam.containsKey('CS - CSN Planner')?mapAccTeam.get('CS - CSN Planner'):Userinfo.getUserID();
        //condition 1,2,3
        
        if(((instBookingClsf.Product_Family__c=='Event') &&
        ((instBookingClsf.New_Logo_Total__c>0)||(instBookingClsf.UpSell_Total__c>0)||(instBookingClsf.Cross_Sell_Total__c>0))) 
        && (checkSKUContains(setOppSKU,setCSNplannerProd))&&(setProdLine.contains('CSN Planner'))
        &&(instBookingClsf.Opportunity__r.Stagename.contains('Closed Won')))
        {  
            
            String description=instBookingClsf.Opportunity__c+'-HC-Planner-'+ '1 Condition';
           //Id OnboardingAccount =instBooking.Opportunity__r.AccountId;
            listOnboardInsertCon1HcPlannerCS.add(onboardingCreate(OppAccountID,'Open',AssignTo,'CSN-Planner',description));

            date activitydatetask1=instBookingClsf.Opportunity__r.Opp_End_Date__c; 
            date activitydatetask2=instBookingClsf.Opportunity__r.ContractStartDate__c;


            activitydatetask2=activitydatetask2!=null?activitydatetask2.addyears(1):activitydatetask2;

            string subject='Create and Deliver Annual Customer Success Review';
            
            description=instBookingClsf.Opportunity__c+'-HC-Planner-'+ '2 Condition';
            listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
            subject,
            activitydatetask2,'High',AssignTo,description));

            activitydatetask1 =activitydatetask1!=null?activitydatetask1.addMonths(6):activitydatetask1;

            string subject2='Create and Deliver Customer Success Review';
            //system.debug('activitydatetask1'+activitydatetask1);
            description=instBookingClsf.Opportunity__c+'-HC-Planner-'+ '3 Condition';
            listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
            'Create and Deliver Customer Success Review',
            activitydatetask1,'High',AssignTo,description));


        }// condition 1,2,3 ends    
        //condition 4
        if(((instBookingClsf.Product_Family__c=='Event') &&
        ((instBookingClsf.New_Logo_Total__c>0)||(instBookingClsf.UpSell_Total__c>0)||(instBookingClsf.Cross_Sell_Total__c>0))) 
        && (checkSKUContains(setOppSKU,setCSNplannerCon4)) &&(setProdLine.contains('CSN Planner'))
        &&(instBookingClsf.Opportunity__r.Stagename.contains('Closed Won'))) 
        {    
            date duedate = ContractImplementDate!=null?ContractImplementDate+1:ContractImplementDate;
            string  subject='New a la Carte Feature Purchased - Review Contract and Reach Out';
            string  description=instBookingClsf.Opportunity__c+'-HC-Planner-'+ '4 Condition';
            listCaseInsert.add(caseCreate('Feature implementation','Open',instBookingClsf.Opportunity__r.AccountId,'CSN - Planner',
            'New a la Carte Feature Purchased - Review Contract and Reach Out'
            ,AssignTo,'',description));  
            listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
            subject,
            duedate,'High',AssignTo,description));

        }//condition 4 ends     

                  //5th condition only renewl value greater than zero not other like new logo,cross sell,upspell
        if(((instBookingClsf.Product_Family__c=='Event') &&((instBookingClsf.Renewal_Value_Total__c>0))) 
        &&(instBookingClsf.Opportunity__r.Stagename.contains('Closed Won'))
        && (checkSKUContains(setOppSKU,setCSNplannerProd))&&(setProdLine.contains('CSN Planner'))) 
        {   
            string subject ='Renewal - Check In With The Client';
            string  description=instBookingClsf.Opportunity__c+'-HC-Planner-'+ '5 Condition';
            date TaskDuedate=instBookingClsf.Opportunity__r.Contract_Implemented_Date__c;
            TaskDuedate=TaskDuedate!=null?TaskDuedate+1:TaskDuedate;

            listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
            subject,TaskDuedate,'High',AssignTo,description));


        }
                
        //6th condition only for one SKu -'CV-SW-EC-EVT-RFPPO'
        if(((instBookingClsf.Product_Family__c=='Event') &&
        ((instBookingClsf.New_Logo_Total__c>0)||(instBookingClsf.UpSell_Total__c>0)||(instBookingClsf.Cross_Sell_Total__c>0))) 
        && (checkSKUContains(setOppSKU, setCSNplannerCon6)) &&(instBookingClsf.Opportunity__r.Stagename.contains('Closed Won'))
        &&(setProdLine.contains('CSN Planner')))
        {  
            string subject='Portal Purchased - Review Contract and Reach Out to the Client';
            date TaskDuedate=instBookingClsf.Opportunity__r.Contract_Implemented_Date__c;
            TaskDuedate=TaskDuedate!=null?TaskDuedate+1:TaskDuedate;
            string  description=instBookingClsf.Opportunity__c+'-HC-Planner-'+ '6 Condition';
            listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
            subject,TaskDuedate,'High',AssignTo,description));

        }           
    
    } //method end here
    static integer j=0,k=0;
    private static void HC_AM(booking_classification__c instBookingClsf,Map<string,ID> mapAccTeam, Set<String> setOppSKU,Id oppRecType)
    {
        //For HC-AM planner set (will be changed to custom setting/metadata)
        set<string> setDiamondCode = new set<string>();
        setDiamondCode.addAll(label.DiamondCode.split(','));
        final set<String> setHCAMSKU12=new Set<String>(); 
        setHCAMSKU12.addAll(label.HCAMSKU12.split(','));            // CV-SW-HC-SAI-SUPFERFPUSN4D,CV-SW-HC-SAI-SUPFERFPUSN3D,CV-SW-HC-CSN-SUPFERFPUSN,CV-SW-HC-SAI-SUPFERFPUSNHFD,CV-SW-HC-SAI-SUPFERFPUSN1D,CV-SW-HC-SAI-SUPFERFPUSN2D 
        
        final set<string> setHCAMSKU13=new Set<String>();
        setHCAMSKU13.addAll(Label.HCAMSKU13.split(','));//CV-SW-HC-CSN-WHTLAPRO
        //for product family "Analytics & Rfp performace" used in HC-AM
        Set<string> AnalyticRfpperformace = new set<string>();//{'CV-SW-HC-CSN-RFPRCS','CV-SW-HC-CSN-RFPRCS1-500',
        //'CV-SW-HC-CSN-RFPRCS500+','CV-SW-HC-CSN-RFPRE',
        //'CV-SW-HC-CSN-RFPRA','CV-SW-HC-CSN-RFPREENTDASH',
        //'CV-SW-HC-CSN-RFPRDDCON','CV-SW-HC-CSN-SCADSCAT'};
        AnalyticRfpperformace.addAll(label.AnalyticRfpperformace.split(','));    
        //for product family Software & Integration used in HC-AM
        Set<string> setSoftwareIntegration = new set<string>();//{'CV-PS-HC-CSN-SUPFEAADVCUSPR',
        //'CV-PS-HC-CSN-SUPFEABCUSPR'}; 
        setSoftwareIntegration.addAll(label.SoftwareIntegration.split(',')); 
        string subject='';
        date ContractImplementDate=instBookingClsf.Opportunity__r.Contract_Implemented_Date__c;
        string AssignTo=UserInfo.getUserID();
        Id OppAccountID =instBookingClsf.Opportunity__r.AccountId;
        AssignTo=mapAccTeam.containsKey('AM - HC')?mapAccTeam.get('AM - HC'):Userinfo.getUserID();
        Id WhatId = instBookingClsf.Opportunity__r.AccountId;
        system.debug('what Id of task  opp accId '+WhatId);
      
        /*if(((instBookingClsf.Product_Family__c=='HC Core Products - Diamonds') &&
            ((instBookingClsf.New_Logo_Total__c>=0)||(instBookingClsf.Cross_Sell_Total__c>=0)))&&
            (instBookingClsf.Opportunity__r.Stagename.contains('Closed Won'))&&(checkSKUContains(setOppSKU,setDiamondCode)))
            {
                date TaskDuedate=instBookingClsf.Opportunity__r.Opportunity_Start_Date_EBS__c;
                TaskDuedate=TaskDuedate!=null?TaskDuedate+60:TaskDuedate;
                
                subject='New Client-(Property Level) NBB-First CRM';
                       
                listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                         subject,
                                         TaskDuedate,'High',AssignTo));
              
            } */
            //condition 2
            if(((instBookingClsf.Product_Family__c=='HC Core Products - Diamonds') &&
            ((instBookingClsf.Renewal_Value_Total__c>=0)))&&
            (instBookingClsf.Opportunity__r.Stagename.contains('Closed Won'))&&(checkSKUContains(setOppSKU,setDiamondCode))
            && instBookingClsf.Opportunity__r.Opportunity_Type__c !='MYD'
            )
            {   date taskRenewalDate;
                date TaskDuedate=instBookingClsf.Opportunity__r.ContractEndDate__c;
                TaskDuedate=TaskDuedate!=null?TaskDuedate-120:TaskDuedate;
                if(instBookingClsf.Opportunity__r.ContractEndDate__c != null){
                     taskRenewalDate = instBookingClsf.Opportunity__r.ContractEndDate__c;
                }
                else
                {
                    taskRenewalDate = system.today();
                }
           
               
            //Map Logic for task subject written in for loop of opportunitylineItem
            //!map.isempty
                if(!mapdiamondvalue.isEmpty()){
              
                    for(string prodname :mapdiamondvalue.values()){
                    subject='Renewal (Property Level) ('+prodname+') (Date of Renewal -'+taskRenewalDate.format()+')';
                    string  description=instBookingClsf.Opportunity__c+'-HC-AM-'+ '2 Condition';
                    listTaskInsert.add(taskCreat(WhatId,'Not Started',
                    subject,
                    TaskDuedate,'High',AssignTo,description));

                    }
                }
            }
            //condition 3 Hc-AM Planner with Productcode check
            if(((instBookingClsf.Product_Family__c=='HC Core Products - Diamonds') &&
            ((instBookingClsf.Renewal_Value_Total__c>=0)||(instBookingClsf.New_Logo_Total__c>=0)||
            (instBookingClsf.UpSell_Total__c>=0)||(instBookingClsf.Cross_Sell_Total__c>=0)))&&
            (instBookingClsf.Opportunity__r.Stagename.contains('Closed Won'))
            &&(checkSKUContains(setOppSKU,setDiamondCode)))
            {
                date TaskDuedate=instBookingClsf.Opportunity__r.Opportunity_Start_Date__c;
                TaskDuedate=TaskDuedate!=null?TaskDuedate+60:TaskDuedate;
                subject='Diamond Client - Client Check In';
                string  description=instBookingClsf.Opportunity__c+'-HC-AM-'+ '3 Condition';
                listTaskInsert.add(taskCreat(WhatId,'Not Started',
                subject,TaskDuedate,'High',AssignTo,description));
                
            }

            //condition 4 HC-Am Planner                            //HC Core Products - Diamonds
            
                
           /* if(((instBookingClsf.Product_Family__c=='HC Core Products - Diamonds') &&
            ((instBookingClsf.UpSell_Total__c>=0)||(instBookingClsf.Renewal_Value_Total__c>=0)))&&
            (instBookingClsf.Opportunity__r.Stagename.contains('Closed Won'))
            &&(checkSKUContains(setOppSKU,setDiamondCode)))
            {
                date TaskDuedate=instBookingClsf.Opportunity__r.Opportunity_Start_Date_EBS__c;
                TaskDuedate=TaskDuedate!=null?TaskDuedate+45:TaskDuedate;
                subject='Diamond Upsell- CRM';
               

                listTaskInsert.add(taskCreat(OppAccountID,'Not Started',
                                         subject,TaskDuedate,'High',AssignTo));
              
            }*/
            // 5th condition Hc-AM bundles and Promo hub
            if(((instBookingClsf.Product_Family__c=='HC Core Products - Bundles & Promo Hub') &&
            ((instBookingClsf.Renewal_Value_Total__c>0)||(instBookingClsf.New_Logo_Total__c>0)
            ||(instBookingClsf.Cross_Sell_Total__c>0)))&&
            (instBookingClsf.Opportunity__r.Stagename.contains('Closed Won'))&& (setProdLine.contains('Bundles')))
            // need to check stage name condition is required in this class or not
            {
                date TaskDuedate=instBookingClsf.Opportunity__r.Opportunity_Start_Date__c;
                TaskDuedate=TaskDuedate!=null?TaskDuedate+120:TaskDuedate;
                subject='Bundle Client - Bi Annual Check In';
                string  description=instBookingClsf.Opportunity__c+'-HC-AM-'+ '5 Condition';
                listTaskInsert.add(taskCreat(WhatId,'Not Started',
                                        subject,TaskDuedate,'High',AssignTo,description));
              
            }
            //6th condition Hc-Am
            if(((instBookingClsf.Product_Family__c=='HC Core Products - Bundles & Promo Hub') &&
            ((instBookingClsf.Renewal_Value_Total__c>=0)))&&
            (instBookingClsf.Opportunity__r.Stagename.contains('Closed Won'))
            && instBookingClsf.Opportunity__r.Opportunity_Type__c !='MYD'
            )
            {   
                date taskEndDate=instBookingClsf.Opportunity__r.ContractEndDate__c;
                date TaskDuedate=instBookingClsf.Opportunity__r.ContractEndDate__c;
                TaskDuedate=TaskDuedate!=null?TaskDuedate-120:TaskDuedate;
                subject='Renewal (Property Level) (Bundled) (Date of Renewal -'+taskEndDate+')';
                string  description=instBookingClsf.Opportunity__c+'-HC-AM-'+ '6 Condition';
                listTaskInsert.add(taskCreat(WhatId,'Not Started',
                                     subject,TaskDuedate,'High',AssignTo,description));
              
            }
            //7th condition  
            if(((instBookingClsf.Product_Family__c=='Software & Integrations') &&
            ((instBookingClsf.Renewal_Value_Total__c>0 || instBookingClsf.MYD_Total__c>0)))&&
            (instBookingClsf.Opportunity__r.Stagename.contains('Closed Won'))
            &&(checkSKUContains(setOppSKU,setSoftwareIntegration)))
            {
                date taskRenewalDate=instBookingClsf.Opportunity__r.ContractEndDate__c;
                date TaskDuedate=instBookingClsf.Opportunity__r.ContractEndDate__c;
                TaskDuedate=TaskDuedate!=null?TaskDuedate-120:TaskDuedate;
             //taskRenewalDate = instBookingClsf.Opportunity__r.ContractEndDate__c;
            //Map Logic for task subject written in for loop of opportunitylineItem
                 string  description=instBookingClsf.Opportunity__c+'-HC-AM-'+ '7 Condition';
                if(!mapOpidvsProductcodesoftwareInt.isEmpty()){
                    
                    system.debug('mapOpidvsProductcodesoftwareInt.values()'+ mapOpidvsProductcodesoftwareInt.values());
                    for(string prodname :mapOpidvsProductcodesoftwareInt.values()){
                        subject='Renewal (Property Level) ('+prodname+') (Date of Renewal -'+taskRenewalDate+')';

                            listTaskInsert.add(taskCreat(WhatId,'Not Started',
                                             subject,TaskDuedate,'High',AssignTo,description));
                        
                        
                    }
                }
            }
            
            // 8th Condition 
            if((instBookingClsf.Opportunity__r.Stagename.contains('Closed Lost'))&&(checkSKUContains(setOppSKU,setHCAMSKU12)))
            
            {
                
                string  description=instBookingClsf.Opportunity__c+'-HC-AM-'+ '8 Condition';
                date TaskDuedate=instBookingClsf.Opportunity__r.ContractEndDate__c!=null?instBookingClsf.Opportunity__r.ContractEndDate__c-120:instBookingClsf.Opportunity__r.ContractEndDate__c;
                
                subject='User names expires (<'+instBookingClsf.Opportunity__r.ContractEndDate__c+'>) Follow up to renew';
                AssignTo=mapAccTeam.containsKey('AM - CSN')?mapAccTeam.get('AM - CSN'):Userinfo.getUserID();
                listTaskInsert.add(taskCreat(WhatId,'Not Started',
                                         subject,TaskDuedate,'High',AssignTo,description));
                
            }   // end of 8th       
            //9th condition oppRecTyperenewal (instBookingClsf.Opportunity__r.recordtypeId == oppRecTyperenewal)            &&
            if((instBookingClsf.Opportunity__r.account.Venue_Type__c=='Above- Property Account')
            &&((!string.isBlank(instBookingClsf.Opportunity__r.MSA_Code__c))||(!string.isBlank(instBookingClsf.Opportunity__r.Other_MSA_Code__c)))
            &&(instBookingClsf.Opportunity__r.Stagename.contains('Closed Won')) && j==0)
            {  
                date TaskDuedate=instBookingClsf.Opportunity__r.ContractEndDate__c!=null?instBookingClsf.Opportunity__r.ContractEndDate__c-120:system.today();
                 string  description=instBookingClsf.Opportunity__c+'-HC-AM-'+ '9 Condition';
                Id ownerIdAcc = instBookingClsf.Opportunity__r.Account.OwnerId;
                subject='Renewal (Corporate  Level) ('+bundleMSACode+')  (Date of Renewal-'+instBookingClsf.Opportunity__r.RenewalDate__c+')';
              
                listTaskInsert.add(taskCreat(WhatId,'Not Started',
                                         subject,TaskDuedate,'High',ownerIdAcc,description));
                j++;
              
            }

            //10th condition can be refactored (can be used in 9th condition if else based on recordtype) //(instBookingClsf.Opportunity__r.recordtypeId != oppRecTyperenewal)            &&
            if((instBookingClsf.Opportunity__r.account.Venue_Type__c=='Above- Property Account')
            &&((!string.isBlank(instBookingClsf.Opportunity__r.MSA_Code__c))||(!string.isBlank(instBookingClsf.Opportunity__r.Other_MSA_Code__c)))
            &&(instBookingClsf.Opportunity__r.Stagename.contains('Closed Won')) && k==0 )
            {   string  description=instBookingClsf.Opportunity__c+'-HC-AM-'+ '11 Condition';
                Id ownerId= instBookingClsf.Opportunity__r.ownerId;
                date TaskDuedate=instBookingClsf.Opportunity__r.Opportunity_Start_Date__c!=null?instBookingClsf.Opportunity__r.Opportunity_Start_Date__c+60:system.today(); //bundleMSAEndDate
                subject='MSA purchased ('+bundleMSACode+') (Corporate  Level) NBB-First CRM';
               
                listTaskInsert.add(taskCreat(WhatId,'Not Started',
                                         subject,TaskDuedate,'High',ownerId,description));
              
                k++;
            }


            //12th condition, skipping 8th,13th(quoteline and msa object rule)
            if(((instBookingClsf.Product_Family__c=='Analytics & RFP Performance') &&
            ((instBookingClsf.Renewal_Value_Total__c>0)||(instBookingClsf.New_Logo_Total__c>0)
            ||(instBookingClsf.Cross_Sell_Total__c>0)))&&
            (instBookingClsf.Opportunity__r.Stagename.contains('Closed Won'))
            &&(checkSKUContains(setOppSKU,AnalyticRfpperformace)))
            {
                string  description=instBookingClsf.Opportunity__c+'-HC-AM-'+ '12 Condition';
                date TaskDuedate=instBookingClsf.Opportunity__r.CloseDate;
                TaskDuedate=TaskDuedate!=null?TaskDuedate+30:TaskDuedate;
                 subject='BI Report Delivery CRM and Renewal';
                
                    listTaskInsert.add(taskCreat(WhatId,'Not Started',
                                         subject,TaskDuedate,'High',AssignTo,description));
                
                
            }
    
        // 13 th Condition 
            if((instBookingClsf.Opportunity__r.Stagename.contains('Closed Lost'))&&(checkSKUContains(setOppSKU,setHCAMSKU13)))
            {
                
                
                date TaskDuedate=instBookingClsf.Opportunity__r.ContractEndDate__c!=null?instBookingClsf.Opportunity__r.ContractEndDate__c+30:instBookingClsf.Opportunity__r.ContractEndDate__c;
                string  description=instBookingClsf.Opportunity__c+'-HC-AM-'+ '13 Condition';
                subject='SRFP White Label Pro did not renew - Reach out';
                
                AssignTo=mapAccTeam.containsKey('AM - CSN')?mapAccTeam.get('AM - CSN'):Userinfo.getUserID();
                listTaskInsert.add(taskCreat(WhatId,'Not Started',
                                         subject,TaskDuedate,'Normal',AssignTo,description));
                
            }   // end of 8th   
    }
    
    private static boolean checkSKUContains(Set<String> setOppSKU, Set<String> setSKUFromCustomsetting){
        
        boolean flag=false;
        for(string sku:setOppSKU){
            
            if(setSKUFromCustomsetting.contains(sku)){
                
                flag=true;
                break;
            }   
            
        }//end 

        return flag;        
        
    } // end here   
    /*
     DESC: To create task by passing some of the parameters
    */
    public static task taskCreat(Id whatId,string status,string subject,date activitydate,string Priority,Id owner ,String description)   
    {
        task tHcPlannerCon2 = new task();
        tHcPlannerCon2.WhatId=whatId;
        tHcPlannerCon2.Subject=subject;
        tHcPlannerCon2.Status=status;
        tHcPlannerCon2.ActivityDate=activitydate;
        tHcPlannerCon2.Priority=Priority; 
        tHcPlannerCon2.OwnerId=owner!=null?owner:UserInfo.getUSerID();
        //tHcPlannerCon2.description=description;
        
        return tHcPlannerCon2;
       
        
    }
    public static case caseCreate(String serviceCategory,string status,Id accId,string productType,string Subject,Id owner,String caseCategory,string description )   
    {   
        Id CaseRecTypeCSPlanner = schema.SObjectType.Case.getRecordTypeInfosByName().get('Client Management (Global)').getRecordTypeId();
        case casecon4CSNPlanner = new case();
        casecon4CSNPlanner.RecordTypeId=CaseRecTypeCSPlanner;
        casecon4CSNplanner.Client_Services_Category__c=serviceCategory;
        casecon4CSNplanner.Status=status;
        casecon4CSNplanner.AccountId =accId;
        casecon4CSNplanner.Product_Type__c=productType;
        casecon4CSNplanner.Subject=subject;
        casecon4CSNplanner.OwnerId=owner;
        casecon4CSNplanner.Creation_Source_Dev__c=String.isNotBlank(description)?description:'TaskAutomation Class';
        return casecon4CSNPlanner;
    }
    
    public static case caseCreateNew(String serviceCategory,string status,Id accId,string productType,string Subject,Id owner,string description,String recordTypeName)   
    {   
        Id CaseRecTypeCSPlanner = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        case caseInstance = new case();
        caseInstance.RecordTypeId = CaseRecTypeCSPlanner;
        caseInstance.Client_Services_Category__c = serviceCategory;
        caseInstance.Status = status;
        caseInstance.AccountId = accId;
        caseInstance.Product_Type__c = productType;
        caseInstance.Subject = subject;
        caseInstance.OwnerId = owner;
        caseInstance.Creation_Source_Dev__c = String.isNotBlank(description)?description:'TaskAutomation Class';
        return caseInstance;
    }
    
    public static Onboarding__c OnboardingCreate(Id accountId,string status,Id owner, String recTypeName, string description) //CSN-Planner
    {
        Id RecTypeCSPlanner = schema.SObjectType.Onboarding__c.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        //system.debug('RecTypeCSPlanner'+RecTypeCSPlanner);
        Onboarding__c onboard = new Onboarding__c();
        onboard.Account_Name__c= accountId;
        onboard.RecordTypeId=RecTypeCSPlanner;
        onboard.Status__c=status;
        onboard.OwnerId= owner;
        onboard.Creation_Source_Dev__c=String.isNotBlank(description)?description:'TaskAutomation Class';
        return onboard;
    }
    
    
    /**
    DESC: to set boolean task created field true on firts time contracted implement true  and use to stop calling of taskautomation multiple times
    */
    private static void setTaskCreatedField(List<Opportunity> listOfOppty){
        
        List<Opportunity> listToUpdateOpty=new List<Opportunity>();
        for(Opportunity instOppty:listOfOppty){
            
            if(instOppty.Contract_Implemented__c && !instOppty.Task_Created__c){
                
                instOppty.Task_Created__c=true;
                listToUpdateOpty.add(instOppty);
                
            }
            
        }
        
        if(!listToUpdateOpty.isEmpty()){
            
            update listToUpdateOpty;
        }   
        
    } // end here
    
    /*
    DESC: This method for 16th condition only- HC-Supplier CS
    */
    private  static boolean checkBothSKU(Set<String> setProdSKU,Set<String> sku16A,Set<String> sku16B,Set<String> sku16c,Set<String> sku16d){


        boolean flag=true;  
        for(String SKU:sku16A){
            
            if(!setProdSKU.contains(SKU)){
                
                flag=false;
                
            }
            
        }
        if(flag){return flag;}else{flag=true;}
        
            
        for(String SKUb:sku16B){
        
            if(!setProdSKU.contains(SKUb)){
                
                flag=false;
                
            }
        
        }
        
        
        
        
        if(flag){return flag;}else{flag=true;}
            
            for(String SKUc:sku16C){
            
                if(!setProdSKU.contains(SKUc)){
                    
                    flag=false;
                    
                }
            
            }
        
       
        if(flag){return flag;}else{flag=true;}
            
            for(String SKUD:sku16d){
            
                if(!setProdSKU.contains(SKUD)){
                    
                    flag=false;
                    
                }
            
            }
        
        
        return flag;
    }// end

    /*
    Desc: To get onboarding data as per requirment, there is one to one relationship betweer opportunity and onbaording
    */
    private static Map<Id,Onboarding__c> getOnboardingWithOppId(Map<Id,Opportunity> mapOpportunity, string description){
        
        Map<Id,Onboarding__c> mapOnboarding=new Map<Id,Onboarding__c>();
        List<Onboarding__c> listOnboardInsert=new List<Onboarding__c>();
        for(Opportunity instOpp:mapOpportunity.values()){
            
            Onboarding__c instOnboard=new Onboarding__c();
            instOnboard.Opportunity_Name__c=instOpp.id;
            instOnboard.Account_Name__c=mapOpportunity.get(instOpp.id).AccountID;
            instOnboard.Contact_Name__c = instOpp.Contact_Associated__c;
            instOnboard.Creation_Source_Dev__c = String.isNotBlank(description)?description:'TaskAutomation Class';
            listOnboardInsert.add(instOnboard);
        }
        System.debug('listOnboardInsert*****'+listOnboardInsert);
        insert listOnboardInsert;
        for(Onboarding__c instOnboarding:listOnboardInsert){
            
            mapOnboarding.put(instOnboarding.Opportunity_Name__c,instOnboarding);
        }   
        
        return mapOnboarding;
        
    }// end 
}// end of class