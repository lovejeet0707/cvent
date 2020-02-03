public class QuoteLineGroupStatus {

	public GroupCreationType creationType {get;set;}

	public enum GroupCreationType {

		MANUALLY_CREATED,

		MANUALLY_CLONED,

		CURRENT_YEAR_QUOTE_TRIGGER_INSERTION,

		OUTYEAR_SCHEDULED_APEX_INSERTION

	}

}