/**
 * @File Name          : Pathway_To_Sol_API_Wrapper.cls
 * @Description        : 
 * @Author             : Naveen Ila
 * @Group              : 
 * @Last Modified By   : Naveen Ila
 * @Last Modified On   : 2/18/2020, 3:29:40 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/18/2020   Naveen Ila     Initial Version
**/
public with sharing class Pathway_To_Sol_API_Wrapper {
    
    
    
    public class ConDataChangeReqBody_Generator {

        public Pathway_To_Sol_Int_HeaderInfo headerInfo;
        public ContactDataHolder contactData;

        public ConDataChangeReqBody_Generator() {

            headerInfo = new Pathway_To_Sol_Int_HeaderInfo();
            headerInfo.operationName = Pathway_To_Sol_AppLiterals.OP_NAME_CON_ADDR_OR_PHONE_CHANGE;
            contactData = new ContactDataHolder();

        }

    }
    
    public class EngagementChagneDataGenerator {
        public Pathway_To_Sol_Int_HeaderInfo headerInfo;
        public EngagementDataHolder engData;
        public EngagementChagneDataGenerator() {
            headerInfo = new Pathway_To_Sol_Int_HeaderInfo();
            headerInfo.operationName = Pathway_To_Sol_AppLiterals.OP_NAME_ENG_DATA_CHANGE;
            engData = new EngagementDataHolder();

        }
    }
    public class EngagementDataHolder {
        public List<EngInfo> engList;
    }

    public class EngInfo {

        /*
        public String riskLevel;
        public String engId;
        public String memberId;
        public String engPrgStatus;
        public Boolean isConDataExist;
        public ContactInfo conInfo;
        public AccountInfo accInfo;
        public String cpName;
        public String engName;
        public String npName;
        public String npUsrId;
        */
        public Map<String,Object> data;

    }

    /***********************************************************************************
    * Name: ContactDataHolder
    * Object: 
    * Purpose: 
    * Author:  (Naveen Ila)
    * Create Date: 2020-02-17
    * Modify History:
    * 2020-02-17        Create this class
    ************************************************************************************/
    public class ContactDataHolder {
        public List<ContactInfo> conList;
    }

    /***********************************************************************************
    * Name: ContactInfo
    * Object: 
    * Purpose: 
    * Author:  (Naveen Ila)
    * Create Date: 2020-02-17
    * Modify History:
    * 2020-02-17        Create this class
    ************************************************************************************/
    public class ContactInfo {

        public Map<String,Object> con;

    }

    
    /***********************************************************************************
    * Name: AccountInfo
    * Object: 
    * Purpose: 
    * Author:  (Naveen Ila)
    * Create Date: 2020-02-28
    * Modify History:
    * 2020-02-17        Create this class
    ************************************************************************************/
    public class AccountInfo {

        public Map<String,Object> acc;

    }

    /***********************************************************************************
    * Name: Pathway_To_Sol_Int_HeaderInfo
    * Object: 
    * Purpose: 
    * Author:  (Naveen Ila)
    * Create Date: 2020-02-17
    * Modify History:
    * 2020-02-17        Create this class
    ************************************************************************************/
    public class Pathway_To_Sol_Int_HeaderInfo {

        public String operationName;

        
    }


}