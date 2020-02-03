global class schedulerBatchUpdateAccountCSN implements Schedulable{
    global void execute(SchedulableContext sc){
        BatchUpdateAccountCSN Obj = new BatchUpdateAccountCSN();
        Database.executeBatch(Obj,1);
    }
}