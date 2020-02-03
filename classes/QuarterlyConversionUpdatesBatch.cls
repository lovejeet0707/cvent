/*------------------------------------------------------------------------------------------------------------------------------+
Simplus(info@Simplus.com)
Purpose: Quarterly Conversion Updates
 
Details: Quarterly scheduled batch apex to update the currency conversion table
 
History:
9/11/2018  CJ Abreu
    Created
 
-------------------------------------------------------------------------------------------------------------------------------+*/
global class  QuarterlyConversionUpdatesBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    String query;
    //List<Currency_Conversion_Table__c> lst_CCT = new List<Currency_Conversion_Table__c>();
    global List<DisplayWrapper> CCTWrappers = new List<DisplayWrapper>();
    global List<DatedConversionRate> lst_DatedConversionRate = new List<DatedConversionRate>();
    global List<String> lst_Headers = new List<String>();
    global List<Date> lst_Dates = new List<Date>();
    global Map<Date, Map<String, Decimal>> map_FindByDate = new Map<Date, Map<String, Decimal>>();
    global  QuarterlyConversionUpdatesBatch() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT ConversionRate,CreatedDate,IsoCode FROM DatedConversionRate Limit 1]);
    }

    global void execute(Database.BatchableContext BC, List<DatedConversionRate> lst_DCR) {
        DateTime endDT=  System.now();
        DateTime startDT=endDT.addDays(-30);

        AggregateResult[] groupedResults
          = [SELECT AVG(ConversionRate),IsoCode FROM DatedConversionRate where CreatedDate>=:startDT AND CreatedDate<=:endDT 
              GROUP BY IsoCode];//CreatedDate>=:startDT AND CreatedDate<=:endDT GROUP BY IsoCode
        Map<String, Decimal> map_strDec = new Map<String, Decimal>();
        List<Currency_Conversion_Table__c> lst_CCT= [SELECT Currency_Conversion_Rate__c, CurrencyIsoCode FROM Currency_Conversion_Table__c WHERE CurrencyIsoCode != 'USD'];
        for (AggregateResult ar : groupedResults)  {
            String str_CurrencyIsoCode =String.valueOf(ar.get('IsoCode'));
            Decimal dec_CurrencyConversionRate = Decimal.valueOf(String.valueOf(ar.get('expr0')));
            map_strDec.put(str_CurrencyIsoCode, dec_CurrencyConversionRate);
        }
        for(Currency_Conversion_Table__c lp : lst_CCT)
        {
            DisplayWrapper dWrapper = new DisplayWrapper();
            Decimal tempDec = lp.Currency_Conversion_Rate__c;
            Decimal stripped = tempDec.stripTrailingZeros();
            dWrapper.oldValue = stripped;
            dWrapper.currencyCode = lp.CurrencyIsoCode;
            CCTWrappers.add(dWrapper);
        }
        for(Currency_Conversion_Table__c lp : lst_CCT)
        {
            if(map_strDec.containsKey(lp.CurrencyIsoCode))
            {
                lp.Currency_Conversion_Rate__c = map_strDec.get(lp.CurrencyIsoCode);
            }
            lst_Headers.add(lp.CurrencyIsoCode);
        }
        for(Currency_Conversion_Table__c lp : lst_CCT)
        {
            for(DisplayWrapper Wlp : CCTWrappers)
            {
                if(Wlp.currencyCode == lp.CurrencyIsoCode)
                {
                    Wlp.newValue = lp.Currency_Conversion_Rate__c;
                }
            }
        }
        for(DatedConversionRate lp: [SELECT CreatedDate,ConversionRate,IsoCode FROM DatedConversionRate where CreatedDate>=:startDT AND CreatedDate<=:endDT ORDER BY CreatedDate,IsoCode])
        {
            Date dt_Temp = Date.valueOf(lp.CreatedDate);
            Map<String, Decimal> map_InnerMap = new Map<String, Decimal>();
            if(map_FindByDate.containsKey(dt_Temp)){
                map_InnerMap = map_FindByDate.get(dt_Temp);
                map_InnerMap.put(lp.IsoCode, lp.ConversionRate);
                map_FindByDate.remove(dt_Temp);
                map_FindByDate.put(dt_Temp, map_InnerMap);
            }
            else {
                lst_Dates.add(dt_Temp);
                map_InnerMap.put(lp.IsoCode, lp.ConversionRate);
                map_FindByDate.put(dt_Temp, map_InnerMap);
            }
        }
        
        System.debug(CCTWrappers.size()); 
        update lst_CCT;
        System.debug('Inserted new Currency Conversion Table records ');
    }
    
    global void finish(Database.BatchableContext BC) {
        DateTime dt = System.now();
        String hbody ='<!DOCTYPE html><html><body><h2>CPQ\'s conversion rates have finished updating.  Please see the below table for reference: '+dt+'</h2><table border=1 style="width:100%"><tr><th>Currency Code</th><th>Old Value</th> <th>New Value</th></tr>';
        System.debug(CCTWrappers.size());
        for(DisplayWrapper lp:CCTWrappers)
        {
            hbody +='<tr><td>'+lp.currencyCode+'</td><td>'+lp.oldValue+'</td><td>'+lp.newValue+'</td></tr>';
            //hbody +='<tr><td>'+'1'+'</td><td>'+'2'+'</td><td>'+'3'+'</td></tr>';
        }
        hbody += '</table><br><br><h2>Individual dated currency conversion rates, used in the above calculation, listed below for reference: </h2><table border=1 style="width:100%">';//</body></html>
        hbody += '<tr><th>Date</th>';
        for(String lp: lst_Headers)
        {
            hbody += '<th>'+lp+'</th>';
        }
        hbody += '</tr>';
        for(Date lpDate: lst_Dates)
        {
            if(map_FindByDate.containsKey(lpDate))
            {
                hbody += '<tr><td>'+lpDate+'</td>';
                Map<String, Decimal> map_InnerMap = map_FindByDate.get(lpDate);
                for(String lpHeader: lst_Headers)
                {
                    if(map_InnerMap.containsKey(lpHeader))
                    {
                        Decimal dec_temp = map_InnerMap.get(lpHeader);
                        hbody += '<td>'+dec_temp+'</td>';
                    }
                }
                hbody += '</tr>';
            }
        }
        hbody += '</table></body></html>';
        AsyncApexJob a = [SELECT Id, Status,ExtendedStatus,NumberOfErrors,JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgwideEmailAddress[] orgwideaddress = [select id from orgwideEmailAddress where displayname ='CRM Management Team']; 
        mail.setToAddresses(getEmailAddresses());
        // List<String> temp = new List<String>{'cj.abreu@simplus.com'};
        // mail.setToAddresses(temp);
        Integer year = System.today().year();
        String quarter = getQuarter();
        mail.setSubject('Cvent Quarterly Conversion Update '+ quarter+' '+year+' Batch: ' + a.Status);
        mail.setHtmlBody(hbody);
        mail.setPlainTextBody('Currency Conversion Table has be updated with the average rate from the last 30 days. Batch processed ' + a.TotalJobItems +
        ' with '+ a.NumberOfErrors + ' failures. '+System.now());
        //mail.setOrgWideEmailAddressId(orgwideaddress[0].id);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        scheduleIt();
    }
    global static String scheduleIt() {
        QuarterlyConversionUpdatesSched reminder = new QuarterlyConversionUpdatesSched();
        // Use to run the Quaterly Conversation setup
        //String Quarter_EXP = '0 0 3 13 JAN,FEB,MAR,OCT ?';
        String Quarter_EXP = '0 0 3 1 JAN,APR,JUL,OCT ?';

        return System.schedule('Quarterly Conversion Updates', Quarter_EXP, reminder);
    }
    private String getQuarter()
    {
        String returnStr; 
        Set<Integer> Q1 = new Set<Integer>{1,2,3};
        Set<Integer> Q2 = new Set<Integer>{4,5,6};
        Set<Integer> Q3 = new Set<Integer>{7,8,9};
        Set<Integer> Q4 = new Set<Integer>{10,11,12};

        Integer cMonth = System.today().month();
        if(Q1.contains(cMonth)){
                return returnStr = 'Q1';}
        if(Q2.contains(cMonth)){
                return returnStr = 'Q2';}
        if(Q3.contains(cMonth)){
                return returnStr = 'Q3';}
    
        return returnStr = 'Q4';
    }
    private List<String> getEmailAddresses() 
    {
        List<String> idList = new List<String>();
        List<String> mailToAddresses = new List<String>();
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name = 'Pricing Team'];  
        for (GroupMember gm : g.groupMembers) {
            idList.add(gm.userOrGroupId);
            }
        User[] usr = [SELECT email FROM user WHERE id IN :idList];
        for(User u : usr) {
            mailToAddresses.add(u.email);
        }   
        return mailToAddresses; 
    }
    private class DisplayWrapper {
        public String currencyCode {get; set;}
        public Decimal oldValue {get; set;}
        public Decimal newValue {get; set;}
    }
}