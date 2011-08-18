/*
Copyright (c) 2008 salesforce.com, inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

public class LocationsExt {
 
    /* this is designed to work with any standard or custom object 
     * that is related to geo_location__c with a lookup field
     * this controller assumes it is an extension to a set controller
     */
    public List<Location> geolocations { get; private set; } 
    
    public integer mappedLocationsCount { get {return geolocations.size(); }}
    
    public string location { get; set; } // used to hold the location after a user clicks, bound to earth component
    
    public ApexPages.StandardSetController setcontroller { get; private set;} 
    
    GeoPrefCon Prefs = new GeoPrefCon(); // save and read user preferences
    public string selectedTable { get ;set;}
        
    public LocationsExt(ApexPages.StandardSetController c) {
        setcontroller = c; 
        
        if ( Prefs.object_selected != null ) {
            selectedTable = Prefs.object_selected;
        }

        // use the filter id passed in if possible.
        string fcf = ApexPages.currentPage().getParameters().get('fcf');
        system.debug( 'set controller ' + fcf);

        if ( fcf != null ) {
            setcontroller.setFilterId( fcf ); 
        } else { 
            if ( Prefs.filter_selected != null ) {
                 setcontroller.setFilterId( Prefs.filter_selected );
            }
        }
 
        geolocations = new list<Location>();
        initGeoList(); 
    } 
    /* gacks ???
    public List<SelectOption> getSortedListViewOptions() {
        List<SelectOption> options = new List<SelectOption>();
        // sort the controller listviewoptions list.
        for ( SelectOption o : setcontroller.getlistviewoptions() ) {
            addOption(options, o);
        }
        return options;
    }   
    
    private void addOption( SelectOption[] options, SelectOption newOpt) {
        Integer position = options.size();
        for (Integer i = 0; i < options.size(); i++) {
            if (newOpt.getLabel() < options[i].getLabel()) {
                position = i;
                break;
            }
        }
        
        if (position == options.size()) {
            options.add(newOpt);
        } else {
            options.add(position, newOpt);
        }
    }    */
    
    public PageReference initGeoList() { 
        setcontroller.setPageSize( 250 ); // largest we can do ?
        setcontroller.first(); 
        
        List<sobject> sl = setcontroller.getRecords();
        geolocations.clear();
        if (sl.size() < 1) return null;
            
        // get object type as a string
        string object_type = getSObjectTypeName( sl[0] );
        
        // system.debug( 'object type :'+ object_type);     system.debug( 'found records :'+ sl.size() );
        
        // list the object id's provided by the set controller,
        // any type will do as long as it has Geo_Location__c lookup
        list<id> recordids = new list<id>();  
           
        for ( sobject a: sl) {  recordids.add( (id) a.get('id') );  } 
        
        //system.debug( 'found ids :'+ ids);
        
        // get a list of locations
        if ( recordids.size() < 1 ) return null;
         
        List<sObject> L = Database.query(
            ' select id,geo_location__c from '+
            object_type + ' where id in ('+ 
            joinstr(recordids)+  ')'  );
    
        //system.debug( L );
        list<id> locationids = new list<id>();  
        
        for ( sobject a:  L )  { 
            id geol = (id) a.get('Geo_Location__c');
            if (geol != null ) 
                locationids.add( geol ); 
        }
        
        system.debug( 'initGeoList list size '+locationids.size()); 
        //system.debug( 'initGeoList id ' +ids );
        
        
        for ( Geo_Location__c gg: [Select g.lon__c, g.lat__c, g.WebLink__c, 
            g.WebLinkName__c, g.SystemModstamp, g.PhotoURL__c, 
            g.PhotoTitle__c, g.PhotoCaption__c, g.OwnerId, g.Name, 
            g.LogoURL__c, g.LastModifiedDate, g.LastModifiedById, 
            g.IsDeleted, g.Id, g.Icon_URL__c, g.Geocode_Status__c, 
            g.Footer__c, g.CreatedDate, g.CreatedById, g.About_Us__c , g.Balloon_Template__c
            From Geo_Location__c g 
            where g.Geocode_Status__c = 'G_GEO_SUCCESS' and id in :locationids ] ) {
                geolocations.add( new Location(gg) );
        }
        //system.debug( geolocations );
       
        // enable this button again
        exportDisabled = false;
        return null;
    }
     
    private string joinstr( list<id> ids) { 
        string ret = '';
        if ( ids.size() < 1 ) return '';
        for ( id t: ids) { ret += '\'' + t +'\',' ;}
        ret = ret.substring( 0, ret.length()-1 );
        return ret; 
    }
    
    private string getSObjectTypeName( sobject so ) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        
        for ( String ot : gd.keyset() ) {
            // system.debug( ot + ' : ' + gd.get( ot) );
            if ( gd.get( ot)  == so.getSobjectType() ) {
                // system.debug( 'getSObjectTypeName is '+ot); 
                return ot;
            }   
        } 
        return null;
    }
    
    public Location firstRecord { 
      get{ 
        if ( geolocations.size() == 0 ) {
            return new Location( 
                new Geo_Location__c( lat__c= 0.0,lon__c=0.0 , name='no account found')
                );
        }
        return geolocations[0];     
      } 
    }
    
    public  List<SelectOption> getItems() { return Prefs.getItems(); }
  
    public PageReference changedFilter() { 
        system.debug( ' changedFilter ' + setcontroller.getfilterId());
        Prefs.filter_selected = setcontroller.getfilterId();
        Prefs.saveFilter();
        exportDisabled = true;
        
        // go there now
        PageReference p = new PageReference( Prefs.object_selected + 
            '?fcf=' + setcontroller.getfilterId());
        p.setRedirect(true);
        return p;
        
    }
    public Boolean exportDisabled { get; private set; } { exportDisabled = false; }
    
    public PageReference redirect() {
        PageReference o = Page.GoogleEarthOpps;  // references to pull these into package
        PageReference a = Page.GoogleEarthAccounts; 
        
        // jump to the prefered page, default is provided for us by Prefs
        String prefUrl = Prefs.object_selected;
        PageReference p = new PageReference( prefUrl);
        p.setRedirect(true);
        return p;
    }
    public LocationsExt() {} // used by the rediect page GeoEarthTab
    
    // TEST METHODS 
    public static testmethod void test_geo() { 
        
        List<account> accountList = [SELECT name FROM Account LIMIT 2];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(accountList);
        
        LocationsExt g = new LocationsExt( ssc );
        g.changedFilter();
        system.assert( g.firstRecord != null );
        system.assert( g.getItems() != null );
        system.assert( g.redirect() != null );
    }
}