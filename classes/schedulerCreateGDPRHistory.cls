global class schedulerCreateGDPRHistory implements Schedulable{
    global void execute(SchedulableContext sc){
        CreateGDPRHistory GDPRObj = new CreateGDPRHistory();
        Database.executeBatch(GDPRObj,90);
    }
}