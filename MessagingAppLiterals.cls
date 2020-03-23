global class MessagingAppLiterals {
    
    global ENUM PROCESS_NAME {PhysicianUIDashBoard,CommunicationUIDashBoard,BulkDataProcessing}
    global ENUM ACTION_NAME {findMessageMaster,dispatchMessage,
       						 initiateMessageMaster,initiateMessageDetail,
        					 ShareMasterRecords,fetchMsgDetails ,
        					 fetchMessagesFromDetail,fetchMsgDashboard,getMessageDetailsForView,
                             fetchMustacheTemplate,fetchSubordinatesMessages}
    global ENUM INPUT_KEY  {STATIC_RESOURCE_NAME}
    global ENUM OUTPUT_KEY  {IS_SUCCESS,ERROR_MSG,
                            MUSTACHE_TEMPLATE_MAP}
    global ENUM GENERIC_KEYS {Max_Chain_Message_Count}

    global ENUM CLASS_REF {MessagingServiceLayerHandler}
    global final static String SOAP_NOTE='SOAP_NOTE__c';
    global final static String Case_Object='Case';
    global final static String COLLABORATIVE_AGREEMENT_OBJECT='Collaborative_Agreement__c';
    global final static String MUSTACHE_TEMPLATE_MSGCHAIN = 'MessageChainMustacheTemplate';
    
}