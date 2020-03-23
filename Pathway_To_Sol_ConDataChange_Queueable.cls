/**
 * @File Name          : Pathway_To_Sol_ConDataChange_Queueable.cls
 * @Description        : 
 * @Author             : Naveen Ila
 * @Group              : 
 * @Last Modified By   : Naveen Ila
 * @Last Modified On   : 2/18/2020, 4:46:02 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/18/2020   Naveen Ila     Initial Version
**/

public class Pathway_To_Sol_ConDataChange_Queueable implements Queueable, Database.AllowsCallouts  {

    public Map<Id, Contact> oldConMap;
    public Map<Id, Contact> newConMap;

    public Pathway_To_Sol_ConDataChange_Queueable(Map<Id, Contact> oldConMap, Map<Id, Contact> newConMap) {
        this.oldConMap = oldConMap;
        this.newConMap = newConMap;
    }

    /**
    * @description 
    * @author Naveen Ila | 2/18/2020 
    * @param QueueableContext context 
    * @return void 
    **/
    public void execute(QueueableContext context) {

        processConDataChangeRequest();

    }


    /**
    * @description 
    * @author Naveen Ila | 2/18/2020 
    * @return void 
    **/
    public void processConDataChangeRequest () {

        Pathway_ToSol_Int_Utility pathwaySolUtilityObj = new Pathway_ToSol_Int_Utility();
        HttpResponse res = pathwaySolUtilityObj.sendContactDataToSol(oldConMap, newConMap);

    }

}