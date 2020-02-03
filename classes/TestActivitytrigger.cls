//========================Created By Rishi Ojha dated 22/07/13====================================

//========================This class is created to test the Trigger >>SetFirstactivityDate

@isTest(SeeAllData=True)

private class TestActivitytrigger
{
static testMethod void testSetFirstActivityDate()

{
        List<T_D__c> tdp = new List<T_D__c>{ new T_D__c(
        Name= 'test tdp 1',
        Requestor_Name__c = 'xyz',
        Goal__c = 'test test',
        Deliverables__c = 'test test'), new T_D__c(
        Name= 'test tdp 2',
        Requestor_Name__c = 'xyz',
        Goal__c = 'test test',
        Deliverables__c = 'test test')};
                                    
        insert tdp;
        
        List<Contact> con = new List<Contact>{ new contact(
        FirstName = 'test con 1',
        LastName = 'xyz',
        LeadSource = 'Web'/*,
        Manager_Email__c = 'test@test.com'*/), new contact(
        FirstName = 'test con 2',
        LastName = 'xyz',
        LeadSource = 'Web'/*,
        Manager_Email__c = 'test@test.com'*/)};
        //insert con;
        
        List<task> t = new List<task>{ new task(
        WhoID = con[1].id,
        Subject='Newtask',
        Status='Completed',
        OwnerId=UserInfo.getUserId(),
        Task_Event_Type__c = 'Client Emails',
        Priority='High'),new task(
        WhoID = con[1].id,
        Subject='Newtask',
        Status='Completed',
        OwnerId=UserInfo.getUserId(),
        Task_Event_Type__c = 'Client Emails',
        Priority='High',
        Mood__c='2 - Frustrated',
        Primary_Reason_for_Mood_Driver__c = 'Sales',
        Reason__c = 'Oversold'),new task(
        WhoID = con[1].id,
        Subject='Newtask',
        Status='Completed',
        OwnerId=UserInfo.getUserId(),
        Task_Event_Type__c = 'Client Emails',
        Priority='High',
        Mood__c='4 - Happy'),new task(
        whatId= tdp[0].id,
        Subject='Newtask',
        Status='Completed',
        Priority='High',
        OwnerId=UserInfo.getUserId(),
        Minutes_on_tasks__c=40)};
        
        insert t;  
        
        t[0].status = 'Completed';
        t[0].Mood__c='1 - Irate';
        t[0].Primary_Reason_for_Mood_Driver__c = 'Sales';
        t[0].Reason__c = 'Oversold';
        
        update t[0];
        
        /*List<task> taskstoupdate = new List<task>{ [select id from task where id =: t[0].id]};
        List<task> taskL = new List<task>();
        for(task tOK:taskstoupdate){
            tOK.status = 'Completed';
            tOK.Mood__c='1 - Irate';
            tOK.Primary_Reason_for_Mood_Driver__c = 'Sales';
            tOK.Reason__c = 'Oversold';
            taskL.add(tOK);
        }
        update taskL;*/
        
       Contact[] cons = [select id from Contact where id in :con];
      delete t[2];

}
}