/**
 * Controller for the documentdateFormat visual force component
 */

public class DocumentDateFormatController {
    public Date valueToFormat {get; set;}
    public String formatSelector {get; set;}

    public String getDocumentDateFormat() {
        return TemplateUtilities.formatDate(valueToFormat, formatSelector);
    }
}