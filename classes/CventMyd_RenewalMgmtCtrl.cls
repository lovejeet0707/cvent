public class CventMyd_RenewalMgmtCtrl {

    public static String getContractQueryString() {
        String queryString = 'SELECT Id,Failed_Auto_Renew_Message__c,isLegacy__c FROM Contract';
        queryString += ' WHERE RecordType.Name = \'Child Contract\'';
        queryString += ' AND SBQQ__RenewalQuoted__c != TRUE';
        queryString += ' AND Failed_Auto_Renew__c != TRUE';
        queryString += ' AND Renewal_Creation_Date__c <=: todaysDate';
        return queryString;
    }
  
}