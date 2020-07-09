public virtual inherited sharing class Module_ServiceLayerHandler implements Module_IBusinessLayer {
    
    
    public virtual Map<String,List<Object>> performUserInterfaceValidations(String action, Map<String, Object> inputMap){ 
        switch on actionName {
              when UIDashBoard {
                  this.performDisplayValidation(inputMap);  
              }
             when getMasterRecord {
                 this.performGeneicValidation(inputMap); 
             }
             when getDetailsRecords {
                 this.performGeneicValidation(inputMap); 
             }
             when insertMasterRecord {
                 this.performInsertValidation(inputMap);
              }
             }
        }
        return null;
    }
    public virtual Map<String,List<Object>> performBulkValidations(String moduleName, Map<String,Object> inputMap){
       
        return null;
    }
    
     public virtual Map<String,Object> invokeBusinessProcess(ModuleAppLiterals.PROCESS_NAME processName,ModuleAppLiterals.ACTION_NAME actionName, Map<String, Object> inputMap){
     switch on processName {
            when UILevel {
                outputMap=this.UILevelProcesFlow(inputMap,actionName);
            }
            when bulkDataProcessing {
               outputMap=this.submodule2UIDashBoard(inputMap,actionName);
            }
        }
        return outputMap;
    }
    
    private Map<String,Object> UILevelProcesFlow(Map<String, Object> inputMap,MessagingAppLiterals.ACTION_NAME actionName){
        try{
            switch on actionName {
                when UIDashBoard {
                    this.performUserInterfaceValidations(UIDashBoard,inputMap);
                    outputMap=this.showDashboardDetails(inputMap);
                }
                when getMasterRecord {
                    outputMap=this.getMasterRecord(inputMap);
                }
                when fetchFromDetail {
                    outputMap= this.fetchFromDetailObject(inputMap);
                } 
                when fetchspecificFlow1 {
                    outputMap=this.fetchSamplewrplst(inputMap);
                }
                when fetchspecificFlow2{
                    outputMap=this.fetchDetailsforView(inputMap);
                } 
                when fetchMustacheTemplate{
                    outputMap=this.fetchTemplate(inputMap);
                }  
                when insertFlow{
                    outputMap=this.insertMasterObject(inputMap);
                }  
                
            }
        }
        catch(Exception e){
               throw e;
            //need to handle exception ( through another component ...coming soon)
        }
        return outputMap;
    }
    
   private void invokeDataChangeQueueableApex (Map<String, Object> ipMap) {
        
       Module_Queueable queObj = new Module_Queueable(ModuleAppLiterals.PROCESS_NAME
                                                                        , ModuleAppLiterals.ACTION_NAME, ipMap);
        System.enqueueJob(QueObj);
        
    }
    
}
