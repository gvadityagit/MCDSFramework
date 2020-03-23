/**
 * @File Name          : Pathway_To_Sol_Queueable.cls
 * @Description        : 
 * @Author             : Naveen Ila
 * @Group              : 
 * @Last Modified By   : Naveen Ila
 * @Last Modified On   : 2/19/2020, 3:19:00 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/19/2020   Naveen Ila     Initial Version
**/
global class Pathway_To_Sol_Queueable implements Queueable, Database.AllowsCallouts  {

    public Map<String, Object> ipMap;
    public Pathway_To_Sol_AppLiterals.PROCESS_NAME  processName;
    public Pathway_To_Sol_AppLiterals.ACTION_NAME  actionName;
    
    
    public Pathway_To_Sol_Queueable(Pathway_To_Sol_AppLiterals.PROCESS_NAME processName
                                                    , Pathway_To_Sol_AppLiterals.ACTION_NAME actionName
                                                    , Map<String, Object> ipMap) {
        
        this.processName = processName;
        this.actionName = actionName;
        this.ipMap = ipMap;

    }

    /**
    * @description 
    * @author Naveen Ila | 2/18/2020 
    * @param QueueableContext context 
    * @return void 
    **/
    public void execute(QueueableContext context) {

        processQueueableRequest();

    }


    /**
    * @description 
    * @author Naveen Ila | 2/18/2020 
    * @return void 
    **/
    public void processQueueableRequest() {

        //NOTE: Break the huge volume of the data into chunks (with configurable size based on the operation)
        Pathway_To_Sol_IBusinessLayer iBusinessLayer = Pathway_To_Sol_Utility.initServiceLayer(Pathway_To_Sol_AppLiterals.BASE_SERVICE_LAYER_CLS_NAME);
        iBusinessLayer.invokeBusinessProcess(processName, actionName, ipMap);


    }

}