/**@author Hemant Rana
Batch Class for the Updation of Service_Tier__c field of the Account Object according to the Share of Wallet Field and the Mapping of Service_Tier_Mapping
Version 1.0
Date: 17th Feb 2016
*/
global class AccountServiceTierAssignment_Batch implements Database.Batchable<sObject>{
    List<LogsWarehouse__c> errorLogObj=new List<LogsWarehouse__c>();
    List<Database.SaveResult> updateResults;//When a account record is updated then it will store the record id which gets saved succesfully and also which gets error and not get updated.
    //Below two variables are used when an account is having both the Event and Hospitality Cloud Product
String eventTier;
String hospitalityTier;
    //Map<String,Integer> tierNameVsOrder
    String query;
    Set<String> eventPLFValues_Set =new Set<String>();
    Set<String> hospPLFValues_Set =new Set<String>();
    Map<String,Set<String>> CloudVsPLFValuesSet_Map  =new Map<String,Set<String>>();
    Map<Id,String> accIdVsCloud_Map=new Map<Id,String>();
    Database.QueryLocator qLocator ;
    List<Decimal> eventCloudMaxAmount_List=new List<Decimal>();
    List<Decimal> hospitalityCloudMaxAmount_List=new List<Decimal>();
    Map<String,Decimal> tierVsAmount_Map=new Map<String,Decimal>();//Map will store the name of the tier and sum of min and max value.(May be deleted)
    Map<Decimal,String> amountVsTier_Map=new Map<Decimal,String>();//Map will store the name of the sum of min and max value and tier.
    
    Map<String,Decimal> HosCloud_tierVsAmount_Map=new Map<String,Decimal>();//Map will store the name of the tier and sum of min and max value.(May be deleted)
    Map<Decimal,String> HosCloud_amountVsTier_Map=new Map<Decimal,String>();//Map will store the name of the sum of min and max value and tier.
    
    List<Service_Tier_Mapping__c> tiersObj=new List<Service_Tier_Mapping__c>();
    
    Map<Id,String> accIdVsCloudName_Map=new Map<Id,String>();
    
    /*New Map*/
    Map<Id,Set<String>> accIdVsCloudSet_Map  =new Map<Id,Set<String>>();
    Set<String> CloudSelected_Set=new Set<String>();
    List<Account> accountQueryList=new List<Account>();
    
    /* 3/22/2016 PK: Added functionality to run the batch conditionally for a list of test accounts */
    List<String> testAccountIds = null;
    global AccountServiceTierAssignment_Batch()
    { 
        this(null);
    }

    
    global AccountServiceTierAssignment_Batch(List<String> testAccountIds0)
    {   
        testAccountIds = testAccountIds0;

        //Giving Basic value to every Map
        amountVsTier_Map.put(0,'Basic');
        tierVsAmount_Map.put('Basic',0);
        eventCloudMaxAmount_List.add(0);
        hospitalityCloudMaxAmount_List.add(0);
        HosCloud_amountVsTier_Map.put(0,'Basic');
        HosCloud_tierVsAmount_Map.put('Basic',0);
        //Ends Here--------------------
        //creatingCloudMapping();
        
        tiersObj=[SELECT Name,Max_Amount__c,Min_Amount__c,Event_Cloud_Vs_Hospitality_Cloud__c FROM Service_Tier_Mapping__c ORDER BY Min_Amount__c];
        For(Service_Tier_Mapping__c tierObj : tiersObj)
        {
            if(tierObj.Event_Cloud_Vs_Hospitality_Cloud__c=='Event'){
                amountVsTier_Map.put(tierObj.Max_Amount__c,tierObj.Name);
                tierVsAmount_Map.put(tierObj.Name,tierObj.Max_Amount__c);
                eventCloudMaxAmount_List.add(tierObj.Max_Amount__c);
            }
            else if(tierObj.Event_Cloud_Vs_Hospitality_Cloud__c=='Hospitality')
            {
                HosCloud_amountVsTier_Map.put(tierObj.Max_Amount__c,tierObj.Name);
                HosCloud_tierVsAmount_Map.put(tierObj.Name,tierObj.Max_Amount__c);
                hospitalityCloudMaxAmount_List.add(tierObj.Max_Amount__c);
            }
        }
        
        
        
        System.Debug('amountVsTier_Map==>'+amountVsTier_Map+'tierVsAmount_Map===>'+tierVsAmount_Map+'eventCloudMaxAmount_List===>>>>'+eventCloudMaxAmount_List);
        System.Debug('HosCloud_amountVsTier_Map==>'+HosCloud_amountVsTier_Map+'HosCloud_tierVsAmount_Map===>'+HosCloud_tierVsAmount_Map+'hospitalityCloudMaxAmount_List===>>>>'+hospitalityCloudMaxAmount_List);
    }
    global Database.querylocator start(Database.BatchableContext BC){
        Query = 'SELECT Id,Purchased_License__c,Service_Tier__c,HC_Share_of_Wallet_Client__c,Share_of_Wallet_Tier_Max__c, No_of_HODI_Applied_Dev__c, (select HODI_Inventory__c, Desired_Tier__c,Previous_Tier__c, Points__c  from Account_HODI__r order by createddate desc)  FROM Account WHERE ((HC_Share_of_Wallet_Client__c!=null AND HC_Share_of_Wallet_Client__c>0) OR  (Share_of_Wallet_Tier_Max__c!=null AND Share_of_Wallet_Tier_Max__c>0)) AND (No_of_Reverse_HODI__c<=0 OR No_of_Reverse_HODI__c=null)';
        
        // and id='+'\''+'00100000004RBRgAAO'+'\'';//;// and Delete_Field__c = true';// and id='+'\''+'001000000012BHWAA2'+'\'';
        
        /* 3/22/2016 PK: Added functionality to run the batch conditionally for a list of test account */
        if(testAccountIds != null){
            
            Query = Query + ' AND ID IN (';
            String idStr = ' ';
            for(String accId: testAccountIds){
                idStr = idStr + '\''+accId+'\' ,';
            }
            idStr = idStr.subString(0, idStr.length() - 1);
            Query = Query + idStr + ')';
        }
        /* END */ 
        
        System.debug('query===>'+query); 
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        System.debug('accIdVsCloud_Map===>'+accIdVsCloud_Map);
        List<Account_HODI__c> accountHODIList = new List<Account_HODI__c>();
        List<Account> accountList = new List<Account>();
        For(Account accRecord: scope){
            /* If the account contains both HC and Event Cloud Product then we will take the hospitality cloud tier in consideration.
            If any one wants to increase the Tier then it will be done by the HODI increase.*/
            if((accRecord.HC_Share_of_Wallet_Client__c!=null && accRecord.HC_Share_of_Wallet_Client__c>0) && (accRecord.Share_of_Wallet_Tier_Max__c!=null && accRecord.Share_of_Wallet_Tier_Max__c>0))
            {
                eventTier='';
                hospitalityTier='';
                if(accRecord.No_of_HODI_Applied_Dev__c <= 0 || accRecord.No_of_HODI_Applied_Dev__c == null)
                {
                    for(Decimal tierAmount : hospitalityCloudMaxAmount_List)
                    {
                        System.debug('tierAmount===>'+tierAmount);
                        if(accRecord.HC_Share_of_Wallet_Client__c<=tierAmount)//String.isBlank(accRecord.Service_Tier__c) && 
                        {
                            System.debug('tierAmount===>'+tierAmount);
                            System.debug('accRecord.HC_Share_of_Wallet_Client__c===>'+accRecord.HC_Share_of_Wallet_Client__c);
                            System.debug('HosCloud_amountVsTier_Map.get(tierAmount)====>'+HosCloud_amountVsTier_Map.get(tierAmount));
                            //hospitalityTier=HosCloud_amountVsTier_Map.get(tierAmount);
                            accRecord.Service_Tier__c = HosCloud_amountVsTier_Map.get(tierAmount);
                            accountList.add(accRecord);
                            break;
                        }
                    }
                    
                    /* Below code snippet is basically used when a account is having both the event and hospitality product then in that case the one having lower tier will be selected.
                    But for now requirement is being changed and we will be using the above code snippet and ccording to which always the hospitality cloud tier will be used.*/
                    /*for(Decimal tierAmount : eventCloudMaxAmount_List)
                    {
                        if(accRecord.Share_of_Wallet_Tier_Max__c<=tierAmount)//String.isBlank(accRecord.Service_Tier__c) && 
                        {
                            System.debug('tierAmount===>'+tierAmount);
                            System.debug('accRecord.Share_of_Wallet_Tier_Max__c===>'+accRecord.Share_of_Wallet_Tier_Max__c);
                            System.debug('amountVsTier_Map.get(tierAmount)====>'+amountVsTier_Map.get(tierAmount));
                            eventTier=amountVsTier_Map.get(tierAmount);
                            break;
                        }
                    }
                    for(Decimal tierAmount : hospitalityCloudMaxAmount_List)
                    {
                        System.debug('tierAmount===>'+tierAmount);
                        if(accRecord.HC_Share_of_Wallet_Client__c<=tierAmount)//String.isBlank(accRecord.Service_Tier__c) && 
                        {
                            System.debug('tierAmount===>'+tierAmount);
                            System.debug('accRecord.HC_Share_of_Wallet_Client__c===>'+accRecord.HC_Share_of_Wallet_Client__c);
                            System.debug('HosCloud_amountVsTier_Map.get(tierAmount)====>'+HosCloud_amountVsTier_Map.get(tierAmount));
                            hospitalityTier=HosCloud_amountVsTier_Map.get(tierAmount);
                            break;
                        }
                    }
                    if(String.isNotBlank(hospitalityTier) && String.isNotBlank(eventTier))
                    {
                        if(hospitalityTier!= eventTier){
                            System.Debug('Different Tier Level Check'+accRecord.Id+'Event Tier Name===>'+eventTier+'HC Tier Name===>'+hospitalityTier);
                            if(tierVsAmount_Map.get(eventTier)<HosCloud_tierVsAmount_Map.get(hospitalityTier))
                            {
                                System.Debug('Inside This Diffrent CHeck===>');
                                accRecord.Service_Tier__c = eventTier;
                                accountList.add(accRecord);
                            }
                            else
                            {
                                accRecord.Service_Tier__c = hospitalityTier;
                                accountList.add(accRecord);
                            }
                        }
                        else
                        {
                            System.Debug('Same Tier Level Check'+accRecord.Id+'Event Tier Name===>'+eventTier+'HC Tier Name===>'+hospitalityTier);
                            accRecord.Service_Tier__c = hospitalityTier;
                            accountList.add(accRecord);
                        }
                    }*/
                }
                System.debug('accountList===>'+accountList);
            }

            //If the account contains only Event Product then the below calculation will be done....................
            else if(accRecord.Share_of_Wallet_Tier_Max__c!=null && accRecord.Share_of_Wallet_Tier_Max__c>0)
            {
                System.debug('Inside event accRech===>'+accRecord.Id);
                for(Decimal tierAmount : eventCloudMaxAmount_List)
                {
                    if(String.isBlank(accRecord.Service_Tier__c) && accRecord.Share_of_Wallet_Tier_Max__c<=tierAmount)
                    {
                        System.debug(' Checkpoint # 1');
                        accRecord.Service_Tier__c=amountVsTier_Map.get(tierAmount);
                        accountList.add(accRecord);
                        break;
                    }
                    else if(String.isNotBlank(accRecord.Service_Tier__c) && accRecord.Share_of_Wallet_Tier_Max__c<=tierAmount)
                    {
                        System.debug(' Checkpoint # 2');
                        if(amountVsTier_Map.get(tierAmount)!=accRecord.Service_Tier__c)//Name Check
                        {
                            System.debug(' Checkpoint # 3');
                            if(tierVsAmount_Map.get(accRecord.Service_Tier__c)<=accRecord.Share_of_Wallet_Tier_Max__c){
                                System.debug(' Checkpoint # 4 : New Tier Higher than the current one');
                                accRecord.Service_Tier__c = amountVsTier_Map.get(tierAmount);
                                accountList.add(accRecord);
                            } else {
                                System.debug(' Checkpoint # 4.1 : New Tier Lower than the current one. Check for HODI applied');
                                if(accRecord.No_of_HODI_Applied_Dev__c <= 0){
                                    System.debug('Checkpoint #4.2 : No HODI applied. Downgrade to new Tier based on Share of Wallet');
                                    accRecord.Service_Tier__c = amountVsTier_Map.get(tierAmount);
                                    accountList.add(accRecord);
                                }
                            }
                        }
                        /* 3/22/2016 PK: No Change in Account Tier based on threshhold.
                        Check if there are any HODI applied and revoke HODI points as Account has grown organically */
                        else {
                            System.debug(' Checkpoint # 5   :: accRecord.No_of_HODI_Applied_Dev__c > '+accRecord.No_of_HODI_Applied_Dev__c);
                            if(accRecord.No_of_HODI_Applied_Dev__c > 0){
                                System.debug(' Checkpoint # 6   :: ' +accRecord.Account_HODI__r[0]);
                                if(accRecord.Account_HODI__r[0].Desired_Tier__c == accRecord.Service_Tier__c && 
                                accRecord.Account_HODI__r[0].Previous_Tier__c != accRecord.Account_HODI__r[0].Desired_Tier__c && 
                                accRecord.Account_HODI__r[0].Points__c != -1) {
                                    accountHODIList.add(createHODIRecord(accRecord));
                                }
                            }
                        }
                        /* END */
                        break;
                    }
                }
                System.debug('accountListEVENT+++==>'+accountList);
            }
            //If the account contains only Hospitality Product then the below calculation will be done....................
            else if(accRecord.HC_Share_of_Wallet_Client__c!=null && accRecord.HC_Share_of_Wallet_Client__c>0)
            {
                for(Decimal tierAmount : hospitalityCloudMaxAmount_List)
                {
                    if(String.isBlank(accRecord.Service_Tier__c) && accRecord.HC_Share_of_Wallet_Client__c<=tierAmount)
                    {
                        accRecord.Service_Tier__c=HosCloud_amountVsTier_Map.get(tierAmount);
                        accountList.add(accRecord);
                        break;
                    }
                    else if(String.isNotBlank(accRecord.Service_Tier__c) && accRecord.HC_Share_of_Wallet_Client__c<=tierAmount)
                    {
                        if(HosCloud_amountVsTier_Map.get(tierAmount)!=accRecord.Service_Tier__c)//Name Check
                        {
                            if(HosCloud_tierVsAmount_Map.get(accRecord.Service_Tier__c)<=accRecord.HC_Share_of_Wallet_Client__c)
                            {
                                accRecord.Service_Tier__c=HosCloud_amountVsTier_Map.get(tierAmount);
                                accountList.add(accRecord);
                            } 
                            else{
                                System.debug(' Hosp Cloud : New Tier Lower than the current one. Check for HODI applied');
                                if(accRecord.No_of_HODI_Applied_Dev__c <= 0){
                                    System.debug('Checkpoint #4.2 : No HODI applied. Downgrade to new Tier based on Share of Wallet');
                                    accRecord.Service_Tier__c = HosCloud_amountVsTier_Map.get(tierAmount);
                                    accountList.add(accRecord);
                                }
                            }
                        }
                        /* 3/22/2016 PK: No Change in Account Tier based on threshhold.
                        Check if there are any HODI applied and revoke HODI points as Account has grown organically */
                        else {
                            if(accRecord.No_of_HODI_Applied_Dev__c > 0){
                                if(accRecord.Account_HODI__r[0].Desired_Tier__c == accRecord.Service_Tier__c && 
                                accRecord.Account_HODI__r[0].Previous_Tier__c != accRecord.Account_HODI__r[0].Desired_Tier__c && 
                                accRecord.Account_HODI__r[0].Points__c != -1) {
                                    accountHODIList.add(createHODIRecord(accRecord));
                                }
                            }
                        }
                        /* END */
                        break;
                    }
                }
                System.debug('accountListHospitality+++==>'+accountList);
            }
        }
        System.debug('accountList====>'+accountList);
        if(accountList!=null)
        {
            updateResults = Database.update(accountList, false);
            for(Integer i=0;i<updateResults.size();i++){
                if (updateResults.get(i).isSuccess()){
                    updateResults.get(i).getId();
                }
                else if (!updateResults.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = updateResults.get(i).getErrors().get(0);
                    accountList.get(i);//failed record from the list
                    system.debug('Failed ID'+accountList.get(i).Id);
                    LogsWarehouse__c logObj=new LogsWarehouse__c();
                    logObj.Error_description__c=error.getMessage();
                    logObj.Batch_Class_Name__c='AccountServiceTierAssignment_Batch';
                    logObj.Record_Id__c=accountList.get(i).Id;
                    errorLogObj.add(logObj);
                }
            }
        }
        if(errorLogObj!=null)
            insert errorLogObj;
        //update accountList ;
        /*3/22/2016 PK: Insert HODI Revocation Records */
        System.debug('accountHODIList====>'+accountHODIList);
        insert accountHODIList;
    }
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedBy.Name , ExtendedStatus  from AsyncApexJob where Id = :BC.getJobId()]; 
         
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        String[] toAddresses = new String[] {a.CreatedBy.Email};  
        mail.setToAddresses(toAddresses);  
        mail.setSubject('Account ServiceTier BatchJob Status: ' + a.Status);  
        //mail.setPlainTextBody('The batch Apex job processed ' + a.JobItemsProcessed);
        String body='<span style='+'\''+'color:#1F497D; font-size:11.0pt;font-family:"Calibri",sans-serif;'+'\''+'><b>Hi '+a.CreatedBy.Name+',  </b></br></br>The request submitted by you to set the Account Service Tier is being completed.</br>You can now test on the account records.</br></br><b>Total Batch Processed:</b> '+a.JobItemsProcessed+'</span></br><span style='+'\''+'font-size:11.0pt;font-family:"Calibri",sans-serif;color:#000000'+'\''+'><b>Thanks,</br>'+'Salesforce'+'<o:p></o:p></b></span>';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        /*
        Send an email notification about Batch Completion.
        */
    }
    /*
        3/22/2016 PK: Utility Method
        TO-DO:  HODI applied; find no of levels between Old Service Tier and New Service Tier and deuct points accordingly.
        To-DO: Find the correct HOD Approver by comparing the latest Service Tier on Account HODI junction
        For now; I am deducting only one point assuming account wouldnt grow more than one level organically
    */
    private Account_HODI__c createHODIRecord(Account accRecord){
        Account_HODI__c accHodi = new Account_HODI__c();
        accHodi.Account__c = accRecord.Id;
        accHodi.HODI_Inventory__c = accRecord.Account_HODI__r[0].HODI_Inventory__c;
        accHodi.Desired_Tier__c = accRecord.Service_Tier__c;
        accHodi.Previous_Tier__c =  accRecord.Service_Tier__c;
        accHodi.Points__c = -1;
        accHodi.HOD_Comment__c = 'Auto Revocation of HODI as Account grew organically'; 
        return accHodi;     
    }
}