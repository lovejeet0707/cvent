global class QuarterlyConversionUpdatesSched implements Schedulable {
    global void execute(SchedulableContext sc) {
        QuarterlyConversionUpdatesBatch b = new QuarterlyConversionUpdatesBatch();
        database.executebatch(b);
    }
}