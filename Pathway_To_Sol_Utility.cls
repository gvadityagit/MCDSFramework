/**
 * @File Name          : Pathway_To_Sol_Utility.cls
 * @Description        : 
 * @Author             : Naveen Ila
 * @Group              : 
 * @Last Modified By   : Naveen Ila
 * @Last Modified On   : 2/20/2020, 6:57:14 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/20/2020   Naveen Ila     Initial Version
**/
public inherited sharing class Pathway_To_Sol_Utility {

    /**
    * @description 
    * @author Naveen Ila | 2/20/2020 
    * @param String clsName 
    * @return Pathway_To_Sol_IBusinessLayer 
    **/
    public static Pathway_To_Sol_IBusinessLayer initServiceLayer (String clsName) {

        Type t = Type.forName(clsName);
        return (Pathway_To_Sol_IBusinessLayer)t.newInstance();

    }

    /**
    * @description 
    * @author Naveen Ila | 2/20/2020 
    * @param HttpRequest req 
    * @param HttpResponse res 
    * @param String opNam 
    * @return void 
    **/
    public static void createApiTracker (HttpRequest req, HttpResponse res, String opNam) {

        String reqBody = req.getBody();
        String resData = 'Got Error Code:= ' + res.getStatusCode() 
                                    //+ ' Error:= ' + res.getBody()
                                    ;

        createApiTracker(reqBody, resData, opNam);

    }

    /**
    * @description 
    * @author Naveen Ila | 2/20/2020 
    * @param String req 
    * @param String res 
    * @param String opNam 
    * @return void 
    **/
    public static void createApiTracker (String req, String res, String opNam) {

        Id recordTypeId = Schema.SObjectType.API_Tracker__c.getRecordTypeInfosByDeveloperName().get('Pathway_To_Sol').getRecordTypeId();
        API_Tracker__c apiTracker = new API_Tracker__c();
        apiTracker.RecordTypeId = recordTypeId;
        apiTracker.Operation_Name__c = opNam;
        apiTracker.Request__c = req;
        apiTracker.Response__c = res;
        apiTracker.Status__c = 'Failure';
        apiTracker.Last_Fired_Date__c = System.now();

        Database.insert(apiTracker, FALSE);
    }

    
    
}