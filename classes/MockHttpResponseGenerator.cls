@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    
    protected Integer statusCode;
    protected String status;
    protected String bodyAsString;
    
    public MockHttpResponseGenerator(Integer statusCode, String status, String body) {
        this.statusCode = statusCode;
        this.status = status;
        this.bodyAsString = body;
        //this.bodyAsBlob = null;
        //this.responseHeaders = responseHeaders;
    }

    global HTTPResponse respond(HTTPRequest req) {

        // Create a fake response
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(statusCode);
        resp.setStatus(status);
        resp.setBody(bodyAsString);
        return resp;
    }
}