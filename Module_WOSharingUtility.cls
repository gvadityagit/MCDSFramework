public without sharing class Module_WOSharingUtility {
    
    public static List<Database.SaveResult> insertintoShareRecords(List<Object__Share> msgShrLst, Boolean allOrNone){
              return Database.insert(msgShrLst, allOrNone);
    }
}
