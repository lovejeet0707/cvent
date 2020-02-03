/**@author Hemant Rana
Extension Class for the Account_HODI Vf Page
Version 1.0
Date: 17th Feb 2016
Description: This class is basically used by the Vf page-> Account_HODI which is called from the HODI button on the Account page, 
whenever some wants the approval to Upgrade or Degrade the Account Service Tier of a particular Account
*/
public class AccountHODIPage_Controller{
        Boolean goWhereN=true;
    Map<Id,Decimal> userIdVsPoolSum_Map=New Map<Id,Decimal>();
    Id accountId;
    //Showing different button on the basic of rendered attribute
    public Boolean showCancel{get;set;}
    public Boolean showClose{get;set;}
    public Boolean showCancelReverseHODI{get;set;}
    //Ends here--------------------------------------------
    //Below boolean variable for rendering to false if already a approval process is there or there is no Service_Tier defined for that particular account
    public Boolean renderSubmitApp{get;set;}
    public Boolean renderPBS{get;set;}
    //Ends here--------------
    public String HODIName {get;set;}
    List<SelectOption> HODIValues;
    public String tierName {get;set;}
    List<SelectOption> tierValues;
    public String currentServiceTier{get;set;}//Showing current Service Tier of the Account on the Page
    Integer poolPoint;//Calculating the pool point which will be deducted according to level to bump needed in an account
    List<Service_Tier_Mapping__c> tierObj;
    //Below are Map of HODI object---------------------------------------------------------------
    Map<Id,Decimal> userIdVsPool_Map;//Map of the HOD id i.e user id and the available points in his Pool.
    Map<Id,String> HODIdVsHODName_Map;//Map of the HOD id i.e user id and the user name in his Pool.
    @testVisible Map<Id,Id> userIdVsHODIId_Map;//Map of the HOD id i.e user id and HODI record id.
    Map<Id,HODI_Inventory__c> HODIIdVsHODIObj_Map;//Map of HODI record id Vs HODI Object
    //Ends Here----------------------------------------------------------------------------------
    Map<String,Integer> tierNameVsLevelCount_Map;//Map on Service_Tier_Mapping__c with tier name in key and there order number staring from 0 in ascending order
    Map<Integer,String> tierLevelVsTierName_Map;//Map on Service_Tier_Mapping__c with Tier Level in the Key and Tier name in the value their tier level starting from 0 in ascending order(Used for the cancel reverse HODI)
    Map<Id,User> userIdVsUser_map;
    public Account[] accRecord{get;set;}
    //Mapping for the Event & Hospitality Cloud for Service Tier Mapping
        Map<String,Set<String>> CloudVsPLFValuesSet_Map;
        Set<String> eventPLFValues_Set;
        Set<String> hospPLFValues_Set;
        Set<String> CloudSelected_Set;
        String cloudSelected;
    //Ends Here---------------------------------------------------------------------------------------
    Integer i=0;
    Decimal shareOfWalletValue=0.0;
    String tierAccordingToAmount;//This will store the name of the TIER which the current Account should have according to the ShareofWallet Field and Service_Tier_Mapping__c object.It is used below for validation that the level of service one want to degrade for the following Account can be processed or not.
    ProcessInstance[] existingApprovals;//Checking if the Account is already under any Approval Process.
    public AccountHODIPage_Controller(ApexPages.StandardController controller) {
        tierLevelVsTierName_Map=new Map<Integer,String>();
        tierObj=new List<Service_Tier_Mapping__c>();
        CloudSelected_Set=new Set<String>();
        userIdVsPool_Map=new Map<Id,Decimal>();
        HODIdVsHODName_Map=new Map<Id,String>();
        userIdVsHODIId_Map=new Map<Id,Id>();
        tierNameVsLevelCount_Map=new Map<String,Integer>();
        //tierNameVsLevelCount_Map.put('Basic',0);//Assigning Basic tier level
        accountId=controller.getID();//getting the Id of the current Account
        HODIIdVsHODIObj_Map=new Map<Id,HODI_Inventory__c>([SELECT Id,Name,Head_of_Department__c,Head_of_Department__r.Name,Pool_Point__c FROM HODI_Inventory__c]);
        accRecord=[SELECT No_of_Reverse_HODI__c,LastModifiedById,LastModifiedDate,Id,Acc_Name_Dev__c,Name,HC_Share_of_Wallet_Client__c,Share_of_Wallet_Tier_Max__c,HOD_Comment_Dev__c,Requestor_Dev__c,IsDegraded_Dev__c,IsRejected_Dev__c,Purchased_License__c,HODI_Request_Date_Dev__c,HODI_Approver_Dev__c,IsHODI_Dev__c,Previous_Tier_Dev__c,HODI_Id_Dev__c ,HODI_Count_Dev__c,Service_Tier__c,Desired_Tier_Dev__c FROM Account WHERE Id =: accountId AND Service_Tier__c!='' ];
        //Calling the method fro Event/Hospitality Mapping
        if(accRecord.size()>0){
            accRecord[0].HOD_Comment_Dev__c='';
            //creatingCloudMapping();
            if((accRecord[0].HC_Share_of_Wallet_Client__c!=null && accRecord[0].HC_Share_of_Wallet_Client__c>0) && (accRecord[0].Share_of_Wallet_Tier_Max__c!=null && accRecord[0].Share_of_Wallet_Tier_Max__c>0))
            {
                shareOfWalletValue=accRecord[0].HC_Share_of_Wallet_Client__c;
                cloudSelected='Hospitality';
            }
            else if(accRecord[0].HC_Share_of_Wallet_Client__c!=null && accRecord[0].HC_Share_of_Wallet_Client__c>0)
            {
                shareOfWalletValue=accRecord[0].HC_Share_of_Wallet_Client__c;
                cloudSelected='Hospitality';
            }
            else{
                shareOfWalletValue=accRecord[0].Share_of_Wallet_Tier_Max__c;
                cloudSelected='Event';
            }
        
        String tierQuery='SELECT Id,Name,Max_Amount__c,Min_Amount__c FROM Service_Tier_Mapping__c WHERE Event_Cloud_Vs_Hospitality_Cloud__c='+'\''+cloudSelected+'\''+' ORDER BY Min_Amount__c';
        System.debug('tierQuery==============>'+tierQuery);
        
        tierObj=(List<Service_Tier_Mapping__c>)Database.query(tierQuery);
        }
        For(HODI_Inventory__c HODIValues : HODIIdVsHODIObj_Map.Values())
        {
            userIdVsPool_Map.put(HODIValues.Head_of_Department__c,HODIValues.Pool_Point__c);
            userIdVsHODIId_Map.put(HODIValues.Head_of_Department__c,HODIValues.Id);
            HODIdVsHODName_Map.put(HODIValues.Head_of_Department__c,HODIValues.Head_of_Department__r.Name);
        }
        userIdVsUser_map=new Map<Id,User>([SELECT Id,Email,Name FROM User WHERE Id =:UserInfo.getUserId()]);
        System.debug('accRecord===>'+accRecord);
        System.debug('accRecordSize===>'+accRecord.size());
        existingApprovals   = [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId =:accountId  AND Status = 'Pending'];
        
        //Account does not have a Service Tier so a message will be shown on the page
        if(accRecord.size()==0)
        {
            showCancel=false;
            showClose=true;
            renderSubmitApp=false;
            String errorMessage='This account does not have a Service Level assigned to it.';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errorMessage));
            renderPBS=false;
        }
        //Account is having a existing Approval Process then only a message will be shown
        else if(existingApprovals.size()>0)
        {
            showCancel=false;
            showClose=true;
            renderSubmitApp=false;
            renderPBS=false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Some Approval Request are already Pending on this Account.'));
        }
        // If above condition is false then this account can be processed for the service tier change
        else if(accRecord.size()>0 && existingApprovals.size()==0){
            if(accRecord[0].No_of_Reverse_HODI__c>0)
            {
                showCancel=false;
                showClose=true;
                renderSubmitApp=false;
                showCancelReverseHODI=true;
            }
            else
            {
                showCancelReverseHODI=false;
                showCancel=true;
                showClose=false;
                renderSubmitApp=true;
            }

            renderPBS=true;
            currentServiceTier=accRecord[0].Service_Tier__c;
            For(Service_Tier_Mapping__c tierValues : tierObj)
            {
                i=i+1;
                if(shareOfWalletValue>=tierValues.Min_Amount__c && shareOfWalletValue<=tierValues.Max_Amount__c)
                {
                    tierAccordingToAmount=tierValues.Name;
                }
                //system.debug('i=================>>>>>>>>>>>>>'+i);
                tierNameVsLevelCount_Map.put(tierValues.Name,i);
                tierLevelVsTierName_Map.put(i,tierValues.Name);
            }
        }
        System.debug('tierNameVsLevelCount_Map====>>>'+tierNameVsLevelCount_Map);
                System.debug('tierLevelVsTierName_Map===>>'+tierLevelVsTierName_Map);
    }
    //Showing the list of HODI on the VF page
    public List<SelectOption> getHODIList()
    {
        HODIValues = new List<SelectOption>();
        for(HODI_Inventory__c HODIValue : HODIIdVsHODIObj_Map.Values())
        {
            HODIValues.add(new SelectOption(HODIValue.Head_of_Department__c, HODIValue.Head_of_Department__r.Name));
        }       
        return HODIValues;
    }
    //Showing the List of TIERS on the vF page
    public List<SelectOption> getTierList()
    {
        tierValues = new List<SelectOption>();
        for(Service_Tier_Mapping__c tierValue : tierObj)
        {
            if(tierValue.Name!=currentServiceTier && tierValue.Name!='Basic')
            tierValues.add(new SelectOption(tierValue.Name, tierValue.Name));
        }       
        return tierValues;
    }
    //This method will send the request for approval to the HODI for the chnage in the level of service(TIERS)
    public PageReference submitForApproval()
    {
        showCancel=false;
        showClose=true;
        String upGrade_deGrade=checkServiceCanSendForApproval_Method();
        if(accRecord.size()>0 && (upGrade_deGrade=='degrade' ||  upGrade_deGrade=='upgrade' || upGrade_deGrade=='reverse' ))
        {
            if(upGrade_deGrade=='degrade'){
                accRecord[0].Desired_Tier_Dev__c = tierName;
                //accRecord[0].HODI_Name__c =userIdVsHODIId_Map.get(HODIName) ;
                accRecord[0].HODI_Id_Dev__c=userIdVsHODIId_Map.get(HODIName);
                accRecord[0].HODI_Count_Dev__c= poolPoint;
                accRecord[0].IsRejected_Dev__c=false;
                accRecord[0].Previous_Tier_Dev__c=accRecord[0].Service_Tier__c;
                accRecord[0].IsDegraded_Dev__c=true;
                accRecord[0].HODI_Approver_Dev__c=Id.ValueOf(HODIName);
                accRecord[0].HODI_Request_Date_Dev__c=system.today();
                accRecord[0].Requestor_Dev__c=userIdVsUser_map.get(UserInfo.getUserId()).Email;
                update accRecord[0];
                approvalProcessMethod();
                /*if(!Test.isRunningTest()){
                    //Added by Shanu (Send post to chatter group "All Cvent" for HODI Submission request
                    String body='<b>Hi '+userIdVsUser_map.get(accRecord[0].HODI_Approver_Dev__c).Name+',</b><p>A new request has been submitted to promote an Account by using HODI in your available inventory:</p><p><ul>    <li><b>Account:</b>'+  accRecord[0].Acc_Name_Dev__c+'</li>  <li><b>Desired Tier:</b>'+ accRecord[0].Desired_Tier_Dev__c+'</li> <li><b>Requestor:</b>'+  userIdVsUser_map.get(accRecord[0].LastModifiedById).Name+'</li>    <li><b>Request Date:</b>'+  accRecord[0].LastModifiedDate.format()+'</li></ul></p><p></p> <p>Upon your approval, this request will be reflected in the system immediately.</p><p>Should you reject this request, the HODI will immediately return to your available inventory and the requestor will be notified that this request was NOT approved. </p><p>If you take no action, this request will be automatically rejected in 72 hours.</p><b><p>Thanks,</p></b><b>'+userIdVsUser_map.get(accRecord[0].LastModifiedById).Name+'</b>';
                    System.debug('body====>>>>'+body);
                    AccountHODIPage_Controller.AddGroupPost(accRecord[0].Id,body);
                }
                */
                Approval.unlock(accountId);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Your request has been submitted for Approval. We will notify you for the final action taken on your request.'));
                return null;
            }
            else if(upGrade_deGrade=='upgrade'){
                accRecord[0].Desired_Tier_Dev__c = tierName;
                accRecord[0].IsDegraded_Dev__c=false;
                //accRecord[0].HODI_Name__c =userIdVsHODIId_Map.get(HODIName) ;
                accRecord[0].HODI_Id_Dev__c=userIdVsHODIId_Map.get(HODIName);
                accRecord[0].HODI_Count_Dev__c= math.abs(poolPoint);
                accRecord[0].IsRejected_Dev__c=false;
                accRecord[0].Previous_Tier_Dev__c=accRecord[0].Service_Tier__c;
                accRecord[0].HODI_Approver_Dev__c=Id.ValueOf(HODIName);
                accRecord[0].HODI_Request_Date_Dev__c=system.today();
                accRecord[0].Requestor_Dev__c=userIdVsUser_map.get(UserInfo.getUserId()).Email;
                update accRecord[0];
                System.debug('accRecord====>'+accRecord[0]);
                approvalProcessMethod();
                /*if(!Test.isRunningTest()){
                     //Added by Shanu (Send post to chatter group "All Cvent" for HODI Submission request
                    String body='<b>Hi '+userIdVsUser_map.get(accRecord[0].HODI_Approver_Dev__c).Name+',</b><p>A new request has been submitted to promote an Account by using HODI in your available inventory:</p><p><ul>    <li><b>Account:</b>'+  accRecord[0].Acc_Name_Dev__c+'</li>  <li><b>Desired Tier:</b>'+ accRecord[0].Desired_Tier_Dev__c+'</li> <li><b>Requestor:</b>'+  userIdVsUser_map.get(accRecord[0].LastModifiedById).Name+'</li>    <li><b>Request Date:</b>'+  accRecord[0].LastModifiedDate.format()+'</li></ul></p><p></p> <p>Upon your approval, this request will be reflected in the system immediately.</p><p>Should you reject this request, the HODI will immediately return to your available inventory and the requestor will be notified that this request was NOT approved. </p><p>If you take no action, this request will be automatically rejected in 72 hours.</p><b><p>Thanks,</p></b><b>'+userIdVsUser_map.get(accRecord[0].LastModifiedById).Name+'</b>';
                    System.debug('body====>>>>'+body);

                    System.debug('body====>>>>'+body);
                    AccountHODIPage_Controller.AddGroupPost(accRecord[0].Id,body);
                }*/
                
                upGradeServiceTier();
                Approval.unlock(accountId);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Your request has been submitted for Approval. We will notify you for the final action taken on your request.'));
                return null;
            }
            else if(upGrade_deGrade=='reverse')
            {
                accRecord[0].Desired_Tier_Dev__c = tierName;
                accRecord[0].IsDegraded_Dev__c=false;
                //accRecord[0].HODI_Name__c =userIdVsHODIId_Map.get(HODIName) ;
                accRecord[0].HODI_Id_Dev__c=userIdVsHODIId_Map.get(HODIName);
                accRecord[0].HODI_Count_Dev__c= 0;
                accRecord[0].No_of_Reverse_HODI__c=math.abs(poolPoint);
                accRecord[0].IsRejected_Dev__c=false;
                accRecord[0].Previous_Tier_Dev__c=accRecord[0].Service_Tier__c;
                accRecord[0].HODI_Approver_Dev__c=Id.ValueOf(HODIName);
                accRecord[0].HODI_Request_Date_Dev__c=system.today();
                accRecord[0].Requestor_Dev__c=userIdVsUser_map.get(UserInfo.getUserId()).Email;
                update accRecord[0];
                System.debug('accRecord====>'+accRecord[0]);
                approvalProcessMethod();
                /*if(!Test.isRunningTest()){
                    String body='<b>Hi '+userIdVsUser_map.get(accRecord[0].HODI_Approver_Dev__c).Name+',</b><p>A new request has been submitted to promote an Account by using HODI in your available inventory:</p><p><ul>    <li><b>Account:</b>'+  accRecord[0].Acc_Name_Dev__c+'</li>  <li><b>Desired Tier:</b>'+ accRecord[0].Desired_Tier_Dev__c+'</li> <li><b>Requestor:</b>'+  userIdVsUser_map.get(accRecord[0].LastModifiedById).Name+'</li>    <li><b>Request Date:</b>'+  accRecord[0].LastModifiedDate.format()+'</li></ul></p><p></p> <p>Upon your approval, this request will be reflected in the system immediately.</p><p>Should you reject this request, the HODI will immediately return to your available inventory and the requestor will be notified that this request was NOT approved. </p><p>If you take no action, this request will be automatically rejected in 72 hours.</p><b><p>Thanks,</p></b><b>'+userIdVsUser_map.get(accRecord[0].LastModifiedById).Name+'</b>';
                    System.debug('body====>>>>'+body);

                    System.debug('body====>>>>'+body);
                    AccountHODIPage_Controller.AddGroupPost(accRecord[0].Id,body);
                }*/
                //upGradeServiceTier();
                Approval.unlock(accountId);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Your request has been submitted for Approval. We will notify you for the final action taken on your request.'));
                return null;
            }
            else
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Some Error.'));
                return null;
            }
        }
        else
        {
            return null;
        }
    }
    //This method will check if the Account Service can be degraded or upgraded or reverse by the HOD.
    /*07/06/2016 : HSR : Below method was earlier doing a check for the change in the Service Tier whether it is Upgrade or Degrade. Now one more thing will be added that is of reverse HODI which chan be done by any HOD.
    Below are the steps which are followed for the checking whether the service change is a UPGRADE/DOWNGRADE/REVERSE-
    *) Through pool point calculate it's a upgrade or downgrade or reverse. If a upgrade then check whether the approver is having that much inventory if yes then it's fine to go otherwise show an error message.
    *) If it's a downgrade then check whether the approver who is downgrading has also upgraded it.
    *) If it's a reverse then any one can reverse it and also we have to update the count field "No. of Reverse HODI" but we have to follow that until the reverse hodi is cancelled no one can do a HODI process*/
    
    private String checkServiceCanSendForApproval_Method()
    {
            System.debug('tierNameVsLevelCount_Map========>'+tierNameVsLevelCount_Map);
            System.debug('tierName======>>'+tierName);
            System.debug('tierAccordingToAmount======>>'+tierAccordingToAmount);
            System.debug('tierNameVsLevelCount_Map.get(tierName)============************'+tierNameVsLevelCount_Map.get(tierName));
            System.debug('tierNameVsLevelCount_Map.get(tierAccordingToAmount)============************'+tierNameVsLevelCount_Map.get(tierAccordingToAmount));
            poolPoint = (tierNameVsLevelCount_Map.keySet().contains(tierName)?tierNameVsLevelCount_Map.get(tierName):0)-(tierNameVsLevelCount_Map.keySet().contains(accRecord[0].Service_Tier__c)?tierNameVsLevelCount_Map.get(accRecord[0].Service_Tier__c):0);//Calculating the POOL Point required by the HOD so that approval can be sent to him
            System.debug('poolPoint**********************'+poolPoint);
            //poolPoint = tierNameVsLevelCount_Map.get(tierName)-tierNameVsLevelCount_Map.get(accRecord[0].Service_Tier__c);//Calculating the POOL Point required by the HOD so that approval can be sent to him
            /*If poolpoint>0 then needs the service tier upgrade otherwise degrade or reverse*/
            if(poolPoint>0)
            {
                System.debug('#1st check point : upgrade tier');
                /*Now check if the approver HOD Inventory has sufficient point to approve this request*/
                if(userIdVsPool_Map.get(HODIName)>=poolPoint){
                    return 'upgrade';
                }
                else{
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The approver doesn’t have sufficient HODI points available to accept this request.'));
                     return null;
                }
            }
            else
            {
                System.debug('#2nd check point : degrade or reverse tier');
                /*If the service tier level is less than what it should be acc to the amount then it's a reverse HODI*/
                if(tierNameVsLevelCount_Map.get(tierName)<tierNameVsLevelCount_Map.get(tierAccordingToAmount))
                {
                    System.debug('#3rd check point : reverse tier');
                    return 'reverse';
                }
                /*else it's a downgrade where we have to also check whether it was approved by the same HOD who is degrading it*/
                else{
                        
                    System.debug('#4th check point : degrade tier');
                    For(Account_HODI__c  accountHODIRec :[SELECT Account__c,CreatedDate,Desired_Tier__c,HODI_Inventory__c,HODI_Name__c,HOD_Comment__c,Id,Points__c,Previous_Tier__c FROM Account_HODI__c WHERE Account__c=:accRecord[0].Id ORDER BY CreatedDate DESC])
                    {
                        if(HODIIdVsHODIObj_Map.get(accountHODIRec.HODI_Inventory__c).Head_of_Department__c!=Id.ValueOf(HODIName) && accountHODIRec.Points__c>0 && goWhereN)
                        {
                            //SHOW ERROR that you can't change the account Service Tier
                            System.debug('SHOW ERROR 1st'+accountHODIRec.Id);
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The HODI applied on this Account was approved by a different approver. Kindly resubmit this request by selecting the Original Approver.'));
                            return null;
                            //break;
                        }
                        else if(HODIIdVsHODIObj_Map.get(accountHODIRec.HODI_Inventory__c).Head_of_Department__c==Id.ValueOf(HODIName) && accountHODIRec.Points__c>0 && accountHODIRec.Points__c>=poolPoint && goWhereN)
                        {
                            System.debug('Perfect New'+accountHODIRec.Id);
                            return 'degrade';
                            break;
                        }  
                        else{
                            goWhereN=false;
                            if(userIdVsPoolSum_Map.keySet().contains(HODIIdVsHODIObj_Map.get(accountHODIRec.HODI_Inventory__c).Head_of_Department__c)){
                                userIdVsPoolSum_Map.put(HODIIdVsHODIObj_Map.get(accountHODIRec.HODI_Inventory__c).Head_of_Department__c,(userIdVsPoolSum_Map.get(HODIIdVsHODIObj_Map.get(accountHODIRec.HODI_Inventory__c).Head_of_Department__c)+accountHODIRec.Points__c));
                            }
                            else{
                                userIdVsPoolSum_Map.put(HODIIdVsHODIObj_Map.get(accountHODIRec.HODI_Inventory__c).Head_of_Department__c,accountHODIRec.Points__c);
                            }
                            if(HODIIdVsHODIObj_Map.keySet().contains(accountHODIRec.HODI_Inventory__c) && HODIIdVsHODIObj_Map.get(accountHODIRec.HODI_Inventory__c).Head_of_Department__c==Id.ValueOf(HODIName) && userIdVsPoolSum_Map.get(HODIIdVsHODIObj_Map.get(accountHODIRec.HODI_Inventory__c).Head_of_Department__c)>=poolPoint)
                            {
                                System.debug('Perfect====>'+accountHODIRec.Id);
                                return 'degrade';
                                break;
                            }
                            else if(HODIIdVsHODIObj_Map.keySet().contains(accountHODIRec.HODI_Inventory__c) && HODIIdVsHODIObj_Map.get(accountHODIRec.HODI_Inventory__c).Head_of_Department__c!=Id.ValueOf(HODIName) && userIdVsPoolSum_Map.get(HODIIdVsHODIObj_Map.get(accountHODIRec.HODI_Inventory__c).Head_of_Department__c)>0)
                            {
                                System.debug('Error===>'+accountHODIRec.Id);
                                //break;
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The HODI applied on this Account was approved by a different approver. Kindly resubmit this request by selecting the Original Approver.'));
                                return null;
                            }
                        }
                    }
                }
            }
        return null;
    }
    //If user want to deGrade the Service Tier of Account
    private void deGradeServiceTier()
    {
        HODI_Inventory__c HODIObj=new HODI_Inventory__c(Id=userIdVsHODIId_Map.get(HODIName));
        HODIObj.Pool_Point__c=HODIIdVsHODIObj_Map.get(HODIObj.Id).Pool_Point__c+math.abs(poolPoint);
        update HODIObj;
    }
    //If user want to upGrade the Service Tier of Account
    private void upGradeServiceTier()
    {
        HODI_Inventory__c HODIObj=new HODI_Inventory__c(Id=userIdVsHODIId_Map.get(HODIName));
        HODIObj.Pool_Point__c=HODIIdVsHODIObj_Map.get(HODIObj.Id).Pool_Point__c-math.abs(poolPoint);
        update HODIObj;
    }
    //Method used to call Approval Process
    private void approvalProcessMethod()
    {
            // Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('HODI Request.');
            req1.setObjectId(accountId);
            // Submit on behalf of a specific submitter
            //req1.setSubmitterId(user1.Id); 
            // Submit the record to specific process and skip the criteria evaluation
            req1.setProcessDefinitionNameOrId('Account_Service_Tier_Approval');
            //req1.setSkipEntryCriteria(true);
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
            
    }
    
    
    //Added by Shanu
    //Adding a FeedItem to Group "All Cvent" and related Account record
    public static void AddGroupPost(ID accId, string htmlBody){
        
        //Sample Body
        //htmlBody = 'HODI Request has been submitted for Account : <b> Cvent Inc. </b>';
        
        
        //Getting Chatter Group "All Cvent"
        CollaborationGroup [] cGroup = [Select Id From CollaborationGroup Where Name = :Label.HODI_Group_Name];
        
        
        List<FeedItem> fitemList = new List<FeedItem>();
        
        //Feed Item post
        FeedItem item = new FeedItem();
        item.IsRichText = true;
        item.body =   htmlBody ;
        item.Type =  'TextPost';

        
        //Adding post to Group
        if( cGroup.size()>0){
                item.ParentId = cGroup[0].Id;
                fitemList.add(item);
        }
        
        //Adding post to Account
        item = item.clone(false,false);
        item.ParentId = accId;
        fitemList.add(item);
        
        
        
        insert fitemList;
    
    }
    /* 06/06/2016 HSR: Added the Cancel of Reverse HODI functionality*/
    /*Find the level of the Cuttent Tier through [[MAP(tierNameVsLevelCount_Map) and Current Tier]] and then add the value of "No. of Reverse HODI" to it and acc to that the name of the Tier which will come update it in the "current tier" and also make the "No. of Reverse HODI=0"*/
    public void CancelReverseHODI()
    {
        System.debug('tierLevelVsTierName_Map===>>>'+tierLevelVsTierName_Map);
        System.debug('tierNameVsLevelCount_Map====>>'+tierNameVsLevelCount_Map);
        Integer levelOfCurrentTier=tierNameVsLevelCount_Map.containsKey(currentServiceTier)?tierNameVsLevelCount_Map.get(currentServiceTier):0;//The check is somewhat wrong as if the Tier name will not be found it will make the integer 0 it will be wrong need to change.
        Decimal desiredTierLevel=levelOfCurrentTier+accRecord[0].No_of_Reverse_HODI__c;
        accRecord[0].Service_Tier__c=tierLevelVsTierName_Map.get(Integer.ValueOf(desiredTierLevel));
        accRecord[0].No_of_Reverse_HODI__c=0;
        update accRecord[0];
        showCancel=false;
        showClose=true;
        showCancelReverseHODI=false;
        renderPBS=false;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'The Revese HODI applied on this account is cancelled.'));
//        return null;
    }
        

}