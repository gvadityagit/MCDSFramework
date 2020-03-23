Public With Sharing Class MessagingDashboardComponentCtrl{  
    
public MessagingWrapperParams messagingParmaObj{set;get;}

public static boolean getIsManager(){
    Id usrId=UserInfo.getUserId();
    system.debug('usrId=='+usrId);
    Map<Id,Boolean> managers=MessagingUtility.checkManagerUser(new List<Id>{usrId});
    return (managers.get(usrId)!=null ? managers.get(usrId) :false);
}

public MessagingDashboardComponentCtrl(){
    messagingParmaObj=new MessagingWrapperParams();
    messagingParmaObj.managersMessageRadioView='managerMessages';
}
    
      
    //fetching Message Center Dashboard records from ServiceLayerHandler Class  
    @remoteAction
    public static String messageCenterDashboard(string paramMap){
        List<MessagingWrapperParams.msgWrapClass> msglst=null;
        try{
            Map<String,String> inputMap = (Map<String, String>)JSON.deserialize(paramMap, Map<String, String>.class);  
            IBusinessLayer iBusinessLayer = MessagingUtility.initServiceLayer(MessagingAppLiterals.CLASS_REF.MessagingServiceLayerHandler.name());
            Map<String,Object> outputMap=iBusinessLayer.invokeBusinessProcess(MessagingAppLiterals.PROCESS_NAME.PhysicianUIDashBoard,MessagingAppLiterals.ACTION_NAME.fetchMsgDashboard,inputMap);
            msglst=(List<MessagingWrapperParams.msgWrapClass>)outputMap.get('msgwrpLst');
        }
        catch(Exception e){
            throw e;
        }
         return JSON.serialize(msglst); 
    }
    
   public boolean displayPopup{set;get;}
   public void showPopup(){
    displayPopup=true;
   }

   @remoteAction
   public static String fetchMasterRecordsForSubordinates(String paramMap){
    List<MessagingWrapperParams.msgWrapClass> msglst=null;
        try{
            Map<String,String> inputMap = (Map<String, String>)JSON.deserialize(paramMap, Map<String, String>.class);  
            IBusinessLayer iBusinessLayer = MessagingUtility.initServiceLayer(MessagingAppLiterals.CLASS_REF.MessagingServiceLayerHandler.name());
            Map<String,Object> outputMap=iBusinessLayer.invokeBusinessProcess(MessagingAppLiterals.PROCESS_NAME.CommunicationUIDashBoard,MessagingAppLiterals.ACTION_NAME.fetchSubordinatesMessages,inputMap);
            msglst=(List<MessagingWrapperParams.msgWrapClass>)outputMap.get('msgwrpLst');
        }
        catch(Exception e){
            throw e;
        }
         return JSON.serialize(msglst);
   } 

}