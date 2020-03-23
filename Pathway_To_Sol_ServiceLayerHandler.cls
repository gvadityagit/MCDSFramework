/**
 * @File Name          : Pathway_To_Sol_ServiceLayerHandler.cls
 * @Description        : 
 * @Author             : Naveen Ila
 * @Group              : 
 * @Last Modified By   : Naveen Ila
 * @Last Modified On   : 2/19/2020, 2:52:28 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    2/19/2020   Naveen Ila     Initial Version
**/
public virtual inherited sharing class Pathway_To_Sol_ServiceLayerHandler implements Pathway_To_Sol_IBusinessLayer {

    
    /**
    * @description 
    * @author Naveen Ila | 2/20/2020 
    * @param Pathway_To_Sol_AppLiterals.PROCESS_NAME processName 
    * @param Pathway_To_Sol_AppLiterals.ACTION_NAME actionName 
    * @param Map<String Object> ipMap 
    * @return virtual 
    **/
    public virtual Map<String, Object> invokeBusinessProcess(Pathway_To_Sol_AppLiterals.PROCESS_NAME processName
                                                , Pathway_To_Sol_AppLiterals.ACTION_NAME actionName
                                                , Map<String, Object> ipMap) {
        switch on processName {
            when PATHWAY_TO_SOL_INT {
                return this.performPathwayToSolOperation(actionName, ipMap);
            }
            when else {
                return NULL;    
            }

        }
    }


    /**
    * @description 
    * @author Naveen Ila | 2/20/2020 
    * @param Pathway_To_Sol_AppLiterals.ACTION_NAME actionName 
    * @param Map<String Object> ipMap 
    * @return Map<String, Object> 
    **/
    public Map<String, Object> performPathwayToSolOperation(Pathway_To_Sol_AppLiterals.ACTION_NAME actionName
                                                    , Map<String, Object> ipMap) {
    
        switch on actionName {
            when CONTACT_DATA_CHANGE_ASYNC {
                this.invokeContactDataChangeQueueableApex(ipMap);
                return NULL;
            }
            when CONTACT_DATA_CHANGE_SYNC {
                Map<String, Object> opMap = new Map<String, Object>();
                try {
                    
                    Map<Id, Contact> oldConMap = (Map<Id, Contact>) ipMap.get('oldConMap');
                    Map<Id, Contact> newConMap = (Map<Id, Contact>) ipMap.get('newConMap');
                    Pathway_To_Sol_Integration_Utility pathwaySolIntUtilityObj = new Pathway_To_Sol_Integration_Utility();
                    String responseBody = pathwaySolIntUtilityObj.sendContactDataToSol(oldConMap, newConMap);
                    
                    opMap.put('responseBody', responseBody);
                } catch (Exception e) {
                    //TODO: log error with exception details    
                } 
                return opMap;

            }
            when ENGAGEMENT_DATA_CHANGE_ASYNC {
                this.invokeEngDataChangeQueueableApex(ipMap);
                return NULL;
            }
            when ENGAGEMENT_DATA_CHANGE_SYNC {
                Map<String, Object> opMap = new Map<String, Object>();
                try {
                    
                    System.debug('$$$ ' + ipMap);
                    Map<Id, Engagement__c> oldEngMap = (Map<Id, Engagement__c>) ipMap.get('oldEngMap');
                    List<Engagement__c> newEngs = (List<Engagement__c>) ipMap.get('newEngList');
                    Pathway_To_Sol_Integration_Utility pathwaySolIntUtilityObj = new Pathway_To_Sol_Integration_Utility();
                    String responseBody = pathwaySolIntUtilityObj.sendEngDataChangeToSol(oldEngMap, newEngs);
                    
                    opMap.put('responseBody', responseBody);
                } catch (Exception e) {
                    //TODO: log error with exception details    
                    System.debug('$$$ Exception ' + e.getMessage());
                } 
                return opMap;

            }
            when ENGAGEMENT_DATA_PUSH_ON_DEMAND_ASYNC {

                this.invokeEngDataPushQueueableApex(ipMap);
                return null;
            }
            when ENGAGEMENT_DATA_PUSH_ON_DEMAND_SYNC {
                Map<String, Object> opMap = new Map<String, Object>();
                try {
                    
                    System.debug('$$$ ' + ipMap);
                    Set<Id> engIdSet = (Set<Id>) ipMap.get('engIdSet');
                    
                    Pathway_To_Sol_Integration_Utility pathwaySolIntUtilityObj = new Pathway_To_Sol_Integration_Utility();
                    String responseBody = pathwaySolIntUtilityObj.sendEngDataToSol(engIdSet);
                    
                    opMap.put('responseBody', responseBody);
                } catch (Exception e) {
                    //TODO: log error with exception details    
                    System.debug('$$$ Exception ' + e.getMessage());
                } 
                return opMap;

            }
            when else {
                return NULL;
            }
        }
    }

    

    /**
    * @description 
    * @author Naveen Ila | 2/20/2020 
    * @param Map<String Object> ipMap 
    * @return void 
    **/
    private void invokeContactDataChangeQueueableApex (Map<String, Object> ipMap) {

        System.debug('$$$ ipMap' + ipMap);
        
        Pathway_To_Sol_Queueable pathwayToSolConQueObj = new Pathway_To_Sol_Queueable(Pathway_To_Sol_AppLiterals.PROCESS_NAME.PATHWAY_TO_SOL_INT
                                                                        , Pathway_To_Sol_AppLiterals.ACTION_NAME.CONTACT_DATA_CHANGE_SYNC, ipMap);
        System.enqueueJob(pathwayToSolConQueObj);
        
    }
    
    private void invokeEngDataChangeQueueableApex (Map<String, Object> ipMap) {

        System.debug('$$$ ipMap' + ipMap);
        
        Pathway_To_Sol_Queueable pathwayToSolConQueObj = new Pathway_To_Sol_Queueable(Pathway_To_Sol_AppLiterals.PROCESS_NAME.PATHWAY_TO_SOL_INT
                                                                        , Pathway_To_Sol_AppLiterals.ACTION_NAME.ENGAGEMENT_DATA_CHANGE_SYNC, ipMap);
        System.enqueueJob(pathwayToSolConQueObj);
        
    }

    private void invokeEngDataPushQueueableApex (Map<String, Object> ipMap) {

        System.debug('$$$ ipMap' + ipMap);
        
        Pathway_To_Sol_Queueable pathwayToSolConQueObj = new Pathway_To_Sol_Queueable(Pathway_To_Sol_AppLiterals.PROCESS_NAME.PATHWAY_TO_SOL_INT
                                                                        , Pathway_To_Sol_AppLiterals.ACTION_NAME.ENGAGEMENT_DATA_PUSH_ON_DEMAND_SYNC, ipMap);
        System.enqueueJob(pathwayToSolConQueObj);
        
    }
    
}