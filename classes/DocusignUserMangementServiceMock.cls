@isTest
global class DocusignUserMangementServiceMock implements HttpCalloutMock {
    //Implement http mock callout here
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('Created');
        return response; 
    }
}