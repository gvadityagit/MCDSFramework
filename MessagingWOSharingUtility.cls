public without sharing class MessagingWOSharingUtility {
    
    public static List<Database.SaveResult> insertMessageShareRecords(List<Messaging_Master__Share> msgShrLst, Boolean allOrNone){
        system.debug('in sharing utility='+ msgShrLst);
        return Database.insert(msgShrLst, allOrNone);
    }
}