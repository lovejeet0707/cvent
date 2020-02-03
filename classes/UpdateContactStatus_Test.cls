/* Suspect Class for the "UpdateContactStatus_Task_Controller" and "UpdateContactStatus_Event_Controller" Class*/
@isTest
private class UpdateContactStatus_Test{
    //private Static RecordType rtType_Event=[SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true]
    private static Opportunity oppObj;
    private static User u;
    private static Account acc;
    
    static Map<String,Schema.RecordTypeInfo> getEventRecordType(){
        Schema.DescribeSObjectResult eventSchema = Schema.SObjectType.Event; 
        Map<String,Schema.RecordTypeInfo> EventRecordTypeInfo = eventSchema.getRecordTypeInfosByName();
        return EventRecordTypeInfo;
    }
    
    static Id insertUser(integer i){
        //Inserting User
        If(u == null){
            Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
            u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                         LocaleSidKey='en_US', ProfileId = p.Id, 
                         TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com'+i);
            insert u;    
        }        
        return u.Id;
    }
    
    static Map<String,Schema.RecordTypeInfo> getTaskRecordType(){
        Schema.DescribeSObjectResult taskSchema = Schema.SObjectType.Task; 
        Map<String,Schema.RecordTypeInfo> TaskRecordTypeInfo = taskSchema.getRecordTypeInfosByName();
        return TaskRecordTypeInfo;
    }
    
    static Id insertAccount(){
        if(acc == null){
            acc = new Account();
            acc.Name='Suspect';
            insert acc; 
        }        
        return acc.Id;
    }
    static Id insertOpportunity(){
        if(oppObj == null){
            RecordType recrdType = [SELECT Id,SobjectType, DeveloperName, IsActive FROM RecordType WHERE SobjectType='Opportunity' AND IsActive=true AND DeveloperName='Event'];
            oppObj = new Opportunity();
            oppObj.RecordTypeId=recrdType.Id;
            oppObj.Name='Suspect Oppty';
            oppObj.Product__c='Event';
            oppObj.StageName='Legal';
            oppObj.AccountId=insertAccount();
            oppObj.CloseDate=system.today();
            oppObj.Parent_Upsell__c='Primary';
            oppObj.License_Type__c='Enterprise';
            oppObj.New_Amount__c=100;
            oppObj.Years__c='1';
            oppObj.Contact_Associated__c=insertContact('Suspect','Suspect','Suspect','Suspect','Suspect','Suspect').Id;
            oppObj.Contact_Role__c='Other User';
            insert oppObj;    
        }        
        return oppObj.Id;
    }
    static Contact insertContact(String eventStatus,String CCStatus,String CSNStatus,String SMMStatus, String inquisiumStatus,String CSNPStatus)
    {
        Contact con=new Contact();
        con.LastName='Suspect';
        con.Product_Desired__c='CSN';
        con.Event_Contact_Status__c=eventStatus;
        con.CC_Contact_Status__c=CCStatus;
        con.CSNS_Contact_Status__c=CSNStatus;
        con.CSN_P_Contact_Status__c=CSNPStatus;
        con.Survey_Contact_Status__c=inquisiumStatus;
        con.SMM_Contact_Status__c=SMMStatus;
        con.AccountId=insertAccount();
        
        con.Types_of_Surveys_Eloqua__c ='Suspect';
        con.of_Employees_in_Organisation_del__c ='Suspect';
        con.of_Events_CC__c ='Suspect';
        con.of_Exhibitors_CC__c ='Suspect';
        con.of_Attendees_Eloqua__c ='Suspect';
        con.Type_of_Events__c ='Suspect';
        con.ChargeFeeforEvents__c ='Suspect';
        con.Ever_Used_Mobile_App_CC__c ='Suspect';
        con.Have_Breakouts_CC__c ='Suspect';
        con.Why_are_you_looking_for_a_survey_tool__c ='Suspect';
        
        insert con;
        return con;
    }
    static Lead insertLead(String eventStatus,String CCStatus,String CSNStatus,String SMMStatus, String inquisiumStatus,String CSNPStatus)
    {
        Lead led=new Lead();
        led.LastName='Suspect';
        led.Product_Desired__c='CSN';
        led.Event_Lead_Status__c=eventStatus;
        led.CC_Lead_Status__c=CCStatus;
        led.CSN_S_Lead_Status__c=CSNStatus;
        led.SMM_Lead_Status__c=SMMStatus;
        led.CSN_P_Lead_Status__c=CSNPStatus;
        led.Lead_Status_Reason_Survey__c=inquisiumStatus;
        
        led.Types_of_Surveys_Eloqua__c ='Suspect';
        led.of_Employees_in_Organisation__c ='Suspect';
        led.of_Events_CC__c ='Suspect';
        led.of_Exhibitors_CC__c ='Suspect';
        led.of_Attendees_Eloqua__c ='Suspect';
        led.Type_of_Events__c ='Suspect';
        led.Charge_Fee_for_Events__c ='Suspect';
        led.Ever_Used_Mobile_App_CC__c ='Suspect';
        led.Have_Breakouts_CC__c ='Suspect';
        led.Why_are_you_looking_for_a_survey_tool__c ='Suspect';
        
        insert led;
        return led;
    }
    
    static Task insertTask(String recordTypeName,Integer i,String eventStatus,String CCStatus,String CSNStatus,String SMMStatus, String inquisiumStatus,String CSNPStatus, String ObjName)
    {
        Task taskObj=new Task();
        Map<String,Id> rtNameVsId_Map=new Map<String,Id>();
        for(RecordType rtType_Task : [SELECT Id,SobjectType, DeveloperName, IsActive FROM RecordType WHERE SobjectType='Task' And IsActive=true]){
            rtNameVsId_Map.put(rtType_Task.DeveloperName,rtType_Task.Id);
        }
        if(ObjName == 'Contact'){
            Id contactId = insertContact(eventStatus,CCStatus,CSNStatus,SMMStatus,inquisiumStatus,CSNPStatus).Id;
            taskObj.WhoId=contactId;}
        else{
            Id leadId = insertLead(eventStatus,CCStatus,CSNStatus,SMMStatus,inquisiumStatus,CSNPStatus).Id;
            taskObj.WhoId=leadID;
        }
        if(rtNameVsId_Map.keySet().contains(recordTypeName))
            taskObj.RecordTypeId=rtNameVsId_Map.get(recordTypeName);//getTaskRecordType().get(recordTypeName).getRecordTypeId();
        taskObj.OwnerId=insertUser(i);
        taskObj.Subject='Build Task';
        taskObj.ActivityDate=system.today();
        taskObj.Priority='Low';
        taskObj.Minutes_on_tasks__c=0;
        taskObj.Status='Completed';
        insert taskObj;
        return taskObj;
    }
    static Event insertEvent(String recordTypeName,Integer i,String eventStatus,String CCStatus,String CSNStatus,String SMMStatus, String inquisiumStatus,String CSNPStatus, String ObjName)
    {
        Event eventObj=new Event();
        Map<String,Id> rtNameVsId_Map = new Map<String,Id>();
        for(RecordType rtType_Task : [SELECT Id,SobjectType, DeveloperName, IsActive FROM RecordType WHERE SobjectType='Event' And IsActive=true]){
            rtNameVsId_Map.put(rtType_Task.DeveloperName,rtType_Task.Id);
        }
        if(ObjName=='Contact'){
            Id contactId = insertContact(eventStatus,CCStatus,CSNStatus,SMMStatus,inquisiumStatus,CSNPStatus).Id;
            eventObj.WhoId=contactId;}
        else if(ObjName=='Lead'){
            Id leadId = insertLead(eventStatus,CCStatus,CSNStatus,SMMStatus,inquisiumStatus,CSNPStatus).Id;
            eventObj.WhoId=leadID;
        }
        if(rtNameVsId_Map.keySet().contains(recordTypeName))
            eventObj.RecordTypeId=rtNameVsId_Map.get(recordTypeName);//getTaskRecordType().get(recordTypeName).getRecordTypeId();
        eventObj.OwnerId=insertUser(i);
        eventObj.Subject='Build Task';
        eventObj.StartDateTime=system.now();
        eventObj.EndDateTime=system.now();
        eventObj.Source__c='Low';
        //eventObj.Minutes_on_tasks__c=0;
        //eventObj.Status='Completed';
        insert eventObj;
        return eventObj;
    }
    /*Task Insertion*/
    //-----------------Task Insertion Fro Lead and Suspect
    static testMethod void testLead_Task_Biz_None()
    {
        Test.startTest();
        Task taskObj=insertTask('BizDev_Tasks',10,'Closed Won','Closed Won','Suspect','Closed Won','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj);
        
        Test.stopTest();
    }
    static testMethod void testLead_Task_Biz_EventCCSMM()
    {
        Test.startTest();
        Task taskObj=insertTask('BizDev_Tasks',10,'Suspect','Suspect','Suspect','Suspect','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj);
        
        Test.stopTest();
    }
    static testMethod void testLead_Task_Biz_SMM()
    {
        Test.startTest();
        Task taskObj=insertTask('BizDev_Tasks',10,'Closed Won','Closed Won','Suspect','Suspect','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj);
        
        Test.stopTest();
    }
    static testMethod void testLead_Task_Biz_CC()
    {
        Test.startTest();
        Task taskObj=insertTask('BizDev_Tasks',10,'Closed Won','Suspect','Suspect','Closed Won','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj);
        
        Test.stopTest();
    }
    static testMethod void testLead_Task_Biz_Event()
    {
        Test.startTest();
        Task taskObj=insertTask('BizDev_Tasks',10,'Suspect','Closed Won','Suspect','Closed Won','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj);
        
        Test.stopTest();
    }
    static testMethod void testLead_Task_Biz_CCSMM()
    {
        Test.startTest();
        Task taskObj=insertTask('BizDev_Tasks',10,'Closed Won','Suspect','Suspect','Suspect','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj);
        
        Test.stopTest();
    }
    static testMethod void testLead_Task_Biz_EventSMM()
    {
        Test.startTest();
        Task taskObj=insertTask('BizDev_Tasks',10,'Suspect','Closed Won','Suspect','Suspect','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj);
        
        Test.stopTest();
    }
    static testMethod void testLead_Task_Biz_EventCC()
    {
        Test.startTest();
        Task taskObj=insertTask('BizDev_Tasks',10,'Suspect','Suspect','Suspect','Closed Won','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj);
        
        Test.stopTest();
    }
    static testMethod void testLead_Enterprise(){
        Test.startTest();
        Task taskObj = insertTask('Enterprise',10,'Suspect','Suspect','Suspect','Closed Won','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj);
        Task taskObj1 = insertTask('Enterprise',10,'Suspect','Suspect','Suspect','Suspect','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj1);
        Test.stopTest();
    }
    /*============Event_Tasks RecordType Tasks===============*/
    //String eventStatus,String CCStatus,String CSNStatus,String SMMStatus, String inquisiumStatus,String CSNPStatus
    static testMethod void testLead_Event_Tasks_None_EventCCCSN_CSN(){
        Test.startTest();
        //Event_Tasks_None
        Task taskObj1 = insertTask('Event_Tasks',0,'Closed Won','Closed Won','Suspect','Suspect','Suspect','Closed Won','Lead');
        myUnitTestTask_All(taskObj1);
        //Event_Tasks_EventCCCSN
        Task taskObj2 = insertTask('Event_Tasks',0,'Suspect','Suspect','Suspect','Suspect','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj2);
        //Event_Tasks_CSN
        Task taskObj3 = insertTask('Event_Tasks',0,'Closed Won','Closed Won','Suspect','Suspect','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj3);
        Test.stopTest();
    }     
    static testMethod void testLead_Event_Tasks_CC_Event_CCCSN(){
        Test.startTest();    
        //Event_Tasks_CC
        Task taskObj4 = insertTask('Event_Tasks',0,'Closed Won','Suspect','Suspect','Suspect','Suspect','Closed Won','Lead');
        myUnitTestTask_All(taskObj4);
        //Event_Tasks_Event
        Task taskObj5 = insertTask('Event_Tasks',0,'Closed Won','Suspect','Suspect','Suspect','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj5);
        //Event_Tasks_CCCSN
        Task taskObj6 = insertTask('Event_Tasks',0,'Suspect','Closed Won','Suspect','Suspect','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj6);
      Test.stopTest();
    }    
    static testMethod void testLead_Event_Tasks_EventCSN_EventCC(){
        Test.startTest();
        //Event_Tasks_EventCSN
        Task taskObj7 = insertTask('Event_Tasks',0,'Suspect','Closed Won','Suspect','Suspect','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj7);    
        //Event_Tasks_EventCC
        Task taskObj8 = insertTask('Event_Tasks',0,'Suspect','Suspect','Suspect','Suspect','Suspect','Closed Won','Lead');
        myUnitTestTask_All(taskObj8);
        Test.stopTest();
    }    
    
    static testMethod void testLead_Task_CSN_None(){
        Test.startTest();
        Task taskObj=insertTask('CSN_Tasks',10,'Suspect','Suspect','Closed Won','Suspect','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj);
        
        Test.stopTest();
    }
    static testMethod void testLead_Task_CSN_CSNS(){
        Test.startTest();
        Task taskObj=insertTask('CSN_Tasks',10,'Suspect','Suspect','Suspect','Suspect','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj);
        
        Test.stopTest();
    }
    static testMethod void testLead_Task_PA_None()
    {
        Test.startTest();
        Task taskObj=insertTask('PA_Tasks',10,'Suspect','Suspect','Suspect','Suspect','Suspect','Closed Won','Lead');
        myUnitTestTask_All(taskObj);
        
        Test.stopTest();
    }
    static testMethod void testLead_Task_PA_CSNP()
    {
        Test.startTest();
        Task taskObj=insertTask('PA_Tasks',10,'Suspect','Suspect','Suspect','Suspect','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj);
        
        Test.stopTest();
    }
    static testMethod void testLead_Task_CC_None()
    {
        Test.startTest();
        Task taskObj=insertTask('CC_Tasks',10,'Suspect','Closed Won','Suspect','Suspect','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj);
        
        Test.stopTest();
    }
    static testMethod void testLead_Task_CC_CC()
    {
        Test.startTest();
        Task taskObj=insertTask('CC_Tasks',10,'Suspect','Suspect','Suspect','Suspect','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj);
        
        Test.stopTest();
    }
    static testMethod void testLead_Task_Inquisium_None()
    {
        Test.startTest();
        Task taskObj=insertTask('Inquisium_Tasks',10,'Suspect','Suspect','Suspect','Suspect','Closed Won','Suspect','Lead');
        myUnitTestTask_All(taskObj);
        
        Test.stopTest();
    }
    static testMethod void testLead_Task_Inquisium_Survey()
    {
        Test.startTest();
        Task taskObj=insertTask('Inquisium_Tasks',10,'Suspect','Suspect','Suspect','Suspect','Suspect','Suspect','Lead');
        myUnitTestTask_All(taskObj);
        
        Test.stopTest();
    }
    //eventStatus,CCStatus,CSNStatus,SMMStatus,inquisiumStatus,CSNPStatus
    //-----------------------Ends Here-------------------
    
    //-----------Task Insertion For Contact----------  
    /*============BizDev_Tasks RecordType Tasks===============*/
    static testMethod void test_Task_Biz_None(){
        Test.startTest();
        //BizDev_Tasks_None
        Task taskObj = insertTask('BizDev_Tasks',0,'Closed Won','Closed Won','Suspect','Closed Won','Suspect','','Contact');
        myUnitTestTask_All(taskObj);
        Test.stopTest();
    }
    
    static testMethod void test_Task_Biz_EventCCSMM(){    
        Test.startTest();
        //BizDev_Tasks_EventCCSMM
        Task taskObj = insertTask('BizDev_Tasks',0,'Suspect','Suspect','Suspect','Suspect','Suspect','','Contact');
        myUnitTestTask_All(taskObj);
        Test.stopTest();
    }
    static testMethod void test_Task_Biz_SMM(){    
        Test.startTest();
        //BizDev_Tasks_SMM
        Task taskObj =insertTask('BizDev_Tasks',0,'Closed Won','Closed Won','Suspect','Suspect','Suspect','','Contact');
        myUnitTestTask_All(taskObj);
        Test.stopTest();
    }
    static testMethod void test_Task_Biz_CC(){    
        Test.startTest();
        //BizDev_Tasks_CC
        Task taskObj = insertTask('BizDev_Tasks',0,'Closed Won','Suspect','Suspect','Closed Won','Suspect','','Contact');
        myUnitTestTask_All(taskObj);
        Test.stopTest();
    }    
    static testMethod void test_Task_Biz_Event(){    
        Test.startTest();    
        //BizDev_Tasks_Event
        Task taskObj =insertTask('BizDev_Tasks',0,'Suspect','Closed Won','Suspect','Closed Won','Suspect','','Contact');
        myUnitTestTask_All(taskObj);
        Test.stopTest();
    }    
    static testMethod void test_Task_Biz_CCSMM(){    
        Test.startTest();   
        //BizDev_Tasks_CCSMM
        Task taskObj = insertTask('BizDev_Tasks',0,'Closed Won','Suspect','Suspect','Suspect','Suspect','','Contact');
        myUnitTestTask_All(taskObj);
        Test.stopTest();
    }     
    static testMethod void test_Task_Biz_EventSMM(){    
        Test.startTest(); 
        //BizDev_Tasks_EventSMM
        Task taskObj1 = insertTask('BizDev_Tasks',0,'Suspect','Closed Won','Suspect','Suspect','Suspect','','Contact');
        myUnitTestTask_All(taskObj1);
        //BizDev_Tasks_EventCC
        Task taskObj2 = insertTask('BizDev_Tasks',0,'Suspect','Suspect','Suspect','Closed Won','Suspect','','Contact');
        myUnitTestTask_All(taskObj2);
        Test.stopTest();
    } 
    
    /*============Enterprise RecordType Tasks===============*/
    static testMethod void test_Task_Enterprise_None_and_SMMEnterpriseEvent(){
        Test.startTest();
        //Enterprise_None
        Task taskObj1 = insertTask('Enterprise',0,'Closed Won','Closed Won','Suspect','Suspect','Suspect','','Contact');
        myUnitTestTask_All(taskObj1);
        //Enterprise_SMMEnterpriseEvent
        Task taskObj2 = insertTask('Enterprise',0,'Suspect','Closed Won','Suspect','Suspect','Suspect','','Contact');
        myUnitTestTask_All(taskObj2);
        Test.stopTest();
    }   
    static testMethod void test_Task_SMMEnterpriseEvent_and_SMMEnterpriseCC(){
        Test.startTest();    
        //Enterprise_SMMEnterpriseEvent
        Task taskObj2 = insertTask('Enterprise',0,'Suspect','Closed Won','Suspect','Suspect','Suspect','','Contact');
        myUnitTestTask_All(taskObj2);
        //Enterprise_SMMEnterpriseCC
        Task taskObj3 = insertTask('Enterprise',0,'Closed Won','Suspect','Suspect','Suspect','Suspect','','Contact');
        myUnitTestTask_All(taskObj3);
        //Enterprise_SMMEnterpriseEveCC
        Task taskObj4 = insertTask('Enterprise',0,'Suspect','Suspect','Suspect','Suspect','Suspect','','Contact');
        myUnitTestTask_All(taskObj4);
        Test.stopTest();
    }  
    
    /*============Event_Tasks RecordType Tasks===============*/
    static testMethod void test_Task_Event_Tasks_None_EventCCCSN_CSN(){
        Test.startTest();
        //Event_Tasks_None
        Task taskObj1 = insertTask('Event_Tasks',0,'Closed Won','Closed Won','Suspect','Suspect','Closed Won','','Contact');
        myUnitTestTask_All(taskObj1);
        //Event_Tasks_EventCCCSN
        Task taskObj2 = insertTask('Event_Tasks',0,'Suspect','Suspect','Suspect','Suspect','Suspect','','Contact');
        myUnitTestTask_All(taskObj2);
        //Event_Tasks_CSN
        Task taskObj3 = insertTask('Event_Tasks',0,'Closed Won','Closed Won','Suspect','Suspect','Suspect','','Contact');
        myUnitTestTask_All(taskObj3);
        Test.stopTest();
    }     
    static testMethod void test_Task_Event_Tasks_CC_Event_CCCSN(){
        Test.startTest();    
        //Event_Tasks_CC
        Task taskObj4 = insertTask('Event_Tasks',0,'Closed Won','Suspect','Suspect','Suspect','Closed Won','','Contact');
        myUnitTestTask_All(taskObj4);
        //Event_Tasks_Event
        Task taskObj5 = insertTask('Event_Tasks',0,'Suspect','Closed Won','Suspect','Suspect','Suspect','','Contact');
        myUnitTestTask_All(taskObj5);
        //Event_Tasks_CCCSN
        Task taskObj6 = insertTask('Event_Tasks',0,'Closed Won','Suspect','Suspect','Suspect','Suspect','','Contact');
        myUnitTestTask_All(taskObj6);
      Test.stopTest();
    }    
    static testMethod void test_Task_Event_Tasks_EventCSN_EventCC(){
        Test.startTest();
        //Event_Tasks_EventCSN
        Task taskObj7 = insertTask('Event_Tasks',0,'Suspect','Closed Won','Suspect','Suspect','Suspect','','Contact');
        myUnitTestTask_All(taskObj7);    
        //Event_Tasks_EventCC
        Task taskObj8 = insertTask('Event_Tasks',0,'Suspect','Suspect','Suspect','Suspect','Closed Won','','Contact');
        myUnitTestTask_All(taskObj8);
        Test.stopTest();
    }  
    
    /*============CSN RecordType Tasks===============*/
    static testMethod void test_Task_CSN()
    {
        Test.startTest();
        Task taskObj1 =insertTask('SR_Tasks',10,'Suspect','Suspect','Closed Won','Suspect','Suspect','Suspect','Contact');
        myUnitTestTask_All(taskObj1);
        Task taskObj2 = insertTask('SR_Tasks',10,'Suspect','Suspect','Suspect','Suspect','Suspect','Suspect','Contact');
        myUnitTestTask_All(taskObj2);
        Test.stopTest();
    }
    
    /*============PA RecordType Tasks===============*/
    static testMethod void test_Task_PA()
    {
        Test.startTest();
        Task taskObj1 = insertTask('PA_Tasks',4,'','','Closed Won','','','Closed Won','Contact');
        myUnitTestTask_All(taskObj1);
        Task taskObj2 = insertTask('PA_Tasks',5,'','','','','','','Contact');
        myUnitTestTask_All(taskObj2);
        Test.stopTest();
    }
    
    /*============CT RecordType Tasks===============*/
    static testMethod void test_Task_CT()
    {
        Test.startTest();
        Task taskObj1 = insertTask('CT_Tasks',6,'','','','Closed Won','','','Contact');
        myUnitTestTask_All(taskObj1);
        Task taskObj2 = insertTask('CT_Tasks',7,'','','','','','','Contact');
        myUnitTestTask_All(taskObj2);
        Test.stopTest();
    }
    
    /*============EInquisium RecordType Tasks===============*/
    static testMethod void test_Task_Inquisium()
    {
        Test.startTest();
        Task taskObj1 = insertTask('Inquisium_Tasks',8,'','','','','Closed Won','','Contact');
        myUnitTestTask_All(taskObj1);
        Task taskObj2= insertTask('Inquisium_Tasks',9,'','','','','','','Contact');
        myUnitTestTask_All(taskObj2);
        Test.stopTest();
    }
    
    /*============CC RecordType Tasks===============*/
    static testMethod void test_Task_CC()
    {
        Test.startTest();
        Task taskObj1 = insertTask('CC_Tasks',10,'Suspect','Closed Won','Suspect','Suspect','Suspect','Suspect','Contact');
        myUnitTestTask_All(taskObj1);
        Task taskObj2 =insertTask('CC_Tasks',10,'Suspect','Suspect','Suspect','Suspect','Suspect','Suspect','Contact');
        myUnitTestTask_All(taskObj2);       
        Test.stopTest();
    }
    
    /*============App RecordType Tasks===============*/
    static testMethod void test_Task_App()
    {
        Test.startTest();
        Task taskObj=insertTask('AppSupport',2,'Closed Won','','','','','','Contact');
        myUnitTestTask_All(taskObj);
        Test.stopTest();
    }
    /* Ends Here-------------------*/
    
    static testMethod void myunitTestfirst()
    {
        Test.startTest();
        PageReference pageRef=Page.UpdateContactStatus_Event;
        Test.setCurrentPage(pageRef);
        Event eventObj=insertEvent('SMM_BD_Presentations',2,'Suspect','Suspect','Suspect','Suspect','Suspect','Suspect','Lead');
        String varParam=eventObj.RecordTypeId+'retURL=/'+insertAccount();
        ApexPages.StandardController controller=new ApexPages.StandardController(eventObj);
        UpdateContactStatus_Event_Controller pageExtension=new UpdateContactStatus_Event_Controller(controller);
        pageExtension.recordTypeName='CrowdCompass_Presentations';
        ApexPages.currentPage().getParameters().put('recTypId',varParam);
        
        ApexPages.currentPage().getParameters().put('RecordType',eventObj.RecordTypeId);
        ApexPages.currentPage().getParameters().put('00No000000DVJJY','1');
        ApexPages.currentPage().getParameters().put('retURL','/home/home.jsp');
        ApexPages.currentPage().getParameters().put('who_id',insertContact('Suspect','Suspect','Suspect','Suspect','Suspect','Suspect').Id);
        ApexPages.currentPage().getParameters().put('evt5','1');
        ApexPages.currentPage().getParameters().put('followup','1');
        //ApexPages.currentPage().getParameters().put('newId',eventObj.id);
        pageExtension.DetailPageReference();
        pageExtension.SaveContact();
        pageExtension.cancel();
        Test.stopTest();
    }
    static testMethod void myunitTest_noContact()
    {
        Test.startTest();
        PageReference pageRef=Page.UpdateContactStatus_Event;
        Test.setCurrentPage(pageRef);
        Event eventObj=insertEvent('CrowdCompass_Presentations',2,'Suspect','Suspect','Suspect','Suspect','Suspect','Suspect','No');
        String varParam=eventObj.RecordTypeId+'retURL=/'+insertAccount();
        ApexPages.currentPage().getParameters().put('recTypId',varParam);
        ApexPages.StandardController controller=new ApexPages.StandardController(eventObj);
        UpdateContactStatus_Event_Controller pageExtension=new UpdateContactStatus_Event_Controller(controller);
        pageExtension.recordTypeName='CrowdCompass_Presentations';
        ApexPages.currentPage().getParameters().put('RecordType',eventObj.RecordTypeId);
        ApexPages.currentPage().getParameters().put('retURL','/home/home.jsp');
        ApexPages.currentPage().getParameters().put('What_Id',insertAccount());
        ApexPages.currentPage().getParameters().put('evt5','1');
        ApexPages.currentPage().getParameters().put('newId',eventObj.id);
        ApexPages.currentPage().getParameters().put('followup','1');
        pageExtension.DetailPageReference();
        pageExtension.SaveContact();
        pageExtension.cancel();
        Test.stopTest();
    }
    
    static testMethod void myunitTestsecond()
    {
        Test.startTest();
        
        //Insert custome Setting Values.................
        UserExcludedFromDWF__c userCustomSet= new UserExcludedFromDWF__c();
        userCustomSet.Name='ephelps@cvent.com';
        insert userCustomSet;
        
        
        PageReference pageRef=Page.UpdateContactStatus_Event;
        Test.setCurrentPage(pageRef);
        Event eventObj=insertEvent('SMM_BD_Presentations',2,'Suspect','Suspect','Suspect','Suspect','Suspect','Suspect','Lead');
        String varParam=eventObj.RecordTypeId+'retURL=/'+insertAccount();
        ApexPages.currentPage().getParameters().put('recTypId',varParam);
        ApexPages.StandardController controller=new ApexPages.StandardController(eventObj);
        UpdateContactStatus_Event_Controller pageExtension=new UpdateContactStatus_Event_Controller(controller);
        pageExtension.recordTypeName='CrowdCompass_Presentations';
        ApexPages.currentPage().getParameters().put('RecordType',eventObj.RecordTypeId);
        ApexPages.currentPage().getParameters().put('00No000000DVJJY','1');
        ApexPages.currentPage().getParameters().put('newId',eventObj.id);
        pageExtension.DetailPageReference();
        pageExtension.SaveContact();
        pageExtension.cancel();
        Test.stopTest();
    }
    static testMethod void myunitTestsecond1()
    {
        Test.startTest();
        PageReference pageRef=Page.UpdateContactStatus_Event;
        Test.setCurrentPage(pageRef);
        Event eventObj=insertEvent('SMM_BD_Presentations',2,'Suspect','Suspect','Suspect','Suspect','Suspect','Suspect','Contact');
        String varParam=eventObj.RecordTypeId+'retURL=/'+insertAccount();
        ApexPages.currentPage().getParameters().put('recTypId',varParam);
        ApexPages.StandardController controller=new ApexPages.StandardController(eventObj);
        UpdateContactStatus_Event_Controller pageExtension=new UpdateContactStatus_Event_Controller(controller);
        pageExtension.recordTypeName='CrowdCompass_Presentations';
        ApexPages.currentPage().getParameters().put('RecordType',eventObj.RecordTypeId);
        ApexPages.currentPage().getParameters().put('newId',eventObj.id);
        pageExtension.DetailPageReference();
        pageExtension.SaveContact();
        pageExtension.cancel();
        Test.stopTest();
    }
    static testMethod void myunitTest_wrongRecType()
    {
        Test.startTest();
        PageReference pageRef=Page.UpdateContactStatus_Event;
        Test.setCurrentPage(pageRef);
        Event eventObj=insertEvent('Suspect',2,'Suspect','Suspect','Suspect','Suspect','Suspect','Suspect','Contact');
        ApexPages.StandardController controller=new ApexPages.StandardController(eventObj);
        UpdateContactStatus_Event_Controller pageExtension=new UpdateContactStatus_Event_Controller(controller);
        ApexPages.currentPage().getParameters().put('RecordType',eventObj.RecordTypeId);
        pageExtension.DetailPageReference();
        pageExtension.SaveContact();
        pageExtension.cancel();
        Test.stopTest();
    }
    
    /*Task Methods*/
    //String eventStatus,String CCStatus,String CSNStatus,String SMMStatus, String inquisiumStatus,String CSNPStatus
    static testMethod void myunitTestfirst_task()
    {
        Test.startTest();
        PageReference pageRef=Page.UpdateContactStatus_Task;
        Test.setCurrentPage(pageRef);
        Task taskObj=insertTask('BizDev_Tasks',2,'Closed Won','Closed Won','Closed Won','Closed Won','Closed Won','Closed Won','Contact');
        String varParam=taskObj.RecordTypeId+'retURL=/'+insertAccount();
        ApexPages.currentPage().getParameters().put('recTypId',varParam);
        ApexPages.StandardController controller=new ApexPages.StandardController(taskObj);
        UpdateContactStatus_Task_Controller pageExtension=new UpdateContactStatus_Task_Controller(controller);
        ApexPages.currentPage().getParameters().put('RecordType',taskObj.RecordTypeId);
        ApexPages.currentPage().getParameters().put('retURL','/home/home.jsp');
        ApexPages.currentPage().getParameters().put('Who_Id',insertContact('Suspect','Suspect','Suspect','Suspect','Suspect','Suspect').Id);
        ApexPages.currentPage().getParameters().put('What_Id',insertAccount());
        ApexPages.currentPage().getParameters().put('tsk5','1');
        ApexPages.currentPage().getParameters().put('Id',taskObj.id);
        ApexPages.currentPage().getParameters().put('newId',taskObj.id);
        ApexPages.currentPage().getParameters().put('followup','1');
        
        pageExtension.DetailPageReference();
        pageExtension.SaveContact();
        pageExtension.cancel();
        Test.stopTest();
    }
    static testMethod void myunitTestsecond_task()
    {
        Test.startTest();
        PageReference pageRef=Page.UpdateContactStatus_Task;
        Test.setCurrentPage(pageRef);
        Task taskObj=insertTask('BizDev_Tasks',2,'Suspect','Suspect','Suspect','Suspect','Suspect','Suspect','Contact');
        String varParam=taskObj.RecordTypeId+'retURL=/'+insertAccount();
        ApexPages.currentPage().getParameters().put('recTypId',varParam);
        ApexPages.StandardController controller=new ApexPages.StandardController(taskObj);
        UpdateContactStatus_Task_Controller pageExtension=new UpdateContactStatus_Task_Controller(controller);
        ApexPages.currentPage().getParameters().put('RecordType',taskObj.RecordTypeId);
        ApexPages.currentPage().getParameters().put('retURL','/home/home.jsp');
        ApexPages.currentPage().getParameters().put('Who_Id',insertContact('Suspect','Suspect','Suspect','Suspect','Suspect','Suspect').Id);
        ApexPages.currentPage().getParameters().put('What_Id',insertAccount());
        ApexPages.currentPage().getParameters().put('tsk5','1');
        //ApexPages.currentPage().getParameters().put('newId',taskObj.id);
        ApexPages.currentPage().getParameters().put('followup','1');
        
        pageExtension.DetailPageReference();
        pageExtension.SaveContact();
        pageExtension.cancel();
        Test.stopTest();
    }
    static testMethod void myunitTestThird_task()
    {
        Test.startTest();
        PageReference pageRef=Page.UpdateContactStatus_Task;
        Test.setCurrentPage(pageRef);
        Task taskObj=insertTask('BizDev_Tasks',2,'Suspect','Suspect','Suspect','Suspect','Suspect','Suspect','Contact');
        String varParam=taskObj.RecordTypeId+'retURL=/'+insertAccount();
        ApexPages.currentPage().getParameters().put('recTypId',varParam);
        ApexPages.StandardController controller=new ApexPages.StandardController(taskObj);
        UpdateContactStatus_Task_Controller pageExtension=new UpdateContactStatus_Task_Controller(controller);
        ApexPages.currentPage().getParameters().put('RecordType',taskObj.RecordTypeId);
        ApexPages.currentPage().getParameters().put('retURL','/home/home.jsp');
        //ApexPages.currentPage().getParameters().put('Who_Id',insertContact('Suspect','Suspect','Suspect','Suspect','Suspect','Suspect').Id);
        ApexPages.currentPage().getParameters().put('What_Id',insertAccount());
        ApexPages.currentPage().getParameters().put('tsk5','1');
        ApexPages.currentPage().getParameters().put('newId',taskObj.id);
        ApexPages.currentPage().getParameters().put('followup','1');
        
        pageExtension.DetailPageReference();
        pageExtension.SaveContact();
        pageExtension.cancel();
        Test.stopTest();
    }
    static testMethod void myunitFourthThird_task()
    {
        Test.startTest();
        PageReference pageRef=Page.UpdateContactStatus_Task;
        Test.setCurrentPage(pageRef);
        Task taskObj=insertTask('CS_AM_RFP',2,'Suspect','Suspect','Suspect','Suspect','Suspect','Suspect','Contact');
        String varParam=taskObj.RecordTypeId+'retURL=/'+insertAccount();
        ApexPages.currentPage().getParameters().put('recTypId',varParam);
        ApexPages.StandardController controller=new ApexPages.StandardController(taskObj);
        UpdateContactStatus_Task_Controller pageExtension=new UpdateContactStatus_Task_Controller(controller);
        ApexPages.currentPage().getParameters().put('RecordType',taskObj.RecordTypeId);
        ApexPages.currentPage().getParameters().put('retURL','/home/home.jsp');
        ApexPages.currentPage().getParameters().put('Who_Id',insertContact('Suspect','Suspect','Suspect','Suspect','Suspect','Suspect').Id);
        ApexPages.currentPage().getParameters().put('What_Id',insertAccount());
        ApexPages.currentPage().getParameters().put('tsk5','1');
        //ApexPages.currentPage().getParameters().put('newId',taskObj.id);
        ApexPages.currentPage().getParameters().put('followup','1');
        
        pageExtension.DetailPageReference();
        pageExtension.SaveContact();
        pageExtension.cancel();
        Test.stopTest();
    }
    static testMethod void myunitTestFourth_task()
    {
        Test.startTest();
        PageReference pageRef=Page.UpdateContactStatus_Task;
        Test.setCurrentPage(pageRef);
        Task taskObj=insertTask('BizDev_Tasks',2,'Suspect','Suspect','Suspect','Suspect','Suspect','Suspect','Lead');
        String varParam=taskObj.RecordTypeId+'retURL=/'+taskObj.WhoId;
        ApexPages.currentPage().getParameters().put('recTypId',varParam);
        ApexPages.StandardController controller=new ApexPages.StandardController(taskObj);
        UpdateContactStatus_Task_Controller pageExtension=new UpdateContactStatus_Task_Controller(controller);
        ApexPages.currentPage().getParameters().put('RecordType',taskObj.RecordTypeId);
        ApexPages.currentPage().getParameters().put('Who_Id',taskObj.WhoId);
        ApexPages.currentPage().getParameters().put('tsk5','1');
        ApexPages.currentPage().getParameters().put('newId',taskObj.id);
        ApexPages.currentPage().getParameters().put('followup','1');
        pageExtension.DetailPageReference();
        pageExtension.SaveContact();
        pageExtension.cancel();
        Test.stopTest();
    }
    static void myUnitTestTask_All(Task taskObj)
    {
        //Test.startTest();
        PageReference pageRef=Page.UpdateContactStatus_Task;
        Test.setCurrentPage(pageRef);
        String varParam=taskObj.RecordTypeId+'retURL=/'+taskObj.WhoId;
        ApexPages.currentPage().getParameters().put('recTypId',varParam);
        ApexPages.StandardController controller=new ApexPages.StandardController(taskObj);
        UpdateContactStatus_Task_Controller pageExtension=new UpdateContactStatus_Task_Controller(controller);
        ApexPages.currentPage().getParameters().put('RecordType',taskObj.RecordTypeId);
        ApexPages.currentPage().getParameters().put('Who_Id',taskObj.WhoId);
        ApexPages.currentPage().getParameters().put('tsk5','1');
        ApexPages.currentPage().getParameters().put('newId',taskObj.id);
        ApexPages.currentPage().getParameters().put('followup','1');
        pageExtension.DetailPageReference();
        pageExtension.SaveContact();        
        pageExtension.cancel();
        //Test.stopTest();
    }
}