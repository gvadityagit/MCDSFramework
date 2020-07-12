global class Module_AppLiterals {
    
    global ENUM PROCESS_NAME {SubModule_UIDashBoard,SubModule2_UIDashBoard,BulkDataProcessing}
    global ENUM ACTION_NAME {findMaster,dispatchMaster,
       						 initiateMaster,initiateDetail,
        					 ShareMasterRecords,
                             fetchMustacheTemplate,fetchSubordinatesData}
    global ENUM INPUT_KEY  {STATIC_RESOURCE_NAME}
    global ENUM OUTPUT_KEY  {IS_SUCCESS,ERROR_MSG,
                            MUSTACHE_TEMPLATE_MAP}
    global ENUM GENERIC_KEYS {Max_Chain_Count}

    global ENUM CLASS_REF {ModuleServiceLayerHandler}

    
}
