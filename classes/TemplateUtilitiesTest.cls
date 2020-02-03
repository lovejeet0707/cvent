/**
 * Created by stevelohrenz on 8/30/17.
 */

@IsTest
private class TemplateUtilitiesTest {

    @isTest
    static void testCurrencySigns() {
        System.assertEquals('$', TemplateUtilities.getCurrencySign('USD'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('ARS'));
        System.assertEquals('ƒ', TemplateUtilities.getCurrencySign('AWG'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('AUD'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('BSD'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('BBD'));
        System.assertEquals('p.', TemplateUtilities.getCurrencySign('BYR'));
        System.assertEquals('€', TemplateUtilities.getCurrencySign('EUR'));
        System.assertEquals('BZ$', TemplateUtilities.getCurrencySign('BZD'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('BMD'));

        System.assertEquals('$b', TemplateUtilities.getCurrencySign('BOB'));
        System.assertEquals('KM', TemplateUtilities.getCurrencySign('BAM'));
        System.assertEquals('P', TemplateUtilities.getCurrencySign('BWP'));
        System.assertEquals('R$', TemplateUtilities.getCurrencySign('BRL'));
        System.assertEquals('£', TemplateUtilities.getCurrencySign('GBP'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('BND'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('CAD'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('KYD'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('CLP'));
        System.assertEquals('¥', TemplateUtilities.getCurrencySign('CNY'));

        System.assertEquals('$', TemplateUtilities.getCurrencySign('COP'));
        System.assertEquals('¢', TemplateUtilities.getCurrencySign('CRC'));
        System.assertEquals('kn', TemplateUtilities.getCurrencySign('HRK'));
        System.assertEquals('Kc', TemplateUtilities.getCurrencySign('CZK'));
        System.assertEquals('kr', TemplateUtilities.getCurrencySign('DKK'));
        System.assertEquals('RD$', TemplateUtilities.getCurrencySign('DOP'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('XCD'));
        System.assertEquals('£', TemplateUtilities.getCurrencySign('EGP'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('SVC'));
        System.assertEquals('kr', TemplateUtilities.getCurrencySign('EEK'));

        System.assertEquals('£', TemplateUtilities.getCurrencySign('FKP'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('FJD'));
        System.assertEquals('¢', TemplateUtilities.getCurrencySign('GHC'));
        System.assertEquals('£', TemplateUtilities.getCurrencySign('GIP'));
        System.assertEquals('Q', TemplateUtilities.getCurrencySign('GTQ'));
        System.assertEquals('£', TemplateUtilities.getCurrencySign('GGP'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('GYD'));
        System.assertEquals('L', TemplateUtilities.getCurrencySign('HNL'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('HKD'));
        System.assertEquals('Ft', TemplateUtilities.getCurrencySign('HUF'));

        System.assertEquals('kr', TemplateUtilities.getCurrencySign('ISK'));
        System.assertEquals('Rp', TemplateUtilities.getCurrencySign('IDR'));
        System.assertEquals('£', TemplateUtilities.getCurrencySign('IMP'));
        System.assertEquals('J$', TemplateUtilities.getCurrencySign('JMD'));
        System.assertEquals('¥', TemplateUtilities.getCurrencySign('JPY'));
        System.assertEquals('£', TemplateUtilities.getCurrencySign('JEP'));
        System.assertEquals('Ls', TemplateUtilities.getCurrencySign('LVL'));
        System.assertEquals('£', TemplateUtilities.getCurrencySign('LBP'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('LRD'));
        System.assertEquals('CHF', TemplateUtilities.getCurrencySign('CHF'));

        System.assertEquals('Lt', TemplateUtilities.getCurrencySign('LTL'));
        System.assertEquals('RM', TemplateUtilities.getCurrencySign('MYR'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('MXN'));
        System.assertEquals('MT', TemplateUtilities.getCurrencySign('MZN'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('NAD'));
        System.assertEquals('ƒ', TemplateUtilities.getCurrencySign('ANG'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('NZD'));
        System.assertEquals('C$', TemplateUtilities.getCurrencySign('NIO'));
        System.assertEquals('kr', TemplateUtilities.getCurrencySign('NOK'));
        System.assertEquals('B/.', TemplateUtilities.getCurrencySign('PAB'));

        System.assertEquals('Gs', TemplateUtilities.getCurrencySign('PYG'));
        System.assertEquals('S/.', TemplateUtilities.getCurrencySign('PEN'));
        System.assertEquals('Php', TemplateUtilities.getCurrencySign('PHP'));
        System.assertEquals('zl', TemplateUtilities.getCurrencySign('PLN'));
        System.assertEquals('lei', TemplateUtilities.getCurrencySign('RON'));
        System.assertEquals('£', TemplateUtilities.getCurrencySign('SHP'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('SGD'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('SBD'));
        System.assertEquals('S', TemplateUtilities.getCurrencySign('SOS'));
        System.assertEquals('R', TemplateUtilities.getCurrencySign('ZAR'));

        System.assertEquals('kr', TemplateUtilities.getCurrencySign('SEK'));
        System.assertEquals('CHF', TemplateUtilities.getCurrencySign('CHF'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('SRD'));
        System.assertEquals('£', TemplateUtilities.getCurrencySign('SYP'));
        System.assertEquals('NT$', TemplateUtilities.getCurrencySign('TWD'));
        System.assertEquals('TT$', TemplateUtilities.getCurrencySign('TTD'));
        System.assertEquals('TL', TemplateUtilities.getCurrencySign('TRY'));
        System.assertEquals('£', TemplateUtilities.getCurrencySign('TRL'));
        System.assertEquals('$', TemplateUtilities.getCurrencySign('TVD'));
        System.assertEquals('$U', TemplateUtilities.getCurrencySign('UYU'));

        System.assertEquals('Bs', TemplateUtilities.getCurrencySign('VEF'));
        System.assertEquals('Z$', TemplateUtilities.getCurrencySign('ZWD'));
        System.assertEquals('Lek', TemplateUtilities.getCurrencySign('ALL'));
        //System.assertEquals('₹', TemplateUtilities.getCurrencySign('INR'));
        System.assertEquals('INR', TemplateUtilities.getCurrencySign('INR'));
        
        
        TemplateUtilities.formatDate(System.today(),'USD');
        TemplateUtilities.formatDate(System.today(),'AUZ');
        TemplateUtilities.getStartDateFromQL(new SBQQ__QuoteLine__c(),1);
        TemplateUtilities.getStartDateFromQL(new SBQQ__QuoteLine__c(),2);
        TemplateUtilities.getStartDateFromQL(new SBQQ__QuoteLine__c(),3);
        TemplateUtilities.getStartDateFromQL(new SBQQ__QuoteLine__c(),4);
    }
}