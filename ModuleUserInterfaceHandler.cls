public virtual with sharing class EXT_PP_UserInterfaceHandler {
    
    private List<sObject> std;
    private static String classRefName=null;
    private EXT_PP_ServiceLayerHandler extensionClass=null;
    
    public EXT_PP_UserInterfaceHandler(){
        classRefName='EXT_PP_ServiceLayerHandler'; //get from customMetadata
         extensionClass= new EXT_PP_ServiceLayerHandler();
    }
    
    public EXT_PP_UserInterfaceHandler(ApexPages.StandardController con){
        std[0]=(sObject)con.getRecord();
    }
    
    public EXT_PP_UserInterfaceHandler(ApexPages.StandardSetController stdSet){
        std=(List<sObject>)stdSet.getSelected();
    }
    
    
    @RemoteAction
    public static void processVFRemoting(){
        
        
    }
    
    @AuraEnabled(Cacheable=true)
    public static void lwcProcessMethod(){
        
    }
    
     @AuraEnabled(Cacheable=true)
    public static void lwcProcessMethod2(){
        
    }
    
    public static void actionMethod(){
        
    }
    
    public static void actionFunctionMethod(){
        
    }
}