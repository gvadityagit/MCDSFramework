public virtual with sharing class ModuleServiceLayerHandler implements IBusinessLayer{
    
    
    public virtual Map<String,List<Object>> invokeBusinessProcess(String action, Map<String, Object> inputMap){
        switch on action {
            when 'method1'{
                this.performBusinessLogicMethod1(inputMap);
            }
        }
        return null;
    }
    
    public virtual Map<String,List<Object>> performUserInterfaceValidations(String action, Map<String, Object> inputMap){ 
        return null;
    }
    public virtual Map<String,List<Object>> performBulkValidations(String moduleName, Map<String,Object> inputMap){
        return null;
    }
    
    
    private void performBusinessLogicMethod1(Map<String, Object> inputMap){
        //perform the input validations
        //performUserInterfaceValidations();
        //invoke the UtilityClass
        EXT_PP_Utility.checkForActiveCommunityAssessment();
    }
    
    private void performBusinessLogicMethod2(){
        //perform the input validations
        //perform the actual logic
    }
    
    private void performBusinessScenario3(String searchKey,String searchValue){
        
    }
    
    
}