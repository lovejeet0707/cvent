public with sharing class CAM_PrintPacklist_Extension {
    private final ApexPages.StandardController controller;
    //Public String[] innerTableHeaders { get; set; }
    Public String tidyFromAddress { get; set; }
    
    public CAM_PrintPacklist_Extension(ApexPages.StandardController stdController) {
		this.controller = stdController;
    }

    public Packlist__c thePacklist {
        get {
            if (thePacklist == null){
                thePacklist = (Packlist__c)controller.getRecord();
				refreshThePacklist();
            }
            return thePacklist;
        }
        set;
    } //thePacklist
    
    public String[] listofAssetTypes { get {
        if (listofAssetTypes == null) {
            refreshThePacklist();
        }
        return listofAssetTypes;
    	} 
		set; 
	}//listofAssetTypes

    public void refreshThePacklist() {
        thePacklist = [SELECT   Id, Name, CreatedDate, 
                                Onsite_Hardware_Request__r.Name, 
                                Onsite_Hardware_Request__r.Event_Name__r.Event_Name__c, Onsite_Hardware_Request__r.Event_Name__r.Project_Manager__c, 
                                Onsite_Hardware_Request__r.C_O__c, Onsite_Hardware_Request__r.Attn__c, Onsite_Hardware_Request__r.Venue_Name__c, Onsite_Hardware_Request__r.Address_Line_1__c, Onsite_Hardware_Request__r.Address_Line_2__c, Onsite_Hardware_Request__r.City__c, Onsite_Hardware_Request__r.Zip_Code__c, Onsite_Hardware_Request__r.State__c, Onsite_Hardware_Request__r.Country__c,
                                Date_Shipment__c, Rental__c, International_Shipping__c, 
                                Cvent_Warehouse__r.Name, Cvent_Warehouse__r.Address_Line_1__c, Cvent_Warehouse__r.Address_Line_2__c, Cvent_Warehouse__r.City__c, Cvent_Warehouse__r.Zip_Code__c, Cvent_Warehouse__r.State__c, Cvent_Warehouse__r.Country__c,
                                (SELECT id, Name, Cvent_Asset_Type__c, Cvent_Asset_Type__r.Name, Cvent_Asset_Group__c, Cvent_Asset_Subgroup__c, Quantity_to_be_Packed__c, Shipped_Quantity__c,
                                        Onsite_Hardware_Request_Bundle__c, Onsite_Hardware_Request_Bundle__r.Cvent_Asset_Bundle__c
                                    FROM Onsite_Hardware_Request_Items__r 
                                    ORDER BY Cvent_Asset_Type__c, Cvent_Asset_Group__c, Cvent_Asset_Subgroup__c 
                                ) 
                            FROM Packlist__c where Id= :thePacklist.Id
                        ];

        if (thePacklist.Onsite_Hardware_Request_Items__r <> null) {
            listofAssetTypes = new String[0];
            
            //add the first Asset Type to the list
            listofAssetTypes.add(thePacklist.Onsite_Hardware_Request_Items__r[0].Cvent_Asset_Type__r.Name);
            
            //start the loop from the second item in the list
            for (integer i = 1; i < thePacklist.Onsite_Hardware_Request_Items__r.size(); i++){
                if ( thePacklist.Onsite_Hardware_Request_Items__r[i].Cvent_Asset_Type__r.Name <> thePacklist.Onsite_Hardware_Request_Items__r[i-1].Cvent_Asset_Type__r.Name) {
                    listofAssetTypes.add(thePacklist.Onsite_Hardware_Request_Items__r[i].Cvent_Asset_Type__r.Name);
                }
            }
        }
        //innerTableHeaders = new List<String> { 'ID', 'Group', 'Packlist Quantity'};
        
    }//refreshThePacklist
}