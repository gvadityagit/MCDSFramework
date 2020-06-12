public inherited sharing class Module_WrapperParams {
    
    @InvocableVariable(label='Record ID' required=true)
    public Id detailId;
   
    
    @InvocableVariable(label='Parent ID' required=true)
   
    public String MessageTo {get;set;}
    public String MessageFrom {get;set;} //= cretedBy
    public String RecordTypeName {get;set;}
    public String IsEscalated {get;set;}
    public String SobjectId {get;set;}
    public String SobjectType {get;set;}
    public String recordTypeID {get;set;}
   
    
    //variables used  in messageDashboardComponent to pass attributes to messagingNewComponent
    
	public String sourceApplication{set;get;}
	public String sourcePageName{set;get;}
    
  
    public String state {get;set;}
    
  
    
    
    public List<MessageChainParms>messageChainList{set;get;}
    
    public class ModuleChainParms{
    	
    	public ModuleChainParms(String fromStr,String msg,String dt){
    		this.fromToStr=fromStr;
    		this.messgStr=msg;
    		this.msgDate=dt;
    	}
    	public String fromToStr{set;get;}
    	public String messgStr{set;get;}
    	public String msgDate{set;get;}
    }

    public class ModuleChainWrapper{
        public String recordId{get;set;}
        public String typeSobjectAPI{get;set;}
      
        public String recordAlias{get;set;}
      
       
        
    }

    public class ModuleChainWrapper2{
       
        public String state{get;set;}
        public String type{get;set;}
        public String typeSobjectAPI{get;set;}
        public Date startDate{get;set;}
        public Date endDate{get;set;}
        public String status{get;set;}
        public String recordId{get;set;}
        public String managerUserId{get;set;}
        public String managerUserName{get;set;}
       
	
       
        public Boolean isEscalated{set;get;}

        public ModuleChainWrapper2(String recordId, String userType, String userName, String state, String type, Date startDate, Date endDate, String status){
            this.recordId= recordId;
            this.NurseName = userType;
           
            this.state = state;
            this.type = type;
            this.startDate = startDate;
            this.endDate = endDate;
            this.status = status;
        }
    }
    
    public class WrapClass3{
        public string ReceivedFrom{get; set;}
        public string TypeofMessage{get; set;}
        public string Received{get; set;}
        
        public string RelatedtoRecord{get; set;}
        public string RecordDate{get; set;}
        public string RecordId{get; set;}
       
        public string ReceivedFromId{get; set;}
        public boolean IsReadMessage{get; set;}
        public String contactId{set;get;}
        public String contactName{set;get;}
       
        public String escalatedStatus{set;get;}
    }
    
   
}
