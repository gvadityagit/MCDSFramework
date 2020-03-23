
global with sharing class Module_BatchSchedular implements Schedulable{
	
	public string batchName              {get;set;}
	public Integer scope                 {get;set;}
	
	public Module_BatchSchedular(String batchName,Integer scope){	
		this.batchName = batchName;	
		this.scope= scope;								
	}
	
	
	global void execute(SchedulableContext SC) {
     	Type batchType = Type.forName(batchName);	
     	Database.executeBatch((Database.Batchable<sobject>)batchType.newInstance(),scope);						   
    }    
}
