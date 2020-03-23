public virtual inherited sharing class MessagingServiceLayerHandler implements IBusinessLayer {
       
    private Map<String,Object> outputMap=new Map<String,Object>();
    
    public MessagingServiceLayerHandler(){
    }
    
    public virtual Map<String,Object> performUserInterfaceValidations(MessagingAppLiterals.PROCESS_NAME processName,MessagingAppLiterals.ACTION_NAME actionName, Map<String, Object> inputMap){ 
        return null;
    }
    
    public virtual Map<String,Object> performBulkValidations(MessagingAppLiterals.PROCESS_NAME processName,MessagingAppLiterals.ACTION_NAME actionName, Map<String,Object> inputMap){
        return null;
    }
    
    public virtual Map<String,Object> performInputLoading(MessagingAppLiterals.PROCESS_NAME processName,MessagingAppLiterals.ACTION_NAME actionName, Map<String, Object> inputMap){ 
        return null;
    }
    
    public virtual Map<String,Object> performUserInputCleanup(MessagingAppLiterals.PROCESS_NAME processName,MessagingAppLiterals.ACTION_NAME actionName, Map<String,Object> inputMap){
        return null;
    }
    
    public virtual Map<String,Object> invokeBusinessProcess(MessagingAppLiterals.PROCESS_NAME processName,MessagingAppLiterals.ACTION_NAME actionName, Map<String, Object> inputMap){
     switch on processName {
            when PhysicianUIDashBoard {
                outputMap=this.physicianUIDashBoard(inputMap,actionName);
            }
            when CommunicationUIDashBoard {
               outputMap=this.communicationUIDashBoard(inputMap,actionName);
            }
            when BulkDataProcessing {
               outputMap=this.executeBulkDataProcessing(inputMap,actionName);
            }
        }
        return outputMap;
    }
    
    private Map<String,Object> communicationUIDashBoard(Map<String, Object> inputMap,MessagingAppLiterals.ACTION_NAME actionName){
        try{
            switch on actionName {
                when getMessageDetailsForView{
                    outputMap=this.fetchMsgDetailsforView(inputMap);
                }
                when fetchSubordinatesMessages{
                    outputMap=this.fetchMsgDashboardwrplst(inputMap);
                } 
            }
        }
        catch(Exception e){
            outputMap.put(MessagingAppLiterals.OUTPUT_KEY.IS_SUCCESS.name(), false);
            outputMap.put(MessagingAppLiterals.OUTPUT_KEY.ERROR_MSG.name(), e.getStackTraceString()+ '='+e.getMessage());
            system.debug('my error='+e.getMessage() +' e.getStackTraceString=='+ e.getStackTraceString());
            throw e;
        }
        return outputMap;
    }
    
    private Map<String,Object> physicianUIDashBoard(Map<String, Object> inputMap,MessagingAppLiterals.ACTION_NAME actionName){
        try{
            switch on actionName {
                when findMessageMaster {
                    outputMap=this.findMessageMasterProcess(inputMap);
                }
                when dispatchMessage {
                    outputMap=this.dispatchMessageProcess(inputMap);
                }
                when fetchMessagesFromDetail {
                    outputMap= this.fetchMessagesFromDetailObject(inputMap);
                } 
                when fetchMsgDashboard {
                    outputMap=this.fetchMsgDashboardwrplst(inputMap);
                }
                when getMessageDetailsForView{
                    outputMap=this.fetchMsgDetailsforView(inputMap);
                } 
                when fetchMustacheTemplate{
                    outputMap=this.fetchMustacheTemplate(inputMap);
                }   
            }
        }
        catch(Exception e){
            outputMap.put(MessagingAppLiterals.OUTPUT_KEY.IS_SUCCESS.name(), false);
            outputMap.put(MessagingAppLiterals.OUTPUT_KEY.ERROR_MSG.name(), e.getMessage());
            throw e;
        }
        return outputMap;
    }
    
    private Map<String,Object> executeBulkDataProcessing(Map<String, Object> inputMap, MessagingAppLiterals.ACTION_NAME actionName){
        outputMap=new Map<String,Object>(); 
        try{
            switch on actionName {
                when ShareMasterRecords {
                    Set<Id> idSet = (Set<Id>)inputMap.get('masterIdSet');
                    if(idSet == null || idSet.isEmpty()){
                        outputMap.put(MessagingAppLiterals.OUTPUT_KEY.IS_SUCCESS.name(), false);
                        outputMap.put(MessagingAppLiterals.OUTPUT_KEY.ERROR_MSG.name(), 'Id set is empty');
                    } else {
                        try{
                            List<Database.SaveResult> sr = this.manageSharingMessageRecords(idSet);
                            outputMap.put('saveResult', sr);
                            outputMap.put(MessagingAppLiterals.OUTPUT_KEY.IS_SUCCESS.name(), true);
                            outputMap.put(MessagingAppLiterals.OUTPUT_KEY.ERROR_MSG.name(), '');
                        }catch(Exception ex){
                            outputMap.put(MessagingAppLiterals.OUTPUT_KEY.IS_SUCCESS.name(), false);
                            outputMap.put(MessagingAppLiterals.OUTPUT_KEY.ERROR_MSG.name(), ex.getMessage());
                        }
                    }
                }
                when else {
                    
                }
            }
        }
        catch(Exception e){
            outputMap.put(MessagingAppLiterals.OUTPUT_KEY.IS_SUCCESS.name(), false);
            outputMap.put(MessagingAppLiterals.OUTPUT_KEY.ERROR_MSG.name(), e.getMessage());
            throw new MessagingException(e.getMessage());
        }
        
        return outputMap;
    }
    
    private Map<String,Object> findMessageMasterProcess(Map<String, Object> inputMap){
        try{
            outputMap=new Map<String,Object>(); 
            MessagingWrapperParams mwrec=new MessagingWrapperParams();
            String filterCriteria = '';
            String sortCriteria;
            List<Id> userIdList = null;
            String targetTopicRecordId = null;
            String masterId = null;
            Id messageParty1 = (Id)inputMap.get('messageParty1');
            Id messageParty2 = (Id)inputMap.get('messageParty2');
            Boolean isEscalated = False;
            
            if(inputMap.get('masterId')!=null && String.isNotBlank((String)inputMap.get('masterId'))){
                masterId = (String)inputMap.get('masterId');
                filterCriteria = ' AND Id = :masterId ';
            }
            else{
                if(messageParty1 != null && messageParty2 != null){
                    filterCriteria += ' AND ((createdbyid = :messageParty1 AND message_to__c = :messageParty2) OR (createdbyid = :messageParty2 AND message_to__c = :messageParty1)) ';
                    //filterCriteria += ' AND (message_to__c = :messageParty2 OR message_to__c = :messageParty1) ';
                }
                else if(messageParty1 != null){
                    filterCriteria += ' AND (createdbyid = :messageParty1 OR message_to__c = :messageParty1) ';
                }
                else if(messageParty2 != null){
                    filterCriteria += ' AND (createdbyid = :messageParty2 OR message_to__c = :messageParty2) ';
                }
                
                if(inputMap.containsKey('TargetTopicId')){
                    targetTopicRecordId = (String) inputMap.get('TargetTopicId');
                    filterCriteria += ' AND recordid__c = :targetTopicRecordId ';
                }
                
                if(inputMap.containsKey('isEscalated')){
                    isEscalated = Boolean.valueOf(inputMap.get('isEscalated'));
                    filterCriteria += ' AND isescalated__c = :isEscalated ';
                }
            }       
            
            sortCriteria = ' createddate Desc ';
            
            String qry = 'SELECT createdbyid,' 
                + ' createdby.NAME, '
                + ' createdby.managerid, '
                + ' createdby.manager.NAME, '
                + ' message_to__c, '
                + ' message_to__r.NAME, '
                + ' message_to__r.managerid, '
                + ' message_to__r.manager.NAME, '
                + ' createddate, '
                + ' id, '
                + ' NAME, '
                + ' isescalated__c, '
                + ' recordid__c, '
                + ' sobjecttype__c, '
                + ' recordtypeid, '
                + ' recordtype.NAME '
                + ' FROM   messaging_master__c ';
            if(!String.isBlank(filterCriteria)){
                qry += ' WHERE ' + filterCriteria.substring(4);
            }
            if(!String.isBlank(sortCriteria)){
                qry += ' ORDER BY ' + sortCriteria;
            }
            
            System.debug( 'final query:' + qry);
            System.debug( 'Anup messageParty1:' + messageParty1+'___messageParty2_'+messageParty2+'___targetTopicRecordId_'+targetTopicRecordId);
            List<Messaging_Master__c> queryResults = DataBase.Query(qry);
            mwrec.messagingMasterList=queryResults;
            System.debug( 'messagge master data queryResults:' + queryResults);
            outputMap.put('messageWrapObj',mwrec);
        }
        catch(Exception e){
            
        }
         return outputMap;
    }
    private virtual Map<String,Object> dispatchMessageProcess(Map<String, Object> inpMap){
        
        try{
            String jsonResponse = null;
            MessagingWrapperParams outJSON = new MessagingWrapperParams();
            //Map<String,String> inpMap = (Map<String, String>)JSON.deserialize(paramMapStr, Map<String, String>.class);

            //MessagingServiceLayerHandler msgSrvHandler = new MessagingServiceLayerHandler(MessagingAppLiterals.PROCESSNAME.PhysicianUIDashBoard);
            Map<String, Object> inputBsnsMap = new Map<String, Object>();
            Messaging_Master__c msgMasterRec = null;
            Messaging_Detail__c msgDtlRec = null;
            Id messageMasterId = null;
            Boolean existingMessageChain = false;
            if(inpMap.containsKey('msgMasterId')){
                try{
                    messageMasterId = Id.valueOf((String)inpMap.get('msgMasterId'));
                    if(messageMasterId != null){
                        existingMessageChain = true;
                    }
                } catch(Exception e){
                    System.debug(LoggingLevel.FINER, 'messageMasterId parse error:' + e);
                }
            }
            if(inpMap.containsKey('isEscalated') && ((Boolean)inpMap.get('isEscalated'))){
                inputBsnsMap.put('isEscalated', inpMap.get('isEscalated'));
            }
            if(inpMap.containsKey('messageParty1')){
                inputBsnsMap.put('messageParty1', inpMap.get('messageParty1'));
            }
            if(inpMap.containsKey('messageParty2')){
                inputBsnsMap.put('messageParty2', inpMap.get('messageParty2'));
            }
            //{"messageParty1":"00537000001gHdUAAU","messageParty2":"0050v000002z1FwAAI","msgMasterId":null,"TargetTypeSobjectAPI":"SOAP_Note__c","recordId":"a0X0v000001BGQNEA4","messageContent":"gvj"}
            if(!existingMessageChain){
                System.debug(LoggingLevel.FINE, 'Message chain does not exists.');
                if(inpMap.containsKey('recordId')){
                    inputBsnsMap.put('TargetTopicId', inpMap.get('recordId'));
                }
                if(inpMap.containsKey('TargetTypeSobjectAPI')){
                    inputBsnsMap.put('TargetTypeSobjectAPI', inpMap.get('TargetTypeSobjectAPI'));
                }
                if(inpMap.containsKey('isEscalated')){
                    inputBsnsMap.put('isEscalated', inpMap.get('isEscalated'));
                }
                //List<Messaging_Master__c> msgMasterLst = msgSrvHandler.findMessageMaster(inputBsnsMap);
                Map<String,Object>outputMap=this.findMessageMasterProcess(inputBsnsMap);
                MessagingWrapperParams wrapParmaObj=(MessagingWrapperParams)outputMap.get('messageWrapObj');
                List<Messaging_Master__c> msgMasterLst = wrapParmaObj.messagingMasterList;
                if(msgMasterLst == null || msgMasterLst.size() == 0){
                    msgMasterRec = this.initiateMessageMaster(inputBsnsMap);
                } else{
                    msgMasterRec = msgMasterLst[0];
                }
                if(msgMasterRec != null){
                    messageMasterId = msgMasterRec.Id;
                    existingMessageChain = true;
                }

                System.debug(System.LoggingLevel.FINER, 'dispatchMessage msgMasterRec:' + msgMasterRec);
            }
            System.debug(System.LoggingLevel.FINER, 'dispatchMessage messageMasterId:' + messageMasterId);
            System.debug(System.LoggingLevel.FINER, 'dispatchMessage existingMessageChain:' + existingMessageChain);

            if(existingMessageChain){
                inputBsnsMap.put('msgMasterId', messageMasterId);
                
                if(inpMap.containsKey('messageContent')){
                    inputBsnsMap.put('messageContent', inpMap.get('messageContent'));
                }

                msgDtlRec = this.initiateMessageDetail(inputBsnsMap);
                outputMap.put('msgDtlRec',msgDtlRec);
            }
        }catch(Exception e){
            throw e;
        }
        return outputMap;
    }
    
    
     private virtual Messaging_Master__c initiateMessageMaster(Map<String, Object> inputBsnsMap){
        System.debug('messagge master inputBsnsMap:' + inputBsnsMap);
        Set<String> fieldSet = new Set<String>();
        Messaging_Master__c msgMasterRec = new Messaging_Master__c();
        //msgMasterRec.RecordTypeId = inputBsnsMap.get('recordTypeID');
        if(inputBsnsMap.containsKey('messageParty1')){
            msgMasterRec.message_to__c = (Id) inputBsnsMap.get('messageParty1');
            fieldSet.add('message_to__c');
        }
        if(inputBsnsMap.containsKey('TargetTopicId')){
            msgMasterRec.recordid__c = (String) inputBsnsMap.get('TargetTopicId');
            fieldSet.add('recordid__c');
        }
        if(inputBsnsMap.containsKey('TargetTypeSobjectAPI')){
            msgMasterRec.sobjecttype__c = (String) inputBsnsMap.get('TargetTypeSobjectAPI');
            fieldSet.add('sobjecttype__c');
        }
        if(inputBsnsMap.containsKey('isEscalated')){
            msgMasterRec.isescalated__c = Boolean.valueOf(inputBsnsMap.get('isEscalated'));
            fieldSet.add('isescalated__c');
        }
        boolean performDML=true;
        if(performDML){
            AccessSecurity.insertAsUser(msgMasterRec, fieldSet);
        }
        
        return msgMasterRec;
        
    }
    
    private virtual Messaging_Detail__c initiateMessageDetail(Map<String, Object> inputBsnsMap){
        System.debug('messagge detail inputBsnsMap:' + inputBsnsMap);
        Set<String> fieldSet = new Set<String>();
        Messaging_Detail__c msgDtlRec = new Messaging_Detail__c();
        if(inputBsnsMap.containsKey('messageParty1')){
            msgDtlRec.To__c = (Id) inputBsnsMap.get('messageParty1');
            fieldSet.add('To__c');
        }
        if(inputBsnsMap.containsKey('messageParty2')){
            msgDtlRec.From__c = (Id) inputBsnsMap.get('messageParty2');
            fieldSet.add('From__c');
        }
        if(inputBsnsMap.containsKey('msgMasterId')){
            msgDtlRec.Messaging_Master__c = (Id) inputBsnsMap.get('msgMasterId');
            //msgDtlRec.Messaging_Master__c = masterID;
            fieldSet.add('Messaging_Master__c');
        }
        if(inputBsnsMap.containsKey('messageContent')){
            msgDtlRec.Message__c = (String) inputBsnsMap.get('messageContent');
            fieldSet.add('Message__c');
        }
        
        msgDtlRec.Read_Message__c = false;
        fieldSet.add('Read_Message__c');
        
       // if(performDML){
            AccessSecurity.insertAsUser(msgDtlRec, fieldSet);
       // }
        
        return msgDtlRec;
        
    }
    
    private virtual Map<String, Object> fetchMessagesFromDetailObject(Map<String, Object> inputMap){
        Id masterId=(String)inputMap.get('msgMasterId');
        Map<String,Object> outPutMap=new Map<String,Object>();
        Integer lmt=Integer.valueOf(MessagingUtility.MessageCenterMdtMap.get(MessagingAppLiterals.GENERIC_KEYS.Max_Chain_Message_Count.name()).value__c);
        List<MessagingWrapperParams.MessageChainParms> oldMsgList=new List<MessagingWrapperParams.MessageChainParms>();
        List<Messaging_Detail__c>detailObjLst=[select id,From__r.Name,Message__c,createddate from Messaging_Detail__c where Messaging_Master__c=: masterId order by createddate desc limit :lmt];
        for(Messaging_Detail__c md:detailObjLst){
            DateTime dt=md.createddate;
            String dtStr=dt.format('MM/dd/yyyy hh:mm a');
            oldMsgList.add(new MessagingWrapperParams.MessageChainParms(md.From__r.Name,md.Message__c,dtStr));
        }
        
        outPutMap.put('messageHistoryChain',oldMsgList);
        system.debug('outPutMap-fromdetail-->'+outPutMap);
        return outPutMap;
    }
    //Created by Shabbir to get final msgdashboard wrapper record list for main class 
    private virtual Map<String,Object> fetchMsgDashboardwrplst(Map<String, Object> inputMap){
        Map<String,Object> outputMap=new Map<String,Object>();
        boolean isReadMessage = true;
        string userId='';
        String extPhysicianProfileName='EXT_Physician';
        String fetchSubOrdinates=inputMap.get('fetchSubOrdinates')!=null ? (String)inputMap.get('fetchSubOrdinates') : 'false';

        userId=(String)inputMap.get('apcorphyid');      
        if(string.isEmpty(userId) || userId == null ){
            userId=userInfo.getUserId();       
        }                
        List<Messaging_Master__c> messgMaster=new List<Messaging_Master__c>();
        if(fetchSubOrdinates.equalsIgnoreCase('true')){
            messgMaster=[SELECT Id,isEscalated__c,createdBy.LastName,createdBy.FirstName,Message_To__r.FirstName,Message_To__r.LastName,createdBy.profile.name,Message_To__r.Profile.Name,Name,Message_To__c,Message_To__r.Name,RecordId__c,SobjectType__c,CreatedBy.Name,CreatedDate,(select id,From__c,To__c,Read_Message__c,createddate from Messaging_Details__r  order BY createddate  desc  limit 1 ) from Messaging_Master__c where Message_To__r.managerId =:userId OR CreatedBy.managerId =:userId ];
        }else{
            messgMaster=[SELECT Id,isEscalated__c,createdBy.LastName,createdBy.FirstName,Message_To__r.FirstName,Message_To__r.LastName,createdBy.profile.name,Message_To__r.Profile.Name,Name,Message_To__c,Message_To__r.Name,RecordId__c,SobjectType__c,CreatedBy.Name,CreatedDate,(select id,From__c,To__c,Read_Message__c,createddate from Messaging_Details__r  order BY createddate desc limit 1 ) from Messaging_Master__c where Message_To__c =:userId OR CreatedById =:userId ];
        }
        
        
        if(!messgMaster.isEmpty()){
            set<Id> rIds=new set<Id>();
            for(Messaging_Master__c mmforSoapCase:messgMaster){
                if(mmforSoapCase.RecordId__c != null){
                    rIds.add(mmforSoapCase.RecordId__c);
                }   
            }
            Map<string,MessagingWrapperParams.recordWrap> recMap=new Map<string,MessagingWrapperParams.recordWrap>();
            if(rIds != null && rIds.size() > 0){            
                recMap= getRecordMap(rIds);   
            }              
            
            List<MessagingWrapperParams.msgWrapClass> msgwrpLst=new List<MessagingWrapperParams.msgWrapClass>();
            for(Messaging_Master__c mm:messgMaster){
                isReadMessage = true;
                string rFrom='';
                String rcvdFromId='';
                //string rid='';
                rFrom=((mm.CreatedById != userid) ? mm.CreatedBy.Name : mm.Message_To__r.Name);  system.debug('--rFrom--'+rFrom+'----userid---'+userid);                         
                rcvdFromId=((mm.CreatedById != userid) ? mm.CreatedById : mm.Message_To__c );
                MessagingWrapperParams.msgWrapClass mwrec=new MessagingWrapperParams.msgWrapClass();
                
                for(Messaging_Detail__c md:mm.Messaging_Details__r){
                    mwrec.Received= md.createddate.format();
                    if(!md.Read_Message__c && (md.To__c == userid)) {
                        isReadMessage = false;
                        break;
                    }
                }
                mwrec.IsReadMessage = isReadMessage;
                mwrec.ReceivedFromId = rcvdFromId;
                mwrec.ReceivedFrom=rFrom;
                if(mm.isEscalated__c){
                    mwrec.escalatedStatus='Yes';
                }else{
                    mwrec.escalatedStatus='';
                }

                if(extPhysicianProfileName.equalsIgnoreCase(mm.createdBy.profile.name)){
                    mwrec.contactId=mm.createdById;
                    mwrec.contactName=mm.createdBy.FirstName+' '+mm.createdBy.LastName; 
                }else{
                    mwrec.contactId=mm.Message_To__c;
                    mwrec.contactName=mm.Message_To__r.FirstName+' '+mm.Message_To__r.LastName;
                }



                string typemsg='';
                if(mm.SobjectType__c != null){
                    Map<String,String>sobjectTypeToLable=(Map<String, String>)JSON.deserialize(MessagingUtility.MessageCenterMdtMap.get('Sobject_Name_to_Label').value__c, Map<String, String>.class);
                    typemsg=sobjectTypeToLable.get(mm.SobjectType__c);
                }
                mwrec.TypeofMessage=(typemsg != null ? typemsg : 'General Message');                
                //mwrec.Received= mm.createddate.format();
                mwrec.apcId=((mm.RecordId__c!=null && recMap.containsKey(mm.RecordId__c))? recMap.get(mm.RecordId__c).agrApcId : '');
                mwrec.apcName=((mm.RecordId__c!=null && recMap.containsKey(mm.RecordId__c))? recMap.get(mm.RecordId__c).agrApcName : '');
                mwrec.RelatedtoMember=((mm.RecordId__c!=null && recMap.containsKey(mm.RecordId__c))? recMap.get(mm.RecordId__c).RelatedtoMember : '');
                mwrec.RelatedtoRecord=((mm.RecordId__c!=null && recMap.containsKey(mm.RecordId__c))? recMap.get(mm.RecordId__c).RecordName : '');
                mwrec.RecordDate=((mm.RecordId__c!=null && recMap.containsKey(mm.RecordId__c))? recMap.get(mm.RecordId__c).RecordDate : '');
                mwrec.RecordId=(mm.RecordId__c!=null? mm.RecordId__c : '');
                mwrec.EngRecId=((mm.RecordId__c!=null && recMap.containsKey(mm.RecordId__c))? recMap.get(mm.RecordId__c).EngId : '');
                mwrec.msgMasterId = (String)mm.Id;
                msgwrpLst.add(mwrec);
            }
            if(!msgwrpLst.isEmpty()){
                outputMap.put('msgwrpLst',msgwrpLst);
                //return msgwrpLst;
                return outputMap;
            }
        }
        return outputMap;
    }
    
    //Created by Shabbir to get Soap Note Ids and Case Ids based on recordids for Dashboard
    private virtual Map<string,MessagingWrapperParams.recordWrap> getRecordMap(set<Id> sIds){
        set<Id> soapidSet=new set<Id>();
        set<Id> caseidSet=new set<Id>();
        set<Id> agreementIds=new set<Id>();
        Map<string,MessagingWrapperParams.recordWrap> rcMap=new Map<string,MessagingWrapperParams.recordWrap>();
        for(id sid:sIds){
            if(string.valueof(sid.getSobjectType()) == MessagingAppLiterals.Case_Object){
                caseidSet.add(sid);    
            }else  if(string.valueof(sid.getSobjectType()) == MessagingAppLiterals.SOAP_NOTE){
                soapidSet.add(sid);    
            }else if(string.valueof(sid.getSobjectType()) == MessagingAppLiterals.COLLABORATIVE_AGREEMENT_OBJECT){
                agreementIds.add(sid);
            }
        }
        
        if(!caseidSet.isEmpty() && caseidSet != null){            
            for(Case c:[SELECT Id, Contact.Name,CreatedDate,Createdbyid,createdby.firstName,createdby.lastName,createdBy.managerId,createdBy.manager.Name,CaseNumber,Engagement__c  from case where id in : caseidSet]){
                MessagingWrapperParams.recordWrap recwrpcase=new MessagingWrapperParams.recordWrap();
                recwrpcase.RelatedtoMember=(c.Contact.Name != null? c.Contact.Name : '');
                recwrpcase.RecordName=c.CaseNumber;
                Date d=Date.valueof(c.CreatedDate);
                recwrpcase.RecordDate= DateTime.newInstance(d.year(),d.month(),d.day()).format('MM/dd/yyyy'); 
                recwrpcase.EngId=(c.Engagement__c != null ? c.Engagement__c+ '' : '');
                recwrpcase.agrApcId=c.CreatedbyId;
                recwrpcase.agrApcManagerId=c.createdBy.managerId;
                recwrpcase.agrApcManagerName=c.createdBy.manager.Name;
                recwrpcase.agrApcName=c.createdby.firstName+' '+c.createdby.lastName;
                rcMap.put(c.Id,recwrpcase);        
            }
        }
        if(!soapidSet.isEmpty() && soapidSet != null){
            for(soap_note__c s:[SELECT Id, Name, Consumer__r.Name,Createdbyid,createdby.firstName,createdby.lastName,createdBy.managerId,createdBy.manager.Name,CreatedDate,Engagement_ID__c from soap_note__c where id in : soapidSet]){              
                MessagingWrapperParams.recordWrap recwrpsoap=new MessagingWrapperParams.recordWrap();
                recwrpsoap.RelatedtoMember=(s.Consumer__r.Name != null? s.Consumer__r.Name : '');
                recwrpsoap.RecordName=s.Name;
                Date d=Date.valueof(s.CreatedDate);
                recwrpsoap.RecordDate= DateTime.newInstance(d.year(),d.month(),d.day()).format('MM/dd/yyyy'); 
                recwrpsoap.EngId = (s.Engagement_Id__c != null ? s.Engagement_ID__c+'' : '');
                recwrpsoap.agrApcId=s.CreatedbyId;
                recwrpsoap.agrApcManagerId=s.createdBy.managerId;
                recwrpsoap.agrApcManagerName=s.createdBy.manager.Name;
                recwrpsoap.agrApcName=s.createdby.firstName+' '+s.createdby.lastName;
                rcMap.put(s.Id,recwrpsoap);    
            }
        }
        if(agreementIds!=null && agreementIds.size()>0){
            for(Collaborative_Agreement__c agr:[select id,Name,State__c,Status__c,Nurse_Practitioner_ID__c,Nurse_Practitioner_ID__r.FirstName,Nurse_Practitioner_ID__r.LastName,Nurse_Practitioner_ID__r.managerId,Nurse_Practitioner_ID__r.manager.name from Collaborative_Agreement__c where id in : agreementIds ]){
                MessagingWrapperParams.recordWrap recwrpAgr=new MessagingWrapperParams.recordWrap();
                recwrpAgr.RelatedtoMember='';
                recwrpAgr.RecordName='';
                recwrpAgr.RecordDate= '';
                recwrpAgr.EngId = '';
                recwrpAgr.agrApcManagerId=agr.Nurse_Practitioner_ID__r.managerId;
                recwrpAgr.agrApcManagerName=agr.Nurse_Practitioner_ID__r.manager.Name;
                recwrpAgr.agrApcId=agr.Nurse_Practitioner_ID__c;
                recwrpAgr.agrApcName=agr.Nurse_Practitioner_ID__r.FirstName+' '+agr.Nurse_Practitioner_ID__r.LastName;
                recwrpAgr.agreementName=agr.Name;
				recwrpAgr.agreementAlias=agr.Name + ' - ' + agr.State__c + ' - ' + agr.Status__c;
                rcMap.put(agr.Id,recwrpAgr);
            }
        }

        if(rcMap != null){  
            return rcMap;
        }
        return null;
    }
    
    
    private List<Database.SaveResult> manageSharingMessageRecords(set<Id> sIds){
        System.debug('Anup manageSharingMessageRecords '+sIds);
        Map<String, Profile> profileNameMap = MessagingUtility.getProfileNameMap();
        Profile providerProfile = profileNameMap.get(Label.Profile_Provider);
        Profile extPhysicianProfile = profileNameMap.get(Label.Profile_EXT_CollabPhy);
        Profile managerProfile = profileNameMap.get(Label.Profile_Manager);

        List<Database.SaveResult> dbShareResult = null;
        List<Messaging_Master__Share> msgMstShrLst = new List<Messaging_Master__Share>();
        for(Messaging_Master__c msgMstrRec : [SELECT createdbyid, 
                                                    createdby.IsActive, 
                                                    createdby.managerid, 
                                                    createdby.manager.IsActive, 
                                                    createdby.profileid, 
                                                    message_to__c, 
                                                    message_to__r.managerid,
                                                    message_to__r.manager.IsActive, 
                                                    message_to__r.profileid, 
                                                    message_to__r.IsActive, 
                                                    recordtypeid,
                                                    isEscalated__c
                                              FROM   messaging_master__c 
                                              WHERE  id IN:sIds ])
        {
            if(msgMstrRec.recordtypeid == MessagingUtility.RECTYP_Messaging_Master_PhysicianMessaging){
                if(msgMstrRec.createdby.profileid == providerProfile.Id 
                    || msgMstrRec.createdby.profileid == managerProfile.Id) // Provider or Manager APC creating the message
                {    
                    msgMstShrLst.add(MessagingUtility.getMessagingMasterShareRec(msgMstrRec.Id, (msgMstrRec.message_to__c + ''))); // share with Physician
                    if(!msgMstrRec.isEscalated__c       // Not able to bypass manager's general message to apc's physician sharing with his manager
                       && msgMstrRec.createdby.managerid != null 
                       && msgMstrRec.createdby.manager.IsActive){
                           msgMstShrLst.add(MessagingUtility.getMessagingMasterShareRec(msgMstrRec.Id, (msgMstrRec.createdby.managerid + '')));   // share with manager
                       }
                }
                else if(msgMstrRec.createdby.profileid == extPhysicianProfile.Id ) //Physician is creating the messsage
                {
                    msgMstShrLst.add(MessagingUtility.getMessagingMasterShareRec(msgMstrRec.Id, (msgMstrRec.message_to__c + ''))); // share with APC/manager
                    if(msgMstrRec.message_to__r.managerid != null 
                       && msgMstrRec.message_to__r.manager.IsActive)
                    {
                        msgMstShrLst.add(MessagingUtility.getMessagingMasterShareRec(msgMstrRec.Id, (msgMstrRec.message_to__r.managerid + '')));   // share with manager
                    }
                }
            }
        }
        
        if(msgMstShrLst.size() > 0){
            dbShareResult = MessagingWOSharingUtility.insertMessageShareRecords(msgMstShrLst, false);
        }
        
        return dbShareResult;
    }
    
	 private virtual Map<String, Object> fetchMsgDetailsforView(Map<String, Object> inputMap){
	        Map<String,Object> outputMap=new Map<String,Object>();
	        string masterId='';
	        boolean isReadMessage = true; 
	        masterId=(String)inputMap.get('masterId'); 
	        System.debug('Anup masterId '+masterId);
	        List<Messaging_Master__c> messgMaster=new List<Messaging_Master__c>();
	        messgMaster=[SELECT id, 
	                            NAME, 
	                            message_to__c, 
	                            message_to__r.NAME, 
	                            recordid__c, 
	                            sobjecttype__c, 
	                            createdby.NAME,
	                            createdby.profileId,
	                            createdby.profile.Name, 
	                            message_to__r.profileId,
	                            message_to__r.profile.Name,
	                            createddate,
	                            IsEscalated__c, 
	                            (SELECT id, 
	                                    from__c, 
	                                    to__c, 
	                                    read_message__c, 
	                                    message__c 
	                                FROM   messaging_details__r) 
	                        FROM   messaging_master__c 
	                        WHERE  id = :masterId 
	                        ORDER  BY createddate DESC  ];
	        System.debug('Anup messgMaster '+messgMaster);
			if(!messgMaster.isEmpty()){
	            
	            set<Id> rIds = new set<Id>();
	            set<Id> aggreementIds = new set<Id>();//Added by Parag
			    set<Id> soapOrCaseIds = new set<Id>();//Added by Parag
	        
	            String typemsg='';
	            Id extProfileId=null; //Id other than Provider and Manager profile
				for(Messaging_Master__c mmforSoapCase:messgMaster){
	                //Label.Profile_Provider, Label.Profile_EXT_CollabPhy,Label.Profile_Manager
					if(!(Label.Profile_Provider.equalsIgnoreCase( mmforSoapCase.createdBY.Profile.name) || Label.Profile_Manager.equalsIgnoreCase( mmforSoapCase.createdBY.Profile.name))){
						extProfileId=mmforSoapCase.createdBY.ProfileId;
					}else{
						extProfileId=mmforSoapCase.message_to__r.profileId;
					}
					
					if(mmforSoapCase.RecordId__c != null){
						rIds.add(mmforSoapCase.RecordId__c);
						
						//Added by Parag - Start
						typemsg = mmforSoapCase.SobjectType__c;
	                    if(mmforSoapCase.SobjectType__c.containsIgnoreCase(MessagingAppLiterals.COLLABORATIVE_AGREEMENT_OBJECT )){
	                       aggreementIds.add(mmforSoapCase.RecordId__c);
	                    }else{
						   soapOrCaseIds.add(mmforSoapCase.RecordId__c);
						}
						//Added by Parag - End
					}
			
					//Added for read messsgae check
	                for(Messaging_Detail__c messDetail:mmforSoapCase.Messaging_Details__r){
	                    if(!messDetail.Read_Message__c){
	                        isReadMessage = false;    
	                    }
	                }
	            }
				
	        Map<string,MessagingWrapperParams.recordWrap> recMap=new Map<string,MessagingWrapperParams.recordWrap>();
	            if(rIds != null && rIds.size() > 0){            
	                recMap= getRecordMap(rIds);   
	            }              
		
            //Added by Parag - Start
            //This is used to get the aggrement details from the soap note or case id  		
			Map<Id,Concurrent_Chart_Assignment__c>  ccaDetailsMap = new Map<Id,Concurrent_Chart_Assignment__c>();
	
			List<Concurrent_Chart_Assignment__c> ccaDetails = [SELECT agreement_id__c,agreement_id__r.Name,agreement_id__r.State__c,agreement_id__r.Status__c, reviewforsobjectid__c, reviewforsobject__c, status__c FROM concurrent_chart_assignment__c WHERE reviewforsobjectid__c in:soapOrCaseIds AND agreement_id__r.Agreement_For__c = :typemsg];
		   
			for(Concurrent_Chart_Assignment__c cca:ccaDetails){
			   ccaDetailsMap.put(cca.reviewforsobjectid__c,cca);
			}   
			//Added by Parag - End
			   
			List<MessagingWrapperParams.ColAgreementWrapper> colAgrwrpLst=new List<MessagingWrapperParams.ColAgreementWrapper>();
	        for(Messaging_Master__c mm:messgMaster){
	            MessagingWrapperParams.ColAgreementWrapper carec=new MessagingWrapperParams.ColAgreementWrapper('','','','','', Date.today(), Date.today(),'');
	            carec.nurseId = ((mm.RecordId__c!=null && recMap.containsKey(mm.RecordId__c))? recMap.get(mm.RecordId__c).agrApcId : '');
	            carec.NurseName = ((mm.RecordId__c!=null && recMap.containsKey(mm.RecordId__c))? recMap.get(mm.RecordId__c).agrApcName : '');
	            
	            carec.physicianId = (( mm.message_to__c != carec.nurseId) ? mm.message_to__c : mm.CreatedById);
	            carec.physicianName = ((mm.message_to__c != carec.nurseId) ? mm.message_to__r.Name :  mm.CreatedBy.Name);
	            
	            //below code is to detect if manager is sending message for perticular APC to APC'S physician
	            if(carec.nurseId !=mm.createdbyId && carec.nurseId != mm.message_to__c && userInfo.getProfileId()==extProfileId && !mm.IsEscalated__c){
	            	//Means manager has sent message to physican
	            	if(mm.message_to__r.profileId==extProfileId){
	            		carec.nurseId=mm.createdbyId;
	            		//carec.NurseName=mm.createdBy.Name;
	            	}else{
	            		carec.nurseId=mm.message_to__c;
	            		//carec.NurseName=mm.message_to__r.Name;
	            	}
	            	
	            }else if(carec.nurseId !=mm.createdbyId && carec.nurseId != mm.message_to__c && userInfo.getProfileId()!=extProfileId && !mm.IsEscalated__c){
            		//Means Physician has escalated message and viewed by manager
	            	if(mm.message_to__r.profileId==extProfileId){
	            		carec.physicianId=mm.message_to__c;
	            		carec.physicianName=mm.message_to__r.Name;
	            	}else{
	            		carec.physicianId=mm.Createdbyid;
	            		carec.physicianName=mm.Createdby.Name;
	            	}
	            }
	            
	            if(carec.nurseId !=mm.createdbyId && carec.nurseId != mm.message_to__c && userInfo.getProfileId()!=extProfileId && mm.IsEscalated__c){
	            	// Escalated message sent by physician regarding APC's subordinates. If same apc manager is viewing this message
	            	carec.nurseId=userInfo.getUserId();
	            	if(mm.message_to__r.profileId==extProfileId){
	            		carec.physicianId=mm.message_to__c;
	            		carec.physicianName=mm.message_to__r.Name;
	            	}else{
	            		carec.physicianId=mm.Createdbyid;
	            		carec.physicianName=mm.Createdby.Name;
	            	}
	            	
	            }
	            
	            carec.managerUserName =((mm.RecordId__c!=null && recMap.containsKey(mm.RecordId__c))? recMap.get(mm.RecordId__c).agrApcManagerName : ''); 
	            carec.managerUserId = ((mm.RecordId__c!=null && recMap.containsKey(mm.RecordId__c))? recMap.get(mm.RecordId__c).agrApcManagerId : '');
	            carec.recordId=mm.RecordId__c;
	            carec.isEscalated=mm.IsEscalated__c;
	            
	            carec.typeSobjectAPI = mm.SobjectType__c;
	            string caId = '';
	            string snorcaseId = '';
	            if(mm.SobjectType__c != null){
	                if(mm.SobjectType__c.containsIgnoreCase(MessagingAppLiterals.COLLABORATIVE_AGREEMENT_OBJECT ))
	                {
	                    caId = (String)mm.RecordId__c;    
	                    carec.memberName = '';
	                    carec.soapCaseName = '';
						MessagingWrapperParams.recordWrap caRecord = recMap.get(caId);
				  	    carec.agreementAlias = caRecord.agreementAlias;
	                    carec.agreementName = caRecord.agreementName;
				
	                }
	                else{
	                    carec.memberName = ((mm.RecordId__c!=null && recMap.containsKey(mm.RecordId__c))? recMap.get(mm.RecordId__c).RelatedtoMember : '');
	                    carec.soapCaseName = ((mm.RecordId__c!=null && recMap.containsKey(mm.RecordId__c))? recMap.get(mm.RecordId__c).RecordName : '');
	                    carec.recordId = (String)mm.RecordId__c;  
	                    snorcaseId = (String)mm.RecordId__c; 
	                    concurrent_chart_assignment__c ccaRecord = ccaDetailsMap.get(snorcaseId);
						caId = (string)ccaRecord.agreement_id__c;
						carec.agreementAlias = ccaRecord.agreement_id__r.Name + ' - ' + ccaRecord.agreement_id__r.State__c + ' - ' + ccaRecord.agreement_id__r.Status__c;
	                    carec.agreementName = ccaRecord.agreement_id__r.Name;
	                }
			    }
	            colAgrwrpLst.add(carec);
	        }
			
	        if(!colAgrwrpLst.isEmpty()){
	            system.debug('isReadMessage:'+isReadMessage);
	            //If message if unread then update the flag
	            if(!isReadMessage){
	                updateReadMessageFlag(messgMaster);    
	            }
	            outputMap.put('colAgrwrpLst',colAgrwrpLst);
	            return outputMap;
	        }
	    }
	    return null;
	}
    
    //This method is used update Read message flag
    private virtual void updateReadMessageFlag(List<Messaging_Master__c> messgMaster){
        
        Set<String> fieldSet = new Set<String>();
        
        List<Messaging_Detail__c> msgDetail = new List<Messaging_Detail__c>();
        
        if(!messgMaster.isEmpty()){
            
            for(Messaging_Detail__c md:messgMaster[0].Messaging_Details__r){
                
                if(md.To__c==UserInfo.getUserId()){
                    md.Read_Message__c=true;
                    msgDetail.add(md);
                }
                
            }
            fieldSet.add('id');
            fieldSet.add('Read_Message__c');
        }
        system.debug('msgDetail:'+msgDetail);
        system.debug('fieldSet:'+fieldSet);
        if(msgDetail!=null && msgDetail.size()>0){
            AccessSecurity.updateAsUser(msgDetail, fieldSet);    
        }
        
    }

    private Map<String, Object> fetchMustacheTemplate(Map<String, Object> inputMap){
        Map<String,Object> outputMap=new Map<String,Object>();
        boolean isErroneous = true;
        if (inputMap.get(MessagingAppLiterals.INPUT_KEY.STATIC_RESOURCE_NAME.name()) != null) {
            List<String> resourceKeys = (List<String>)inputMap.get(MessagingAppLiterals.INPUT_KEY.STATIC_RESOURCE_NAME.name());
            if(resourceKeys != null && resourceKeys.size() >0){
                Map<String,String> staticResourceContentMap = MessagingUtility.getStaticResourceContent(resourceKeys);
                outputMap.put(MessagingAppLiterals.OUTPUT_KEY.MUSTACHE_TEMPLATE_MAP.name(), staticResourceContentMap);
                outputMap.put(MessagingAppLiterals.OUTPUT_KEY.IS_SUCCESS.name(), true);
                isErroneous = false;
            }
        }
        if(isErroneous){
            outputMap.put(MessagingAppLiterals.OUTPUT_KEY.IS_SUCCESS.name(), false);
            outputMap.put(MessagingAppLiterals.OUTPUT_KEY.ERROR_MSG.name(), 'Static resource key has not ben passed');
        }
        return outputMap;
    }


}