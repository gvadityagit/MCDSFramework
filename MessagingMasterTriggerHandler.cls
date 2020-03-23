public class MessagingMasterTriggerHandler implements PathwayTriggerHandlerInterface
{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static final Boolean TriggerDisabled = true;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled()
    {
        if (Appcommonmethods.runTrigger('MessagingMasterTrigger'))
            return false;
        else
            return TriggerDisabled;
    }
 
    public void BeforeInsert(List<SObject> newItems){
    //serviceLayer
    }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {
        
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        
        inputMap.put('masterIdSet', newItems.keySet());
        IBusinessLayer iBusinessLayer = MessagingUtility.initServiceLayer(MessagingAppLiterals.CLASS_REF.MessagingServiceLayerHandler.name());
        outputMap = iBusinessLayer.invokeBusinessProcess(MessagingAppLiterals.PROCESS_NAME.BulkDataProcessing,MessagingAppLiterals.ACTION_NAME.ShareMasterRecords, inputMap);
        system.debug('mY outputmap='+outputMap);
        if(! (Boolean)outputMap.get(MessagingAppLiterals.OUTPUT_KEY.IS_SUCCESS.name())){
            throw new MessagingException((String) outputMap.get(MessagingAppLiterals.OUTPUT_KEY.ERROR_MSG.name()));
        }

    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}


    
}