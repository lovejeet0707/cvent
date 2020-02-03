/**
 * Created by stevelohrenz on 9/29/17.
 */

@IsTest
private class DocumentDateFormatControllerTest {
    static testMethod void testGetDocumentFormatUSD() {
        DocumentDateFormatController controller = new DocumentDateFormatController();

        controller.valueToFormat = Date.today();
        controller.formatSelector = 'USD';
        controller.getDocumentDateFormat();

    }

    static testMethod void testGetDocumentFormatGBP() {
        DocumentDateFormatController controller = new DocumentDateFormatController();

        controller.valueToFormat = Date.today();
        controller.formatSelector = 'GBP';
        controller.getDocumentDateFormat();

    }

    /*static testMethod void testGetDocumentFormatNull() {
        DocumentDateFormatController controller = new DocumentDateFormatController();

        controller.formatSelector = 'GBP';
        controller.getDocumentDateFormat();

    } */
}