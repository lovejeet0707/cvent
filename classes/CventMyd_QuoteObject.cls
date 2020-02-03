public class CventMyd_QuoteObject {
    
    public Map<Integer,CventMyd_Outyear> outyearMap {get;set;}

    public Settings settings {get;set;}

    public String insertionId {get;set;}

    public Boolean currentYearSynced {get;set;}

    public String calculationIdString {get;set;}

    public CventMyd_QuoteAutomationStage automationStage {get;set;}

    public String previousQuoteType {get;set;}

    public List<String> qcpConfigurationErrors {get;set;}

    public class Settings {

        public List<String> preCalculationFieldNames {get;set;}

        public List<String> calculatedFieldNames {get;set;}

        public List<String> numberFieldNames {get;set;}

        public Long msAtLastUpdate {get;set;}

    }

}