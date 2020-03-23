@isTest(seeAllData=false)
public class MessagingDashboardComponentCtrlTest{

   static List<Collaborative_Agreement__c> lstAgreement;
    static List<Assessment_Detail_Response__c> lstAssessmentResponse;
    static List<Assessment_Detail__c> lstAssessDetail;
    static List<Question_Master__c> lstQMaster;
    static List<Assessment_Master__c> lstAssessMaster;
    static List<Assessment_Section__c> lstAssessSection;
    static Account acc;
    static Contact consumer;
    static Contact conPhysicianObject;
    static User thisUserTest;
    @testSetup
    public static void setUpdata(){
        TestClassDataFactory.loadCustomSettings(new Set<String>{'Utility__c'});
         User adminUser = [SELECT Id,email from User WHERE Profile.Name = :label.Profile_Manager AND UserRoleId != null AND IsActive =  true LIMIT 1];
        
        lstAssessMaster = new List<Assessment_Master__c>();
         String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = 'ABC' + dateString + randomInt;
        Profile providerProfile = [Select id from Profile where Name = :Label.Profile_Provider limit 1];
        thisUserTest = new User();
        thisUserTest.UserName = uniqueName + '@optum.com';
        thisUserTest.Email = uniqueName + '@optum.com';
        thisUserTest.Alias='Test12';
        thisUserTest.isActive=true;
        thisUserTest.EmailEncodingKey='UTF-8';
        thisUserTest.LanguageLocaleKey='en_US';
        thisUserTest.ProfileId=providerProfile.Id;
        thisUserTest.Credentials__c='ANP-BC';
        thisUserTest.Credential_Category__c='DO';
        thisUserTest.NPI__c='1912968298';
        thisUserTest.Signature_Name__c='test';
        thisUserTest.LastName='test';
        thisUserTest.TimeZoneSidKey='America/Los_Angeles';
        thisUserTest.LocaleSidKey='en_US';
        thisUserTest.LastName='test';
        thisUserTest.CommunityNickname='Samplecommunity';
        thisUserTest.ManagerId=adminuser.Id;
        INSERT thisUserTest ;
        
        //Create Clinical Program
        Clinical_Program__c cp= TestClassDataFactory.testCP(); 
        
        //Create Account  
        Account ac1 = TestClassDataFactory.createNewAccount(); 
        ac1.Market__c = 'Florida';
        Account ac2 = TestClassDataFactory.createNewAccount();
        system.debug('Account details'+ac1);
        system.debug('Account details'+ac2);
        
        
        ac1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();   
        system.debug('Account id:'+ac2.RecordType.Name);
        update ac1;
        
        //Create Contact
        Contact consumer = TestClassDataFactory.createNewContact(ac1.Id, cp.Id, 'Consumer');
        consumer.LastName = 'NewPhysTestLast';
        consumer.FirstName = 'Smith';
        insert consumer; 
        
        //Create Client Clinical Program
        Client_Clinical_Program__c ccp = TestClassDataFactory.testCCP(cp.Id, ac1.Id);
        
        //Create Engagement
        Engagement__c newEngagement = TestClassDataFactory.createEngagement(ac2.Id, consumer.id, ccp.Id, null, null);
        insert newEngagement;
        SOAP_Note__c soapNoteObj = TestUtility.addSoapNote(consumer.Id,newEngagement.Id);
            soapNoteObj.Note_Status__c = 'Complete';
            update soapNoteObj;
        Case newCase = new Case(); 
            String OnCallRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('On Call Support').getRecordTypeId();
             newCase.Engagement__c = newEngagement.id; 
            newCase.ContactId = newEngagement.Consumer__c;
            newCase.Subject = OnCallAppLiterals.ON_CALL_CASE_PAGE_ONCALL_SUPPORT;
            newCase.RecordTypeId = OnCallRecordTypeId;
            newCase.Description = 'Test'; 
            newCase.Status='Completed';
            newCase.Client__c = 'demo';
            newCase.Diagnostic_Procedures_Notes__c = 'Test';             
            Insert newCase;   
            
         Account accountObj = createNewAccount('Texas');
        
        insert accountObj;
        conPhysicianObject= createnewContact(accountObj.id);
        insert conPhysicianObject;
         
         Profile collabPhysProfile = [Select id from Profile where Name = 'EXT_Physician' limit 1];                
        User thisUserTestPhysician=userCreationList(collabPhysProfile);
        thisUserTestPhysician.Market__c='Florida';     
        thisUserTestPhysician.contactId = conPhysicianObject.Id;
        insert thisUserTestPhysician;
        
       
        lstAgreement = new List<Collaborative_Agreement__c>();
        Collaborative_Agreement__c collabAgreementDetailObj=new Collaborative_Agreement__c ();
        collabAgreementDetailObj.Physician_ID__c=conPhysicianObject.Id;
        collabAgreementDetailObj.Nurse_Practitioner_ID__c=thisuserTest.Id;        
        collabAgreementDetailObj.Start_Date__c =Date.Today()-10;
        collabAgreementDetailObj.End_Date__c = Date.Today()+40;
        collabAgreementDetailObj.State__c = 'Texas';
        collabAgreementDetailObj.Status__c = 'Active';
        lstAgreement.add(collabAgreementDetailObj);
        insert lstAgreement;
        
        /*collabAgreementDetailObj.Nurse_Practitioner_ID__c=adminUser.Id; 
        update collabAgreementDetailObj;    */   
        
        Assessment_Master__c aMasterSoapNote = createAssessmentMaster('SOAP Note Concurrent Provider Review TEST','SOAPNoteConcurrentProviderReviewTest','SOAP_Concurrent_Review_TEST', 1);
        Assessment_Master__c aMasterCase = createAssessmentMaster('On Call Case Concurrent Provider Review TEST','OnCallCaseConcurrentProviderReviewTest','On_Call_Concurrent_Review_TEST', 2);
        lstAssessMaster.add(aMasterSoapNote);
        lstAssessMaster.add(aMasterCase);
        insert lstAssessMaster;
        List<Assessment_Setting__c> listOfAssessmentSettings =new List<Assessment_Setting__c>();
        
        Assessment_Setting__c assessment_set1=OpDesTestDataFactory.createAssessmentSettings(aMasterSoapNote.id);
        assessment_set1.PullAnswerfromPrevAsmnt__c=AppLiterals.SETTINGUSERDECIDE;
        assessment_set1.Tag__c='Assessment';
        listOfAssessmentSettings.add(assessment_set1);      
        
        Assessment_Setting__c assessment_set2=OpDesTestDataFactory.createAssessmentSettings(aMasterCase.id);
        assessment_set2.PullAnswerfromPrevAsmnt__c=AppLiterals.SETTINGUSERDECIDE;
        listOfAssessmentSettings.add(assessment_set2);
        insert listOfAssessmentSettings;
        lstAssessSection =  new List<Assessment_Section__c>();
        Assessment_Section__c assessmentSecSoapNote=OpDesTestDataFactory.createSection(aMasterSoapNote.id,1);
        Assessment_Section__c assessmentSecCase =OpDesTestDataFactory.createSection(aMasterCase.id,2);
        lstAssessSection.add(assessmentSecSoapNote);
        lstAssessSection.add(assessmentSecCase);
        insert lstAssessSection;
        
        
        list<Question_Block__c> Qblocks = new list<Question_Block__c>();
        Question_Block__c QblockSoapNote = OpDesTestDataFactory.createQuestionBlock(assessmentSecSoapNote.id,1);
        Question_Block__c QblockCase = OpDesTestDataFactory.createQuestionBlock(assessmentSecCase.id,2);
        Qblocks.add(QblockSoapNote);
        Qblocks.add(QblockCase);
        insert Qblocks; 
        
        List<Alternate_Text__c>  alternatetextList = new List<Alternate_Text__c> ();
        alternatetextList.add(OpDesTestDataFactory.CreateAlternateText('','','questionmaster', 'SOAP Note Details'));
        alternatetextList.add(OpDesTestDataFactory.CreateAlternateText('','','questionmaster', 'On Call Case Details'));

        alternatetextList.add(OpDesTestDataFactory.CreateAlternateText('','','questionmaster', 'Appropriate collaboration and/or consultation is initiated?'));
        alternatetextList.add(OpDesTestDataFactory.CreateAlternateText('','','questionmaster', 'Appropriate communication with relevant stakeholders in care is documented?'));
        alternatetextList.add(OpDesTestDataFactory.CreateAlternateText('','','questionmaster', 'Appropriate diagnostic investigations are ordered or performed?'));
        alternatetextList.add(OpDesTestDataFactory.CreateAlternateText('','','questionmaster', 'Care plan is developed and/or revised as appropriate?'));
        alternatetextList.add(OpDesTestDataFactory.CreateAlternateText('','','questionmaster', 'Comments'));
        alternatetextList.add(OpDesTestDataFactory.CreateAlternateText('','','questionmaster', 'Pertinent information is synthesized to formulate differential diagnosis and confirm most likely diagnosis?'));
        alternatetextList.add(OpDesTestDataFactory.CreateAlternateText('','','questionmaster', 'Pertinent positive and negative history is documented?'));
        alternatetextList.add(OpDesTestDataFactory.CreateAlternateText('','','questionmaster', 'Pertinent positive and negative objective findings are documented?'));
        alternatetextList.add(OpDesTestDataFactory.CreateAlternateText('','','questionmaster', 'Prescribing and pharmacotherapy is timely and appropriate?'));
        alternatetextList.add(OpDesTestDataFactory.CreateAlternateText('','','questionmaster', 'Reason for visit/interaction is clearly documented?'));


        insert alternatetextList;

        lstQMaster = new List<Question_Master__c>();
        //Question_Master__c QMasterSoapNote=OpDesTestDataFactory.createQuestionMaster(QblockSoapNote.id,AppLiterals.RADIOTYPE,1,alternatetextList[0].id);
        Question_Master__c QMasterSoapNote=OpDesTestDataFactory.createGridTypeQuestionMaster(QblockSoapNote.id,1,alternatetextList[0].id);
        QMasterSoapNote.HeaderCol1__c = 'APC Name';
        QMasterSoapNote.HeaderCol2__c = 'SOAP ID';
        QMasterSoapNote.HeaderCol3__c = 'Visit Date';
        lstQMaster.add(QMasterSoapNote);
        //insert lstQMaster;
        //Question_Master__c QMasterCall=OpDesTestDataFactory.createQuestionMaster(QblockCase.id,AppLiterals.RADIOTYPE,1,alternatetextList[1].id);
        Question_Master__c QMasterCall=OpDesTestDataFactory.createGridTypeQuestionMaster(QblockCase.id,1,alternatetextList[1].id);
        QMasterCall.HeaderCol1__c = 'APC Name';
        QMasterCall.HeaderCol2__c = 'Case ID';
        QMasterCall.HeaderCol3__c = 'Call Date';
        lstQMaster.add(QMasterCall);

        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockSoapNote.id,AppLiterals.RADIOTYPE,2,alternatetextList[11].id));
        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockSoapNote.id,AppLiterals.RADIOTYPE,3,alternatetextList[2].id));
        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockSoapNote.id,AppLiterals.RADIOTYPE,4,alternatetextList[3].id));
        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockSoapNote.id,AppLiterals.RADIOTYPE,5,alternatetextList[4].id));
        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockSoapNote.id,AppLiterals.RADIOTYPE,6,alternatetextList[5].id));
        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockSoapNote.id,AppLiterals.RADIOTYPE,7,alternatetextList[6].id));
        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockSoapNote.id,AppLiterals.RADIOTYPE,8,alternatetextList[7].id));
        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockSoapNote.id,AppLiterals.RADIOTYPE,9,alternatetextList[8].id));
        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockSoapNote.id,AppLiterals.RADIOTYPE,10,alternatetextList[9].id));
        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockSoapNote.id,AppLiterals.RADIOTYPE,11,alternatetextList[10].id));

        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockCase.id,AppLiterals.RADIOTYPE,2,alternatetextList[11].id));
        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockCase.id,AppLiterals.RADIOTYPE,3,alternatetextList[2].id));
        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockCase.id,AppLiterals.RADIOTYPE,4,alternatetextList[3].id));
        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockCase.id,AppLiterals.RADIOTYPE,5,alternatetextList[4].id));
        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockCase.id,AppLiterals.RADIOTYPE,6,alternatetextList[5].id));
        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockCase.id,AppLiterals.RADIOTYPE,7,alternatetextList[6].id));
        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockCase.id,AppLiterals.RADIOTYPE,8,alternatetextList[7].id));
        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockCase.id,AppLiterals.RADIOTYPE,9,alternatetextList[8].id));
        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockCase.id,AppLiterals.RADIOTYPE,10,alternatetextList[9].id));
        lstQMaster.add(OpDesTestDataFactory.createQuestionMaster(QblockCase.id,AppLiterals.RADIOTYPE,11,alternatetextList[10].id));
        
        insert lstQMaster; 
        lstAssessDetail = new List<Assessment_Detail__c>();
        Assessment_Detail__c ADetailSoapNote=new Assessment_Detail__c(Assessment_Master__c=aMasterSoapNote.id,Assessment_Status__c='In Progress',Patient__c=consumer.id);
        lstAssessDetail.add(ADetailSoapNote);   
        Assessment_Detail__c ADetailCall=new Assessment_Detail__c(Assessment_Master__c=aMasterCase.id,Assessment_Status__c='In Progress',Patient__c=consumer.id);
        lstAssessDetail.add(ADetailCall);   
        insert lstAssessDetail;
        
        lstAssessmentResponse = new List<Assessment_Detail_Response__c>();
        Assessment_Detail_Response__c ADetailResponseSoapNote=new Assessment_Detail_Response__c
                                                       (Question_Master__c=QMasterSoapNote.id,
                                                       Answer_Value__c='Testing Answer',
                                                       Answer_Value2__c='Testing Answer1',
                                                       Answer_Value3__c='Testing Answer2',
                                                       Answer_Value4__c='Testing Answer3',
                                                       Answer_Value5__c='Testing Answer4',
                                                       Assessment_Detail__c=ADetailSoapNote.id,
                                                       Row_Number__c=1);
        lstAssessmentResponse.add(ADetailResponseSoapNote);            
        Assessment_Detail_Response__c ADetailResponseCall=new Assessment_Detail_Response__c
                                                       (Question_Master__c=QMasterCall.id,
                                                       Answer_Value__c='Testing Answer',
                                                       Answer_Value2__c='Testing Answer1',
                                                       Answer_Value3__c='Testing Answer2',
                                                       Answer_Value4__c='Testing Answer3',
                                                       Answer_Value5__c='Testing Answer4',
                                                       Assessment_Detail__c=ADetailCall.id,
                                                       Row_Number__c=1);
        lstAssessmentResponse.add(ADetailResponseCall);
        

 
        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[1 + 1].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailSoapNote.id,Row_Number__c=(1 + 1)));
        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[1 + 2].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailSoapNote.id,Row_Number__c=(1 + 2)));
        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[1 + 3].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailSoapNote.id,Row_Number__c=(1 + 3)));
        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[1 + 4].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailSoapNote.id,Row_Number__c=(1 + 4)));
        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[1 + 5].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailSoapNote.id,Row_Number__c=(1 + 5)));
        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[1 + 6].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailSoapNote.id,Row_Number__c=(1 + 6)));
        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[1 + 7].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailSoapNote.id,Row_Number__c=(1 + 7)));
        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[1 + 8].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailSoapNote.id,Row_Number__c=(1 + 8)));
        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[1 + 9].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailSoapNote.id,Row_Number__c=(1 + 9)));
        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[1 + 10].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailSoapNote.id,Row_Number__c=(1 + 11)));



        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[11 + 1].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailCall.id,Row_Number__c=(1 + 1)));
        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[11 + 2].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailCall.id,Row_Number__c=(1 + 2)));
        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[11 + 3].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailCall.id,Row_Number__c=(1 + 3)));
        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[11 + 4].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailCall.id,Row_Number__c=(1 + 4)));
        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[11 + 5].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailCall.id,Row_Number__c=(1 + 5)));
        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[11 + 6].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailCall.id,Row_Number__c=(1 + 6)));
        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[11 + 7].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailCall.id,Row_Number__c=(1 + 7)));
        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[11 + 8].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailCall.id,Row_Number__c=(1 + 8)));
        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[11 + 9].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailCall.id,Row_Number__c=(1 + 9)));
        lstAssessmentResponse.add(new Assessment_Detail_Response__c(Question_Master__c=lstQMaster[11 + 10].id,Answer_Value__c='Testing Answer',Assessment_Detail__c=ADetailCall.id,Row_Number__c=(1 + 11)));


        insert lstAssessmentResponse;
        Concurrent_Chart_Assignment__c ccaSoapNote = new Concurrent_Chart_Assignment__c();
        ccaSoapNote.Agreement_ID__c = lstAgreement[0].id;
        ccaSoapNote.Assessment_Detail__c = ADetailCall.id;
        ccaSoapNote.Assigned_Date__c = system.today();
        ccaSoapNote.ReviewCompletedDate__c = system.today();
        ccaSoapNote.ReviewForSObjectID__c = newCase.Id;
        ccaSoapNote.Status__c = 'Review Completed';
        ccaSoapNote.ReviewForSObject__c='Case';
        ccaSoapNote.IsActive__c =true;
        insert ccaSoapNote;
        
        Concurrent_Chart_Assignment__c cca = new Concurrent_Chart_Assignment__c();
        cca.Agreement_ID__c = lstAgreement[0].id;
        cca.Assessment_Detail__c = ADetailCall.id;
        cca.Assigned_Date__c = system.today();
        cca.ReviewCompletedDate__c = system.today();
        cca.ReviewForSObjectID__c = soapNoteObj.Id;
        cca.Status__c = 'Review Completed';
        cca.ReviewForSObject__c='Soap_Note__c';
        cca.IsActive__c =true;
        insert cca;
       
        
    }  
    
    
        public static Account createNewAccount(String mrkt){  
        Account acc = new Account();
        acc.Name = 'TestClass';
        acc.Phone='1234567891';
        acc.Fax='1234567891';
        acc.Plan_Type__c='MediCare';
        acc.TIN__c = '123456789';
        acc.Include_Optum_Logo__c = false;
        acc.BillingCity = 'tes address';
        acc.BillingStreet = 'test street';
        acc.BillingPostalCode = '60107';
        acc.BillingState = 'MN';
        acc.BillingCountry = 'test country';
        acc.ShippingState= 'MN';
        acc.ShippingCity= 'Texas';
        acc.ShippingStreet= 'testStreet';
        acc.ShippingCountry= 'USA';
        acc.ShippingPostalCode = '90009';
        acc.Population_Groups__c='Population group'; 
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Facility').getRecordTypeId(); 
        acc.Market__c = mrkt;        
        return acc;
    }
    public static User userCreationList(Profile providerProfile){
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = 'ABC' + dateString + randomInt;
        
        User thisUserTest = new User();
        thisUserTest.UserName = uniqueName + '@optum.com';
        thisUserTest.Email = uniqueName + '@optum.com';
        thisUserTest.Alias='Test';
        thisUserTest.isActive=true;
        thisUserTest.EmailEncodingKey='UTF-8';
        thisUserTest.LanguageLocaleKey='en_US';
        thisUserTest.ProfileId=providerProfile.Id;
        thisUserTest.Credentials__c='ANP-BC';
        thisUserTest.Credential_Category__c='DO';
        thisUserTest.NPI__c='1912968298';
        thisUserTest.Signature_Name__c='test';
        thisUserTest.LastName='test';
        thisUserTest.TimeZoneSidKey='America/Los_Angeles';
        thisUserTest.LocaleSidKey='en_US';
        thisUserTest.LastName='test';
        thisUserTest.CommunityNickname='Samplecommunity'+uniqueName;
        return thisUserTest;
    }
    
       public static Assessment_Master__c createAssessmentMaster(String name, String filename, String uniqueIdentifier, Integer num){
        Assessment_Master__c aMaster=OpDesTestDataFactory.createAssessmentLibrary(num,'Draft',num);
        aMaster.Is_Standard_Library_Assessment__c = false;
        aMaster.Assessment_Name__c = name;
        aMaster.Assessment_File_Name__c=filename;
        aMaster.Status__c = 'Draft';
        aMaster.Tag__c ='Survey';               
        aMaster.Enable_Electronically_Sign__c=false;        
        aMaster.Assessment_Unique_Identifier__c= uniqueIdentifier;
        return aMaster;
    }  
    public static Contact createnewContact(Id accountId){
        String ConsRTID = [SELECT ID FROM RecordType where DeveloperName = 'Collaborating_Physician' and SobjectType='Contact'][0].ID;
        Contact c1 = new Contact (
            AccountID = accountId,
            RecordTypeID = ConsRTID,
            Status__c = 'New',
            CanAllowPortalSelfReg = false,
            Salutation = 'Mr.',
            FirstName = 'NewPhysTestFirst',
            Credential__c = 'DO',
            LastName = 'NewPhysTestLast',
            NPI__c = '4893303928',
            Specialty__c = 'Endocrinologist',
            MailingStreet = '123 My St.',
            Email = 'foekfkf@domain.com',
            MailingCity = 'Anytown',
            MailingState = 'CO',
            MailingPostalCode = '84993',
            County__c = 'Washington', Phone = '6693340001',
            Fax = '4487730001',
            Phone_Verified_Date__c = null,
            Fax_Verified_Date__c = null,
            Phone_Verified_By__c = null,
            Fax_Verified_By__c = null,
            OtherPhone = '8839920001',
            Other_Fax__c = '3379950001',
            Other_Phone_verified_date__c = null,
            Other_Fax_verified_date__c = null,
            Other_Phone_verified_by__c = null,
            Other_Fax_verified_by__c = null,
            OtherStreet='Street', OtherCity='City', OtherState='CA', OtherPostalCode='98765',
            OtherCountry='USA', Notes__c = 'these are some notes',Birthdate=System.Today(),
            Gender__c = 'Female'
        );
        return c1;
    }
    
    
    static testMethod void remoteActionScenarioWithEmptyParam(){
        MessagingDashboardComponentCtrl ecp=new MessagingDashboardComponentCtrl();
        ecp.showPopup();
        
        String abc=MessagingDashboardComponentCtrl.messageCenterDashboard('');
    }
    
    static testMethod void remoteActionScenario(){
        PageReference pageRef = new PageReference('/apex/Ext_Comm_PhysicianReview');
        Test.setCurrentPage(pageRef);
        conPhysicianObject = [Select Id from Contact limit 1];
        thisUserTest =  [Select Id from User limit 1];
        lstAssessDetail = [Select Id from Assessment_Detail__c];
        case cas=[select id from Case];       
        Contact conPhysicianObject = [Select Id,firstname,lastname from Contact limit 1];
        User thisUserTest =  [Select Id,firstname,lastname from User limit 1];   
        List<Collaborative_Agreement__c> ca=[SELECT ID,Physician_ID__c,Physician_ID__r.Name,Nurse_Practitioner_ID__c from Collaborative_Agreement__c];
        List<Concurrent_Chart_Assignment__c> cca=[select id,Name,Agreement_ID__c,Agreement_ID__r.Nurse_Practitioner_ID__r.LastName,Agreement_ID__r.Nurse_Practitioner_ID__r.FirstName,Agreement_ID__r.Physician_ID__c,Agreement_ID__r.Physician_ID__r.Name,Agreement_ID__r.Nurse_Practitioner_ID__c ,Assessment_Detail__c ,Assigned_Date__c,ReviewCompletedDate__c,ReviewForSObjectID__c,Status__c,ReviewForSObject__c,Review_Viewed_By__c  from Concurrent_Chart_Assignment__c];
       // MessagingDashboardComponentCtrl ecp=new MessagingDashboardComponentCtrl();
       // ecp.showPopup();
        List<Soap_Note__c> lstSoapNote= [Select Id from Soap_Note__c];
        user adminUser=[select id,Name,firstname,lastname from user where id =: ca[0].Nurse_Practitioner_ID__c];
        system.debug('--adminuser---'+adminUser);
        System.runAs(adminUser){
        test.startTest();
        Map<String, String> SearchParams = new Map<String, String>();
        SearchParams.put('fromdate',string.valueof(Date.today().toStartOfMonth().format()));
        SearchParams.put('todate',string.valueof(Date.today().format()));
        SearchParams.put('selectedAPC',ca[0].Nurse_Practitioner_ID__c);
        SearchParams.put('selectedPhysicianId',ca[0].Physician_ID__c);
        String SearchStr = '{"fromdate":"'+string.valueof(Date.today().toStartOfMonth().format())+'","todate":"'+string.valueof(Date.today().toStartOfMonth().format())+'","selectedAPC":"'+cca[0].Agreement_ID__r.Nurse_Practitioner_ID__c+'","selectedPhysicianId":"'+cca[0].Agreement_ID__r.Physician_ID__c+'"}';
        String SearchStrNoAPC = '{"fromdate":"'+string.valueof(Date.today().toStartOfMonth().format())+'","todate":"'+string.valueof(Date.today().toStartOfMonth().format())+'","selectedAPC":"","selectedPhysicianId":"'+cca[0].Agreement_ID__r.Physician_ID__c+'"}';
        String abc=MessagingDashboardComponentCtrl.messageCenterDashboard(SearchStr);
        }
    }
}