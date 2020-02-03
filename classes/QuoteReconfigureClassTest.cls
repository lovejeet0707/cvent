@isTest
public class QuoteReconfigureClassTest{
    static testMethod void QuoteReconfigureClassMethod(){
        Quote_Reconfigure__c gg = new Quote_Reconfigure__c(name = 'aFX1N0000000219WAA',Batch__c= 'Batch 1');
        insert gg;
        
        QuoteReconfigureClass quoteRe = new QuoteReconfigureClass();
        quoteRe.reconfigureQuote();
    }
}