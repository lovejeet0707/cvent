global class CventMyd_DummySchedulable implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        String executionMessage = 'This class does not do anything.';
        System.debug('executionMessage: ' + executionMessage);
    }

}