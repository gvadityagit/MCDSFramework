public class PathwayAPIHandlerSFJWT {
    
    public PathwayAPIHandlerSFJWT(Configuration config) {
        this.config = config;
    }
    
    public class Configuration {
        public String alg {get;set;}
        public String iss {get;set;}
        public String typ {get;set;}
        public String exp {get;set;}
        public Integer validFor {get;set;}
        public String privateKey {get;set;}
        public String algType = 'HS256';
        public  String RS256 = 'RS256';
        public Integer tokenValidity {get;set;}
        public String cryptoAlogirtham {get;set;}
        
    }
    
    
    private class JwtException extends Exception { }
    
    private Configuration config;
   
    
    public String requestAccessToken() {
        
        String jwt = '';
        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('alg', this.config.alg);
        header.writeStringField('typ', this.config.typ);
        header.writeEndObject();
        String encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));
        JSONGenerator body = JSON.createGenerator(false);
        body.writeStartObject();
        body.writeStringField('iss', this.config.iss);
        Long rightNow = (dateTime.now().getTime()/1000)+1;
        body.writeNumberField('exp', (rightNow + config.validFor));
        body.writeEndObject();
        
        jwt = encodedHeader + '.' + base64URLencode(Blob.valueOf(body.getAsString()));
        
        if ( this.config.alg == config.algType ) {
            Blob key = Blob.valueOf(config.privateKey);
            Blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),key);
            jwt += '.' + base64URLencode(signature);
        } else  {
            jwt += '.';
        }
        return jwt;
    }
    
    private String base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }
}