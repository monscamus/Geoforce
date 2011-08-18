public class accSetKml {
    public ApexPages.StandardSetController setcontroller { get; private set;} 
    
    public accSetKml(ApexPages.StandardSetController c) {
        setcontroller = c; 
    }
    
    public string kmlstring { get { 
        system.debug( 'kmlstring getFilterId:'+ setcontroller.getFilterId() );
        PageReference pr =  Page.kmlAccountSetStyleBalloon;
        pr.getParameters().put('fcf', setcontroller.getFilterId()  );
        return GeoUtils.generateFromContent( pr );
    } } 
    
}