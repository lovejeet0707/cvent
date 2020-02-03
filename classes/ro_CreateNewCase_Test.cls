@isTest
public class ro_CreateNewCase_Test {
    static testMethod void myUnitTest() {
     TabConfiguration__c oTabConfiguration = new TabConfiguration__c();
     oTabConfiguration.Name = 'Internal';
     oTabConfiguration.Tabs__c = 'home,articles,training,guides,lanyoncommunities,ideas,support';
     insert oTabConfiguration;
     
     CategoryMapping__c oCategoryMapping = new CategoryMapping__c();
     oCategoryMapping.Name = 'Internal';
     oCategoryMapping.Actual_Community_Name__c = 'Internal';
     oCategoryMapping.Category__c = 'REGONLINE';
     oCategoryMapping.Category_Group__c = 'CATEGORIES';
     oCategoryMapping.Product__c = 'RegOnline';
     oCategoryMapping.Product_Family_Name__c = 'RegOnline';
     oCategoryMapping.OwnerId__c = userinfo.getUserId();
     insert oCategoryMapping;
     
     system.debug('@Developer -->oCategoryMapping:' +ro_ConfigHelper.self.oCategoryMapping); 
       
	    ro_CreateNewCase rcn = new ro_CreateNewCase();
	    rcn.saveAndAddAttachment();
	    rcn.save();
	      
	    Account oAccount = new Account();
					oAccount.Name = 'Lanyon Master';
  		 insert oAccount;
        
     Contact oContact = new Contact();
					oContact.AccountID = oAccount.id;
					oContact.FirstName = 'Fname';
					oContact.LastName = 'Lname';	
					oContact.Email = 'test@test.com';
					insert oContact;
    
	    User_Contact_Relation__c ucr = new User_Contact_Relation__c();
	    ucr.User__c = Userinfo.getUserId();
	    ucr.Related_Contact__c = oContact.Id;
	    ucr.sfxId__c = 'NIK16514344';
	    insert ucr;
     
     rcn = new ro_CreateNewCase();
					rcn.PopulateAccountId();
					rcn.c.Subject = 'Test Subject';
					rcn.c.Description = 'Test Description';
					rcn.c.Customer_Impact__c = 'Test Impact';
					rcn.saveAndAddAttachment();
    	
    	rcn.isSite = true;
    	rcn.sFirstName = 'fname';
					rcn.sLastName = 'lname';
					rcn.sEmail = 'email@email.com';
					rcn.sCompanyName = 'compname';
    	rcn.save();

	    ro_AccountSelectionController rac = new ro_AccountSelectionController();
    }
}