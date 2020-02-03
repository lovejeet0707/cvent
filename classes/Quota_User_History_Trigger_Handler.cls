public class Quota_User_History_Trigger_Handler{

// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 02/03/2016
// PURPOSE     :  To handle trigger methods
// TEST CLASS :   Quota_User_History_Trigger_Handler_Test
// TRIGGER: QuotaUserHistoryTrigger
// SPECIAL NOTES:
// ===============================
    
    
    //Before Insert
    public void OnBeforeInsert( List<Quota_User_History__c> newValues ){
    }
    
    //Before Update
    public void OnAfterInsert( Map<Id,Quota_User_History__c> newMap ){
    }
    
    
    //Before Update
    public void OnBeforeUpdate( Map<Id,Quota_User_History__c> newMap , Map<Id,Quota_User_History__c> oldMap ){
    }
        
    //After Update    
    public void OnAfterUpdate( Map<Id,Quota_User_History__c> newMap , Map<Id,Quota_User_History__c> oldMap ){
        //Calling Method to Insert New Quota History for Existing User If Some Information is Changed
        CreateHistoryForExistingUser(newMap.Values(),oldMap);
    }
    
    
    
    
    /* METHODS */
    
    //Method to Insert Quota History If Existing User Role/Title/EffectiveDate is changed
    public void CreateHistoryForExistingUser(List<Quota_User_History__c> newValues , Map<Id,Quota_User_History__c> oldMap){
    List<Quota_User_History__c> qHistoryToInsert = new List<Quota_User_History__c>();
    
    System.debug(' **** Quota History New Values ********* ' + newValues);
    System.debug(' **** Quota History Old Values ********* ' + oldMap.Values());
    
            for( Quota_User_History__c  qh: newValues ){
                
                
                Quota_User_History__c  Oldqh = oldMap.Get(qh.Id);
                
                //IF VALUES ARE CHANGED FOR THREE FIELDS
                if( Oldqh.Role__c != qh.Role__c || Oldqh.Title__c != qh.Title__c || Oldqh.Effective_Date__c != qh.Effective_Date__c || Oldqh.Sales_Team_Members__c != qh.Sales_Team_Members__c ){
                    
                    Quota_User_History__c  qHistoryOld  =  oldMap.get(qh.Id);
                    
                    //New Record Creation From Old record Cloning
                    Quota_User_History__c  qHistoryNew  =  qHistoryOld.Clone(false,true);
                    
                    qHistoryNew.Is_Current__c =  false; 
                    qHistoryToInsert.Add(qHistoryNew);
                }
            }
            
            if(qHistoryToInsert.size()>0){
                insert qHistoryToInsert;
            }
    }
    
    
}