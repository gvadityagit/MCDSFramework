/**
 * @File Name          : Pathway_To_Sol_Integration_Utility.cls
 * @Description        : 
 * @Author             : Naveen Ila
 * @Group              : 
 * @Last Modified By   : Naveen Ila
 * @Last Modified On   : 2/17/2020, 3:06:18 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    2/17/2020   Naveen Ila     Initial Version
**/
public with sharing class Pathway_To_Sol_Integration_Utility {

    public JWT_Utility solOAuthDet; 

    /**
    * @description 
    * @author Naveen Ila | 2/17/2020 
    * @return void 
    **/
    public void fetchAccessTokenDetails () {

        solOAuthDet = new JWT_Utility();
        //NOTE: Move this to App Literals
        solOAuthDet.fetchAccessTokenDetails(Pathway_To_Sol_AppLiterals.ACCESS_TOKEN_MDT_NAME);

    }

    

    /**
    * @description 
    * @author Naveen Ila | 2/17/2020 
    * @return String 
    **/
    public String sendContactDataToSol (Map<Id, Contact> oldConMap, Map<Id, Contact> newConMap) {

        System.debug('$$$ oldConMap ' + oldConMap);
        System.debug('$$$ newConMap ' + newConMap);
        Pathway_To_Sol_API_Wrapper.ConDataChangeReqBody_Generator reqBodyObj = processContactData(oldConMap, newConMap);
        if (NULL != reqBodyObj 
            && NULL != reqBodyObj.contactData 
            && NULL != reqBodyObj.contactData.conList
            && (!reqBodyObj.contactData.conList.isEmpty())
            ) {
            
            return sendRequestWithGenericEndPoint(JSON.serialize(reqBodyObj), reqBodyObj.headerInfo.operationName);

        }

        return NULL;

    }



    /**
    * @description 
    * @author Naveen Ila | 2/17/2020 
    * @param HttpRequest req 
    * @return HttpResponse 
    **/
    public HttpResponse sendRequest (HttpRequest req) {

        Http htp = new Http();
        return htp.send(req);
        
    }

    /**
    * @description 
    * @author Naveen Ila | 2/17/2020 
    * @return Pathway_To_Sol_API_Wrapper.ConDataChangeReqBody_Generator 
    **/
   
    public Pathway_To_Sol_API_Wrapper.ConDataChangeReqBody_Generator processContactData (Map<Id,Contact> oldConMap, Map<Id, Contact> newConMap) {

        Pathway_To_Sol_API_Wrapper.ConDataChangeReqBody_Generator reqBodyObj = new Pathway_To_Sol_API_Wrapper.ConDataChangeReqBody_Generator();
        
        List<Pathway_To_Sol_API_Wrapper.ContactInfo> conInfos = new List<Pathway_To_Sol_API_Wrapper.ContactInfo>();

        for (Id conId : newConMap.keySet()) {
            Map<String,Object> conData = new Map<String,Object>();
            
            Contact newCon = newConMap.get(conId);
            Contact oldCon = oldConMap.get(conId);
            Boolean isConAddressChanged = isContactAddressModifiedCheck(oldCon, newCon, conData);
            Boolean isConPhoneChanged = isContactFieldsModifiedCheck(oldCon, newCon, fetchPathwaySolConPhoneFldMapping(), conData);
            
            if (isConAddressChanged || isConPhoneChanged) {

                Pathway_To_Sol_API_Wrapper.ContactInfo conInfo = new Pathway_To_Sol_API_Wrapper.ContactInfo();
                conData.put('Id', newCon.Id);
                conInfo.con = conData;
                
                conInfos.add(conInfo);
            }

        }

        if (conInfos.size() > 0) {
            
            reqBodyObj.contactData.conList = conInfos;
        }

        return reqBodyObj;

    }

    /**
    * @description 
    * @author Naveen Ila | 2/18/2020 
    * @param Contact oldCon 
    * @param Contact newCon 
    * @param Contact con 
    * @return Boolean 
    **/
    public Boolean isContactAddressModifiedCheck (Contact oldCon, Contact newCon, Map<String,Object> con) {

        Map<String,String> fldsToCheck = fetchPathwaySolConAddressFldMapping();
        return isContactFieldsModifiedCheck(oldCon, newCon, fldsToCheck, con);
        
    }

    /**
    * @description 
    * @author Naveen Ila | 2/18/2020 
    * @param Contact oldCon 
    * @param Contact newCon 
    * @param Set<String> fldsToCheck 
    * @param Contact con 
    * @return Boolean 
    **/
    public Boolean isContactFieldsModifiedCheck (Contact oldCon, Contact newCon, Map<String, String> fldsToCheck, Map<String,Object> obj) {

        Boolean isContactfldsModified = false;
        SObject oldConSobj = oldCon;
        SObject newConSobj = newCon;
        
        
        if (NULL != oldCon && NULL != newCon) {
            
            for (String fld : fldsToCheck.keySet()) {
                isContactfldsModified = isContactfldsModified || (oldConSobj.get(fld) != newConSobj.get(fld));
            }
        }

        if (isContactfldsModified) {
            transferData(fldsToCheck, newConSobj, obj);
        }

        return isContactfldsModified;
    }

    /**
    * @description 
    * @author Naveen Ila | 3/2/2020 
    * @param Map<String String> fldsToLoad 
    * @param SObject objFrom 
    * @param Map<String Object> objTo 
    * @return void 
    **/
    public void transferData (Map<String, String> fldsToLoad, SObject objFrom, Map<String, Object> objTo) {

        for (String fld : fldsToLoad.keySet()) {
            objTo.put(fldsToLoad.get(fld), objFrom.get(fld));
        }

    }

    /**
    * @description 
    * @author Naveen Ila | 3/2/2020 
    * @return Map<String, String> 
    **/
    public Map<String,String> fetchPathwaySolConAddressFldMapping() {

        //TODO: put these values in metadata configuration
        Map<String, String> mAddressFld = new Map<String, String>();
        mAddressFld.put('OtherStreet', 'MailingStreet');
        mAddressFld.put('OtherCity', 'MailingCity');
        mAddressFld.put('OtherState', 'MailingState');
        mAddressFld.put('OtherCountry', 'MailingCountry');
        mAddressFld.put('OtherPostalCode', 'MailingPostalCode');
        return mAddressFld;
        
    }

    /**
    * @description 
    * @author Naveen Ila | 3/2/2020 
    * @return Map<String, String> 
    **/
    public Map<String,String> fetchPathwaySolConPhoneFldMapping() {

        //TODO: put these values in metadata configuration
        return new Map<String, String>{'Primary_Phone__c' => 'Phone'};
        
    }

    /**
    * @description 
    * @author Naveen Ila | 3/2/2020 
    * @return Map<String, String> 
    **/
    public Map<String,String> fetchPathwaySolAccAddressFldMapping() {

        //TODO: put these values in metadata configuration
        Map<String, String> mAddressFld = new Map<String, String>();
        mAddressFld.put('ShippingStreet', 'BillingStreet');
        mAddressFld.put('ShippingCity', 'BillingCity');
        mAddressFld.put('ShippingState', 'BillingState');
        mAddressFld.put('ShippingCountry', 'BillingCountry');
        mAddressFld.put('ShippingPostalCode', 'BillingPostalCode');
        return mAddressFld;
        
    }

    /**
    * @description 
    * @author Naveen Ila | 2/20/2020 
    * @param Map<Id Engagement__c> oldEngMap 
    * @param List<Engagement__c> newEngList 
    * @return String 
    **/
    public String sendEngDataChangeToSol (Map<Id, Engagement__c> oldEngMap, List<Engagement__c> newEngList) {

        
        List<Pathway_To_Sol_API_Wrapper.EngInfo> engInfos = prepareEngDataChangeReqBody(oldEngMap, newEngList);
        if (!engInfos.isEmpty()) {
            

            Pathway_To_Sol_API_Wrapper.EngagementChagneDataGenerator reqBodyObj = new Pathway_To_Sol_API_Wrapper.EngagementChagneDataGenerator();
            reqBodyObj.engData.engList = engInfos;
            
            return sendRequestWithGenericEndPoint(JSON.serialize(reqBodyObj), reqBodyObj.headerInfo.operationName);


        }

        return NULL;
        
    }

    @future(callout=true)
    public static void processFutureCalloutData(string param){
        Map<String,Map<ID,Eng_Prog_Supp_Services__c>> ipMap = (Map<String,Map<ID,Eng_Prog_Supp_Services__c>>)JSON.deserialize(param,Map<String,Map<ID,Eng_Prog_Supp_Services__c>>.class);
        Map<ID,Eng_Prog_Supp_Services__c> oldEngSuppServiceMap= (Map<ID,Eng_Prog_Supp_Services__c>)ipMap.get('oldEngSuppServiceMap');
        Map<ID,Eng_Prog_Supp_Services__c> newEngSuppServiceMap= (Map<ID,Eng_Prog_Supp_Services__c>)ipMap.get('newEngSuppServiceMap');
        system.debug('****oldEngSuppServiceMap' +oldEngSuppServiceMap);
        system.debug('****newEngSuppServiceMap' +newEngSuppServiceMap);
        
        processEngSuppServiceHousecallConnect(newEngSuppServiceMap,oldEngSuppServiceMap);
        
    }

    public static void processEngSuppServiceHousecallConnect(Map<ID,Eng_Prog_Supp_Services__c> newEngSuppServiceMap,Map<ID,Eng_Prog_Supp_Services__c> oldEngSuppServiceMap){
        set<id> engId = new set<id>();
        if(newEngSuppServiceMap!=null){
            list<Eng_Prog_Supp_Services__c> engSuppLst = newEngSuppServiceMap.values();
            for(Eng_Prog_Supp_Services__c service : engSuppLst){
                if(string.isnotblank(service.Supplemental_Service__c) && service.Supplemental_Service__c.equals('HouseCalls Connect') &&
                (service.End_Date__c  == NULL || service.End_Date__c  >= system.today())){
                    engId.add(service.Engagement__c);

                }
            }

            if(engId!=null && engId.size()>0){
                Pathway_To_Sol_Integration_Utility pathwauUtility = new Pathway_To_Sol_Integration_Utility();
                system.debug('****api '+pathwauUtility.sendEngDataToSol(engId));
            }
        }
    }

    /**
    * @description : Send Eng Data to Sol (On Demand Service)
    * @author Naveen Ila | 3/3/2020 
    * @param Set<Id> engIdSet 
    * @return String 
    **/
    public String sendEngDataToSol (Set<Id> engIdSet) {


        
        List<Pathway_To_Sol_API_Wrapper.EngInfo> engInfos = prepareEngDataChangeReqBody(engIdSet);
        if (!engInfos.isEmpty()) {
            

            Pathway_To_Sol_API_Wrapper.EngagementChagneDataGenerator reqBodyObj = new Pathway_To_Sol_API_Wrapper.EngagementChagneDataGenerator();
            reqBodyObj.engData.engList = engInfos;
            
            return sendRequestWithGenericEndPoint(JSON.serialize(reqBodyObj), reqBodyObj.headerInfo.operationName);


        }

        return NULL;
        
    }

    /**
    * @description 
    * @author Naveen Ila | 2/20/2020 
    * @param Map<Id Engagement__c> oldEngMap 
    * @param List<Engagement__c> newEngList 
    * @return List<Pathway_To_Sol_API_Wrapper.EngInfo> 
    **/
    public List<Pathway_To_Sol_API_Wrapper.EngInfo> prepareEngDataChangeReqBody (Map<Id, Engagement__c> oldEngMap, List<Engagement__c> newEngList) {

        //List<Pathway_To_Sol_API_Wrapper.EngInfo> engInfos = new List<Pathway_To_Sol_API_Wrapper.EngInfo>();
        Set<Id> engIdSetForConDataPush = new Set<Id>();
        Set<String> engRiskLevelsForConDataPush = fetchEngRiskLevelsForConDataPush();
        Map<Id, Engagement__c> mNewEng = new Map<Id, Engagement__c>();
        
        Map<Id, Pathway_To_Sol_API_Wrapper.EngInfo> mMemIdVsEngInfo = new Map<Id, Pathway_To_Sol_API_Wrapper.EngInfo>();

        if (NULL != newEngList && !newEngList.isEmpty()) {
            mNewEng.putAll(newEngList);
        

            for (Engagement__c eng : newEngList) {

                Pathway_To_Sol_API_Wrapper.EngInfo engInfo;            
                Engagement__c oldEng = oldEngMap.get(eng.Id);
                
                Map<String, Object> conObj;
                if(oldEng.Risk_Level__c != eng.Risk_Level__c 
                    && eng.Program_Status_Eng__c == Pathway_To_Sol_AppLiterals.ENG_PROG_STATUS_OPEN) {

                    engInfo = populateEngInfoBaseDetails(engInfo, eng);
                    Pathway_To_Sol_API_Wrapper.ContactInfo conInfo = (Pathway_To_Sol_API_Wrapper.ContactInfo) engInfo.data.get('conInfo');
                    conObj = conInfo.con;
                    conObj.put('Risk_Level__c', eng.Risk_Level__c);
                    if (engRiskLevelsForConDataPush.contains(eng.Risk_Level__c)) {
                        
                        engIdSetForConDataPush.add(eng.Id);
                    }
                    
                    

                    
                }
                //NOTE: keep below lines for future reference (Eng Prog Status Update)
                /*
                if(oldEng.Program_Status_Eng__c != eng.Program_Status_Eng__c) {
                    if (NULL == engInfo) {
                        engInfo = populateEngInfoBaseDetails(engInfo, eng);
                    }
                    conObj = engInfo.data.get('conInfo');
                    conObj.put('Risk_Level__c', eng.Risk_Level__c);
                    engInfo.data.put('engPrgStatus', eng.Program_Status_Eng__c);
                }
                */

                System.debug('$$$ engInfo ' + engInfo);

                if (NULL != engInfo) {
                    mMemIdVsEngInfo.put(eng.Consumer__c, engInfo);
                }
                
            }
        }

        if (! engIdSetForConDataPush.isEmpty()) {
            prepareEngsRelDataToSol(engIdSetForConDataPush, mMemIdVsEngInfo);
        }

        return mMemIdVsEngInfo.values();

    }

    /**
    * @description 
    * @author Naveen Ila | 3/3/2020 
    * @param Set<Id> engIdSet 
    * @return List<Pathway_To_Sol_API_Wrapper.EngInfo> 
    **/
    public List<Pathway_To_Sol_API_Wrapper.EngInfo> prepareEngDataChangeReqBody (Set<Id> engIdSet) {

        Map<Id, Pathway_To_Sol_API_Wrapper.EngInfo> mMemIdVsEngInfo = new Map<Id, Pathway_To_Sol_API_Wrapper.EngInfo>();
        if (NULL != engIdSet && !engIdSet.isEmpty()) {

            

            prepareEngsRelDataToSol(engIdSet, mMemIdVsEngInfo, FALSE);


            
        }

        return mMemIdVsEngInfo.values();

    }



    /**
    * @description 
    * @author Naveen Ila | 3/2/2020 
    * @return Set<String> 
    **/
    public Set<String> fetchEngRiskLevelsForConDataPush () {

        //TODO: Need to populate below set from Custom Metadata
        Set<String> engStatusSet = new Set<String>();
        //Highest, Rising or Emerging
        engStatusSet.add('Highest');
        engStatusSet.add('Rising');
        engStatusSet.add('Emerging');
        return engStatusSet;

    }

    public void prepareEngsRelDataToSol (Set<Id> engIdSetForConDataPush, Map<Id, Pathway_To_Sol_API_Wrapper.EngInfo> mMemIdVsEngInfo) {
        prepareEngsRelDataToSol(engIdSetForConDataPush, mMemIdVsEngInfo, TRUE);
    }

    /**
    * @description 
    * @author Naveen Ila | 3/2/2020 
    * @param Set<Id> engIdSetForConDataPush 
    * @param Map<Id Pathway_To_Sol_API_Wrapper.EngInfo> mMemIdVsEngInfo 
    * @return void 
    **/
    public void prepareEngsRelDataToSol (Set<Id> engIdSetForConDataPush, Map<Id, Pathway_To_Sol_API_Wrapper.EngInfo> mMemIdVsEngInfo, Boolean isBaseInfoExist) {

        System.debug('$$$ loaing contact & account info from engagement');

        List<Engagement__c> engList = [SELECT Id, NP_Name__c, Name, Clinical_Program__c, Program_Status_Eng__c
                                            , Consumer__r.FirstName, Consumer__r.LastName, Consumer__r.Primary_Phone__c
                                            ,Consumer__r.OtherStreet, Consumer__r.OtherCity, Consumer__r.OtherState
                                            ,Consumer__r.OtherCountry, Consumer__r.OtherPostalCode
                                            , Consumer__r.Account.Name
                                            ,Consumer__r.Account.ShippingStreet, Consumer__r.Account.ShippingCity, Consumer__r.Account.ShippingState
                                            ,Consumer__r.Account.ShippingCountry, Consumer__r.Account.ShippingPostalCode
                                            FROM Engagement__c WHERE Id IN: engIdSetForConDataPush];

        for(Engagement__c  eng : engList) {

            Id consumerId = eng.Consumer__c;
            Pathway_To_Sol_API_Wrapper.EngInfo engInfo;
            if (!isBaseInfoExist) {
                mMemIdVsEngInfo.put(consumerId, populateEngInfoBaseDetails(engInfo, eng));
            }

            if (mMemIdVsEngInfo.containsKey(consumerId)) {
                
                engInfo = mMemIdVsEngInfo.get(consumerId);
                prepareEngRelDataToSol(eng, engInfo, isBaseInfoExist);

            }

        }

    }

    
    /**
    * @description : To preare the body to share Account, Contact and Engagement details to Sol
    *                   if engagement risk level matches with given set
    * @author Naveen Ila | 2/28/2020 
    * @return Pathway_To_Sol_API_Wrapper.EngInfo 
    **/
    public void prepareEngRelDataToSol (Engagement__c eng, Pathway_To_Sol_API_Wrapper.EngInfo engInfo, Boolean isBaseInfoExist) {

        System.debug('$$$ we here to populate contct, account info');
        populateEngRecData(eng, engInfo);
        populateContactFldMapEngRiskLevelChange(eng.Consumer__r, engInfo);
        populateAccountFldMapEngRiskLevelChange(eng.Consumer__r.Account, engInfo);

        return;
    }

    /**
    * @description 
    * @author Naveen Ila | 3/2/2020 
    * @param Engagement__c eng 
    * @param Pathway_To_Sol_API_Wrapper.EngInfo engInfo 
    * @return void 
    **/
    public void populateEngRecData (Engagement__c eng, Pathway_To_Sol_API_Wrapper.EngInfo engInfo) {

        Map<String, Object> engObj = new Map<String, Object>();
        Map<String,String> mEngFldMapping = new Map<String,String>();
        //mEngFldMapping.put('NP_Name__c', 'npName');
        mEngFldMapping.put('Program_Status_Eng__c', 'Program_Status__c');
        mEngFldMapping.put('Clinical_Program__c', 'Clinical_Program__c');
        Pathway_To_Sol_API_Wrapper.ContactInfo conInfo = (Pathway_To_Sol_API_Wrapper.ContactInfo) engInfo.data.get('conInfo');
        transferData(mEngFldMapping, eng, conInfo.con);

    }

    /**
    * @description 
    * @author Naveen Ila | 3/2/2020 
    * @param Contact con 
    * @param Pathway_To_Sol_API_Wrapper.EngInfo engInfo 
    * @return void 
    **/
    public void populateContactFldMapEngRiskLevelChange (Contact con, Pathway_To_Sol_API_Wrapper.EngInfo engInfo) {

        Map<String, String> mConFldMapping = new Map<String, String> ();
        mConFldMapping.putAll(fetchPathwaySolConAddressFldMapping());
        mConFldMapping.putAll(fetchPathwaySolConPhoneFldMapping());
        mConFldMapping.put('FirstName', 'FirstName');
        mConFldMapping.put('LastName', 'LastName');
        mConFldMapping.put('Id', 'Data_Source_ID__c');
        Pathway_To_Sol_API_Wrapper.ContactInfo conInfo = (Pathway_To_Sol_API_Wrapper.ContactInfo) engInfo.data.get('conInfo');
        Map<String,Object> conObj = conInfo.con;
        transferData(mConFldMapping, con, conObj);
        /*
        Pathway_To_Sol_API_Wrapper.ContactInfo conInfo = new Pathway_To_Sol_API_Wrapper.ContactInfo();
        conInfo.con = conObj;
        engInfo.data.put('conInfo', conInfo);
        */

    }

    /**
    * @description 
    * @author Naveen Ila | 3/2/2020 
    * @param Account acc 
    * @param Pathway_To_Sol_API_Wrapper.EngInfo engInfo 
    * @return void 
    **/
    public void populateAccountFldMapEngRiskLevelChange (Account acc, Pathway_To_Sol_API_Wrapper.EngInfo engInfo) {

        Map<String, String> mAccFldMapping = new Map<String, String> ();
        mAccFldMapping.putAll(fetchPathwaySolAccAddressFldMapping());
        
        mAccFldMapping.put('Name', 'Name');
        mAccFldMapping.put('Id', 'Account_Source_ID__c');
        Map<String,Object> accObj = new Map<String,Object>();
        transferData(mAccFldMapping, acc, accObj);
        Pathway_To_Sol_API_Wrapper.AccountInfo accInfo = new Pathway_To_Sol_API_Wrapper.AccountInfo();
        accInfo.acc = accObj;
        //engInfo.accInfo = accInfo;
        engInfo.data.put('accInfo', accInfo);

    }

    /**
    * @description 
    * @author Naveen Ila | 2/21/2020 
    * @param Pathway_To_Sol_API_Wrapper.EngInfo engInfo 
    * @param Engagement__c eng 
    * @return Pathway_To_Sol_API_Wrapper.EngInfo 
    **/
    public Pathway_To_Sol_API_Wrapper.EngInfo populateEngInfoBaseDetails (Pathway_To_Sol_API_Wrapper.EngInfo engInfo, Engagement__c eng) {

        engInfo = new Pathway_To_Sol_API_Wrapper.EngInfo();

        Map<String, String> mConFldMapping = new Map<String, String> ();
        mConFldMapping.put('Id', 'Eng_Source_System_ID__c');
        mConFldMapping.put('Consumer__c', 'Data_Source_ID__c');
        mConFldMapping.put('Name', 'Engagement_ID__c');
        
        Map<String,Object> conObj = new Map<String,Object>();
        transferData(mConFldMapping, eng, conObj);
        Pathway_To_Sol_API_Wrapper.ContactInfo conInfo = new Pathway_To_Sol_API_Wrapper.ContactInfo();
        conInfo.con = conObj;
        engInfo.data = new Map<String, Object> ();
        engInfo.data.put('conInfo', conInfo);
        return engInfo;

    }



    /**
    * @description 
    * @author Naveen Ila | 2/17/2020 
    * @param Map<String String> headersInfo 
    * @param String method 
    * @param String endPoint 
    * @return HttpRequest 
    **/
    public HttpRequest buildRequest (Map<String,String> headersInfo, String method, String endPoint) {

        HttpRequest req = new HttpRequest();
        
        if (NULL != headersInfo && headersInfo.size() > 0) {
            for (String key : headersInfo.keySet()) {
                req.setHeader(key, headersInfo.get(key));
            }

        }

        req.setMethod(method);
        req.setEndpoint(endPoint);

        return req;
    }

    /**
    * @description 
    * @author Naveen Ila | 2/20/2020 
    * @param String baseUrl 
    * @param String restSericeName 
    * @return String 
    **/
    public String buildReqEndPoint ( String restSericeName) {

        return  solOAuthDet.jwtUtility.Custom_Domain_Name__c + '/services/apexrest/' + restSericeName + '/';       
    }

    public String sendRequestWithGenericEndPoint (String reqBody, String opName) {

        System.debug('$$$ reqBody ' + reqBody);

        fetchAccessTokenDetails();
        if (String.isBlank(solOAuthDet.tokenDet.errMsg)) {

            String uri = buildReqEndPoint (Pathway_To_Sol_AppLiterals.GENERIC_SERVICE_ENDPOINT);
            Map<String,String> reqHeaders = new Map<String,String>();
            reqHeaders.put('Content-Type', 'Application/json');
            reqHeaders.put('Authorization', solOAuthDet.tokenDet.token_type + ' ' + solOAuthDet.tokenDet.access_token);
            HttpRequest req = buildRequest(reqHeaders, 'POST', uri);
            req.setBody(reqBody);
            HttpResponse res = sendRequest(req);

            if (res.getStatus() == 'OK' || (res.getStatusCode() >= 200 && res.getStatusCode() <= 300)) {
                return res.getBody();
            } else {
                
                Pathway_To_Sol_Utility.createApiTracker(req, res, opName);
                
            }

        } else {
            
            Pathway_To_Sol_Utility.createApiTracker('Pathway To Sol OAuth JWT', solOAuthDet.tokenDet.errMsg, 'Pathway To Sol Authorization');
        }

        return NULL;

    }


    
}