
public with sharing class Module_withSharing_Utility {
    
    public static Module_IBusinessLayer initServiceLayer (String clsName) {
        Type t = Type.forName(clsName);
        return (Module_IBusinessLayer)t.newInstance();
    }

    //some other utility methods for common logics
}
