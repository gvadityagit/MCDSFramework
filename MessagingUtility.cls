public inherited sharing class MessagingUtility {

    //constants
    public static final Map<String, Message_Center_Setting__mdt> MessageCenterMdtMap;
    private static Map<String,Profile> profileNameMap;
    
     public static IBusinessLayer initServiceLayer (String clsName) {
        Type t = Type.forName(clsName);
        return (IBusinessLayer)t.newInstance();
    }

    static {
        Map<String, Message_Center_Setting__mdt> tempMap = new Map<String, Message_Center_Setting__mdt>();
        for (Message_Center_Setting__mdt s: [SELECT DeveloperName, Value__c 
                                     FROM Message_Center_Setting__mdt 
                                     WHERE App_Name__c = 'Physician'])
        {
            tempMap.put(s.DeveloperName, s);
        }
        MessageCenterMdtMap = tempMap;
    }

	public static final Id RECTYP_Messaging_Master_PhysicianMessaging = Schema.SObjectType.Messaging_Master__c.getRecordTypeInfosByName().get('PhysicianMessaging').getRecordTypeId();
    
    public static final String ROW_CAUSE_MSG_EXTPP = Schema.Messaging_Master__Share.rowCause.EXT_PP_Sharing__c;
    
    public static Id getRelevantMsgMasterRecordType(MessagingAppLiterals.PROCESS_NAME actType){
        switch on actType{
            when PhysicianUIDashBoard { return RECTYP_Messaging_Master_PhysicianMessaging;}
            when CommunicationUIDashBoard { return RECTYP_Messaging_Master_PhysicianMessaging;}
            when else { return RECTYP_Messaging_Master_PhysicianMessaging;}
        }
    }
    
    public static Messaging_Master__Share getMessagingMasterShareRec(Id msgMId, String usrOrGrpId){
        Messaging_Master__Share messagingMasterShareRec = new Messaging_Master__Share(ParentId = msgMId, 
                                                                 UserOrGroupId = usrOrGrpId, 
                                                                 AccessLevel = AppLiterals.ACCESSLEVEL_EDIT,
                                                                 RowCause = ROW_CAUSE_MSG_EXTPP);
        return messagingMasterShareRec;
    }

    public static Map<String,String> getStaticResourceContent(List<String> resourceKeys){

        Map<String,String> staticResourceContentMap = new Map<String,String>();
        for (StaticResource sr : [select name, Body from StaticResource where Name in :resourceKeys]) {
            staticResourceContentMap.put(sr.name, sr.Body.toString());
        }
        return staticResourceContentMap;
    }

    public static Map<String, Profile> getProfileNameMap(){
        if(profileNameMap == null){
            profileNameMap = new Map<String, Profile>();
            List<String> idNames = new List<String>{Label.Profile_Provider, Label.Profile_EXT_CollabPhy,Label.Profile_Manager};
            for (Profile pf : [Select Id, name from Profile where name in :idNames]) {
                profileNameMap.put(pf.name, pf);
            }
        }

        return profileNameMap;
    }

    public static Map<Id,Boolean> checkManagerUser(List<Id>userIds){
        Map<Id,Boolean>retMap=new Map<Id,Boolean>();
        List<User> usrLst=[SELECT ID,PROFILE.NAME,ManagerId FROM USER WHERE MANAGERId in : userIds OR id in : userIds];
        for(User u:usrLst){
            if(u.profile.Name== Label.Profile_Manager){
                retMap.put(u.Id,true);
            }
            if(u.managerId!=null){
                retMap.put(u.managerId,true);

            }

        }
        return retMap;

    }

    public static Map<Id, User> getCommunityUsers4mContact(List<Id> lstConatct){
        Map<Id, User> contact2CommunityUserMap = new Map<Id, User>();
        for(User us: [SELECT id,contactid, 
                               isactive 
                        FROM   USER 
                        WHERE  contactid IN :lstConatct ]){
            contact2CommunityUserMap.put(us.contactid, us);
        }
        return contact2CommunityUserMap;
    }
}