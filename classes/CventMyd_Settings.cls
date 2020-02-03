public without sharing class CventMyd_Settings {
    public static List<List<String>> fieldValueMapFieldNameLists;
    public static List<Map<String,List<String>>> quoteLineToSubscriptionFieldMaps;
    public static String opportunityFieldNamesString;
    public static String legacySubscriptionFieldNamesString;
    public static Id quoteUnlockedRecordTypeId;
    public static Id childContractRecordTypeId;
    public static Id parentContractRecordTypeId;
    public static Integer quoteLineMaxCount;
    public static String twinFieldNamesString;
    public static String extraQuoteLineFieldNamesString;
    public static String fullQuoteLineFieldNamesString;
    public static Integer secondsBeforeForceReroutingAmendment;
    public static Integer quotesPerLegacyValidationJob;
    public static Boolean mydTriggersAreActive;
    public static List<String> administratorEmails;
    public static String qleUrlBeforeQuoteId;
    public static String orgBaseUrl;
    public static Boolean contractingInForeground;
    public static Integer scheduledJobMax;
    public static CventMyd_RecalculateQuotes.Settings recalculationSettings;
    public static CventMyd_ContractingMonitor.Settings contractingMonitorSettings;
    public static CventMyd_AutoRenewContractSchedulable.Settings renewalGenerationSettings;
    public static CventMyd_ValidationHandler.Settings validationSettings;
    public static CventMyd_ReassignmentHandler.Settings reassignmentSettings;
    static {
        Set<String> subscriptionFieldNames = new Set<String>();
        fieldValueMapFieldNameLists = new List<List<String>>();
        quoteLineToSubscriptionFieldMaps = new List<Map<String,List<String>>>();
        quoteLineToSubscriptionFieldMaps.add(new Map<String,List<String>>());
        quoteLineToSubscriptionFieldMaps.add(new Map<String,List<String>>());
        quotesPerLegacyValidationJob = 100;
        quoteUnlockedRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Unlocked').getRecordTypeId();
        Map<String,Schema.RecordTypeInfo> contractRecordTypeNameToRecordTypeInfo = Schema.SObjectType.Contract.getRecordTypeInfosByName();
        childContractRecordTypeId = contractRecordTypeNameToRecordTypeInfo.get('Child Contract').getRecordTypeId();
        parentContractRecordTypeId = contractRecordTypeNameToRecordTypeInfo.get('Parent Contract').getRecordTypeId();
        Map<String,Schema.SObjectField> fieldNameToField = Schema.getGlobalDescribe().get('CventMyd_Settings__mdt').getDescribe().fields.getMap();
        Set<String> fieldNames = new Set<String>();
        for(String fieldName : fieldNameToField.keySet()) {
            if(fieldName.containsIgnoreCase('__c')){fieldNames.add(fieldName);}
        }
        String queryString = 'SELECT Id,DeveloperName,' + CventMyd_UtilityMethods.getFieldNamesStringFromStringSet(fieldNames);
        queryString += ' FROM CventMyd_Settings__mdt';
        for(CventMyd_Settings__mdt settingsRecord : Database.query(queryString)) {
            subscriptionFieldNames.addAll(CventMyd_UtilityMethods.getListOfStrings(settingsRecord.subscriptionFieldNames__c));
            if(settingsRecord.DeveloperName == 'QcpSettings') {
                fieldValueMapFieldNameLists.add(CventMyd_UtilityMethods.getListOfStrings(settingsRecord.preCalculationQuoteLineFieldNames__c));
                fieldValueMapFieldNameLists.add(CventMyd_UtilityMethods.getListOfStrings(settingsRecord.calculatedQuoteLineFieldNames__c));                
            }
            else if(settingsRecord.preOrPost__c == 'pre' || settingsRecord.preOrPost__c == 'post') {
                String jsonKey = settingsRecord.jsonStringFieldName__c;
                Integer fieldMapIndex = (settingsRecord.preOrPost__c == 'pre') ? 0 : 1;
                quoteLineToSubscriptionFieldMaps[fieldMapIndex].put(jsonKey,CventMyd_UtilityMethods.getListOfStrings(settingsRecord.subscriptionFieldNames__c));
            }
            else if(settingsRecord.DeveloperName == 'Processing_Settings') {
                Set<String> opportunityFieldNames = new Set<String>(CventMyd_UtilityMethods.getListOfStrings(settingsRecord.opportunityQueryFields__c));
                opportunityFieldNamesString = CventMyd_UtilityMethods.getFieldNamesStringFromStringSet(opportunityFieldNames);
                Set<String> quoteLineFieldNames = new Set<String>(CventMyd_UtilityMethods.getListOfStrings(settingsRecord.quoteLineQueryFields__c));
                extraQuoteLineFieldNamesString = CventMyd_UtilityMethods.getFieldNamesStringFromStringSet(quoteLineFieldNames);           
                qleUrlBeforeQuoteId = settingsRecord.qleUrlBeforeQuoteId__c;
                quoteLineMaxCount = (Integer)settingsRecord.quoteLineMaxCount__c;
                secondsBeforeForceReroutingAmendment = (Integer)settingsRecord.secondsBeforeForceReroutingAmendment__c;
                mydTriggersAreActive = settingsRecord.mydTriggersActive__c;
                administratorEmails = CventMyd_UtilityMethods.getListOfStrings(settingsRecord.administratorEmails__c);
                contractingInForeground = (Boolean)settingsRecord.contractingInForeground__c;
                scheduledJobMax = (Integer)settingsRecord.scheduledJobMax__c;
                renewalGenerationSettings = (CventMyd_AutoRenewContractSchedulable.Settings)JSON.deserialize(settingsRecord.renewalGenerationSettingsJson__c,CventMyd_AutoRenewContractSchedulable.Settings.Class);
                recalculationSettings = (CventMyd_RecalculateQuotes.Settings)JSON.deserialize(settingsRecord.recalculationSettingsJson__c,CventMyd_RecalculateQuotes.Settings.Class);
                contractingMonitorSettings = (CventMyd_ContractingMonitor.Settings)JSON.deserialize(settingsRecord.contractingMonitorSettingsJson__c,CventMyd_ContractingMonitor.Settings.Class);
                validationSettings = (CventMyd_ValidationHandler.Settings)JSON.deserialize(settingsRecord.validationSettingsJson__c,CventMyd_ValidationHandler.Settings.Class);
                reassignmentSettings = (CventMyd_ReassignmentHandler.Settings)JSON.deserialize(settingsRecord.reassignmentSettingsJson__c,CventMyd_ReassignmentHandler.Settings.Class);
            }
        }
        subscriptionFieldNames.remove('');
        legacySubscriptionFieldNamesString = CventMyd_UtilityMethods.getFieldNamesStringFromStringSet(subscriptionFieldNames);
        Set<String> twinFieldNames = CventMyd_UtilityMethods.getSubscriptionQuoteLineTwinFieldNames();
        twinFieldNamesString = CventMyd_UtilityMethods.getFieldNamesStringFromStringSet(twinFieldNames);
        fullQuoteLineFieldNamesString = extraQuoteLineFieldNamesString + ',' + twinFieldNamesString;
        orgBaseUrl = String.valueOf(System.URL.getSalesforceBaseUrl());
        orgBaseUrl = orgBaseUrl.split('delegate=')[1];
        orgBaseUrl = orgBaseUrl.substringBeforeLast(']') + '/';
    }
}