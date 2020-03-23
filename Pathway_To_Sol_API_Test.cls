/**
 * @File Name          : Pathway_To_Sol_API_Test.cls
 * @Description        : 
 * @Author             : Naveen Ila
 * @Group              : 
 * @Last Modified By   : Naveen Ila
 * @Last Modified On   : 2/21/2020, 1:29:14 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/21/2020   Naveen Ila     Initial Version
**/
@isTest
private class Pathway_To_Sol_API_Test {

    @testSetup 
    static void setupData() {

        Test.startTest();

            TestClassDataFactory.loadCustomSettings(FALSE, new Set<String>{'Utility__c'});
            Integer heavyDataNoOfRecs = 10;
            List<Account> accList = new List<Account>();
            Account acc = TestClassDataFactory.createNewAccount('Facility');
            accList.add(acc);
            
            Account accClient = TestClassDataFactory.createNewAccount('Client');
            accList.add(accClient);
            
            

            insert accList;
            
            List<Clinical_Program__c> cpList = new List<Clinical_Program__c>();
            Clinical_Program__c dsnpCP = TestClassDataFactory.testCP(System.Label.DSNP, FALSE);
            Clinical_Program__c iesnpCP = TestClassDataFactory.testCP(System.Label.IESNP, FALSE);
            Clinical_Program__c isnpCP = TestClassDataFactory.testCP(System.Label.ISNP, FALSE);
            Clinical_Program__c ttsCP = TestClassDataFactory.testCP(System.Label.Transitions_to_SNF, FALSE);
            Clinical_Program__c cpcCP = TestClassDataFactory.testCP(System.Label.CarePlus_Community, FALSE);
            cpList.add(dsnpCP);
            cpList.add(isnpCP);
            cpList.add(iesnpCP);
            cpList.add(ttsCP);
            cpList.add(cpcCP);
            

            insert cpList;

            List<Auto_Fax_Configuration__c> afcList = new List<Auto_Fax_Configuration__c>();
            for (Clinical_Program__c cp : cpList) {
                
                Auto_Fax_Configuration__c afc = TestClassDataFactory.populateAutoFaxConfig4SoapNote(cp.Id, FALSE);
                afcList.add(afc);

            }

            insert afcList;
            
            List<Contact> conList = new List<Contact>();
            Contact dsnpCon = TestClassDataFactory.createNewContact(acc.id, dsnpCP.id, 'Consumer');
            Contact dsnpCon2 = TestClassDataFactory.createNewContact(acc.id, dsnpCP.id, 'Consumer');
            Contact iesnpCon = TestClassDataFactory.createNewContact(acc.id, iesnpCP.id, 'Consumer');
            Contact isnpCon = TestClassDataFactory.createNewContact(acc.id, isnpCP.id, 'Consumer');
            Contact ttsCon = TestClassDataFactory.createNewContact(acc.id, ttsCP.id, 'Consumer');
            Contact cpcCon = TestClassDataFactory.createNewContact(acc.id, cpcCP.id, 'Consumer');
            conList.add(dsnpCon);
            conList.add(dsnpCon2);
            conList.add(iesnpCon);
            conList.add(isnpCon);
            conList.add(ttsCon);
            conList.add(cpcCon);

            insert conList;

            Map<Id, Contact_Information__c> conIdVsConInfoMap = new Map<Id, Contact_Information__c>();
            Map<Id, Membership__c> conIdVsMemMap = new Map<Id, Membership__c>();
            for (Contact con : conList) {
                Contact_Information__c conInfo = TestClassDatafactory.createContactInformation('Facility',con.Id, 'notes', 'street1', 'Eden Prairie', '35742', 'MN','USA');
                conInfo.Fax_Number__c = '1234567890';
                conInfo.Fax_Verified_Date__c = System.today();
                conIdVsConInfoMap.put(con.Id, conInfo);
                Membership__c membeship = TestClassDatafactory.testMembershipRec(con.Id, accClient.Id);
                conIdVsMemMap.put(con.Id, membeship);
            }
            Id conRelRTId = Schema.SObjectType.Contact_Relationship__c.getRecordTypeInfosByName().get('Physician Contact').getRecordTypeId();
            if (conIdVsConInfoMap.size() > 0) {
                
                insert conIdVsConInfoMap.values();

                Option_Type__c opType = TestClassDataFactory.testOT();
                List<Contact_Relationship__c> conRelList = new List<Contact_Relationship__c>();
                for (Id conId : conIdVsConInfoMap.keySet()) {
                   
                    Contact_Relationship__c cr = TestClassDataFactory.testCR(conId, opType.Id, FALSE);
                    cr.RecordTypeId = conRelRTId;
                    cr.Contact_Information_ID__c = conIdVsConInfoMap.get(conId).id;
                    cr.Role__c = 'PCP';
                    cr.Start_Date__c = System.today().addDays(-10);
                    cr.End_Date__c = null;
                    conRelList.add(cr); 

                }

                insert conRelList;
            }

            if (conIdVsMemMap.size() > 0) {

                insert conIdVsMemMap.values();
                
            }

            List<Client_Clinical_Program__c> ccpList = new List<Client_Clinical_Program__c>();
            Client_Clinical_Program__c dsnpCCP = TestClassDataFactory.testCCP(dsnpCP.id, accClient.id, FALSE);
            Client_Clinical_Program__c iesnpCCP = TestClassDataFactory.testCCP(iesnpCP.id, accClient.id, FALSE);
            Client_Clinical_Program__c isnpCCP = TestClassDataFactory.testCCP(isnpCP.id, accClient.id, FALSE);
            Client_Clinical_Program__c ttsCCP = TestClassDataFactory.testCCP(ttsCP.id, accClient.id, FALSE);
            Client_Clinical_Program__c cpcCCP = TestClassDataFactory.testCCP(cpcCP.id, accClient.id, FALSE);
            
            ccpList.add(dsnpCCP);
            ccpList.add(iesnpCCP);
            ccpList.add(isnpCCP);
            ccpList.add(ttsCCP);
            ccpList.add(cpcCCP);
            insert ccpList;
            
            List<Engagement__c> engList = new List<Engagement__c>();
            Engagement__c dsnpEng = TestClassDataFactory.createEngagement(acc.id, dsnpCon.Id, dsnpCCP.id, conIdVsMemMap.get(dsnpCon.Id).Id, null, FALSE);
            Engagement__c dsnpEng2 = TestClassDataFactory.createEngagement(acc.id, dsnpCon2.Id, dsnpCCP.id, conIdVsMemMap.get(dsnpCon2.Id).Id, null, FALSE);
            Engagement__c iesnpEng = TestClassDataFactory.createEngagement(acc.id, iesnpCon.Id, iesnpCCP.id, conIdVsMemMap.get(iesnpCon.Id).Id, null, FALSE);
            Engagement__c isnpEng = TestClassDataFactory.createEngagement(acc.id, isnpCon.Id, isnpCCP.id, conIdVsMemMap.get(isnpCon.Id).Id, null, FALSE);
            Engagement__c ttsEng = TestClassDataFactory.createEngagement(acc.id, ttsCon.Id, ttsCCP.id, conIdVsMemMap.get(ttsCon.Id).Id, null, FALSE);
            Engagement__c cpcEng = TestClassDataFactory.createEngagement(acc.id, cpcCon.Id, cpcCCP.id, conIdVsMemMap.get(cpcCon.Id).Id, null, FALSE);
            engList.add(dsnpEng);
            engList.add(dsnpEng2);
            engList.add(iesnpEng);
            engList.add(isnpEng);
            engList.add(ttsEng);
            engList.add(cpcEng);

            for (Engagement__c eng : engList) {

                eng.Contact_Information_ID__c = conIdVsConInfoMap.get(eng.Consumer__c).Id;
                eng.Program_Start_Date_Eng__c = System.today().addDays(-4);
                
            }
            insert engList;

        Test.stopTest();

    }

    static testMethod void accessTokenFailureStatus() {

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Pathway_To_Sol_API_Test_Mock());
            Pathway_To_Sol_API_Test_Mock.isAbleFetchToken = false;
            Contact con = [SELECT Id FROM Contact LIMIT 01];

            con.OtherStreet = 'Test Street ' + DateTime.now().addMinutes(5).getTime();

            update con;


        Test.stopTest();

        List<API_Tracker__c> apiTrackers = [SELECT Id FROM API_Tracker__c];
        System.assertEquals(1, apiTrackers.size(), 'There should be one api tracker inserted');

    }

    static testMethod void testContactAddressChange() {

        Test.startTest();
        
            Pathway_To_Sol_API_Test_Mock.isSuccessScenario = false;
            Test.setMock(HttpCalloutMock.class, new Pathway_To_Sol_API_Test_Mock());
            Contact con = [SELECT Id FROM Contact LIMIT 01];

            con.OtherStreet = 'Test Street ' + DateTime.now().addMinutes(5).getTime();

            update con;


        Test.stopTest();

        List<API_Tracker__c> apiTrackers = [SELECT Id FROM API_Tracker__c];
        System.assertEquals(1, apiTrackers.size(), 'There should be no api tracker inserted');

        
    }
    

    static testMethod void testContactAddressChangeBulk() {

        Test.startTest();

            Test.setMock(HttpCalloutMock.class, new Pathway_To_Sol_API_Test_Mock());
            List<Contact> conList = new List<Contact>();

            for (Contact con : [SELECT Id FROM Contact]) {

                con.OtherStreet = 'Test Street ' + DateTime.now().addMinutes(5).getTime();
                conList.add(con);
            }

            update conList;

        Test.stopTest();

        List<API_Tracker__c> apiTrackers = [SELECT Id FROM API_Tracker__c];
        System.assertEquals(0, apiTrackers.size(), 'There should be no api tracker inserted');

        
    }

    static testMethod void testEngRiskLevelChangeBulk() {

        Test.startTest();

            Test.setMock(HttpCalloutMock.class, new Pathway_To_Sol_API_Test_Mock());
            List<Engagement__c> engList = new List<Engagement__c>();

            for (Engagement__c eng : [SELECT Id, Risk_Level__c FROM Engagement__c]) {

                eng.Risk_Level__c = (eng.Risk_Level__c == 'High') ? 'Medium' : 'High' ;
                engList.add(eng);
            }

            update engList;

        Test.stopTest();

        List<API_Tracker__c> apiTrackers = [SELECT Id FROM API_Tracker__c];
        System.assertEquals(0, apiTrackers.size(), 'There should be no api tracker inserted');

        
    }
    
}