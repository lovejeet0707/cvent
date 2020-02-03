global class schedulercreateGDPRPersonaBatch implements Schedulable{
    global void execute(SchedulableContext sc){
        createGDPRPersonaBatch GDPRObj = new createGDPRPersonaBatch();
        Database.executeBatch(GDPRObj,90);
    }
}