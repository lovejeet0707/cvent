public with sharing class CAM_ReturnShipment_E {
    private final ApexPages.StandardController controller;
    public String   pageID { get; set; }
    public String   warehouseId { get; set; }
    public String   packlistId { get; set; }
    public Boolean  anonMode { get; set; }
    public Boolean uniqueAssetMode { get; set; }
    public String   scannedIdList { get; set; }
    public Onsite_Hardware_Request_Item__c  theItem { get; set; }
    public Packlist__c                      thePacklist { get; set; }
    public List<Packlist_Item__c>           packlistItems { get; set; }
    public String newLine { get {
        newLine = '\n';
        return newLine;
        }
        set;
    }

    public CAM_ReturnShipment_E (ApexPages.StandardController stdController) {
		this.controller = stdController;
        pageID = apexpages.currentpage().getparameters().get('id');
        warehouseId = apexpages.currentpage().getparameters().get('warehouse');
        packlistId = apexpages.currentpage().getparameters().get('Packlist__c');

        if ( packlistId <> null ){
            //if this parameter is not empty, it means that the page was called from a Packlist page. We will grab the first item in the Packlist, and redirect to the page with that ID
            System.System.debug('Found Packlist Id');
            redirectMe();
        }
        
        if ( pageID == null ) {
            anonMode = true;
        } else {
            anonMode = false;
            refreshPacklist();
            refreshPacklistItems();
        }
    }//constructor

    public void refreshPacklist(){
        // Consumables do not return back from onsite, therefore are excluded from this list
        // Items only show in the list if their Shipped Quantity is larger than 0. (The exception is that incorrect type unique assets are added, but the shipped quantity has not increased)
        thePacklist = [SELECT Id, Name, 
                                    (SELECT id, Name, Cvent_Asset_Type__c, Cvent_Asset_Type__r.Name, Cvent_Asset_Type__r.Type__c, Packlist__c, Returned_Quantity__c, Returned__c, Returned_Quantity_Others__c,
                                            Cvent_Asset_Group__c, Cvent_Asset_Subgroup__c, Quantity_to_be_Packed__c, CreatedDate,
                                            Onsite_Hardware_Request__r.Event_Name__r.Project_Manager__c, Onsite_Hardware_Request__r.Name, Onsite_Hardware_Request__c, Onsite_Hardware_Request__r.Event_Name__c, Onsite_Hardware_Request__r.Event_Name__r.Event_Name__c,
                                            Shipped_Quantity_Unique_Assets__c, Shipped_Quantity_Correct_Unique_Assets__c, Shipped_Quantity_Others__c, Shipped_Quantity__c
                                        FROM Onsite_Hardware_Request_Items__r 
                                        WHERE   Cvent_Asset_Type__r.Type__c <> 'Consumable'
                                            AND (Shipped_Quantity__c > 0 OR Shipped_Quantity_Unique_Assets__c > 0)
                                        ORDER BY Cvent_Asset_Type__r.Sort_Order__c, Cvent_Asset_Group__c, Cvent_Asset_Subgroup__c, name) 
                        FROM Packlist__c WHERE Id IN (SELECT Packlist__c FROM Onsite_Hardware_Request_Item__c WHERE id=:pageID) ];

        for (Onsite_Hardware_Request_Item__c i : thePacklist.Onsite_Hardware_Request_Items__r){
            if (i.id == pageID){
                theItem = i;
                if (theItem.Cvent_Asset_Type__r.Type__c == 'Unique Asset'){
                    uniqueAssetMode = TRUE;
                } else {
                    uniqueAssetMode = FALSE;
                    if ( theItem.Returned_Quantity_Others__c == null ){
                        theItem.Returned_Quantity_Others__c = theItem.Shipped_Quantity__c;
                    }
                }
            }
        }
    }//refreshPacklist

    public void refreshPacklistItems(){
        packlistItems = new List<Packlist_Item__c>();
        packlistItems = [SELECT id, Name, Cvent_Asset__c, Validate_Asset_Types_Match__c, Date_Actual_Return__c,
                            Cvent_Asset__r.Asset_Name__c, Cvent_Asset__r.Asset_Tag__c, Cvent_Asset__r.Cvent_Asset_Type__r.Name,
                            Cvent_Asset__r.IMEI__c, Cvent_Asset__r.Manufacturer__c, Cvent_Asset__r.Model_Number__c, Cvent_Asset__r.Phone_Number__c, Cvent_Asset__r.SIM_Number__c,
                            Cvent_Asset__r.Kit_Asset_Tag__c, Cvent_Asset__r.Kit_Asset_Tag__r.Asset_Name__c, Cvent_Asset__r.Kit_Asset_Tag__r.Asset_Tag__c, Cvent_Asset__r.Kit_Asset_Tag__r.Cvent_Asset_Type__r.Name,
                            Cvent_Asset__r.Kit_Asset_Tag__r.IMEI__c, Cvent_Asset__r.Kit_Asset_Tag__r.Manufacturer__c, Cvent_Asset__r.Kit_Asset_Tag__r.Model_Number__c, Cvent_Asset__r.Kit_Asset_Tag__r.Phone_Number__c, Cvent_Asset__r.Kit_Asset_Tag__r.SIM_Number__c,
                            Cvent_Box__c, Cvent_Box__r.Number_Label__c, Cvent_Box__r.Cvent_Box_Type__r.Name, Cvent_Box__r.Dimensions_in__c, Cvent_Box__r.Dimensions_cm__c
                            FROM Packlist_Item__c
                            WHERE Onsite_Hardware_Request_Item__c = :pageID AND Cvent_Asset__r.Status__c = 'Deployed'
                            ORDER BY Cvent_Box__r.Number_Label__c, Cvent_Asset__r.Asset_Tag__c
                        ];
    }//refreshPacklistItems

    public PageReference redirectMe(){
        thePacklist = [SELECT Id, Name, 
                                        (SELECT id, Name, Returned__c
                                        FROM Onsite_Hardware_Request_Items__r 
                                        WHERE Cvent_Asset_Type__r.Type__c <> 'Consumable'
                                        ORDER BY Cvent_Asset_Type__r.Sort_Order__c, Cvent_Asset_Group__c, Cvent_Asset_Subgroup__c, name ) 
                        FROM  Packlist__c WHERE Id= :packlistId LIMIT 1
                        ];
        pageID = thePacklist.Onsite_Hardware_Request_Items__r[0].id;
        for ( integer i=0; i<thePacklist.Onsite_Hardware_Request_Items__r.size(); i++ ){
            //look for the first item that still needs to be returned
            if (thePacklist.Onsite_Hardware_Request_Items__r[i].Returned__c < 100){
                pageID = thePacklist.Onsite_Hardware_Request_Items__r[i].id;
                i = thePacklist.Onsite_Hardware_Request_Items__r.size();
            }
        }
        PageReference p = new PageReference('/apex/CAM_ReturnShipment?id=' + pageID);
        p.setRedirect(true);
        System.System.debug('Redirecting to CAM_ReturnShipment with the pageID');
        return p;
    }//redirectMe

    public List<SelectOption> getWarehouses() {
        List<SelectOption> options = new List<SelectOption>();
        List<Cvent_Warehouse__c> wList = new List<Cvent_Warehouse__c>();
        
        //add the default option
        options.add(new SelectOption('', '-- Select Warehouse --'));
        wList = [SELECT ID, Name, Country__c FROM Cvent_Warehouse__c ORDER BY Name ASC];
        
        for (integer i = 0; i < wList.size(); i++) {
            options.add(new SelectOption(wList[i].ID, wList[i].Name));
        }

        return options;
    }//getWarehouses

    public void returnAssets(){
        //if the warehouse is not selected, stop the process. We need to know where the items are going back in.
        if (warehouseId == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select the Return Warehouse and try again'));
        } else {
            String[] idList = new String[0];
            idList = scannedIdList.split('\n');
            //somehow some browsers use \n or \r or both to indicate newline. will remove both, just in case
            for (integer i=0; i<idList.size(); i++){
                idList[i] = idList[i].replace('\r', '');
            }
            Integer[] results = new Integer[] {0, 0, 0, 0, 0};
            //Results: Total input, Duplicate, Not found, Found but not deployed, Returned
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
            }//duplicate check


            List<Cvent_Asset__c> assets = new List<Cvent_Asset__c>();
            try {
                //find the assets based on the Asset Tags
                assets = [SELECT Id, Name, Asset_Tag__c, Status__c FROM Cvent_Asset__c WHERE Asset_Tag__c IN :idList];
            } catch(Exception ex){
                assets = null;
                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'None of the barcodes scanned matched an asset'));
            }

            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'IDList size: ' + idList.size()));
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'assets size: ' + assets.size()));

            //check if any barcodes are not actual assets. remove the ones that match, therefore
            //whatever is remaining in the original list, is Not Found.
            if (idList.size() <> assets.size()){
                for (integer i1=0; i1<idList.size(); i1++){
                    for (integer i2=0; i2<assets.size(); i2++){
                        if (idList[i1] == assets[i2].Asset_Tag__c){
                            idList.remove(i1);
                            i1--;
                            i2 = assets.size();//exit the inner loop
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
                String[] assetIdList = new String[0];

                for (integer i=0; i<assets.size(); i++){
                    if (assets[i].Status__c == 'Available'){
                        // if the status is Available, then the asset cannot be returned
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Barcode found but Asset was already marked as returned: ' + assets[i].Asset_Tag__c));
                        assets.remove(i);
                        i--;
                        results[3]++;
                    } else {
                        //the remaining ones should be ok to return
                        assets[i].Status__c = 'Available';
                        assets[i].Location_Current__c = warehouseId;

                        update assets[i];
                        results[4]++;
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Asset returned: ' + assets[i].Asset_Tag__c));

                        assetIdList.add(assets[i].id);
                    }
                }//for loop for each asset scanned

                //find the corresponding Packlist Items and mark them as Returned 
                List<Packlist_Item__c> plItems = new List<Packlist_Item__c>();
                plItems = [SELECT id, name, Date_Actual_Return__c, Onsite_Hardware_Request_Item__c
                            FROM Packlist_Item__c
                            WHERE Cvent_Asset__c IN :assetIdList AND 	Date_Actual_Return__c = null
                            ];

                //updating the Actual Return Date marks the Packlist Item as returned
                for (Packlist_Item__c p: plItems){
                    p.Date_Actual_Return__c = System.today();
                    update p;
                }
                
                //the page is designed to show details of a single packlist. set the OHRI ID as the parameter to refresh it accordinly. 
                if ( plItems.size() > 0 ) { 
                    pageID = plItems[0].Onsite_Hardware_Request_Item__c;
                    ApexPages.currentPage().getParameters().put('id', plItems[0].Onsite_Hardware_Request_Item__c);
                    anonMode = false;
                    refreshPacklist();
                    refreshPacklistItems();
                } 
                //TODO: warn the user that there are other items being returned
                //TODO: check if the asset is in working condition. if not, highlight it


            }//main check for matched
        
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'--- Results ---'));
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Barcodes entered: ' + results[0]));
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Duplicates: ' + results[1]));
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Barcode not found: ' + results[2]));
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Barcode found but Asset was already marked as returned: ' + results[3]));
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Asset returned: ' + results[4]));

        }//initial warehouse check
    }//returnAssets

    public void returnAsset(){
		String packlistItemIDtobeReturned = ApexPages.currentPage().getParameters().get('packlistItemIDtobeReturned');
		String assetIDtobeReturned = ApexPages.currentPage().getParameters().get('assetIDtobeReturned');

        if (warehouseId == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select the Return Warehouse and try again'));
        } else {
            Cvent_Asset__c asset = new Cvent_Asset__c();
            asset = [SELECT ID, Name, Status__c, Asset_Tag__c FROM Cvent_Asset__c WHERE ID =:assetIDtobeReturned LIMIT 1];
            asset.Status__c = 'Available';
            asset.Location_Current__c = warehouseId;

            update asset;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Asset returned: ' + asset.Asset_Tag__c));

            Packlist_Item__c packlistItem = new Packlist_Item__c();
            packlistItem = [SELECT id, name, Date_Actual_Return__c FROM Packlist_Item__c WHERE ID =: packlistItemIDtobeReturned LIMIT 1];
            packlistItem.Date_Actual_Return__c = System.today();
            update packlistItem;

            refreshPacklist();
            refreshPacklistItems();
        }
    }//returnAsset

    public void confirmReturnedQuantity(){
        if (warehouseId == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select the Return Warehouse and try again'));
        } else {
            
            //TODO: check for negative numbers
            update theItem;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Item marked as returned'));

            refreshPacklist();
            refreshPacklistItems();
        }
    }//confirmReturnedQuantity
}