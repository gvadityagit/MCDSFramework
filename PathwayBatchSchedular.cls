/*Schedular for scheduling all batch classes used in the application*/
global with sharing class PathwayBatchSchedular implements Schedulable{
	
	public string batchName              {get;set;}
	public Integer scope                 {get;set;}
	
	public PathwayBatchSchedular(String batchName,Integer scope){	
		this.batchName = batchName;	
		this.scope= scope;								
	}
	
	/*
	@Description: This method will execute the batch whos name is passed as a parameter in the scheduler  
	*/
	global void execute(SchedulableContext SC) {
     	Type batchType = Type.forName(batchName);	
     	Database.executeBatch((Database.Batchable<sobject>)batchType.newInstance(),scope);						   
    }    
}