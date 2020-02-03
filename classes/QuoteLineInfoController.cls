/*** Written by Udita for : Email Confirmation through Quote : TICCM-97 ****/
public class QuoteLineInfoController {
    public SBQQ__Quote__c q {get; set;}
    public Id objId {get; set;}
   // public List<SBQQ__QuoteLine__c> quoteLines{get; set;}
    public Map<Decimal, List<SBQQ__QuoteLine__c>> groupedMap{get; set;}
    public Map<Decimal,string> dateMap{get; set;}
    public List<SBQQ__QuoteLine__c> tempList;
    public List<GroupYear> yearGroups {get; set;}
    Set<Id> quoteLineId;
    public Decimal rollUpOverageFee{get; set;}
    public map<id,decimal> overrageMap{get; set;}
    public map<id,decimal> RollupQtyMap{get; set;}
    public map<id,decimal> RollupPriceMap{get; set;}
    
    public QuoteLineInfoController(){
        quoteLineId = new Set<Id>();
        //quoteLines = new List<SBQQ__QuoteLine__c>();
        groupedMap=new Map<Decimal, List<SBQQ__QuoteLine__c>>();
        dateMap=new Map<Decimal, string>();
        q= new SBQQ__Quote__c ();
        yearGroups  = new List<GroupYear>();
        rollUpOverageFee = 0.0;
        overrageMap = new map<id,decimal>();
        RollupQtyMap =  new map<id,decimal>();
        RollupPriceMap = new map<id,decimal>();
    }
    
    public List<GroupYear> getquoteLines1() {
        Decimal sumOfOverrage = 0;
        q=[select id,SBQQ__Type__c,CurrencyISOCode ,Multiple_Years_Commitment__c,Dynamic_Contract_Term_Dates_USD_NONUSD__c,SBQQ__PaymentTerms__c,Contract_Term_Years__c from SBQQ__Quote__c where id =:objId];
          List<SBQQ__QuoteLine__c> quoteLines = [select id,SBQQ__EffectiveStartDate__c,SBQQ__EffectiveEndDate__c,SBQQ__EffectiveQuantity__c,totalRollupPrice__c,Rollup_Quantity__c,SBQQ__ProductCode__c,Overage_Fee__c,rollupQuantityIntoThisBundle__c,rollupIntoBundleForEbs__c,SBQQ__Product__r.Name,term__c,SBQQ__Quantity__c,Custom_Discount__c,SBQQ__NetTotal__c,Discount_Type__c,SBQQ__AdditionalDiscountAmount__c,(select Overage_Fee__c,SBQQ__EffectiveQuantity__c,SBQQ__Quantity__c from SBQQ__Quote_Lines__r) from SBQQ__QuoteLine__c where SBQQ__EffectiveQuantity__c > 0 AND SBQQ__Quote__c = :objId AND rollupIntoBundleForEbs__c != true ORDER BY term__c];
           for(SBQQ__QuoteLine__c ql : quoteLines){
               Decimal rollUpOverageFee = 0.0;
               if(ql.Rollup_Quantity__c <> 0 && ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-OAPREM'){
                  for(SBQQ__QuoteLine__c subQuoteLine : ql.SBQQ__Quote_Lines__r){
                    if(subQuoteLine.Overage_Fee__c != NULL && subQuoteLine.SBQQ__EffectiveQuantity__c <> 0)
                        rollUpOverageFee = (subQuoteLine.Overage_Fee__c * subQuoteLine.SBQQ__EffectiveQuantity__c) + rollUpOverageFee;
                        overrageMap.put(ql.id,rollUpOverageFee/ql.Rollup_Quantity__c); 
                     }                       
               }else{
                  if(ql.Overage_Fee__c == null){
                     overrageMap.put(ql.id,0);}else{overrageMap.put(ql.id,ql.Overage_Fee__c);}
                }
                
                if(ql.rollupQuantityIntoThisBundle__c == TRUE){
                   RollupQtyMap.put(ql.id,ql.Rollup_Quantity__c);
                   RollupPriceMap.put(ql.id,ql.totalRollupPrice__c);
                }else{
                   RollupQtyMap.put(ql.id,ql.SBQQ__EffectiveQuantity__c);
                   RollupPriceMap.put(ql.id,ql.SBQQ__NetTotal__c);
                }
            }
          if((q.SBQQ__Type__c == 'Amendment' || q.SBQQ__Type__c == 'Renewal' || (q.SBQQ__Type__c == 'Quote')) && q.Contract_Term_Years__c == '1'){  
            yearGroups.add(new GroupYear(quoteLines,0,null));
          } 
        if(q.Contract_Term_Years__c != '1' && ((Boolean.ValueOf(q.Multiple_Years_Commitment__c))  ||  (!Boolean.ValueOf(q.Multiple_Years_Commitment__c)))){
             for(SBQQ__QuoteLine__c ql : quoteLines){
                
                if(!groupedMap.containsKey(ql.term__c)){
                   tempList = new List<SBQQ__QuoteLine__c>();
                   tempList.add(ql);
                   groupedMap.put(ql.term__c,tempList);
                   dateMap.put(ql.term__c,ql.SBQQ__EffectiveStartDate__c.format() +'-'+ ql.SBQQ__EffectiveEndDate__c.format());
                   quoteLineId.add(ql.Id);
                }
                else{
                    if(!quoteLineId.contains(ql.Id)){
                    groupedMap.get(ql.term__c).add(ql);
                    quoteLineId.add(ql.Id);
                    }
                }            
             }system.debug('---groupedMap'+groupedMap);
             
             yearGroups = new List<GroupYear>();
             for (Decimal key : groupedMap.keySet()){
               yearGroups.add(new GroupYear(groupedMap.get(key),key,dateMap.get(key)));
               system.debug('---yearGroups'+yearGroups);
             }
        }        
        return yearGroups;
    }
    
    public class GroupYear{
      public List<SBQQ__QuoteLine__c> qLines{get; set;}
      public Decimal year{get; set;}
      public string startDate{get; set;}
      public GroupYear(List<SBQQ__QuoteLine__c> qLines,decimal year, string startDate){
          this.qLines = qLines;
          this.year = year;
          this.startDate = startDate;
      }
    }
}