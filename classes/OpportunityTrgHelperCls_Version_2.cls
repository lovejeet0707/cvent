/* ===============================
AUTHOR     :     Shanu Aggarwal    
CREATED DATE   : 12 MAY 2016
PURPOSE     :    Extending Opportunity Trigger Handler Code
TEST CLASS :     OpportunityTrgHelperCls_Version_2_Test
SPECIAL NOTES:   We have extended a version of OpportunityTrgHelperCls which is used for Opportunity trigger.  

HISTORY: 
1) 05 May 2016 :-  Shanu Added a method called CreateTMMob to create TM onboarding records when opportunities are closed won.
2) 21 Nov 2017 :-  HSR Added a Method called CheckQuoteProduct which will check whether the Opportunity which we are doing closed/won .
3) 01 Dec 2017 :- HSR : Added a method called ChangeOppSplitOwner to change the Split Owner of the OpportunitySplit when a Owner is being changed in the Closed/Won opportunity.
has only one Primary Quote and atleast on Product attached.
4) 08 Jan 2018 :- HSR : If contract team is removing AM owner name from opportunity, we want an email alert should out to that rep whose name we are removing.
5) 16th Jan 2018 :- HSR : Owner Assignment while creating Opportunity on the basis of the AccountTeamMember.
============================= 
*/

public class OpportunityTrgHelperCls_Version_2 {
    
    static boolean testBoolean=false;
    
    @TestVisible 
    static boolean isComingfromTestHandler1=false;
    
    //Method for Before Insert Event
    public static void OnBeforeInsert(List<Opportunity> newValues){    
        
        //Set<ID> userstoRun = new Set<ID>{'00500000007RNH1','00500000007Jxph','005o0000002QrNR','005o0000002jzhH'};
        // In Test, these methods can only be called by OpportunityTrgHelperCls_Version_2__Test
        //if(!isComingfromTestHandler1 && userstoRun.contains(UserInfo.getUserId())){
        if(!isComingfromTestHandler1){
            //Map MYD fields from renewed Opportunity generated frin CPQ
            MapMYDFieldsFromCPQ(newValues, null);
            //HSR : 16th Jan : Owner Assignment while creating Opportunity on the basis of the AccountTeamMember.
            if(Label.IsOppOwnerAssignmentEnable=='True')
                oppOwnerAssignment(newValues);
        }
        
        populateOppOwnerRole(newValues); // add by kumud [Trigger merge: OwnerRoleTrigger]
        populateRenewalSpecialist(newValues);
        if(ExecuteMethodHelper.isActive('CloseDateAutomation'))
        {
            List<String> profileToBeExcluded = Label.ProfileToExclude.split(',');
            if(!profileToBeExcluded.contains(String.ValueOf(UserInfo.getProfileId())))
            {
                renewalDateAutomationBeforeInsert(newValues);  
            }
        }
    }
    
    //Method for Before Update Event
    public static void OnBeforeUpdate(Map<Id,Opportunity> oldMapValues,Map<Id,Opportunity> newMapValues){    
        
        if(!isComingfromTestHandler1){

            Set<Id> quoteIdsToValidate = CventMyd_ValidationHandler.getQuoteIdsFromOpportunityTrigger();
            CventMyd_ValidationHandler.validateQuotes(quoteIdsToValidate);
            CventMyd_ValidationHandler.validateClosedWonAttachmentsFromTrigger();           
            
            If((!testBoolean && !System.isBatch()) || Test.isRunningTest()){//
                WebDesignSupportRollup(newMapValues.values(),oldMapValues,false,false);
            }
            
            /*HSR:Added this as a part of Refactoring*/
            List<Opportunity> ownerUpdateList = new List<Opportunity>();
            /*Added By :HSR : Method will check whether the Opportunity which we are doing closed/won has only one Primary Quote
and at least on Product attached.*/
            Set<Id> oppIdSet = new Set<Id>();
            Map<String,ObsoletedProfiles__c> obsoletedProfiles = ObsoletedProfiles__c.getAll(); //Added By Mohsin
            Map<Id,Opportunity> mapOfOpps = new Map<Id,Opportunity>();    //Added By Mohsin
            Map<integer,String> monthMap =new Map<integer,String> {1 => 'January',2 => 'February',3 => 'March',4 => 'April',5 => 'May',6 => 'June',7 => 'July',8 => 'August',9 => 'September',10 => 'October',11 => 'November',12 => 'December'}; //  added by Udita : P-004699
            list<String> byPassAffixProfileIds = new list<String>();
            String byPassAffixUserName = Label.UserBypassQM;
            byPassAffixProfileIds=  Label.OpportunityAffixByPassProfile.split(',');
            String idloggedinUser = String.ValueOf(UserInfo.getProfileId());
            String loggedinUserName = UserInfo.getUserName();
             //Added By Mohsin
            //List<Profile> profiles = [Select Id,Name from Profile where Id =:UserInfo.getProfileId() LIMIT 1];
            List<String> salesProfiles = Label.SalesProfilesOnly.split(',');
            List<String> profileToBeExcluded = Label.ProfileToExclude.split(',');
            Id renewalRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
            Map<Id,Opportunity> mapOfOpps2 = new Map<Id,Opportunity>();
            List<Opportunity> listOfOpps3 = new List<Opportunity>();
            For(Opportunity opp : newMapValues.values()){
                string oppName='';
                Opportunity oldOpp = oldMapValues.get(opp.Id);
                if(opp.StageName == 'Closed Won' && opp.StageName!=oldOpp.StageName)
                {
                    oppIdSet.add(opp.Id);
                    //Added by Mohsin
                    if(!salesProfiles.isEmpty())
                    {
                        if(salesProfiles.contains(idloggedinUser.substring(0,15)))
                        {
                            if(opp.ATI_Check__c == FALSE && (opp.Product__c == 'Event' || opp.Product__c == 'CrowdCompass' || opp.Product__c == 'Lanyon Events' || opp.Product__c == 'Lanyon Meetings' || opp.Product__c == 'Lanyon Passkey' || opp.Product__c == 'Lanyon Travel' || opp.Product__c == 'Onsite Solutions' || opp.Product__c == 'Survey') && !obsoletedProfiles.containsKey(userinfo.getProfileId()))
                            {
                                mapOfOpps.put(opp.Id,opp); 
                            }
                            mapOfOpps2.put(opp.Id,opp); //Added By Mohsin
                        }
                    }
                }
                //Added By Mohsin
                if(opp.StageName.contains('Closed') && opp.StageName != oldOpp.StageName && opp.RecordTypeId == renewalRTId)
                {
                    listOfOpps3.add(opp);
                }
                if(opp.OwnerId != oldOpp.OwnerId)
                {
                    ownerUpdateList.add(opp);
                }
                // added by Udita for P-004699(Update Opportunity Name)
                  if(Boolean.ValueOf(Label.AffixFunctioanlity) ){
                    oppName = '';
                    if(oldOpp.id == opp.id && opp.Opportunity_Type__c =='NBB' && opp.Opportunity_Name_Affix__c!= NULL && UserInfo.getUserName() != Label.UserBypassQM){
                        oppName = monthMap.get(opp.closeDate.Month()) + ' ' + opp.closeDate.Year() + ' ' + 'NBB' + ' ' + opp.Opportunity_Name_Affix__c;
                    }
                    if(oldOpp.id == opp.id && !Test.isRunningTest() && opp.StageName.contains('Closed') && (opp.Opportunity_Name_Affix__c != oldOpp.Opportunity_Name_Affix__c) && !byPassAffixProfileIds.contains(idloggedinUser.substring(0,15))){
                        opp.addError('You cannot edit Opportunity Name Affix field once the Opportunity is Closed Won');
                    }
                    if(oldOpp.id == opp.id && opp.Opportunity_Name_Affix__c!= NULL && oldMapValues.get(opp.id).Opportunity_Name_Affix__c != null && opp.Opportunity_Name_Affix__c != oldMapValues.get(opp.id).Opportunity_Name_Affix__c && opp.Opportunity_Type__c !='NBB' && !opp.StageName.contains('Closed') && UserInfo.getUserName() != Label.UserBypassQM){
                        oppName = opp.Name.replace(oldMapValues.get(opp.id).Opportunity_Name_Affix__c,opp.Opportunity_Name_Affix__c );
                    } 
                    if(oldOpp.id == opp.id && opp.Opportunity_Name_Affix__c!= NULL && oldMapValues.get(opp.id).Opportunity_Name_Affix__c == null  && opp.Opportunity_Type__c !='NBB' && !opp.StageName.contains('Closed')  && UserInfo.getUserName() != Label.UserBypassQM){
                        oppName = opp.Name + ' ' + opp.Opportunity_Name_Affix__c;
                    } 
                    if(oldOpp.id == opp.id &&  !String.IsBlank(oppName)){
                      opp.Name= oppName.length()>120?oppName.Substring(0,120):oppName;
                    }
                  }
            }
            
            if(oppIdSet.size()>0)
                CheckQuoteProduct(newMapValues.values(), oppIdSet);
            if(!mapOfOpps.isEmpty() && mapOfOpps.size() > 0 && Label.ATIValidation == 'TRUE')
                AtiValidation(mapOfOpps);
            if(!mapOfOpps2.isEmpty() && mapOfOpps2.size() > 0 && Label.SendOrderToEBS == 'TRUE')
                SendOrderToEBSValidation(mapOfOpps2);
            if(!listOfOpps3.isEmpty() && listOfOpps3.size() > 0 && !profileToBeExcluded.contains(String.ValueOf(UserInfo.getProfileId())) && ExecuteMethodHelper.isActive('CloseDateAutomation'))
            renewalDateAutomationBeforeUpdate(listOfOpps3); 
            //Map MYD fields from renewed Opportunity generated from CPQ
            //IF(CheckRecursive.runTwentyFour()){    // check recursive added by udita as issue was coming in marking renewal quoted on contract
            MapMYDFieldsFromCPQ( newMapValues.values(), oldMapValues);
            //}            /*HSR:Added this as a part of Refactoring*/
            if(ownerUpdateList.size()>0)
                populateOppOwnerRole(ownerUpdateList); // add by kumud [Trigger merge: OwnerRoleTrigger]            
        }
    }
    
    //Method for After Insert Event
    public static void OnAfterInsert(Map<Id,Opportunity> newMapValues){   
        if(!isComingfromTestHandler1){
            //Added by Shanu
            CreateTMMob(newMapValues);
        }
    }
    
    //Method for After Update Event
    public static void OnAfterUpdate(Map<Id,Opportunity> oldMapValues, Map<Id,Opportunity> newMapValues){ 
        //System.debug('CheckRecursive.runTwentyOne****'+CheckRecursive.runTwentyOne());
        
        //Added By Mohsin - #P-005039
        //Map<Id,Opportunity> mapOfOpps3 = new Map<Id,Opportunity>();   
        //for(Opportunity opp : newMapValues.values())
        //{
           // System.debug('New SBQQ__Contracted__c:'+opp.SBQQ__Contracted__c+', Old SBQQ__Contracted__c'+oldMapValues.get(opp.Id).SBQQ__Contracted__c);
            //if(((opp.SBQQ__Contracted__c == TRUE && opp.SBQQ__Contracted__c != oldMapValues.get(opp.Id).SBQQ__Contracted__c)) || Test.isRunningTest())
            //{
            //    mapOfOpps3.put(opp.Id,opp);
            //}
        //}
        //if(!mapOfOpps3.isEmpty() && mapOfOpps3.size() > 0 && Boolean.valueOf(Label.SocialTablesEmailAlert))
            //SendSocialTablesEmailAlert(mapOfOpps3);
        Map<id,Opportunity> NBBOppIds = new Map<id,Opportunity>();  //TICCM-321 
        //code for Professional services Email Alert :Udita
        if(CheckRecursive.runTwentyOne() == true || test.isRunningTest()){
            set<id> accIds = new set<id>();
            set<id> oppIds = new set<id>();
            List<Messaging.SingleEmailMessage> emailMsgList = new List<Messaging.SingleEmailMessage>();  
            
            for(Opportunity opp : newMapValues.values()){
                Opportunity oppOld = oldMapValues.get(opp.id);
                system.debug('---oppOld.StageName'+oppOld.StageName);
                system.debug('---oppOld.Name'+oppOld.Name);
                system.debug('---oppNew.StageName'+opp.StageName);
                system.debug('---oppNew.Name'+opp.Name);
                if((opp.StageName == 'Closed Won' && oppOld.StageName != opp.StageName)  || test.isRunningTest()){   
                    if(opp.AccountId !=null){
                        accIds.add(opp.accountId);}                     
                    oppIds.add(opp.id);
                     if(opp.Opportunity_Type__c == 'NBB'){
                       NBBOppIds.put(opp.id,opp);
                    }
                }
            }
            map<id,list<EB_SB_Builder__c>> EBSPMap= new map<id,list<EB_SB_Builder__c>>();
            map<id,list<EB_SB_Builder__c>> EBSPMapClientMail = new map<id,list<EB_SB_Builder__c>>();
            map<id,list<OpportunityLineItem>> opptunityMap= new map<id,list<OpportunityLineItem>>();
            
            if(oppIds.size() > 0){
                for(OpportunityLineItem opp: [select id,OpportunityId,Product_Name__c,ProductCode  from OpportunityLineItem where ProductCode ='CV-PS-EC-CCS-APPBPLS' and OpportunityId in :oppIds]){
                    if(!opptunityMap.containskey(opp.OpportunityId)){
                        opptunityMap.put(opp.OpportunityId,new list<OpportunityLineItem>());
                    }
                    opptunityMap.get(opp.OpportunityId).add(opp);
                }
            }
            if((oppIds.size() > 0  && !opptunityMap.isEmpty()) || test.isRunningTest()){   
                if(accIds.size() > 0){
                    for(EB_SB_Builder__c ebsp: [select id,OwnerId,AccountCustom__r.name,owner.name,Project_Status_del__c,AccountCustom__c from EB_SB_Builder__c where AccountCustom__c in : accIds and (Project_Status_del__c != NULL AND Project_Status_del__c !='Completed' and Project_Status_del__c != 'Cancelled')]){
                        String idString = String.valueOf(ebsp.OwnerId);
                        if(!idString.Startswith('00G')){
                            if(!EBSPMap.containskey(ebsp.AccountCustom__c)){
                                EBSPMap.put(ebsp.AccountCustom__c,new list<EB_SB_Builder__c>());
                            }
                            EBSPMap.get(ebsp.AccountCustom__c).add(ebsp);
                            
                            if(ebsp.Project_Status_del__c != 'Yet to Start'){
                                if(!EBSPMapClientMail.containskey(ebsp.AccountCustom__c)){
                                    EBSPMapClientMail.put(ebsp.AccountCustom__c,new list<EB_SB_Builder__c>());
                                }
                                EBSPMapClientMail.get(ebsp.AccountCustom__c).add(ebsp);                    
                            }
                        }
                    }
                }
                
                Id templateId;
                //Getting template Id
                if(Label.isEmailTemplateRun == 'True'){
                    templateId = [Select Id From EmailTemplate Where DeveloperName = 'Cvent_CrowdCompass_Integration_Term'].Id;  
                    
                    for(Opportunity opp : newMapValues.values()){
                        if(opptunityMap.size() >0 && opptunityMap.containsKey(opp.id)/* || test.isRunningTest()*/){
                            if(EBSPMap.size() >0 && EBSPMap.containsKey(opp.AccountId)){
                                for(EB_SB_Builder__c  ebs : EBSPMap.get(opp.AccountId)){                   
                                    for(OpportunityLineItem oli : opptunityMap.get(opp.id)){
                                        Messaging.SingleEmailMessage msg =  new Messaging.SingleEmailMessage();                    
                                        msg.setSubject('Integration Alert: Client purchased CrowdCompass');
                                        msg.setHtmlBody('<p>Dear '+ ebs.Owner.name+ ',</p>'+
                                                        '<p>A CrowdCompass app has been sold on '+ '<a href="https://cvent.my.salesforce.com/'+ebs.AccountCustom__c+'">'+ebs.AccountCustom__r.name+'</a>'+ '. Please click ' + '<a href="https://cvent.my.salesforce.com/'+ebs.id+'">here</a>' + ' to view the record.</P><P>' + label.NOTIFICATION_FOR_EBSB_ONWER  + '.</p>');
                                        List<String> sendTo = new List<String>();
                                        sendTo.add(ebs.OwnerId);
                                        sendTo.add(label.EmailId_ProfessionalServiceCSE);
                                        sendTo.add(label.EmailId_ProfessionalServiceRKonwar);
                                       // sendTo.add(label.EmailId_ProfessionalServiceDeeksha);
                                       // sendTo.add(label.EmailId_ProfessionalServiceNArora);
                                        System.debug('sendto*****'+sendTo);
                                        msg.setToAddresses(sendTo); 
                                        msg.setOrgWideEmailAddressId('0D2o0000000GpxI');
                                        msg.setSaveAsActivity(false);
                                        emailMsgList.add(msg); 
                                        
                                    } 
                                }
                            }
                            System.debug('emailMsgList inside for before EBS*****'+emailMsgList);                   
                            system.debug('----opp.Contact_Associated__c'+opp.Contact_Associated__c);  
                            if((EBSPMapClientMail.size() >0 && EBSPMapClientMail.containsKey(opp.AccountId)) || Test.isRunningTest()){               
                                if(opp.Contact_Associated__c != null){
                                    Messaging.SingleEmailMessage msg1 =  new Messaging.SingleEmailMessage();  
                                    msg1.setTemplateId(templateId);
                                    msg1.setToAddresses(new List<String>{opp.Contact_Associated__c});  
                                    System.debug('msg1*****'+msg1);
                                    msg1.setOrgWideEmailAddressId('0D2000000008OzJ');
                                    msg1.setSaveAsActivity(false);
                                    msg1.setTargetObjectId(opp.Contact_Associated__c);
                                    msg1.setWhatId(opp.id);
                                    emailMsgList.add(msg1);     
                                }
                            }
                            System.debug('emailMsgList inside for after EBS*****'+emailMsgList);                   
                        }
                    }                  
                    
                    System.debug('emailMsgList*****'+emailMsgList);                             
                    if(emailMsgList.size()>0){
                        Messaging.sendEmail(emailMsgList);
                    }  
                }            
            }
        }
        // code ends FOR Professional Services Email Alert P-003824
        
         //Udita : TICCM-321
        Boolean MethodIsActive = ExecuteMethodHelper.isActive('OnboardingAutomation');
        If(MethodIsActive){
        if(NBBOppIds.size() > 0){
           List<OnboardingAutomation__mdt> onbAutomtion = [SELECT MasterLabel, Exclude__c,Include__c,Product__c FROM OnboardingAutomation__mdt];
           MAP<Id, set<string>> IdVsProduct = new MAP<Id, set<string>>();
           List<Onboarding__c> onboardingInsertList = new List<Onboarding__c>();
           set<string> oppProducts = new set<string>();
           map<id,set<string>> ProductsMap = new map<id,set<string>>();
           Schema.DescribeSObjectResult objSchema = Onboarding__c.sObjectType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();
            List<Schema.Picklistentry>fld =fieldmap.get('Product__c').getDescribe().getpicklistValues();
            System.debug('fld'+fld);
            List<String> pickList = new List<String>();
            
            for(Schema.Picklistentry pl : fld)
            {
                pickList.add(pl.getValue());
            }
            System.debug('pickList'+pickList);
            
           for(OpportunityLineItem opp: [select id,OpportunityId,Product_Name__c,ProductCode,Opportunity.AccountID,Product2.Name from OpportunityLineItem where ((ProductCode ='LA-SW-SEC-LTR-TS' OR ProductCode ='LA-PS-SEC-LTR-PMF' OR ProductCode ='LA-SW-SEC-LTR-LTP') OR (Product2.Name like '%Transient Sourcing%' OR Product2.Name like '%Marketplace Intelligence%' OR Product2.Name like '%Hotel Directory%' OR Product2.Name like '%Reverse Auction%' OR Product2.Name like '%Rate Audit%' OR  Product2.Name like '%Rate Availability%' OR Product2.Name like '%Rate Parity%' OR Product2.Name like '%Reverse Audit%' OR Product2.Name like '%Hotel Content%' OR Product2.Name like '%Hotel Content%')) AND OpportunityId IN :NBBOppIds.keyset()]){
              if(opp.ProductCode =='LA-SW-SEC-LTR-TS' || opp.ProductCode =='LA-PS-SEC-LTR-PMF' || opp.ProductCode =='LA-SW-SEC-LTR-LTP'){                           
                if(!IdVsProduct.containsKey(opp.OpportunityId)){
                   IdVsProduct.put(opp.OpportunityId,new set<string>());
                }
                IdVsProduct.get(opp.OpportunityId).add(opp.ProductCode);
              }
              for(string st : pickList){
                if(opp.Product2.Name.contains(st))
                   oppProducts.add(st) ;     
                if(opp.Product2.Name == 'Hotel Content Subscription - Package A'){
                   oppProducts.add('Hotel Content Package A') ; 
                }   
                if( opp.Product2.Name == 'Hotel Content Subscription - Package B')   
                   oppProducts.add('Hotel Content Package B') ;           
              }
               ProductsMap.put(opp.OpportunityId,oppProducts);
           }
            
           for(Id oppId : IdVsProduct.keyset()){
               Boolean createOnboarding;
               set<string> OppProductCodes = IdVsProduct.get(oppId);
               for(OnboardingAutomation__mdt onb : onbAutomtion){
                if(OppProductCodes.contains(onb.Include__c) && !OppProductCodes.contains(onb.Exclude__c)){
                    createOnboarding = True;
                }
               }
               if(createOnboarding == true){
                    Onboarding__c onbRec = new Onboarding__c();
                    onbRec.Opportunity_Name__c = oppId;
                    onbRec.RecordtypeId =  Schema.SObjectType.Onboarding__c.getRecordTypeInfosByDeveloperName().get('BT_Demand_Form').getRecordTypeId();
                    onbRec.Account_Name__c = NBBOppIds.get(oppId).AccountId;
                    onbRec.Product__c =String.join(new List<String>(ProductsMap.get(oppId)), ';');// ProductsMap.get(oppId);
                    onbRec.Status__c = 'Open';
                    onboardingInsertList.add(onbRec);
              }
           }
           if(onboardingInsertList.size() > 0){
               insert onboardingInsertList;
           }
         }
        }  
        // In Test, these methods can only be called by OpportunityTrgHelperCls_Version_2__Test
        if(!isComingfromTestHandler1){
            //Added by Shanu
            CreateTMMob(newMapValues);
            updateBCValues(oldMapValues,newMapValues);
            
            // below method call is replaced by new method handleContractedOpportunities (new method called onBeforeUpdate)
            // ResetRenewalAmend(newMapValues,oldMapValues);
            //Chater post on Closed Won- Added on 9 Nov 2017
            if(Label.OppAlertEnable=='True'){
                OpportunityChatterAlerts(newMapValues,oldMapValues);
            }
            
            //Update Owner from Opportunity to Child/Parent Contracts and all Quotes
            syncOwner(newMapValues.values(),oldMapValues); 
            
            //Added by Hemant : 12/01/2017 : To change the OpportunitySplitOwner when the Owner Id of opportunity is changed after the Opportunity is Closed/Won
            ChangeOppSplitOwner(newMapValues,oldMapValues); 
            
            // new code for reassignment updated 4/17 by aaron rodriguez
            
            CventMyd_ReassignmentHandler.handleReassignment();
            
            //Added by Hemant : 01/08/2018 : If contract team is removing AM owner name from opportunity, we want an email alert should out to that rep whose name we are removing.
            if(Label.AMAlertEnable == 'True')
                SendAMAlert(newMapValues,oldMapValues);
            
            //Added by Shanu : 01/10/2018 : Create RFP Case when Opportunity is Closed Lost and Account's CSN Listing Type is Basic
            CreateRFPCaseOnClosedLost(newMapValues.values(),oldMapValues);
            System.debug('Ashna**** Called');
            
            //Added on - 03/06/2018 - Rollup to Web Design support
            WebDesignSupportRollup(newMapValues.values(),oldMapValues,true,false);
            
        }
         /*30/11/2018:Call method for updating PayGo opportunity address with Login Account details on Closed Won...*/
        if(UserInfo.getUserId() == Label.InformaticaUserId && Boolean.ValueOf(Label.IsPayGoActive))
        PayGoHelperClass.updatePayGoIdAddress(newMapValues,oldMapValues);
        
        //Calling below methods  [Trigger merge activity] : Kumud
        onAfterUpdateTaskBillingUpdate(newMapValues.values(),newMapValues,oldMapValues);
        successExperienceProductRollup(newMapValues.values(),newMapValues,oldMapValues);
    }
    
    
    //Method for After Delete Event
    public static void OnAfterDelete(List<Opportunity> oldValues, Map<Id,Opportunity> oldMap){ 
        //Added on - 03/06/2018 - Rollup to Web Design support
        WebDesignSupportRollup(oldValues,oldMap,false,true);
    }
    
    //Creating TM onboarding records when opportunities are closed won 
    //Updating the Name field of TM onboarding with Opp name ..
    //TM Onboarding name should be Acc name 
    //Starts with NBB
    public static void CreateTMMob(Map<Id,Opportunity> newMapValues){
        
        
        List<TM_Buildout__c> TMToInsert = new List<TM_Buildout__c>  (); 
        Set<Id> oppIds = new Set<Id>();
        
        for (Opportunity o : newMapValues.values()){
            if((o.StageName == 'Closed Won' && o.Product__c == 'TicketMob' && o.NBB_Renewal__c.startswith('NBB') && o.Parent_Upsell__c == 'Primary' && o.MYD_Deal__c == 'First Year') && o.TM_Buildout__r.size() == 0 ){
                oppIds.add(o.Id);
            }        
        }
        
        if(oppIds.size()>0){
            
            for (Opportunity o : [Select Id, AccountId, MYD_Deal__c, NBB_Renewal__c,Parent_Upsell__c, Account.Name, StageName, Account_Name_TM__c, Product__c,New_Type__c,(Select id from TM_Buildout__r) from Opportunity where id in: oppIds]){  //TM_ID__c
                
                
                if(HelperClassforCreateTMOB.firstRun){              
                    TM_Buildout__c tm = new TM_Buildout__c ();                     
                    tm.Opportunity__c = o.Id ; 
                    tm.Name=o.Account_Name_TM__c;
                   //tm.OwnerId=o.TM_Id__c;
                    tm.Account__c=o.AccountId;
                    TMToInsert.add(tm);
                    HelperClassforCreateTMOB.firstRun=false;
                }
                
            }
            
            try {
                insert TMToInsert; 
            }catch (system.Dmlexception e) {
                system.debug (e);
            }
        }
    }
    
    
    /*
**  Added on 1 Jan 2018 - Shanu Aggarwal
**  Obsolete Method- RollUpHelper method converted into WebDesignSupportRollup method
**  Once Opportunity is Closed Won , the Web Design Support should be calculated/roll-up on Contact level. 
**/
    public static void WebDesignSupportRollup(List<Opportunity> newList, Map<Id,Opportunity> oldMapValues, boolean isAfter,boolean isDeleted){
        
        testBoolean = true;
        Opportunity oldOpp;
        Set<ID> conIds = new Set<ID>();
        Set<ID> aggConIds = new Set<ID>();
        Set<ID> aggConIds2 = new Set<ID>();
        Set<Id> oppsToReset= new Set<Id>();
        
        Map<Id,Decimal> conIdVsDesignSupport = new Map<Id,Decimal> ();
        Map<Id,Decimal> conIdVsDedicatedEnterpriseSupport = new Map<Id,Decimal> ();
        Map<Id,Decimal> conIdVsAttendeeSupport = new Map<Id,Decimal> ();
        Map<Id,Contact> conUpdateMap = new Map<Id,Contact>();
        
        //Check if opportunity is closed won-
        for(Opportunity idForOppNew : newList ){
            
            
            oldOpp=oldMapValues.get(idForOppNew.Id);
            //If Opportunity is deleted or Support Min changed
            if(isDeleted==true || (isAfter==true && (idForOppNew.StageName == 'Closed Won' || idForOppNew.StageName == 'Follow-up – Missing/Erroneous Contract' || idForOppNew.StageName == 'Pushed – Missing/Erroneous Contract'|| idForOppNew.StageName == 'Closed Won - AR Settlement' || idForOppNew.StageName == 'Closed Won – Legal Opt Out' || idForOppNew.StageName == 'Closed Won – Do Not Send to EBS' || idForOppNew.StageName == 'Closed Won - PreAcquisition' ))){ //idForOppNew.Web_Design_Support_Minutes_Purchased__c!=oldOpp.Web_Design_Support_Minutes_Purchased__c  commeted by kd
                aggConIds.add(idForOppNew.Contact_Associated__c);
            }
            else if(isDeleted==true || (isAfter==true && idForOppNew.Dedicated_Ent_Support_Minutes_Purchased__c!=oldOpp.Dedicated_Ent_Support_Minutes_Purchased__c && (idForOppNew.StageName == 'Closed Won' || idForOppNew.StageName == 'Follow-up – Missing/Erroneous Contract' || idForOppNew.StageName == 'Pushed – Missing/Erroneous Contract'|| idForOppNew.StageName == 'Closed Won - AR Settlement' || idForOppNew.StageName == 'Closed Won – Legal Opt Out' || idForOppNew.StageName == 'Closed Won – Do Not Send to EBS' || idForOppNew.StageName == 'Closed Won - PreAcquisition' ))){
                aggConIds2.add(idForOppNew.Contact_Associated__c);
            }
            else if(isAfter==false && idForOppNew.Contact_Associated__c !=null && (oldOpp.StageName != 'Closed Won' && oldOpp.StageName != 'Follow-up – Missing/Erroneous Contract' && oldOpp.StageName != 'Pushed – Missing/Erroneous Contract' && oldOpp.StageName != 'Closed Won - AR Settlement' && oldOpp.StageName != 'Closed Won – Legal Opt Out' && oldOpp.StageName != 'Closed Won – Do Not Send to EBS' && oldOpp.StageName != 'Closed Won - PreAcquisition') && (idForOppNew.StageName == 'Closed Won' || idForOppNew.StageName == 'Follow-up – Missing/Erroneous Contract' || idForOppNew.StageName == 'Pushed – Missing/Erroneous Contract'|| idForOppNew.StageName == 'Closed Won - AR Settlement' || idForOppNew.StageName == 'Closed Won – Legal Opt Out' || idForOppNew.StageName == 'Closed Won – Do Not Send to EBS' || idForOppNew.StageName == 'Closed Won - PreAcquisition' )){
                conIds.add(idForOppNew.Contact_Associated__c);
            }else if (isAfter==false  && idForOppNew.Contact_Associated__c !=null && (oldOpp.StageName == 'Closed Won' || oldOpp.StageName == 'Follow-up – Missing/Erroneous Contract' || oldOpp.StageName == 'Pushed – Missing/Erroneous Contract' || oldOpp.StageName == 'Closed Won - AR Settlement'|| oldOpp.StageName == 'Closed Won – Legal Opt Out' || oldOpp.StageName == 'Closed Won – Do Not Send to EBS' || oldOpp.StageName == 'Closed Won - PreAcquisition' ) && ( idForOppNew.StageName != 'Closed Won' && idForOppNew.StageName != 'Follow-up – Missing/Erroneous Contract' && idForOppNew.StageName != 'Pushed – Missing/Erroneous Contract' && idForOppNew.StageName != 'Closed Won - AR Settlement' && idForOppNew.StageName != 'Closed Won – Legal Opt Out' && idForOppNew.StageName != 'Closed Won – Do Not Send to EBS' && idForOppNew.StageName != 'Closed Won - PreAcquisition' )){
                conIds.add(idForOppNew.Contact_Associated__c);
                oppsToReset.add(idForOppNew.Id);
            }
        }
        
        //If Support Min Changed, Rollup to Contact
        if(aggConIds.size()>0){
            for(AggregateResult ar : [Select Contact_Associated__c  from Opportunity Where Contact_Associated__c IN:aggConIds  Group BY Contact_Associated__c ]){ // SUM(Web_Design_Support_Minutes_Purchased__c)total commeted by kd
                //conIdVsDesignSupport.put((Id)ar.get('Contact_Associated__c'), (Decimal)ar.get('total'));
                aggConIds.remove((Id)ar.get('Contact_Associated__c'));
            }
            
            //remaining contact records which doesn't  have opp, reset to 0
            if(aggConIds.size()>0){
                for(Id conId : aggConIds){
                    conIdVsDesignSupport.put(conId, 0);
                }
            }
        }
        
        //If Dedicated Enterprise Min Changed, Rollup to Contact - Added By Mohsin
        if(aggConIds2.size()>0 && Label.isDedicatedEntSupport == 'TRUE'){
            for(AggregateResult ar : [Select SUM(Dedicated_Ent_Support_Minutes_Purchased__c)total, Contact_Associated__c  from Opportunity Where Contact_Associated__c IN:aggConIds2  Group BY Contact_Associated__c ]){
                conIdVsDedicatedEnterpriseSupport.put((Id)ar.get('Contact_Associated__c'), (Decimal)ar.get('total'));
                aggConIds2.remove((Id)ar.get('Contact_Associated__c'));
            }
            
            //remaining contact records which doesn't  have opp, reset to 0
            if(aggConIds2.size()>0 && Label.isDedicatedEntSupport == 'TRUE'){
                for(Id conId : aggConIds2){
                    conIdVsDedicatedEnterpriseSupport.put(conId, 0);
                }
            }
        }
        
        //If closed won, calculate rollup
        else if(conIds.size()>0){
            
            Decimal Qty=0;
            for(OpportunityLineItem oli : [ Select Product2.Name,OpportunityId, Opportunity.Contact_Associated__c, Quantity,Product2.ProductCode From OpportunityLineItem Where ((Product2.Name=: Label.OpportunityProductname OR Product2.ProductCode=: Label.OpportunityProductCode) OR (Product2.Name= 'CVENT Attendee Support') OR (Product2.Name=: Label.OppProductname OR Product2.ProductCode=: Label.OppProductCode)) and Opportunity.Contact_Associated__c IN:conIds and (Opportunity.StageName='Closed Won' OR Opportunity.StageName='Follow-up – Missing/Erroneous Contract' OR Opportunity.StageName='Pushed – Missing/Erroneous Contract' OR Opportunity.StageName='Closed Won – Do Not Send to EBS' OR Opportunity.StageName='Closed Won - AR Settlement' OR Opportunity.StageName='Closed Won – Legal Opt Out' OR Opportunity.StageName='Closed Won - PreAcquisition'  OR OpportunityId IN:newList)]){
                
                Qty=oli.Quantity;
                System.debug('Product Code is: '+oli.Product2.ProductCode);
                System.debug('Product Name is: '+oli.Product2.Name);
                System.debug('Product Code is: '+oli.Product2.ProductCode.equalsIgnoreCase(Label.OppProductCode));
                //reset value to 0 if opp is not closed won-
                if(oppsToReset.contains(oli.OpportunityId)){
                    Qty=0;
                }
                
                //Web Design Support Roll up
                if(oli.Product2.Name== Label.OpportunityProductname || oli.Product2.ProductCode== Label.OpportunityProductCode){
                    
                    //populate the web design support on Opportunity 
                    if(!trigger.newMap.isEmpty())
                        
                        //     if(trigger.newMap.containsKey(oli.OpportunityId))
                        //trigger.newMap.get(oli.OpportunityId).put('Web_Design_Support_Minutes_Purchased__c',Qty==null?0:Qty);
                    
                    if(!conIdVsDesignSupport.containsKey(oli.Opportunity.Contact_Associated__c)){
                        conIdVsDesignSupport.put(oli.Opportunity.Contact_Associated__c,Qty);
                    }else{
                        conIdVsDesignSupport.put(oli.Opportunity.Contact_Associated__c,conIdVsDesignSupport.get(oli.Opportunity.Contact_Associated__c)+Qty);
                    }
                    
                }// Attendee Support Roll up
                else if(oli.Product2.Name == 'CVENT Attendee Support'){
                    
                    //populate the attendee support on Opportunity 
                    if(trigger.newMap.containsKey(oli.OpportunityId))
                        trigger.newMap.get(oli.OpportunityId).put('Attendee_Support_Units_Purchased__c',Qty==null?0:Qty);
                    
                    if(!conIdVsAttendeeSupport.containsKey(oli.Opportunity.Contact_Associated__c)){
                        conIdVsAttendeeSupport.put(oli.Opportunity.Contact_Associated__c,Qty);
                    }else{
                        conIdVsAttendeeSupport.put(oli.Opportunity.Contact_Associated__c,conIdVsAttendeeSupport.get(oli.Opportunity.Contact_Associated__c)+Qty);
                    }
                    
                }// Dedicated Enterprise Reactive Support Person Roll up
                else if((oli.Product2.Name == Label.OppProductname || oli.Product2.ProductCode == Label.OppProductCode) && Label.isDedicatedEntSupport == 'TRUE')
                {
                    System.debug('Opp Inside Found Product Code');
                    //populate the Dedicated Enterprise Reactive Support Person on Opportunity 
                    if(trigger.newMap.containsKey(oli.OpportunityId))
                        trigger.newMap.get(oli.OpportunityId).put('Dedicated_Ent_Support_Minutes_Purchased__c',Qty==null?0:Qty);
                    
                    if(!conIdVsDedicatedEnterpriseSupport.containsKey(oli.Opportunity.Contact_Associated__c)){
                        conIdVsDedicatedEnterpriseSupport.put(oli.Opportunity.Contact_Associated__c,Qty);
                    }else{
                        conIdVsDedicatedEnterpriseSupport.put(oli.Opportunity.Contact_Associated__c,conIdVsDedicatedEnterpriseSupport.get(oli.Opportunity.Contact_Associated__c)+Qty);
                    }
                }
                
            }
            
            //Roll up on Contact Attendee Support
            if(!conIdVsAttendeeSupport.isEmpty()){
                for(Id contactId: conIdVsAttendeeSupport.keySet()){
                    Contact con = new Contact(Id=contactId,Attendee_Support_Units_Purchased__c=conIdVsAttendeeSupport.get(contactId));
                    conUpdateMap.put(con.Id,con);
                }   
            }
            
        }
        
        //Roll up on Contact Web Design Support
        if(!conIdVsDesignSupport.isEmpty()){
            for(Id contactId: conIdVsDesignSupport.keySet()){
                Contact con = new Contact(Id=contactId,Total_Design_Support_Purchased__c=conIdVsDesignSupport.get(contactId));
                conUpdateMap.put(con.Id,con);
            }   
        }
        
        //Roll up on Contact Dedicated Ent Support Minutes Purchased
        if(!conIdVsDedicatedEnterpriseSupport.isEmpty()){
            for(Id contactId: conIdVsDedicatedEnterpriseSupport.keySet()){
                Contact con = new Contact(Id=contactId,Dedicated_Ent_Support_Minutes_Purchased__c=conIdVsDedicatedEnterpriseSupport.get(contactId));
                conUpdateMap.put(con.Id,con);
            }   
        }
        if(!conUpdateMap.isEmpty()){update conUpdateMap.values();}
        
    }
    
    
    /*
**
**  CPQ - Opportunity Fields Mapping when MYD's created through CPQ
**/
    public static void MapMYDFieldsFromCPQ( List<Opportunity> newList, Map<Id,Opportunity> oldMapValues){
        
        
        //OpportunityId vs Primary Quote Id
        Set<Id> QuoteIdSet = new Set<Id>();
        //OpportunityId vs Renewed Contract Id
        Set<Id> RenewedIdSet = new Set<Id>();
        //OpportunityId vs Parent Agreement Id
        Set<Id> AgreementIdSet = new Set<Id>();
        String closeDateMMYY='';
        
        //Contains records from assoicated Opportunity
        Map<Id,SBQQ__Quote__c> primaryQuoteMap;
        Map<Id,Contract> agreementContractsMap;
        
        //List of Opportunity to update 
        List<Opportunity> oppTpUpdateList = new List<Opportunity>();
        
        Map<integer,String> monthMap =new Map<integer,String> {1 => 'January',2 => 'February',3 => 'March',4 => 'April',5 => 'May',6 => 'June',7 => 'July',8 => 'August',9 => 'September',10 => 'October',11 => 'November',12 => 'December'};
        Date startDateEBS;    
            
            
            
            //Filter Opportunities if Primary Quote or Renewed Contract is changed
            for(Opportunity newOpp : newList){
                
                /** 
** ****  START FIRST YEAR MAPPING *****
** Added on 05/24/2018 - P-003576 Automate the fields for first year opportunity
** 
**/
                //Added on 05/24/2018 - P-003956 Automate the fields for first year opportunity :Added by Udita 
                if(newOpp.Deal_Year__c == '1'){
                    
                    //Opportunity Start Date EBS
                    
                    //Deal Closed By
                    newOpp.Deal_Closed_by__c = newOpp.OwnerId;
                    if(oldMapValues==null || ((!oldMapValues.isEmpty() && newOpp.Contract_Implemented__c !=oldMapValues.get(newOpp.Id).Contract_Implemented__c && newOpp.Contract_Implemented__c ==true))){
                        Id CSNSupplierRecId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CSN-Supplier').getRecordTypeId();
                        if(newOpp.Parent_Upsell__c=='Primary' && newOpp.NBB_Renewal__c=='NBB'/* && newOpp.RecordTypeId != CSNSupplierRecId*/){   /// code for Event cloud :(Recordtype if not CSN Supplier)
                            if(newOpp.Opportunity_Start_Date__c > newOpp.ContractReceived__c){
                                startDateEBS= newOpp.Opportunity_Start_Date__c;
                            }else{
                                startDateEBS= newOpp.ContractReceived__c;
                            }
                            if(newOpp.Contract_Implemented_Date__c>startDateEBS){
                                startDateEBS= newOpp.Contract_Implemented_Date__c;
                            }
                            
                            newOpp.Opportunity_Start_Date_EBS__c= startDateEBS;                   
                        }
                       /* else if(newOpp.Parent_Upsell__c=='Primary' && newOpp.NBB_Renewal__c=='NBB' && newOpp.RecordTypeId == CSNSupplierRecId){  // code for hospitality cloud (for CSN SUPPLIER)
                            if(newOpp.Opportunity_Start_Date__c > newOpp.ContractReceived__c){
                                startDateEBS= newOpp.Opportunity_Start_Date__c;
                            }else{
                                startDateEBS= newOpp.ContractReceived__c;
                            }                      
                            newOpp.Opportunity_Start_Date_EBS__c= startDateEBS;
                            
                        }*/ // Commented by Udita  - P-005113
                    } 
                    
                    //Early Contract if contract is received 90 days earlier than start date 
                    if(oldMapValues==null || ((!oldMapValues.isEmpty() && newOpp.StageName!=oldMapValues.get(newOpp.Id).StageName && newOpp.StageName=='Closed Won'))){ 
                        if(newOpp.ContractStartDate__c!=null && newOpp.ContractReceived__c < newOpp.ContractStartDate__c.addDays(-90)){
                            newOpp.Early_Contract__c = 'Early';
                        }else{
                            newOpp.Early_Contract__c = 'Not Early';
                        }
                    }               
                }
                if(((newOpp.Deal_Year__c != '1' && newOpp.Opportunity_Type__c == 'MYD' ) || (newOpp.Contract_Type_2_0__c == 'Cancellations' || newOpp.Contract_Type_2_0__c == 'Renegotiated - Negative Impact' || newOpp.Contract_Type_2_0__c == 'Renegotiated - Positive Impact') || (newOpp.Opportunity_Type__c == 'Renewal')) && (oldMapValues==null || ((!oldMapValues.isEmpty() && newOpp.Contract_Implemented__c !=oldMapValues.get(newOpp.Id).Contract_Implemented__c && newOpp.Contract_Implemented__c ==true)))){
                    newOpp.Opportunity_Start_Date_EBS__c= newOpp.Opportunity_Start_Date__c;               
                } 
                  if((oldMapValues==null || (!oldMapValues.isEmpty() && newOpp.Contract_Implemented__c !=oldMapValues.get(newOpp.Id).Contract_Implemented__c && newOpp.Contract_Implemented__c == true)) && newOpp.Parent_Upsell__c=='One-Off' && newOpp.Opportunity_Start_Date__c != NULL && newOpp.ContractReceived__c != NULL){                    
                    if(newOpp.Opportunity_Start_Date__c.year() == newOpp.ContractReceived__c.year() && newOpp.Opportunity_Start_Date__c.month() < newOpp.ContractReceived__c.month()){
                       startDateEBS= newOpp.Opportunity_Start_Date__c;
                    }else{
                       startDateEBS= newOpp.Opportunity_Start_Date__c;
                    }
                   
                    if(newOpp.Opportunity_Start_Date__c.year() ==  newOpp.ContractReceived__c.year() && newOpp.Opportunity_Start_Date__c.month() == newOpp.ContractReceived__c.month()){
                       if(newOpp.Opportunity_Start_Date__c.day() > newOpp.ContractReceived__c.day()){
                          startDateEBS= newOpp.Opportunity_Start_Date__c; 
                       }else{
                          startDateEBS= newOpp.ContractReceived__c;
                       }
                    }
                    newOpp.Opportunity_Start_Date_EBS__c= startDateEBS; 
                }               
                if((newOpp.Parent_Upsell__c=='Upsell' || newOpp.Parent_Upsell__c=='Extension') && (newOpp.Contract_Type_2_0__c != 'Cancellations' && newOpp.Contract_Type_2_0__c != 'Renegotiated - Negative Impact' && newOpp.Contract_Type_2_0__c != 'Renegotiated - Positive Impact') && (oldMapValues==null || ((!oldMapValues.isEmpty() && newOpp.Contract_Implemented__c !=oldMapValues.get(newOpp.Id).Contract_Implemented__c && newOpp.Contract_Implemented__c ==true)))){                    
                    if(newOpp.Opportunity_Start_Date__c > newOpp.ContractReceived__c){
                        startDateEBS= newOpp.Opportunity_Start_Date__c;
                    }else{
                        startDateEBS= newOpp.ContractReceived__c;
                    }                      
                    newOpp.Opportunity_Start_Date_EBS__c= startDateEBS;                    
                 }
                //Deal Closed By - Update from OwnerId
                if(oldMapValues==null || (!oldMapValues.isEmpty() && newOpp.StageName!=oldMapValues.get(newOpp.Id).StageName && newOpp.StageName.startswith('Closed'))){
                    
                    //Deal Closed By - Update from OwnerId
                    if(newOpp.Deal_Year__c == '1')
                        newOpp.Deal_Closed_by__c = newOpp.OwnerId;
                    
                    //Case Received Date
                    if(newOpp.StageName=='Closed Won')
                        newOpp.Case_Received_Date__c = system.today();
                }
                
                /** 
** ****  END FIRST YEAR MAPPING*****
**/
                
                
                
                /** 
** ****  START MYD MAPPING *****
**/
                
                //Update Logic
                if( trigger.isUpdate){         //!newOpp.Bypass_Historic_Opp__c &&
                    Opportunity oldOpp = oldMapValues.get(newOpp.Id);
                    if(newOpp.SBQQ__PrimaryQuote__c!=null)
                        QuoteIdSet.add(newOpp.SBQQ__PrimaryQuote__c);
                    if(newOpp.SBQQ__RenewedContract__c!=null && newOpp.SBQQ__RenewedContract__c!=oldOpp.SBQQ__RenewedContract__c )
                        RenewedIdSet.add(newOpp.SBQQ__RenewedContract__c);
                    if(newOpp.Master_Agreement__c!=null && newOpp.Master_Agreement__c!=oldOpp.Master_Agreement__c )
                        AgreementIdSet.add(newOpp.Master_Agreement__c);
                }
                //Insert Logic 
                else if( trigger.isInsert){    //!newOpp.Bypass_Historic_Opp__c &&
                    if(newOpp.SBQQ__PrimaryQuote__c!=null)
                        QuoteIdSet.add(newOpp.SBQQ__PrimaryQuote__c);
                    if(newOpp.SBQQ__RenewedContract__c!=null)
                        RenewedIdSet.add(newOpp.SBQQ__RenewedContract__c);
                    if(newOpp.Master_Agreement__c!=null)
                        AgreementIdSet.add(newOpp.Master_Agreement__c);
                }
            }
        
        /**
***
*** Primary Quote
*** 
***/
        
        if(!QuoteIdSet.isEmpty()){
            
            
            
            //Payment Terms Mapping : Udita for EBS Related SFDC field automation
            Map<String,String> mappingPaymentTerm = new Map<String,String>();
            //For custom payment terms
            Map<String,String> mappingCustomPaymentTerm = new Map<String,String>();
            // Billing Frequency + Payment Method + Custom Payment Term 
            //by invoice
            mappingPaymentTerm.put('Annual Upfront+by Invoice+null','Annual Upfront Invoice+ ');
            mappingPaymentTerm.put('Quarterly+by Invoice+null','Quarterly Invoice+ ');
            mappingPaymentTerm.put('Bi-Annual+by Invoice+null','Bi-Annual Invoice+ ');
            mappingPaymentTerm.put('All Years Upfront+by Invoice+null','All Years Upfront Invoice+ ');
            //mappingPaymentTerm.put('Custom(up to 5x/year)+by Invoice+Enter the customized Term for payment','Customize Payment by Invoice+Enter the customized Term for payment');
            
            //by credit card
            mappingPaymentTerm.put('Annual Upfront+by Credit Card+null','Annual Upfront Credit Card+ ');
            mappingPaymentTerm.put('Quarterly+by Credit Card+null','Quarterly Credit Card+ ');
            mappingPaymentTerm.put('Bi-Annual+by Credit Card+null','Bi-Annual Credit Card+ ');
            mappingPaymentTerm.put('All Years Upfront+by Credit Card+null','All Years Upfront Credit Card+ ');
            // mappingPaymentTerm.put('Custom(up to 5x/year)+by Credit Card+Enter the customized Term for payment','Customize Payment by Credit Card+Enter the customized Term for payment');
            
            //not required
            mappingPaymentTerm.put('Not Required+Not Required+null','Pay Reg Fees As You Go+ ');
            mappingPaymentTerm.put('Not Required+Not Required+Enter the customized Term for payment','Other (fill out field below)+Enter the customized Term for payment');
            
            //population custom payment term map : Udita Enhancements
            mappingCustomPaymentTerm.put('Custom(up to 5x/year)+by Invoice','Customize Payment by Invoice');
            mappingCustomPaymentTerm.put('Custom(up to 5x/year)+by Credit Card','Customize Payment by Credit Card');
            mappingCustomPaymentTerm.put('Custom (6+x/year)+by Invoice','Customize Payment by Invoice');
            mappingCustomPaymentTerm.put('Custom (6+x/year)+by Credit Card','Customize Payment by Credit Card');
            
            primaryQuoteMap = new Map<Id,SBQQ__Quote__c>([ Select Id,SBQQ__BillingFrequency__c,PO__c,Federal_Tax_ID_VAT_ID_GST_ID__c,SBQQ__Type__c,Apply_Current_Exchange_Rate__c,Quote_Currency_Rate__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Upcoming_Renewal_Type__c,SBQQ__Quote__c.SBQQ__StartDate__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Parent_Contract_Term_Years__c, Auto_renewal_clause__c,Contract_Executed_Date__c,Current_Year__c,Contract_Term_Years__c,Effective_Year_1_Start_Date__c,Effective_Year_1_End_Date__c,SBQQ__EndDate__c, SBQQ__PaymentTerms__c,Payment_Method__c,Billing_Frequency__c,Custom_Payment_Terms__c,
                                                          SBQQ__Opportunity2__r.Ship_To_Address__r.Operating_Unit_Name__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Opportunity__r.CVII_Contract_Number__c,SBQQ__Opportunity2__r.Contract_Number_New__c, SBQQ__Opportunity2__r.Parent_Upsell__c,SBQQ__Opportunity2__r.Master_Agreement__r.CVII_Contract_Number__c,SBQQ__Opportunity2__r.CVII_Contract_Number__c,SBQQ__Opportunity2__r.Master_Agreement__r.SBQQ__Opportunity__r.CVII_Contract_Number__c,
                                                          ( Select Id,Room_Nights_or_RFPs__c,SBQQ__Product__c,Number_of_RFPs__c,Room_Nights__c From SBQQ__LineItems__r Where SBQQ__Product__r.Name = 'Supplier Network - Enterprise Bundle' Limit 1 ) From SBQQ__Quote__c Where ID IN: QuoteIdSet]);
            
            //Processing Opportunities
            for( Opportunity syncedOpp : newList){
                //Get New Souce Opp
                //Opportunity syncedOpp = (Opportunity)trigger.newMap.get(syncedOppId);
                //Get Primary Quote
                SBQQ__Quote__c quote = primaryQuoteMap.get(syncedOpp.SBQQ__PrimaryQuote__c);
                
                /*Check for null pointer on Quote - PK 7/25/2017 */ 
                if(quote == null){
                    continue;
                } 
                // TICCM-639 : Udita
                if(ExecuteMethodHelper.isActive('OppFieldAutomation')){
                    system.debug('----quote'+quote);
                    system.debug('----quote.SBQQ__Opportunity2__r.Ship_To_Address__r.Operating_Unit_Name__c'+quote.SBQQ__Opportunity2__r.Ship_To_Address__r.Operating_Unit_Name__c);
                  /* if(oldMapValues==null || ((!oldMapValues.isEmpty() && syncedOpp.Contract_Implemented__c !=oldMapValues.get(syncedOpp.Id).Contract_Implemented__c && syncedOpp.Contract_Implemented__c ==true))){
                   if( quote.Billing_Frequency__c != null &&  (quote.Billing_Frequency__c =='Annual Upfront'  || quote.Billing_Frequency__c == 'Bi-Annual' || quote.Billing_Frequency__c == 'Quarterly') ){
                      syncedOpp.Billing_Schedule__c ='STANDARD';}else{syncedOpp.Billing_Schedule__c = 'CUSTOM';}    }    NO- GO    */  
                                   
                 /*  if(quote.SBQQ__Opportunity2__r.Ship_To_Address__r.Operating_Unit_Name__c != null){
                    if(quote.SBQQ__Opportunity2__r.Ship_To_Address__r.Operating_Unit_Name__c == 'CVAUS'){ syncedOpp.Deal_Booked_In__c = 'Australian Books';} if(quote.SBQQ__Opportunity2__r.Ship_To_Address__r.Operating_Unit_Name__c == 'CVCDN'){syncedOpp.Deal_Booked_In__c = 'Canada Books';}if(quote.SBQQ__Opportunity2__r.Ship_To_Address__r.Operating_Unit_Name__c == 'CVSGP'){ syncedOpp.Deal_Booked_In__c = 'Singapore Books';}if(quote.SBQQ__Opportunity2__r.Ship_To_Address__r.Operating_Unit_Name__c == 'CVUK'){ syncedOpp.Deal_Booked_In__c = 'UK Books';}if(quote.SBQQ__Opportunity2__r.Ship_To_Address__r.Operating_Unit_Name__c == 'CVINC'){syncedOpp.Deal_Booked_In__c = 'US Books';}if(quote.SBQQ__Opportunity2__r.Ship_To_Address__r.Operating_Unit_Name__c == 'CVDE'){syncedOpp.Deal_Booked_In__c = 'Germany Books';} if(quote.SBQQ__Opportunity2__r.Ship_To_Address__r.Operating_Unit_Name__c == 'CVUAE'){syncedOpp.Deal_Booked_In__c = 'UAE Books';}                                              }
                    system.debug('===syncedOpp.Deal_Booked_In__c'+syncedOpp.Deal_Booked_In__c);   NO- GO    */  
                   
                    if(quote.SBQQ__Type__c=='Amendment' && quote.SBQQ__Opportunity2__r.Master_Agreement__c != null &&  quote.SBQQ__Opportunity2__r.Master_Agreement__r.SBQQ__Opportunity__r.CVII_Contract_Number__c != null){
                       syncedOpp.Parent_Contract_Number__c = Decimal.valueOf(quote.SBQQ__Opportunity2__r.Master_Agreement__r.SBQQ__Opportunity__r.CVII_Contract_Number__c);
                    }
                    /*if(quote.SBQQ__Opportunity2__r.CVII_Contract_Number__c != null){
                       syncedOpp.Contract_Number_New__c = quote.SBQQ__Opportunity2__r.CVII_Contract_Number__c;
                    }*/
                     if(quote.SBQQ__Opportunity2__r.Contract_Number_New__c != null){
                       syncedOpp.CVII_Contract_Number__c = quote.SBQQ__Opportunity2__r.Contract_Number_New__c ;
                    }
               
                    /*if(syncedOpp.Opportunity_Start_Date_EBS__c != null && syncedOpp.Contract_Implemented_Date__c != null && syncedOpp.Opportunity_Start_Date_EBS__c.addDays(-30) > syncedOpp.Contract_Implemented_Date__c){
                       syncedOpp.Billing_Date__c  = syncedOpp.Opportunity_Start_Date_EBS__c.addDays(-30) ;}else{syncedOpp.Billing_Date__c  = syncedOpp.Contract_Implemented_Date__c;} NO -GO */
                    if(quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c != null && quote.SBQQ__Opportunity2__r.CVII_Contract_Number__c != null && (quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Upcoming_Renewal_Type__c == 'MYD Renewal' || quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Upcoming_Renewal_Type__c == 'Contract Renewal')){syncedOpp.Previous_Contract_Number__c = decimal.valueOf(quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Opportunity__r.CVII_Contract_Number__c) ;}
                    if(quote.SBQQ__Opportunity2__r.Parent_Upsell__c!= null){syncedOpp.Upsell_Category__c = quote.SBQQ__Opportunity2__r.Parent_Upsell__c == 'One-Off' ? 'Not Renewable (One-off) ' : 'Standalone';}
                 }
                syncedOpp.Applicable_Exchange_Rate__c = (quote.Apply_Current_Exchange_Rate__c || syncedOpp.Applicable_Exchange_Rate__c == null) ? quote.Quote_Currency_Rate__c : syncedOpp.Applicable_Exchange_Rate__c;
                //Map fields from Primary Quote on Opp
                //Map fields from Primary Quote on Opp
                if(quote.Auto_renewal_clause__c ==true){syncedOpp.ARClause__c   = 'Yes';}else{syncedOpp.ARClause__c   = 'No';}
                
                /*if(String.valueOf(quote.Current_Year__c) <> '1')
syncedOpp.MYD_Deal__c = 'MYD';
*/
                syncedOpp.Deal_Year__c  = String.valueOf(quote.Current_Year__c);
                syncedOpp.Years__c      = quote.Contract_Term_Years__c;
                // syncedOpp.Opportunity_Start_Date_EBS__c = quote.Effective_Year_1_Start_Date__c;
                // syncedOpp.Opp_End_Date__c      = quote.Effective_Year_1_End_Date__c; Changes made by lovejeet as Effective_Year_1_End_Date__c date has gone obsolete. 
                syncedOpp.Opp_End_Date__c      = quote.SBQQ__EndDate__c;
                //syncedOpp.ContractReceived__c =  quote.Contract_Executed_Date__c;                
                
                //MYD Name and Close Date
                if(quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Upcoming_Renewal_Type__c == 'MYD Renewal' && quote.SBQQ__StartDate__c!=null && quote.SBQQ__Type__c != 'Amendment'){
                    
                    //Close Date can be updated manually if this field is true- No automation needed in some cases ( Added on  12/11/2017)
                    if(syncedOpp.Is_Close_Date_Locked__c==false)
                        syncedOpp.CloseDate  =  quote.SBQQ__StartDate__c;
                    
                    syncedOpp.NBB_Renewal__c    =   'NBB';
                    syncedOpp.Name = monthMap.get(syncedOpp.closeDate.Month()) + ' ' + syncedOpp.closeDate.Year() + ' ' + 'NBB' + ' ' + syncedOpp.Deal_Year__c + ' Of ' +  quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Parent_Contract_Term_Years__c;
                    String byPassAffixUserName= Label.UserBypassQM;                    
                   
                      if(syncedOpp.Opportunity_Name_Affix__c != NULL && Boolean.valueOf(Label.AffixFunctioanlity) && UserInfo.getUserName() != Label.UserBypassQM){
                        string oppName='';
                        oppName = syncedOpp.Name +' '+ syncedOpp.Opportunity_Name_Affix__c; // added by Udita for P-004699(Update Opportunity Name)
                        if(!String.IsBlank(oppName)){
                            syncedOpp.Name= oppName.length()>120?oppName.Substring(0,120):oppName;
                        }
                      }  
                     
                }
                
                //If there are quote lines associated with this , update mentioned fields from line items 
                if(quote.SBQQ__LineItems__r!=null && quote.SBQQ__LineItems__r.size()>0){
                    /*
Commented as a result of Field Purge Activity.
if(quote.SBQQ__LineItems__r[0].Room_Nights_or_RFPs__c == 'RFPs')
syncedOpp.of_RFPs__c =  quote.SBQQ__LineItems__r[0].Number_of_RFPs__c;
else*/
                    if(quote.SBQQ__LineItems__r[0].Room_Nights_or_RFPs__c == 'Room Nights')
                        syncedOpp.of_Total_Room_Nights_Committed__c =  quote.SBQQ__LineItems__r[0].Room_Nights__c;
                }
                
                /**
** START - P-003956
** Added below fields on 05/24/2018 - Added by Shanu for Project P-003576
**/
                
                //Invoice Payment Terms
                //syncedOpp.Invoice_Payment_Terms__c = quote.SBQQ__PaymentTerms__c;
                
                //Invoice Payment Method
                if(quote.Payment_Method__c=='by Invoice')
                    syncedOpp.Invoice_Payment_Mode__c = 'Cash';
                else if(quote.Payment_Method__c=='by Credit Card')
                    syncedOpp.Invoice_Payment_Mode__c = 'Credit Card';
                else if(quote.Payment_Method__c=='Not Required')
                    syncedOpp.Invoice_Payment_Mode__c = 'Cash and Credit Card Form';
                
                
                
                //Payment Terms :Udita for EBS Fields Automation
                if(UserInfo.getUserName() != Label.UserBypassQM){
                if(Test.isRunningTest() || oldMapValues==null || ((!oldMapValues.isEmpty() && syncedOpp.StageName!=oldMapValues.get(syncedOpp.Id).StageName && syncedOpp.StageName=='Closed Won'))){
                    string termKey = quote.Billing_Frequency__c+'+'+quote.Payment_Method__c+'+'+quote.Custom_Payment_Terms__c;
                    if(mappingPaymentTerm.containsKey(termKey)){
                        syncedOpp.PaymentTerms__c = mappingPaymentTerm.get(termKey).split('\\+')[0];
                        syncedOpp.EnterOtherPaymentTerms__c  = mappingPaymentTerm.get(termKey).split('\\+')[1];
                    }else{
                        syncedOpp.PaymentTerms__c = 'All Years Upfront';
                        syncedOpp.EnterOtherPaymentTerms__c  = '';
                    }
                    
                    string customtermKey = quote.Billing_Frequency__c+'+'+quote.Payment_Method__c;
                    if(mappingCustomPaymentTerm.containsKey(customtermKey)){
                        syncedOpp.PaymentTerms__c = mappingCustomPaymentTerm.get(customtermKey).split('\\+')[0];
                        if(quote.Custom_Payment_Terms__c!= null && quote.Custom_Payment_Terms__c.length() > 255){
                            syncedOpp.EnterOtherPaymentTerms__c  = quote.Custom_Payment_Terms__c.subString(0,244);
                        }
                        else{
                            syncedOpp.EnterOtherPaymentTerms__c  = quote.Custom_Payment_Terms__c;
                        }
                    }
                }
              }
                //Primary Contract/Upsell 
                if(syncedOpp.Parent_Upsell__c==null){
                    
                    if(quote.SBQQ__Type__c=='Amendment')
                        syncedOpp.Parent_Upsell__c = 'Upsell';
                    else
                        syncedOpp.Parent_Upsell__c = 'Primary';
                }
                
                //First Year/MYD
                
                
                if(oldMapValues==null || ((!oldMapValues.isEmpty() && syncedOpp.StageName!=oldMapValues.get(syncedOpp.Id).StageName && syncedOpp.StageName=='Closed Won'))){
                    
                    
                    
                    
                    if(syncedOpp.Parent_Upsell__c=='Primary'){
                        
                        if(syncedOpp.Deal_Year__c=='1')
                            syncedOpp.MYD_Deal__c = 'First Year';
                        else
                            syncedOpp.MYD_Deal__c = 'MYD';
                    }else{
                        syncedOpp.MYD_Deal__c = 'First Year';
                        
                        
                    }
                    
                }
                
                //   }
                /**
** END
**/
            }
        }
        
        /**
***
*** Renewed Contracts and Parent Agreement
*** 
***/
        if(!RenewedIdSet.isEmpty() || !AgreementIdSet.isEmpty()){
            
            System.debug('RenewedIdSet*******' + RenewedIdSet);
            //All Renewed Contracts and Parent Agreement (Contract)
            Set<ID> contractIds = new Set<ID>();
            contractIds.addAll(RenewedIdSet);
            contractIds.addAll(AgreementIdSet);
            
            system.debug('*****contractIds'+contractIds);
            //Query Renewed Contract + Agreement fields  SBQQ__Opportunity__r.Event_City__c,SBQQ__Opportunity__r.Event_Country__c,SBQQ__Opportunity__r.Event_State__c,SBQQ__Opportunity__r.Event_Venue__c,
            agreementContractsMap = new Map<Id,Contract>([ Select Id,Parent_Contract__r.EndDate,SBQQ__Opportunity__r.Name,SBQQ__Opportunity__r.CloseDate,SBQQ__Opportunity__r.RecordTypeId,StartDate,EndDate,SBQQ__Opportunity__r.Advertising_Agency__c,SBQQ__Opportunity__r.Barter_Contract__c,SBQQ__Opportunity__r.Brand_Name__c,SBQQ__Opportunity__r.Brand_Name_Others__c,SBQQ__Opportunity__r.Cash_Paid_by_Cvent__c,
                                                          SBQQ__Opportunity__r.Chain_Deal__c,SBQQ__Opportunity__r.Chain_Name__c,SBQQ__Opportunity__r.Chain_Name_Others__c,
                                                          SBQQ__Opportunity__r.SBQQ__PrimaryQuote__r.Contract_Executed_Date__c, SBQQ__Opportunity__r.RenewalDate__c ,
                                                          SBQQ__Opportunity__r.Competitor_Used__c,SBQQ__Opportunity__r.Competitors_in_Evaluation_Process__c,SBQQ__Opportunity__r.Contact_Associated__c,
                                                          SBQQ__Opportunity__r.Contact_Role__c,SBQQ__Opportunity__r.Contract_Implemented__c,SBQQ__Opportunity__r.ContractReceived__c,SBQQ__Opportunity__r.Early_Contract__c,
                                                          SBQQ__Opportunity__r.Deal_Closed_by__c,SBQQ__Opportunity__r.EBS_Order_Date__c,
                                                          SBQQ__Opportunity__r.Event_Name__c,SBQQ__Opportunity__r.FirstPresentation__c,
                                                          SBQQ__Opportunity__r.Govt__c,SBQQ__Opportunity__r.Management_Company_Name__c,SBQQ__Opportunity__r.Marketing_Deliverables__c,
                                                          SBQQ__Opportunity__r.Marketing_Services_Provided_By_Client__c,SBQQ__Opportunity__r.Mktg_Lead_Source__c,SBQQ__Opportunity__r.MSA_Code__c,
                                                          SBQQ__Opportunity__r.Ownership_Group__c,SBQQ__Opportunity__r.Sales_Cycle__c,SBQQ__Opportunity__r.Listed_Created__c,SBQQ__Opportunity__r.Product__c,
                                                          SBQQ__Opportunity__r.Ship_To_Address__c,SBQQ__Opportunity__r.Bill_To_Address__c,SBQQ__Opportunity__r.Do_Not_Send_Invoice_OrderType_Override__c,SBQQ__Opportunity__r.Billing_Schedule__c,SBQQ__Opportunity__r.Invoice_Payment_Terms__c,SBQQ__Opportunity__r.Invoice_Payment_Mode__c,SBQQ__Opportunity__r.Ship_To_Contact__c,SBQQ__Opportunity__r.Bill_To_Contact__c,SBQQ__Opportunity__r.Offset_Days__c,SBQQ__Opportunity__r.PO__c,SBQQ__Opportunity__r.Operating_Unit_ID__c,SBQQ__Opportunity__r.Deal_Booked_In__c,SBQQ__Opportunity__r.Sold_To_Company__c,SBQQ__Opportunity__r.Header_Notes__c,SBQQ__Opportunity__r.Billing_Date__c,SBQQ__Opportunity__r.Club_Code__c,
                                                          Upcoming_Renewal_Type__c,SBQQ__Opportunity__r.NBB_Renewal__c,SBQQ__Opportunity__r.Opportunity_Name_Affix__c,SBQQ__Opportunity__r.Contract_Term_Months__c,SBQQ__Opportunity__r.Customer_Legal_Name__c,SBQQ__Opportunity__r.CVII_Contract_Number__c From Contract Where ID IN: contractIds]);
            
            //Processing Opportunities
            for( Opportunity syncedOpp : newList){
                System.debug('agreementContractsMap*******' + syncedOpp.SBQQ__RenewedContract__c);
                //Get New Souce Opp
                //Opportunity syncedOpp = (Opportunity)trigger.newMap.get(syncedOppId);
                
                //Mapping from Renewed Contract
                if(agreementContractsMap.containsKey(syncedOpp.SBQQ__RenewedContract__c) && syncedOpp.SBQQ__RenewedContract__c!=null){   
                    
                    //Get Renewed Contract
                    Contract renewedContract = agreementContractsMap.get(syncedOpp.SBQQ__RenewedContract__c);
                    system.debug('********************renewedContract.SBQQ__Opportunity__c'+renewedContract.SBQQ__Opportunity__c);
                    if(renewedContract.SBQQ__Opportunity__c!=null){
                        //Get Opportunity from Renewed Contract 
                        Opportunity syncedFromOpp = agreementContractsMap.get(syncedOpp.SBQQ__RenewedContract__c).SBQQ__Opportunity__r;
                        
                        
                        //Map fields from Renewed Contract on Opp
                        syncedOpp.Opportunity_Name_Affix__c                  =   syncedFromOpp.Opportunity_Name_Affix__c;  // added by Udita for P-004699(Update Opportunity Name)
                        syncedOpp.Customer_Legal_Name__c                     =   syncedFromOpp.Customer_Legal_Name__c;
                        syncedOpp.Advertising_Agency__c                      =   syncedFromOpp.Advertising_Agency__c;
                        syncedOpp.Barter_Contract__c                         =   syncedFromOpp.Barter_Contract__c;
                        syncedOpp.Brand_Name__c                              =   syncedFromOpp.Brand_Name__c;
                        syncedOpp.Brand_Name_Others__c                       =   syncedFromOpp.Brand_Name_Others__c;
                        //syncedOpp.Cash_Paid_by_Cvent__c                    =   syncedFromOpp.Cash_Paid_by_Cvent__c;
                        syncedOpp.Chain_Deal__c                              =   syncedFromOpp.Chain_Deal__c;
                        syncedOpp.Chain_Name__c                              =   syncedFromOpp.Chain_Name__c;
                        syncedOpp.Chain_Name_Others__c                       =   syncedFromOpp.Chain_Name_Others__c;
                        syncedOpp.Competitor_Used__c                         =   syncedFromOpp.Competitor_Used__c;
                        syncedOpp.Competitors_in_Evaluation_Process__c       =   syncedFromOpp.Competitors_in_Evaluation_Process__c;
                        syncedOpp.Contact_Associated__c                      =   syncedFromOpp.Contact_Associated__c;
                        syncedOpp.Contact_Role__c                            =   syncedFromOpp.Contact_Role__c;
                        //syncedOpp.Contract_Implemented__c                    =   syncedFromOpp.Contract_Implemented__c;
                        syncedOpp.Deal_Booked_In__c                          =   syncedFromOpp.Deal_Booked_In__c;
                        
                        
                        //Don't automate the field for first year contract
                        if(syncedOpp.Deal_Year__c != '1'){
                            syncedOpp.Deal_Closed_by__c                      =   syncedFromOpp.Deal_Closed_by__c;
                            syncedOpp.Early_Contract__c                      =   syncedFromOpp.Early_Contract__c;
                        }
                        
                        
                        //syncedOpp.Event_City__c                              =   syncedFromOpp.Event_City__c;
                        //syncedOpp.Event_Country__c                           =   syncedFromOpp.Event_Country__c;
                        syncedOpp.Event_Name__c                              =   syncedFromOpp.Event_Name__c;
                        //syncedOpp.Event_State__c                             =   syncedFromOpp.Event_State__c;
                        //syncedOpp.Event_Venue__c                             =   syncedFromOpp.Event_Venue__c;
                        syncedOpp.FirstPresentation__c                       =   syncedFromOpp.FirstPresentation__c;
                        syncedOpp.Govt__c                                    =   syncedFromOpp.Govt__c;
                        syncedOpp.Management_Company_Name__c                 =   syncedFromOpp.Management_Company_Name__c;
                        syncedOpp.Marketing_Deliverables__c                  =   syncedFromOpp.Marketing_Deliverables__c;
                        syncedOpp.Marketing_Services_Provided_By_Client__c   =   syncedFromOpp.Marketing_Services_Provided_By_Client__c;
                        syncedOpp.Mktg_Lead_Source__c                        =   syncedFromOpp.Mktg_Lead_Source__c;
                        syncedOpp.MSA_Code__c                                =   syncedFromOpp.MSA_Code__c;
                        syncedOpp.Ownership_Group__c                         =   syncedFromOpp.Ownership_Group__c;
                        //syncedOpp.Sales_Cycle__c                           =   syncedFromOpp.Sales_Cycle__c;
                        syncedOpp.Listed_Created__c                          =   syncedFromOpp.Listed_Created__c;
                        syncedOpp.Product__c                                 =   syncedFromOpp.Product__c;
                        if(syncedOpp.Ship_To_Address__c==null)
                            syncedOpp.Ship_To_Address__c                         =   syncedFromOpp.Ship_To_Address__c;
                        if(syncedOpp.Bill_To_Address__c==null)
                            syncedOpp.Bill_To_Address__c                         =   syncedFromOpp.Bill_To_Address__c;
                        syncedOpp.Do_Not_Send_Invoice_OrderType_Override__c  =   syncedFromOpp.Do_Not_Send_Invoice_OrderType_Override__c;
                        syncedOpp.Billing_Schedule__c                        =   syncedFromOpp.Billing_Schedule__c ;
                        //syncedOpp.Invoice_Payment_Terms__c                   =   syncedFromOpp.Invoice_Payment_Terms__c;
                        syncedOpp.Invoice_Payment_Mode__c                    =   syncedFromOpp.Invoice_Payment_Mode__c;
                        syncedOpp.Ship_To_Contact__c                         =   syncedFromOpp.Ship_To_Contact__c ;
                        syncedOpp.Bill_To_Contact__c                         =   syncedFromOpp.Bill_To_Contact__c;
                        syncedOpp.Offset_Days__c                             =   syncedFromOpp.Offset_Days__c ;
                        syncedOpp.PO__c                                      =   syncedFromOpp.PO__c;
                        //syncedOpp.Operating_Unit_ID__c                     =   syncedFromOpp.Operating_Unit_ID__c ;
                        syncedOpp.Sold_To_Company__c                         =   syncedFromOpp.Sold_To_Company__c;
                        syncedOpp.Header_Notes__c                            =   syncedFromOpp.Header_Notes__c;
                        syncedOpp.Billing_Date__c                            =   syncedFromOpp.Billing_Date__c ;
                        syncedOpp.Club_Code__c                               =   syncedFromOpp.Club_Code__c;
                        //syncedOpp.ContractReceived__c                        =   syncedFromOpp.ContractReceived__c;                                                    
                        syncedOpp.EBS_Order_Date__c                          =   syncedFromOpp.EBS_Order_Date__c;
                        
                        /**
** Fields to be mapped differently based on MYD and Renewal contract
**/
                        //MYD Contract Mapping
                        if(renewedContract.Upcoming_Renewal_Type__c == 'MYD Renewal'){
                            syncedOpp.RecordTypeId      =    syncedFromOpp.RecordTypeId;
                            syncedOpp.StageName         =   'MYD Created';
                            
                            //Added on 03/29/2018 - P# P-003555
                            syncedOpp.CVII_Contract_Number__c = syncedFromOpp.CVII_Contract_Number__c;
                            
                            
                            //Added after CPQ Go Live- 7/10/2017
                            if(renewedContract.EndDate!=null)
                                syncedOpp.Auto_Close_Date__c = renewedContract.EndDate - 30;
                        }
                        //Renewal Contract Mapping
                        else if(renewedContract.Upcoming_Renewal_Type__c == 'Contract Renewal'){
                            syncedOpp.NBB_Renewal__c      =   'Renewal';
                            //StageName and ClosedDate
                            if(trigger.isInsert){
                                syncedOpp.StageName       =   'Up for Renewal';
                            }
                            
                            //Added on 03/29/2018 - P# P-003555
                            if(syncedFromOpp.CVII_Contract_Number__c!=null)
                                syncedOpp.Previous_Contract_Number__c = Decimal.ValueOf(syncedFromOpp.CVII_Contract_Number__c);
                            
                            //Set Record Type
                            Id renewalTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                            syncedOpp.RecordTypeId =  renewalTypeId;
                            //Renewal Opp Name and Close Date
                            if(renewedContract.Parent_Contract__c!=null && renewedContract.Parent_Contract__r.EndDate!=null){
                                //Renewal Opp Closed Date
                                syncedOpp.CloseDate   =  renewedContract.Parent_Contract__r.EndDate;
                                system.debug('Afix******'+syncedOpp.Opportunity_Name_Affix__c);
                                //syncedOpp.CloseDate   =  (System.today().daysBetween(renewedContract.Parent_Contract__r.EndDate)>=0?renewedContract.Parent_Contract__r.EndDate:system.today());
                                if(syncedOpp.RenewalDate__c == null)
                                    syncedOpp.RenewalDate__c =  renewedContract.Parent_Contract__r.EndDate;
                                syncedOpp.Name =  monthMap.get(syncedOpp.closeDate.Month()) + ' ' + syncedOpp.closeDate.Year() + ' Renewal Opportunity';
                                String byPassAffixUserName= Label.UserBypassQM;                    
                              
                                 if(syncedOpp.Opportunity_Name_Affix__c!= NULL && Boolean.valueOf(Label.AffixFunctioanlity) && UserInfo.getUserName() != Label.UserBypassQM){
                                    string oppName='';
                                    oppName = syncedOpp.Name +' '+ syncedOpp.Opportunity_Name_Affix__c; // added by Udita for P-004699(Update Opportunity Name)
                                     if(!String.IsBlank(oppName)){
                                        syncedOpp.Name= oppName.length()>120?oppName.Substring(0,120):oppName;
                                     } 
                                 }
                                 
                            }
                            
                        }   
                        
                    }
                    
                }
                
                //Mapping from Parent Agreement
                if(agreementContractsMap.containsKey(syncedOpp.Master_Agreement__c) && syncedOpp.Master_Agreement__c!=null){
                    system.debug('-----agreementContractsMap.containsKey(syncedOpp.Master_Agreement__c)'+agreementContractsMap.containsKey(syncedOpp.Master_Agreement__c));
                    //Get Parent Agreement
                    Contract masterAgreement = agreementContractsMap.get(syncedOpp.Master_Agreement__c);
                    syncedOpp.ContractStartDate__c = masterAgreement.StartDate;
                    syncedOpp.ContractReceived__c  =   masterAgreement.SBQQ__Opportunity__r.ContractReceived__c;
                    syncedOpp.ContractEndDate__c = masterAgreement.EndDate;
                    
                    //Early Contract if contract is received 90 days earlier than start date : added by udita because contract start was null previously
                    if(oldMapValues==null || ((!oldMapValues.isEmpty() && syncedOpp.ContractStartDate__c!=null && syncedOpp.StageName=='Closed Won'))){ 
                        if(masterAgreement.StartDate !=null && syncedOpp.ContractReceived__c < masterAgreement.StartDate.addDays(-90)){
                            syncedOpp.Early_Contract__c = 'Early';
                        }else{
                            syncedOpp.Early_Contract__c = 'Not Early';
                        }
                    }  
                }
                
            }
            
        }   
        
    }
    
    /**
** P-001384
** On Update Only
** Post Chatter when Opportunity is closed won with any of the Products associated stored in custom setting OpportunityAlert
** Added by Shanu on 09 Nov 2017
**/
    /** Enhancements added by udita for project P-003953 : Opportunity Alert Creation - HC Bundle Product(s) have reached Verbal Stage**/
    public static boolean isTest=false;
    public static void OpportunityChatterAlerts(Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMapValues){
        //Get Custom Setting data
        Set<Id> oppIds = new Set<Id>();
        Set<Id> primaryQuoteIds = new Set<Id>();
        List<Messaging.SingleEmailMessage> emailMsgList = new List<Messaging.SingleEmailMessage>(); 
        //Opportunity is Closed Won
        for(Opportunity opp : newMap.values()){     
            
            system.debug('===========oldMapValues.get(opp.id).StageName'+oldMapValues.get(opp.id).StageName);
            system.debug('===========oldMapValues.get(opp.id).StageName'+opp.StageName);
            if(isTest || (oldMapValues.containsKey(opp.id) && oldMapValues.get(opp.id).StageName!=opp.StageName && ( opp.StageName=='Closed Won' || opp.StageName=='Closed Won – Do Not Send to EBS' || opp.StageName=='Verbal'))){  //Udita : adding all the stages for which chatter alert would fire
                oppIds.add(opp.Id);
                primaryQuoteIds.add(opp.SBQQ__PrimaryQuote__c);
            }
        }
        
        //Process Closed Won Opps
        if(oppIds.size()>0){
            Id CSNRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CSN-Supplier').getRecordTypeId();
            // map for chatter alerts
            Map<String,OpportunityAlerts__c> alertSetting = OpportunityAlerts__c.getAll();
            // map for email alerts
            Map<String,OpportunityEmailAlerts__c> emailSetting = OpportunityEmailAlerts__c.getAll();
            
            Map<Id,Opportunity> oppMap= new Map<Id,Opportunity>();
            
            system.debug('+alertSetting ' + alertSetting.keySet() );
            
            //Fetch Opportunties with matching Products,  related Quote,Implementation Survey and Docusign Status. 
            for(Opportunity opp : [Select Id,RecordTypeId,Account.Name,Parent_Upsell__c,Owner.Email, AccountId, Chain_Deal__c,Product__c,Deal_Year__c ,SBQQ__PrimaryQuote__r.Id,SBQQ__PrimaryQuote__r.Name,SBQQ__PrimaryQuote__r.Legal_Review_Stage__c,Name,NBB_Renewal__c, StageName,
                                   (Select OpportunityId,ProductCode,Product2.Name,Opportunity.stagename,Opportunity.Deal_Year__c,Opportunity.Parent_Upsell__c From OpportunityLineItems Where ProductCode IN: alertSetting.keySet() or ProductCode IN: emailSetting.keySet()),
                                   (Select Name,Tax_Exempt__c From Implementation_Surveys__r Where Quote__c IN:primaryQuoteIds Limit 1),
                                   (Select Name From dsfs__R00N80000002fD9vEAE__r Where dsfs__Envelope_Status__c='Completed' Limit 1)
                                   From Opportunity Where Id IN:oppIds
                                  ]){
                                      oppMap.put(opp.Id,opp);
                                  }
            //Check codes only for Opportunities with NBB/Renewal = NBB Only  
            Set<String> NBBRenewalCodeSet = new Set<String>();
            NBBRenewalCodeSet.add('LA-SW-SHC-LPY-GLO');
            NBBRenewalCodeSet.add('LA-SW-SHC-LPY-PKRLO');
            NBBRenewalCodeSet.add('LA-SW-SHC-LPY-PKWDRM');
            NBBRenewalCodeSet.add('LA-SW-SHC-LPY-PKHF');
            NBBRenewalCodeSet.add('LA-SW-SHC-LPY-PKHH');
            NBBRenewalCodeSet.add('LA-SW-SHC-LPY-PKHV');
            NBBRenewalCodeSet.add('LA-SW-SHC-LPY-PKHRLM');
            
            //Multiple chatter per Opportunity
            Map<Id,List<AlertWrapper>> chatterMap = new Map<Id,List<AlertWrapper>> ();
            
            //Body vs List of reciepients per Opp
            Map<String,List<Id>> alertVsSentToIds = new Map<String,List<Id>>();
            
            
            
            
            String alert;
            String code;
            String body;
            String surveyLink='';
            String quoteLink;
            String docusignLink='';
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm()+'/';
            String isTaxExempt='';
            
            
            
            //Processing filtered opps
            for (Opportunity opp : oppMap.Values()) {
                if(opp.StageName=='Closed Won' || opp.StageName=='Closed Won – Do Not Send to EBS'){ // Udita : added If condition for Completion, MSA/Bulk Purchase Contract Type, Tax Exemption Customer
                    alertVsSentToIds.clear();
                    
                    //Primary quote should be there 
                    if(opp.Implementation_Surveys__r.size()>0){
                        surveyLink = baseUrl+ opp.Implementation_Surveys__r[0].Id;
                        isTaxExempt = opp.Implementation_Surveys__r[0].Tax_Exempt__c;
                    }
                    
                    if(opp.dsfs__R00N80000002fD9vEAE__r.size()>0)
                        docusignLink = baseUrl + opp.dsfs__R00N80000002fD9vEAE__r[0].Id;
                    
                    //Alerts for Completion, MSA/Bulk Purchase Contract Type, Tax Exemption Customer
                    
                    //Completion Alert
                    if( alertSetting.containsKey('Completion')  && opp.RecordTypeId==CSNRecTypeId || (opp.Product__c=='CSN' ||  opp.Product__c=='Decision Street' || opp.Product__c=='EMI')){
                        
                        //prepare body
                        body='\n\n Opp Name: '+ opp.Name + '\n Account : ' + opp.Account.Name + '\n Quote: ' + baseUrl + opp.SBQQ__PrimaryQuote__c +'\n Implementation Survey: '+ surveyLink + '\n\tDocusign Agreement: ' + docusignLink + '\n\n ' + alertSetting.get('Completion').Alert_Description__c;
                        
                        alertVsSentToIds.put(body,alertSetting.get('Completion').Sent_to__c.split(','));
                        
                    }
                    
                    //MSA/Bulk Purchase Contract Type
                    if( alertSetting.containsKey('MSA/Bulk Purchase Contract Type') && opp.Chain_Deal__c!=null && 
                       (opp.Chain_Deal__c.startswith('Bulk Purchase') || opp.Chain_Deal__c.startswith('MSA') || opp.Chain_Deal__c.startswith('Multi-Property')) ){ 
                           
                           //prepare body
                           body='\n\n Opp Name: '+ opp.Name + '\n Account : ' + opp.Account.Name + '\n Quote: ' + baseUrl + opp.SBQQ__PrimaryQuote__c +'\n Implementation Survey: '+ surveyLink + '\n\tDocusign Agreement: ' + docusignLink + '\n\n ' + alertSetting.get('MSA/Bulk Purchase Contract Type').Alert_Description__c;
                           
                           alertVsSentToIds.put(body,alertSetting.get('MSA/Bulk Purchase Contract Type').Sent_to__c.split(','));
                           
                       }
                    
                    //Tax Exemption Customer Alert
                    if( alertSetting.containsKey('Tax Exemption Customer')  && (isTaxExempt=='Yes, and we have no certificate on file' || isTaxExempt=='Yes, but certificate on file is expired')){
                        
                        //prepare body
                        body='\n\n Opp Name: '+ opp.Name + '\n Account : ' + opp.Account.Name  + '\n Quote: ' + baseUrl + opp.SBQQ__PrimaryQuote__c +'\n Implementation Survey: '+ surveyLink + '\n\tDocusign Agreement: ' + docusignLink + '\n\n ' + alertSetting.get('Tax Exemption Customer').Alert_Description__c;
                        
                        alertVsSentToIds.put(body,alertSetting.get('Tax Exemption Customer').Sent_to__c.split(','));
                        
                    }
                    
                }   
                //Iterate For Product Codes Alert for Current Opp
                for(OpportunityLineItem oli : opp.OpportunityLineItems){
                    
                    system.debug('$$$$alertSetting.containsKey(code)$$$$$  '+alertSetting.containsKey(code));
                    code=oli.ProductCode;
                    //fetching values on behalf of custom setting : OpportunityAlerts
                    if(alertSetting.containskey(code)){
                        alert=alertSetting.get(code).Alert_Description__c;}
                    list<string> stages = new list <string> (); // added by Udita to fetch the stages on behalf of sku code in custom setting
                    list<String> groupsIds = new list <string> ();
                    if(alertSetting.containskey(code) && alertSetting.get(code).Stage__c !=null && alertSetting.get(code).Sent_to__c !=null){
                        stages =  alertSetting.get(code).Stage__c.split(',');
                        groupsIds =alertSetting.get(code).Sent_to__c.split(','); 
                    }
                    //Content is lenghty of Alert so stored in label 
                    if(alert=='Label:OppAlert')
                        alert=Label.OppAlert;
                    else if (alert=='Label:OppAlert2')
                        alert=Label.OppAlert2; 
                    //ends!!!!!!
                    
                    //fetching values on behalf of custom setting : OpportunityEmailAlerts : UPDATED REQUEST: New Alert Workflow for CPS // P-004603 :udita
                    if(Label.OppEmailAlert == 'True'){
                        if(emailSetting.containsKey(code)){
                            string stage_EmailAlert = emailSetting.get(code).Stage__c;
                            list<string> sentToEmail = new list <string>();
                            if(emailSetting.containskey(code) && emailSetting.get(code).Sent_to__c !=null){
                                sentToEmail =  emailSetting.get(code).Sent_to__c.split(',');
                            }
                            system.debug('-----sentToEmail'+sentToEmail);
                            //code for sending email alerts:Udita    
                            if(emailSetting.containsKey(code)  && stage_EmailAlert == oli.Opportunity.stagename && (oli.Opportunity.Parent_Upsell__c == 'Primary' || oli.Opportunity.Parent_Upsell__c == 'Upsell')){
                                Messaging.SingleEmailMessage msg1 =  new Messaging.SingleEmailMessage();  
                                msg1.setTemplateId(emailSetting.get(code).TemplateId__c);
                                msg1.setToAddresses(new List<String>{opp.Owner.Email}); 
                                msg1.setToAddresses(sentToEmail);   
                                System.debug('msg1*****'+msg1);
                                msg1.setOrgWideEmailAddressId('0D2000000008OzJ');
                                msg1.setSaveAsActivity(false);
                                msg1.setTargetObjectId(opp.OwnerID);
                                msg1.setWhatId(opp.id);
                                emailMsgList.add(msg1);    
                                system.debug('---emailMsgList'+emailMsgList);                     
                            }
                        }
                    }  
                    if(alertSetting.containsKey(code)  && ((NBBRenewalCodeSet.contains(code) && opp.NBB_Renewal__c=='NBB' && (opp.StageName=='Closed Won' || opp.StageName=='Closed Won – Do Not Send to EBS')) || (!NBBRenewalCodeSet.contains(code) && (stages !=null && stages.contains(oli.Opportunity.stagename))))){
                        system.debug('If1---'+ opp.StageName);
                        if(groupsIds.contains(Label.PasskeySoldGroupId)){  // added by Udita - P-004410
                            if(oli.Opportunity.Deal_Year__c == '1'){ // added by Udita - P-004410
                                //prepare body
                                body='\n\n Opp Name: '+ opp.Name + '\n Account : ' + opp.Account.Name + '\n Quote: ' + baseUrl + opp.SBQQ__PrimaryQuote__c +'\n Implementation Survey: '+ surveyLink + '\n\tDocusign Agreement: ' + docusignLink + '\n Product Name: '+ oli.Product2.Name + '\n Product Code: '+ code + '\n\n ' + alert.trim();                           
                                alertVsSentToIds.put(body,alertSetting.get(code).Sent_to__c.split(','));
                                break;
                            }
                        }else{
                            //prepare body 
                            body='\n\n Opp Name: '+ opp.Name + '\n Account : ' + opp.Account.Name + '\n Quote: ' + baseUrl + opp.SBQQ__PrimaryQuote__c +'\n Implementation Survey: '+ surveyLink + '\n\tDocusign Agreement: ' + docusignLink + '\n Product Name: '+ oli.Product2.Name + '\n Product Code: '+ code + '\n\n ' + alert.trim();
                            
                            alertVsSentToIds.put(body,alertSetting.get(code).Sent_to__c.split(','));
                            break;
                        }    
                    }
                    
                }        
                
                //prepare Map for posting chatters
                for(String alertBody : alertVsSentToIds.keySet()){
                    if(chatterMap.containsKey(opp.Id)){
                        chatterMap.get(opp.Id).add(new AlertWrapper(alertBody,alertVsSentToIds.get(alertBody)));
                    }else{
                        chatterMap.put(opp.Id, new List<AlertWrapper>{new AlertWrapper(alertBody,alertVsSentToIds.get(alertBody))});
                    }
                }
                
                
            }
            system.debug('$$$$$$$$$$$chatterMap  '+ chatterMap);
            //PostChatter(oppIdvsSentIds,oppIdvsText);
            PostChatter(chatterMap);
            //send email instead of chatters
            if(emailMsgList.size()>0){
                Messaging.sendEmail(emailMsgList);
                system.debug('*****sendEmail*****');
            } 
        }
        
    }
    
    //Bind chatter body with Sent to reciepients
    public class AlertWrapper{
        String chatterBody;
        List<Id> sentToIds;
        public AlertWrapper(String chatterBody,List<Id> sentToIds){
            this.chatterBody=chatterBody;
            this.sentToIds=sentToIds;
        }
    }
    
    //public static void PostChatter(Map<Id,List<Id>> oppIdvsSentIds , Map<Id,String> oppIdvsText){
    public static void PostChatter(Map<Id,List<AlertWrapper>> chatterMap){
        
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        
        ConnectApi.FeedItemInput input;
        ConnectApi.MarkupBeginSegmentInput markupBeginSegment;
        ConnectApi.MarkupEndSegmentInput markupEndSegment;
        ConnectApi.MessageBodyInput body;
        ConnectApi.MentionSegmentInput mentionSegmentInput;
        
        
        for(Id oppId : chatterMap.keySet()){
            
            
            //Multiple chatter per opportunity
            for(AlertWrapper awrapper : chatterMap.get(oppId)){
                
                //Attach under Opp Record
                input = new ConnectApi.FeedItemInput();
                input.subjectId = oppId;
                
                //init body
                body = new ConnectApi.MessageBodyInput();
                body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                
                //@Mention ( Sent To Alerts )
                for(Id userOrGroupId : awrapper.sentToIds){
                    mentionSegmentInput = new ConnectApi.MentionSegmentInput();        
                    mentionSegmentInput.id = userOrGroupId;
                    body.messageSegments.add(mentionSegmentInput);
                }
                
                
                
                
                //Chatter Text Body/Description
                ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = awrapper.chatterBody;   
                body.messageSegments.add(textSegment);
                
                
                //populate body
                input.body = body;
                
                //bulk chatter
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
                batchInputs.add(batchInput);
            }
            
            
        }
        
        //post chattern
        if(!Test.isRunningTest()){
            
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        }
        
        
        
    }
    
    
    /**
**  Sync owners from Opportunity to Primary Quote and Parent/Child Contracts
**   Added on - 13/11/2017
**/ 
    public static void syncOwner(List<Opportunity> newValues, Map<Id,Opportunity> oldMapValues){
        
        Map<Id,Id> oppVSOwnerIdMap = new Map<Id,Id>();
        system.debug('====>istest'+isTest);
        //Owner is changed
        for(Opportunity opp: newValues){        
            if((oldMapValues.get(opp.id).OwnerId!=opp.OwnerId) || isTest ){ // && isTest
                oppVSOwnerIdMap.put(opp.Id,opp.OwnerId);
            }
        }
        
        //Sync Owners
        if(!oppVSOwnerIdMap.isEmpty()){
            
            List<SBQQ__Quote__c> updateQuoteList = new List<SBQQ__Quote__c> ();
            List<Contract> updateContractList = new List<Contract> ();
            
            Set<Id> recTypes = new Set<Id>();
            Id parentRecTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
            Id childrecTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();
            recTypes.add(parentRecTypeId);
            recTypes.add(childrecTypeId);
            
            for(Opportunity oppRec : [Select Id,OwnerId,StageName,
                                      (Select Id,OwnerId,SBQQ__SalesRep__c From SBQQ__Quotes2__r Where OwnerId NOT IN: oppVSOwnerIdMap.values()),
                                      (Select Id,SBQQ__RenewalOwner__c From SBQQ__Contracts__r Where OwnerId NOT IN: oppVSOwnerIdMap.values() and RecordTypeId IN :recTypes)
                                      From Opportunity Where ID IN: oppVSOwnerIdMap.keySet()]){
                                          
                                          //Sync oweners to Quote
                                          for(SBQQ__Quote__c q : oppRec.SBQQ__Quotes2__r){
                                              
                                              q.OwnerId = oppRec.OwnerId;
                                              q.SBQQ__SalesRep__c = oppRec.OwnerId;
                                              updateQuoteList.add(q);
                                              
                                          }
                                          //Sync owners to Contract
                                          if(oppRec.StageName == 'Up for Renewal'){
                                              for(Contract c : oppRec.SBQQ__Contracts__r){
                                                  
                                                  c.SBQQ__RenewalOwner__c = oppRec.OwnerId;
                                                  updateContractList.add(c);
                                                  
                                              }
                                          }
                                          
                                      }
            
            if(updateQuoteList.size()>0){
                update updateQuoteList;
            }
            if(updateContractList.size()>0){
                update updateContractList;
            }
        }
    }
    /*
**
** Check whether the Opportunity has atleast one primary quote and a OpportunityProduct when a Opportunity is Closed/Won.
** Added by : HSR
** Added on : 21st Nov 2017
*/
    public static void CheckQuoteProduct( List<Opportunity> newList, Set<Id> oppIdSet){
        
        Set<Id> profileIdSet = new Set<Id>();
        //Query to fetch all the Finance Profiles......
        
        
        /* For(Profile profileRec : [SELECT Id FROM Profile WHERE Name LIKE '%Finance%'])
{
profileIdSet.add(profileRec.Id);
}*/ // comment5ed by udita for PI-0003804
        
        //Validation will not fire for the Finance User
        //  if(!profileIdSet.contains(UserInfo.getProfileId())){   // commented by udita for PI-0003804
        
        Map<Id,Integer> oppIdVsQuoteCountmap = new Map<Id,Integer>();
        Map<Id,Integer> oppIdVsProductCountmap = new Map<Id,Integer>();
        
        For(Opportunity oppObj : [SELECT Id,(SELECT Id FROM SBQQ__Quotes2__r WHERE SBQQ__Primary__c = TRUE),(SELECT Id FROM OpportunityLineItems LIMIT 1) FROM Opportunity WHERE Id IN : oppIdSet])
        {
            oppIdVsQuoteCountmap.put(oppObj.Id,oppObj.SBQQ__Quotes2__r.size());
            oppIdVsProductCountmap.put(oppObj.Id,oppObj.OpportunityLineItems.size());
            
        }
        
        For(Opportunity oppObj : newList){
            if(oppIdVsQuoteCountmap.containsKey(oppObj.Id)){
                if(oppIdVsQuoteCountmap.get(oppObj.Id)==0 && !Test.isRunningTest() && oppObj.Parent_Upsell__c !='One-Off' && UserInfo.getUserName() != Label.UserBypassQM ){ // last check added by udita for PI-0003804
                    oppObj.addError('Opportunity should have atleast one Primary Quote.');
                }else if(oppIdVsQuoteCountmap.get(oppObj.Id)>1 && !Test.isRunningTest()){
                    oppObj.addError('Opportunity should not have more than one Primary Quote.');
                }
            }
            if(oppIdVsProductCountmap.containsKey(oppObj.Id) && oppIdVsProductCountmap.get(oppObj.Id) == 0 && !Test.isRunningTest()){
                //oppObj.addError('Opportunity should have at least one Product.');
            }
        }
        // } // comment5ed by udita for PI-0003804
    }
    
    /**
***
Added By : HSR
Date : 12/01/2017
Description : To change the OpportunitySplitOwner when the Owner Id of opportunity is changed after the Opportunity is Closed/Won.
***
**/
    public static void ChangeOppSplitOwner(Map<Id,Opportunity> newMapValues,Map<Id,Opportunity> oldMapValues){
        Map<Id,Id> oppIdVsOldOwnerMap = new Map<Id,Id>();
        Map<Id,Id> oppIdVsNewOwnerMap = new Map<Id,Id>();
        Opportunity oldOppObj;
        
        Map<String,Map<Id,Decimal>> oppOwnerVsOppSplitVsPercent = new Map<String,Map<Id,Decimal>>();
        Map<Id,Decimal> oppSplitIdVsPercent = new Map<Id,Decimal>();
        String s;
        
        Set<Id> splitTypeIdSet = new Set<Id>();
        Set<Id> oppOwnerIdSet = new Set<Id>();
        For(Opportunity oppObj : newMapValues.Values()){
            oldOppObj = oldMapValues.get(oppObj.Id);
            if(isTest || (oldOppObj.OwnerId != oppObj.OwnerId && oppObj.StageName == 'Closed Won'))
            {
                oppIdVsOldOwnerMap.put(oppObj.Id,oldOppObj.OwnerId);
                oppIdVsNewOwnerMap.put(oppObj.Id,oppObj.OwnerId);
                oppOwnerIdSet.add(oppObj.OwnerId);
                oppOwnerIdSet.add(oldOppObj.OwnerId);
            }
        }
        System.debug('oppIdVsOldOwnerMap**'+oppIdVsOldOwnerMap);
        System.debug('oppIdVsNewOwnerMap**'+oppIdVsNewOwnerMap);
        if(!oppIdVsOldOwnerMap.isEmpty()){
            For(OpportunitySplitType splitTypeRec : [SELECT Id FROM OpportunitySplitType WHERE IsActive = TRUE])
            {
                splitTypeIdSet.add(splitTypeRec.Id);
            }
            List<OpportunitySplit> oppSplitList = new List<OpportunitySplit>();
            OpportunitySplit oppSplitObj = new OpportunitySplit();
            For(OpportunitySplit oppSplitRec : [SELECT Id,SplitOwnerId,OpportunityId,SplitPercentage FROM OpportunitySplit WHERE OpportunityId IN : oppIdVsNewOwnerMap.keySet() AND SplitOwnerId IN : oppOwnerIdSet AND SplitTypeId  IN : splitTypeIdSet])// 
            {
                s = '';
                s = String.ValueOf(oppSplitRec.OpportunityId)+String.ValueOf(oppSplitRec.SplitOwnerId);
                if(oppOwnerIdSet.contains(oppSplitRec.SplitOwnerId) && !oppOwnerVsOppSplitVsPercent.containsKey(s)){
                    oppSplitIdVsPercent = new Map<Id,Decimal>();
                    oppSplitIdVsPercent.put(oppSplitRec.Id,oppSplitRec.SplitPercentage);
                    oppOwnerVsOppSplitVsPercent.put(s,oppSplitIdVsPercent);
                }
            }
            System.debug('oppOwnerVsOppSplitVsPercent********'+oppOwnerVsOppSplitVsPercent);
            if(!oppOwnerVsOppSplitVsPercent.isEmpty())
            {
                For(Id oppId : oppIdVsOldOwnerMap.keySet())
                {
                    String oldOppVsOwnerId = String.ValueOf(oppId)+String.ValueOf(oppIdVsOldOwnerMap.get(oppId));
                    String newOppVsOwnerId = String.ValueOf(oppId)+String.ValueOf(oppIdVsNewOwnerMap.get(oppId));
                    System.debug('oldOppVsOwnerId********'+oldOppVsOwnerId);
                    System.debug('newOppVsOwnerId*************'+newOppVsOwnerId);
                    Decimal oldPercent = 0; 
                    Decimal newPercent = 0; 
                    For(Id oldVal : oppOwnerVsOppSplitVsPercent.get(oldOppVsOwnerId).keySet())
                    {
                        oldPercent = oppOwnerVsOppSplitVsPercent.get(oldOppVsOwnerId).get(oldVal);
                    }
                    System.debug('oldPercent******'+oldPercent);
                    For(Id newVal : oppOwnerVsOppSplitVsPercent.get(newOppVsOwnerId).keySet())
                    {
                        newPercent = oppOwnerVsOppSplitVsPercent.get(newOppVsOwnerId).get(newVal);
                        oppSplitObj = new OpportunitySplit(Id = newVal);
                        oppSplitObj.SplitPercentage = oldPercent;
                        oppSplitList.add(oppSplitObj);
                    }
                    System.debug('newPercent******'+newPercent);
                    For(Id oldVal : oppOwnerVsOppSplitVsPercent.get(oldOppVsOwnerId).keySet())
                    {
                        oppSplitObj = new OpportunitySplit(Id = oldVal);
                        oppSplitObj.SplitPercentage = newPercent;
                        oppSplitList.add(oppSplitObj);
                        System.debug('oldPercent********'+oldPercent);
                    }
                }
            }
            System.debug('oppSplitList*******'+oppSplitList);
            if(oppSplitList.size()>0 && !Test.isRunningTest())
                Database.update(oppSplitList,false);
        }
    }
    /**
***
Added By : HSR
Date : 01/08/2018
Description : If contract team is removing AM owner name from opportunity, we want an email alert should out to that rep whose name we are removing.
***
**/
    public static void SendAMAlert(Map<Id,Opportunity> newMapValues,Map<Id,Opportunity> oldMapValues){
        Opportunity oldOppObj;
        Map<Id,String> oppIdVsAMOwnerNameMap = new Map<Id,String>();
        Map<String,String> userIdVsEmailMap = new Map<String,String>();
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail;
        For(Opportunity oppObj : newMapValues.Values()){
            system.debug('=====>'+oppObj.AM_Owner__c);
            
            oldOppObj = oldMapValues.get(oppObj.Id);
            system.debug('=====>'+oldOppObj.AM_Owner__c);
            if(istest || (oldOppObj.AM_Owner__c!=null && oppObj.AM_Owner__c!=oldOppObj.AM_Owner__c && oldOppObj.AM_Owner__c!='Not Applicable'))
            {
                oppIdVsAMOwnerNameMap.put(oppObj.Id,oldOppObj.AM_Owner__c);
            }
        }
        system.debug('===>'+oppIdVsAMOwnerNameMap.values());
        if(!oppIdVsAMOwnerNameMap.isEmpty()){
            For(User userObj : [SELECT Id,Name,Email,Profile.name FROM User WHERE Name IN :oppIdVsAMOwnerNameMap.Values() AND IsActive = TRUE AND IsPortalEnabled = FALSE])
            {
                if(!userObj.Email.contains('='))
                    userIdVsEmailMap.put(userObj.Name,userObj.Email);
            }
            if(!userIdVsEmailMap.isEmpty()){
                For(Id oppId : oppIdVsAMOwnerNameMap.keySet())
                {
                    if(userIdVsEmailMap.containskey(oppIdVsAMOwnerNameMap.get(oppId))){
                        mail = new Messaging.SingleEmailMessage();  
                        String[] toAddresses = new String[] {userIdVsEmailMap.get(oppIdVsAMOwnerNameMap.get(oppId))};  
                            mail.setToAddresses(toAddresses);  
                        mail.setSubject('Your name has been removed from AM Influence https://cvent.my.salesforce.com/'+oppId);  
                        String body='<span style='+'\''+'color:black; font-size:11.0pt;font-family:"Calibri",sans-serif;'+'\''+'><b>Hi '+oppIdVsAMOwnerNameMap.get(oppId)+',  </b></br></br></b><b>Reason of alert : </b></br></br><b>Opp. ID link –</b> <a href="https://cvent.my.salesforce.com/'+oppId+'">'+'https://cvent.my.salesforce.com/'+oppId+'</a></br></p></br><b>Please </b><span style='+'\''+'color:red; font-size:11.0pt;font-family:"Calibri",sans-serif;'+'\''+'><b> write to contracts team </b></span><b>in case of any discrepancy. </b> </p></p></br><span style='+'\''+'font-size:11.0pt;font-family:"Calibri",sans-serif;color:red'+'\''+'><b>Possible Reasons for the update:</b><ul><li>AM Influence has been updated by another rep.</li><li>If the owner of the opportunity is the same name in the AM Influence field.</li><li>If the name identified was incorrectly associated to the AM influence field, according to the parent contract.</li></ul> </span> <span style='+'\''+'font-size:11.0pt;font-family:"Calibri",sans-serif;color:#000000'+'\''+'><b>Thanks,</br>'+'SF Alerts'+'<o:p></o:p></b></span>';
                        mail.setHtmlBody(body);
                        allmsg.add(mail);
                    }
                }
                if(allmsg.size()>0)
                    Messaging.sendEmail(allmsg,false);
            }   
        }
    }
    
    
    
    /*
**  Added on 1/10/2018 ( Shanu Aggarwal)
**  Create RFP Cases after Opportunity is Closed Lost and Account's CSN Listing Type is Basic
**  P-001519 
**/
    public static void CreateRFPCaseOnClosedLost( List<Opportunity> newList, Map<Id,Opportunity> oldMapValues){
        
        System.debug('Ashna**** Called 2');
        Set<Id> oppIds = new Set<ID>();
        List<Case> casesToCreate = new List<Case>();
        //Opportunity is Closed Won and License Type is 1 > 4 Diamond
        for(Opportunity opp : newList){        
            if(istest || (oldMapValues.get(opp.id).StageName!=opp.StageName && opp.StageName=='Closed Lost' && (opp.License_Type__c=='1 Diamond' ||  opp.License_Type__c=='2 Diamond' ||   opp.License_Type__c=='3 Diamond' || opp.License_Type__c=='4 Diamond' ))){
                oppIds.add(opp.Id);
                
            }
        }
        System.debug('Ashna**** '+ oppIds);
        //Create cases If account listing type is basic
        if(oppIds.size()>0){
            system.debug('=====>Account.CSN_Listing_Type__c'+Account.CSN_Listing_Type__c);
            for( Opportunity opp : [ Select AccountId From Opportunity Where ID IN: oppIds and Account.CSN_Listing_Type__c = 'Basic' AND (Account.BillingCountry ='US' OR Account.BillingCountry ='CA' OR  Account.BillingCountry ='VI' OR Account.BillingCountry ='MX')]){   //Account.BillingCountry check added by Udita on Ashna request - P-004419
                System.debug('Ashna**** '+ opp);
                Case c = new Case(AccountId=opp.AccountId,RecordTypeId='0120000000096iP',OwnerId='00G00000006uMGq',Subject='Property moved from diamond to basic - review user shut down',Product_Type__c='CSN - Supplier',Client_Services_Category__c='Profile Management',Origin='CSN Task');
                casesToCreate.add(c);
            }
            if(casesToCreate.size()>0)
                insert casesToCreate;
        }       
        
    }
    /*
**
Creaed By : HSR
Date : 16th Jan 2018
Description : Owner Assignment while creating Opportunity on the basis of the AccountTeamMember.
**
*/
    public static void oppOwnerAssignment(List<Opportunity> newOppList){
        System.debug('#Checkpoint Inside*****');
        Set<Id> accountIdSet = new Set<Id>();
        List<Opportunity> oppRecList = new List<Opportunity>();
        For(Opportunity oppRec : newOppList)
        {
            if(oppRec.Product__c!=null && !oppRec.IsClosed && !oppRec.IsWon && ((oppRec.NBB_Renewal__c!=null && oppRec.NBB_Renewal__c=='Renewal') || (oppRec.Deal_Year__c!=null && oppRec.Deal_Year__c!='1'))){//&& oppRec.Deal_Closed_by__c == null (oppRec.MYD_Deal__c!=null && oppRec.MYD_Deal__c == 'MYD')
                accountIdSet.add(oppRec.AccountId);
                oppRecList.add(oppRec);
            }
        }
        System.debug('oppRecList*****'+oppRecList);
        System.debug('accountIdSet*****'+accountIdSet);
        if(accountIdSet.size()>0){
            //Fetching AccountTeam Member.
            Map<Id,Account> mapIDOppParentAcc=new Map<ID,Account>([SELECT Id,
                                                                   (SELECT Id, AccountId,UserId,TeamMemberRole FROM AccountTeamMembers WHERE TeamMemberRole = 'AM - Event' 
                                                                    OR TeamMemberRole = 'Multi-Product' OR TeamMemberRole = 'AM - Inquisium' OR TeamMemberRole = 'AM - RegOnline' OR
                                                                    TeamMemberRole = 'AM - CrowdCompass' OR TeamMemberRole = 'AM - OS' OR TeamMemberRole = 'AM - HC' OR
                                                                    TeamMemberRole = 'AM–OS' OR TeamMemberRole = 'AM - Event Cloud' OR TeamMemberRole = 'SAT-HMC' OR TeamMemberRole = 'SAT-CHAIN'
                                                                   )FROM Account WHERE Id IN: accountIdSet]); 
            
            
            Map<ID,Map<String,String>> mapAccountIdTeam=new Map<Id,Map<String,String>>();
            for(Account acc : mapIDOppParentAcc.values()){
                if(acc.AccountTeamMembers!=null){
                    Map<String,String> mapRoleVsuserID=new Map<String,String>();
                    for(AccountTeamMember actTeam : acc.AccountTeamMembers){
                        mapRoleVsuserID.put(actTeam.TeamMemberRole,actTeam.UserId);
                    }
                    system.debug('*****mapRoleVsuserID*******'+mapRoleVsuserID);
                    mapAccountIdTeam.put(acc.Id,mapRoleVsuserID);
                }
            }
            
            If(!mapAccountIdTeam.isEmpty())
            {
                For(Opportunity oppRec : oppRecList){
                    if(mapAccountIdTeam.containsKey(oppRec.AccountId)){
                        //Opportunity Owner Assignment for - Hospitality Cloud
                        String chainDeal = String.ValueOf(oppRec.Chain_Deal__c);
                        if((oppRec.Product__c=='CSN' || oppRec.Product__c=='EMI' || oppRec.Product__c=='Lanyon Passkey' || oppRec.Product__c=='Lanyon Group' || oppRec.Product__c=='Lanyon Transient'|| oppRec.Product__c=='Lanyon Travel')
                           && (oppRec.Chain_Deal__c!=null &&  (oppRec.Chain_Deal__c == 'Venue/Service' || chainDeal.containsIgnoreCase('Ownership Group') || chainDeal.containsIgnoreCase('Advertising Agency') || 
                                                               chainDeal.endsWithIgnoreCase('by Affiliate')))
                           && mapAccountIdTeam.get(oppRec.AccountId).containsKey('AM - HC')
                          ){
                              oppRec.OwnerId = mapAccountIdTeam.get(oppRec.AccountId).get('AM - HC');
                          }
                        //...............Ends Here...........
                        //Opportunity Owner Assignment for - Event Cloud //AM - Event Cloud
                        else if(oppRec.Product__c=='Survey'){
                            system.debug('---mapAccountIdTeam.get(oppRec.AccountId)'+mapAccountIdTeam.get(oppRec.AccountId).get('AM - HC') );
                            if(mapAccountIdTeam.get(oppRec.AccountId).containsKey('AM - Inquisium')){
                                oppRec.OwnerId = mapAccountIdTeam.get(oppRec.AccountId).get('AM - Inquisium');
                                system.debug('---oppRec'+oppRec.id);
                            }
                            else if(mapAccountIdTeam.get(oppRec.AccountId).containsKey('AM - HC')){
                                oppRec.OwnerId = mapAccountIdTeam.get(oppRec.AccountId).get('AM - HC');
                                system.debug('---oppRec'+mapAccountIdTeam.get(oppRec.AccountId).containsKey('AM - HC') );
                            }
                        }
                        else if(oppRec.Product__c=='Event' || oppRec.Product__c=='CrowdCompass' || oppRec.Product__c=='Onsite Solutions'){
                            if(mapAccountIdTeam.get(oppRec.AccountId).containsKey('AM - Event Cloud')){
                                oppRec.OwnerId = mapAccountIdTeam.get(oppRec.AccountId).get('AM - Event Cloud');break;
                                
                            }
                            else if(mapAccountIdTeam.get(oppRec.AccountId).containsKey('AM - Event')){
                                oppRec.OwnerId = mapAccountIdTeam.get(oppRec.AccountId).containsKey('AM - Event Cloud')?mapAccountIdTeam.get(oppRec.AccountId).get('AM - Event Cloud'):mapAccountIdTeam.get(oppRec.AccountId).get('AM - Event');break;
                                
                            }
                            else if(mapAccountIdTeam.get(oppRec.AccountId).containsKey('AM - CrowdCompass')){
                                oppRec.OwnerId = mapAccountIdTeam.get(oppRec.AccountId).containsKey('AM - Event Cloud')?mapAccountIdTeam.get(oppRec.AccountId).get('AM - Event Cloud'):mapAccountIdTeam.get(oppRec.AccountId).get('AM - CrowdCompass'); break;
                                
                            }
                            else if(mapAccountIdTeam.get(oppRec.AccountId).containsKey('AM - OS')){
                                oppRec.OwnerId = mapAccountIdTeam.get(oppRec.AccountId).containsKey('AM - Event Cloud')?mapAccountIdTeam.get(oppRec.AccountId).get('AM - Event Cloud'):mapAccountIdTeam.get(oppRec.AccountId).get('AM - OS');break;
                                
                            }
                            else if(mapAccountIdTeam.get(oppRec.AccountId).containsKey('Multi-Product')){
                                oppRec.OwnerId = mapAccountIdTeam.get(oppRec.AccountId).containsKey('AM - Event Cloud')?mapAccountIdTeam.get(oppRec.AccountId).get('AM - Event Cloud'):mapAccountIdTeam.get(oppRec.AccountId).get('Multi-Product');break;
                                system.debug('---oppRec'+oppRec.OwnerId );
                                
                            }
                        }
                        else if(oppRec.Product__c=='RegOnline' && mapAccountIdTeam.get(oppRec.AccountId).containsKey('AM - RegOnline')){
                            System.debug('#Checkpoint Else');
                            oppRec.OwnerId = mapAccountIdTeam.get(oppRec.AccountId).get('AM - RegOnline');
                        }
                    }
                }
            }
        }
    }

    //to delete bookings classification : Udita
    public static void deleteRelatedBookings(map<id,Opportunity> oldOppMap)
    {  
        List<Booking_Classification__c> relatedBookings = [SELECT id,Opportunity__c FROM Booking_Classification__c WHERE Opportunity__r.id IN: oldOppMap.keyset()];
        if(relatedBookings.size() > 0){
            delete relatedBookings;
        }
    }
    //method ends

    /*HSR : To update Booking Classification fields when some of the opportunity fields is being updated.*/
    public static void updateBCValues(Map<Id,Opportunity> oldMapValues, Map<Id,Opportunity> newMapValues){
        Opportunity oldOpp = new Opportunity();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        For(Opportunity oppRec : newMapValues.values())
        {
            oldOpp = oldMapValues.get(oppRec.Id);
            if(istest || ((oppRec.SBQQ__AmendedContract__c != oldOpp.SBQQ__AmendedContract__c || 
                           oppRec.Deal_Year__c != oldOpp.Deal_Year__c || 
                           oppRec.SBQQ__RenewedContract__c != oldOpp.SBQQ__RenewedContract__c || 
                           oppRec.Exchange_Rate__c != oldOpp.Exchange_Rate__c || 
                           oppRec.Contract_Type_2_0__c != oldOpp.Contract_Type_2_0__c) && oppRec.Lock_BCT__c==false) || oppRec.Exchange_Rate__c != oldOpp.Exchange_Rate__c)
            {
                oppMap.put(oppRec.Id,oppRec);
            }
        }
        if(!oppMap.isEmpty()){
            List<Booking_Classification__c> BCObjList = new List<Booking_Classification__c>();
            For(Booking_Classification__c BCObj : [SELECT Id,Opportunity__c,SBQQ_AmendedContract__c,SBQQ_RenewedContract__c,Contract_Type_2_0__c,Deal_Years__c FROM Booking_Classification__c WHERE Opportunity__c IN : oppMap.keySet()]){
                
                BCObj.SBQQ_AmendedContract__c = oppMap.get(BCObj.Opportunity__c).SBQQ__AmendedContract__c!=null?String.ValueOf(oppMap.get(BCObj.Opportunity__c).SBQQ__AmendedContract__c):'';
                BCObj.SBQQ_RenewedContract__c = oppMap.get(BCObj.Opportunity__c).SBQQ__RenewedContract__c!=null?String.Valueof(oppMap.get(BCObj.Opportunity__c).SBQQ__RenewedContract__c):'';
                BCObj.Contract_Type_2_0__c = oppMap.get(BCObj.Opportunity__c).Contract_Type_2_0__c!=null?String.valueOf(oppMap.get(BCObj.Opportunity__c).Contract_Type_2_0__c):'';
                BCObj.Deal_Years__c = oppMap.get(BCObj.Opportunity__c).Deal_Year__c!=null?Integer.ValueOf(oppMap.get(BCObj.Opportunity__c).Deal_Year__c):null;
                BCObj.Exchange_Rates__c = oppMap.get(BCObj.Opportunity__c).Exchange_Rate__c;
                BCObjList.add(BCObj);
            }
            
            if(BCObjList.size()>0)
                update BCObjList;
        }
    }// end 
    
    
    /*
Author : Kumud
Desc: Set opportunity owner role : Move code from OwnerRoleTrigger  and deactivated the trigger
Date: 26 June 2018

*/
    private static void populateOppOwnerRole(List<Opportunity> listOfOpp){
        
        Set<Id> setUserIDs = new Set<Id>();
        for(Opportunity instOpp : listOfOpp)
        {
            setUserIDs.add(instOpp.OwnerId);
        }
        
        Map<Id,User> mapUser = new Map<Id,User>([Select id, UserRole.Name,CountryCode  from User where Id IN :setUserIDs]);
        
        for(Opportunity instOpp : listOfOpp){
            
            
            if(mapUser.containskey(instOpp.ownerID) && mapUser.get(instOpp.ownerID)!=null){
                instOpp.opp_owner_role__c = mapUser.get(instOpp.OwnerId).UserRole.Name;if(ExecuteMethodHelper.isActive('OppFieldAutomation')){ if(instOpp.Opportunity_Type__c != 'MYD'){ instOpp.Deal_Closed_by__c = mapUser.get(instOpp.OwnerId).ID;  }     
                         
                if(mapUser.get(instOpp.OwnerId).CountryCode == 'AE'){instOpp.Sold_By__c = 'Dubai';}
                if(mapUser.get(instOpp.OwnerId).CountryCode == 'US'){instOpp.Sold_By__c = 'USA';}                   
                if(mapUser.get(instOpp.OwnerId).CountryCode == 'GB' || mapUser.get(instOpp.OwnerId).CountryCode == 'ES' || mapUser.get(instOpp.OwnerId).CountryCode == 'DE'){instOpp.Sold_By__c = 'Europe';}                  
                if(mapUser.get(instOpp.OwnerId).CountryCode == 'IN'){instOpp.Sold_By__c = 'India';}                  
                if(mapUser.get(instOpp.OwnerId).CountryCode == 'AU'){instOpp.Sold_By__c = 'Australia';}
                if(mapUser.get(instOpp.OwnerId).CountryCode == 'SG'){instOpp.Sold_By__c = 'Singapore';}                      
                if(mapUser.get(instOpp.OwnerId).CountryCode == 'CA'){instOpp.Sold_By__c = 'Canada';}}                  
         
    } // end of method
    }}
    /*
Author : Kumud
Desc: Move delete validation here
Date: 26 June 2018

*/
    public static void onbeforeDelete(List<Opportunity> listOfOpportunity){
        
        final String userID=label.OpprtunityDeleteUserID;
        final Id loginUserID=userInfo.getUserID();
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>(); 
        String[] toAddresses = new String[]{'vaibhav.jain@cvent.com','ZMahmood@cvent.com','Ankit.Jain@cvent.com'};
            String ProfileId = UserInfo.getProfileId();
        
        //OppDeleteCS Trigger
        List<Profile> userRec =  [Select id from Profile where name = 'Client Services Leadership' or Name = 'System Administrator'];   
        
        
        for(opportunity  instOFOpp : listOfOpportunity){
            // PreventOppDeletion,preventoppdelete  trigger. 
            if (!instOFOpp.ignoreValidation__c && loginUserID !=userID && ((instOFOpp.StageName == 'Closed Won'||instOFOpp.StageName == 'Closed Lost') && instOFOpp.New_Type__c.startswith('Renewal') || (instOFOpp.StageName == 'Closed Won'&& instOFOpp.CFC_Check__c != null && instOFOpp.Contract_Implemented__c == True)) && UserInfo.getUserName() != Label.UserBypassQM) {
                
                instOFOpp.addError('You are not authorised to delete this Opportunity.');
                
            }
            
            if(!instOFOpp.ignoreValidation__c && loginUserID !=userID && instOFOpp.LeadSource == 'Client Services'  && (ProfileId != userRec[0].Id || ProfileId != userRec[0].Id)  ){
                
                instOFOpp.addError('You cannot delete opportunities created by Client Services');
            }
            
            if(!instOFOpp.ignoreValidation__c && loginUserID !=userID && instOFOpp.Master_Type__c!=null &&  instOFOpp.Master_Type__c.contains('Renewal') && UserInfo.getUserName() != Label.UserBypassQM){
                
                instOFOpp.addError('You are not authorised to delete this Opportunity.');
            }
            
            else if(instOFOpp.New_Type__c!=null && instOFOpp.New_Type__c.contains('Renewal')){
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddresses);
                mail.setSenderDisplayName('CVENT Notifications');
                mail.setSubject('Opportunity deleted!');
                mail.setBccSender(false);
                mail.setUseSignature(false);
                mail.setHtmlBody ('Hi,</br></br>'+
                                  'An opportunity has been deleted. Please see details below: </br>' +
                                  'Opportunity Name : '+ instOFOpp.Name + '</br>' +
                                  'Opportunity Link : https://cvent.my.salesforce.com/'+ instOFOpp.Id + '</br>' +
                                  'Unique Id Opp : '+ instOFOpp.Unique_ID_Opp__c + '</br>' +
                                  'Contract Type : '+ instOFOpp.New_Type__c + '</br>' +
                                  'Close Date : '+ instOFOpp.CloseDate + '</br>' +
                                  'Product : '+ instOFOpp.Product__c + '</br>' +
                                  'Opportunity Owner : '+ instOFOpp.Owner + '</br>' +
                                  'Contract Total : '+ instOFOpp.New_Contract_Total__c + '</br>' +
                                  'Account Link : https://cvent.my.salesforce.com/'+ instOFOpp.AccountId+ '</br>' +
                                  'Deleted by: '+ UserInfo.getName()  + '</br></br>' +
                                  'Regards,</br>'+ 
                                  'Sales Support India');
                mails.add(mail);
                
            }
        } // end of loop
        if(!mails.isEmpty()){
            
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>(mails));
        }
        
    }// end 
    
    
    /*

Author : Kumud
Desc: Call task automation and billing handler on after update of opportunity: // Moving code from trigger to Handler


*/
    private static void onAfterUpdateTaskBillingUpdate(List<Opportunity> listOpp,Map<Id,Opportunity> newMapOpp,Map<Id,Opportunity> oldMapOpp){
        
        //Add by Kumud 
        Map<Id, Opportunity> newMapOppty=new  Map<Id ,Opportunity>();
        Map<Id, Opportunity> oldMapOppty=new  Map<Id, Opportunity>();
        //For Onboarding Creation
        Map<Id, Opportunity> newMapOnboardingOppty=new  Map<Id ,Opportunity>();
        Map<Id, Opportunity> oldMapOnboardingOppty=new  Map<Id, Opportunity>();
        //When Primary Quote is re-synced or Net Total is updated.....
        Set<Id> oppIdBCCalculate = new Set<Id>();
        Set<String> oppIdReassignBCCalculate = new Set<String>();
        Map<String,Id> oldNewOppLineIdMap = new Map<String,id>();
        for(Opportunity objOppty:listOpp){
            
            if((objOppty.stageName!=oldMapOpp.get(objOppty.id).stageName || objOppty.Contract_Implemented__c !=oldMapOpp.get(objOppty.id).Contract_Implemented__c) && (objOppty.stageName=='Closed Won' && objOppty.Contract_Implemented__c)){
                if(!objOppty.Task_Created__c){
                    newMapOppty.put(objOppty.id,objOppty);
                    oldMapOppty.put(objOppty.id,oldMapOppty.get(objOppty.id));
                }
                //if(!objOppty.Onboarding_Created__c)
                //{
                newMapOnboardingOppty.put(objOppty.id,objOppty);
                oldMapOnboardingOppty.put(objOppty.id,oldMapOppty.get(objOppty.id));
                //}
            }
            //When Primary Quote is re-synced or Net Total is updated.....
            if(objOppty.SBQQ__PrimaryQuote__c!=oldMapOpp.get(objOppty.id).SBQQ__PrimaryQuote__c || objOppty.Net_Amount_Opp__c!=oldMapOpp.get(objOppty.id).Net_Amount_Opp__c){
                oppIdBCCalculate.add(objOppty.Id);
                if(String.isNotBlank(objOppty.Reassigned_To__c)){
                    oppIdReassignBCCalculate.add(objOppty.Reassigned_To__c);
                    oldNewOppLineIdMap.put(objOppty.Reassigned_To__c,objOppty.Id);
                }
            }
            
        } 
        //When Primary Quote is re-synced or Net Total is updated.....
        if(oppIdBCCalculate.size()>0 && Label.IsBCRecalculate=='True'){
            SnapShotUtilityHelper.CreateOppProdSnapshot(null,oppIdBCCalculate,oppIdReassignBCCalculate,oldNewOppLineIdMap);
        }
        if(!TaskAssignAutomationTrgHelper.isRun && newMapOppty.size()>0 && Label.IsTaskAssignAutomationTrgHelper=='True')
            TaskAssignAutomationTrgHelper.onAfterUpdatecreateTask(newMapOppty,oldMapOppty);  
        if(!TaskAssignAutomationTrgHelper.isRunOnboard && newMapOnboardingOppty.size()>0 && Label.IsOnboardingAssignAutomationTrgHelper == 'True')
            TaskAssignAutomationTrgHelper.onAfterUpdatecreateOnboarding(newMapOnboardingOppty,oldMapOnboardingOppty);  
        // End here 
        // Add by kd
        List<Opportunity> listOpp_ContractImpl=new List<Opportunity>(); 
        /*  below list and set are used to identify whether it is hybrid opp or not */
        List<Opportunity> listHybridOpp=new List<Opportunity>(); 
        List<Opportunity> listNonHybridOpp=new List<Opportunity>();
        Set<Id> setOppIDs=new Set<Id>();
        for(Opportunity oppty:listOpp){
            if((newMapOpp.get(oppty.id).Contract_Implemented__c !=oldMapOpp.get(oppty.id).Contract_Implemented__c||newMapOpp.get(oppty.id).Contract_Number_New__c!=oldMapOpp.get(oppty.id).Contract_Number_New__c) && newMapOpp.get(oppty.id).Contract_Implemented__c){
                listOpp_ContractImpl.add(newMapOpp.get(oppty.id));
                setOppIDs.add(oppty.id);
            }
        }
        if(listOpp_ContractImpl.size()>0 && !billingCaseCreate_Opp_handler.isRunonce){
            Map<Id,Boolean>  mapOppIdIsHybrid=AssignReviewerOpptyTriggerHelper.isHybridOppty(setOppIDs);
            billingCaseCreate_Opp_handler.isRunonce=true;
            billingCaseCreate_Opp_handler.createContractReview(listOpp_ContractImpl,mapOppIdIsHybrid);
        }
        
        
    }
       
    //Added By Mohsin
    public static void AtiValidation(Map<Id,Opportunity> mapOfOpps){
        for(Booking_Classification__c bc : [select id,UpSell_Total__c,Renewal_Value_Total__c,Cross_Sell_Total__c,Total_NBB_Total__c,Opportunity__c from Booking_Classification__c where Opportunity__c IN :mapOfOpps.keySet()]){
            if(bc.UpSell_Total__c > 0 || bc.Renewal_Value_Total__c > 0){
                if(bc.Cross_Sell_Total__c > 0){
                    mapOfOpps.get(bc.Opportunity__c).addError('You can\'t close an opportunity before filling up the Account Transition Information.');}
            }else{
                if(bc.Cross_Sell_Total__c > 0){
                    mapOfOpps.get(bc.Opportunity__c).addError('You can\'t close an opportunity before filling up the Account Transition Information.');
                }else if(bc.Total_NBB_Total__c > 0){
                    mapOfOpps.get(bc.Opportunity__c).addError('You can\'t close an opportunity before filling up the Account Transition Information.');}
            }
        }
    }
    
    //Added By Mohsin
    public static void SendOrderToEBSValidation(Map<Id,Opportunity> mapOfOpps2){
        List<String> salesforceAppProductCodes = Label.SalesforceAppProductCodes.split(',');
        for(OpportunityLineItem oli : [SELECT Id,OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN :mapOfOpps2.keySet() AND ProductCode IN :salesforceAppProductCodes]){
            Opportunity relatedOpp = mapOfOpps2.get(oli.OpportunityId);
            if(String.isBlank(relatedOpp.SF_Org_ID__c)){
                relatedOpp.addError('Please fill the SF Org ID before marking the Opportunity as Closed Won');
            }
        }
    }

    
    //Added By Mohsin
        public static void SendSocialTablesEmailAlert(Map<Id,Opportunity> mapOfOpps3){
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            //for(ATI_Info__c ati : [select Id from ATI_Info__c where Parent_Opportunity__c IN :mapOfOpps3.keySet(0)])
            //List<Opportunity> opps = [select Id,Account.Name,Amount,(SELECT Id,Name,Product2.Name,ProductCode,OpportunityId,TotalPrice,Quantity FROM OpportunityLineItems) from Opportunity where Id IN :mapOfOpps3.keySet()];// WHERE ProductCode = 'CV-SW-EC-SCT-SCTPLNLISC' OR ProductCode = 'CV-SW-EC-SCT-SCTADDUSRLGN'
            //System.debug('SendSocialEmail-'+opps[0].OpportunityLineItems.size());
            for(Opportunity opp : [select Id,Account.Name,Owner.Name,Amount,(SELECT Id,Name,Product2.Name,ProductCode,OpportunityId,TotalPrice,Quantity FROM OpportunityLineItems WHERE ProductCode = 'CV-SW-EC-SCT-SCTPLNLISC' OR ProductCode = 'CV-SW-EC-SCT-SCTADDUSRLGN'),(Select Id,Comments__c,Main_User1__r.Name,Main_User_2__r.Name,Main_User_3__r.Name,Main_User1__r.Email,Main_User_2__r.Email,Main_User_3__r.Email,Main_User1__r.Phone,Main_User_2__r.Phone,Main_User_3__r.Phone from Account_Transition_Information__r) from Opportunity where Id IN :mapOfOpps3.keySet()]){
                if(opp.OpportunityLineItems.size() > 0){
                    String emails = '';
                    String numbers = '';
                    String mainUser = '';
                    String additionalComments = '';
                    if(opp.Account_Transition_Information__r.size() > 0){
                        for(ATI_Info__c ati : opp.Account_Transition_Information__r){
                            //Collecting Email Addresses
                            if(String.isBlank(emails)){
                                if(String.isNotBlank(ati.Main_User1__r.Email)){
                                    emails = ati.Main_User1__r.Email;}
                                if(String.isNotBlank(ati.Main_User_2__r.Email)){
                                    emails = emails+', '+ati.Main_User_2__r.Email;}
                                if(String.isNotBlank(ati.Main_User_3__r.Email)){
                                    emails = emails+', '+ati.Main_User_3__r.Email;}
                            }
                            else
                            {if(String.isNotBlank(ati.Main_User1__r.Email)){
                                    emails = emails+', '+ati.Main_User1__r.Email;}
                                if(String.isNotBlank(ati.Main_User_2__r.Email)){
                                    emails = emails+', '+ati.Main_User_2__r.Email;}
                                if(String.isNotBlank(ati.Main_User_3__r.Email)){
                                    emails = emails+', '+ati.Main_User_3__r.Email; }
                            }
                            
                            //Collecting Phone Numbers
                            if(String.isBlank(numbers)){
                                if(String.isNotBlank(ati.Main_User1__r.Phone)){
                                    numbers = ati.Main_User1__r.Phone;}
                                if(String.isNotBlank(ati.Main_User_2__r.Phone)){
                                    numbers = numbers+','+ati.Main_User_2__r.Phone;}
                                if(String.isNotBlank(ati.Main_User_3__r.Phone)){
                                    numbers = numbers+','+ati.Main_User_3__r.Phone;}
                            }else{
                                if(String.isNotBlank(ati.Main_User1__r.Phone)){
                                    numbers = numbers+','+ati.Main_User1__r.Phone;}
                                if(String.isNotBlank(ati.Main_User_2__r.Phone)){
                                    numbers = numbers+','+ati.Main_User_2__r.Phone;}
                                if(String.isNotBlank(ati.Main_User_3__r.Phone)){
                                    numbers = numbers+','+ati.Main_User_3__r.Phone;}
                            }
                            
                            //Main User Name
                            if(String.isBlank(mainUser)){
                                if(String.isNotBlank(ati.Main_User1__r.Name)){
                                    mainUser = ati.Main_User1__r.Name;}
                                 if(String.isNotBlank(ati.Main_User_2__r.Name)){
                                    mainUser = mainUser+','+ati.Main_User_2__r.Name;}
                                if(String.isNotBlank(ati.Main_User_3__r.Name)){
                                    mainUser = mainUser+','+ati.Main_User_3__r.Name;}
                            }else{
                                if(String.isNotBlank(ati.Main_User1__r.Name)){
                                    mainUser = mainUser+','+ati.Main_User1__r.Name;
                                }
                                if(String.isNotBlank(ati.Main_User_2__r.Name)) {
                                    mainUser = mainUser+','+ati.Main_User_2__r.Name;
                                }
                                if(String.isNotBlank(ati.Main_User_3__r.Name)){
                                    mainUser = mainUser+','+ati.Main_User_3__r.Name;
                                }
                            }
                            
                             //Main Additional Comments
                            if(String.isBlank(additionalComments)){
                                if(String.isNotBlank(ati.Comments__c)){
                                    additionalComments = ati.Comments__c;
                                }
                            }else {
                                if(String.isNotBlank(ati.Comments__c)){
                                    additionalComments = additionalComments+','+ati.Comments__c;
                                }
                            }
                        }
                    }
                    Decimal totalAmount = 0;
                    Decimal quantityOfSocialTablesPlannerLicense = 0;
                    Decimal userCount = 0;
                    for(OpportunityLineItem oli : opp.OpportunityLineItems) {
                        totalAmount += oli.TotalPrice;
                        if(oli.ProductCode == 'CV-SW-EC-SCT-SCTPLNLISC'){
                            quantityOfSocialTablesPlannerLicense = oli.Quantity;
                            userCount += 5.0;}
                        else{
                            userCount += oli.Quantity;
                        }
                        System.debug('usercount=='+userCount);
                    }
                    String bodyText = '';
                    bodyText = 'Account Name - '+opp.Account.Name+'<br />Opportunity Owner -'+opp.Owner.Name+'<br/ >Total Booking Amount – '+opp.Amount+'<br/ >ST Booking Amount – '+totalAmount+'<br/ ># of Events purchased – '+quantityOfSocialTablesPlannerLicense+'<br/ >User Count – '+userCount+'<br/ >Email Addresses – '+emails+'<br/ >Phone Numbers – '+numbers+'<br/ >User Names – '+mainUser+'<br/ >Detail Promises, Expectations or Helpful Notes – '+additionalComments;
                    List<String> emailAddresses = Label.SocialTablesSupportEmails.split(',');
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setToAddresses(emailAddresses);
                    message.optOutPolicy = 'FILTER';
                    message.subject = 'New Social Tables Implementation -'+opp.Account.Name;
                    message.setHtmlBody(bodyText);
                    messages.add(message);
                }
            }
            if(!messages.isEmpty()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                if (results[0].success){
                    System.debug('The email was sent successfully.');
                }
                else {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }
            }
        }
        
        //Added By Mohsin
        public static void populateRenewalSpecialist(List<Opportunity> newValues){
            Id renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            Map<Id,Opportunity> listOfOpp = new Map<Id,Opportunity>();
            Map<Id,Id> listOfAccIdVsOpp = new Map<Id,Id>();
            Map<Id,String> listOfOppVsRS = new Map<Id,String>();
            for(Opportunity opp : newValues){
                if(opp.RecordTypeId == renewalRecordTypeId) {
                    listOfOpp.put(opp.Id,opp);
                    listOfAccIdVsOpp.put(opp.AccountId,opp.Id); }
            }

            if(!listOfAccIdVsOpp.isEmpty()) {
                for(Account acc : [select Id,Named_Acct__c,(select id,User.Name,AccountId,TeamMemberRole FROM AccountTeamMembers where TeamMemberRole='AM - Renewal Specialist' LIMIT 1) from Account where Id IN :listOfAccIdVsOpp.keySet()]){
                    if(acc.Named_Acct__c != null && acc.Named_Acct__c.containsIgnoreCase('Tpp Client')){
                        if(!acc.AccountTeamMembers.isEmpty()){
                            listOfOpp.get(listOfAccIdVsOpp.get(acc.Id)).Renewal_Specialist__c = acc.AccountTeamMembers[0].User.Name;
                        }            
                    }
                }
            }
        }
    
        //Added By Mohsin
        public static void renewalDateAutomationBeforeInsert(List<Opportunity> newValues){
            Id renewalRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
            List<Opportunity> listOfSelectedOpps = new List<Opportunity>();
                List<Opportunity> listOfSelectedOpps2 = new List<Opportunity>();
                for(Opportunity opp : newValues){
                    if(opp.RenewalDate__c != NULL && opp.RecordTypeId == renewalRTId){
                        listOfSelectedOpps.add(opp);}
                    if(opp.ContractEndDate__c != NULL && opp.RecordTypeId == renewalRTId){
                        listOfSelectedOpps2.add(opp);}
                }
                if(!listOfSelectedOpps.isEmpty()){
                    for(Opportunity opp : listOfSelectedOpps){
                        if(opp.RenewalDate__c > System.today()){
                            opp.CloseDate = opp.RenewalDate__c;}
                    }
                }
                if(!listOfSelectedOpps2.isEmpty() || Test.isRunningTest()){
                    Map<Id,Opportunity> mapOfOpps = new Map<Id,Opportunity>([select id,SBQQ__PrimaryQuote__r.Contract_Executed_Date__c from Opportunity where Id IN :listOfSelectedOpps2]);
                    for(Opportunity opp : listOfSelectedOpps2){
                        if(opp.ContractEndDate__c < System.today()){
                            opp.CloseDate = mapOfOpps.get(opp.Id).SBQQ__PrimaryQuote__r.Contract_Executed_Date__c; 
                        }
                    }
                }
        }

        public static void renewalDateAutomationBeforeUpdate(List<Opportunity> newValues) {
            List<Opportunity> listOfSelectedOpps = new List<Opportunity>();
                for(Opportunity opp : newValues){
                    if(opp.RenewalDate__c != NULL){
                        listOfSelectedOpps.add(opp);}
                }
                if(!listOfSelectedOpps.isEmpty()){
                    Map<Id,Opportunity> mapOfOpps = new Map<Id,Opportunity>([select id,SBQQ__PrimaryQuote__r.Contract_Executed_Date__c from Opportunity where Id IN :listOfSelectedOpps]);
                    for(Opportunity opp : listOfSelectedOpps){
                        if(opp.RenewalDate__c > System.today()){
                            opp.CloseDate = opp.RenewalDate__c;}
                        else if(opp.RenewalDate__c < System.today()){
                            System.debug('today is greater');
                            if(mapOfOpps.get(opp.Id).SBQQ__PrimaryQuote__r.Contract_Executed_Date__c != NULL){
                                if(System.today() > mapOfOpps.get(opp.Id).SBQQ__PrimaryQuote__r.Contract_Executed_Date__c){
                                    System.debug('Inside of contract executed date condition');
                                    opp.CloseDate = mapOfOpps.get(opp.Id).SBQQ__PrimaryQuote__r.Contract_Executed_Date__c;}
                                else{
                                    opp.CloseDate = System.today();}
                            }else{
                                opp.CloseDate = System.today();}
                        }
                    }
                }
        }

    /**
    **  Added by Udita : TICCM-1018 - Sucess Experience Product
    **  Added by Shanu : TICCM-1106 - Success Experience
    **/
    public static void successExperienceProductRollup(List<Opportunity> newValues,Map<Id,Opportunity> newMapOpp,Map<Id,Opportunity> oldMapOpp){
            
        Map<Id,Id> accVsOppMap = new Map<Id,Id>();
        Set<String> regionNames = new Set<String>();
        String calcTargetExperience;
        String calcDUNSexperience;
        String calcSuccessExperience;
        
        Map<Id,Account> accMap = new Map<Id,Account>();
        Map<Id,Account> updateAccountMap = new Map<Id,Account>();
        Map<String,Integer> expVsLevelMap = new Map<String,Integer>();
        
        //Stores the highest success experience for the duns number
        Map<String,Account> dunsVsHighestExperienceMap = new Map<String,Account>();
        //Map for Account Notifcations
        Map<Id,String> accounIdVsTypeMap = new Map<Id,String>();
        Map<Id,Id> lostOpptyIdsMap = new Map<Id,Id>();
        
        for(Opportunity opp : newValues){
            if((opp.stageName!=oldMapOpp.get(opp.id).stageName) && opp.Opportunity_Type__c == 'NBB' && (opp.StageName.contains('Closed') || opp.StageName == 'Verbal')){
               accVsOppMap.put(opp.AccountId, opp.Id);
            }
            //To Skip Lost Opportunities from Success Calculation
            if(opp.IsWon==False && opp.IsClosed==True){lostOpptyIdsMap.put(opp.AccountId,opp.Id);}   
        }
        
        system.debug('$$$$ accVsOppMap $$$$'+ accVsOppMap);
        
        //Get Products 
        if(!accVsOppMap.isEmpty()){
                     
            Map<Id,Set<String>> accVsLineCategMapMap = new Map<Id,Set<String>>();
            Map<Id,Decimal> accVsLineRevenueMap = new Map<Id,Decimal>();
            
            for(OpportunityLineItem line : [Select Id,OpportunityId,Annual_Recurring_Revenue__c,Product2.Success_Experience_Category__c,Product_Name__c,ProductCode,Opportunity.AccountID,Product2.Name,Product2.Success_Experience_Product__c,Opportunity.Account.Success_Experience_Account_Value__c,
            Opportunity.Account.Success_Experience_Region__c,Opportunity.Account.Success_Experience_Products__c,Opportunity.Account.Account_Cloud__c, Opportunity.Account.Named_Acct__c, Opportunity.Account.Success_Experience_Override__c,Opportunity.Opportunity_Type__c,
            Opportunity.Account.Global_Ultimate_DUNS__c, Opportunity.Account.Success_Experience__c, Opportunity.Account.Success_Experience_Opportunity__c,SBQQ__QuoteLine__r.Revenue_Type__c,
            SBQQ__QuoteLine__r.Product_Group__c ,SBQQ__QuoteLine__r.SBQQ__EffectiveStartDate__c,SBQQ__QuoteLine__r.SBQQ__EffectiveEndDate__c,SBQQ__QuoteLine__r.SBQQ__Group__c,SBQQ__QuoteLine__r.SBQQ__Group__r.SBQQ__Optional__c,SBQQ__QuoteLine__r.Primary_Quote_Line__c,convertCurrency(SBQQ__QuoteLine__r.Annual_Recurring_Revenue__c) from OpportunityLineItem where 
            ((Product2.Success_Experience_Product__c = TRUE  AND Product2.Success_Experience_Category__c != NULL ) OR 
            (SBQQ__QuoteLine__r.Product_Group__c = 'Event Cloud' AND SBQQ__QuoteLine__r.Revenue_Type__c ='Annual Recurring' /*AND SBQQ__QuoteLine__r.SBQQ__EffectiveStartDate__c <= Today*/ and SBQQ__QuoteLine__r.SBQQ__EffectiveEndDate__c >= Today AND (SBQQ__QuoteLine__r.SBQQ__Group__c = null or SBQQ__QuoteLine__r.SBQQ__Group__r.SBQQ__Optional__c = False) 
            AND SBQQ__QuoteLine__r.Primary_Quote_Line__c= true)) AND Opportunity.AccountId IN : accVsOppMap.keySet() AND Opportunity.Probability>=80]){
           
            //The automation should only run if this field is unhecked so that user can change these fields manually.
                if(line.Opportunity.Account.Success_Experience_Override__c==false){
                    
                    //Calculate Success Products
                    if(line.Product2.Success_Experience_Product__c == TRUE  && line.Product2.Success_Experience_Category__c !=null){
                        if(!accVsLineCategMapMap.containsKey(line.Opportunity.AccountID)){
                            accVsLineCategMapMap.put(line.Opportunity.AccountID,new set<string>{line.Product2.Success_Experience_Category__c});
                        }else{
                            accVsLineCategMapMap.get(line.Opportunity.AccountID).add(line.Product2.Success_Experience_Category__c);
                        }
                    }
                    
                   
                   //Calculate Success Account Value
                   if(line.SBQQ__QuoteLine__r.Product_Group__c == 'Event Cloud'  && line.SBQQ__QuoteLine__r.Revenue_Type__c =='Annual Recurring' && (line.Opportunity.Opportunity_Type__c=='NBB' || line.SBQQ__QuoteLine__r.SBQQ__EffectiveStartDate__c <= system.Today()) && line.SBQQ__QuoteLine__r.SBQQ__EffectiveEndDate__c >= system.Today() && (line.SBQQ__QuoteLine__r.SBQQ__Group__c == null || line.SBQQ__QuoteLine__r.SBQQ__Group__r.SBQQ__Optional__c == False) && line.SBQQ__QuoteLine__r.Primary_Quote_Line__c== true){
                        if(!accVsLineRevenueMap.containsKey(line.Opportunity.AccountID)){
                            accVsLineRevenueMap.put(line.Opportunity.AccountID,line.SBQQ__QuoteLine__r.Annual_Recurring_Revenue__c);
                        }else{
                            accVsLineRevenueMap.put(line.Opportunity.AccountID,(accVsLineRevenueMap.get(line.Opportunity.AccountID) + line.SBQQ__QuoteLine__r.Annual_Recurring_Revenue__c));
                        }
                    }
                   
                    accMap.put(line.Opportunity.AccountID, line.Opportunity.Account);
                    
                    //Calculate Success Experience
                    if(!lostOpptyIdsMap.containsKey(line.Opportunity.AccountId)){
                        regionNames.add('\''+ line.Opportunity.Account.Success_Experience_Region__c +'\''); 
                        if(line.Opportunity.Account.Global_Ultimate_DUNS__c!=null)
                            dunsVsHighestExperienceMap.put(line.Opportunity.Account.Global_Ultimate_DUNS__c,null);
                    }                   
                }
            }
            
            /** TICCM-1106 - 1st Part - Sucess Experience Evaluation
            **  Sucess Experience High Touch, Full Service, Advised, Guided calculation based on DUNS, Setup table
            **  Added on 11/26/2019 - Added by Shanu 
            **/
            regionNames.remove(null);
            //Get Success Experience Rules for calculation - Region vs List of Setup Experience
            Map<String,List<Success_Experience_Setup__c>> regionVsSetupMap = new Map<String,List<Success_Experience_Setup__c>>();            
            system.debug('$$$$ regionNames $$$$'+ regionNames);   
                     
            if(regionNames.size()>0){
                //Filters the setup table based on the regions from account 
                List<String> regionList = new List<String>();
                regionList.addAll(regionNames);
                
                for(Success_Experience_Setup__c setup : Database.Query('Select Id,Region__c,Rule_Reason__c,Target_Success_Experience__c,Level__c,Account_Value_Higher_Threshold__c, Account_Value_Lower_Threshold__c,Named_Account__c,Products__c,Number_of_Products_Lower_Threshold__c,Number_of_Products_Higher_Threshold__c from Success_Experience_Setup__c where Region__c includes ('+ String.join(regionList, ',') +') Order by Level__c DESC, Account_Value_Higher_Threshold__c DESC NULLS LAST')){
                     for(String reg : setup.Region__c.split(';')){
                        if(!regionVsSetupMap.containsKey(reg))
                            regionVsSetupMap.put(reg, new List<Success_Experience_Setup__c>{setup});
                        else
                            regionVsSetupMap.get(reg).add(setup);
                    }
                    
                    //Store Target Experience vs Level for comparison
                    expVsLevelMap.put(setup.Target_Success_Experience__c, Integer.valueOf(setup.Level__c));
                }
                
                system.debug('$$$$ expVsLevelMap $$$$'+ expVsLevelMap);
                
                //Get Accounts related to current DUNS number, except from current accounts
                if(!dunsVsHighestExperienceMap.isEmpty() && !regionVsSetupMap.isEmpty()){
                    for(Account dunsAcc : [Select Success_Experience__c,Success_Experience_Opportunity__c, Global_Ultimate_DUNS__c From Account Where Global_Ultimate_DUNS__c IN:dunsVsHighestExperienceMap.keySet() AND Success_Experience__c!=null AND ID NOT IN :accVsOppMap.keySet()]){
                        //Stores the highest sucess experience value among all accounts per DUNS number
                        if(dunsVsHighestExperienceMap.get(dunsAcc.Global_Ultimate_DUNS__c)==null || (expVsLevelMap.get(dunsAcc.Success_Experience__c) > expVsLevelMap.get(dunsVsHighestExperienceMap.get(dunsAcc.Global_Ultimate_DUNS__c).Success_Experience__c))){
                            dunsVsHighestExperienceMap.put(dunsAcc.Global_Ultimate_DUNS__c,dunsAcc);
                        }
                    }
                }
                system.debug('$$$$ dunsVsHighestExperienceMap $$$$'+ dunsVsHighestExperienceMap);
            }
                  
            
            //Processing Accounts
            for(Account acc : accMap.values()){
                
                system.debug('$$$$ accVsLineCategMapMap $$$$'+ accVsLineCategMapMap);
                system.debug('$$$$ accVsLineRevenueMap $$$$'+ accVsLineRevenueMap);     
                
                //TICCM-1110 - For Success Experience Products
                if(accVsLineCategMapMap.containsKey(acc.id)){
                   acc.Success_Experience_Products__c = String.join(new list<String>(accVsLineCategMapMap.get(acc.id)),';');  
                   updateAccountMap.put(acc.Id,acc);
                } 
                
                
                //TICCM-1111 : For Annual Recurring value 
                if(accVsLineRevenueMap.containsKey(acc.id)){
                    acc.Success_Experience_Account_Value__c = accVsLineRevenueMap.get(acc.Id);
                    updateAccountMap.put(acc.Id,acc);
                }
                system.debug('&&&&&&&&&&& Success_Experience_Products__c &&&&&&' + acc.Success_Experience_Products__c);
                
                /** TICCM-1106 - Success Experience Value 
                **  2nd Part - Sucess Experience High Touch, Full Service, Advised, Guided calculation based on DUNS, Setup table
                **  Added on 11/26/2019 - Added by Shanu 
                **/
                if(!regionVsSetupMap.isEmpty() && regionVsSetupMap.containsKey(acc.Success_Experience_Region__c) && acc.Success_Experience_Account_Value__c!=null && acc.Success_Experience_Products__c!=null && !lostOpptyIdsMap.containsKey(acc.Id)){
                    
                    Set<String> namedAcctCommonSet;
                    Set<String> accProductsSet;
                    Set<String> setupProductsSet;
                    Success_Experience_Setup__c calcTargetSetup;
                    
                    //Calculate Target Success Experience
                    for(Success_Experience_Setup__c setup : regionVsSetupMap.get(acc.Success_Experience_Region__c)){
                        
                        //Get Named Accounts
                        if(acc.Named_Acct__c!=null && setup.Named_Account__c!=null){
                            namedAcctCommonSet = new Set<String>(acc.Named_Acct__c.split(';'));
                            namedAcctCommonSet.retainAll(setup.Named_Account__c.split(';'));
                        }
                        //Get Account Products
                        if(setup.Products__c!=null){
                            accProductsSet = new Set<String>(acc.Success_Experience_Products__c.split(';'));
                            setupProductsSet = new Set<String>(setup.Products__c.split(';'));
                        }
                    
                        system.debug('&&&&&&&&&&& accProductsSet &&&&&&' + accProductsSet);
                        system.debug('&&&&&&&&&&& setupProductsSet &&&&&&' + setupProductsSet);
                        
                        //Success Experience Setup Evaluation:
                        //1. Region is already Matched - by Filtering Region in SOQL
                        //2. Account Value
                        if((acc.Success_Experience_Account_Value__c >=setup.Account_Value_Lower_Threshold__c && acc.Success_Experience_Account_Value__c <=setup.Account_Value_Higher_Threshold__c) ||
                        //3. Named Account    (Contains Any)
                        (namedAcctCommonSet!=null && !namedAcctCommonSet.isEmpty()) ||
                        //4. Success Products (Exach Match)
                        (accProductsSet!=null && (accProductsSet.equals(setupProductsSet) ||
                        //5. Number of Products 
                        (accProductsSet.size() >= setup.Number_of_Products_Lower_Threshold__c && accProductsSet.size() <= setup.Number_of_Products_Higher_Threshold__c)))){
                            calcTargetExperience = setup.Target_Success_Experience__c ; 
                            calcTargetSetup = setup;
                            break;
                        }
                    }       
                    
                    //Calculate DUNS Experience
                    if(dunsVsHighestExperienceMap.containsKey(acc.Global_Ultimate_DUNS__c) && dunsVsHighestExperienceMap.get(acc.Global_Ultimate_DUNS__c)!=null){
                        calcDUNSexperience = dunsVsHighestExperienceMap.get(acc.Global_Ultimate_DUNS__c).Success_Experience__c;
                    }
                    
                    system.debug('$$$$$ calcTargetExperience $$$' + calcTargetExperience);
                    system.debug('$$$$ calcDUNSexperience $$$$'+ calcDUNSexperience);
                    
                    /** 
                    ** Populate Sucess Experience here (only if target experience is not blank)
                    **/
                    if(String.isNotBlank(calcTargetExperience)){
                        
                        /** 
                        ** Success Experience Comparison
                        **/
                        //By Default calculated experience is target experience
                        calcSuccessExperience = calcTargetExperience;
                        acc.Success_Experience_Reason__c = calcTargetSetup.Rule_Reason__c;
                        
                        //Override Calculated expe If DUNS Experience is greater than Target experience
                        if(String.isNotBlank(calcDUNSexperience) && expVsLevelMap.get(calcDUNSexperience) > expVsLevelMap.get(calcTargetExperience)){
                            calcSuccessExperience = calcDUNSexperience;
                            acc.Success_Experience_Reason__c = 'Inherited experience from DUNS Family';
                        }
                        
                        /** 
                        ** Success Experience Assignment 
                        **/
                        // Guided -     
                        if((calcSuccessExperience == 'Guided' && (acc.Success_Experience__c==null || accVsOppMap.get(acc.Id)==acc.Success_Experience_Opportunity__c)) || 
                        // Advised - 
                        (calcSuccessExperience == 'Advised' && (acc.Success_Experience__c==null || acc.Success_Experience__c=='Guided' || (acc.Success_Experience__c=='High Touch' && accVsOppMap.get(acc.Id)==acc.Success_Experience_Opportunity__c))) ||
                        // High Touch -
                        (calcSuccessExperience == 'High Touch' && ((acc.Success_Experience__c=='Guided' || String.isBlank(acc.Success_Experience__c)) || (acc.Success_Experience__c=='Advised' && accVsOppMap.get(acc.Id)==acc.Success_Experience_Opportunity__c)))){
                        
                            acc.Success_Experience__c = calcSuccessExperience;
                            acc.Success_Experience_Opportunity__c = accVsOppMap.get(acc.Id);
                            acc.Success_Experience_Date__c = system.today();
                            acc.Success_Populated_From_Code__c = true;
                            updateAccountMap.put(acc.Id,acc);
                            
                            //DUNS Notification - If Calculated Experience is higher than DUNS Experience
                            if (String.isNotBlank(calcDUNSexperience) && expVsLevelMap.get(calcSuccessExperience) > expVsLevelMap.get(calcDUNSexperience) && dunsVsHighestExperienceMap.get(acc.Global_Ultimate_DUNS__c).Id !=acc.Id){
                                accounIdVsTypeMap.put(dunsVsHighestExperienceMap.get(acc.Global_Ultimate_DUNS__c).Id, 'DUNNotify');
                            } 
                        }
                        //HT Notifcation - Advised to HT 
                        else if (calcSuccessExperience == 'High Touch' && acc.Success_Experience__c=='Advised' && accVsOppMap.get(acc.Id)!=acc.Success_Experience_Opportunity__c){
                            accounIdVsTypeMap.put(acc.Id, 'HTNotify');
                        }
                                      
                    }
                }     
                
                system.debug('$$$$ calcSuccessExperience $$$$'+ calcSuccessExperience);
                
            }
            system.debug('$$$$ accounIdVsTypeMap $$$$'+ accounIdVsTypeMap);
            system.debug('---updateAccountMap----'+ updateAccountMap);
            //Update Account
            if(!updateAccountMap.isEmpty()){
                update updateAccountMap.values();
            }
            //Notification Send
            if(!accounIdVsTypeMap.isEmpty()){
                successExperienceEmailNotification(accounIdVsTypeMap);
            }
        }
    }
    
    //Notification : TICCM-1106 : Udita
    public static void successExperienceEmailNotification(Map<Id,String> accounIdVsTypeMap){

            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();            
            List<setEmailParameters> parameterList = new List<setEmailParameters>();
            
            // map of template label
            Map<String,Id> templateTypeVsId = new Map<String,Id>();
            templateTypeVsId.put('HTNotify',Label.HTNotify);
            templateTypeVsId.put('DUNNotify',Label.DUNNotify);
            
            for(AccountTeamMember accTeam : [Select Id, AccountId, TeamMemberRole , User.Email, User.Name, UserId  From  AccountTeamMember Where AccountId =:accounIdVsTypeMap.keySet()]){
                   parameterList.add(new setEmailParameters(accTeam.AccountId, accTeam.UserId,accounIdVsTypeMap.get(accTeam.AccountId),accTeam.User.Email));
            }
            
            for(SetEmailParameters param : parameterList){
                Messaging.SingleEmailMessage message =  new Messaging.SingleEmailMessage();
                message.setToAddresses(new string[] {param.emailId});             
                message.setTemplateId(id.valueOf(templateTypeVsId.get(param.templateType)));
                message.setTargetObjectId(param.userId);
                message.setSaveAsActivity(false);
                message.setWhatId(param.accountId);
                messages.add(message);
            }
            
            if(messages.size()>0){
                Messaging.sendEmail(messages);
            } 
        
     }
        
     public class SetEmailParameters {
          public Id accountId;
          public Id userId;
          public String templateType;
          public String emailId;
            
          public setEmailParameters(id accountId,id UserId,string templateType,string EmailId) {
            this.accountId = accountId;
            this.userId = UserId;
            this.templateType = templateType;
            this.emailId = EmailId;
          }
     }
     
}// end of class