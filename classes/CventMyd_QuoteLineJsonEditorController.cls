public with sharing class CventMyd_QuoteLineJsonEditorController {

    public SBQQ__QuoteLine__c quoteLine {get;set;}

    public String userMessage {get;set;}

    public String style {get;set;}

    public Boolean recalculate {get;set;}

    public String pricingMessage {get;set;}

    public Decimal netPrice {get;set;}

    public Boolean showInjectionButton {get;set;}

    public String queryString {get;set;}

    public CventMyd_QuoteLineJsonEditorController (ApexPages.StandardController standardController) {

        quoteLine = (SBQQ__QuoteLine__c)standardController.getRecord();

        Set<String> fields = new Set<String>{

            'jsonString__c','SBQQ__ListPrice__c',

            'SBQQ__NetPrice__c','SBQQ__Quantity__c',

            'SBQQ__NetTotal__c','SBQQ__EffectiveQuantity__c',

            'SBQQ__ListPrice__c','Custom_Discount__c',

            'SBQQ__Quote__r.Cloned_From_Quote__c',

            'SBQQ__Quote__r.isLockedIntratermRenewal__c',

            'SBQQ__Quote__r.unlockedTransformedQuote__c',

            'SBQQ__Quote__r.Cloned_From_Quote__c'

        };

        queryString = 'SELECT Id,Name,' + CventMyd_UtilityMethods.getFieldNamesStringFromStringSet(fields);

        Id quoteLineId =  quoteLine.Id;

        queryString += ' FROM SBQQ__QuoteLine__c WHERE Id =: quoteLineId';
    
        quoteLine = Database.query(queryString);

        netPrice = quoteLine.SBQQ__NetPrice__c;

        Boolean lockedTransformedQuote = quoteLine.SBQQ__Quote__r.Cloned_From_Quote__c != null && !quoteLine.SBQQ__Quote__r.unlockedTransformedQuote__c;

        Boolean lockedMydQuote = quoteLine.SBQQ__Quote__r.isLockedIntratermRenewal__c;

        style = 'font-weight:bold;';

        showInjectionButton = (lockedTransformedQuote || lockedMydQuote);

        userMessage = (showInjectionButton) ? null : 'This line\'s quote is not locked; value injection isn\'t applicable.';

        style += (!showInjectionButton) ? 'color:red;' : '';
        
    }

    public void updateJson() {

        String jsonString = quoteLine.jsonString__c;

        Decimal discountAmount = quoteLine.SBQQ__ListPrice__c - netPrice;

        jsonString = replaceJsonStringField(jsonString,'SBQQ__NetPrice__c',String.valueOf(netPrice));

        jsonString = replaceJsonStringField(jsonString,'SBQQ__Quantity__c',String.valueOf(quoteLine.SBQQ__Quantity__c));

        jsonString = replaceJsonStringField(jsonString,'Custom_Discount__c',String.valueOf(discountAmount));

        jsonString = replaceJsonStringField(jsonString,'SBQQ__AdditionalDiscountAmount__c',String.valueOf(discountAmount));

        jsonString = replaceJsonStringField(jsonString,'SBQQ__Discount__c','null');

        jsonString = replaceJsonStringField(jsonString,'Discount_Type__c','"Amt."');

        SBQQ__QuoteLine__c updateObject = new SBQQ__QuoteLine__c(jsonString__c = jsonString, Id = quoteLine.Id);

        quoteLine.jsonString__c = jsonString;

        quoteLine.SBQQ__NetPrice__c = netPrice;

        quoteLine.Discount_Type__c = 'Amt.';

        quoteLine.Custom_Discount__c = discountAmount;        

        if(!recalculate) {

            SBQQ.TriggerControl.disable();

        }

        Database.SaveResult saveResult = Database.update(quoteLine);

        userMessage = (saveResult.isSuccess()) ? 'JSON saved successfully.' : 'Whoops, an error occurred.';

        String pricingMessage;

        if(saveResult.isSuccess()) {

            Id quoteLineId = quoteLine.Id;

            quoteLine = Database.query(queryString);

            userMessage += '<br/>This line is now set to effective amounts of ' + quoteLine.SBQQ__EffectiveQuantity__c + 'x' + quoteLine.SBQQ__NetPrice__c;

            userMessage += '=' + quoteLine.SBQQ__NetTotal__c;

            userMessage += '<br/>The List Price is ' + quoteLine.SBQQ__ListPrice__c + ' and the Net Unit Price is ' + quoteLine.SBQQ__NetPrice__c + '<br/>Hence the discount amount is ' + quoteLine.Custom_Discount__c;

            userMessage += (!recalculate) ? '<br/>Make sure to recalculate the quote before finishing your work.' : '<br/>Your quote is recalculating now.';

        }

        style += (saveResult.isSuccess()) ? ' color:green;' : 'color:red;';

    }

    public static String replaceJsonStringField(String originalJsonString, String fieldName, String fieldValue) {

        String originalFieldJson = originalJsonString.substringBetween('"' + fieldName + '":[',']');

        String newFieldJson = originalFieldJson;

        newFieldJson = newFieldJson.replaceFirst(newFieldJson.substringBefore(','),fieldValue);

        originalFieldJson = '"' + fieldName + '":[' + originalFieldJson + ']';

        newFieldJson = '"' + fieldName + '":[' + newFieldJson + ']';

        return originalJsonString.replace(originalFieldJson,newFieldJson);

    }

}