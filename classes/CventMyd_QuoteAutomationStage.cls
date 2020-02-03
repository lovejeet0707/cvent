public class CventMyd_QuoteAutomationStage {

    public OutyearProcessingStage outyearProcessingStage {get;set;}

    public CodeStatus codeStatus {get;set;}

    public enum CodeStatus {

        LAST_UPDATED_BY_TRIGGER,

        LAST_UPDATED_BY_SCHEDULABLE_JOB,

        CALCULATION_CYCLE_FINISHED

    }

    public enum OutyearProcessingStage {

        NEWLY_INSERTED_VARIABLE,

        NEWLY_INSERTED_NON_VARIABLE,

        CURRENT_YEAR_FINISHED,

        OUTYEAR_PROCESSING_IN_PROGRESS,

        OUTYEAR_PROCESSING_COMPLETE

    }

    public enum GroupCreationType {

        MANUALLY_CREATED,

        MANUALLY_CLONED,

        CURRENT_YEAR_QUOTE_TRIGGER_INSERTION,

        OUTYEAR_SCHEDULED_APEX_INSERTION

    }   

}