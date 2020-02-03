//*********************************************************************************** 
//
//  Account_Partner_RollupSched
//
//  Desciption:

//  This class was created by InSitu Software for Cvent. It implements the 
//  Schedulable interface and is provided so that the Account Partner Rollup Calc processing 
//  can be scheduled to run on a regular basis. 
//
//  History:
//  InSitu  10/20/2013  Original version. 
//
// ***********************************************************************************

global with sharing class Account_Partner_RollupSched implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {
        // Use the static helper method to queue up the batch job.
        // Process all accounts in batches of 20 records, perform Account Partner Rollup.
        Id idJob = Account_Partner_RollupBatch.runAccount_Partner_RollupBatch(0, 20);
        
    }
}