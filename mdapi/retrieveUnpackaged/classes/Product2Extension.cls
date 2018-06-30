public class Product2Extension {

    public List<Product2> productsToInsert {get;set;}
    public Map<String,String> fieldLabels{get;set;}

    public Product2Extension(ApexPages.StandardController stdController){
        productsToInsert = new List<Product2>();
        getLabels();
        addRows();
    }
    
    public void GetLabels(){
        fieldLabels = new Map<String,String>{};
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType productSchema = schemaMap.get('Product2');
        Map<String, Schema.SObjectField> fieldMap = productSchema.getDescribe().fields.getMap();
        
        for (String fieldName: fieldMap.keySet()) {      
            fieldLabels.put(fieldName,fieldMap.get(fieldName).getDescribe().getLabel());
            System.debug('label : ' + fieldLabels);
        }
               
    }

    public void AddRows(){
        for ( Integer i=0; i<2; i++ ){
            productsToInsert.add( new Product2() );
        }
    }
    
    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }

    public PageReference Save(){
        try {
            insert productsToInsert;

            //If successful clear the list and display an informational message
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,productsToInsert.size()+' Inserted'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e){

        }
        return null;
    }

}