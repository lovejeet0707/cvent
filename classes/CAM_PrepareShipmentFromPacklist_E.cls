public with sharing class CAM_PrepareShipmentFromPacklist_E {
    private final ApexPages.StandardController controller;
    public String firstItemId;

    public CAM_PrepareShipmentFromPacklist_E(ApexPages.StandardController stdController) {
		this.controller = stdController;
        refreshthePacklist();
    }
    
    public Packlist__c thePacklist {
        get {
            if (thePacklist == null){
                thePacklist = (Packlist__c)controller.getRecord();
				refreshthePacklist();
            }
            return thePacklist;
        }
        set;
    } //thePacklist
    
    public void refreshthePacklist() {
        thePacklist = [SELECT Id, Name, 
                                    (SELECT id, Name, Cvent_Asset_Type__c, Cvent_Asset_Type__r.Name, Cvent_Asset_Group__c, Cvent_Asset_Subgroup__c, 
                                            Quantity_to_be_Packed__c, CreatedDate,
                                            Shipped_Quantity_Unique_Assets__c, Shipped_Quantity_Others__c, Shipped_Quantity__c
                                        FROM Onsite_Hardware_Request_Items__r 
                                        ORDER BY name, Cvent_Asset_Type__c, Cvent_Asset_Group__c, Cvent_Asset_Subgroup__c ) 
                        FROM  Packlist__c WHERE Id= :thePacklist.Id
                            ];
        firstItemId = thePacklist.Onsite_Hardware_Request_Items__r[0].id;
    }//refreshthePacklist

    public PageReference redirectMe() {
        PageReference p = new PageReference('/apex/CAM_PrepareShipment?id=' + firstItemId);
        p.setRedirect(true);
        return p;

    }//redirectMe

}