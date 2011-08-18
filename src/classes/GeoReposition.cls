public class GeoReposition {
    
    public GeoReposition(ApexPages.StandardController c) {
        controller = c; 
    	geolocation =[ 
    		select id, Icon_URL__c, about_us__c, name, lat__c, lon__c , PhotoURL__c,
    		WebLink__c,WebLinkName__c from Geo_Location__c where id = :controller.getRecord().id limit 1];
   		loc = new Location( geolocation);
   	}
    public pageReference relocate() {
    	// save the new position into the lat, lon fields
    	list<string> ll = location_str.split(',');
		geolocation.lat__c = parse(ll[0]);
		geolocation.lon__c = parse(ll[1]);
		geolocation.geocode_status__c = 'G_GEO_MANUAL'; // user specified these cooridnates
		try { 
			update geolocation;
		} catch ( DmlException ex ) { 
			ApexPages.addMessages(ex);
			return null;
		}
		return new PageReference('/'+ geolocation.id); 
    }
    double parse (string inp) {
    	return double.valueof( inp.replaceAll('[()]','') );	
    }
    public pageReference goBack() { 
    	return new PageReference('/'+ geolocation.id); 
    }
    
    Geo_Location__c    geolocation { get; private set; }
    public string location_str { get; set; }
    ApexPages.StandardController controller;
    public Location loc { get ; private set; }
    
   	public static testmethod void test_1() { 
    	PageReference pageRef = Page.GeoReposition;
        Test.setCurrentPage(pageRef);

   	 	Geo_Location__c ggg = new  Geo_Location__c(name='foo');
   	 	insert ggg;
   	 	ApexPages.StandardController sc = new ApexPages.StandardController(ggg);
   	 	
   	 	GeoReposition g = new GeoReposition(sc);
   	 	
   	 	g.goback(); 
   	 	g.location_str = '(22.2, 333.9)';
   	 	g.relocate(); 
   	}  
}