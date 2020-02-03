public class contractRelatedOpp {
      
    public Opportunity relatedOpp{get;set;}
    public Account relatedAcc{get;set;}
    public String ContractId{get;set;}
    public boolean checklist{get;set;}
    public boolean hasvalues{get;set;}
    public List<Opportunity> oppRecords{get;set;}
    public contractRelatedOpp(ApexPages.StandardController controller) {
        ContractId = ApexPages.currentPage().getParameters().get('id');
        relatedOpp = new Opportunity();
        oppRecords = new List<Opportunity>();
        relatedAcc = new Account();
        checklist=false;
        relatedOpp();
        relatedAcc();
        relatedOpps();
    }
    public Opportunity relatedOpp(){
       ID oppId = [Select Primary_Opportunity__c from Contract where id =: ContractId].Primary_Opportunity__c;
       system.debug('@@@@@Opp Id: '+oppId);
       relatedOpp = [Select id,Name,Owner.Name,RecordType.Name,Product__c,New_Type__c,License_Type__c,CloseDate,Team__c,Contract_Implemented__c,Contract_Implemented_Date__c,    //True_Product__c   comment by kd
                     Original_Contract_End_Date__c,Sold_By__c,Deal_Booked_In__c,Additional_Terms__c,Are_you_Sales_Tax_Exempt__c,Federal_Tax_Id__c,Text_Type_II__c,
                     Parent_Upsell__c,NBB_Renewal__c,MYD_Deal__c,PSG_Type__c,New_Contract_Total__c,Native_Total__c,ContractReceived__c,ContractStartDate__c,  //Weighted_Contract_Total__c
                     ContractEndDate__c,RenewalDate__c,Booked_Month__c,OptOutDate__c,Discount_Deadline__c,Received_in_Month__c,Opportunity_Start_Date__c,Opp_End_Date__c,
                     Years__c,PaymentTerms__c,Deal_Year__c,Year_1_at_Risk__c,EnterOtherPaymentTerms__c,Total_Amount_at_Risk__c,Verisign_Required__c,Currency__c,Forex_rate__c,ARClause__c,
                     Auto_Renewal_Details__c,Unique_ID_Opp__c,Non_Standard_Terms__c,CVII_Contract_Number__c,Parent_Contract_Number__c,Upsell_Category__c,Description,Contract_Error__c,  //Client_Signed_SLA__c
                     Detail_of_Error__c,Commission_Type__c
                        FROM Opportunity where id =: oppId];
       checklist = true;
       return relatedOpp; 
    } 
    public Account relatedAcc(){
       ID accId = [Select AccountId from Contract where id =: ContractId].AccountId;
       system.debug('@@@@@Opp Id: '+accId);
       relatedAcc = [Select id,Name,Owner.Name,ParentId,Named_Acct__c,Account_Status__c,Type,CVII_ID__c,Cvent_Account_ID__c,Purchased_License__c,Standard_Non_Standard_Contract__c,BillingCountry,BillingCity,BillingState,BillingStreet,
                     Phone,Fax,Time_Zone__c,Website,Country_Region__c,Consent_for_logo__c,Description
                        FROM Account where id =: accId];
       checklist = true;
       return relatedAcc; 
    }
    public List<Opportunity> relatedOpps(){
       Id oppId = [Select Primary_Opportunity__c from Contract where id =: ContractId].Primary_Opportunity__c;
       Opportunity oppCnumber = [Select Contract_Number_New__c from Opportunity where id =: oppId];
       system.debug('@@@@@Opp Id: '+oppId);
       system.debug('@@@@@oppCnumber : '+oppCnumber);
       if(oppCnumber.Contract_Number_New__c != null){
           for(Opportunity o : [Select id,Name,Owner.Name,RecordType.Name,Product__c,New_Type__c,License_Type__c,CloseDate,StageName,Parent_Upsell__c,Contract_Number_New__c FROM Opportunity where Contract_Number_New__c =: oppCnumber.Contract_Number_New__c and StageName = 'Closed Won']){
               oppRecords.add(o);
               hasvalues = true;
           }
       }
       system.debug('oppRecords : '+oppRecords);
       checklist = true;
       return oppRecords; 
    }
    public PageReference submit() {
        return null;
    }
}