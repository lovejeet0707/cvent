/**
 * Place for handling common utility methods shared between Propoal and Quote Template methods.
 */

public with sharing class TemplateUtilities {

    /**
     * Retrieve the correct currency symbol for the
     */
    public static String getCurrencySign(String iso) {
        String symbol = null;
        if (iso == 'ALL') {
            symbol = 'Lek';
        } else if (iso == 'USD') {
            symbol = '$';
        } else if (iso == 'ARS') {
            symbol = '$';
        } else if (iso == 'AWG') {
            symbol = 'ƒ';
        } else if (iso == 'AUD') {
            symbol = '$';
        } else if (iso == 'BSD') {
            symbol = '$';
        } else if (iso == 'BBD') {
            symbol = '$';
        } else if (iso == 'BYR') {
            symbol = 'p.';
        } else if (iso == 'EUR') {
            symbol = '€';
        } else if (iso == 'BZD') {
            symbol = 'BZ$';
        } else if (iso == 'BMD') {
            symbol = '$';
        } else if (iso == 'BOB') {
            symbol = '$b';
        } else if (iso == 'BAM') {
            symbol = 'KM';
        } else if (iso == 'BWP') {
            symbol = 'P';
        } else if (iso == 'BRL') {
            symbol = 'R$';
        } else if (iso == 'GBP') {
            symbol = '£';
        } else if (iso == 'BND') {
            symbol = '$';
        } else if (iso == 'CAD') {
            symbol = '$';
        } else if (iso == 'KYD') {
            symbol = '$';
        } else if (iso == 'CLP') {
            symbol = '$';
        } else if (iso == 'CNY') {
            symbol = '¥';
        } else if (iso == 'COP') {
            symbol = '$';
        } else if (iso == 'CRC') {
            symbol = '¢';
        } else if (iso == 'HRK') {
            symbol = 'kn';
        } else if (iso == 'CZK') {
            symbol = 'Kc';
        } else if (iso == 'DKK') {
            symbol = 'kr';
        } else if (iso == 'DOP') {
            symbol = 'RD$';
        } else if (iso == 'XCD') {
            symbol = '$';
        } else if (iso == 'EGP') {
            symbol = '£';
        } else if (iso == 'SVC') {
            symbol = '$';
        } else if (iso == 'EEK') {
            symbol = 'kr';
        } else if (iso == 'FKP') {
            symbol = '£';
        } else if (iso == 'FJD') {
            symbol = '$';
        } else if (iso == 'GHC') {
            symbol = '¢';
        } else if (iso == 'GIP') {
            symbol = '£';
        } else if (iso == 'GTQ') {
            symbol = 'Q';
        } else if (iso == 'GGP') {
            symbol = '£';
        } else if (iso == 'GYD') {
            symbol = '$';
        } else if (iso == 'HNL') {
            symbol = 'L';
        } else if (iso == 'HKD') {
            symbol = '$';
        } else if (iso == 'HUF') {
            symbol = 'Ft';
        } else if (iso == 'ISK') {
            symbol = 'kr';
        } else if (iso == 'IDR') {
            symbol = 'Rp';
        } else if (iso == 'IMP') {
            symbol = '£';
        } else if (iso == 'JMD') {
            symbol = 'J$';
        } else if (iso == 'JPY') {
            symbol = '¥';
        } else if (iso == 'JEP') {
            symbol = '£';
        } else if (iso == 'LVL') {
            symbol = 'Ls';
        } else if (iso == 'LBP') {
            symbol = '£';
        } else if (iso == 'LRD') {
            symbol = '$';
        } else if (iso == 'CHF') {
            symbol = 'CHF';
        } else if (iso == 'LTL') {
            symbol = 'Lt';
        } else if (iso == 'MYR') {
            symbol = 'RM';
        } else if (iso == 'MXN') {
            symbol = '$';
        } else if (iso == 'MZN') {
            symbol = 'MT';
        } else if (iso == 'NAD') {
            symbol = '$';
        } else if (iso == 'ANG') {
            symbol = 'ƒ';
        } else if (iso == 'NZD') {
            symbol = '$';
        } else if (iso == 'NIO') {
            symbol = 'C$';
        } else if (iso == 'NOK') {
            symbol = 'kr';
        } else if (iso == 'PAB') {
            symbol = 'B/.';
        } else if (iso == 'PYG') {
            symbol = 'Gs';
        } else if (iso == 'PEN') {
            symbol = 'S/.';
        } else if (iso == 'PHP') {
            symbol = 'Php';
        } else if (iso == 'PLN') {
            symbol = 'zl';
        } else if (iso == 'RON') {
            symbol = 'lei';
        } else if (iso == 'SHP') {
            symbol = '£';
        } else if (iso == 'SGD') {
            symbol = '$';
        } else if (iso == 'SBD') {
            symbol = '$';
        } else if (iso == 'SOS') {
            symbol = 'S';
        } else if (iso == 'ZAR') {
            symbol = 'R';
        } else if (iso == 'SEK') {
            symbol = 'kr';
        } else if (iso == 'SRD') {
            symbol = '$';
        } else if (iso == 'SYP') {
            symbol = '£';
        } else if (iso == 'TWD') {
            symbol = 'NT$';
        } else if (iso == 'TTD') {
            symbol = 'TT$';
        } else if (iso == 'TRY') {
            symbol = 'TL';
        } else if (iso == 'TRL') {
            symbol = '£';
        } else if (iso == 'TVD') {
            symbol = '$';
        } else if (iso == 'UYU') {
            symbol = '$U';
        } else if (iso == 'VEF') {
            symbol = 'Bs';

        } else if (iso == 'ZWD') {
            symbol = 'Z$';
        } else if (iso == 'INR') {
            //symbol = '?';
            symbol = 'INR';
        }
        return symbol;
    }

    public static String formatDate(Date valueToFormat, String formatSelector) {
        if(valueToFormat == null) {
            return '';
        } else {
            if(formatSelector == 'USD') {
                return valueToFormat.month() + '/' + valueToFormat.day() + '/' + valueToFormat.year();
            } else {
                return valueToFormat.day() + '/' + valueToFormat.month() + '/' + valueToFormat.year();
            }
        }
    }

    public static Date getStartDateFromQL(SBQQ__QuoteLine__c ql, Decimal year) {
        Date result = NULL;

        result = ql.Ad_Start_Date__c;
        if(result == NULL) {
            result = ql.SA_Start_Date__c;
            if(result == NULL) {
            //modified logic for new logic 
                result = ql.SBQQ__EffectiveStartDate__c;
                
            }
        }

        return result;
    }

    public static Date getEndDateFromQL(SBQQ__QuoteLine__c ql, Decimal year) {
        Date result = NULL;

        result = ql.Ad_End_Date__c;
        if(result == NULL) {
            result = ql.SA_End_Date__c;
            if(result == NULL) {
            //modified logic for new logic
                result = ql.SBQQ__EffectiveEndDate__c;
                
            }
        }

        return result;
    }

    public static String escapeNotesString(String quoteLineNote) {
        if(quoteLineNote == null) {
            return '';
        } else {
            return quoteLineNote.escapeHtml4().stripHtmlTags().replace('&', '&amp;');
        }
    }
}