public with sharing class MessagingUserInterfaceHandler{
    
    public MessagingWrapperParams messagingWrapperParam {get;set;}
    private List<sObject> std;
    public Map<String,Object> outputMap {get;set;}
    
    
    
    public MessagingUserInterfaceHandler(){
      
    }
    
    public MessagingUserInterfaceHandler(ApexPages.StandardController con){ 
        std[0]=(sObject)con.getRecord();
    }
    
    public MessagingUserInterfaceHandler(ApexPages.StandardSetController stdSet){
        std=(List<sObject>)stdSet.getSelected();
    }
    
    
    @RemoteAction
    public static String processVFRemoting(String input){
        Type t = Type.forName('MessagingServiceLayerHandler');
        MessagingServiceLayerHandler messagingServiceLayerHandler = (MessagingServiceLayerHandler)t.newInstance();
        System.debug('messagingServiceLayerHandler-->'+messagingServiceLayerHandler);
        Map<String ,Object>  inputMap=new Map<String, Object>();
        // outmessagingServiceLayerHandler.invokeBusinessProcess(MessagingAppLiterals.ActionName.PhysicianDashBoard, inputMap);
        //return outnva=JSON.Serilaxe(map);
        return null;
    }
    
    
    
    @AuraEnabled(Cacheable=true)
    public static void lwcProcessMethod(){
        
    }
    
    public virtual void actionMethod(){
        
    }
    
    public virtual void actionFunctionMethod(){
        
    }
}