@isTest
private class MessagingCommonLookUpControllerTest{
    
    static User physicianUser{set;get;}
    
    @testSetup
    public static void setupData(){
    	
    	TestClassDataFactory.loadCustomSettings(new Set<String>{'Utility__c','Opdes_OWS__c','State_Codes__c'});
    	Profile collabPhysProfile = [Select id from Profile where Name = 'EXT_Physician' limit 1];
    	
    	List<Trigger_Support__c> trList=new List<Trigger_Support__c>();
        trList.add(new Trigger_Support__c(Name = 'EngagementTrigger', Trigger_ON__c = False));
        trList.add(new Trigger_Support__c(Name = 'CaseTrigger', Trigger_ON__c = False));
        insert trList;
    	
    	
    	Account accountObj = TestUtility.createNewAccount();
        accountObj.Market__c='Florida';
        update accountObj;
        
        Contact conObject= createnewContact(accountObj.id);
        
        Contact consumer = TestUtility.createnewContact(accountObj.id);
        consumer.IMS_Contact_ID__c = 'testIMSID';
        update consumer;
        Engagement__c objEng = TestUtility.createNewEngagement(consumer.Id,accountObj.Id);
        insert objEng;
        SOAP_Note__c soapNoteObj = TestUtility.addSoapNote(consumer.Id,objEng.Id);
        soapNoteObj.Note_Status__c = 'Complete';
        update soapNoteObj;
        
        
        physicianUser = new User();
        physicianUser.UserName    = 'ABCPKJTest12@optum.com';
        physicianUser.Email    = 'ABCPKJTest12@optum.com';
        physicianUser.Alias='Test';
        physicianUser.isActive=true;
        physicianUser.EmailEncodingKey='UTF-8';
        physicianUser.LanguageLocaleKey='en_US';
        physicianUser.ProfileId=collabPhysProfile.Id;
        physicianUser.Credentials__c='ANP-BC';
        physicianUser.contactId = conObject.Id;
        physicianUser.Credential_Category__c='DO';
        physicianUser.NPI__c='1912968298';
        physicianUser.Signature_Name__c='test';
        physicianUser.LastName='test';
        physicianUser.TimeZoneSidKey='America/Los_Angeles';
        physicianUser.LocaleSidKey='en_US';
        physicianUser.LastName='test';
        if([SELECT id,Credentials__c,contactid,name  from user where profile.name='EXT_Physician' and userName='ABCPKJTest12@optum.com'].size()==0){
            INSERT physicianUser ;
        }
        
        Profile providerProfile = [Select id from Profile where Name = :Label.Profile_Provider limit 1];
        
        User providerUserTest = new User();
        providerUserTest.UserName = 'ABCPKJTest@optum.com';
        providerUserTest.Email = 'ABCPKJTest@optum.com';
        providerUserTest.Alias='Test';
        providerUserTest.isActive=true;
        providerUserTest.EmailEncodingKey='UTF-8';
        providerUserTest.LanguageLocaleKey='en_US';
        providerUserTest.ProfileId=providerProfile.Id;
        providerUserTest.Credentials__c='ANP-BC';
        providerUserTest.Credential_Category__c='DO';
        providerUserTest.NPI__c='1912968298';
        providerUserTest.Signature_Name__c='test';
        providerUserTest.LastName='test';
        providerUserTest.TimeZoneSidKey='America/Los_Angeles';
        providerUserTest.LocaleSidKey='en_US';
        providerUserTest.LastName='test';
        providerUserTest.CommunityNickname='Samplecommunity';
        if([SELECT id,name  from user where profile.name=:Label.Profile_Provider and userName='ABCPKJTest@optum.com'].size()==0){
            INSERT providerUserTest ;
        }
        
        
        Collaborative_Agreement__c collaAgreementObj=new Collaborative_Agreement__c(Status__c='Active',state__c='Florida',Physician_ID__c=conObject.Id,Nurse_Practitioner_ID__c=providerUserTest.Id);
        collaAgreementObj.Start_Date__c = system.today()-1;
        collaAgreementObj.End_Date__c = system.today()+1;
        INSERT collaAgreementObj;
        
        Case c=new Case(subject='On Call Support',accountid=accountObj.id,Status='Completed');
        insert c;
            
        List<Concurrent_Chart_Assignment__c> ccaList = new List<Concurrent_Chart_Assignment__c>();

            Concurrent_Chart_Assignment__c ccaObj = new Concurrent_Chart_Assignment__c(Assigned_Date__c=system.today()-1,Agreement_ID__c = collaAgreementObj.Id,ReviewForSObjectID__c=soapNoteObj.Id, ReviewForSObject__c = 'Soap_Note__c', isActive__c=true);
            ccaList.add(ccaObj);

            Concurrent_Chart_Assignment__c ccaObj_reviewed = new Concurrent_Chart_Assignment__c(Assigned_Date__c=system.today()-1,Agreement_ID__c = collaAgreementObj.Id,ReviewForSObjectID__c=soapNoteObj.Id, ReviewForSObject__c = 'Soap_Note__c',Status__c='Review Completed', isActive__c=true);
            ccaList.add(ccaObj_reviewed);

            Concurrent_Chart_Assignment__c ccaObj_toReview = new Concurrent_Chart_Assignment__c(Assigned_Date__c=system.today()-1,Agreement_ID__c = collaAgreementObj.Id,ReviewForSObjectID__c=soapNoteObj.Id, ReviewForSObject__c = 'Soap_Note__c', Status__c='Ready for Review', isActive__c=true);
            ccaList.add(ccaObj_toReview);
            
            ccaList.add(new Concurrent_Chart_Assignment__c(Assigned_Date__c=system.today()-1,Agreement_ID__c = collaAgreementObj.Id,ReviewForSObjectID__c=c.Id, ReviewForSObject__c = 'Case', Status__c='Ready for Review', isActive__c=true));
        	Insert ccaList;
        
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
        insert c1;
        return c1;
    }
    
    public static testMethod void getFilterValueTestForLookup(){
    	
    	Collaborative_Agreement__c ca=[SELECT ID,Physician_ID__c,Nurse_Practitioner_ID__c FROM Collaborative_Agreement__c WHERE Status__c='Active'][0];
    	Test.startTest();
    	ApexPages.currentPage().getParameters().put('ptyp','AgrLookup');
        ApexPages.currentPage().getParameters().put('styp','apc');
        ApexPages.currentPage().getParameters().put('apcid',ca.Nurse_Practitioner_ID__c);
       	ApexPages.currentPage().getParameters().put('phyid',ca.Physician_ID__c);
       	ApexPages.currentPage().getParameters().put('agrid',ca.Id);
       	MessagingCommonLookUpController obj=new MessagingCommonLookUpController();
       	String fltr=obj.filterValue;
    	Test.stopTest();
    	List<SelectOption> soLst=obj.filterList;
    	System.assert(fltr!=null);
    	
    	ApexPages.currentPage().getParameters().put('ptyp','CCALookup');
    	obj=new MessagingCommonLookUpController();
    	fltr=obj.filterValue;
    	
    	System.assert(fltr!=null);
    }
    
    public static testMethod void getAgreementDetailsTest_Positive(){
    	Collaborative_Agreement__c ca=[SELECT ID,Physician_ID__c,Nurse_Practitioner_ID__c FROM Collaborative_Agreement__c WHERE Status__c='Active'][0];
    	Test.startTest();
    	ApexPages.currentPage().getParameters().put('ptyp','AgrLookup');
        ApexPages.currentPage().getParameters().put('styp','apc');
        ApexPages.currentPage().getParameters().put('apcid',ca.Nurse_Practitioner_ID__c);
       	ApexPages.currentPage().getParameters().put('phyid',ca.Physician_ID__c);
       	ApexPages.currentPage().getParameters().put('agrid',ca.Id);
       	MessagingCommonLookUpController obj=new MessagingCommonLookUpController();
       	List<MessagingWrapperParams.ColAgreementWrapper> agreementDtls=obj.agreementDetails;
       	Test.stopTest();
    }
    
    
     public static testMethod void getCCAWraperDeatils_Positive(){
    	Collaborative_Agreement__c ca=[SELECT ID,Physician_ID__c,Nurse_Practitioner_ID__c FROM Collaborative_Agreement__c WHERE Status__c='Active'][0];
    	Test.startTest();
    	ApexPages.currentPage().getParameters().put('ptyp','CCALookup');
        ApexPages.currentPage().getParameters().put('styp','apc');
        ApexPages.currentPage().getParameters().put('apcid',ca.Nurse_Practitioner_ID__c);
       	ApexPages.currentPage().getParameters().put('phyid',ca.Physician_ID__c);
       	ApexPages.currentPage().getParameters().put('agrid',ca.Id);
       	MessagingCommonLookUpController obj=new MessagingCommonLookUpController();
       	List<MessagingWrapperParams.CCARecordWraper> ccaDetls=obj.ccaDetails;
       	Test.stopTest();
    }
    
    

}