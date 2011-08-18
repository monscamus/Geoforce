public class oppSetKml {
	
    public ApexPages.StandardSetController setcontroller { get; private set;}   
    
    public oppSetKml(ApexPages.StandardSetController c) {
        setcontroller = c; 
    }
   
    public string kmlstring { get { 
        system.debug( 'kmlstring getFilterId:'+ setcontroller.getFilterId() );
        PageReference pr =  Page.kmlOpportunitySet; 
        pr.getParameters().put('fcf', setcontroller.getFilterId()  );
        return GeoUtils.generateFromContent( pr );
     } 
    }
     
}