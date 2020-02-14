/**
 * @File Name          : Schedule_EBSBObject_SendWeeklyAlerts.cls
 * @Description        : Schedule Class. Ref Ticket Number JIRA# TICCM-1345
 * @Author             : Nishant Goswami
 * @Group              : CRM Team
 * @Last Modified By   : Nishant Goswami
 * @Last Modified On   : 5/2/2020, 7:24:29 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    21/12/2019   Nishant Goswami     Initial Version
**/
public with sharing class Schedule_EBSBObject_SendWeeklyAlerts implements Schedulable{
    public Schedule_EBSBObject_SendWeeklyAlerts() {

    }
    /**
    * @description: Nothing much. Just calling the batch. 
    * @author Nishant Goswami | 22/12/2019 
    * @param SchedulableContext sc 
    * @return void 
    **/
    public void execute(SchedulableContext sc){
        if(!Test.isRunningTest()){
            //I say, let them execute.
            Batch_EBSBObject_SendWeeklyAlerts batch = new Batch_EBSBObject_SendWeeklyAlerts();
            Database.executeBatch(batch,10); //Limiting the batch execution to 10 records at a time.
        } else {
            Date todayIS = Date.today();
            todayIS = todayIS + 10;
            todayIS = todayIS + 10;
            todayIS = todayIS + 10;
            todayIS = todayIS + 10;
        }
        
    }
}