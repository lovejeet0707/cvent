/*Version 24.0
Date:7th Nov 2016
Description : Migrating FEATURESET to PRODUCT/PRICEBOOK. Below are the name of the field which needs to be replaced - 
    OLD FIELD NAME       = NEW FIELD NAME
    Feature_Sets__r      = OpportunityLineItems;
    R00N00000008aGEXEA2  = OpportunityLineItems;
    Feature_Set__c       = OpportunityLineItem;
    Opportunity_N__c     = OpportunityId; 
    Feature__c           = Product_Name__c; (IMP : CAN'T DO CTRL+F AND CTRL+R AND NEED TO CHECK BEFORE REPLACING AS THEIR IS A CUSTOM SETTING OF SAME NAME "Feature__c")
    
//Lines Commented as Can't update CurrencyISOCode of OpportunityLineItem
*/
public class billingCaseCreate_Opp_handler {
    Public Static Boolean isRunOnce1=false;
    public static void oppAutomationYear1_Method(List<Opportunity> opportunityList)
    {
        Set<Id> opportunityOwnerIdSet=new Set<Id>();
        Map<Id,Account> accIdVsAccountObj= new Map<Id,Account>();
        Map<Id,String> userIdVsCountryName= new Map<Id,String>();
        Set<Id> accountIdSet= new Set<Id>();
        Set<Id> oppIdSet=new Set<Id>();
        Set<String> featureSet = new Set<String>();
        Map<Id,String> oppIdVsEarlyContract=new Map<Id,String>();
        For(FeatureSet__c ft : FeatureSet__c.getall().values())
        {
            featureSet.add(ft.FeatureSet__c);
        }
        System.debug('featureSet==========>>>>'+featureSet);
        system.debug('*******------------------>'+opportunityList);
        For(Opportunity oppObj : opportunityList)
        {
            system.debug('===============>'+oppObj.Contract_Number_New__c);
            oppIdSet.add(oppObj.Id);
            if(oppObj.AccountId!=null){//oppObj.Contract_Implemented__c && 
                if(!accountIdSet.contains(oppObj.AccountId))
                    accountIdSet.add(oppObj.AccountId);
            }
            system.debug('*************-------->'+oppObj.Deal_Closed_by__c);
            if(oppObj.Deal_Closed_by__c!=null){
                opportunityOwnerIdSet.add(oppObj.OwnerId);
                opportunityOwnerIdSet.add(oppObj.Deal_Closed_by__c);
            }
        }
        For(OpportunityLineItem featureSetRec : [SELECT Id ,OpportunityId ,Product_Name__c FROM OpportunityLineItem WHERE OpportunityId  IN :  oppIdSet and Product_Name__c IN : featureSet]){
            if(!oppIdVsEarlyContract.containsKey(featureSetRec.OpportunityId )){
                oppIdVsEarlyContract.put(featureSetRec.OpportunityId  , featureSetRec.Product_Name__c);
            }
        }
        System.debug('oppIdVsEarlyContract=======>>'+oppIdVsEarlyContract);
        if(opportunityOwnerIdSet.size()>0 && opportunityOwnerIdSet!=null)
        {
            For(User userRecord : [SELECT Id,Country FROM User WHERE Id IN :opportunityOwnerIdSet AND Country !=null]){userIdVsCountryName.put(userRecord.Id,userRecord.Country); }// && Profile_Name__c LIKE '%Sales Representative%'
        }
        if(accountIdSet.size()>0 && accountIdSet!=null){
            For(Account accRecord:[SELECT Id,Affiliate_Name__c,Advertising_Agency__c,Chain_Affiliation__c,Other_Chain__c,Brand__c,Management_Company__c FROM Account WHERE id in :accountIdSet])
            {
                accIdVsAccountObj.put(accRecord.Id,accRecord);
            }
        }
        For(Opportunity oppObj : opportunityList){
            System.debug('oppIdVsEarlyContract.containsKey(oppObj.Id)=======>>>>'+oppIdVsEarlyContract.containsKey(oppObj.Id));
            if(oppObj.ContractStartDate__c!=null && oppObj.ContractReceived__c!=null)
                oppObj.Early_Contract__c=oppIdVsEarlyContract.containsKey(oppObj.Id)?'Not Early':(oppObj.ContractReceived__c.daysBetween(oppObj.ContractStartDate__c)>89?'Early':'Not Early');
            /*.............................For the Close Date.........................................*/
            if(oppIdVsEarlyContract.containsKey(oppObj.Id) && oppObj.ContractReceived__c!=null && UserInfo.getUserName() != Label.UserBypassQM)
            {
                oppObj.CloseDate=oppObj.ContractReceived__c;
            }
            else if((oppObj.NBB_Renewal__c!=null && oppObj.NBB_Renewal__c=='Renewal') && (oppObj.Early_Contract__c!=null && oppObj.Early_Contract__c=='Not Early') && oppObj.RenewalDate__c!=null)
            {
                System.debug('#Checkpoint 2');
                System.debug('RecievedMonth minus 1'+(oppObj.ContractReceived__c.month()-1));
                System.debug('RenewalMonth minus 1'+oppObj.RenewalDate__c.month());
                if(oppObj.ContractReceived__c!=null && (oppObj.RenewalDate__c.month() < oppObj.ContractReceived__c.month()) && UserInfo.getUserName() != Label.UserBypassQM)
                {
                    System.debug('#Checkpoint 3');
                    oppObj.CloseDate=oppObj.ContractReceived__c;
                }
                else
                {
                    oppObj.CloseDate=oppObj.RenewalDate__c;
                }
   /*Starts FROM Here..............*/
if(oppObj.RenewalDate__c.year() == oppObj.ContractReceived__c.year())
{
    if(oppObj.RenewalDate__c.month() == oppObj.ContractReceived__c.month()){
        
        oppObj.CloseDate=oppObj.RenewalDate__c;
    }
    else if(oppObj.RenewalDate__c.month() < oppObj.ContractReceived__c.month() && UserInfo.getUserName() != Label.UserBypassQM){
        oppObj.CloseDate=oppObj.ContractReceived__c;
    }
    else{
        oppObj.CloseDate=oppObj.RenewalDate__c;
    }
}
else if(oppObj.RenewalDate__c.year() < oppObj.ContractReceived__c.year() && UserInfo.getUserName() != Label.UserBypassQM )
{
    if(oppObj.RenewalDate__c.month() < oppObj.ContractReceived__c.month()){
        oppObj.CloseDate=oppObj.ContractReceived__c;
    }
    else{
        oppObj.CloseDate=oppObj.ContractReceived__c;
    }
}
else{
    oppObj.CloseDate=oppObj.RenewalDate__c;
}
/*Ends Here............*/
            }
            /*else if((oppObj.NBB_Renewal__c!=null && oppObj.NBB_Renewal__c=='Renewal') && (oppObj.Early_Contract__c!=null && oppObj.Early_Contract__c=='Early') && oppObj.RenewalDate__c!=null)
            {
                System.debug('#Checkpoint 2');
                System.debug('RecievedMonth minus 1'+(oppObj.ContractReceived__c.month()-1));
                System.debug('RenewalMonth minus 1'+oppObj.RenewalDate__c.month());
                if(oppObj.ContractReceived__c!=null && (oppObj.RenewalDate__c < oppObj.ContractReceived__c))
                {
                    System.debug('#Checkpoint 3');
                    oppObj.CloseDate=oppObj.ContractReceived__c;
                }
                else
                {
                    oppObj.CloseDate=oppObj.RenewalDate__c;
                }
            }
            else if(((oppObj.NBB_Renewal__c!=null && (oppObj.NBB_Renewal__c=='NBB' || oppObj.NBB_Renewal__c=='Renewal')) || (oppObj.Parent_Upsell__c!=null && oppObj.Parent_Upsell__c!='Primary'))&& (oppObj.Early_Contract__c!=null && oppObj.Early_Contract__c=='Early'))
            {
                if(oppObj.ContractStartDate__c!=null)
                {
                    oppObj.CloseDate=oppObj.ContractStartDate__c;
                }
            }*/
            else if((oppObj.MYD_Deal__c=='First Year' && oppObj.MYD_Deal__c!=null) && (oppObj.NBB_Renewal__c=='Renewal' && oppObj.NBB_Renewal__c!=null) && (oppObj.Early_Contract__c=='Early' && oppObj.Early_Contract__c!=null) && (oppObj.Parent_Upsell__c!=null && (oppObj.Parent_Upsell__c=='Primary' || oppObj.Parent_Upsell__c=='Upsell')) && oppObj.ContractReceived__c!=null)
            {
                
                if(oppObj.RenewalDate__c!=null && oppObj.ContractStartDate__c!=null && oppObj.ContractReceived__c.addDays(90)<oppObj.RenewalDate__c && oppObj.ContractReceived__c.addDays(90)<oppObj.ContractStartDate__c)
                {
                    if(oppObj.RenewalDate__c<oppObj.ContractStartDate__c)
                    {oppObj.CloseDate=oppObj.RenewalDate__c;}
                    else
                    {oppObj.CloseDate=oppObj.ContractStartDate__c;}
                }
                else if(oppObj.RenewalDate__c!=null && oppObj.ContractReceived__c.addDays(90)<oppObj.RenewalDate__c)
                {
                    oppObj.CloseDate=oppObj.RenewalDate__c;
                }
                else if(oppObj.ContractStartDate__c!=null && oppObj.ContractReceived__c.addDays(90)<oppObj.ContractStartDate__c)
                {
                    oppObj.CloseDate=oppObj.ContractStartDate__c;
                }
            }
            else if(oppObj.ContractReceived__c!=null && UserInfo.getUserName() != Label.UserBypassQM )
            {
                oppObj.CloseDate=oppObj.ContractReceived__c;
            }
            /*..................................Ends Here.............................................*/
            
            
            
            
            //oppObj.CloseDate=()?oppObj.ContractReceived__c:((oppObj.Early_Contract__c!=null && oppObj.Early_Contract__c=='Early')?(oppObj.ContractStartDate__c!=null?oppObj.ContractStartDate__c:oppObj.CloseDate):(oppObj.ContractReceived__c!=null?oppObj.ContractReceived__c:oppObj.CloseDate));
            System.debug('oppObj.CloseDate====='+oppObj.CloseDate);
            // oppObj.CloseDate=(oppObj.Early_Contract__c=='Early'?oppObj.ContractStartDate__c:oppObj.ContractReceived__c);
            //DateTime closeDateTime = oppObj.CloseDate;
            //oppObj.Name=closeDateTime.format('MMM')+' '+oppObj.CloseDate.Year()+' '+(oppObj.Early_Contract__c=='Not Early'?' ':'Early')+' '+(oppObj.Parent_Upsell__c=='Upsell'?'Upsell':oppObj.NBB_Renewal__c)+' '+(oppObj.Years__c=='1'?' ':(' Year '+oppObj.Deal_Year__c+' of '+oppObj.Years__c));//((oppObj.Years__c<oppObj.Deal_Year__c?' Of'+oppObj.Years__c:''))
            Datetime closeDateTime;
            if(oppObj.CloseDate!=null)
            closeDateTime = datetime.newInstance(oppObj.CloseDate.year(), oppObj.CloseDate.month(),oppObj.CloseDate.day());
            oppObj.Name=(closeDateTime !=null?closeDateTime .format('MMMMM'):'')+' '+(closeDateTime!=null?closeDateTime.Year():null)+' '+((oppObj.Early_Contract__c=='Not Early' ||oppObj.Early_Contract__c=='')?'':'Early')+' '+((oppObj.Parent_Upsell__c=='Upsell' && oppObj.Parent_Upsell__c!=null)?'Upsell':(oppObj.NBB_Renewal__c!=null?oppObj.NBB_Renewal__c:''))+' '+(oppObj.Years__c=='1'?'':(' Year '+oppObj.Deal_Year__c+' of '+(oppObj.Years__c!=null?oppObj.Years__c:'')))+' '+(oppObj.Opportunity_Name_Affix__c!=null?oppObj.Opportunity_Name_Affix__c:'');//((oppObj.Years__c<oppObj.Deal_Year__c?' Of'+oppObj.Years__c:''))//Opportunity_Name_Affix__c added by Harshit/Udita for TICCM-956 
            oppObj.MYD_Deal__c=(oppObj.Deal_Year__c=='1'?'First Year':'MYD');
            //if(oppObj.Contract_Implemented__c)
            //{
                
            //oppObj.Bill_Cycle__c=(accIdVsAccountObj.containsKey(oppObj.AccountId) && ((accIdVsAccountObj.get(oppObj.AccountId).Chain_Affiliation__c!=null && accIdVsAccountObj.get(oppObj.AccountId).Chain_Affiliation__c == 'Hilton Worldwide') || (accIdVsAccountObj.get(oppObj.AccountId).Other_Chain__c!=null && accIdVsAccountObj.get(oppObj.AccountId).Other_Chain__c.contains('Curio'))) && oppObj.Contribution_Type__c=='Brand Contribution' && oppObj.Chain_Deal__c.contains('MSA'))?'US MSA Bill Cycle USD CA-16605':(oppObj.Deal_Booked_In__c=='US Books'?'US':(oppObj.Deal_Booked_In__c=='UK Books'?'UK':(oppObj.Deal_Booked_In__c=='CT Books'?'CT':'')))+' '+(String.isNotBlank(oppObj.MSA_Code__c)?'MSA Bill Cycle':'Daily Bill Cycle')+' '+(oppObj.CurrencyIsoCode!=null?oppObj.CurrencyIsoCode:'');
            
            if(oppObj.AccountId!=null && accIdVsAccountObj.containsKey(oppObj.AccountId)){
                if(accIdVsAccountObj.get(oppObj.AccountId).Affiliate_Name__c!=null && accIdVsAccountObj.get(oppObj.AccountId).Affiliate_Name__c=='Curio Collection')
                {
                    oppObj.Chain_Name__c='Hilton Worldwide';
                    oppObj.Brand_Name__c='Curio Collection';
                }
                else if(accIdVsAccountObj.get(oppObj.AccountId).Affiliate_Name__c!=null && accIdVsAccountObj.get(oppObj.AccountId).Affiliate_Name__c=='Autograph Collection')
                {
                    oppObj.Chain_Name__c='Marriott Hotels';
                    oppObj.Brand_Name__c='Autograph Collection';
                }
                else{
                    oppObj.Chain_Name__c=(accIdVsAccountObj.get(oppObj.AccountId).Chain_Affiliation__c!=null )?accIdVsAccountObj.get(oppObj.AccountId).Chain_Affiliation__c:oppObj.Chain_Name__c;
                    oppObj.Brand_Name__c=(accIdVsAccountObj.get(oppObj.AccountId).Brand__c!=null )?accIdVsAccountObj.get(oppObj.AccountId).Brand__c:oppObj.Brand_Name__c;
                }
                if(oppObj.Chain_Deal__c!=null && oppObj.Chain_Deal__c.contains('Advertising Agency')){oppObj.Advertising_Agency__c=(accIdVsAccountObj.get(oppObj.AccountId).Advertising_Agency__c!=null )?accIdVsAccountObj.get(oppObj.AccountId).Advertising_Agency__c:oppObj.Advertising_Agency__c;
                }
                oppObj.Management_Company_Name__c=(accIdVsAccountObj.get(oppObj.AccountId).Management_Company__c!=null)?accIdVsAccountObj.get(oppObj.AccountId).Management_Company__c:oppObj.Management_Company_Name__c;
                oppObj.Chain_Name_Others__c=accIdVsAccountObj.get(oppObj.AccountId).Other_Chain__c!=null?accIdVsAccountObj.get(oppObj.AccountId).Other_Chain__c:(accIdVsAccountObj.get(oppObj.AccountId).Affiliate_Name__c!=null?accIdVsAccountObj.get(oppObj.AccountId).Affiliate_Name__c:oppObj.Chain_Name_Others__c);
            }
            oppObj.OwnerId=oppObj.Deal_Closed_by__c!=null?oppObj.Deal_Closed_by__c:oppObj.OwnerId;
            System.debug('Deal_Closed_by__c===>>>>>'+oppObj.Deal_Closed_by__c);
            System.debug('userIdVsCountryName===>>>>>'+userIdVsCountryName);
            String location=userIdVsCountryName.containsKey(oppObj.Deal_Closed_by__c)?userIdVsCountryName.get(oppObj.Deal_Closed_by__c):oppObj.Sold_By__c;//(userRecord.Country!=null?userRecord.Country:oppObj.Sold_By__c);
            System.debug('location===>>>'+location);
           // if(location!=null){oppObj.Sold_By__c=(location=='IN'?'India':((location=='United Kingdom'||location=='GB')?'Europe':(location=='AU'?'Australia':(location=='US'?'USA':location))));}
            if(location!=null){oppObj.Sold_By__c=(location=='IN'?'India':((location=='United Kingdom'||location=='GB')?'Europe':(location=='AU'?'Australia':(location=='CA'?'Canada':(location=='SG'?'Singapore':(location=='US'?'USA':location))))));}
            //oppObj.Sold_By__c=(location=='IN'?'India':(location=='United Kingdom'?'Europe':(location=='US'?'USA':location)));
            //oppObj.Sold_By__c=(location=='IN'?'India':(location=='United Kingdom'?'Europe':location));
            //oppObj.Upsell_Category__c=(oppObj.Parent_Upsell__c=='One-Off'?'Not Renewable One-off':(oppObj.Parent_Contract_Number__c==Integer.ValueOf(oppObj.Contract_Number_New__c)?'Closed with Renewal':'Standalone'));
            //oppObj.Upsell_Category__c= ((oppObj.Parent_Upsell__c!=null && oppObj.Parent_Upsell__c=='One-Off')?'Not Renewable One-off':(((oppObj.Parent_Contract_Number__c!=null && oppObj.Contract_Number_New__c!=null)&&(oppObj.Parent_Contract_Number__c==Integer.ValueOf(oppObj.Contract_Number_New__c) ))?'Closed with Renewal':'Standalone'));
            
            oppObj.Upsell_Category__c = (((oppObj.Parent_Upsell__c!=null && (oppObj.Parent_Upsell__c=='One-Off'  || oppObj.Parent_Upsell__c=='eCommerce/CS')) || (oppObj.License_Type__c!=null && oppObj.License_Type__c=='Custom Work'))?'Not Renewable (One-off)':((oppObj.Parent_Contract_Number__c!=null && oppObj.Contract_Number_New__c!=null)?(String.ValueOf(oppObj.Parent_Contract_Number__c)==oppObj.Contract_Number_New__c?'Closed With Renewal':'Standalone'):null));//oppObj.Upsell_Category__c
            System.debug('******************CLOSEDATE IN TRIGGER'+oppObj.CloseDate);
            //BILL CYCLE  = “Deal Booked In”  + “MSA Code” + currency [3 digts]
        }
    }
    Public Static Boolean isRunOnce2=false;
    public static void billingCaseCreate_Method(List<Opportunity> opportunityList)
    {
        System.debug('Checkpoint*********');
        //Initializing variables......
        Map<Id,Opportunity> oppIdVsOpp_Map = new Map<Id,Opportunity>();
        Set<Id> oppIdSet = new Set<Id>();
        BillingCase__c billingObj = new BillingCase__c();
        Map<Id,BillingCase__c> billingRecMap = new Map<Id,BillingCase__c>();
        Set<String> CVIIIdSet = new Set<String>();
        For(Opportunity oppObj : opportunityList)
        {
            system.debug('cviiId '+oppObj.CVII_ID__c);
            if(oppObj.CVII_ID__c!=null && (!String.ValueOf(oppObj.CVII_ID__c).contains(';') || !String.ValueOf(oppObj.CVII_ID__c).contains(',')))
            {
                oppIdSet.add(oppObj.Id);
            }
        }
        System.debug('oppIdSet*********'+oppIdSet);
        //Query on Opportunity to fetch all the values which needs to be pushed into Billing case..........
        For(Opportunity oppRec : [SELECT Id,Account.Id,Bill_To_Contact__c,Bill_To_Address__c,Account.Billing_Case__c,CVII_ID__c,Account.Name,Bill_To_Contact__r.FirstName,Bill_To_Contact__r.LastName,Bill_To_Contact__r.Email,Bill_To_Contact__r.Phone,Bill_To_Address__r.Address__c,Bill_To_Address__r.Address_2__c,Bill_To_Address__r.City__c,Bill_To_Address__r.State__c,Bill_To_Address__r.Postal_Code__c,Bill_To_Address__r.Country__c FROM Opportunity WHERE Id IN : oppIdSet]){
            if(oppRec.Account.Billing_Case__c!=null)
            {
                billingObj = new BillingCase__c(Id=oppRec.Account.Billing_Case__c);
                billingObj.CVII_Number__c = oppRec.CVII_ID__c;
                billingObj.Name = oppRec.Account.Name;
                billingObj.CustomersAccount__c = oppRec.Account.Id;// Added by Udita P-004429
                if(oppRec.Bill_To_Contact__c!=null){
                    billingObj.Billing_Contact__c = oppRec.Bill_To_Contact__r.FirstName!=null?oppRec.Bill_To_Contact__r.FirstName:''+' '+oppRec.Bill_To_Contact__r.LastName!=null?oppRec.Bill_To_Contact__r.LastName:'';
                    billingObj.Primary_Email__c = oppRec.Bill_To_Contact__r.Email!=null?oppRec.Bill_To_Contact__r.Email:'';
                    billingObj.Phone__c = oppRec.Bill_To_Contact__r.Phone!=null?oppRec.Bill_To_Contact__r.Phone:'';
                }
                if(oppRec.Bill_To_Address__c != null){
                    billingObj.Mailing_Address__c = oppRec.Bill_To_Address__r.Address__c!=null?oppRec.Bill_To_Address__r.Address__c:''+' '+oppRec.Bill_To_Address__r.Address_2__c!=null?oppRec.Bill_To_Address__r.Address_2__c:'';
                    billingObj.City__c = oppRec.Bill_To_Address__r.City__c!=null?oppRec.Bill_To_Address__r.City__c:'';
                    billingObj.State__c = oppRec.Bill_To_Address__r.State__c!=null?oppRec.Bill_To_Address__r.State__c:'';
                    billingObj.Zip__c = oppRec.Bill_To_Address__r.Postal_Code__c!=null?oppRec.Bill_To_Address__r.Postal_Code__c:'';
                    billingObj.Country__c = oppRec.Bill_To_Address__r.Country__c!=null?oppRec.Bill_To_Address__r.Country__c:'';
                }

                //billingRecList.add(billingObj);
                billingRecMap.put(oppRec.Account.Id,billingObj);
            }
            else
            {
                oppIdVsOpp_Map.put(oppRec.Id,oppRec);
                CVIIIdSet.add(oppRec.CVII_ID__c);
            }
        }
        System.debug('oppIdVsOpp_Map*********'+oppIdVsOpp_Map);
            System.debug('billingRecMap*********'+billingRecMap);
                    System.debug('CVIIIdSet*********'+CVIIIdSet);
        Map<String,Id> CVIIIdVsBillingId_Map = new Map<String,Id>();
        //Query on Billing Cases to fetch billing record according to the Opportunity CVII....
        if(!oppIdVsOpp_Map.isEmpty()){
            For(BillingCase__c billingCaseRec : [SELECT Id,CVII_Number__c FROM BillingCase__c WHERE CVII_Number__c IN : CVIIIdSet])
            {
                CVIIIdVsBillingId_Map.put(billingCaseRec.CVII_Number__c,billingCaseRec.Id);
            }
        }
        Opportunity oppRec = new Opportunity();
        For(Id oppId : oppIdVsOpp_Map.keySet())
        {
            oppRec = new Opportunity();
            oppRec = oppIdVsOpp_Map.get(oppId);
            //Billing Cases fetch attached with Account
            if(CVIIIdVsBillingId_Map.containsKey(oppIdVsOpp_Map.get(oppId).CVII_ID__c)){
                billingObj = new BillingCase__c(Id=CVIIIdVsBillingId_Map.get(oppIdVsOpp_Map.get(oppId).CVII_ID__c));
                billingObj.CVII_Number__c = oppRec.CVII_ID__c;
                billingObj.Name = oppRec.Account.Name;
                billingObj.CustomersAccount__c = oppRec.Account.Id; // Added by Udita P-004429
                if(oppRec.Bill_To_Contact__c!=null){
                    billingObj.Billing_Contact__c = oppRec.Bill_To_Contact__r.FirstName!=null?oppRec.Bill_To_Contact__r.FirstName:''+' '+oppRec.Bill_To_Contact__r.LastName!=null?oppRec.Bill_To_Contact__r.LastName:'';
                    billingObj.Primary_Email__c = oppRec.Bill_To_Contact__r.Email!=null?oppRec.Bill_To_Contact__r.Email:'';
                    billingObj.Phone__c = oppRec.Bill_To_Contact__r.Phone!=null?oppRec.Bill_To_Contact__r.Phone:'';
                }
                if(oppRec.Bill_To_Address__c!=null){
                    billingObj.Mailing_Address__c = oppRec.Bill_To_Address__r.Address__c!=null?oppRec.Bill_To_Address__r.Address__c:''+' '+oppRec.Bill_To_Address__r.Address_2__c!=null?oppRec.Bill_To_Address__r.Address_2__c:'';
                    billingObj.City__c = oppRec.Bill_To_Address__r.City__c!=null?oppRec.Bill_To_Address__r.City__c:'';
                    billingObj.State__c = oppRec.Bill_To_Address__r.State__c!=null?oppRec.Bill_To_Address__r.State__c:'';
                    billingObj.Zip__c = oppRec.Bill_To_Address__r.Postal_Code__c!=null?oppRec.Bill_To_Address__r.Postal_Code__c:'';
                    billingObj.Country__c = oppRec.Bill_To_Address__r.Country__c!=null?oppRec.Bill_To_Address__r.Country__c:'';
                }
                billingRecMap.put(oppRec.Account.Id,billingObj);
                //billingRecList.add(billingObj);
            }
            //Create new Billing cases for the rest and attach to account......
            else{
                billingObj = new BillingCase__c();
                billingObj.CVII_Number__c = oppRec.CVII_ID__c;
                billingObj.Name = oppRec.Account.Name;
                billingObj.CustomersAccount__c = oppRec.Account.Id; // Added by Udita P-004429
                if(oppRec.Bill_To_Contact__c!=null){            
                    billingObj.Billing_Contact__c = oppRec.Bill_To_Contact__r.FirstName!=null?oppRec.Bill_To_Contact__r.FirstName:''+' '+oppRec.Bill_To_Contact__r.LastName!=null?oppRec.Bill_To_Contact__r.LastName:'';
                    billingObj.Primary_Email__c = oppRec.Bill_To_Contact__r.Email!=null?oppRec.Bill_To_Contact__r.Email:'';
                    billingObj.Phone__c = oppRec.Bill_To_Contact__r.Phone!=null?oppRec.Bill_To_Contact__r.Phone:'';
                }
                if(oppRec.Bill_To_Address__c!=null){
                    billingObj.Mailing_Address__c = oppRec.Bill_To_Address__r.Address__c!=null?oppRec.Bill_To_Address__r.Address__c:''+' '+oppRec.Bill_To_Address__r.Address_2__c!=null?oppRec.Bill_To_Address__r.Address_2__c:'';
                    billingObj.City__c = oppRec.Bill_To_Address__r.City__c!=null?oppRec.Bill_To_Address__r.City__c:'';
                    billingObj.State__c = oppRec.Bill_To_Address__r.State__c!=null?oppRec.Bill_To_Address__r.State__c:'';
                    billingObj.Zip__c = oppRec.Bill_To_Address__r.Postal_Code__c!=null?oppRec.Bill_To_Address__r.Postal_Code__c:'';
                    billingObj.Country__c = oppRec.Bill_To_Address__r.Country__c!=null?oppRec.Bill_To_Address__r.Country__c:'';
                }
                
                billingRecMap.put(oppRec.Account.Id,billingObj);
                //billingRecList.add(billingObj);
            }
        }
        System.debug('billingRecMap*********'+billingRecMap);
        //Upsert Billing Case............
        if(!billingRecMap.isEmpty())
            upsert billingRecMap.values();
        Account accObj = new Account();
        List<Account> accRecList = new List<Account>();
        For(Id accId : billingRecMap.keySet()){
            accObj = new Account(Id = accId);
            accObj.Billing_Case__c = billingRecMap.get(accId).Id;
            accRecList.add(accObj);
        }
        if(accRecList.size()>0)
            update accRecList;
    }
    /*    
       Add by Kd:  call by opportunity trigger on update 
    */
      Public Static Boolean isRunOnce=false;
        public static void  createContractReview(List<Opportunity> listCurrentOppty,Map<Id,Boolean>  mapOppIdIsHybrid){
           List<Contract_Reviewing__c> contractReviewList= new List<Contract_Reviewing__c>();
           Set<String>  ContractNumberSet=new Set<String>();
           List<Opportunity> opportunityRecord;
           Set<Id> setOpptyId=new Set<Id>();
           Map<id,Contract_Reviewing__c> mapOppVsContract=new Map<id,Contract_Reviewing__c>();
           Map<String,String> mapProductVsUser=new Map<String,String>();
           
           for(TrackUser__c tractObj:TrackUser__c.getAll().values()){             mapProductVsUser.put(tractObj.Product_Name__c,tractObj.Name__c);           }
           for(Opportunity oppObj:listCurrentOppty){
               setOpptyId.add(oppObj.id);
              ContractNumberSet.add(oppObj.Contract_Number_New__c); 
               
           }
           if(ContractNumberSet.size()>0){
               opportunityRecord=[SELECT Id,CurrencyIsoCode,Contract_Number_New__c,CFC_Check__c,To_Be_Reviewed_By__c FROM Opportunity WHERE Contract_Number_New__c IN : ContractNumberSet];
           }
            
            map<String,RRATracker__c> mapRRATracker=RRATracker__c.getAll();
            Map<String,Integer> mapNameVsRRId=new Map<String,Integer>();
            Map<Integer,String> mapRRIdVsName=new Map<Integer,String>();
            Integer startIndex=-1,totalCustomSettingRecords=0;
            totalCustomSettingRecords=mapRRATracker.size();
            for(RRATracker__c objRRtracker :mapRRATracker.values()){ 
                mapNameVsRRId.put(objRRtracker.User_Name__c,Integer.valueOF(objRRtracker.RoundRobinId__c));   
                mapRRIdVsName.put(Integer.valueOF(objRRtracker.RoundRobinId__c),objRRtracker.User_Name__c);            } 
             Set<String> setContractNumber=new Set<String>();   
             For(Opportunity oppObj : opportunityRecord)
             {
                setContractNumber.add(oppObj.Contract_Number_New__c);    
             }  
             List<Contract_Reviewing__c> listContractReview;
             if(setContractNumber.size()>0)
                listContractReview=new List<Contract_Reviewing__c>([select opportunity__r.Contract_Implemented__c,Accounting_Hybrid_Review_Ok__c,Contract_Reviewer__c, Opportunity_Contract__c,Opportunity__c from Contract_Reviewing__c where (Opportunity_Contract__c in :setContractNumber or Opportunity__c in:setOpptyId)]);
            List<Contract_Reviewing__c> latestContractObj=new List<Contract_Reviewing__c>([select Contract_Reviewer__c, Opportunity_Contract__c from Contract_Reviewing__c order by createdDate desc limit 1]);
            if(latestContractObj.size()>0){
                startIndex=mapNameVsRRId.keyset().contains(latestContractObj[0].Contract_Reviewer__c)?Integer.valueOF(mapNameVsRRId.get(latestContractObj[0].Contract_Reviewer__c)) :-1  ;
            }
            Map<String,String> mapNumberVsAssignUser=new Map<String,String>();
            List<Contract_Reviewing__c> listtobeUpdateContract =new List<Contract_Reviewing__c>();
            Map<Id,Contract_Reviewing__c> mapOppidVscontract=new Map<Id,Contract_Reviewing__c>();
            for(Contract_Reviewing__c objReview:listContractReview){
                    mapOppidVscontract.put(objReview.Opportunity__C,objReview);
                    if(objReview.Contract_Reviewer__c!=null){
                          mapNumberVsAssignUser.put(objReview.Opportunity_Contract__c,objReview.Contract_Reviewer__c);
                          mapOppVsContract.put(objReview.Opportunity__c,objReview);
                    }else if(objReview.Accounting_Hybrid_Review_Ok__c=='No' && objReview.opportunity__r.Contract_Implemented__c ){
                             objReview.Accounting_Hybrid_Review_Ok__c='Error Correct';
                            listtobeUpdateContract.add(objReview);
                    }                   
            }
            For(Opportunity oppObj :listCurrentOppty)
            {      
                //   if(mapOppidVscontract.containsKey(oppObj.id)){
                    if(!mapOppidVscontract.keyset().contains(oppObj.id) && !mapOppVsContract.keySet().Contains(oppObj.id)){
                        
                        if(mapOppIdIsHybrid.keySet().contains(oppObj.id) && mapOppIdIsHybrid.get(oppObj.id)==true)
                        {
                                       Contract_Reviewing__c contractReview = new Contract_Reviewing__c();
                                       contractReview.Accounting_Reviewer_Hybrid_Feature__c=mapProductVsUser.keySet().contains(oppObj.Product__c)?mapProductVsUser.get(oppObj.Product__c):null;
                                       contractReview.Opportunity__c=oppObj.Id;
                                       contractReview.CurrencyIsoCode=oppObj.CurrencyIsoCode;
                                       contractReview.recordTypeID=Schema.SObjectType.Contract_Reviewing__c.getRecordTypeInfosByName().get('Accounting Review(Hybrid)').getRecordTypeId();
                                       contractReviewList.add(contractReview);
                            
                        }
                    
                            else{// && !mapOppIdIsHybrid.get(oppObj.id)
                                    Contract_Reviewing__c contractReview = new Contract_Reviewing__c();
                                    if(mapNumberVsAssignUser.keyset().contains(oppObj.Contract_Number_New__c)){
                                            contractReview.Contract_Reviewer__c=mapNumberVsAssignUser.get(oppObj.Contract_Number_New__c);
                                    }       
                                    else {
                                            if(startIndex<totalCustomSettingRecords-1){
                                                startIndex=startIndex+1;
                                            }else {
                                                startIndex=0;
                                            }   
                                        contractReview.Contract_Reviewer__c=mapRRIdVsName.get(startIndex);
                                    }
                                    contractReview.Opportunity__c=oppObj.Id;
                                    contractReview.CurrencyIsoCode=oppObj.CurrencyIsoCode;
                                    contractReviewList.add(contractReview);
                            }
                            
                    }
                   // }
            }
            if(contractReviewList.size()>0){
                insert contractReviewList;
            }
            if(listtobeUpdateContract.size()>0){
               update listtobeUpdateContract;
            }
    } // end 

    /*
     Author:Kumud
     Desc : Call by trigger
     Date: 26 June 2018
    
    */
    public static void onBeforeInsert(List<Opportunity> newOpportunities){
       
       
        List<Opportunity> listOfOpp=new List<Opportunity>();
        for(Opportunity instOpp:newOpportunities){
            
            
            if(instOpp.Contract_Number_New__c!=null && (instOpp.Deal_Year__c!=null && instOpp.Deal_Year__c=='1')){
                
                listOfOpp.add(instOpp);
            }
        }// end of loop
        
        if(!listOfOpp.isEmpty() && !billingCaseCreate_Opp_handler.isRunonce1){
            
            billingCaseCreate_Opp_handler.isRunonce1=true;
            billingCaseCreate_Opp_handler.oppAutomationYear1_Method(listOfOpp);
        }
       
       
    }// end 
    
    /*
     Author:Kumud
     Desc : Call by trigger on before update
     Date: 26 June 2018
    
    */
    public static void onBeforeUpdate(List<Opportunity> newOpportunities, Map<Id,Opportunity> newMapOpportunity,Map<Id,Opportunity> oldMapOpportunity){
        
        
        List<Opportunity> listOfOpp=new List<Opportunity>();
        for(Opportunity instOpp:newOpportunities){
            
            
            if(instOpp.Contract_Number_New__c!=null && (instOpp.Contract_Number_New__c!=oldMapOpportunity.get(instOpp.id).Contract_Number_New__c) && 
             (instOpp.Deal_Year__c=='1')){
               
                    listOfOpp.add(instOpp);
            }
        }// end of loop
        
        if(!listOfOpp.isEmpty() && !billingCaseCreate_Opp_handler.isRunonce1){
            
            billingCaseCreate_Opp_handler.isRunonce1=true;
            billingCaseCreate_Opp_handler.oppAutomationYear1_Method(listOfOpp);
        }
    } // end 
    
    /*
     Author:Kumud
     Desc : Call by trigger on after update
     Date: 26 June 2018
    
    */
    public static void onAfterUpdate(List<Opportunity> newOpportunities, Map<Id,Opportunity> newMapOpportunity,Map<Id,Opportunity> oldMapOpportunity){
        
        List<Opportunity> listOfOpp=new List<Opportunity>();
        for(Opportunity instOpp:newOpportunities){
            
            
            if((instOpp.Contract_Implemented__c !=oldMapOpportunity.get(instOpp.id).Contract_Implemented__c) && (instOpp.stageName=='Closed Won' && instOpp.Contract_Implemented__c)) {
                listOfOpp.add(instOpp);
            }
                
            
        }// end of loop
        
        if(!listOfOpp.isEmpty() && !billingCaseCreate_Opp_handler.isRunonce2){
        
            billingCaseCreate_Opp_handler.isRunonce2=true;
            billingCaseCreate_Opp_handler.billingCaseCreate_Method(listOfOpp);
        }
        
    } // end 
    
   
   
  
}