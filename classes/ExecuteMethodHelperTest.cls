@isTest
private class ExecuteMethodHelperTest{
 static testMethod void validateActive() {
    Execute_Function__mdt active = [select id from Execute_Function__mdt where MasterLabel='TestExecuteFunction' ];
    
    ExecuteMethodHelper cont = new ExecuteMethodHelper();
    ExecuteMethodHelper.isActive('TestExecuteFunction');
 }
}