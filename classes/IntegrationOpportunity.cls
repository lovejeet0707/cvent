global class IntegrationOpportunity{
    public static void handleNewOpportunities(List<Opportunity> oList){
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONOPPORTUNITY.HANDLENEWOPPORTUNITIES - Start.');
        List<Id> newO=new List<Id>();
        map<id, Decimal> NegMap = new map<id, Decimal>();
        map<id, string> ROLMap = new map<id, string>();
        Decimal Neg = 0;
        
        for(OpportunityLineItem OLI : [SELECT opportunityId, Product_Line__c, quantity FROM OpportunityLineItem where opportunityId in :oList]){
            if(OLI.Product_Line__c == 'RegOnline by Lanyon')
                ROLMap.put(OLI.OpportunityId, OLI.Product_Line__c);
            if(OLI.quantity < 0)   
                NegMap.put(OLI.OpportunityID, OLI.Quantity); 
        }
        for(Opportunity o:oList){
            if(o.StageName=='Closed Won' && o.Number_of_Products__c > 0 && o.Migrated_to_EBS__c == 0){ //String.isBlank(o.EBS_Quote_Number__c)&&String.isBlank(o.EBS_Order_Number__c) && o.VCG_synced_Quote__c!=null
                System.Debug(Logginglevel.FINER,'INTEGRATIONOPPORTUNITY.HANDLENEWOPPORTUNITIES - Opportunity('+o.Id+', '+o.Name+') is valid. Attempting to add to queue.');
                Neg = NegMap.get(o.id);
                if((Neg == 0 || Neg == null) && ROLMap.size() == 0) 
                    newO.Add(o.Id);
            }
            else
                System.Debug(Logginglevel.FINER,'INTEGRATIONOPPORTUNITY.HANDLENEWOPPORTUNITIES - Contact('+o.Id+', '+o.Name+') is not valid. Skipping');
        }
        if(!newO.isEmpty()){
            System.Debug(Logginglevel.FINER,'INTEGRATIONOPPORTUNITY.HANDLENEWOPPORTUNITIES - Adding '+newO.size()+' items to the queue.');
            addtoQueue(newO,'Create');
        }
    }
    
    public static void handleUpdatedOpportunities(List<Opportunity> oList,map<Id,Opportunity> oldList){
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONOPPORTUNITY.HANDLEUPDATEDOPPORTUNITIES - Start');
        
        //
        // First, see if we actually need to process any of the opps
        // Logic below indicates we only need to process records if:
        //   - oldMap doesn't have the opp in it (which should never happen if this is called before/after Update!?)
        //   - oldMap has the opp, and the opp is being switched to Closed Won
        //
        // There are other restrictions as well, but checking for the above and making sure the
        // opps pass at least those criteria should keep us from executing the rest of this code
        // over and over again when it's not needed. Currently this code is being called 8 times
        // during a CPQ save quote as primary, resulting in 16 extra queries, which is contributing
        // to SOQL Query Limit errors. -LC <lawrence.coffin@cloudsherpas.com> 2015-08-04
        //
        Boolean needsProcessing = false;
        for (Opportunity o : oList) {
            if (!oldList.containsKey(o.Id)
                || (o.StageName == 'Closed Won' && oldList.get(o.Id).StageName != 'Closed Won'))
            {
                needsProcessing = true;
                break;
            }
        }
        
        if (needsProcessing == false)
        {
            return;
        }
        // End entry checks
        
        List<Id> updateO=new List<Id>();
        //Added by Joe Henry to handle negative quantity
        map<id, Decimal> NegMap = new map<id, Decimal>();
        map<id, string> ROLMap = new map<id, string>();
        Decimal Neg = 0;
        //for(OpportunityLineItem  OL : [Select id, quantity, OpportunityID from OpportunityLineItem where  quantity < 0 and OpportunityID in :oList])
        
        for(OpportunityLineItem OLI : [SELECT opportunityId, Product_Line__c, quantity FROM OpportunityLineItem where opportunityId in :oList]){
            if(OLI.Product_Line__c == 'RegOnline by Lanyon')
                ROLMap.put(OLI.OpportunityId, OLI.Product_Line__c);
            if(OLI.quantity < 0)   
                NegMap.put(OLI.OpportunityID, OLI.Quantity); 
        }
        //End addition by Joe henry
        for (Opportunity o : oList){
            System.Debug(Logginglevel.FINER,'INTEGRATIONOPPORTUNITY.HANDLEUPDATEDOPPORTUNITIES - Testing '+o.Id+', '+o.Name);
            Opportunity old = oldList.get(o.Id);
            System.debug('*******Old Value*****'+ oldList + '****new value****'+ o);
            if (old != null && old.StageName != 'Closed Won' && o.StageName == 'Closed Won' && o.Migrated_to_EBS__c == 0) //String.isBlank(o.EBS_Quote_Number__c) && o.VCG_synced_Quote__c != null
            {
                Neg = NegMap.get(o.id);
                System.Debug(Logginglevel.FINER,'INTEGRATIONOPPORTUNITY.HANDLEUPDATEDOPPORTUNITIES - old.StageName '+old.StageName+'  New StageName'+o.StageName+'  o.Migrated_to_EBS__c '+o.Migrated_to_EBS__c+'  Neg'+Neg+' ROLMap.size  '+ROLMap.size());     
                if((Neg == 0 || Neg == null) && ROLMap.size() == 0){
                    if(o.StageName != old.StageName){
                        System.Debug(Logginglevel.FINEST,'INTEGRATIONOPPORTUNITY.HANDLEUPDATEDOPPORTUNITIES - Changes detected. Adding '+o.Id+', '+o.Name+' to queue');
                        updateO.Add(o.Id);
                    }  
                    else
                        System.Debug(Logginglevel.FINEST,'INTEGRATIONOPPORTUNITY.HANDLEUPDATEDOPPORTUNITIES - No changes detected for '+o.Id+', '+o.Name+'. skipping');
                }
            }
            else if (old == null)
                updateO.Add(o.Id);
        }
        if(!updateO.isEmpty()){
            System.Debug(Logginglevel.FINE,'INTEGRATIONOPPORTUNITY.HANDLEUPDATEDOPPORTUNITIES - Adding '+updateO.size()+' opportunities to queue.');
            addToQueue(updateO, 'Update');
        }
        
    }
    
    public static void updateParentAccount(List<Opportunity> oList,map<Id,Opportunity> oldList){
        List <Account> parentAccounts = new List <Account>();
        List <Opportunity> updatedOptys = new List<Opportunity>();
        Set <Id> AccIDs = new Set <Id>();
        
        Set <Id> sAccIDs = new Set <Id>();
        Map<Id,Account> mapAccounts =new Map<Id,Account>();
        
        System.Debug(Logginglevel.DEBUG,'IntegrationOpportunity.updateParentAccount - Start');  
        
        if(oldList == null){
            for (Opportunity newOpportunity : oList){
                
                //Get only the opty's which has Account 
                if (newOpportunity.AccountID != null) {
                    updatedOptys.add(newOpportunity);                      
                }
            }
        }       
        else{               
            for (Opportunity newOpportunity : oList){
                Opportunity oldOpportunity = oldList.get(newOpportunity.Id);
                //Get only the opty's which has Account changed
                if (oldOpportunity.AccountID != newOpportunity.AccountID && (newOpportunity.AccountID != null)) {
                    updatedOptys.add(newOpportunity);
                }
            }
        }
        if (!updatedOptys.isEmpty()){     
            for (Opportunity o : updatedOptys){               
                sAccIDs.Add(o.AccountId);
            }
            if(sAccIDs.Size() >0){
                mapAccounts = new Map<Id,Account>([SELECT Id, ParentId FROM Account where Id IN :sAccIDs]); 
                if(mapAccounts.Size() > 0){
                    for (Opportunity o : updatedOptys){
                        Account refAccount = mapAccounts.Get(o.AccountId);
                        if(refAccount.ParentId != null){
                            o.Parent_Account__c = refAccount.ParentId;
                        }
                        else{
                            o.Parent_Account__c  = null; 
                        }
                    }
                }
            } 
        }
    }

    private static void addToQueue(List<Id> aList,String updateType)
    {
        addToQueue(aList, updateType, null);
    }
    
    @TestVisible private static void addToQueue(List<Id> cList,String updateType, String ebsOrderSyncId){
        String qName='Opportunity';
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONOPPORTUNITY.ADDTOQUEUE - Start');
        System.Debug(Logginglevel.FINE,'INTEGRATIONOPPORTUNITY.ADDTOQUEUE - Building list of field mappings');
        List<EBS_Integration__c> fieldList=[SELECT Name,Object__c,Field__c,Map_To__c,Map__c,Validate__c FROM EBS_Integration__c WHERE Object__c='Opportunity' AND Map__c=true];
        Map<String,EBS_Integration__c> fieldMap=new Map<String,EBS_Integration__c>();
        
        for(EBS_Integration__c f:fieldList){
            fieldMap.put(String.ValueOf(f.Field__c).ToUpperCase(),f);
        }
        
        String queryString='SELECT ';
        for(EBS_Integration__c f:fieldList){
            queryString+=f.Field__c+',';
        }
        if(queryString!='SELECT '){
            
            /* Pull all relevant data to ensure a staggered sync for New Customers. The following fields are already part of EBS Integration Settings. If any of these
            * doesnt have a valid EBS Id value, then sync those first with EBS before sending the order. Utilize the EBS Order Sync Framework object.
            * 
            * Account.EBS_Account_Id__c
            * Bill_to_Address__r.EBS_Site_Use_ID__c
            * Ship_To_Address__r.EBS_Site_Use_ID__c
            * Bill_To_Contact__r.EBS_Contact_Id__c
            * Ship_To_Contact__r.EBS_Contact_ID__c
            * Sold_To_Company__r.EBS_Account_Id__c
            * */
            //queryString+=' Owner.Skip_EBS_Sync__c, ';
            
            Map<String,Integration_Queue__c> newList=new Map<String,Integration_Queue__c>();
            Map <Id, EBS_Order_Sync_Framework__c> orderSyncMap=new Map<Id, EBS_Order_Sync_Framework__c>();
            
            queryString+='id,License_Type__c, (select Id from EBS_Order_Sync_Framework__r) FROM Opportunity WHERE Id IN :cList';
            System.Debug(Logginglevel.FINE,'INTEGRATIONOPPORTUNITY.ADDTOQUEUE - Running query: '+queryString);
            //try{
                for(Opportunity o:Database.query(queryString)){
                    if(o.Bill_to_Address__c == null || o.Ship_To_Address__c == null 
                       || o.Bill_To_Contact__c == null || o.Ship_To_Contact__c == null){
                           System.debug('#CheckPoint 1');
                           System.Debug(Logginglevel.FINER,'INTEGRATIONOPPORTUNITY.ADDTOQUEUE - Bill To/Ship To/Sold To required data missing....SKIPPING SYNC PROCESS **** ');
                           continue;       
                       } 
                    else { 
                            System.debug('#CheckPoint 2');           
                           //System.Debug(Logginglevel.FINER,'INTEGRATIONOPPORTUNITY.ADDTOQUEUE - Adding opportunity ('+o.Id+', '+o.Name+' to queue.');
                        
                            if(ebsOrderSyncId == null && o.EBS_Order_Sync_Framework__r.size() > 0){
                                System.debug('#CheckPoint 3');
                               System.Debug(Logginglevel.FINER,'INTEGRATIONOPPORTUNITY.ADDTOQUEUE - Found associated EBS Order Sync Framework Record. Tying the process back to this framework record.');
                                ebsOrderSyncId = o.EBS_Order_Sync_Framework__r[0].Id;
                            }
                            
                           if(o.Account.EBS_Account_Id__c != null && o.Bill_to_Address__r.EBS_Site_Use_ID__c != null && o.Ship_To_Address__r.EBS_Site_Use_ID__c != null 
                              && o.Bill_To_Contact__r.EBS_Contact_Id__c != null && o.Ship_To_Contact__r.EBS_Contact_ID__c != null && ebsOrderSyncId != null) 
                           {
                               System.debug('INSDIE BIG IF IFRST');
                               Integration_Queue__c newItem=IntegrationHelper.mapToQueue(o,fieldList);
                               if(newItem!=null){
                                   if(o.License_Type__c!='Pay Go' && o.License_Type__c!='PayGo'){//This check is added for the PayGo integration as we don't want to sync paygo opportunity into EBS.
                                       newItem.Queue__c=qName;
                                       newItem.Status__c='Queued';
                                       newItem.Object_ID__c=o.Id;
                                       newItem.Type__c=updateType;
                                       newItem.Last_Modified_By_Email__c = newItem.Last_Modified_By_Email__c;
                                       newItem.EBS_Order_Sync_Process_Id__c = ebsOrderSyncId;    
                                       newItem.Put(fieldMap.get('OWNER.EMPLOYEENUMBER').Map_To__c,o.Owner.EmployeeNumber);
                                       newList.Put(newItem.Object_Id__c,newItem);
                                   }
                               }
                               else
                                   System.Debug(Logginglevel.ERROR,'INTEGRATIONOPPORTUNITY.ADDTOQUEUE - Unable to map to queue.');
                           } else {
                               System.debug('Inside EBS Sync ELSE UP ONE**********');
                               //System.Debug(Logginglevel.FINER,'INTEGRATIONOPPORTUNITY.ADDTOQUEUE - Dependent Data Requires Sync: NEW CUSTOMER/ADDRES/CONTACT Situation for opportunity ('+o.Id+', '+o.Name+' to queue.');
                               if(ebsOrderSyncId != null ){
                                   System.debug('Inside EBS Sync If**********');
                                   System.Debug(Logginglevel.FINER,'INTEGRATIONOPPORTUNITY.ADDTOQUEUE -EBS Order Sync Record '+ebsOrderSyncId+'already exits' );
                                   //Trigger an update to the EBS Order Sync Record
                                   orderSyncMap.put(o.Id, new EBS_Order_Sync_Framework__c(Id=ebsOrderSyncId));
                               } else { 
                                   System.debug('Inside EBS Sync**********');                       
                                   System.Debug(Logginglevel.FINER,'INTEGRATIONOPPORTUNITY.ADDTOQUEUE: Enqueuing for Order Sync Framework...' );
                                   EBS_Order_Sync_Framework__c orderSync = new EBS_Order_Sync_Framework__c();
                                   orderSync.Opportunity__c = o.Id;
                                   orderSyncMap.put(o.Id, orderSync);
                               }
                           }
                       }
                }
            //}catch(Exception e){
                //System.debug(e);
                //System.Debug(Logginglevel.ERROR,'INTEGRATIONOPPORTUNITY.ADDTOQUEUE - Error  '+e.getMessage());
            // }
            System.debug('newList**********'+newList);
            System.debug('orderSyncMap**********'+orderSyncMap);
            if(newList!=null){
                IntegrationHelper.addToQueue(newList,fieldList,qName);
            }
            if(orderSyncMap.size() > 0){
                enqueueOrders(orderSyncMap);
            }            
        }
        else
            System.Debug(Logginglevel.ERROR,'INTEGRATIONOPPORTUNITY.ADDTOQUEUE - No field mappings for opportunity found!');
    }
    
    @TestVisible private static void enqueueOrders(Map <Id, EBS_Order_Sync_Framework__c> orderSyncMap){
        upsert orderSyncMap.values();
    }

    webservice static void resyncOpportunity(String oppId) {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONOPPORTUNITY.resyncOpportunity - Start.');
        List<Id> newO=new List<Id>();
        newO.Add(oppId);
        System.Debug(Logginglevel.FINER,'INTEGRATIONOPPORTUNITY.resyncOpportunity - Adding '+newO.size()+' items to the queue.');
        addtoQueue(newO,'Create');
    }
    
    webservice static void resyncOpportunityForOrderSync(String oppId, String ebsOrderSyncId) {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONOPPORTUNITY.resyncOpportunityForOrderSync - Start. EBS Order Sync Id is '+ebsOrderSyncId);
        List<Id> newO=new List<Id>();
        newO.Add(oppId);
        System.Debug(Logginglevel.FINER,'INTEGRATIONOPPORTUNITY.resyncOpportunityForOrderSync - Adding '+newO.size()+' items to the queue.');
        addtoQueue(newO,'Create', ebsOrderSyncId);
    }    
}