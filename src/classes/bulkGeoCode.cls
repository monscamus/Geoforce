public class bulkGeoCode {
    
    public string nextAddr { get; set; } 
	
	public Account account { get; set; } 
	
	public bulkGeoCode() {		nextAddr = getNextAddress(); 	}
	
	public boolean hasNextAddress {	get { return  ( nextAddr != '' ); } 	}
	
  	public static string jsapi_script { get { return  geoApiKey.jsapi_script; }}
 
  	public static string maps_script { get { return  geoApiKey.maps_script; }}

    public string msg {get; set;}  

    public Boolean doGeocode { get; private set; } { doGeocode = false; } 
     
 	public string accountId { get; set; }

 	public string geostatus { get; set; }

 	public string geopoint { get; set; }
 	
    public void newGeoLocation() { 
    	
    	doGeocode = true;
    	// update the database, fetch a new account?
    	Geo_Location__c glnew = new Geo_Location__c( 
	    	name = account.name,
	    	webLink__c = account.website,
	    	about_us__c = account.description,
	    	lat__c = 0.0 ,
	    	lon__c = 0.0
    	); 
    
    	if (geostatus == null ) {
	    	msg = 'Geococd status is null';
	    	return;
	    	
        }
        if ( geostatus  == '200' )  { 
            glnew.geocode_status__c = 'G_GEO_SUCCESS';
            string[] lat_lon = geopoint.split(',');
            if ( lat_lon.size() ==2) {
	            glnew.lat__c = Double.valueOf(lat_lon[1]); 
	            glnew.lon__c = Double.valueOf(lat_lon[0]); 
            } 

        } else { 
            
            glnew.geocode_status__c = 
            	GeoUtils.geo_response.get( geostatus )
            	+ ' ('+ geostatus + ')';
        }         
        try {
	 		insert glnew;
	    	account.Geo_Location__c = glnew.id; 
	    	update account;
	    	
	    	nextAddr = getNextAddress();  // fetch next one    	
        } catch (exception e) {
            msg = e.getMessage(); 
            doGeocode = false;
        }
    }
    
    /* 
     * pull the account into a class var, and generate an address string to return
     */
    string getNextAddress() { 
    	try {
    	   	
    	   	account = [select id, name,billingstreet,billingcity,billingstate,
              billingpostalcode,billingcountry , description, website 
              from account where geo_location__c = null AND 
              Geocode_Exclude__c != true 
              limit 1];
         	accountId = account.id;
         	
         	return  GeoUtils.accountAddressString(account);
         	 
        } catch (exception e) {
            msg = e.getMessage(); 
            doGeocode = false;
            return '' ;
        }
    }
    
    public static testmethod void t1 () { 
        Account a =  new Account(name='foo');
        insert a;
        bulkGeoCode e = new bulkGeoCode(); 
        system.debug( e.msg );
        system.assertEquals( e.doGeocode , false);
        e.account = a;
        e.geostatus = '200';
        e.geopoint = '12.0,-33.0';
        e.newGeoLocation();
        e.doGeocode = true;
        system.assertEquals( e.doGeocode , true);
        e.geostatus = '201';
        e.newGeoLocation();
        System.assert( bulkGeoCode.jsapi_script != null);
    }
}