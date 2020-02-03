/***** CLass written to replace cutsom label turn ON/OFF functionality : Udita : 6/21/2019****/
/*** How to use : Boolean MethodIsActive = ExecuteMethodHelper.isActive('/ Label of record you’ve created in metadata');
                  If(MethodIsActive){
                  // execute code
                  }
*********/
public class ExecuteMethodHelper{
    public static Boolean isActive(string MethodName) {
      Execute_Function__mdt active = [select id,Mark_Active__c,Class_Name__c from Execute_Function__mdt where MasterLabel =: MethodName];
      return Boolean.ValueOf(active.Mark_Active__c);
    }
}