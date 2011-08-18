public class newGeoLocationExt {
	
	public boolean isstep1 { get; set; } { isstep1 = true; }
	
	public boolean isstep2 { get; set; } { isstep2 = false; }
	 
	private final Account acct;
	
	public newGeoLocationExt( ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
    	
    	items = new List<SelectOption>(); 
    	items.add(new SelectOption('addr','Use this address')); 
    	items.add(new SelectOption('manu','Manually locate')); 
    	method = 'manu';
    	
		if ( acct.BillingStreet != null &&  
	    		acct.BillingCity != null &&
	    		acct.BillingState != null ) { 
    		method = 'addr'; 
    		
    		nextAddr = GeoUtils.accountAddressString(acct); 
    	}
    }
    public string nextAddr { get; set; }     
    
    public string geostatus { get; set; }

 	public string geopoint { get; set; }
    
    public boolean hasNextAddress {	get { return  ( nextAddr != '' ); } 	}
    
    public pageReference step2() {
    	isstep1 = false; 
    	isstep2 = true;	
    	
    	Geo_Location__c glnew = new Geo_Location__c( 
	    	name = acct.name,
	    	webLink__c = acct.website,
	    	about_us__c = acct.description
    	); 
    	insert glnew;
    	acct.Geo_Location__c = glnew.id; 
    	update acct;
    	    	
    	if ( method == 'manu' ) { 
    	 	// go to the position page	
    	 	PageReference pr = Page.GeoReposition;  //new PageReference( '/apex/GeoReposition' ); 
    	 	pr.getParameters().put('id', glnew.id);
    	 	pr.setRedirect( true);
    	 	return pr;
    	}   	
        
        if ( geostatus  == '200' )  {
            string[] lat_lon = geopoint.split(',');
            glnew.lat__c = Double.valueOf(lat_lon[1]); 
            glnew.lon__c = Double.valueOf(lat_lon[0]);  
            glnew.geocode_status__c = 'G_GEO_SUCCESS';
        } else { 
            glnew.lat__c = 0.0; glnew.lon__c = 0.0;
            glnew.geocode_status__c = 
            	GeoUtils.geo_response.get( geostatus )
            	+ ' ('+ geostatus + ')';
        }         
		update glnew; 
 	 
    	return new PageReference('/'+glnew.id);
    }
         
    public Boolean automatic { set; get; } 
	public list<SelectOption> items { get; set; }  
	public string method   { get; set;} 
	
	public static testmethod void test_geo() {
		Account a = [select id,name,website,description,billingcountry,billingpostalcode,billingstreet,billingstate,billingcity from Account limit 1];
		ApexPages.StandardController ssc = 
		new ApexPages.StandardController(a);
        newGeoLocationExt nge = new newGeoLocationExt(  ssc);
		System.assert( nge.automatic == null );
		System.assert( nge.isstep1 == true); 
		System.assert( nge.isstep2 == false); 
		System.assert(nge.step2() != null);
	} 
}