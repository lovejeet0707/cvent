public with sharing class CAM_ExportData_Extension {
    private final ApexPages.StandardController controller;
    public String param_id { get; set; }
    public String param_obj { get; set; }
    public Packlist_Item__c[] packedAssets { get; set; }

    public CAM_ExportData_Extension(ApexPages.StandardController stdController) {
		this.controller = stdController;
        param_id = ApexPages.currentPage().getParameters().get('pid');
        param_obj = ApexPages.currentPage().getParameters().get('obj');
        prepareData();
    }

    public void prepareData(){
        packedAssets = new List<Packlist_Item__c>();
        
        if ( param_obj == null ){ 
            packedAssets = [SELECT id, Name, Cvent_Asset__c, Validate_Asset_Types_Match__c, 
                            Onsite_Hardware_Request_Item__r.Cvent_Asset_Group__c, Onsite_Hardware_Request_Item__r.Cvent_Asset_Subgroup__c,
                            Cvent_Asset__r.Serial_Number__c, Cvent_Asset__r.Customs_Value__c,
                            Cvent_Asset__r.Asset_Name__c, Cvent_Asset__r.Asset_Tag__c, Cvent_Asset__r.Cvent_Asset_Type__r.Name,
                            Cvent_Asset__r.IMEI__c, Cvent_Asset__r.Manufacturer__c, Cvent_Asset__r.Model_Number__c, Cvent_Asset__r.Phone_Number__c, Cvent_Asset__r.SIM_Number__c,
                            Cvent_Asset__r.Kit_Asset_Tag__c, Cvent_Asset__r.Kit_Asset_Tag__r.Asset_Name__c, Cvent_Asset__r.Kit_Asset_Tag__r.Asset_Tag__c, Cvent_Asset__r.Kit_Asset_Tag__r.Cvent_Asset_Type__r.Name, Cvent_Asset__r.Kit_Asset_Tag__r.Serial_Number__c,
                            Cvent_Asset__r.Kit_Asset_Tag__r.IMEI__c, Cvent_Asset__r.Kit_Asset_Tag__r.Manufacturer__c, Cvent_Asset__r.Kit_Asset_Tag__r.Model_Number__c, Cvent_Asset__r.Kit_Asset_Tag__r.Phone_Number__c, Cvent_Asset__r.Kit_Asset_Tag__r.SIM_Number__c,
                            Cvent_Box__c, Cvent_Box__r.Number_Label__c, Cvent_Box__r.Cvent_Box_Type__r.Name, Cvent_Box__r.Dimensions_in__c, Cvent_Box__r.Dimensions_cm__c
                            FROM Packlist_Item__c
                            WHERE Onsite_Hardware_Request_Item__c =:param_id
                            ORDER BY Cvent_Box__r.Number_Label__c, Cvent_Asset__r.Asset_Tag__c
                            ];
        } else if (param_obj == 'Packlist__c') {
            packedAssets = [SELECT id, Name, Cvent_Asset__c, Validate_Asset_Types_Match__c, 
                            Onsite_Hardware_Request_Item__r.Cvent_Asset_Group__c, Onsite_Hardware_Request_Item__r.Cvent_Asset_Subgroup__c,
                            Cvent_Asset__r.Serial_Number__c, Cvent_Asset__r.Customs_Value__c,
                            Cvent_Asset__r.Asset_Name__c, Cvent_Asset__r.Asset_Tag__c, Cvent_Asset__r.Cvent_Asset_Type__r.Name,
                            Cvent_Asset__r.IMEI__c, Cvent_Asset__r.Manufacturer__c, Cvent_Asset__r.Model_Number__c, Cvent_Asset__r.Phone_Number__c, Cvent_Asset__r.SIM_Number__c,
                            Cvent_Asset__r.Kit_Asset_Tag__c, Cvent_Asset__r.Kit_Asset_Tag__r.Asset_Name__c, Cvent_Asset__r.Kit_Asset_Tag__r.Asset_Tag__c, Cvent_Asset__r.Kit_Asset_Tag__r.Cvent_Asset_Type__r.Name, Cvent_Asset__r.Kit_Asset_Tag__r.Serial_Number__c,
                            Cvent_Asset__r.Kit_Asset_Tag__r.IMEI__c, Cvent_Asset__r.Kit_Asset_Tag__r.Manufacturer__c, Cvent_Asset__r.Kit_Asset_Tag__r.Model_Number__c, Cvent_Asset__r.Kit_Asset_Tag__r.Phone_Number__c, Cvent_Asset__r.Kit_Asset_Tag__r.SIM_Number__c,Cvent_Asset__r.Kit_Asset_Tag__r.Customs_Value__c,
                            Cvent_Box__c, Cvent_Box__r.Number_Label__c, Cvent_Box__r.Cvent_Box_Type__r.Name, Cvent_Box__r.Dimensions_in__c, Cvent_Box__r.Dimensions_cm__c
                            FROM Packlist_Item__c
                            WHERE Onsite_Hardware_Request_Item__r.Packlist__c =:param_id
                            ORDER BY Cvent_Box__r.Number_Label__c, Cvent_Asset__r.Asset_Tag__c
                            ];            
        }



    }//prepareData
}