@RestResource(urlMapping='/application/modulename/*')
global with sharing class Module_ExposeAPIHandler {
    
    static List<Wrapper> wrapperlist=null;
    
    @HttpGet
    global static List<Wrapper> genericGet(){
        String searchKey = RestContext.request.params.get('searchKey');
        String searchValue = RestContext.request.params.get('searchValue');
        if(searchKey<>null && searchValue<>null){
          //invokeServiceLayer
        }
        return wrapperList;
    } 
    
    @HttpPost 
    global static String postData() {
        //input formatting
      //invoke Service Layer Method
      return null;
    }
    
    @HttpDelete
    global static String deleteData() {
          //input formatting
       //invoke Service Layer Method 
       return null;
    }
    
    @HttpPut
    global static String updateData() {
          //input formatting
        //invoke Service Layer Method 
        return null;
      }

global class Wrapper{
 
    public String firstName;
    public String lastName;
    public String Gender;
    public Date Birthdate;
    public String Phone;
    public String Email;
    public String mailingCity;
    public String mailingCountry;
    public String mailingPostalCode;
    public String mailingState;
    public String mailingStreet;
}

}
