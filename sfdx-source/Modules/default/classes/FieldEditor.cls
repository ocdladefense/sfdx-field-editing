public with sharing virtual class FieldEditor {

  
    
	public Id sObjectId;
    
    public SObject record {get; set;}
    
    public String fieldName {public get; private set;}
    
    public String fieldValue {get; set;}
    
    public String codeServer {public get; private set;}
    
    
    public FieldEditor() {
        Map<String,String> query = ApexPages.currentPage()?.getParameters();
        
        Ocdla_Apps__c config = Ocdla_Apps__c.getOrgDefaults();

        Boolean isSandbox = [SELECT IsSandbox, Id FROM Organization].IsSandbox;
        
        this.codeServer = isSandbox ? config.Ocdla_Test_Application_Server__c : config.Ocdla_Production_Application_Server__c;

        if(query.get('id') != null) {
        	this.sObjectId = (Id)query.get('id');
        }
        
        if(query.get('fieldName') != null) {
        	this.fieldName = query.get('fieldName');
        }
        
        for(String key : new Set<String>{'id','fieldName'}) {
            if(null == query.get(key)) {
                throw new FieldEditorException('REQUIRED_PARAMETER_MISSING: '+key+' parameter cannot be empty.');
            }
        }
        
        // Construct a query for the given field dynamically.
        Schema.SObjectType token = this.sObjectId.getSObjectType();
		Schema.DescribeSObjectResult result = token.getDescribe();
        
        String queryFormat = 'SELECT {0} FROM {1} WHERE Id = \'\'{2}\'\'';
        List<String> params = new List<String>{this.fieldName, result.getName(), this.sObjectId};

		this.record = Database.query(String.format(queryFormat,params));
        this.fieldValue = (String)record.get(this.fieldName);
    }
    

  
    
    /**
     * Save the result of the rich text edit session.
     * Results are saved to fieldName and fieldValue using the SObject.put() method.
     * We redirect with the same PageReference variables.
     */
    public virtual PageReference doSubmit() {
        
		PageReference current = ApexPages.currentPage();
        Map<String,String> params = current.getParameters();
        params.put('id', this.sObjectId);
        params.put('fieldName', this.fieldName);
        current.setRedirect(True);
        
        this.record.put(this.fieldName, this.fieldValue);
        update this.record;
        
        return current;
    }
    
    
    public virtual PageReference doCancel() {
        
        String theUrl = '/'+String.valueOf(this.sObjectId);
        
        return new PageReference(theUrl);
    }
}