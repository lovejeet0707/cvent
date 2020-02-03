/*
* Author: Sandeep Kumar
* Version: 1.0
* Date: 27 March, 2017
* Standard data template class for common objects.
* Method calls return objects with a minium amount of data for insert in test classes.
* These object should then be modified for and inserted 
*/
public class TestUtil {  
    
    /* Create Account Methods */
    public static  Account createAccount(String name, String RTName) {
        //We dont' use a lot of RT for accounts  
        Id rtId = RecordTypeUtil.getRecordTypeIDByDevName('Account',RTName);
        return new Account (name = name, recordTypeId = rtId, Service_Tier__c='Bronze', BillingCountryCode = 'US', BillingStateCode = 'NY', BillingPostalCode = '10001');
    }
    
    /* Create EB Agent Profile */
    public static  EB_Agent_Profile__c createEBAgentProfile(String name, Id userId, String agentSkillGroup) {
        return new EB_Agent_Profile__c (name = name, Current_Assignment__c = 'Available', Agent_Skill_Group__c = agentSkillGroup, Agent_Shift__c = 'US', 
                                        Max_Workload_Agent_Hrs__c = 100,Agent_Status__c = 'Tenured',Max_of_Projects_Per_Week__c = 3,
                                        Agent_Name__c = userId);
    }
    
    /* Create EB Agent Project Score Setting */
    public static  EB_Project_Score_Setting__c createEBProjScoreSetting(String name, String catType, Decimal catWeightage,Integer catPoint) {
        return new EB_Project_Score_Setting__c (name = name, EB_Category__c = catType, Category_Weightage__c = catWeightage, Points__c = catPoint);
    }
    
    /* Create Event Builder Question/Answer test records  */
    public static  Event_Builder_Survey_Q_A__c createEventBuilderQuestionAnswer(String questionName,String ansType,Integer sequence,String surveyType) {
        return new Event_Builder_Survey_Q_A__c (Answer_Type__c = ansType, Is_Question__c = true, Sequence__c = sequence, Survey_Type__c = surveyType);
    }
    
    /* Create EBProjectStageToPendingHrs Setting */
    public static  EBProjectStageToPendingHrsSetting__c createEbProjectStageToPendingHrsSetting(String name, Decimal advHrs, Decimal complxHrs,Decimal medHrs, Decimal simHrs) {
        return new EBProjectStageToPendingHrsSetting__c (name = name, AdvancedPendingHrs__c = advHrs, ComplexPendingHrs__c = complxHrs, MediumPendingHrs__c = medHrs,SimplePendingHrs__c = simHrs);
    }
    
    public static Account createAccount(String name ) {
        return TestUtil.createAccount(name, 'Account');        
    }
    
    public static AccountTeamMember createATM(String accountId, String userId){
        return new AccountTeamMember(AccountId=accountId, UserId=userId, 
                    TeamMemberRole='Technical Sales Manager');
    }
    
    /* Create Contact Methods */
    public static Contact createContact(String firstName, String lastName, String email, String accountId) {
        return new Contact(AccountId=accountId, FirstName=firstName, LastName=lastName,
                            Title='Dude', Department='Things', Email=email);
    }
    public static Contact createContact(String accountId) {
        // Generate a pseudo random contact info
        String rnd = System.now().getTime()+'-'+
                String.valueOf(Math.round(Math.random() * 100));
        String email = rnd +'_newuser@testorg.com';
        String firstName = 'John'+rnd;
        String lastName = 'Doe';
        return createContact(firstName, lastName, email, accountId);
    }
    
   /* Create Opportunity Methods and Helpers*/
    /*
     *  valid stages include Closed Won, Closed Lost, Bid Phase
     * just returns - required fields vary by Record Type
     */
    public static Opportunity createOpportunity(String theName, String rtDevName, String stageName){ 
        ID rtId = RecordTypeUtil.getRecordTypeIDByDevName('Opportunity',rtDevName);
        Decimal probability = getProbability(stageName); 
        
    Opportunity instOfOppSec = new Opportunity();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        //instOfOppSec.AccountId = instofAcc.id;
        instOfOppSec.Name = theName;
        instOfOppSec.Product__c = 'CSN';
        instOfOppSec.Contract_Number_New__c = '25512';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.StageName = stageName;
        instOfOppSec.CloseDate = system.today().addyears(1);
        instOfOppSec.RecordTypeId = rtId;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = '1';
       
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        instOfOppSec.Contact_Role__c = 'Influencer';
        instOfOppSec.ContractReceived__c = system.today();
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '2';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
        instOfOppSec.Send_This_To_Tract__c = true;
        
        instOfOppSec.Forex_rate__c = 1;
        
        instOfOppSec.Clubbed_Opportunity__c = true;
        
        return instOfOppSec;
        
    }    
    
    public static Opportunity createOpportunityNew(String oppName, String stageName,Id ContactId,Id accId){ 
        Opportunity instOfOppSec = new Opportunity();
        instOfOppSec.Name = 'Test Opp';
        instOfOppSec.Contact_Role__c = 'Influencer';
        instOfOppSec.Contact_Associated__c = ContactId;
        instOfOppSec.AccountId = accId;
        instOfOppSec.Name = oppName;
        instOfOppSec.StageName = stageName;
        instOfOppSec.CloseDate = system.today().addyears(1);
        instOfOppSec.Contact_Role__c = 'Influencer';
        
        return instOfOppSec;
        
    }    
    //create the case
    public static case createcase() {
    Case c = new Case();
    c.Product_Type__c = 'Event Tool';
    c.Subject = 'Test Subject';
    c.Description = 'Test Desc';
    c.Status = 'Open';
    c.Minutesoncase__c = 30; 
    return c;
       
    }
    
    //Create the Task
    Public static Task createtask(){
    Task t = new Task();
    t.Subject = 'test';
    t.Priority = 'Normal';
    t.ActivityDate = System.Today();
    return t;
    }                    
    
    //Create the Contact_Role__c 
     Public static Contact_Role__c createrole(){
     Contact_Role__c cr = new Contact_Role__c();
     cr.Product__c = 'Event';
     cr.Last_Login_Date__c = System.today() - 50;
     cr.User_Sub_Role__c = 'Community Portal Administrator';
     return cr;
     }  
     
     //Return the old records from Contact_Role__c object
     Public Static Contact_Role__c createoldcr(){
     Contact_Role__c Oldcr2 = new Contact_Role__c();
    // Oldcr2.RecordTypeId= custRectypeId;
    // Oldcr2.Contact__c = con.Id;
    // Oldcr2.Account_Customer_Role__c = acc.Id;
     Oldcr2.Product__c = 'Event';
     Oldcr2.Last_Login_Date__c = System.today() - 50;
     Oldcr2.User_Sub_Role__c = 'Community Portal Administrator';
     return Oldcr2 ;

     }    
    
    
    private static Map<String, Decimal> probabilityStageNameMap = new Map<String, Decimal>();
    public static Decimal getProbability(String stage) {
        if (probabilityStageNameMap == null) {
            probabilityStageNameMap = new Map<String, Decimal>();
            for (OpportunityStage oppStage : [Select MasterLabel, DefaultProbability From OpportunityStage]) {
                probabilityStageNameMap.put(oppStage.MasterLabel, oppStage.DefaultProbability);
            }
        }
        return probabilityStageNameMap.get(stage);
    }
    
    public static List<Product2> createProducts(List<String> products){
        List<Product2> productList = new List<Product2> ();
        for (String productName:products ){
            productList.add(new Product2(name = productName));
        }
        return productList;
    }
    
    public static PricebookEntry createPricebookEntry(Product2 product,Decimal price ) {
        return createPricebookEntry(new Pricebook2(Id=Test.getStandardPricebookId()),product,price);
    }
    
    public static PricebookEntry createPricebookEntry(Pricebook2 pricebook, Product2 product, Decimal price ) {
        return new PricebookEntry(
            Product2Id = product.Id,
            PriceBook2Id = pricebook.Id,
            UnitPrice = price,
            UseStandardPrice = false,
            isactive = true
        );
    }
    
    public static  OpportunityLineItem createOpportunityLineItems(Opportunity opp, PricebookEntry pbe){
        
        return new OpportunityLineItem ( 
            OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            of_Items__c = 4,
            UnitPrice = pbe.UnitPrice 
         );
    }
    
    /* Create OpportunityTeamMember Methods */
   /* public static OpportunityTeamMember createOTM(String oppId, String userId) {
        return new OpportunityTeamMember(OpportunityId=oppId, UserId=userId, 
                    TeamMemberRole='Sales Engineer');
    }
   */ 
    
    /* Create User Methods */
    public static User createUser(String profileID) {
        // Generate a pseudo random user email
        String uniqueKey = System.now().getTime()+'-'+
                String.valueOf(Math.round(Math.random() * 100));
        // Get a new user object from createUser(String, String)
        return TestUtil.createUser(profileID, uniqueKey+'_newuser@testorg.com');
    }
    
    public static User createUser(String profileID, String Email) {
        // Check if the profile Id is valid
        if (!UserProfileUtil.validProfile(profileID)){
            throw new InvalidIdException('The ProfileID provided is not a valid Profile Id.');
        }
        // Initialize a new user
        User testUser = new User(Alias = 'newUser', Email=Email, 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = (Id) profileID, FederationIdentifier=Email,
        TimeZoneSidKey='America/Los_Angeles', UserName=Email);
        // Return new user object
        return testUser;
    }
    
    
    /* Create Attachment Methods */
   /* public static Attachment createAttachment(Id parentId) {
        return TestUtil.createAttachment(parentId,'someName');
    }
    
    public static Attachment createAttachment(Id parentId, String attachmentName) {
        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = parentId;
        attachment.Name = attachmentName;
        attachment.Body = b;
        return attachment;
    }
    */
    /*
    Below method add by kumud to create data for test classes
    Date : 9March2018
    */
    
    public static Address__c createAccountAddress(ID accID,String typeOfAddress ){
        
        
        Address__c address = new Address__c();
        address.Type__c = typeOfAddress;
        address.Account__c = accID;
        return address;
    }
    
    public static EBS_Orders__c createEBSOrder(Id oppId,String productLine,string headerId){
        
         EBS_Orders__c instorder = new EBS_Orders__c();
         instorder.Opportunity__c = oppId;
         instorder.EBS_Order_Number__c = 'OR-54564';
         instorder.EBS_Order_Status__c = 'New';
         instorder.EBS_Quote_Number__c = 'QA-154455';
         instorder.EBS_Header_ID__c = headerId;
         instorder.Product_Line__c = productLine;
        
         return instorder;
    }
    
    public static EBS_Integration__c createEbsIntegration(string name,String objectName){
        
        EBS_Integration__c eIntegration = new EBS_Integration__c();
        eIntegration.Name = name;
        eIntegration.Object__c = objectName;
        eIntegration.Map__c =true;
        eIntegration.Field__c = 'Name';
        eIntegration.Validate__c=true;
        
        return eIntegration;
        
    }
    
    /* Custom exception class that can be thrown while executing methods in this class */
    public class InvalidIdException extends Exception {} 
    
    //Added by kumud thakur on 30/05/18
    public static User CreateDeploymentUser(){
        
        Id profileId = [Select id from profile where name='System Administrator'].id;
        
        user instUsr = new user();
        instUsr.username = 'deploymentuser@cvent.com.testclass';
       // instUsr.username ='deploymentuser@cvent.com';
        instUsr.ProfileId = profileId;
        instUsr.LastName = 'test'; 
        instUsr.Email = 'abc@abc.com';
        instUsr.Alias = 'alias';
        instUsr.TimeZoneSidKey = 'America/Los_Angeles';
        instUsr.EmailEncodingKey = 'UTF-8';
        instUsr.LanguageLocaleKey = 'en_US'; 
        instUsr.LocaleSidKey = 'en_US';
        
        return instUsr;
    }
    
    //Added by kumud thakur on 30/05/18
    public static Contract CreateContract(Account accId,Id OpptyId){
        
        Contract instContract=new Contract();
        instContract.AccountId=accId.id;
        instContract.name='test';
        instContract.startdate=system.today();
        instContract.enddate=system.today()+12;
        instContract.SBQQ__Opportunity__c=OpptyId;
        
        return instContract;
    }
    
    
    public static AccountTeamMember createAccountTeamMember(ID AccountID, String teamRole){
        
        AccountTeamMember instAccTeam=new AccountTeamMember();
        instAccTeam.AccountID=AccountID;
        instAccTeam.TeamMemberRole=teamRole;
        instAccteam.userid=userinfo.getUserId();
        return instAccTeam;
        
        
    }
    public static AccountTeamMember createAccountTeamMember(Id accountId, Id userId, String teamMemberRole){
        
        AccountTeamMember instAccTeam=new AccountTeamMember();
        instAccTeam.AccountId = accountId;
        instAccTeam.TeamMemberRole = teamMemberRole;
        instAccteam.userId = userId;
        return instAccTeam;
    }
}