public virtual with sharing class Module_ServiceLayerHandler implements Module_IBusinessLayer {
    
    
    public virtual Map<String,List<Object>> performUserInterfaceValidations(String action, Map<String, Object> inputMap){ 
        return null;
    }
    public virtual Map<String,List<Object>> performBulkValidations(String moduleName, Map<String,Object> inputMap){
        return null;
    }
    
     public virtual Map<String,Object> invokeBusinessProcess(ModuleAppLiterals.PROCESS_NAME processName,ModuleAppLiterals.ACTION_NAME actionName, Map<String, Object> inputMap){
     switch on processName {
            when submodule1UIDashBoard {
                outputMap=this.submodule1UIDashBoard(inputMap,actionName);
            }
            when submodule2UIDashBoard {
               outputMap=this.submodule2UIDashBoard(inputMap,actionName);
            }
            when BulkDataProcessing {
               outputMap=this.invokeDataChangeQueueableApex(inputMap,actionName);
            }
        }
        return outputMap;
    }
    
    private Map<String,Object> submodule1UIDashBoard(Map<String, Object> inputMap,MessagingAppLiterals.ACTION_NAME actionName){
        try{
            switch on actionName {
                when findsomething {
                    outputMap=this.findsomething(inputMap);
                }
                when dispatchMessage {
                    outputMap=this.dispatchMessageProcess(inputMap);
                }
                when fetchMessagesFromDetail {
                    outputMap= this.fetchMessagesFromDetailObject(inputMap);
                } 
                when fetchMsgDashboard {
                    outputMap=this.fetchMsgDashboardwrplst(inputMap);
                }
                when getMessageDetailsForView{
                    outputMap=this.fetchMsgDetailsforView(inputMap);
                } 
                when fetchMustacheTemplate{
                    outputMap=this.fetchMustacheTemplate(inputMap);
                }   
            }
        }
        catch(Exception e){
               throw e;
        }
        return outputMap;
    }
    
   private void invokeDataChangeQueueableApex (Map<String, Object> ipMap) {

        System.debug('$$$ ipMap' + ipMap);
        
       ModuleQueueable QueObj = new ModuleQueueable(ModuleAppLiterals.PROCESS_NAME.PATHWAY_TO_SOL_INT
                                                                        , ModuleAppLiterals.ACTION_NAME.CONTACT_DATA_CHANGE_SYNC, ipMap);
        System.enqueueJob(QueObj);
        
    }
    
}
