/**@author Hemant Rana
Batch Class for the Updation of ContactStatus and Contact Owner field whenever a new task is created.
Version 1.0
Date: 01th July 2016
*/
global class DWFContactStatusOwnerBatch implements Database.Batchable<sObject>,Database.Stateful{
    Integer contactSize;
    Integer taskSize;
    Boolean isError;
    /*......................Initializing Maps for the Custom Setting...........................................*/
    Map<String,DWR_Role_ContactStatus__c> roleVsContactStatusField_Map=new Map<String,DWR_Role_ContactStatus__c>();
    Map<String,DWF_SubjectLine_Vs_DWStatus__c> subjectVsDWFStatus_Map=new Map<String,DWF_SubjectLine_Vs_DWStatus__c>();
    Map<String,DWF_Contact_Status_Order__c> statusVsOrder_Map=new Map<String,DWF_Contact_Status_Order__c>();
    Map<String,DWF_Product_Vs_Status_Vs_Owner_Field__c> productVsContactStatusOwnerField_Map=new Map<String,DWF_Product_Vs_Status_Vs_Owner_Field__c>();
    /*......................Ends Here...........................................*/
    /* Custom object initialization where status and id of batch job will be saved*/
    DWF_Batch_Execution__c DWFBatchExecutionObj;
    /*.............................ENDS HERE......................................*/
    global DWFContactStatusOwnerBatch()
    {  
        isError = false;
        contactSize=0;
        taskSize=0;
        /*...........Putting Custom Setting value inside the Map....*/
        statusVsOrder_Map=DWF_Contact_Status_Order__c.getAll();
        roleVsContactStatusField_Map=DWR_Role_ContactStatus__c.getAll();
        productVsContactStatusOwnerField_Map=DWF_Product_Vs_Status_Vs_Owner_Field__c.getAll();
        subjectVsDWFStatus_Map=DWF_SubjectLine_Vs_DWStatus__c.getAll();
        
        /* Inserting record in the custom object "DWF_Batch_Execution__c"*/
        DWFBatchExecutionObj=new DWF_Batch_Execution__c();
        DWFBatchExecutionObj.Batch_Status__c='New';
        insert DWFBatchExecutionObj;
        /*...................ENDS HERE.....................*/
    }
    global Database.querylocator start(Database.BatchableContext BC){
        String Query = 'SELECT Id,Task_Assigned_Role__c,Status,Product__c,WhoId,Subject,Owner.Name FROM Task WHERE IsDWFBatchProcessed_Dev__c=TRUE ORDER BY LastModifiedDate ASC';
        System.debug('query===>'+query); 
        if(DWFBatchExecutionObj!=null){
            DWF_Batch_Execution__c DWFBatchExecutionStatusObj=new DWF_Batch_Execution__c(Id=DWFBatchExecutionObj.Id,Batch_Status__c='InProgress',Batch_Start_Date_Time__c=system.now(),Batch_Id__c=BC.getJobId());
            update DWFBatchExecutionStatusObj;
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Task> scope){
        Map<Id,List<Task>> contactIdVsTaskList=new Map<Id,List<Task>>();
        List<Task> taskList=new List<Task>();
        List<Task> taskIsDWFBatchUpdateList=new List<Task>();//List to add the task records for which the checkbox should be updated to false
        List<Contact> conUpdateList=new List<Contact>();
        Integer taskCount=0;
        For(Task taskObj : scope)
        {
            if(taskObj.Subject!=null && ((taskObj.Task_Assigned_Role__c=='Pre Sales - Special Projects' && taskObj.Status=='Completed') || (taskObj.Task_Assigned_Role__c!='Pre Sales - Special Projects')))
            {   
                taskObj.put('IsDWFBatchProcessed_Dev__c',FALSE);
                taskIsDWFBatchUpdateList.add(taskObj);
                if(taskObj.WhoId!=null && String.ValueOf(taskObj.WhoId).startsWith('003')){
                    if(!contactIdVsTaskList.containsKey(taskObj.WhoId)){
                        taskList=new List<Task>();
                        taskList.add(taskObj);
                        contactIdVsTaskList.put(taskObj.WhoId,taskList);
                    }
                    else
                    {
                        contactIdVsTaskList.get(taskObj.WhoId).add(taskObj);
                    }
                    taskCount=taskCount+1;
                }
            }
        }
        if(taskIsDWFBatchUpdateList.size()>0)
            Database.SaveResult[] srList = Database.update(taskIsDWFBatchUpdateList, false);
        For(Contact conObj : [SELECT Id,Contact_Owner_for_PA__c,Event_Contact_Status__c,CSNS_Contact_Status__c,SMM_Contact_Status__c,CSN_P_Contact_Status__c,Survey_Contact_Status__c,CC_Contact_Status__c,Contact_Owner_for_CrowdCompass__c,Contact_Owner_for_CSN_S__c,Contact_Owner_for_Event__c,Contact_Owner_for_Survey__c,Contact_Owner_for_SMM__c FROM Contact WHERE Id IN : contactIdVsTaskList.keySet()])
        {
            For(Task taskObj : contactIdVsTaskList.get(conObj.Id))
            {
                if(roleVsContactStatusField_Map.containsKey(taskOBj.Task_Assigned_Role__c)){
                    String contactStatusFieldAPI=roleVsContactStatusField_Map.get(taskOBj.Task_Assigned_Role__c).Contact_Status_Field__c;
                    String statusValue=String.ValueOf(conObj.get(contactStatusFieldAPI));
                    String contactOwnerFieldAPI=roleVsContactStatusField_Map.get(taskOBj.Task_Assigned_Role__c).Contact_Owner_Field__c;
                    For(String subjectString : subjectVsDWFStatus_Map.keySet())
                    {
                        if(taskObj.subject.contains(subjectString) && contactStatusFieldAPI!=null){
                            
                            
                            
                            if(statusValue==null || (statusValue!=null && !statusVsOrder_Map.containsKey(statusValue)) ||(statusValue!=null && statusVsOrder_Map.containsKey(statusValue) && 
                            subjectVsDWFStatus_Map.containsKey(subjectString) && statusVsOrder_Map.containsKey(subjectVsDWFStatus_Map.get(subjectString).DW_Status__c) &&
                            (statusVsOrder_Map.get(subjectVsDWFStatus_Map.get(subjectString).DW_Status__c).Order__c >= statusVsOrder_Map.get(statusValue).Order__c))){

                            
                                if(contactStatusFieldAPI=='Event_Contact_Status__c' && (taskObj.subject.contains(' OD-CC') || taskObj.subject.contains(' PS-CC') || taskObj.subject.contains(' CC_') || taskObj.subject.contains(' CrowdCompass')))
                                {
                                    conObj.put('CC_Contact_Status__c',subjectVsDWFStatus_Map.get(subjectString).DW_Status__c);
                                    conObj.put('Contact_Owner_for_CrowdCompass__c',taskObj.Owner.Name);
                                }
                                else{
                                    conObj.put(contactStatusFieldAPI,subjectVsDWFStatus_Map.get(subjectString).DW_Status__c);
                                    if(contactOwnerFieldAPI!=null)
                                        conObj.put(contactOwnerFieldAPI,taskObj.Owner.Name); 
                                }
                                
                                
                                
                            }
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                        }
                    }
                }
                //The below else block will work for the Task assigned to the IST User......................
                                    
                    
                    else if(taskOBj.Task_Assigned_Role__c=='Pre Sales - Special Projects' && taskOBj.Product__c!=null){
                        if(taskOBj.Product__c.split(';').size()>1)
                        {
                            For(String productName : taskOBj.Product__c.split(';'))
                            {
                                if(productVsContactStatusOwnerField_Map.containsKey(productName)){
                                    String contactStatusFieldAPI=productVsContactStatusOwnerField_Map.get(productName).Contact_Status_Field__c;
                                    String statusValue=String.ValueOf(conObj.get(contactStatusFieldAPI));
                                    String contactOwnerFieldAPI=productVsContactStatusOwnerField_Map.get(productName).Contact_Owner_Field__c;
                                    For(String subjectString : subjectVsDWFStatus_Map.keySet())
                                    {
                                        if(taskObj.subject.contains(subjectString) && contactStatusFieldAPI!=null){
                                                                        if(statusValue==null || (statusValue!=null && !statusVsOrder_Map.containsKey(statusValue)) ||(statusValue!=null && statusVsOrder_Map.containsKey(statusValue) && 
                            
                            
                            subjectVsDWFStatus_Map.containsKey(subjectString) && statusVsOrder_Map.containsKey(subjectVsDWFStatus_Map.get(subjectString).DW_Status__c) &&
                            
                            (statusVsOrder_Map.get(subjectVsDWFStatus_Map.get(subjectString).DW_Status__c).Order__c >= statusVsOrder_Map.get(statusValue).Order__c))){ 
                                                if(contactStatusFieldAPI=='Event_Contact_Status__c' && (taskObj.subject.contains(' OD-CC') || taskObj.subject.contains(' PS-CC') || taskObj.subject.contains(' CC_') || taskObj.subject.contains(' CrowdCompass')))
                                                {
                                                    conObj.put('CC_Contact_Status__c',subjectVsDWFStatus_Map.get(subjectString).DW_Status__c);
                                                    conObj.put('Contact_Owner_for_CrowdCompass__c',taskObj.Owner.Name);
                                                }
                                                else{
                                                    conObj.put(contactStatusFieldAPI,subjectVsDWFStatus_Map.get(subjectString).DW_Status__c);
                                                    if(contactOwnerFieldAPI!=null)
                                                        conObj.put(contactOwnerFieldAPI,taskObj.Owner.Name); 
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else{
                            String productName = taskOBj.Product__c;
                            if(productVsContactStatusOwnerField_Map.containsKey(productName)){
                                String contactStatusFieldAPI=productVsContactStatusOwnerField_Map.get(productName).Contact_Status_Field__c;
                                String statusValue=String.ValueOf(conObj.get(contactStatusFieldAPI));
                                String contactOwnerFieldAPI=productVsContactStatusOwnerField_Map.get(productName).Contact_Owner_Field__c;
                                For(String subjectString : subjectVsDWFStatus_Map.keySet())
                                {
                                    if(taskObj.subject.contains(subjectString) && contactStatusFieldAPI!=null){
                                                                    if(statusValue==null || (statusValue!=null && !statusVsOrder_Map.containsKey(statusValue)) ||(statusValue!=null && statusVsOrder_Map.containsKey(statusValue) && 
                            
                            
                            subjectVsDWFStatus_Map.containsKey(subjectString) && statusVsOrder_Map.containsKey(subjectVsDWFStatus_Map.get(subjectString).DW_Status__c) &&
                            
                            (statusVsOrder_Map.get(subjectVsDWFStatus_Map.get(subjectString).DW_Status__c).Order__c >= statusVsOrder_Map.get(statusValue).Order__c))){ 
                                            if(contactStatusFieldAPI=='Event_Contact_Status__c' && (taskObj.subject.contains(' OD-CC') || taskObj.subject.contains(' PS-CC') || taskObj.subject.contains(' CC_') || taskObj.subject.contains(' CrowdCompass')))
                                            {
                                                conObj.put('CC_Contact_Status__c',subjectVsDWFStatus_Map.get(subjectString).DW_Status__c);
                                                conObj.put('Contact_Owner_for_CrowdCompass__c',taskObj.Owner.Name);
                                            }
                                            else{
                                                conObj.put(contactStatusFieldAPI,subjectVsDWFStatus_Map.get(subjectString).DW_Status__c);
                                                if(contactOwnerFieldAPI!=null)
                                                    conObj.put(contactOwnerFieldAPI,taskObj.Owner.Name); 
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
            }
            conUpdateList.add(conObj);
        }
        System.debug('conUpdateList*********************'+conUpdateList);
        if(conUpdateList.size()>0){
            Database.SaveResult[] srConList = Database.update(conUpdateList, false);
            if(!isError){
                For(Integer i=0;i<srConList.size();i++){
                    if(!srConList.get(i).isSuccess())
                    {
                        isError = True;
                        break;
                    }
                }
            }
        }
        contactSize=contactSize+conUpdateList.size();
        taskSize=taskSize+taskCount;
    }
    global void finish(Database.BatchableContext BC){
        
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedBy.Name , ExtendedStatus  from AsyncApexJob where Id = :BC.getJobId()]; 
        
        /*When called from the Scheduler Class */
        if(DWFBatchExecutionObj!=null){
            DWF_Batch_Execution__c DWFBatchExecutionStatusObj=new DWF_Batch_Execution__c(Id=DWFBatchExecutionObj.Id);
            DWFBatchExecutionStatusObj.Batch_Status__c='Completed';
            DWFBatchExecutionStatusObj.Batch_End_Date_Time__c=system.now();
            DWFBatchExecutionStatusObj.No_of_Contact_Processed__c=contactSize;
            DWFBatchExecutionStatusObj.No_of_Task_Processed__c=taskSize;
            update DWFBatchExecutionStatusObj;
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        String[] toAddresses = new String[] {Label.DWF_User_Email_ID};// {a.CreatedBy.Email};  
        mail.setToAddresses(toAddresses); 
        String body;
        if(!isError){       
            mail.setSubject('DWF BatchJob Status: ' + a.Status);  
            //mail.setPlainTextBody('The batch Apex job processed ' + a.JobItemsProcessed);
            body='<span style='+'\''+'color:#1F497D; font-size:11.0pt;font-family:"Calibri",sans-serif;'+'\''+'><b>Hi '+a.CreatedBy.Name+',  </b></br></br>The request submitted by you to update the Contact Status and Contact Product Owner is being completed.</br></br><b>Total Batch Processed:</b> '+a.JobItemsProcessed+'</span></br><span style='+'\''+'font-size:11.0pt;font-family:"Calibri",sans-serif;color:#000000'+'\''+'><b>Thanks,</br>'+'Salesforce'+'<o:p></o:p></b></span>';
        }
        else{
            mail.setSubject('DWF BatchJob Status Failed');  
            //mail.setPlainTextBody('The batch Apex job processed ' + a.JobItemsProcessed);
            body='<span style='+'\''+'color:#1F497D; font-size:11.0pt;font-family:"Calibri",sans-serif;'+'\''+'><b>Hi '+a.CreatedBy.Name+',  </b></br></br>The request submitted by you to update the Contact Status and Contact Product Owner is Failed.</br></br><b>Total Batch Processed:</b> '+a.JobItemsProcessed+'</span></br><span style='+'\''+'font-size:11.0pt;font-family:"Calibri",sans-serif;color:#000000'+'\''+'><b>Thanks,</br>'+'Salesforce'+'<o:p></o:p></b></span>';
        }
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        /*
        Send an email notification about Batch Completion.
        */
    }
}