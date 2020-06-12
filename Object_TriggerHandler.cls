public class Object_TriggerHandler implements Application_TriggerHandlerInterface
{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static final Boolean TriggerDisabled = true;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled()
    {
        //your code.
    }
 
    public void BeforeInsert(List<SObject> newItems){  }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {
        
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        
        inputMap.put('masterSet', newItems.keySet());
        Module_IBusinessLayer iBusinessLayer = Module_Utility.initServiceLayer(Module_AppLiterals.CLASS_REF.Module_ServiceLayerHandler.name());
        outputMap = iBusinessLayer.invokeBusinessProcess(Module_AppLiterals.PROCESS_NAME.BulkDataProcessing,Module_AppLiterals.ACTION_NAME.ShareMasterRecords, inputMap);
         if(outputMap.get()){
            //do somelogic
        }

    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}


    
}
