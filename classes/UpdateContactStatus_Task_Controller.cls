public with sharing class UpdateContactStatus_Task_Controller {
    //String estUrl;
    String checkStatusClosedWon;
    Id taskId;
    Id recordTypeId;
    Id contactId;
    String recordPrefix;
    String whatId;
    String retUrlRecordId ;
    String newId;
    String tsk5;
    String logACall;
    String whoId;
    String param;
    Set<String> userNameSet;//Set for custom setting value to store the username for excluding this DWF fuctionality
    String urlParam;//As we are concatinating the contact and recordtypeid of task so this variable is used to to extract them from url
    public String recordTypeName{get;set;}//Recordtype name is stored in this and used for rendering the pageblock section accordingly
    public Contact contactRec {get; set;}//used in the vf page to show contact status field
    public Lead leadRec {get; set;}//used in the vf page to show lead status field
    List<Task> taskRecord;
    public boolean showContactStatus{get;set;}
    public boolean showLeadStatus{get;set;}
    private Contact con;//This will create the new contact instance and then it will update the contact record of the related task.
    private Lead leadObj;//This will create the new task instance and then it will update the task record of the related task.
    /*
        This variable stores which status need so be updated. It will store a variable acc to the status. If it's already "Closed Won"
        then this variable sill save "None" else the name of the status field and then acc to that that particular status new value will be store in the Contact Record.
    */
    private String conStatusUpdate_Var;
    Id test;
    public UpdateContactStatus_Task_Controller(ApexPages.StandardController controller) {
        contactRec = new Contact();
        leadRec=new Lead();
        taskRecord=new List<Task>();
        userNameSet=new Set<String>();
    }
    //Method used for redirecting the page and setting the returl value of the url when new button is clicked
    public PageReference DetailPageReference()
    {
        For(UserExcludedFromDWF__c ft : UserExcludedFromDWF__c.getall().values())
        {
            userNameSet.add(ft.name);
        }
        if(ApexPages.currentPage().getParameters().containsKey('Id')){
            taskId=ApexPages.currentPage().getParameters().get('Id');
            System.debug('taskId========>>'+taskId);
            if(ApexPages.currentPage().getParameters().containsKey('retURL')){
                String vTest=ApexPages.currentPage().getParameters().get('retURL');
                if(vTest.contains('RelatedActivityList'))
                {
                    vTest=vTest.substringBetween('?id=','&rlid=');
                    System.debug('vTest========>>>>****'+vTest);
                    test=Id.ValueOf(vTest);
                }
                else{
                    System.debug('vTest========>>'+vTest);
                    String IdExtract=vTest.removeStart('/');
                    if(IdExtract.length()>=15)
                    test=Id.valueOf(IdExtract.substring(0,15));
                    System.debug('test Else========>>'+test);
                }
            }
            System.debug('test========>>'+test);
        }
        system.debug('Get Id of record************'+test);
        system.debug('TaskId of record************'+taskId);
        if(ApexPages.currentPage().getParameters().containsKey('RecordType')){
            recordTypeId=ApexPages.currentPage().getParameters().get('RecordType');
        }
        System.debug('Starting recordTypeId ====>>>>>>'+recordTypeId);
        if(ApexPages.currentPage().getParameters().containsKey('What_Id')){
            whatId=ApexPages.currentPage().getParameters().get('What_Id');
        }
        if(ApexPages.currentPage().getParameters().containsKey('Who_Id')){
            whoId=ApexPages.currentPage().getParameters().get('Who_Id');
        }
        System.debug('retUrlRecordId====>>>'+retUrlRecordId);
        if(ApexPages.currentPage().getParameters().containsKey('newid')){
            newId=ApexPages.currentPage().getParameters().get('newid');
            
        }
        if(ApexPages.currentPage().getParameters().containsKey('retURL')){
            retUrlRecordId=ApexPages.currentPage().getParameters().get('retURL');
        }
        //To get the subject of the Task Object...............................
        if(ApexPages.currentPage().getParameters().containsKey('tsk5'))
        {
            tsk5=ApexPages.currentPage().getParameters().get('tsk5');
            tsk5=EncodingUtil.urlEncode(tsk5,'UTF-8');
        }
        if(ApexPages.currentPage().getParameters().containsKey('followup'))
        {
            logACall = ApexPages.currentPage().getParameters().get('followup');
        }
        System.debug('afdasfdasf===>'+ApexPages.currentPage().getParameters().containsKey('recTypId'));
        if(ApexPages.currentPage().getParameters().containsKey('recTypId'))
        {
            System.debug('asfsafdsad===>'+ApexPages.currentPage().getParameters().get('recTypId'));
            param=ApexPages.currentPage().getParameters().get('recTypId');
            if(param.contains('home/home.jsp'))
            {
                retUrlRecordId='home/home.jsp';//param.substringAfterLast('retURL=');
            }
            else
            retUrlRecordId=param.substringAfterLast('retURL=/');
            recordTypeId=param.substringBefore('retURL=');
            if(retUrlRecordId==null || retUrlRecordId=='')
                retUrlRecordId=param.substringAfterLast('retURL=');
            
        }
        System.debug('retUrlRecordId===>'+retUrlRecordId);
        System.debug('recordTypeId====>'+recordTypeId);
        System.debug('newId==-awsf=-a0sd=f-0===>'+newId);

        if(recordTypeId==null){
            
            Schema.DescribeSObjectResult describeOpp = Schema.SObjectType.Task;    
            List<Schema.RecordTypeInfo> rtInfos = describeOpp.getRecordTypeInfos();
            for(Schema.RecordTypeInfo rtInfo : rtInfos) {
                if(rtInfo.isDefaultRecordTypeMapping()) {               
                    recordTypeId=rtInfo.getRecordTypeId();
                    break;
                }
            }
            System.debug('recordTypeIdDefault======>'+recordTypeId);
        }
        if(retUrlRecordId!=null && retUrlRecordId.startsWith('/')){
            System.debug('# Checkpoint Inside If'+retUrlRecordId);
             retUrlRecordId=retUrlRecordId.removeStart('/');
        }
        
        else if(retUrlRecordId!=null && retUrlRecordId.startsWith('https://cvent.my.salesforce.com/')){//'https://cvent.my.salesforce.com/'
            System.debug('# Checkpoint Inside Else'+retUrlRecordId);
        retUrlRecordId=retUrlRecordId.removeStart('https://cvent.my.salesforce.com/');}//'https://cvent.my.salesforce.com/'
            
        System.debug('#Final Check point'+retUrlRecordId);
        if(taskId!=null || retUrlRecordId!=null || recordTypeId!=null){
            
            taskRecordTypeName();
        }
        System.debug('recordTypeName===>'+recordTypeName);
        /*if(newId==null)
            statusclosedwoncheck(retUrlRecordId);
        else
            statusclosedwoncheck(newId);*/
        if(test!=null)
            statusclosedwoncheck(test);
        System.debug('checkStatusClosedWon=========>>>>>'+checkStatusClosedWon);
        if(!userNameSet.contains(UserInfo.getUserName()) && (recordTypeName=='TPP_Intl_Task' || recordTypeName=='Enterprise'|| recordTypeName=='Event_Tasks'||recordTypeName=='CC_Tasks'||recordTypeName=='PA_Tasks'||recordTypeName=='Inquisium_Tasks'||recordTypeName=='CSN_Tasks'||recordTypeName=='SR_Tasks'||recordTypeName=='BizDev_Tasks'))
        {
            System.debug('inside 1st Check');
            System.debug('szdvszdfasdfdsf'+newId);
            //When we click on new button for creating task NEWID will always be null thats why we had put the check of NEWID
            if(newId==null){//  && checkStatusClosedWon=='NOT' 
                System.debug('#Checkpoint : Inside the New Task Functionality');
                String taskEditUrl;
                System.debug('inside check'+retUrlRecordId);
                if(taskId!=null)
                taskEditUrl='/'+taskId+'/e?'+'&retURL='+retUrlRecordId+'&saveURL=/apex/UpdateContactStatus_Task?recTypId='+recordTypeId+'retURL='+retUrlRecordId+'&RecordType='+recordTypeId+'&ent=Task&nooverride=1';
                else
                taskEditUrl='/00T/e?'+'&retURL='+retUrlRecordId+'&saveURL=/apex/UpdateContactStatus_Task?recTypId='+recordTypeId+'retURL='+retUrlRecordId+'&RecordType='+recordTypeId+'&ent=Task&nooverride=1';
                /*3/23/2016: PK: Carry forward the subject for "Save & New button"*/
                if(tsk5 != null){
                    taskEditUrl = taskEditUrl + '&tsk5='+tsk5;
                }
                if(whatId != null){
                    taskEditUrl = taskEditUrl + '&what_id='+whatId;
                }   
                if(whoId!=null)
                {
                    taskEditUrl = taskEditUrl + '&who_id='+whoId;
                }
                if(logACall != null){
                    taskEditUrl = taskEditUrl + '&followup='+logACall;
                }
                PageReference taskDetailPage=new PageReference(taskEditUrl);
                taskDetailPage.setRedirect(true);
                return taskDetailPage;
            }
            else if(newId!=null )// && checkStatusClosedWon=='NOT' 
            {
                System.debug('#Checkpoint : Inside the EDIT Task Functionality');
                System.debug('newId====>'+newId);
                Task taskObj=[SELECT Id,WhoId,WhatId,RecordTypeId FROM Task WHERE Id=:newId];
                System.debug('taskObj====>'+taskObj);
                    if(taskObj!=null && taskObj.WhoId!=null)//&& (WhoIdprefix=='003' || WhoIdPrefix=='00Q')
                    {
                        contactId=taskObj.WhoId;
                        System.debug('This Level #2nd Check');
                        recordPrefix = String.valueOf(taskObj.WhoId).substring(0,3);
                        System.debug('recordPrefix===>'+recordPrefix);
                        if(recordPrefix=='003')
                        {
                            showContactStatus=true;
                            showLeadStatus=false;
                        
                            contactRec=[SELECT CSN_P_Contact_Status_Notes__c ,SMM_Lost_Details__c ,SMM_Recycle_Trash_Reason__c,SMM_Recycle_Competitor_Name__c,SMM_Contact_Status__c,CSN_P_Status_Details__c,Id,Event_Lost_Details__c,CC_Lost_Details__c,CSN_P_Lost_Details__c,CSN_S_Lost_Details__c,Survey_Lost_Details__c,Name,Event_Not_Ready_Reason__c,CC_Not_Ready_Reason__c,CSN_P_Not_Ready_Reason__c,HC_Not_Ready_Reason__c,Inquisium_Not_Ready_Reason__c,CSN_S_Recycle_Competitor_Name__c,CSN_P_Recycle_Competitor_Name__c,Sourcing_through__c,CSN_S_Recycle_Trash__c,Survey_Recycle_Competitor_Name__c,Survey_Recycle_Reason__c,CC_Recycle_Trash_Reason__c,CC_Recycle_Competitor_Name__c,CC_Contact_Status__c,Survey_Contact_Status__c,CSN_P_Contact_Status__c,CSNS_Contact_Status__c,Event_Contact_Status__c,Event_Recycle_Reason__c,Event_Recycle_Competitor_Name__c FROM Contact WHERE Id=:contactId];
                            //This method is called to verify that the contact status is "Closed Won" or not
                            statusclosedwoncheck(null);
                            if(checkStatusClosedWon=='NOT'){
                            createContactUpdate(recordTypeName);
                            return null;}
                            else{
                                System.debug('retUrlRecordId=============**********'+retUrlRecordId);
                                PageReference taskDetailPage=new PageReference('/'+retUrlRecordId);
                                taskDetailPage.setRedirect(true);
                                return taskDetailPage;
                            }
                            
                        
                        }
                        else if(recordPrefix=='00Q')
                        {
                            showContactStatus=false;
                            showLeadStatus=true;
                            leadRec=[SELECT Survey_Lead_Status__c,SMM_Lead_Status__c,SMM_Recycle_Trash_Reason__c,SMM_Recycle_Competitor_Name__c,SMM_Lost_Details__c,Inquisium_Lead_Status__c,Name,CSN_P_Status_Details__c,CSN_P_Lost_Details__c ,CSN_P_Recycle_Competitor_Name__c ,Sourcing_through__c ,CSN_S_Lost_Details__c ,CSN_S_Recycle_Competitor_Name__c ,CSN_S_Recycle_Trash_Reason__c ,Survey_Lost_Details__c ,Survey_Recycle_Competitor_Name__c ,Survey_Recycle_Reason__c ,CC_Lost_Details__c ,Event_Lost_Details__c ,CC_Recycle_Competitor_Name__c,Event_Recycle_Competitor_Name__c ,CC_Recycle_Trash_Reason__c ,Id,Event_Recycle_Reason__c ,Lead_Status_Reason_Survey__c,CC_Lead_Status__c,CSN_P_Lead_Status__c,CSN_S_Lead_Status__c,Event_Lead_Status__c FROM Lead WHERE Id=:contactId];
                            //This method is called to verify that the contact status is "Closed Won" or not
                            statusclosedwoncheck(null);
                            if(checkStatusClosedWon=='NOT'){
                            createLeadUpdate(recordTypeName);
                            return null;}
                            else{
                                System.debug('retUrlRecordId=============**********'+retUrlRecordId);
                                PageReference taskDetailPage=new PageReference('/'+retUrlRecordId);
                                taskDetailPage.setRedirect(true);
                                return taskDetailPage;
                            }
                            //createLeadUpdate(recordTypeName);
                            return null;
                        }
                        return null;
                    }
                    else
                    {
                        System.debug('recordIdElse====>'+retUrlRecordId);
                        PageReference taskDetailPage=new PageReference('/'+retUrlRecordId);
                        taskDetailPage.setRedirect(true);
                        return taskDetailPage;
                    }
                    return null;
            }
            else
            {
                System.debug('inside final else');
                //String taskEditUrl='/00T/e?'+'&retURL='+retUrlRecordId+'&RecordType='+recordTypeId+'&ent=Task&nooverride=1';
                String taskEditUrl;
                if(taskId==null)
                taskEditUrl='/00T/e?'+'&retURL='+retUrlRecordId+'&RecordType='+recordTypeId+'&ent=Task&nooverride=1';
                else
                taskEditUrl='/'+taskId+'/e?retURL='+test+'&RecordType='+recordTypeId+'&ent=Task&nooverride=1';
                system.debug('tsk5===>>>>>'+tsk5);
                /*3/23/2016: PK: Carry forward the subject for "Save & New button"*/
                if(tsk5 != null){
                    taskEditUrl = taskEditUrl + '&tsk5='+tsk5;//EncodingUtil.urlEncode(tsk5,'UTF-8');
                }
                if(whatId != null){
                    taskEditUrl = taskEditUrl + '&what_id='+whatId;
                }   
                if(whoId!=null)
                {
                    taskEditUrl = taskEditUrl + '&who_id='+whoId;
                }
                if(logACall != null){
                    taskEditUrl = taskEditUrl + '&followup='+logACall;
                }
                system.debug('tsk5===>>>>>'+tsk5);
                system.debug('taskEditUrl===>>>>>'+taskEditUrl);
                PageReference taskDetailPage=new PageReference(taskEditUrl);
                taskDetailPage.setRedirect(true);
                return taskDetailPage;
            }
            return null;
        }
        else
        {
            System.debug('inside final else');
            String taskEditUrl;
            if(taskId==null)
            taskEditUrl='/00T/e?'+'&retURL='+retUrlRecordId+'&RecordType='+recordTypeId+'&ent=Task&nooverride=1';
            else
            taskEditUrl='/'+taskId+'/e?retURL='+test+'&RecordType='+recordTypeId+'&ent=Task&nooverride=1';
            System.debug('taskEditUrl=========>>>>'+taskEditUrl);
            System.debug('tsk5=========>>>>'+tsk5);
            /*3/23/2016: PK: Carry forward the subject for "Save & New button"*/
            if(tsk5 != null){
                taskEditUrl = taskEditUrl + '&tsk5='+tsk5;
                System.debug('taskEditUrl =========>>>>'+taskEditUrl );
            }
            if(whatId != null){
                taskEditUrl = taskEditUrl + '&what_id='+whatId;
            }   
            if(whoId!=null)
            {
                taskEditUrl = taskEditUrl + '&who_id='+whoId;
            }
            if(logACall != null){
                taskEditUrl = taskEditUrl + '&followup='+logACall;
            }
            PageReference taskDetailPage=new PageReference(taskEditUrl);
            taskDetailPage.setRedirect(true);
            return taskDetailPage;
        }
        return null;
    }
        
    //This method will create a instance of Contact along with the Status which needs to be updated....
    private void createLeadUpdate(String recordType)
    {
        if(recordType=='BizDev_Tasks')
        {
            if(leadRec.Event_Lead_Status__c=='Closed Won' && leadRec.CC_Lead_Status__c=='Closed Won' && leadRec.SMM_Lead_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='None';
            }
            else if(leadRec.Event_Lead_Status__c!='Closed Won' && leadRec.CC_Lead_Status__c!='Closed Won' && leadRec.SMM_Lead_Status__c!='Closed Won')
            {
                conStatusUpdate_Var='EventCCSMM';
            }
            //New code from here
            else if(leadRec.Event_Lead_Status__c=='Closed Won' && leadRec.CC_Lead_Status__c=='Closed Won' && leadRec.SMM_Lead_Status__c!='Closed Won')
            {
                conStatusUpdate_Var='SMM';
            }
            else if(leadRec.Event_Lead_Status__c=='Closed Won' && leadRec.CC_Lead_Status__c!='Closed Won' && leadRec.SMM_Lead_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='CC';
            }
            else if(leadRec.Event_Lead_Status__c!='Closed Won' && leadRec.CC_Lead_Status__c=='Closed Won' && leadRec.SMM_Lead_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='Event';
            }
            else if(leadRec.Event_Lead_Status__c=='Closed Won' && leadRec.CC_Lead_Status__c!='Closed Won' && leadRec.SMM_Lead_Status__c!='Closed Won')
            {
                conStatusUpdate_Var='CCSMM';
            }
            else if(leadRec.Event_Lead_Status__c!='Closed Won' && leadRec.CC_Lead_Status__c=='Closed Won' && leadRec.SMM_Lead_Status__c!='Closed Won')
            {
                conStatusUpdate_Var='EventSMM';
            }
            else if(leadRec.Event_Lead_Status__c!='Closed Won' && leadRec.CC_Lead_Status__c!='Closed Won' && leadRec.SMM_Lead_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='EventCC';
            }
        }
        /*22nd June 2016 : HSR --> Added new "Enterprise" and "TPP_Intl_Task" Task Record Type */
        else if(recordType=='Enterprise'){
            if(leadRec.SMM_Lead_Status__c == 'Closed Won'){
                conStatusUpdate_Var='None';
            }
            else{
                conStatusUpdate_Var='SMMEnterprise';
            }
        }
        else if(recordType=='Event_Tasks' ||  recordType=='TPP_Intl_Task')
        {
            if(leadRec.Event_Lead_Status__c=='Closed Won' && leadRec.CC_Lead_Status__c=='Closed Won' && leadRec.CSN_P_Lead_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='None';
            }
            else if(leadRec.Event_Lead_Status__c!='Closed Won' && leadRec.CC_Lead_Status__c!='Closed Won' && leadRec.CSN_P_Lead_Status__c!='Closed Won')
            {
                conStatusUpdate_Var='EventCCCSN';
            }
            //New code from here
            else if(leadRec.Event_Lead_Status__c=='Closed Won' && leadRec.CC_Lead_Status__c=='Closed Won' && leadRec.CSN_P_Lead_Status__c!='Closed Won')
            {
                conStatusUpdate_Var='CSN';
            }
            else if(leadRec.Event_Lead_Status__c=='Closed Won' && leadRec.CC_Lead_Status__c!='Closed Won' && leadRec.CSN_P_Lead_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='CC';
            }
            else if(leadRec.Event_Lead_Status__c!='Closed Won' && leadRec.CC_Lead_Status__c=='Closed Won' && leadRec.CSN_P_Lead_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='Event';
            }
            else if(leadRec.Event_Lead_Status__c=='Closed Won' && leadRec.CC_Lead_Status__c!='Closed Won' && leadRec.CSN_P_Lead_Status__c!='Closed Won')
            {
                conStatusUpdate_Var='CCCSN';
            }
            else if(leadRec.Event_Lead_Status__c!='Closed Won' && leadRec.CC_Lead_Status__c=='Closed Won' && leadRec.CSN_P_Lead_Status__c!='Closed Won')
            {
                conStatusUpdate_Var='EventCSN';
            }
            else if(leadRec.Event_Lead_Status__c!='Closed Won' && leadRec.CC_Lead_Status__c!='Closed Won' && leadRec.CSN_P_Lead_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='EventCC';
            }
        }
        /*.............................. ENDS HERE....................... */
        else if(recordType=='CSN_Tasks'||recordType=='SR_Tasks')  
        {
            if(leadRec.CSN_S_Lead_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='None';
            }
            else
            {
                conStatusUpdate_Var='CSNS';
            }
        }
        else if(recordType=='PA_Tasks')
        {
            if(leadRec.CSN_P_Lead_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='None';
            }
            else
            {
                conStatusUpdate_Var='CSNP';
            }
        }
        else if(recordType=='CC_Tasks')
        {
            if(leadRec.CC_Lead_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='None';
            }
            else
            {
                conStatusUpdate_Var='CC';
            }
        }
        else if(recordType=='Inquisium_Tasks')
        {
            if(leadRec.Lead_Status_Reason_Survey__c=='Closed Won')
            {
                conStatusUpdate_Var='None';
            }
            else
            {
                conStatusUpdate_Var='Survey';
            }
        }
    } 
    //This method will create a instance of Contact along with the Status which needs to be updated....
    private void createContactUpdate(String recordType)
    {
        if(recordType=='BizDev_Tasks')
        {
            if(contactRec.Event_Contact_Status__c=='Closed Won' && contactRec.CC_Contact_Status__c=='Closed Won' && contactRec.SMM_Contact_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='None';
            }
            else if(contactRec.Event_Contact_Status__c!='Closed Won' && contactRec.CC_Contact_Status__c!='Closed Won' && contactRec.SMM_Contact_Status__c!='Closed Won')
            {
                conStatusUpdate_Var='EventCCSMM';
            }
            //New code from here
            else if(contactRec.Event_Contact_Status__c=='Closed Won' && contactRec.CC_Contact_Status__c=='Closed Won' && contactRec.SMM_Contact_Status__c!='Closed Won')
            {
                conStatusUpdate_Var='SMM';
            }
            else if(contactRec.Event_Contact_Status__c=='Closed Won' && contactRec.CC_Contact_Status__c!='Closed Won' && contactRec.SMM_Contact_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='CC';
            }
            else if(contactRec.Event_Contact_Status__c!='Closed Won' && contactRec.CC_Contact_Status__c=='Closed Won' && contactRec.SMM_Contact_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='Event';
            }
            else if(contactRec.Event_Contact_Status__c=='Closed Won' && contactRec.CC_Contact_Status__c!='Closed Won' && contactRec.SMM_Contact_Status__c!='Closed Won')
            {
                conStatusUpdate_Var='CCSMM';
            }
            else if(contactRec.Event_Contact_Status__c!='Closed Won' && contactRec.CC_Contact_Status__c=='Closed Won' && contactRec.SMM_Contact_Status__c!='Closed Won')
            {
                conStatusUpdate_Var='EventSMM';
            }
            else if(contactRec.Event_Contact_Status__c!='Closed Won' && contactRec.CC_Contact_Status__c!='Closed Won' && contactRec.SMM_Contact_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='EventCC';
            }
        }
        /*22nd June 2016 : HSR --> Added new "Enterprise" Task Record Type */
        else if(recordType=='Enterprise')
        {
            if(contactRec.Event_Contact_Status__c=='Closed Won' && contactRec.CC_Contact_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='None';
            }
            else if(contactRec.Event_Contact_Status__c!='Closed Won' && contactRec.CC_Contact_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='SMMEnterpriseEvent';
            }
            else if(contactRec.Event_Contact_Status__c=='Closed Won' && contactRec.CC_Contact_Status__c!='Closed Won')
            {
                conStatusUpdate_Var='SMMEnterpriseCC';
            }
            else if(contactRec.Event_Contact_Status__c!='Closed Won' && contactRec.CC_Contact_Status__c!='Closed Won')
            {
                conStatusUpdate_Var='SMMEnterpriseEveCC';
            }
        }
        else if(recordType=='Event_Tasks' || recordType=='TPP_Intl_Task')
        {
            if(contactRec.Event_Contact_Status__c=='Closed Won' && contactRec.CC_Contact_Status__c=='Closed Won' && contactRec.CSN_P_Contact_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='None';
            }
            else if(contactRec.Event_Contact_Status__c!='Closed Won' && contactRec.CC_Contact_Status__c!='Closed Won' && contactRec.CSN_P_Contact_Status__c!='Closed Won')
            {
                conStatusUpdate_Var='EventCCCSN';
            }
            else if(contactRec.Event_Contact_Status__c=='Closed Won' && contactRec.CC_Contact_Status__c=='Closed Won' && contactRec.CSN_P_Contact_Status__c!='Closed Won')
            {
                conStatusUpdate_Var='CSN';
            }
            else if(contactRec.Event_Contact_Status__c=='Closed Won' && contactRec.CC_Contact_Status__c!='Closed Won' && contactRec.CSN_P_Contact_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='CC';
            }
            else if(contactRec.Event_Contact_Status__c!='Closed Won' && contactRec.CC_Contact_Status__c=='Closed Won' && contactRec.CSN_P_Contact_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='Event';
            }
            else if(contactRec.Event_Contact_Status__c=='Closed Won' && contactRec.CC_Contact_Status__c!='Closed Won' && contactRec.CSN_P_Contact_Status__c!='Closed Won')
            {
                conStatusUpdate_Var='CCCSN';
            }
            else if(contactRec.Event_Contact_Status__c!='Closed Won' && contactRec.CC_Contact_Status__c=='Closed Won' && contactRec.CSN_P_Contact_Status__c!='Closed Won')
            {
                conStatusUpdate_Var='EventCSN';
            }
            else if(contactRec.Event_Contact_Status__c!='Closed Won' && contactRec.CC_Contact_Status__c!='Closed Won' && contactRec.CSN_P_Contact_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='EventCC';
            }
        }
        /*.............................. ENDS HERE....................... */
        else if(recordType=='CSN_Tasks'||recordType=='SR_Tasks')
        {
            if(contactRec.CSNS_Contact_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='None';
            }
            else
            {
                conStatusUpdate_Var='CSNS';
            }
        }
        else if(recordType=='PA_Tasks')
        {
            if(contactRec.CSN_P_Contact_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='None';
            }
            else
            {
                conStatusUpdate_Var='CSNP';
            }
        }
        else if(recordType=='CC_Tasks')
        {
            if(contactRec.CC_Contact_Status__c == 'Closed Won')
            {
                conStatusUpdate_Var='None';
            }
            else
            {
                conStatusUpdate_Var='CC';
            }
        }
        else if(recordType=='Inquisium_Tasks')
        {
            if(contactRec.Survey_Contact_Status__c=='Closed Won')
            {
                conStatusUpdate_Var='None';
            }
            else
            {
                conStatusUpdate_Var='Survey';
            }
        }
    }   
    //Called through the save button

    public PageReference SaveContact()
    {
        if(recordPrefix=='003'){
            if(conStatusUpdate_Var=='None')
            {
                con=new Contact(Id=contactId);
            }
            /*22nd June 2016 : HSR --> Added new "Enterprise" Task Record Type */
            else if(conStatusUpdate_Var=='SMMEnterpriseEvent')
            {
                con=new Contact(id=contactRec.Id);
                /* con.SMM_Contact_Status__c=contactRec.SMM_Contact_Status__c;
                con.SMM_Recycle_Trash_Reason__c=contactRec.SMM_Recycle_Trash_Reason__c;
                con.SMM_Recycle_Competitor_Name__c=contactRec.SMM_Recycle_Competitor_Name__c;
                con.SMM_Lost_Details__c=contactRec.SMM_Lost_Details__c; */
                con.Event_Not_Ready_Reason__c=contactRec.Event_Not_Ready_Reason__c;
                con.Event_Contact_Status__c=contactRec.Event_Contact_Status__c;
                con.Event_Recycle_Reason__c=contactRec.Event_Recycle_Reason__c;
                con.Event_Recycle_Competitor_Name__c=contactRec.Event_Recycle_Competitor_Name__c;
                con.Event_Lost_Details__c=contactRec.Event_Lost_Details__c;
            }
            else if(conStatusUpdate_Var=='SMMEnterpriseCC')
            {
                con=new Contact(id=contactRec.Id);
                /* con.SMM_Contact_Status__c=contactRec.SMM_Contact_Status__c;
                con.SMM_Recycle_Trash_Reason__c=contactRec.SMM_Recycle_Trash_Reason__c;
                con.SMM_Recycle_Competitor_Name__c=contactRec.SMM_Recycle_Competitor_Name__c;
                con.SMM_Lost_Details__c=contactRec.SMM_Lost_Details__c; */
                con.CC_Not_Ready_Reason__c=contactRec.CC_Not_Ready_Reason__c;
                con.CC_Contact_Status__c=contactRec.CC_Contact_Status__c;
                con.CC_Recycle_Trash_Reason__c=contactRec.CC_Recycle_Trash_Reason__c;
                con.CC_Recycle_Competitor_Name__c=contactRec.CC_Recycle_Competitor_Name__c;
                con.CC_Lost_Details__c=contactRec.CC_Lost_Details__c;
                
            }
            else if(conStatusUpdate_Var=='SMMEnterpriseEveCC')
            {
                con=new Contact(id=contactRec.Id);
                /* con.SMM_Contact_Status__c=contactRec.SMM_Contact_Status__c;
                con.SMM_Recycle_Trash_Reason__c=contactRec.SMM_Recycle_Trash_Reason__c;
                con.SMM_Recycle_Competitor_Name__c=contactRec.SMM_Recycle_Competitor_Name__c;
                con.SMM_Lost_Details__c=contactRec.SMM_Lost_Details__c; */
                
                con.Event_Contact_Status__c=contactRec.Event_Contact_Status__c;
                con.CC_Contact_Status__c=contactRec.CC_Contact_Status__c;
                con.Event_Recycle_Reason__c=contactRec.Event_Recycle_Reason__c;
                con.CC_Recycle_Trash_Reason__c=contactRec.CC_Recycle_Trash_Reason__c;
                con.Event_Recycle_Competitor_Name__c=contactRec.Event_Recycle_Competitor_Name__c;
                con.CC_Recycle_Competitor_Name__c=contactRec.CC_Recycle_Competitor_Name__c;
                con.Event_Lost_Details__c=contactRec.Event_Lost_Details__c;
                con.CC_Lost_Details__c=contactRec.CC_Lost_Details__c;
                con.CC_Not_Ready_Reason__c=contactRec.CC_Not_Ready_Reason__c;
                con.Event_Not_Ready_Reason__c=contactRec.Event_Not_Ready_Reason__c;
            }
            else if(conStatusUpdate_Var=='EventCCCSN')
            {
                con=new Contact(id=contactRec.Id);
                
                con.CC_Contact_Status__c=contactRec.CC_Contact_Status__c;
                con.CC_Recycle_Trash_Reason__c=contactRec.CC_Recycle_Trash_Reason__c;
                con.CC_Recycle_Competitor_Name__c=contactRec.CC_Recycle_Competitor_Name__c;
                con.CC_Lost_Details__c=contactRec.CC_Lost_Details__c;
                con.CC_Not_Ready_Reason__c=contactRec.CC_Not_Ready_Reason__c;
                
                con.Event_Contact_Status__c=contactRec.Event_Contact_Status__c;
                con.Event_Recycle_Reason__c=contactRec.Event_Recycle_Reason__c;
                con.Event_Recycle_Competitor_Name__c=contactRec.Event_Recycle_Competitor_Name__c;
                con.Event_Lost_Details__c=contactRec.Event_Lost_Details__c;
                con.Event_Not_Ready_Reason__c=contactRec.Event_Not_Ready_Reason__c;
                
                con.CSN_P_Contact_Status__c=contactRec.CSN_P_Contact_Status__c;
                con.Sourcing_through__c=contactRec.Sourcing_through__c;
                con.CSN_P_Recycle_Competitor_Name__c=contactRec.CSN_P_Recycle_Competitor_Name__c;
                con.CSN_P_Lost_Details__c=contactRec.CSN_P_Lost_Details__c;
                con.CSN_P_Status_Details__c=contactRec.CSN_P_Status_Details__c;
                con.CSN_P_Not_Ready_Reason__c=contactRec.CSN_P_Not_Ready_Reason__c;
                
            }
            else if(conStatusUpdate_Var=='CSN')
            {
                con=new Contact(id=contactRec.Id);
                
                con.CSN_P_Contact_Status__c=contactRec.CSN_P_Contact_Status__c;
                con.Sourcing_through__c=contactRec.Sourcing_through__c;
                con.CSN_P_Recycle_Competitor_Name__c=contactRec.CSN_P_Recycle_Competitor_Name__c;
                con.CSN_P_Lost_Details__c=contactRec.CSN_P_Lost_Details__c;
                con.CSN_P_Status_Details__c=contactRec.CSN_P_Status_Details__c;
                con.CSN_P_Not_Ready_Reason__c=contactRec.CSN_P_Not_Ready_Reason__c;
            }
            else if(conStatusUpdate_Var=='CCCSN')
            {
                con=new Contact(id=contactRec.Id);
                
                con.CC_Contact_Status__c=contactRec.CC_Contact_Status__c;
                con.CC_Recycle_Trash_Reason__c=contactRec.CC_Recycle_Trash_Reason__c;
                con.CC_Recycle_Competitor_Name__c=contactRec.CC_Recycle_Competitor_Name__c;
                con.CC_Lost_Details__c=contactRec.CC_Lost_Details__c;
                con.CC_Not_Ready_Reason__c=contactRec.CC_Not_Ready_Reason__c;
                
                con.CSN_P_Contact_Status__c=contactRec.CSN_P_Contact_Status__c;
                con.Sourcing_through__c=contactRec.Sourcing_through__c;
                con.CSN_P_Recycle_Competitor_Name__c=contactRec.CSN_P_Recycle_Competitor_Name__c;
                con.CSN_P_Lost_Details__c=contactRec.CSN_P_Lost_Details__c;
                con.CSN_P_Status_Details__c=contactRec.CSN_P_Status_Details__c;
                con.CSN_P_Not_Ready_Reason__c=contactRec.CSN_P_Not_Ready_Reason__c;
            }
            else if(conStatusUpdate_Var=='EventCSN')//
            {
                con=new Contact(id=contactRec.Id);
                
                con.Event_Contact_Status__c=contactRec.Event_Contact_Status__c;
                con.Event_Recycle_Reason__c=contactRec.Event_Recycle_Reason__c;
                con.Event_Recycle_Competitor_Name__c=contactRec.Event_Recycle_Competitor_Name__c;
                con.Event_Lost_Details__c=contactRec.Event_Lost_Details__c;
                con.Event_Not_Ready_Reason__c=contactRec.Event_Not_Ready_Reason__c;
                
                con.CSN_P_Contact_Status__c=contactRec.CSN_P_Contact_Status__c;
                con.Sourcing_through__c=contactRec.Sourcing_through__c;
                con.CSN_P_Recycle_Competitor_Name__c=contactRec.CSN_P_Recycle_Competitor_Name__c;
                con.CSN_P_Lost_Details__c=contactRec.CSN_P_Lost_Details__c;
                con.CSN_P_Status_Details__c=contactRec.CSN_P_Status_Details__c;
                con.CSN_P_Not_Ready_Reason__c=contactRec.CSN_P_Not_Ready_Reason__c;
            }
            /*.............................. ENDS HERE....................... */
            else if(conStatusUpdate_Var=='EventSMM')
            {
                con=new Contact(id=contactRec.Id);
                
                con.Event_Contact_Status__c=contactRec.Event_Contact_Status__c;
                con.Event_Recycle_Reason__c=contactRec.Event_Recycle_Reason__c;
                con.Event_Recycle_Competitor_Name__c=contactRec.Event_Recycle_Competitor_Name__c;
                con.Event_Lost_Details__c=contactRec.Event_Lost_Details__c;
                con.Event_Not_Ready_Reason__c=contactRec.Event_Not_Ready_Reason__c;
                
                con.SMM_Contact_Status__c=contactRec.SMM_Contact_Status__c;
                con.SMM_Recycle_Trash_Reason__c=contactRec.SMM_Recycle_Trash_Reason__c;
                con.SMM_Recycle_Competitor_Name__c=contactRec.SMM_Recycle_Competitor_Name__c;
                con.SMM_Lost_Details__c=contactRec.SMM_Lost_Details__c;
            }
            else if(conStatusUpdate_Var=='EventCC')
            {
                con=new Contact(id=contactRec.Id);
                
                con.CC_Contact_Status__c=contactRec.CC_Contact_Status__c;
                con.CC_Recycle_Trash_Reason__c=contactRec.CC_Recycle_Trash_Reason__c;
                con.CC_Recycle_Competitor_Name__c=contactRec.CC_Recycle_Competitor_Name__c;
                con.CC_Lost_Details__c=contactRec.CC_Lost_Details__c;
                con.CC_Not_Ready_Reason__c=contactRec.CC_Not_Ready_Reason__c;
                
                con.Event_Contact_Status__c=contactRec.Event_Contact_Status__c;
                con.Event_Recycle_Reason__c=contactRec.Event_Recycle_Reason__c;
                con.Event_Recycle_Competitor_Name__c=contactRec.Event_Recycle_Competitor_Name__c;
                con.Event_Lost_Details__c=contactRec.Event_Lost_Details__c;
                con.Event_Not_Ready_Reason__c=contactRec.Event_Not_Ready_Reason__c;
            }
            else if(conStatusUpdate_Var=='CCSMM')
            {
                con=new Contact(id=contactRec.Id);
                
                con.CC_Contact_Status__c=contactRec.CC_Contact_Status__c;
                con.CC_Recycle_Trash_Reason__c=contactRec.CC_Recycle_Trash_Reason__c;
                con.CC_Recycle_Competitor_Name__c=contactRec.CC_Recycle_Competitor_Name__c;
                con.CC_Lost_Details__c=contactRec.CC_Lost_Details__c;
                con.CC_Not_Ready_Reason__c=contactRec.CC_Not_Ready_Reason__c;
                
                con.SMM_Contact_Status__c=contactRec.SMM_Contact_Status__c;
                con.SMM_Recycle_Trash_Reason__c=contactRec.SMM_Recycle_Trash_Reason__c;
                con.SMM_Recycle_Competitor_Name__c=contactRec.SMM_Recycle_Competitor_Name__c;
                con.SMM_Lost_Details__c=contactRec.SMM_Lost_Details__c;
            }
            else if(conStatusUpdate_Var=='Event')
            {
                con=new Contact(id=contactRec.Id);
                con.Event_Contact_Status__c=contactRec.Event_Contact_Status__c;
                con.Event_Recycle_Reason__c=contactRec.Event_Recycle_Reason__c;
                con.Event_Recycle_Competitor_Name__c=contactRec.Event_Recycle_Competitor_Name__c;
                con.Event_Lost_Details__c=contactRec.Event_Lost_Details__c;
                con.Event_Not_Ready_Reason__c=contactRec.Event_Not_Ready_Reason__c;
            }
            else if(conStatusUpdate_Var=='CC')
            {
                con=new Contact(id=contactRec.Id);
                con.CC_Contact_Status__c=contactRec.CC_Contact_Status__c;
                con.CC_Recycle_Trash_Reason__c=contactRec.CC_Recycle_Trash_Reason__c;
                con.CC_Recycle_Competitor_Name__c=contactRec.CC_Recycle_Competitor_Name__c;
                con.CC_Lost_Details__c=contactRec.CC_Lost_Details__c;
                con.CC_Not_Ready_Reason__c=contactRec.CC_Not_Ready_Reason__c;
            }
            else if(conStatusUpdate_Var=='EventCCSMM')
            {
                con=new Contact(id=contactRec.Id);
                
                con.CC_Contact_Status__c=contactRec.CC_Contact_Status__c;
                con.CC_Recycle_Trash_Reason__c=contactRec.CC_Recycle_Trash_Reason__c;
                con.CC_Recycle_Competitor_Name__c=contactRec.CC_Recycle_Competitor_Name__c;
                con.CC_Lost_Details__c=contactRec.CC_Lost_Details__c;
                con.CC_Not_Ready_Reason__c=contactRec.CC_Not_Ready_Reason__c;
                
                con.Event_Contact_Status__c=contactRec.Event_Contact_Status__c;
                con.Event_Recycle_Reason__c=contactRec.Event_Recycle_Reason__c;
                con.Event_Recycle_Competitor_Name__c=contactRec.Event_Recycle_Competitor_Name__c;
                con.Event_Lost_Details__c=contactRec.Event_Lost_Details__c;
                con.Event_Not_Ready_Reason__c=contactRec.Event_Not_Ready_Reason__c;
                
                con.SMM_Contact_Status__c=contactRec.SMM_Contact_Status__c;
                con.SMM_Recycle_Trash_Reason__c=contactRec.SMM_Recycle_Trash_Reason__c;
                con.SMM_Recycle_Competitor_Name__c=contactRec.SMM_Recycle_Competitor_Name__c;
                con.SMM_Lost_Details__c=contactRec.SMM_Lost_Details__c;
            }
            else if(conStatusUpdate_Var=='SMM')
            {
                con=new Contact(id=contactRec.Id);
                con.SMM_Contact_Status__c=contactRec.SMM_Contact_Status__c;
                con.SMM_Recycle_Trash_Reason__c=contactRec.SMM_Recycle_Trash_Reason__c;
                con.SMM_Recycle_Competitor_Name__c=contactRec.SMM_Recycle_Competitor_Name__c;
                con.SMM_Lost_Details__c=contactRec.SMM_Lost_Details__c;
            }
            else if(conStatusUpdate_Var=='CSNS')
            {
                con=new Contact(id=contactRec.Id);
                con.CSNS_Contact_Status__c=contactRec.CSNS_Contact_Status__c;
                con.CSN_S_Recycle_Trash__c=contactRec.CSN_S_Recycle_Trash__c;
                con.CSN_S_Recycle_Competitor_Name__c=contactRec.CSN_S_Recycle_Competitor_Name__c;
                con.CSN_S_Lost_Details__c=contactRec.CSN_S_Lost_Details__c;
                con.HC_Not_Ready_Reason__c=contactRec.HC_Not_Ready_Reason__c;
                
            }
            else if(conStatusUpdate_Var=='CSNP')
            {
                con=new Contact(Id=contactRec.Id);
                con.CSN_P_Contact_Status__c=contactRec.CSN_P_Contact_Status__c;
                con.Sourcing_through__c=contactRec.Sourcing_through__c;
                con.CSN_P_Recycle_Competitor_Name__c=contactRec.CSN_P_Recycle_Competitor_Name__c;
                con.CSN_P_Lost_Details__c=contactRec.CSN_P_Lost_Details__c;
                con.CSN_P_Status_Details__c=contactRec.CSN_P_Status_Details__c;
                con.CSN_P_Not_Ready_Reason__c=contactRec.CSN_P_Not_Ready_Reason__c;
                
            }
            else if(conStatusUpdate_Var=='Survey')
            {
                con=new Contact(id=contactRec.Id);
                con.Survey_Contact_Status__c=contactRec.Survey_Contact_Status__c;
                con.Survey_Recycle_Reason__c=contactRec.Survey_Recycle_Reason__c;
                con.Survey_Recycle_Competitor_Name__c=contactRec.Survey_Recycle_Competitor_Name__c;
                con.Survey_Lost_Details__c=contactRec.Survey_Lost_Details__c;
                con.Inquisium_Not_Ready_Reason__c=contactRec.Inquisium_Not_Ready_Reason__c;
            }
            try{
            update con;
            }
            catch(Exception e){
                String errorSubstring = e.getMessage().SubStringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION, ');
                errorSubstring = errorSubstring .SubstringBefore(': []');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorSubstring));
                return null;
            }
        }
        if(recordPrefix=='00Q')
        {
            System.debug('===>conStatusUpdate_Var'+conStatusUpdate_Var);
            if(conStatusUpdate_Var=='None')
            {
                leadObj=new lead(Id=contactId);
            }
            /*22nd June 2016 : HSR --> Added new "Enterprise" Task Record Type */
            else if(conStatusUpdate_Var=='SMMEnterprise')
            {
                leadObj = new Lead(id=leadRec.Id);
                leadObj.SMM_Lead_Status__c=leadRec.SMM_Lead_Status__c;
                leadObj.SMM_Recycle_Trash_Reason__c=leadRec.SMM_Recycle_Trash_Reason__c;
                leadObj.SMM_Recycle_Competitor_Name__c=leadRec.SMM_Recycle_Competitor_Name__c;
                leadObj.SMM_Lost_Details__c=leadRec.SMM_Lost_Details__c;
            }
            else if(conStatusUpdate_Var=='EventCCCSN')
            {
                leadObj = new Lead(id=leadRec.Id);
                
                leadObj.CC_Lead_Status__c=leadRec.CC_Lead_Status__c;
                leadObj.CC_Recycle_Trash_Reason__c=leadRec.CC_Recycle_Trash_Reason__c;
                leadObj.CC_Recycle_Competitor_Name__c=leadRec.CC_Recycle_Competitor_Name__c;
                leadObj.CC_Lost_Details__c=leadRec.CC_Lost_Details__c;
                
                leadObj.Event_Lead_Status__c=leadRec.Event_Lead_Status__c;
                leadObj.Event_Recycle_Reason__c=leadRec.Event_Recycle_Reason__c;
                leadObj.Event_Recycle_Competitor_Name__c=leadRec.Event_Recycle_Competitor_Name__c;
                leadObj.Event_Lost_Details__c=leadRec.Event_Lost_Details__c;
                
                leadObj.CSN_P_Lead_Status__c=leadRec.CSN_P_Lead_Status__c;
                leadObj.Sourcing_through__c=leadRec.Sourcing_through__c;
                leadObj.CSN_P_Recycle_Competitor_Name__c=leadRec.CSN_P_Recycle_Competitor_Name__c;
                leadObj.CSN_P_Lost_Details__c=leadRec.CSN_P_Lost_Details__c;
                leadObj.CSN_P_Status_Details__c=leadRec.CSN_P_Status_Details__c;
            }
            else if(conStatusUpdate_Var=='CSN')
            {
                leadObj=new Lead(id=leadRec.Id);
                leadObj.CSN_P_Lead_Status__c=leadRec.CSN_P_Lead_Status__c;
                leadObj.Sourcing_through__c=leadRec.Sourcing_through__c;
                leadObj.CSN_P_Recycle_Competitor_Name__c=leadRec.CSN_P_Recycle_Competitor_Name__c;
                leadObj.CSN_P_Lost_Details__c=leadRec.CSN_P_Lost_Details__c;
                leadObj.CSN_P_Status_Details__c=leadRec.CSN_P_Status_Details__c;
            }
            else if(conStatusUpdate_Var=='CCCSN')
            {
                leadObj=new Lead(id=leadRec.Id);
                
                leadObj.CC_Lead_Status__c=leadRec.CC_Lead_Status__c;
                leadObj.CC_Recycle_Trash_Reason__c=leadRec.CC_Recycle_Trash_Reason__c;
                leadObj.CC_Recycle_Competitor_Name__c=leadRec.CC_Recycle_Competitor_Name__c;
                leadObj.CC_Lost_Details__c=leadRec.CC_Lost_Details__c;
                
                leadObj.CSN_P_Lead_Status__c=leadRec.CSN_P_Lead_Status__c;
                leadObj.Sourcing_through__c=leadRec.Sourcing_through__c;
                leadObj.CSN_P_Recycle_Competitor_Name__c=leadRec.CSN_P_Recycle_Competitor_Name__c;
                leadObj.CSN_P_Lost_Details__c=leadRec.CSN_P_Lost_Details__c;
                leadObj.CSN_P_Status_Details__c=leadRec.CSN_P_Status_Details__c;
            }
            else if(conStatusUpdate_Var=='EventCSN')//
            {
                leadObj=new Lead(id=leadRec.Id);
                
                leadObj.Event_Lead_Status__c=leadRec.Event_Lead_Status__c;
                leadObj.Event_Recycle_Reason__c=leadRec.Event_Recycle_Reason__c;
                leadObj.Event_Recycle_Competitor_Name__c=leadRec.Event_Recycle_Competitor_Name__c;
                leadObj.Event_Lost_Details__c=leadRec.Event_Lost_Details__c;
                
                leadObj.CSN_P_Lead_Status__c=leadRec.CSN_P_Lead_Status__c;
                leadObj.Sourcing_through__c=leadRec.Sourcing_through__c;
                leadObj.CSN_P_Recycle_Competitor_Name__c=leadRec.CSN_P_Recycle_Competitor_Name__c;
                leadObj.CSN_P_Lost_Details__c=leadRec.CSN_P_Lost_Details__c;
                leadObj.CSN_P_Status_Details__c=leadRec.CSN_P_Status_Details__c;
            }
            
            
            /*.............................. ENDS HERE....................... */
             else if(conStatusUpdate_Var=='EventSMM')
            {
                leadObj=new Lead(id=leadRec.Id);
                leadObj.Event_Lead_Status__c=leadRec.Event_Lead_Status__c;
                leadObj.Event_Recycle_Reason__c=leadRec.Event_Recycle_Reason__c;
                leadObj.Event_Recycle_Competitor_Name__c=leadRec.Event_Recycle_Competitor_Name__c;
                leadObj.Event_Lost_Details__c=leadRec.Event_Lost_Details__c;
                
                leadObj.SMM_Lead_Status__c=leadRec.SMM_Lead_Status__c;
                leadObj.SMM_Recycle_Trash_Reason__c=leadRec.SMM_Recycle_Trash_Reason__c;
                leadObj.SMM_Recycle_Competitor_Name__c=leadRec.SMM_Recycle_Competitor_Name__c;
                leadObj.SMM_Lost_Details__c=leadRec.SMM_Lost_Details__c;
            }
            else if(conStatusUpdate_Var=='EventCC')
            {
                leadObj=new Lead(id=leadRec.Id);
                
                leadObj.CC_Lead_Status__c=leadRec.CC_Lead_Status__c;
                leadObj.CC_Recycle_Trash_Reason__c=leadRec.CC_Recycle_Trash_Reason__c;
                leadObj.CC_Recycle_Competitor_Name__c=leadRec.CC_Recycle_Competitor_Name__c;
                leadObj.CC_Lost_Details__c=leadRec.CC_Lost_Details__c;
                
                leadObj.Event_Lead_Status__c=leadRec.Event_Lead_Status__c;
                leadObj.Event_Recycle_Reason__c=leadRec.Event_Recycle_Reason__c;
                leadObj.Event_Recycle_Competitor_Name__c=leadRec.Event_Recycle_Competitor_Name__c;
                leadObj.Event_Lost_Details__c=leadRec.Event_Lost_Details__c;
            }
            else if(conStatusUpdate_Var=='CCSMM')
            {
                leadObj=new Lead(id=leadRec.Id);
                leadObj.CC_Lead_Status__c=leadRec.CC_Lead_Status__c;
                leadObj.CC_Recycle_Trash_Reason__c=leadRec.CC_Recycle_Trash_Reason__c;
                leadObj.CC_Recycle_Competitor_Name__c=leadRec.CC_Recycle_Competitor_Name__c;
                leadObj.CC_Lost_Details__c=leadRec.CC_Lost_Details__c;
                leadObj.SMM_Lead_Status__c=leadRec.SMM_Lead_Status__c;
                leadObj.SMM_Recycle_Trash_Reason__c=leadRec.SMM_Recycle_Trash_Reason__c;
                leadObj.SMM_Recycle_Competitor_Name__c=leadRec.SMM_Recycle_Competitor_Name__c;
                leadObj.SMM_Lost_Details__c=leadRec.SMM_Lost_Details__c;
            }
            else if(conStatusUpdate_Var=='Event')
            {
                leadObj=new Lead(id=leadRec.Id);
                leadObj.Event_Lead_Status__c=leadRec.Event_Lead_Status__c;
                leadObj.Event_Recycle_Reason__c=leadRec.Event_Recycle_Reason__c;
                leadObj.Event_Recycle_Competitor_Name__c=leadRec.Event_Recycle_Competitor_Name__c;
                leadObj.Event_Lost_Details__c=leadRec.Event_Lost_Details__c;
            }
            else if(conStatusUpdate_Var=='CC')
            {
                leadObj=new Lead(id=leadRec.Id);
                leadObj.CC_Lead_Status__c=leadRec.CC_Lead_Status__c;
                leadObj.CC_Recycle_Trash_Reason__c=leadRec.CC_Recycle_Trash_Reason__c;
                leadObj.CC_Recycle_Competitor_Name__c=leadRec.CC_Recycle_Competitor_Name__c;
                leadObj.CC_Lost_Details__c=leadRec.CC_Lost_Details__c;
            }
            else if(conStatusUpdate_Var=='EventCCSMM')
            {
                leadObj=new Lead(id=leadRec.Id);
                leadObj.CC_Lead_Status__c=leadRec.CC_Lead_Status__c;
                leadObj.CC_Recycle_Trash_Reason__c=leadRec.CC_Recycle_Trash_Reason__c;
                leadObj.CC_Recycle_Competitor_Name__c=leadRec.CC_Recycle_Competitor_Name__c;
                leadObj.CC_Lost_Details__c=leadRec.CC_Lost_Details__c;
                leadObj.Event_Lead_Status__c=leadRec.Event_Lead_Status__c;
                leadObj.Event_Recycle_Reason__c=leadRec.Event_Recycle_Reason__c;
                leadObj.Event_Recycle_Competitor_Name__c=leadRec.Event_Recycle_Competitor_Name__c;
                leadObj.Event_Lost_Details__c=leadRec.Event_Lost_Details__c;
                
                leadObj.SMM_Lead_Status__c=leadRec.SMM_Lead_Status__c;
                leadObj.SMM_Recycle_Trash_Reason__c=leadRec.SMM_Recycle_Trash_Reason__c;
                leadObj.SMM_Recycle_Competitor_Name__c=leadRec.SMM_Recycle_Competitor_Name__c;
                leadObj.SMM_Lost_Details__c=leadRec.SMM_Lost_Details__c;
            }
            else if(conStatusUpdate_Var=='SMM')
            {
                leadObj=new Lead(id=leadRec.Id);
                leadObj.SMM_Lead_Status__c=leadRec.SMM_Lead_Status__c;
                leadObj.SMM_Recycle_Trash_Reason__c=leadRec.SMM_Recycle_Trash_Reason__c;
                leadObj.SMM_Recycle_Competitor_Name__c=leadRec.SMM_Recycle_Competitor_Name__c;
                leadObj.SMM_Lost_Details__c=leadRec.SMM_Lost_Details__c;
            }
            else if(conStatusUpdate_Var=='CSNS')
            {
                leadObj=new Lead(id=leadRec.Id);
                leadObj.CSN_S_Lead_Status__c=leadRec.CSN_S_Lead_Status__c;
                leadObj.CSN_S_Recycle_Trash_Reason__c=leadRec.CSN_S_Recycle_Trash_Reason__c;
                leadObj.CSN_S_Recycle_Competitor_Name__c=leadRec.CSN_S_Recycle_Competitor_Name__c;
                leadObj.CSN_S_Lost_Details__c=leadRec.CSN_S_Lost_Details__c;
            }
            else if(conStatusUpdate_Var=='CSNP')
            {
                leadObj=new Lead(Id=leadRec.Id);
                leadObj.CSN_P_Lead_Status__c=leadRec.CSN_P_Lead_Status__c;
                leadObj.Sourcing_through__c=leadRec.Sourcing_through__c;
                leadObj.CSN_P_Recycle_Competitor_Name__c=leadRec.CSN_P_Recycle_Competitor_Name__c;
                leadObj.CSN_P_Lost_Details__c=leadRec.CSN_P_Lost_Details__c;
                leadObj.CSN_P_Status_Details__c=leadRec.CSN_P_Status_Details__c;
            }
            else if(conStatusUpdate_Var=='Survey')
            {
                leadObj=new lead(id=leadRec.Id);
                leadObj.Inquisium_Lead_Status__c=leadRec.Inquisium_Lead_Status__c;
                leadObj.Survey_Recycle_Reason__c=leadRec.Survey_Recycle_Reason__c;
                leadObj.Survey_Recycle_Competitor_Name__c=leadRec.Survey_Recycle_Competitor_Name__c;
                leadObj.Survey_Lost_Details__c=leadRec.Survey_Lost_Details__c;
            }
            try{
            update leadObj;
            }
            catch(Exception e){
                String errorSubstring = e.getMessage().SubStringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION, ');
                errorSubstring = errorSubstring .SubstringBefore(': []');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorSubstring));
                return null;
            }
        }
        PageReference contactDetailPage=new PageReference('/'+contactId);
        contactDetailPage.setRedirect(true);
        return contactDetailPage;
    }
    //Get current task RecordType Name
    private string taskRecordTypeName()
    {
        String taskQuery;
        System.debug('recordTypeId===>>>>>>>'+recordTypeId);
        System.debug('retUrlRecordId===>>>>>>>'+retUrlRecordId);
        System.debug('taskId===>>>>>>>'+taskId);
        
        if(retUrlRecordId!=null &&String.ValueOf(retUrlRecordId).length()>=15  && String.ValueOf(retUrlRecordId).substring(0,3)=='00T'){
            taskQuery='SELECT RecordTypeId,RecordType.DeveloperName,Subject,WhatId,WhoId FROM Task WHERE Id =';
            taskQuery=taskQuery+'\''+retUrlRecordId+'\'';
            sObject sTask=Database.query(taskQuery);
                Task taskObj=(Task)sTask;
                if(taskObj.WhatId!=null)
                    whatId=taskObj.WhatId;
                if(taskObj.WhoId!=null)
                    WhoId=taskObj.WhoId;
                if(taskObj.Subject!=null)
                    tsk5=EncodingUtil.urlEncode(taskObj.Subject,'UTF-8');
                recordTypeId=taskObj.RecordTypeId;
                recordTypeName=taskObj.RecordType.DeveloperName;
        }
        else if(taskId!=null && String.ValueOf(taskId).length()>=15 &&  String.ValueOf(taskId).substring(0,3)=='00T')
        {
            taskQuery='SELECT RecordTypeId,RecordType.DeveloperName,Subject,WhatId,WhoId FROM Task WHERE Id =';
            taskQuery=taskQuery+'\''+taskId+'\'';
            sObject sTask=Database.query(taskQuery);
                Task taskObj=(Task)sTask;
                if(taskObj.WhatId!=null)
                    whatId=taskObj.WhatId;
                if(taskObj.WhoId!=null)
                    WhoId=taskObj.WhoId;
                if(taskObj.Subject!=null)
                    //tsk5=taskObj.Subject;
                tsk5=EncodingUtil.urlEncode(taskObj.Subject,'UTF-8');
                recordTypeId=taskObj.RecordTypeId;
                recordTypeName=taskObj.RecordType.DeveloperName;
        }
        
        else if(recordTypeId != null && String.ValueOf(recordTypeId)!='')
        {
            String recordTypeQuery='SELECT Name,DeveloperName FROM RecordType WHERE Id ='+'\''+recordTypeId+'\'';
            System.debug('recordTypeQuery====>>>>'+recordTypeQuery);
            sObject sRecordType=Database.query(recordTypeQuery);
            RecordType rt=(RecordType)sRecordType;
            recordTypeName=rt.DeveloperName;
        }
        return recordTypeName;
    }

    /* 3/25/2016 : PK: Added for Cancel button override */
    public PageReference cancel(){
        String cancelUrl = '/';
        if(contactId != null){
            cancelUrl = cancelUrl + contactId;
        } else if(whatId != null){
            cancelUrl = cancelUrl + whatId;
        }
        PageReference pg = new PageReference(cancelUrl);
        pg.setRedirect(true);
        return pg;
        
    }
    
    private String statusclosedwoncheck(Id retUrlRecordId){
        if(retUrlRecordId != null){
            if(String.ValueOf(retUrlRecordId).substring(0,3)=='003'){
                Contact con =[SELECT Id,Event_Contact_Status__c,Survey_Contact_Status__c,CC_Contact_Status__c,CSN_P_Contact_Status__c,CSNS_Contact_Status__c,SMM_Contact_Status__c FROM Contact WHERE Id =: retUrlRecordId];
                //Inquisium Task Check
                if(recordTypeName=='Inquisium_Tasks')
                {
                    if(con.Survey_Contact_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //CC Task Check
                if(recordTypeName=='CC_Tasks')
                {
                    if(con.CC_Contact_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //PA Task Check
                if(recordTypeName=='PA_Tasks')
                {
                    if(con.CSN_P_Contact_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //SR_Tasks / CSN_Tasks Task Check
                if(recordTypeName=='CSN_Tasks' || recordTypeName=='SR_Tasks' )
                {
                    if(con.CSNS_Contact_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //Enterprise Task Check
                if(recordTypeName=='Enterprise')
                {
                    if(con.SMM_Contact_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //BizDev_Tasks Task Check
                if(recordTypeName=='BizDev_Tasks')
                {
                    if(con.Event_Contact_Status__c=='Closed Won' && con.CC_Contact_Status__c=='Closed Won' &&  con.SMM_Contact_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //TPP_Intl_Task OR Event_Tasks   ---> Event_Contact_Status__c/CC_Contact_Status__c/CSN_P_Contact_Status__c
                if(recordTypeName=='TPP_Intl_Task' || recordTypeName=='Event_Tasks')
                {
                    if(con.Event_Contact_Status__c=='Closed Won' && con.CC_Contact_Status__c=='Closed Won' &&  con.CSN_P_Contact_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
            }
            else if(String.ValueOf(retUrlRecordId).substring(0,3)=='00Q'){
                Lead leadObj =[SELECT Id,Event_Lead_Status__c,Survey_Lead_Status__c,CC_Lead_Status__c,CSN_P_Lead_Status__c,CSN_S_Lead_Status__c,SMM_Lead_Status__c FROM Lead WHERE Id =: retUrlRecordId];
                //Inquisium Task Check
                if(recordTypeName=='Inquisium_Tasks')
                {
                    if(leadObj.Survey_Lead_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //CC Task Check
                if(recordTypeName=='CC_Tasks')
                {
                    if(leadObj.CC_Lead_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //PA Task Check
                if(recordTypeName=='PA_Tasks')
                {
                    if(leadObj.CSN_P_Lead_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //SR_Tasks / CSN_Tasks Task Check
                if(recordTypeName=='CSN_Tasks' || recordTypeName=='SR_Tasks' )
                {
                    if(leadObj.CSN_S_Lead_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //Enterprise Task Check
                if(recordTypeName=='Enterprise')
                {
                    if(leadObj.SMM_Lead_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //BizDev_Tasks Task Check
                if(recordTypeName=='BizDev_Tasks')
                {
                    if(leadObj.Event_Lead_Status__c=='Closed Won' && leadObj.CC_Lead_Status__c=='Closed Won' &&  leadObj.SMM_Lead_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //TPP_Intl_Task OR Event_Tasks   ---> Event_Lead_Status__c/CC_Lead_Status__c/CSN_P_Lead_Status__c
                if(recordTypeName=='TPP_Intl_Task' || recordTypeName=='Event_Tasks')
                {
                    if(leadObj.Event_Lead_Status__c=='Closed Won' && leadObj.CC_Lead_Status__c=='Closed Won' &&  leadObj.CSN_P_Lead_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
            }
        }
        else
        {
            //Inquisium Task Check
             if(contactRec.Id!=null && String.ValueOf(contactRec.Id).substring(0,3)=='003'){
                if(recordTypeName=='Inquisium_Tasks')
                {
                    if(contactRec.Survey_Contact_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //CC Task Check
                if(recordTypeName=='CC_Tasks')
                {
                    if(contactRec.CC_Contact_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //PA Task Check
                if(recordTypeName=='PA_Tasks')
                {
                    if(contactRec.CSN_P_Contact_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //SR_Tasks / CSN_Tasks Task Check
                if(recordTypeName=='CSN_Tasks' || recordTypeName=='SR_Tasks' )
                {
                    if(contactRec.CSNS_Contact_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //Enterprise Task Check
                if(recordTypeName=='Enterprise')
                {
                    if(contactRec.SMM_Contact_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //BizDev_Tasks Task Check
                if(recordTypeName=='BizDev_Tasks')
                {
                    if(contactRec.Event_Contact_Status__c=='Closed Won' && contactRec.CC_Contact_Status__c=='Closed Won' &&  contactRec.SMM_Contact_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //TPP_Intl_Task OR Event_Tasks   ---> Event_Contact_Status__c/CC_Contact_Status__c/CSN_P_Contact_Status__c
                if(recordTypeName=='TPP_Intl_Task' || recordTypeName=='Event_Tasks')
                {
                    if(contactRec.Event_Contact_Status__c=='Closed Won' && contactRec.CC_Contact_Status__c=='Closed Won' &&  contactRec.CSN_P_Contact_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
             }
             else if(leadRec.Id!=null && String.ValueOf(leadRec.Id).substring(0,3)=='00Q')//For Lead Process)
             {
                                 if(recordTypeName=='Inquisium_Tasks')
                {
                    if(leadRec.Survey_Lead_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //CC Task Check
                if(recordTypeName=='CC_Tasks')
                {
                    if(leadRec.CC_Lead_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //PA Task Check
                if(recordTypeName=='PA_Tasks')
                {
                    if(leadRec.CSN_P_Lead_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //SR_Tasks / CSN_Tasks Task Check
                if(recordTypeName=='CSN_Tasks' || recordTypeName=='SR_Tasks' )
                {
                    if(leadRec.CSN_S_Lead_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //Enterprise Task Check
                if(recordTypeName=='Enterprise')
                {
                    if(leadRec.SMM_Lead_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //BizDev_Tasks Task Check
                if(recordTypeName=='BizDev_Tasks')
                {
                    if(leadRec.Event_Lead_Status__c=='Closed Won' && leadRec.CC_Lead_Status__c=='Closed Won' &&  leadRec.SMM_Lead_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
                //TPP_Intl_Task OR Event_Tasks   ---> Event_Lead_Status__c/CC_Lead_Status__c/CSN_P_Lead_Status__c
                if(recordTypeName=='TPP_Intl_Task' || recordTypeName=='Event_Tasks')
                {
                    if(leadRec.Event_Lead_Status__c=='Closed Won' && leadRec.CC_Lead_Status__c=='Closed Won' &&  leadRec.CSN_P_Lead_Status__c=='Closed Won')
                    checkStatusClosedWon='ClosedWon';
                    else
                    checkStatusClosedWon='NOT';
                }
             }
        }
        
        return checkStatusClosedWon;
    }
    

}