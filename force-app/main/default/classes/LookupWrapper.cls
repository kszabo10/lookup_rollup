/***
 * ===================================================================
 * @author      
 * @email       
 * @version     
 * @date        
 * @description 
 * ===================================================================
**/
public class LookupWrapper{
    public String parentObjectAPI;
    public String childObjectAPI;
    public String parentRollupFieldAPI;
    public String childFieldAPI;
    public String lookupFieldAPI;
    public String lookupFieldReferenceAPI;      // derived from lookupFieldAPI, it may be replaced with __r or the Id postfix may be taken out
    public String operation;
    public String queryCondition;

    // Setters
    public void setParentObjectAPI(String iParentObjectAPI){
        this.parentObjectAPI = iParentObjectAPI;
    }

    public void setChildObjectAPI(String iChildObjectAPI){
        this.childObjectAPI = iChildObjectAPI;
    }

    public void setParentRollupFieldAPI(String iParentRollupFieldAPI){
        this.parentRollupFieldAPI = iParentRollupFieldAPI;
    }

    public void setChildFieldAPI(String iChildFieldAPI){
        this.childFieldAPI = iChildFieldAPI;
    }

    public void setLookupFieldAPI(String iLookupFieldAPI){
        this.lookupFieldAPI = iLookupFieldAPI;
    }

    public void setLookupFieldReferenceAPI(String iLookupFieldReferenceAPI){
        this.lookupFieldReferenceAPI = iLookupFieldReferenceAPI;
    }


    public void setOperation(String iOperation){
        this.operation = iOperation;
    }

    public void setQueryCondition(String iQueryCondition){
        this.queryCondition = iqueryCondition;
    }

}