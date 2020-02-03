public class CAM_OnsiteHardwareRequestForm_Extension {
    private final ApexPages.StandardController controller;
    public Map<String, Decimal> itemQuantity;
    public integer charLmt { get {
            return 55;
        }
        set;
    }
    public String newLine { get {
        newLine = '\n';
        return newLine;
        }
        set;
    }

    public CAM_OnsiteHardwareRequestForm_Extension(ApexPages.StandardController stdController) {
		this.controller = stdController;
        refreshTheRequest();
    }

    public Onsite_Hardware_Request__c theRequest {
        get {
            if (theRequest == null){
                theRequest = (Onsite_Hardware_Request__c)controller.getRecord();
				refreshTheRequest();
            }
            return theRequest;
        }
        set;
    } //theRequest
    
    public void refreshTheRequest() {
        theRequest = [SELECT 
                            Id, Name, CreatedDate, createdby.Name, International_Event__c, Shipment_Handled_by_the_Client__c, Advance_Warehouse__c, 
                            Event_Name__c, Event_Name__r.Name, Event_Name__r.Event_Name__c, Event_Name__r.Project_Manager__c, Status__c,
                            Event_Start_Date__c, Date_Drop_Off__c, Date_Current_Shipment_Date__c, Date_Current_Request_Freeze_Date__c,
                            (SELECT id, name, Requested_Quantity__c, 
                                    Cvent_Asset_Subgroup_Bundle__c, Cvent_Asset_Subgroup_Bundle__r.Cvent_Asset_Bundle__c, Cvent_Asset_Subgroup_Bundle__r.Cvent_Asset_Subgroup__c , 
                                    Cvent_Asset_Subgroup__c, Cvent_Asset_Group__c, Cvent_Asset_Bundle__c
                            FROM Onsite_Hardware_Request_Bundles__r 
                            ORDER BY Cvent_Asset_Subgroup_Bundle__r.Cvent_Asset_Subgroup__r.Cvent_Asset_Group__r.Sort_Order__c, Cvent_Asset_Subgroup_Bundle__r.Cvent_Asset_Subgroup__r.Sort_Order__c),
                            (SELECT id, Name, Cvent_Warehouse__c
                                FROM   Packlists__r)
                        FROM Onsite_Hardware_Request__c 
                        WHERE Id= :theRequest.Id
                    ];


        //populate the quantity values into a Map, for easy access later
        itemQuantity = new Map<String, Decimal>();
        String key;
        for (integer i=0; i<theRequest.Onsite_Hardware_Request_Bundles__r.size(); i++) {
            key = String.valueOf(theRequest.Onsite_Hardware_Request_Bundles__r[i].Cvent_Asset_Subgroup_Bundle__r.Cvent_Asset_Bundle__c) + String.valueOf(theRequest.Onsite_Hardware_Request_Bundles__r[i].Cvent_Asset_Subgroup_Bundle__r.Cvent_Asset_Subgroup__c);
            itemQuantity.put(key, theRequest.Onsite_Hardware_Request_Bundles__r[i].Requested_Quantity__c);
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'itemQuantity set ' + theRequest.Onsite_Hardware_Request_Bundles__r[i].Cvent_Asset_Subgroup_Bundle__r.Cvent_Asset_Bundle__c + ' ' + theRequest.Onsite_Hardware_Request_Bundles__r[i].Requested_Quantity__c));
        }
    }
/*
    public class wrapRequestItem {
        public Cvent_Asset_Subgroup_Bundle__c ab {get; set;}
        public Decimal aq {get; set;}
        public Boolean abMultiItem {get; set;}
        public String abMultiItemDetail {get; set;}
 
        public wrapRequestItem(Cvent_Asset_Subgroup_Bundle__c a) {
            ab = a;
            aq = 0;
            abMultiItem = FALSE;
            abMultiItemDetail = '';
        }

        public wrapRequestItem(Cvent_Asset_Subgroup_Bundle__c a, Decimal q) {
            ab = a;
            aq = q;
            abMultiItem = FALSE;
            abMultiItemDetail = '';
        }
    }//wrapRequestItem
*/
    public String selectedTab { 
        get {
            if (selectedTab == null ){
                selectedTab = catalog[0].grp.id;
            }
            return selectedTab;
        } 
        set; 
    }

    public class requestStatus {
        public String   label       {get; set;}
        public Boolean  completed   {get; set;}
        public Boolean  isActive    {get; set;}
        public Date     dt          {get; set;}
        public String   dsc         {get; set;}

        public requestStatus(String l, Boolean c, Boolean i, Date d, String dd) {
            label       = l;
            completed   = c;
            isActive    = i;
            dt          = d;
            dsc         = dd;
        }
    }

    public List<requestStatus> timeline {
        get {
            timeline = new List<requestStatus>();

            List<String> dsc = new List<String>();
            dsc.add('This request was created by ' + theRequest.createdby.Name + ' on ' + theRequest.CreatedDate);
            dsc.add('This is an estimate.\nBased on the Drop Off Date the PM provided, the Logistics Team expects to finalize this request and create the Packlist on this date.\nPM can make any changes to the request up to that point.\nNo changes will be allowed once the request is finalized.');
            dsc.add('This is an estimate.\nBased on the Drop Off Date the PM provided, the Logistics Team plans to ship to the event on this date.');
            dsc.add('This is entered by the PM and can be changed by updating the Onsite Hardware Request record.');
            dsc.add('This is entered by the PM and can be changed by updating the Event Data record.');

            timeline.add(new requestStatus('Request Created',           TRUE,   FALSE,  theRequest.CreatedDate.date(), dsc[0]));
            timeline.add(new requestStatus('Request Finalized',         FALSE,  FALSE,  theRequest.Date_Current_Request_Freeze_Date__c, dsc[1]));
            timeline.add(new requestStatus('Shipment Goes Out',         FALSE,  FALSE,  theRequest.Date_Current_Shipment_Date__c, dsc[2]));
            timeline.add(new requestStatus('Dropped Off at the Event',  FALSE,  FALSE,  theRequest.Date_Drop_Off__c.date(), dsc[3]));
            timeline.add(new requestStatus('Event Starts',              FALSE,  FALSE,  theRequest.Event_Start_Date__c, dsc[4]));
            
            //set the Completed flags based on the Status of the Request
            if( theRequest.Status__c == 'Finalized' ){
                timeline[1].completed = TRUE;
            } else if ( theRequest.Status__c == 'Being Packed' || theRequest.Status__c == 'Shipped' ){
                timeline[1].completed = TRUE;
                timeline[2].completed = TRUE;
            }

            //set the Completed flags based on the dates of estimates
            if ( Date.today() > theRequest.Event_Start_Date__c ){
                timeline[3].completed = TRUE;
                timeline[4].completed = TRUE;
            } else if ( Date.today() > theRequest.Date_Drop_Off__c ){
                timeline[3].completed = TRUE;
            }

            //Start from the beginning and look for the first incomplete step. Mark that as the Active step, and exit
            for (integer i=0; i < timeline.size(); i++){
                if ( timeline[i].completed == FALSE ){
                    timeline[i].isActive = TRUE;
                    i = timeline.size();
                }
            }

            return timeline;
        }
        set;
    }//timeline

/*
    Public Map<String, Boolean> assetGroupInUse { 
        get {
            assetGroupInUse =  new Map<String, Boolean>();

            //loop through the available groups and populate the map
            //we use the TRUE value by default, as the notification will be hidden based on this value
            for (integer i=0; i<assetGroups.size(); i++){
                assetGroupInUse.put(assetGroups[i].id, TRUE);
            }

            //loop through the assets and change the value to FALSE if there is a quantity on the given asset
            for(integer i=0; i<assets.size(); i++){
                if (assets[i].aq > 0){
                    assetGroupInUse.put(assets[i].ab.Cvent_Asset_Subgroup__r.Cvent_Asset_Group__r.ID, FALSE);
                }
            }
            return assetGroupInUse;
        } //get
        set; 
    }//assetGroupInUse

    public List<Cvent_Asset_Group__c> assetGroups {
        get {
            if (assetGroups == null ){

                String[] assetGroupIDcd = new List<String>();
                for (integer i=0; i<assets.size(); i++){
                    assetGroupIDcd.add(assets[i].ab.Cvent_Asset_Subgroup__r.Cvent_Asset_Group__r.ID);
                }

        		assetGroups = new List<Cvent_Asset_Group__c>();
                assetGroups = [SELECT     Id, Name
                                FROM Cvent_Asset_Group__c 
                                WHERE ID IN :assetGroupIDcd
                                ORDER BY Sort_Order__c
                            ];
                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Asset Groups fetched.: ' + assetGroups.size() ));
            }
            return assetGroups;
        } 
        set;
    }//assetGroups
*/

/* 
    public List<wrapRequestItem> assets {
        get {
            if (assets == null){
				assets = new List<wrapRequestItem>();
        		Cvent_Asset_Subgroup_Bundle__c[] assetList; 
                
                assetList = [SELECT     Id, Name, Cvent_Asset_Subgroup__r.Name, Cvent_Asset_Bundle__c, Cvent_Asset_Bundle__r.Name, 
                                        Cvent_Asset_Subgroup__r.Cvent_Asset_Group__c, Cvent_Asset_Subgroup__r.Cvent_Asset_Group__r.ID, Cvent_Asset_Group__c
                                FROM Cvent_Asset_Subgroup_Bundle__c 
                                ORDER BY Sort_Order__c, Cvent_Asset_Subgroup__r.Cvent_Asset_Group__r.Sort_Order__c, Cvent_Asset_Subgroup__r.Sort_Order__c, Cvent_Asset_Bundle__r.Sort_Order__c
                                LIMIT 50
                            ];

                Decimal q;
                //update the assets list with the existing item quantities
                for (integer i = 0; i < assetList.size(); i++){
                    q = 0;

                    for(integer y = 0; y < theRequest.Onsite_Hardware_Request_Bundles__r.size(); y++){
                        if (theRequest.Onsite_Hardware_Request_Bundles__r[y].Cvent_Asset_Subgroup_Bundle__c == assetList[i].id){
                            q = theRequest.Onsite_Hardware_Request_Bundles__r[y].Requested_Quantity__c;
                            y = theRequest.Onsite_Hardware_Request_Bundles__r.size();
                        }
                    }
                    if (q <> 0){
                        assets.add(new wrapRequestItem(assetList[i], q));
                    } else {
                        assets.add(new wrapRequestItem(assetList[i]));
                    }
                }

                //populate the bundle details to help the user
                Cvent_Asset_Bundle__c[] bundleDetails;
                bundleDetails = [SELECT ID, Name, (SELECT id, Cvent_Asset_Type__c, Cvent_Asset_Type__r.Name, Quantity__c FROM Cvent_Asset_Bundle_Items__r ORDER BY ID)
                                    FROM Cvent_Asset_Bundle__c
                                    WHERE ID IN (SELECT Cvent_Asset_Bundle__c FROM Cvent_Asset_Subgroup_Bundle__c)
                                        AND Count_Bundle_Items__c > 0
                                ];
                
                for (integer i=0; i<bundleDetails.size(); i++) {
                    for (integer x=0; x < assets.size(); x++) {
                        if (assets[x].ab.Cvent_Asset_Bundle__c == bundleDetails[i].id) {
                            assets[x].abMultiItemDetail = 'This bundle includes:\n' + bundleDetails[i].Cvent_Asset_Bundle_Items__r[0].Quantity__c.format() + ' x ' + bundleDetails[i].Cvent_Asset_Bundle_Items__r[0].Cvent_Asset_Type__r.Name + '\n';
                            for (integer y=1; y<bundleDetails[i].Cvent_Asset_Bundle_Items__r.size(); y++){
                                assets[x].abMultiItemDetail = assets[x].abMultiItemDetail + bundleDetails[i].Cvent_Asset_Bundle_Items__r[y].Quantity__c.format() + ' x ' + bundleDetails[i].Cvent_Asset_Bundle_Items__r[y].Cvent_Asset_Type__r.Name + '\n';
                                assets[x].abMultiItem = TRUE;
                            }
                            x = assets.size();
                        }
                    }
                }
                
            }
			return assets;
        }//end of get
        set;
    }//end of assets
*/
    public void removeItem() {
        String itemID = ApexPages.currentPage().getParameters().get('itemID');

        integer currentItem = -1;

        for (integer i=0; i<theRequest.Onsite_Hardware_Request_Bundles__r.size(); i++){
            if (itemID == theRequest.Onsite_Hardware_Request_Bundles__r[i].ID){
                currentItem = i;
            }
        }

        delete theRequest.Onsite_Hardware_Request_Bundles__r[currentItem];
        


        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Item removed'));
        
        //refreshTheRequest();
        theRequest  = null;
        catalog     = null;
        //assets = null;
        //assetGroups = null;

    }//removeItem

    public void addItem() {
        String assetID = ApexPages.currentPage().getParameters().get('assetID');
        String L1index = ApexPages.currentPage().getParameters().get('L1index');
        String L2index = ApexPages.currentPage().getParameters().get('L2index');
        String L3index = ApexPages.currentPage().getParameters().get('L3index');

        Integer L1i = integer.valueOf(L1index);
        Integer L2i = integer.valueOf(L2index);
        Integer L3i = integer.valueOf(L3index);

        Boolean okToSubmit = TRUE;
        if (catalog[L3i].lst[L2i].lst[L1i].qty <= 0 ) {
            okToSubmit = FALSE;
        }

        if (okToSubmit){
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Asset qty: ' + catalog[L3i].lst[L2i].lst[L1i].qty));

            
            //create the new empty object
            Onsite_Hardware_Request_Bundle__c newBundle = new Onsite_Hardware_Request_Bundle__c();
            
            //populate the fields
            newBundle.Onsite_Hardware_Request__c        = theRequest.Id;
            newBundle.Requested_Quantity__c             = catalog[L3i].lst[L2i].lst[L1i].qty;
            newBundle.Cvent_Asset_Subgroup_Bundle__c    = catalog[L3i].lst[L2i].lst[L1i].asset.ID;

                    
            //save
            insert newBundle;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Item added'));

            Cvent_Asset_Bundle_Item__c[] bundleItems;
            bundleItems = [ SELECT id, Name, Quantity__c, Cvent_Asset_Type__c
                            FROM Cvent_Asset_Bundle_Item__c
                            WHERE Cvent_Asset_Bundle__c = :catalog[L3i].lst[L2i].lst[L1i].asset.Cvent_Asset_Bundle__c
                            ];


            for (integer i=0; i<bundleItems.size(); i++){
                Onsite_Hardware_Request_Item__c newItem = new Onsite_Hardware_Request_Item__c();
                
                newItem.Onsite_Hardware_Request_Bundle__c   = newBundle.ID;
                newItem.Onsite_Hardware_Request__c          = theRequest.Id;
                newItem.Requested_Quantity__c               = (newBundle.Requested_Quantity__c * bundleItems[i].Quantity__c).round(System.RoundingMode.CEILING);
                newItem.Cvent_Asset_Type__c                 = bundleItems[i].Cvent_Asset_Type__c;

                insert newItem;
                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'New item created'));
            }

            theRequest  = null;
            catalog     = null;
            //assets = null;
            //assetGroups = null;
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please enter a positive number as quantity and re-submit'));
        }//okToSubmit


    }//addItem

    public void updateItem() {
        String assetID = ApexPages.currentPage().getParameters().get('assetID');

        String L1index = ApexPages.currentPage().getParameters().get('L1index');
        String L2index = ApexPages.currentPage().getParameters().get('L2index');
        String L3index = ApexPages.currentPage().getParameters().get('L3index');

        Integer L1i = integer.valueOf(L1index);
        Integer L2i = integer.valueOf(L2index);
        Integer L3i = integer.valueOf(L3index);

        Boolean okToSubmit = TRUE;
        if (catalog[L3i].lst[L2i].lst[L1i].qty <= 0 ) {
            okToSubmit = FALSE;
        }


        if (okToSubmit) {
            //fetch the object
            Onsite_Hardware_Request_Bundle__c existingBundle;

            existingBundle = [SELECT    id, name, Requested_Quantity__c, 
                                        (SELECT id, Name, Requested_Quantity__c FROM Onsite_Hardware_Request_Items__r)
                                FROM    Onsite_Hardware_Request_Bundle__c
                                WHERE   Cvent_Asset_Subgroup_Bundle__c = :catalog[L3i].lst[L2i].lst[L1i].asset.ID
                                        AND Onsite_Hardware_Request__c = :theRequest.Id
                            ];

            //populate the field
            existingBundle.Requested_Quantity__c = catalog[L3i].lst[L2i].lst[L1i].qty;
                    
            //save
            update existingBundle;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Item updated'));

            for (integer i=0; i<existingBundle.Onsite_Hardware_Request_Items__r.size(); i++){
                delete existingBundle.Onsite_Hardware_Request_Items__r[i];
                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Deleted existing items'));
            }


            Cvent_Asset_Bundle_Item__c[] bundleItems;
            bundleItems = [ SELECT id, Name, Quantity__c, Cvent_Asset_Type__c
                            FROM Cvent_Asset_Bundle_Item__c
                            WHERE Cvent_Asset_Bundle__c = :catalog[L3i].lst[L2i].lst[L1i].asset.Cvent_Asset_Bundle__c
                            ];


            for (integer i=0; i<bundleItems.size(); i++){
                Onsite_Hardware_Request_Item__c newItem = new Onsite_Hardware_Request_Item__c();
                
                newItem.Onsite_Hardware_Request_Bundle__c   = existingBundle.ID;
                newItem.Onsite_Hardware_Request__c          = theRequest.Id;
                newItem.Requested_Quantity__c               = (existingBundle.Requested_Quantity__c * bundleItems[i].Quantity__c).round(System.RoundingMode.CEILING);
                newItem.Cvent_Asset_Type__c                 = bundleItems[i].Cvent_Asset_Type__c;

                insert newItem;
                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Create new item ' + newItem.ID));
            }

            theRequest  = null;
            catalog     = null;
            //assets = null;
            //assetGroups = null;
        }  else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please enter a positive number as quantity and re-submit'));
        }//okToSubmit

    }//updateItem






    public class w_CASB {
        public Cvent_Asset_Subgroup_Bundle__c   asset {get; set;}
        public integer                          c {get; set;}
        public Decimal                          qty {get; set;}
        public Boolean                          multi {get; set;}
        public String                           multi_desc {get; set;}
 
        public w_CASB(Cvent_Asset_Subgroup_Bundle__c a, integer cc, Decimal q) {
            asset       = a;
            c           = cc;
            qty         = q;
            multi       = FALSE;
            multi_desc  = '';
        }

        public w_CASB(Cvent_Asset_Subgroup_Bundle__c a, integer cc, Decimal q, Boolean m, String md) {
            asset       = a;
            c           = cc;
            qty         = q;
            multi       = m;
            multi_desc  = md;
        }
    }//LEVEL 1 w_CASB

    public class w_CASB_S {
        public List<w_CASB>             lst {get; set;}
        public Cvent_Asset_Subgroup__c  subgrp {get; set;}
        public integer                  c {get; set;}

        public w_CASB_S(List<w_CASB> l, Cvent_Asset_Subgroup__c s, integer cc){
            lst     = l;
            subgrp  = s;
            c       = cc;
        }
    }//LEVEL 2 w_CASB_S

    public class w_CASB_S_G {
        public List<w_CASB_S>       lst {get; set;}
        public Cvent_Asset_Group__c grp {get; set;}
        public integer              c {get; set;}
        public Boolean              inUse {get; set;}

        public w_CASB_S_G(List<w_CASB_S> l, Cvent_Asset_Group__c g, integer cc, Boolean b){
            lst     = l;
            grp     = g;
            c       = cc;
            inUse   = b;
        }
    }//LEVEL 3 w_CASB_S_G



    public List<w_CASB_S_G> catalog {
        get {
            if (catalog == null){
        		Cvent_Asset_Subgroup_Bundle__c[]    L1;
                Cvent_Asset_Subgroup__c[]           L2;
                Cvent_Asset_Group__c[]              L3;
                catalog = new List<w_CASB_S_G>();

                //need to start populating the list from the inner most level
                //first, we gather the list of all assets, subgroups and groups
                //then, we start populating them into the lists (L3, L2, L1)


                //populate assets
                L1 = [SELECT     Id, Name, Cvent_Asset_Subgroup__c, Cvent_Asset_Subgroup__r.Name, Cvent_Asset_Bundle__c, Cvent_Asset_Bundle__r.Name, 
                                        Cvent_Asset_Subgroup__r.Cvent_Asset_Group__c, Cvent_Asset_Subgroup__r.Cvent_Asset_Group__r.ID, Cvent_Asset_Group__c
                                FROM Cvent_Asset_Subgroup_Bundle__c 
                                ORDER BY Sort_Order__c, Cvent_Asset_Subgroup__r.Cvent_Asset_Group__r.Sort_Order__c, Cvent_Asset_Subgroup__r.Sort_Order__c, Cvent_Asset_Bundle__r.Sort_Order__c
                                //LIMIT 1000
                            ];

                //populate subgroup IDs of the assets
                String[] L1_ID = new List<String>();
                for (integer i1=0; i1<L1.size(); i1++){
                    L1_ID.add(L1[i1].Cvent_Asset_Subgroup__c);
                }

                //populate subgroups by using the subgroup IDs from assets
                L2 = [SELECT     Id, Name, Cvent_Asset_Group__c
                                FROM Cvent_Asset_Subgroup__c 
                                WHERE ID IN :L1_ID
                            ];

                //populate group IDs of the subgroups
                String[] L2_ID = new List<String>();
                for (integer i2=0; i2<L2.size(); i2++){
                    L2_ID.add(L2[i2].Cvent_Asset_Group__c);
                }

                //populate groups by using the group IDs from subgroups
                L3 = [SELECT     Id, Name
                                FROM Cvent_Asset_Group__c 
                                WHERE Id IN :L2_ID
                            ];


                //populate the bundle item details into a Map, for easy access later
                Cvent_Asset_Bundle__c[] bundleDetails;
                bundleDetails = [SELECT ID, Name, (SELECT id, Cvent_Asset_Type__c, Cvent_Asset_Type__r.Name, Quantity__c FROM Cvent_Asset_Bundle_Items__r ORDER BY ID)
                                FROM Cvent_Asset_Bundle__c
                                WHERE ID IN (SELECT Cvent_Asset_Bundle__c FROM Cvent_Asset_Subgroup_Bundle__c)
                                AND Count_Bundle_Items__c > 0
                                ];
                Map<String, String> bundles = new Map<String, String>();
                for (integer i=0; i<bundleDetails.size(); i++) {
                    String s = 'This bundle includes:\n' + bundleDetails[i].Cvent_Asset_Bundle_Items__r[0].Quantity__c.format() + ' x ' + bundleDetails[i].Cvent_Asset_Bundle_Items__r[0].Cvent_Asset_Type__r.Name + '\n';
                    for (integer y=1; y<bundleDetails[i].Cvent_Asset_Bundle_Items__r.size(); y++){
                        s = s + bundleDetails[i].Cvent_Asset_Bundle_Items__r[y].Quantity__c.format() + ' x ' + bundleDetails[i].Cvent_Asset_Bundle_Items__r[y].Cvent_Asset_Type__r.Name + '\n';
                    }
                    if (bundleDetails[i].Cvent_Asset_Bundle_Items__r.size()>1){
                        bundles.put(bundleDetails[i].id, s);
                    }
                }

                /*
                Boolean[] inUse = new List<Boolean>();
                for (integer i=0; i<L3.size(); i++){
                    inUse.add(FALSE);
                }
                */

                //main loop to populate the catalog
                for (integer i3=0; i3<L3.size(); i3++){
                    Cvent_Asset_Group__c grp = L3[i3];
                    List<w_CASB_S> l_asset_subgrp = new List<w_CASB_S>();
                    Boolean inUse = FALSE;

                    for (integer i2=0; i2<L2.size(); i2++){
                        Cvent_Asset_Subgroup__c  subgrp = L2[i2];
                        List<w_CASB> l_asset = new List<w_CASB>();

                        if (L2[i2].Cvent_Asset_Group__c == grp.ID){

                            for (integer i1=0; i1<L1.size(); i1++){
                                Cvent_Asset_Subgroup_Bundle__c asset = L1[i1];

                                if(L1[i1].Cvent_Asset_Subgroup__c == subgrp.ID){
                                    //assets are put in a list
                                    //there are two additional values we set against an asset: quantity and bundle details
                                    //Bundle details: they are stored in a Map for easy access. Below, we check against that Map, and use the values.
                                    //Quantity: when the theRequest is being populated, the quantity values are put in a Map. they are pulled below.

                                    Decimal q = 0;
                                    String s = String.valueOf(L1[i1].Cvent_Asset_Bundle__c) + String.valueOf(subgrp.ID);
                                    if( itemQuantity.containsKey(s) ){
                                        q = itemQuantity.get(s);
                                        inUse = TRUE;
                                        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Quantity exists' + q));
                                    }

                                    if( bundles.containsKey(L1[i1].Cvent_Asset_Bundle__c) ){
                                        l_asset.add(new w_CASB(asset, l_asset.size(), q, TRUE, bundles.get(L1[i1].Cvent_Asset_Bundle__c)));
                                    } else {
                                        l_asset.add(new w_CASB(asset, l_asset.size(), q));
                                    }
                                }
                            }//L1

                            //subgroups and their assets are put in a list
                            l_asset_subgrp.add(new w_CASB_S(l_asset, subgrp, l_asset_subgrp.size()));
                        }
                    }//L2

                    //groups, subgroups and their assets are put in a list
                    catalog.add(new w_CASB_S_G(l_asset_subgrp, grp, catalog.size(), inUse));
                    //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Group added. inUse: ' + inUse + ' group: ' + grp.Name));
                }//L3
            }



            return catalog;
        }
        set;
    }//catalog




}