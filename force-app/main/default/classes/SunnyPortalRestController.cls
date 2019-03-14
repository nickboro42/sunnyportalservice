public class SunnyPortalRestController {

    public String instanceId {get;set;}
    static final String appId  = '0447fe28-da60-4162-8cc3-6a46ec20940b';
    static final String baseUrl = 'https://com.sunny-portal.de/services';
    static final String tokenIdentifier;
    static final String tokenKey;
    static final String httpGetMethod = 'GET';

    
    @AuraEnabled
    public static TokenResult getToken(string inputUser, string inputPassword) {


        HttpRequest req = new HttpRequest();
        Http http = new Http();
        TokenResult results = new TokenResult();
        
        //auth header
        String user = inputUser;
        String password = inputPassword;   
        Blob headerValue = Blob.valueOf(user + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        String serviceName = 'token';
        
        req.setHeader('Authorization', authorizationHeader);
        req.setMethod('GET');
        System.debug('*****GOT HERE****');
        String url = baseUrl + '/' + serviceName + '/100/' + appId + '/' + appId;
        
        req.setEndpoint(url);
        
        HTTPResponse resp = new HTTPResponse();
            
        try {
            resp = http.send(req);
            
        }
        catch (System.CalloutException e) {
            System.debug('ERROR:' + e);
            
            System.debug('error is:' + e);
        }

        XmlDom doc = new XmlDom(resp.getBody());
        results = toTokenResult(doc);
        return results;
        
    }

    @AuraEnabled
    public static List<ResponseDataResult> getResponse(String portalUser, String portalPass, String serviceName, String plantOid) {
        
        TokenResult reqToken = getToken(portalUser, portalPass);
        String reqIdentifier = reqToken.identifier;
        String reqKey = reqToken.key;
        DateTime reqTimestamp = DateTime.now();
        String reqTimestampString = reqTimestamp.format('yyyy-MM-dd\'T\'HH:mm:ss', 'UTC');
        String channelDate = reqTimestamp.format('yyyy-MM-dd');
        String reqSignature = buildSignature(httpGetMethod, serviceName, reqIdentifier, reqTimestampString, reqKey);
        String reqUrl = baseUrl + '/' + serviceName + '/100/';

        switch on serviceName {
            when 'plantlist' {
                reqUrl =  reqUrl + reqIdentifier + '?timestamp=' + reqTimestampString + '&culture=en-us&signature-version=100&signature-method=perm&signature=' + reqSignature;
            }

            when 'devicelist' {
                reqUrl = reqUrl + plantOid + '?identifier=' + reqIdentifier + '&timestamp=' + reqTimestampString + '&culture=en-us&signature-version=100&signature-method=perm&signature=' + reqSignature;
            }
        }
        System.debug('req url ' + reqUrl);

        List<ResponseDataResult> ResponseDataResult = new List<ResponseDataResult>();
        HttpRequest req = new HttpRequest();
        Http httpClient = new Http();
        
        req.setEndpoint(reqUrl);
        req.setMethod(httpGetMethod);
        HTTPResponse resp = new HTTPResponse();
            
        try {
            resp = httpClient.send(req);
            
        }
        catch (System.CalloutException e) {
            System.debug('ERROR:' + e);
            
            System.debug('error is:' + e);
        }
        
        XmlDom doc = new XmlDom(resp.getBody());
        
        switch on serviceName {
            when 'plantlist' {               
                System.debug('plant-list-response' + String.valueOf(doc));
                XmlDom.Element[] elements = doc.getElementsByTagName('plant');
            for(XmlDom.Element element : elements)  
                ResponseDataResult.add(toDataResult(element));
            }
            when 'devicelist' {
                XmlDom.Element[] elements = doc.getElementsByTagName('device');
                for(XmlDom.Element element : elements)  
                ResponseDataResult.add(toDataResult(element));
            }
        }
        
        
        return ResponseDataResult;
    }
    
    private static TokenResult toTokenResult(XmlDom tknDoc) {
        
        TokenResult tkn = new TokenResult();
        System.Debug('TokenDoc ' + tknDoc);
        tkn.identifier = tknDoc.getElementByTagName('identifier').getValue('identifier');
        tkn.key = tknDoc.getElementByTagName('key').getValue('key');
        return tkn;
    }
    
    private static ResponseDataResult toDataResult(XmlDom.Element element){
        ResponseDataResult theResult = new ResponseDataResult();
        theResult.objName = element.getAttribute('name');
        theResult.objOid = element.getAttribute('oid');
        if(element.getAttribute('serialnumber') <> null){
            theResult.objSerialNumber = element.getAttribute('serialnumber');
        }
        return theResult;
    }

    
    private static String buildSignature(String method, String service, String identifier, String timestamp, String secret) {
        
        string saltString = method.toLowerCase() + service.toLowerCase() + timestamp + identifier.toLowerCase();
         
        Blob signatureBlob = Crypto.generateMac('hmacSHA1', Blob.valueOf(saltString), Blob.valueOf(secret));
        
        String base64EncodedSignature = EncodingUtil.base64Encode(signatureBlob);
        
        String urlEncodedSignature = EncodingUtil.urlEncode(base64EncodedSignature, 'UTF-8');
        
        return urlEncodedSignature;
        
    }

    // inner classes
    private class TokenResult {
        
        public String identifier;
        public String key;
        public String error;
        public String test;
        public String toDisplayString() {
            return identifier + ',' + key;
        }
        
    }   

    public class ResponseDataResult {
	    @AuraEnabled
            public string objName {get;set;}
        @AuraEnabled
            public string objOid  {get;set;}
         @AuraEnabled
            public String objSerialNumber {get;set;}
        }
}