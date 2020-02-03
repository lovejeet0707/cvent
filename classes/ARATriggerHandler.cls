// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 02/03/2016
// PURPOSE     :  To handle trigger methods
// TEST CLASS :   TestARATrigger
// SPECIAL NOTES:
// ===============================

Public Class ARATriggerHandler {
    
    
    
    //"ARA Sharing Group"
    static Group []groupARA = [Select Id From Group Where DeveloperName = 'ARA_Sharing_Group'];
    
    //Before Insert
    Public void onBeforeInsert(List<ARA__c> newAraRecords){
    }
    
    //Before Update
    Public void onBeforeUpdate( Map<Id,ARA__c> newMapAra, Map<Id,ARA__c> oldMapAra ){       
    
    }
    
    
    /*START ADDED BY SHANU for ARA Sharing Project (Date 14-03-2016)
    ************************************************/
    
    //Method to Share Opportunities with a Group called "ARA Sharing Group" when Account is at Risk
    Public void OpportunitySharing( List<ARA__c> newAraRecords){
            
            //Id's of Accounts
            Set<Id> accIds = new Set<Id>();
            
            //Id's of Assignee of ARA
            Set<Id> assigneToIds = new Set<Id>();         
            
            //List of AccountTeamMembers 
            List<AccountTeamMember> accMembersList = new List<AccountTeamMember>();
            
            //Key = AccountId, Value = Id's of Assignee of ARA
            Map<Id, Set<ID> > accountVSAssigneeMap = new Map<Id, Set<ID>>();
        
            //If ARA is created for Account Risk
            for(ARA__c araobj : newAraRecords){

                if( araobj.Status__c != 'Closed Won' && araobj.Status__c != 'Closed-Lost' ){
                        
                        accIds.add(araobj.Account__c);
                        
                        //Assinee not blank on ARA
                        if(araobj.Assigned_To__c!=null){
                            
                            assigneToIds.add(araobj.Assigned_To__c);
                            
                            //Adding Assignees per Account
                            if(accountVSAssigneeMap.ContainsKey(araobj.Account__c)){
                                accountVSAssigneeMap.get(araobj.Account__c).Add(araobj.Assigned_To__c);
                            }
                            else{
                                accountVSAssigneeMap.put(araobj.Account__c, new Set<Id>{araobj.Assigned_To__c});
                            }
                        }
                }
            }
            
            //List of Accounts to share associated Opportunity with a Group using Criteria Based Sharing Rule defined on Account
            List<Account> accList = [ Select Id, Is_Opp_Shared_With_Risk_Group__c From Account Where Id IN :accIds];
        
            
            List<Account> accsToUpdate = new List<Account> ();
            
                    //Sharing Opportunity Record with a Group by setting field Is_Opp_Shared_With_Risk_Group__c = true on Account
                    for( Account accObj : accList ){
                            accObj.Is_Opp_Shared_With_Risk_Group__c = true;
                            accsToUpdate.add(accObj); 
                            
                            //Adding Team Members into List
                            Set<ID> assigneeIds =  accountVSAssigneeMap.get(accObj.Id);
                            
                            if(assigneeIds!=null && assigneeIds.size()>0){
                                
                                for(Id assigneeId : assigneeIds){
                                    
                                    AccountTeamMember accMember = new AccountTeamMember();
                                    accMember.AccountId = accObj.Id;
                                    accMember.TeamMemberRole = 'ARA Manager';
                                    accMember.UserId = assigneeId;
                                    accMembersList.Add(accMember);
                                }
                            }
                    }
                     
            //Sharing Opportunities by updating Accounts
            if(accsToUpdate.size()>0){
                Update accsToUpdate;
            }
            
            //Adding Assigned_To__c to AccountTeamMember
            if(accMembersList.size()>0){
                Insert accMembersList;
            }
            
            
            //Adding Assigned_To__c to a Group "ARA Sharing Group"
            if(groupARA.size()>0 && assigneToIds.size()>0){       
                groupMemberListSharingUser(assigneToIds, 'Add to Group');
            }   
    
    }
    
    //Method to Delete Account Team Members once ARA is Closed. (18-01-2017)
    Public void DeleteAccountTeamMembers( List<ARA__c> newAraRecords ){
        
        //Id's of Accounts
        Set<Id> accIds = new Set<Id>();
        
         //If ARA is created for Account Risk
        for(ARA__c araobj : newAraRecords){
            
            if( araobj.Status__c == 'Closed Won' || araobj.Status__c == 'Closed-Resolved' || araobj.Status__c == 'Closed-Lost' || araobj.Status__c == 'Unqualified'  ){
                accIds.add(araobj.Account__c);
            }
            
        }
        
        List<AccountTeamMember> accMemberList = [Select Id From AccountTeamMember Where TeamMemberRole = 'ARA Manager' and AccountID IN: accIds];
        
        if(accMemberList.size()>0)
            delete accMemberList;
    }
    
    //Method to Remove access from Opportunities with a Group called "ARA Sharing Group" when Account is not at Risk
    Public void RemoveOpportunitySharing( List<ARA__c> newAraRecords){
            
            //Id's of Accounts
            Set<Id> accIds = new Set<Id>();
            
            //Id's of Assignee of ARA
            Set<Id> assigneToIds = new Set<Id>();
            
            //List of AccountTeamMembers 
            List<AccountTeamMember> accMembersListToDelete = new List<AccountTeamMember>();
        
            //If ARA is created for Account Risk
            for(ARA__c araobj : newAraRecords){
                
                if( araobj.Status__c == 'Closed Won' || araobj.Status__c == 'Closed-Lost' ){
                        
                        accIds.add(araobj.Account__c);
                        
                        if(araobj.Assigned_To__c!=null)
                        assigneToIds.add(araobj.Assigned_To__c);
                }
            }
            
            //List of Accounts to remove sharing of associated Opportunity with a Group using Criteria Based Sharing Rule defined on Account
            List<Account> accList = [ Select Id, Is_Opp_Shared_With_Risk_Group__c,( Select Id From AccountTeamMembers where UserId IN: assigneToIds ) From Account Where Id IN :accIds];
        
            
            List<Account> accsToUpdate = new List<Account> ();
            
                    //Sharing Opportunity Record with a Group by setting field Is_Opp_Shared_With_Risk_Group__c = true on Account
                    for( Account accObj : accList ){
                            accObj.Is_Opp_Shared_With_Risk_Group__c = false;
                            accsToUpdate.add(accObj);    

                            
                            accMembersListToDelete.AddALL(accObj.AccountTeamMembers);                           
                    }
                     
            
             //Sharing Opportunities by updating Accounts
            if(accsToUpdate.size()>0){
                Update accsToUpdate;
            }
            
            //Removing Assigned_To__c from AccountTeamMember
            if(accMembersListToDelete.size()>0){       
                Delete accMembersListToDelete;
            }
            
            //Removing Assigned_To__c from a Group "ARA Sharing Group"
            if(groupARA.size()>0 && assigneToIds.size()>0){       
                groupMemberListSharingUser(assigneToIds, 'Remove from Group');
            }
            
            
    }
    
    //Method to add/Remove a User (Assignto on ARA) with "ARA Sharing Group"
    @future
    Public static void groupMemberListSharingUser( Set<Id> assigneToIds , string action ){
            
            List<GroupMember> groupMemberList = new List<GroupMember>();
            
            //Assignee added to Group
            if( action == 'Add to Group'){
                
                for(Id userId : assigneToIds){
                    
                        GroupMember gm = new GroupMember();
                        gm.UserOrGroupId = userId ;
                        gm.GroupId = groupARA[0].Id;
                    
                        groupMemberList.Add(gm);
                }
                
                //Adding Assign To "ARA Sharing Group"
                if(groupMemberList.size()>0){
                    insert groupMemberList;
                }
            }
            
            //Assignee Remove from Group
            else if ( action == 'Remove from Group' ){
                
                groupMemberList = [ Select Id From GroupMember Where UserOrGroupId IN:assigneToIds and GroupId =:groupARA[0].Id ];
                
                if(groupMemberList.size()>0)
                delete groupMemberList;
            }
            
    }
    
    
    
    /*END ARA Sharing Project (Date 14-03-2016)
    ************************************************/
    
    
    
    
    //Added by Kumud
    
    /*  
      Below Method call by after Insert @Param List<ARA__c> from the trigger on ARA Object
    */
    Public void onAfterInsert(List<ARA__c> newAraRecords){
        
       
        
        /*  
           Below List, map for Account update and Account related with the ARA records
        */
        List<Account> listToBeUpdateAccount=new List<Account>();
        Map<ID,ID> mapIDVsAccountID = new MAp<ID,ID>();
        Map<Id,Account> mapIDVsAccount = new Map<Id,Account>();
        
        for(ARA__c araobj:newAraRecords){
            mapIDVsAccountID.Put(araobj.id,araobj.Account__c);
        } // End of loop
        
        for(Account objAcc:[select id,Emergency_Notes__c,ARA_Emergency_Notes__C from Account where id in :mapIDVsAccountID.values()]){
                mapIDVsAccount.put(objAcc.Id,objAcc);
        
        }//End of loop
        
        
        for(ARA__c araobj:newAraRecords){
             // Append Emergency notes with account Emergency Notes
            if(araobj.Status__c!='Settlement' && araobj.Status__c!='Closed Won' && araobj.Status__c!='Closed - Lost' ){
                    
                    //mapIDVsAccount.get(mapIDVsAccountID.get(araobj.ID)).Emergency_Notes__c='ARA Emergency Notes:-'+araobj.ARA_Emergency_Notes__c+' \r\n Account Emergency Notes:-'+mapIDVsAccount.get(mapIDVsAccountID.get(araobj.Id)).Emergency_Notes__c;
                    mapIDVsAccount.get(mapIDVsAccountID.get(araobj.ID)).ARA_Emergency_Notes__C=araobj.ARA_Emergency_Notes__c;
                    listToBeUpdateAccount.add(mapIDVsAccount.get(mapIDVsAccountID.get(araobj.Id)));
            }           
            
                   
        }// End of loop
        
        if(listToBeUpdateAccount.size()>0){           
            update listToBeUpdateAccount;  // Update Account
        }               
    }
    

    
    
    
    

    /*  
      Below Method call by after updatet @Param Map<Id,ARA__c> with new values , Map<Id,ARA__c> with old values call from the trigger on ARA Object
    */
    Public void onAfterUpdate(Map<Id,ARA__c> newMapAra,Map<Id,ARA__c> oldMapAra){
        
        /*  
           Below List, map for Account update and Account related with the ARA records
        */
        List<Account> listToBeUpdateAccount=new List<Account>();
        Set<ID> setAccountIDs=new Set<ID>();
        Map<ID,ID> mapIDVsAccountID=new MAp<ID,ID>();
        Map<Id,Account> mapIDVsAccount=new Map<Id,Account>();
        
        for(ARA__c araobj:newMapAra.values()){
           
            mapIDVsAccountID.Put(araobj.id,araobj.Account__c);
            
        
        }// End of loop
        for(Account objAcc:[select id,Emergency_Notes__c,ARA_Emergency_Notes__C  from Account where id in :mapIDVsAccountID.values()]){
                mapIDVsAccount.put(objAcc.Id,objAcc);
        
        }// End of loop
        Id accountIdV=null;
        
        for(ARA__c araobj:newMapAra.values()){
            System.debug('**************'+newMapAra.get(araobj.id).RecordTypeId);
            
            Id recTypeId = Schema.SObjectType.ARA__c.getRecordTypeInfosByName().get('New ARA').getRecordTypeId();
            
                if(newMapAra.get(araobj.id).RecordTypeId !=oldMapAra.get(araobj.id).RecordTypeId && newMapAra.get(araobj.id).RecordTypeId == recTypeId && accountIdV!=mapIDVsAccountID.get(araobj.ID))
                    {
                        mapIDVsAccount.get(mapIDVsAccountID.get(araobj.ID)).ARA_Emergency_Notes__C='';
                        listToBeUpdateAccount.add(mapIDVsAccount.get(mapIDVsAccountID.get(araobj.Id)));       
                        accountIdV = mapIDVsAccountID.get(araobj.ID);
                    }
                  // Run only when any one value change during update 
                if(newMapAra.get(araobj.id).Account__C !=oldMapAra.get(araobj.id).Account__C || newMapAra.get(araobj.id).Status__C !=oldMapAra.get(araobj.id).Status__C || newMapAra.get(araobj.id).ARA_Emergency_Notes__c !=oldMapAra.get(araobj.id).ARA_Emergency_Notes__c ){
                      
                     if(araobj.Status__c!='Settlement' &&  araobj.Status__c!='Closed Won' && araobj.Status__c!='Closed - Lost'  ){
                           
                          //  if(newMapAra.get(araobj.id).ARA_Emergency_Notes__c !=oldMapAra.get(araobj.id).ARA_Emergency_Notes__c){
                                if(accountIdV==null || accountIdV!=mapIDVsAccountID.get(araobj.ID)){
                                  mapIDVsAccount.get(mapIDVsAccountID.get(araobj.ID)).ARA_Emergency_Notes__C=araobj.ARA_Emergency_Notes__c;
                                  listToBeUpdateAccount.add(mapIDVsAccount.get(mapIDVsAccountID.get(araobj.Id)));
                                    accountIdV = mapIDVsAccountID.get(araobj.ID);
                               }                                  
                           // }   
                    }
                    else {
                           if(accountIdV==null || accountIdV!=mapIDVsAccountID.get(araobj.ID)){
                               mapIDVsAccount.get(mapIDVsAccountID.get(araobj.ID)).ARA_Emergency_Notes__C='';
                               listToBeUpdateAccount.add(mapIDVsAccount.get(mapIDVsAccountID.get(araobj.Id)));       
                               accountIdV = mapIDVsAccountID.get(araobj.ID);
                           }
                    }
                }   // End of If    
            
            
        } // End of loop
        if(listToBeUpdateAccount.size()>0){
            
            update listToBeUpdateAccount;  // update Account
            
        }
        
        //Calling Method to Share Opportunities with a Group called "ARA Sharing Group" when Account is at Risk
        OpportunitySharing(newMapAra.values());  
        
        //Calling Method to REMOVE Sharing of  Opportunities with a Group called "ARA Sharing Group" when Account is at Risk
        RemoveOpportunitySharing(newMapAra.values());
        
        //Delete Team Member with ARA role once ARA is closed
        DeleteAccountTeamMembers(newMapAra.values());
            
    }// End of Method
    

} // End of class