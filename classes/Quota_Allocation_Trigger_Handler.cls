Public Class Quota_Allocation_Trigger_Handler {
        
// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 26/02/2016
// PURPOSE     :  To handle trigger events
// TRIGGER : QuotaAllocationTrigger 
// TEST CLASS : Quota_Allocation_Trigger_Handler_Test
// SPECIAL NOTES:
// ===============================
// Change History:
//
//==================================
    
    
    
    //Before Insert
    public void OnBeforeInsert( List<Quota_Allocation__c>  newValues ){      
       //Check Duplicate Quota Types
       CheckDuplicateQuotaTypes(newValues);
        
       //Updating Direct Manager, Product, VP/SVP Email on Allocation
       Popopulate_DManager_Product_VPEmail(newValues);
    }
    
    //After Insert
    public void OnAfterInsert( Map<ID,Quota_Allocation__c>  newMap ){
        
        
        
        CreateQuotaUserHistory(newMap.values());

       
        SyncMonthlyQuota(newMap.values(),'');
    }
        
        
    //Before Update    
    public void OnBeforeUpdate( Map<ID,Quota_Allocation__c> newMap, Map<ID,Quota_Allocation__c> oldMap ){
            
        //Clear Old Amount of Quota Allocation after Approval
         ClearOldAmountOfQuota(newMap.values(), oldMap);
         
        //Updating Direct Manager, Product, VP/SVP Email on Allocation
        Popopulate_DManager_Product_VPEmail(newMap.values());
            
    }
    
    //After Update
    public void OnAfterUpdate( Map<ID,Quota_Allocation__c>  newMap, Map<ID,Quota_Allocation__c> oldMap ){
            
        //Creation of Quota User History after Approval
        CreateQuotaUserHistory(newMap.values());
        
        SyncMonthlyQuota(newMap.values(),'Update');
    }
    

    /* METHODS */
     
     //Method to update Product field and VP/SVP Email of Product on Quota Allocation object
    //Method to update Direct_Manager_Email__c field from User's Manager
    
    public void Popopulate_DManager_Product_VPEmail(List<Quota_Allocation__c>  newValues){
    
        //Key = User__c and value = List of Allocations per user
        Map<Id,List<Quota_Allocation__c>> mapofAllocation = new Map<Id,List<Quota_Allocation__c>>();
        
        
        for(Quota_Allocation__c q :  newValues ){
            //If Record is approved
            if(mapofAllocation.ContainsKey(q.User__c)){          
                mapofAllocation.Get(q.User__c).add(q);                  
            }
            else{
                mapofAllocation.Put(q.User__c, new List<Quota_Allocation__c>{q});               
            }
        }
            
         //Map of Users 
        Map<Id, User> usersMap = new Map<Id, User>( [ Select Id, Manager.Email, UserRoleId, UserRole.Name From User Where ID IN: mapofAllocation.Keyset() and ManagerId !=null ] );
        
        //Updating Manager, Product and VP of Product on Quota Allocation. 
        for( Id userId :  usersMap.KeySet()){
            
            string roleName = usersMap.Get(userId).UserRole.Name;
            
            //Extracting Product From RoleName
            string product =  roleName == null ? '' : roleName.substringAfterLast('(').RemoveEnd(')');

            List<Quota_Allocation__c> qList = mapofAllocation.Get(userId);
            
            //List of Quota allocation per user 
            for( Quota_Allocation__c qAllocation :  qList ){
                 
                qAllocation.Direct_Manager_Email__c = usersMap.Get(userId).Manager.Email;
                qAllocation.Product_Team__c = product;
                
                if(QuotaProductVpNotification__c.getValues(product)!=null){
                    qAllocation.VP_SVP_Email__c = QuotaProductVpNotification__c.getValues(product).VP_SVP_Email__c;
                }
            }
        }
    }
    
    
    
    //Method to clear old amounts of quota
    public void ClearOldAmountOfQuota( List<Quota_Allocation__c>  newValues, Map<ID,Quota_Allocation__c> oldMapValues  ){
                
        for( Quota_Allocation__c  qa : newValues ){
            
            
            if(qa.Is_Approved__c == true ){
                
                
                //Clear Values once Approval action is performed
                qa.Old_Amount_for_Jan__c     =  NULL ;
                qa.Old_Amount_for_Feb__c     =  NULL ;
                qa.Old_Amount_for_Mar__c     =  NULL ;
                qa.Old_Amount_for_Apr__c     =  NULL ;
                qa.Old_Amount_for_May__c     =  NULL ;
                qa.Old_Amount_for_June__c    =  NULL ;
                qa.Old_Amount_for_July__c    =  NULL ;
                qa.Old_Amount_for_Aug__c     =  NULL ;
                qa.Old_Amount_for_Sept__c    =  NULL ;
                qa.Old_Amount_for_Oct__c     =  NULL ;
                qa.Old_Amount_for_Nov__c     =  NULL ;
                qa.Old_Amount_for_Dec__c     =  NULL ;
                
                
                // Put old values back once record is Rejected
                if(qa.Is_Existing_Rejected__c == true ){
                    
                    qa.Amount_for_Jan__c     =  oldMapValues.Get(qa.Id).Old_Amount_for_Jan__c  == NULL ? qa.Amount_for_Jan__c  : oldMapValues.Get(qa.Id).Old_Amount_for_Jan__c;
                    qa.Amount_for_Feb__c     =  oldMapValues.Get(qa.Id).Old_Amount_for_Feb__c  == NULL ? qa.Amount_for_Feb__c  : oldMapValues.Get(qa.Id).Old_Amount_for_Feb__c;
                    qa.Amount_for_Mar__c     =  oldMapValues.Get(qa.Id).Old_Amount_for_Mar__c  == NULL ? qa.Amount_for_Mar__c  : oldMapValues.Get(qa.Id).Old_Amount_for_Mar__c;
                    qa.Amount_for_Apr__c     =  oldMapValues.Get(qa.Id).Old_Amount_for_Apr__c  == NULL ? qa.Amount_for_Apr__c  : oldMapValues.Get(qa.Id).Old_Amount_for_Apr__c;
                    qa.Amount_for_May__c     =  oldMapValues.Get(qa.Id).Old_Amount_for_May__c  == NULL ? qa.Amount_for_May__c  : oldMapValues.Get(qa.Id).Old_Amount_for_May__c;
                    qa.Amount_for_June__c    =  oldMapValues.Get(qa.Id).Old_Amount_for_June__c == NULL ? qa.Amount_for_June__c : oldMapValues.Get(qa.Id).Old_Amount_for_June__c;
                    qa.Amount_for_July__c    =  oldMapValues.Get(qa.Id).Old_Amount_for_July__c == NULL ? qa.Amount_for_July__c : oldMapValues.Get(qa.Id).Old_Amount_for_July__c;
                    qa.Amount_for_Aug__c     =  oldMapValues.Get(qa.Id).Old_Amount_for_Aug__c  == NULL ? qa.Amount_for_Aug__c  : oldMapValues.Get(qa.Id).Old_Amount_for_Aug__c;
                    qa.Amount_for_Sept__c    =  oldMapValues.Get(qa.Id).Old_Amount_for_Sept__c == NULL ? qa.Amount_for_Sept__c : oldMapValues.Get(qa.Id).Old_Amount_for_Sept__c;
                    qa.Amount_for_Oct__c     =  oldMapValues.Get(qa.Id).Old_Amount_for_Oct__c  == NULL ? qa.Amount_for_Oct__c  : oldMapValues.Get(qa.Id).Old_Amount_for_Oct__c;
                    qa.Amount_for_Nov__c     =  oldMapValues.Get(qa.Id).Old_Amount_for_Nov__c  == NULL ? qa.Amount_for_Nov__c  : oldMapValues.Get(qa.Id).Old_Amount_for_Nov__c;
                    qa.Amount_for_Dec__c     =  oldMapValues.Get(qa.Id).Old_Amount_for_Dec__c  == NULL ? qa.Amount_for_Dec__c  : oldMapValues.Get(qa.Id).Old_Amount_for_Dec__c;
                    
                    //Setting Back to False so that If Record is Approved Next Time Will not enter in this condition.
                    qa.Is_Existing_Rejected__c = false;
                
                }
               
            }
        
        }
        
    }
    
    public void CheckDuplicateQuotaTypes( List<Quota_Allocation__c>  newValues ) {
        
        //UserId's against checking duplicate Quotas
        Set<Id> userIds = new Set<Id>();
        
        string key;
        //KEY = UserId+Type+Year => VALUE = Count
        Map<String,Integer> duplicateCheckMap = new Map<String,Integer>();
        
        
        //Getting new Quotas
        for(Quota_Allocation__c newqa : newValues){
            system.debug('######### ' + newqa.Year__c);
            userIds.add(newqa.User__c);
          
            
            key = string.ValueOf(newqa.User__c) + newqa.Quota_Type__c + newqa.Year__c;

            //Increment the count once key is found
            if( duplicateCheckMap.containsKey(key)){
                duplicateCheckMap.put(key,duplicateCheckMap.get(key)+1);
            }
            //Initialize the count with 1 
            else{
               duplicateCheckMap.put(key,1);
            }
            
        }
            
        //Getting Old Quotas 
        for( Quota_Allocation__c  oldQuota : [Select User__c, Quota_Type__c,Year__c from Quota_Allocation__c Where User__c IN : userIds] ){
           
            //Adding old quota details into existing map
            key = string.ValueOf(oldQuota.User__c) + oldQuota.Quota_Type__c + oldQuota.Year__c;
            //Increment the count once key is found
            if( duplicateCheckMap.containsKey(key)){
                duplicateCheckMap.put(key,duplicateCheckMap.get(key)+1);
            }
            //Initialize the count with 1 
            else{
               duplicateCheckMap.put(key,1);
            }
        }
        
        
        //Adding Error for Duplicate Quotas
        for(Quota_Allocation__c qa : newValues){
            
            key= string.ValueOf(qa.User__c) + qa.Quota_Type__c + qa.Year__c;

            //Duplicate found If count is greater than 2 for this mapping
            if( !duplicateCheckMap.isEmpty() && duplicateCheckMap.get(key)>1){
                qa.addError('Duplicate Quota Type Found..');
            }
        }

    }
    
    
    
    //Create/Update Monthly Quotas (For Reporting Purpose)
    public void SyncMonthlyQuota( List<Quota_Allocation__c> allocationList , String dmlType){
        
        Map<String,String> monthlyAPIvsNameMap = new Map<String,String>();
        monthlyAPIvsNameMap.put('Amount_for_Jan__c', 'January');
        monthlyAPIvsNameMap.put('Amount_for_Feb__c', 'February');
        monthlyAPIvsNameMap.put('Amount_for_Mar__c', 'March');
        monthlyAPIvsNameMap.put('Amount_for_Apr__c', 'April');
        monthlyAPIvsNameMap.put('Amount_for_May__c', 'May');
        monthlyAPIvsNameMap.put('Amount_for_June__c','June');
        monthlyAPIvsNameMap.put('Amount_for_July__c','July');
        monthlyAPIvsNameMap.put('Amount_for_Aug__c', 'August');
        monthlyAPIvsNameMap.put('Amount_for_Sept__c','September');
        monthlyAPIvsNameMap.put('Amount_for_Oct__c', 'October');
        monthlyAPIvsNameMap.put('Amount_for_Nov__c', 'November');
        monthlyAPIvsNameMap.put('Amount_for_Dec__c', 'December');
                
        
        List<Quota_Monthly__c> qMonthlyList = new List<Quota_Monthly__c>();
        
        Map<Id, Map<String,Quota_Monthly__c>> allocationVsMonthlyMap = new Map<Id,Map<String,Quota_Monthly__c>>();
        
        //Existing QuotaId vs Monthly Amount
        if(dmlType == 'Update'){
    
            allocationVsMonthlyMap = new Map<Id,Map<String,Quota_Monthly__c>>();
            for( Quota_Monthly__c qm : [ Select Id, Quota_Allocation__c,Amount__c,Month__c From Quota_Monthly__c Where Quota_Allocation__c IN: allocationList ] ){
                
                    if(allocationVsMonthlyMap.containsKey(qm.Quota_Allocation__c))
                        allocationVsMonthlyMap.get(qm.Quota_Allocation__c).put(qm.Month__c, qm);                        
                    else
                        allocationVsMonthlyMap.put(qm.Quota_Allocation__c, new Map<String,Quota_Monthly__c>{ qm.Month__c => qm});
            }
        }
        
        //Processing 
        for(Quota_Allocation__c qAllocation : allocationList ){
            
            //Iterate Months 
            for( String month : monthlyAPIvsNameMap.keySet() ){
                
                Integer amount = Integer.valueOf(qAllocation.get(month));
                if(amount!=null){ 
                    Quota_Monthly__c qMonthly = new Quota_Monthly__c();
                    
                    //Check for already Exisiting Month Record on Allocation
                    if(allocationVsMonthlyMap.get(qAllocation.Id)!=null && allocationVsMonthlyMap.get(qAllocation.Id).get(monthlyAPIvsNameMap.get(month))!=null){

                        qMonthly.Id = allocationVsMonthlyMap.get(qAllocation.Id).get(monthlyAPIvsNameMap.get(month)).Id;
                    }
                    
                    qMonthly.Year__c = Date.Today().Year();
                    qMonthly.Amount__c = amount;
                    qMonthly.Month__c = monthlyAPIvsNameMap.get(month);
                    qMonthly.Quota_Allocation__c = qAllocation.Id;
                    qMonthlyList.add(qMonthly);
                    
                }
            }
        }
        
        
        if(qMonthlyList.size()>0)
            upsert qMonthlyList;
        
        
    }

    
    //Method to insert Quota User History record per User (Only First Time when Quota is Allocated for New User)
    public void CreateQuotaUserHistory( List<Quota_Allocation__c>  newValues ){
        
        //Collecting User Id's of Quota Allocation Record
        Set<ID> userIdsQAllocation = new Set<ID>();
            
        //Collecting User Id's of Quota User History (Check If user is already there in History table)
        Set<ID> userIdsQUserHistory = new Set<ID>();
        
        //List to insert Quota User History
        List<Quota_User_History__c> qHistoryInsertList = new List<Quota_User_History__c>();
        
        //Direct Sales Team Members for Quota
        Map<Id, String> userIdVsTeamMemb = new Map<Id, String>();
        
        //User Id's of Quota Allocation
        for(Quota_Allocation__c q :  newValues ){
            //If Record is approved
            if(q.Is_Apporved_New__c == true){
                userIdsQAllocation.Add(q.User__c);
                userIdVsTeamMemb.put(q.User__c, q.Sales_Team_Members__c);
            }
        }
        
        //Collecting Users Exist In Quota User History Table
        if(userIdsQAllocation.size()>0){
            for(Quota_User_History__c qh: [ Select Id,User__c, User__r.UserRole.Name ,User__r.Title From Quota_User_History__c Where User__c IN:userIdsQAllocation and Is_Current__c = True ]){
                userIdsQUserHistory.Add(qh.User__c);
            }
        }
        
        
        Map<Id, User> usersMap = new Map<Id, User>([Select Id,Title,UserRole.Name From User Where ID IN: userIdsQAllocation]);
        
             
        for( Id userId : userIdsQAllocation){
            
            //If User doesn't exist in Quota History Table and New Record is Approved, Create User History
       
            if( userIdsQUserHistory.Contains(userId) == false){
                
                Quota_User_History__c qHistory = new Quota_User_History__c();
                qHistory.Effective_Date__c =  Date.Today();
                qHistory.Is_Current__c = true;
                
                qHistory.User__c = userId ;
                qHistory.Title__c = usersMap.get(userId).Title ;
                qHistory.Role__c =  usersMap.get(userId).UserRole.Name;
                
                //Populate Sales Team Members from Quota Allocation
                qHistory.Sales_Team_Members__c =  userIdVsTeamMemb.get(userId);
                
                qHistoryInsertList.add(qHistory);
            }
        
        }
        
        if(qHistoryInsertList.size()>0){
            insert qHistoryInsertList;
        }            
    }
}