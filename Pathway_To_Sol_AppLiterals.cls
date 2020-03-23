/**
 * @File Name          : Pathway_To_Sol_AppLiterals.cls
 * @Description        : 
 * @Author             : Naveen Ila
 * @Group              : 
 * @Last Modified By   : Naveen Ila
 * @Last Modified On   : 2/19/2020, 2:50:02 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/19/2020   Naveen Ila     Initial Version
**/
public with sharing class Pathway_To_Sol_AppLiterals {

    public ENUM PROCESS_NAME {PATHWAY_TO_SOL_INT}
    public ENUM ACTION_NAME {CONTACT_DATA_CHANGE_ASYNC
                            , CONTACT_DATA_CHANGE_SYNC
                            ,ENGAGEMENT_DATA_CHANGE_ASYNC
                            ,ENGAGEMENT_DATA_CHANGE_SYNC
                            ,ENGAGEMENT_DATA_PUSH_ON_DEMAND_ASYNC
                            ,ENGAGEMENT_DATA_PUSH_ON_DEMAND_SYNC

                            }

    public static final String BASE_SERVICE_LAYER_CLS_NAME = 'Pathway_To_Sol_ServiceLayerHandler';
    public static final String OP_NAME_CON_ADDR_OR_PHONE_CHANGE = 'Contact_Address_Phone_Change';
    public static final String ACCESS_TOKEN_MDT_NAME = 'Pathway_To_Sol_Details';
    public static final String GENERIC_SERVICE_ENDPOINT = 'pathway_to_sol';
    
    public static final String OP_NAME_ENG_DATA_CHANGE = 'ENGAGEMENT_DATA_CHANGE';
    public static final String ENG_PROG_STATUS_OPEN = 'Open';
}