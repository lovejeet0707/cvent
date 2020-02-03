@isTest 

public class CAM_Test_PopulateData {

    public static List<Cvent_Asset_Group__c> groups;
    public static List<Cvent_Asset_Subgroup__c> subgroups;
    public static List<Cvent_Asset_Type__c> assetTypes;
    public static List<Cvent_Asset_Bundle__c> bundles;
    public static List<Cvent_Asset_Bundle_Item__c> bundleItems;
    public static List<Cvent_Asset_Subgroup_Bundle__c> subgroupAndBundles;
    public static List<Onsite_Hardware_Request__c> ohr;
    public static List<Onsite_Hardware_Request_Bundle__c> ohrb;
    public static List<Onsite_Hardware_Request_Item__c> ohri;
    public static List<Cvent_Warehouse__c> warehouses;
    public static List<Packlist__c> packlists;
    public static List<Cvent_Asset__c> assets;
    public static List<Cvent_Box_Type__c> boxTypes;
    public static List<Cvent_Box__c> boxes;
    public static List<Packlist_Item__c> packlistItems;

    @isTest public static void populateData() {

        /* *********************** Org Setup data *********************** */
        //Test.startTest();
        //CAM_Test_PopulateSetupData.populateSetupData();
        //Test.stopTest();

        List<PSA_Custom_Trigger_Settings__c> mcs = PSA_Custom_Trigger_Settings__c.getall().values();
        if ( mcs == null ) {
            PSA_Custom_Trigger_Settings__c settings = new PSA_Custom_Trigger_Settings__c(Name='Default', Disable_Project_populatePMsMgr__c=TRUE);
            insert settings;
        } else {
            for (PSA_Custom_Trigger_Settings__c p : mcs){
                System.assertEquals(False, p.Disable_Project_populatePMsMgr__c);
            }            
        }

        PSA_Custom_Trigger_Settings__c settings = new PSA_Custom_Trigger_Settings__c(Name='Default', 
                                                                                    Disable_Project_populatePMsMgr__c=TRUE,
                                                                                    Disable_Project_pendingCompletionPost__c = TRUE);
        insert settings;


        /* *********************** Admin created data *********************** */

        //Cvent Asset Group
        groups = new List<Cvent_Asset_Group__c>();
        groups.add( new Cvent_Asset_Group__c(Name='Group A') );
        groups.add( new Cvent_Asset_Group__c(Name='Group B') );
        insert groups;


        //Cvent Asset Subgroup
        subgroups = new List<Cvent_Asset_Subgroup__c>();
        subgroups.add( new Cvent_Asset_Subgroup__c(Name='Subgroup A1', Cvent_Asset_Group__c=groups[0].id) );
        subgroups.add( new Cvent_Asset_Subgroup__c(Name='Subgroup A2', Cvent_Asset_Group__c=groups[0].id) );
        subgroups.add( new Cvent_Asset_Subgroup__c(Name='Subgroup B1', Cvent_Asset_Group__c=groups[1].id) );
        subgroups.add( new Cvent_Asset_Subgroup__c(Name='Subgroup B2', Cvent_Asset_Group__c=groups[1].id) );
        insert subgroups;


        //Cvent Asset Types
        assetTypes = new List<Cvent_Asset_Type__c>();
        assetTypes.add( new Cvent_Asset_Type__c(Name='Type 1', Type__c='Unique Asset') );
        assetTypes.add( new Cvent_Asset_Type__c(Name='Type 2', Type__c='Unique Asset') );
        assetTypes.add( new Cvent_Asset_Type__c(Name='Type 3', Type__c='Non-Unique Asset') );
        assetTypes.add( new Cvent_Asset_Type__c(Name='Type 4', Type__c='Consumable') );
        insert assetTypes;

        //Cvent Asset Bundle
        bundles = new List<Cvent_Asset_Bundle__c>();
        bundles.add( new Cvent_Asset_Bundle__c(Name='Bundle 1') );
        bundles.add( new Cvent_Asset_Bundle__c(Name='Bundle 2') );
        bundles.add( new Cvent_Asset_Bundle__c(Name='Bundle 3') );
        bundles.add( new Cvent_Asset_Bundle__c(Name='Bundle 4') );
        insert bundles;


        //Cvent Asset Bundle Item
        bundleItems = new List<Cvent_Asset_Bundle_Item__c>();
        //bundle #1
        bundleItems.add( new Cvent_Asset_Bundle_Item__c(Cvent_Asset_Bundle__c=bundles[0].id, Cvent_Asset_Type__c=assetTypes[0].id, Quantity__c=1.1) );
        bundleItems.add( new Cvent_Asset_Bundle_Item__c(Cvent_Asset_Bundle__c=bundles[0].id, Cvent_Asset_Type__c=assetTypes[1].id, Quantity__c=1.2) );
        //bundle #2
        bundleItems.add( new Cvent_Asset_Bundle_Item__c(Cvent_Asset_Bundle__c=bundles[1].id, Cvent_Asset_Type__c=assetTypes[0].id, Quantity__c=1.1) );
        bundleItems.add( new Cvent_Asset_Bundle_Item__c(Cvent_Asset_Bundle__c=bundles[1].id, Cvent_Asset_Type__c=assetTypes[1].id, Quantity__c=1.2) );
        bundleItems.add( new Cvent_Asset_Bundle_Item__c(Cvent_Asset_Bundle__c=bundles[1].id, Cvent_Asset_Type__c=assetTypes[2].id, Quantity__c=1.4) );
        //bundle #3
        bundleItems.add( new Cvent_Asset_Bundle_Item__c(Cvent_Asset_Bundle__c=bundles[2].id, Cvent_Asset_Type__c=assetTypes[2].id, Quantity__c=1) );
        //bundle #4
        bundleItems.add( new Cvent_Asset_Bundle_Item__c(Cvent_Asset_Bundle__c=bundles[3].id, Cvent_Asset_Type__c=assetTypes[3].id, Quantity__c=0.8) );
        insert bundleItems;


        //Cvent Asset Subgroup & Bundle
        subgroupAndBundles = new List<Cvent_Asset_Subgroup_Bundle__c>();
        subgroupAndBundles.add( new Cvent_Asset_Subgroup_Bundle__c(Cvent_Asset_Bundle__c=bundles[0].id, Cvent_Asset_Subgroup__c=subgroups[0].id) );
        subgroupAndBundles.add( new Cvent_Asset_Subgroup_Bundle__c(Cvent_Asset_Bundle__c=bundles[1].id, Cvent_Asset_Subgroup__c=subgroups[1].id) );
        subgroupAndBundles.add( new Cvent_Asset_Subgroup_Bundle__c(Cvent_Asset_Bundle__c=bundles[2].id, Cvent_Asset_Subgroup__c=subgroups[2].id) );
        subgroupAndBundles.add( new Cvent_Asset_Subgroup_Bundle__c(Cvent_Asset_Bundle__c=bundles[3].id, Cvent_Asset_Subgroup__c=subgroups[3].id) );
        insert subgroupAndBundles;


        //Cvent Warehouse
        warehouses = new List<Cvent_Warehouse__c>();
        warehouses.add( new Cvent_Warehouse__c(name='Warehouse 1', Country__c = 'United States') );
        warehouses.add( new Cvent_Warehouse__c(name='Warehouse 2', Country__c = 'United States') );
        insert warehouses;


        //Asset
        assets = new List<Cvent_Asset__c>();
        assets.add ( new Cvent_Asset__c(Asset_Tag__c='001', Asset_Name__c = 'Asset 1', Cvent_Asset_Type__c = assetTypes[0].id, Location_Current__c = warehouses[0].id, Location_Home__c = warehouses[0].id, Condition__c = 'Functioning' ));
        assets.add ( new Cvent_Asset__c(Asset_Tag__c='002', Asset_Name__c = 'Asset 2', Cvent_Asset_Type__c = assetTypes[0].id, Location_Current__c = warehouses[0].id, Location_Home__c = warehouses[0].id, Condition__c = 'Functioning' ));
        assets.add ( new Cvent_Asset__c(Asset_Tag__c='003', Asset_Name__c = 'Asset 3', Cvent_Asset_Type__c = assetTypes[1].id, Location_Current__c = warehouses[0].id, Location_Home__c = warehouses[0].id, Condition__c = 'Functioning' ));
        assets.add ( new Cvent_Asset__c(Asset_Tag__c='004', Asset_Name__c = 'Asset 4', Cvent_Asset_Type__c = assetTypes[1].id, Location_Current__c = warehouses[0].id, Location_Home__c = warehouses[0].id, Condition__c = 'Functioning' ));
        insert assets;


        //Box Type
        boxTypes = new List<Cvent_Box_Type__c>();
        boxTypes.add ( new Cvent_Box_Type__c(Name='Box - S', Height_cm__c=1, Height_in__c=1, Length_cm__c=1, Length_in__c=1, Width_cm__c=1, Width_in__c=1));
        boxTypes.add ( new Cvent_Box_Type__c(Name='Box - S', Height_cm__c=2, Height_in__c=2, Length_cm__c=2, Length_in__c=2, Width_cm__c=2, Width_in__c=2));
        insert boxTypes;


        /* *********************** User created data *********************** */
        //Account
        Account a = new Account (   RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId(),
                                    Name = 'Test Account',
                                    BillingCountryCode = 'TR'
                                );
        insert a;

        //Contact
        //pse__Salesforce_User__c = UserInfo.getUserId()
        Contact pm = new Contact (  FirstName = 'Test PM Name', 
                                    LastName = 'Lastname', 
                                    Email='emre.yenier@cvent.com', 
                                    AccountId=a.id
                                );
        insert pm;
        System.assertNotEquals(null, pm, 'PM contact is null');
        if (pm <> null) {
            //CAM_Test_PopulateSetupData.setPMUser(pm.id);
        } 
        

        //RPG
        pse__Region__c region = new pse__Region__c(name = 'Test Region');
        pse__Practice__c practice = new pse__Practice__c(name = 'Test Practice');
        pse__Grp__c grp = new pse__Grp__c(name = 'Test Group');
        insert region;
        insert practice;
        insert grp;

        //Project
        //pse__Account__c = [SELECT ID FROM Account WHERE Name LIKE 'Cvent%' LIMIT 1][0].id,
        pse__Proj__c p = new pse__Proj__c(
                                            RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('Customer Project').getRecordTypeId(),
                                            Name = 'Test Project',
                                            pse__Start_Date__c = date.newInstance(2019, 01, 01),
                                            pse__End_Date__c = date.newInstance(2021, 01, 01),
                                            pse__Account__c = a.id,
                                            pse__Region__c = region.id,
                                            pse__Practice__c = practice.id,
                                            pse__Group__c = grp.id,
                                            pse__Project_Type__c = 'Customer Project',
                                            pse__Billing_Type__c = 'Time and Materials',
                                            Time_Approval_Method__c = 'Auto-Approve',
                                            Expense_Approval_Method__c = 'Auto-Approve',
                                            pse__Planned_Hours__c = 100,
                                            pse__Project_Manager__c = pm.id
                                            );
        List<User> userlist = [SELECT ID, Name FROM User WHERE Validation_Bypass__c = TRUE LIMIT 1];
        System.runAs (userlist[0]) {
            insert p;
        }

        //Event Data
        Event_Data__c ed = new Event_Data__c (
                                                RecordTypeId = Schema.SObjectType.Event_Data__c.getRecordTypeInfosByName().get('Conference Event Data').getRecordTypeId(),
                                                Name = p.name,
                                                Onsite__c = 'No',
                                                Project_Billing_Code__c = 'Test',
                                                Event_Start_Date__c = date.newInstance(2020, 06, 03),
                                                Event_Finish_Date__c = date.newInstance(2020, 06, 06),
                                                Project__c = p.id,
                                                Issue_Tracker__c = 'Yes',
                                                Link_to_Issue_Tracker__c = 'https://www.cvent.com/',
                                                Debrief_Status__c = 'N/A',
                                                International__c = 'No',
                                                Call_Center__c = 'None',
                                                Production_URL__c = 'https://www.cvent.com/',
                                                Staging_URL__c = 'https://www.cvent.com/',
                                                Hosting_Start_Date__c = date.newInstance(2019, 01, 01),
                                                Hosting_End_Date__c = date.newInstance(2021, 01, 01)
                                            );
        insert ed;

        //Onsite Hardware Request
        ohr = new List<Onsite_Hardware_Request__c>();
        ohr.add( new Onsite_Hardware_Request__c(    Event_Name__c = ed.id, 
                                                    Date_Drop_Off__c = datetime.newInstance(2020, 06, 01, 09, 00, 00),
                                                    Country__c = 'United States') );
        insert ohr;


        //Onsite Hardware Request Bundle
        ohrb = new List<Onsite_Hardware_Request_Bundle__c>();
        ohrb.add( new Onsite_Hardware_Request_Bundle__c(Onsite_Hardware_Request__c=ohr[0].id, Cvent_Asset_Subgroup_Bundle__c=subgroupAndBundles[0].id ,Requested_Quantity__c=10) );
        ohrb.add( new Onsite_Hardware_Request_Bundle__c(Onsite_Hardware_Request__c=ohr[0].id, Cvent_Asset_Subgroup_Bundle__c=subgroupAndBundles[1].id ,Requested_Quantity__c=1) );
        ohrb.add( new Onsite_Hardware_Request_Bundle__c(Onsite_Hardware_Request__c=ohr[0].id, Cvent_Asset_Subgroup_Bundle__c=subgroupAndBundles[2].id ,Requested_Quantity__c=2) );
        insert ohrb;


        //Onsite Hardware Request Item
        ohri = new List<Onsite_Hardware_Request_Item__c>();
        
        //bundle #1
        ohri.add( new Onsite_Hardware_Request_Item__c(  Onsite_Hardware_Request__c=ohr[0].id, 
                                                        Onsite_Hardware_Request_Bundle__c=ohrb[0].id, 
                                                        Requested_Quantity__c=(ohrb[0].Requested_Quantity__c * bundleItems[0].Quantity__c ),
                                                        Cvent_Asset_Type__c = assetTypes[0].id  ) );

        ohri.add( new Onsite_Hardware_Request_Item__c(  Onsite_Hardware_Request__c=ohr[0].id, 
                                                        Onsite_Hardware_Request_Bundle__c=ohrb[0].id, 
                                                        Requested_Quantity__c=(ohrb[0].Requested_Quantity__c * bundleItems[1].Quantity__c ),
                                                        Cvent_Asset_Type__c = assetTypes[1].id  ) );

        //bundle #2
        ohri.add( new Onsite_Hardware_Request_Item__c(  Onsite_Hardware_Request__c=ohr[0].id, 
                                                        Onsite_Hardware_Request_Bundle__c=ohrb[1].id, 
                                                        Requested_Quantity__c=(ohrb[1].Requested_Quantity__c * bundleItems[2].Quantity__c ),
                                                        Cvent_Asset_Type__c = assetTypes[0].id  ) );

        ohri.add( new Onsite_Hardware_Request_Item__c(  Onsite_Hardware_Request__c=ohr[0].id, 
                                                        Onsite_Hardware_Request_Bundle__c=ohrb[1].id, 
                                                        Requested_Quantity__c=(ohrb[1].Requested_Quantity__c * bundleItems[3].Quantity__c ),
                                                        Cvent_Asset_Type__c = assetTypes[1].id  ) );

        ohri.add( new Onsite_Hardware_Request_Item__c(  Onsite_Hardware_Request__c=ohr[0].id, 
                                                        Onsite_Hardware_Request_Bundle__c=ohrb[1].id, 
                                                        Requested_Quantity__c=(ohrb[1].Requested_Quantity__c * bundleItems[4].Quantity__c ),
                                                        Cvent_Asset_Type__c = assetTypes[2].id  ) );

        //bundle #3
        ohri.add( new Onsite_Hardware_Request_Item__c(  Onsite_Hardware_Request__c=ohr[0].id, 
                                                        Onsite_Hardware_Request_Bundle__c=ohrb[2].id, 
                                                        Requested_Quantity__c=(ohrb[2].Requested_Quantity__c * bundleItems[5].Quantity__c ),
                                                        Cvent_Asset_Type__c = assetTypes[2].id  ) );

        insert ohri;
        
        
        //Packlist
        packlists = new List<Packlist__c>();
        packlists.add (new Packlist__c( Name='Test Packlist 1',
                                        Onsite_Hardware_Request__c = ohr[0].id,
                                        Cvent_Warehouse__c = warehouses[0].id,
                                        Date_Shipment__c = date.newInstance(2020, 06, 01),
                                        International_Shipping__c = False ) );
        insert packlists;
        for (Onsite_Hardware_Request_Item__c oi1:ohri){
            oi1.Packlist__c = packlists[0].id;
        }
        update ohri;

        //Box
        boxes = new List<Cvent_Box__c>();
        boxes.add ( new Cvent_Box__c(Packlist__c = packlists[0].id, Number_in_Packlist__c=1, Cvent_Box_Type__c=boxTypes[0].id));
        boxes.add ( new Cvent_Box__c(Packlist__c = packlists[0].id, Number_in_Packlist__c=2, Cvent_Box_Type__c=boxTypes[0].id));
        insert boxes;

        //Packlist Items
        packlistItems = new List<Packlist_Item__c>();
        packlistItems.add ( new Packlist_Item__c(Onsite_Hardware_Request_Item__c = ohri[0].id, Cvent_Asset__c = assets[0].id, Cvent_Box__c = boxes[0].id));
        insert packlistItems;
        assets[0].Status__c = 'Deployed';
        update assets[0];

    }//populateData
}//class CAM_Test_PopulateData