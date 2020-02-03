public class CventMyd_QuoteLineObject {
    
    public String qleId {get;set;}

    public String requiredByQleId {get;set;}

    public List<String> clonedFromQleIds {get;set;}

    public Boolean insertOnNextCurrentYear {get;set;}

    public Boolean insertedWithApex {get;set;}

    public Boolean deleteThisLine {get;set;}

    public String quoteName {get;set;}

    public String nextYearQleId {get;set;}

    public Map<String,List<String>> preCalculationFieldValueMap {get;set;}

    public Map<String,List<String>> calculatedFieldValueMap {get;set;}

    public Map<String,String> contractedFieldValueMap {get;set;}

    public Boolean legacySubscriptionUpdated {get;set;}

    public String requiredBySubscriptionIdString {get;set;}

    public Boolean parallelLineAddition {get;set;}

}