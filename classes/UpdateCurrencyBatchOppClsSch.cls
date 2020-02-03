global class UpdateCurrencyBatchOppClsSch implements Schedulable {
   global void execute(SchedulableContext sc) {
      UpdateCurrencyBatchOppCls b = new UpdateCurrencyBatchOppCls (); 
      database.executebatch(b);
   }
}