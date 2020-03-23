/**
 * @File Name          : Pathway_To_Sol_IBusinessLayer.cls
 * @Description        : 
 * @Author             : Naveen Ila
 * @Group              : 
 * @Last Modified By   : Naveen Ila
 * @Last Modified On   : 2/19/2020, 2:50:12 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/19/2020   Naveen Ila     Initial Version
**/
public interface Pathway_To_Sol_IBusinessLayer {

    
    Map<String,Object> invokeBusinessProcess(Pathway_To_Sol_AppLiterals.PROCESS_NAME processName, Pathway_To_Sol_AppLiterals.ACTION_NAME actionName, Map<String, Object> ipMap);
    
    
}