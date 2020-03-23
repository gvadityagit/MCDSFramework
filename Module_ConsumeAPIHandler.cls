public without sharing  class Module_ConsumeAPIHandler implements Callable {
    
       
     public void  invokeviaJWTwithCertificate(){  }
    
    
     public void  invokeviaJWTwithoutCertificate(){  
     
     }
    
     public void  invokeviaNamedCredentials(){  }
    
    
     public void  invokeviaPassword(){  
     
     }
    
    
    
    public Object call(String action, Map<String, Object> args) {
        Switch on action {
            when 'Method1' {
                this.invokeviaJWTwithCertificate();
            }
            when 'Method2' {
                this.invokeviaJWTwithoutCertificate();
            }
             when 'Method3' {
                this.invokeviaNamedCredentials();
            }
            when else {
                throw new CustomException('Method not implemented');
            }
        }
        return null;
    }
    
}
