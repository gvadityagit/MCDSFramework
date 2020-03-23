@isTest
public class MessagingSendMessagePanelControllerTest{
    private static String userNamePrefix = 'Testname';
    private static Map<Id, Profile> profileIdMap;
    private static List<Account> accountList;
    private static Account physAccountObj;
    private static Contact conPhysicianObject;
    private static List<Contact> contactList;
    private static List<User> userList;
    private static User apcUserTest;
    private static User phyUserTest;
    private static List<Collaborative_Agreement__c> lstAgreements;
    private static Collaborative_Agreement__c collabAgreementDetailObj;
    private static Concurrent_Chart_Assignment__c ccaObj;

    private static MessagingSendMessagePanelController mcon;

    @TestSetup
    static void makeData(){
        List<Trigger_Support__c> tsLst = TestClassDataFactory.getTriggerOnCS(new List<String>{'AccountTrigger','contacttrigger','CCATrigger', 'EngagementTrigger'
            																					, 'SoapNoteTrigger', 'MessagingMasterTrigger'}
                                                                             , new List<boolean>{false, false, true, false, false, true});
        TestClassDataFactory.loadCustomSettings(new Set<String>{'Utility__c','Opdes_OWS__c','State_Codes__c'});
        if(!tsLst.isEmpty()){
            insert tsLst;
        }

        accountList = new List<Account>();
        physAccountObj = TestClassDataFactory.createNewAccount('Facility');
        physAccountObj.Market__c = 'Texas';
        accountList.add(physAccountObj);
        insert accountList;

        conPhysicianObject = TestClassDataFactory.createNewContact(physAccountObj.id, null, 'Collaborating Physician');
        contactList = new List<Contact>();
        contactList.add(conPhysicianObject);
        insert contactList;

        userList = new List<User>();
        apcUserTest=TestClassDataFactory.createUserBasedOnProfile(System.Label.Profile_Provider, 'APC' + userNamePrefix);
        apcUserTest.ManagerId=UserInfo.getUserId();
        userList.add(apcUserTest);

        phyUserTest = TestClassDataFactory.createUserBasedOnProfile(System.Label.Profile_EXT_CollabPhy, 'Physician' + userNamePrefix);
        phyUserTest.ContactId = conPhysicianObject.Id;
        userList.add(phyUserTest);
        insert userList;

        lstAgreements = new List<Collaborative_Agreement__c>();
        collabAgreementDetailObj=new Collaborative_Agreement__c ();
        collabAgreementDetailObj.Physician_ID__c=conPhysicianObject.Id;
        collabAgreementDetailObj.Nurse_Practitioner_ID__c=apcUserTest.Id;        
        collabAgreementDetailObj.Start_Date__c =Date.Today()-10;
        collabAgreementDetailObj.End_Date__c =Date.Today()+4;
        collabAgreementDetailObj.State__c = 'Texas';
        collabAgreementDetailObj.Agreement_For__c='Case';
        collabAgreementDetailObj.Status__c = 'Active';
        lstAgreements.add(collabAgreementDetailObj);
        
        insert lstAgreements;


        ccaObj = new Concurrent_Chart_Assignment__c(Agreement_ID__c = collabAgreementDetailObj.Id,ReviewForSObjectID__c='0ABCDEFGH123456789'/*spNoteRec.id*/, ReviewForSObject__c = 'SOAP_Note__c', isActive__c=true, Status__c='Ready for Review', ReviewCompletedDate__c = null);
        insert ccaObj;
    }

    private static void retrieveSetUpData(){
        //profileIdMap = new Map<Id, Profile>([Select id, name from Profile where name in :(new List<String>{System.Label.Profile_Provider, System.Label.Profile_EXT_CollabPhy})]);
        accountList = [Select Name from Account];
        physAccountObj = accountList[0];
        contactList = [Select Name from Contact];
        conPhysicianObject = contactList[0];
        String searchText = '%'+userNamePrefix+'%';
        userList = [Select Id, ContactId,ProfileId, profile.name, firstname, lastname,managerId from User where firstname like:searchText order by createdDate limit 2];
        for(user u:userList){
            if(u.Profile.name == System.Label.Profile_Provider){
                apcUserTest = u;
            } else if(u.Profile.name == System.Label.Profile_EXT_CollabPhy){
                phyUserTest = u;
            }
        }
        lstAgreements = [Select Id, Name, Physician_ID__c, Nurse_Practitioner_ID__c, Start_Date__c, End_Date__c, Agreement_For__c, Status__c from Collaborative_Agreement__c];
        collabAgreementDetailObj = lstAgreements[0];

        ccaObj = [Select Id,Agreement_ID__c,ReviewForSObjectID__c,ReviewForSObject__c from Concurrent_Chart_Assignment__c];


        mcon = new MessagingSendMessagePanelController();
    }
            
    @IsTest
    static void testDispatchMessage(){
        retrieveSetUpData();
        String retJson1, retJson2, retJson3, retJson4, retJson5, retJson6;
        Messaging_Detail__c retMap1, retMap2, retMap3;
        Id msgMasterId1, msgMasterId2, msgMasterId3;
        String inputParamJson1 = '{"messageParty1":"' + apcUserTest.id + '","messageParty2":"' + phyUserTest.id + '","msgMasterId":"","TargetTypeSobjectAPI":"Collaborative_Agreement__c","recordId":"' + collabAgreementDetailObj.id + '","messageContent":"1st message"}';
		String inputParamJson2 = '{"messageParty1":"' + apcUserTest.id + '","messageParty2":"' + phyUserTest.id + '","msgMasterId":"","TargetTypeSobjectAPI":"Collaborative_Agreement__c","recordId":"' + collabAgreementDetailObj.id + '","messageContent":"2nd message"}';
        String inputParamJson3 = '{"messageParty1":"' + apcUserTest.managerid + '","messageParty2":"' + phyUserTest.id + '","msgMasterId":"","TargetTypeSobjectAPI":"Collaborative_Agreement__c","recordId":"' + collabAgreementDetailObj.id + '","messageContent":"1st escalation message","isEscalated":true}';
        String inputParamJson6 = '{"messageParty1":"' + apcUserTest.managerid + '","messageParty2":"' + phyUserTest.id + '","msgMasterId":"","TargetTypeSobjectAPI":"Collaborative_Agreement__c","TargetTopicId":"' + collabAgreementDetailObj.id + '","isEscalated":true}';
        Test.startTest();
        System.runAs(phyUserTest){
            retJson1 = MessagingSendMessagePanelController.dispatchMessage(inputParamJson1);
            retJson2 = MessagingSendMessagePanelController.dispatchMessage(inputParamJson2);
            retJson3 = MessagingSendMessagePanelController.dispatchMessage(inputParamJson3);
            
            retMap2 = (Messaging_Detail__c)JSON.deserialize(retJson2, Messaging_Detail__c.class);
        	msgMasterId2 = (Id)retMap2.get('Messaging_Master__c');
            retMap3 = (Messaging_Detail__c)JSON.deserialize(retJson3, Messaging_Detail__c.class);
    	    msgMasterId3 = (Id)retMap3.get('Messaging_Master__c');
	        
            String inputParamJson4 = '{"msgMasterId":"' + msgMasterId2 + '"}';
            String inputParamJson5 = '{"msgMasterId":"' + msgMasterId3 + '"}';
            
            retJson4 = MessagingSendMessagePanelController.getMessagesWithMasterId(inputParamJson4);
            retJson5 = MessagingSendMessagePanelController.getMessagesWithMasterId(inputParamJson5);
            
            retJson6 = MessagingSendMessagePanelController.getMessageMasterData(inputParamJson6);
        }
        Test.stopTest();
        System.assertNotEquals(retJson1, NULL, 'dispatchMessage() Not worked.');
        retMap1 = (Messaging_Detail__c)JSON.deserialize(retJson1, Messaging_Detail__c.class);
        msgMasterId1 = (Id)retMap1.get('Messaging_Master__c');
        System.assertNotEquals(msgMasterId1, NULL, 'dispatchMessage() Not worked. Returned no Messaging_Master__c.');
        
        List<Messaging_Master__Share> mdsL = [Select UserOrGroupId, AccessLevel, RowCause From Messaging_Master__Share Where ParentId =:msgMasterId1 AND RowCause =: MessagingUtility.ROW_CAUSE_MSG_EXTPP];
        boolean isSharedWithAPC = false;
        boolean isSharedWithAPCMngr = false;
        for(Messaging_Master__Share mds : mdsL){
            if(mds.UserOrGroupId == apcUserTest.id && mds.RowCause == MessagingUtility.ROW_CAUSE_MSG_EXTPP){
                isSharedWithAPC = true;
            }
            if(mds.UserOrGroupId == apcUserTest.managerid && mds.RowCause == MessagingUtility.ROW_CAUSE_MSG_EXTPP){
                isSharedWithAPCMngr = true;
            }
        }
        System.assertEquals(True, isSharedWithAPC, 'Message master not shared with APC.');
        System.assertEquals(True, isSharedWithAPCMngr, 'Message master not shared with APC Manager.');
                
        System.assertNotEquals(retJson2, NULL, 'dispatchMessage() Not worked on 2nd try.');
        System.assertEquals(msgMasterId1, msgMasterId2, 'dispatchMessage() Not worked. Returned Messaging_Master__c id are not same.');
        
        System.assertNotEquals(retJson3, NULL, 'dispatchMessage() Not worked for escalation.');
        System.assertNotEquals(msgMasterId1, msgMasterId3, 'dispatchMessage() Not worked. Returned Messaging_Master__c id are same when escalated.');
        
        System.assertNotEquals(retJson4, NULL, 'getMessagesWithMasterId() Not worked.');
        Map<String, List<MessagingWrapperParams.MessageChainParms>> msgChainMap1 = (Map<String, List<MessagingWrapperParams.MessageChainParms>>)JSON.deserialize(retJson4, Map<String, List<MessagingWrapperParams.MessageChainParms>>.class);
        List<MessagingWrapperParams.MessageChainParms> msgChainList1 = msgChainMap1.get('messageHistoryChain');
        System.assertEquals(msgChainList1.size(), 2, 'getMessagesWithMasterId() Not worked. Not returned correct list of records.');
        
        System.assertNotEquals(retJson5, NULL, 'getMessagesWithMasterId() Not worked.');
        Map<String, List<MessagingWrapperParams.MessageChainParms>> msgChainMap2 = (Map<String, List<MessagingWrapperParams.MessageChainParms>>)JSON.deserialize(retJson5, Map<String, List<MessagingWrapperParams.MessageChainParms>>.class);
        List<MessagingWrapperParams.MessageChainParms> msgChainList2 = msgChainMap2.get('messageHistoryChain');
        System.assertEquals(msgChainList2.size(), 1, 'getMessagesWithMasterId() Not worked. Not returned correct list of records.');
        
        System.assertNotEquals(retJson6, NULL, 'getMessageMasterData() Not worked.');
        MessagingWrapperParams retWrap1 = (MessagingWrapperParams)JSON.deserialize(retJson6, MessagingWrapperParams.class);
        System.assertEquals(msgMasterId3, retWrap1.messagingMasterId, 'getMessageMasterData() has not returned same Message Master Id');
        System.assertEquals(collabAgreementDetailObj.id, retWrap1.SobjectId, 'getMessageMasterData() has not returned same Message Master Id');
        System.assertEquals(apcUserTest.managerid, retWrap1.MessageTo, 'getMessageMasterData() has not returned same Message To Id');
        System.assertEquals(phyUserTest.id, retWrap1.MessageFrom, 'getMessageMasterData() has not returned same Message From Id');
    }
    
}