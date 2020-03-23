global interface Module_IBusinessLayer {

    Map<String,Object> invokeBusinessProcess(ModuleAppLiterals.PROCESS_NAME processName,ModuleAppLiterals.ACTION_NAME actionName, Map<String,Object> inputMap);
    
    Map<String,Object> performUserInterfaceValidations(ModuleAppLiterals.PROCESS_NAME processName,ModuleAppLiterals.ACTION_NAME actionName, Map<String,Object> inputMap);
    
    Map<String,Object> performBulkValidations(ModuleAppLiterals.PROCESS_NAME processName,ModuleAppLiterals.ACTION_NAME actionName, Map<String,Object> inputMap);
    
    Map<String,Object> performInputLoading(ModuleAppLiterals.PROCESS_NAME processName,ModuleAppLiterals.ACTION_NAME actionName, Map<String,Object> inputMap);
    
    Map<String,Object> performUserInputCleanup(ModuleAppLiterals.PROCESS_NAME processName,ModuleAppLiterals.ACTION_NAME actionName, Map<String,Object> inputMap);
}
