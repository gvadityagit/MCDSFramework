public class MessagingTriggerHandler implements PathwayTriggerHandlerInterface
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
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}


    
}