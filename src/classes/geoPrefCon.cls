public class geoPrefCon {
    /* 
        Store and retrieve a page and filter preference 
    */
    public string object_selected { get; set; } 
    public string filter_selected { get; set; }
    public void saveFilter() { 
     Geo_Pref__c gp = getDefaultPref();
     gp.filter_id__c = filter_selected;
     upsert gp Key_Index__c;  
    }
    public geoPrefCon() { 
        Geo_Pref__c gp = getDefaultPref();
        object_selected = gp.Name;
        filter_selected = gp.Filter_Id__c; 
        }
    
    public PageReference savePref() {
        Geo_Pref__c gp = getDefaultPref();
        system.debug( gp );
        if ( gp.Name != object_selected ) {
            gp.Default__c = false; 
            upsert gp Key_Index__c;  // turn off old one
        
            gp = getPageByName( object_selected );
            gp.Default__c = true; 
            upsert gp Key_Index__c;  // turn on new one
        }   
        return null;
    }
        
    private Geo_Pref__c getDefaultPref( ) {  
        Geo_Pref__c  ret;
        try {  // run a query to see if there is a default already
         ret = [Select g.Name, g.Default__c, g.Key_Index__c, g.OwnerId, g.Filter_ID__c 
            From Geo_Pref__c g where g.Default__c = true AND            
                    g.OwnerId = :UserInfo.getUserId() limit 1];
        } catch (System.Queryexception q) {
            // no default, create one now
            ret = new Geo_Pref__c ( name= '/apex/GoogleEarthAccounts',
                key_index__c = UserInfo.getUserId()+'/apex/GoogleEarthAccounts',
                Default__c = true );
        }
        return ret;
    }

    private Geo_Pref__c getPageByName( string pName ) {  
        Geo_Pref__c  ret;
        try {  // run a query to see if there is a default already
         ret = [Select g.Name, g.Default__c, g.Key_Index__c, g.OwnerId, g.Filter_ID__c  From Geo_Pref__c g 
            where g.Name = :pName 
            AND     g.OwnerId = :UserInfo.getUserId() 
            limit 1];
        } catch (System.Queryexception q) {
            // no page by this name, create one now
            ret = new Geo_Pref__c ( name= pName,
                key_index__c = UserInfo.getUserId()+pName,
                Default__c = true );
        }
        return ret;
    }
    
    public static testmethod void t1() {
        
         Profile p = [select id from profile where name='Standard User'];
          
         User u = [select id,alias,email, lastname, profileid, username from user where isactive = true limit 1 ];// random user
         
         u.alias = 'standt';
         u.email='standarduser@testorg.com';
         u.emailencodingkey='UTF-8';
         u.lastname='Testing'; 
         u.languagelocalekey='en_US'; 
         u.localesidkey='en_US';
         u.profileid = p.Id;
         u.timezonesidkey='America/Los_Angeles'; 
         u.username='standarduser@testorg.com';

		/* causes some test problems on systems that don't have any more users?
         System.runAs(u) {
             // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
                        
            geoprefcon g=new geoprefcon();
            
            system.assertEquals('/apex/GoogleEarthAccounts', g.object_selected, 'default ');
            
            g.object_selected = '/apex/GoogleEarthOpps';
            g.savePref();
            system.assertEquals('/apex/GoogleEarthOpps', g.object_selected, 'default 2');
            
            system.assert( g.getItems().size() > 0);        
          
        }
        */
    }
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('/apex/GoogleEarthAccounts','Accounts'));
        options.add(new SelectOption('/apex/GoogleEarthOpps','Opportunity'));
        return options;
    }

}