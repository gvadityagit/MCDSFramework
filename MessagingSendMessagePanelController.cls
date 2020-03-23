public with sharing class MessagingSendMessagePanelController{
    public String agreementId {get;set;}
    public String agreementAlias {get;set;}
    public String messageParty1Name {get;set;}
    public String messageParty1 {get;set;}
    public String soapCaseId {get;set;}
    public String messagingMasterId {get;set;}
   
    
    
    public MessagingSendMessagePanelController(){
    }
    
    public static boolean getHasManager(){
    id userid=userinfo.getUserId();
    List<user> usrlst=[select id,ManagerId from User where id=:userid];
    if(usrlst != null && !usrlst.isEmpty()){
        if(usrlst[0].ManagerId != null){
        return true;
        }
    }
    return false;
    }
    
    public String mustchTempToShowMessageChain; //This mustache template is used in message chain panel component to show messages between two users
    
    public String getMustchTempToShowMessageChain(){
        Map<String,List<String>> inputMap = new Map<String, List<String>>();
        inputMap.put(MessagingAppLiterals.INPUT_KEY.STATIC_RESOURCE_NAME.name(), new List<String>{MessagingAppLiterals.MUSTACHE_TEMPLATE_MSGCHAIN});
        IBusinessLayer iBusinessLayer = MessagingUtility.initServiceLayer(MessagingAppLiterals.CLASS_REF.MessagingServiceLayerHandler.name());
        Map<String,Object> outPutMap=iBusinessLayer.invokeBusinessProcess(MessagingAppLiterals.PROCESS_NAME.PhysicianUIDashBoard,MessagingAppLiterals.ACTION_NAME.fetchMustacheTemplate,inputMap);
        if((Boolean)outPutMap.get(MessagingAppLiterals.OUTPUT_KEY.IS_SUCCESS.name()) == true){
            return ((Map<String,String>)(outPutMap.get(MessagingAppLiterals.OUTPUT_KEY.MUSTACHE_TEMPLATE_MAP.name()))).get(MessagingAppLiterals.MUSTACHE_TEMPLATE_MSGCHAIN);
        }
        else {  //Error handling required
            return '';
        }
    }

    @RemoteAction
    public static String getMessageMasterData(String paramMapStr){
        String jsonResponse = null;
        Map<String,Object> outputMap=null;
        MessagingWrapperParams outJSON = new MessagingWrapperParams();
        Map<String,String> inpMap = (Map<String, String>)JSON.deserialize(paramMapStr, Map<String, String>.class);

        Map<String, Object> inputBsnsMap = new Map<String, Object>();
        if(inpMap.containsKey('isEscalated') && Boolean.valueOf(inpMap.get('isEscalated'))){
            //inputBsnsMap.put('messageParty1', Id.valueOf(inpMap.get('managerUserId')));
            inputBsnsMap.put('isEscalated', inpMap.get('isEscalated'));
        }
        if(inpMap.containsKey('messageParty1')){
            inputBsnsMap.put('messageParty1', Id.valueOf(inpMap.get('messageParty1')));
        }
        if(inpMap.containsKey('messageParty2')){
             inputBsnsMap.put('messageParty2',Id.valueOf(inpMap.get('messageParty2')));
        }
        if(inpMap.containsKey('TargetTopicId')){
            inputBsnsMap.put('TargetTopicId', inpMap.get('TargetTopicId'));
        }
        if(inpMap.containsKey('masterId')){
            inputBsnsMap.put('masterId', inpMap.get('masterId'));
        }
        
        IBusinessLayer iBusinessLayer = MessagingUtility.initServiceLayer(MessagingAppLiterals.CLASS_REF.MessagingServiceLayerHandler.name());
        outputMap=iBusinessLayer.invokeBusinessProcess(MessagingAppLiterals.PROCESS_NAME.PhysicianUIDashBoard,MessagingAppLiterals.ACTION_NAME.findMessageMaster,inputBsnsMap);
        MessagingWrapperParams wrapParmaObj=(MessagingWrapperParams)outputMap.get('messageWrapObj');
        List<Messaging_Master__c> msgMasterLst = wrapParmaObj.messagingMasterList;

        if(msgMasterLst != null && msgMasterLst.size() > 0){
            Messaging_Master__c msgMst = msgMasterLst[0];

            outJson.messagingMasterId = msgMst.Id;
            outJson.MessageTo = msgMst.message_to__c;
            outJson.MessageFrom = msgMst.createdbyid;
            outJson.RecordTypeName = msgMst.recordtype.NAME;
            outJson.IsEscalated = msgMst.isescalated__c + '';
            outJson.SobjectId = msgMst.recordid__c;
            outJson.SobjectType = msgMst.sobjecttype__c;
        }
        System.debug(System.LoggingLevel.FINER, 'messagge master outJson:' + outJson);

        jsonResponse = JSON.serialize(outJSON);
        System.debug(System.LoggingLevel.FINER, 'messagge master jsonResponse:' + jsonResponse);

        return jsonResponse;
    }
    
    //Method Description: This method is used to get all messages from Detail object as per input parameters.
    //Created by Pankaj 
    @RemoteAction
    public static String getMessagesWithMasterId(String paramMapStr){
        Map<String,String> inputMap = (Map<String, String>)JSON.deserialize(paramMapStr, Map<String, String>.class);
        IBusinessLayer iBusinessLayer = MessagingUtility.initServiceLayer(MessagingAppLiterals.CLASS_REF.MessagingServiceLayerHandler.name());
        Map<String,Object> outPutMap=iBusinessLayer.invokeBusinessProcess(MessagingAppLiterals.PROCESS_NAME.PhysicianUIDashBoard,MessagingAppLiterals.ACTION_NAME.fetchMessagesFromDetail,inputMap);
        return JSON.serialize(outPutMap);
    }
    
    @RemoteAction
    public static String dispatchMessage(String paramMapStr){
        try{
        String jsonResponse = null;
        MessagingWrapperParams messageParam = new MessagingWrapperParams();
        Map<String,String> inpMap = (Map<String, String>)JSON.deserialize(paramMapStr, Map<String, String>.class);
        Map<String, Object> inputBsnsMap = new Map<String, Object>();
        //Messaging_Master__c msgMasterRec = null;
        Messaging_Detail__c msgDtlRec = null;
        Id messageMasterId = null;
        Boolean existingMessageChain = false;
        Map<String,Object> outPutMap=null;
        if(inpMap.get('msgMasterId')!=null ){
            try{
                messageMasterId = Id.valueOf(inpMap.get('msgMasterId'));
                if(messageMasterId != null){
                    existingMessageChain = true;
                }
            } catch(Exception e){
                System.debug(LoggingLevel.FINER, 'messageMasterId error:' + e);
            }
        }
        if(inpMap.containsKey('isEscalated') && Boolean.valueOf(inpMap.get('isEscalated'))){
            inputBsnsMap.put('isEscalated', inpMap.get('isEscalated'));
        }
        if(inpMap.containsKey('messageParty1')){
            inputBsnsMap.put('messageParty1', Id.valueOf(inpMap.get('messageParty1')));
        }
        if(inpMap.containsKey('messageParty2')){
            inputBsnsMap.put('messageParty2', Id.valueOf(inpMap.get('messageParty2')));
        }
        //{"messageParty1":"00537000001gHdUAAU","messageParty2":"0050v000002z1FwAAI","msgMasterId":null,"TargetTypeSobjectAPI":"SOAP_Note__c","recordId":"a0X0v000001BGQNEA4","messageContent":"gvj"}
        //if(!existingMessageChain){
            
        if(inpMap.containsKey('messageContent')){
            inputBsnsMap.put('messageContent', inpMap.get('messageContent'));
        }
        System.debug(LoggingLevel.FINE, 'Message chain does not exists.');
        if(inpMap.containsKey('recordId')){
            inputBsnsMap.put('recordId', inpMap.get('recordId'));
        }
        if(inpMap.containsKey('TargetTypeSobjectAPI')){
            inputBsnsMap.put('TargetTypeSobjectAPI', inpMap.get('TargetTypeSobjectAPI'));
        }
        if(inpMap.containsKey('isEscalated')){
            inputBsnsMap.put('isEscalated', Boolean.valueOf(inpMap.get('isEscalated')));
        }
        
        messageParam.recordTypeID=MessagingUtility.getRelevantMsgMasterRecordType(MessagingAppLiterals.PROCESS_NAME.PhysicianUIDashBoard);
        inputBsnsMap.put('recordTypeID',messageParam.recordTypeID);
        //}    
        
        inputBsnsMap.put('existingMessageChain',existingMessageChain);
        IBusinessLayer iBusinessLayer = MessagingUtility.initServiceLayer(MessagingAppLiterals.CLASS_REF.MessagingServiceLayerHandler.name());
        outPutMap=iBusinessLayer.invokeBusinessProcess(MessagingAppLiterals.PROCESS_NAME.PhysicianUIDashBoard,MessagingAppLiterals.ACTION_NAME.dispatchMessage,inputBsnsMap);
      
        msgDtlRec = (Messaging_Detail__c) outPutMap.get('msgDtlRec');
        return JSON.serialize(msgDtlRec);
        }
        catch(Exception e){
              throw e;  
        }
    }
    
    
    
    @RemoteAction
    public static String getMessageDetailsForView(String paramMapStr){
        String jsonResponse = null;
        Map<String, String> inpMap = (Map<String, String>)JSON.deserialize(paramMapStr, Map<String, String>.class);

        Map<String, Object> inputBsnsMap = new Map<String, Object>();
        if(inpMap.containsKey('masterId')){
            inputBsnsMap.put('masterId', (String)inpMap.get('masterId'));
        }
         IBusinessLayer iBusinessLayer = MessagingUtility.initServiceLayer(MessagingAppLiterals.CLASS_REF.MessagingServiceLayerHandler.name());
        Map<String,Object> outPutMap=iBusinessLayer.invokeBusinessProcess(MessagingAppLiterals.PROCESS_NAME.CommunicationUIDashBoard,MessagingAppLiterals.ACTION_NAME.getMessageDetailsForView,inputBsnsMap);
        List<MessagingWrapperParams.ColAgreementWrapper> msgMasterLst = (List<MessagingWrapperParams.ColAgreementWrapper>)outputMap.get('colAgrwrpLst');
        if(msgMasterLst != null && msgMasterLst.size() > 0){
            MessagingWrapperParams.ColAgreementWrapper msgMst = msgMasterLst[0];
            jsonResponse = JSON.serialize(msgMst);
        }        
        System.debug(System.LoggingLevel.FINER, 'messagge master jsonResponse:' + jsonResponse);

        return jsonResponse;
    }
    
}