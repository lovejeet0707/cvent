trigger DWF_ExecuteTrigger on DWF_Batch_Execution__c (after insert) {
        DWFContactStatusOwnerBatch DWFContactStatusBatch=new DWFContactStatusOwnerBatch();
        Id BatchId=Database.executeBatch(DWFContactStatusBatch,200);
        For(DWF_Batch_Execution__c DWFExecute : trigger.new)
        {
            System.debug('inside this');
            DWF_Batch_Execution__c DWFBatchExecutionObj=new DWF_Batch_Execution__c(Id=DWFExecute.Id);
            DWFBatchExecutionObj.Batch_Id__c=BatchId;
            DWFBatchExecutionObj.Batch_Start_Date_Time__c=system.now();
            update DWFBatchExecutionObj;
        }
}