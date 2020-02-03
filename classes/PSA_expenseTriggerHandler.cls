/****************************************************************************************
Name            : PSA_expenseTriggerHandler
Author          : TOP Step Consulting - Andy Heidrich (aheidrich@topstepconsulting.com)
Created Date    : 
Description     : Contains methods called from Triggers on the Expense object. All
				: Expense trigger code should go in this class.  Each method
				: has its description listed at the beginning of the method.
Changelog		: 
******************************************************************************************/

public class PSA_expenseTriggerHandler {

	//Method to populate the Expense Type lookup on Expense records
	//from the Expense Types object.  This allows the COGS/Internal
	//GL Account # to be pulled onto the Expense record via formula.
	//Used in EBS integration.  Called before Expense insert/update.    
    public static void setExpenseType(list<pse__Expense__c> eList) {
        
        if(PSA_Utils.isTriggerDisabled('setExpenseType')) { return; }
        
        //Declare map for Expense Type records
        map<string,Expense_Type__c> etMap = new map<string,Expense_Type__c>();
        //Loop through query of Expense Type records
        for(Expense_Type__c et : [SELECT Id, Name, COGS_Account_Number__c, Internal_Account_Number__c
                                  FROM Expense_Type__c])
        {
            //Put Expense Type name and values in the map
            etMap.put(et.Name, et);
        }
        
        //Loop through the Expenses in this batch
        for(pse__Expense__c e : eList) {
            //Proceed if we have Expense Types
            if(!etMap.isEmpty()) {
            	//Proceed if this Expense's Type is in the map
                if(etMap.containsKey(e.pse__Type__c)) {
                	//Populate the lookup
                    e.Expense_Type__c = etMap.get(e.pse__Type__c).Id;
            	}    
            }   
        }
    }
    
    public static void createExpenseShare(map<Id,pse__Expense__c> eMap) {
        
        // Create a new list of sharing objects for Expense Report
        List<pse__Expense__Share> eShrs  = new List<pse__Expense__Share>();
        
        set<string> dupeChecker = new set<string>();
        for(pse__Expense__Share es : [SELECT ParentId, UserOrGroupId
                                      FROM pse__Expense__Share WHERE
                                      ParentId IN : eMap.keyset()]) 
        {
            string theKey = string.valueOf(es.ParentId) + string.valueOf(es.UserOrGroupId);
            dupeChecker.add(theKey);
        }
        
        // Declare variables
        pse__Expense__Share mShr;       
             
        for(pse__Expense__c e : [Select pse__Expense_Report__r.pse__Approver__c,
                                 pse__Project__r.Expense_Approval_Method__c
                                 from pse__Expense__c where Id in : eMap.keySet()]) {
        
            
                
                // Instantiate the sharing object
                mShr = new pse__Expense__Share();
                     
                // Set the ID of record being shared
                mShr.ParentId = e.Id;
                                     
                string theKey = string.valueOf(e.Id) + string.valueOf(e.pse__Expense_Report__r.pse__Approver__c);
                                
                //Share with Approver  
                if(e.pse__Expense_Report__r.pse__Approver__c != null  && !dupeChecker.contains(theKey)) {
                  
					 //Set the IDs
					 mShr.UserOrGroupId = e.pse__Expense_Report__r.pse__Approver__c;
				 
					 // Set the access level
					 mShr.AccessLevel = 'edit';
				   
					 // Set the Apex sharing reason
					 mShr.RowCause = Schema.pse__Expense__Share.RowCause.psaMgrShare__c;
				   
					 // Add objects to list for insert
					 eShrs.add(mShr);
				}
					
		 //End For Loop
         }
            
		if(eShrs.isEmpty()){}
		else{        
            // Insert sharing records and capture save result 
            // The false parameter allows for partial processing if multiple records are passed 
            // into the operation 
            Database.SaveResult[] lsr = Database.insert(eShrs,false);
            
            // Create counter
            Integer i=0;
            
            // Process the save results
            for(Database.SaveResult sr : lsr){
                if(!sr.isSuccess()){
                    // Get the first save result error
                    Database.Error err = sr.getErrors()[0];
                    
                    // Check if the error is related to a trivial access level
                    // Access levels equal or more permissive than the object's default 
                    // access level are not allowed. 
                    // These sharing records are not required and thus an insert exception is 
                    // acceptable. 
                    if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  
                                                   &&  err.getMessage().contains('AccessLevel'))){
                        // Throw an error when the error is not related to trivial access level.
                        trigger.newMap.get(eShrs[i].ParentId).
                          addError(
                           'Unable to grant sharing access due to following exception: '
                           + err.getMessage());
                    }
                }
                i++;
            }
        }
    }
}