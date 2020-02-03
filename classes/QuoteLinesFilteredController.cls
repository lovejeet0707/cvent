public class QuoteLinesFilteredController {
    
    public Id objId {get; set;}
    public Boolean boo_1Record{get; set;}
    public String str_CurrencyIsoCode {get; set;}
    public List<SBQQ__QuoteLine__c> quoteLines{get;set;}    
    public List<DisplayWrapper> getQuoteLineList() {
        quoteLines = [SELECT Net_Total_CVent_Converted__c, Net_Unit_Price_Cvent_Converted__c, Regular_Price_Cvent_Converted__c, SBQQ__ProductName__c, SBQQ__Quantity__c, SBQQ__RegularPrice__c, SBQQ__TotalDiscountAmount__c, SBQQ__TotalDiscountRate__c, 
                SBQQ__NetPrice__c, Discount_Type__c, CurrencyIsoCode, SBQQ__NetTotal__c, SBQQ__Quote__r.Contract_Remaining_Term__c, 
                OnArrival_360_Event_Selection__r.Name, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Name, 
                SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Name, Contract_Output_Grouping__c, 
                SBQQ__ProductCode__c, Rack_Rate__c, SBQQ__EffectiveQuantity__c, Year_2_Effective_Quantity__c, 
                 SBQQ__Discount__c, SBQQ__Bundled__c,SBQQ__Product__r.Show_True_Quantity__c,Product_Family__c,
                SBQQ__ComponentVisibility__c, SBQQ__Hidden__c, SBQQ__AdditionalDiscountAmount__c,Conversion_Rate__c,Notes__c,Overage_Fee__c 
                FROM SBQQ__QuoteLine__c 
                WHERE SBQQ__Quote__c = :objId and SBQQ__Optional__c = False];
        
        List<DisplayWrapper> qlWrappers = new List<DisplayWrapper>();
        if(quoteLines.size() == 1){boo_1Record = true;}else{boo_1Record = false;}
        for(SBQQ__QuoteLine__c quoteLine: quoteLines) {
            QuoteLineTemplateContentController.QLWrapper wrapper;
            if(quoteLine.SBQQ__ProductCode__c.startsWith('CV-SW-EC-EVT-CCMOB') || quoteLine.SBQQ__ProductCode__c == 'CV-SW-EC-CCS-OAPREM' || quoteLine.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-OAPREM') {
                try{
                    wrapper = aggregateCrowdCompass(quoteLine, 1, quoteLines);
                } catch (Exception e) {System.debug('QuoteLinesFilteredController ' + e.getMessage());} 
            } else {
                String eventName = '';
                if(quoteLine.OnArrival_360_Event_Selection__c != null) {
                    eventName = quoteLine.OnArrival_360_Event_Selection__r.Name;    
                }                 
                if (String.isBlank(eventName) && quoteLine.SBQQ__RequiredBy__c != null) {
                    if(quoteLine.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__c != null) {
                        eventName = quoteLine.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Name;
                    }
                    if (String.isBlank(eventName) && quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c != null) {
                        if(quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__c != null) {
                            eventName = quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Name;
                        }
                    }
                }
                
                eventName = eventName.escapeHtml3(); 
                if(quoteLine.SBQQ__ProductCode__c.startsWith('CV-PS-HC-OSS-OA360')){
                    try{
                        wrapper = QuoteLineTemplateContentController.aggregateOA360(quoteLine, 1, quoteLines, eventName);
                    } catch (Exception e1) {System.debug('QuoteLinesFilteredController aggregateOA360 error ' + e1.getMessage());}
                }
            }
            
            DisplayWrapper dWrapper = new DisplayWrapper();
            dWrapper.productName = quoteLine.SBQQ__ProductName__c;
            dWrapper.quantity = quoteLine.SBQQ__EffectiveQuantity__c;
            dWrapper.listPrice = quoteLine.SBQQ__RegularPrice__c;
            dWrapper.listPrice_Cvent_Converted = quoteLine.Regular_Price_Cvent_Converted__c;
            dWrapper.discountRate = quoteLine.SBQQ__Discount__c ;
            dWrapper.discountAmount = quoteLine.SBQQ__AdditionalDiscountAmount__c;
            dWrapper.discountType = quoteLine.Discount_Type__c;
            dWrapper.netPrice = quoteLine.SBQQ__NetPrice__c;
            dWrapper.netPrice_Cvent_Converted = quoteLine.Net_Unit_Price_Cvent_Converted__c;
            dWrapper.netTotal = quoteLine.SBQQ__NetTotal__c;
            dWrapper.netTotal_Cvent_Converted = quoteLine.Net_Total_CVent_Converted__c;
            dWrapper.quoteLineNotes = quoteLine.Notes__c;
            dWrapper.overAgeFee = quoteLine.Overage_Fee__c ;
            dWrapper.CurrencyIsoCode = quoteLine.CurrencyIsoCode;
            str_CurrencyIsoCode = quoteLine.CurrencyIsoCode;
            if(wrapper != null && !boo_1Record ) {//&& quoteLine.SBQQ__Bundled__c == true
                System.debug('quoteLine.SBQQ__RegularPrice__c  :'+ quoteLine.SBQQ__RegularPrice__c);
                dWrapper.quantity = wrapper.quantity ==0? dWrapper.quantity: wrapper.quantity;
                //CJ -- added functionality to list price
                dWrapper.listPrice  = wrapper.rackRate ==0.00? dWrapper.listPrice : wrapper.rackRate; 
                dWrapper.netPrice = wrapper.discountUnitRate ==0.00? dWrapper.netPrice : wrapper.discountUnitRate;
                dWrapper.netTotal = wrapper.netTotalPrice ==0.00? dWrapper.netTotal : wrapper.netTotalPrice;
                if(quoteLine.SBQQ__RegularPrice__c == 0.00)
                {
                    dWrapper.listPrice_Cvent_Converted = wrapper.rackRate/quoteLine.Conversion_Rate__c;
                    dWrapper.netPrice_Cvent_Converted = wrapper.discountUnitRate/ quoteLine.Conversion_Rate__c;
                    dWrapper.netTotal_Cvent_Converted = wrapper.netTotalPrice / quoteLine.Conversion_Rate__c;
                }
                
                dWrapper.discountAmount = wrapper.rackRate - wrapper.discountUnitRate;
                dWrapper.discountAmount = wrapper.quantity ==0 ? quoteLine.SBQQ__AdditionalDiscountAmount__c :dWrapper.discountAmount ;
                dWrapper.discountType = 'Amt.';
            } 
            if(quoteLine.SBQQ__Bundled__c == FALSE 
                && quoteLine.SBQQ__ComponentVisibility__c != 'Never' 
                && quoteLine.SBQQ__ComponentVisibility__c != 'Editor Only' 
                && quoteLine.SBQQ__Hidden__c == FALSE && quoteLine.SBQQ__EffectiveQuantity__c > 0) {
                qlWrappers.add(dWrapper);
            }
                
        }
      
        
        return qlWrappers;
    }
    public QuoteLineTemplateContentController.QLWrapper aggregateCrowdCompass(SBQQ__QuoteLine__c quoteLine, Decimal year, List<SBQQ__QuoteLine__c> quoteLines) {
        QuoteLineTemplateContentController.QLWrapper result = new QuoteLineTemplateContentController.QLWrapper(quoteLine.SBQQ__ProductName__c);

        Decimal totalQuantity = 0;
        Decimal totalRackRate = 0;
        Decimal totalPrice = 0;
        Decimal discountRate = 0;
        for (SBQQ__QuoteLine__c ql : quoteLines) {
            Decimal int_Quantity = 0;
            if(ql.SBQQ__Product__r.Show_True_Quantity__c){int_Quantity = ql.SBQQ__Quantity__c;}
            else
            {
                int_Quantity = ql.SBQQ__EffectiveQuantity__c;
            }
            
            if (ql.SBQQ__RequiredBy__c == quoteLine.Id && ( ql.SBQQ__ProductCode__c.startsWith('CV-SW-EC-CC-CCMBAP') || ql.SBQQ__ProductCode__c.startsWith('CV-SW-EC-EVT-OAPREM'))) {//( ql.SBQQ__ProductCode__c.startsWith('CV-SW-EC-CC-CCMBAP') || ql.SBQQ__ProductCode__c.startsWith('CV-SW-EC-EVT-OAPREM'))
                //if (year == 1) {
                    totalQuantity += int_Quantity;
                    totalRackRate += int_Quantity * ql.SBQQ__RegularPrice__c;
                    totalPrice += ql.SBQQ__NetTotal__c;
                    discountRate += ql.SBQQ__TotalDiscountAmount__c;
                //} else if (year == 2) {
                //    totalQuantity += int_Quantity;
                //    totalRackRate += int_Quantity * ql.SBQQ__RegularPrice__c;
                //    totalPrice += ql.SBQQ__NetTotal__c;
                //    discountRate += ql.SBQQ__TotalDiscountAmount__c;
                //} else if (year == 3) {
                //    totalQuantity += int_Quantity;
                //    totalRackRate += int_Quantity * ql.SBQQ__RegularPrice__c;
                //    totalPrice += ql.SBQQ__NetTotal__c;
                //    discountRate += ql.SBQQ__TotalDiscountAmount__c;
                //} else if (year == 4) {
                //    totalQuantity += int_Quantity;
                //    totalRackRate += int_Quantity * ql.SBQQ__RegularPrice__c;
                //    totalPrice += ql.SBQQ__NetTotal__c;
                //    discountRate += ql.SBQQ__TotalDiscountAmount__c;
                //} else if (year == 5) {
                //    totalQuantity += int_Quantity;
                //    totalRackRate += int_Quantity *ql.SBQQ__RegularPrice__c;
                //    totalPrice += ql.SBQQ__NetTotal__c;
                //    discountRate += ql.SBQQ__TotalDiscountAmount__c;
                //}  
            }
            
        }
        if (totalQuantity != 0) {
            result.quantity = totalQuantity;
            result.rackRate = totalRackRate / totalQuantity;
            result.discountUnitRate = totalPrice / totalQuantity;
            result.netTotalPrice = totalPrice;
            result.savingsTotal = totalRackRate - totalPrice;         
        } else {
            result = NULL;
        }
        return result;
    }
    
    public class DisplayWrapper {
        public String productName {get; set;}
        public Decimal quantity {get; set;}
        public Decimal listPrice {get; set;}
        public Decimal listPrice_Cvent_Converted {get; set;}
        public Decimal discountRate {get; set;}
        public Decimal discountAmount {get; set;}
        public Decimal overAgeFee {get; set;}
        public String discountType {get; set;}
        public Decimal netPrice {get; set;}
        public Decimal netPrice_Cvent_Converted {get; set;}
        public Decimal netTotal {get; set;}
        public Decimal netTotal_Cvent_Converted {get; set;}
        //Added by Dishank P-003925
        public String quoteLineNotes {get;set;}
        public String CurrencyIsoCode {get; set;}
        
    }

}