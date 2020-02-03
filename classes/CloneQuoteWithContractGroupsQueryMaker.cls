public with sharing class CloneQuoteWithContractGroupsQueryMaker {

    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields
    public static string getQueryWithCreatableFields(String strObjectName) {

        String strSelectedFields = 'Id, ';
        /*
        if (String.isBlank(strWhereClause)) {
            return null;
        }
        */
        if (String.isBlank(strObjectName)) {
            return null;
        }

        Map<String, Schema.SObjectField> strFieldName_objToken = Schema.getGlobalDescribe().get(strObjectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> lstSelectFields = new list<string>();

        if (strFieldName_objToken != null) {
            for (Schema.SObjectField fieldToken : strFieldName_objToken.values()) {
                Schema.DescribeFieldResult field = fieldToken.getDescribe();
                if (field.isCreateable()) {
                    lstSelectFields.add(field.getName());
                }
            }
        }

        if (!lstSelectFields.isEmpty()) {
            for (string s : lstSelectFields) {
                strSelectedFields += s + ',';
            }
            if (strSelectedFields.endsWith(',')) {
                strSelectedFields = strSelectedFields.substring(0,strSelectedFields.lastIndexOf(','));
            }

        }

        return strSelectedFields;
        //return 'SELECT ' + strSelectedFields + ' FROM ' + strObjectName + ' WHERE ' + strWhereClause;
    }


    // @invocableMethod
    // public static void generateGroupsAndLines(List<SBQQ__Quote__c> listQuote) {
    //     SimplusQuoteTriggerHandler_V31 objSimplusQuoteTriggerHandler_V31 = new SimplusQuoteTriggerHandler_V31();
    //     objSimplusQuoteTriggerHandler_V31.handleAfterInsert(listQuote);
    // }



    // Returns a dynamic SOQL statement for the whole object, includes ALL fields
    public static string getQueryWithAllFields(String strObjectName) {

        String strSelectedFields = '';
        /*
        if (String.isBlank(strWhereClause)) {
            return null;
        }
        */

        if (String.isBlank(strObjectName)) {
            return null;
        }

        Map<String, Schema.SObjectField> strFieldName_objToken = Schema.getGlobalDescribe().get(strObjectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> lstSelectFields = new list<string>();

        if (strFieldName_objToken != null) {
            for (Schema.SObjectField fieldToken : strFieldName_objToken.values()) {
                Schema.DescribeFieldResult field = fieldToken.getDescribe();

                    lstSelectFields.add(field.getName());

            }
        }

        if (!lstSelectFields.isEmpty()) {
            for (string s : lstSelectFields) {
                strSelectedFields += s + ',';
            }
            if (strSelectedFields.endsWith(',')) {
                strSelectedFields = strSelectedFields.substring(0,strSelectedFields.lastIndexOf(','));
            }

        }

        return strSelectedFields;
    }





    //Creates the nested query required for quotelines
    public static string getOuterQueryForQuoteLines(String strObjectName, String strWhereClause) {

        if (String.isBlank(strWhereClause)) {
            return null;
        }

        String strFinalQuery = '';
        if(strObjectName.equalsIgnoreCase('SBQQ__Quote__c')){
            String strInnerQuery = '';

            strInnerQuery = CloneQuoteWithContractGroupsQueryMaker.getQueryWithCreatableFields('SBQQ__QuoteLine__c');

            strFinalQuery = 'SELECT (SELECT Year_2_Prior_Quantity_X__c,Year_3_Prior_Quantity_X__c,Year_4_Prior_Quantity_X__c,Year_5_Prior_Quantity_X__c,Year_5_Net_Price_X__c,Year_4_Net_Price_X__c,Year_3_Net_Price_X__c,Year_2_Net_Price_X__c,Year_2_Net_Price__c,Year_3_Net_Price__c,Year_4_Net_Price__c,Year_5_Net_Price__c,Year_3_Discount_Schedule_Quantity__c,'+
                                            'Year_4_Discount_Schedule_Quantity__c,Year_5_Discount_Schedule_Quantity__c, ' +
                                            ' Name,Year_2_Effective_Quantity__c,Year_3_Effective_Quantity__c,Year_4_Effective_Quantity__c,Year_5_Effective_Quantity__c,	SBQQ__NetTotal__c,'+
                                            'SBQQ__AdditionalDiscount__c,SBQQ__EffectiveStartDate__c,term__c,SBQQ__EffectiveEndDate__c, ' +strInnerQuery +
                                            ' FROM SBQQ__LineItems__r), ' + CloneQuoteWithContractGroupsQueryMaker.getQueryWithCreatableFields(strObjectName) + ' FROM ' + strObjectName + ' WHERE ' + strWhereClause;

            return strFinalQuery;
        }
        else {
            strFinalQuery = 'SELECT ' + CloneQuoteWithContractGroupsQueryMaker.getQueryWithCreatableFields(strObjectName) + ' FROM ' + strObjectName + ' WHERE ' + strWhereClause;
        }
        return strFinalQuery;
    }



    /***********************************Added by Ashwini************************************************* */
    // code may be Repetative : it is used in Simplus Trigger v3
    // Should not Impact DM Batch

    // public static string getOuterQueryForQuoteLines_Trigger(String strObjectName, String strWhereClause, String strSubsObject) {

    //     if (String.isBlank(strWhereClause)) {
    //         return null;
    //     }

    //     String strFinalQuery = '';
    //     if(strObjectName.equalsIgnoreCase('SBQQ__Quote__c')){
    //         String strInnerQuery = '';
    //         //strInnerQuery = CloneQuoteWithContractGroupsQueryMaker.getQueryWithCreatableFields('SBQQ__QuoteLine__c');

    //         /*
    //         strFinalQuery = 'SELECT NAME, (SELECT SBQQ__Product__c, SBQQ__Number__c,Year_2_Net_Price__c,Year_3_Net_Price__c,Year_4_Net_Price__c,Year_5_Net_Price__c,Year_3_Discount_Schedule_Quantity__c,'+
    //                                         'Year_4_Discount_Schedule_Quantity__c,Year_5_Discount_Schedule_Quantity__c, ' +
    //                                         ' Name,Year_2_Effective_Quantity__c,Year_3_Effective_Quantity__c,Year_4_Effective_Quantity__c,Year_5_Effective_Quantity__c,	SBQQ__NetTotal__c,'+
    //                                         'SBQQ__AdditionalDiscount__c,SBQQ__EffectiveStartDate__c,SBQQ__EffectiveEndDate__c, '
    //                                         +CloneQuoteWithContractGroupsQueryMaker.getSubscriptionFields('SBQQ__Subscription__c',strSubsObject) +
    //                                         +strInnerQuery +
    //                                         ' FROM SBQQ__LineItems__r), ' + CloneQuoteWithContractGroupsQueryMaker.getQueryWithCreatableFields(strObjectName) + ' FROM ' + strObjectName + ' WHERE ' + strWhereClause;
    //         */

    //         String strAllQuoteLineFields = CloneQuoteWithContractGroupsQueryMaker.getQueryWithCreatableFields('SBQQ__QuoteLine__c');

    //         strFinalQuery = 'SELECT NAME, (SELECT '
    //                         + strAllQuoteLineFields
    //                         + ', '
    //                         + CloneQuoteWithContractGroupsQueryMaker.getSubscriptionFields('SBQQ__Subscription__c',strSubsObject)
    //                         + strInnerQuery
    //                         + ' FROM SBQQ__LineItems__r), '
    //                         + CloneQuoteWithContractGroupsQueryMaker.getQueryWithCreatableFields(strObjectName)
    //                         + ' FROM ' + strObjectName
    //                         + ' WHERE ' + strWhereClause;

    //         return strFinalQuery;
    //     }
    //     strFinalQuery = 'SELECT ' + CloneQuoteWithContractGroupsQueryMaker.getQueryWithCreatableFields(strObjectName) + ' FROM ' + strObjectName + ' WHERE ' + strWhereClause;
    //     return strFinalQuery;
    // }

    //  public static String getSubscriptionFields(String strObjectName,String relationShipName){
    //      String strSelectedFields = '';
    //     if (String.isBlank(strObjectName)) {
    //         return strSelectedFields;
    //     }
    //     else {
    //         strSelectedFields = relationShipName+'.Id, ';
    //         Map<String, Schema.SObjectField> strFieldName_objToken = Schema.getGlobalDescribe().get(strObjectName.toLowerCase()).getDescribe().Fields.getMap();
    //         list<string> lstSelectFields = new list<string>();

    //         if (strFieldName_objToken != null) {
    //             for (Schema.SObjectField fieldToken : strFieldName_objToken.values()) {
    //                 Schema.DescribeFieldResult field = fieldToken.getDescribe();
    //                 if (field.isCreateable()) {
    //                     lstSelectFields.add(field.getName());
    //                 }
    //             }
    //         }

    //         if (!lstSelectFields.isEmpty()) {
    //             for (string s : lstSelectFields) {
    //                 strSelectedFields += relationShipName +'.' +s + ',';
    //             }
    //             if (strSelectedFields.endsWith(',')) {
    //                 strSelectedFields = strSelectedFields.substring(0,strSelectedFields.lastIndexOf(','));
    //             }

    //         }

    //         return strSelectedFields;
    //     }
    //  }
}