public class Product2Extension {

    public List<Product2> productsToBeInserted{get;set;}
    public List<PriceBookEntry> pbesToInsert{get;set;}
    public Map<String,String> productLabels{get;set;}
    public Map<String,String> pbLabels{get;set;}
    public List<ProductWrapper> productsToInsert{get;set;}

    public void AddRows(){
        
        for ( Integer i=0; i< constants.DEFAULT_ROWS; i++ ){
            productsToInsert.add(New ProductWrapper());
        }
    }
       
    public class ProductWrapper{
        
        public Product2 productRecord{get;set;}
        public PriceBookEntry pricebookEntryRecord{get;set;}
        
        public ProductWrapper(){
            productRecord = new Product2(Name='', initial_inventory__c = 0,Family = '', isActive = False);
            pricebookEntryRecord = new PriceBookEntry(UnitPrice = 0, PriceBook2Id = Constants.STANDARD_PRICEBOOK_ID);
        }
    }
        
    public Product2Extension(ApexPages.StandardController stdController){
        productsToBeInserted = new List<Product2>();
        pbesToInsert = new List<PriceBookEntry>();
        productsToInsert =new list<ProductWrapper>();
        GetFamilyOptions();
        //addRows();
    }

    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(constants.SELECT_ONE,constants.SELECT_ONE)); 
        for(Schema.PicklistEntry family : constants.PRODUCT_FAMILY){
            options.add(new SelectOption(family.getValue(),family.getlabel()));            
        }
        return options;
    }
    

    public List<ChartHelper.ChartData> GetInventory(){
        System.debug('GetInventory');
        return ChartHelper.GetInventory();
    }

    public PageReference Save(){
       
        Integer i = 0;
        try {
            
            for(ProductWrapper pdt : productsToInsert){
  
                if(pdt.productRecord.Name != '' && pdt.productRecord.initial_inventory__c != 0 && pdt.pricebookEntryRecord.UnitPrice != 0 ){
                    productsToBeInserted.add(pdt.productRecord);
                    pbesToInsert.add(pdt.pricebookEntryRecord);
                }else{}
           
            }
            
            if(productsToBeInserted.size() > 0){ 
    
                Savepoint sp = Database.setSavepoint();     
                
                Database.SaveResult[] srList = Database.insert(productsToBeInserted, false);
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        pbesToInsert.get(i).Product2Id = sr.getId();
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted product. Product ID: ' + sr.getId());
                    }
                    else {
                        pbesToInsert.remove(i);
                        i--;
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,constants.ERROR_MESSAGE));
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                    i++;
                }
                insert pbesToInsert;
                //List<PriceBookEntry> pbesInserted = [Select Id, Product2.Name, Pricebook2.Name, UnitPrice from PriceBookEntry];
                //System.debug(pbesInserted);
               // Database.rollback(sp);

            }else{}
            
            
            //If successful clear the list and display an informational message
            
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,productsToBeInserted.size()+' Inserted'));
            productsToBeInserted.clear();   //Do not remove
            pbesToInsert.clear();
            addRows();  //Do not remove
       } catch (Exception e){
		System.debug(e.getMessage());
        }
        return null;
   
    }

}