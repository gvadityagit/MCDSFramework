global interface IBusinessLayer {

    Map<String,Object> invokeBusinessProcess(MessagingAppLiterals.PROCESS_NAME processName,MessagingAppLiterals.ACTION_NAME actionName, Map<String,Object> inputMap);
    
    Map<String,Object> performUserInterfaceValidations(MessagingAppLiterals.PROCESS_NAME processName,MessagingAppLiterals.ACTION_NAME actionName, Map<String,Object> inputMap);
    
    Map<String,Object> performBulkValidations(MessagingAppLiterals.PROCESS_NAME processName,MessagingAppLiterals.ACTION_NAME actionName, Map<String,Object> inputMap);
    
    Map<String,Object> performInputLoading(MessagingAppLiterals.PROCESS_NAME processName,MessagingAppLiterals.ACTION_NAME actionName, Map<String,Object> inputMap);
    
    Map<String,Object> performUserInputCleanup(MessagingAppLiterals.PROCESS_NAME processName,MessagingAppLiterals.ACTION_NAME actionName, Map<String,Object> inputMap);
}