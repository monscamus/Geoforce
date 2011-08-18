public class GeoPreview {
    // single location
    public string previewKMLString { get { 
        // generate the kml from a VF page
        PageReference pr = Page.kmlPreviewTemplate;
        pr.getParameters().put('id', this.controller.getRecord().id );
        string ret = GeoUtils.generateFromContent( pr );
        system.debug( ' previewKMLString ' + ret);
        return ret;    
    }}     
     
    public string location { get; set; } 
    /* used by display a single ( preview ) of a location 
     * return a single location class, given the controller record id 
     */
    public Location getPreviewLocation() {  
        return new Location(    [ 
            select id, Icon_URL__c,  
            Footer__c, about_us__c, name, lat__c, lon__c , 
            PhotoCaption__c, PhotoURL__c, photoTitle__c,Balloon_Template__c,
            WebLink__c,WebLinkName__c from Geo_Location__c where id = :controller.getRecord().id limit 1] 
        );
    }

    public GeoPreview(ApexPages.StandardController c) {
        controller = c; 
    }    
    
    private ApexPages.StandardController controller; 
    
 	public static testmethod void test_1() { 
 		PageReference pageRef = Page.GeoPreview;
        Test.setCurrentPage(pageRef);

   	 	Geo_Location__c ggg = new  Geo_Location__c(name='foo');
   	 	insert ggg;
   	 	ApexPages.StandardController sc = 
   	 		new ApexPages.StandardController(ggg);
 		
 		GeoPreview gp = new GeoPreview( sc );	
 		Location l = gp.getPreviewLocation();
 		system.assert( l != null) ;
 		
 		System.assert( gp.previewKMLString != null );
 	}
 	
 	public static testmethod void test_2() {
 		List<Opportunity> ol = [SELECT name FROM Opportunity LIMIT 2];
        ApexPages.StandardSetController ssc = 
        	new ApexPages.StandardSetController(ol);
        
        oppSetKml osk = new oppSetKml( ssc );
  		System.assert( osk.kmlstring != null);
 	} 

 	public static testmethod void test_3() {
 		List<Account> ol = [SELECT name FROM Account LIMIT 2];
        ApexPages.StandardSetController ssc = 
        	new ApexPages.StandardSetController(ol);
        
        accSetKml osk = new accSetKml( ssc );
  		System.assert( osk.kmlstring != null);
 	} 
 	
 	
}