/*------------------------------------------------------------------------------------------------------------------------------+
Simplus(info@Simplus.com)
Purpose: Finance Shells Trigger Handler
 
Details: Trigger Handler Framework
 
History:
06/26/2018 CJ Abreu
    -- Created
 

-------------------------------------------------------------------------------------------------------------------------------+*/
public class FinanceShellsTriggerHandler 
{
    //Public static Map<String,Decimal> mapCurrencyConv {get; set;}
    /*Public FinanceShellsTriggerHandler(){
       
    }*/
    public void handleAfterInsert(List<Finance_Shell__c> lstNewFinanceShells){
        system.debug('FInance' + lstNewFinanceShells);
        if(!lstNewFinanceShells.isEmpty() && lstNewFinanceShells.size() > 0){
            List<Finance_Shell__c> lstActiveFinanceShells = new List<Finance_Shell__c>();          
            for(Finance_Shell__c lstItr : lstNewFinanceShells){
                if(!lstItr.Contract_Expired__c){
                    lstActiveFinanceShells.add(lstItr);
                }
            }
            createFinanceBudget(lstNewFinanceShells);
            createFinanceCommision(lstActiveFinanceShells);
        }
    }

    public void handleAfterUpdate(List<Finance_Shell__c> lstNewFinanceShells){
        System.debug('lstNewFinanceShells-->' + lstNewFinanceShells);
        if(!lstNewFinanceShells.isEmpty() && lstNewFinanceShells.size() > 0){
           List<Finance_Shell__c> lstActiveshell = new List<Finance_Shell__c>();  
            for (Finance_Shell__c fs : lstNewFinanceShells){
                 if ( !fs.Locked__c && !fs.Contract_Expired__c) {
                    lstActiveshell.add (fs); 
                 }
            }
            System.debug('lstActiveshell-->' + lstActiveshell);
            deleteFinanceBudget(lstActiveshell);
            deleteFinanceCommision(lstActiveshell);
            createFinanceBudget(lstActiveshell);
            createFinanceCommision(lstActiveshell);
        }

    }
    
    /**
     * Creating finance commision for newly created or updated FinanceShell 
     * 15 Jan 2019
    **/
    public void createFinanceCommision(List<Finance_Shell__c> lstNewFinanceShells){
        
        Set<Id> setQuoteIds = new Set<Id>();
        List<Finance_Commission__c> lstFinanceCommisions = new List<Finance_Commission__c>();
        Map<Id,Finance_Shell__c> mapShell = new Map<Id,Finance_Shell__c>();
        for(Finance_Shell__c lstItr : lstNewFinanceShells){     
            if(lstItr.Quote_ID__c != null && !lstItr.Locked__c){
                setQuoteIds.add(lstItr.Quote_ID__c);
                mapShell.put(lstItr.Quote_ID__c,lstItr);
            }           
        }
        List<SBQQ__QuoteLine__c> lstQuoteLines = [SELECT  Id,SBQQ__StartDate__c,SBQQ__Quote__c,SBQQ__Product__c,SBQQ__ProductCode__c,SBQQ__RequiredBy__c,
                                                          SBQQ__Discount__c,
                                                          SBQQ__EffectiveQuantity__c,
                                                          SBQQ__EndDate__c,
                                                          SBQQ__ListPrice__c,
                                                          SBQQ__NetTotal__c,
                                                          SBQQ__Quantity__c,
                                                          SBQQ__TotalDiscountRate__c,
                                                          SBQQ__ListTotal__c,
                                                          Cloned_from_Quote_Line__c,
                                                          Rack_Rate__c,
                                                          term__c,
                                                          SBQQ__ProductFamily__c,
                                                          SBQQ__NetPrice__c,
                                                          SBQQ__Quote__r.Contract_Term_Years__c,
                                                          SBQQ__Quote__r.Current_Year__c,
                                                          SBQQ__Quote__r.Multiple_Years_Commitment__c,
                                                          Revenue_Type__c,
                                                          SBQQ__EffectiveEndDate__c,
                                                          SBQQ__EffectiveStartDate__c,
                                                          SBQQ__Quote__r.CurrencyIsoCode,
                                                          SBQQ__Group__c,
                                                          SBQQ__RenewedSubscription__c,
                                                          SBQQ__UpgradedSubscription__c,
                                                          SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__r.SBQQ__NetTotal__c,
                                                          jsonString__c,
                                                          SBQQ__Quote__r.jsonString__c,
                                                          SBQQ__Quote__r.SBQQ__EndDate__c,
                                                          SBQQ__Quote__r.SBQQ__StartDate__c,
                                                          SBQQ__Quote__r.Contract_Extension__c
                                                          FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :setQuoteIds ORDER BY term__c ASC];
                                                          
        //lstQuoteLines.sort();
        
        Map<String,Finance_Commission__c> mapprocessedQLI= new Map <String,Finance_Commission__c>();
        
        for (SBQQ__QuoteLine__c qli : lstQuoteLines) {
          // key is the combination of QuoteID,Product
            Finance_Commission__c  fcObj = new Finance_Commission__c();
            String key = qli.SBQQ__Quote__c + '#' + qli.SBQQ__Product__c;
            if (!mapprocessedQLI.containsKey(key)) {
                fcObj.Finance_shell__c =  mapShell.get(qli.SBQQ__Quote__c).Id;
                fcObj.Close_Date__c =  mapShell.get(qli.SBQQ__Quote__c).Closed_Date__c;
                fcObj.Total_Duration__c = mapShell.get(qli.SBQQ__Quote__c).Total_Duration__c;
                fcObj.Type__c =  mapShell.get(qli.SBQQ__Quote__c).Opportunity_type__c;
                fcObj.Product__c = qli.SBQQ__Product__c;
                fcObj.CurrencyIsoCode= qli.SBQQ__Quote__r.CurrencyIsoCode;
                fcObj.product_family__c = qli.SBQQ__ProductFamily__c;
                fcObj.Product_Revenue_type__c = qli.Revenue_Type__c; 
                fcObj.ProductCode__c = qli.SBQQ__ProductCode__c;
                fcObj.Quote_Lookup__c = qli.SBQQ__Quote__c;                                
                fcObj.VariableOptions__c = qli.SBQQ__Quote__r.Multiple_Years_Commitment__c;
                fcObj = populateFinanceCommision(qli,fcObj);
            }else {
                fcObj = mapprocessedQLI.get(key);
                fcObj = populateFinanceCommision(qli,fcObj);  
            }
            mapprocessedQLI.put(key,fcObj); 
            System.debug('Map of QuoteLines==>'+mapprocessedQLI);
        }
         if (mapprocessedQLI!=null){
    
             insert mapprocessedQLI.values();
         }
    }
    
       
    public Finance_Commission__c populateFinanceCommision(SBQQ__QuoteLine__c qli, Finance_Commission__c fcObj){
            //populate Finance commission on the basis of qli belongs variable and non variable Quote fill the fields accordingly
            CventMyd_QuoteObject quoteObject = new CventMyd_QuoteObject();
                    quoteObject = (CventMyd_QuoteObject)JSON.deserialize(qli.SBQQ__Quote__r.jsonString__c,CventMyd_QuoteObject.class);
            
            if (fcObj.VariableOptions__c) {
                if (qli.term__c == qli.SBQQ__Quote__r.Current_Year__c) {
                    fcObj.Term_1__c = qli.term__c;
                    System.debug('Term==>'+fcObj.Term_1__c);
                    fcObj.Year_1_discount__c= qli.SBQQ__Discount__c;
                    System.debug('Year 1 Discount==>'+fcObj.Year_1_discount__c);
                    fcObj.Year_1_Compound_Discount__c = qli.SBQQ__TotalDiscountRate__c;
                    System.debug('Year1 Compound Discount==>'+fcObj.Year_1_Compound_Discount__c);
                    fcObj.Year_1_effective_Quantity__c = qli.SBQQ__EffectiveQuantity__c+ (fcObj.Year_1_effective_Quantity__c==null? 0:fcObj.Year_1_effective_Quantity__c);
                    System.debug('Year1 Effective Quantity==>'+fcObj.Year_1_effective_Quantity__c);
                    fcObj.Year_1_List_price__c = qli.SBQQ__ListPrice__c + (fcObj.Year_1_List_price__c==null? 0:fcObj.Year_1_List_price__c);
                    System.debug('Year1 List Price-->'+fcObj.Year_1_List_price__c);
                    fcObj.Year_1_List_total__c = qli.SBQQ__ListTotal__c + (fcObj.Year_1_List_total__c==null? 0:fcObj.Year_1_List_total__c);
                    System.debug('Year_1_List_total__c-->'+fcObj.Year_1_List_total__c);
                    fcObj.Year_1_Net_Amount__c = qli.SBQQ__NetTotal__c + (fcObj.Year_1_Net_Amount__c==null? 0:fcObj.Year_1_Net_Amount__c);
                    System.debug('Year_1_Net_Amount__c-->'+fcObj.Year_1_Net_Amount__c);
                    fcObj.Year_1_Net_Price__c = qli.SBQQ__NetPrice__c + (fcObj.Year_1_Net_Price__c==null? 0:fcObj.Year_1_Net_Price__c);
                    System.debug('Year_1_Net_Price__c-->'+fcObj.Year_1_Net_Price__c);
                    fcObj.Year_1_Quantity__c = qli.SBQQ__Quantity__c + (fcObj.Year_1_Quantity__c==null? 0:fcObj.Year_1_Quantity__c);
                    System.debug('Year_1_Quantity__c---> '+fcObj.Year_1_Quantity__c);
                    fcObj.Year_1_Rackrate__c = qli.Rack_Rate__c + (fcObj.Year_1_List_price__c==null? 0:fcObj.Year_1_List_price__c);
                    System.debug('Year_1_Rackrate__c-->'+fcObj.Year_1_Rackrate__c);
                    // dates for 1st year from Quote and for subsequent years from Quote Json
                    fcObj.Year_1_start_date__c =qli.SBQQ__Quote__r.SBQQ__StartDate__c;
                    System.debug('Year_1_start_date__c ==>'+fcObj.Year_1_start_date__c);
                    fcObj.Year_1_end_date__c =qli.SBQQ__Quote__r.SBQQ__EndDate__c;  
                    System.debug('Year_1_end_date__c ==>'+fcObj.Year_1_end_date__c);
                    
                } if (qli.term__c == qli.SBQQ__Quote__r.Current_Year__c+1) {
                    fcObj.Term_2__c = qli.term__c;
                    fcObj.Year_2_discount__c= qli.SBQQ__Discount__c;
                    System.debug('Year_2_discount__c-->'+fcObj.Year_2_discount__c);
                    fcObj.Year_2_Compound_Discount__c = qli.SBQQ__TotalDiscountRate__c;
                    System.debug('Year_2_Compound_Discount__c =>'+fcObj.Year_2_Compound_Discount__c );
                    fcObj.Year_2_effective_Quantity__c = qli.SBQQ__EffectiveQuantity__c+ (fcObj.Year_2_effective_Quantity__c==null? 0:fcObj.Year_2_effective_Quantity__c);
                 
                    fcObj.Year_2_List_price__c = qli.SBQQ__ListPrice__c + (fcObj.Year_2_List_price__c==null? 0:fcObj.Year_2_List_price__c);
                    fcObj.Year_2_List_total__c = qli.SBQQ__ListTotal__c + (fcObj.Year_2_List_total__c==null? 0:fcObj.Year_2_List_total__c);
                    fcObj.Year_2_Net_Amount__c = qli.SBQQ__NetTotal__c + (fcObj.Year_2_Net_Amount__c==null? 0:fcObj.Year_2_Net_Amount__c);
                    fcObj.Year_2_Net_Price__c = qli.SBQQ__NetPrice__c + (fcObj.Year_2_Net_Price__c==null? 0:fcObj.Year_2_Net_Price__c);
                    fcObj.Year_2_Quantity__c = qli.SBQQ__Quantity__c + (fcObj.Year_2_Quantity__c==null? 0:fcObj.Year_2_Quantity__c);
                    fcObj.Year_2_Rackrate__c = qli.Rack_Rate__c + (fcObj.Year_2_List_price__c==null? 0:fcObj.Year_2_List_price__c);
                    
                    // dates for 1st year from Quote and for subsequent years from Quote Json
                    if(quoteObject.outyearMap != null){
                            Map<Integer,CventMyd_Outyear> outyearMap  = quoteObject.outyearMap;
                            fcObj.Year_2_start_date__c = outyearMap.get(Integer.valueOf(qli.term__c)).startDate;
                            fcObj.Year_2_end_date__c = outyearMap.get(Integer.valueOf(qli.term__c)).endDate;
                    }
                    
                } if (qli.term__c == qli.SBQQ__Quote__r.Current_Year__c+2) {
                    fcObj.Term_3__c = qli.term__c;
                    fcObj.Year_3_discount__c= qli.SBQQ__Discount__c;
                    fcObj.Year_3_Compound_Discount__c = qli.SBQQ__TotalDiscountRate__c;
                    fcObj.Year_3_effective_Quantity__c = qli.SBQQ__EffectiveQuantity__c+ (fcObj.Year_3_effective_Quantity__c==null? 0:fcObj.Year_3_effective_Quantity__c);
                    fcObj.Year_3_List_price__c = qli.SBQQ__ListPrice__c + (fcObj.Year_3_List_price__c==null? 0:fcObj.Year_3_List_price__c);
                    fcObj.Year_3_List_total__c = qli.SBQQ__ListTotal__c + (fcObj.Year_3_List_total__c==null? 0:fcObj.Year_3_List_total__c);
                    fcObj.Year_3_Net_Amount__c = qli.SBQQ__NetTotal__c + (fcObj.Year_3_Net_Amount__c==null? 0:fcObj.Year_3_Net_Amount__c);
                    fcObj.Year_3_Net_Price__c = qli.SBQQ__NetPrice__c + (fcObj.Year_3_Net_Price__c==null? 0:fcObj.Year_3_Net_Price__c);
                    fcObj.Year_3_Quantity__c = qli.SBQQ__Quantity__c + (fcObj.Year_3_Quantity__c==null? 0:fcObj.Year_3_Quantity__c);
                    fcObj.Year_3_Rackrate__c = qli.Rack_Rate__c + (fcObj.Year_3_List_price__c==null? 0:fcObj.Year_3_List_price__c);
                    
                    // dates for 1st year from Quote and for subsequent years from Quote Json
                    if(quoteObject.outyearMap != null){
                            Map<Integer,CventMyd_Outyear> outyearMap  = quoteObject.outyearMap;
                            fcObj.Year_3_start_date__c = outyearMap.get(Integer.valueOf(qli.term__c)).startDate;
                            fcObj.Year_3_end_date__c = outyearMap.get(Integer.valueOf(qli.term__c)).endDate;
                    }
            
                    
                } if (qli.term__c == qli.SBQQ__Quote__r.Current_Year__c+3) {
                    fcObj.Term_4__c = qli.term__c;
                    fcObj.Year_4_discount__c= qli.SBQQ__Discount__c;
                    fcObj.Year_4_Compound_Discount__c = qli.SBQQ__TotalDiscountRate__c;
                    fcObj.Year_4_effective_Quantity__c = qli.SBQQ__EffectiveQuantity__c+ (fcObj.Year_4_effective_Quantity__c==null? 0:fcObj.Year_4_effective_Quantity__c);
                    fcObj.Year_4_List_price__c = qli.SBQQ__ListPrice__c + (fcObj.Year_4_List_price__c==null? 0:fcObj.Year_4_List_price__c);
                    fcObj.Year_4_List_total__c = qli.SBQQ__ListTotal__c + (fcObj.Year_4_List_total__c==null? 0:fcObj.Year_4_List_total__c);
                    fcObj.Year_4_Net_Amount__c = qli.SBQQ__NetTotal__c + (fcObj.Year_4_Net_Amount__c==null? 0:fcObj.Year_4_Net_Amount__c);
                    fcObj.Year_4_Net_Price__c = qli.SBQQ__NetPrice__c + (fcObj.Year_4_Net_Price__c==null? 0:fcObj.Year_4_Net_Price__c);
                    fcObj.Year_4_Quantity__c = qli.SBQQ__Quantity__c + (fcObj.Year_4_Quantity__c==null? 0:fcObj.Year_4_Quantity__c);
                    fcObj.Year_4_Rackrate__c = qli.Rack_Rate__c + (fcObj.Year_4_List_price__c==null? 0:fcObj.Year_4_List_price__c);
                    if(quoteObject.outyearMap != null){
                            Map<Integer,CventMyd_Outyear> outyearMap  = quoteObject.outyearMap;
                            fcObj.Year_4_start_date__c = outyearMap.get(Integer.valueOf(qli.term__c)).startDate;
                            fcObj.Year_4_end_date__c = outyearMap.get(Integer.valueOf(qli.term__c)).endDate;
                    }
                        
                } if (qli.term__c == qli.SBQQ__Quote__r.Current_Year__c+4) {
                    fcObj.Term_5__c = qli.term__c;
                    fcObj.Year_5_discount__c= qli.SBQQ__Discount__c;
                    fcObj.Year_5_Compound_Discount__c = qli.SBQQ__TotalDiscountRate__c;
                    fcObj.Year_5_effective_Quantity__c = qli.SBQQ__EffectiveQuantity__c+ (fcObj.Year_5_effective_Quantity__c==null? 0:fcObj.Year_5_effective_Quantity__c);
                    fcObj.Year_5_List_price__c = qli.SBQQ__ListPrice__c + (fcObj.Year_5_List_price__c==null? 0:fcObj.Year_5_List_price__c);
                    fcObj.Year_5_List_total__c = qli.SBQQ__ListTotal__c + (fcObj.Year_5_List_total__c==null? 0:fcObj.Year_5_List_total__c);
                    fcObj.Year_5_Net_Amount__c = qli.SBQQ__NetTotal__c + (fcObj.Year_5_Net_Amount__c==null? 0:fcObj.Year_5_Net_Amount__c);
                    fcObj.Year_5_Net_Price__c = qli.SBQQ__NetPrice__c + (fcObj.Year_5_Net_Price__c==null? 0:fcObj.Year_5_Net_Price__c);
                    fcObj.Year_5_Quantity__c = qli.SBQQ__Quantity__c + (fcObj.Year_5_Quantity__c==null? 0:fcObj.Year_5_Quantity__c);
                    fcObj.Year_5_Rackrate__c = qli.Rack_Rate__c + (fcObj.Year_5_List_price__c==null? 0:fcObj.Year_5_List_price__c);
                    
                    // dates for 1st year from Quote and for subsequent years from Quote Json
                    if(quoteObject.outyearMap != null){
                            Map<Integer,CventMyd_Outyear> outyearMap  = quoteObject.outyearMap;
                            fcObj.Year_5_start_date__c = outyearMap.get(Integer.valueOf(qli.term__c)).startDate;
                            fcObj.Year_5_end_date__c = outyearMap.get(Integer.valueOf(qli.term__c)).endDate;
                    }
                }     
            // non variable     
            } else {
                   // contract extension scenario for non variables
                    Integer int_extensionNums = qli.SBQQ__Quote__r.Contract_Extension__c != null ? (Integer.valueOf(qli.SBQQ__Quote__r.Contract_Term_Years__c)-Integer.valueOf(qli.SBQQ__Quote__r.Contract_Extension__c)): Integer.valueOf(qli.SBQQ__Quote__r.Contract_Term_Years__c);                  
                    fcObj.Term_1__c = qli.SBQQ__Quote__r.Current_Year__c;
                    fcObj.Year_1_discount__c= qli.SBQQ__Discount__c;
                    fcObj.Year_1_Compound_Discount__c = qli.SBQQ__TotalDiscountRate__c;
                    fcObj.Year_1_effective_Quantity__c = qli.SBQQ__EffectiveQuantity__c+ (fcObj.Year_1_effective_Quantity__c==null?0:fcObj.Year_1_effective_Quantity__c);
                    fcObj.Year_1_List_price__c = qli.SBQQ__ListPrice__c + (fcObj.Year_1_List_price__c== null?0:fcObj.Year_1_List_price__c);
                    fcObj.Year_1_List_total__c = qli.SBQQ__ListTotal__c + (fcObj.Year_1_List_total__c==null?0:fcObj.Year_1_List_total__c);
                    fcObj.Year_1_Net_Amount__c = qli.SBQQ__NetTotal__c + (fcObj.Year_1_Net_Amount__c==null?0:fcObj.Year_1_Net_Amount__c);
                    fcObj.Year_1_Net_Price__c = qli.SBQQ__NetPrice__c + (fcObj.Year_1_Net_Price__c==null?0:fcObj.Year_1_Net_Price__c);
                    fcObj.Year_1_Quantity__c = qli.SBQQ__Quantity__c + (fcObj.Year_1_Quantity__c==null?0:fcObj.Year_1_Quantity__c);
                    fcObj.Year_1_Rackrate__c = qli.Rack_Rate__c + (fcObj.Year_1_Rackrate__c ==null?0:fcObj.Year_1_Rackrate__c);
                    
                    // dates for 1st year from Quote and for subsequent years from Quote Json
                    fcObj.Year_1_start_date__c =qli.SBQQ__Quote__r.SBQQ__StartDate__c;
                    fcObj.Year_1_end_date__c =qli.SBQQ__Quote__r.SBQQ__EndDate__c;
                    
                    if(quoteObject.outyearMap != null){
                        if(qli.SBQQ__Quote__r.Current_Year__c+1 <= Integer.valueOf(qli.SBQQ__Quote__r.Contract_Term_Years__c)){
                    
                            fcObj.Term_2__c = qli.SBQQ__Quote__r.Current_Year__c+1;
                            fcObj.Year_2_discount__c= qli.SBQQ__Discount__c;
                            fcObj.Year_2_Compound_Discount__c = qli.SBQQ__TotalDiscountRate__c;
                            fcObj.Year_2_effective_Quantity__c = qli.SBQQ__EffectiveQuantity__c+ (fcObj.Year_2_effective_Quantity__c==null?0:fcObj.Year_2_effective_Quantity__c);
                            fcObj.Year_2_List_price__c = qli.SBQQ__ListPrice__c +(fcObj.Year_2_List_price__c==null?0:fcObj.Year_2_List_price__c);
                            fcObj.Year_2_List_total__c = qli.SBQQ__ListTotal__c + (fcObj.Year_2_List_total__c==null?0:fcObj.Year_2_List_total__c);
                            fcObj.Year_2_Net_Amount__c = (fcObj.Year_2_Net_Amount__c==null?0:fcObj.Year_2_Net_Amount__c);
                            
                            if(qli.SBQQ__Quote__r.Current_Year__c+1 > int_extensionNums && int_extensionNums != Integer.valueOf(qli.SBQQ__Quote__r.Contract_Term_Years__c)){
                                if(qli.SBQQ__NetTotal__c != 0 && qli.SBQQ__NetTotal__c!= null){
                                    fcObj.Year_2_Net_Amount__c = qli.SBQQ__NetTotal__c + fcObj.Year_2_Net_Amount__c;
                                } 
                                else if(qli.SBQQ__UpgradedSubscription__c != null ) {
                                    fcObj.Year_2_Net_Amount__c = (qli.SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__r.SBQQ__NetTotal__c == null ? fcObj.Year_2_Net_Amount__c : qli.SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__r.SBQQ__NetTotal__c+fcObj.Year_2_Net_Amount__c);
                                }
                            }
                            else {
                                fcObj.Year_2_Net_Amount__c = (qli.SBQQ__NetTotal__c == null ? fcObj.Year_2_Net_Amount__c : qli.SBQQ__NetTotal__c + fcObj.Year_2_Net_Amount__c);
                            }
                            
                            fcObj.Year_2_Net_Price__c = qli.SBQQ__NetPrice__c + (fcObj.Year_2_Net_Price__c==null?0:fcObj.Year_2_Net_Price__c);
                            fcObj.Year_2_Quantity__c = qli.SBQQ__Quantity__c + (fcObj.Year_2_Quantity__c==null?0:fcObj.Year_2_Quantity__c);
                            fcObj.Year_2_Rackrate__c = qli.Rack_Rate__c + (fcObj.Year_2_Rackrate__c ==null?0:fcObj.Year_2_Rackrate__c);
                            Map<Integer,CventMyd_Outyear> outyearMap  = quoteObject.outyearMap;
                            fcObj.Year_2_start_date__c = outyearMap.get(Integer.valueOf(qli.SBQQ__Quote__r.Current_Year__c+1)).startDate;
                            fcObj.Year_2_end_date__c = outyearMap.get(Integer.valueOf(qli.SBQQ__Quote__r.Current_Year__c+1)).endDate;
                        }      
                    } 
                    if(quoteObject.outyearMap != null){
                        if(qli.SBQQ__Quote__r.Current_Year__c+2 <= Integer.valueOf(qli.SBQQ__Quote__r.Contract_Term_Years__c)){
                    
                            fcObj.Term_3__c = qli.SBQQ__Quote__r.Current_Year__c+2;
                            fcObj.Year_3_discount__c= qli.SBQQ__Discount__c;
                            fcObj.Year_3_Compound_Discount__c = qli.SBQQ__TotalDiscountRate__c;
                            fcObj.Year_3_effective_Quantity__c = qli.SBQQ__EffectiveQuantity__c+ (fcObj.Year_3_effective_Quantity__c==null?0:fcObj.Year_3_effective_Quantity__c);
                            fcObj.Year_3_List_price__c = qli.SBQQ__ListPrice__c +(fcObj.Year_3_List_price__c==null?0:fcObj.Year_3_List_price__c);
                            fcObj.Year_3_List_total__c = qli.SBQQ__ListTotal__c + (fcObj.Year_3_List_total__c==null?0:fcObj.Year_3_List_total__c);
                            fcObj.Year_3_Net_Amount__c = (fcObj.Year_3_Net_Amount__c==null?0:fcObj.Year_3_Net_Amount__c);
                            fcObj.Year_3_Net_Price__c = qli.SBQQ__NetPrice__c + (fcObj.Year_3_Net_Price__c==null?0:fcObj.Year_3_Net_Price__c);
                            fcObj.Year_3_Quantity__c = qli.SBQQ__Quantity__c + (fcObj.Year_3_Quantity__c==null?0:fcObj.Year_3_Quantity__c);
                            fcObj.Year_3_Rackrate__c = qli.Rack_Rate__c + (fcObj.Year_3_Rackrate__c==null?0:fcObj.Year_3_Rackrate__c);
                            
                            if(qli.SBQQ__Quote__r.Current_Year__c+2 > int_extensionNums && int_extensionNums != Integer.valueOf(qli.SBQQ__Quote__r.Contract_Term_Years__c)){
                                if(qli.SBQQ__NetTotal__c != 0 && qli.SBQQ__NetTotal__c!= null){
                                    fcObj.Year_3_Net_Amount__c = qli.SBQQ__NetTotal__c + fcObj.Year_3_Net_Amount__c;
                                } 
                                else if(qli.SBQQ__UpgradedSubscription__c != null ) {
                                    fcObj.Year_3_Net_Amount__c = (qli.SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__r.SBQQ__NetTotal__c == null ? fcObj.Year_3_Net_Amount__c : qli.SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__r.SBQQ__NetTotal__c+fcObj.Year_3_Net_Amount__c);
                                }
                            }
                            else {
                                fcObj.Year_3_Net_Amount__c = (qli.SBQQ__NetTotal__c == null ? fcObj.Year_3_Net_Amount__c : qli.SBQQ__NetTotal__c + fcObj.Year_3_Net_Amount__c);
                            }
                            
                            
                            Map<Integer,CventMyd_Outyear> outyearMap  = quoteObject.outyearMap;
                            fcObj.Year_3_start_date__c = outyearMap.get(Integer.valueOf(qli.SBQQ__Quote__r.Current_Year__c+2)).startDate;
                            fcObj.Year_3_end_date__c = outyearMap.get(Integer.valueOf(qli.SBQQ__Quote__r.Current_Year__c+2)).endDate;
                        }      
                    }
                    if(quoteObject.outyearMap != null){
                        if(qli.SBQQ__Quote__r.Current_Year__c+3 <= Integer.valueOf(qli.SBQQ__Quote__r.Contract_Term_Years__c)){
                    
                            fcObj.Term_4__c = qli.SBQQ__Quote__r.Current_Year__c+3;
                            fcObj.Year_4_discount__c= qli.SBQQ__Discount__c;
                            fcObj.Year_4_Compound_Discount__c = qli.SBQQ__TotalDiscountRate__c;
                            fcObj.Year_4_effective_Quantity__c = qli.SBQQ__EffectiveQuantity__c+ (fcObj.Year_4_effective_Quantity__c==null?0:fcObj.Year_4_effective_Quantity__c);
                            fcObj.Year_4_List_price__c = qli.SBQQ__ListPrice__c +(fcObj.Year_4_List_price__c==null?0:fcObj.Year_4_List_price__c);
                            fcObj.Year_4_List_total__c = qli.SBQQ__ListTotal__c + (fcObj.Year_4_List_total__c==null?0:fcObj.Year_4_List_total__c);
                            fcObj.Year_4_Net_Amount__c = (fcObj.Year_4_Net_Amount__c==null?0:fcObj.Year_4_Net_Amount__c);
                            if(qli.SBQQ__Quote__r.Current_Year__c+3 > int_extensionNums && int_extensionNums != Integer.valueOf(qli.SBQQ__Quote__r.Contract_Term_Years__c)){
                                if(qli.SBQQ__NetTotal__c != 0 && qli.SBQQ__NetTotal__c!= null){
                                    fcObj.Year_4_Net_Amount__c = qli.SBQQ__NetTotal__c + fcObj.Year_4_Net_Amount__c;
                                } 
                                else if(qli.SBQQ__UpgradedSubscription__c != null ) {
                                    fcObj.Year_4_Net_Amount__c = (qli.SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__r.SBQQ__NetTotal__c == null ? fcObj.Year_4_Net_Amount__c : qli.SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__r.SBQQ__NetTotal__c+fcObj.Year_4_Net_Amount__c);
                                }
                            }
                            else {
                                fcObj.Year_4_Net_Amount__c = (qli.SBQQ__NetTotal__c == null ? fcObj.Year_4_Net_Amount__c : qli.SBQQ__NetTotal__c + fcObj.Year_4_Net_Amount__c);
                            }
                            fcObj.Year_4_Net_Price__c = qli.SBQQ__NetPrice__c + (fcObj.Year_4_Net_Price__c==null?0:fcObj.Year_4_Net_Price__c);
                            fcObj.Year_4_Quantity__c = qli.SBQQ__Quantity__c + (fcObj.Year_4_Quantity__c==null?0:fcObj.Year_4_Quantity__c);
                            fcObj.Year_4_Rackrate__c = qli.Rack_Rate__c + (fcObj.Year_4_Rackrate__c==null?0:fcObj.Year_4_Rackrate__c);
                            Map<Integer,CventMyd_Outyear> outyearMap  = quoteObject.outyearMap;
                            fcObj.Year_4_start_date__c = outyearMap.get(Integer.valueOf(qli.SBQQ__Quote__r.Current_Year__c+3)).startDate;
                            fcObj.Year_4_end_date__c = outyearMap.get(Integer.valueOf(qli.SBQQ__Quote__r.Current_Year__c+3)).endDate;
                        }      
                    }
                    if(quoteObject.outyearMap != null){
                        if(qli.SBQQ__Quote__r.Current_Year__c+4 <= Integer.valueOf(qli.SBQQ__Quote__r.Contract_Term_Years__c)){
                    
                            fcObj.Term_5__c = qli.SBQQ__Quote__r.Current_Year__c+4;
                            fcObj.Year_5_discount__c= qli.SBQQ__Discount__c;
                            fcObj.Year_5_Compound_Discount__c = qli.SBQQ__TotalDiscountRate__c;
                            fcObj.Year_5_effective_Quantity__c = qli.SBQQ__EffectiveQuantity__c+ (fcObj.Year_5_effective_Quantity__c==null?0:fcObj.Year_5_effective_Quantity__c);
                            fcObj.Year_5_List_price__c = qli.SBQQ__ListPrice__c +(fcObj.Year_5_List_price__c==null?0:fcObj.Year_5_List_price__c);
                            fcObj.Year_5_List_total__c = qli.SBQQ__ListTotal__c + (fcObj.Year_5_List_total__c==null?0:fcObj.Year_5_List_total__c);
                            fcObj.Year_5_Net_Amount__c = (fcObj.Year_5_Net_Amount__c==null?0:fcObj.Year_5_Net_Amount__c);
                            if(qli.SBQQ__Quote__r.Current_Year__c+4 > int_extensionNums && int_extensionNums != Integer.valueOf(qli.SBQQ__Quote__r.Contract_Term_Years__c)){
                                if(qli.SBQQ__NetTotal__c != 0 && qli.SBQQ__NetTotal__c!= null){
                                    fcObj.Year_5_Net_Amount__c = qli.SBQQ__NetTotal__c + fcObj.Year_5_Net_Amount__c;
                                } 
                                else if(qli.SBQQ__UpgradedSubscription__c != null ) {
                                    fcObj.Year_5_Net_Amount__c = (qli.SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__r.SBQQ__NetTotal__c == null ? fcObj.Year_5_Net_Amount__c : qli.SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__r.SBQQ__NetTotal__c+fcObj.Year_5_Net_Amount__c);
                                }
                            }
                            else {
                                fcObj.Year_5_Net_Amount__c = (qli.SBQQ__NetTotal__c == null ? fcObj.Year_5_Net_Amount__c : qli.SBQQ__NetTotal__c + fcObj.Year_5_Net_Amount__c);
                            }
                            fcObj.Year_5_Net_Price__c = qli.SBQQ__NetPrice__c + (fcObj.Year_5_Net_Price__c==null?0:fcObj.Year_5_Net_Price__c);
                            fcObj.Year_5_Quantity__c = qli.SBQQ__Quantity__c + (fcObj.Year_5_Quantity__c==null?0:fcObj.Year_5_Quantity__c);
                            fcObj.Year_5_Rackrate__c = qli.Rack_Rate__c + (fcObj.Year_5_Rackrate__c==null?0:fcObj.Year_5_Rackrate__c);
                            Map<Integer,CventMyd_Outyear> outyearMap  = quoteObject.outyearMap;
                            fcObj.Year_5_start_date__c = outyearMap.get(Integer.valueOf(qli.SBQQ__Quote__r.Current_Year__c+4)).startDate;
                            fcObj.Year_5_end_date__c = outyearMap.get(Integer.valueOf(qli.SBQQ__Quote__r.Current_Year__c+4)).endDate;
                        }      
                    }
            } 
            
            return fcObj;
        
    }
      

    /**
     * Delete finance commision for newly created or updated FinanceShell 
     * 15 Jan 2019
    **/
    public void deleteFinanceCommision(List<Finance_Shell__c> lstNewFinanceShells){
        Set<Id> setFinanceShell = new Set<Id>();
        for(Finance_Shell__c lstItr : lstNewFinanceShells){
            if(!lstItr.Locked__c){
                setFinanceShell.add(lstItr.Id);
            }
        }
        String queryFinanceCommision = 'SELECT Id FROM Finance_Commission__c WHERE Finance_shell__c IN :setFinanceShell';
        //System.debug('queryFinanceCommision-->' + queryFinanceCommision);
        List<Finance_Commission__c> lstFinanceCommision = Database.query(queryFinanceCommision);
        Database.DeleteResult[] delFinanceCommisions = Database.delete(lstFinanceCommision);
        System.debug(' Commision Records Deleted');
    }
    
    public void deleteFinanceBudget(List<Finance_Shell__c> lstNewFinanceShells){
        Set<Id> setFinanceShell = new Set<Id>();
        for(Finance_Shell__c lstItr : lstNewFinanceShells){
            if(!lstItr.Locked__c){
                setFinanceShell.add(lstItr.Id);
            }
        }
        String queryFinanceBudget = 'SELECT Id FROM Finance_Budget__c WHERE Finance_shell__c IN :setFinanceShell';
        System.debug('queryFinanceBudget-->' + queryFinanceBudget);
        List<Finance_Budget__c> lstFinanceBudget = Database.query(queryFinanceBudget);
        Database.DeleteResult[] delFinanceBudget = Database.delete(lstFinanceBudget);
        System.debug('Records Deleted');
    }
    
    
    public static void createFinanceBudget(List<Finance_Shell__c> lstNewFinanceShells)
    {
        //if it's none MYD 1 to many, if true 1 to 1
        Set<Id> setAllQuoteIds = new Set<Id>();
        Set<Id> setMYDQuoteIds = new Set<Id>();
        Set<Id> setNotMYDQuoteIds = new Set<Id>();
        Map<String, Finance_Shell__c> map_FS = new Map<String, Finance_Shell__c>();
        List<Finance_Budget__c> lst_FB = new List<Finance_Budget__c>();
        for(Finance_Shell__c lstItr : lstNewFinanceShells){ 
            if(lstItr.Variable_Options__c == true){
                setMYDQuoteIds.add(lstItr.Quote_ID__c);
            }
            else{
                setNotMYDQuoteIds.add(lstItr.Quote_ID__c);
            }
            setAllQuoteIds.add(lstItr.Quote_ID__c);
            map_FS.put(lstItr.Quote_ID__c, lstItr);
        }
        
        List<SBQQ__QuoteLine__c> lstQuoteLines = [SELECT Id,
                                                         SBQQ__Quote__c,
                                                         SBQQ__Product__c,
                                                         SBQQ__ProductCode__c,
                                                         SBQQ__ProductFamily__c,
                                                         SBQQ__RequiredBy__c,
                                                         SBQQ__Discount__c,
                                                         SBQQ__EffectiveQuantity__c,
                                                         SBQQ__EndDate__c,
                                                         SBQQ__StartDate__c,
                                                         SBQQ__ListPrice__c,
                                                         SBQQ__NetTotal__c,
                                                         SBQQ__Quantity__c,
                                                         SBQQ__TotalDiscountRate__c,
                                                         SBQQ__ListTotal__c,
                                                         Revenue_Type__c,
                                                         Rack_Rate__c,
                                                         SBQQ__AdditionalDiscount__c,
                                                         Cloned_from_Quote_Line__c,
                                                         term__c,
                                                         SBQQ__Quote__r.SBQQ__EndDate__c,
                                                         SBQQ__Quote__r.SBQQ__StartDate__c,
                                                         SBQQ__NetPrice__c,
                                                         SBQQ__Quote__r.Contract_Term__c,
                                                         SBQQ__Quote__r.Contract_Term_Years__c,
                                                         SBQQ__Quote__r.Current_Year__c,
                                                         SBQQ__Quote__r.Multiple_Years_Commitment__c,
                                                         SBQQ__Quote__r.Contract_Remaining_Term__c,
                                                         SBQQ__Quote__r.SBQQ__Opportunity2__r.OwnerId,
                                                         SBQQ__Quote__r.CurrencyIsoCode,
                                                       SBQQ__Quote__r.Contract_Extension__c,
                                                         SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__r.SBQQ__NetTotal__c,
                                                         SBQQ__RequiredBy__r.SBQQ__Product__c,
                                                         SBQQ__EffectiveStartDate__c,
                                                         SBQQ__EffectiveEndDate__c,
                                                         SBQQ__Quote__r.jsonString__c,
                                                         jsonString__c
                                                    FROM SBQQ__QuoteLine__c 
                                                   WHERE SBQQ__Quote__c IN :setAllQuoteIds];
System.debug(setAllQuoteIds);
        Map<Id,Map<String,List<SBQQ__QuoteLine__c>>> mapQuoteLines = new Map<Id,Map<String,List<SBQQ__QuoteLine__c>>>();
        Map<String,List<SBQQ__QuoteLine__c>> mapProductLines = new Map<String,List<SBQQ__QuoteLine__c>>();
        System.debug(lstQuoteLines);
        for(SBQQ__QuoteLine__c lp : lstQuoteLines)
        {
         
            if(setMYDQuoteIds.contains(lp.SBQQ__Quote__c)){
                Date startDate = lp.SBQQ__EffectiveStartDate__c;
                Date endDate = lp.SBQQ__EffectiveEndDate__c;
                if(!Test.isRunningTest()){   
                    if(Integer.valueOf(lp.term__c)!=Integer.valueOf(lp.SBQQ__Quote__r.Current_Year__c)){
                        CventMyd_QuoteObject quoteObject = new CventMyd_QuoteObject();
                        quoteObject = (CventMyd_QuoteObject)JSON.deserialize(lp.SBQQ__Quote__r.jsonString__c,CventMyd_QuoteObject.class); 
                        if(quoteObject.outyearMap != null){
                            Map<Integer,CventMyd_Outyear> outyearMap  = quoteObject.outyearMap;
                            startDate = outyearMap.get(Integer.valueOf(lp.term__c)).startDate;
                            endDate = outyearMap.get(Integer.valueOf(lp.term__c)).endDate;
                        }
                    }  
                    else {
                        startDate = lp.SBQQ__Quote__r.SBQQ__StartDate__c;
                        endDate = lp.SBQQ__Quote__r.SBQQ__EndDate__c;
                    }                  
                }
                Finance_Budget__c newFB = updateFinanceBudget(lp, map_FS,startDate, endDate, lp.term__c, false,false);
                lst_FB.add(newFB);
            }
            else if(setNotMYDQuoteIds.contains(lp.SBQQ__Quote__c)){
                Decimal dec_term = lp.term__c;
                System.debug('lp.term__c;' + lp.term__c);
                //need to use Contract term year instead of contract remaining term
                //extension - Contract_Term_Years__c.. end point 
                CventMyd_QuoteObject quoteObject = new CventMyd_QuoteObject();
                quoteObject = (CventMyd_QuoteObject)JSON.deserialize(lp.SBQQ__Quote__r.jsonString__c,CventMyd_QuoteObject.class); 
                Date dt_startDate = lp.SBQQ__Quote__r.SBQQ__StartDate__c;
                Date dt_endDate = lp.SBQQ__Quote__r.SBQQ__EndDate__c;
                Integer int_extensionNums = lp.SBQQ__Quote__r.Contract_Extension__c != null ? (Integer.valueOf(lp.SBQQ__Quote__r.Contract_Term_Years__c)-Integer.valueOf(lp.SBQQ__Quote__r.Contract_Extension__c)): Integer.valueOf(lp.SBQQ__Quote__r.Contract_Term_Years__c);
                for(Integer i =(Integer)lp.SBQQ__Quote__r.Current_Year__c; i<= Integer.valueOf(lp.SBQQ__Quote__r.Contract_Term_Years__c); i++) {
                    Finance_Budget__c newFB = new Finance_Budget__c(); 
                    if(i != (Integer)lp.SBQQ__Quote__r.Current_Year__c){
                        if(quoteObject.outyearMap != null){
                            Map<Integer,CventMyd_Outyear> outyearMap  = quoteObject.outyearMap;
                            system.debug('quoteObject >> ' + JSON.serialize(quoteObject));
                            system.debug('quoteObject >> outyearMap >> ' + JSON.serialize(outyearMap));
                            system.debug('quoteObject >> dec_term >> ' + dec_term);
                            system.debug('quoteObject >> lp >> ' + JSON.serialize(lp));
                            dt_startDate = outyearMap.get(Integer.valueOf(dec_term)).startDate;
                            dt_endDate = outyearMap.get(Integer.valueOf(dec_term )).endDate;
                        }
                        if(i > int_extensionNums && int_extensionNums != Integer.valueOf(lp.SBQQ__Quote__r.Contract_Term_Years__c)){ newFB = updateFinanceBudget(lp, map_FS,dt_startDate, dt_endDate, dec_term, true,true);}else{ newFB = updateFinanceBudget(lp, map_FS,dt_startDate, dt_endDate, dec_term, false, true); }
                         
                    }
                    else {
                        if(i > int_extensionNums && int_extensionNums != Integer.valueOf(lp.SBQQ__Quote__r.Contract_Term_Years__c)){newFB = updateFinanceBudget(lp, map_FS,dt_startDate, dt_endDate, dec_term, true,false);} else{ newFB = updateFinanceBudget(lp, map_FS,dt_startDate, dt_endDate, dec_term, false, false);} dt_startDate = lp.SBQQ__Quote__r.SBQQ__StartDate__c; dt_endDate = lp.SBQQ__Quote__r.SBQQ__EndDate__c;

                    }
              //      if(i!=(Integer)lp.SBQQ__Quote__r.Current_Year__c){
                       
                 //   }
                    dec_term =  dec_term+1; lst_FB.add(newFB);
                }
            }             
        }
        if(lst_FB.size()>0){
            System.debug(lst_FB);
            upsert lst_FB;
        }
    }
   /* public static Finance_Budget__c updateFinanceBudget(SBQQ__QuoteLine__c lp, Map<String, Finance_Shell__c> map_FS, Date dt_startDate, Date dt_endDate, Decimal dec_term, Boolean boo_Extension)
    {
        Finance_Budget__c newFB = new Finance_Budget__c();
        newFB.Active_Contract_year__c = lp.SBQQ__Quote__r.Current_Year__c;
        //Decimal currRate = mapCurrencyConv.get(lp.SBQQ__Quote__r.CurrencyIsoCode);
        newFB.Compound_Discount__c = lp.SBQQ__TotalDiscountRate__c;
        newFB.Contract_Expired__c = map_FS.containsKey(lp.SBQQ__Quote__c) ? map_FS.get(lp.SBQQ__Quote__c).Contract_Expired__c : false;
        newFB.Contract_Received_Date__c = map_FS.containsKey(lp.SBQQ__Quote__c) ? map_FS.get(lp.SBQQ__Quote__c).Contract_Received_Date__c : null;
        newFB.Discount__c = lp.SBQQ__AdditionalDiscount__c;   
        newFB.Effective_Quantity__c = lp.SBQQ__EffectiveQuantity__c;
        newFB.End_Date__c = dt_endDate;//lp.SBQQ__EndDate__c; //In case of non variable this will be changing depending on for loop iterator
        newFB.Finance_Shell__c = map_FS.get(lp.SBQQ__Quote__c).Id;
        newFB.Full_Contract_End_Date__c = map_FS.containsKey(lp.SBQQ__Quote__c) ? map_FS.get(lp.SBQQ__Quote__c).Parent_Contract_End_Date__c : null;
        newFB.Full_Contract_Start_Date__c = map_FS.containsKey(lp.SBQQ__Quote__c) ? map_FS.get(lp.SBQQ__Quote__c).Parent_Contract_Start_Date__c : null;
        newFB.Full_contract_term__c = Integer.valueOf(lp.SBQQ__Quote__r.Contract_Term_Years__c);
        newFB.List_price__c = (lp.SBQQ__ListPrice__c);
        newFB.List_total__c = (lp.SBQQ__ListTotal__c);
        newFB.Net_Amount__c =boo_Extension ? lp.SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__r.SBQQ__NetTotal__c : (lp.SBQQ__NetTotal__c); //coming from condition boo_Extension  
        newFB.Net_Price__c = (lp.SBQQ__NetPrice__c);
        newFB.CurrencyIsoCode= lp.SBQQ__Quote__r.CurrencyIsoCode;
        newFB.Opportunity_Owner__c = lp.SBQQ__Quote__r.SBQQ__Opportunity2__r.OwnerId;
        newFB.Parent_product__c = lp.SBQQ__RequiredBy__r.SBQQ__Product__c;
        newFB.Product__c = lp.SBQQ__Product__c;
        newFB.ProductCode__c = lp.SBQQ__ProductCode__c;
        newFB.product_family__c = lp.SBQQ__ProductFamily__c;
        newFB.Product_Revenue_type__c = lp.Revenue_Type__c;
        newFB.Quantity__c = lp.SBQQ__Quantity__c;        //newFB.Quote__c = lp.SBQQ__Quote__c;//this is a formula field
        newFB.Quote_Line__c = lp.id;
        newFB.Rackrate__c = lp.Rack_Rate__c;
        newFB.Start_Date__c = dt_startDate;//lp.SBQQ__StartDate__c; //In case of non variable this will be changing depending on for loop iterator
        newFB.Term__c = dec_term;//lp.term__c; //In case of non variable this will be changing depending on for loop iterator
        newFB.Type__c = 'New';
        if(map_FS.get(lp.SBQQ__Quote__c).Opportunity_type__c =='Amendment') {
            newFB.Type__c = 'Amendment';
        } else if(map_FS.get(lp.SBQQ__Quote__c).Opportunity_type__c == 'Renewal') {
            newFB.Type__c = 'Renewal';
        }

        return newFB;
    }*/
    public static Finance_Budget__c updateFinanceBudget(SBQQ__QuoteLine__c lp, Map<String, Finance_Shell__c> map_FS, Date dt_startDate, Date dt_endDate, Decimal dec_term, Boolean boo_Extension, Boolean isProrated)
    {
        Finance_Budget__c newFB = new Finance_Budget__c();
        newFB.Active_Contract_year__c = lp.SBQQ__Quote__r.Current_Year__c;
        //Decimal currRate = mapCurrencyConv.get(lp.SBQQ__Quote__r.CurrencyIsoCode);
        newFB.Compound_Discount__c = lp.SBQQ__TotalDiscountRate__c;
        newFB.Contract_Expired__c = map_FS.containsKey(lp.SBQQ__Quote__c) ? map_FS.get(lp.SBQQ__Quote__c).Contract_Expired__c : false;
        newFB.Contract_Received_Date__c = map_FS.containsKey(lp.SBQQ__Quote__c) ? map_FS.get(lp.SBQQ__Quote__c).Contract_Received_Date__c : null;
        newFB.Discount__c = lp.SBQQ__AdditionalDiscount__c;   
        newFB.Effective_Quantity__c = lp.SBQQ__EffectiveQuantity__c;
        newFB.End_Date__c = dt_endDate;//lp.SBQQ__EndDate__c; //In case of non variable this will be changing depending on for loop iterator
        newFB.Finance_Shell__c = map_FS.get(lp.SBQQ__Quote__c).Id;
        newFB.Full_Contract_End_Date__c = map_FS.containsKey(lp.SBQQ__Quote__c) ? map_FS.get(lp.SBQQ__Quote__c).Parent_Contract_End_Date__c : null;
        newFB.Full_Contract_Start_Date__c = map_FS.containsKey(lp.SBQQ__Quote__c) ? map_FS.get(lp.SBQQ__Quote__c).Parent_Contract_Start_Date__c : null;
        newFB.Full_contract_term__c = Integer.valueOf(lp.SBQQ__Quote__r.Contract_Term_Years__c);
        if(isProrated == true){
            newFB.List_price__c = (lp.SBQQ__ListPrice__c );
            newFB.List_total__c = (lp.SBQQ__ListTotal__c);
          //  newFB.Net_Amount__c =boo_Extension ? (lp.SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__r.SBQQ__NetTotal__c ): (lp.SBQQ__NetTotal__c ); //coming from condition boo_Extension  
            if(boo_Extension){
                if(lp.SBQQ__NetTotal__c != 0 && lp.SBQQ__NetTotal__c!= null){
                    newFB.Net_Amount__c = lp.SBQQ__NetTotal__c;
                } 
                else if(lp.SBQQ__UpgradedSubscription__c != null ) {
                    newFB.Net_Amount__c = (lp.SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__r.SBQQ__NetTotal__c == null ? 0 : lp.SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__r.SBQQ__NetTotal__c);
                }
            }
            else {
                newFB.Net_Amount__c = (lp.SBQQ__NetTotal__c == null ? 0 : lp.SBQQ__NetTotal__c);
            }
            newFB.Net_Price__c = (lp.SBQQ__NetPrice__c );
        }
        else {
            newFB.List_price__c = (lp.SBQQ__ListPrice__c);
            newFB.List_total__c = (lp.SBQQ__ListTotal__c); 
            newFB.Net_Price__c = (lp.SBQQ__NetPrice__c);            
            newFB.Net_Amount__c = (lp.SBQQ__NetTotal__c == null ? 0 : lp.SBQQ__NetTotal__c);
           // newFB.CurrencyIsoCode= lp.SBQQ__Quote__r.CurrencyIsoCode;
        }        
        newFB.Opportunity_Owner__c = lp.SBQQ__Quote__r.SBQQ__Opportunity2__r.OwnerId;newFB.Parent_product__c = lp.SBQQ__RequiredBy__r.SBQQ__Product__c;newFB.Product__c = lp.SBQQ__Product__c;
        newFB.ProductCode__c = lp.SBQQ__ProductCode__c;newFB.product_family__c = lp.SBQQ__ProductFamily__c;newFB.Product_Revenue_type__c = lp.Revenue_Type__c;newFB.CurrencyIsoCode= lp.SBQQ__Quote__r.CurrencyIsoCode;newFB.Quantity__c = lp.SBQQ__Quantity__c;        //newFB.Quote__c = lp.SBQQ__Quote__c;//this is a formula field
        newFB.Quote_Line__c = lp.id;newFB.Rackrate__c = lp.Rack_Rate__c;newFB.Start_Date__c = dt_startDate;//lp.SBQQ__StartDate__c; //In case of non variable this will be changing depending on for loop iterator
        newFB.Term__c = dec_term;newFB.Type__c = 'New'; if(map_FS.get(lp.SBQQ__Quote__c).Opportunity_type__c =='Amendment') {
            newFB.Type__c = 'Amendment'; } else if(map_FS.get(lp.SBQQ__Quote__c).Opportunity_type__c == 'Renewal') {newFB.Type__c = 'Renewal'; }

        return newFB;
    }
}