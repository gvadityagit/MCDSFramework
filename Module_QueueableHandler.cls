
global class Module_QueueableHandler implements Queueable, Database.AllowsCallouts  {

    public Map<String, Object> ipMap;
    public Module_AppLiterals.PROCESS_NAME  processName;
    public Module_AppLiterals.ACTION_NAME  actionName;
    
    
    public Module_QueueableHandler(Module_AppLiterals.PROCESS_NAME processName
                                                    , Module_AppLiterals.ACTION_NAME actionName
                                                    , Map<String, Object> ipMap) {        
        this.processName = processName;
        this.actionName = actionName;
        this.ipMap = ipMap;
    }

      public void execute(QueueableContext context) {
        processQueueableRequest();
    }

    public void processQueueableRequest() {
        //NOTE: Break the huge volume of the data into chunks (with configurable size based on the operation)
        Module_IBusinessLayer iBusinessLayer = Module_withSharing_Utility.initServiceLayer(Module_AppLiterals.BASE_SERVICE_LAYER_CLS_NAME);
        iBusinessLayer.invokeBusinessProcess(processName, actionName, ipMap);
    }

}
