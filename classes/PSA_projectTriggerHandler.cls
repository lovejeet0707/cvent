/****************************************************************************************
Name            : PSA_projectTriggerHandler
Author          : TOP Step Consulting - Andy Heidrich (aheidrich@topstepconsulting.com)
Created Date    : 
Description     : Contains methods called from Triggers on the Project object. All
				: Project trigger code should go in this class.  Each method
				: has its description listed at the beginning of the method.
Changelog		: 
******************************************************************************************/

public class PSA_projectTriggerHandler {
    
    //Method to populate PM's Manager and PM's Manager's Manager in hidden
    //fields on the Project.  Called before insert/update    
    public static void populatePMsMgr(list<pse__Proj__c> projList) {
        
        if(PSA_Utils.isTriggerDisabled('populatePMsMgr')) { return; }
        
        //Create and populate a set of PM ContactIds
        set<Id> pmIds = new set<Id>();
        for(pse__Proj__c p : projList) {
            pmIds.add(p.pse__Project_Manager__c);
        }
        
        //Build map of related users, their managers, and their manager's
        //managers using the set of PM Contact Ids
        map<Id,Contact> cMap = new map<Id,Contact>([SELECT Id, pse__Salesforce_User__r.ManagerId,
                                                    pse__Salesforce_User__r.Manager.ManagerId
                                                   FROM Contact
                                                   WHERE Id IN : pmIds]);
        
        //Loop through projects in this batch
        for(pse__Proj__c p : projList) {
            //Only run if PM field is populated
            if(p.pse__Project_Manager__c != null) {
                
                //Set PM's Manager (only if PM's user has a Manager populated on the user record, else skip)
                if(cMap.get(p.pse__Project_Manager__c).pse__Salesforce_User__r.ManagerId != null) {
                    p.PM_s_Manager__c = cMap.get(p.pse__Project_Manager__c).pse__Salesforce_User__r.ManagerId;
                }
                
                //Set PM's Manager's Manager (only if PM's user has a Manager populated on the user record, else skip)
                if(cMap.get(p.pse__Project_Manager__c).pse__Salesforce_User__r.Manager.ManagerId != null) {
                    p.PM_s_Manager_s_Manager__c = cMap.get(p.pse__Project_Manager__c).pse__Salesforce_User__r.Manager.ManagerId;
                }
            }
        }
     }
    
    
    //Method to @mention in Chatter all currently assigned resources when a project's status
    //is set to 'Pending Completion' if their Assignments are also not Closed for Time
    //Entry AND Closed for Expense Entry.  Called from After Update trigger.
    public static void pendingCompletionPost(map<Id,pse__Proj__c> projMap, map<Id,pse__Proj__c> projOldMap) {
        
        if(PSA_Utils.isTriggerDisabled('pendingCompletionPost')) { return; }
        
        //Get post text from Custom Setting for Chatter post
        PSA_Chatter_Settings__c chatterSettings = PSA_Chatter_Settings__c.getValues('Default');
        string postText = chatterSettings.Pending_Completion_Message__c;
        
        //Create set to check for and prevent duplicates
        set<string> preventDupeSet = new set<string>();
        
        //Declare Batch for bulkified posting of Feed Elements
        list<ConnectApi.BatchInput> batchInputs = new list<ConnectApi.BatchInput>();

		//Declare and populate nested map of Project Id (outer key) and Assignment
   		//Id + Assignment (inner map) for assigned resource @mentions
        map<Id,map<Id,pse__Assignment__c>> assignMap = new map<Id,map<Id,pse__Assignment__c>>();
        for(pse__Assignment__c a : [SELECT Id, pse__Resource__r.pse__Salesforce_User__c, pse__Project__c
                                    FROM pse__Assignment__c
                                   	WHERE pse__Project__c IN : projMap.keySet()
                                    AND (pse__Closed_for_Time_Entry__c = FALSE OR
                                         pse__Closed_for_Expense_Entry__c = FALSE)
                                    AND pse__Start_Date__c <= TODAY
                                    AND pse__End_Date__c >= TODAY
                                    AND pse__Resource__r.pse__Is_Resource_Active__c = TRUE
                                    AND (pse__Resource__r.pse__Last_Date__c > TODAY OR 
                                         pse__Resource__r.pse__Last_Date__c = NULL)
                                    AND pse__Resource__r.pse__Salesforce_User__c != NULL])
        {
            if(assignMap.get(a.pse__Project__c) == null) {
                assignMap.put(a.pse__Project__c, new map<Id,pse__Assignment__c>{a.Id => a});
            }
            else {
                assignMap.get(a.pse__Project__c).put(a.Id,a);
            }
        }        
        
        //Loop through the projects and create the feed posts
        for(pse__Proj__c p : projMap.values()) {
        
            //Only run if Project was set to Pending Completion in current update operation
            if(p.pse__Stage__c == 'Pending Completion' && projOldMap.get(p.Id).pse__Stage__c != 'Pending Completion') {
        
                //Declare MessageBodyInput container and segments list to build Chatter post
                ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
                messageInput.messageSegments = new list<ConnectApi.MessageSegmentInput>();
                
                //Create text segment for post body text using text from custom setting
                ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = postText;
                messageInput.messageSegments.add(textSegment);
                
                //Add a couple of carriage returns after the post and before the mentions
                ConnectApi.TextSegmentInput cr = new ConnectApi.TextSegmentInput();
                cr.text = '\r\n' + '\r\n';
                messageInput.messageSegments.add(cr);
               
                //Loop through inner map for this Project in assignMap and add
                //mention segments for each active assigned resource
                if(assignMap.containsKey(p.Id) && assignMap.get(p.Id).values().size() > 0) {
                    for(pse__Assignment__c a : assignMap.get(p.Id).values()) {
                        
                        //Declare key of Project + User Id to use for dupe checking
                        string theKey = string.valueOf(a.pse__Project__c) + string.valueOf(a.pse__Resource__r.pse__Salesforce_User__c);            
                        
                        //Add @mention to List if not in it already
                        if(!preventDupeSet.contains(theKey)) {
                            ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                            mentionSegment.id = a.pse__Resource__r.pse__Salesforce_User__c;
                            messageInput.messageSegments.add(mentionSegment);
                            
                            //Add a space between each @mention
                            ConnectApi.TextSegmentInput space = new ConnectApi.TextSegmentInput();
                			space.text = ' ';
                			messageInput.messageSegments.add(space);
                            
                            //Add Proj + User Id to preventDupeSet
                            preventDupeSet.add(theKey);
                        }
                    }
                }    
                
                //Add PM's Manager to @mention section of Chatter post
                //(if PM not already mentioned via Assignment)
                if(p.PM_s_Manager__c != null) {
                                        
                    //Declare key of Project + User Id to use for dupe checking
                    string theKey = string.valueOf(p.Id) + string.valueOf(p.PM_s_Manager__c);
                    //CC PM's Manager if he/she isn't already getting a mention from an Assignment        
                    if(!preventDupeSet.contains(theKey)) {
                        //Add line breaks and 'CC: ' for PM's Manager
                		ConnectApi.TextSegmentInput cc = new ConnectApi.TextSegmentInput();
                		cc.text = '\r\n' + '\r\n' + 'CC:' + '\r\n';
                		messageInput.messageSegments.add(cc);
                        
                        //@mention PM's Manager
                        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                        mentionSegment.id = p.PM_s_Manager__c;
                        messageInput.messageSegments.add(mentionSegment);
                                
                        //Add Proj + User Id to preventDupeSet
                        preventDupeSet.add(theKey);  
                    }  
                }      
        
                //Construct FeedItemInput using MessageBodyInput and Project Id
                ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                input.body = messageInput;
                input.feedElementType = ConnectApi.FeedElementType.FeedItem;
                input.subjectId = p.Id;
                
                //Add post to batchInputs list for bulk posting
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
                batchInputs.add(batchInput);
        
            }
        }
        
        //Post messages to Chatter if there are messages to post
        if(!batchInputs.isEmpty()) {
        	ConnectApi.ChatterFeeds.postFeedElementBatch(null,batchInputs);
        }
    }

}