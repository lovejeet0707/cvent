@isTest
global class MergingCallsFromSFMock implements HttpCalloutMock
{
    global httpResponse respond(HTTPrequest req)
    {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        //res.setStatus('Method Not Allowed');
        return res;
    }
}