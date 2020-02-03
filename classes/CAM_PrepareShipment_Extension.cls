public with sharing class CAM_PrepareShipment_Extension {
    private final ApexPages.StandardController controller;
    public Integer packedQuantity { get; set; }
    public String scannedAssetId { get; set; }
    public String newLine { get {
        newLine = '\n';
        return newLine;
        }
        set;
    }
    public Boolean uniqueAssetMode { get; set; }
    public String bulkIDList { get; set; }
    List<Cvent_Box__c> boxList;
    public String activeBoxSingle { get; set; }
    public String activeBoxBulk { get; set; }
    public String activeBulkBox { get; set; }
    public String splitItemNewId { get; set; }

    public CAM_PrepareShipment_Extension(ApexPages.StandardController stdController) {
		this.controller = stdController;
        activeBoxSingle = ApexPages.currentPage().getParameters().get('activeBoxSingleParam');
        activeBoxBulk = ApexPages.currentPage().getParameters().get('activeBoxBulkParam');
        refreshTheRequestedItem();
    }

    public Onsite_Hardware_Request_Item__c theRequestedItem {
        get {
            if (theRequestedItem == null){
                theRequestedItem = (Onsite_Hardware_Request_Item__c)controller.getRecord();
				refreshTheRequestedItem();
            }
            return theRequestedItem;
        }
        set;
    } //theRequestedItem
    
    public void refreshTheRequestedItem() {
        theRequestedItem = [SELECT Id, Name, Packlist_Quantity__c, Quantity_to_be_Packed__c, Shipped_Quantity_Others__c,
                                    Cvent_Asset_Type__c, Cvent_Asset_Type__r.Type__c, Cvent_Asset_Type__r.Name, Cvent_Asset_Group__c, Cvent_Asset_Subgroup__c, Packlist__c, Packlist__r.Name,  Packlist__r.Date_Shipment__c, 
                                    Onsite_Hardware_Request_Bundle__c, Onsite_Hardware_Request_Bundle__r.Cvent_Asset_Bundle__c, 
                                    Onsite_Hardware_Request__c, Onsite_Hardware_Request__r.Name, Onsite_Hardware_Request__r.Event_Name__c,Onsite_Hardware_Request__r.Event_Name__r.Event_Name__c,
                                    Onsite_Hardware_Request__r.Event_Name__r.Project_Manager__c, Cvent_Box__c,
                                    (SELECT ID, Name, Cvent_Asset__c, Cvent_Asset__r.Asset_Tag__c, Cvent_Asset__r.Asset_Name__c, Validate_Asset_Types_Match__c, 
                                        CreatedDate, Cvent_Box__c, Cvent_Box__r.Number_Label__c, Cvent_Box__r.Cvent_Box_Type__r.Name
                                        FROM  Packlist_Items__r 
                                        ORDER BY Validate_Asset_Types_Match__c, CreatedDate DESC)
                            FROM  Onsite_Hardware_Request_Item__c WHERE Id= :theRequestedItem.Id];

		packedQuantity = 0;
        for (integer i=0; i<theRequestedItem.Packlist_Items__r.size(); i++){
            if (theRequestedItem.Packlist_Items__r[i].Validate_Asset_Types_Match__c == TRUE){
                packedQuantity++;
            }
        }//for

        if (theRequestedItem.Cvent_Asset_Type__r.Type__c == 'Unique Asset'){
            uniqueAssetMode = TRUE;
        } else {
            uniqueAssetMode = FALSE;
        }
    }//refreshTheRequestedItem

	public Packlist__c thePacklist {
        get {
            if (thePacklist == null){
				refreshThePacklist();
            }
            return thePacklist;
        }
        set;
    } //thePacklist
    
    public void refreshThePacklist() {
        thePacklist = [SELECT Id, Name, 
                                    (SELECT id, Name, Cvent_Asset_Type__c, Cvent_Asset_Type__r.Name, Cvent_Asset_Group__c, Cvent_Asset_Subgroup__c, 
                                            Quantity_to_be_Packed__c, CreatedDate,
                                            Shipped_Quantity_Unique_Assets__c, Shipped_Quantity_Correct_Unique_Assets__c, Shipped_Quantity_Others__c, Shipped_Quantity__c
                                        FROM Onsite_Hardware_Request_Items__r 
                                        ORDER BY Cvent_Asset_Type__r.Sort_Order__c, Cvent_Asset_Group__c, Cvent_Asset_Subgroup__c) 
                        FROM Packlist__c WHERE Id= :theRequestedItem.Packlist__c];
    }//refreshThePacklist

    public void removeAsset() {
		String packlistItemIDtobeDeleted = ApexPages.currentPage().getParameters().get('packlistItemIDtobeDeleted');
		String assetIDtobeUpdated = ApexPages.currentPage().getParameters().get('assetIDtobeUpdated');

        Packlist_Item__c assettobeDeleted = new Packlist_Item__c();
        Cvent_Asset__c asset = New Cvent_Asset__c();
        
        assettobeDeleted = [SELECT ID, Cvent_Asset__c FROM Packlist_Item__c WHERE ID=:packlistItemIDtobeDeleted LIMIT 1];
        asset = [SELECT Id, Name, Status__c FROM Cvent_Asset__c WHERE ID = :assetIDtobeUpdated LIMIT 1];
        
        //update the status of the Asset
        asset.Status__c = 'Available';
        update asset;

		//delete the Packlist Item and force refresh the related list on the page
        delete assettobeDeleted;
        theRequestedItem = null;
        thePacklist = null;
        otherItems = null;
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Asset Removed'));
    }//removeAsset

    public void scanAsset() {
        //create the new empty object
        Packlist_Item__c scannedAsset = new Packlist_Item__c();
        Cvent_Asset__c asset = New Cvent_Asset__c();
                
        try{
        	//find the ID of the Asset based on its Name
            asset = [SELECT Id, Name, Status__c FROM Cvent_Asset__c WHERE Asset_Tag__c = :scannedAssetId AND Status__c= 'Available' LIMIT 1];
        } catch(Exception ex){
            asset = null;
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'No Asset Found'));
        }

        //check for already added Asset IDs
        if (asset <> null) {
            for (integer i=0; i<theRequestedItem.Packlist_Items__r.size(); i++){
                if (theRequestedItem.Packlist_Items__r[i].Cvent_Asset__c == asset.Id){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'The Asset has already been added'));
                    i = theRequestedItem.Packlist_Items__r.size();
                    asset = null;
                }
            }
        }
        
        if (asset <> null){
            //populate the fields
            scannedAsset.Onsite_Hardware_Request_Item__c = controller.getRecord().Id;
            scannedAsset.Cvent_Asset__c = asset.ID;
            scannedAsset.Cvent_Box__c = activeBoxSingle;
            
            //save
            insert scannedAsset;
            theRequestedItem = null;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Asset Added'));
            
            //update the status of the Asset
            asset.Status__c = 'Deployed';
            update asset;
        }
        
        scannedAssetId = null; 
        thePacklist = null;
        otherItems = null;
    }//scanAsset

    public void populateShippingQuantity(){
        theRequestedItem.Shipped_Quantity_Others__c = theRequestedItem.Quantity_to_be_Packed__c;
    }//populateShippingQuantity

    public void confirmShippingQuantity(){
        update theRequestedItem;
        uniqueAssetMode = FALSE;
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Shipping Quantity updated to: ' + theRequestedItem.Shipped_Quantity_Others__c));

        scannedAssetId = null; 
        thePacklist = null;
        otherItems = null;
    }//confirmShippingQuantity

    public class w_ReqItem {
        public Onsite_Hardware_Request_Item__c  reqItem     {get; set;}
        public integer                          c           {get; set;}
        public String                           progress_s  {get; set;}
        public Double                           progress    {get; set;}

 
        public w_ReqItem(Onsite_Hardware_Request_Item__c i, integer ic, String cs, Double pr) {
            reqItem     = i;
            c           = ic;
            progress_s  = cs;
            progress    = pr;
        }
    }//w_ReqItem

    public List<w_ReqItem> otherItems {
        get {
            if (otherItems == null ){
                otherItems = new List<w_ReqItem>();
        		Onsite_Hardware_Request_Item__c[] L1; 
                
                L1 = thePacklist.Onsite_Hardware_Request_Items__r;

                //main loop to populate the catalog
                for (integer i1=0; i1<L1.size(); i1++){
                    Double fillPercent;
                    Integer longWay = 0;
                    Integer otherOption = 1;

                    if ( L1[i1].Shipped_Quantity__c >= L1[i1].Quantity_to_be_Packed__c ) {
                        //if the shipped quantity is greater or equal to the requested quantity, then mark the item as complete
                        fillPercent = 1;
                    } else {
                        fillPercent = (L1[i1].Shipped_Quantity__c / L1[i1].Quantity_to_be_Packed__c);
                    }
                    //fillPercent = Math.round(fillPercent, 2);
                    if (fillPercent >= 0.5) {
                        longWay = 1;
                    }

                    String s = 'M 1 0 A 1 1 0 ' + longWay + ' ' + otherOption + ' ' + Math.cos(2 * Math.PI * fillPercent) + ' ' + Math.sin(2 * Math.PI * fillPercent) + ' L 0 0';
                    otherItems.add(new w_ReqItem(L1[i1], otherItems.size(), s, fillPercent));
                }//L1

            }//null check
            
            return otherItems;
        }
        set;
    }//otherItems

    public PageReference createNewItem() {
        //create a new Item. Bundle same, Packlist same, Asset Type of the scanned asset. Requested quantity 1
        //move the Packlist Item under the new Item
        //refresh the page to show the new one


		String packlistItemID = ApexPages.currentPage().getParameters().get('packlistItemID');
		//String assetIDtobeUpdated = ApexPages.currentPage().getParameters().get('assetIDtobeUpdated');

        Packlist_Item__c assetToMove = new Packlist_Item__c();
        assetToMove = [SELECT ID, Cvent_Asset__c, Cvent_Asset__r.Cvent_Asset_Type__c, Onsite_Hardware_Request_Item__c FROM Packlist_Item__c WHERE ID=:packlistItemID LIMIT 1];

        Onsite_Hardware_Request_Item__c newItem = new Onsite_Hardware_Request_Item__c();

        newItem.Onsite_Hardware_Request_Bundle__c   = theRequestedItem.Onsite_Hardware_Request_Bundle__c;
        newItem.Onsite_Hardware_Request__c          = theRequestedItem.Onsite_Hardware_Request__c;
        newItem.Packlist__c                         = theRequestedItem.Packlist__c;
        newItem.Requested_Quantity__c               = 1;
        newItem.Cvent_Asset_Type__c                 = assetToMove.Cvent_Asset__r.Cvent_Asset_Type__c;
        newItem.Item_Created_By__c                  = 'Logistics Team';
        insert newItem;

        assetToMove.Onsite_Hardware_Request_Item__c = newItem.id;
        update assetToMove;
        
        scannedAssetId = null; 
        thePacklist = null;
        otherItems = null;

        //Show the new item
        PageReference pageRef = new PageReference('/apex/CAM_PrepareShipment?id=' + newItem.id);
        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'New item added to the Packlist ' + newItem.id));
        pageRef.setRedirect(true);
        return pageRef;

    }//createNewItem

    public void bulkScanAssets() {
        String[] idList = new String[0];
        idList = bulkIDList.split('\n');
        Integer[] results = new Integer[] {0, 0, 0, 0, 0};
        //Results: total input, Duplicate, Not found, found but not available, added
        results[0] = idList.size();
        
        for (integer i1=0; i1<idList.size(); i1++){
            Integer count = 0;
            for (integer i2=0; i2<idList.size(); i2++){
                if (idList[i1] == idList[i2]){
                    count++;
                }
            }
            if (count > 1) {
                results[1]++;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Duplicate barcode found: ' + idList[i1]));
                idList.remove(i1);
                i1--;
            }
        }

        List<Cvent_Asset__c> assets = new List<Cvent_Asset__c>();
                
        try {
            //find the assets based on the Asset Tags
            assets = [SELECT Id, Name, Asset_Tag__c, Status__c FROM Cvent_Asset__c WHERE Asset_Tag__c = :idList];
        } catch(Exception ex){
            assets = null;
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'None of the barcodes scanned matched an asset'));
        }

        //check if any barcodes are not actual assets. remove the ones that match, therefore
        //whatever is remaining in the original list, is not found.
        if (idList.size() <> assets.size()){
            for (integer i1=0; i1<idList.size(); i1++){
                for (integer i2=0; i2<assets.size(); i2++){
                    if (idList[i1] == assets[i2].Asset_Tag__c){
                        idList.remove(i1);
                        i1 = i1 - 1;
                    }
                }
            }
            
            //inform the user about unmatched barcode(s)
            for (String s : idList){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Barcode not found: ' + s));
                results[2]++;
            }
        }


        //matched barcodes
        if (assets <> null) {
            for (integer i=0; i<assets.size(); i++){
                if (assets[i].Status__c <> 'Available'){
                    // if the status is not Available, then the asset cannot be packed
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Barcode found but Asset not available: ' + assets[i].Asset_Tag__c));
                    assets.remove(i);
                    i--;
                    results[3]++;
                } else {
                    //the remaining ones should be ok to insert
                    Packlist_Item__c scannedAsset = new Packlist_Item__c();

                    //populate the fields
                    scannedAsset.Onsite_Hardware_Request_Item__c = controller.getRecord().Id;
                    scannedAsset.Cvent_Asset__c = assets[i].ID;
                    scannedAsset.Cvent_Box__c = activeBoxBulk;
                    
                    //save
                    insert scannedAsset;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Asset Added: ' + assets[i].Asset_Tag__c));
                    
                    //update the status of the Asset
                    assets[i].Status__c = 'Deployed';
                    update assets[i];

                    results[4]++;
                }
            }
        }//main loop for matched
        
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'--- Results ---'));
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Barcodes entered: ' + results[0]));
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Duplicates: ' + results[1]));
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Barcode not found: ' + results[2]));
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Barcode found but Asset not available: ' + results[3]));
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Asset added: ' + results[4]));

        scannedAssetId = null; 
        thePacklist = null;
        theRequestedItem = null;
        otherItems = null;
    }//bulkScanAssets

    /*
    public void enableBulkScan(){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'0 ' + bulkScanEnabled));
        if (bulkScanEnabled) {
            bulkScanEnabled = FALSE;
        } else {
            bulkScanEnabled = TRUE;
        }
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'1 ' + bulkScanEnabled));
    }*/


    public List<SelectOption> getBoxes() {
        //pulls the list of boxes defined for this packlist and returns it as an Option list for dropdowns
        //also stores the list of boxes for future use
        List<SelectOption> options = new List<SelectOption>();
        boxList = new List<Cvent_Box__c>();
        
        //add the default option
        options.add(new SelectOption('', '-- Select Box --'));
        boxList = [SELECT ID, Name, Number_in_Packlist__c, Number_Label__c, 
                        Dimensions_in__c, Dimensions_cm__c, Cvent_Box_Type__c, Cvent_Box_Type__r.Name 
                    FROM Cvent_Box__c 
                    WHERE Packlist__c = :thePacklist.Id
                    ORDER BY Number_Label__c ASC];
        
        for (integer i = 0; i < boxList.size(); i++) {
            options.add(new SelectOption(boxList[i].ID, boxList[i].Number_Label__c + ' (' + boxList[i].Cvent_Box_Type__r.Name + ')'));
            //options.add(new SelectOption(boxList[i].ID, boxList[i].Number_Label__c));
        }

        return options;
    }//getBoxes    

    public void bulkUpdateBox(){
        for (Packlist_Item__c item: theRequestedItem.Packlist_Items__r){
            item.Cvent_Box__c = activeBulkBox;
            update item;
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'item updated' + item.Cvent_Asset__r.Asset_Tag__c ));
        }

    }//bulkUpdateBox

    public void splitItem() {
        uniqueAssetMode = FALSE;
        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Shipping Quantity updated to: ' + theRequestedItem.Shipped_Quantity_Others__c));

        //create the new item with the same values as the original one
        //get the original quantity and half it (in case it is not an even number, use rounding)
        Onsite_Hardware_Request_Item__c newItem = new Onsite_Hardware_Request_Item__c();
        
        newItem.Onsite_Hardware_Request_Bundle__c   = theRequestedItem.Onsite_Hardware_Request_Bundle__c;
        newItem.Onsite_Hardware_Request__c          = theRequestedItem.Onsite_Hardware_Request__c;
        newItem.Packlist__c                         = theRequestedItem.Packlist__c;
        newItem.Requested_Quantity__c               = 0;
        newItem.Packlist_Quantity__c                = (theRequestedItem.Quantity_to_be_Packed__c / 2).round(System.RoundingMode.CEILING);
        newItem.Cvent_Asset_Type__c                 = theRequestedItem.Cvent_Asset_Type__c;
        newItem.Item_Created_By__c                  = 'Logistics Team';

        insert newItem;

        //update the original item
        theRequestedItem.Packlist_Quantity__c   = (theRequestedItem.Quantity_to_be_Packed__c / 2).round(System.RoundingMode.FLOOR);
        update theRequestedItem;
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Item successfully split into two'));

        splitItemNewId = newItem.id;

        scannedAssetId = null; 
        thePacklist = null;
        otherItems = null;
        theRequestedItem = null;
    }//splitItem

}