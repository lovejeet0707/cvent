global class CventSurveyWebservice_JobSchedularFCS implements Schedulable{



public void execute(SchedulableContext sc) {

    CronTrigger ct =[SELECT TimesTriggered, NextFireTime FROM CronTrigger WHERE Id =:sc.getTriggerId()];

try{

    CventSurveyWebserviceControllerFCS.ProcessRequest();
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
    CventSurveyWebservice_JobSchedularFCS  cm = new CventSurveyWebservice_JobSchedularFCS ();
    system.schedule('Scheduled ProcessFCS', SchTimer, cm);
    
}

}
}