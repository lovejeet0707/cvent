public with sharing class FinanceReportingQueryMaker {
    public static string getQueryWithAllFields(String strObjectName) {

        String strSelectedFields = '';        
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
}