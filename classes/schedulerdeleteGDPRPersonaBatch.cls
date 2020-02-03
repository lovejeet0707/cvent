global class schedulerdeleteGDPRPersonaBatch implements Schedulable{
    global void execute(SchedulableContext sc){
        deleteGDPRPersonaBatch GDPRObj = new deleteGDPRPersonaBatch();
        Database.executeBatch(GDPRObj,90);
    }
}