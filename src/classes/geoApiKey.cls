/* 
 * Sign up for a key at this location: 
 * http://code.google.com/apis/maps/signup.html
 * place the in this file
 * the forcekey should specify *.force.com as the domain for any visualforce pages
 * the key should specify *.salesforce.com for geocode requests that start on the server
 */

public class geoApiKey {
	public geoApiKey() {}
	public geoApiKey(ApexPages.StandardController c) {}
	public geoApiKey(ApexPages.StandardSetController c) {}
	
	// salesforce key
	private static string k  = 'ABQIAAAAztVBfkQpR0ADsDMoBIuFHhQdMY-rqcBK7mOLf4exckLw5w98-BTuHDgP6ooNF9j0bKgAnsA_OsN7HQ';
	private static string client = 'client=gme-salesforcefoundation';
	// *.salesforce.com 
    public string key 		{ get { return k; }}
    // *.force.com 
    public string forcekey 	{ get { return k; }}
 	
 	public static string jsapi_script { 
 		get { return 'http://www.google.com/jsapi?' +client + '&key=' + k; }}
 	public static string maps_script { 
 		get { return 'http://maps.google.com/maps?file=api&v=2&' +client; }}
 	
 	public static testmethod void t1() { 
 		geoApiKey g = new geoApiKey(); 
 		system.assert( g.key != null );
 		system.assert( g.forcekey != null );
 		ApexPages.StandardController sc = new ApexPages.StandardController(new Account());
 		g = new geoApiKey( sc);
 		
 		insert new Account( name='foo'); 
 		List<account> accountList = [SELECT name FROM Account LIMIT 1];
		ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(accountList);
		g = new geoApiKey( ssc); 
 	}
}