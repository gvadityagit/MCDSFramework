public with sharing class MessagingCommonLookUpController {
    
    //private Integer totalRecordCount;
    public String offsetValue{get;set;}    
    public Integer limitPerSOQL = 1000;   
    public String pageType{get;set;}
    public String srchType{get;set;}
    private String srchFilterAPCId = '';
    private String srchFilterPhyId = '';
    private String srchFilterAgrId = '';
    public String srchManager{get; set;}
    public MessagingCommonLookUpController(){
       //totalRecordCount = 0;
       srchManager='false';
       offsetValue = '0';
       pageType = ApexPages.currentPage().getParameters().get('ptyp');
       srchType = ApexPages.currentPage().getParameters().get('styp');
       srchFilterAPCId = ApexPages.currentPage().getParameters().get('apcid');
       srchFilterPhyId = ApexPages.currentPage().getParameters().get('phyid');
       srchFilterAgrId = ApexPages.currentPage().getParameters().get('agrid');
       srchManager = ApexPages.currentPage().getParameters().get('manager');
    }
    
    public String filterValue{get{
        if (pageType!=null){
            if(pageType.equalsIgnoreCase('AgrLookup')) {
                filterValue = 'Filtered All Agreements in allowed span';
            } else if(pageType.equalsIgnoreCase('CCALookup')){
                filterValue = 'Filtered by agreement id';
            }
        }
        return this.filterValue;          
    }set;}   
     
    public List<SelectOption> filterList{get{
        return EXT_PP_Utility.getUserFilterList();
    }set;}   
    
    /*
    public List<SelectOption> getDateRange(){
        return EXT_PP_Utility.getDateRange(totalRecordCount, limitPerSOQL);
    }*/
    
    public List<MessagingWrapperParams.ColAgreementWrapper> agreementDetails{get{
        if(this.agreementDetails == null){
            loadData();             
        }
        return this.agreementDetails;
    }set;}
    
    public List<MessagingWrapperParams.CCARecordWraper> ccaDetails{get{
        if(this.ccaDetails == null){
            loadData();          
        }   
        return this.ccaDetails;
    }set;}
    
    /*
    public void setTotalRecordCount(){
        String countOfRecord = 'Select count() from Collaborative_Agreement__c';
        if(addFilter() != '')
            countOfRecord +=  addFilter();  
        totalRecordCount  = DataBase.countQuery(countOfRecord);  
        if(totalRecordCount > 2000){
            totalRecordCount = 2000;
        }
        system.debug('limitPerSOQL******'+limitPerSOQL); 
    }*/
    
    private String addFilter(){
        String strFilter = '';
        System.debug('####AddFilter entered');
        if(filterValue == 'Filtered All Agreements in allowed span'){
            Integer searchDateRangeLimit = Integer.valueOf(EXT_PP_Utility.PhysicianPortalMdtMap.get('ReviewCompletedUnshareMonths').Value__c);
            String srcPage=ApexPages.currentPage().getParameters().get('srcPg');
            if(srcPage!=null && srcPage.equalsIgnoreCase('ProviderReview')){
                searchDateRangeLimit = Integer.valueOf(EXT_PP_Utility.PhysicianPortalMdtMap.get('UnsharePriorMonthForInactiveAgrmt').Value__c);
            }
            System.debug('####searchDateRangeLimit '+searchDateRangeLimit);
            System.debug('####srchFilterAPCId '+srchFilterAPCId+' ####srchFilterPhyId '+srchFilterPhyId);
            
            if (srchType != null && srchType.equalsIgnoreCase('phy') && !String.isBlank(srchFilterAPCId) && srchManager != null && srchManager.equalsIgnoreCase('false')) {
				
                searchDateRangeLimit = Integer.valueOf(EXT_PP_Utility.PhysicianPortalMdtMap.get('UnsharePriorMonthForInactiveAgrmt').Value__c);
                System.debug('####phy searchDateRangeLimit '+searchDateRangeLimit);
                strFilter += ' WHERE ((Status__c = \'Active\' AND Start_Date__c <= TODAY AND (End_Date__c >TODAY OR End_Date__c = null)) OR (Status__c = \'Inactive\' AND Start_Date__c <= TODAY AND (End_Date__c = Last_N_Months:'+ searchDateRangeLimit + ' OR End_Date__c = THIS_MONTH))) AND Nurse_Practitioner_Id__c = :srchFilterAPCId ';  
                system.debug('--apcquery---');
            
            }else{
                strFilter += ' WHERE Status__c != \'Entered in Error\' AND Start_Date__c <= TODAY AND (End_Date__c >= Last_N_Months:'
                            + searchDateRangeLimit + ' OR End_Date__c = null) ';
                if (srchType != null && srchType.equalsIgnoreCase('apc') && !String.isBlank(srchFilterPhyId)) {
                    strFilter += ' AND Physician_Id__c = :srchFilterPhyId ';
                }
                else if (srchType != null && srchType.equalsIgnoreCase('phy') && !String.isBlank(srchFilterAPCId) && srchManager != null && srchManager.equalsIgnoreCase('true')) {
                    strFilter += ' AND (Nurse_Practitioner_Id__c = :srchFilterAPCId  OR Nurse_Practitioner_Id__r.ManagerId = :srchFilterAPCId) ';  system.debug('-managerquery-');
                }
            }
        }
        system.debug('-querystrfilter--'+strFilter);
        return strFilter;
    }
    
    private String addCCAFilter(){
        String strFilter = '';
        if(filterValue =='Filtered by agreement id'){            
            Integer searchDateRangeLimit = Integer.valueOf(EXT_PP_Utility.PhysicianPortalMdtMap.get('ReviewCompletedUnshareMonths').Value__c);
            System.debug('*****srchType'+srchType+' srchFilterAPCId '+srchFilterAPCId+' srchManager '+srchManager);
            if (srchType != null && srchType.equalsIgnoreCase('phy') && srchManager != null && srchManager.equalsIgnoreCase('false')) {				
                searchDateRangeLimit = Integer.valueOf(EXT_PP_Utility.PhysicianPortalMdtMap.get('UnsharePriorMonthForInactiveAgrmt').Value__c);
            }
            System.debug('*****searchDateRangeLimit '+searchDateRangeLimit);
            strFilter += ' WHERE Assigned_date__c <= TODAY AND Assigned_date__c >= Last_N_Months:' + searchDateRangeLimit 
                    + ' AND Agreement_ID__c =:srchFilterAgrId '; 
        }
        
        return strFilter;
    }
    
    private String addOrderBy(){
        String strOrderBy = '';
        if(filterValue == 'Filtered All Agreements in allowed span'){
            strOrderBy += ' ORDER BY Nurse_Practitioner_Id__r.FirstName,Nurse_Practitioner_Id__r.LastName, State__c, Status__c, Start_Date__c,End_Date__c ';
        } 
        else{
            strOrderBy += ' ORDER BY LastModifiedDate desc ';
        }

        return strOrderBy;
    }
    
    private String addCCAOrderBy(){
        String strOrderBy = '';
        if(filterValue == 'Filtered All Agreements in allowed span'){
            strOrderBy += ' ORDER BY Assigned_date__c desc ';
        } 

        return strOrderBy;
    }

    private void prepareResults(List<Collaborative_Agreement__c> lstDetails){
        agreementDetails = new List<MessagingWrapperParams.ColAgreementWrapper>();
        if(lstDetails.size()>0){
            List<ID> contactIds = new List<ID>();
            Map<Id, User> contact2CommunityUserMap = new Map<Id, User>();
            for(Collaborative_Agreement__c cagr : lstDetails){
                contactIds.add(cagr.Physician_ID__c);
            }
            if(!contactIds.isEmpty()){
                contact2CommunityUserMap = MessagingUtility.getCommunityUsers4mContact(contactIds);
            }
            for(Collaborative_Agreement__c wrp : lstDetails){
                String NurseName = '';
                String PhysicianName = '';
                String type = EXT_PP_Utility.getAgreementTypeDisplayValue(wrp.Agreement_For__c);
                if(wrp.Status__c == 'Active' && wrp.End_Date__c < Date.today())            
                    wrp.Status__c = 'Inactive';
                if(wrp.Nurse_Practitioner_Id__c != null && wrp.Physician_ID__c != null){
                    NurseName = wrp.Nurse_Practitioner_Id__r.LastName+', '+wrp.Nurse_Practitioner_Id__r.FirstName;
                    PhysicianName = wrp.Physician_ID__r.LastName+', '+wrp.Physician_ID__r.FirstName;
                    MessagingWrapperParams.ColAgreementWrapper wrapRec = new MessagingWrapperParams.ColAgreementWrapper(wrp.Id, NurseName, PhysicianName, wrp.State__c, type, wrp.Start_Date__c, wrp.End_Date__c, wrp.Status__c);
                    if(filterValue == 'Filtered All Agreements in allowed span'){
                        wrapRec.managerUserId = wrp.Nurse_Practitioner_Id__r.ManagerId;
                        wrapRec.managerUserName = wrp.Nurse_Practitioner_Id__r.Manager.Name;
                        wrapRec.typeSobjectAPI = wrp.Agreement_For__c;
                        wrapRec.agreementAlias = wrp.Name + ' - ' + wrp.State__c + ' - ' + wrp.Status__c;
                        wrapRec.agreementName = wrp.Name;
                        wrapRec.nurseId = wrp.Nurse_Practitioner_Id__c;
                        wrapRec.physicianId = wrp.Physician_ID__c;
                        wrapRec.physicianUserId = (contact2CommunityUserMap.containsKey(wrp.Physician_ID__c) && contact2CommunityUserMap.get(wrp.Physician_ID__c).isActive)
                        ?contact2CommunityUserMap.get(wrp.Physician_ID__c).Id:null;
                    
                    }
                    System.debug('JSON.serialize(wrapRec):' + JSON.serialize(wrapRec));
                    agreementDetails.add(wrapRec);
                }              
            }
        }        
    }   

    private void prepareCCAResults(List<concurrent_chart_assignment__c> lstDetails){
        ccaDetails = new List<MessagingWrapperParams.CCARecordWraper>();
        Map<Id, SObject> cCARecordDetails = getCCARecordDetails(lstDetails);
        if(lstDetails.size()>0){            
            for(concurrent_chart_assignment__c wrp : lstDetails){
                MessagingWrapperParams.CCARecordWraper wrapRec = new MessagingWrapperParams.CCARecordWraper();
                wrapRec.recordId = wrp.ReviewForSObjectID__c;
                wrapRec.typeSobjectAPI = wrp.ReviewForSObject__c;
                SObject tempRec = cCARecordDetails.get(wrapRec.recordId);
                if(tempRec != null){
                    if('Case'.equalsIgnoreCase(wrapRec.typeSobjectAPI)){
                        Case cs = (Case) tempRec;
                        wrapRec.caseNumber = cs.CaseNumber;
                        wrapRec.memberName = cs.Contact.Name;
                        wrapRec.engagementNumber = cs.Engagement__r.Name;
                        wrapRec.recordAlias = cs.CaseNumber;
                    }
                    else if('Soap_Note__c'.equalsIgnoreCase(wrapRec.typeSobjectAPI)){
                        Soap_Note__c sn = (Soap_Note__c) tempRec;
                        wrapRec.soapNoteName = sn.Name;
                        wrapRec.memberName = sn.Consumer__r.Name;
                        wrapRec.engagementNumber = sn.Engagement_Id__r.Name;
                        wrapRec.recordAlias = sn.Name;
                    }
                }
                System.debug('JSON.serialize(wrapRec):' + JSON.serialize(wrapRec));
                ccaDetails.add(wrapRec);
            }
        }        
    }    
                          
    public void loadData(){        
        offsetValue = '0';        
        //setTotalRecordCount();
        if (pageType!=null){
            if(pageType.equalsIgnoreCase('AgrLookup')) {
                loadAgreementRecord();
            } else if(pageType.equalsIgnoreCase('CCALookup')){
                loadCCARecord();
            }
        }
        
    }
    
     public void loadAgreementRecord(){
        Integer offSetValue = Integer.valueOf(this.offSetValue);
        String query = 'SELECT id, End_Date__c, Agreement_For__c,LastModifiedDate , Nurse_Practitioner_Id__c,Nurse_Practitioner_Id__r.FirstName,Nurse_Practitioner_Id__r.LastName, Physician_Id__c,Physician_Id__r.FirstName, Physician_Id__r.lastName, Start_Date__c, State__c, Status__c ';

        if(filterValue == 'Filtered All Agreements in allowed span'){
            query += ', Name, Nurse_Practitioner_Id__r.ManagerId, Nurse_Practitioner_Id__r.Manager.Name ';
        }
        
        query += ' FROM Collaborative_Agreement__c ';        
        if(addFilter() != ''){
            query += addFilter();
        }              
        query += addOrderBy() + ' LIMIT :limitPerSOQL OFFSET :offSetValue ';
        System.debug(LoggingLevel.FINE, 'final query:' + query);
         System.debug('final query:' + query);
        List<Collaborative_Agreement__c> queryResults = DataBase.Query(query);
        prepareResults(queryResults);
    }
    
    
     public void loadCCARecord(){
        Integer offSetValue = Integer.valueOf(this.offSetValue);
        String query = 'SELECT agreement_id__c, id, NAME, reviewforsobjectid__c, reviewforsobject__c, status__c FROM concurrent_chart_assignment__c  ';

        query += addCCAFilter();
            
        query += addCCAOrderBy() + ' LIMIT :limitPerSOQL OFFSET :offSetValue ';
        System.debug(LoggingLevel.FINE, 'final query:' + query);
        List<concurrent_chart_assignment__c> queryResults = DataBase.Query(query);
        prepareCCAResults(queryResults);
    }

    public Map<Id, SObject> getCCARecordDetails(List<concurrent_chart_assignment__c> ccaRecs){
        Map<Id, SObject> retRecDtlmap = new Map<Id, SObject>();
        Set<Id> ccaSoapIdSet = new Set<Id>();
        Set<Id> ccaCaseIdSet = new Set<Id>();
        for(concurrent_chart_assignment__c rec : ccaRecs){
            if('Soap_Note__c'.equalsIgnoreCase(rec.ReviewForSObject__c)){
                ccaSoapIdSet.add(rec.reviewforsobjectid__c);
            }
            else if('Case'.equalsIgnoreCase(rec.ReviewForSObject__c)){
                ccaCaseIdSet.add(rec.reviewforsobjectid__c);
            }
        }

        if(ccaSoapIdSet.size() > 0){
            for (SOAP_Note__c sn : [Select Id
                                        , Name
                                        , Consumer__c
                                        , Consumer__r.Name 
                                        , Engagement_ID__c
                                        , Engagement_ID__r.Name
                                    from SOAP_Note__c 
                                    Where Id in:ccaSoapIdSet]) {
                retRecDtlmap.put(sn.id, sn);
            }
        }
        if(ccaCaseIdSet.size() > 0){
            for (Case cs : [Select Id
                                , CaseNumber
                                , ContactId
                                , Contact.Name 
                                , Engagement__c
                                , Engagement__r.Name
                            from Case 
                            Where Id in:ccaCaseIdSet]) {
                retRecDtlmap.put(cs.id, cs);
            }
        }
        System.debug(LoggingLevel.Fine, 'getCCARecordDetails ccaSoapIdSet:' + ccaSoapIdSet);
        System.debug(LoggingLevel.Fine, 'getCCARecordDetails ccaCaseIdSet:' + ccaCaseIdSet);
        System.debug(LoggingLevel.Fine, 'getCCARecordDetails retRecDtlmap:' + retRecDtlmap);
        return retRecDtlmap;
    }
}