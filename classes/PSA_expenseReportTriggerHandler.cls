/****************************************************************************************
Name            : PSA_expenseReportTriggerHandler
Author          : TOP Step Consulting - Andy Heidrich (aheidrich@topstepconsulting.com)
Created Date    : 
Description     : Contains methods called from Triggers on the Expense Report object. All
				: Expense Report trigger code should go in this class.  Each method
				: has its description listed at the beginning of the method.
Changelog		: 
******************************************************************************************/
public class PSA_expenseReportTriggerHandler {

    //Method to populate the Approver field on Expense Report
    //Populates with Resource's Manager if project Expense Approval Method is Resource Manager
    //(or if PM is submitting against his or her own Project)
    //Populates with Project Manager if project Expense Approval Method is Project Manager
    //Runs in before insert/update context
    public static void populateApprover(list<pse__Expense_Report__c> erList) {
        
        if(PSA_Utils.isTriggerDisabled('ERpopulateApprover')) { return; }
        
        //Declare sets to hold Ids for SOQL
        set<Id> projIds = new set<Id>();
    	set<Id> resIds = new set<Id>();
    
    	//Loop through ERs in this batch and add Ids to sets
        for(pse__Expense_Report__c er : erList) {
        
        	projIds.add(er.pse__Project__c);
        	resIds.add(er.pse__Resource__c);
    	}
    
    	//Create map of ER Projects and required fields
        map<Id,pse__Proj__c> projMap = new map<Id,pse__Proj__c>
        	([SELECT Id, Expense_Approval_Method__c,
              pse__Project_Manager__c,
              pse__Project_Manager__r.pse__Salesforce_User__c
         	  FROM pse__Proj__c WHERE Id IN : projIds]);
    
    	//Create map of ER Resources and required fields
        map<Id,Contact> resMap = new map<Id,Contact>
        	([SELECT Id, pse__Salesforce_User__c, pse__Salesforce_User__r.ManagerId
		 	  FROM Contact WHERE Id IN : resIds]);
    
    	//Loop through the ERs
        for(pse__Expense_Report__c er : erList) {
        
            
            //Assign Ids of Resource, PM, and RM Users and contacts, 
            //assign Expense Approval Method to string
            Id res = er.pse__Resource__r.pse__Salesforce_User__c;
            Id rm = resMap.get(er.pse__Resource__c).pse__Salesforce_User__r.ManagerId;
            Id pm = projMap.get(er.pse__Project__c).pse__Project_Manager__r.pse__Salesforce_User__c;
            Id pmCon = projMap.get(er.pse__Project__c).pse__Project_Manager__c;
            Id resCon = er.pse__Resource__c;
            string approvalMethod = projMap.get(er.pse__Project__c).Expense_Approval_Method__c;
            
            //Perform validation that PM Salesforce User is in place if Approval route is PM
            if(approvalMethod == 'Project Manager' && resCon != pmCon) {
               
               	//Error if no PM
                if(pm == null && er.pse__Status__c == 'Submitted') {
                   	er.addError('Either this Project has no Project Manager defined, or the PM does not have a ' +
                                'Salesforce User populated on his or her Contact record. You must have a Project ' +
                                'Manager to submit Expense Reports against projects where the Expense Approval ' +
                                'Method is \'Project Manager.\'');
               	}
                
               	//If it's all good, populate the Approver field
                else {
                   	er.pse__Approver__c = pm;
               	}
            }
            
            //Perform validation that Resource has Manager if Approval route 
            //is Resource Manager or PM is submitting against own Project.
            else if(projMap.get(er.pse__Project__c).Expense_Approval_Method__c == 'Resource Manager' || resCon == pmCon) {
                
               	//Error if Resource has no Manager
                if(rm == null && er.pse__Status__c == 'Submitted') {
                   	er.addError('You do not have a Manager populated on your User record.  This is required to submit ' +
                                'Expense Reports against Projects where the Expense Approval Method is \'Resource ' +
                                'Manager\' (or when you are the PM submitting against your own Project).  Please contact ' +
                                'the Help Desk to correct this issue.');
               	}
                
               	//If it's all good, populate the Approver field
                else {
                   	er.pse__Approver__c = rm;
               	}
            }        
    	}
    }
    

	//Method to create Integration Queue records from Expense Report records.  If a resource has
	//an EBS Vendor Number on his or her Resource record and the Expense Report is Approved and has
	//not yet been integrated, it is added to the queue for record creation.  Moved from Lanyon2
	//SFDC instance (and moved from trigger to class); originally developed by Joe Henry @ Cloud Sherpas	
	public static void handleNewExpenseReport(List<pse__Expense_Report__c> eList) {
		
        if(PSA_Utils.isTriggerDisabled('handleNewExpenseReport')) { return; }
		
        System.Debug(Logginglevel.DEBUG,'IntegrationExpenseReport.handleNewExpenseReport - Start.');
        List<Id> newO=new List<Id>();
        for(pse__Expense_Report__c o : eList)
        {
            //Only run if Approved Expense Report with blank EBS ID, where resource has an EBS
            //Vendor Number populated on his or her Contact record
            if(o.pse__Status__c == 'Approved' && String.isBlank(o.EBS_ID__c) && !string.isBlank(o.EBS_Vendor_Num__c))
            {
                System.Debug(Logginglevel.FINER,'IntegrationExpenseReport.handleNewExpenseReport - Expense Report('+o.Id+', '+o.Name+') is valid. Attempting to add to queue.');
                //Add to queue list
                newO.Add(o.Id);
            } 
            else
                System.Debug(Logginglevel.FINER,'IntegrationExpenseReport.handleNewExpenseReport - Expense Report('+o.Id+', '+o.Name+') is not valid. Skipping');
        }
        if(!newO.isEmpty()) 
        {
            System.Debug(Logginglevel.FINER,'IntegrationExpenseReport.handleNewExpenseReport - Adding '+newO.size()+' items to the queue.');
            //Send list to addToQueue method
            addtoQueue(newO,'Create');
        }
	}

	//Method to Build integration queue records - create mapping against Custom Setting, define
	//integration queue records, and pass them to IntegrationHelper for addition to queue
    private static void addToQueue(List<Id> cList,String updateType)
    {
        String qName='ExpenseReport';
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONEXPENSEREPORT.ADDTOQUEUE - Start');
        System.Debug(Logginglevel.FINE,'INTEGRATIONEXPENSEREPORT.ADDTOQUEUE - Building list of field mappings');
        
        //Get the mappings for Expense Report from the Custom Setting
        List<EBS_Integration__c> fieldList=[SELECT Name,Object__c,Field__c,Map_To__c,Map__c,Validate__c FROM EBS_Integration__c WHERE Object__c='pse__Expense_Report__c' AND Map__c=true];
        //Create a keyed map of the mappings with field name as key
        Map<String,EBS_Integration__c> fieldMap=new Map<String,EBS_Integration__c>();
        for(EBS_Integration__c f:fieldList)
        {
            fieldMap.put(String.ValueOf(f.Field__c).ToUpperCase(),f);
        }
        
        //Build the query
        String queryString='SELECT ';
        for(EBS_Integration__c f:fieldList)
        {
            queryString+=f.Field__c+',';
        }
        
        if(queryString!='SELECT ')
        {
            Map<String,Integration_Queue__c> newList=new Map<String,Integration_Queue__c>();
            queryString+='Id, Name FROM pse__Expense_Report__c WHERE Id IN :cList';
            System.Debug(Logginglevel.FINE,'INTEGRATIONEXPENSEREPORT.ADDTOQUEUE - Running query: '+queryString);
            try
            {
                for(pse__Expense_Report__c o:Database.query(queryString))
                {
                    System.Debug(Logginglevel.FINER,'INTEGRATIONEXPENSEREPORT.ADDTOQUEUE - Adding pse__Expense_Report__c ('+o.Id+', '+o.Name+' to queue.');
                    Integration_Queue__c newItem=IntegrationHelper.mapToQueue(o,fieldList);
                    if(newItem!=null)
                    {
                        newItem.Queue__c=qName;
                        newItem.Status__c='Queued';
                        newItem.Object_ID__c=o.Id;
                        newItem.Type__c=updateType;
                       
                        newList.Put(newItem.Object_Id__c,newItem);
                    }
                    else
                        System.Debug(Logginglevel.ERROR,'INTEGRATIONEXPENSEREPORT.ADDTOQUEUE - Unable to map to queue.');
                }
            }
            catch(Exception e)
            {
                System.Debug(Logginglevel.ERROR,'INTEGRATIONEXPENSEREPORT.ADDTOQUEUE - Error  '+e.getMessage());
            }
            if(newList!=null)
            {
                IntegrationHelper.addToQueue(newList,fieldList,qName);
            }
        }
        else
            System.Debug(Logginglevel.ERROR,'INTEGRATIONEXPENSEREPORT.ADDTOQUEUE - No field mappings for Expense_Report found!');
    }
    
    public static void createExpenseReportShare(map<Id,pse__Expense_Report__c> erMap) {
        
        // Create a new list of sharing objects for Expense Report
        List<pse__Expense_Report__Share> erShrs  = new List<pse__Expense_Report__Share>();
        
        // Declare variables
        pse__Expense_Report__Share mShr;       
             
        set<string> dupeChecker = new set<string>();
        for(pse__Expense_Report__Share ers : [SELECT ParentId, UserOrGroupId
                                      		  FROM pse__Expense_Report__Share WHERE
                                              ParentId IN : erMap.keyset()]) 
        {
            string theKey = string.valueOf(ers.ParentId) + string.valueOf(ers.UserOrGroupId);
            dupeChecker.add(theKey);
        }
        
        for(pse__Expense_Report__c er : [Select pse__Approver__c,
                                         pse__Project__r.Expense_Approval_Method__c
                                         from pse__Expense_Report__c where Id in : erMap.keySet()]) {
        
            
                
                // Instantiate the sharing object
                mShr = new pse__Expense_Report__Share();
                     
                // Set the ID of record being shared
                mShr.ParentId = er.Id;
                                             
                string theKey = string.valueOf(er.Id) + string.valueOf(er.pse__Approver__c);
                                
                //Share with Approver  
                if(er.pse__Approver__c != null && !dupeChecker.contains(theKey)) {
                  
					 //Set the IDs
					 mShr.UserOrGroupId = er.pse__Approver__c;
				 
					 // Set the access level
					 mShr.AccessLevel = 'edit';
				   
					 // Set the Apex sharing reason
					 mShr.RowCause = Schema.pse__Expense_Report__Share.RowCause.psaMgrShare__c;
				   
					 // Add objects to list for insert
					 erShrs.add(mShr);
				}
					
		 //End For Loop
         }
            
		if(erShrs.isEmpty()){}
		else{        
            // Insert sharing records and capture save result 
            // The false parameter allows for partial processing if multiple records are passed 
            // into the operation 
            Database.SaveResult[] lsr = Database.insert(erShrs,false);
            
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
                        trigger.newMap.get(erShrs[i].ParentId).
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