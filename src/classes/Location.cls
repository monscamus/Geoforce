public class Location {
	/* this class is needed because the weblink may or may not 
	 * be formatted as required, add some logic to ensure it's valid.
	 */
	public Geo_Location__c geo { get; private set; }
   	public string weblink { get; private set; }
   	public Boolean showWebLink { get; private set; }
   	public Location ( Geo_Location__c g ) { 
   		geo = g; 
   		if ( geo.lat__c == null ) geo.lat__c = 0.0;
   		if ( geo.lon__c == null ) geo.lon__c = 0.0;
   		showWebLink = false; 
   		weblink = 	geo.WebLink__c;
   		if ( weblink != null ) {
	   		if ( ! (weblink.contains('http://') || 
	   		    weblink.contains('https://') )) {
	   			// add the missing protocol so that the web link is valid
	   			weblink = 'http://' + weblink;	
	   		} 
	   		showWebLink = true;
   		}	
   		// system.debug( showWebLink ); system.debug( weblink ) ; 
   		// system.debug( this );
   	}   
}