public virtual with sharing class Module_UserInterfaceHandler {
    
    public Module_WrapperParams messagingParmaObj{set;get;}

    public Module_UserInterfaceHandler(){
    messagingParmaObj=new Module_WrapperParams();
}
          
   
    @remoteAction
    public static String vfMethod(string paramMap){
        List<Module_WrapperParams.msgWrapClass> msglst=null;
        try{
            Map<String,String> inputMap = (Map<String, String>)JSON.deserialize(paramMap, Map<String, String>.class);  
            IBusinessLayer iBusinessLayer = Module_with_Utility.initServiceLayer(Module_AppLiterals.CLASS_REF.Module_ServiceLayerHandler.name());
            Map<String,Object> outputMap=iBusinessLayer.invokeBusinessProcess(Module_AppLiterals.PROCESS_NAME.UIDashBoard,Module_AppLiterals.ACTION_NAME.fetchMsgDashboard,inputMap);
            msglst=(List<MessagingWrapperParams.msgWrapClass>)outputMap.get('msgwrpLst');
        }
        catch(Exception e){
            throw e;
        }
         return JSON.serialize(msglst); 
    }
    
   

   @remoteAction
   public static String fetchMasterRecordsForSubordinates(String paramMap){
    List<MessagingWrapperParams.msgWrapClass> msglst=null;
        try{
            Map<String,String> inputMap = (Map<String, String>)JSON.deserialize(paramMap, Map<String, String>.class);  
            IBusinessLayer iBusinessLayer = Module_with_Utility.initServiceLayer(Module_AppLiterals.CLASS_REF.Module_ServiceLayerHandler.name());
            Map<String,Object> outputMap=iBusinessLayer.invokeBusinessProcess(Module_AppLiterals.PROCESS_NAME.UIDashBoard,Module_AppLiterals.ACTION_NAME.fetchSubordinatesMessages,inputMap);
            msglst=(List<MessagingWrapperParams.msgWrapClass>)outputMap.get('msgwrpLst');
        }
        catch(Exception e){
            throw e;
        }
         return JSON.serialize(msglst);
   } 

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
