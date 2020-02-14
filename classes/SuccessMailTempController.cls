/**
Author : Shanu Aggarwal
Added on : 3 Jan 2019
Purpose : To be used in Template - Success Experience Higher Level in DUNS
**        List of Accounts with same DUNS Number
**/
public class SuccessMailTempController{
    
    public static string dunsNumber {get;set;}
    public static List<Account> getDUNSAccounts(){
        return [Select Id,Name,Success_Experience__c,Success_Experience_Account_Value__c 
                From Account Where Global_Ultimate_DUNS__c=:dunsNumber and Success_Experience__c!=null];
    }
}