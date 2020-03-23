
global with sharing class Module_API_Test_Mock implements HttpCalloutMock {

    public static Boolean isAbleFetchToken = true;
    public static Boolean isSuccessScenario = true;

    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response.
        // Set response values, and 
        // return response.
        
        return buildResponse(req);
    }

    public HttpResponse buildResponse (HTTPRequest req) {

        String serviceName = fetchServiceName(req.getEndpoint());
        HttpResponse res;

        switch on serviceName {
            when 'token' {
                res = buildBaseResponse(isAbleFetchToken);
                res.setBody(prepareTokenBody());

            }
            when 'moduleName' {
                res = buildBaseResponse(isSuccessScenario);
            }
            when else {
                
            }
        }
        return res;
    }

    public String fetchServiceName (String endPoint) {

        List<String> endPointParts = endPoint.split('/');
        return endPointParts.get(endPointParts.size() - 1);
    }

    public HttpResponse buildBaseResponse (Boolean flag) {

        HttpResponse res = new HttpResponse();
        if (flag) {
            res.setStatus('OK');
            res.setStatusCode(200);
        } else {
            res.setStatusCode(400);
            res.setStatus('Failed');
        }

        return res;
    }

    public String prepareTokenBody () {

        JWT_Utility.TokenDetails tnkDet = new JWT_Utility.TokenDetails();

        if (isAbleFetchToken) {
            tnkDet.access_token = 'abcdefghijklmnopqrstuvwxyz' + DateTime.now().addMinutes(5).getTime();
            tnkDet.token_type = 'Bearer';
        } 

        return JSON.serialize(tnkDet);

    }

}