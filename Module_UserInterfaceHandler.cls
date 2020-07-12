public virtual with sharing class Module_UserInterfaceHandler {
    
    public Module_WrapperParams paramObj{set;get;}

    public Module_UserInterfaceHandler(){
    paramObj=new Module_WrapperParams();
}
          
   
    @remoteAction
    public static String vfMethod(string paramMap){
        List<Module_WrapperParams.sub1WrapClass> sub1lst=null;
        try{
            Map<String,String> inputMap = (Map<String, String>)JSON.deserialize(paramMap, Map<String, String>.class);  
            IBusinessLayer iBusinessLayer = Module_with_Utility.initServiceLayer(Module_AppLiterals.CLASS_REF.Module_ServiceLayerHandler.name());
            Map<String,Object> outputMap=iBusinessLayer.invokeBusinessProcess(Module_AppLiterals.PROCESS_NAME.UIDashBoard,Module_AppLiterals.ACTION_NAME.fetchDashboard,inputMap);
            sub1lst=(List<Module_WrapperParams.sub1WrapClass>)outputMap.get('wrpLst');
        }
        catch(Exception e){
            throw e;
        }
         return JSON.serialize(sub1lst); 
    }
    
   

   @remoteAction
   public static String fetchMasterRecords(String paramMap){
    List<Module_WrapperParams.sub2WrapClass> sub2lst=null;
        try{
            Map<String,String> inputMap = (Map<String, String>)JSON.deserialize(paramMap, Map<String, String>.class);  
            IBusinessLayer iBusinessLayer = Module_with_Utility.initServiceLayer(Module_AppLiterals.CLASS_REF.Module_ServiceLayerHandler.name());
            Map<String,Object> outputMap=iBusinessLayer.invokeBusinessProcess(Module_AppLiterals.PROCESS_NAME.UIDashBoard,Module_AppLiterals.ACTION_NAME.fetchSubordinates,inputMap);
            sub2lst=(List<Module_WrapperParams.sub2WrapClass>)outputMap.get('msgwrpLst');
        }
        catch(Exception e){
            throw e;
        }
         return JSON.serialize(sub2lst);
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
