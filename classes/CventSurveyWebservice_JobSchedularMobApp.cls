/**********************************
 Class Name:CventSurveyWebservice_JobSchedularMobApp 
 * Author: Rishi Ojha (Cvent)
 * Date: 03-Sep-2014
 * Requirement 
 * Description:This class is responsible to periodically Call CventSurveyWebserviceControllerMobApp to process
 *                                                                    Survey Response.
               . 
***********************************/

global class CventSurveyWebservice_JobSchedularMobApp implements Schedulable{



public void execute(SchedulableContext sc) {

    CronTrigger ct =[SELECT TimesTriggered, NextFireTime FROM CronTrigger WHERE Id =:sc.getTriggerId()];

try{

    CventSurveyWebserviceControllerMobApp.ProcessRequest();
    System.abortJob(ct.Id);

}catch(exception e){
} 
finally{

    dateTime dt=System.now().addMinutes(480); //we can specify 10 mins or 15     
    String Csec,Cmin,Chr,Cday,Cmonth,CYear;
    Csec=String.valueof(dt.second());
    Cmin=String.valueof(dt.minute());
    Chr=String.valueof(dt.hour());
    Cday=String.valueof(dt.day());
    Cmonth=String.valueof(dt.month());
    CYear=String.valueof(dt.Year());
    String SchTimer=Csec+' '+Cmin+' '+Chr+' '+Cday+' '+Cmonth+' ? '+CYear;
    system.debug('*************SchTimer:'+SchTimer);
    CventSurveyWebservice_JobSchedularMobApp  cm = new CventSurveyWebservice_JobSchedularMobApp ();
    system.schedule('Scheduled ProcessMA', SchTimer, cm);
    
}

}
}