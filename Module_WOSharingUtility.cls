public without sharing class Module_WOSharingUtility {
    
    public static List<Database.SaveResult> insertintoShareRecords(List<Object__Share> objShrLst, Boolean allOrNone){
              return Database.insert(objShrLst, allOrNone);
    }
}
