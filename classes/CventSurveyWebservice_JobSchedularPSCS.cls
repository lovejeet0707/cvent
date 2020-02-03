/**********************************
 Class Name:CventSurveyWebservice_JobSchedularPSCS
 * Author: Rishi Ojha (Cvent)
 * Date: 07-Oct-2019
 * Requirement 
 * Description:This class is responsible to periodically Call CventSurveyWebserviceControllerPSCS to process
 *                                                                    Survey Response.
               . 
***********************************/

global class CventSurveyWebservice_JobSchedularPSCS implements Schedulable{



public void execute(SchedulableContext sc) {

    CronTrigger ct =[SELECT TimesTriggered, NextFireTime FROM CronTrigger WHERE Id =:sc.getTriggerId()];

try{

    CventSurveyWebserviceControllerPSCS.ProcessRequest();
    System.abortJob(ct.Id);

}catch(exception e){
} 
finally{

    dateTime dt=System.now().addMinutes(120);      
    String Csec,Cmin,Chr,Cday,Cmonth,CYear;
    Csec=String.valueof(dt.second());
    Cmin=String.valueof(dt.minute());
    Chr=String.valueof(dt.hour());
    Cday=String.valueof(dt.day());
    Cmonth=String.valueof(dt.month());
    CYear=String.valueof(dt.Year());
    String SchTimer=Csec+' '+Cmin+' '+Chr+' '+Cday+' '+Cmonth+' ? '+CYear;
    system.debug('*************SchTimer:'+SchTimer);
    CventSurveyWebservice_JobSchedularPSCS  cm = new CventSurveyWebservice_JobSchedularPSCS ();
    system.schedule('Scheduled ProcessPSCS', SchTimer, cm);
    
}

}
}