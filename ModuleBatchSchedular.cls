global  with sharing class ModuleBatchSchedular
	
	/*
	@Description: This method will execute the batch whos name is passed as a parameter in the scheduler  
	*/
	global void execute(SchedulableContext SC) {
     	Type batchType = Type.forName(batchName);	
     	Database.executeBatch((Database.Batchable<sobject>)batchType.newInstance(),scope);						   
    }    
}