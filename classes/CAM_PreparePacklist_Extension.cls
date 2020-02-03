public with sharing class CAM_PreparePacklist_Extension {
    private final ApexPages.StandardSetController controller;
    public String pageID { get; set; }
    public Boolean packlistExists { get; set; }
    List<Cvent_Warehouse__c> wList;
    private String doNotShipText = '-- EXCLUDE FROM SHIPMENT --';
    private String doNotShipId = '-9999';
    public String newLine { get {
        newLine = '\n';
        return newLine;
        }
        set;
    }
    //public Decimal emre { get; set; }

    Map<String, String> warehouseListwithNames = new Map<String, String>();

    public CAM_PreparePacklist_Extension(ApexPages.StandardSetController stdController) {
		this.controller = stdController;
        pageID = apexpages.currentpage().getparameters().get('id');

        //List<CAM_Settings__c> mcs = CAM_Settings__c.getall().values();
        //emre = mcs[0].No_of_Weeks__c;
        //Map<String_dataset_name, CustomSettingName__c> mcs = CustomSettingName__c.getAll();
        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'setting is: '+ emre));

    }//constructor

    public List<Onsite_Hardware_Request_Item__c> items {
        get {
            if (items == null){
                items = (List<Onsite_Hardware_Request_Item__c>)controller.getSelected();
				refreshItems();
                //List<w_ReqItem> it = itemsAndWarehouse();
            }
            return items;
        }
        set;
    } //items

    public void refreshItems() {
        items = [SELECT 
                        Id, Name, Requested_Quantity__c, Packlist_Quantity__c, Packlist__c, Packlist__r.Name, 
                        Cvent_Asset_Group__c, Cvent_Asset_Subgroup__c, Cvent_Asset_Type__c, Cvent_Asset_Type__r.Name,
                        Onsite_Hardware_Request_Bundle__c, Onsite_Hardware_Request_Bundle__r.Cvent_Asset_Bundle__c 
                    FROM Onsite_Hardware_Request_Item__c 
                    WHERE Onsite_Hardware_Request_Bundle__r.Onsite_Hardware_Request__c = :pageID 
                    ORDER BY Cvent_Asset_Type__c, Cvent_Asset_Group__c, Cvent_Asset_Subgroup__c];
        
        if (items <> null) {
            listofAssetTypes = new String[0];
            
            //add the first Asset Type to the list
            listofAssetTypes.add(items[0].Cvent_Asset_Type__r.Name);
            
            //start the loop from the second item in the list
            for (integer i = 1; i < items.size(); i++){
                if ( items[i].Cvent_Asset_Type__r.Name <> items[i-1].Cvent_Asset_Type__r.Name) {
                    listofAssetTypes.add(items[i].Cvent_Asset_Type__r.Name);
                }
            }
        }
    }//refreshItems

    public Onsite_Hardware_Request__c theRequest {
        get {
            if (theRequest == null){
				refreshTheRequest();
            }
            return theRequest;
        }
        set;
    } //theRequest
    
    public void refreshTheRequest() {
        theRequest = [SELECT 
                            Id, Name, International_Event__c, Country__c, Shipment_Handled_by_the_Client__c, Advance_Warehouse__c, 
                            Event_Name__r.Event_Name__c, Event_Name__r.Name,Event_Name__r.Project_Manager__c,
                            Event_Start_Date__c, Date_Drop_Off__c, Date_Current_Shipment_Date__c, Date_Current_Request_Freeze_Date__c,
                            (SELECT id, name, Requested_Quantity__c, Cvent_Asset_Subgroup_Bundle__c, Cvent_Asset_Subgroup__c, Cvent_Asset_Group__c, Cvent_Asset_Bundle__c
                            FROM Onsite_Hardware_Request_Bundles__r ),
                            (SELECT id, Name, Cvent_Warehouse__c
                                FROM   Packlists__r)
                        FROM Onsite_Hardware_Request__c 
                        WHERE Id= :pageID
                    ];
    }//refreshTheRequest

    public String[] listofAssetTypes { get {
        if (listofAssetTypes == null) {
            refreshItems();
        }
        return listofAssetTypes;
    	} 
		set; 
	}//listofAssetTypes

    public class w_ReqItem {
        public Onsite_Hardware_Request_Item__c  reqItem {get; set;}
        public String                           warehouse {get; set;}
        public integer                          c {get; set;}
 
        public w_ReqItem(Onsite_Hardware_Request_Item__c i, String w, integer ic) {
            reqItem     = i;
            warehouse   = w;
            c           = ic;
        }
        
		public w_ReqItem(Onsite_Hardware_Request_Item__c i, integer ic) {
            reqItem     = i;
            warehouse   = null;
            c           = ic;
        }
    }//w_ReqItem

    public class w_ReqItem_AT {
        public List<w_ReqItem>      lst {get; set;}
        public Cvent_Asset_Type__c  assetType {get; set;}
        public integer              c {get; set;}
        public Decimal              totalQty {get; set;}
 
        public w_ReqItem_AT(List<w_ReqItem> l, Cvent_Asset_Type__c aa, integer ic, Decimal t) {
            lst         = l;
            assetType   = aa;
            c           = ic;
            totalQty    = t;
        }
    }//w_ReqItem_AT

    public List<w_ReqItem_AT> assets {
        get {
            if (assets == null ){
                assets = new List<w_ReqItem_AT>();
        		Onsite_Hardware_Request_Item__c[]   L1; 
                Cvent_Asset_Type__c[]               L2;
                
                L1 = [SELECT 
                            Id, Name, Requested_Quantity__c, Packlist_Quantity__c, Packlist__c, Packlist__r.Name, 
                            Packlist__r.Cvent_Warehouse__c, Packlist__r.Cvent_Warehouse__r.Name, Packlist__r.Cvent_Warehouse__r.Country__c,
                            Cvent_Asset_Group__c, Cvent_Asset_Subgroup__c, Cvent_Asset_Type__c, Cvent_Asset_Type__r.Name,
                            Onsite_Hardware_Request_Bundle__c, Onsite_Hardware_Request_Bundle__r.Cvent_Asset_Bundle__c 
                        FROM Onsite_Hardware_Request_Item__c 
                        WHERE Onsite_Hardware_Request_Bundle__r.Onsite_Hardware_Request__c = :pageID 
                        ORDER BY Cvent_Asset_Type__r.Sort_Order__c, Onsite_Hardware_Request_Bundle__r.Cvent_Asset_Subgroup_Bundle__r.Cvent_Asset_Subgroup__r.Cvent_Asset_Group__r.Sort_Order__c, Onsite_Hardware_Request_Bundle__r.Cvent_Asset_Subgroup_Bundle__r.Cvent_Asset_Subgroup__r.Sort_Order__c
                    ];

                String[] L1_ID = new List<String>();
                for (integer i1=0; i1<L1.size(); i1++){
                    L1_ID.add(L1[i1].Cvent_Asset_Type__c);
                }

                //populate subgroups by using the subgroup IDs from assets
                L2 = [SELECT     Id, Name
                                FROM Cvent_Asset_Type__c 
                                WHERE ID IN :L1_ID
                            ];

                //main loop to populate the catalog
                for (integer i2=0; i2<L2.size(); i2++){
                    Cvent_Asset_Type__c atype   = L2[i2];
                    List<w_ReqItem> l_asset     = new List<w_ReqItem>();
                    Decimal totalQty            = 0;

                        for (integer i1=0; i1<L1.size(); i1++){
                            Onsite_Hardware_Request_Item__c asset = L1[i1];

                            if(L1[i1].Cvent_Asset_Type__c == atype.ID){
                                asset.Packlist_Quantity__c = asset.Requested_Quantity__c;
                                l_asset.add(new w_ReqItem(asset, L1[i1].Packlist__r.Cvent_Warehouse__c, l_asset.size()));
                                if ( L1[i1].Packlist__c <> null) {
                                    packlistExists = TRUE;
                                }
                                totalQty = totalQty + asset.Requested_Quantity__c;
                            }
                        }//L1

                        assets.add(new w_ReqItem_AT(l_asset, atype, assets.size(), totalQty));
                }//L2

            }//null check
            return assets;
        }
        set;
    }

/*
    public List<w_ReqItem> itemsAndWarehouse {
        get {
            if (itemsAndWarehouse == null){
				itemsAndWarehouse = new List<w_ReqItem>();
        		Onsite_Hardware_Request_Item__c[] itemList; 
                
                itemList = [SELECT 
                                    Id, Name, Requested_Quantity__c, Packlist_Quantity__c, Packlist__c, Packlist__r.Name, 
                                    Cvent_Asset_Group__c, Cvent_Asset_Subgroup__c, Cvent_Asset_Type__c, Cvent_Asset_Type__r.Name,
                                    Onsite_Hardware_Request_Bundle__c, Onsite_Hardware_Request_Bundle__r.Cvent_Asset_Bundle__c 
                                FROM Onsite_Hardware_Request_Item__c 
                                WHERE Onsite_Hardware_Request_Bundle__r.Onsite_Hardware_Request__c = :pageID 
                                ORDER BY Cvent_Asset_Type__c, Cvent_Asset_Group__c, Cvent_Asset_Subgroup__c
                            ];

                //check if the items have been added to a packlist already or not. 
                for (integer i = 0; i < itemList.size(); i++){
                    if (itemList[i].Packlist__c <> null){
                        Packlist__c p = new Packlist__c();
                        p = [SELECT ID, Name, Cvent_Warehouse__c FROM Packlist__c WHERE id=:itemList[i].Packlist__c];
                        itemsAndWarehouse.add(new w_ReqItem(itemList[i], p.Cvent_Warehouse__c, 0));
                        packlistExists = true;
                    } else {
						itemsAndWarehouse.add(new w_ReqItem(itemList[i], 0));   
                    }

                    //set all items' Packlist Quantity to the Packlist Quantity. This way the default value will be the requested quantity and user has to verify that before deciding not to ship any assets
                    itemList[i].Packlist_Quantity__c = itemList[i].Requested_Quantity__c;
                }
            }
			return itemsAndWarehouse;
        }//get
        set;
    }//itemsAndWarehouse
*/
    public List<SelectOption> getWarehouses() {
        List<SelectOption> options = new List<SelectOption>();
        wList = new List<Cvent_Warehouse__c>();
        
        //add the default option
        options.add(new SelectOption('', '-- Select One --'));
        wList = [SELECT ID, Name, Country__c FROM Cvent_Warehouse__c ORDER BY Name ASC];
        
        for (integer i = 0; i < wList.size(); i++) {
            options.add(new SelectOption(wList[i].ID, wList[i].Name));
            warehouseListwithNames.put(wList[i].ID, wList[i].Name);
        }

        //add the EXCLUDE FROM SHIPMENT as the last option. Want the user to select it deliberately
        //options.add(new SelectOption(doNotShipId, doNotShipText));
        return options;
    }//getWarehouses

    public void createPacklists(){
        Boolean okToSubmit = TRUE;
        String errorMessage = '';

        //cannot submit the form if all of the items that have a positive quantity do not have a corresponding warehouse selected
        for (integer i2=0; i2 < assets.size(); i2++) {
            for (integer i1=0; i1 < assets[i2].lst.size(); i1++) {
                if (assets[i2].lst[i1].warehouse == null && assets[i2].lst[i1].reqItem.Packlist_Quantity__c <> 0) {
                    okToSubmit = FALSE;
                    i2 = assets[i2].lst.size();
                    errorMessage = 'Please select a warehouse for each device';
                }
            }
        }

        if (okToSubmit == FALSE) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
        } else {
            List<String> selectedWarehouses = new List<String>();

            //iterate through all of the items to identify the number of distinct warehouses selected
            for (integer i2=0; i2 < assets.size(); i2++) {
                for (integer i1=0; i1 < assets[i2].lst.size(); i1++) {                    
                    //how many packlists needed?
                    //add a new packlist if (the warehouse is not already in the list) AND (the packlist quantity is larger than 0)
                    if( !selectedWarehouses.contains(assets[i2].lst[i1].warehouse) && assets[i2].lst[i1].reqItem.Packlist_Quantity__c > 0 ) {
                        selectedWarehouses.add(assets[i2].lst[i1].warehouse);
                    }
                }
            }
        
            for (integer i=0; i<selectedWarehouses.size(); i++){
                //create the packlist object
                //loop through the items and add the ones that belong to that warehouse to the packlist 
                
                Packlist__c packlist = new Packlist__c();
                // Packlist name: Event Year + Event Month + Event Name + Warehouse Name
                // Event Start Date is on the Event Data record but is not mandatory. Default to drop off date, if it is missing
                Datetime d = theRequest.Event_Start_Date__c;
                if (d == null){
                    d = theRequest.Date_Drop_Off__c.date();
                }
                // date.month method returns a single digit month value if it is before October. In order to help the user with the sorting of these requests, we are adding a 0 to the auto-generated packlist name.
                if(d.month()<10){
                    packlist.Name = d.year() + '-0' + d.month() + ' - ' + theRequest.Name + ' - ' + warehouseListwithNames.get(selectedWarehouses[i]);
                } else {
                    packlist.Name = d.year() + '-'  + d.month() + ' - ' + theRequest.Name + ' - ' + warehouseListwithNames.get(selectedWarehouses[i]);
                }
                
                packlist.Onsite_Hardware_Request__c = theRequest.Id;
                packlist.Cvent_Warehouse__c = selectedWarehouses[i];
                packlist.Date_Shipment__c = theRequest.Date_Current_Shipment_Date__c;
                //Set the International Flag based on the Event Country vs Warehouse Country
                Boolean international = FALSE;
                for (integer iw=0; iw<wList.size(); iw++){
                    if (wList[iw].id == selectedWarehouses[i]){
                        if (theRequest.Country__c <> wList[iw].Country__c){
                            international = TRUE;
                        }
                    }
                }
                packlist.International_Shipping__c = international;
                insert packlist;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Packlist created: ' + packlist.Name));
                
                //Loop through the items, and assign them to the matching packlist
                for (integer i2=0; i2 < assets.size(); i2++) {
                    for (integer i1=0; i1 < assets[i2].lst.size(); i1++) {
                        //if the Packlist Quantity is 0, exclude the item from the packlist
                        if ( assets[i2].lst[i1].warehouse == selectedWarehouses[i] && assets[i2].lst[i1].reqItem.Requested_Quantity__c > 0) {
                            assets[i2].lst[i1].reqItem.Packlist__c = packlist.Id;
                            update assets[i2].lst[i1].reqItem;
                            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Added Item to the Packlist ' + assets[i2].lst[i1].reqItem.Name));
                        }
                    }
                }
                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Packlist(s) created'));
            }//packlist loop
            
            assets = null;
            theRequest = null;

        }//if-else
    }//createPacklists

    public void splitItem(){
        String itemIdToBeSplit = ApexPages.currentPage().getParameters().get('itemIdToBeSplit');
        String L1index = ApexPages.currentPage().getParameters().get('L1index');
        String L2index = ApexPages.currentPage().getParameters().get('L2index');

        Integer L1i = integer.valueOf(L1index);
        Integer L2i = integer.valueOf(L2index);

        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'ID: ' + itemIdToBeSplit + ' obj id: ' + assets[L2i].lst[L1i].reqItem.ID + ' qty: ' + assets[L2i].lst[L1i].reqItem.Requested_Quantity__c));


        //create the new item with the same values as the original one
        //get the original quantity and half it (in case it is not an even number, use rounding)
        Onsite_Hardware_Request_Item__c newItem = new Onsite_Hardware_Request_Item__c();
        
        newItem.Onsite_Hardware_Request_Bundle__c   = assets[L2i].lst[L1i].reqItem.Onsite_Hardware_Request_Bundle__c;
        newItem.Onsite_Hardware_Request__c          = theRequest.Id;
        newItem.Requested_Quantity__c               = (assets[L2i].lst[L1i].reqItem.Requested_Quantity__c / 2).round(System.RoundingMode.CEILING);
        newItem.Cvent_Asset_Type__c                 = assets[L2i].lst[L1i].reqItem.Cvent_Asset_Type__c;
        newItem.Item_Created_By__c                  = 'Logistics Team';

        insert newItem;

        //update the original item
        assets[L2i].lst[L1i].reqItem.Requested_Quantity__c = (assets[L2i].lst[L1i].reqItem.Requested_Quantity__c / 2).round(System.RoundingMode.FLOOR);
        update assets[L2i].lst[L1i].reqItem;
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Item successfully split into two'));

        assets = null;
        theRequest = null;                
    }//splitItem
}