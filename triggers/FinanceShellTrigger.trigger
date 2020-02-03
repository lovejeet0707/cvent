trigger FinanceShellTrigger on Finance_Shell__c (after insert,
                                                 after update) {
   // public static Boolean isExecuted = false;
    if(Trigger.isAfter){       
        FinanceShellsTriggerHandler handler = new FinanceShellsTriggerHandler();
        if(Trigger.isInsert){            
            handler.handleAfterInsert(Trigger.new);
        }
        else if(Trigger.isUpdate){ 
         List <Finance_Shell__c> financeShell = new List<Finance_Shell__c>();
           for (Finance_Shell__c  fs : Trigger.new){          
               If(!checkRecursive.SetOfIDs.contains(fs.Id)){
                    checkRecursive.SetOfIDs.add(fs.Id);
                    financeShell.add(fs);
                }
            }
            handler.handleAfterUpdate(financeShell);              
        }       
    }
}