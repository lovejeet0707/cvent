public class CventMyd_QuoteJsonController {

    public SBQQ__Quote__c quote {get;set;}

    public String quoteLinesJson {get;set;}

    public Boolean editQuoteJson {get;set;}

    public List<SBQQ__QuoteLine__c> quoteLines {get;set;}

    public String messageToUser {get;set;}

    public String messageStyle {get;set;}

    public CventMyd_QuoteJsonController (ApexPages.StandardController standardController) {

        editQuoteJson = false;

        Id quoteId = (ApexPages.currentPage().getParameters().get('quoteId') != null) ? ApexPages.currentPage().getParameters().get('quoteId') : ((SBQQ__Quote__c)standardController.getRecord()).Id;

        this.quote = [SELECT

            Id,jsonString__c,Current_Year__c,Contract_Term_Years__c,

            (SELECT

            Id,jsonString__c,term__c,SBQQ__ProductCode__c,SBQQ__Number__c

            FROM SBQQ__LineItems__r

            WHERE SBQQ__Number__c < 3000

            ORDER BY SBQQ__Number__c ASC

            LIMIT 70)

            FROM SBQQ__Quote__c

            WHERE Id =: quoteId

        ];

        this.quoteLines = new List<SBQQ__QuoteLine__c>();

        if(this.quote.SBQQ__LineItems__r.size() <= 7) {

            this.quoteLines = this.quote.SBQQ__LineItems__r;

        }

        else {

            this.quoteLines.add(this.quote.SBQQ__LineItems__r[0]);

            List<Integer> years = new List<Integer>();

            years.add(Integer.valueOf(this.quote.SBQQ__LineItems__r[0].term__c));

            for(SBQQ__QuoteLine__c ql : this.quote.SBQQ__LineItems__r) {

                if(!years.contains(Integer.valueOf(ql.term__c))) {

                    this.quoteLines.add(ql);

                    years.add(Integer.valueOf(ql.term__c));

                }

            }            

        }

        this.quoteLinesJson = JSON.serialize(this.quoteLines);
        
    }

    public void toggleEditForm() {
        this.messageToUser = (editQuoteJson) ? 'Quote JSON update operation cancelled.' : 'Be careful when editing quote JSON.';
        editQuoteJson = !editQuoteJson;
        this.messageStyle = getMessageStyle(this.messageToUser);
    }

    public void saveQuoteJson() {
        System.debug('saveQuoteJson() method in controller...');
        SBQQ__Quote__c quoteToUpdate = new SBQQ__Quote__c(Id = this.quote.Id, jsonString__c = this.quote.jsonString__c);
        String jsonStringFromPage = Apexpages.currentPage().getParameters().get('quoteJsonString');
        String jsonStringDespaced = jsonStringFromPage;
        System.debug('jsonString from JS function (before): ' + jsonStringFromPage);
        if(jsonStringFromPage != null) {
            for(Integer i = 0; i < jsonStringDespaced.length(); i++){
                if(jsonStringDespaced.charAt(i) == 10 || jsonStringDespaced.charAt(i) == 13 || jsonStringDespaced.charAt(i) == 32) {
                    jsonStringDespaced = jsonStringDespaced.replace(jsonStringDespaced.subString(i,i+1),'');
                }
            }
            System.debug('jsonString from JS function (after): ' + jsonStringDespaced);
            quoteToUpdate.jsonString__c = jsonStringDespaced;
        }
        Database.SaveResult saveResult;
        String exceptionMessage;
        try {
            CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(quoteToUpdate);
            saveResult = Database.update(quoteToUpdate);
        }
        catch (Exception e) {
            exceptionMessage = 'Please try that again. Exception: ' + e.getMessage();
        }
        if(saveResult != null && saveResult.isSuccess() && exceptionMessage == null) {
            messageToUser = 'Quote JSON saved successfully. You should probably recalculate the quote.';
            this.quote.jsonString__c = jsonStringDespaced;
            editQuoteJson = false;
        }
        else {
            messageToUser = exceptionMessage;
        }
        this.messageStyle = getMessageStyle(this.messageToUser);
    }

    public static String getMessageStyle(String exceptionMessage) {
        exceptionMessage = (exceptionMessage == null) ? '' : exceptionMessage;
        String messageStyle = 'font-weight:bold; color:';
        messageStyle += exceptionMessage.contains('Exception: ') ? 'red;"' : (exceptionMessage.contains('Be careful')) ? 'orange;': 'green;';
        return messageStyle;
    }

}